--------------------------------------------------------
--  DDL for Package Body OKC_REP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_UTIL_PVT" AS
/* $Header: OKCVREPUTILB.pls 120.30.12010000.20 2013/10/29 11:54:48 aksgoyal ship $ */


  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

  G_RETURN_CODE_SUCCESS     CONSTANT NUMBER := 0;
  G_RETURN_CODE_WARNING     CONSTANT NUMBER := 1;
  G_RETURN_CODE_ERROR       CONSTANT NUMBER := 2;
  G_APPLICATION_ID          CONSTANT NUMBER := 510;

  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------
  -- Start of comments
  --API name      : check_contract_access_external
  --Type          : Private.
  --Function      : Checks access to a external contract by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Required
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract to be checked
  --              : p_contract_type       IN VARCHAR2       Required
  --                   Type of the contract to be checked
  --OUT           : x_has_access          OUT  VARCHAR2(1)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE check_contract_access_external(
    p_api_version     IN  NUMBER,
    p_init_msg_list   IN VARCHAR2,
    p_contract_id     IN  NUMBER,
    p_contract_type   IN  VARCHAR2,
    x_has_access      OUT NOCOPY  VARCHAR2,
    x_msg_data        OUT NOCOPY  VARCHAR2,
    x_msg_count       OUT NOCOPY  NUMBER,
    x_return_status   OUT NOCOPY  VARCHAR2)
  IS

  l_api_name VARCHAR2(30);
  l_org_id  OKC_REP_CONTRACTS_ALL.ORG_ID%type;
  l_result  VARCHAR2(1);

  CURSOR intents_csr(p_contract_type IN VARCHAR2) IS
    SELECT NULL
    FROM okc_bus_doc_types_b
    WHERE document_type = p_contract_type
    AND (INSTR( FND_PROFILE.VALUE('OKC_REP_INTENTS'), intent) <> 0
        OR FND_PROFILE.VALUE('OKC_REP_INTENTS') IS NULL);

  CURSOR po_contract_csr(p_contract_id IN NUMBER, p_contract_type IN VARCHAR2) IS
    SELECT
      h.org_id
    FROM
      po_headers_all h
      ,okc_template_usages t
    WHERE  h.po_header_id = t.document_id
    AND  t.document_type IN ('PA_BLANKET','PA_CONTRACT','PO_STANDARD')
    AND  t.document_type = p_contract_type
    AND  h.po_header_id = p_contract_id;

  CURSOR neg_contract_csr(p_contract_id IN NUMBER, p_contract_type IN VARCHAR2) IS
    SELECT
      h.org_id
    FROM
      pon_auction_headers_all h
      ,okc_template_usages t
    WHERE  h.auction_header_id = t.document_id
    AND  t.document_type IN ('AUCTION','RFI','RFQ')
    AND  t.document_type = p_contract_type
    AND  h.auction_header_id = p_contract_id;

  CURSOR bsa_contract_csr(p_contract_id IN NUMBER, p_contract_type IN VARCHAR2) IS
    SELECT
      h.org_id
    FROM
      oe_blanket_headers_all h
      ,okc_template_usages t
    WHERE  h.header_id = t.document_id
    AND  t.document_type = 'B'
    AND  t.document_type = p_contract_type
    AND  h.header_id = p_contract_id;

  CURSOR so_contract_csr(p_contract_id IN NUMBER, p_contract_type IN VARCHAR2) IS
    SELECT
      h.org_id
    FROM
      oe_order_headers_all h
      ,okc_template_usages t
    WHERE  h.header_id = t.document_id
    AND  t.document_type = 'O'
    AND  t.document_type = p_contract_type
    AND  h.header_id = p_contract_id;

  CURSOR quote_contract_csr(p_contract_id IN NUMBER, p_contract_type IN VARCHAR2) IS
    SELECT
      h.org_id
    FROM
      aso_quote_headers_all h
      ,okc_template_usages t
    WHERE  h.quote_header_id = t.document_id
    AND  t.document_type = 'QUOTE'
    AND  t.document_type = p_contract_type
    AND  h.quote_header_id = p_contract_id;

  CURSOR quote_security_csr(p_contract_id IN NUMBER) IS
    SELECT
      NULL
    FROM
      aso_quote_headers_all h
    WHERE  h.quote_header_id = p_contract_id
    AND  get_quote_access(
      (SELECT s.resource_id
      FROM jtf_rs_salesreps s
      WHERE s.person_id = fnd_global.employee_id()),
      h.quote_number) <> 'NONE';

  CURSOR mo_check_csr(p_org_id in number) IS
     SELECT organization_id
     FROM   mo_glob_org_access_tmp
     WHERE  organization_id = p_org_id;

  BEGIN

    l_api_name  := 'check_contract_access_external';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '100: Entered OKC_REP_UTIL_PVT.check_contract_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '101: Contract Id is: ' || to_char(p_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '102: Contract Type is: ' || p_contract_type);
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF     (p_contract_type = 'PA_BLANKET')
        OR (p_contract_type = 'PA_CONTRACT')
        OR (p_contract_type = 'PO_STANDARD') THEN

      OPEN  po_contract_csr(p_contract_id, p_contract_type);
      FETCH po_contract_csr  INTO  l_org_id;
      CLOSE po_contract_csr;

    ELSIF  (p_contract_type = 'AUCTION')
        OR (p_contract_type = 'RFI')
        OR (p_contract_type = 'RFQ') THEN

      OPEN  neg_contract_csr(p_contract_id, p_contract_type);
      FETCH neg_contract_csr  INTO  l_org_id;
      CLOSE neg_contract_csr;

    ELSIF p_contract_type = 'B' THEN

      OPEN  bsa_contract_csr(p_contract_id, p_contract_type);
      FETCH bsa_contract_csr  INTO  l_org_id;
      CLOSE bsa_contract_csr;

    ELSIF p_contract_type = 'O' THEN

      OPEN  so_contract_csr(p_contract_id, p_contract_type);
      FETCH so_contract_csr  INTO  l_org_id;
      CLOSE so_contract_csr;

    ELSIF p_contract_type = 'QUOTE' THEN

      OPEN  quote_contract_csr(p_contract_id, p_contract_type);
      FETCH quote_contract_csr  INTO  l_org_id;
      CLOSE quote_contract_csr;

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Values from contract_csr: l_org_id = ' || l_org_id );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_has_access := FND_API.G_FALSE;

    --  Call multi-org API to check access to contract's organization by current user
    OPEN  mo_check_csr(l_org_id);
    FETCH mo_check_csr INTO l_org_id;

    IF (mo_check_csr%FOUND) THEN
      l_result := 'Y';
    ELSE
      l_result := 'N';
    END IF;

    CLOSE mo_check_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Values after mo_check_csr fetch: l_org_id = ' || l_org_id || ', from mo_check_csr%FOUND: l_result = ' || l_result);
    END IF;

    IF (l_result = 'Y') THEN

      --  Check for allowed intents
      OPEN  intents_csr(p_contract_type);
      FETCH intents_csr INTO l_result;

      IF (intents_csr%FOUND) THEN
        l_result := 'Y';
      ELSE
        l_result := 'N';
      END IF;

      CLOSE intents_csr;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
          'Values after intents_csr fetch: l_result = ' || l_result);
      END IF;

      IF (l_result = 'Y') THEN

        x_has_access := FND_API.G_TRUE;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'intents check passed');
        END IF;

        IF p_contract_type = 'QUOTE' THEN

          OPEN  quote_security_csr(p_contract_id);
          FETCH quote_security_csr  INTO  l_result;

          IF quote_security_csr%FOUND THEN
            l_result := 'Y';
          ELSE
            l_result := 'N';
          END IF;

          CLOSE quote_security_csr;

          IF l_result = 'Y' THEN

            x_has_access := FND_API.G_TRUE;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'IF l_result = Y for quoting security');
            END IF;
          ELSE

            x_has_access := FND_API.G_FALSE;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'IF l_result = N for quoting security');
            END IF;
          END IF;

        END IF;

      END IF; -- End of intent profile check

    END IF;  -- End of MO_GLOBAL check

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     '110: Leaving OKC_REP_UTIL_PVT.check_contract_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '111: x_has_access is: ' || x_has_access);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '112: x_return_status is: ' || x_return_status);
    END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        --close cursors
        IF (intents_csr%ISOPEN) THEN
          CLOSE intents_csr ;
        END IF;
        IF (po_contract_csr%ISOPEN) THEN
          CLOSE po_contract_csr ;
        END IF;
        IF (neg_contract_csr%ISOPEN) THEN
          CLOSE neg_contract_csr ;
        END IF;
        IF (bsa_contract_csr%ISOPEN) THEN
          CLOSE bsa_contract_csr ;
        END IF;
        IF (so_contract_csr%ISOPEN) THEN
          CLOSE so_contract_csr ;
        END IF;
        IF (quote_contract_csr%ISOPEN) THEN
          CLOSE quote_contract_csr ;
        END IF;
        IF (quote_security_csr%ISOPEN) THEN
          CLOSE quote_security_csr ;
        END IF;
        IF (mo_check_csr%ISOPEN) THEN
          CLOSE mo_check_csr ;
        END IF;

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 '115: Leaving check_contract_access:FND_API.G_EXC_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --close cursors
        IF (intents_csr%ISOPEN) THEN
          CLOSE intents_csr ;
        END IF;
        IF (po_contract_csr%ISOPEN) THEN
          CLOSE po_contract_csr ;
        END IF;
        IF (neg_contract_csr%ISOPEN) THEN
          CLOSE neg_contract_csr ;
        END IF;
        IF (bsa_contract_csr%ISOPEN) THEN
          CLOSE bsa_contract_csr ;
        END IF;
        IF (so_contract_csr%ISOPEN) THEN
          CLOSE so_contract_csr ;
        END IF;
        IF (quote_contract_csr%ISOPEN) THEN
          CLOSE quote_contract_csr ;
        END IF;
        IF (quote_security_csr%ISOPEN) THEN
          CLOSE quote_security_csr ;
        END IF;
        IF (mo_check_csr%ISOPEN) THEN
          CLOSE mo_check_csr ;
        END IF;

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 '116:Leaving check_contract_access:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        --close cursors
        IF (intents_csr%ISOPEN) THEN
          CLOSE intents_csr ;
        END IF;
        IF (po_contract_csr%ISOPEN) THEN
          CLOSE po_contract_csr ;
        END IF;
        IF (neg_contract_csr%ISOPEN) THEN
          CLOSE neg_contract_csr ;
        END IF;
        IF (bsa_contract_csr%ISOPEN) THEN
          CLOSE bsa_contract_csr ;
        END IF;
        IF (so_contract_csr%ISOPEN) THEN
          CLOSE so_contract_csr ;
        END IF;
        IF (quote_contract_csr%ISOPEN) THEN
          CLOSE quote_contract_csr ;
        END IF;
        IF (quote_security_csr%ISOPEN) THEN
          CLOSE quote_security_csr ;
        END IF;
        IF (mo_check_csr%ISOPEN) THEN
          CLOSE mo_check_csr ;
        END IF;


        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 '117: Leaving check_contract_access because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END check_contract_access_external;

  -- Start of comments
  --API name      : check_contract_access
  --Type          : Private.
  --Function      : Checks access to a contract by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Required
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract whose access to be checked
  --              : p_function_name       IN VARCHAR2       Required
  --                   Name of the function whose access to be checked. Possible values OKC_REP_SELECT, OKC_REP_UPDATE
  --OUT           : x_has_access          OUT  VARCHAR2(1)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE check_contract_access(
    p_api_version     IN  NUMBER,
    p_init_msg_list   IN VARCHAR2,
    p_contract_id     IN  NUMBER,
    p_function_name   IN  VARCHAR2,
    x_has_access      OUT NOCOPY  VARCHAR2,
    x_msg_data        OUT NOCOPY  VARCHAR2,
    x_msg_count       OUT NOCOPY  NUMBER,
    x_return_status   OUT NOCOPY  VARCHAR2)
  IS

  l_api_name VARCHAR2(30);
  l_org_id  OKC_REP_CONTRACTS_ALL.ORG_ID%type;
  l_owner_id  OKC_REP_CONTRACTS_ALL.OWNER_ID%type;
  l_contract_type  OKC_REP_CONTRACTS_ALL.CONTRACT_TYPE%type;
  l_use_acl_flag OKC_REP_CONTRACTS_ALL.USE_ACL_FLAG%type;
  l_result  VARCHAR2(1);
  l_user_id FND_USER.USER_ID%type;
  l_user_name FND_USER.USER_NAME%type;
  l_status_code OKC_REP_CONTRACTS_ALL.CONTRACT_STATUS_CODE%type;
  l_approversOut            ame_util.approversTable2;
  l_process_complete_yn varchar2(1);
  l_item_indexes        ame_util.idList;
  l_item_classes        ame_util.stringList;
  l_item_ids            ame_util.stringList;
  l_item_sources        ame_util.longStringList;
  l_transaction_type    CONSTANT VARCHAR2(200) := 'OKC_REP_CON_APPROVAL';

  CURSOR intents_csr(p_contract_type IN VARCHAR2) IS
    SELECT NULL
    FROM okc_bus_doc_types_b
    WHERE document_type = p_contract_type
    AND   ((is_sales_workbench() = 'N'
            AND (INSTR( FND_PROFILE.VALUE('OKC_REP_INTENTS'), intent) <> 0
                 OR FND_PROFILE.VALUE('OKC_REP_INTENTS') IS NULL)
           )
        OR (is_sales_workbench() = 'Y'
            AND intent IN ('S', 'O')
           )
          );

  CURSOR contract_csr(p_contract_id in number) IS
     SELECT org_id,
            owner_id,
            use_acl_flag,
            contract_type,
            contract_status_code
     FROM   okc_rep_contracts_all
     WHERE  contract_id = p_contract_id;

  CURSOR grants_csr(p_contract_id1 in number, p_contract_id2 in number, p_grantee_key in FND_GRANTS.grantee_key%TYPE, p_grantee_orig_system in FND_GRANTS.grantee_orig_system%TYPE) IS
    SELECT
      NULL
    FROM
      jtf_rs_groups_denorm d
      ,jtf_rs_group_members m
      ,jtf_rs_resource_extns e
      ,fnd_grants g
      ,fnd_objects o
    WHERE  d.parent_group_id = g.parameter2
    AND TRUNC(SYSDATE)
      BETWEEN d.start_date_active
      AND NVL(d.end_date_active,TRUNC(SYSDATE))
    and  d.group_id = m.group_id
    and  m.delete_flag <> 'Y'
    and  e.resource_id = m.resource_id
    and  g.object_id = o.object_id
    AND  o.obj_name = G_OBJECT_NAME
    AND  g.grantee_type = G_FND_GRANTEE_TYPE_GROUP
    AND  g.instance_pk1_value = p_contract_id1
    AND  e.user_id = FND_GLOBAL.user_id()
    AND  (
         (g.parameter3 = G_FND_GRANTS_UPDATE_ACCESS AND p_function_name IN (G_SELECT_ACCESS_LEVEL, G_UPDATE_ACCESS_LEVEL))
      OR (g.parameter3 = G_FND_GRANTS_VIEW_ACCESS   AND p_function_name  =  G_SELECT_ACCESS_LEVEL)
    )
     UNION ALL
    SELECT
          NULL
    FROM
       fnd_grants g
      ,fnd_objects o
    WHERE  g.object_id = o.object_id
    AND  o.obj_name = G_OBJECT_NAME
    AND  g.grantee_type = G_FND_GRANTEE_TYPE_USER
    AND  g.instance_pk1_value = p_contract_id2
    AND  (
         (g.grantee_key = p_grantee_key AND (g.grantee_orig_system = p_grantee_orig_system OR g.grantee_orig_system = 'JRES_IND')) -- for R12 functionality
      OR (g.grantee_key = FND_GLOBAL.user_name() AND g.grantee_orig_system = 'PER') -- for 11.5 backward compatibility
         )
    AND  (
         (g.parameter3 = G_FND_GRANTS_UPDATE_ACCESS AND p_function_name IN (G_SELECT_ACCESS_LEVEL, G_UPDATE_ACCESS_LEVEL))
      OR (g.parameter3 = G_FND_GRANTS_VIEW_ACCESS   AND p_function_name  =  G_SELECT_ACCESS_LEVEL)
    );

  -- Cursor to get current user's JTF resource id
  CURSOR cur_user_jtf_resource_csr IS
    SELECT resource_id
    FROM   jtf_rs_resource_extns
    WHERE  user_id = FND_GLOBAL.user_id();

  l_resource_id JTF_RS_RESOURCE_EXTNS.resource_id%TYPE;
  l_grantee_key FND_GRANTS.grantee_key%TYPE;
  l_grantee_orig_system FND_GRANTS.grantee_orig_system%TYPE;
  l_grantee_orig_system_id FND_GRANTS.grantee_orig_system_id%TYPE;

  BEGIN

    l_api_name  := 'check_contract_access';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '100: Entered OKC_REP_UTIL_PVT.check_contract_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '101: Contract Id is: ' || to_char(p_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '102: Fucntion Name is: ' || p_function_name);
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN  contract_csr(p_contract_id);
    FETCH contract_csr  INTO  l_org_id, l_owner_id, l_use_acl_flag, l_contract_type, l_status_code;
    CLOSE contract_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Values from contract_csr: l_org_id = ' || l_org_id || ', l_owner_id = ' || l_owner_id || ',l_use_acl_flag = ' || l_use_acl_flag);
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Values from contract_csr: l_contract_type = ' || l_contract_type || ', l_status_code = ' || l_status_code);
 	       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Values : FND_GLOBAL.user_id() = ' || FND_GLOBAL.user_id() || ', FND_GLOBAL.user_name() = ' || FND_GLOBAL.user_name());
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_has_access := FND_API.G_FALSE;
    l_user_name := FND_GLOBAL.user_name();
    l_user_id := FND_GLOBAL.user_id();

    -- Multi-Org Initialization
 	     MO_GLOBAL.init(G_APP_NAME);

 	     --  Call multi-org API to check access to contract's organization by current user
 	     l_result := MO_GLOBAL.check_access(p_org_id => l_org_id);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Values after calling MOAC API l_result = ' || l_result);
 	     END IF;
      IF (l_result = 'Y') THEN -- if the currenct user has org access of the contract in which it is created
 	              ---for pending approval documents, need to check if user falls in the list of approvers, then give them access to view/update contract details
 	                    IF (l_status_code = 'PENDING_APPROVAL') THEN
 	                 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name, 'checking whether user is present in approvers list');
 	                         END IF;

 	                 ame_api2.getallapprovers1(
 	                  applicationIdIn   => G_APPLICATION_ID,
 	                       transactionTypeIn => l_transaction_type,
 	                       transactionIdIn   => fnd_number.number_to_canonical(p_contract_id),
 	                       approvalProcessCompleteYNOut => l_process_complete_yn,
 	                       approversOut      => l_approversOut,
 	                       itemIndexesOut    => l_item_indexes,
 	                       itemClassesOut    => l_item_classes,
 	                       itemIdsOut        => l_item_ids,
 	                       itemSourcesOut    => l_item_sources);

 	                         FOR i IN 1 .. l_approversOut.count
 	                         LOOP
 	                         IF l_approversOut(i).name = l_user_name THEN
 	                              x_has_access := FND_API.G_TRUE;

 	                                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                                           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name, '200:Approver is the current user. so user have access.');
 	                                                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name, '200:x_has_access is: ' || x_has_access);
 	                                                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name, '200:x_return_status is: ' || x_return_status);
 	                                           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name, '200:Leaving OKC_REP_UTIL_PVT.check_contract_access');
     END IF;

      RETURN;
    END IF;
    END LOOP;
    END IF;  --l_status_code = 'PENDING_APPROVAL'


   END IF; --l_result ='Y'

 	     IF ( p_function_name = G_UPDATE_ACCESS_LEVEL AND NOT( FND_FUNCTION.TEST(G_FUNC_OKC_REP_ADMINISTRATOR,'Y') OR FND_FUNCTION.TEST(G_FUNC_OKC_REP_USER_FUNC,'Y') ) ) THEN

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'returning FALSE, queried for UPDATE access, not an Admin, not a User, must be a Viewer');

    END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
 	       x_has_access := FND_API.G_FALSE;
 	       RETURN;
         END IF;

    IF (l_result = 'Y') THEN

      --  Check for allowed intents
      OPEN  intents_csr(l_contract_type);
      FETCH intents_csr INTO l_result;

      IF (intents_csr%FOUND) THEN
        l_result := 'Y';
      ELSE
        l_result := 'N';
      END IF;

      CLOSE intents_csr;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
          'Values after intents_csr fetch: l_result = ' || l_result);
      END IF;

      IF (l_result = 'Y') THEN



        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Value from FND_GLOBAL.user_id() call: l_user_id = ' || l_user_id);
        END IF;

        --   Check if the current user is owner of the contract
        IF (l_user_id = l_owner_id) THEN
          x_has_access := FND_API.G_TRUE;

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'IF (l_user_id = l_owner_id) THEN: TRUE: x_has_access = ' || x_has_access);
          END IF;
        ELSE

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'checking OKC_REP_ADMINISTRATOR function: ' || G_FUNC_OKC_REP_ADMINISTRATOR);
          END IF;

          IF (FND_FUNCTION.TEST(G_FUNC_OKC_REP_ADMINISTRATOR,'Y')) THEN

            x_has_access := FND_API.G_TRUE;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'IF (FND_FUNCTION.TEST(G_FUNC_OKC_REP_ADMINISTRATOR,''Y'')) THEN: TRUE: x_has_access = ' || x_has_access);
            END IF;
          ELSE

            -- Check if Use ACL flag is enabled for the current contract
            IF (l_use_acl_flag = 'Y') THEN

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'IF (l_use_acl_flag = ''Y'') THEN: TRUE: x_has_access = ' || x_has_access);
              END IF;

              -- Get current user's resource_id
              OPEN cur_user_jtf_resource_csr;
              FETCH cur_user_jtf_resource_csr INTO l_resource_id;
              CLOSE cur_user_jtf_resource_csr;

              -- Get grantee key of the current resource
              l_grantee_key := JTF_RS_WF_INTEGRATION_PUB.get_wf_role(l_resource_id);

              -- Get greantee orig system for the current grantee key
              wf_directory.GetRoleOrigSysInfo(Role => l_grantee_key,
                                              Orig_System => l_grantee_orig_system,
                                              Orig_System_Id => l_grantee_orig_system_id);

              -- Check access of the current user in grants schema
              OPEN  grants_csr(p_contract_id, p_contract_id, l_grantee_key, l_grantee_orig_system);
              FETCH grants_csr INTO l_result;

              IF (grants_csr%FOUND) THEN
                x_has_access := FND_API.G_TRUE;

                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'IF (grants_csr%FOUND) THEN: TRUE: x_has_access = ' || x_has_access);
                END IF;
              ELSE
                x_has_access := FND_API.G_FALSE;

                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'IF (grants_csr%FOUND) THEN: FALSE: x_has_access = ' || x_has_access);
                END IF;
              END IF;

              CLOSE grants_csr;
            ELSE
              x_has_access := FND_API.G_TRUE;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'IF (l_use_acl_flag = ''Y'') THEN: FALSE: x_has_access = ' || x_has_access);
              END IF;
            END IF; -- End of Use ACL flag check

          END IF; -- End of FND_FUNCTION.TEST() check

        END IF; -- End of owner id check

      END IF; -- End of intent profile check

    END IF;  -- End of MO_GLOBAL check

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     '110: Leaving OKC_REP_UTIL_PVT.check_contract_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '111: x_has_access is: ' || x_has_access);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '112: x_return_status is: ' || x_return_status);
    END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        --close cursors
        IF (intents_csr%ISOPEN) THEN
          CLOSE intents_csr ;
        END IF;
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        IF (grants_csr%ISOPEN) THEN
          CLOSE grants_csr ;
        END IF;

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 '115: Leaving check_contract_access:FND_API.G_EXC_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --close cursors
        IF (intents_csr%ISOPEN) THEN
          CLOSE intents_csr ;
        END IF;
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        IF (grants_csr%ISOPEN) THEN
          CLOSE grants_csr ;
        END IF;

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 '116:Leaving check_contract_access:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        --close cursors
        IF (intents_csr%ISOPEN) THEN
          CLOSE intents_csr ;
        END IF;
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        IF (grants_csr%ISOPEN) THEN
          CLOSE grants_csr ;
        END IF;

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 '117: Leaving check_contract_access because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END check_contract_access;


