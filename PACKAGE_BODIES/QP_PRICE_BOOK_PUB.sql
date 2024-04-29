--------------------------------------------------------
--  DDL for Package Body QP_PRICE_BOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_BOOK_PUB" AS
/*$Header: QPXPPRBB.pls 120.17 2006/04/27 15:13 rchellam noship $*/

--Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_PRICE_BOOK_PUB';

/*****************************************************************************
 Public API to Create and Publish Full/Delta Price Book
*****************************************************************************/
PROCEDURE Create_Publish_Price_Book(
             p_pb_input_header_rec     IN pb_input_header_rec,
             p_pb_input_lines_tbl      IN pb_input_lines_tbl,
             x_request_id              OUT NOCOPY NUMBER,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_retcode                 OUT NOCOPY NUMBER,
             x_err_buf                 OUT NOCOPY VARCHAR2,
             x_price_book_messages_tbl OUT NOCOPY price_book_messages_tbl)
IS
  l_user_id 		NUMBER;
  l_login_id 		NUMBER;
  l_sysdate 		DATE;
  l_pb_input_header_rec		pb_input_header_rec;
  l_pb_input_header_id		NUMBER;
  l_full_pb_input_header_id 	NUMBER;
  l_message_text  	VARCHAR2(2000);

  l_context_tbl		QP_PRICE_BOOK_UTIL.VARCHAR30_TYPE;
  l_attribute_tbl       QP_PRICE_BOOK_UTIL.VARCHAR30_TYPE;
  l_attribute_value_tbl QP_PRICE_BOOK_UTIL.VARCHAR_TYPE;
  l_attribute_type_tbl  QP_PRICE_BOOK_UTIL.VARCHAR30_TYPE;

BEGIN

  l_sysdate := sysdate;
  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  x_return_status := 'S';

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP'); --specifying an MOAC enabled application although
                          --org context is based on the current responsibility
