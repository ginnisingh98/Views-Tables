--------------------------------------------------------
--  DDL for Package Body ASO_CONTRACT_TERMS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CONTRACT_TERMS_INT" AS
/* $Header: asoiktcb.pls 120.1.12010000.2 2009/08/20 07:35:58 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_Contract_Terms_INT
-- Purpose          :
-- History          :
--    10-29-2002 hyang - created
-- NOTE             :
-- End of Comments

  g_pkg_name           CONSTANT VARCHAR2 (30) := 'ASO_Contract_Terms_INT';
  g_file_name          CONSTANT VARCHAR2 (12) := 'asoiktcb.pls';

  G_ITEMS_CODE                  CONSTANT VARCHAR2(30)   := 'OKC$S_ITEMS';
  G_ITEM_CATEGORIES_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_ITEM_CATEGORIES';
  G_PA_NUMBER_CODE              CONSTANT VARCHAR2(30)   := 'OKC$S_PA_NUMBER';
  G_PA_NAME_CODE                CONSTANT VARCHAR2(30)   := 'OKC$S_PA_NAME';
  G_QUOTE_NUMBER_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_QUOTE_NUMBER';
  G_CUSTOMER_NAME_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUSTOMER_NAME';
  G_CUSTOMER_NUMBER_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CUSTOMER_NUMBER';
  G_CUST_PO_NUMBER_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_PO_NUMBER';
  G_VERSION_NUMBER_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_VERSION_NUMBER';
  G_CUST_CONTACT_NAME_CODE      CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CONTACT_NAME';
  G_SALESREP_NAME_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_SALESREP_NAME';
  G_CURRENCY_CODE_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CURRENCY_CODE';
  G_FREIGHT_TERMS_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_FREIGHT_TERMS';
  G_SHIPPING_METHOD_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPPING_METHOD';
  G_PAYMENT_TERM_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_PAYMENT_TERM';
  G_SUPPLIER_NAME_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_SUPPLIER_NAME';
  G_CURRENCY_NAME_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CURRENCY_NAME';
  G_CURRENCY_SYMBOL_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CURRENCY_SYMBOL';


  PROCEDURE Get_Article_Variable_Values (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_sys_var_value_tbl         IN OUT NOCOPY /* file.sql.39 change */    OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type
  ) IS

    l_api_version               NUMBER          := 1.0;
    l_api_name                  VARCHAR2 (50)   := 'Get_Line_Variable_Values';
    l_index                     BINARY_INTEGER;

    l_contract_id               NUMBER;
    l_quote_number              NUMBER;
    l_cust_party_id             NUMBER;
    l_cust_account_id           NUMBER;
    l_cust_po_number            VARCHAR2 (50);
    l_quote_version             NUMBER;
    l_party_id                  NUMBER;
    l_resource_id               NUMBER;
    l_currency_code             VARCHAR2 (15);
    l_freight_terms_code        VARCHAR2 (30);
    l_ship_method_code          VARCHAR2 (30);
    l_payment_term_id           NUMBER;
    l_org_id                    NUMBER;

    CURSOR c_qte_header_variables
    IS
      SELECT quote.contract_id, quote.quote_number, quote.cust_party_id, quote.cust_account_id,
        quote.quote_version, quote.party_id, quote.resource_id,
        quote.currency_code, quote.org_id
      FROM aso_quote_headers_all quote
      WHERE quote.quote_header_id = p_doc_id;

   CURSOR c_qte_payments_variable
   IS
      SELECT payments.cust_po_number, payments.payment_term_id
      FROM aso_quote_headers_all quote, aso_payments payments
      WHERE quote.quote_header_id = payments.quote_header_id
        AND payments.quote_line_id IS NULL
        AND quote.quote_header_id = p_doc_id;

    CURSOR c_qte_shipments_variables
    IS
      SELECT shipments.freight_terms_code, shipments.ship_method_code
      FROM aso_quote_headers_all quote, aso_shipments shipments
      WHERE quote.quote_header_id = shipments.quote_header_id
        AND shipments.quote_line_id IS NULL
        AND quote.quote_header_id = p_doc_id;

  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- API body
    --
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values Begin',
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: P_API_VERSION '|| p_api_version,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: P_INIT_MSG_LIST '|| p_init_msg_list,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: p_doc_id '|| p_doc_id,
        1,
        'Y'
      );
    END IF;

    OPEN c_qte_header_variables ;
    FETCH c_qte_header_variables INTO
      l_contract_id,
      l_quote_number,
      l_cust_party_id,
      l_cust_account_id,
      l_quote_version,
      l_party_id,
      l_resource_id,
      l_currency_code,
      l_org_id;
    CLOSE c_qte_header_variables;

    OPEN c_qte_payments_variable ;
    FETCH c_qte_payments_variable INTO
      l_cust_po_number,
      l_payment_term_id;
    CLOSE c_qte_payments_variable;

    OPEN c_qte_shipments_variables ;
    FETCH c_qte_shipments_variables INTO
      l_freight_terms_code,
      l_ship_method_code;
    CLOSE c_qte_shipments_variables;

    l_index := p_sys_var_value_tbl.FIRST;

    WHILE l_index IS NOT NULL
    LOOP

      IF p_sys_var_value_tbl(l_index).Variable_code = G_PA_NUMBER_CODE
        AND l_contract_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning PA_NUMBER: ' || l_contract_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_contract_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_PA_NAME_CODE
        AND l_contract_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning PA_NAME: ' || l_contract_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_contract_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_QUOTE_NUMBER_CODE
        AND l_quote_number IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning QUOTE_NUMBER: ' || l_quote_number,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_quote_number);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CUSTOMER_NAME_CODE
        AND l_cust_party_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CUSTOMER_NAME: ' || l_cust_party_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_cust_party_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CUSTOMER_NUMBER_CODE
        AND l_cust_account_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CUSTOMER_NUMBER: ' || l_cust_account_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_cust_account_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CUST_PO_NUMBER_CODE
        AND l_cust_po_number IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CUST_PO_NUMBER: ' || l_cust_po_number,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := l_cust_po_number;

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_VERSION_NUMBER_CODE
        AND l_quote_version IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning VERSION_NUMBER: ' || l_quote_version,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_quote_version);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CUST_CONTACT_NAME_CODE
        AND l_party_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CUST_CONTACT_NAME: ' || l_party_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_party_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_SALESREP_NAME_CODE
        AND l_resource_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning SALESREP_NAME: ' || l_resource_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_resource_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CURRENCY_CODE_CODE
        AND l_currency_code IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CURRENCY_CODE: ' || l_currency_code,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := l_currency_code;

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_FREIGHT_TERMS_CODE
        AND l_freight_terms_code IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning FREIGHT_TERMS: ' || l_freight_terms_code,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := l_freight_terms_code;

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_SHIPPING_METHOD_CODE
        AND l_ship_method_code IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning SHIPPING_METHOD: ' || l_ship_method_code,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := l_ship_method_code;

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_PAYMENT_TERM_CODE
        AND l_payment_term_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning PAYMENT_TERM: ' || l_payment_term_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_payment_term_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_SUPPLIER_NAME_CODE
        AND l_org_id IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning SUPPLIER_NAME: ' || l_org_id,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := TO_CHAR(l_org_id);

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CURRENCY_NAME_CODE
        AND l_currency_code IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CURRENCY_NAME: ' || l_currency_code,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := l_currency_code;

      ELSIF p_sys_var_value_tbl(l_index).Variable_code = G_CURRENCY_SYMBOL_CODE
        AND l_currency_code IS NOT NULL
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add(
            'Get_Line_Variable_Values assigning CURRENCY_SYMBOL: ' || l_currency_code,
            1,
            'Y');
        END IF;
        p_sys_var_value_tbl(l_index).Variable_value_id := l_currency_code;

      END IF;

      l_index := p_sys_var_value_tbl.next(l_index);
    END LOOP;

    --
    -- End of API body.
    --

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add(
        'Get_Line_Variable_Values End ',
        1,
        'Y');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );

  END Get_Article_Variable_Values;

  PROCEDURE Get_Line_Variable_Values (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_variables_tbl             IN        OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
    x_line_var_value_tbl        OUT NOCOPY /* file.sql.39 change */       OKC_TERMS_UTIL_GRP.item_dtl_tbl
  ) IS

    l_api_version               NUMBER          := 1.0;
    l_api_name                  VARCHAR2 (50)   := 'Get_Line_Variable_Values';
    l_index                     BINARY_INTEGER;
    TYPE l_table_type           is table of varchar2(2000);
    l_table                     l_table_type;

  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- API body
    --
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values Begin',
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: P_API_VERSION '|| p_api_version,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: P_INIT_MSG_LIST '|| p_init_msg_list,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: p_doc_id '|| p_doc_id,
        1,
        'Y'
      );
    END IF;

    l_index := p_variables_tbl.FIRST;

    WHILE l_index IS NOT NULL
    LOOP

      IF p_variables_tbl(l_index).Variable_code = G_ITEMS_CODE
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Get_Line_Variable_Values: bulk collecting items',
            1,
            'Y'
          );
        END IF;

        SELECT DISTINCT Segment1
        BULK COLLECT INTO x_line_var_value_tbl.item
        FROM Mtl_System_Items_b items, Aso_Quote_Lines_All lines
        WHERE lines.inventory_item_id = items.INVENTORY_ITEM_ID
          AND lines.organization_id = items.organization_id
          AND lines.LINE_CATEGORY_CODE = 'ORDER'
          AND lines.quote_header_id = p_doc_id;

      ELSIF p_variables_tbl(l_index).Variable_code = G_ITEM_CATEGORIES_CODE
      THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Get_Line_Variable_Values: bulk collecting items categories',
            1,
            'Y'
          );
        END IF;

        SELECT DISTINCT Category_Concat_Segs
        BULK COLLECT INTO x_line_var_value_tbl.category
        FROM Mtl_Item_Categories mic, Aso_Quote_Lines_All lines, Mtl_Categories_V cats
        WHERE lines.inventory_item_id = mic.INVENTORY_ITEM_ID
          AND mic.category_id = cats.category_id
          AND mic.organization_id = lines.organization_id
          AND mic. category_set_id =
            (SELECT nvl(FND_PROFILE.VALUE('ASO_CATEGORY_SET'), sets.category_set_id )
              FROM Mtl_Default_Category_Sets sets
              WHERE functional_area_id = 7)
          AND lines.LINE_CATEGORY_CODE = 'ORDER'
          AND lines.quote_header_id = p_doc_id;

      END IF;

      l_index := p_variables_tbl.next(l_index);
    END LOOP;

    --
    -- End of API body.
    --

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add(
        'Get_Line_Variable_Values End ',
        1,
        'Y');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );

  END Get_Line_Variable_Values;

  FUNCTION OK_To_Commit (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_doc_type                  IN        VARCHAR2 := 'QUOTE',
    p_validation_string         IN        VARCHAR2
  ) RETURN VARCHAR2 IS

    l_api_version               NUMBER          := 1.0;
    l_api_name                  VARCHAR2 (50)   := 'OK_To_Commit';
    l_max_version_flag          VARCHAR2 (1);
    l_update_allowed            VARCHAR2 (1);
    l_quote_version             NUMBER;
    l_quote_expiration_date     DATE;
    l_price_request_id          NUMBER;
    l_return                    VARCHAR2 (1)    := FND_API.G_TRUE;

    l_status_override	        VARCHAR2(1); -- bug 8811226

    CURSOR c_quote_header
    IS
      SELECT status.update_allowed_flag, quote.quote_expiration_date,
        quote.max_version_flag, quote.price_request_id
      FROM aso_quote_headers_all quote, aso_quote_statuses_b status
      WHERE quote.quote_header_id = p_doc_id
        AND quote.quote_status_id = status.quote_status_id;

  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- API body
    --
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'OK_To_Commit Begin',
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: P_API_VERSION '|| p_api_version,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: P_INIT_MSG_LIST '|| p_init_msg_list,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: p_doc_id '|| p_doc_id,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: p_doc_type '|| p_doc_type,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: p_validation_string '|| p_validation_string,
        1,
        'Y'
      );
    END IF;

    IF p_doc_type <> 'QUOTE'
    THEN
      l_return  := FND_API.G_FALSE;
    ELSE

      OPEN c_quote_header ;
      FETCH c_quote_header INTO l_update_allowed, l_quote_expiration_date,
        l_max_version_flag, l_price_request_id;
      IF (c_quote_header%NOTFOUND)
      THEN
        l_return  := FND_API.G_FALSE;
      END IF;
      CLOSE c_quote_header;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'OK_To_Commit: l_update_allowed '|| l_update_allowed,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: l_quote_expiration_date '|| l_quote_expiration_date,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: l_max_version_flag '|| l_max_version_flag,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'OK_To_Commit: l_price_request_id '|| l_price_request_id,
        1,
        'Y'
      );
    END IF;


     -- bug 8811226
     l_status_override := nvl(fnd_profile.value('ASO_STATUS_OVERRIDE'),'N');

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'OK_To_Commit: l_status_override '|| l_status_override,
        1,
        'Y'
      );

     END IF;
     If l_status_override = 'Y' then
	l_update_allowed := 'Y';
     END IF;



      IF (trunc(sysdate) > trunc(l_quote_expiration_date))
        OR l_update_allowed = 'N'
        OR l_max_version_flag = 'N'
        OR l_price_request_id IS NOT NULL
      THEN
     	    l_return  := FND_API.G_FALSE;
      END IF;

    END IF;
    --
    -- End of API body.
    --

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add(
        'OK_To_Commit End ',
        1,
        'Y');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );
  RETURN l_return;
  END OK_To_Commit;

END ASO_Contract_Terms_INT;

/