-- Start of comments
  --API name      : Function has_contract_access_external
  --Type          : Private.
  --Function      : Checks access to a contract by the current user for external contracts.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_contract_id         IN NUMBER       Required
  --                   Id of the contract that is being checked
  --              : p_contract_type       IN VARCHAR2       Required
  --                   Contract type for contract being chacked
  --OUT           : Return Y if the current user has access to the contracts, else returns N
  -- End of comments
  FUNCTION has_contract_access_external(
      p_contract_id     IN  NUMBER,
      p_contract_type   IN  VARCHAR2
    ) RETURN VARCHAR2
  IS
    l_api_name                     VARCHAR2(30);
    l_has_access                   VARCHAR2(1);
    l_return_status                VARCHAR2(1);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);

  BEGIN

    l_api_name                     := 'check_contract_access_external';
    l_has_access                   := 'N';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.check_contract_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Type is: ' || p_contract_type);
    END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.has_contract_access');
    END IF;
    --- Call check_contract_access procedure.
    check_contract_access_external(
        p_api_version     => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_contract_id         => p_contract_id,
        p_contract_type       => p_contract_type,
        x_has_access          => l_has_access,
        x_msg_data            => l_msg_data,
        x_msg_count           => l_msg_count,
        x_return_status       => l_return_status
    );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.check_contract_access return status is: '
          || l_return_status);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.check_contract_access returns has_access as : '
          || l_has_access);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Leaving Function has_contract_access');
    END IF;
    RETURN l_has_access ;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function has_contract_access because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_has_access ;
  END has_contract_access_external;




