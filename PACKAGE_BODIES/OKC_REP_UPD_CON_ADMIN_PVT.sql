--------------------------------------------------------
--  DDL for Package Body OKC_REP_UPD_CON_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_UPD_CON_ADMIN_PVT" AS
 /* $Header: OKCVREPUADB.pls 120.26 2006/08/18 02:05:23 vamuru noship $ */

   ---------------------------------------------------------------------------
   -- GLOBAL CONSTANTS
   ---------------------------------------------------------------------------
   G_RETURN_CODE_SUCCESS     CONSTANT NUMBER := 0;
   G_DOC_TYPE_ANY            CONSTANT VARCHAR2(10) := 'A_ALL';
   G_DOC_TYPE_ALL_OM         CONSTANT VARCHAR2(15) := 'SA_ORDER_MGMT';
   G_DOC_TYPE_BSA            CONSTANT VARCHAR2(10) := 'B';
   G_DOC_TYPE_SO             CONSTANT VARCHAR2(10) := 'O';
   G_DOC_TYPE_QUOTE          CONSTANT VARCHAR2(10) := 'QUOTE';
   G_DOC_TYPE_REP            CONSTANT VARCHAR2(10) := 'A_REP';
   G_MODE_UPDATE             CONSTANT VARCHAR2(10) := 'UPDATE';

   G_CON_ADMIN_FROM_NEW           CONSTANT VARCHAR2(20) := 'NEW_CON_ADMIN';
   G_CON_ADMIN_FROM_SALES_GROUP   CONSTANT VARCHAR2(20) := 'SALES_GROUP_ASMT';

   G_ERROR_CODE              CONSTANT VARCHAR2(10) := 'E';
   G_WARNING_CODE            CONSTANT VARCHAR2(10) := 'W';

   ---------------------------------------------------------------------------
   -- START: Procedures and Functions
   ---------------------------------------------------------------------------

   PROCEDURE populate_output_and_log_file(
                        p_doc_type                IN VARCHAR2,
                        p_con_number              IN VARCHAR2,
                        p_cust_name               IN VARCHAR2,
                        p_doc_type_name           IN VARCHAR2,
                        p_current_con_admin       IN VARCHAR2,
                        p_new_con_admin           IN VARCHAR2,
                        p_operating_unit          IN VARCHAR2,
                        p_msg_type                IN VARCHAR2,
                        p_msg_code                IN VARCHAR2,
                        p_doc_index               IN NUMBER
    ) IS

      l_api_name          VARCHAR2(30);

    BEGIN

      l_api_name := 'populate_output_and_log_file';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
          'Entered OKC_REP_UPD_CON_ADMIN_PVT.populate_output_and_log_file');
      END IF;

      -- Show the text Contract Details only once
      IF (p_doc_index = 1) THEN

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_CONTRACT_DETAILS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '================');
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_CONTRACT_DETAILS'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, '================');

      END IF;

      -- Document Type
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_DOC_TYPE') || '                 : ' || p_doc_type_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_DOC_TYPE') || '                 : ' || p_doc_type_name);

      -- Operating Unit
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_OPERATING_UNIT') || '                : ' || p_operating_unit);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_OPERATING_UNIT') || '                : ' || p_operating_unit);

      -- Contract Number
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_NUMBER') || '               : '|| p_con_number);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_NUMBER') || '               : '|| p_con_number);

      -- Customer
      IF (p_cust_name IS NOT NULL) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CUSTOMER') || '                      : ' || p_cust_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CUSTOMER') || '                      : ' || p_cust_name);
      ELSE
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CUSTOMER') || '                      : ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_NOT_AVAILABLE'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CUSTOMER') || '                      : ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_NOT_AVAILABLE'));
      END IF;

      -- Current Contract Administrator
      IF (p_current_con_admin IS NOT NULL) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CURR_CON_ADMIN') || ': ' || p_current_con_admin);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CURR_CON_ADMIN') || ': ' || p_current_con_admin);
      ELSE
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CURR_CON_ADMIN') || ': ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_NOT_AVAILABLE'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CURR_CON_ADMIN') || ': ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_NOT_AVAILABLE'));
      END IF;

      -- New Contract Administrator
      IF(p_new_con_admin IS NOT NULL) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_NEW_CON_ADMIN') || '    : ' || p_new_con_admin);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_NEW_CON_ADMIN') || '    : ' || p_new_con_admin);
      END IF;

      -- Error Message
      IF( p_msg_type = G_ERROR_CODE) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_ADMIN_ERR_MSG') || '                 : ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, p_msg_code));
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_ADMIN_ERR_MSG') || '                 : ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, p_msg_code));
      ELSIF (p_msg_type = G_WARNING_CODE) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_ADMIN_WARN_MSG') || '               : ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, p_msg_code));
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_ADMIN_WARN_MSG') || '               : ' || OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, p_msg_code));
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '====================================');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '====================================');

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
          'Leaving OKC_REP_UPD_CON_ADMIN_PVT.populate_output_and_log_file');
      END IF;

   END populate_output_and_log_file;



   PROCEDURE populate_report_parameters(
      p_doc_type              IN VARCHAR2,
      p_cust_id               IN NUMBER,
      p_prev_con_admin_id     IN NUMBER,
      p_salesrep_id           IN NUMBER,
      p_sales_group_id        IN NUMBER,
      p_org_id                IN NUMBER,
      p_order_type_id         IN NUMBER,
      p_new_con_admin_user_id IN NUMBER,
      p_mode                  IN VARCHAR2)IS

    l_api_name          VARCHAR2(30);

    CURSOR con_admin_name_csr IS
        SELECT  per.full_name
        FROM  fnd_user fu,
              per_all_people_f per
        WHERE fu.user_id = p_prev_con_admin_id
        AND   per.person_id = fu.employee_id;

    CURSOR doc_type_name_csr IS
        SELECT name
        FROM   okc_bus_doc_types_tl
        WHERE  document_type = p_doc_type
        AND    language = userenv('LANG');

    CURSOR doc_type_name_lkp_csr IS
        SELECT meaning
        FROM   fnd_lookups
        WHERE  lookup_code = p_doc_type
        AND    lookup_type = 'OKC_REP_DOC_TYPE_GROUPS';

    CURSOR customer_name_csr IS
        SELECT party_name
        FROM   hz_parties
        WHERE  party_id = p_cust_id;

    CURSOR ou_name_csr IS
        SELECT name
        FROM   hr_all_organization_units
        WHERE  organization_id = p_org_id;

    CURSOR salesperson_name_csr IS
        SELECT jtf_res.resource_name
        FROM   jtf_rs_salesreps s,
               jtf_rs_resource_extns_vl jtf_res
        WHERE  s.salesrep_id = p_salesrep_id
        AND    s.resource_id = jtf_res.resource_id;

    CURSOR trans_type_name_csr IS
        SELECT name
        FROM   oe_transaction_types_tl
        WHERE  transaction_type_id = p_order_type_id
        AND    language = userenv('LANG');

    CURSOR sales_grp_name_csr IS
        SELECT group_name
        FROM   jtf_rs_groups_tl
        WHERE  group_id = p_sales_group_id
        AND    language = userenv('LANG');

    l_doc_type_name okc_bus_doc_types_tl.name%TYPE;
    l_cust_name hz_parties.party_name%TYPE;
    l_ou_name hr_all_organization_units.name%TYPE;
    l_salesperson_name jtf_rs_salesreps.name%TYPE;
    l_trans_type_name oe_transaction_types_tl.name%TYPE;
    l_sales_grp_name jtf_rs_groups_tl.group_name%TYPE;
    l_con_admin_name per_all_people_f.full_name%TYPE;
    l_not_available_text fnd_new_messages.message_text%TYPE;

    BEGIN

      l_api_name := 'populate_report_parameters';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
          'Entered OKC_REP_UPD_CON_ADMIN_PVT.populate_report_parameters');
      END IF;

      -- Get the translated string for the text "Not Available"
      l_not_available_text := OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_NOT_AVAILABLE');


      -- Get Contract Administrator name
      IF (p_prev_con_admin_id IS NOT NULL) THEN
        OPEN  con_admin_name_csr;
        FETCH con_admin_name_csr INTO l_con_admin_name;
        CLOSE con_admin_name_csr;
      ELSE
        l_con_admin_name := l_not_available_text;
      END IF;

      -- Get Document Type name
      IF (p_doc_type = G_DOC_TYPE_ANY OR
          p_doc_type = G_DOC_TYPE_ALL_OM OR
          p_doc_type = G_DOC_TYPE_REP) THEN
        OPEN  doc_type_name_lkp_csr;
        FETCH doc_type_name_lkp_csr INTO l_doc_type_name;
        CLOSE doc_type_name_lkp_csr;
      ELSE
        OPEN  doc_type_name_csr;
        FETCH doc_type_name_csr INTO l_doc_type_name;
        CLOSE doc_type_name_csr;
      END IF;


      -- Get Customer name
      IF (p_cust_id IS NOT NULL) THEN
        OPEN  customer_name_csr;
        FETCH customer_name_csr INTO l_cust_name;
        CLOSE customer_name_csr;
      ELSE
        l_cust_name := l_not_available_text;
      END IF;


      -- Get Operating Unit name
      IF (p_org_id IS NOT NULL) THEN
        OPEN  ou_name_csr;
        FETCH ou_name_csr INTO l_ou_name;
        CLOSE ou_name_csr;
      ELSE
        l_ou_name := l_not_available_text;
      END IF;


      -- Get Salesperson name
      IF (p_salesrep_id IS NOT NULL) THEN
        OPEN  salesperson_name_csr;
        FETCH salesperson_name_csr INTO l_salesperson_name;
        CLOSE salesperson_name_csr;
      ELSE
        l_salesperson_name := l_not_available_text;
      END IF;


      -- Get Transaction Type name
      IF (p_order_type_id IS NOT NULL) THEN
        OPEN  trans_type_name_csr;
        FETCH trans_type_name_csr INTO l_trans_type_name;
        CLOSE trans_type_name_csr;
      ELSE
        l_trans_type_name := l_not_available_text;
      END IF;


      -- Get Sales Group name
      IF (p_sales_group_id IS NOT NULL) THEN
        OPEN  sales_grp_name_csr;
        FETCH sales_grp_name_csr INTO l_sales_grp_name;
        CLOSE sales_grp_name_csr;
      ELSE
        l_sales_grp_name := l_not_available_text;
      END IF;

      -- Populate the title
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_CON_ADMIN_NAME'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

      -- Populate log/output files with Report Parameters
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_REP_PARAMS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=================');

      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_REP_PARAMS'));
      FND_FILE.PUT_LINE(FND_FILE.LOG, '=================');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_DOC_TYPE') || ': '|| l_doc_type_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_DOC_TYPE') || ': '|| l_doc_type_name);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CUSTOMER') || ': '|| l_cust_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CUSTOMER') || ': '|| l_cust_name);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_ADMIN') || ': '|| l_con_admin_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_ADMIN') || ': '|| l_con_admin_name);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_OPERATING_UNIT') || ': '|| l_ou_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_OPERATING_UNIT') || ': '|| l_ou_name);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_SALESPERSON') || ': '|| l_salesperson_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_SALESPERSON') || ': '|| l_salesperson_name);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_ORDER_TYPE') || ': '|| l_trans_type_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_ORDER_TYPE') || ': '|| l_trans_type_name);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_SALES_GROUP') || ': '|| l_sales_grp_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_SALES_GROUP') || ': '|| l_sales_grp_name);

      -- Show the action parameter value
      IF (p_mode = G_MODE_UPDATE) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_CON_ADMIN_ACT') || ': '|| OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ACT_UPDATE'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_CON_ADMIN_ACT') || ': '|| OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ACT_UPDATE'));
      ELSE
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_CON_ADMIN_ACT') || ': '|| OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ACT_VIEW'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_UPD_CON_ADMIN_ACT') || ': '|| OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ACT_VIEW'));
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG, '');


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
          'Leaving OKC_REP_UPD_CON_ADMIN_PVT.populate_report_parameters');
      END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                g_module || l_api_name,
                'Leaving populate_report_parameters because of EXCEPTION: ' || sqlerrm);
       END IF;

       FND_FILE.PUT_LINE(FND_FILE.LOG,
           'Leaving populate_report_parameters because of EXCEPTION: ' ||
           sqlerrm);

       --close cursors
       IF (con_admin_name_csr%ISOPEN) THEN
         CLOSE con_admin_name_csr ;
       END IF;
       IF (doc_type_name_csr%ISOPEN) THEN
         CLOSE doc_type_name_csr ;
       END IF;
       IF (doc_type_name_lkp_csr%ISOPEN) THEN
         CLOSE doc_type_name_lkp_csr ;
       END IF;
       IF (customer_name_csr%ISOPEN) THEN
         CLOSE customer_name_csr ;
       END IF;
       IF (ou_name_csr%ISOPEN) THEN
         CLOSE ou_name_csr ;
       END IF;
       IF (salesperson_name_csr%ISOPEN) THEN
         CLOSE salesperson_name_csr ;
       END IF;
       IF (trans_type_name_csr%ISOPEN) THEN
         CLOSE trans_type_name_csr ;
       END IF;
       IF (sales_grp_name_csr%ISOPEN) THEN
         CLOSE sales_grp_name_csr ;
       END IF;
       ROLLBACK TO OKC_REP_UPD_CON_ADMIN_PVT;

   END populate_report_parameters;


   -- Start of comments
   --API name      : update_con_admin_manager
   --Type          : Private.
   --Function      : API to update Contract Administrator of Blanket Sales
   --                Agreements, Sales Orders, Quotes and Repository Contracts
   --                (Sell and Other intent only)
   --Pre-reqs      : None.
   --Parameters    :
   --IN            : errbuf                  OUT NUMBER
   --              : retcode                 OUT VARCHAR2
   --              : p_doc_type              IN VARCHAR2    Required
   --                   Type of contracts whose administrator need to be modified
   --              : p_cust_id               IN NUMBER      Optional
   --                   Customer of contracts whose administrator need to be modified
   --              : p_prev_con_admin_id     IN NUMBER      Optional
   --                   Existing administrator of contracts whose administrator need to be modified
   --              : p_salesrep_id           IN NUMBER      Optional
   --                   Salesperson of contracts whose administrator need to be modified
   --              : p_sales_group_id        IN NUMBER      Optional
   --                   Sales Group of quotes whose administrator need to be modified
   --              : p_org_id                IN NUMBER      Optional
   --                   Operating unit of contracts whose administrator need to be modified
   --              : p_order_type_id         IN NUMBER      Optional
   --                   Order type of contracts whose administrator need to be modified
   --              : p_new_con_admin_id      IN NUMBER      Optional
   --                   New Contract Administrator Id
   --              : p_new_con_admin_name    IN VARCHAR2    Optional
   --                   New Contract Administrator Name
   --              : p_mode                  IN VARCHAR2    Optional
   --                   Mode of operation Preview Only or Update
   --              : p_con_admin_from        IN VARCHAR2    Required
   --                   Contract Administrator from, possible values are NEW_CON_ADMIN or SALES_GROUP_ASMT
   --Note          :
   -- End of comments
     PROCEDURE update_con_admin_manager(
       errbuf                  OUT NOCOPY VARCHAR2,
       retcode                 OUT NOCOPY VARCHAR2,
       p_doc_type              IN VARCHAR2,
       p_cust_id               IN NUMBER,
       p_prev_con_admin_id     IN NUMBER,
       p_salesrep_id           IN NUMBER,
       p_sales_group_id        IN NUMBER,
       p_org_id                IN NUMBER,
       p_order_type_id         IN NUMBER,
       p_new_con_admin_user_id IN NUMBER,
       p_new_con_admin_name    IN VARCHAR2,
       p_mode                  IN VARCHAR2,
       p_con_admin_from        IN VARCHAR2
       )IS

        l_api_name          VARCHAR2(30);

        CURSOR selected_bsa_csr IS
            SELECT  header.header_id AS contract_id,
                    header.order_number AS contract_number,
                    customer.party_name AS customer,
                    doc_type.name AS document_type,
                    hr.name AS operating_unit,
                    t.contract_admin_id AS contract_admin_id
            FROM  oe_blanket_headers header,
                  okc_template_usages t,
                  hz_parties customer,
                  hz_cust_accounts  hzc,
                  okc_bus_doc_types_tl doc_type,
                  hr_all_organization_units_tl hr
            WHERE t.document_type = 'B'
            AND   header.header_id = t.document_id
            AND   header.sold_to_org_id = hzc.cust_account_id (+)
            AND   hzc.party_id = customer.party_id (+)
            AND   (p_cust_id IS NULL OR customer.party_id = p_cust_id)
            AND   (p_prev_con_admin_id IS NULL OR t.contract_admin_id = p_prev_con_admin_id)
            AND   (p_salesrep_id IS NULL OR header.salesrep_id = p_salesrep_id)
            AND   (p_org_id IS NULL OR header.org_id = p_org_id)
            AND   (p_order_type_id IS NULL OR header.order_type_id = p_order_type_id)
            AND   doc_type.document_type = t.document_type
            AND   doc_type.language = USERENV('LANG')
            AND   hr.organization_id = header.org_id
            AND   hr.language = USERENV('LANG')
            AND   (p_new_con_admin_user_id IS NULL OR
                   t.contract_admin_id is null OR
                   t.contract_admin_id <> p_new_con_admin_user_id);

        CURSOR selected_so_csr IS
            SELECT  header.header_id AS contract_id,
                    header.order_number AS contract_number,
                    customer.party_name customer,
                    doc_type.name AS document_type,
                    hr.name AS operating_unit,
                    t.contract_admin_id AS contract_admin_id
            FROM  oe_order_headers  header,
                  okc_template_usages t,
                  hz_parties customer,
                  hz_cust_accounts  hzc,
                  okc_bus_doc_types_tl doc_type,
                  hr_all_organization_units_tl hr
            WHERE t.document_type = 'O'
            AND   header.header_id = t.document_id
            AND   header.sold_to_org_id = hzc.cust_account_id (+)
            AND   hzc.party_id = customer.party_id (+)
            AND   (p_cust_id IS NULL OR customer.party_id = p_cust_id)
            AND   (p_prev_con_admin_id IS NULL OR t.contract_admin_id = p_prev_con_admin_id)
            AND   (p_salesrep_id IS NULL OR header.salesrep_id = p_salesrep_id)
            AND   (p_org_id IS NULL OR header.org_id = p_org_id)
            AND   (p_order_type_id IS NULL OR header.order_type_id = p_order_type_id)
            AND   doc_type.document_type = t.document_type
            AND   doc_type.language = USERENV('LANG')
            AND   hr.organization_id = header.org_id
            AND   hr.language = USERENV('LANG')
            AND   (p_new_con_admin_user_id IS NULL OR
                   t.contract_admin_id is null OR
                   t.contract_admin_id <> p_new_con_admin_user_id);

        CURSOR selected_quote_csr IS
            SELECT  header.quote_header_id AS contract_id,
                    header.quote_number AS contract_number,
                    customer.party_name AS customer,
                    doc_type.name document_type,
                    hr.name AS operating_unit,
                    t.contract_admin_id AS contract_admin_id
            FROM  aso_quote_headers header,
                  okc_template_usages t,
                  hz_parties customer,
                  okc_bus_doc_types_tl doc_type,
                  aso_quote_statuses_vl quote_status,
                  hr_all_organization_units_tl hr
            WHERE t.document_type = 'QUOTE'
            AND   header.quote_header_id = t.document_id
            AND   header.max_version_flag = 'Y'
            AND   (p_cust_id IS NULL OR header.cust_party_id = p_cust_id)
            AND   (p_prev_con_admin_id IS NULL OR t.contract_admin_id = p_prev_con_admin_id)
            AND   (p_salesrep_id IS NULL OR header.resource_id = (SELECT resource_id
                                                                  FROM   jtf_rs_salesreps
                                                                  WHERE  salesrep_id = p_salesrep_id))
            AND   (p_org_id IS NULL OR header.org_id = p_org_id)
            AND   (p_order_type_id IS NULL OR header.order_type_id = p_order_type_id)
            AND   (p_sales_group_id IS NULL OR header.resource_grp_id = p_sales_group_id)
            AND   customer.party_id (+) = header.cust_party_id
            AND   doc_type.document_type = t.document_type
            AND   doc_type.language = USERENV('LANG')
            AND   quote_status.quote_status_id = header.quote_status_id
            AND   quote_status.status_code <> 'ORDER SUBMITTED'
            AND   hr.organization_id = header.org_id
            AND   hr.language = USERENV('LANG')
            AND   (p_new_con_admin_user_id IS NULL OR
                   t.contract_admin_id is null OR
                   t.contract_admin_id <> p_new_con_admin_user_id);

        CURSOR selected_rep_csr IS
            SELECT  header.contract_id AS contract_id,
                    header.contract_number AS contract_number,
                    doc_type_tl.name AS document_type,
                    hr.name AS operating_unit,
                    header.owner_id AS contract_admin_id
            FROM  okc_rep_contracts header,
                  Hr_all_organization_units_tl  hr,
                  Okc_bus_doc_types_b  doc_type_b,
                  Okc_bus_doc_types_tl  doc_type_tl
            WHERE (p_cust_id IS NULL OR EXISTS (
                       SELECT con_parties.party_id
                       FROM   okc_rep_contract_parties con_parties
                       WHERE  header.contract_id = con_parties.contract_id
                       AND    con_parties.party_id = p_cust_id
                       AND    (con_parties.party_role_code = 'PARTNER_ORG' OR
                               con_parties.party_role_code = 'CUSTOMER_ORG')))
            AND   (p_prev_con_admin_id IS NULL OR header.owner_id = p_prev_con_admin_id)
            AND   (p_org_id IS NULL OR header.org_id = p_org_id)
            AND   doc_type_b.document_type = header.contract_type
            AND   doc_type_b.intent IN ('S', 'O')
            AND   doc_type_tl.document_type = header.contract_type
            AND   doc_type_tl.language = USERENV('LANG')
            AND   hr.organization_id = header.org_id
            AND   hr.language = USERENV('LANG')
            AND   (p_new_con_admin_user_id IS NULL OR
                   header.owner_id IS NULL OR
                   header.owner_id <> p_new_con_admin_user_id);

        CURSOR cust_names_csr (p_contract_id IN NUMBER) IS
            SELECT  hz.party_name
            FROM  okc_rep_contract_parties con_party,
                  hz_parties hz
            WHERE con_party.contract_id = p_contract_id
            AND   (con_party.party_role_code = 'CUSTOMER_ORG' OR
                   con_party.party_role_code = 'PARTNER_ORG')
            AND   con_party.party_id = hz.party_id;

        CURSOR con_admin_name_csr (p_user_id IN fnd_user.user_id%TYPE) IS
            SELECT nvl(per.full_name, fu.user_name)
            FROM  fnd_user fu,
                  per_all_people_f per
            WHERE fu.user_id = p_user_id
            AND   per.person_id = fu.employee_id;

        CURSOR validate_con_admin_csr (p_con_admin_id IN fnd_user.user_id%TYPE) IS
            SELECT  1
            FROM  fnd_user fu,
                  per_all_people_f per
            WHERE fu.user_id = p_con_admin_id
            AND   per.person_id = fu.employee_id
            AND   sysdate between per.effective_start_date AND nvl(per.effective_end_date, sysdate);

        TYPE selected_bsa_tbl IS TABLE OF selected_bsa_csr%ROWTYPE;
        TYPE selected_so_tbl IS TABLE OF selected_so_csr%ROWTYPE;
        TYPE selected_quote_tbl IS TABLE OF selected_quote_csr%ROWTYPE;
        TYPE selected_rep_tbl IS TABLE OF selected_rep_csr%ROWTYPE;

        TYPE NumList IS TABLE OF okc_rep_contracts_all.contract_id%TYPE NOT NULL
          INDEX BY PLS_INTEGER;

        TYPE NamesList IS TABLE OF hz_parties.party_name%TYPE NOT NULL
          INDEX BY PLS_INTEGER;

        selected_bsa selected_bsa_tbl;
        selected_so selected_so_tbl;
        selected_quote selected_quote_tbl;
        selected_rep selected_rep_tbl;

        l_selected_doc_ids OKC_TERMS_UTIL_PVT.doc_ids_tbl;
        l_selected_doc_types OKC_TERMS_UTIL_PVT.doc_types_tbl;
        l_new_con_admin_user_ids OKC_TERMS_UTIL_PVT.new_con_admin_user_ids_tbl;
        l_doc_index NUMBER(4) := 0;
        l_new_con_admin_user_id okc_template_usages.contract_admin_id%TYPE;
        l_new_con_admin_user_name per_all_people_f.full_name%TYPE;

        l_batch_size number(4) := 1000;
        l_cust_names varchar2(4000);

        selected_rep_con_ids NumList;
        l_rep_cust_names NamesList;

        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);

        l_succ_doc_count NUMBER;
        l_err_doc_count NUMBER;
        l_msg_code VARCHAR2(2000);
        l_msg_type VARCHAR2(1);
        l_temp NUMBER;
        l_rec_index NUMBER;
        l_current_con_admin_name per_all_people_f.full_name%TYPE;

      BEGIN

        l_api_name := 'update_con_admin_manager';

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Entered OKC_REP_UPD_CON_ADMIN_PVT.update_con_admin_manager');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_doc_type: ' || p_doc_type);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_cust_id: ' || p_cust_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_prev_con_admin_id: ' || p_prev_con_admin_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_salesrep_id: ' || p_salesrep_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_sales_group_id: ' || p_sales_group_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_org_id: ' || p_org_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_order_type_id: ' || p_order_type_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_con_admin_from: ' || p_con_admin_from);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_new_con_admin_id: ' || p_new_con_admin_user_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_new_con_admin_name: ' || p_new_con_admin_name);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'p_mode: ' || p_mode);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT OKC_REP_UPD_CON_ADMIN_PVT;

        -- Populate the log/output files with user entered report parameters
        populate_report_parameters(p_doc_type              => p_doc_type,
                                   p_cust_id               => p_cust_id,
                                   p_prev_con_admin_id     => p_prev_con_admin_id,
                                   p_salesrep_id           => p_salesrep_id,
                                   p_sales_group_id        => p_sales_group_id,
                                   p_org_id                => p_org_id,
                                   p_order_type_id         => p_order_type_id,
                                   p_new_con_admin_user_id => p_new_con_admin_user_id,
                                   p_mode                  => p_mode);

        l_succ_doc_count := 0;
        l_err_doc_count := 0;
        l_msg_code := NULL;
        l_msg_type := NULL;
        l_rec_index := 0;

        -- Fetch BSAs using user entered search criteria
        IF(p_doc_type = G_DOC_TYPE_ANY OR
           p_doc_type = G_DOC_TYPE_ALL_OM OR
           p_doc_type = G_DOC_TYPE_BSA) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                            'Fetching BSAs ...');
          END IF;

          OPEN selected_bsa_csr;
          LOOP -- the following statement fetches 1000 rows or less in each iteration

            FETCH selected_bsa_csr BULK COLLECT INTO selected_bsa
            LIMIT l_batch_size;

            EXIT WHEN selected_bsa.COUNT = 0;

            -- Iterate through the selected BSAs and populate each BSA details into
            -- concurrent log and out put files
            FOR i IN 1..NVL(selected_bsa.LAST, -1) LOOP

              -- Increment record index
              l_rec_index := l_rec_index + 1;

              -- If the current mode is UPDATE, then populate the following PL/SQL tables with current BSA details
              IF(p_mode = G_MODE_UPDATE) THEN

                l_selected_doc_ids(l_doc_index) := selected_bsa(i).contract_id;
                l_selected_doc_types(l_doc_index) := G_DOC_TYPE_BSA;
                l_new_con_admin_user_ids(l_doc_index) := p_new_con_admin_user_id;

                l_doc_index := l_doc_index + 1;

              END IF;

              -- Check if the current Sales Agreement has a Contract Administrator
              IF (selected_bsa(i).contract_admin_id IS NOT NULL) THEN
                -- Get current Contract Administrator name
                OPEN  con_admin_name_csr(selected_bsa(i).contract_admin_id);
                FETCH con_admin_name_csr INTO l_current_con_admin_name;
                CLOSE con_admin_name_csr;
              ELSE
                l_current_con_admin_name := NULL;
              END IF;


              -- Populate concurrent output and log file with document details
              populate_output_and_log_file( p_doc_type         => G_DOC_TYPE_BSA,
                                            p_con_number       => selected_bsa(i).contract_number,
                                            p_cust_name        => selected_bsa(i).customer,
                                            p_doc_type_name    => selected_bsa(i).document_type,
                                            p_current_con_admin=> l_current_con_admin_name,
                                            p_new_con_admin    => NULL,
                                            p_operating_unit   => selected_bsa(i).operating_unit,
                                            p_msg_type         => l_msg_type,
                                            p_msg_code         => l_msg_code,
                                            p_doc_index        => l_rec_index);

            END LOOP;

          END LOOP;
          CLOSE selected_bsa_csr;

        END IF;

        -- Fetch Sales Orders using user entered search criteria
        IF(p_doc_type = G_DOC_TYPE_ANY OR
           p_doc_type = G_DOC_TYPE_ALL_OM OR
           p_doc_type = G_DOC_TYPE_SO) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                              'Fetching Sales Orders ...');
          END IF;

          OPEN selected_so_csr;

          LOOP -- the following statement fetches 1000 rows or less in each iteration

            FETCH selected_so_csr BULK COLLECT INTO selected_so
            LIMIT l_batch_size;

            EXIT WHEN selected_so.COUNT = 0;

            -- Iterate through the selected Sales Orders and populate each Sales Order details into
            -- concurrent log and out put files
            FOR i IN 1..NVL(selected_so.LAST, -1) LOOP

              -- Increment record index
              l_rec_index := l_rec_index + 1;

              -- If the current mode is UPDATE, then populate the following PL/SQL tables with current Sales Order details
              IF(p_mode = G_MODE_UPDATE) THEN

                l_selected_doc_ids(l_doc_index) := selected_so(i).contract_id;
                l_selected_doc_types(l_doc_index) := G_DOC_TYPE_SO;
                l_new_con_admin_user_ids(l_doc_index) := p_new_con_admin_user_id;

                l_doc_index := l_doc_index + 1;

              END IF;

              -- Check if the current Sales Order has a Contract Administrator
              IF (selected_so(i).contract_admin_id IS NOT NULL) THEN
                -- Get current Contract Administrator name
                OPEN  con_admin_name_csr(selected_so(i).contract_admin_id);
                FETCH con_admin_name_csr INTO l_current_con_admin_name;
                CLOSE con_admin_name_csr;
              ELSE
                l_current_con_admin_name := NULL;
              END IF;

              -- Populate concurrent output and log file with document details
              populate_output_and_log_file( p_doc_type         => G_DOC_TYPE_SO,
                                            p_con_number       => selected_so(i).contract_number,
                                            p_cust_name        => selected_so(i).customer,
                                            p_doc_type_name    => selected_so(i).document_type,
                                            p_current_con_admin=> l_current_con_admin_name,
                                            p_new_con_admin    => NULL,
                                            p_operating_unit   => selected_so(i).operating_unit,
                                            p_msg_type         => l_msg_type,
                                            p_msg_code         => l_msg_code,
                                            p_doc_index        => l_rec_index );

            END LOOP;

          END LOOP;
          CLOSE selected_so_csr;

        END IF;


        -- Fetch Quotes using user entered search criteria
        IF(p_doc_type = G_DOC_TYPE_ANY OR
           p_doc_type = G_DOC_TYPE_QUOTE) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                            'Fetching Sales Quotes ...');
          END IF;

          OPEN selected_quote_csr;
          LOOP -- the following statement fetches 1000 rows or less in each iteration

            FETCH selected_quote_csr BULK COLLECT INTO selected_quote
            LIMIT l_batch_size;

            EXIT WHEN selected_quote.COUNT = 0;

            -- Iterate through the selected Quotes and populate each Quote details into
            -- concurrent log and out put files
            FOR i IN 1..NVL(selected_quote.LAST, -1) LOOP

              l_msg_code := NULL;
              l_msg_type := NULL;
              l_new_con_admin_user_name := NULL;

              -- Increment record index
              l_rec_index := l_rec_index + 1;

              -- If user selects Sales Group Assignment as Contract Administrator from
              IF( p_con_admin_from = G_CON_ADMIN_FROM_SALES_GROUP) THEN

                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                            'Calling OKC_TERMS_UTIL_PVT.get_sales_group_con_admin');
                END IF;

                -- Call the following Terms API to get the new contract administrator id according
                -- to Sales Group Assignment
                OKC_TERMS_UTIL_PVT.get_sales_group_con_admin(
                                   p_api_version    => 1.0,
                                   p_init_msg_list  => FND_API.G_FALSE,
                                   p_doc_id         =>  selected_quote(i).contract_id,
                                   p_doc_type       => G_DOC_TYPE_QUOTE,
                                   x_new_con_admin_user_id   => l_new_con_admin_user_id,
                                   x_return_status  => l_return_status,
                                   x_msg_count      => l_msg_count,
                                   x_msg_data       => l_msg_data);

                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

                IF(l_new_con_admin_user_id IS NOT NULL) THEN

                  -- Check whether the current and the new Contract Administrators are same
                  IF(l_new_con_admin_user_id = selected_quote(i).contract_admin_id) THEN

                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                              'Current and the new Contract Administrators are same');
                    END IF;

                    l_msg_type := G_WARNING_CODE;
                    l_msg_code := 'OKC_REP_SW_INV_ADMINS_WARN_MSG';

                  ELSE -- If current and the new Contract Administrators are different
                    -- Check whether the contract administrator is an active employee in the system
                    OPEN  validate_con_admin_csr(l_new_con_admin_user_id);
                    FETCH validate_con_admin_csr INTO l_temp;

                    IF (validate_con_admin_csr%ROWCOUNT = 0) THEN

                      -- If the contract administrator is not an active employee

                      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                                'Contract Administrator with user id ' || l_new_con_admin_user_id || ' is not an active employee');
                      END IF;

                      l_msg_type := G_ERROR_CODE;
                      l_msg_code := 'OKC_REP_SW_INV_CON_ADMIN';
                      CLOSE validate_con_admin_csr;

                    ELSE -- If the contract administrator is an active employee

                      CLOSE validate_con_admin_csr;

                      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                                'New Contract Administrator Id ' || l_new_con_admin_user_id);
                      END IF;

                      OPEN  con_admin_name_csr(l_new_con_admin_user_id);
                      FETCH con_admin_name_csr INTO l_new_con_admin_user_name;
                      CLOSE con_admin_name_csr;

                      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                                  'New Contract Administrator Name ' || l_new_con_admin_user_name);
                      END IF;

                    END IF; -- End of validate_con_admin_csr%ROWCOUNT = 0

                  END IF; -- End of l_new_con_admin_user_id = selected_quote(i).contract_admin_id

                ELSE -- l_new_con_admin_user_id is NULL

                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                            'No Contract Administrator found.');
                  END IF;

                  -- Increment the errored document count
                  l_err_doc_count := l_err_doc_count + 1;

                  l_msg_type := G_ERROR_CODE;
                  l_msg_code := 'OKC_REP_SW_NO_CON_ADMIN';

                END IF;

              ELSE -- p_con_admin_from is not G_CON_ADMIN_FROM_SALES_GROUP

                l_new_con_admin_user_id := p_new_con_admin_user_id;
                l_new_con_admin_user_name := p_new_con_admin_name;

              END IF;


              -- If the current mode is UPDATE, then populate the following PL/SQL tables with current BSA details
              IF(p_mode = G_MODE_UPDATE) THEN

                l_selected_doc_ids(l_doc_index) := selected_quote(i).contract_id;
                l_selected_doc_types(l_doc_index) := G_DOC_TYPE_QUOTE;
                l_new_con_admin_user_ids(l_doc_index) := l_new_con_admin_user_id;

                l_doc_index := l_doc_index + 1;

              END IF;


              -- Check if the current Sales Quote has a Contract Administrator
              IF (selected_quote(i).contract_admin_id IS NOT NULL) THEN
                -- Get current Contract Administrator name
                OPEN  con_admin_name_csr(selected_quote(i).contract_admin_id);
                FETCH con_admin_name_csr INTO l_current_con_admin_name;
                CLOSE con_admin_name_csr;
              ELSE
                l_current_con_admin_name := NULL;
              END IF;


              -- Populate concurrent output and log file with document details
              populate_output_and_log_file( p_doc_type         => G_DOC_TYPE_QUOTE,
                                            p_con_number       => selected_quote(i).contract_number,
                                            p_cust_name        => selected_quote(i).customer,
                                            p_doc_type_name    => selected_quote(i).document_type,
                                            p_current_con_admin=> l_current_con_admin_name,
                                            p_new_con_admin    => l_new_con_admin_user_name,
                                            p_operating_unit   => selected_quote(i).operating_unit,
                                            p_msg_type         => l_msg_type,
                                            p_msg_code         => l_msg_code,
                                            p_doc_index        => l_rec_index );

            END LOOP;

          END LOOP;
          CLOSE selected_quote_csr;

        END IF;


        -- Call the Terms API to update the Contract Administrator of the selected BSAs,
        -- Sales Orders and Sales Quotes
        IF(p_mode = G_MODE_UPDATE AND
           l_selected_doc_ids.LAST > 0) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Calling OKC_TERMS_UTIL_PVT.update_contract_admin');
          END IF;

          OKC_TERMS_UTIL_PVT.update_contract_admin(
                                p_api_version   => 1.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_commit        => FND_API.G_FALSE,
                                p_doc_ids_tbl   => l_selected_doc_ids,
                                p_doc_types_tbl => l_selected_doc_types,
                                p_new_con_admin_user_ids_tbl    => l_new_con_admin_user_ids,
                                x_return_status => l_return_status,
                                x_msg_count     => l_msg_count,
                                x_msg_data      => l_msg_data);

          -- Increment the succeeded document count
          l_succ_doc_count := l_succ_doc_count + l_selected_doc_ids.COUNT;

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;


        -- Fetch Repository Contracts using user entered search criteria
        IF(p_doc_type = G_DOC_TYPE_ANY OR
           p_doc_type = G_DOC_TYPE_REP) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                              'Fetching Repository Contracts ...');
          END IF;

          l_msg_code := NULL;
          l_msg_type := NULL;

          OPEN  selected_rep_csr;
          LOOP -- the following statement fetches 1000 rows or less in each iteration

            FETCH selected_rep_csr BULK COLLECT INTO selected_rep
            LIMIT l_batch_size;

            EXIT WHEN selected_rep.COUNT = 0;

            -- Iterate through the selected Repository Contracts and populate each Contract details into
            -- concurrent log and out put files
            FOR i IN 1..NVL(selected_rep.LAST, -1) LOOP

              -- Increment record index
              l_rec_index := l_rec_index + 1;

              -- Prepare a number array of contract ids, this is required by the UPDATE
              -- statement under FORALL as it will not take selected_rep(i).contract_id in the WHERE clause
              -- Getting the following compilation error
              -- PLS-00436: implementation restriction: cannot reference fields of BULK In-BIND table of records
              selected_rep_con_ids(i) := selected_rep(i).contract_id;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                                 'Getting customer names of the current Repository Contract ...');
              END IF;

              -- Fetch current contract customer names
              OPEN cust_names_csr(selected_rep(i).contract_id);
              FETCH cust_names_csr BULK COLLECT INTO l_rep_cust_names;
              CLOSE cust_names_csr;

              -- Initilaize the customer names string to empty at the beginning of every contract
              l_cust_names := '';

              FOR j IN 1..NVL(l_rep_cust_names.LAST, -1) LOOP
                IF j = 1 THEN
                  l_cust_names := l_rep_cust_names(j);
                ELSE
                  l_cust_names := l_cust_names ||', '|| l_rep_cust_names(j);
                END IF;
              END LOOP;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                               'Customer names of the current Repository Contract ' || l_cust_names);
              END IF;

              -- Get current Contract Administrator name
              OPEN  con_admin_name_csr(selected_rep(i).contract_admin_id);
              FETCH con_admin_name_csr INTO l_current_con_admin_name;
              CLOSE con_admin_name_csr;


              -- Populate concurrent log and output files with document details
              populate_output_and_log_file( p_doc_type         => G_DOC_TYPE_REP,
                                            p_con_number       => selected_rep(i).contract_number,
                                            p_cust_name        => l_cust_names,
                                            p_doc_type_name    => selected_rep(i).document_type,
                                            p_current_con_admin=> l_current_con_admin_name,
                                            p_new_con_admin    => NULL,
                                            p_operating_unit   => selected_rep(i).operating_unit,
                                            p_msg_type         => l_msg_type,
                                            p_msg_code         => l_msg_code,
                                            p_doc_index        => l_rec_index );

            END LOOP;

            -- If the current mode is UPDATE, then update the Contract Administrator of the
            -- selected Repository Contracts
            IF (p_mode = G_MODE_UPDATE) THEN

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                                'Updating Latest version of Repository Contract with new Contract Administrator');
              END IF;

	      FORALL i IN NVL(selected_rep_con_ids.FIRST,0)..NVL(selected_rep_con_ids.LAST,-1)

                UPDATE okc_rep_contracts_all
                SET    owner_id = p_new_con_admin_user_id
                WHERE  contract_id = selected_rep_con_ids(i);

              /* ---- Per CR, Contract Admin is now version specific.
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                                'Updating Archived versions of Repository Contract with new Contract Administrator');
              END IF;


		    FORALL i IN NVL(selected_rep_con_ids.FIRST,0)..NVL(selected_rep_con_ids.LAST,-1)

                UPDATE okc_rep_contract_vers
                SET    owner_id = p_new_con_admin_user_id
                WHERE  contract_id = selected_rep_con_ids(i);

                -------  */

              -- Increment the succeeded document count
              l_succ_doc_count := l_succ_doc_count + selected_rep_con_ids.COUNT;


            END IF; -- p_mode = G_MODE_UPDATE


          END LOOP;
          CLOSE selected_rep_csr;

        END IF;

        -- Populate the log/output files with summary of the current job
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_SUMMARY'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=======');

        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_SUMMARY'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, '=======');

        -- If Contract Administrator is selected manually
        IF( p_con_admin_from <> G_CON_ADMIN_FROM_SALES_GROUP) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_NEW_CON_ADMIN') || ': '|| p_new_con_admin_name);
          FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_NEW_CON_ADMIN') || ': '|| p_new_con_admin_name);
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_TOT_CON_SUCC') || ': '|| l_succ_doc_count);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_TOT_CON_SUCC') || ': '|| l_succ_doc_count);

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_TOT_CON_ERR') || ': '|| l_err_doc_count);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_TOT_CON_ERR') || ': '|| l_err_doc_count);


        IF(p_mode = 'UPDATE') THEN
          COMMIT;
        END IF;

        retcode := G_RETURN_CODE_SUCCESS;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'Leaving OKC_REP_UPD_CON_ADMIN_PVT.update_con_admin_manager');
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                   g_module || l_api_name,
                   'Leaving update_con_admin_manager because of EXCEPTION: ' || sqlerrm);
          END IF;

          FND_FILE.PUT_LINE(FND_FILE.LOG,
              'Leaving update_con_admin_manager because of EXCEPTION: ' ||
              sqlerrm);

          --close cursors
          IF (selected_bsa_csr%ISOPEN) THEN
            CLOSE selected_bsa_csr ;
          END IF;
          IF (selected_so_csr%ISOPEN) THEN
            CLOSE selected_so_csr ;
          END IF;
          IF (selected_quote_csr%ISOPEN) THEN
            CLOSE selected_quote_csr ;
          END IF;
          IF (selected_rep_csr%ISOPEN) THEN
            CLOSE selected_rep_csr ;
          END IF;
          IF (cust_names_csr%ISOPEN) THEN
            CLOSE cust_names_csr ;
          END IF;
          ROLLBACK TO OKC_REP_UPD_CON_ADMIN_PVT;
          errbuf := substr(SQLERRM, 1, 2000);

     END update_con_admin_manager;


END OKC_REP_UPD_CON_ADMIN_PVT;

/