--    MO_GLOBAL.set_policy_context('M', null);--commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL

  --Assign input parameter to local variable so that columns can be modified.
  l_pb_input_header_rec := p_pb_input_header_rec;

  --Perform Value To Id conversion
  QP_PRICE_BOOK_UTIL.Convert_PB_Input_Value_to_Id(l_pb_input_header_rec);
                                                       --IN OUT parameter

  --Perform Defaulting
  QP_PRICE_BOOK_UTIL.Default_PB_Input_Criteria(l_pb_input_header_rec);
                                                       --IN OUT parameter

  --IF publishing an existing price book
  IF l_pb_input_header_rec.publish_existing_pb_flag = 'Y' THEN

    BEGIN
      SELECT pb_input_header_id
      INTO   l_pb_input_header_id
      FROM   qp_pb_input_headers_vl
      WHERE  price_book_name = l_pb_input_header_rec.price_book_name
      AND    customer_attr_value = l_pb_input_header_rec.customer_attr_value
      AND    customer_context = 'CUSTOMER'
      AND    customer_attribute = 'QUALIFIER_ATTRIBUTE2'
      AND    price_book_type_code = l_pb_input_header_rec.price_book_type_code;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INPUT_REC_NOT_FOUND');
        l_message_text := FND_MESSAGE.GET;
        BEGIN
          SELECT qp_price_book_messages_s.nextval
          INTO   x_price_book_messages_tbl(1).message_id FROM dual;
        EXCEPTION
          WHEN OTHERS THEN
            x_price_book_messages_tbl(1).message_id := NULL;
        END;
        x_price_book_messages_tbl(1).message_type := 'E';
        x_price_book_messages_tbl(1).message_code := 'QP_INPUT_REC_NOT_FOUND';
        x_price_book_messages_tbl(1).message_text := l_message_text;
        x_price_book_messages_tbl(1).creation_date := l_sysdate;
        x_price_book_messages_tbl(1).created_by := l_user_id;
        x_price_book_messages_tbl(1).last_update_date := l_sysdate;
        x_price_book_messages_tbl(1).last_updated_by := l_user_id;
        x_price_book_messages_tbl(1).last_update_login := l_login_id;
        RETURN;
    END;

    UPDATE qp_pb_input_headers_b
    SET    publish_existing_pb_flag =
                       l_pb_input_header_rec.publish_existing_pb_flag,
           dlv_xml_flag = l_pb_input_header_rec.dlv_xml_flag,
           pub_template_code = l_pb_input_header_rec.pub_template_code,
           pub_language = l_pb_input_header_rec.pub_language,
           pub_territory = l_pb_input_header_rec.pub_territory,
           pub_output_document_type =
                       l_pb_input_header_rec.pub_output_document_type,
           dlv_email_flag = l_pb_input_header_rec.dlv_email_flag,
           dlv_email_addresses = l_pb_input_header_rec.dlv_email_addresses,
           dlv_printer_flag = l_pb_input_header_rec.dlv_printer_flag,
           dlv_printer_name = l_pb_input_header_rec.dlv_printer_name,
           dlv_xml_site_id = l_pb_input_header_rec.dlv_xml_site_id,
           generation_time_code = l_pb_input_header_rec.generation_time_code,
           gen_schedule_date = l_pb_input_header_rec.gen_schedule_date,
           request_origination_code = 'API',
           last_update_date = l_sysdate,
           last_updated_by = l_user_id,
           last_update_login = l_login_id
    WHERE  pb_input_header_id = l_pb_input_header_id;

    UPDATE qp_pb_input_headers_tl
    SET    pub_template_name = l_pb_input_header_rec.pub_template_name,
           last_update_date = l_sysdate,
           last_updated_by = l_user_id,
           last_update_login = l_login_id
    WHERE  pb_input_header_id = l_pb_input_header_id;

  ELSE --Creating price book

    IF l_pb_input_header_rec.price_book_type_code = 'D' THEN
      --Delta Price Book. Insert input records where all columns other than
      --effective_date and publishing criteria are same as corresponding full
      --price book

      --Fetch pb_input_header_id of corresponding full price book
      BEGIN
        SELECT pb_input_header_id
        INTO   l_full_pb_input_header_id
        FROM   qp_pb_input_headers_vl
        WHERE  price_book_name = l_pb_input_header_rec.price_book_name
        AND    customer_attr_value = l_pb_input_header_rec.customer_attr_value
        AND    customer_context = 'CUSTOMER'
        AND    customer_attribute = 'QUALIFIER_ATTRIBUTE2'
        AND    price_book_type_code = 'F';
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_FULL_PRICE_BOOK_MUST_EXIST');
          l_message_text := FND_MESSAGE.GET;
          BEGIN
            SELECT qp_price_book_messages_s.nextval
            INTO   x_price_book_messages_tbl(1).message_id FROM dual;
          EXCEPTION
            WHEN OTHERS THEN
            x_price_book_messages_tbl(1).message_id := NULL;
          END;
          x_price_book_messages_tbl(1).message_type := 'E';
          x_price_book_messages_tbl(1).message_code :=
                                 'QP_FULL_PRICE_BOOK_MUST_EXIST';
          x_price_book_messages_tbl(1).message_text := l_message_text;
          x_price_book_messages_tbl(1).creation_date := l_sysdate;
          x_price_book_messages_tbl(1).created_by := l_user_id;
          x_price_book_messages_tbl(1).last_update_date := l_sysdate;
          x_price_book_messages_tbl(1).last_updated_by := l_user_id;
          x_price_book_messages_tbl(1).last_update_login := l_login_id;
          RETURN;
      END;

      --Fetch values of certain columns from the corresponding columns of the
      --full price book
      BEGIN
        SELECT customer_context, customer_attribute, customer_attr_value,
               cust_account_id, --internal id for customer number
               currency_code, limit_products_by, product_context,
               product_attribute, product_attr_value,
               item_quantity, org_id, price_based_on, pl_agr_bsa_id,
               pricing_perspective_code, request_type_code,
               pl_agr_bsa_name
        INTO   l_pb_input_header_rec.customer_context,
               l_pb_input_header_rec.customer_attribute,
               l_pb_input_header_rec.customer_attr_value,
               l_pb_input_header_rec.cust_account_id,
               l_pb_input_header_rec.currency_code,
               l_pb_input_header_rec.limit_products_by,
               l_pb_input_header_rec.product_context,
               l_pb_input_header_rec.product_attribute,
               l_pb_input_header_rec.product_attr_value,
               l_pb_input_header_rec.item_quantity,
               l_pb_input_header_rec.org_id,
               l_pb_input_header_rec.price_based_on,
               l_pb_input_header_rec.pl_agr_bsa_id,
               l_pb_input_header_rec.pricing_perspective_code,
               l_pb_input_header_rec.request_type_code,
               l_pb_input_header_rec.pl_agr_bsa_name
        FROM   qp_pb_input_headers_vl
        WHERE  pb_input_header_id = l_full_pb_input_header_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_FULL_PRICE_BOOK_MUST_EXIST');
          l_message_text := FND_MESSAGE.GET;
          BEGIN
            SELECT qp_price_book_messages_s.nextval
            INTO   x_price_book_messages_tbl(1).message_id FROM dual;
          EXCEPTION
            WHEN OTHERS THEN
            x_price_book_messages_tbl(1).message_id := NULL;
          END;
          x_price_book_messages_tbl(1).message_type := 'E';
          x_price_book_messages_tbl(1).message_code :=
                                 'QP_FULL_PRICE_BOOK_MUST_EXIST';
          x_price_book_messages_tbl(1).message_text := l_message_text;
          x_price_book_messages_tbl(1).creation_date := l_sysdate;
          x_price_book_messages_tbl(1).created_by := l_user_id;
          x_price_book_messages_tbl(1).last_update_date := l_sysdate;
          x_price_book_messages_tbl(1).last_updated_by := l_user_id;
          x_price_book_messages_tbl(1).last_update_login := l_login_id;
          RETURN;
      END;

      INSERT INTO qp_pb_input_headers_b
      ( pb_input_header_id, customer_context, customer_attribute,
        customer_attr_value, cust_account_id,
        dlv_xml_site_id, currency_code, limit_products_by,
        product_context, product_attribute, product_attr_value,
        effective_date, item_quantity,
        dlv_xml_flag, pub_template_code, pub_language, pub_territory,
        pub_output_document_type,
        dlv_email_flag, dlv_email_addresses, dlv_printer_flag,
        dlv_printer_name, generation_time_code, gen_schedule_date,
        --request_id,
        org_id, price_book_type_code, price_based_on, pl_agr_bsa_id,
        pricing_perspective_code,
        publish_existing_pb_flag, overwrite_existing_pb_flag,
        request_origination_code,
        request_type_code,
        --validation_error_flag,
        creation_date, created_by, last_update_date, last_updated_by,
        last_update_login
      )
      VALUES(
        qp_pb_input_headers_b_s.nextval,
        l_pb_input_header_rec.customer_context,
        l_pb_input_header_rec.customer_attribute,
        l_pb_input_header_rec.customer_attr_value,
        l_pb_input_header_rec.cust_account_id,
        l_pb_input_header_rec.dlv_xml_site_id,
        l_pb_input_header_rec.currency_code,
        l_pb_input_header_rec.limit_products_by,
        l_pb_input_header_rec.product_context,
        l_pb_input_header_rec.product_attribute,
        l_pb_input_header_rec.product_attr_value,
        l_pb_input_header_rec.effective_date,
        l_pb_input_header_rec.item_quantity,
        l_pb_input_header_rec.dlv_xml_flag,
        l_pb_input_header_rec.pub_template_code,
        l_pb_input_header_rec.pub_language,
        l_pb_input_header_rec.pub_territory,
        l_pb_input_header_rec.pub_output_document_type,
        l_pb_input_header_rec.dlv_email_flag,
        l_pb_input_header_rec.dlv_email_addresses,
        l_pb_input_header_rec.dlv_printer_flag,
        l_pb_input_header_rec.dlv_printer_name,
        l_pb_input_header_rec.generation_time_code,
        l_pb_input_header_rec.gen_schedule_date,
        --request_id, --not populated with a value at this point
        l_pb_input_header_rec.org_id,
        l_pb_input_header_rec.price_book_type_code,
        l_pb_input_header_rec.price_based_on,
        l_pb_input_header_rec.pl_agr_bsa_id,
        l_pb_input_header_rec.pricing_perspective_code,
        l_pb_input_header_rec.publish_existing_pb_flag,
        l_pb_input_header_rec.overwrite_existing_pb_flag,
        l_pb_input_header_rec.request_origination_code,
        l_pb_input_header_rec.request_type_code,
        --l_pb_input_header_rec.validation_error_flag, --not populated
        l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id)
      RETURNING pb_input_header_id
      INTO l_pb_input_header_id;

      INSERT INTO qp_pb_input_headers_tl
      (pb_input_header_id, price_book_name, pl_agr_bsa_name,
       pub_template_name, creation_date, created_by,
       last_update_date, last_updated_by,
       last_update_login, language, source_lang
      )
      SELECT
        l_pb_input_header_id,
        l_pb_input_header_rec.price_book_name,
        l_pb_input_header_rec.pl_agr_bsa_name,
        l_pb_input_header_rec.pub_template_name,
        l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id,
        l.language_code,
        userenv('LANG')
      FROM  fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND   NOT EXISTS (SELECT NULL
                        FROM   qp_pb_input_headers_tl t
                        WHERE  t.pb_input_header_id =
                                 l_pb_input_header_id
                        AND    t.language = l.language_code);


      --Select the certain columns of input lines from the full price book
      BEGIN
        SELECT context, attribute, attribute_value, attribute_type
        BULK COLLECT INTO l_context_tbl, l_attribute_tbl,
        l_attribute_value_tbl, l_attribute_type_tbl
        FROM   qp_pb_input_lines
        WHERE  pb_input_header_id = l_full_pb_input_header_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      --Insert the Input criteria into input lines tables
      FORALL k IN l_context_tbl.FIRST..l_context_tbl.LAST
        INSERT INTO qp_pb_input_lines
        (pb_input_line_id, pb_input_header_id,
         context, attribute, attribute_value,
         attribute_type, creation_date, created_by, last_update_date,
         last_updated_by, last_update_login
        )
        VALUES
        (qp_pb_input_lines_s.nextval,
         l_pb_input_header_id,
         l_context_tbl(k), l_attribute_tbl(k),
         l_attribute_value_tbl(k), l_attribute_type_tbl(k),
         l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id
        );

    ELSE --Not Delta price book request

      --Insert the Input criteria into the price book input header tables
      INSERT INTO qp_pb_input_headers_b
      (pb_input_header_id, customer_context, customer_attribute,
       customer_attr_value, cust_account_id,
       dlv_xml_site_id, currency_code, limit_products_by,
       product_context, product_attribute, product_attr_value,
       effective_date, item_quantity,
       dlv_xml_flag, pub_template_code, pub_language, pub_territory,
       pub_output_document_type,
       dlv_email_flag, dlv_email_addresses, dlv_printer_flag,
       dlv_printer_name, generation_time_code, gen_schedule_date,
       --request_id,
       org_id, price_book_type_code, price_based_on, pl_agr_bsa_id,
       pricing_perspective_code,
       publish_existing_pb_flag, overwrite_existing_pb_flag,
       request_origination_code,
       request_type_code,
       --validation_error_flag,
       creation_date, created_by, last_update_date, last_updated_by,
       last_update_login
      )
      VALUES
      (qp_pb_input_headers_b_s.nextval,
       l_pb_input_header_rec.customer_context,
       l_pb_input_header_rec.customer_attribute,
       l_pb_input_header_rec.customer_attr_value,
       l_pb_input_header_rec.cust_account_id,
       l_pb_input_header_rec.dlv_xml_site_id,
       l_pb_input_header_rec.currency_code,
       l_pb_input_header_rec.limit_products_by,
       l_pb_input_header_rec.product_context,
       l_pb_input_header_rec.product_attribute,
       l_pb_input_header_rec.product_attr_value,
       l_pb_input_header_rec.effective_date,
       l_pb_input_header_rec.item_quantity,
       l_pb_input_header_rec.dlv_xml_flag,
       l_pb_input_header_rec.pub_template_code,
       l_pb_input_header_rec.pub_language,
       l_pb_input_header_rec.pub_territory,
       l_pb_input_header_rec.pub_output_document_type,
       l_pb_input_header_rec.dlv_email_flag,
       l_pb_input_header_rec.dlv_email_addresses,
       l_pb_input_header_rec.dlv_printer_flag,
       l_pb_input_header_rec.dlv_printer_name,
       l_pb_input_header_rec.generation_time_code,
       l_pb_input_header_rec.gen_schedule_date,
       --l_pb_input_header_rec.request_id,
       l_pb_input_header_rec.org_id,
       l_pb_input_header_rec.price_book_type_code,
       l_pb_input_header_rec.price_based_on,
       l_pb_input_header_rec.pl_agr_bsa_id,
       l_pb_input_header_rec.pricing_perspective_code,
       l_pb_input_header_rec.publish_existing_pb_flag,
       l_pb_input_header_rec.overwrite_existing_pb_flag,
       l_pb_input_header_rec.request_origination_code,
       l_pb_input_header_rec.request_type_code,
       --l_pb_input_header_rec.validation_error_flag,
       l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id
      ) RETURNING pb_input_header_id INTO
        l_pb_input_header_id;

      INSERT INTO qp_pb_input_headers_tl
      (pb_input_header_id, price_book_name, pl_agr_bsa_name,
       pub_template_name, creation_date, created_by,
       last_update_date, last_updated_by,
       last_update_login, language, source_lang
      )
      SELECT
        l_pb_input_header_id,
        l_pb_input_header_rec.price_book_name,
        l_pb_input_header_rec.pl_agr_bsa_name,
        l_pb_input_header_rec.pub_template_name,
        l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id,
        l.language_code,
        userenv('LANG')
      FROM  fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND   NOT EXISTS (SELECT NULL
                        FROM   qp_pb_input_headers_tl t
                        WHERE  t.pb_input_header_id =
                                 l_pb_input_header_id
                        AND    t.language = l.language_code);


      --Insert the Input criteria into input lines tables
      IF p_pb_input_lines_tbl.COUNT > 0 THEN
        FOR k IN p_pb_input_lines_tbl.FIRST..p_pb_input_lines_tbl.LAST
        LOOP
          l_context_tbl(k) := p_pb_input_lines_tbl(k).context;
          l_attribute_tbl(k) := p_pb_input_lines_tbl(k).attribute;
          l_attribute_value_tbl(k) := p_pb_input_lines_tbl(k).attribute_value;
          l_attribute_type_tbl(k) := p_pb_input_lines_tbl(k).attribute_type;
        END LOOP;
      END IF; --If p_pb_input_lines_tbl.count > 0

      FORALL i IN l_context_tbl.FIRST..l_context_tbl.LAST
        INSERT INTO qp_pb_input_lines
        (pb_input_line_id, pb_input_header_id,
         context, attribute, attribute_value,
         attribute_type, creation_date, created_by, last_update_date,
         last_updated_by, last_update_login
        )
        VALUES
        (qp_pb_input_lines_s.nextval, l_pb_input_header_id,
         l_context_tbl(i), l_attribute_tbl(i),
         l_attribute_value_tbl(i),
         l_attribute_type_tbl(i),
         l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id
        );

    END IF; --If Delta Price Book request

  END IF; --If publishing existing price book

  QP_PRICE_BOOK_PVT.Generate_Publish_Price_Book(
              p_pb_input_header_id => l_pb_input_header_id,
              x_request_id  => x_request_id,
              x_return_status => x_return_status,
              x_retcode => x_retcode,
              x_err_buf => x_err_buf);

  IF x_return_status = 'E' THEN --If input validation errors occur
    SELECT * BULK COLLECT INTO x_price_book_messages_tbl
    FROM   qp_price_book_messages
    WHERE  pb_input_header_id = l_pb_input_header_id;

    DELETE FROM qp_price_book_messages
    WHERE  pb_input_header_id = l_pb_input_header_id;

    DELETE FROM qp_pb_input_headers_b
    WHERE  pb_input_header_id = l_pb_input_header_id;

    DELETE FROM qp_pb_input_headers_tl
    WHERE  pb_input_header_id = l_pb_input_header_id;

    DELETE FROM qp_pb_input_lines
    WHERE  pb_input_header_id = l_pb_input_header_id;

  END IF;

  --Commit Stmt may be needed here