-- Start of comments
  --API name      : Function check_contract_access
  --Type          : Private.
  --Function      : Checks access to a contract by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract whose access to be checked
  --              : p_function_name       IN VARCHAR2       Required
  --                   Name of the function whose access to be checked. Possible values OKC_REP_SELECT, OKC_REP_UPDATE
  --OUT           : Return Y if the current user has access to the contracts, else returns N
  -- End of comments
  FUNCTION has_contract_access(
      p_contract_id     IN  NUMBER,
      p_function_name   IN  VARCHAR2
    ) RETURN VARCHAR2
  IS
    l_api_name                     VARCHAR2(30);
    l_has_access                   VARCHAR2(1);
    l_return_status                VARCHAR2(1);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);

  BEGIN

    l_api_name                     := 'has_contract_access';
    l_has_access                   := 'N';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.check_contract_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Access Function Name is: ' || p_function_name);
    END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.has_contract_access');
    END IF;
    --- Call check_contract_access procedure.
    check_contract_access(
        p_api_version     => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_contract_id         => p_contract_id,
        p_function_name       => p_function_name,
        x_has_access          => l_has_access,
        x_msg_data            => l_msg_data,
        x_msg_count           => l_msg_count,
        x_return_status       => l_return_status
    );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.check_contract_access return status is: '
          || l_return_status);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.check_contract_access returns has_access as : '
          || l_has_access);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Leaving Function has_contract_access');
    END IF;
    RETURN l_has_access ;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function has_contract_access because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_has_access ;
  END has_contract_access;



  /**
   * This procedure changes status of a contract and logs the user action that
   * caused this into database tables OKC_REP_CON_STATUS_HIST.
   * @param IN p_contract_id  Id of the contract whose status to be changed
   * @param IN p_contract_version Version number of the contract whose status to be changed
   * @param IN p_status_code New status code to be set on the contract
   * @param IN p_user_id Id of the user who caused this change
   * @param IN p_note User entered notes in the notification while approving or rejecting the contract
   */
  PROCEDURE change_contract_status(
      p_api_version         IN  NUMBER,
      p_init_msg_list   IN VARCHAR2,
      p_contract_id         IN NUMBER,
      p_contract_version    IN NUMBER,
      p_status_code         IN VARCHAR2,
      p_user_id             IN NUMBER:=NULL,
      p_note                IN VARCHAR2:=NULL,
    x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2)  IS

  l_api_name VARCHAR2(30);
  l_user_id  FND_USER.USER_ID%type;

  BEGIN

    l_api_name := 'change_contract_status';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '200: Entered OKC_REP_UTIL_PVT.change_contract_status');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '201: Contract Id is: ' || to_char(p_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '202: Contract version is: ' || p_contract_version);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '203: Status code is: ' || p_status_code);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '204: USer Id is: ' || to_char(p_user_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '205: Note is: ' || p_note);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name || '.begin',
        'Before updating Contract Status');
    END IF;

    -- Update the contract status
    UPDATE  okc_rep_contracts_all
    SET     contract_status_code = p_status_code,
            contract_last_update_date = sysdate,
            contract_last_updated_by = FND_GLOBAL.user_id()
    WHERE   contract_id = p_contract_id
    AND     contract_version_num = p_contract_version;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name,
        'After updating Contract Status');
    END IF;

    -- Log this status change into OKC_REP_CON_STATUS_HIST table
    IF (p_user_id IS NULL) THEN
      l_user_id := FND_GLOBAL.user_id();

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name || '.begin',
        'Current user id' || l_user_id);
      END IF;

    ELSE
      l_user_id := p_user_id;
    END IF;  -- End of p_user_id IS NULL

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name,
        'Before inserting a row into OKC_REP_CON_STATUS_HIST');
    END IF;

    -- Insert row into OKC_REP_CON_STATUS_HIST
    INSERT INTO OKC_REP_CON_STATUS_HIST(
        contract_id,
        contract_version_num,
        status_code,
        status_change_date,
        changed_by_user_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
    VALUES(
        p_contract_id,
        p_contract_version,
        p_status_code,
        sysdate,
        l_user_id,
        1,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name,
        'After inserting a row into OKC_REP_CON_STATUS_HIST');
    END IF;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 'Leaving change_contract_status:FND_API.G_EXC_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 'Leaving change_contract_status: FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 'Leaving change_contract_status because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END change_contract_status;



  -- Start of comments
  --API name      : add_approval_hist_record
  --Type          : Private.
  --Function      : Inserts a record into table OKC_REP_CON_APPROVALS.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                   Contract ID of the approval history record
  --              : p_contract_version    IN VARCHAR2       Required
  --                   Contract version of the approval history record
  --              : p_action_code    IN OUT VARCHAR2       Optional
  --                   New action code to be set on the contract
  --              : p_user_id    IN VARCHAR2       Optional
  --                   Id of the user who caused this change
  --              : p_note    IN OUT VARCHAR2       Optional
  --                   User entered notes in the notification while approving or rejecting the contract
 --              : p_forward_user_id IN NUMBER Optional
 --		 	 ID of the user to whom the notification is forwarded/Delegated
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE add_approval_hist_record(
      p_api_version         IN  NUMBER,
      p_init_msg_list   IN VARCHAR2,
      p_contract_id         IN NUMBER,
      p_contract_version    IN NUMBER,
      p_action_code         IN VARCHAR2,
      p_user_id             IN NUMBER:=NULL,
      p_note                IN VARCHAR2:=NULL,
    x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
      p_forward_user_id          IN NUMBER:=NULL)  IS

  l_api_name VARCHAR2(30);
  l_user_id  FND_USER.USER_ID%type;

  BEGIN

    l_api_name := 'add_approval_hist_record';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '300: Entered OKC_REP_UTIL_PVT.add_approval_hist_record');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '301: Contract Id is: ' || to_char(p_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '302: Contract version is: ' || p_contract_version);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '303: Action code is: ' || p_action_code);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '304: USer Id is: ' || to_char(p_user_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '305: Note is: ' || p_note);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                '306: Forwarded User Id is: ' || to_char(p_forward_user_id));
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name,
        'Before inserting a row into OKC_REP_CON_APPROVALS');
    END IF;

     -- Insert a row into OKC_REP_CON_APPROVALS
      INSERT INTO OKC_REP_CON_APPROVALS(
          contract_id,
          contract_version_num,
          action_code,
          user_id,
          action_date,
          notes,
          object_version_number,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          forward_user_id)
      VALUES(
          p_contract_id,
          p_contract_version,
          p_action_code,
          p_user_id,
          sysdate,
          p_note,
          1,
          p_user_id,
          sysdate,
          p_user_id,
          sysdate,
          p_user_id,
          p_forward_user_id);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
        g_module || l_api_name,
        'After inserting a row into OKC_REP_CON_APPROVALS');
    END IF;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 'Leaving add_approval_hist_record:FND_API.G_EXC_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 'Leaving add_approval_hist_record: FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || l_api_name || '.exception',
                 'Leaving add_approval_hist_record because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END add_approval_hist_record;


  -- Start of comments
  --API name      : validate_contract_party
  --Type          : Private.
  --Function      : Validates a contract party
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                   Contract ID of the party to be validated
  --              : p_intent    IN VARCHAR2       Required
  --                   Intent of the contract
  --              : p_party_role_code    IN OUT VARCHAR2       Optional
  --                   Role code of the contract party to be validated
  --              : p_party_role_txt    IN VARCHAR2       Optional
  --                   Role name of the contract party to be validated
  --              : p_party_id    IN OUT NUMBER       Optional
  --                   Id of the contract party to be validated
  --              : p_party_name    IN VARCHAR2       Required
  --                   Name of the contract party to be validated
  --              : p_location_id    IN NUMBER       Optional
  --                   Id of the location of the contract party to be validated
  --              : p_mode    IN VARCHAR2       Required
  --                   Mode of the validation. Possible values 'IMPORT' or 'AUTHORING'
  --OUT           : x_valid_party_flag       OUT  VARCHAR2(1)
  --              : x_error_code          OUT  VARCHAR2(100)
  --                   Possible error codes are;
  --                     ROLE_NOT_EXIST - Party role doesn't exist (Import module)
  --                     INV_ROLE_INTENT - Party role and Contract intent combination is invalid (Import module)
  --                     PARTY_NOT_EXIST - Party doesn't exist (Import module)
  --                     INV_CUST_ACCT - Customer party doesn't have any customer accounts (Import module)
  --                     PARTY_NOT_UNIQUE - Party in not unique in the Contract (Import and Authoring modules)
  --                     INV_ROLE_PARTY - Role and Party combination is invalid (Authoring module)
  --                     INV_ROLE_LOCATION - Role and Party Location combination is invalid (Authoring module)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments

  PROCEDURE validate_contract_party(
         p_api_version              IN NUMBER,
         p_init_msg_list            IN VARCHAR2,
         p_contract_id              IN NUMBER,
         p_intent                   IN VARCHAR2 DEFAULT NULL,
         p_party_role_code          IN OUT NOCOPY VARCHAR2,
         p_party_role_txt           IN VARCHAR2 DEFAULT NULL,
         p_party_id                 IN OUT NOCOPY NUMBER,
         p_party_name               IN VARCHAR2,
         p_location_id              IN NUMBER DEFAULT NULL,
         p_mode                     IN VARCHAR2,
         x_valid_party_flag         OUT NOCOPY VARCHAR2,
         x_error_code           OUT NOCOPY VARCHAR2,
         x_return_status            OUT NOCOPY VARCHAR2,
         x_msg_count                OUT NOCOPY NUMBER,
         x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
  l_api_name VARCHAR2(30);
  l_api_version       CONSTANT NUMBER := 1.0;
  l_temp NUMBER;
  l_party_role_code2 VARCHAR2(30);


  CURSOR party_role_exist_csr IS
       SELECT  resp_party_code
       FROM    okc_resp_parties_tl
       WHERE   UPPER(name) = UPPER(p_party_role_txt)
       AND     language = USERENV('LANG')
       AND     document_type_class = 'REPOSITORY';

  CURSOR party_role_valid_csr IS
       SELECT  1
       FROM    okc_resp_parties_b
       WHERE   resp_party_code = p_party_role_code
       AND     intent = p_intent
       AND     document_type_class = 'REPOSITORY';

  CURSOR internal_party_exist_csr IS
       SELECT  organization_id
       FROM    hr_all_organization_units
       WHERE   UPPER(name) = UPPER(p_party_name);

  CURSOR tca_party_exist_csr IS
       SELECT  party_id
       FROM    hz_parties
       WHERE   UPPER(party_name) = UPPER(p_party_name)
	AND     party_type IN ('ORGANIZATION', 'PERSON'); 	 /*--10334886: Added person party Type*/

  /*CURSOR vendor_exist_csr IS
       SELECT  vendor_id
       FROM    po_vendors
       WHERE   UPPER(vendor_name) = UPPER(p_party_name);*/

  CURSOR vendor_exist_csr IS
       SELECT  ap.vendor_id
       FROM    ap_suppliers ap,
            hz_parties hp
       WHERE ap.party_id = hp.party_id
    AND UPPER(hp.party_name) = UPPER(p_party_name);

  CURSOR rep_party_unique_csr(l_party_role_code2 varchar2) IS
       SELECT  1
       FROM    okc_rep_contract_parties
       WHERE   contract_id = p_contract_id
       AND     party_id = p_party_id
       AND     party_role_code IN (p_party_role_code, l_party_role_code2);

  CURSOR imp_party_unique_csr IS
       SELECT  1
       FROM    okc_rep_imp_parties_t
       WHERE   imp_contract_id = p_contract_id
       AND     party_id = p_party_id
       AND     party_role_code = p_party_role_code;

  CURSOR internal_party_and_role_csr IS
       SELECT  1
       FROM    hr_all_organization_units
       WHERE   UPPER(name) = UPPER(p_party_name)
       AND     organization_id = p_party_id;

  CURSOR tca_party_and_role_csr IS
       SELECT  1
       FROM    hz_parties
       WHERE   UPPER(party_name) = UPPER(p_party_name)
       AND     party_id = p_party_id;

  /*CURSOR vendor_and_role_csr IS
       SELECT  1
       FROM    po_vendors
       WHERE   UPPER(vendor_name) = UPPER(p_party_name)
       AND     vendor_id = p_party_id;  */

  CURSOR vendor_and_role_csr IS
       SELECT  1
       FROM    ap_suppliers ap,
               hz_parties hp
       WHERE   UPPER(ap.vendor_name) = UPPER(p_party_name)
       AND     hp.party_id = ap.party_id
       AND     ap.vendor_id = p_party_id;

  CURSOR tca_location_valid_csr IS
       SELECT  1
       FROM    hz_party_sites
       WHERE   party_id = p_party_id
       AND     party_site_id = p_location_id;

  CURSOR vendor_location_valid_csr IS
       SELECT  1
       FROM    po_vendor_sites_all
       WHERE   vendor_id = p_party_id
       AND     vendor_site_id = p_location_id;

  BEGIN

  l_api_name := 'validate_contract_party';

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Entered OKC_REP_WF_PVT.validate_contract_party');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_contract_id = ' || p_contract_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_intent = ' || p_intent);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_party_role_code = ' || p_party_role_code);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_party_role_txt = ' || p_party_role_txt);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_party_id = ' || p_party_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_party_name = ' || p_party_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_location_id = ' || p_location_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'p_mode = ' || p_mode);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_valid_party_flag := 'Y';

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Validating Contract Party for ' || p_mode || ' module');
  END IF;

  IF(p_mode = G_P_MODE_IMPORT) THEN

    -- Check existence of the party role
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Checking existence of the party role');
    END IF;

    OPEN  party_role_exist_csr;
    FETCH party_role_exist_csr  INTO  p_party_role_code;

    IF party_role_exist_csr%NOTFOUND THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
           'Party role not found');
      END IF;

      CLOSE party_role_exist_csr;

      x_valid_party_flag := 'N';
      x_error_code := 'ROLE_NOT_EXIST';

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_valid_party_flag: ' || x_valid_party_flag);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_error_code: ' || x_error_code);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_WF_PVT.validate_contract_party');
      END IF;

      return;
    END IF;

    CLOSE party_role_exist_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Party Role found with code ' || p_party_role_code);
    END IF;


    -- Check validity of the party role and contract intent combination
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Checking validity of the party role and contract intent combination');
    END IF;

    OPEN  party_role_valid_csr;
    FETCH party_role_valid_csr INTO l_temp;

    IF party_role_valid_csr%NOTFOUND THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
           'Party role and contract intent combination is invalid');
      END IF;

      CLOSE party_role_valid_csr;

      x_valid_party_flag := 'N';
      x_error_code := 'INV_ROLE_INTENT';

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_valid_party_flag: ' || x_valid_party_flag);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_error_code: ' || x_error_code);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_WF_PVT.validate_contract_party');
      END IF;

      return;
    END IF;

    CLOSE party_role_valid_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Party role and contract intent combination is valid');
    END IF;

    -- Check existence of the party
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Checking existence of the party');
    END IF;

    IF (p_party_role_code = 'INTERNAL_ORG') THEN

      OPEN  internal_party_exist_csr;
      FETCH internal_party_exist_csr INTO p_party_id;

      IF internal_party_exist_csr%NOTFOUND THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Party not found');
        END IF;

        CLOSE internal_party_exist_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'PARTY_NOT_EXIST';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE internal_party_exist_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_PARTNER OR
           p_party_role_code = G_PARTY_ROLE_CUSTOMER) THEN

      OPEN  tca_party_exist_csr;
      FETCH tca_party_exist_csr INTO p_party_id;

      IF tca_party_exist_csr%NOTFOUND THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Party not found');
        END IF;

        CLOSE tca_party_exist_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'PARTY_NOT_EXIST';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE tca_party_exist_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_SUPPLIER) THEN

      OPEN  vendor_exist_csr;
      FETCH vendor_exist_csr INTO p_party_id;

      IF vendor_exist_csr%NOTFOUND THEN
        CLOSE vendor_exist_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'PARTY_NOT_EXIST';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE vendor_exist_csr;

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Party found with id ' || p_party_id);
    END IF;

  END IF; -- End of p_mode = 'IMPORT'


  -- If p_mode = 'AUTHORING', then check uniqueness of the contract party in the repository table
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Checking uniqueness of the party in contract');
  END IF;

  IF (p_mode = G_P_MODE_AUTHORING) THEN

    IF (p_party_role_code = G_PARTY_ROLE_PARTNER OR
        p_party_role_code = G_PARTY_ROLE_CUSTOMER) THEN
      l_party_role_code2 := G_PARTY_ROLE_CUSTOMER;
    END IF;

    OPEN  rep_party_unique_csr(l_party_role_code2);
    FETCH rep_party_unique_csr INTO l_temp;

    IF (rep_party_unique_csr%FOUND) THEN

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party already exist in the contract');
      END IF;

      CLOSE rep_party_unique_csr;

      x_valid_party_flag := 'N';
      x_error_code := 'PARTY_NOT_UNIQUE';

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_valid_party_flag: ' || x_valid_party_flag);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_error_code: ' || x_error_code);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_WF_PVT.validate_contract_party');
      END IF;

      return;
    END IF;

    CLOSE rep_party_unique_csr;

  END IF;

  -- If p_mode = 'IMPORT', then check uniqueness of the contract party in the import table
  IF (p_mode = G_P_MODE_IMPORT) THEN

    OPEN  imp_party_unique_csr;
    FETCH imp_party_unique_csr INTO p_party_id;

    IF imp_party_unique_csr%FOUND THEN

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party already exist in the contract');
      END IF;

      CLOSE imp_party_unique_csr;

      x_valid_party_flag := 'N';
      x_error_code := 'PARTY_NOT_UNIQUE';

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_valid_party_flag: ' || x_valid_party_flag);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_error_code: ' || x_error_code);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_WF_PVT.validate_contract_party');
      END IF;

      return;
    END IF;

    CLOSE imp_party_unique_csr;

  END IF;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Party is unique in the contract');
  END IF;

  IF (p_mode = G_P_MODE_AUTHORING) THEN

    -- Check validity of party role and party combination
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Checking validity of party role and party combination');
    END IF;

    IF (p_party_role_code = G_PARTY_ROLE_INTERNAL) THEN

      OPEN  internal_party_and_role_csr;
      FETCH internal_party_and_role_csr INTO l_temp;

      IF internal_party_and_role_csr%NOTFOUND THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Party with id' || p_party_id || ' and name ' || p_party_name || 'not found in table HR_ALL_ORGANIZATION_UNITS');
        END IF;

        CLOSE internal_party_and_role_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'INV_ROLE_PARTY';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE internal_party_and_role_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_PARTNER OR
           p_party_role_code = G_PARTY_ROLE_CUSTOMER) THEN

      OPEN  tca_party_and_role_csr;
      FETCH tca_party_and_role_csr INTO l_temp;

      IF tca_party_and_role_csr%NOTFOUND THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Party with id' || p_party_id || ' and name ' || p_party_name || 'not found in table HZ_PARTIES');
        END IF;

        CLOSE tca_party_and_role_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'INV_ROLE_PARTY';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE tca_party_and_role_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_SUPPLIER) THEN

      OPEN  vendor_and_role_csr;
      FETCH vendor_and_role_csr INTO l_temp;

      IF vendor_and_role_csr%NOTFOUND THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Party with id' || p_party_id || ' and name ' || p_party_name || 'not found in table PO_VENDORS');
        END IF;

        CLOSE vendor_and_role_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'INV_ROLE_PARTY';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE vendor_and_role_csr;

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Party role and party combination is valid');
    END IF;

    -- Check validity of party and location combination
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Checking validity of party role and party address combination');
    END IF;

    -- Bug 4247146. Added null check for party location id as the Party
    -- Address/Site field in the Add party page became optional
    IF ((p_location_id IS NOT NULL) AND
        (p_party_role_code = G_PARTY_ROLE_PARTNER OR
         p_party_role_code = G_PARTY_ROLE_CUSTOMER)) THEN

      OPEN  tca_location_valid_csr;
      FETCH tca_location_valid_csr INTO l_temp;

      IF tca_location_valid_csr%NOTFOUND THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Party role and party address combination is invalid');
        END IF;

        CLOSE tca_location_valid_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'INV_ROLE_LOCATION';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE tca_location_valid_csr;

    ELSIF (p_location_id IS NOT NULL AND
           p_party_role_code = G_PARTY_ROLE_SUPPLIER) THEN

      OPEN  vendor_location_valid_csr;
      FETCH vendor_location_valid_csr INTO l_temp;

      IF vendor_location_valid_csr%NOTFOUND THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Party role and party address combination is invalid');
        END IF;

        CLOSE vendor_location_valid_csr;

        x_valid_party_flag := 'N';
        x_error_code := 'INV_ROLE_LOCATION';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_party_flag: ' || x_valid_party_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_contract_party');
        END IF;

        return;
      END IF;

      CLOSE vendor_location_valid_csr;

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Party role and party address combination is valid');
    END IF;

  END IF; -- End of p_mode = 'AUTHORING'


  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      --close cursors
      IF (party_role_exist_csr%ISOPEN) THEN
        CLOSE party_role_exist_csr ;
      END IF;
      IF (party_role_valid_csr%ISOPEN) THEN
        CLOSE party_role_valid_csr ;
      END IF;
      IF (internal_party_exist_csr%ISOPEN) THEN
        CLOSE internal_party_exist_csr ;
      END IF;
      IF (tca_party_exist_csr%ISOPEN) THEN
        CLOSE tca_party_exist_csr ;
      END IF;
      IF (vendor_exist_csr%ISOPEN) THEN
        CLOSE vendor_exist_csr ;
      END IF;
      IF (rep_party_unique_csr%ISOPEN) THEN
        CLOSE rep_party_unique_csr ;
      END IF;
      IF (imp_party_unique_csr%ISOPEN) THEN
        CLOSE imp_party_unique_csr ;
      END IF;
      IF (internal_party_and_role_csr%ISOPEN) THEN
        CLOSE internal_party_and_role_csr ;
      END IF;
      IF (tca_party_and_role_csr%ISOPEN) THEN
        CLOSE tca_party_and_role_csr ;
      END IF;
      IF (vendor_and_role_csr%ISOPEN) THEN
        CLOSE vendor_and_role_csr ;
      END IF;
      IF (tca_location_valid_csr%ISOPEN) THEN
        CLOSE tca_location_valid_csr ;
      END IF;
      IF (vendor_location_valid_csr%ISOPEN) THEN
        CLOSE vendor_location_valid_csr ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving validate_contract_party:FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --close cursors
      IF (party_role_exist_csr%ISOPEN) THEN
        CLOSE party_role_exist_csr ;
      END IF;
      IF (party_role_valid_csr%ISOPEN) THEN
        CLOSE party_role_valid_csr ;
      END IF;
      IF (internal_party_exist_csr%ISOPEN) THEN
        CLOSE internal_party_exist_csr ;
      END IF;
      IF (tca_party_exist_csr%ISOPEN) THEN
        CLOSE tca_party_exist_csr ;
      END IF;
      IF (vendor_exist_csr%ISOPEN) THEN
        CLOSE vendor_exist_csr ;
      END IF;
      IF (rep_party_unique_csr%ISOPEN) THEN
        CLOSE rep_party_unique_csr ;
      END IF;
      IF (imp_party_unique_csr%ISOPEN) THEN
        CLOSE imp_party_unique_csr ;
      END IF;
      IF (internal_party_and_role_csr%ISOPEN) THEN
        CLOSE internal_party_and_role_csr ;
      END IF;
      IF (tca_party_and_role_csr%ISOPEN) THEN
        CLOSE tca_party_and_role_csr ;
      END IF;
      IF (vendor_and_role_csr%ISOPEN) THEN
        CLOSE vendor_and_role_csr ;
      END IF;
      IF (tca_location_valid_csr%ISOPEN) THEN
        CLOSE tca_location_valid_csr ;
      END IF;
      IF (vendor_location_valid_csr%ISOPEN) THEN
        CLOSE vendor_location_valid_csr ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving validate_contract_party:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN

      --close cursors
      IF (party_role_exist_csr%ISOPEN) THEN
        CLOSE party_role_exist_csr ;
      END IF;
      IF (party_role_valid_csr%ISOPEN) THEN
        CLOSE party_role_valid_csr ;
      END IF;
      IF (internal_party_exist_csr%ISOPEN) THEN
        CLOSE internal_party_exist_csr ;
      END IF;
      IF (tca_party_exist_csr%ISOPEN) THEN
        CLOSE tca_party_exist_csr ;
      END IF;
      IF (vendor_exist_csr%ISOPEN) THEN
        CLOSE vendor_exist_csr ;
      END IF;
      IF (rep_party_unique_csr%ISOPEN) THEN
        CLOSE rep_party_unique_csr ;
      END IF;
      IF (imp_party_unique_csr%ISOPEN) THEN
        CLOSE imp_party_unique_csr ;
      END IF;
      IF (internal_party_and_role_csr%ISOPEN) THEN
        CLOSE internal_party_and_role_csr ;
      END IF;
      IF (tca_party_and_role_csr%ISOPEN) THEN
        CLOSE tca_party_and_role_csr ;
      END IF;
      IF (vendor_and_role_csr%ISOPEN) THEN
        CLOSE vendor_and_role_csr ;
      END IF;
      IF (tca_location_valid_csr%ISOPEN) THEN
        CLOSE tca_location_valid_csr ;
      END IF;
      IF (vendor_location_valid_csr%ISOPEN) THEN
        CLOSE vendor_location_valid_csr ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving validate_contract_party because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => sqlcode,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END validate_contract_party;


  -- Start of comments
  --API name      : validate_party_contact
  --Type          : Private.
  --Function      : Validates a party contact
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                   Contract ID of the party contact to be validated
  --              : p_party_role_code    IN VARCHAR2       Required
  --                   Role code of the party of the contact to be validated
  --              : p_party_id    IN    NUMBER       Required
  --                   Id of the contract party to be validated
  --              : p_contact_id    IN   NUMBER       Required
  --                   Id of the party contact to be validated
  --              : p_contact_name    IN   VARCHAR2       Required
  --                   Name of the party contact to be validated
  --              : p_contact_role_id    IN   NUMBER       Required
  --                   Id of the role of the party contact to be validated
  --OUT           : x_valid_contact_flag       OUT  VARCHAR2(1)
  --              : x_error_code          OUT  VARCHAR2(100)
  --                   Possible error codes are;
  --                     CONTACT_NOT_UNIQUE - Contact is not unique in the party
  --                     CONTACT_NOT_EXIST - Party and contact combination is invalid
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_party_contact(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_contract_id              IN NUMBER,
       p_party_role_code          IN VARCHAR2,
       p_party_id                 IN NUMBER,
       p_contact_id               IN NUMBER,
       p_contact_name             IN VARCHAR2,
       p_contact_role_id          IN NUMBER,
       x_valid_contact_flag       OUT NOCOPY VARCHAR2,
       x_error_code               OUT NOCOPY VARCHAR2,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;
    l_temp NUMBER;


    CURSOR contact_unique_csr IS
          SELECT  1
          FROM    okc_rep_party_contacts
          WHERE   contract_id = p_contract_id
          AND     party_id = p_party_id
          AND     party_role_code = p_party_role_code
          AND     contact_id = p_contact_id
          AND     contact_role_id = p_contact_role_id;

-- Bug 6598261.Changed per_all_workforce_v to per_workforce_v.

    CURSOR internal_party_contact_csr IS
          SELECT  1
          FROM    per_workforce_v
          WHERE   person_id = p_contact_id
          AND     full_name = p_contact_name;

    CURSOR tca_party_contact_csr IS
          SELECT  1
          FROM    hz_relationships  hr,
                  hz_parties  hz,
                  hz_parties  hz1
          WHERE   hr.party_id = p_contact_id
          AND     hr.subject_type = 'PERSON'
          AND     hr.object_type = 'ORGANIZATION'
          AND     hr.object_table_name = 'HZ_PARTIES'
          AND     hr.object_id = p_party_id
          AND     hr.relationship_code = 'CONTACT_OF'
          AND     hz.party_id = p_contact_id
          AND     hz1.party_id = hr.subject_id
          AND     hz1.party_name = p_contact_name;

    CURSOR vendor_party_contact_csr IS
          SELECT   1
          FROM     po_vendor_contacts   pvc,
                   Po_vendor_sites_all    pvs
          WHERE    pvs.vendor_id = p_party_id
          AND      pvc.vendor_site_id = pvs.vendor_site_id
          AND      pvc.vendor_contact_id = p_contact_id;


  BEGIN

    l_api_name := 'validate_party_contact';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_WF_PVT.validate_party_contact');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_contract_id = ' || p_contract_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_party_role_code = ' || p_party_role_code);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_party_id = ' || p_party_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_contact_id = ' || p_contact_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_contact_name = ' || p_contact_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_contact_role_id = ' || p_contact_role_id);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_valid_contact_flag := 'Y';

    -- Check uniqueness of the party contact
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Checking uniqueness of the party contact');
    END IF;

    OPEN  contact_unique_csr;
    FETCH contact_unique_csr INTO l_temp;

    IF (contact_unique_csr%FOUND) THEN

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contact already exist in the party');
      END IF;

      CLOSE contact_unique_csr;

      x_valid_contact_flag := 'N';
      x_error_code := 'CONTACT_NOT_UNIQUE';

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_valid_contact_flag: ' || x_valid_contact_flag);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'x_error_code: ' || x_error_code);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_WF_PVT.validate_party_contact');
      END IF;

      return;

    END IF;

    CLOSE contact_unique_csr;



    -- Check validity of party and contact combination
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Checking validity of party and contact combination');
    END IF;

    IF (p_party_role_code = G_PARTY_ROLE_INTERNAL) THEN

      OPEN  internal_party_contact_csr;
      FETCH internal_party_contact_csr INTO l_temp;

      IF (internal_party_contact_csr%NOTFOUND) THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Combination of party and contact is invalid');
        END IF;

        CLOSE internal_party_contact_csr;

        x_valid_contact_flag := 'N';
        x_error_code := 'CONTACT_NOT_EXIST';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_contact_flag: ' || x_valid_contact_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_party_contact');
        END IF;

        return;

      END IF;

      CLOSE internal_party_contact_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_PARTNER OR
           p_party_role_code = G_PARTY_ROLE_CUSTOMER) THEN

      OPEN  tca_party_contact_csr;
      FETCH tca_party_contact_csr INTO l_temp;

      IF (tca_party_contact_csr%NOTFOUND) THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Combination of party and contact is invalid');
        END IF;

        CLOSE tca_party_contact_csr;

        x_valid_contact_flag := 'N';
        x_error_code := 'CONTACT_NOT_EXIST';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_contact_flag: ' || x_valid_contact_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_party_contact');
        END IF;

        return;

      END IF;

      CLOSE tca_party_contact_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_SUPPLIER) THEN

      OPEN  vendor_party_contact_csr;
      FETCH vendor_party_contact_csr INTO l_temp;

      IF (vendor_party_contact_csr%NOTFOUND) THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Combination of party and contact is invalid');
        END IF;

        CLOSE vendor_party_contact_csr;

        x_valid_contact_flag := 'N';
        x_error_code := 'CONTACT_NOT_EXIST';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_valid_contact_flag: ' || x_valid_contact_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'x_error_code: ' || x_error_code);
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_WF_PVT.validate_party_contact');
        END IF;

        return;

      END IF;

      CLOSE vendor_party_contact_csr;

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Party and contact combination is valid');
    END IF;


  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      --close cursors
      IF (contact_unique_csr%ISOPEN) THEN
        CLOSE contact_unique_csr ;
      END IF;
      IF (internal_party_contact_csr%ISOPEN) THEN
        CLOSE internal_party_contact_csr ;
      END IF;
      IF (tca_party_contact_csr%ISOPEN) THEN
        CLOSE tca_party_contact_csr ;
      END IF;
      IF (vendor_party_contact_csr%ISOPEN) THEN
        CLOSE vendor_party_contact_csr ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving validate_party_contact:FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --close cursors
      IF (contact_unique_csr%ISOPEN) THEN
        CLOSE contact_unique_csr ;
      END IF;
      IF (internal_party_contact_csr%ISOPEN) THEN
        CLOSE internal_party_contact_csr ;
      END IF;
      IF (tca_party_contact_csr%ISOPEN) THEN
        CLOSE tca_party_contact_csr ;
      END IF;
      IF (vendor_party_contact_csr%ISOPEN) THEN
        CLOSE vendor_party_contact_csr ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving validate_party_contact:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN

      --close cursors
      IF (contact_unique_csr%ISOPEN) THEN
        CLOSE contact_unique_csr ;
      END IF;
      IF (internal_party_contact_csr%ISOPEN) THEN
        CLOSE internal_party_contact_csr ;
      END IF;
      IF (tca_party_contact_csr%ISOPEN) THEN
        CLOSE tca_party_contact_csr ;
      END IF;
      IF (vendor_party_contact_csr%ISOPEN) THEN
        CLOSE vendor_party_contact_csr ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving validate_party_contact because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END validate_party_contact;

  -- Start of comments
  --API name      : populate_import_errors
  --Type          : Private.
  --Function      : Populate the okc_rep_imp_errors_t table with error messages
  --Pre-reqs      : None
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                    Contract ID that the error is from
  --              : p_error_obj_type    IN    VARCHAR2       Required
  --                    Error Object Type: 'CONTRACT', 'PARTY', 'DOCUMENT'
  --              : p_error_obj_id     IN NUMBER       Required
  --                   Error Object's ID
  --              : p_error_msg_txt  IN VARCHAR2       Required
  --                   Translated error message text
  --              : p_program_id                IN  NUMBER Required
  --                    Concurrent program ID
  --              : p_program_login_id          IN  NUMBER Required
  --                    Concurrent program login ID
  --              : p_program_app_id            IN  NUMBER Required
  --                    Concurrent program application ID
  --              : p_request_id                IN  NUMBER Required
  --                    Concurrent program request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE populate_import_errors(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_contract_id              IN NUMBER,
       p_error_obj_type           IN VARCHAR2,
       p_error_obj_id             IN NUMBER,
       p_error_msg_txt            IN VARCHAR2,
       p_program_id               IN NUMBER,
       p_program_login_id         IN NUMBER,
       p_program_app_id           IN NUMBER,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;

    l_imp_error_id              NUMBER;

    CURSOR ERROR_ID_CSR IS
    SELECT OKC_REP_IMP_ERRORS_T_S.NEXTVAL
    FROM DUAL;

    BEGIN

    l_api_name := 'populate_import_errors';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_UTIL_PVT.populate_import_errors');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_contract_id = ' || p_contract_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_error_obj_type = ' || p_error_obj_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_error_obj_id = ' || p_error_obj_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_error_msg_txt = ' || p_error_msg_txt);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_program_id = ' || p_program_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_program_login_id = ' || p_program_login_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_program_app_id = ' || p_program_app_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_request_id = ' || p_request_id);


    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;



    OPEN ERROR_ID_CSR;
    FETCH ERROR_ID_CSR INTO l_imp_error_id;
    CLOSE ERROR_ID_CSR;

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'l_imp_error_id: '||l_imp_error_id);
    END IF;

    INSERT INTO OKC_REP_IMP_ERRORS_T(
    IMP_ERROR_ID,
    IMP_CONTRACT_ID,
    ERROR_OBJECT_TYPE,
    ERROR_OBJECT_ID,
    ERROR_MESSAGE,
    CREATION_DATE,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID)
    VALUES(
    l_imp_error_id,
    p_contract_id,
    p_error_obj_type,
    p_error_obj_id,
    p_error_msg_txt,
    sysdate,
    p_program_id,
    p_program_login_id,
    p_program_app_id,
    p_request_id
    );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      --close cursors
      IF (ERROR_ID_CSR%ISOPEN) THEN
        CLOSE ERROR_ID_CSR ;
      END IF;

      IF ERROR_ID_CSR%ISOPEN THEN
        CLOSE ERROR_ID_CSR;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving populate_import_errors:FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --close cursors
      IF (ERROR_ID_CSR%ISOPEN) THEN
        CLOSE ERROR_ID_CSR ;
      END IF;

      IF ERROR_ID_CSR%ISOPEN THEN
        CLOSE ERROR_ID_CSR;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving populate_import_errors:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN

      --close cursors
      IF (ERROR_ID_CSR%ISOPEN) THEN
        CLOSE ERROR_ID_CSR ;
      END IF;

      IF ERROR_ID_CSR%ISOPEN THEN
        CLOSE ERROR_ID_CSR;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving populate_import_errors because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END populate_import_errors;


  -- Start of comments
  --API name      : validate_import_documents
  --Type          : Private.
  --Function      : Validates the contract documents stored in the interface table
  --                in a concurrent program.
  --Pre-reqs      : Currently only called from repository import.
  --              : Contract documents should be saved to the OKC_REP_IMP_DOCUMENTS_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent program request id
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_import_documents(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;

    l_category_code     VARCHAR2(30);
    l_valid_flag        VARCHAR2(1);
    l_error_msg         VARCHAR2(2000);

    l_file_name_length  CONSTANT NUMBER := 2048;
    l_file_desc_length  CONSTANT NUMBER := 255;

    CURSOR IMPORT_DOCUMENTS_CSR IS
    SELECT IMP_DOCUMENT_ID,
    IMP_CONTRACT_ID,
    DOCUMENT_INDEX,
    FILE_NAME,
    DOCUMENT_DESC,
    CATEGORY_NAME_TXT,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID
    FROM OKC_REP_IMP_DOCUMENTS_T
    WHERE REQUEST_ID = p_request_id
    AND VALID_FLAG in ('Y', 'U');

    l_import_documents_rec IMPORT_DOCUMENTS_CSR%ROWTYPE;

    CURSOR document_category_csr (p_category_name VARCHAR2) IS
    select cat.name
    from fnd_document_categories cat,
    fnd_document_categories_tl cattl
    where UPPER(cattl.user_name) = UPPER(p_category_name)
    and cat.category_id = cattl.category_id
    and cat.name like 'OKC_REPO_%'
    and (cat.start_date_active is null OR trunc(cat.start_date_active) <= trunc(sysdate))
    and (cat.end_date_active is null OR trunc(cat.end_date_active) >= trunc(sysdate))
    and language = userenv('LANG');


    BEGIN

    l_api_name := 'validate_import_documents';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_UTIL_PVT.'||l_api_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_request_id = ' || p_request_id);

    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN IMPORT_DOCUMENTS_CSR;
    LOOP
        FETCH IMPORT_DOCUMENTS_CSR INTO l_import_documents_rec;
        EXIT WHEN IMPORT_DOCUMENTS_CSR%NOTFOUND;

        --Initialize l_valid_flag for every record
        l_valid_flag := 'Y';
        --Initialize l_error_msg to be NULL
        l_error_msg := NULL;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --File Name should exist
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters file name');
        END IF;
        IF l_import_documents_rec.FILE_NAME IS NOT NULL THEN
            l_import_documents_rec.FILE_NAME := LTRIM(l_import_documents_rec.FILE_NAME);
            l_import_documents_rec.FILE_NAME := RTRIM(l_import_documents_rec.FILE_NAME);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_documents_rec.FILE_NAME IS NULL OR LENGTH(l_import_documents_rec.FILE_NAME)=0)) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_MISS_DOC_NAME');
            fnd_message.set_token(TOKEN => 'DOC_INDEX',
                                  VALUE => l_import_documents_rec.document_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Document Name is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_documents_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Document ID: '||l_import_documents_rec.imp_document_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;



       END IF;

       --If l_valid_flag is already set to 'N', we do not perform any more checks
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if file name is too long');
       END IF;
       --File Name should be <= 256
       IF (l_valid_flag = 'Y' AND LENGTH(l_import_documents_rec.file_name) > l_file_name_length) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_LONG_DOC_NAME');
            fnd_message.set_token(TOKEN => 'DOC_INDEX',
                                  VALUE => l_import_documents_rec.document_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document Name is too long');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_documents_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document ID: '||l_import_documents_rec.imp_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

       --If l_valid_flag is already set to 'N', we do not perform any more checks
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if file description is too long');
       END IF;
       --File Name should be <= 256
       IF (l_valid_flag = 'Y' AND l_import_documents_rec.document_desc IS NOT NULL AND LENGTH(l_import_documents_rec.document_desc) > l_file_desc_length) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_LONG_DOC_DESC');
            fnd_message.set_token(TOKEN => 'DOC_INDEX',
                                  VALUE => l_import_documents_rec.document_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document Description is too long');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_documents_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document ID: '||l_import_documents_rec.imp_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
            END IF;
       END IF;


       --If l_valid_flag is already set to 'N', we do not perform any more checks
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters category name');
        END IF;
        --Category Name Text should exist
        IF l_import_documents_rec.category_name_txt IS NOT NULL THEN
            l_import_documents_rec.category_name_txt := LTRIM(l_import_documents_rec.category_name_txt);
            l_import_documents_rec.category_name_txt := RTRIM(l_import_documents_rec.category_name_txt);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_documents_rec.category_name_txt IS NULL OR LENGTH(l_import_documents_rec.category_name_txt)=0)) THEN
                l_valid_flag := 'N';
                l_category_code := NULL;

                fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_MISS_DOC_CATEGORY');
                fnd_message.set_token(TOKEN => 'DOC_INDEX',
                                  VALUE => l_import_documents_rec.document_index);
                l_error_msg := fnd_message.get;
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document Category is missing');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_documents_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document ID: '||l_import_documents_rec.imp_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
        END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        IF l_valid_flag = 'Y' THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if category name is valid');
            END IF;

            OPEN  document_category_csr(l_import_documents_rec.category_name_txt);
            FETCH document_category_csr  INTO  l_category_code;

            IF document_category_csr%NOTFOUND THEN
                    l_valid_flag := 'N';
                    l_category_code := NULL;

                    fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_INV_DOC_CATEGORY');
                    fnd_message.set_token(TOKEN => 'DOC_INDEX',
                                  VALUE => l_import_documents_rec.document_index);
                    l_error_msg := fnd_message.get;
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Category ID not found with given category name: '||l_import_documents_rec.category_name_txt);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract ID: '||l_import_documents_rec.imp_contract_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Document ID: '||l_import_documents_rec.imp_document_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'l_error_msg: '||l_error_msg);
                    END IF;
            END IF;

            CLOSE document_category_csr;
      END IF;

        --Populate the valid_flag and category_code columns in OKC_REP_IMP_DOCUMENTS_T
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Updating OKC_REP_IMP_DOCUMENTS_T');
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'DOCUMENT ID: '||l_import_documents_rec.imp_document_id);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'l_category_code: '||l_category_code);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'l_valid_flag: '||l_valid_flag);
        END IF;

        --Populate the error message table
        IF(l_valid_flag = 'N' AND l_error_msg IS NOT NULL) THEN
            populate_import_errors(p_init_msg_list => FND_API.G_FALSE,
                                   p_api_version => 1.0,
                                   p_contract_id => l_import_documents_rec.imp_contract_id,
                                p_error_obj_type => G_IMP_DOCUMENT_ERROR,
                                p_error_obj_id => l_import_documents_rec.imp_document_id,
                                p_error_msg_txt => l_error_msg,
                                p_program_id => l_import_documents_rec.program_id,
                                p_program_login_id => l_import_documents_rec.program_login_id,
                                p_program_app_id => l_import_documents_rec.program_application_id,
                                p_request_id => l_import_documents_rec.request_id,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);
        END IF;

        IF(l_valid_flag = 'Y') THEN
        --Update the record in OKC_REP_IMP_DOCUMENTS_T
        UPDATE OKC_REP_IMP_DOCUMENTS_T
        SET CATEGORY_CODE = l_category_code,
        VALID_FLAG = l_valid_flag
        where imp_document_id = l_import_documents_rec.imp_document_id;
        END IF;

        IF(l_valid_flag = 'N') THEN
        UPDATE OKC_REP_IMP_DOCUMENTS_T
        SET VALID_FLAG = l_valid_flag
        where imp_document_id = l_import_documents_rec.imp_document_id;
        END IF;

    END LOOP;
    CLOSE IMPORT_DOCUMENTS_CSR;

    --bug fix for 4209521
    --need to commit or the Java layer will not pick up the changes
    COMMIT;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF IMPORT_DOCUMENTS_CSR%ISOPEN THEN
        CLOSE IMPORT_DOCUMENTS_CSR;
      END IF;

      IF document_category_csr%ISOPEN THEN
        CLOSE document_category_csr;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF IMPORT_DOCUMENTS_CSR%ISOPEN THEN
        CLOSE IMPORT_DOCUMENTS_CSR;
      END IF;

      IF document_category_csr%ISOPEN THEN
        CLOSE document_category_csr;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN
      IF IMPORT_DOCUMENTS_CSR%ISOPEN THEN
        CLOSE IMPORT_DOCUMENTS_CSR;
      END IF;

      IF document_category_csr%ISOPEN THEN
        CLOSE document_category_csr;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||' because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END validate_import_documents;

  -- Start of comments
  --API name      : validate_import_parties
  --Type          : Private.
  --Function      : Validates contract parties during import
  --Pre-reqs      : Currently only called from repository import.
  --              : Contracts should be saved to the OKC_REP_IMP_PARTIES_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_import_parties(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;

    l_valid_flag        VARCHAR2(1);
    l_error_code        VARCHAR2(20);
    l_error_msg         VARCHAR2(2000);


    l_signed_by_length  CONSTANT NUMBER := 150;

    l_party_role_code   VARCHAR2(240);
    l_party_id          NUMBER;
    l_contract_intent   VARCHAR2(1);
    l_signed_date       DATE;


    CURSOR IMPORT_PARTIES_CSR IS
    SELECT IMP_PARTY_ID,
    IMP_CONTRACT_ID,
    PARTY_INDEX,
    SIGNED_BY_TXT,
    SIGNED_DATE,
    PARTY_NAME_TXT,
    PARTY_ROLE_TXT,
    VALID_FLAG,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID
    FROM OKC_REP_IMP_PARTIES_T
    WHERE REQUEST_ID = p_request_id
    AND VALID_FLAG IN ('U', 'Y');

    l_import_parties_rec IMPORT_PARTIES_CSR%ROWTYPE;

    CURSOR CONTRACT_INTENT_CSR (p_imp_contract_id NUMBER) IS
    SELECT INTENT
    FROM OKC_BUS_DOC_TYPES_V bus_doc,
    OKC_REP_IMP_CONTRACTS_T temp
    WHERE bus_doc.name = temp.contract_type_txt
    AND temp.imp_contract_id = p_imp_contract_id
    AND bus_doc.document_type_class = 'REPOSITORY';

    BEGIN

    l_api_name := 'validate_import_parties';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_UTIL_PVT.'||l_api_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_request_id = ' || p_request_id);

    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN IMPORT_PARTIES_CSR;
    LOOP
        FETCH IMPORT_PARTIES_CSR INTO l_import_parties_rec;
        EXIT WHEN IMPORT_PARTIES_CSR%NOTFOUND;

        --Initialize l_valid_flag for every record
        l_valid_flag := 'Y';
        --Initialize l_error_msg for every record
        l_error_msg := NULL;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Party Name should exist
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters party name');
        END IF;
        IF l_import_parties_rec.party_name_txt IS NOT NULL THEN
            l_import_parties_rec.party_name_txt := LTRIM(l_import_parties_rec.party_name_txt);
            l_import_parties_rec.party_name_txt := RTRIM(l_import_parties_rec.party_name_txt);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_parties_rec.party_name_txt IS NULL OR LENGTH(l_import_parties_rec.party_name_txt)=0)) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_MISS_PARTY_NAME');
            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Name is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_parties_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party ID: '||l_import_parties_rec.imp_party_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Party Role should exist
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters party role');
        END IF;
        IF l_import_parties_rec.party_role_txt IS NOT NULL THEN
            l_import_parties_rec.party_role_txt := LTRIM(l_import_parties_rec.party_role_txt);
            l_import_parties_rec.party_role_txt := RTRIM(l_import_parties_rec.party_role_txt);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_parties_rec.party_role_txt IS NULL OR LENGTH(l_import_parties_rec.party_role_txt)=0)) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_MISS_PARTY_ROLE');
            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Role is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_parties_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party ID: '||l_import_parties_rec.imp_party_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;

       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Party Signed By should exist
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters party signed by');
        END IF;
        IF l_import_parties_rec.signed_by_txt IS NOT NULL THEN
            l_import_parties_rec.signed_by_txt := LTRIM(l_import_parties_rec.signed_by_txt);
            l_import_parties_rec.signed_by_txt := RTRIM(l_import_parties_rec.signed_by_txt);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_parties_rec.signed_by_txt IS NULL OR LENGTH(l_import_parties_rec.signed_by_txt)=0)) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_MISS_SIGNED_BY');
            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Signed By is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_parties_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party ID: '||l_import_parties_rec.imp_party_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;

       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Party Signed By should be <150
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if party signed by is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_parties_rec.signed_by_txt IS NOT NULL
            AND LENGTH(l_import_parties_rec.signed_by_txt) > l_signed_by_length) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_LONG_SIGNED_BY');
            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Signed By is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_parties_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party ID: '||l_import_parties_rec.imp_party_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;

       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Party Signed Date should exist
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters party signed date');
        END IF;
        IF l_import_parties_rec.signed_date IS NOT NULL THEN
            l_import_parties_rec.signed_date := LTRIM(l_import_parties_rec.signed_date);
            l_import_parties_rec.signed_date := RTRIM(l_import_parties_rec.signed_date);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_parties_rec.signed_date IS NULL OR LENGTH(l_import_parties_rec.signed_date)=0)) THEN
            l_valid_flag := 'N';

            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_MISS_SIGNED_DATE');
            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
            l_error_msg := fnd_message.get;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Signed Date is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_parties_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party ID: '||l_import_parties_rec.imp_party_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;

       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Party Signed Date should be the right format
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if party signed date is in the correct format');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_parties_rec.signed_date IS NOT NULL) THEN
        BEGIN
            l_signed_date := to_date(l_import_parties_rec.signed_date, G_IMP_DATE_FORMAT);
            EXCEPTION
                WHEN OTHERS THEN
                l_valid_flag := 'N';
                fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_INV_SIGNED_DATE');
                fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
                l_error_msg := fnd_message.get;

                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Party Signed Date is not valid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Party ID: '||l_import_parties_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
        END;
       END IF;


        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Now call validate_contract_party API
        IF (l_valid_flag = 'Y') THEN
            OPEN CONTRACT_INTENT_CSR (l_import_parties_rec.imp_contract_id);
                FETCH CONTRACT_INTENT_CSR INTO l_contract_intent;

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'l_contract_intent: '||l_contract_intent);
                END IF;

                IF (l_contract_intent IS NOT NULL ) THEN

                    validate_contract_party(p_api_version => 1.0,
                                    p_init_msg_list => FND_API.G_FALSE,
                                    p_contract_id => l_import_parties_rec.imp_contract_id,
                                    p_party_role_code => l_party_role_code,
                                    p_party_role_txt => l_import_parties_rec.party_role_txt,
                                    p_party_id => l_party_id,
                                    p_party_name => l_import_parties_rec.party_name_txt,
                                    p_mode => G_P_MODE_IMPORT,
                                    p_intent => l_contract_intent,
                                    x_valid_party_flag => l_valid_flag,
                                    x_error_code => l_error_code,
                                    x_return_status => x_return_status,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data);

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'After calling validate_contract_party, l_valid_flag: '||l_valid_flag);
                    END IF;

                    IF(l_valid_flag = 'N') THEN

                        --ROLE_NOT_EXIST - Party role doesn't exist
                        IF l_error_code = 'ROLE_NOT_EXIST' THEN
                            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_INV_PARTY_ROLE');
                            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                      VALUE => l_import_parties_rec.party_index);
                            l_error_msg := fnd_message.get;
                        END IF;

                        --INV_ROLE_INTENT - Party role and Contract intent combination is invalid
                        IF l_error_code = 'INV_ROLE_INTENT' THEN
                            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_INV_ROLE_INTENT');
                            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                    VALUE => l_import_parties_rec.party_index);
                            l_error_msg := fnd_message.get;

                        END IF;

                        --PARTY_NOT_EXIST - Party doesn't exist
                        IF l_error_code = 'PARTY_NOT_EXIST' THEN
                            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_INV_PARTY_NAME');
                            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                    VALUE => l_import_parties_rec.party_index);
                            l_error_msg := fnd_message.get;
                        END IF;

                        --INV_CUST_ACCT - Customer party doesn't have any customer accounts
                        IF l_error_code = 'INV_CUST_ACCT' THEN
                            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_INV_CUST_PARTY');
                            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                  VALUE => l_import_parties_rec.party_index);
                            l_error_msg := fnd_message.get;
                        END IF;

                        --PARTY_NOT_UNIQUE - Party in not unique in the Contract
                        IF l_error_code = 'PARTY_NOT_UNIQUE' THEN
                            fnd_message.set_name(G_APP_NAME,'OKC_REP_IMP_NONUNIQUE_PARTY');
                            fnd_message.set_token(TOKEN => 'PARTY_INDEX',
                                    VALUE => l_import_parties_rec.party_index);
                            l_error_msg := fnd_message.get;

                        END IF;

                    END IF;
/*                ELSE
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Contract type is invalid in csv file');
                    END IF;
                    --contract intent does not exist
                    --this means that contract_type_txt is invalid
                    --we need to flag the contract header as invalid
                    UPDATE OKC_REP_IMP_CONTRACTS_T
                    SET VALID_FLAG = 'N'
                    WHERE IMP_CONTRACT_ID = l_import_parties_rec.imp_contract_id;

                    --Also populate the error table
                    --Note that in this case we do not wait until the end to populate the error table
                    --because this time the error type is 'CONTRACT' and not 'PARTY'.
                    --The party may still be valid by itself.
                    l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_CON_TYPE');
                    populate_import_errors(p_init_msg_list => FND_API.G_FALSE,
                                   p_api_version => 1.0,
                                   p_contract_id => l_import_parties_rec.imp_contract_id,
                                   p_error_obj_type => G_IMP_CONTRACT_ERROR,
                                   p_error_obj_id => l_import_parties_rec.imp_contract_id,
                                   p_error_msg_txt => l_error_msg,
                                   p_program_id => l_import_parties_rec.program_id,
                                   p_program_login_id => l_import_parties_rec.program_login_id,
                                   p_program_app_id => l_import_parties_rec.program_application_id,
                                   p_request_id => l_import_parties_rec.request_id,
                                   x_return_status => x_return_status,
                                   x_msg_count => x_msg_count,
                                   x_msg_data => x_msg_data); */
                END IF;

            CLOSE CONTRACT_INTENT_CSR;

        END IF;


        --Populate the error message table
        IF(l_valid_flag = 'N' AND l_error_msg IS NOT NULL) THEN
            populate_import_errors(p_init_msg_list => FND_API.G_FALSE,
                                   p_api_version => 1.0,
                                   p_contract_id => l_import_parties_rec.imp_contract_id,
                                   p_error_obj_type => G_IMP_PARTY_ERROR,
                                   p_error_obj_id => l_import_parties_rec.imp_party_id,
                                   p_error_msg_txt => l_error_msg,
                                   p_program_id => l_import_parties_rec.program_id,
                                   p_program_login_id => l_import_parties_rec.program_login_id,
                                   p_program_app_id => l_import_parties_rec.program_application_id,
                                   p_request_id => l_import_parties_rec.request_id,
                                   x_return_status => x_return_status,
                                   x_msg_count => x_msg_count,
                                   x_msg_data => x_msg_data);
        END IF;


        --Update the record
        IF (l_valid_flag = 'Y') THEN
        UPDATE OKC_REP_IMP_PARTIES_T
        SET
        PARTY_ID = l_party_id,
        PARTY_ROLE_CODE = l_party_role_code,
        --SIGNED_DATE = l_signed_date,
        VALID_FLAG = l_valid_flag
        WHERE IMP_PARTY_ID = l_import_parties_rec.imp_party_id;
        END IF;

        IF (l_valid_flag = 'N') THEN
        UPDATE OKC_REP_IMP_PARTIES_T
        SET
        VALID_FLAG = l_valid_flag
        WHERE IMP_PARTY_ID = l_import_parties_rec.imp_party_id;
        END IF;

    END LOOP;
    CLOSE IMPORT_PARTIES_CSR;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Leaving OKC_REP_UTIL_PVT.'||l_api_name);
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      IF CONTRACT_INTENT_CSR%ISOPEN THEN
        CLOSE CONTRACT_INTENT_CSR;
      END IF;

      IF IMPORT_PARTIES_CSR%ISOPEN THEN
        CLOSE IMPORT_PARTIES_CSR;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF CONTRACT_INTENT_CSR%ISOPEN THEN
        CLOSE CONTRACT_INTENT_CSR;
      END IF;

      IF IMPORT_PARTIES_CSR%ISOPEN THEN
        CLOSE IMPORT_PARTIES_CSR;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN

      IF CONTRACT_INTENT_CSR%ISOPEN THEN
        CLOSE CONTRACT_INTENT_CSR;
      END IF;

      IF IMPORT_PARTIES_CSR%ISOPEN THEN
        CLOSE IMPORT_PARTIES_CSR;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||' because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END validate_import_parties;




  -- Start of comments
  --API name      : validate_import_contracts
  --Type          : Private.
  --Function      : Validates contracts during import
  --Pre-reqs      : Currently only called from repository import.
  --              : Contracts should be saved to the OKC_REP_IMP_CONTRACTS_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE validate_import_contracts(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;

    l_contract_number_length    CONSTANT NUMBER := 150;
    l_contract_name_length      CONSTANT NUMBER := 450;
    l_description_length        CONSTANT NUMBER := 2000;
    l_version_comments_length   CONSTANT NUMBER := 2000;
    l_keywords_length           CONSTANT NUMBER := 2000;
    l_location_length           CONSTANT NUMBER := 2000;
    l_orig_system_code_length   CONSTANT NUMBER := 30;
    l_orig_system_id1_length    CONSTANT NUMBER := 100;
    l_orig_system_id2_length    CONSTANT NUMBER := 100;

    --these are used to update the record
    l_valid_flag                VARCHAR2(1);
    l_status_code               VARCHAR2(30);
    l_contract_type             VARCHAR2(30);
    l_authoring_party_code      VARCHAR2(30);
    l_org_id                    NUMBER;
    l_owner_user_id             NUMBER;
    l_amount                    NUMBER;
    l_effective_date            DATE;
    l_expiration_date           DATE;
    l_currency_code             VARCHAR2(30);
    l_contract_id               NUMBER;
    l_contract_number           VARCHAR2(151);
    l_unique_contract_number    VARCHAR2(151); --used for checking contract number uniqueness

    l_error_msg                 VARCHAR2(2000);

    l_int_parties_count         NUMBER;
    l_ext_parties_count         NUMBER;
    -- l_intent                    VARCHAR2(30);

    --Used to check auto contract numbering profile option
    l_auto_number_yn            VARCHAR2(1);
    l_auto_number_option        CONSTANT VARCHAR2(30):= 'OKC_REP_AUTO_CON_NUMBER';

    -- Used for storing contract intent code
    l_contract_intent           VARCHAR2(30);

    CURSOR CONTRACT_ID_CSR IS
    SELECT OKC_REP_CONTRACTS_ALL_S1.NEXTVAL
    FROM DUAL;

    CURSOR CONTRACT_NUMBER_CSR IS
    SELECT OKC_REP_CONTRACTS_ALL_S2.NEXTVAL
    FROM DUAL;

    CURSOR CONTRACT_NUMBER_UNIQUE_CSR (p_contract_number VARCHAR2, p_imp_contract_id NUMBER) IS
    SELECT CONTRACT_NUMBER
    FROM OKC_REP_CONTRACTS_ALL
    WHERE UPPER(CONTRACT_NUMBER) = UPPER(p_contract_number)
    UNION
    SELECT CONTRACT_NUMBER
    FROM OKC_REP_IMP_CONTRACTS_T
    WHERE UPPER(CONTRACT_NUMBER) = UPPER(p_contract_number)
    AND IMP_CONTRACT_ID <> p_imp_contract_id
    --fix issue#7 in bug 4107212, add the following where clause
    AND VALID_FLAG <> 'N';

    CURSOR IMPORT_CONTRACTS_CSR IS
    SELECT IMP_CONTRACT_ID,
    CONTRACT_NUMBER,
    CONTRACT_NAME,
    DESCRIPTION,
    VERSION_COMMENTS,
    CONTRACT_EFFECTIVE_DATE,
    CONTRACT_EXPIRATION_DATE,
    CURRENCY_CODE,
    CONTRACT_AMOUNT,
    ORG_NAME,
    OWNER_USER_NAME,
    PHYSICAL_LOCATION,
    KEYWORDS,
    CONTRACT_TYPE_TXT,
    AUTHORING_PARTY_TXT,
    CONTRACT_STATUS_TXT,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    ORIG_SYSTEM_REFERENCE_CODE,
    ORIG_SYSTEM_REFERENCE_ID1,
    ORIG_SYSTEM_REFERENCE_ID2
    FROM
    OKC_REP_IMP_CONTRACTS_T
    WHERE
    REQUEST_ID = p_request_id
    AND VALID_FLAG IN ('U', 'Y');

    l_import_contracts_rec IMPORT_CONTRACTS_CSR%ROWTYPE;

    CURSOR CONTRACT_STATUS_CSR (p_status_txt VARCHAR2) IS
    SELECT LOOKUP_CODE FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKC_REP_CONTRACT_STATUSES'
    AND LOOKUP_CODE = 'SIGNED'
    AND UPPER(MEANING) = UPPER(p_status_txt);

    CURSOR CONTRACT_TYPE_CSR (p_type_txt VARCHAR2) IS
    SELECT DOCUMENT_TYPE
    FROM OKC_BUS_DOC_TYPES_V
    WHERE DOCUMENT_TYPE_CLASS = 'REPOSITORY'
    AND UPPER(NAME) = UPPER(p_type_txt);

    CURSOR CONTRACT_INTENT_CSR (p_imp_contract_id NUMBER) IS
    SELECT INTENT
    FROM OKC_BUS_DOC_TYPES_V bus_doc,
    OKC_REP_IMP_CONTRACTS_T temp
    WHERE bus_doc.name = temp.contract_type_txt
    AND temp.imp_contract_id = p_imp_contract_id
    AND bus_doc.document_type_class = 'REPOSITORY';

    CURSOR ORG_NAME_CSR (p_org_name VARCHAR2) IS
    SELECT ORGANIZATION_ID
    FROM HR_ALL_ORGANIZATION_UNITS
    WHERE UPPER(NAME) = UPPER(p_org_name)
    AND mo_global.check_access(ORGANIZATION_ID) = 'Y';

    CURSOR OWNER_NAME_CSR (p_owner_name VARCHAR2) IS
    SELECT FND_USER.USER_ID
    FROM FND_USER,
    PER_PEOPLE_F
    WHERE FND_USER.EMPLOYEE_ID = PER_PEOPLE_F.PERSON_ID
    AND UPPER(FND_USER.USER_NAME) = UPPER(p_owner_name);

    CURSOR CURRENCY_CSR (p_currency_code VARCHAR2) IS
    SELECT CURRENCY_CODE
    FROM FND_CURRENCIES
    WHERE UPPER(CURRENCY_CODE) = UPPER(p_currency_code)
    AND ENABLED_FLAG = 'Y';

    CURSOR AUTHORING_PARTY_CSR (p_authoring_party_txt VARCHAR2) IS
    SELECT LOOKUP_CODE
    FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKC_AUTHORING_PARTY'
    AND UPPER(MEANING) = UPPER(p_authoring_party_txt);

    CURSOR CONTRACT_PARTIES_CSR (p_contract_id VARCHAR2) IS
    SELECT PARTY_ROLE_CODE, PARTY_NAME_TXT
    FROM OKC_REP_IMP_PARTIES_T
    WHERE IMP_CONTRACT_ID = p_contract_id;

    l_contract_parties_rec CONTRACT_PARTIES_CSR%ROWTYPE;
    l_int_party_name OKC_REP_IMP_PARTIES_T.PARTY_NAME_TXT%TYPE;

    --CURSOR PARTY_INTENT_CSR (p_contract_type VARCHAR2, p_party_role_code VARCHAR2) IS
    --SELECT INTERNAL_EXTERNAL_FLAG
    --FROM OKC_RESP_PARTIES_B RESP_PARTIES,
    --OKC_BUS_DOC_TYPES_B DOC_TYPES
    --WHERE RESP_PARTIES.RESP_PARTY_CODE = p_party_role_code
    --AND RESP_PARTIES.DOCUMENT_TYPE_CLASS = 'REPOSITORY'
    --AND DOC_TYPES.INTENT = RESP_PARTIES.INTENT
    --AND DOC_TYPES.DOCUMENT_TYPE = p_contract_type;

    CURSOR VALID_PARTIES_CSR (p_contract_id VARCHAR2) IS
    SELECT VALID_FLAG, IMP_PARTY_ID
    FROM OKC_REP_IMP_PARTIES_T
    WHERE IMP_CONTRACT_ID = p_contract_id;

    l_valid_parties_rec VALID_PARTIES_CSR%ROWTYPE;


    CURSOR VALID_DOCUMENTS_CSR (p_contract_id VARCHAR2) IS
    SELECT VALID_FLAG, IMP_DOCUMENT_ID
    FROM OKC_REP_IMP_DOCUMENTS_T
    WHERE IMP_CONTRACT_ID = p_contract_id;

    l_valid_documents_rec VALID_DOCUMENTS_CSR%ROWTYPE;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);



    BEGIN

    l_api_name := 'validate_import_contracts';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_UTIL_PVT.'||l_api_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_request_id = ' || p_request_id);

    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN IMPORT_CONTRACTS_CSR;
    LOOP
        FETCH IMPORT_CONTRACTS_CSR INTO l_import_contracts_rec;
        EXIT WHEN IMPORT_CONTRACTS_CSR%NOTFOUND;

        --Initialize l_valid_flag for every record
        l_valid_flag := 'Y';
        --Initialize l_error_msg for every record
        l_error_msg := NULL;
        --Initialize l_int_parties_count and l_ext_parties_count
        l_int_parties_count := 0;
        l_ext_parties_count := 0;
        --Initialize l_intent
        -- l_intent := NULL;
        --Initialize l_contract_id
        l_contract_id := NULL;
 --Bug 6603192 Initialize l_amount
        l_amount := NULL;


        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Number is required, if autonumbering is turned off
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters contract number');
        END IF;
        --Checking profile option value
        FND_PROFILE.GET(NAME => l_auto_number_option, VAL => l_auto_number_yn);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Profile OKC_REP_AUTO_CON_NUMBER value is: '||l_auto_number_yn);
        END IF;
        IF l_auto_number_yn = 'Y' THEN
            --If auto number is on
            --contract_number has to be null
            --otherwise system should error out
            IF(l_import_contracts_rec.contract_number IS NOT NULL) THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_NONNULL_NUMBER');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Auto number is turned on, but contract number is not null');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
        ELSE
            --If auto number is off
            --contract_number is required
            --otherwise system should error out
            IF(l_import_contracts_rec.contract_number IS NULL) THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_NUMBER');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Auto number is turned off, but contract number is missing');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            ELSE
                --contract number is entered
                --we need to check for length
                IF(LENGTH(l_import_contracts_rec.contract_number) > l_contract_number_length) THEN
                    l_valid_flag := 'N';
                    l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_NUMBER');
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Conract number is too long');
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'l_error_msg: '||l_error_msg);
                    END IF;

                END IF;
            END IF;
        END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Number has to be unique
        IF l_valid_flag = 'Y' THEN
            OPEN CONTRACT_NUMBER_UNIQUE_CSR(l_import_contracts_rec.contract_number, l_import_contracts_rec.imp_contract_id);
                FETCH CONTRACT_NUMBER_UNIQUE_CSR INTO l_unique_contract_number;
                IF CONTRACT_NUMBER_UNIQUE_CSR%FOUND THEN
                    l_valid_flag := 'N';
                    l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_NONUNIQUE_NUMBER');
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Conract number is not unique');
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'l_error_msg: '||l_error_msg);
                    END IF;
                END IF;
            CLOSE CONTRACT_NUMBER_UNIQUE_CSR;
        END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Name is required
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters contract name');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.contract_name IS NULL) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_NAME');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Name is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Name should be <450
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if contract name is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.contract_name)>l_contract_name_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_NAME');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Name is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

       -- If l_valid_flag is already set to 'N', we do not perform any more checks
       -- Validating to report error if a BUY contract is imported in Sales Workbench
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Checking if BUY intent contract is being imported in Sales Workbench');
       END IF;
       IF (l_valid_flag = 'Y') THEN
           OPEN CONTRACT_INTENT_CSR (l_import_contracts_rec.imp_contract_id);
           FETCH CONTRACT_INTENT_CSR INTO l_contract_intent;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'l_contract_intent: '||l_contract_intent);
           END IF;
           IF ((is_sales_workbench() = 'Y') AND (l_contract_intent = G_INTENT_BUY)) THEN
               l_valid_flag := 'N';
               l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_SWB_INV_INTENT');
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Buy Intent Contract can not be imported in Sales Workbench ');
                   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'l_error_msg: '||l_error_msg);
               END IF;
            END IF;
            CLOSE CONTRACT_INTENT_CSR;
       END IF;
        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Original System Reference Code should be <30
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if Original System Reference Code is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.orig_system_reference_code)>l_orig_system_code_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_ORIG_CODE');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Original System Reference Code is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Original System ID1 should be <100
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if Original System ID1 is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.orig_system_reference_id1)>l_orig_system_id1_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_ORIG_ID1');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Original System ID1 is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Original System ID2 should be <100
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if Original System ID2 is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.orig_system_reference_id2)>l_orig_system_id2_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_ORIG_ID2');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Original System ID2 is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Status is required
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters contract status');
        END IF;
        IF l_import_contracts_rec.contract_status_txt IS NOT NULL THEN
            l_import_contracts_rec.contract_status_txt := LTRIM(l_import_contracts_rec.contract_status_txt);
            l_import_contracts_rec.contract_status_txt := RTRIM(l_import_contracts_rec.contract_status_txt);
        END IF;

        IF (l_valid_flag = 'Y' AND (l_import_contracts_rec.contract_status_txt IS NULL OR LENGTH(l_import_contracts_rec.contract_status_txt)=0)) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_STATUS');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Status is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Status can only be 'SIGNED'
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if status is valid');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.contract_status_txt IS NOT NULL) THEN
            OPEN CONTRACT_STATUS_CSR(l_import_contracts_rec.contract_status_txt);
                FETCH CONTRACT_STATUS_CSR INTO l_status_code;
                IF CONTRACT_STATUS_CSR%NOTFOUND THEN
                    l_valid_flag := 'N';
                    l_status_code := NULL;
                    l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_STATUS');
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract Status is invalid');
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'l_error_msg: '||l_error_msg);
                    END IF;
                END IF;
            CLOSE CONTRACT_STATUS_CSR;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Type is required
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters contract type');
        END IF;
        IF l_import_contracts_rec.contract_type_txt IS NOT NULL THEN
            l_import_contracts_rec.contract_type_txt := LTRIM(l_import_contracts_rec.contract_type_txt);
            l_import_contracts_rec.contract_type_txt := RTRIM(l_import_contracts_rec.contract_type_txt);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_contracts_rec.contract_type_txt IS NULL OR LENGTH(l_import_contracts_rec.contract_type_txt)=0)) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_CON_TYPE');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Type is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Type should resolve to valid contract type code
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if contract type is valid');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.contract_type_txt IS NOT NULL) THEN
            OPEN CONTRACT_TYPE_CSR(l_import_contracts_rec.contract_type_txt);
                FETCH CONTRACT_TYPE_CSR INTO l_contract_type;
                IF CONTRACT_TYPE_CSR%NOTFOUND THEN
                    l_valid_flag := 'N';
                    l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_CON_TYPE');
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract Type is invalid');
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'l_error_msg: '||l_error_msg);
                    END IF;
                END IF;
            CLOSE CONTRACT_TYPE_CSR;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Effective Date is required
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters contract effective date');
        END IF;
        IF l_import_contracts_rec.contract_effective_date IS NOT NULL THEN
            l_import_contracts_rec.contract_effective_date := LTRIM(l_import_contracts_rec.contract_effective_date);
            l_import_contracts_rec.contract_effective_date := RTRIM(l_import_contracts_rec.contract_effective_date);
        END IF;

        IF (l_valid_flag = 'Y' AND (l_import_contracts_rec.contract_effective_date IS NULL OR LENGTH(l_import_contracts_rec.contract_effective_date)=0)) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_EFF_DATE');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Effective Date is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Effective Date should be in the format specified by user language preference
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if contract effective date is in the correct format');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.contract_effective_date IS NOT NULL) THEN
        BEGIN
            l_effective_date := to_date(l_import_contracts_rec.contract_effective_date, G_IMP_DATE_FORMAT);
            EXCEPTION
                WHEN OTHERS THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_EFF_DATE');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract Effective Date is not valid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
        END;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Expiration Date should be in the format specified by user language preference
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if contract expriation date is in the correct format');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.contract_expiration_date IS NOT NULL) THEN
        BEGIN
            l_expiration_date := to_date(l_import_contracts_rec.contract_expiration_date, G_IMP_DATE_FORMAT);
            EXCEPTION
                WHEN OTHERS THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_EXP_DATE');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract Expiration Date is not valid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
        END;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Contract Expiration Date should be after Contract Effective Date
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if contract expriation date is in the correct format');
        END IF;
        IF (l_valid_flag = 'Y'
                AND l_import_contracts_rec.contract_effective_date IS NOT NULL
                AND l_import_contracts_rec.contract_expiration_date IS NOT NULL) THEN
            --at this point if there are any errors regarding the date format we should have caught it
            --so it is safe to convert the dates
            IF TRUNC(to_date(l_import_contracts_rec.contract_effective_date,G_IMP_DATE_FORMAT)) > TRUNC(to_date(l_import_contracts_rec.contract_expiration_date,G_IMP_DATE_FORMAT)) THEN
                l_valid_flag := 'N';
            --Acq Plan Message Cleanup
                --l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_EXP_BEFORE_EFF');

                l_resolved_msg_name := OKC_API.resolve_message('OKC_REP_IMP_EXP_BEFORE_EFF',l_contract_type);
                l_resolved_token := OKC_API.resolve_hdr_token(l_contract_type);

                --l_error_msg := fnd_message.get_string(G_APP_NAME,l_resolved_msg_name,p_token1=>'HDR_TOKEN',p_token1_value => l_resolved_token);

                l_error_msg := OKC_TERMS_UTIL_PVT.Get_Message(G_APP_NAME,l_resolved_msg_name,p_token1=>'HDR_TOKEN',p_token1_value => l_resolved_token);
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract Expiration Date is before Contract Effective Date');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Organization Name is required
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters organization name');
        END IF;
        IF l_import_contracts_rec.org_name IS NOT NULL THEN
            l_import_contracts_rec.org_name := LTRIM(l_import_contracts_rec.org_name);
            l_import_contracts_rec.org_name := RTRIM(l_import_contracts_rec.org_name);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_contracts_rec.org_name IS NULL OR LENGTH(l_import_contracts_rec.org_name)=0)) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_ORG');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Operating Unit is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Organization Name should resolve to a valid Org ID
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if organization name is valid');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.org_name IS NOT NULL) THEN
            OPEN ORG_NAME_CSR(l_import_contracts_rec.org_name);
            FETCH ORG_NAME_CSR INTO l_org_id;
            IF ORG_NAME_CSR%NOTFOUND THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_ORG');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Operating Unit is invalid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
            CLOSE ORG_NAME_CSR;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Organization Name is required
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters owner user name');
        END IF;
        IF l_import_contracts_rec.owner_user_name IS NOT NULL THEN
            l_import_contracts_rec.owner_user_name := LTRIM(l_import_contracts_rec.owner_user_name);
            l_import_contracts_rec.owner_user_name := RTRIM(l_import_contracts_rec.owner_user_name);
        END IF;
        IF (l_valid_flag = 'Y' AND (l_import_contracts_rec.owner_user_name IS NULL OR LENGTH(l_import_contracts_rec.owner_user_name)=0)) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_OWNER');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Owner User Name is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Owner User Name should resolve to a valid FND User ID
        --Also, the owner needs to be an employee
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if owner user name is valid');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.owner_user_name IS NOT NULL) THEN
            OPEN OWNER_NAME_CSR(l_import_contracts_rec.owner_user_name);
            FETCH OWNER_NAME_CSR INTO l_owner_user_id;
            IF OWNER_NAME_CSR%NOTFOUND THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_OWNER');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Owner User Name is invalid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
            CLOSE OWNER_NAME_CSR;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Currency Code is required if Amount is entered
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if user enters currency when amount is entered');
        END IF;
        IF l_import_contracts_rec.currency_code IS NOT NULL THEN
            l_import_contracts_rec.currency_code := LTRIM(l_import_contracts_rec.currency_code);
            l_import_contracts_rec.currency_code := RTRIM(l_import_contracts_rec.currency_code);
        END IF;
        IF (l_valid_flag = 'Y'
                AND l_import_contracts_rec.contract_amount IS NOT NULL
                AND (l_import_contracts_rec.currency_code IS NULL OR LENGTH(l_import_contracts_rec.currency_code)=0)) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_MISS_CURRENCY');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Owner User Name is missing');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Currency should exist in FND_CURRENCIES table
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if currency is valid');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.currency_code IS NOT NULL) THEN
            OPEN CURRENCY_CSR(l_import_contracts_rec.currency_code);
            FETCH CURRENCY_CSR INTO l_currency_code;
            IF CURRENCY_CSR%NOTFOUND THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_CURRENCY');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Currency is invalid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
            CLOSE CURRENCY_CSR;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Amout should be in the format specified by user language preference
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if amount is in the correct format');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.contract_amount IS NOT NULL) THEN
        BEGIN
            --l_amount := to_number(l_import_contracts_rec.contract_amount, G_IMP_NUMBER_FORMAT);
            --validation is changed for fixing the bug 14535644
            l_amount := to_number(l_import_contracts_rec.contract_amount);
            IF Length(l_amount) > 15 THEN
                RAISE Invalid_Number;
            END IF;

            EXCEPTION
            WHEN OTHERS THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_AMOUNT');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Amount is not valid');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
        END;


       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Authoring Party should resolve to valid authoring_party_code
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if authoring party is valid');
        END IF;
        IF (l_valid_flag = 'Y' AND l_import_contracts_rec.authoring_party_txt IS NOT NULL) THEN
            OPEN AUTHORING_PARTY_CSR(l_import_contracts_rec.authoring_party_txt);
            FETCH AUTHORING_PARTY_CSR INTO l_authoring_party_code;
            IF AUTHORING_PARTY_CSR%NOTFOUND THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_AUTH_PARTY');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Authoring Party is invalid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
            CLOSE AUTHORING_PARTY_CSR;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Physical Location should be <2000
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if Physical Location is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.physical_location)>l_location_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_LOCATION');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Physical Location is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Keywords should be <2000
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if keywords is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.keywords)>l_keywords_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_KEYWORDS');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Keywords is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Description should be <2000
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if description is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.description)>l_description_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_DESC');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Description is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Version Comments should be <2000
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Checking if version comments is too long');
        END IF;
        IF (l_valid_flag = 'Y' AND LENGTH(l_import_contracts_rec.version_comments)>l_version_comments_length) THEN
            l_valid_flag := 'N';
            l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_LONG_COMMENTS');
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Version Comments is too long');
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_error_msg: '||l_error_msg);
            END IF;
       END IF;

        --If l_valid_flag is already set to 'N', we do not perform any more checks
        --Validate Contract Parties
        --1. There should exactly one internal party
        --2. There should be at least one external party
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Validating contract parties');
        END IF;
        IF (l_valid_flag = 'Y') THEN
            OPEN CONTRACT_PARTIES_CSR(l_import_contracts_rec.imp_contract_id);
            LOOP
                FETCH CONTRACT_PARTIES_CSR INTO l_contract_parties_rec;
                EXIT WHEN CONTRACT_PARTIES_CSR%NOTFOUND;

                --At this point if the l_valid_flag is still 'Y', it means that l_contract_type is resolved
                IF (l_contract_parties_rec.party_role_code = G_PARTY_ROLE_INTERNAL) THEN
                  l_int_parties_count := l_int_parties_count + 1;
      l_int_party_name := l_contract_parties_rec.party_name_txt;
                ELSE
                  l_ext_parties_count := l_ext_parties_count + 1;
                END IF;
            END LOOP;
            CLOSE CONTRACT_PARTIES_CSR;

            IF l_int_parties_count <> 1 THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_INT_PARTIES');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'There are not exactly one internal party');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
          ELSE
                --fix bug 4160416, need to validate internal party name with the org name in the header
                IF l_import_contracts_rec.org_name <> l_int_party_name THEN
                    l_valid_flag := 'N';
                    l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_INT_PARTY_NAME');
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Internal party name and org name are not matching');
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'l_error_msg: '||l_error_msg);
                    END IF;
                END IF;
            END IF;

            IF l_ext_parties_count <1 THEN
                l_valid_flag := 'N';
                l_error_msg := fnd_message.get_string(G_APP_NAME,'OKC_REP_IMP_INV_EXT_PARTIES');
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'There are less than one external party');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'l_error_msg: '||l_error_msg);
                END IF;
            END IF;
       END IF;


        --If any of the parties and documents belonging to the contract is invalid,
        --We should flag the contract as invalid

        IF l_valid_flag = 'Y' THEN
            OPEN VALID_PARTIES_CSR(l_import_contracts_rec.imp_contract_id);
            LOOP
            FETCH VALID_PARTIES_CSR INTO l_valid_parties_rec;
            EXIT WHEN VALID_PARTIES_CSR%NOTFOUND;

            IF l_valid_parties_rec.valid_flag = 'N' THEN
                l_valid_flag := 'N';
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'One of the contract parties is invalid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Party ID: '||l_valid_parties_rec.imp_party_id);
                END IF;
            END IF;
            END LOOP;
            CLOSE VALID_PARTIES_CSR;
        END IF;

        IF l_valid_flag = 'Y' THEN

            OPEN VALID_DOCUMENTS_CSR(l_import_contracts_rec.imp_contract_id);
            LOOP
            FETCH VALID_DOCUMENTS_CSR INTO l_valid_documents_rec;
            EXIT WHEN VALID_DOCUMENTS_CSR%NOTFOUND;

            IF l_valid_documents_rec.valid_flag = 'N' THEN
                l_valid_flag := 'N';
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'One of the contract documents is invalid');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract ID: '||l_import_contracts_rec.imp_contract_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Document ID: '||l_valid_documents_rec.imp_document_id);
                END IF;
            END IF;
            END LOOP;
            CLOSE VALID_DOCUMENTS_CSR;
        END IF;


        --Populate the error message table
        IF(l_valid_flag = 'N' AND l_error_msg IS NOT NULL) THEN
            populate_import_errors(p_init_msg_list => FND_API.G_FALSE,
                                   p_api_version => 1.0,
                                   p_contract_id => l_import_contracts_rec.imp_contract_id,
                                   p_error_obj_type => G_IMP_CONTRACT_ERROR,
                                   p_error_obj_id => l_import_contracts_rec.imp_contract_id,
                                   p_error_msg_txt => l_error_msg,
                                   p_program_id => l_import_contracts_rec.program_id,
                                   p_program_login_id => l_import_contracts_rec.program_login_id,
                                   p_program_app_id => l_import_contracts_rec.program_application_id,
                                   p_request_id => l_import_contracts_rec.request_id,
                                   x_return_status => x_return_status,
                                   x_msg_count => x_msg_count,
                                   x_msg_data => x_msg_data);
        END IF;

        l_contract_number := l_import_contracts_rec.contract_number;

        --Get the contract_id from the sequence
        --We do not waste contract IDs on invalid contracts
        IF(l_valid_flag = 'Y') THEN
            OPEN CONTRACT_ID_CSR;
            FETCH CONTRACT_ID_CSR INTO l_contract_id;
            CLOSE CONTRACT_ID_CSR;

            --Also update okc_rep_imp_parties_t and okc_rep_imp_documents_t
            --with the new contract_id
            UPDATE OKC_REP_IMP_PARTIES_T
            SET CONTRACT_ID = l_contract_id
            WHERE IMP_CONTRACT_ID = l_import_contracts_rec.imp_contract_id;

            UPDATE OKC_REP_IMP_DOCUMENTS_T
            SET CONTRACT_ID = l_contract_id
            WHERE IMP_CONTRACT_ID = l_import_contracts_rec.imp_contract_id;



            IF (l_auto_number_yn = 'Y') THEN
                --Get the contract_number from the sequence
                --if auto number is on
                OPEN CONTRACT_NUMBER_CSR;
                FETCH CONTRACT_NUMBER_CSR INTO l_contract_number;
                CLOSE CONTRACT_NUMBER_CSR;
            END IF;
        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'l_contract_id: '||l_contract_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'l_contract_number: '||l_contract_number);
        END IF;

        IF (l_valid_flag = 'Y') THEN
        --Update the record
        UPDATE OKC_REP_IMP_CONTRACTS_T
        SET
        CONTRACT_ID = l_contract_id,
        CONTRACT_NUMBER = l_contract_number,
        CONTRACT_STATUS_CODE = l_status_code,
        CONTRACT_TYPE = l_contract_type,
        AUTHORING_PARTY_CODE = l_authoring_party_code,
        ORG_ID = l_org_id,
        OWNER_USER_ID = l_owner_user_id,
        --CONTRACT_EFFECTIVE_DATE = l_effective_date,
        --CONTRACT_EXPIRATION_DATE = l_expiration_date,
        CONTRACT_AMOUNT = l_amount,
        VALID_FLAG = l_valid_flag
        WHERE IMP_CONTRACT_ID = l_import_contracts_rec.imp_contract_id;

        END IF;


        IF(l_valid_flag = 'N') THEN
        UPDATE OKC_REP_IMP_CONTRACTS_T
        SET
        VALID_FLAG = l_valid_flag
        WHERE IMP_CONTRACT_ID = l_import_contracts_rec.imp_contract_id;
        END IF;
    END LOOP;
    CLOSE IMPORT_CONTRACTS_CSR;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Leaving OKC_REP_UTIL_PVT.'||l_api_name);
   END IF;


  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    IF CONTRACT_ID_CSR%ISOPEN THEN
        CLOSE CONTRACT_ID_CSR;
    END IF;

    IF CONTRACT_NUMBER_CSR%ISOPEN THEN
        CLOSE CONTRACT_NUMBER_CSR;
    END IF;

    IF CONTRACT_INTENT_CSR%ISOPEN THEN
        CLOSE CONTRACT_INTENT_CSR;
    END IF;

    IF IMPORT_CONTRACTS_CSR%ISOPEN THEN
        CLOSE IMPORT_CONTRACTS_CSR;
    END IF;
    IF CONTRACT_NUMBER_UNIQUE_CSR%ISOPEN THEN
        CLOSE CONTRACT_NUMBER_UNIQUE_CSR;
    END IF;
    IF CONTRACT_STATUS_CSR%ISOPEN THEN
        CLOSE CONTRACT_STATUS_CSR;
    END IF;
    IF CONTRACT_TYPE_CSR%ISOPEN THEN
        CLOSE CONTRACT_TYPE_CSR;
    END IF;
    IF ORG_NAME_CSR%ISOPEN THEN
        CLOSE ORG_NAME_CSR;
    END IF;
    IF OWNER_NAME_CSR%ISOPEN THEN
        CLOSE OWNER_NAME_CSR;
    END IF;
    IF CURRENCY_CSR%ISOPEN THEN
        CLOSE CURRENCY_CSR;
    END IF;
    IF AUTHORING_PARTY_CSR%ISOPEN THEN
        CLOSE AUTHORING_PARTY_CSR;
    END IF;
    IF CONTRACT_PARTIES_CSR%ISOPEN THEN
        CLOSE CONTRACT_PARTIES_CSR;
    END IF;
    --IF PARTY_INTENT_CSR%ISOPEN THEN
    --    CLOSE PARTY_INTENT_CSR;
    --END IF;
    IF VALID_PARTIES_CSR%ISOPEN THEN
        CLOSE VALID_PARTIES_CSR;
    END IF;
    IF VALID_DOCUMENTS_CSR%ISOPEN THEN
        CLOSE VALID_DOCUMENTS_CSR;
    END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF CONTRACT_ID_CSR%ISOPEN THEN
        CLOSE CONTRACT_ID_CSR;
    END IF;

    IF CONTRACT_NUMBER_CSR%ISOPEN THEN
        CLOSE CONTRACT_NUMBER_CSR;
    END IF;
    IF CONTRACT_NUMBER_UNIQUE_CSR%ISOPEN THEN
        CLOSE CONTRACT_NUMBER_UNIQUE_CSR;
    END IF;

    IF CONTRACT_INTENT_CSR%ISOPEN THEN
        CLOSE CONTRACT_INTENT_CSR;
    END IF;

    IF IMPORT_CONTRACTS_CSR%ISOPEN THEN
        CLOSE IMPORT_CONTRACTS_CSR;
    END IF;
    IF CONTRACT_STATUS_CSR%ISOPEN THEN
        CLOSE CONTRACT_STATUS_CSR;
    END IF;
    IF CONTRACT_TYPE_CSR%ISOPEN THEN
        CLOSE CONTRACT_TYPE_CSR;
    END IF;
    IF ORG_NAME_CSR%ISOPEN THEN
        CLOSE ORG_NAME_CSR;
    END IF;
    IF OWNER_NAME_CSR%ISOPEN THEN
        CLOSE OWNER_NAME_CSR;
    END IF;
    IF CURRENCY_CSR%ISOPEN THEN
        CLOSE CURRENCY_CSR;
    END IF;
    IF AUTHORING_PARTY_CSR%ISOPEN THEN
        CLOSE AUTHORING_PARTY_CSR;
    END IF;
    IF CONTRACT_PARTIES_CSR%ISOPEN THEN
        CLOSE CONTRACT_PARTIES_CSR;
    END IF;
    --IF PARTY_INTENT_CSR%ISOPEN THEN
    --    CLOSE PARTY_INTENT_CSR;
    --END IF;
    IF VALID_PARTIES_CSR%ISOPEN THEN
        CLOSE VALID_PARTIES_CSR;
    END IF;
    IF VALID_DOCUMENTS_CSR%ISOPEN THEN
        CLOSE VALID_DOCUMENTS_CSR;
    END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN
    IF CONTRACT_ID_CSR%ISOPEN THEN
        CLOSE CONTRACT_ID_CSR;
    END IF;

    IF CONTRACT_NUMBER_CSR%ISOPEN THEN
        CLOSE CONTRACT_NUMBER_CSR;
    END IF;

    IF CONTRACT_NUMBER_UNIQUE_CSR%ISOPEN THEN
        CLOSE CONTRACT_NUMBER_UNIQUE_CSR;
    END IF;

    IF CONTRACT_INTENT_CSR%ISOPEN THEN
        CLOSE CONTRACT_INTENT_CSR;
    END IF;

    IF IMPORT_CONTRACTS_CSR%ISOPEN THEN
        CLOSE IMPORT_CONTRACTS_CSR;
    END IF;
    IF CONTRACT_STATUS_CSR%ISOPEN THEN
        CLOSE CONTRACT_STATUS_CSR;
    END IF;
    IF CONTRACT_TYPE_CSR%ISOPEN THEN
        CLOSE CONTRACT_TYPE_CSR;
    END IF;
    IF ORG_NAME_CSR%ISOPEN THEN
        CLOSE ORG_NAME_CSR;
    END IF;
    IF OWNER_NAME_CSR%ISOPEN THEN
        CLOSE OWNER_NAME_CSR;
    END IF;
    IF CURRENCY_CSR%ISOPEN THEN
        CLOSE CURRENCY_CSR;
    END IF;
    IF AUTHORING_PARTY_CSR%ISOPEN THEN
        CLOSE AUTHORING_PARTY_CSR;
    END IF;
    IF CONTRACT_PARTIES_CSR%ISOPEN THEN
        CLOSE CONTRACT_PARTIES_CSR;
    END IF;
    --IF PARTY_INTENT_CSR%ISOPEN THEN
    --    CLOSE PARTY_INTENT_CSR;
    --END IF;
    IF VALID_PARTIES_CSR%ISOPEN THEN
        CLOSE VALID_PARTIES_CSR;
    END IF;
    IF VALID_DOCUMENTS_CSR%ISOPEN THEN
        CLOSE VALID_DOCUMENTS_CSR;
    END IF;


      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||' because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END validate_import_contracts;



  -- Start of comments
  --API name      : insert_prod_data
  --Type          : Private.
  --Function      : Insert validated contracts and parties into production tables
  --                i.e., move from OKC_REP_IMP_CONTRACTS_T and OKC_REP_IMP_PARTIES_T
  --                to OKC_REP_CONTRACTS_ALL AND OKC_REP_CONTRACT_PARTIES
  --                It also insert a record into OKC_REP_CON_STATUS_HIST for every record
  --                inserted into OKC_REP_CONTRACTS_ALL.
  --Pre-reqs      : Currently only called from repository import.
  --                Contracts should be saved to the OKC_REP_IMP_CONTRACTS_T table
  --                Date should all be validated in OKC_REP_IMP_CONTRACTS_T,
  --              : OKC_REP_IMP_PARTIES_T, and OKC_REP_IMP_DOCUMENTS_T
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_commit             IN VARCHAR2  Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  --              : x_number_inserted     OUT NUMBER
  -- End of comments

  PROCEDURE insert_prod_data (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_commit            IN  VARCHAR2,
    p_request_id        IN  NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_number_inserted   OUT NOCOPY NUMBER)
  IS

    l_api_name            CONSTANT VARCHAR2(30):='insert_prod_data';
    l_api_version         CONSTANT NUMBER := 1.0;

    l_number_inserted   NUMBER;
    l_number_valid      NUMBER;

    l_min_contract_id     NUMBER;
    l_max_contract_id     NUMBER;
    l_start_contract_id   NUMBER;
    l_insert_batch_size   NUMBER;

    CURSOR number_inserted_csr IS
    SELECT COUNT(contract_id)
    FROM   okc_rep_contracts_all
    WHERE  request_id = p_request_id;

    CURSOR contract_id_cur IS
    SELECT
        MIN(contract_id) AS min_contract_id,
        MAX(contract_id) AS max_contract_id,
        COUNT(contract_id)
    FROM  okc_rep_imp_contracts_t
    WHERE request_id = p_request_id
    AND   valid_flag = 'Y';

  BEGIN

     FND_FILE.PUT_LINE(FND_FILE.LOG, '**********************************');
     FND_FILE.PUT_LINE(FND_FILE.LOG, '***** BEGIN insert_prod_data *****');
     FND_FILE.PUT_LINE(FND_FILE.LOG, '**********************************');

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_api_version = ' || p_api_version);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_request_id = ' || p_request_id);

     l_insert_batch_size := 50;
     l_number_inserted := 0;
     l_number_valid  := -1;

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_insert_batch_size = ' || l_insert_batch_size);

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Inserting contracts into production table...');
    END IF;

    l_min_contract_id := 0;
    l_max_contract_id := 0;

    OPEN  contract_id_cur;
    FETCH contract_id_cur INTO l_min_contract_id, l_max_contract_id, l_number_valid;
    CLOSE contract_id_cur;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_number_valid = ' || l_number_valid);

    IF l_number_valid > 0 THEN


          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_min_contract_id = ' || l_min_contract_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_max_contract_id = ' || l_max_contract_id);

          l_start_contract_id := l_min_contract_id;

          FOR i IN 0..l_number_valid LOOP

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_start_contract_id = ' || l_start_contract_id);

            BEGIN

              SAVEPOINT before_insert_contracts;

              FND_FILE.PUT_LINE(FND_FILE.LOG, '***** SAVEPOINT before_insert_contracts *****');

              --Bulk insert contracts
              INSERT INTO okc_rep_contracts_all
                (contract_id,
                contract_version_num,
                contract_name,
                contract_number,
                contract_desc,
                contract_type,
                contract_status_code,
                version_comments,
                org_id,
                authoring_party_code,
                owner_id,
                contract_effective_date,
                contract_expiration_date,
                currency_code,
                amount,
                keywords,
                physical_location,
                source_language,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                program_id,
                program_login_id,
                program_application_id,
                request_id,
                latest_signed_ver_number,
                orig_system_reference_code,
                orig_system_reference_id1,
                orig_system_reference_id2,
                CONTRACT_LAST_UPDATED_BY,
                CONTRACT_LAST_UPDATE_DATE

                )
              SELECT
                contract_id,
                1, --contract_version_num,
                contract_name,
                contract_number,
                description,
                contract_type,
                contract_status_code,
                version_comments,
                org_id,
                authoring_party_code,
                owner_user_id,
                TO_DATE(contract_effective_date, G_IMP_DATE_FORMAT),
                TO_DATE(contract_expiration_date, G_IMP_DATE_FORMAT),
                currency_code,
                contract_amount,
                keywords,
                physical_location,
                USERENV('LANG'),--source_language,
                1, --object_version_number,
                FND_GLOBAL.USER_ID, --created_by,
                SYSDATE, --creation_date,
                FND_GLOBAL.USER_ID, --last_updated_by,
                SYSDATE, --last_update_date,
                FND_GLOBAL.USER_ID, --last_update_login,
                program_id,
                program_login_id,
                program_application_id,
                request_id,
                1, --latest_signed_ver_number,
                orig_system_reference_code,
                orig_system_reference_id1,
                orig_system_reference_id2,
                fnd_global.user_id,
                sysdate

              FROM  okc_rep_imp_contracts_t
              WHERE request_id = p_request_id
              AND   valid_flag = 'Y'
              AND   contract_id >= l_start_contract_id
              AND   contract_id <  l_start_contract_id + l_insert_batch_size;

            FND_FILE.PUT_LINE(FND_FILE.LOG, '***** INSERT INTO okc_rep_contracts_all *****');

            --insert into contract parties
            INSERT INTO okc_rep_contract_parties
              (
              contract_id,
              party_role_code,
              party_id,
              --signed_by,
              --signed_date,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              program_id,
              program_login_id,
              program_application_id,
              request_id
              )
            SELECT
              contract_id,
              party_role_code,
              party_id,
              --signed_by_txt,
              --TO_DATE(signed_date, G_IMP_DATE_FORMAT),
              1, --object_version_number,
              FND_GLOBAL.USER_ID, --CREATED_BY,
              SYSDATE, --CREATION_DATE,
              FND_GLOBAL.USER_ID, --LAST_UPDATED_BY,
              SYSDATE, --LAST_UPDATE_DATE,
              FND_GLOBAL.USER_ID, --LAST_UPDATE_LOGIN,
              program_id,
              program_login_id,
              program_application_id,
              request_id
            FROM okc_rep_imp_parties_t
            WHERE valid_flag = 'Y'
            AND   request_id = p_request_id
            AND   contract_id IS NOT NULL
            AND   contract_id >= l_start_contract_id
            AND   contract_id <  l_start_contract_id + l_insert_batch_size;

            FND_FILE.PUT_LINE(FND_FILE.LOG, '***** INSERT INTO okc_rep_contract_parties *****');

            --insert into okc_rep_signature_details
            INSERT INTO OKC_REP_SIGNATURE_DETAILS
              (
              contract_id,
              contract_version_num,
              party_role_code,
              party_id,
              signed_by,
              signed_date,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              program_id,
              program_login_id,
              program_application_id,
              request_id
              )
            SELECT
              contract_id,
              1, -- ontract_version_num
              party_role_code,
              party_id,
              signed_by_txt,
              TO_DATE(signed_date, g_imp_date_format),
              1, --object_version_number,
              FND_GLOBAL.USER_ID, --created_by,
              SYSDATE, --creation_date,
              FND_GLOBAL.USER_ID, --last_updated_by,
              SYSDATE, --last_update_date,
              FND_GLOBAL.USER_ID, --last_update_login,
              program_id,
              program_login_id,
              program_application_id,
              request_id
            FROM  okc_rep_imp_parties_t
            WHERE valid_flag = 'Y'
            AND   request_id = p_request_id
            AND   contract_id IS NOT NULL
            AND   contract_id >= l_start_contract_id
            AND   contract_id <  l_start_contract_id + l_insert_batch_size;

            FND_FILE.PUT_LINE(FND_FILE.LOG, '***** INSERT INTO OKC_REP_SIGNATURE_DETAILS *****');

            --insert into status history
            INSERT INTO okc_rep_con_status_hist
              (
              contract_id,
              contract_version_num,
              status_code,
              status_change_date,
              changed_by_user_id,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
              )
            SELECT
              contract_id,
              contract_version_num,
              contract_status_code,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
            FROM  okc_rep_contracts_all
            WHERE request_id = p_request_id
            AND   created_by = FND_GLOBAL.USER_ID
            AND   contract_id >= l_start_contract_id
            AND   contract_id <  l_start_contract_id + l_insert_batch_size;

            FND_FILE.PUT_LINE(FND_FILE.LOG, '***** INSERT INTO okc_rep_con_status_hist *****');

            COMMIT;

            FND_FILE.PUT_LINE(FND_FILE.LOG, '***** COMMIT *****');

            l_start_contract_id := l_start_contract_id + l_insert_batch_size;

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_start_contract_id = ' || l_start_contract_id);

            EXIT WHEN l_start_contract_id > l_max_contract_id;

          EXCEPTION
            WHEN OTHERS THEN

              FND_FILE.PUT_LINE(FND_FILE.LOG, '***** EXCEPTION WHEN OTHERS *****');
              FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

              x_return_status := FND_API.G_RET_STS_ERROR;
              x_number_inserted := 0;

              FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                      p_data  =>  x_msg_data);

              --rollback to the
              ROLLBACK TO before_insert_contracts;

              FND_FILE.PUT_LINE(FND_FILE.LOG, '***** ROLLBACK TO before_insert_contracts *****');

              --We also need to mark the documents as invalid
              --so that in the Java layer we won't add them as attachments

              --Here the assumption is made that exception has happened
              --in the INSERT SQL, so l_start_contract_id is from the
              --current iteration and we do not adjust it here
              UPDATE okc_rep_imp_documents_t
              SET    valid_flag = 'N'
              WHERE  request_id = p_request_id
              AND    contract_id >= l_start_contract_id
              AND    contract_id <  l_start_contract_id + l_insert_batch_size;

              FND_FILE.PUT_LINE(FND_FILE.LOG, '***** UPDATE okc_rep_imp_documents_t SET valid_flag = N *****');

              COMMIT;

              FND_FILE.PUT_LINE(FND_FILE.LOG, '***** COMMIT *****');
          END;


        END LOOP;

        FND_FILE.PUT_LINE(FND_FILE.LOG, '***** END LOOP *****');

    END IF;


    OPEN number_inserted_csr;
    FETCH number_inserted_csr INTO l_number_inserted;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'number_inserted_csr%ROWCOUNT = ' || number_inserted_csr%ROWCOUNT);

    CLOSE number_inserted_csr;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '***** END LOOP *****');

    x_number_inserted := l_number_inserted;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_number_inserted = ' || x_number_inserted);

    FND_FILE.PUT_LINE(FND_FILE.LOG, '********************************');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '***** END insert_prod_data *****');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '********************************');
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '***** EXCEPTION WHEN WHEN FND_API.G_EXC_ERROR *****');
      FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

      --close cursors
      IF (number_inserted_csr%ISOPEN) THEN
        CLOSE number_inserted_csr ;
      END IF;
      IF (contract_id_cur%ISOPEN) THEN
        CLOSE contract_id_cur ;
      END IF;


      x_return_status := FND_API.G_RET_STS_ERROR;
      x_number_inserted := 0;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '***** EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR *****');
      FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

      --close cursors
      IF (number_inserted_csr%ISOPEN) THEN
        CLOSE number_inserted_csr ;
      END IF;
      IF (contract_id_cur%ISOPEN) THEN
        CLOSE contract_id_cur ;
      END IF;


      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      x_number_inserted := 0;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '***** EXCEPTION WHEN OTHERS *****');
      FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

      --close cursors
      IF (number_inserted_csr%ISOPEN) THEN
        CLOSE number_inserted_csr ;
      END IF;
      IF (contract_id_cur%ISOPEN) THEN
        CLOSE contract_id_cur ;
      END IF;


      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_number_inserted := 0;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END insert_prod_data;

  -- Start of comments
  --API name      : validate_and_insert_contracts
  --Type          : Private.
  --Function      : Validates contracts in the interface tables, and then insert
  --                the valid ones into production tables:
  --                okc_rep_contracts_all and okc_rep_contract_parties
  --                Note that contract documents are inserted in the Java layer after this
  --Pre-reqs      : Currently only called from repository import.
  --              : Contracts should be saved to the OKC_REP_IMP_CONTRACTS_T table
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_request_id         IN NUMBER       Required
  --                    Concurrent Program Request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  --              : x_number_inserted     OUT NUMBER
  -- End of comments
  PROCEDURE validate_and_insert_contracts(
    p_api_version   IN  NUMBER,
    p_init_msg_list   IN  VARCHAR2,
    p_request_id    IN  NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    x_msg_count   OUT NOCOPY NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_number_inserted   OUT NOCOPY NUMBER)
  IS

  l_api_name            CONSTANT VARCHAR2(30):='validate_contracts';
  l_api_version         CONSTANT NUMBER := 1.0;

  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_UTIL_PVT.'||l_api_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_request_id = ' || p_request_id);

    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --We need to validate documents and parties before we validate contract headers
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Validating Contract Documents...');
    END IF;

    validate_import_documents(p_api_version => 1.0,
                              p_init_msg_list => FND_API.G_FALSE,
                            p_request_id => p_request_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Validating Contract Parties...');
    END IF;

    validate_import_parties(p_api_version => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
                            p_request_id => p_request_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Validating Contract Headers...');
    END IF;

    validate_import_contracts(p_api_version => 1.0,
                            p_init_msg_list => FND_API.G_FALSE,
                            p_request_id => p_request_id,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Finished validating Contracts.  Now we will insert valid headers and parties into production tables.');
    END IF;

    insert_prod_data(p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_TRUE,
                    p_request_id => p_request_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_number_inserted => x_number_inserted);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||':FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving '||l_api_name||' because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);


  END validate_and_insert_contracts;


  -- Start of comments
  --API name      : delete_import_contract
  --Type          : Private.
  --Function      : (1) Delete the imported contract and its parties
  --                by calling okc_rep_contract_process_pvt.delete_contract
  --                (2) Set the contract's valid_flag to 'N' in okc_rep_imp_contracts_t
  --                (3) Insert an error message in okc_rep_imp_errors_t
  --                This procedure does the cleanup due to an error adding attachments
  --                in the Java layer during repository import
  --Pre-reqs      : None
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_commit               IN VARCHAR2    Optional
  --                   Default = FND_API.G_FALSE
  --              : p_contract_id         IN NUMBER       Required
  --                    Contract ID that the error is from
  --              : p_imp_document_id     IN NUMBER       Required
  --                   okc_rep_imp_documents_t.imp_document_id
  --              : p_error_msg_txt  IN VARCHAR2       Required
  --                   Translated error message text
  --              : p_program_id                IN  NUMBER Required
  --                    Concurrent program ID
  --              : p_program_login_id          IN  NUMBER Required
  --                    Concurrent program login ID
  --              : p_program_app_id            IN  NUMBER Required
  --                    Concurrent program application ID
  --              : p_request_id                IN  NUMBER Required
  --                    Concurrent program request ID
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE delete_import_contract(
       p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_commit                   IN VARCHAR2,
       p_contract_id              IN NUMBER,
       p_imp_document_id             IN NUMBER,
       p_error_msg_txt            IN VARCHAR2,
       p_program_id               IN NUMBER,
       p_program_login_id         IN NUMBER,
       p_program_app_id           IN NUMBER,
       p_request_id               IN NUMBER,
       x_return_status            OUT NOCOPY VARCHAR2,
       x_msg_count                OUT NOCOPY NUMBER,
       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;



    BEGIN

    l_api_name := 'delete_import_contract';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_UTIL_PVT.delete_import_contract');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_contract_id = ' || p_contract_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_imp_document_id = ' || p_imp_document_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_error_msg_txt = ' || p_error_msg_txt);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_program_id = ' || p_program_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_program_login_id = ' || p_program_login_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_program_app_id = ' || p_program_app_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_request_id = ' || p_request_id);


    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete contract
    okc_rep_contract_process_pvt.delete_contract(
      p_api_version  => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit        => FND_API.G_FALSE,
      p_contract_id  => p_contract_id,
      x_msg_data   => x_msg_data,
      x_msg_count  => x_msg_count,
      x_return_status  => x_return_status);


     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                'Called okc_rep_contract_process_pvt.delete_contract');
    END IF;

    -- Update valid_flag
    UPDATE OKC_REP_IMP_CONTRACTS_T
    SET valid_flag = 'N'
    WHERE CONTRACT_ID = p_contract_id;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                'Updated valid_flag to N');
    END IF;

    -- Insert error message
    populate_import_errors(p_init_msg_list => FND_API.G_FALSE,
                                   p_api_version => 1.0,
                                   p_contract_id => p_contract_id,
                                   p_error_obj_type => G_IMP_DOCUMENT_ERROR,
                                   p_error_obj_id => p_imp_document_id,
                                   p_error_msg_txt => p_error_msg_txt,
                                   p_program_id => p_program_id,
                                   p_program_login_id => p_program_login_id,
                                   p_program_app_id => p_program_app_id,
                                   p_request_id => p_request_id,
                                   x_return_status => x_return_status,
                                   x_msg_count => x_msg_count,
                                   x_msg_data => x_msg_data);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                'Inserted error into okc_rep_imp_errors_t');
    END IF;


    IF(p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                'Committed transaction');
        END IF;

    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.delete_import_contract');
    END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving delete_import_contract:FND_API.G_EXC_ERROR Exception');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving delete_import_contract:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION, g_module || l_api_name,
             'Leaving delete_import_contract because of EXCEPTION: ' || sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                p_data  =>  x_msg_data);

  END delete_import_contract;

  -- Start of comments
  --API name      : Function add_quotes
  --Type          : Private.
  --Function      : Add quotes around a string
  --                if it contains comma or quotes.
  --                This is used for generating error report
  --                during repository import
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_string         IN VARCHAR2       Required
  --OUT           : if p_string contains comma, return "p_string"
  --                otherwise return p_string
  -- End of comments
  FUNCTION add_quotes(
      p_string     IN  VARCHAR2
    ) RETURN VARCHAR2
  IS
    l_api_name          VARCHAR2(30);
    l_string            VARCHAR2(2050);
    l_unprocessed_string VARCHAR2(2050);

  BEGIN

    l_api_name          := 'add_quotes';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.'||l_api_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_string is: ' || p_string);
    END IF;

    l_string := NULL;
    l_unprocessed_string := p_string;

    --if p_string starts and ends with quotes
    --we need to surround it with two double quotes
    --else if p_string contains comma
    --we need to surround it with one double quote
    IF (substr(l_unprocessed_string,1,1) = '"' AND substr(l_unprocessed_string, LENGTH(p_string), 1) = '"') THEN
        l_string := '""' || p_string || '""';
    ELSIF (instr(p_string, ',') > 0) THEN
        l_string := '"' || p_string || '"';

    ELSE
        l_string := p_string;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving Function OKC_REP_UTIL_PVT.'||l_api_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'l_string is: ' || l_string);
    END IF;

    return l_string;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function '||l_api_name||' because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_string;

  END add_quotes;

  -- Start of comments
  --API name      : Function get_csv_error_string
  --Type          : Private.
  --Function      : Returns one line in the CSV Error Report
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_imp_contract_id         IN NUMBER       Required
  --                   okc_rep_imp_contracts_t.imp_contract_id
  -- End of comments
  FUNCTION get_csv_error_string(
      p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2,
       p_imp_contract_id     IN  NUMBER
    ) RETURN VARCHAR2
  IS
    l_api_name                     VARCHAR2(30);
    l_num_parties                  CONSTANT NUMBER := 3;
    l_num_documents                CONSTANT NUMBER := 5;
    --there can be max of 9 error messages for each contract
    --one for header, three for parties, and five for documents
    --since each message has max length of 2000 in fnd_new_messages
    --l_csv_error_string should be at least 18000 + original data
    l_csv_error_string             VARCHAR2(20000);
    l_error_msg                    VARCHAR2(18000);

    l_empty_party_string           CONSTANT VARCHAR2(4) := ',,,,';
    l_empty_doc_string             CONSTANT VARCHAR2(3) := ',,,';
    l_party_index                  NUMBER;
    l_document_index               NUMBER;


    CURSOR IMP_CONTRACT_CSR IS
    SELECT CONTRACT_NUMBER,
    CONTRACT_NAME,
    CONTRACT_STATUS_TXT,
    CONTRACT_TYPE_TXT,
    CONTRACT_EFFECTIVE_DATE,
    CONTRACT_EXPIRATION_DATE,
    ORG_NAME,
    OWNER_USER_NAME,
    CURRENCY_CODE,
    CONTRACT_AMOUNT,
    AUTHORING_PARTY_TXT,
    PHYSICAL_LOCATION,
    KEYWORDS,
    DESCRIPTION,
    VERSION_COMMENTS,
    ORIG_SYSTEM_REFERENCE_CODE,
    ORIG_SYSTEM_REFERENCE_ID1,
    ORIG_SYSTEM_REFERENCE_ID2
    FROM OKC_REP_IMP_CONTRACTS_T
    WHERE IMP_CONTRACT_ID = p_imp_contract_id;

    l_imp_contract_rec IMP_CONTRACT_CSR%ROWTYPE;


    CURSOR IMP_PARTIES_CSR IS
    SELECT
    PARTY_INDEX,
    PARTY_NAME_TXT,
    PARTY_ROLE_TXT,
    SIGNED_BY_TXT,
    SIGNED_DATE
    FROM OKC_REP_IMP_PARTIES_T
    WHERE IMP_CONTRACT_ID = p_imp_contract_id
    ORDER BY PARTY_INDEX;

    l_imp_parties_rec IMP_PARTIES_CSR%ROWTYPE;


    CURSOR IMP_DOCUMENTS_CSR IS
    SELECT
    DOCUMENT_INDEX,
    FILE_NAME,
    CATEGORY_NAME_TXT,
    DOCUMENT_DESC
    FROM OKC_REP_IMP_DOCUMENTS_T
    WHERE IMP_CONTRACT_ID = p_imp_contract_id
    ORDER BY DOCUMENT_INDEX;

    l_imp_documents_rec IMP_DOCUMENTS_CSR%ROWTYPE;


    CURSOR IMP_ERRORS_CSR IS
    SELECT
    ERROR_MESSAGE
    FROM OKC_REP_IMP_ERRORS_T
    WHERE IMP_CONTRACT_ID = p_imp_contract_id;

    l_imp_errors_rec IMP_ERRORS_CSR%ROWTYPE;


  BEGIN

    l_api_name := 'get_csv_error_string';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.'||l_api_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_imp_contract_id is: ' || p_imp_contract_id);
    END IF;

    --initialize l_csv_error_string
    l_csv_error_string := NULL;

    OPEN IMP_CONTRACT_CSR;
    FETCH IMP_CONTRACT_CSR INTO l_imp_contract_rec;
    IF IMP_CONTRACT_CSR%NOTFOUND THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_imp_contract_id does not exist in okc_rep_imp_contracts_t: '||p_imp_contract_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'returning null');
        END IF;
        RETURN l_csv_error_string;
    END IF;

    -------------------Important: The order of the following statements matter!----------
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.contract_number) || ',';
    --l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.contract_name) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.contract_name);

    -- bug 4198537
    --the framework does not support opening the concurrent program output file in excel yet
    --so I am commenting the following part out
    /*
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.contract_status_txt) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.contract_type_txt) || ',';
    l_csv_error_string := l_csv_error_string || l_imp_contract_rec.contract_effective_date || ',';
    l_csv_error_string := l_csv_error_string || l_imp_contract_rec.contract_expiration_date || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.org_name) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.owner_user_name) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.currency_code) || ',';
    l_csv_error_string := l_csv_error_string || l_imp_contract_rec.contract_amount || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.authoring_party_txt) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.physical_location) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.keywords) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.description) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.version_comments) || ',';


    l_party_index := 0;
    OPEN IMP_PARTIES_CSR;
    LOOP
        FETCH IMP_PARTIES_CSR INTO l_imp_parties_rec;
        EXIT WHEN IMP_PARTIES_CSR%NOTFOUND;
        -------------------Important: The order of the following statements matter!----------
        l_csv_error_string := l_csv_error_string || add_quotes(l_imp_parties_rec.party_name_txt) || ',';
        l_csv_error_string := l_csv_error_string || add_quotes(l_imp_parties_rec.party_role_txt) || ',';
        l_csv_error_string := l_csv_error_string || add_quotes(l_imp_parties_rec.signed_by_txt) || ',';
        l_csv_error_string := l_csv_error_string || l_imp_parties_rec.signed_date || ',';
        l_party_index := l_party_index + 1;
    END LOOP;
    CLOSE IMP_PARTIES_CSR;

    IF l_party_index < l_num_parties THEN
        --we have less than 3 parties, need to fill in the commas
        FOR i IN (l_party_index+1)..l_num_parties
        LOOP
            l_csv_error_string := l_csv_error_string || l_empty_party_string;
        END LOOP;
    END IF;

    l_document_index := 0;
    OPEN IMP_DOCUMENTS_CSR;
    LOOP
        FETCH IMP_DOCUMENTS_CSR INTO l_imp_documents_rec;
        EXIT WHEN IMP_DOCUMENTS_CSR%NOTFOUND;
        -------------------Important: The order of the following statements matter!----------
        l_csv_error_string := l_csv_error_string || add_quotes(l_imp_documents_rec.file_name) || ',';
        l_csv_error_string := l_csv_error_string || add_quotes(l_imp_documents_rec.category_name_txt) || ',';
        l_csv_error_string := l_csv_error_string || add_quotes(l_imp_documents_rec.document_desc) || ',';
        l_document_index := l_document_index + 1;

    END LOOP;
    CLOSE IMP_DOCUMENTS_CSR;

    IF l_document_index < l_num_documents THEN
        --we have less than 5 documents, need to fill in the commas
        FOR i IN (l_document_index+1)..l_num_documents
        LOOP
            l_csv_error_string := l_csv_error_string || l_empty_doc_string;
        END LOOP;
    END IF;


    --we need to concatenate the last three orig_system* attributes
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.orig_system_reference_code) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.orig_system_reference_id1) || ',';
    l_csv_error_string := l_csv_error_string || add_quotes(l_imp_contract_rec.orig_system_reference_id2);
    --Note that we don't close the IMP_CONTRACT_CSR until last
    --because of the orig_system* attributes
*/
    CLOSE IMP_CONTRACT_CSR;


    --Concatenate error messages
    l_error_msg := NULL;
    OPEN IMP_ERRORS_CSR;
    LOOP
        FETCH IMP_ERRORS_CSR INTO l_imp_errors_rec;
        EXIT WHEN IMP_ERRORS_CSR%NOTFOUND;
        l_error_msg :=  l_error_msg || FND_GLOBAL.Newline || l_imp_errors_rec.error_message || ' ';
    END LOOP;
    CLOSE IMP_ERRORS_CSR;

    IF(LENGTH(l_error_msg) > 0) THEN
        l_csv_error_string := l_csv_error_string || ',' || add_quotes(l_error_msg);
    END IF;

    l_csv_error_string := l_csv_error_string || FND_GLOBAL.Newline;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving Function '||l_api_name);
    END IF;
    RETURN l_csv_error_string;

  EXCEPTION
    WHEN OTHERS THEN

      --close cursors
      IF (IMP_CONTRACT_CSR%ISOPEN) THEN
        CLOSE IMP_CONTRACT_CSR ;
      END IF;
      IF (IMP_PARTIES_CSR%ISOPEN) THEN
        CLOSE IMP_PARTIES_CSR ;
      END IF;
      IF (IMP_DOCUMENTS_CSR%ISOPEN) THEN
        CLOSE IMP_DOCUMENTS_CSR ;
      END IF;
      IF (IMP_ERRORS_CSR%ISOPEN) THEN
        CLOSE IMP_ERRORS_CSR ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function '||l_api_name||' because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_csv_error_string ;
  END get_csv_error_string;



  -- Start of comments
  --API name      : Function get_csv_header_string
  --Type          : Private.
  --Function      : Returns the header in the csv file
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  -- End of comments
  FUNCTION get_csv_header_string(
      p_api_version              IN NUMBER,
       p_init_msg_list            IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_api_name                      VARCHAR2(30);
    l_csv_header_string             VARCHAR2(10000);

    CURSOR CSV_HEADER_CSR IS
    select meaning from fnd_lookup_values
    where lookup_type = 'OKC_REP_IMP_TEMPL_ATTRIBUTES'
    and LANGUAGE = userenv('LANG')
    and VIEW_APPLICATION_ID = 0
    and SECURITY_GROUP_ID = fnd_global.lookup_security_group('OKC_REP_IMP_TEMPL_ATTRIBUTES', VIEW_APPLICATION_ID)
    and enabled_flag = 'Y'
    order by to_number(tag);

    l_csv_header_rec CSV_HEADER_CSR%ROWTYPE;

    BEGIN

    l_api_name := 'get_csv_header_string';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.'||l_api_name);
    END IF;

    l_csv_header_string := NULL;
    OPEN CSV_HEADER_CSR;
    LOOP
        FETCH CSV_HEADER_CSR INTO l_csv_header_rec;
        EXIT WHEN CSV_HEADER_CSR%NOTFOUND;
        l_csv_header_string := l_csv_header_string || l_csv_header_rec.meaning || ',';
    END LOOP;
    CLOSE CSV_HEADER_CSR;

    IF(instr(l_csv_header_string, ',') > 0) THEN
        --we need to remove the last ','
        l_csv_header_string := substr(l_csv_header_string,1, length(l_csv_header_string)-1);
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.'||l_api_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'l_csv_header_string is: ' || l_csv_header_string);
    END IF;

    RETURN l_csv_header_string;

    EXCEPTION
    WHEN OTHERS THEN
      --close cursors
      IF (CSV_HEADER_CSR%ISOPEN) THEN
        CLOSE CSV_HEADER_CSR ;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function '||l_api_name||' because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_csv_header_string;

  END get_csv_header_string;



  -- Start of comments
  --API name      : get_vendor_userlist
  --Type          : Private.
  --Function      : Returns the external vendor user email addresses.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_document_id         IN NUMBER       Required
  --                   Id of the contract
  --              : p_external_party_id   IN NUMBER       Required
  --                   External party ID
  --OUT           : x_external_userlist   OUT  VARCHAR2(1)
  --                      external contact email addresses
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE get_vendor_userlist(
      p_api_version         IN  NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_document_id         IN  NUMBER,
      p_external_party_id   IN NUMBER,
      x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
    x_external_userlist   OUT NOCOPY VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;
    l_contact_email_address VARCHAR2(450);
    l_index             NUMBER;

    CURSOR vendor_contact_csr IS
      SELECT contact_id
      FROM OKC_REP_PARTY_CONTACTS
      WHERE contract_id = p_document_id
       AND  party_id = p_external_party_id
       AND  party_role_code = G_PARTY_ROLE_SUPPLIER;

    CURSOR vendor_email_csr(l_contact_id NUMBER) IS
        SELECT email_address
        FROM po_vendor_contacts pvc
        WHERE pvc.vendor_contact_id = l_contact_id;

  BEGIN

    l_api_name      := 'get_vendor_userlist';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_UTIL_PVT.get_external_userlist');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_document_id is: ' || to_char(p_document_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_external_party_id is: ' || to_char(p_external_party_id));
    END IF;

  -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get email address of the vendor contacts.
    l_index := 1;
    FOR vendor_contact_rec IN vendor_contact_csr  LOOP

      -- Added for bug 5230060 fix
      l_contact_email_address := NULL;

        OPEN vendor_email_csr(vendor_contact_rec.contact_id);
        FETCH vendor_email_csr INTO l_contact_email_address;
        CLOSE vendor_email_csr;
        IF (l_contact_email_address IS NOT NULL) THEN
            IF (l_index = 1) THEN
                x_external_userlist := l_contact_email_address;
            ELSE
                x_external_userlist := x_external_userlist || ',' || l_contact_email_address;
            END IF;  -- (l_index = 1)
        l_index := l_index + 1;
        END IF; -- (l_contact_email_address <> NULL)
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.get_vendor_userlist');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_vendor_userlist:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursor
        IF (vendor_contact_csr%ISOPEN) THEN
          CLOSE vendor_contact_csr ;
        END IF;
        IF (vendor_email_csr%ISOPEN) THEN
          CLOSE vendor_email_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_vendor_userlist:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursor
        IF (vendor_contact_csr%ISOPEN) THEN
          CLOSE vendor_contact_csr ;
        END IF;
        IF (vendor_email_csr%ISOPEN) THEN
          CLOSE vendor_email_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_vendor_userlist because of EXCEPTION: ' || sqlerrm);
        END IF;
        --close cursor
        IF (vendor_contact_csr%ISOPEN) THEN
          CLOSE vendor_contact_csr ;
        END IF;
        IF (vendor_email_csr%ISOPEN) THEN
          CLOSE vendor_email_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END get_vendor_userlist;

  -- Start of comments
  --API name      : get_customer_userlist
  --Type          : Private.
  --Function      : Returns the external customer user email addresses.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_document_id         IN NUMBER       Required
  --                   Id of the contract
  --              : p_external_party_id   IN NUMBER       Required
  --                   External party ID
  --              : p_external_party_role IN VARCHAR2     Required
  --                   External party role.
  --OUT           : x_external_userlist   OUT  VARCHAR2(1)
  --                      external contact email addresses
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE get_customer_userlist(
      p_api_version         IN  NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_document_id         IN  NUMBER,
      p_external_party_id   IN NUMBER,
      p_external_party_role IN VARCHAR2,
      x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
    x_external_userlist   OUT NOCOPY VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;
    l_contact_email_address     VARCHAR2(450);
    l_index             NUMBER;

    CURSOR tca_contact_csr IS
      SELECT contact_id
      FROM OKC_REP_PARTY_CONTACTS
      WHERE contract_id = p_document_id
       AND  party_id = p_external_party_id
       AND  party_role_code = p_external_party_role;

    CURSOR tca_email_csr(l_contact_id NUMBER) IS
        SELECT email_address
        FROM hz_contact_points cp
        WHERE cp.owner_table_id = l_contact_id
           AND   cp.owner_table_name='HZ_PARTIES'
           AND   cp.contact_point_type = 'EMAIL';
  BEGIN
    l_api_name := 'get_customer_userlist';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_UTIL_PVT.get_customer_userlist');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_document_id is: ' || to_char(p_document_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_external_party_id is: ' || to_char(p_external_party_id));
    END IF;

  -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_index := 1;
    FOR tca_contact_rec IN tca_contact_csr LOOP

        -- Added for bug 5230060 fix
        l_contact_email_address := NULL;

        OPEN tca_email_csr(tca_contact_rec.contact_id);
        FETCH tca_email_csr INTO l_contact_email_address;
        CLOSE tca_email_csr;
        IF (l_contact_email_address IS NOT NULL) THEN
            IF (l_index = 1) THEN
                x_external_userlist := l_contact_email_address;
            ELSE
                x_external_userlist := x_external_userlist || ',' || l_contact_email_address;
            END IF;  -- (l_index = 1)
        l_index := l_index + 1;
        END IF; -- (l_contact_email_address <> NULL)
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.get_customer_userlist');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_customer_userlist:FND_API.G_EXC_ERROR Exception');
        END IF;
        IF (tca_contact_csr%ISOPEN) THEN
          CLOSE tca_contact_csr ;
        END IF;
        IF (tca_email_csr%ISOPEN) THEN
          CLOSE tca_email_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_customer_userlist:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        IF (tca_contact_csr%ISOPEN) THEN
          CLOSE tca_contact_csr ;
        END IF;
        IF (tca_email_csr%ISOPEN) THEN
          CLOSE tca_email_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_customer_userlist because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (tca_contact_csr%ISOPEN) THEN
          CLOSE tca_contact_csr ;
        END IF;
        IF (tca_email_csr%ISOPEN) THEN
          CLOSE tca_email_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END get_customer_userlist;


  -- Start of comments
  --API name      : get_external_userlist
  --Type          : Private.
  --Function      : Returns the external user email addresses.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_document_id         IN NUMBER       Required
  --                   Id of the contract
  --             : p_document_type        IN VARCHAR2     Required
  --                   Contract type.
  --              : p_external_party_id   IN NUMBER       Required
  --                   External party ID
  --              : p_external_party_role IN VARCHAR2     Required
  --                   External party role.
  --OUT           : x_external_userlist   OUT  VARCHAR2(1)
  --                      external contact email addresses
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE get_external_userlist(
      p_api_version         IN  NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_document_id         IN  NUMBER,
      p_document_type       IN VARCHAR2,
      p_external_party_id   IN NUMBER,
      p_external_party_role IN VARCHAR2,
      x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
    x_external_userlist   OUT NOCOPY VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       CONSTANT NUMBER := 1.0;

  BEGIN

    l_api_name      := 'get_external_userlist';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_UTIL_PVT.get_external_userlist');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_document_id is: ' || to_char(p_document_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_document_type is: ' || to_char(p_document_type));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_external_party_id is: ' || to_char(p_external_party_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_external_party_role is: ' || to_char(p_external_party_role));
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    if (p_external_party_role = G_PARTY_ROLE_SUPPLIER) THEN
        get_vendor_userlist(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_document_id         => p_document_id,
          p_external_party_id   => p_external_party_id,
          x_msg_data            => x_msg_data,
          x_msg_count           => x_msg_count,
          x_return_status       => x_return_status,
        x_external_userlist   => x_external_userlist);
  ELSE
      get_customer_userlist(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_document_id         => p_document_id,
          p_external_party_id   => p_external_party_id,
          p_external_party_role => p_external_party_role,
          x_msg_data            => x_msg_data,
          x_msg_count           => x_msg_count,
          x_return_status       => x_return_status,
        x_external_userlist   => x_external_userlist);
    END IF;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.get_external_userlist');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_external_userlist:FND_API.G_EXC_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_external_userlist:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving get_external_userlist because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END get_external_userlist;


  -- Start of comments
  --API name      : ok_to_commit
  --Type          : Private.
  --Function      : Returns the external user email addresses.
  --                Bug Fix 4232846 - If p_validation_string is not null (called from
  --                Contract Parties or Deliverables) we should check contract status
  --                as well.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --                   Default = FND_API.G_FALSE
  --              : p_doc_id              IN NUMBER       Required
  --                   Id of the contract
  --              : p_validation_string   IN VARCHAR2     Optional
  --                   Validation string
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  FUNCTION ok_to_commit(
      p_api_version       IN  Number,
      p_init_msg_list     IN  Varchar2,
      p_doc_id            IN  Number,
      p_validation_string IN  Varchar2 default NULL,
      x_return_status     OUT NOCOPY Varchar2,
      x_msg_data          OUT NOCOPY Varchar2,
      x_msg_count         OUT NOCOPY Number)
  RETURN Varchar2 IS

    l_api_version      NUMBER;
    l_api_name         VARCHAR2(30);
    l_ok_to_commit     Varchar2(1);
    l_temp             NUMBER;


    CURSOR l_contract_exist_csr IS
      SELECT contract_id
      FROM okc_rep_contracts_all
      WHERE contract_id=p_doc_id;

    CURSOR l_contract_updatable_csr IS
      SELECT contract_id
      FROM okc_rep_contracts_all
      WHERE contract_id=p_doc_id
          AND contract_status_code in (G_STATUS_REJECTED, G_STATUS_DRAFT);


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_REP_WF_PVT.ok_to_commit');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_doc_id = ' || p_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'p_validation_string = ' || p_validation_string);
    END IF;

    l_api_version := 1.0;
    l_api_name := 'ok_to_commit';
    l_ok_to_commit := FND_API.G_FALSE;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If p_validation_string is NULL, check only the header record. Otherwise check contract
    -- status as well.
    IF (p_validation_string is NULL) THEN
        OPEN  l_contract_exist_csr;
        FETCH l_contract_exist_csr INTO l_temp;
        IF (l_contract_exist_csr%NOTFOUND) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract not found');
            END IF;
            l_ok_to_commit := FND_API.G_FALSE;
            CLOSE l_contract_exist_csr;
        ELSE
            -- Update the CONTRACT_LAST_UPDATE_DATE and CONTRACT_LAST_UPDATE_BY columns
            -- No need to updated these columns. These are updated upon View Contract.
            -- UPDATE  okc_rep_contracts_all
            -- SET     CONTRACT_LAST_UPDATE_DATE = sysdate,
            --      CONTRACT_LAST_UPDATED_BY = FND_GLOBAL.user_id()
            -- WHERE   contract_id = p_doc_id;
            l_ok_to_commit := FND_API.G_TRUE;
            CLOSE l_contract_exist_csr;
        END IF; -- (l_contract_exist_csr%NOTFOUND)
    ELSE
        OPEN  l_contract_updatable_csr;
        FETCH l_contract_updatable_csr INTO l_temp;
        IF (l_contract_updatable_csr%NOTFOUND) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract not found');
            END IF;
            l_ok_to_commit := FND_API.G_FALSE;
            CLOSE l_contract_updatable_csr;
        ELSE
            -- Update the CONTRACT_LAST_UPDATE_DATE and CONTRACT_LAST_UPDATE_BY columns
            -- No need to updated these columns. These are updated upon View Contract.
            -- UPDATE  okc_rep_contracts_all
            -- SET     CONTRACT_LAST_UPDATE_DATE = sysdate,
            --      CONTRACT_LAST_UPDATED_BY = FND_GLOBAL.user_id()
            -- WHERE   contract_id = p_doc_id;
            l_ok_to_commit := FND_API.G_TRUE;
            CLOSE l_contract_updatable_csr;
        END IF; -- (l_contract_updatable_csr%NOTFOUND)
    END IF;   -- (p_validation_string is NULL)
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                   '110: Leaving OKC_REP_UTIL_PVT.ok_to_commit');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              '111: Output is: ' || l_ok_to_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              '112: x_return_status is: ' || x_return_status);
    END IF;
    return l_ok_to_commit;
  EXCEPTION

    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                  'Leaving Function ok_to_commit because of EXCEPTION: '||sqlerrm);
        END IF;

        IF (l_contract_exist_csr%ISOPEN) THEN
          CLOSE l_contract_exist_csr ;
        END IF;
        IF (l_contract_updatable_csr%ISOPEN) THEN
          CLOSE l_contract_updatable_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
    RETURN l_ok_to_commit ;

  END ok_to_commit;


-- Start of comments
--API name      : purge_recent_contracts
--Type          : Private.
--Function      : Called from OKC_PURGE_PVT package to purge
--                contracts that are older than p_num_days days
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--IN            : p_num_days IN NUMBER
--Note          :
-- End of comments

  PROCEDURE purge_recent_contracts(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_num_days IN NUMBER)

  IS
    l_api_name      VARCHAR2(32);
  BEGIN
    l_api_name := 'purge_recent_contracts';

    retcode := G_RETURN_CODE_ERROR;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Entering OKC_REP_UTIL_PVT.purge_recent_contracts');
    END IF;

    DELETE FROM okc_rep_recent_contracts c
    WHERE c.last_visited_date < SYSDATE - p_num_days;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Leaving OKC_REP_UTIL_PVT.purge_recent_contracts');
    END IF;

    retcode := G_RETURN_CODE_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            G_MODULE || l_api_name,
            'Leaving purge_recent_contracts because of EXCEPTION: ' || SQLERRM);
          errbuf := substr(SQLERRM, 1, 200);
        END IF;

END purge_recent_contracts;

-- Start of comments
--API name      : can_update
--Type          : Private.
--Function      : Checks if user can update a contract
--Pre-reqs      : None.
--Parameters    :
--OUT           : Return Y if user is allowed to update contracts, N if not allowed
--Note          :
-- End of comments

  FUNCTION can_update RETURN VARCHAR2
    IS
        l_api_name   VARCHAR2(10);
        l_can_update VARCHAR2(1);
  BEGIN

    l_api_name                     := 'can_update';
    l_can_update                   := 'N';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.can_update');
    END IF;

    IF FND_FUNCTION.TEST(G_FUNC_OKC_REP_ADMINISTRATOR,'Y') OR FND_FUNCTION.TEST(G_FUNC_OKC_REP_USER_FUNC,'Y') THEN
      l_can_update := 'Y';
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.check_contract_access returns l_can_update as : '
          || l_can_update);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Leaving Function l_can_update');
    END IF;
    RETURN l_can_update;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function can_update because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_can_update ;
  END can_update;

-- Start of comments
--API name      : is_sales_workbench
--Type          : Private.
--Function      : Checks if the current application is Sales Contracts Workbench or Contract Repository
--Pre-reqs      : None.
--Parameters    :
--OUT           : Return Y if it is Sales Contracts Workbench, otherwise returns N
--Note          :
-- End of comments

  FUNCTION is_sales_workbench RETURN VARCHAR2
    IS

      l_api_name   VARCHAR2(20);
      l_is_sales_workbench VARCHAR2(1);

    BEGIN

      l_api_name := 'is_sales_workbench';
      l_is_sales_workbench := 'N';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Entered Function OKC_REP_UTIL_PVT.is_sales_workbench');
      END IF;

      IF FND_FUNCTION.TEST(G_FUNC_OKC_REP_SALES_WB_USER,'Y') THEN
        l_is_sales_workbench := 'Y';
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'OKC_REP_UTIL_PVT.is_sales_workbench returns l_is_sales_workbench as : '
            || l_is_sales_workbench);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Leaving Function is_sales_workbench');
      END IF;

      RETURN l_is_sales_workbench;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                  'Leaving Function is_sales_workbench because of EXCEPTION: '||sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        RETURN l_is_sales_workbench ;
  END is_sales_workbench;


  -- Start of comments
  --API name      : insert_new_vendor_contact
  --Type          : Private.
  --Function      : Creates a new vendor contact and returns the newly created contact id.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_vendor_site_id         IN NUMBER       Required
  --                   Vendor site id of the contact
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract for which the new contact being created
  --              : p_first_name       IN VARCHAR2     Required
  --                   First name of the contact
  --              : p_last_name         IN NUMBER       Required
  --                   Last name of the contact
  --              : p_area_code        IN VARCHAR2     Optional
  --                   Area code of the contact phone number.
  --              : p_phone   IN NUMBER       Optional
  --                   Phone number of the contact
  --              : p_email_address IN VARCHAR2     Optional
  --                   Email address of the contact.
  --OUT           : x_vendor_contact_id   OUT  VARCHAR2(1)
  --                   Vendor contact id
  -- End of comments
  PROCEDURE insert_new_vendor_contact(
      p_vendor_site_id                IN NUMBER,
      p_contract_id                   IN NUMBER,
      p_first_name                    IN VARCHAR2,
      p_last_name                     IN VARCHAR2,
      p_area_code                     IN VARCHAR2,
      p_phone                         IN VARCHAR2,
      p_email_address                 IN VARCHAR2,
      x_vendor_contact_id             OUT NOCOPY NUMBER)
  IS
      l_api_name      VARCHAR2(32);
      l_vendor_contact_rec AP_VENDOR_PUB_PKG.r_vendor_contact_rec_type;


      l_return_status VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(2000);
      l_per_party_id NUMBER;
      l_rel_party_id NUMBER;
      l_rel_id NUMBER;
      l_org_contact_id NUMBER;
      l_party_site_id NUMBER;
      l_org_id okc_rep_contracts_all.org_id%TYPE;

      CURSOR contract_org_csr IS
          SELECT org_id
          FROM okc_rep_contracts_all
          WHERE contract_id = p_contract_id;