END Create_Publish_Price_Book;


/*****************************************************************************
 Public API to Query an existing Full/Delta Price Book
*****************************************************************************/
PROCEDURE Get_Price_Book(
    p_price_book_name 		     IN VARCHAR2,
    p_customer_id         	     IN NUMBER,
    p_price_book_type_code	     IN VARCHAR2,
    x_price_book_header_rec 	    OUT NOCOPY price_book_header_rec,
    x_price_book_lines_tbl 	    OUT NOCOPY price_book_lines_tbl,
    x_price_book_line_details_tbl   OUT NOCOPY price_book_line_details_tbl,
    x_price_book_attributes_tbl     OUT NOCOPY price_book_attributes_tbl,
    x_price_book_break_lines_tbl    OUT NOCOPY price_book_break_lines_tbl,
    x_price_book_messages_tbl 	    OUT NOCOPY price_book_messages_tbl,
    x_return_status  		    OUT NOCOPY VARCHAR2,
    x_query_messages  		    OUT NOCOPY VARCHAR_TBL)
IS
i  		NUMBER := 1;
l_count 	NUMBER;
l_message_text 	VARCHAR2(2000);
l_customer_id 	NUMBER;
l_user_id   	NUMBER;
l_party_id_match   VARCHAR2(1);

BEGIN

  x_return_status := 'S';

  l_user_id := fnd_global.user_id;

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP'); --specifying an MOAC enabled application although
                          --org context is based on the current responsibility