/* Bug 8721411 */
      CURSOR get_party_id( okc_contract_id OKC_REP_CONTRACT_PARTIES.contract_id%TYPE ,
                       party_rep_location_id OKC_REP_CONTRACT_PARTIES.party_location_id%TYPE)
                   IS
                   SELECT     party_id
                   FROM     OKC_REP_CONTRACT_PARTIES
                   WHERE    contract_id=okc_contract_id  AND
                            party_location_id=party_rep_location_id;

/* Bug 8721411 */
    BEGIN
      l_api_name := 'insert_new_vendor_contact';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        'Entering OKC_REP_UTIL_PVT.insert_new_vendor_contact');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_vendor_site_id: ' || p_vendor_site_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_contract_id: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_first_name: ' || p_first_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_last_name: ' || p_last_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_area_code: ' || p_area_code);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_phone: ' || p_phone);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_email_address: ' || p_email_address);
      END IF;

      -- Populate the record structure required by AP API
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Populate the record structure required by AP API');
      END IF;

      OPEN  contract_org_csr;
      FETCH contract_org_csr  INTO  l_org_id;
      CLOSE contract_org_csr;

      -- Set single-org policy context
      -- Even though in R12 vedor information is migrated to TCA still
      -- AP has some legacy code which requires org context
      IF (l_org_id IS NOT NULL) THEN
        MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                                     p_org_id => l_org_id);
      END IF;

      l_vendor_contact_rec.VENDOR_SITE_ID := p_vendor_site_id;
      l_vendor_contact_rec.ORG_ID := l_org_id;
      l_vendor_contact_rec.PERSON_FIRST_NAME := p_first_name;
      l_vendor_contact_rec.PERSON_LAST_NAME := p_last_name;
      l_vendor_contact_rec.AREA_CODE := p_area_code;
      l_vendor_contact_rec.PHONE := p_phone;
      l_vendor_contact_rec.EMAIL_ADDRESS := p_email_address;

/* Bug 8721411 */

       OPEN get_party_id(p_contract_id,p_vendor_site_id);
      FETCH get_party_id INTO  l_vendor_contact_rec.VENDOR_ID;
      CLOSE get_party_id;


/* Bug 8721411 */

      -- Call the API to create a vendor contact
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Before calling AP_VENDOR_PUB_PKG.create_vendor_contact()');
      END IF;

      -- Call AP API to create a vendor contact as per user entered information
      AP_VENDOR_PUB_PKG.create_vendor_contact(
                            p_api_version => 1.0,
                            p_vendor_contact_rec => l_vendor_contact_rec,
                            p_commit => FND_API.G_FALSE,
                            x_vendor_contact_id => x_vendor_contact_id,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_per_party_id => l_per_party_id,
                            x_rel_party_id => l_rel_party_id,
                            x_rel_id => l_rel_id,
                            x_org_contact_id => l_org_contact_id,
                            x_party_site_id => l_party_site_id);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'After calling AP_VENDOR_PUB_PKG.create_vendor_contact()');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
            G_MODULE||l_api_name,
            'Leaving OKC_REP_UTIL_PVT.insert_new_vendor_contact');
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            G_MODULE || l_api_name,
            'Leaving insert_new_vendor_contact because of EXCEPTION: ' || SQLERRM);
        END IF;