--    MO_GLOBAL.set_policy_context('M', null);--commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL

  IF p_price_book_type_code IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_PARAMETER_REQUIRED');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_PRICE_BOOK_TYPE_CODE');
    l_message_text := FND_MESSAGE.GET;
    x_query_messages(i) := substr(l_message_text, 1, 240);
    i := i + 1;
  ELSE
    IF NOT (p_price_book_type_code = 'F' OR p_price_book_type_code = 'D') THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_PARAMETER');
      FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_PRICE_BOOK_TYPE_CODE');
      l_message_text := FND_MESSAGE.GET;
      x_query_messages(i) := substr(l_message_text, 1, 240);
      i := i + 1;
    END IF;
  END IF;

  IF p_price_book_name IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_PARAMETER_REQUIRED');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_PRICE_BOOK_NAME');
    l_message_text := FND_MESSAGE.GET;
    x_query_messages(i) := substr(l_message_text, 1, 240);
    i := i + 1;
  END IF;

  IF p_customer_id IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_PARAMETER_REQUIRED');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_CUSTOMER_ID');
    l_message_text := FND_MESSAGE.GET;
    x_query_messages(i) := substr(l_message_text, 1, 240);
    i := i + 1;
  ELSE
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
       --Check if the customer id on pb matches the parent org of the
       --customer associated with user
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
             AND party5.party_id = l_customer_id --customer id on user
             AND party4.party_id = p_customer_id);--customer id of pb
       EXCEPTION
         WHEN OTHERS THEN
           l_party_id_match := 'N';
       END;

       IF p_customer_id <> l_customer_id AND l_party_id_match <> 'Y'
       THEN
         x_return_status := 'E';
         FND_MESSAGE.SET_NAME('QP', 'QP_CUSTOMER_NOT_MATCHING');
         l_message_text := FND_MESSAGE.GET;
         x_query_messages(i) := substr(l_message_text, 1, 240);
         i := i + 1;
       END IF;

     ELSE -- Internal User
       BEGIN
         SELECT 1
         INTO   l_count
         FROM   hz_parties
         WHERE  party_id = p_customer_id
         AND    rownum = 1;
       EXCEPTION
         WHEN OTHERS THEN
           l_count := 0;
       END;

       IF l_count = 0 AND p_customer_id <> -1 THEN -- invalid customer
         x_return_status := 'E';
         FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_CUSTOMER');
         l_message_text := FND_MESSAGE.GET;
         x_query_messages(i) := substr(l_message_text, 1, 240);
         i := i + 1;
       END IF;

     END IF; --External User

  END IF;

  IF x_return_status = 'E' THEN
    RETURN;
  END IF;

  --Query price book
  BEGIN
    SELECT price_book_header_id,
           price_book_type_code,
           currency_code,
           effective_date,
           org_id,
           customer_id,
           cust_account_id,
           document_id,
           item_category,
           price_based_on,
           pl_agr_bsa_id,
           pricing_perspective_code,
           item_quantity,
           request_id,
           request_type_code,
           pb_input_header_id,
           pub_status_code,
           price_book_name,
           pl_agr_bsa_name,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           price_book_type,
           currency,
           operating_unit,
           customer_name
    INTO   x_price_book_header_rec
    FROM   qp_price_book_headers_v
    WHERE  price_book_name = p_price_book_name
    AND    price_book_type_code = p_price_book_type_code
    AND    customer_id = p_customer_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_PRICE_BOOK_DOES_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME', p_price_book_name);
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_TYPE_CODE', p_price_book_type_code);
      l_message_text := FND_MESSAGE.GET;
      x_query_messages(i) := substr(l_message_text, 1, 240);
      RETURN;
  END;

  SELECT price_book_line_id, price_book_header_id, item_number,
         product_uom_code, list_price, net_price, sync_action_code,
         line_status_code, creation_date, created_by, last_update_date,
         last_updated_by, last_update_login, description, customer_item_number,
         customer_item_desc, display_item_number, sync_action
  BULK COLLECT INTO x_price_book_lines_tbl
  FROM   qp_price_book_lines_v
  WHERE  price_book_header_id = x_price_book_header_rec.price_book_header_id;

  SELECT price_book_line_det_id, price_book_line_id, price_book_header_id,
         list_header_id, list_line_id, list_line_no, list_price,
         modifier_operand, modifier_application_method, adjustment_amount,
         adjusted_net_price, list_line_type_code, price_break_type_code,
         creation_date, created_by, last_update_date, last_updated_by,
         last_update_login, list_name, list_line_type, price_break_type,
         application_method_name
  BULK COLLECT INTO x_price_book_line_details_tbl
  FROM   qp_price_book_line_details_v
  WHERE  price_book_header_id = x_price_book_header_rec.price_book_header_id;

  SELECT price_book_attribute_id, price_book_line_det_id, price_book_line_id,
         price_book_header_id, pricing_prod_context, pricing_prod_attribute,
         comparison_operator_code, pricing_prod_attr_value_from,
         pricing_attr_value_to, pricing_prod_attr_datatype, attribute_type,
         creation_date, created_by, last_update_date, last_updated_by,
         last_update_login, context_name, attribute_name, attribute_value_name,
         attribute_value_to_name, comparison_operator_name
  BULK COLLECT INTO x_price_book_attributes_tbl
  FROM   qp_price_book_attributes_v
  WHERE  price_book_header_id = x_price_book_header_rec.price_book_header_id;

  SELECT price_book_break_line_id, price_book_header_id, price_book_line_id,
         price_book_line_det_id, pricing_context, pricing_attribute,
         comparison_operator_code, pricing_attr_value_from,
         pricing_attr_value_to, pricing_attribute_datatype, operand,
         application_method, recurring_value,
         creation_date, created_by, last_update_date,
         last_updated_by, last_update_login, context_name, attribute_name,
         attribute_value_name, attribute_value_to_name,
         comparison_operator_name, application_method_name
  BULK COLLECT INTO x_price_book_break_lines_tbl
  FROM   qp_price_book_break_lines_v
  WHERE  price_book_header_id = x_price_book_header_rec.price_book_header_id;

  SELECT * BULK COLLECT INTO x_price_book_messages_tbl
  FROM   qp_price_book_messages
  WHERE  price_book_header_id = x_price_book_header_rec.price_book_header_id;