END insert_new_vendor_contact;



  -- Start of comments
  --API name      : sync_con_header_attributes
  --Type          : Public.
  --Function      : Updates the header level attributes of all archived versions when they're modified in the working version
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contact
  --OUT           : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE sync_con_header_attributes(
      p_api_version         IN NUMBER,
      p_init_msg_list       IN VARCHAR2,
      p_contract_id                IN NUMBER,
      x_msg_data            OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2)
  IS
      l_api_name      VARCHAR2(32);
      l_api_version       NUMBER;

      l_desc okc_rep_contracts_all.contract_desc%TYPE;
      l_use_acl_flag okc_rep_contracts_all.use_acl_flag%TYPE;
      l_expire_ntf_flag okc_rep_contracts_all.expire_ntf_flag%TYPE;
      l_expire_ntf_period okc_rep_contracts_all.expire_ntf_period%TYPE;
      l_ntf_contact_role_id okc_rep_contracts_all.notify_contact_role_id%TYPE;

      CURSOR contract_attribs_csr IS
        SELECT contract_desc,
               use_acl_flag,
               expire_ntf_flag,
               expire_ntf_period,
               notify_contact_role_id
        FROM okc_rep_contracts_all
        WHERE contract_id = p_contract_id;

    BEGIN
      l_api_name := 'sync_con_header_attributes';
      l_api_version := 1.0;

      -- Standard Start of API savepoint
      SAVEPOINT sync_con_header_attributes;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        'Entering OKC_REP_UTIL_PVT.sync_con_header_attributes');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'p_contract_id: ' || p_contract_id);
      END IF;

      OPEN  contract_attribs_csr;
      FETCH contract_attribs_csr  INTO  l_desc, l_use_acl_flag, l_expire_ntf_flag, l_expire_ntf_period, l_ntf_contact_role_id;
      CLOSE contract_attribs_csr;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                          'l_desc : ' || l_desc);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                          'l_use_acl_flag : ' || l_use_acl_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                          'l_expire_ntf_flag : ' || l_expire_ntf_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                          'l_expire_ntf_period : ' || l_expire_ntf_period);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                          'l_ntf_contact_role_id : ' || l_ntf_contact_role_id);
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                        'Updating Archived versions of Contract with new Contract header attribute values');
      END IF;

      -- Update all the rows in archived contract versions table with new contract header details
      UPDATE okc_rep_contract_vers
      SET contract_desc = l_desc,
          use_acl_flag = l_use_acl_flag,
          expire_ntf_flag = l_expire_ntf_flag,
          expire_ntf_period = l_expire_ntf_period,
          notify_contact_role_id = l_ntf_contact_role_id
      WHERE contract_id = p_contract_id;

      COMMIT WORK;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_UTIL_PVT.sync_con_header_attributes');
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            G_MODULE || l_api_name,
            'Leaving sync_con_header_attributes because of EXCEPTION: ' || SQLERRM);
        END IF;

        IF (contract_attribs_csr%ISOPEN) THEN
          CLOSE contract_attribs_csr ;
        END IF;

END sync_con_header_attributes;


  -- Start of comments
  --API name      : check_contract_doc_access
  --Type          : Private.
  --Function      : Checks access to contract docs by the current user.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_api_version         IN NUMBER       Required
  --              : p_init_msg_list       IN VARCHAR2     Optional
  --              : p_contract_id         IN NUMBER       Required
  --                   Id of the contract whose access to be checked
  --              : p_function_name       IN VARCHAR2       Required
  --                   Name of the function whose access to be checked. Possible values OKC_REP_SELECT and OKC_REP_UPDATE
  --OUT           : x_has_access          OUT  VARCHAR2(1)
  --              : x_status_code         OUT  VARCHAR2(30)
  --              : x_return_status       OUT  VARCHAR2(1)
  --              : x_msg_count           OUT  NUMBER
  --              : x_msg_data            OUT  VARCHAR2(2000)
  -- End of comments
  PROCEDURE check_contract_doc_access(
      p_api_version     IN  NUMBER,
      p_init_msg_list   IN VARCHAR2,
      p_contract_id     IN  NUMBER,
      p_version_number  IN  NUMBER,
      p_function_name   IN  VARCHAR2,
      x_has_access      OUT NOCOPY  VARCHAR2,
      x_status_code     OUT NOCOPY  VARCHAR2,
      x_archived_yn     OUT NOCOPY  VARCHAR2,
      x_msg_data        OUT NOCOPY  VARCHAR2,
      x_msg_count       OUT NOCOPY  NUMBER,
      x_return_status   OUT NOCOPY  VARCHAR2)
  IS

     l_status_code OKC_REP_CONTRACTS_ALL.CONTRACT_STATUS_CODE%TYPE;
     l_archived_yn OKC_REP_DOC_VERSIONS_V.ARCHIVED_YN%TYPE;

  BEGIN

     check_contract_access(
      p_api_version     => p_api_version,
      p_init_msg_list   => p_init_msg_list,
      p_contract_id     => p_contract_id,
      p_function_name   => p_function_name,
      x_has_access      => x_has_access,
      x_msg_data        => x_msg_data,
      x_msg_count       => x_msg_count,
      x_return_status   => x_return_status) ;

      select status, archived_yn into l_status_code, l_archived_yn
        from OKC_REP_DOC_VERSIONS_V
        where document_id = p_contract_id
        and   document_version = p_version_number;

      x_status_code := l_status_code;
      x_archived_yn := l_archived_yn;

  EXCEPTION
  WHEN OTHERS THEN

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                 g_module || 'check_contract_doc_access.exception',
                 '117: Leaving check_contract_access because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

  END check_contract_doc_access;

  FUNCTION get_accessible_ous RETURN VARCHAR2
  IS
    l_api_name   VARCHAR2(20);
    l_ou_list VARCHAR2(4000);
    l_ou_tab MO_GLOBAL.OrgIdTab;

    BEGIN

      l_api_name := 'get_accessible_ous';


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Entered Function OKC_REP_UTIL_PVT.get_accessible_ous');
      END IF;

      l_ou_tab := MO_GLOBAL.get_ou_tab;

      IF (l_ou_tab.COUNT > 0) THEN

        FOR i IN l_ou_tab.FIRST .. l_ou_tab.LAST LOOP

          l_ou_list := l_ou_list || ' ' || l_ou_tab(i);

          IF (i <> l_ou_tab.LAST) THEN

            l_ou_list := l_ou_list || ', ';

          END IF;

        END LOOP;

      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'OKC_REP_UTIL_PVT.get_accessible_ous returns l_ou_list as : '
            || l_ou_list);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Leaving Function get_accessible_ous');
      END IF;
      RETURN l_ou_list;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                  'Leaving Function get_accessible_ous because of EXCEPTION: '||sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
  END get_accessible_ous;


-- Start of comments
  --API name      : has_contract_access
  --Type          : Private.
  --Function      : Checks access to a quote by the current user. It first checks the profile
  --              : "aso_enable_security_check". If this profile is set to 'No',
  --              : the API returns 'UPDATE'. else it calls ASO_SECURITY_INT.get_quote_access
  --              : to get the current user access.
  --              :
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_resource_id         IN NUMBER       Required
  --              : p_quote_number        IN NUMBER       Required
  --OUT           : Return 'NONE' if the current user does not have access to the quote. Else it
  --              : returns 'READ' or 'UPDATE'.
  -- End of comments
  FUNCTION get_quote_access
  (
    p_resource_id                IN   NUMBER,
    p_quote_number               IN   NUMBER
  ) RETURN VARCHAR2
  IS
    l_api_name                     VARCHAR2(30);
    l_access                       VARCHAR2(30);
    l_check_security_access        VARCHAR2(15);

  BEGIN

    l_api_name                     := 'get_quote_access';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_UTIL_PVT.get_quote_access');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Resource Id is: ' || p_resource_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Quote Number is: ' || p_quote_number);
    END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'checking security profile - ASO_ENABLE_SECURITY_CHECK');
    END IF;

    FND_PROFILE.GET(NAME => G_SALES_QUOTE_SEC_PROFILE, VAL => l_check_security_access);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Profile ASO_ENABLE_SECURITY_CHECK value is: '||l_check_security_access);
    END IF;
    IF (l_check_security_access = 'N') THEN
        l_access := G_SALES_QUOTE_UPDATE_ACCESS;
    ELSE
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling ASO_SECURITY_INT.get_quote_access to get the access');
        END IF;
        l_access := ASO_SECURITY_INT.get_quote_access(p_resource_id, p_quote_number);
    END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.get_quote_access returns l_access as : '
          || l_access);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Leaving Function get_quote_access');
    END IF;
    RETURN l_access ;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function get_quote_access because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN l_access ;
  END get_quote_access;

 --Start of comments
  --API name      : contract_terms_disabled_yn
  --Type          : Private.
  --Function      : Based on the type of the contract selected for update, this
  --              : will return 'Y' if there exist contracts with this contract type
  --              : which have structured terms authored.
  --              : Otherwise, it will return 'N'.The Enable_Contract_Terms chkbox
  --              : will be readonly if 'Y' is returned.It will be updateable otherwise.
  --              :
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_contract_type               IN  VARCHAR2      Required
  --OUT           : x_disable_contract_terms_yn   OUT VARCHAR2
  -- End of comments

  PROCEDURE contract_terms_disabled_yn
  (p_contract_type              IN VARCHAR2 ,
  x_disable_contract_terms_yn   OUT NOCOPY  VARCHAR2

  )
  IS
  l_api_name                     VARCHAR2(30);

  BEGIN

  l_api_name := 'contract_terms_disabled_yn';

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Procedure OKC_REP_UTIL_PVT.contract_terms_disabled_yn');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Type is: ' || p_contract_type);

  END IF;


  SELECT Nvl((SELECT 'Y' FROM okc_template_usages WHERE document_type = p_contract_type AND ROWNUM =1),'N') INTO x_disable_contract_terms_yn FROM dual;



  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.contract_terms_disabled_yn returns x_disable_contract_terms_yn as : '
          || x_disable_contract_terms_yn);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Leaving Procedure contract_terms_disabled_yn');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN

        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                'Leaving Function contract_terms_disabled_yn because of EXCEPTION: '||sqlerrm);
      END IF;

        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);



  END contract_terms_disabled_yn;




END OKC_REP_UTIL_PVT;

/