END Get_Price_Book;

/*****************************************************************************
 Overloaded Public API to Query an existing Full/Delta Price Book along with
 the attached formatted (.pdf, etc.) document
*****************************************************************************/
PROCEDURE Get_Price_Book(
    p_price_book_name                IN VARCHAR2,
    p_customer_id                    IN NUMBER,
    p_price_book_type_code           IN VARCHAR2,
    x_price_book_header_rec         OUT NOCOPY price_book_header_rec,
    x_price_book_lines_tbl          OUT NOCOPY price_book_lines_tbl,
    x_price_book_line_details_tbl   OUT NOCOPY price_book_line_details_tbl,
    x_price_book_attributes_tbl     OUT NOCOPY price_book_attributes_tbl,
    x_price_book_break_lines_tbl    OUT NOCOPY price_book_break_lines_tbl,
    x_price_book_messages_tbl       OUT NOCOPY price_book_messages_tbl,
    x_documents_rec                 OUT NOCOPY documents_rec,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_query_messages                OUT NOCOPY VARCHAR_TBL)
IS
BEGIN

  --Call the Get_Price_Book without the x_documents_rec parameter
  Get_Price_Book(
    p_price_book_name	=> p_price_book_name,
    p_customer_id     	=> p_customer_id,
    p_price_book_type_code 	=> p_price_book_type_code,
    x_price_book_header_rec 	=> x_price_book_header_rec,
    x_price_book_lines_tbl 	=> x_price_book_lines_tbl,
    x_price_book_line_details_tbl => x_price_book_line_details_tbl,
    x_price_book_attributes_tbl   => x_price_book_attributes_tbl,
    x_price_book_break_lines_tbl  => x_price_book_break_lines_tbl,
    x_price_book_messages_tbl     => x_price_book_messages_tbl,
    x_return_status  => x_return_status,
    x_query_messages => x_query_messages);

  IF x_return_status = 'S' THEN
    IF x_price_book_header_rec.document_id IS NOT NULL THEN
      BEGIN
        SELECT document_id, document_content, document_content_type,
               document_name, creation_date, created_by, last_update_date,
               last_updated_by, last_update_login
        INTO   x_documents_rec
        FROM   qp_documents
        WHERE  document_id = x_price_book_header_rec.document_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  END IF;

END Get_Price_Book; --Overloaded

END QP_PRICE_BOOK_PUB;

/
