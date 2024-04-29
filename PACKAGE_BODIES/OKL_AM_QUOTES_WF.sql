--------------------------------------------------------
--  DDL for Package Body OKL_AM_QUOTES_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_QUOTES_WF" AS
/* $Header: OKLRQWFB.pls 120.26 2008/02/01 04:58:13 veramach noship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_create_quote_pvt.';

  -- Start of comments
  --
  -- Procedure Name : raise_pre_proceeds_event
  -- Description   : Not required once the raise event is done from okl_am_wf
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE raise_pre_proceeds_event (
                                   p_transaction_id   IN VARCHAR2) AS

    l_parameter_list        wf_parameter_list_t;
    l_key                   VARCHAR2(240);
    l_event_name            VARCHAR2(240) := 'oracle.apps.okl.am.preproceeds';
    l_seq                   NUMBER;

    -- Cursor to get the value of the sequence
   CURSOR okl_key_csr IS
   SELECT okl_wf_item_s.nextval
   FROM   DUAL;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'raise_pre_proceeds_event';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    SAVEPOINT raise_pre_proceeds_event;

   OPEN  okl_key_csr;
   FETCH okl_key_csr INTO l_seq;
   CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq ;

    WF_EVENT.AddParameterToList('TRANSACTION_ID',
                                p_transaction_id,
                                l_parameter_list);
    --added by akrangan
    wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
    -- Raise Event
    WF_EVENT.raise(
                 p_event_name  => l_event_name,
                 p_event_key   => l_key,
                 p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;
      ROLLBACK TO raise_pre_proceeds_event;
  END raise_pre_proceeds_event;

  -- Start of comments
  --
  -- Procedure Name : raise_repurchase_quote_event
  -- Description   : Not required once the raise event is done from okl_am_wf
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE raise_repurchase_quote_event (
                                   p_transaction_id   IN VARCHAR2) AS

    l_parameter_list      wf_parameter_list_t;
    l_key                 VARCHAR2(240);
    l_event_name          VARCHAR2(240) := 'oracle.apps.okl.am.repurchasequote';
    l_seq                 NUMBER;

    -- Cursor to get the value of the sequence
   CURSOR okl_key_csr IS
   SELECT okl_wf_item_s.nextval
   FROM   DUAL;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'raise_repurchase_quote_event';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);


  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    SAVEPOINT raise_repurchase_quote_event;

   OPEN  okl_key_csr;
   FETCH okl_key_csr INTO l_seq;
   CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq ;

    WF_EVENT.AddParameterToList('TRANSACTION_ID',
                                p_transaction_id,
                                l_parameter_list);
    wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
    -- Raise Event
    WF_EVENT.raise(
                 p_event_name  => l_event_name,
                 p_event_key   => l_key,
                 p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;
      ROLLBACK TO raise_repurchase_quote_event;
  END raise_repurchase_quote_event;


  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_qte_partial
  -- Description   : Checks if the quote is a partial quote or not
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_qte_partial(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    -- Get the assets for the contract
   -- nikshah -- Bug # 5484903 Fixed,
   -- Changed CURSOR get_assets_in_k_csr SQL definition
    CURSOR get_assets_in_k_csr (p_qte_id IN NUMBER) IS
      SELECT kle.id asset_id
      FROM   OKC_K_LINES_B    kle,
                  OKC_LINE_STYLES_B LSEB,
             OKL_TRX_QUOTES_B           qte
      WHERE  kle.chr_id = qte.khr_id
        AND kle.STS_CODE <> 'ABANDONED'
 AND KLE.LSE_ID = LSEB.ID
 AND LSEB.LTY_CODE = 'FREE_FORM1'
        AND  qte.id = p_qte_id;

    -- get the assets in the quote
    CURSOR get_assets_in_qte_csr ( p_qte_id IN NUMBER) IS
      SELECT kle.id kle_id
      FROM   OKL_AM_ASSET_LINES_UV kle
      WHERE  kle.qte_id        = p_qte_id;

    -- Get the number of assets for the contract
  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR get_k_assets_no_csr SQL definition
    CURSOR get_k_assets_no_csr ( p_qte_id IN NUMBER) IS
      SELECT COUNT(KLE.id) CONTRACT_ASSETS
      FROM   OKC_K_LINES_B    kle,
                  OKC_LINE_STYLES_B LSEB,
             OKL_TRX_QUOTES_B           qte
      WHERE  kle.chr_id = qte.khr_id
        AND kle.STS_CODE <> 'ABANDONED'
 AND KLE.LSE_ID = LSEB.ID
        AND LSEB.LTY_CODE = 'FREE_FORM1'
        AND  qte.id = p_qte_id;

    -- get the number of assets in the quote
    CURSOR get_q_assets_no_csr ( p_qte_id IN NUMBER) IS
      SELECT COUNT(KLE.id) QUOTE_ASSETS
      FROM   OKL_AM_ASSET_LINES_UV kle
      WHERE  kle.qte_id        = p_qte_id;

    l_trx_id        VARCHAR2(2000);
    l_assets_match  VARCHAR2(1);
    l_k_assets      NUMBER := -999;
    l_q_assets      NUMBER := -9999;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_qte_partial';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_trx_id := WF_ENGINE.GetItemAttrText(
                                 itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'TRANSACTION_ID');

      -- Get number of assets in contract
      OPEN get_k_assets_no_csr ( TO_NUMBER(l_trx_id));
      FETCH get_k_assets_no_csr INTO l_k_assets;
      CLOSE get_k_assets_no_csr;

      -- Get number of assets in quote
      OPEN get_q_assets_no_csr ( TO_NUMBER(l_trx_id));
      FETCH get_q_assets_no_csr INTO l_q_assets;
      CLOSE get_q_assets_no_csr;

      -- If the number of assets in contract does not match with number in qte then qte partial
      IF NVL(l_k_assets,-999) <> NVL(l_q_assets,-9999) THEN

        resultout := 'COMPLETE:QUOTE_PARTIAL';
        RETURN ;

      ELSE

        -- For each asset in quote check if exists in contract
        FOR get_assets_in_qte_rec IN get_assets_in_qte_csr(TO_NUMBER(l_trx_id)) LOOP
           l_assets_match := 'N';
           FOR get_assets_in_k_rec IN get_assets_in_k_csr(TO_NUMBER(l_trx_id)) LOOP
             IF get_assets_in_k_rec.asset_id = get_assets_in_qte_rec.kle_id THEN
               l_assets_match := 'Y';
               EXIT;
             END IF;
           END LOOP;
           -- If any one asset in quote not found in contract then error
           IF l_assets_match = 'N' THEN
             resultout := 'COMPLETE:QUOTE_PARTIAL';
             RETURN ;
           END IF;
        END LOOP;

      END IF;

      resultout := 'COMPLETE:QUOTE_FULL';
      RETURN ;

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        IF get_k_assets_no_csr%ISOPEN THEN
         CLOSE get_k_assets_no_csr;
        END IF;

        IF get_q_assets_no_csr%ISOPEN THEN
         CLOSE get_q_assets_no_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_qte_partial',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_k_assets_no_csr%ISOPEN THEN
         CLOSE get_k_assets_no_csr;
        END IF;

        IF get_q_assets_no_csr%ISOPEN THEN
         CLOSE get_q_assets_no_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_qte_partial',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_qte_partial;

  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_att
  -- Description    : Get and set for pre-proceeds item attributes
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version        : 1.0
  -- History        : PAGARG Bug# 4012492 Issue with message if there are too
  --                : many assets
  -- End of comments
  PROCEDURE pop_pre_proceeds_att(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    -- Cursor to get the pre-proceeds attribute details
    CURSOR okl_pop_pre_proceeds_csr(p_quote_id IN NUMBER) IS
   SELECT K.id,
           K.contract_number,
           Q.last_updated_by,
           Q.created_by
   FROM   OKL_TRX_QUOTES_V        Q,
           OKL_K_HEADERS_FULL_V    K
    WHERE  Q.khr_id = K.id
    AND    Q.id     = p_quote_id;

    --PAGARG Bug# 4012492
    --Modified the cursor to query contract number instead of asset details of quote
    -- cursor to populate approval attributes
    CURSOR okl_approval_quote_csr(p_id IN NUMBER) IS
    SELECT TO_CHAR(sysdate, 'MM-DD-YYYY') system_date,
           TRQ.quote_number               quote_number,
           TRQ.date_effective_to          effective_to,
           QTE.amount                     quote_total,
           OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_TYPE',TRQ.qtp_code,'N') quote_type,
           TRQ.creation_date              quote_creation_date,
           OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_REASON',TRQ.qrs_code,'N') quote_reason,
           OKL_AM_UTIL_PVT.get_chr_currency(TRQ.khr_id) currency,
           TRQ.comments                   comments,
           KHR.contract_number            contract_number,
           TRQ.last_updated_by            last_updated_by
    FROM   OKC_K_HEADERS_B  KHR,
           OKL_TRX_QUOTES_V TRQ,
           (SELECT SUM(NVL(amount,0)) amount, qte_id FROM OKL_TXL_QUOTE_LINES_V GROUP BY qte_id) QTE
    WHERE  KHR.id           = TRQ.khr_id
    AND    QTE.qte_id       = TRQ.id
    AND    TRQ.id           = p_id;

    l_trx_id              NUMBER;
    l_pre_proceeds_rec    okl_pop_pre_proceeds_csr%ROWTYPE;
    l_no_data_found      BOOLEAN;
    l_user                WF_USERS.NAME%TYPE;
    l_message             VARCHAR2(30000);
    l_header_done         BOOLEAN := FALSE;
    l_updated_by          NUMBER;
    l_comments            VARCHAR2(30000);
    l_requestor           VARCHAR2(200);
    l_description         VARCHAR2(200);
    l_formatted_qte_tot   VARCHAR2(2000);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_trx_id := WF_ENGINE.GetItemAttrText(
                                 itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'TRANSACTION_ID');

      OPEN  okl_pop_pre_proceeds_csr(l_trx_id);
     FETCH okl_pop_pre_proceeds_csr INTO l_pre_proceeds_rec;
     CLOSE okl_pop_pre_proceeds_csr;

      -- Set the contract details to the item attributes of WF
      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CONTRACT_ID',
                                avalue   => l_pre_proceeds_rec.id);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CONTRACT_NUMBER',
                                avalue   => l_pre_proceeds_rec.contract_number);

      -- MDOKAL, 21-MAR-2003 Bug 2862254
      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'MESSAGE_DOC',
                              avalue   => 'plsql:okl_am_quotes_wf.pop_oklamppt_doc/'||itemkey);

      -- get the requestor
      OKL_AM_WF.GET_NOTIFICATION_AGENT(
           itemtype        => itemtype,
           itemkey         => itemkey,
           actid           => actid,
           funcmode        => funcmode,
           p_user_id       => l_pre_proceeds_rec.last_updated_by,
           x_name          => l_requestor,
           x_description   => l_description);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REQUESTER',
                                avalue   => l_requestor);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'WF_ADMINISTRATOR',
                                avalue   => l_requestor);

      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CREATED_BY',
                                avalue   => l_pre_proceeds_rec.last_updated_by);

      ---OKL AM Termination Quote Pre-Proceeds
      WF_ENGINE.SetItemAttrText (
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'TRX_TYPE_ID',
                                avalue   => 'OKLAMPPT');

      -- Set the Quote ID
      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'QUOTE_ID',
                                avalue   => l_trx_id);

      /*  MESSAGE

      Quote Number: <<Quote Number>>
      Quote Type: <<Quote Type>>
      Quote Effective To Date: <<Effective To>>
      Total: <<Quote Total>> <<Currency>>

      A PreProceeds Termination was requested for contract <<Contract Number>> on
      <<Quote Creation Date>> for the following reason: <<Quote Reason>>.

      -----------------------------------------------------------------------------
      Asset Number   |   Asset Description  |  Model         |   Serial Number    |
      -----------------------------------------------------------------------------
      <<Asset Number>> <<Asset Description>> <<Model Number>> <<Serial Number>>  |
      -----------------------------------------------------------------------------

      Comments:
      <<Comments>>
     */

      -- PAGARG Bug# 4012492
      -- message is now changed and will not have asset details
      --build message
      FOR l_quote_rec in okl_approval_quote_csr(l_trx_id) LOOP

        IF NOT l_header_done THEN

          l_formatted_qte_tot :=  OKL_ACCOUNTING_UTIL.format_amount(
                                                        l_quote_rec.quote_total,
                                                        l_quote_rec.currency);
          l_message  :=
                      '<p>Quote Number: '||l_quote_rec.quote_number||'<br>'||
                      'Quote Type: '||l_quote_rec.quote_type||'<br>'||
                      'Quote Effective To Date: '||l_quote_rec.effective_to||'<br>'||
                      'Total: '||l_formatted_qte_tot|| ' ' ||l_quote_rec.currency|| '<br></p>'||
                      '<p> A PreProceeds Termination was requested for contract '||
                      l_quote_rec.contract_number||' on '||l_quote_rec.quote_creation_date||
                      ' for the following reason: '||l_quote_rec.quote_reason||'<br>'||'</p>';

           l_header_done := TRUE;
           l_comments    := l_quote_rec.comments;
        END IF;

      END LOOP;

      IF l_header_done THEN
         --PAGARG Bug# 4012492
         l_message  := l_message||'<p>Comments:<br>'||
                       l_comments||'</p>';
      ELSE
         l_message := '';
      END IF;

      -- Set the message
      WF_ENGINE.SetItemAttrText (
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'MESSAGE_DESCRIPTION',
                                avalue   => l_message);
      resultout := 'COMPLETE:Y';

      RETURN ;

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

	IF okl_pop_pre_proceeds_csr%ISOPEN THEN
           CLOSE okl_pop_pre_proceeds_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_att',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pop_pre_proceeds_att;


  -- Start of comments
  --
  -- Procedure Name : reset_pre_proceeds_att
  -- Description   : Reset Pre/Post Proceeds attributes from quote_id
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE reset_pre_proceeds_att(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    l_quote_id NUMBER;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'reset_pre_proceeds_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- Get the Quote ID
      l_quote_id := WF_ENGINE.GetItemAttrNumber(
                                 itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'QUOTE_ID');

      -- Set the Transaction ID
      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID',
                                avalue   => l_quote_id);

      -- Set the EMAIL_ADDRESS to NULL
      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'EMAIL_ADDRESS',
                                avalue   => NULL);

      -- Set the other parameters
      pop_pre_proceeds_att(
                  itemtype => itemtype,
                  itemkey   => itemkey,
                  actid    => actid,
                 funcmode => funcmode,
                  resultout => resultout);

      resultout := 'COMPLETE:Y';

      RETURN ;

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN
             IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'reset_pre_proceeds_att',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END reset_pre_proceeds_att;

  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_qte_approved
  -- Description   : Gets the transaction_id which in this case is Quote_Id and
  --                  checks if quote sent for approval was approved or not
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_qte_approved(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS


    l_approved_yn   VARCHAR2(1) := 'N';

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_qte_approved';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- Get the approved_yn flag
      l_approved_yn := WF_ENGINE.GetItemAttrText(
                                 itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'APPROVED_YN');

      -- if the approval request was approved then approved else rejected
      IF l_approved_yn = 'Y' THEN
        resultout := 'COMPLETE:APPROVAL_APPROVED';
      ELSE
        resultout := 'COMPLETE:APPROVAL_REJECTED';
      END IF;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
             IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

	WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_qte_approved',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_qte_approved;


  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_noti_att
  -- Description   : Get and set for quote and contract details to notify
  --                  requestor to split contract
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE pop_pre_proceeds_noti_att(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    -- Get the asset details for the contract
--start changed by abhsaxen for Bug#6174484
    CURSOR get_assets_in_k_csr (p_qte_id IN NUMBER) IS
	SELECT okhv.contract_number contract_number,
	  clet.item_description asset_description,
	  clet.name asset_number,
	  oalv.serial_number serial_number,
	  oalv.model_number model_number
	FROM okc_k_lines_b cleb,
	  okc_k_lines_tl clet,
	  okx_asset_lines_v oalv,
	  okc_k_headers_all_b okhv,
	  okc_line_styles_b lsev,
	  okl_trx_quotes_all_b trq
	WHERE cleb.id = oalv.parent_line_id(+)
	 AND cleb.chr_id = okhv.id
	 AND cleb.lse_id = lsev.id
	 AND lsev.lty_code = 'FREE_FORM1'
	 AND cleb.chr_id = trq.khr_id
	 AND cleb.id = clet.id
	 AND clet.LANGUAGE = userenv('LANG')
	 AND cleb.sts_code <> 'ABANDONED'
	 AND trq.id = p_qte_id;

--end changed by abhsaxen for Bug#6174484

    -- get the asset details for the quote
--start changed by abhsaxen for Bug#6174484
    CURSOR get_assets_in_qte_csr ( p_qte_id IN NUMBER) IS
	SELECT otqv.quote_number quote_number,
	  clet.item_description asset_description,
	  clet.name asset_number,
	  oalv.serial_number serial_number,
	  oalv.model_number model_number
	FROM okl_trx_quotes_b otqv,
	  okl_txl_qte_lines_all_b tql,
	  okc_k_lines_b cleb,
	  okc_k_lines_tl clet,
	  okx_asset_lines_v oalv,
	  okc_line_styles_b lsev
	WHERE otqv.id = p_qte_id
	 AND tql.kle_id = cleb.id
	 AND otqv.id = tql.qte_id
	 AND tql.qlt_code = 'AMCFIA'
	 AND cleb.id = oalv.parent_line_id(+)
	 AND cleb.lse_id = lsev.id
	 AND lsev.lty_code = 'FREE_FORM1'
	 AND cleb.id = clet.id
	 AND clet.LANGUAGE = userenv('LANG')
	 AND cleb.sts_code <> 'ABANDONED';
--end changed by abhsaxen for Bug#6174484

    get_assets_in_k_rec     get_assets_in_k_csr%ROWTYPE;
    get_assets_in_qte_rec   get_assets_in_qte_csr%ROWTYPE;
    l_qte_id                VARCHAR2(2000);
    l_message               VARCHAR2(32000);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_noti_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


  /*  MESSAGE

   The contract <<Contract Number>> assets does not match the quote <<Quote Number>> assets.
   Please split the contract so that the contract assets match the quote assets.

   Contract Assets:
   -----------------------------------------------------------------------------
   Asset Number       Asset Description     Model            Serial Number
   -----------------------------------------------------------------------------
   <<K Asset Number>><<K Asset Description>><<K Model Number>><<K Serial Number>>
   -----------------------------------------------------------------------------

   Quote Assets:
   -----------------------------------------------------------------------------
   Asset Number       Asset Description     Model            Serial Number
   -----------------------------------------------------------------------------
   <<Q Asset Number>><<Q Asset Description>><<Q Model Number>><<Q Serial Number>>
   -----------------------------------------------------------------------------

  */

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- get the quote id
      l_qte_id := WF_ENGINE.GetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

      --build message
      OPEN  get_assets_in_k_csr(TO_NUMBER(l_qte_id));
      FETCH get_assets_in_k_csr INTO get_assets_in_k_rec;
      CLOSE get_assets_in_k_csr;

      OPEN  get_assets_in_qte_csr(TO_NUMBER(l_qte_id));
      FETCH get_assets_in_qte_csr INTO get_assets_in_qte_rec;
      CLOSE get_assets_in_qte_csr;


      l_message  := '<p>The contract '|| get_assets_in_k_rec.contract_number
                    ||' assets does not match the quote '|| get_assets_in_qte_rec.quote_number
                    ||' assets.</p> '
                    ||'<p>Please split the contract so that the contract assets '
                    ||'match the quote assets.</p>';


      l_message  :=   l_message||'<p>Contract Assets:</p><p>'||
                      '<table width="50%" border="1">'||
                      '<tr>'||
                      '<td><b>Asset Number</b></td>'||
                      '<td><b>Asset Description</b></td>'||
                      '<td><b>Model</b></td>'||
                      '<td><b>Serial Number</b></td>'||
                      '</tr>';

      FOR get_assets_in_k_rec in get_assets_in_k_csr(TO_NUMBER(l_qte_id)) LOOP

        l_message  :=  l_message||'<tr>'||
                                  '<td>'||get_assets_in_k_rec.asset_number||'</td>'||
                                  '<td>'||get_assets_in_k_rec.asset_description||'</td>'||
                                  '<td>'||get_assets_in_k_rec.model_number||'</td>'||
                                  '<td>'||get_assets_in_k_rec.serial_number||'</td>'||
                                  '</tr>';
      END LOOP;

      l_message  :=   l_message||'</table></p>';

      l_message  :=   l_message||'<p>Quote Assets:</p><p>'||
                      '<table width="50%" border="1">'||
                      '<tr>'||
                      '<td><b>Asset Number</b></td>'||
                      '<td><b>Asset Description</b></td>'||
                      '<td><b>Model</b></td>'||
                      '<td><b>Serial Number</b></td>'||
                      '</tr>';

      FOR get_assets_in_qte_rec in get_assets_in_qte_csr(TO_NUMBER(l_qte_id)) LOOP

        l_message  :=  l_message||'<tr>'||
                                  '<td>'||get_assets_in_qte_rec.asset_number||'</td>'||
                                  '<td>'||get_assets_in_qte_rec.asset_description||'</td>'||
                                  '<td>'||get_assets_in_qte_rec.model_number||'</td>'||
                                  '<td>'||get_assets_in_qte_rec.serial_number||'</td>'||
                                  '</tr>';
      END LOOP;

      l_message  := l_message||'</table></p>';

      -- Set the message
      WF_ENGINE.SetItemAttrText (
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'MESSAGE_DESCRIPTION',
                                avalue   => l_message);

      resultout := 'COMPLETE:Y';

      RETURN ;

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF get_assets_in_k_csr%ISOPEN THEN
           CLOSE get_assets_in_qte_csr;
        END IF;
        IF get_assets_in_k_csr%ISOPEN THEN
           CLOSE get_assets_in_qte_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_noti_att',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pop_pre_proceeds_noti_att;


  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_app_att
  -- Description    : Get and set for pre-proceeds item attributes for approval
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version        : 1.0
  -- History        : PAGARG Bug# 4012492 Issue with message if there are too
  --                : many assets
  -- End of comments
  PROCEDURE pop_pre_proceeds_app_att(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    --PAGARG Bug# 4012492
    --Modified the cursor to query contract number instead of asset details of quote
    -- cursor to populate approval attributes
    CURSOR okl_approval_quote_csr(p_id IN NUMBER) IS
    SELECT TO_CHAR(sysdate, 'MM-DD-YYYY') system_date,
           TRQ.quote_number               quote_number,
           TRQ.date_effective_to          effective_to,
           QTE.amount                     quote_total,
           OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_TYPE',TRQ.qtp_code,'N') quote_type,
           TRQ.creation_date              quote_creation_date,
           OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_REASON',TRQ.qrs_code,'N') quote_reason,
           OKL_AM_UTIL_PVT.get_chr_currency(TRQ.khr_id) currency,
           KHR.contract_number            contract_number,
           TRQ.comments                   comments,
           TRQ.last_updated_by            last_updated_by
    FROM   OKC_K_HEADERS_B   KHR,
           OKL_TRX_QUOTES_V  TRQ,
           (SELECT SUM(NVL(amount,0)) amount, qte_id FROM OKL_TXL_QUOTE_LINES_V GROUP BY qte_id) QTE
    WHERE  KHR.id            = TRQ.khr_id
    AND    QTE.qte_id        = TRQ.id
    AND    TRQ.id            = p_id;

    l_trx_id              NUMBER;
    l_message             VARCHAR2(30000);
    l_header_done         BOOLEAN := FALSE;
    l_comments            VARCHAR2(2000);
    l_formatted_qte_tot   VARCHAR2(2000);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_app_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_trx_id := WF_ENGINE.GetItemAttrText(
                                 itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'TRANSACTION_ID');

      /*  MESSAGE

      Quote Number: <<Quote Number>>
      Quote Type: <<Quote Type>>
      Quote Effective To Date: <<Effective To>>
      Total: <<Quote Total>> <<Currency>>

      A PreProceeds Termination was requested for contract <<Contract Number>> on
      <<Quote Creation Date>> for the following reason: <<Quote Reason>>.

      -----------------------------------------------------------------------------
      Asset Number   |   Asset Description  |  Model         |   Serial Number    |
      -----------------------------------------------------------------------------
      <<Asset Number>> <<Asset Description>> <<Model Number>> <<Serial Number>>  |
      -----------------------------------------------------------------------------

     Comments:
     <<Comments>>

     */

      --PAGARG Bug# 4012492 message is now changed, no assets displayed
      --build message
      FOR okl_approval_quote_rec in okl_approval_quote_csr(l_trx_id) LOOP

        IF NOT l_header_done THEN

          l_formatted_qte_tot :=  OKL_ACCOUNTING_UTIL.format_amount(
                                                        okl_approval_quote_rec.quote_total,
                                                        okl_approval_quote_rec.currency);
          l_message  :=
                      '<p>Quote Number: '||okl_approval_quote_rec.quote_number||'<br>'||
                      'Quote Type: '||okl_approval_quote_rec.quote_type||'<br>'||
                      'Quote Effective To Date: '||okl_approval_quote_rec.effective_to||'<br>'||
                      'Total: '||l_formatted_qte_tot||' '|| okl_approval_quote_rec.currency|| '<br></p>'||
                      '<p> A PreProceeds Termination was requested for contract '||
                      okl_approval_quote_rec.contract_number||' on '||okl_approval_quote_rec.quote_creation_date||
                      ' for the following reason: '||okl_approval_quote_rec.quote_reason||'<br>'||'</p>';

           l_header_done := TRUE;
           l_comments    := okl_approval_quote_rec.comments;
        END IF;

      END LOOP;

      IF l_header_done THEN
         --PAGARG Bug# 4012492
         l_message  := l_message||'<p>Comments:<br>'||
                       l_comments||'</p>';
      ELSE
         l_message := '';
      END IF;

      -- Set the message
      WF_ENGINE.SetItemAttrText (
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'MESSAGE_DESCRIPTION',
                                avalue   => l_message);
      resultout := 'COMPLETE:Y';

      RETURN ;

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN
             IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_app_att',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pop_pre_proceeds_app_att;


  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_doc_att
  -- Description   : Sets the message for notification to requestor for
  --                  documentation followup
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE pop_pre_proceeds_doc_att(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    -- get the quote details
    CURSOR l_message_csr ( p_qte_id IN NUMBER) IS
      SELECT   TO_CHAR(SYSDATE, 'DD-MON-RRRR') SYSTEM_DATE,
               OTQ.QUOTE_NUMBER QUOTE_NUMBER,
               TO_CHAR(OTQ.DATE_EFFECTIVE_TO, 'DD-MON-RRRR') EFFECTIVE_TO,
               OKL_ACCOUNTING_UTIL.format_amount(SUM(NVL(OTL.AMOUNT,0)),OKL_AM_UTIL_PVT.get_chr_currency(OTQ.KHR_ID))||' '||OKL_AM_UTIL_PVT.get_chr_currency(OTQ.KHR_ID) QUOTE_TOTAL,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_REASON',OTQ.qrs_code,'N')QUOTE_REASON ,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_TYPE',OTQ.qtp_code,'N') QUOTE_TYPE,
               TO_CHAR(OTQ.CREATION_DATE, 'DD-MON-RRRR') QUOTE_CREATION_DATE,
               KHR.CONTRACT_NUMBER CONTRACT_NUMBER,
               OTQ.comments COMMENTS
      FROM     OKL_TRX_QUOTES_V        OTQ,
               OKL_TXL_QUOTE_LINES_B   OTL,
               OKC_K_HEADERS_V         KHR
      WHERE    OTQ.ID          = p_qte_id
      AND      OTQ.ID          = OTL.QTE_ID
      AND      KHR.ID          = OTQ.KHR_ID
      GROUP BY TO_CHAR(SYSDATE, 'DD-MON-RRRR'),
               OTQ.QUOTE_NUMBER,
               OTQ.DATE_EFFECTIVE_TO,
               OTQ.QST_CODE,
               OTQ.CREATION_DATE,
               OTQ.QRS_CODE,
               KHR.CONTRACT_NUMBER,
               OTQ.KHR_ID,
               OTQ.QTP_CODE,
               OTQ.COMMENTS;

    l_message_rec l_message_csr%ROWTYPE;
    l_trx_id      NUMBER;
    l_message     VARCHAR2(30000);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_doc_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_trx_id := WF_ENGINE.GetItemAttrText(
                                 itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'TRANSACTION_ID');

      --build message
     OPEN  l_message_csr(l_trx_id);
     FETCH l_message_csr INTO l_message_rec;
     CLOSE l_message_csr;

      /*  MESSAGE

      Quote Number: <<Quote Number>>
      Quote Type: <<Quote Type>>
      Quote Effective To Date: <<Effective To>>
      Total: <<Quote Total>> <<Currency>>

      The Termination Quote was requested for Contract <<Contract Number>> on
      <<Quote Creation Date>> for the following reason: <<Quote Reason>>.

      Please respond to this notification upon receipt of pre-proceeds documentation.

      Comments:
      <<Comments>>
     */


      l_message  := '<p>Quote Number:'||l_message_rec.quote_number||'<br>'||
                    'Quote Type:'||l_message_rec.quote_type||'<br>'||
                    'Quote Effective To Date:'||l_message_rec.effective_to||'<br>'||
                    'Total:'||l_message_rec.quote_total||'<br>'||
                    '<p>The Termination Quote was requested for Contract '||l_message_rec.contract_number||' on<br>'||
                    l_message_rec.quote_creation_date||' for the following reason: '||l_message_rec.quote_reason||'.</p>'||
                    '<p>Please respond to this notification upon receipt of pre-proceeds documentation.</p>'||
                    '<p>Comments:<br>'||
                    l_message_rec.comments||'</p>';


      -- Set the message
      WF_ENGINE.SetItemAttrText (
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'MESSAGE_DESCRIPTION',
                                avalue   => l_message);

      resultout := 'COMPLETE:Y';

      RETURN ;

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;



   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF l_message_csr%ISOPEN THEN
          CLOSE l_message_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_doc_att',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pop_pre_proceeds_doc_att;


  -- Start of comments
  --
  -- Procedure Name : pre_proceeds_trmnt_contract
  -- Description   : Makes call to terminate contract api. gets the values need
  --                  to be passed to terminate contract and sets the terminate
  --                  contract input parameters
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  -- History        : RMUNJULU 02-JAN-03 2699412 Set the okc context
  --
  -- End of comments
  PROCEDURE pre_proceeds_trmnt_contract(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    SUBTYPE term_rec_type IS OKL_AM_LEASE_LOAN_TRMNT_PUB.term_rec_type;
    SUBTYPE tcnv_rec_type IS OKL_AM_LEASE_LOAN_TRMNT_PUB.tcnv_rec_type;

    -- Cursor to get the quote details
    CURSOR get_qte_details_csr( p_qte_id IN NUMBER)  IS
      SELECT qtp_code,
             qrs_code
      FROM   OKL_TRX_QUOTES_V
      WHERE  id = p_qte_id;

    l_term_rec                       term_rec_type;
    l_tcnv_rec                       tcnv_rec_type;

    l_contract_id                    NUMBER;
    l_contract_number                OKL_K_HEADERS_FULL_V.contract_number%TYPE;
    l_termination_date               DATE;
    lx_msg_count                     NUMBER;
    lx_msg_data                      VARCHAR2(2000);
    l_return_status                  VARCHAR2(1);
    l_api_version                    NUMBER := 1;
    l_qte_id                         NUMBER;
    l_qtp_code                       VARCHAR2(200);
    l_qrs_code                       VARCHAR2(200);
    l_org_id                         NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pre_proceeds_trmnt_contract';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      -- Get the values for term_rec before calling the terminate contract api
      l_qte_id := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'TRANSACTION_ID');

      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      l_contract_number := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_NUMBER');

      SELECT SYSDATE INTO l_termination_date FROM DUAL;

      -- Get the org id for the contract
      l_org_id := OKL_AM_UTIL_PVT.get_chr_org_id(l_contract_id);

      -- Set the contract org id to the application
      --DBMS_APPLICATION_INFO.set_client_info (l_org_id);
      MO_GLOBAL.set_policy_context ('S', l_org_id); -- Bug 6140786


      -- RMUNJULU 02-JAN-03 2699412 Set the okc context
      OKL_CONTEXT.set_okc_org_context(p_chr_id => l_contract_id);


      OPEN  get_qte_details_csr(l_qte_id);
      FETCH get_qte_details_csr INTO l_qtp_code, l_qrs_code;
      CLOSE get_qte_details_csr;

      -- set the term_rec_type of terminate contract
      l_term_rec.p_contract_id          :=    l_contract_id;
      l_term_rec.p_contract_number      :=    l_contract_number;
      l_term_rec.p_termination_date     :=    l_termination_date;
      l_term_rec.p_control_flag         :=    'TRMNT_QUOTE_UPDATE';
      l_term_rec.p_quote_id             :=    l_qte_id;
      l_term_rec.p_quote_type           :=    l_qtp_code;
      l_term_rec.p_quote_reason         :=    l_qrs_code;

      l_tcnv_rec.id                     :=    OKL_API.G_MISS_NUM;

      -- Call the terminate contract api
      OKL_AM_LEASE_LOAN_TRMNT_PUB.lease_loan_termination (
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKL_API.G_TRUE,
           x_return_status                => l_return_status,
           x_msg_count                    => lx_msg_count,
           x_msg_data                     => lx_msg_data,
           p_term_rec                     => l_term_rec,
           p_tcnv_rec                     => l_tcnv_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      ELSE
        resultout := 'COMPLETE:Y';
      END IF;
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN G_EXCEPTION THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        IF get_qte_details_csr%ISOPEN THEN
          CLOSE get_qte_details_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pre_proceeds_trmnt_contract',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_qte_details_csr%ISOPEN THEN
          CLOSE get_qte_details_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pre_proceeds_trmnt_contract',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pre_proceeds_trmnt_contract;


  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_serv_maint
  -- Description   : Checks if service and maintainance needed
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_serv_maint(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

     -- Get the total number of service lines
     CURSOR get_service_lines_csr ( p_khr_id IN NUMBER) IS
       SELECT  COUNT(OKLV.id)
       FROM    OKC_K_LINES_V       OKLV,
               OKC_LINE_STYLES_V   OLSV
       WHERE   OKLV.chr_id   = p_khr_id
       AND     OKLV.lse_id   = OLSV.id
       AND     OLSV.lty_code = 'SOLD_SERVICE'
       AND     OKLV.end_date > SYSDATE;

     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_contract_id             NUMBER;
     l_no_of_recipients        NUMBER := 0;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_serv_maint';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      -- Get the values for term_rec before checking rule
      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      OPEN  get_service_lines_csr (l_contract_id);
      FETCH get_service_lines_csr INTO l_no_of_recipients;
      CLOSE get_service_lines_csr;

      IF l_no_of_recipients IS NOT NULL AND l_no_of_recipients > 0 THEN
        resultout := 'COMPLETE:Y';
      ELSE
        resultout := 'COMPLETE:N';
      END IF;

      RETURN;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        IF get_service_lines_csr%ISOPEN THEN
          CLOSE get_service_lines_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_serv_maint',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_service_lines_csr%ISOPEN THEN
          CLOSE get_service_lines_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_serv_maint',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_serv_maint;

  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_serv_maint
  -- Description   : Populate the item attributes for service and maintenance
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE pop_pre_proceeds_serv_maint(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_contract_id             NUMBER;
     l_no_of_service_lines     NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_serv_maint';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

   BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RECIPIENT_ID',
                                avalue   => '0'); -- intialize

      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CURRENT_REC_ID',
                                avalue   => 0); -- intialized to 0

  --12/20/06 rkuttiya changed recipient type to VENDOR
      /*WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RECIPIENT_TYPE',
                                avalue   => 'V'); -- always  for Service and Maintenance */
       WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'RECIPIENT_TYPE',
                                      avalue   => 'VENDOR');

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PROCESS_CODE',
                                avalue   => 'AMQSM'); -- for Service and Maintenance

      resultout := 'COMPLETE:Y';
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_serv_maint',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pop_pre_proceeds_serv_maint;


  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_serv_noti
  -- Description   : Checks if service and maintenance request sent to all vendors
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_serv_noti(
                                itemtype  IN  VARCHAR2,
                                itemkey   IN  VARCHAR2,
                                actid     IN  NUMBER,
                                funcmode  IN  VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2) IS

     -- Get the details of service providers for the provided service line
     -- Select all the providers (lines) for the contract which have not been notified
  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR get_serv_prov_dtl_csr SQL definition
     CURSOR get_serv_prov_dtl_csr ( p_khr_id          IN NUMBER,
                                    p_current_rec_id  IN NUMBER) IS
       SELECT OKLB.id                    line_id,
              OKPB.object1_id1           party_id
       FROM   OKC_K_PARTY_ROLES_B  OKPB,
              OKC_K_LINES_B        OKLB,
              OKC_LINE_STYLES_B    OLSB,
       FND_LOOKUPS FNDV
       WHERE  OKLB.chr_id = p_khr_id
       AND    OKLB.id > NVL(p_current_rec_id,0)
       AND    OKPB.dnz_chr_id = OKLB.dnz_chr_id
       AND    OKPB.cle_id = OKLB.id
       AND    OKLB.lse_id = OLSB.id
       AND    OLSB.lty_code = 'SOLD_SERVICE'
       AND    OKLB.end_date > SYSDATE
       AND    FNDV.lookup_type = 'OKC_ROLE'
       AND    OKPB.RLE_CODE = FNDV.lookup_code
       ORDER BY OKLB.id ASC;


     l_contract_id      NUMBER;
     l_current_rec_id   NUMBER;
     l_recipient_id     VARCHAR2(200);
     l_total_no_of_recp NUMBER;
     l_line_id          NUMBER;

  --12/20/06 rkuttiya added for XMLP Project
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
  --get the recipient email address
    CURSOR c_recipient(p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = p_recipient_id;

  -- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;
    l_from_email      VARCHAR2(100);
    l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_to_email        VARCHAR2(100);
  -- ansethur 26-jul-2007 R12B XMLP start changes
    l_agent_id               NUMBER;
    l_quote_id               VARCHAR2(200);
    l_vendor_id              number;

    -- Check quote exists
    CURSOR  get_agent_id_csr  ( p_qte_id   IN VARCHAR2)
    IS
    SELECT  a.LAST_UPDATED_BY LAST_UPDATED_BY
    FROM    OKL_TXL_QUOTE_LINES_V a
    WHERE   a.qte_id = to_number(p_qte_id);

     CURSOR c_vendor(p_vendor_id IN NUMBER)
     IS
     select party_id
     from ap_suppliers
     where vendor_id = p_vendor_id;
  -- ansethur 26-jul-2007 R12B XMLP end changes
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_serv_noti';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      l_current_rec_id := WF_ENGINE.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CURRENT_REC_ID');

      -- gets the first provider line of the cursor each time
      OPEN  get_serv_prov_dtl_csr (l_contract_id, l_current_rec_id);
      FETCH get_serv_prov_dtl_csr INTO l_line_id, l_recipient_id;
      CLOSE get_serv_prov_dtl_csr;

      IF l_line_id IS NULL THEN -- no more providers(lines)
       resultout := 'COMPLETE:NOTIFY_COMPLETE';
         RETURN;
     ELSE
       resultout := 'COMPLETE:NOTIFY_OUTSTANDING';
      END IF;

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'RECIPIENT_ID',
                                avalue   => l_recipient_id);
   --12/20/06 rkuttiya aadded for XMLP Project
   --get the email address of the recipient
  -- ansethur 30-jul-2007 R12B XMLP start changes
      OPEN c_vendor(l_recipient_id);
      FETCH c_vendor INTO  l_vendor_id;
      CLOSE c_vendor;

      OPEN c_recipient(l_vendor_id);
      FETCH c_recipient INTO l_to_email;
      CLOSE c_recipient;
  -- ansethur 30-jul-2007 R12B XMLP start changes
   -- set the email address attribute
       WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'EMAIL_ADDRESS',
                                avalue   => l_to_email);

      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CURRENT_REC_ID',
                                avalue   => l_line_id);
      -- Since the Fulfillment query take p_id which is transaction id
      -- set transaction id to line id
      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TRANSACTION_ID',
                                avalue   => l_line_id);
  -- ansethur 26-jul-2007 R12B XMLP start changes
     l_quote_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'QUOTE_ID');

      OPEN get_agent_id_csr(l_quote_id);
      FETCH get_agent_id_csr INTO l_agent_id;
      CLOSE get_agent_id_csr;

      OPEN c_agent_csr(l_agent_id);
      FETCH c_agent_csr INTO l_from_email;
      CLOSE c_agent_csr;

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'FROM_ADDRESS',
                                avalue   => l_from_email);

  -- ansethur 26-jul-2007 R12B XMLP end changes
      -- Initialize the message stack
--      OKL_API.init_msg_list('T');

--  12/20/06 rkuttiya added for XMLP Project
 --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_LINE_ID';
          l_xmp_rec.param_value := l_line_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );
           IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             RAISE ERR;
           END IF;


           IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                  l_batch_id := lx_xmp_rec.batch_id;
                  wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                              itemkey => itemkey,
                                              aname   => 'BATCH_ID',
                                              avalue  => l_batch_id );
                     --    resultout := 'COMPLETE:SUCCESS'; commented by ansethur 26-jul-2007 for XMLP
           ELSE
                   resultout := 'COMPLETE:ERROR';
           END IF;

      RETURN;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_serv_prov_dtl_csr%ISOPEN THEN
         CLOSE get_serv_prov_dtl_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_serv_noti',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_serv_noti;


  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_bill_of_sale
  -- Description   : Checks if bill of sale rule exists
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  -- History         :  RMUNJULU 11-FEB-03 2797035 Changed TRUE to FALSE for msg
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_bill_of_sale(
                                itemtype IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
           actid    IN  NUMBER,
           funcmode IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2) IS


     l_rulv_rec              OKL_RULE_PUB.rulv_rec_type;
     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_rule_found              VARCHAR2(1) := 'N';
     l_contract_id             NUMBER;
     l_contract_number         OKL_K_HEADERS_FULL_V.contract_number%TYPE;

    l_id            NUMBER;
    l_rule_khr_id   NUMBER;
    l_qtp_code      VARCHAR2(30);
    l_qtev_rec      okl_trx_quotes_pub.qtev_rec_type;
    l_rgd_code      VARCHAR2(30);

    -- Get the quote khr_id
    CURSOR c_qte_csr(c_id NUMBER) IS
    SELECT  khr_id, qtp_code
    FROM    OKL_TRX_QUOTES_B
    WHERE   id = c_id;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_bill_of_sale';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- Get the values for term_rec before checking rule
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                           itemkey => itemkey,
                                           aname   => 'TRANSACTION_ID');

        OPEN c_qte_csr(l_id);
        FETCH c_qte_csr INTO l_contract_id, l_qtp_code;
        CLOSE c_qte_csr;

        l_qtev_rec.khr_id := l_contract_id;
        l_qtev_rec.qtp_code := l_qtp_code;
        l_rule_khr_id := okl_am_util_pvt.get_rule_chr_id (l_qtev_rec);
        IF l_qtp_code LIKE 'TER_RECOURSE%' THEN
                l_rgd_code := 'AVTQPR';
        ELSE
                l_rgd_code := 'AMTQPR';
        END IF;

      -- Call the util api to get the rule info for service and maintenance rule
      OKL_AM_UTIL_PVT.get_rule_record(
        p_rgd_code => l_rgd_code, -- Rule Grp :Termination Quote Process
        p_rdf_code => 'AMFBOS', -- Rule Code:AM Bill of Sale Requirement
        p_chr_id => l_rule_khr_id,
        p_cle_id => NULL,
        x_rulv_rec => l_rulv_rec,
        x_return_status => l_return_status,
        p_message_yn => FALSE); -- RMUNJULU 11-FEB-03 2797035 Changed TRUE to FALSE

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
           END IF;

      IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        IF NVL (l_rulv_rec.rule_information1, '*') = 'Y' THEN
          l_rule_found := 'Y';
        END IF;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
        l_rule_found    := 'N';
      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      END IF;

      IF l_rule_found = 'Y' THEN
        resultout := 'COMPLETE:Y';
      ELSE
        resultout := 'COMPLETE:N';
      END IF;

    ELSE
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        IF c_qte_csr%ISOPEN THEN
          CLOSE c_qte_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_bill_of_sale',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN
             IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF c_qte_csr%ISOPEN THEN
          CLOSE c_qte_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_bill_of_sale',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_bill_of_sale;


  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_bill_of_sale
  -- Description   : Populate the item attributes for bill of sale
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE pop_pre_proceeds_bill_of_sale(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS


     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_contract_id             NUMBER;
     l_contract_number         OKL_K_HEADERS_FULL_V.contract_number%TYPE;
     l_recipient_type          VARCHAR2(3);
     l_id                      NUMBER;
     l_recipient_code          VARCHAR2(200);
     l_recipient_id            NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_bill_of_sale';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- Get the values for term_rec before checking rule
      l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                         itemkey => itemkey,
                                         aname   => 'TRANSACTION_ID');

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RECIPIENT_ID',
                                avalue   =>  0);

      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CURRENT_REC_ID',
                                avalue   =>  0);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PROCESS_CODE',
                                avalue   => 'AMQBS'); -- for Bill of Sale

      resultout := 'COMPLETE:Y';
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_bill_of_sale',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END pop_pre_proceeds_bill_of_sale;

  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_bill_noti
  -- Description   : Gets the recipients for quote and sets the bill of sale attributes
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_bill_noti(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    -- Get the recipient info for the quote which will be the recipient for bill of sale
--start changed by abhsaxen for Bug#6174484
    CURSOR l_recipient_csr (p_qte_id IN NUMBER, p_current_party_id IN NUMBER) IS
     SELECT qp.party_object1_id1        recipient_id,
            qp.party_jtot_object1_code  recipient_code,
            qp.id                       party_id,
            qp.email_address            email_id
      FROM    okl_quote_parties qp
      WHERE  qp.qte_id= p_qte_id
      AND    qp.id> NVL(p_current_party_id, 0)
      AND    qp.qpt_code LIKE 'RECIPIENT%'
      ORDER BY qp.id ASC;
--end changed by abhsaxen for Bug#6174484
--12/20/06 rkuttiya commented following for XMLP
     --l_recipient_type          VARCHAR2(3);
     l_recipient_type          VARCHAR2(30);
    --
     l_id                      NUMBER;
     l_recipient_code          VARCHAR2(200);
     l_recipient_id            NUMBER;
     l_current_rec_id          NUMBER;
     l_party_id                NUMBER;
     l_email_id                VARCHAR2(2000);

--12/20/06 rkuttiya added for XMLP Project
    l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

   CURSOR c_requestor(p_quote_id IN NUMBER) is
   SELECT a.last_updated_by last_update_by
   FROM okl_txl_quote_lines_v a
   WHERE a.qte_id = p_quote_id;

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    l_requestor_id  NUMBER;

  -- get the sender email address
    CURSOR c_requestor_csr (p_requestor_id NUMBER)
    IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = p_requestor_id;

    l_from_email      VARCHAR2(100);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_bill_noti';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
--
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- Get the values
      l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                         itemkey => itemkey,
                                         aname   => 'TRANSACTION_ID');

      l_current_rec_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                       itemkey => itemkey,
                                                       aname   => 'CURRENT_REC_ID');

      -- Get recipient info
      OPEN  l_recipient_csr ( TO_NUMBER(l_id), l_current_rec_id);
      FETCH l_recipient_csr INTO l_recipient_id, l_recipient_code, l_party_id, l_email_id;
      CLOSE l_recipient_csr;

      IF l_party_id IS NULL THEN -- no more recipients
       resultout := 'COMPLETE:NOTIFY_COMPLETE';
         RETURN;
     ELSE
       resultout := 'COMPLETE:NOTIFY_OUTSTANDING';
      END IF;

      -- Set the recipient type

-- 12/20/06 rkuttiya changed recipient type to Lessee, Vendor as appropriate, for XMLP Project
      IF    UPPER(l_recipient_code) = 'OKX_PARTY'      THEN
         --l_recipient_type := 'P';
           l_recipient_type := 'LESSEE';
      ELSIF UPPER(l_recipient_code) = 'OKX_PARTYSITE'  THEN
        -- l_recipient_type := 'PS';
           l_recipient_type := 'LESSEE';
      ELSIF UPPER(l_recipient_code) = 'OKX_PCONTACT'   THEN
         --l_recipient_type := 'PC';
           l_recipient_type := 'LESSEE';
      ELSIF UPPER(l_recipient_code) = 'OKX_VENDOR'     THEN
         --l_recipient_type := 'V';
           l_recipient_type := 'VENDOR';
      ELSIF UPPER(l_recipient_code) = 'OKX_VENDORSITE' THEN
         --l_recipient_type := 'VS';
           l_recipient_type := 'VENDOR';
      ELSIF UPPER(l_recipient_code) = 'OKX_VCONTACT'   THEN
         --l_recipient_type := 'VC';
           l_recipient_type := 'VENDOR';
      ELSIF UPPER(l_recipient_code) = 'OKX_OPERUNIT'   THEN ---WHAT WILL THIS BE
         --l_recipient_type := 'P';
           l_recipient_type := 'LESSEE';
      ELSE -- default is PARTY
        -- default is LESSEE from R12 onwards, for XMLP Project
        -- l_recipient_type := 'P';
           l_recipient_type := 'LESSEE';

      END IF;

     --12/20/06 rkuttiya added for XMLP Project
     -- get the requestor email
      OPEN c_requestor(l_id);
      FETCH c_requestor INTO l_requestor_id;
      CLOSE c_requestor;

     OPEN c_requestor_csr(l_requestor_id);
     FETCH c_requestor_csr INTO l_from_email;
     CLOSE c_requestor_csr;

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RECIPIENT_ID',
                                avalue   =>  l_recipient_id);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RECIPIENT_TYPE',
                                avalue   => l_recipient_type);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'EMAIL_ADDRESS',
                                avalue   => l_email_id);

--12/20/06 rkuttiya commented for XMLP project
--set the from email address
       WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'FROM_ADDRESS',
                                      avalue   => l_from_email);


      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CURRENT_REC_ID',
                                avalue   => l_party_id);

     --20-Dec-06 rkuttiya added for XMLP Project
     --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_QUOTE_ID';
          l_xmp_rec.param_value := l_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec :'||l_return_status);
           END IF;

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                    avalue  => l_batch_id );
                    --    resultout := 'COMPLETE:SUCCESS'; commented by ansethur for XMLP
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN

	IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF l_recipient_csr%ISOPEN THEN
          CLOSE l_recipient_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_bill_noti',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_bill_noti;

  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_title_filing
  -- Description   : Checks if title filing needed
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  -- History         :  RMUNJULU 11-FEB-03 2797035 Changed TRUE to FALSE for msg
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_title_filing(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

     l_rulv_rec              OKL_RULE_PUB.rulv_rec_type;
     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_rule_found              VARCHAR2(1) := 'N';
     l_contract_id             NUMBER;
     -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      -- Get the values for term_rec before checking rule
      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      -- Call the util api to get the rule info for Title/filing
      OKL_AM_UTIL_PVT.get_rule_record(
      p_rgd_code         => 'LAAFLG', -- Rule Grp
            p_rdf_code         => 'LAFLTL', -- Rule Code
      p_chr_id           => l_contract_id,
      p_cle_id           => NULL,
            x_rulv_rec         => l_rulv_rec,
       x_return_status     => l_return_status,
      p_message_yn       => FALSE);  -- RMUNJULU 11-FEB-03 2797035 Changed TRUE to FALSE

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
           END IF;

      IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        IF  l_rulv_rec.jtot_object1_code IS NOT NULL
        AND l_rulv_rec.object1_id1 IS NOT NULL THEN
          l_rule_found := 'Y';
        END IF;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
        l_rule_found    := 'N';
      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      END IF;

      IF l_rule_found = 'Y' THEN
        resultout := 'COMPLETE:Y';
      ELSE
        resultout := 'COMPLETE:N';
      END IF;

      RETURN;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_title_filing',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_title_filing',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_title_filing;

  -- Start of comments
  --
  -- Procedure Name : pop_pre_proceeds_title_filing
  -- Description   : Populate title filing attributes
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE pop_pre_proceeds_title_filing(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_contract_id             NUMBER;
     l_no_of_recipients        NUMBER;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_pre_proceeds_title_filing';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      -- Get the values for term_rec before checking rule
      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RECIPIENT_ID',
                                avalue   => '0'); -- initialize

      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CURRENT_CLE_ID',
                                avalue   => 0);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PROCESS_CODE',
                                avalue   => 'AMQTF'); -- for Title/Filing

      resultout := 'COMPLETE:Y';
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_pre_proceeds_title_filing',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END pop_pre_proceeds_title_filing;


  -- Start of comments
  --
  -- Procedure Name : chk_pre_proceeds_title_noti
  -- Description   : Populate title filing attributes
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE chk_pre_proceeds_title_noti(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

     -- Get the next asset id for the contract (only financial lines)
     CURSOR get_asset_for_k_csr ( p_khr_id            IN NUMBER,
                                  p_current_asset_id  IN NUMBER) IS
      SELECT  OKLV.id             cle_id
      FROM    OKC_K_LINES_V       OKLV,
              OKC_LINE_STYLES_V   OLSV
      WHERE   OKLV.chr_id   = p_khr_id
      AND     OKLV.id > NVL(p_current_asset_id , 0)
      AND     OKLV.lse_id   = OLSV.id
      AND     OLSV.lty_code = 'FREE_FORM1'
      ORDER BY OKLV.id ASC;


     l_rulv_rec              OKL_RULE_PUB.rulv_rec_type;
     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_rule_found              VARCHAR2(1) := 'N';
     l_contract_id             NUMBER;
     l_current_rec_id          NUMBER;
     l_current_rec_no          NUMBER;
     l_cle_id                  NUMBER;
     l_recipient_type          VARCHAR2(100); -- ansethur 31-jul-2007 modified for XMLP VARCHAR2(3);

 --12/20/06 rkuttiya added for XMLP Project
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
  --get the recipient email address
    CURSOR c_recipient (p_recipient_id IN varchar2)--ansethur 26-jul-2007 XMLP (p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = to_number(p_recipient_id);--ansethur 26-jul-2007 XMLP added to_number

  -- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;
    l_from_email      VARCHAR2(100);
    l_to_email        VARCHAR2(100);

     -- ansethur 26-jul-2007 R12B XMLP start changes to fetch the recipient id
    l_agent_id               NUMBER;
    l_quote_id               NUMBER;

    -- Check quote exists
    CURSOR  get_agent_id_csr  ( p_qte_id   IN NUMBER)
    IS
    SELECT  a.LAST_UPDATED_BY LAST_UPDATED_BY
    FROM    OKL_TXL_QUOTE_LINES_V a
    WHERE   a.qte_id = p_qte_id;
   -- ansethur 26-jul-2007 R12B XMLP End changes
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_pre_proceeds_title_noti';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      -- Get the values for term_rec before checking rule
      l_contract_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CONTRACT_ID');

      l_current_rec_id := WF_ENGINE.GetItemAttrNumber(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'CURRENT_CLE_ID');

      OPEN  get_asset_for_k_csr (l_contract_id, l_current_rec_id);
      FETCH get_asset_for_k_csr INTO l_cle_id;
      CLOSE get_asset_for_k_csr;

      IF l_cle_id IS NULL THEN
       resultout := 'COMPLETE:NOTIFY_COMPLETE';
         RETURN;
     ELSE
       resultout := 'COMPLETE:NOTIFY_OUTSTANDING';
      END IF;

      -- Call the util api to get the rule info for Title/filing
      OKL_AM_UTIL_PVT.get_rule_record(
        p_rgd_code         => 'LAAFLG', -- Rule Grp
        p_rdf_code         => 'LAFLTL', -- Rule Code
        p_chr_id           => l_contract_id,
        p_cle_id           => null, -- ansethur 26-jul-2007 XMLP passed null in place of l_cle_id,
        x_rulv_rec         => l_rulv_rec,
        x_return_status    => l_return_status,
        p_message_yn       => FALSE);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
   END IF;


     --12/20/06 rkuttiya changed recipient type to LESSEE,VENDOR as appropriate for XMLP Project
      -- Set the recipient type
      IF    UPPER(l_rulv_rec.jtot_object1_code) = 'OKX_PARTY'      THEN
         --l_recipient_type := 'P';
           l_recipient_type := 'LESSEE';
      ELSIF UPPER(l_rulv_rec.jtot_object1_code) = 'OKX_PARTYSITE'  THEN
         --l_recipient_type := 'PS';
           l_recipient_type := 'LESSEE';
      ELSIF UPPER(l_rulv_rec.jtot_object1_code) = 'OKX_PCONTACT'   THEN
         --l_recipient_type := 'PC';
           l_recipient_type := 'LESSEE';
      ELSIF UPPER(l_rulv_rec.jtot_object1_code) = 'OKX_VENDOR'     THEN
         --l_recipient_type := 'V';
           l_recipient_type := 'VENDOR';
      ELSIF UPPER(l_rulv_rec.jtot_object1_code) = 'OKX_VENDORSITE' THEN
         --l_recipient_type := 'VS';
           l_recipient_type := 'VENDOR';
      ELSIF UPPER(l_rulv_rec.jtot_object1_code) = 'OKX_VCONTACT'   THEN
         l_recipient_type := 'VC';
         l_recipient_type := 'VENDOR';
      ELSE -- default is PARTY
       -- 12/20/06 rkuttiya added for XMLP, R12 onwards, default is LESSEE
         --l_recipient_type := 'P';
           l_recipient_type := 'LESSEE';
      END IF;

      WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CURRENT_CLE_ID',
                                avalue   => l_cle_id);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'RECIPIENT_ID',
                                avalue   => l_rulv_rec.object1_id1);

      WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'RECIPIENT_TYPE',
                                avalue   => l_recipient_type);

 --12/20/06 rkuttiya aadded for XMLP Project
   --get the email address of the recipient
      OPEN c_recipient(l_rulv_rec.object1_id1);
      FETCH c_recipient INTO l_to_email;
      CLOSE c_recipient;

   -- set the email address attribute
       WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'EMAIL_ADDRESS',
                                  avalue   => l_to_email);



      -- Since the Fulfillment query take p_id which is transaction id
      -- set transaction id to cle id
      WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'TRANSACTION_ID',
                                  avalue   => l_cle_id);
  -- ansethur 26-jul-2007 R12B XMLP start changes
     l_quote_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'QUOTE_ID');

     OPEN get_agent_id_csr(l_quote_id);
      FETCH get_agent_id_csr INTO l_agent_id;
      CLOSE get_agent_id_csr;

      OPEN c_agent_csr(l_agent_id);
      FETCH c_agent_csr INTO l_from_email;
      CLOSE c_agent_csr;
      WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'FROM_ADDRESS',
                                  avalue   => l_from_email);
  -- ansethur 26-jul-2007 R12B XMLP End changes

--  12/20/06 rkuttiya added for XMLP Project
 --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_LINE_ID';
          l_xmp_rec.param_value := l_cle_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec :'||l_return_status);
   END IF;

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                    avalue  => l_batch_id );
                    --    resultout := 'COMPLETE:SUCCESS'; commented by ansethur 26-jul-2007 for XMLP
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_asset_for_k_csr%ISOPEN THEN
          CLOSE get_asset_for_k_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'chk_pre_proceeds_title_noti',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END chk_pre_proceeds_title_noti;


  -- Start of comments
  --
  -- Procedure Name : pop_repurchase_qte_att
  -- Description   : Gets the transaction_id which in this case is Quote_Id and
  --                  Populates the item attributes for the Repurchase Quote WF
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE pop_repurchase_qte_att(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    -- Cursor to get the contract details for the quote
    CURSOR okl_pop_contract_details_csr ( p_quote_id IN NUMBER) IS
      SELECT   K.id,
               K.contract_number,
               Q.last_updated_by
      FROM     OKL_K_HEADERS_FULL_V    K,
               OKL_TRX_QUOTES_V        Q
      WHERE    K.id    = Q.khr_id
      AND      Q.id    = p_quote_id;

    l_transaction_id               VARCHAR2(2000);
    l_k_id                         NUMBER;
    l_created_by                   NUMBER;
    l_k_number                     OKL_K_HEADERS_FULL_V.contract_number%TYPE;

    l_requester           VARCHAR2(200);
    l_description         VARCHAR2(200);
    l_requester_id        NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_repurchase_qte_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --get attr for transaction id
    l_transaction_id := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'TRANSACTION_ID');

    -- From the cursor get the contract details
    OPEN  okl_pop_contract_details_csr(TO_NUMBER(l_transaction_id));
    FETCH okl_pop_contract_details_csr INTO l_k_id, l_k_number, l_requester_id;
    CLOSE okl_pop_contract_details_csr;

    -- Set the contract details to the item attributes of WF
    WF_ENGINE.SetItemAttrNumber(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CONTRACT_ID',
                                avalue   => l_k_id);

    WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CONTRACT_NUMBER',
                                avalue   => l_k_number);

    -- get the requestor
    OKL_AM_WF.GET_NOTIFICATION_AGENT(
           itemtype        => itemtype,
           itemkey         => itemkey,
           actid           => actid,
           funcmode        => funcmode,
           p_user_id       => l_requester_id,
           x_name          => l_requester,
           x_description   => l_description);

    WF_ENGINE.SetItemAttrText(
                                itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'WF_ADMINISTRATOR',
                                avalue   => l_requester);


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF okl_pop_contract_details_csr%ISOPEN THEN
           CLOSE okl_pop_contract_details_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'pop_repurchase_qte_att',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END pop_repurchase_qte_att;



  -- Start of comments
  --
  -- Procedure Name   : repurchase_qte_asset_dispose
  -- Description   : Call to Asset dispose, this procedure called from
  --                  repurchase quote WF
  -- Business Rules   :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version    : 1.0
  -- History          : SECHAWLA 11-MAR-03
  --                    Modified to the logic to consider only the Repurchase sale price amount(instead of the
  --                    sum total of all quote line type amounts) as the proceeds of sale for Repurchase quotes
  -- End of comments
  PROCEDURE repurchase_qte_asset_dispose(
                                itemtype IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
           actid  IN  NUMBER,
           funcmode IN  VARCHAR2,
    resultout       OUT NOCOPY VARCHAR2) IS


    -- SECHAWLA 11-MAR-03 : Modified the cursor below to select only the Repurchase sale price amount as proceeds
    -- of sale, instead of the sum total of all quote line type amounts.

    -- Cursor to get the sum of the amounts of all quote lines for the quote ( for a asset)
   /* CURSOR l_sum_amt_csr ( p_qte_id IN NUMBER) IS
    SELECT SUM(amount)   total_amount,
           kle_id        kle_id
    FROM   OKL_TXL_QUOTE_LINES_V
    WHERE  qte_id = p_qte_id
    AND    qlt_code <> 'AMCTAX'
    GROUP BY kle_id;
    */

    CURSOR l_amt_csr ( p_qte_id IN NUMBER) IS
    SELECT nvl(amount,0) amount,  kle_id    -- SECHAWLA 11-MAR-03 : nvl the amount
    FROM   OKL_TXL_QUOTE_LINES_V
    WHERE  qte_id = p_qte_id
    AND    qlt_code = 'AMBSPR' ;

    --SECHAWLA 11-MAR-03 : Added the following cursor
    -- This cursor is used when there are no quote lines of type 'AMBSPR'. In this case 0 is passed as proceeds_of_sale
    -- to Asset Disposition
    CURSOR l_quotelines_csr( p_qte_id IN NUMBER) IS
    SELECT DISTINCT kle_id
    FROM   OKL_TXL_QUOTE_LINES_V
    WHERE  qte_id = p_qte_id;

    -- RRAVIKIR Legal Entity Changes
    CURSOR fetch_art_id(cp_qte_id IN NUMBER) IS
    SELECT art_id
    FROM   OKL_TRX_QUOTES_B
    WHERE  id = cp_qte_id;

    CURSOR fetch_legal_entity_id(cp_art_id IN NUMBER) IS
    SELECT legal_entity_id
    FROM   OKL_ASSET_RETURNS_ALL_B
    WHERE  id = cp_art_id;

    l_legal_entity_id   NUMBER;
    l_art_id            NUMBER;
    -- Legal Entity Changes End


   -- l_sum_amt_rec          l_amt_csr%ROWTYPE;
    l_termination_date     DATE;
    lx_msg_count           NUMBER;
    lx_msg_data            VARCHAR2(32000);
    l_return_status        VARCHAR2(1);
    l_api_version          NUMBER := 1;
    l_transaction_id       VARCHAR(200);

    --SECHAWLA 11-MAR-03 : new declarations
    l_line_count           NUMBER := 0;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'repurchase_qte_asset_dispose';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      -- Get the values for dispose_asset before calling the dispose_asset api

      l_transaction_id := WF_ENGINE.GetItemAttrText(
                                          itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'TRANSACTION_ID');

      -- get the amount
      l_line_count := 0;

      -- RRAVIKIR Legal Entity Changes
      l_transaction_id := TO_NUMBER(l_transaction_id);

      OPEN fetch_art_id(cp_qte_id => l_transaction_id);
      FETCH fetch_art_id INTO l_art_id;
      CLOSE fetch_art_id;

      IF (l_art_id is null or l_art_id = OKC_API.G_MISS_NUM) THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      END IF;

      /*IF (l_art_id is null or l_art_id = OKC_API.G_MISS_NUM) THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_required_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'l_art_id');
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;*/

      OPEN fetch_legal_entity_id(cp_art_id => l_art_id);
      FETCH fetch_legal_entity_id INTO l_legal_entity_id;
      CLOSE fetch_legal_entity_id;

      IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      END IF;
      /*IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_required_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'l_legal_entity_id');
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;      */
      -- Legal Entity Changes End

      FOR l_amt_rec IN l_amt_csr ( l_transaction_id ) LOOP -- SECHAWLA 11-MAR-03 Changed the cursor name

        l_line_count := l_line_count + 1;

        -- call asset dispose retirement
        OKL_AM_ASSET_DISPOSE_PUB.dispose_asset(
                 p_api_version            => l_api_version,
                 p_init_msg_list          => OKL_API.G_TRUE, --**** SHOULD THIS BE SET TO TRUE
                 x_return_status          => l_return_status,
                 x_msg_count              => lx_msg_count,
                 x_msg_data               => lx_msg_data,
                 p_financial_asset_id         => l_amt_rec.kle_id,
                 p_quantity                   => NULL,
                 p_proceeds_of_sale           => l_amt_rec.amount, -- SECHAWLA 11-MAR-03 Changed the column name
                 p_legal_entity_id            => l_legal_entity_id);  -- RRAVIKIR Legal Entity Changes

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_ASSET_DISPOSE_PUB.dispose_asset :'||l_return_status);
   END IF;


        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          resultout := 'COMPLETE:N';
          RAISE G_EXCEPTION;
        END IF;

      END LOOP;

      -- SECHAWLA 11-MAR-03 : There were no quote lines of type 'AMBSPR'. Call asset disposition with 0 proceeds_of_sale
      IF l_line_count = 0 THEN
         FOR l_quotelines_rec IN l_quotelines_csr(l_transaction_id) LOOP

             OKL_AM_ASSET_DISPOSE_PUB.dispose_asset(
                 p_api_version            => l_api_version,
                 p_init_msg_list          => OKL_API.G_TRUE, --**** SHOULD THIS BE SET TO TRUE
                 x_return_status          => l_return_status,
                 x_msg_count              => lx_msg_count,
                 x_msg_data               => lx_msg_data,
                 p_financial_asset_id         => l_quotelines_rec.kle_id,
                 p_quantity                   => NULL,
                 p_proceeds_of_sale           => 0,
                 p_legal_entity_id            => l_legal_entity_id); -- RRAVIKIR Legal Entity Changes

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_ASSET_DISPOSE_PUB.dispose_asset :'||l_return_status);
   END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                resultout := 'COMPLETE:N';
                RAISE G_EXCEPTION;
            END IF;

         END LOOP;
      END IF;
      -- SECHAWLA 11-MAR-03 : end new code

      resultout := 'COMPLETE:Y';
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        -- SECHAWLA 11-MAR-03 : Added the cursor close statements
        IF l_amt_csr%ISOPEN THEN
           CLOSE l_amt_csr;
        END IF;

        IF l_quotelines_csr%ISOPEN THEN
           CLOSE l_quotelines_csr;
        END IF;

        -- RRAVIKIR Legal Entity Changes
        IF fetch_legal_entity_id%ISOPEN THEN
          CLOSE fetch_legal_entity_id;
        END IF;

        IF fetch_art_id%ISOPEN THEN
          CLOSE fetch_art_id;
        END IF;
        -- Legal Entity Changes End

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'repurchase_qte_asset_dispose',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        -- SECHAWLA 11-MAR-03 : Added the cursor close statements
        IF l_amt_csr%ISOPEN THEN
           CLOSE l_amt_csr;
        END IF;

        IF l_quotelines_csr%ISOPEN THEN
           CLOSE l_quotelines_csr;
        END IF;

        -- RRAVIKIR Legal Entity Changes
        IF fetch_legal_entity_id%ISOPEN THEN
          CLOSE fetch_legal_entity_id;
        END IF;

        IF fetch_art_id%ISOPEN THEN
          CLOSE fetch_art_id;
        END IF;
        -- Legal Entity Changes End

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'repurchase_qte_asset_dispose',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END repurchase_qte_asset_dispose;

  -- Start of comments
  --
  -- Procedure Name : update_asset_return_status
  -- Description   : To update the asset return status if there is a return
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE update_asset_return_status(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS


    -- Cursor to get the sum of the amounts of all quote lines for the quote ( for a asset)
    CURSOR l_return_csr ( p_qte_id IN NUMBER) IS
    SELECT QLT.kle_id kle_id,
           RET.id     ret_id
    FROM   OKL_ASSET_RETURNS_V ret,
           OKL_TXL_QUOTE_LINES_V qlt
    WHERE  RET.kle_id = QLT.kle_id
    AND    QLT.qte_id = p_qte_id
    AND    QLT.qlt_code <> 'AMCTAX'
    GROUP BY QLT.kle_id, RET.id;


    l_transaction_id            VARCHAR2(2000);
    l_api_version               NUMBER := 1;
    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(32000);
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_artv_rec                 OKL_ASSET_RETURNS_PUB.artv_rec_type;
    lx_artv_rec                 OKL_ASSET_RETURNS_PUB.artv_rec_type;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'update_asset_return_status';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      --get attr for transaction id which is the quote id for quote WFs
      l_transaction_id := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'TRANSACTION_ID');

      -- get the return rec
      FOR l_return_rec IN l_return_csr ( l_transaction_id) LOOP

        lp_artv_rec.id := l_return_rec.ret_id;
        lp_artv_rec.ars_code := 'REPURCHASE'; --'OKL_ASSET_RETURN_STATUS'

        -- Call the update of the asset return
        OKL_ASSET_RETURNS_PUB.update_asset_returns (
           p_api_version      => l_api_version,
           p_init_msg_list    => OKL_API.G_FALSE,
           x_return_status    => l_return_status,
           x_msg_count        => lx_msg_count,
           x_msg_data         => lx_msg_data,
           p_artv_rec         => lp_artv_rec,
           x_artv_rec         => lx_artv_rec);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_ASSET_RETURNS_PUB.update_asset_returns :'||l_return_status);
   END IF;


        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          resultout := 'COMPLETE:N';
          RAISE G_EXCEPTION;
        END IF;
      END LOOP;

      resultout := 'COMPLETE:Y';
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN

	IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'update_asset_return_status',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'update_asset_return_status',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END update_asset_return_status;

  -- Start of comments
  --
  -- Procedure Name : create_invoice
  -- Description : Generic procedure, can be called from any quote WF
  --                  Will create invoice for the quote
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  -- History        : RMUNJULU 09-MAY-03 2949544 Changed condition before call to
  --                  invoice api
  --                : rmunjulu EDAT modified to get quote amount excluding
  --                  Estimated Billing Adjustment if partial quote
  --
  -- End of comments
  PROCEDURE create_invoice(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS


   -- Returns previously billed records
    CURSOR okl_get_inv_csr ( p_qte_id IN NUMBER) IS
  SELECT tai.id
  FROM   OKL_TRX_AR_INVOICES_V tai
  WHERE   tai.qte_id = p_qte_id;

/*
    -- Get the quote amount
    CURSOR okl_get_qte_amt_csr(p_qte_id IN NUMBER) IS
    SELECT SUM(amount)
    FROM   OKL_TXL_QUOTE_LINES_V
    WHERE  qte_id = p_qte_id;
*/

    -- RMUNJULU 09-MAY-03 2949544
 -- Returns Quote Line which needs invoice creation
 CURSOR l_qlt_csr (p_qte_id IN NUMBER) IS
  SELECT qlt.kle_id          kle_id
  FROM okl_txl_quote_lines_b qlt,
       fnd_lookups          flo
  WHERE qlt.qte_id      = p_qte_id
  AND   qlt.amount      NOT IN (OKL_API.G_MISS_NUM, 0)
  AND  flo.lookup_type  = 'OKL_QUOTE_LINE_TYPE'
  AND  flo.lookup_code  = qlt.qlt_code
  AND  qlt.qlt_code  NOT IN (
          'AMCFIA',  -- Used to save quote assets, not amounts
          'AMCTAX',  -- Estimated tax, AR will recalculate tax
          'AMYOUB')  -- Outstanding balances are already billed
        AND     ROWNUM = 1;

    -- rmunjulu EDAT
    -- get the quote elements also excluding Estimated Billing Adjustment
    -- as it is not billed as part of partial termination quote
 CURSOR l_partial_qlt_csr (p_qte_id IN NUMBER) IS
  SELECT qlt.kle_id          kle_id
  FROM okl_txl_quote_lines_b qlt,
       fnd_lookups          flo
  WHERE qlt.qte_id      = p_qte_id
  AND   qlt.amount      NOT IN (OKL_API.G_MISS_NUM, 0)
  AND  flo.lookup_type  = 'OKL_QUOTE_LINE_TYPE'
  AND  flo.lookup_code  = qlt.qlt_code
  AND  qlt.qlt_code  NOT IN (
          'AMCFIA',  -- Used to save quote assets, not amounts
          'AMCTAX',  -- Estimated tax, AR will recalculate tax
          'AMYOUB',        -- Outstanding balances are already billed
       'BILL_ADJST') -- Estimated Billing Adjustment
        AND     ROWNUM = 1;

    -- rmunjulu EDAT
    -- get the quote details (if partial or full)
    CURSOR l_qte_details_csr (p_qte_id IN NUMBER) IS
        SELECT nvl(qte.partial_yn,'N') partial_yn
        ,qte.khr_id khr_id   -- gboomina added for bug#5265083
        FROM   okl_trx_quotes_v qte
        WHERE  qte.id = p_qte_id;

    l_api_version               NUMBER := 1;
    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(2000);
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lx_taiv_tbl                 OKL_AM_INVOICES_PVT.taiv_tbl_type;
    l_transaction_id            VARCHAR2(200);
    l_invoice_id                NUMBER:= -9999;
    l_qte_amt                   NUMBER := -9999;


    -- RMUNJULU 09-MAY-03 2949544
    l_kle_id NUMBER := OKL_API.G_MISS_NUM;
    l_invoice_needed_yn VARCHAR2(1) := 'N';

    -- rmunjulu EDAT
    l_qte_partial_yn VARCHAR2(3);

    -- gboomina Added for bug# 5265083 - Start
    l_contract_id okl_trx_quotes_v.khr_id%type;
    l_org_id                         NUMBER;
    -- gboomina Bug 5265083 - End
  -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_invoice';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      --get attr for transaction id which is the quote id for quote WFs
      l_transaction_id := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'TRANSACTION_ID');

      OPEN  okl_get_inv_csr(TO_NUMBER(l_transaction_id));
      FETCH okl_get_inv_csr INTO l_invoice_id;
      CLOSE okl_get_inv_csr;

      -- Create invoice if no invoice created already
      IF l_invoice_id IS NULL OR l_invoice_id = -9999 THEN

/*
        OPEN  okl_get_qte_amt_csr(TO_NUMBER(l_transaction_id));
        FETCH okl_get_qte_amt_csr INTO l_qte_amt;
        CLOSE okl_get_qte_amt_csr;
*/

        -- rmunjulu EDAT
        -- Get if Quote Full or Partial
  OPEN  l_qte_details_csr (TO_NUMBER(l_transaction_id ));
  -- gboomina Bug 5265083 - Start
                FETCH l_qte_details_csr INTO l_qte_partial_yn,l_contract_id;
  -- gboomina Bug 5265083 - End
  CLOSE l_qte_details_csr;

        -- rmunjulu EDAT
        IF  nvl(l_qte_partial_yn, 'N') = 'N' THEN -- full termination
           -- RMUNJULU 09-MAY-03 2949544 Cursor checks if any atleast one quote line exists
           -- which needs invoice to be created
           -- rmunjulu EDAT -- check for full termination
           OPEN  l_qlt_csr(TO_NUMBER(l_transaction_id));
           FETCH l_qlt_csr INTO l_kle_id;
           IF l_qlt_csr%FOUND THEN
              l_invoice_needed_yn := 'Y';
           END IF;
           CLOSE l_qlt_csr;
  ELSE
     -- rmunjulu EDAT -- check for partial termination quote
           OPEN  l_partial_qlt_csr(TO_NUMBER(l_transaction_id));
           FETCH l_partial_qlt_csr INTO l_kle_id;
           IF l_partial_qlt_csr%FOUND THEN
              l_invoice_needed_yn := 'Y';
           END IF;
           CLOSE l_partial_qlt_csr;
  END IF;

        -- RMUNJULU 09-MAY-03 2949549 Changed condition to check if atleast one
        -- quote line exists which has invoices need to be created
        IF nvl(l_invoice_needed_yn,'N') = 'Y' THEN

   -- gboomian Bug 5265083 - Start
          l_org_id := OKL_AM_UTIL_PVT.get_chr_org_id(l_contract_id);
          -- Set the contract org id to the application
          --DBMS_APPLICATION_INFO.set_client_info (l_org_id);
          MO_GLOBAL.set_policy_context ('S', l_org_id); -- Bug 6140786
   -- gboomian Bug 5265083 - End

          -- Create invoice
          OKL_AM_INVOICES_PVT.Create_Quote_Invoice(
                p_api_version     => l_api_version,
                p_init_msg_list   => OKL_API.G_FALSE,
                x_return_status   => l_return_status,
                x_msg_count       => lx_msg_count,
                x_msg_data        => lx_msg_data,
                p_quote_id        => TO_NUMBER(l_transaction_id),
                x_taiv_tbl        => lx_taiv_tbl);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_INVOICES_PVT.Create_Quote_Invoice :'||l_return_status);
   END IF;


        END IF;

      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      ELSE
        resultout := 'COMPLETE:Y';
      END IF;
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        IF okl_get_inv_csr%ISOPEN THEN
          CLOSE okl_get_inv_csr;
        END IF;

        -- rmunjulu EDAT
        IF l_qte_details_csr%ISOPEN THEN
          CLOSE l_qte_details_csr;
        END IF;

        -- rmunjulu EDAT
        IF l_partial_qlt_csr%ISOPEN THEN
          CLOSE l_partial_qlt_csr;
        END IF;
        /*
        IF okl_get_qte_amt_csr%ISOPEN THEN
          CLOSE okl_get_qte_amt_csr;
        END IF;
        */

        -- RMUNJULU 09-MAY-03 2949544
        IF l_qlt_csr%ISOPEN THEN
          CLOSE l_qlt_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'create_invoice',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF okl_get_inv_csr%ISOPEN THEN
          CLOSE okl_get_inv_csr;
        END IF;

        -- rmunjulu EDAT
        IF l_qte_details_csr%ISOPEN THEN
          CLOSE l_qte_details_csr;
        END IF;

        -- rmunjulu EDAT
        IF l_partial_qlt_csr%ISOPEN THEN
          CLOSE l_partial_qlt_csr;
        END IF;

        /*
        IF okl_get_qte_amt_csr%ISOPEN THEN
          CLOSE okl_get_qte_amt_csr;
        END IF;
        */
        -- RMUNJULU 09-MAY-03 2949544
        IF l_qlt_csr%ISOPEN THEN
          CLOSE l_qlt_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'create_invoice',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END create_invoice;


  -- Start of comments
  --
  -- Procedure Name : update_quote_status
  -- Description   : Generic procedure, can be called from any quote WF
  --                  Will update the quote status to COMPLETE for the quote id
  --                  which is the transaction id for WF
  -- Business Rules :
  -- Parameters    : itemtype, itemkey, actid, funcmode, resultout
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE update_quote_status(
                                itemtype IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                             actid    IN  NUMBER,
                            funcmode IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2) IS

    l_transaction_id            VARCHAR2(2000);
    l_api_version               NUMBER := 1;
    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(2000);
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;
    lx_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;
    l_quote_status              VARCHAR2(200) := 'COMPLETE';--'OKL_QUOTE_STATUS'
    -- Start : PRASJAIN : Bug 6324373
    l_quote_status_err          VARCHAR2(200) := 'ACCEPTED';--'OKL_QUOTE_STATUS'
    l_tmt_status_code           VARCHAR2(200);

    -- Fetch tmt_status_code
    CURSOR c_tmt_status_code_csr (p_qte_id IN NUMBER) IS
        SELECT tmt_status_code
          FROM okl_trx_contracts trx
         WHERE trx.qte_id = p_qte_id;
    -- End : PRASJAIN : Bug 6324373
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'update_quote_status';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      --get attr for transaction id which is the quote id for quote WFs
      l_transaction_id := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'TRANSACTION_ID');

      -- set the qtev_rec_type of quote header
      lp_qtev_rec.id                    :=    TO_NUMBER(l_transaction_id);

      -- Start : PRASJAIN : Bug 6324373
      OPEN  c_tmt_status_code_csr(lp_qtev_rec.id);
      FETCH c_tmt_status_code_csr INTO l_tmt_status_code;
      CLOSE c_tmt_status_code_csr;

      IF l_tmt_status_code = 'ERROR' THEN
        lp_qtev_rec.qst_code   :=    l_quote_status_err;
      ELSE
        lp_qtev_rec.qst_code   :=    l_quote_status;
      END IF;
      -- End : PRASJAIN : Bug 6324373

      -- Call the update of the quote header api
      OKL_TRX_QUOTES_PUB.update_trx_quotes (
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKL_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => lx_msg_count,
           x_msg_data                     => lx_msg_data,
           p_qtev_rec                     => lp_qtev_rec,
           x_qtev_rec                     => lx_qtev_rec);

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to  OKL_TRX_QUOTES_PUB.update_trx_quotes :'||l_return_status);
      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:N';
        RAISE G_EXCEPTION;
      ELSE
        resultout := 'COMPLETE:Y';
      END IF;
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        -- Start : PRASJAIN : Bug 6324373
        IF c_tmt_status_code_csr%ISOPEN THEN
          CLOSE c_tmt_status_code_csr;
        END IF;
        -- End : PRASJAIN : Bug 6324373

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'update_quote_status',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN

         IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        -- Start : PRASJAIN : Bug 6324373
        IF c_tmt_status_code_csr%ISOPEN THEN
          CLOSE c_tmt_status_code_csr;
        END IF;
        -- End : PRASJAIN : Bug 6324373

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'update_quote_status',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END update_quote_status;

  -- Start of comments
  --
  -- Procedure Name : validate_quote
  -- Description :
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE validate_quote( itemtype IN  VARCHAR2,
                itemkey   IN  VARCHAR2,
                   actid     IN  NUMBER,
                   funcmode IN  VARCHAR2,
                resultout OUT NOCOPY VARCHAR2) IS

    -- Check quote exists
    CURSOR  get_quote_csr  ( p_qte_id   IN VARCHAR2)
    IS
    SELECT  a.LAST_UPDATED_BY LAST_UPDATED_BY,
            a.QTE_ID QTE_ID,
            b.PO_PARTY_ID1 QP_PARTY_ID,
            decode(b.po_party_object, 'OKX_OPERUNIT', 'O', 'OKX_PARTY', 'P', 'OKX_VENDOR', 'V') party_type
    FROM    OKL_TXL_QUOTE_LINES_V a,
            OKL_AM_QUOTE_PARTIES_UV b
    WHERE   a.qte_id = to_number(p_qte_id)
--    and     b.qp_role_code = 'RECIPIENT'
    and     b.quote_id = a.qte_id;

    l_quote_rec                     get_quote_csr%rowtype;
    l_quote_id                      varchar2(100);

    l_user_name   WF_USERS.name%type;
    l_name        WF_USERS.description%type;

    l_recipient_name     varchar2(100);
    l_recipient_id       number;
    l_party_object_tbl   okl_am_parties_pvt.party_object_tbl_type;
    l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

--12/18/06 rkuttiya added for XMLP Project
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
  --get the recipient email address
    CURSOR c_recipient(p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = p_recipient_id;

  -- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;
    l_from_email      VARCHAR2(100);
    l_to_email        VARCHAR2(100);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      -- Get the values for dispose_asset before calling the dispose_asset api

      l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                            itemkey  => itemkey,
                          aname   => 'TRANSACTION_ID');

      OPEN  get_quote_csr(l_quote_id);
      FETCH get_quote_csr INTO l_quote_rec;
      CLOSE get_quote_csr;

      okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_quote_rec.last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);

        -- Find party details
        OKL_AM_PARTIES_PVT.get_party_details (
                                p_id_code      => l_quote_rec.party_type,
                                p_id_value      => l_quote_rec.qp_party_id,
                                x_party_object_tbl => l_party_object_tbl,
                                x_return_status  => l_return_status);

  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_PARTIES_PVT.get_party_details  :'||l_return_status);
   END IF;

        -- Check that a quote id is returned for the TRANSACTION_ID given.

  IF l_quote_rec.last_updated_by IS NOT NULL THEN

            wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                             avalue  => l_quote_rec.last_updated_by);

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user_name);

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'NOTIFY_AGENT',
                              avalue  => l_user_name);

            -- Populate Item Attributes for Fulfillment
            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'PROCESS_CODE',
                              avalue  => 'AMTER');
--12/18/06 rkuttiya comented for XMLP Project
--Recipient Type P changed to LESSEE
           /* wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_TYPE',
                              avalue  => 'P'); */

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'RECIPIENT_TYPE',
                                                avalue  => 'LESSEE');


            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_ID',
                                avalue  => l_party_object_tbl(1).p_id1);


            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_DESCRIPTION',
                                avalue  => l_party_object_tbl(1).p_name);

--12/18/06 rkuttiya modified for XMLP Project
--set the From Address and TO Address
        OPEN c_recipient(l_party_object_tbl(1).p_id1);
        FETCH c_recipient INTO l_to_email;
        CLOSE c_recipient;

         wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'EMAIL_ADDRESS',
                                     avalue  =>  l_to_email);

        OPEN c_agent_csr(l_quote_rec.last_updated_by);
        FETCH c_agent_csr into l_from_email;
        CLOSE c_agent_csr;

          wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'FROM_EMAIL',
                                     avalue  =>  l_from_email);


   --18-Dec-06 rkuttiya added for XMLP Project
   --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_QUOTE_ID';
          l_xmp_rec.param_value := l_quote_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );
	  IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
	       'after call to OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec  :'||l_return_status);
	   END IF;

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                    avalue  => l_batch_id );
                        resultout := 'COMPLETE:VALID';
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;

        --resultout := 'COMPLETE:VALID';
      ELSE
        resultout := 'COMPLETE:INVALID';
      END IF;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'validate_quote',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END validate_quote;

  -- Start of comments
  --
  -- Procedure Name : pop_partial_quote_att
  -- Description :
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE pop_partial_quote_att( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;

    l_message       VARCHAR2(30000);
    l_comments       VARCHAR2(1000);
    l_sent_date     VARCHAR2(50);
    -- cursor to populate notification attributes
  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR okl_partial_quote_csr SQL definition
 CURSOR okl_partial_quote_csr(c_id NUMBER)
 IS
    SELECT   to_char(sysdate, 'DD-MON-RRRR') system_date,
               OTQ.quote_number             quote_number,
               to_char(OTQ.date_effective_to, 'DD-MON-RRRR')        effective_to,
               okl_accounting_util.format_amount(SUM(NVL(OTL.AMOUNT,0)),okl_am_util_pvt.get_chr_currency(OTQ.KHR_ID))||' '||okl_am_util_pvt.get_chr_currency(OTQ.KHR_ID)       QUOTE_TOTAL,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_REASON',OTQ.qrs_code,'N')QUOTE_REASON ,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_TYPE',OTQ.qtp_code,'N') QUOTE_TYPE,
               to_char(OTQ.creation_date, 'DD-MON-RRRR')            quote_creation_date,
               nvl2 (qp.cpl_id, okl_am_util_pvt.get_jtf_object_name (pr.jtot_object1_code, pr.object1_id1, pr.object1_id2), okl_am_util_pvt.get_jtf_object_name (qp.party_jtot_object1_code, qp.party_object1_id1,qp.party_object1_id2)) recipient_name,
               to_char(qp.date_sent, 'DD-MON-RRRR')             recipient_date,
               AD.CONTRACT_NUMBER           CONTRACT_NUMBER,
               OTQ.COMMENTS                 COMMENTS,
               OTQ.LAST_UPDATED_BY          LAST_UPDATED_BY,
               OTQ.KHR_ID                   KHR_ID
    FROM      OKL_TRX_QUOTES_V OTQ,
              OKL_TXL_QUOTE_LINES_B OTL,
              OKL_QUOTE_PARTIES QP,
       OKC_K_PARTY_ROLES_V PR,
              OKC_K_HEADERS_ALL_B AD
    WHERE OTQ.ID          = c_id
    AND   pr.id (+) = qp.cpl_id
    AND   ad.org_id = otq.org_id
    AND   OTQ.ID          = OTL.QTE_ID
    AND   AD.ID           = OTQ.KHR_ID
    AND   OTQ.ID          = qp.qte_id
--    AND   OTQ.PARTIAL_YN  = 'Y'
    AND   qp.qpt_code = 'RECIPIENT'
    AND   otl.org_id = otq.org_id
    GROUP BY to_char(sysdate, 'MM-DD-YYYY'),
               OTQ.quote_number,
               OTQ.date_effective_to,
               OTQ.QST_CODE,
               OTQ.creation_date,
               OTQ.qrs_code,
               OTQ.qtp_code,
               nvl2 (qp.cpl_id, okl_am_util_pvt.get_jtf_object_name (pr.jtot_object1_code, pr.object1_id1, pr.object1_id2), okl_am_util_pvt.get_jtf_object_name (qp.party_jtot_object1_code, qp.party_object1_id1,qp.party_object1_id2)),
               qp.date_sent,
               AD.CONTRACT_NUMBER,
               OTQ.COMMENTS,
               OTQ.LAST_UPDATED_BY,
               OTQ.KHR_ID;

    l_quote_rec     okl_partial_quote_csr%rowtype;

    CURSOR c_asset_details_csr(c_qte_id NUMBER)
    IS
    SELECT CLEV.ITEM_DESCRIPTION ASSET_DESCRIPTION ,
           OKHV.CONTRACT_NUMBER CONTRACT_NUMBER ,
           CLEV.NAME ASSET_NUMBER ,
           OALV.SERIAL_NUMBER SERIAL_NUMBER,
           OALV.MODEL_NUMBER MODEL_NUMBER
     FROM OKL_K_LINES_FULL_V CLEV,
          OKX_ASSET_LINES_V OALV,
          OKC_K_HEADERS_V OKHV,
          OKC_LINE_STYLES_V LSEV,
          FA_CATEGORIES_VL FAC ,
          OKL_AM_ASSET_LINES_UV AL
    WHERE CLEV.ID             = OALV.PARENT_LINE_ID
      AND CLEV.CHR_ID         = OKHV.ID
      AND CLEV.LSE_ID         = LSEV.ID
      AND LSEV.LTY_CODE       = 'FREE_FORM1'
      AND AL.ID = CLEV.ID
      AND FAC.CATEGORY_ID (+) = OALV.DEPRECIATION_CATEGORY
      AND AL.QTE_ID =  c_qte_id;

    l_header_done    BOOLEAN := FALSE;
    l_updated_by     NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_partial_quote_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        --build message

        OPEN okl_partial_quote_csr(l_id);
        FETCH okl_partial_quote_csr INTO l_quote_rec;
        CLOSE okl_partial_quote_csr;

            l_message  := '<p>Quote Number:'||l_quote_rec.quote_number||'<br>'||
                      'Quote Effective To Date:'||l_quote_rec.effective_to||'<br>'||
                      'Total:'||l_quote_rec.quote_total||
                      '<p>The partial quote of '||l_quote_rec.quote_type||' was requested for Contract '||l_quote_rec.contract_number||' on<br>'||
                      l_quote_rec.quote_creation_date||' for the following reason: '||l_quote_rec.quote_reason||'.</p>'||
                      '<p>This quote will be sent to the Recipient '||l_quote_rec.recipient_name||' on '||l_quote_rec.recipient_date||' following your <br>'||
                      'approval. </p>'||
                      '<table width="50%" border="1">'||
                      '<tr>'||
                      '<td>Asset Number</td>'||
                      '<td>Asset Description</td>'||
                      '<td>Model</td>'||
                      '<td>Serial Number</td>'||
                      '</tr>';
             l_header_done := TRUE;
             l_updated_by  := l_quote_rec.last_updated_by;
             l_comments    := l_quote_rec.comments;
             l_sent_date   := l_quote_rec.recipient_date;

        FOR l_asset_details_rec in c_asset_details_csr(l_id) loop
          l_message  :=  l_message||'<tr>'||
                                '<td>'||l_asset_details_rec.asset_number||'</td>'||
                                '<td>'||l_asset_details_rec.asset_description||'</td>'||
                                '<td>'||l_asset_details_rec.model_number||'</td>'||
                                '<td>'||l_asset_details_rec.serial_number||'</td>'||
                                '</tr>';
        END LOOP;

          l_message  := l_message||'</table><p>Comments:<br>'||
                    l_comments||'</p>'||
                    '<p>Please contact us before '||l_sent_date||' to confirm the quote amounts.'||
                    '</p>';

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TRX_TYPE_ID',
                              avalue  => 'OKLAMPAR');

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MESSAGE_DESCRIPTION',
                              avalue  => l_message);

        resultout := 'COMPLETE:';
        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
         IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF okl_partial_quote_csr%ISOPEN THEN
           CLOSE okl_partial_quote_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'pop_partial_quote_att', itemtype, itemkey, actid, funcmode);
        RAISE;

  END pop_partial_quote_att;

  -- Start of comments
  --
  -- Procedure Name : set_quote_approved_yn
  -- Description : Called from Send Quote Workflow (OKLAMNQT) to update
  --                  the quote status afer Approval/Rejection
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE set_quote_approved_yn( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS


    l_id            VARCHAR2(100);
    l_approved      VARCHAR2(1);

    x_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);
    p_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    x_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    p_api_version   NUMBER       := 1;
    p_init_msg_list VARCHAR2(1)  := FND_API.G_TRUE;

    API_ERROR       EXCEPTION;

    l_notify_response VARCHAR2(30);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_quote_approved_yn';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');


        l_approved := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'APPROVED_YN');

        l_notify_response := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'RESULT');

        IF nvl(l_approved, 'Y') = 'N' OR l_notify_response = 'REJECTED' THEN
            p_qtev_rec.QST_CODE := 'REJECTED';
        ELSE
            p_qtev_rec.QST_CODE := 'APPROVED';
            p_qtev_rec.DATE_APPROVED := SYSDATE;
        END IF;

        p_qtev_rec.ID := to_number(l_id);

        p_qtev_rec.APPROVED_YN := nvl(l_approved, 'Y');

        okl_qte_pvt.update_row( p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_qtev_rec       => p_qtev_rec,
                                x_qtev_rec       => x_qtev_rec);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_qte_pvt.update_row :'||x_return_status);
           END IF;

  IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            IF nvl(l_approved, 'Y') = 'Y' THEN
       resultout := 'COMPLETE:APPROVED';
            ELSE
       resultout := 'COMPLETE:REJECTED';
            END IF;
  ELSE
   RAISE API_ERROR;
  END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        wf_core.context('OKL_AM_QUOTES_WF' , 'set_quote_approved_yn', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'set_quote_approved_yn', itemtype, itemkey, actid, funcmode);
        RAISE;

  END set_quote_approved_yn;

  -- Start of comments
  --
  -- Procedure Name : pop_gl_quote_att
  -- Description :
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE pop_gl_quote_att( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;

    l_message       VARCHAR2(30000);

    -- cursor to populate notification attributes
 CURSOR okl_quote_csr(c_id NUMBER)
 IS
    SELECT     TO_CHAR(SYSDATE, 'DD-MON-RRRR') SYSTEM_DATE,
               OTQ.QUOTE_NUMBER             QUOTE_NUMBER,
               to_char(OTQ.DATE_EFFECTIVE_TO, 'DD-MON-RRRR') EFFECTIVE_TO,
               okl_accounting_util.format_amount(SUM(NVL(OTL.AMOUNT,0)),okl_am_util_pvt.get_chr_currency(OTQ.KHR_ID))||' '||okl_am_util_pvt.get_chr_currency(OTQ.KHR_ID)       QUOTE_TOTAL,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_REASON',OTQ.qrs_code,'N')QUOTE_REASON ,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_TYPE',OTQ.qtp_code,'N') QUOTE_TYPE,
               to_char(OTQ.CREATION_DATE, 'DD-MON-RRRR') QUOTE_CREATION_DATE,
               AD.CONTRACT_NUMBER           CONTRACT_NUMBER,
               OTQ.COMMENTS                 COMMENTS,
               OTQ.LAST_UPDATED_BY          LAST_UPDATED_BY,
               OTQ.KHR_ID                   KHR_ID
    FROM      OKL_TRX_QUOTES_V OTQ,
              OKL_TXL_QUOTE_LINES_B OTL,
              OKC_K_HEADERS_V AD
    WHERE OTQ.ID          = c_id
    AND   OTQ.ID          = OTL.QTE_ID
    AND AD.ID         = OTQ.KHR_ID
    GROUP BY TO_CHAR(SYSDATE, 'DD-MON-RRRR'),
               OTQ.QUOTE_NUMBER,
               OTQ.DATE_EFFECTIVE_TO,
               OTQ.QST_CODE,
               OTQ.CREATION_DATE,
               OTQ.QRS_CODE,
               AD.CONTRACT_NUMBER,
               OTQ.COMMENTS,
               OTQ.LAST_UPDATED_BY, OTQ.KHR_ID, OTQ.qtp_code;

    l_quote_rec okl_quote_csr%rowtype;
    l_projected_gl      NUMBER;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_gl_quote_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        l_projected_gl := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'QUOTE_GL');
        --build message
     OPEN  okl_quote_csr(l_id);
     FETCH okl_quote_csr INTO l_quote_rec;
     CLOSE okl_quote_csr;

        l_message  := '<p>Quote Number:'||l_quote_rec.quote_number||'<br>'||
                      'Quote Effective To Date:'||l_quote_rec.effective_to||'<br>'||
                      'Total:'||l_quote_rec.quote_total||'<br>'||
                      'Projected Gain/Loss:'||okl_accounting_util.format_amount((l_projected_gl),okl_am_util_pvt.get_chr_currency(l_quote_rec.KHR_ID))||' '||okl_am_util_pvt.get_chr_currency(l_quote_rec.KHR_ID)||'<br>'||
                      '<p>A Quote of type '||l_quote_rec.quote_type||' was requested for Contract '||l_quote_rec.contract_number||' on<br>'||
                      l_quote_rec.quote_creation_date||' for the following reason: '||l_quote_rec.quote_reason||'.</p>'||
                      '<p>Comments:<br>'||
                      l_quote_rec.comments||'</p>'||
                      '<p>The quote will be completed following your approval.</p>';

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TRX_TYPE_ID',
                              avalue  => 'OKLAMGAL');

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MESSAGE_DESCRIPTION',
                              avalue  => l_message);

        resultout := 'COMPLETE:';
        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN

             IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF okl_quote_csr%ISOPEN THEN
           CLOSE okl_quote_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'pop_gl_quote_att', itemtype, itemkey, actid, funcmode);
        RAISE;

  END pop_gl_quote_att;

  -- Start of comments
  --
  -- Procedure Name : validate_quote_approval
  -- Description    : Validates quote id on entry to Workflow
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE validate_quote_approval( itemtype IN  VARCHAR2,
                                     itemkey   IN  VARCHAR2,
                                     actid     IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     resultout OUT NOCOPY VARCHAR2) IS

    -- Check quote exists an d is either DRAFTED or REJECTED
  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR get_quote_csr SQL definition
    CURSOR  get_quote_csr  ( p_qte_id   IN VARCHAR2)
    IS
    SELECT  a.last_updated_by, a.quote_number, count(*) recs
    FROM    OKL_TRX_QUOTES_B a,
            OKL_QUOTE_PARTIES b
    WHERE   a.id = p_qte_id
    and     a.qst_code in ('DRAFTED', 'REJECTED')
    and     b.qte_id (+) = a.id
    GROUP BY a.last_updated_by, a.quote_number;

    l_last_updated_by               NUMBER;
    l_quote_id                      VARCHAR2(200);

    l_user_name   WF_USERS.name%type;
    l_name        WF_USERS.description%type;
    l_current_party  NUMBER;

    l_quote_number  VARCHAR2(100);

    x_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);
    p_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    x_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    p_api_version   NUMBER       := 1;
    p_init_msg_list VARCHAR2(1)  := FND_API.G_TRUE;

    API_ERROR       EXCEPTION;
--19-jul-2007 ansethur R12B XML Publisher starts
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';
    l_return_status  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;

 -- Check quote exists
    CURSOR  get_quote_xmlp_csr  ( p_qte_id   IN VARCHAR2)
    IS
    SELECT  a.LAST_UPDATED_BY LAST_UPDATED_BY,
            a.QTE_ID QTE_ID,
            b.PO_PARTY_ID1 QP_PARTY_ID,
            decode(b.po_party_object, 'OKX_OPERUNIT', 'O', 'OKX_PARTY', 'P', 'OKX_VENDOR', 'V') party_type
    FROM    OKL_TXL_QUOTE_LINES_V a,
            OKL_AM_QUOTE_PARTIES_UV b
    WHERE   a.qte_id = to_number(p_qte_id)
--  and     b.qp_role_code = 'RECIPIENT'
    and     b.quote_id = a.qte_id;

    l_quote_rec                     get_quote_xmlp_csr%rowtype;
    l_party_object_tbl   okl_am_parties_pvt.party_object_tbl_type;

 --get the recipient email address
    CURSOR c_recipient(p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = p_recipient_id;

-- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;

    l_from_email      VARCHAR2(100);
    l_to_email        VARCHAR2(100);
  --19-jul-2007 ansethur R12B XML Publisher Starts
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_quote_approval';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname   => 'TRANSACTION_ID');

--  20-Mar-06 rmunjulu 5087501 call okl_qte_pvt.update_row( ) to update the
--  LAST_UPDATED_BY column of the quote with the current logged in user_id so before
--  raising the business event so that workflow can pick up the correct requestor.

       p_qtev_rec.ID := to_number(l_quote_id);
       okl_qte_pvt.update_row( p_api_version      => p_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => x_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_qtev_rec        => p_qtev_rec,
                                x_qtev_rec        => x_qtev_rec);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_qte_pvt.update_row :'||x_return_status);
   END IF;

       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          RAISE API_ERROR;
       END IF;
-- end of 20-Mar-06 rmunjulu 5087501

      OPEN  get_quote_csr(l_quote_id);
      FETCH get_quote_csr INTO l_last_updated_by, l_quote_number, l_current_party;
      CLOSE get_quote_csr;

      okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);
      -- Check that a quote id is returned for the TRANSACTION_ID given.

         IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_wf.get_notification_agent :'||l_return_status);
   END IF;

  IF l_last_updated_by IS NOT NULL AND l_user_name IS NOT NULL THEN

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                             avalue  => l_user_name);

             wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'WF_ADMINISTRATOR',
                              avalue  => l_user_name);

            IF itemtype <> 'OKLAMRQT' THEN

             wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                             avalue  => l_last_updated_by);

             wf_engine.SetItemAttrText (
                                itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'NOTIFY_AGENT',
                              avalue  => l_user_name);

             wf_engine.SetItemAttrText (
                                itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'QUOTE_NUMBER',
                              avalue  => l_quote_number);
   END IF;

            -- change the quote status to submitted to indicate that the WF
            -- is processing for approval

            p_qtev_rec.ID := to_number(l_quote_id);
            p_qtev_rec.QST_CODE := 'SUBMITTED';
            okl_qte_pvt.update_row( p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_qtev_rec        => p_qtev_rec,
                                x_qtev_rec        => x_qtev_rec);

  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_qte_pvt.update_row :'||x_return_status);
   END IF;

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                RAISE API_ERROR;
            END IF;
   --19-jul-2007 ansethur R12B XML Publisher Starts
        OPEN  get_quote_xmlp_csr(l_quote_id);
        FETCH get_quote_xmlp_csr INTO l_quote_rec;
        CLOSE get_quote_xmlp_csr;

        -- Find party details
        OKL_AM_PARTIES_PVT.get_party_details (
                               	p_id_code		    => l_quote_rec.party_type,
                               	p_id_value		    => l_quote_rec.qp_party_id,
                               	x_party_object_tbl	=> l_party_object_tbl,
                               	x_return_status		=> x_return_status);

  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_PARTIES_PVT.get_party_details :'||l_return_status);
   END IF;

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                RAISE API_ERROR;
            END IF;

            -- Populate Item Attributes for Fulfillment
            wf_engine.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'PROCESS_CODE',
         	                    avalue  => 'AMTER');

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'RECIPIENT_ID',
                                avalue  => l_party_object_tbl(1).p_id1);


            wf_engine.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'RECIPIENT_DESCRIPTION',
                                avalue  => l_party_object_tbl(1).p_name);

        OPEN c_recipient(l_party_object_tbl(1).p_id1);
        FETCH c_recipient INTO l_to_email;
        CLOSE c_recipient;

         wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'EMAIL_ADDRESS',
                                     avalue  =>  l_to_email);

        OPEN c_agent_csr(l_quote_rec.last_updated_by);
        FETCH c_agent_csr into l_from_email;
        CLOSE c_agent_csr;

          wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'FROM_ADDRESS',
                                     avalue  =>  l_from_email);
   --18-Dec-06 rkuttiya added for XMLP Project
   --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_QUOTE_ID';
          l_xmp_rec.param_value := l_quote_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec :'||l_return_status);
           END IF;

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                   avalue  => l_batch_id );

                        resultout := 'COMPLETE:VALID';
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;
          --  resultout := 'COMPLETE:VALID';

  --19-jul-2007 ansethur R12B XML Publisher Ends

         ELSE
            resultout := 'COMPLETE:INVALID';
         END IF;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'VALIDATE_QUOTE_APPROVAL', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_quote_csr%ISOPEN THEN
           CLOSE get_quote_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'VALIDATE_QUOTE_APPROVAL',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END validate_quote_approval;

  -- Start of comments
  --
  -- Procedure Name : pop_cp_quote_att
  -- Description    : Populate Restructure Quote Notification Message
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE pop_cp_quote_att( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;

    l_message       VARCHAR2(30000);

    -- cursor to populate notification attributes
 CURSOR okl_quote_csr(c_id NUMBER)
 IS
    SELECT     TO_CHAR(SYSDATE, 'DD-MON-RRRR') SYSTEM_DATE,
               OTQ.QUOTE_NUMBER             QUOTE_NUMBER,
               to_char(OTQ.DATE_EFFECTIVE_TO, 'DD-MON-RRRR') EFFECTIVE_TO,
               okl_accounting_util.format_amount(SUM(NVL(OTL.AMOUNT,0)),okl_am_util_pvt.get_chr_currency(OTQ.KHR_ID))||' '||okl_am_util_pvt.get_chr_currency(OTQ.KHR_ID)       QUOTE_TOTAL,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_REASON',OTQ.qrs_code,'N')QUOTE_REASON ,
               OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_QUOTE_TYPE',OTQ.qtp_code,'N') QUOTE_TYPE,
               to_char(OTQ.CREATION_DATE, 'DD-MON-RRRR') QUOTE_CREATION_DATE,
               AD.CONTRACT_NUMBER           CONTRACT_NUMBER,
               OTQ.COMMENTS                 COMMENTS,
               OTQ.LAST_UPDATED_BY          LAST_UPDATED_BY,
               OTQ.KHR_ID                   KHR_ID
    FROM      OKL_TRX_QUOTES_V OTQ,
              OKL_TXL_QUOTE_LINES_B OTL,
              OKC_K_HEADERS_V AD
    WHERE OTQ.ID          = c_id
    AND   OTQ.ID          = OTL.QTE_ID
    AND AD.ID         = OTQ.KHR_ID
    GROUP BY TO_CHAR(SYSDATE, 'DD-MON-RRRR'),
               OTQ.QUOTE_NUMBER,
               OTQ.DATE_EFFECTIVE_TO,
               OTQ.QST_CODE,
               OTQ.CREATION_DATE,
               OTQ.QRS_CODE,
               AD.CONTRACT_NUMBER,
               OTQ.COMMENTS,
               OTQ.LAST_UPDATED_BY, OTQ.KHR_ID, OTQ.qtp_code;

    l_quote_rec okl_quote_csr%rowtype;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_cp_quote_att';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        --build message
     OPEN  okl_quote_csr(l_id);
     FETCH okl_quote_csr INTO l_quote_rec;
     CLOSE okl_quote_csr;

        l_message  := '<p>Quote Number:'||l_quote_rec.quote_number||'<br>'||
                      'Quote Effective To Date:'||l_quote_rec.effective_to||'<br>'||
                      'Total:'||l_quote_rec.quote_total||'<br>'||
                      '<p>The Restructure Quote was requested for Contract '||l_quote_rec.contract_number||' on<br>'||
                      l_quote_rec.quote_creation_date||' for the following reason: '||l_quote_rec.quote_reason||'.</p>'||
                      '<p>Comments:<br>'||
                      l_quote_rec.comments||'</p>'||
                      '<p>The quote will be porcessed following your approval.</p>';

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TRX_TYPE_ID',
                              avalue  => 'OKLAMRQT');

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MESSAGE_DESCRIPTION',
                              avalue  => l_message);

        resultout := 'COMPLETE:';
        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN

         IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF okl_quote_csr%ISOPEN THEN
           CLOSE okl_quote_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'pop_cp_quote_att', itemtype, itemkey, actid, funcmode);
        RAISE;

  END pop_cp_quote_att;

  -- Start of comments
  --
  -- Procedure Name : CHECK_IF_PARTIAL_QUOTE
  -- Description    : Check for Partial Quote
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE CHECK_IF_PARTIAL_QUOTE(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS
    l_id      NUMBER;
    l_partial_yn    VARCHAR2(1);
    l_khr_id        NUMBER;
    l_rule_khr_id   NUMBER;
    l_qtp_code      VARCHAR2(30);
    l_qtev_rec      okl_trx_quotes_pub.qtev_rec_type;
    l_rgd_code      VARCHAR2(30);

    CURSOR c_qte_csr(c_id NUMBER) IS
    SELECT  partial_yn, khr_id, qtp_code
    FROM    OKL_TRX_QUOTES_B
    WHERE   id = c_id;

    l_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;

    API_ERROR EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_if_partial_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        OPEN c_qte_csr(l_id);
        FETCH c_qte_csr INTO l_partial_yn, l_khr_id, l_qtp_code;
        CLOSE c_qte_csr;

        l_qtev_rec.khr_id := l_khr_id;
        l_qtev_rec.qtp_code := l_qtp_code;
        l_rule_khr_id := okl_am_util_pvt.get_rule_chr_id (l_qtev_rec);
        IF l_qtp_code LIKE 'TER_RECOURSE%' THEN
                l_rgd_code := 'AVTPAR';
        ELSE
                l_rgd_code := 'AMTPAR';
        END IF;

     IF l_partial_yn = 'Y' THEN

         OKL_AM_UTIL_PVT.get_rule_record(
                                  p_rgd_code     => l_rgd_code,
                                  p_rdf_code     => 'AMAPRE',
                                  p_chr_id     => l_rule_khr_id,
                                  p_cle_id     => NULL,
                                  x_rulv_rec     => l_rulv_rec,
                                  x_return_status => l_return_status,
                                  p_message_yn => FALSE);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
   END IF;

     IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

      IF NVL (l_rulv_rec.rule_information1, '*') = 'Y' THEN

                resultout := 'COMPLETE:Y';
            ELSE
                resultout := 'COMPLETE:N';
            END IF;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN

            resultout := 'COMPLETE:N';
        ELSE
            RAISE API_ERROR;
        END IF;
    ELSE
        resultout := 'COMPLETE:N';
    END IF;

    RETURN;

   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

         IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_IF_PARTIAL_QUOTE', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF c_qte_csr%ISOPEN THEN
           CLOSE c_qte_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_IF_PARTIAL_QUOTE', itemtype, itemkey, actid, funcmode);
        RAISE;

  END CHECK_IF_PARTIAL_QUOTE;

  -- Start of comments
  --
  -- Procedure Name : pop_stop_notification
  -- Description    : populates stop notification
  -- Business Rules :
  -- Parameters     : document_id,display_type, document, document_type
  -- Version     : 1.0
  -- History        : rkuttiya created 22-SEP-2003  Bug:2794685
  --                : RMUNJULU 03-OCT-03 2794685 Changed to get proper results
  -- End of comments

  PROCEDURE pop_stop_notification (document_id   in varchar2,
                                   display_type  in varchar2,
                                   document      in out nocopy varchar2,
                                   document_type in out nocopy varchar2) IS


    -- Cursor to obtain quote and contract details
    CURSOR  c_quote_ctr  ( p_qte_id   IN NUMBER)
    IS
    SELECT  TRX.ID,
            TRX.QUOTE_NUMBER,
            TRX.KHR_ID,
            TRX.QTP_CODE,
            KHR.CONTRACT_NUMBER
    FROM    OKL_TRX_QUOTES_B TRX,
            OKC_K_HEADERS_B KHR
    WHERE   TRX.id = p_qte_id
    AND     TRX.KHR_ID = KHR.ID;


    l_quote_ctr         c_quote_ctr%rowtype;
    l_quote_id          NUMBER;
    l_rgd_code          VARCHAR2(30);
    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
    l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_message           VARCHAR2(32000);

    l_tolerance_option VARCHAR2(150);
    l_tolerance_value NUMBER;
    l_tolerance_formula VARCHAR2(150);
    l_tolerance_basis   VARCHAR2(30);
    l_approval_formula  VARCHAR2(150);


    l_user_name      WF_USERS.name%type;
    l_name           WF_USERS.description%type;
    l_header_done    BOOLEAN := FALSE;
    l_pos            NUMBER;
    l_stop_type      VARCHAR2(15);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_stop_notification';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


        --get the parameters from document id
        l_pos      := INSTR(document_id, ':');
        l_quote_id   := SUBSTR(document_id, 1, l_pos - 1);
        l_stop_type   := SUBSTR(document_id, l_pos + 1, LENGTH(document_id) - l_pos);

        --get quote and contract details
        OPEN c_quote_ctr(l_quote_id);
        FETCH c_quote_ctr INTO l_quote_ctr;
        CLOSE c_quote_ctr;

        -- RMUNJULU Updated the message texts
        --setting the message dynamically based on different STOP  Global Variables
        IF l_stop_type = 'TOPTION' THEN -- Tolerance Allowed Option is set to NOT APPLICABLE
         l_message := '<html><body>'||
                      '<p>The termination quote approval process for Contract Number '||l_quote_ctr.contract_number||', Quote Number '||l_quote_ctr.quote_number||
                      ' has resulted in error.</p>'||
                      '<p>The Tolerance Allowed Option of the Gain/Loss value set of Termination Quote Process terms and conditions is set to NOT APPLICABLE.</p>'||
                      '<p>Please verify and change the Termination Quote Process terms and conditions and resubmit the quote for approval.</p> </body></html>';
        ELSIF l_stop_type = 'TFORMULAE' THEN -- Tolerance Allowed Formula returned no value
         l_message := '<html><body>'||
                      '<p>The termination quote approval process for Contract Number '||l_quote_ctr.contract_number||', Quote Number '||l_quote_ctr.quote_number||
                      ' has resulted in error.</p>'||
                      '<p>The Tolerance Allowed Formula of the Gain/Loss value set of Termination Quote Process terms and conditions has returned an error.</p> '||
                      '<p>Please  verify and change the Termination Quote Process terms and conditions and resubmit the quote for approval.</p> </body></html>';
        ELSIF l_stop_type = 'AFORMULA' THEN -- Approval Processing Formula is not set
         l_message := '<html><body>'||
                      '<p>The termination quote approval process for Contract Number: '||l_quote_ctr.contract_number||', Quote Number '||l_quote_ctr.quote_number||
                      ' has resulted in error.</p>'||
                      '<p>The Approval Processing Formula of the Gain/Loss value set of Termination Quote Process terms and conditions is not set.</p>'||
                      '<p>Please verify and change the Termination Quote Process terms and conditions and resubmit the quote for approval.</p> </body></html>';
        ELSIF l_stop_type = 'AFORMULAE' THEN -- Approval Processing Formula returned error
         l_message := '<html><body>'||
                      '<p>The termination quote approval process for Contract Number: '||l_quote_ctr.contract_number||', Quote Number: '||l_quote_ctr.quote_number||
                      ' has resulted in error.</p>'||
                      '<p>The Approval Processing Formula of the Gain/Loss value set of Termination Quote Process terms and conditions has returned an error. '||
                      '<p>Please verify and change the Termination Quote Process terms and conditions and resubmit the quote for approval.</p> </body></html>';
        END IF;


        document := l_message;
        document_type := display_type;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

        RETURN;

  EXCEPTION
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF c_quote_ctr%ISOPEN THEN
           CLOSE c_quote_ctr;
        END IF;

  END pop_stop_notification;

  -- Start of comments
  --
  -- Procedure Name : CHECK_IF_QUOTE_GAIN_LOSS
  -- Description    : Check for Quote Gain or Loss
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  -- History        : rkuttiya updated on 16-SEP-2003 Bug: 2794685
  --                : RMUNJULU 03-OCT-03 2794685 Changed to get proper results
  -- End of comments

  PROCEDURE CHECK_IF_QUOTE_GAIN_LOSS(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS
    l_id     NUMBER;
    l_partial_yn    VARCHAR2(1);
    l_khr_id        NUMBER;
    l_rule_khr_id   NUMBER;
    l_qtp_code      VARCHAR2(30);
    l_qtev_rec      okl_trx_quotes_pub.qtev_rec_type;
    l_rgd_code      VARCHAR2(30);

--Rkuttiya 18-SEP-2003 added "last_updated by" column to the  following cursor for bug 2794685
    CURSOR c_qte_csr(c_id NUMBER) IS
    SELECT  khr_id, qtp_code,last_updated_by
    FROM    OKL_TRX_QUOTES_B
    WHERE   id = c_id;

    CURSOR c_qtl_csr(c_id NUMBER) IS
    SELECT *
    FROM   OKL_TXL_QUOTE_LINES_B
    WHERE  qte_id =c_id;

    l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;

    API_ERROR EXCEPTION;

    l_quote_total NUMBER := 0;
    l_quote_net  NUMBER := 0;
    l_tolerance  NUMBER := 0;
    l_seq  NUMBER;
    l_formula_value NUMBER;

    l_rule_found BOOLEAN := FALSE;
    l_check_gain_yn BOOLEAN := FALSE;
    l_line_formula_yn BOOLEAN := FALSE;
    l_always_approve_yn BOOLEAN := FALSE;

    l_calc_option VARCHAR2(150);
    l_fixed_value NUMBER;
    l_formula_name VARCHAR2(150);

    l_result VARCHAR2(50) := 'COMPLETE:NO';

--rkuttiya 18-SEP-2003 Bug:2794685
    l_last_updated_by    NUMBER;
    l_user_name          VARCHAR2(200);
    l_name               VARCHAR2(200);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_if_quote_gain_loss';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'TRANSACTION_ID');


--rkuttiya 18-SEP-2003  added variable l_last_updated_by in the FETCH clause bug: 2794685
        OPEN c_qte_csr(l_id);
        FETCH c_qte_csr INTO l_khr_id, l_qtp_code,l_last_updated_by;
        CLOSE c_qte_csr;

        l_qtev_rec.khr_id := l_khr_id;
        l_qtev_rec.qtp_code := l_qtp_code;
        l_rule_khr_id := okl_am_util_pvt.get_rule_chr_id (l_qtev_rec);
        IF l_qtp_code LIKE 'TER_RECOURSE%' THEN
                l_rgd_code := 'AVTGAL';
        ELSE
                l_rgd_code := 'AMTGAL';
        END IF;

     OKL_AM_UTIL_PVT.get_rule_record(
                                    p_rgd_code         => l_rgd_code,
                                    p_rdf_code         => 'AMAPRE',
                                    p_chr_id         => l_rule_khr_id,
                                    p_cle_id         => NULL,
                                    x_rulv_rec         => l_rulv_rec,
                                    x_return_status => l_return_status,
                                    p_message_yn => FALSE);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
   END IF;


     IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
              IF NVL (l_rulv_rec.rule_information1, '*') = 'Y' THEN
                l_result := CHECK_CALC_OPTIONS(itemtype   => itemtype,
                                               itemkey    => itemkey,
                                               actid      => actid,
                                               funcmode   => funcmode,
                                            p_rgd_code => l_rgd_code,
                                p_khr_id   => l_rule_khr_id,
                                               p_qte_id   => l_id);

--rkuttiya 18-SEP-2003  added for bug 2794685
                IF l_result = 'COMPLETE:STOP' THEN
--Set notification body
                   wf_engine.SetItemAttrText (
                                              itemtype=> itemtype,
                  itemkey => itemkey,
                  aname   => 'MESSAGE_DOC',
                                        avalue  => 'plsql:okl_am_quotes_wf.pop_stop_notification/'||l_id||':'||G_STOP);

--get the name of requestor

                   okl_am_wf.get_notification_agent(
                                               itemtype           => itemtype
                                      , itemkey            => itemkey
                                      , actid           => actid
                                      , funcmode           => funcmode
                                             , p_user_id          => l_last_updated_by
                                             , x_name             => l_user_name
                                      , x_description      => l_name);

--set the value for item attribute 'REQUESTER'

                   wf_engine.SetItemAttrText ( itemtype    => itemtype,
                   itemkey     => itemkey,
                   aname       => 'REQUESTER',
                                        avalue      => l_user_name);
                 END IF;
            ELSE
               l_result := 'COMPLETE:NO';
            end if;


           ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
             resultout := 'COMPLETE:NO';
           ELSE
             RAISE API_ERROR;
          END IF;
        resultout := l_result;

        RETURN;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_IF_QUOTE_GAIN_LOSS', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF c_qte_csr%ISOPEN THEN
           CLOSE c_qte_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_IF_QUOTE_GAIN_LOSS', itemtype, itemkey, actid, funcmode);
        RAISE;

  END CHECK_IF_QUOTE_GAIN_LOSS;

  -- Start of comments
  --
  -- Procedure Name : CHECK_FOR_EXT_APPROVAL
  -- Description    : Check for Quote Approvers
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE CHECK_FOR_EXT_APPROVAL(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS

    l_quote_id                      varchar2(100);

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version  CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
 l_msg_count      NUMBER  := OKL_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);
 l_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
 l_q_party_uv_rec    okl_am_parties_pvt.q_party_uv_rec_type;
    l_party_count  NUMBER;

    API_ERROR           EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_for_ext_approval';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        l_q_party_uv_rec.quote_id := l_quote_id;
        l_q_party_uv_rec.qp_role_code := 'APPROVER';


        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

  okl_am_parties_pvt.get_quote_parties (
   p_api_version  => l_api_version,
   p_init_msg_list  => l_init_msg_list,
   x_msg_count      => l_msg_count,
   x_msg_data      => l_msg_data,
   x_return_status  => l_return_status,
   p_q_party_uv_rec => l_q_party_uv_rec,
   x_q_party_uv_tbl => l_q_party_uv_tbl,
   x_record_count  => l_party_count);

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_parties_pvt.get_quote_parties :'||l_return_status);
   END IF;


        IF l_party_count > 0 THEN

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_COUNT',
                                       avalue   => l_party_count);


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_TYPE',
                                       avalue   => 'APPROVER');


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PROCESS_CODE',
                                       avalue   => 'AMTER');

             resultout := 'COMPLETE:Y';
        ELSE
             resultout := 'COMPLETE:N';
        END IF;

      RETURN ;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT_ADD',
                        itemtype, itemkey, actid, funcmode);
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_EXT_APPROVAL',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
  END CHECK_FOR_EXT_APPROVAL;

  -- Start of comments
  --
  -- Procedure Name : GET_QUOTE_PARTY_DETAILS
  -- Description    : Generic procedure called from OKLAMNQT Workflow
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE GET_QUOTE_PARTY_DETAILS(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS

    l_quote_id          NUMBER;
    l_party_count       NUMBER;
    l_party_type        VARCHAR2(30);

    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version       CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count         NUMBER  := OKL_API.G_MISS_NUM;
    l_msg_data          VARCHAR2(2000);
    l_q_party_uv_tbl    okl_am_parties_pvt.q_party_uv_tbl_type;
    l_q_party_uv_rec    okl_am_parties_pvt.q_party_uv_rec_type;
    l_total_party_count NUMBER;
    l_current_rec       NUMBER;

    l_recipient_type    VARCHAR2(50);
    l_recipient_id      NUMBER;
    l_recipient_desc    VARCHAR2(1000);

    l_external_approver VARCHAR2(30000);

    MISSING_DETAILS_ERROR  EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_quote_party_details';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
      -- Get the values for dispose_asset before calling the dispose_asset api

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        l_party_count := WF_ENGINE.GetItemAttrNumber( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'PARTY_COUNT');

        l_party_type := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'PARTY_TYPE');

        l_q_party_uv_rec.quote_id       := l_quote_id;
        l_q_party_uv_rec.qp_role_code   := l_party_type;

        IF l_party_count > 0 THEN

      okl_am_parties_pvt.get_quote_parties (
           p_api_version  => l_api_version,
           p_init_msg_list  => l_init_msg_list,
           x_msg_count      => l_msg_count,
           x_msg_data      => l_msg_data,
           x_return_status  => l_return_status,
           p_q_party_uv_rec => l_q_party_uv_rec,
           x_q_party_uv_tbl => l_q_party_uv_tbl,
           x_record_count  => l_total_party_count);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_parties_pvt.get_quote_parties :'||l_return_status);
   END IF;

   IF l_q_party_uv_tbl(l_party_count).co_email IS NOT NULL THEN

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
            itemkey => itemkey,
            aname   => 'EMAIL_ADDRESS',
            avalue  => l_q_party_uv_tbl(l_party_count).co_email);

        l_recipient_desc := nvl(l_q_party_uv_tbl(l_party_count).co_contact_name,
        l_q_party_uv_tbl(l_party_count).po_party_name);

--19-jul-2007 ansethur  R12B XML Publisher Starts
        l_recipient_id := l_q_party_uv_tbl(l_party_count).po_party_id1;

        IF l_q_party_uv_tbl(l_party_count).po_party_object = 'OKX_PARTY' THEN
              l_recipient_type := 'LESSEE';
        ELSIF l_q_party_uv_tbl(l_party_count).po_party_object = 'OKX_VENDOR' THEN
              l_recipient_type := 'VENDOR';
        ELSIF l_q_party_uv_tbl(l_party_count).po_party_object = 'OKX_OPERUNIT' THEN
               l_recipient_type := 'LESSEE';
        END IF;
--19-jul-2007 ansethur  R12B XML Publisher Ends

  ELSIF l_q_party_uv_tbl(l_party_count).co_contact_id1 IS NOT NULL THEN

        -- Recipient is at contact level
        l_recipient_id := l_q_party_uv_tbl(l_party_count).co_contact_id1;
        --rkuttiya changed recipient type to LESSEE/VENDOR for XMLP Project
        IF l_q_party_uv_tbl(l_party_count).co_contact_object = 'OKX_PARTY' THEN
            --l_recipient_type := 'PC';
              l_recipient_type := 'LESSEE';
        ELSIF l_q_party_uv_tbl(l_party_count).co_contact_object = 'OKX_VENDOR' THEN
            --l_recipient_type := 'VC';
              l_recipient_type := 'VENDOR';
        ELSIF l_q_party_uv_tbl(l_party_count).co_contact_object = 'OKX_OPERUNIT' THEN
            --l_recipient_type := 'O';
              l_recipient_type := 'LESSEE';
        END IF;

        l_recipient_desc := l_q_party_uv_tbl(l_party_count).co_contact_name;

  ELSIF l_q_party_uv_tbl(l_party_count).po_party_id1 IS NOT NULL THEN

        -- Recipient is at po party level
        l_recipient_id := l_q_party_uv_tbl(l_party_count).po_party_id1;

        IF l_q_party_uv_tbl(l_party_count).po_party_object = 'OKX_PARTY' THEN
            --l_recipient_type := 'P';
              l_recipient_type := 'LESSEE';
        ELSIF l_q_party_uv_tbl(l_party_count).po_party_object = 'OKX_VENDOR' THEN
            --l_recipient_type := 'V';
              l_recipient_type := 'VENDOR';
        ELSIF l_q_party_uv_tbl(l_party_count).po_party_object = 'OKX_OPERUNIT' THEN
            --l_recipient_type := 'O';
              l_recipient_type := 'LESSEE';
        END IF;

        l_recipient_desc := l_q_party_uv_tbl(l_party_count).po_party_name;

  ELSE
        OKC_API.SET_MESSAGE (
   p_app_name => OKC_API.G_APP_NAME,
   p_msg_name => 'NO_RECIPIENT',
   p_token1 => 'PARAM',
   p_token1_value => l_quote_id);

        RAISE MISSING_DETAILS_ERROR;

  END IF;

  IF l_q_party_uv_tbl(l_party_count).co_email IS NULL THEN
   -- Populate remaining Item Attributes for Fulfillment

     IF l_recipient_type IS NOT NULL THEN
         wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'RECIPIENT_TYPE',
                                     avalue  => l_recipient_type);
     ELSE
         OKC_API.SET_MESSAGE (
            p_app_name => OKC_API.G_APP_NAME,
            p_msg_name => 'NO_RECIPIENT_TYPE',
            p_token1 => 'PARAM',
            p_token1_value => l_quote_id);

         RAISE MISSING_DETAILS_ERROR;
     END IF;

     IF l_recipient_id IS NOT NULL THEN
         wf_engine.SetItemAttrText (
                  itemtype=> itemtype,
                  itemkey => itemkey,
                  aname   => 'RECIPIENT_ID',
                  avalue  => l_recipient_id);
    ELSE
         OKC_API.SET_MESSAGE (
          p_app_name => OKC_API.G_APP_NAME,
          p_msg_name => 'NO_RECIPIENT_ID',
          p_token1 => 'PARAM',
          p_token1_value => l_quote_id);

         RAISE MISSING_DETAILS_ERROR;
    END IF;
  END IF;

    IF l_party_type = 'APPROVER' AND l_recipient_desc IS NOT NULL THEN

        l_external_approver := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                      itemkey  => itemkey,
                    aname    => 'EXTERNAL_APPROVER');

        IF l_external_approver IS NOT NULL THEN
            l_external_approver := l_external_approver||'<tr><td>'||l_recipient_desc||'</td></tr>';
        ELSE
            l_external_approver := '<tr><td>'||l_recipient_desc||'</td></tr>';
        END IF;

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
            itemkey => itemkey,
            aname   => 'EXTERNAL_APPROVER',
                        avalue  => l_external_approver);

    END IF;
--19-jul-2007 ansethur  R12B XML Publisher Starts
    IF l_recipient_type IS NOT NULL THEN
        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'RECIPIENT_TYPE',
                                       avalue  => l_recipient_type);
    ELSE
        OKC_API.SET_MESSAGE (
                  p_app_name => OKC_API.G_APP_NAME,
                  p_msg_name => 'NO_RECIPIENT_TYPE',
                  p_token1 => 'PARAM',
                  p_token1_value => l_quote_id);

        RAISE MISSING_DETAILS_ERROR;
    END IF;

    IF l_recipient_id IS NOT NULL THEN
         wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'RECIPIENT_ID',
                                       avalue  => l_recipient_id);
    ELSE
        OKC_API.SET_MESSAGE (
                     p_app_name => OKC_API.G_APP_NAME,
                     p_msg_name => 'NO_RECIPIENT_ID',
                     p_token1 => 'PARAM',
                     p_token1_value => l_quote_id);

                     RAISE MISSING_DETAILS_ERROR;
    END IF;
--19-jul-2007 ansethur  R12B XML Publisher Ends
        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                    itemkey => itemkey,
                                    aname   => 'RECIPIENT_DESCRIPTION',
                                    avalue  => l_recipient_desc);

        -- Decrement party counter
         wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'PARTY_COUNT',
                                       avalue  => l_party_count-1);

-- If there is no email found on the quote party record
-- then return NO_EMAIL, the workflow bypasses the Fulfillment
-- request in this instance.
-- Logic changed for bug ????????
        IF l_q_party_uv_tbl(l_party_count).co_email IS NOT NULL THEN
            resultout := 'COMPLETE:NEXT';
        ELSE
            resultout := 'COMPLETE:NO_EMAIL';
        END IF;
  ELSE
         -- MDOKAL, 15-APR-2003 Bug 2862254, Fix for HTML Notification Issue
         WF_ENGINE.SetItemAttrText(
                            itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'EXTERNAL_APPROVER_DOC',
                          avalue   => 'plsql:okl_am_quotes_wf.pop_external_approver_doc/'||itemkey);

         resultout := 'COMPLETE:DONE';
  END IF;
 RETURN ;
END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

    EXCEPTION
     WHEN MISSING_DETAILS_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED : MISSING_DETAILS_ERROR');
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'GET_QUOTE_PARTY_DETAILS',
                        itemtype, itemkey, actid, funcmode);

  END GET_QUOTE_PARTY_DETAILS;

  -- Start of comments
  --
  -- Procedure Name : CHECK_FOR_ADVANCE_NOTICE
  -- Description    : Checks for any Advanced Notices
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE CHECK_FOR_ADVANCE_NOTICE(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS

    l_quote_id                      varchar2(100);

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version  CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
 l_msg_count      NUMBER  := OKL_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);
 l_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
 l_q_party_uv_rec    okl_am_parties_pvt.q_party_uv_rec_type;
    l_party_count  NUMBER;
    l_delay_days        NUMBER(10,4);

    CURSOR c_delay_days_csr(c_qte_id  NUMBER) IS
 SELECT  max(QP_DELAY_DAYS) DELAY_DAYS
 FROM   OKL_AM_QUOTE_PARTIES_UV
    WHERE  quote_id = c_qte_id
 AND    qp_role_code = 'ADVANCE_NOTICE';

    API_ERROR           EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_for_advance_notice';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        l_q_party_uv_rec.quote_id := l_quote_id;
        l_q_party_uv_rec.qp_role_code := 'ADVANCE_NOTICE';

  okl_am_parties_pvt.get_quote_parties (
   p_api_version  => l_api_version,
   p_init_msg_list  => l_init_msg_list,
   x_msg_count      => l_msg_count,
   x_msg_data      => l_msg_data,
   x_return_status  => l_return_status,
   p_q_party_uv_rec => l_q_party_uv_rec,
   x_q_party_uv_tbl => l_q_party_uv_tbl,
   x_record_count  => l_party_count);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_parties_pvt.get_quote_parties :'||l_return_status);
   END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

        IF l_party_count > 0 THEN

   OPEN c_delay_days_csr(l_quote_id);
   FETCH c_delay_days_csr INTO l_delay_days;
   CLOSE c_delay_days_csr;

            WF_ENGINE.SetItemAttrNumber( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'NOTICE_DELAY',
                                       avalue   => l_delay_days);

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_COUNT',
                                       avalue   => l_party_count);


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_TYPE',
                                       avalue   => 'ADVANCE_NOTICE');


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PROCESS_CODE',
                                       avalue   => 'AMTER');

             resultout := 'COMPLETE:Y';
        ELSE
             resultout := 'COMPLETE:N';
        END IF;

      RETURN ;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT_ADD',
                        itemtype, itemkey, actid, funcmode);

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;


        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_ADVANCE_NOTICE',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END CHECK_FOR_ADVANCE_NOTICE;

  -- Start of comments
  --
  -- Procedure Name : CHECK_FOR_RECIPIENT
  -- Description    : Checks for any RECIPIENT's
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE CHECK_FOR_RECIPIENT(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS



    l_quote_id                      varchar2(100);

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version  CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
 l_msg_count      NUMBER  := OKL_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);
 l_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
 l_q_party_uv_rec    okl_am_parties_pvt.q_party_uv_rec_type;
    l_party_count  NUMBER;

    API_ERROR           EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_for_recipient';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        l_q_party_uv_rec.quote_id := l_quote_id;
        l_q_party_uv_rec.qp_role_code := 'RECIPIENT';

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

  okl_am_parties_pvt.get_quote_parties (
   p_api_version  => l_api_version,
   p_init_msg_list  => l_init_msg_list,
   x_msg_count      => l_msg_count,
   x_msg_data      => l_msg_data,
   x_return_status  => l_return_status,
   p_q_party_uv_rec => l_q_party_uv_rec,
   x_q_party_uv_tbl => l_q_party_uv_tbl,
   x_record_count  => l_party_count);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_parties_pvt.get_quote_parties :'||l_return_status);
   END IF;

        IF l_party_count > 0 THEN

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_COUNT',
                                       avalue   => l_party_count);


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_TYPE',
                                       avalue   => 'RECIPIENT');


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PROCESS_CODE',
                                       avalue   => 'AMTER');

             resultout := 'COMPLETE:Y';
        ELSE
             resultout := 'COMPLETE:N';
        END IF;

      RETURN ;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT_ADD',
                        itemtype, itemkey, actid, funcmode);
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END CHECK_FOR_RECIPIENT;

  -- Start of comments
  --
  -- Procedure Name : CHECK_FOR_FYI
  -- Description    : Checks for any FYI's
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE CHECK_FOR_FYI(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS



    l_quote_id                      varchar2(100);

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version  CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
 l_msg_count      NUMBER  := OKL_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);
 l_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
 l_q_party_uv_rec    okl_am_parties_pvt.q_party_uv_rec_type;
    l_party_count  NUMBER;

    API_ERROR           EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_for_fyi';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        l_q_party_uv_rec.quote_id := l_quote_id;
        l_q_party_uv_rec.qp_role_code := 'FYI';

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

  okl_am_parties_pvt.get_quote_parties (
                           p_api_version  => l_api_version,
                           p_init_msg_list  => l_init_msg_list,
                           x_msg_count      => l_msg_count,
                           x_msg_data      => l_msg_data,
                           x_return_status  => l_return_status,
                           p_q_party_uv_rec => l_q_party_uv_rec,
                           x_q_party_uv_tbl => l_q_party_uv_tbl,
                           x_record_count  => l_party_count);


           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_parties_pvt.get_quote_parties :'||l_return_status);
           END IF;

        IF l_party_count > 0 THEN

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_COUNT',
                                       avalue   => l_party_count);


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_TYPE',
                                       avalue   => 'FYI');


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PROCESS_CODE',
                                       avalue   => 'AMTER');

             resultout := 'COMPLETE:Y';
        ELSE
             resultout := 'COMPLETE:N';
        END IF;

      RETURN ;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT_ADD',
                        itemtype, itemkey, actid, funcmode);
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_FYI',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END CHECK_FOR_FYI;

  -- Start of comments
  --
  -- Procedure Name : CHECK_FOR_RECIPIENT_ADD
  -- Description    : Checks for any additional recipients exists
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE CHECK_FOR_RECIPIENT_ADD(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS



    l_quote_id                      varchar2(100);

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version  CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
 l_msg_count      NUMBER  := OKL_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);
 l_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
 l_q_party_uv_rec    okl_am_parties_pvt.q_party_uv_rec_type;
    l_party_count  NUMBER;

    API_ERROR           EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_for_recipient_add';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                              itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        l_q_party_uv_rec.quote_id := l_quote_id;
        l_q_party_uv_rec.qp_role_code := 'RECIPIENT_ADDITIONAL';

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

  okl_am_parties_pvt.get_quote_parties (
   p_api_version  => l_api_version,
   p_init_msg_list  => l_init_msg_list,
   x_msg_count      => l_msg_count,
   x_msg_data      => l_msg_data,
   x_return_status  => l_return_status,
   p_q_party_uv_rec => l_q_party_uv_rec,
   x_q_party_uv_tbl => l_q_party_uv_tbl,
   x_record_count  => l_party_count);

	   IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
	       'after call to okl_am_parties_pvt.get_quote_parties :'||l_return_status);
	   END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

        IF l_party_count > 0 THEN

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_COUNT',
                                       avalue   => l_party_count);


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PARTY_TYPE',
                                       avalue   => 'RECIPIENT_ADDITIONAL');


            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                    itemkey  => itemkey,
                  aname    => 'PROCESS_CODE',
                                       avalue   => 'AMTER');

             resultout := 'COMPLETE:Y';
        ELSE
             resultout := 'COMPLETE:N';
        END IF;

      RETURN ;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT_ADD',
                        itemtype, itemkey, actid, funcmode);
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'CHECK_FOR_RECIPIENT_ADD',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END CHECK_FOR_RECIPIENT_ADD;

  -- Start of comments
  --
  -- Function Name : CHECK_CALC_OPTIONS
  -- Description    : Called when quote is gain/loss
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.1
  --History         : rkuttiya  22-SEP-2003  modified for Bug:2794685
  --                : RMUNJULU 03-OCT-03 2794685 Changed to get proper results
  -- End of comments

 FUNCTION CHECK_CALC_OPTIONS(itemtype IN  VARCHAR2,
                            itemkey      IN  VARCHAR2,
                            actid        IN  NUMBER,
                            funcmode     IN  VARCHAR2,
                            p_rgd_code   IN VARCHAR2,
                   p_khr_id     IN NUMBER,
                            p_qte_id     IN NUMBER )
  RETURN VARCHAR2
  IS

--rkuttiya 17-SEP-2003  commented for bug 2794685
/*    CURSOR c_qtl_csr(c_id NUMBER) IS
      SELECT *
      FROM   OKL_TXL_QUOTE_LINES_B
      WHERE  qte_id =c_id;
*/
    l_id         NUMBER;
    l_partial_yn    VARCHAR2(1);
    l_khr_id        NUMBER;
    l_rule_khr_id   NUMBER;
    l_qtp_code      VARCHAR2(30);
    l_qtev_rec      okl_trx_quotes_pub.qtev_rec_type;
    l_rgd_code      VARCHAR2(30);

    l_quote_total NUMBER := 0;
    l_quote_net  NUMBER := 0;
    l_tolerance  VARCHAR2(150);
    l_seq      NUMBER;

    l_rule_found BOOLEAN := FALSE;
  --l_check_gain_yn BOOLEAN := FALSE;
    l_line_formula_yn BOOLEAN := FALSE;
    l_always_approve_yn BOOLEAN := FALSE;

    l_calc_option VARCHAR2(150);
    l_fixed_value NUMBER;
    l_formula_name VARCHAR2(150);
    l_approval_formula  VARCHAR2(150);

    l_result VARCHAR2(50) := 'COMPLETE:NO';

    l_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;

--  rkuttiya 16-SEP-2003  Bug:2794685
    l_gain_loss_approval  VARCHAR2(100);
    l_tolerance_amount    NUMBER;
    l_formula_value       NUMBER;
    l_params           OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;
    l_net_gain_loss       NUMBER;
--  rkuttiya end;

    API_ERROR EXCEPTION;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_calc_options';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        --rkuttiya  17-SEP-2003    added for Bug:2794685
        l_params(1).name  := 'QUOTE_ID';
        l_params(1).value := p_qte_id;
        --rkuttiya end

     -- ***************************************
     -- Check tolerance calculation options for Gain/Loss
     -- ***************************************

     OKL_AM_UTIL_PVT.get_rule_record(
                                    p_rgd_code     => p_rgd_code,
                                    p_rdf_code     => 'AMGALO',
                                    p_chr_id     => p_khr_id,
                                    p_cle_id     => NULL,
                                    x_rulv_rec     => l_rulv_rec,
                                    x_return_status => l_return_status,
                                    p_message_yn => TRUE);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
           END IF;


     IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

                --rkuttiya 16-SEP-2003 added following code for bug:2794685
                l_calc_option           := l_rulv_rec.rule_information7;
                l_fixed_value           := NVL(TO_NUMBER(l_rulv_rec.rule_information4),0);
                l_formula_name          := l_rulv_rec.rule_information6;
                l_tolerance             := l_rulv_rec.rule_information5;
                l_approval_formula      := l_rulv_rec.rule_information8;
        ELSE
        RAISE API_ERROR;
     END IF;

       --rkuttiya 16-SEP-2003 added following code for bug:2794685
       IF l_calc_option = 'NOT_APPLICABLE' THEN -- Tolerance option not applicable

          l_gain_loss_approval := 'COMPLETE:STOP';
          G_STOP := 'TOPTION'; -- Tolerance Option is not set
          l_tolerance_amount := 0;

          RETURN  l_gain_loss_approval;  -- RMUNJULU 2794685 Added

       ELSIF l_calc_option = 'USE_FIXED_AMOUNT' THEN -- Tolerance option is amount -- RMUNJULU CHANGED FROM AMOUNT

          l_gain_loss_approval := 'COMPLETE:YES';
          l_tolerance_amount := l_fixed_value;

       ELSIF l_calc_option = 'USE_FORMULA' THEN -- Tolerance option is formula

          l_gain_loss_approval := 'COMPLETE:YES';

          -- Get tolerance amount from tolerance formula
          OKL_AM_UTIL_PVT.get_formula_value (
                 p_formula_name           => l_formula_name,
                 p_chr_id                 => p_khr_id, -- RMUNJULU Changed
                 p_cle_id                 => NULL,
                 p_additional_parameters  => l_params, -- RMUNJULU 2794685 Added
                 x_formula_value          => l_formula_value,
                 x_return_status          => l_return_status);

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            l_gain_loss_approval := 'COMPLETE:STOP';
               G_STOP := 'TFORMULAE'; -- Tolerance Formula has returned error

               RETURN  l_gain_loss_approval;    -- RMUNJULU 2794685 Added
            ELSE
             l_tolerance_amount := l_formula_value;
           END IF;
        END IF;

       --rkuttiya 17-SEP-2003  added following code for Bug:2794685
       -- Check Approval details
      IF l_approval_formula IS NULL THEN

         l_gain_loss_approval := 'COMPLETE:STOP';
         G_STOP := 'AFORMULA'; -- No Approval Processing Formula set

          RETURN  l_gain_loss_approval;  -- RMUNJULU 2794685 Added

      ELSE

         l_gain_loss_approval := 'COMPLETE:YES';

         -- Get Approval Processing Formula value : this will be the net gain loss for the quote
         OKL_AM_UTIL_PVT.get_formula_value (
                        p_formula_name           => l_approval_formula,
                        p_chr_id                 => p_khr_id, -- RMUNJULU Changed
                        p_cle_id                 => NULL,
                        p_additional_parameters  => l_params,
                        x_formula_value          => l_formula_value,
                        x_return_status          => l_return_status);

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          l_gain_loss_approval := 'COMPLETE:STOP';
             G_STOP := 'AFORMULAE'; -- Approval Processing Formula returned error

             RETURN  l_gain_loss_approval;  -- RMUNJULU 2794685 Added
           ELSE
             l_net_gain_loss := l_formula_value;
           END IF;
      END IF;

      --Comparing the net Gain Loss with the tolerance amount
      IF l_gain_loss_approval = 'COMPLETE:YES' THEN

         -- If Loss or gain less than tolerance then approval required
         IF l_net_gain_loss < l_tolerance_amount THEN -- RMUNJULU Changed

            l_gain_loss_approval := 'COMPLETE:YES'; -- Gain Loss Approval is needed

            wf_engine.SetItemAttrNumber(
                       itemtype => itemtype,
           itemkey  => itemkey,
           aname    => 'QUOTE_GL',
                       avalue   => (l_net_gain_loss));
         ELSE
            l_gain_loss_approval := 'COMPLETE:NO';   -- Gain Loss Approval is NOT needed
         END IF;
      END IF;

      RETURN  l_gain_loss_approval;

--rkuttiya 16-SEP-2003  commented the following code for Bug: 2794685
/*      l_calc_option := l_rulv_rec.rule_information1;
      l_fixed_value := NVL (To_Number (l_rulv_rec.rule_information2), 0);
      l_formula_name := l_rulv_rec.rule_information3;
      l_tolerance := NVL (To_Number (l_rulv_rec.rule_information4), 0);
*/


--rkuttiya 16-SEP-2003  commented the following code for Bug: 2794685

/*        IF    l_calc_option = 'NOT_APPLICABLE' THEN
      l_always_approve_yn := TRUE;

        ELSIF l_calc_option = 'USE_FIXED_AMOUNT' THEN
      l_quote_net := l_fixed_value;

        ELSIF l_calc_option = 'USE_FORMULA' THEN
      l_line_formula_yn := TRUE;

     ELSE
  -- Invalid combination of values for RULE rule in GROUP group
      okl_am_util_pvt.set_message(
                                p_app_name => 'OKL'
                               ,p_msg_name => 'OKL_AM_INVALID_RULE_FORMULA'
                               ,p_msg_level => OKL_AM_UTIL_PVT.G_DEBUG_LEVEL
                               ,p_token1 => 'GROUP'
                               ,p_token1_value => l_rgd_code
                               ,p_token2 => 'RULE'
                               ,p_token2_value => 'AMGALO');

      RAISE API_ERROR;
     END IF;
*/


--rkuttiya 16-SEP-2003  commented the following code for Bug: 2794685

/*

 -- *****************************
 -- Calculate taxable quote total
 -- *****************************

     IF NOT l_always_approve_yn THEN

            FOR l_rec in c_qtl_csr(l_id) LOOP

          IF NVL (l_rec.taxed_yn, 'N') <> 'Y' THEN
              l_quote_total := l_quote_total + NVL(l_rec.amount,0);
          END IF;
         END LOOP;

     END IF;

 -- ***********************************
 -- Calculate net quote using a formula
 -- ***********************************

     IF l_line_formula_yn THEN

            FOR l_rec in c_qtl_csr(l_id) LOOP

          l_formula_value := 0;
                okl_am_util_pvt.get_formula_value (
                               p_formula_name => l_formula_name,
                                   p_chr_id         => l_khr_id,
                                   p_cle_id         => l_rec.kle_id,
                                   x_formula_value => l_formula_value,
                                   x_return_status => l_return_status);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          RAISE API_ERROR;
      ELSE
          l_quote_net := l_quote_net + l_formula_value;
      END IF;

     END LOOP;

 END IF;

 -- *********************************
 -- Compare quote total and net quote
 -- *********************************

 IF (l_quote_total - l_quote_net < l_tolerance) OR (l_always_approve_yn) THEN

        wf_engine.SetItemAttrNumber( itemtype => itemtype,
                  itemkey  => itemkey,
                aname    => 'QUOTE_GL',
                                     avalue   => (l_quote_total - l_quote_net));
        l_result := 'COMPLETE:Y';
    ELSE
        l_result := 'COMPLETE:N';
 END IF;
*/


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

    EXCEPTION
     WHEN API_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_CALC_OPTIONS', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_CALC_OPTIONS', itemtype, itemkey, actid, funcmode);
        RAISE;

    END CHECK_CALC_OPTIONS;


  -- Start of comments
  --
  -- Procedure Name : validate_manual_quote_req
  -- Description    : Validates quote id on entry to Workflow
  --                  and gets merge field for notification message.
  --                : MDOKAL 20-MAR-2003
  --                : Modified procedure, no longer obtains notification
  --                  message details.
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.1
  --
  -- End of comments
  PROCEDURE VALIDATE_MANUAL_QUOTE_REQ( itemtype IN  VARCHAR2,
                itemkey   IN  VARCHAR2,
                   actid     IN  NUMBER,
                   funcmode IN  VARCHAR2,
                resultout OUT NOCOPY VARCHAR2) IS


    -- MDOKAL,  20-MAR-2003 BUG 2862254
    -- Modified cursor to retrieve only header details as the HTML body is now
    -- created in a separate procedure 'pop_oklamnmq_doc', now handled as a
    -- PL/SQL Document.

    -- Check quote exists
    CURSOR  get_quote_csr  ( p_qte_id   IN NUMBER)
    IS
    SELECT  trx.QUOTE_NUMBER
    ,       khr.short_description contract_name
    ,       khr.contract_number
    ,       trx.last_updated_by
    ,       trx.date_requested
    ,       decode(trx.QTP_CODE, 'TER_PURCHASE', 'Y', 'N') PURCHASE_ASSET
    ,       nvl(early_termination_yn, 'N') EOT
    ,       decode(nvl(partial_yn, 'N'), 'N', 'Y', 'N') COMPLETE_CONTRACT
    FROM    OKL_TRX_QUOTES_V trx,
            OKC_K_HEADERS_V khr
    WHERE   trx.id = p_qte_id
    and     trx.QST_CODE = 'DRAFTED'
    and     trx.khr_id  = khr.id;

    r_qte_details   get_quote_csr%rowtype;

    l_user_name   WF_USERS.name%type;
    l_name        WF_USERS.description%type;

    l_quote_id    NUMBER;
  -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_manual_quote_req';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

        l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                            aname    => 'TRANSACTION_ID');

        wf_engine.SetItemAttrText (
                                itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MESSAGE_DOC',
                              avalue  => 'plsql:okl_am_quotes_wf.pop_oklamnmq_doc/'||l_quote_id);

        OPEN get_quote_csr(l_quote_id);
        FETCH get_quote_csr INTO r_qte_details;
        CLOSE get_quote_csr;

        okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => r_qte_details.last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                             avalue  => l_user_name);

        wf_engine.SetItemAttrText (
                                itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'QUOTE_NUMBER',
                              avalue  => r_qte_details.quote_number);

        wf_engine.SetItemAttrText (
                                itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NUMBER',
                              avalue  => r_qte_details.contract_number);

        wf_engine.SetItemAttrText (
                                itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NAME',
                              avalue  => r_qte_details.contract_name);

        IF l_user_name IS NOT NULL THEN
            resultout := 'COMPLETE:VALID';
        ELSE
            resultout := 'COMPLETE:INVALID';
        END IF;
    END IF;
    RETURN ;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_quote_csr%ISOPEN THEN
           CLOSE get_quote_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'validate_quote_approval',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END VALIDATE_MANUAL_QUOTE_REQ;

  -- Start of comments
  --
  -- Procedure Name : VALIDATE_ACCEPT_REST_QTE
  -- Description    : Validates quote id on entry to Workflow
  -- Business Rules :
  -- Parameters     : itemtype, itemkey, actid, funcmode, resultout
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE VALIDATE_ACCEPT_REST_QTE( itemtype IN  VARCHAR2,
                itemkey   IN  VARCHAR2,
                   actid     IN  NUMBER,
                   funcmode IN  VARCHAR2,
                resultout OUT NOCOPY VARCHAR2) IS

    -- Check quote exists an d is either DRAFTED or REJECTED
  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR get_quote_csr SQL definition
    CURSOR  get_quote_csr  ( p_qte_id   IN VARCHAR2)
    IS
    SELECT  a.last_updated_by, a.quote_number
    FROM    OKL_TRX_QUOTES_B a,
            okl_quote_parties b
    WHERE   a.id = p_qte_id
    and     a.qst_code in ('ACCEPTED')
    and     b.qte_id (+) = a.id;

    l_last_updated_by               NUMBER;
    l_quote_id                      VARCHAR2(200);

    l_user_name   WF_USERS.name%type;
    l_name        WF_USERS.description%type;

 l_quote_number  VARCHAR2(100);
  -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_accept_rest_qte';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

      l_quote_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                            itemkey  => itemkey,
                          aname   => 'TRANSACTION_ID');

      OPEN  get_quote_csr(l_quote_id);
      FETCH get_quote_csr INTO l_last_updated_by, l_quote_number;
      CLOSE get_quote_csr;

      okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);
      -- Check that a quote id is returned for the TRANSACTION_ID given.

  IF l_last_updated_by IS NOT NULL AND l_user_name IS NOT NULL THEN

             wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                             avalue  => l_user_name);

             wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'WF_ADMINISTRATOR',
                              avalue  => l_user_name);

             wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'QUOTE_NUMBER',
                             avalue  => l_quote_number);

            resultout := 'COMPLETE:VALID';
         ELSE
            resultout := 'COMPLETE:INVALID';
         END IF;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_quote_csr%ISOPEN THEN
           CLOSE get_quote_csr;
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'VALIDATE_ACCEPT_REST_QTE',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END VALIDATE_ACCEPT_REST_QTE;


  -- Start of comments
  --
  -- Procedure Name : set_quote_approved_yn
  -- Description :
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE set_rest_qte_approved_yn( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS


    l_id            VARCHAR2(100);
    l_approved      VARCHAR2(1);

    x_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);
    p_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    x_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    p_api_version   NUMBER       := 1;
    p_init_msg_list VARCHAR2(1)  := FND_API.G_TRUE;

    API_ERROR       EXCEPTION;

    l_notify_response VARCHAR2(30);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_rest_qte_approved_yn';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');


        l_approved := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'APPROVED_YN');

        -- Set the quote status to REJECTED if the approval is declined
        -- else set to 'APPROVED'
        IF nvl(l_approved, 'Y') = 'N' THEN
            p_qtev_rec.QST_CODE := 'REJECTED';
        ELSE
            p_qtev_rec.QST_CODE := 'APPROVED';
            p_qtev_rec.DATE_APPROVED := SYSDATE;
        END IF;

        p_qtev_rec.ID := to_number(l_id);

        p_qtev_rec.APPROVED_YN := nvl(l_approved, 'Y');

        okl_qte_pvt.update_row( p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_qtev_rec        => p_qtev_rec,
                                x_qtev_rec        => x_qtev_rec);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_qte_pvt.update_row :'||x_return_status);
   END IF;

  IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            IF nvl(l_approved, 'Y') = 'Y' THEN
       resultout := 'COMPLETE:SUCCESS';
            ELSE
       resultout := 'COMPLETE:ERROR';
            END IF;
  ELSE
   RAISE API_ERROR;
  END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'set_rest_qte_approved_yn', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN


        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'set_rest_qte_approved_yn', itemtype, itemkey, actid, funcmode);
        RAISE;

  END set_rest_qte_approved_yn;

  -- Start of comments
  --
  -- Procedure Name : check_profile_recipient
  -- Description : check if the profile value for OKL_MANUAL_TERMINATION_QUOTE_REP
  --                  returns valid recipients.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_profile_recipient( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS


    l_id            VARCHAR2(100);
    l_performer     VARCHAR2(100);
    l_recipients    NUMBER;

    cursor c1_csr (p_value varchar)  is
       select count(*)
       from WF_USER_ROLES WUR
       where WUR.ROLE_NAME = p_value;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_profile_recipient';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        l_performer := rtrim(ltrim(fnd_profile.value('OKL_MANUAL_TERMINATION_QUOTE_REP')));

        wf_engine.SetItemAttrText( itemtype => itemtype,
                  itemkey  => itemkey,
                aname    => 'PERFORMING_AGENT',
                                     avalue   => l_performer);

        OPEN c1_csr (l_performer);
        FETCH c1_csr INTO l_recipients;
        CLOSE c1_csr;

  IF l_recipients > 0 THEN
      resultout := 'COMPLETE:VALID';
        ELSE
      resultout := 'COMPLETE:INVALID';
        END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN


        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF c1_csr%ISOPEN THEN
           CLOSE c1_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'check_profile_recipient', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_profile_recipient;


  -- Start of comments
  --
  -- Procedure Name : pop_oklamnmq_doc
  -- Description : MDOKAL, 20-MAR-2003 Bug 2862254
  --                  This procedure is invoked dynamically by Workflow API's
  --                  in order to populate the message body item attribute
  --                  during notification submission.
  -- Business Rules :
  -- Parameters  : document_id, display_type, document, document_type
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE pop_oklamnmq_doc (document_id   in varchar2,
                              display_type  in varchar2,
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS


    -- Check quote exists
    CURSOR  get_quote_csr  ( p_qte_id   IN NUMBER)
    IS
    SELECT  trx.QUOTE_NUMBER
    ,       khr.short_description contract_name
    ,       khr.contract_number
    ,       trx.last_updated_by
    ,       trx.date_requested
    ,       decode(trx.QTP_CODE, 'TER_PURCHASE', 'Y', 'N') PURCHASE_ASSET
    ,       nvl(early_termination_yn, 'N') EOT
    ,       decode(nvl(partial_yn, 'N'), 'N', 'Y', 'N') COMPLETE_CONTRACT
    ,       kle.ITEM_DESCRIPTION ASSET_NUMBER
    ,       txl.ASSET_QUANTITY ASSET_QUANTITY
    ,       txl.QUOTE_QUANTITY QUOTE_QUANTITY
    FROM    OKL_TRX_QUOTES_V trx,
            OKL_TXL_QUOTE_LINES_V txl,
            OKC_K_HEADERS_V khr,
            OKC_K_LINES_V   kle
    WHERE   trx.id = p_qte_id
    and     txl.qte_id (+) = trx.id
    and     trx.QST_CODE = 'DRAFTED'
    and     trx.khr_id  = khr.id
    and     txl.kle_id  = kle.id;

    r_qte_details   get_quote_csr%rowtype;

    l_user_name   WF_USERS.name%type;
    l_name        WF_USERS.description%type;

    l_quote_id    NUMBER;

    l_message        VARCHAR2(32000);
    l_header_done    BOOLEAN := FALSE;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_oklamnmq_doc';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        l_quote_id := document_id;

        FOR r_qte_details in get_quote_csr(l_quote_id) LOOP

        IF NOT l_header_done THEN

            okl_am_wf.get_notification_agent(
                                itemtype   => 'OKLAMNMQ'
                           , itemkey     => 'N/A'
                           , actid       => null
                           , funcmode   => 'RUN'
                              , p_user_id     => r_qte_details.last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);
            l_message :=
                      '<p>Requestor: '||l_user_name||'</p>'||
                      '<p>A termination quote has been requested for Contract No. '||r_qte_details.contract_number||' on '||r_qte_details.date_requested||
                      ' with the following parameters:</p> '||
                      '<table width="25%">'||
                      '<tr><td>End of Term:</td><td>'||r_qte_details.eot||'</td></tr>'||
                      '<tr><td>Complete Contract:</td><td>'||r_qte_details.complete_contract||'</td></tr>'||
                      '<tr><td>Purchase Asset:</td><td>'||r_qte_details.purchase_asset||'</td></tr>'||
                      '</table>';
            IF r_qte_details.complete_contract = 'N' THEN

               l_message := l_message||'<p>Asset Details for Partial Contract:</p>'||
                      '<table width="50%" border="1">'||
                      '<tr>'||
                      '<td><b>Asset No.</b></td>'||
                      '<td><b>Asset Quantity</b></td>'||
                      '<td><b>Quote Quantity</b></td>'||
                      '</tr>';
            END IF;

            l_header_done := TRUE;
        END IF;
        IF r_qte_details.complete_contract = 'N' THEN
            l_message  :=  l_message||'<tr>'||
                                '<td>'||r_qte_details.asset_number||'</td>'||
                                '<td>'||r_qte_details.asset_quantity||'</td>'||
                                '<td>'||r_qte_details.quote_quantity||'</td>'||
                                '</tr>';
        END IF;
        END LOOP;
        IF r_qte_details.complete_contract = 'N' THEN
            l_message  :=  l_message||'</table>';
        END IF;

        document := l_message;
        document_type := display_type;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

        RETURN;
  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF get_quote_csr%ISOPEN THEN
           CLOSE get_quote_csr;
        END IF;

  END pop_oklamnmq_doc;

  -- Start of comments
  --
  -- Procedure Name : pop_oklamppt_doc
  -- Description : MDOKAL, 21-MAR-2003 Bug 2862254
  --                  This procedure is invoked dynamically by Workflow API's
  --                  in order to populate the message body item attribute
  --                  during notification submission. Called from Termication
  --                  Quote Acceptance (OKLAMPPT)
  -- Business Rules :
  -- Parameters  : document_id, display_type, document, document_type
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE pop_oklamppt_doc (document_id   in varchar2,
                              display_type  in varchar2,
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

    l_message        VARCHAR2(32000);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_oklamppt_doc';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        l_message := wf_engine.GetItemAttrText (
                                itemtype            => 'OKLAMPPT',
                    itemkey             => document_id,
                    aname               => 'MESSAGE_DESCRIPTION');

        document := l_message;
        document_type := display_type;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

	RETURN;

  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
     NULL;

  END pop_oklamppt_doc;



  -- Start of comments
  --
  -- Procedure Name : pop_external_approver_doc
  -- Description : MDOKAL, 15-APR-2003 Bug 2902588
  --                  This procedure is invoked dynamically by Workflow API's
  --                  in order to populate the message body item attribute
  --                  during notification submission. Called from Send Quote
  --                  (OKLAMNQT)
  -- Business Rules :
  -- Parameters  : document_id, display_type, document, document_type
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE pop_external_approver_doc (document_id   in varchar2,
                              display_type  in varchar2,
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

    l_message        VARCHAR2(32000);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_external_approver_doc';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        l_message := wf_engine.GetItemAttrText (
                                itemtype            => 'OKLAMNQT',
                    itemkey             => document_id,
                    aname               => 'EXTERNAL_APPROVER');

        document := l_message;
        document_type := display_type;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

        RETURN;

  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     NULL;

  END pop_external_approver_doc;

  -- Start of comments
  --
  -- Procedure Name : update_partial_quote
  -- Description : Called from Send Quote (OKLAMNQT)
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE update_partial_quote( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_approved      VARCHAR2(1);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'update_partial_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_approved := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'APPROVED_YN');

        IF nvl(l_approved, 'Y') = 'Y' THEN
       resultout := 'COMPLETE:APPROVED';
        ELSE
       resultout := 'COMPLETE:REJECTED';
        END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'update_partial_quote', itemtype, itemkey, actid, funcmode);
        RAISE;

  END update_partial_quote;

  -- Start of comments
  --
  -- Procedure Name : update_gain_loss_quote
  -- Description : Called from Send Quote (OKLAMNQT)
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE update_gain_loss_quote( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_approved      VARCHAR2(1);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'update_gain_loss_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_approved := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'APPROVED_YN');

        IF nvl(l_approved, 'Y') = 'Y' THEN
       resultout := 'COMPLETE:APPROVED';
        ELSE
       resultout := 'COMPLETE:REJECTED';
        END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'update_gain_loss_quote', itemtype, itemkey, actid, funcmode);
        RAISE;

  END update_gain_loss_quote;

  -- Start of comments
  --
  -- Procedure Name : chk_securitization
  -- Description : Called from Terminate Quote Acceptance (OKLAMPPT)
  --                  Bug 3082639
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  -- History        : rmunjulu EDAT Added code to pass quote dates to securitization API
  --
  -- End of comments
  PROCEDURE chk_securitization( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_quote_id      VARCHAR2(100);

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version  CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
 l_msg_count      NUMBER  := OKL_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);

    API_ERROR           EXCEPTION;


    -- rmunjulu EDAT -- get quote dates
    CURSOR get_quote_values_csr (p_qte_id IN NUMBER) IS
       SELECT qte.date_effective_from,
              qte.date_accepted
       FROM   OKL_TRX_QUOTES_B  qte
       WHERE  qte.id = p_qte_id;

    l_quote_eff_date DATE;
    l_quote_accpt_date DATE;
  -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'chk_securitization';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_quote_id := wf_engine.GetItemAttrText( itemtype   => itemtype,
                              itemkey => itemkey,
                            aname   => 'TRANSACTION_ID');

        -- rmunjulu EDAT Added to get quote dates which are now passed to securitization API
        OPEN get_quote_values_csr (l_quote_id);
        FETCH get_quote_values_csr INTO l_quote_eff_date, l_quote_accpt_date;
        CLOSE get_quote_values_csr;

        -- call the securitization API to check for securitized components
        -- on the quote. If found create investor disbursements
        OKL_AM_SECURITIZATION_PVT.process_securitized_streams(
            p_api_version  => l_api_version,
            p_init_msg_list  => l_init_msg_list,
            x_return_status  => l_return_status,
            x_msg_count   => l_msg_count,
            x_msg_data   => l_msg_data,
            p_quote_id   => l_quote_id,
            p_effective_date    => l_quote_eff_date,   -- rmunjulu EDAT Added
            p_transaction_date  => l_quote_accpt_date, -- rmunjulu EDAT Added
            p_call_origin       => OKL_SECURITIZATION_PVT.G_TRX_REASON_EARLY_TERMINATION);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_SECURITIZATION_PVT.process_securitized_streams :'||l_return_status);
   END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
        END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        -- rmunjulu EDAT
        IF get_quote_values_csr%ISOPEN THEN
           CLOSE get_quote_values_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'chk_securitization', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        -- rmunjulu EDAT
        IF get_quote_values_csr%ISOPEN THEN
           CLOSE get_quote_values_csr;
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'chk_securitization', itemtype, itemkey, actid, funcmode);
        RAISE;

  END chk_securitization;

  -- Start of comments
  --
  -- Procedure Name : update_partial_quote
  -- Description : Updates Quote status to Drafted when Check_if_Quote_gain_loss ends in STOP
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  -- History            : RKUTTIYA created for Bug: 2794685
  -- End of comments

  PROCEDURE update_quote_drafted(itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2) AS

    l_transaction_id            VARCHAR2(2000);
    l_api_version               NUMBER := 1;
    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(2000);
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;
    lx_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;
    l_quote_status              VARCHAR2(200) := 'DRAFTED';--'OKL_QUOTE_STATUS'
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'update_quote_drafted';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN
      --get attr for transaction id which is the quote id for quote WFs
      l_transaction_id := WF_ENGINE.GetItemAttrText(
                                           itemtype => itemtype,
                        itemkey => itemkey,
                      aname    => 'TRANSACTION_ID');

      -- set the qtev_rec_type of quote header
      lp_qtev_rec.id                    :=    TO_NUMBER(l_transaction_id);
      lp_qtev_rec.qst_code              :=    l_quote_status;

      -- Call the update of the quote header api
      OKL_TRX_QUOTES_PUB.update_trx_quotes (
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKL_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => lx_msg_count,
           x_msg_data                     => lx_msg_data,
           p_qtev_rec                     => lp_qtev_rec,
           x_qtev_rec                     => lx_qtev_rec);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to  OKL_TRX_QUOTES_PUB.update_trx_quotes :'||l_return_status);
   END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION;
      ELSE
        resultout := 'COMPLETE:';
      END IF;
      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'update_quote_status',
                        itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        WF_CORE.context('OKL_AM_QUOTES_WF' , 'update_quote_status',
                        itemtype, itemkey, actid, funcmode);
        RAISE;


   END update_quote_drafted;

  -- Start of comments
  --
  -- Procedure Name : set_message
  -- Desciption     : Sets the message with tokens
  --                  Does NOT put the message on the message stack
  --                  This set_message is used instead of the standard OKL_API.set_message
  --                  because the OKL_API.set_message puts the message on message stack after
  --                  which it cannot be retrieved using FND_MESSAGE.get
  -- Business Rules :
  -- Parameters     :
  -- Version  : 1.0
  -- History        : RMUNJULU created 4131592
  --
  -- End of comments
  PROCEDURE set_message (
 p_app_name  IN VARCHAR2 DEFAULT 'OKL',
 p_msg_name  IN VARCHAR2,
 p_token1  IN VARCHAR2 DEFAULT NULL,
 p_token1_value IN VARCHAR2 DEFAULT NULL,
 p_token2  IN VARCHAR2 DEFAULT NULL,
 p_token2_value IN VARCHAR2 DEFAULT NULL,
 p_token3  IN VARCHAR2 DEFAULT NULL,
 p_token3_value IN VARCHAR2 DEFAULT NULL,
 p_token4  IN VARCHAR2 DEFAULT NULL,
 p_token4_value IN VARCHAR2 DEFAULT NULL,
 p_token5  IN VARCHAR2 DEFAULT NULL,
 p_token5_value IN VARCHAR2 DEFAULT NULL,
 p_token6  IN VARCHAR2 DEFAULT NULL,
 p_token6_value IN VARCHAR2 DEFAULT NULL,
 p_token7  IN VARCHAR2 DEFAULT NULL,
 p_token7_value IN VARCHAR2 DEFAULT NULL,
 p_token8  IN VARCHAR2 DEFAULT NULL,
 p_token8_value IN VARCHAR2 DEFAULT NULL,
 p_token9  IN VARCHAR2 DEFAULT NULL,
 p_token9_value IN VARCHAR2 DEFAULT NULL,
 p_token10  IN VARCHAR2 DEFAULT NULL,
 p_token10_value IN VARCHAR2 DEFAULT NULL ) IS

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_message';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

 FND_MESSAGE.set_name( P_APP_NAME, P_MSG_NAME);

 IF (p_token1 IS NOT NULL) AND (p_token1_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token1,
                 VALUE  => p_token1_value);
 END IF;

 IF (p_token2 IS NOT NULL) AND (p_token2_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token2,
                 VALUE  => p_token2_value);
 END IF;

 IF (p_token3 IS NOT NULL) AND (p_token3_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token3,
                 VALUE  => p_token3_value);
 END IF;

 IF (p_token4 IS NOT NULL) AND (p_token4_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token4,
                 VALUE  => p_token4_value);
 END IF;

 IF (p_token5 IS NOT NULL) AND (p_token5_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token5,
                 VALUE  => p_token5_value);
 END IF;

 IF (p_token6 IS NOT NULL) AND (p_token6_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token6,
                 VALUE  => p_token6_value);
 END IF;
 IF (p_token7 IS NOT NULL) AND (p_token7_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token7,
                 VALUE  => p_token7_value);
 END IF;

 IF (p_token8 IS NOT NULL) AND (p_token8_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token8,
                 VALUE  => p_token8_value);
 END IF;
 IF (p_token9 IS NOT NULL) AND (p_token9_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token9,
                 VALUE  => p_token9_value);
 END IF;

 IF (p_token10 IS NOT NULL) AND (p_token10_value IS NOT NULL) THEN
  FND_MESSAGE.set_token( TOKEN  => p_token10,
                 VALUE  => p_token10_value);
 END IF;

 --FND_MSG_PUB.add;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  END set_message;

  -- Start of comments
  --
  -- Procedure Name : check_rollover_amount
  -- Description : Checks if Rollover Quote and if base amount > 0
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  -- History        : rmunjulu created for Bug: 4131592
  -- End of comments
  PROCEDURE check_rollover_amount(
                                    itemtype    IN  VARCHAR2,
                                    itemkey   IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS
    -- Get the quote details
    CURSOR c_qte_csr(c_id NUMBER) IS
    SELECT  khr_id, qtp_code,last_updated_by
    FROM    OKL_TRX_QUOTES_B
    WHERE   id = c_id;

    -- Get the quote BASE amount
    CURSOR c_qtl_csr(c_id NUMBER) IS
    SELECT sum(amount) amount
    FROM   OKL_TXL_QUOTE_LINES_B
    WHERE  qte_id =c_id
    AND    qlt_code NOT IN ('AMCFIA','AMYOUB','BILL_ADJST');

    l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

    l_result VARCHAR2(50) := 'COMPLETE:NO';

    l_last_updated_by    NUMBER;
    l_user_name          VARCHAR2(200);
    l_name               VARCHAR2(200);
    l_amount        NUMBER;
    l_id         NUMBER;
    l_khr_id        NUMBER;
    l_qtp_code      VARCHAR2(30);
    l_roll_message_header VARCHAR2(350);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_rollover_amount';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN

        l_id := wf_engine.GetItemAttrText(
                       itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'TRANSACTION_ID');

        OPEN c_qte_csr(l_id);
        FETCH c_qte_csr INTO l_khr_id, l_qtp_code,l_last_updated_by;
        CLOSE c_qte_csr;

        IF l_qtp_code like ('TER_ROLL%') THEN

           OPEN  c_qtl_csr (l_id);
           FETCH c_qtl_csr INTO l_amount;
           CLOSE c_qtl_csr;

           IF l_amount IS NULL THEN
              l_amount := 0;
           END IF;

           IF l_amount <= 0 THEN
              l_result := 'COMPLETE:STOP';
           ELSE
              l_result := 'COMPLETE:YES';
           END IF;

           IF l_result = 'COMPLETE:STOP' THEN

-- Rollover Quote Amount Approval.
              -- Get the proper message from Seed
              set_message(
                   p_app_name     => 'OKL',
                   p_msg_name     => 'OKL_AM_ROLL_HDR_MSG');

              l_roll_message_header := FND_MESSAGE.get;

              wf_engine.SetItemAttrText (
                              itemtype=> itemtype,
                  itemkey => itemkey,
                  aname   => 'MESSAGE_HEADER',
                            avalue  => l_roll_message_header);

              --Set notification body
              wf_engine.SetItemAttrText (
                              itemtype=> itemtype,
                  itemkey => itemkey,
                  aname   => 'MESSAGE_DOC',
                            avalue  => 'plsql:okl_am_quotes_wf.pop_roll_notification/'||l_id);

              --get the name of requestor
              okl_am_wf.get_notification_agent(
                           itemtype           => itemtype
                         , itemkey            => itemkey
                         , actid           => actid
                         , funcmode           => funcmode
                         , p_user_id          => l_last_updated_by
                         , x_name             => l_user_name
                         , x_description      => l_name);

              --set the value for item attribute 'REQUESTER'
              wf_engine.SetItemAttrText (
                               itemtype    => itemtype,
                   itemkey     => itemkey,
                   aname       => 'REQUESTER',
                            avalue      => l_user_name);
            END IF;
        ELSE
              l_result := 'COMPLETE:YES';
        END IF;

        resultout := l_result;

        RETURN;
    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        IF c_qte_csr%ISOPEN THEN
           CLOSE c_qte_csr;
        END IF;
        IF c_qtl_csr%ISOPEN THEN
           CLOSE c_qtl_csr;
        END IF;
        wf_core.context('OKL_AM_QUOTES_WF' , 'check_rollover_amount', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_rollover_amount;

  -- Start of comments
  --
  -- Procedure Name : pop_roll_notification
  -- Description : Populates the rollover notification message
  -- Business Rules :
  -- Parameters  : document_id,display_type, document, document_type
  -- Version  : 1.0
  -- History        : rmunjulu created for Bug: 4131592
  -- End of comments
  PROCEDURE pop_roll_notification (document_id   IN VARCHAR2,
                                   display_type  IN VARCHAR2,
                                   document      IN OUT NOCOPY VARCHAR2,
                                   document_type IN OUT NOCOPY VARCHAR2) IS

    -- Cursor to obtain quote and contract details
    CURSOR  l_quote_csr  ( p_qte_id   IN NUMBER) IS
    SELECT  TRX.ID,
            TRX.QUOTE_NUMBER,
            TRX.KHR_ID,
            TRX.QTP_CODE,
            KHR.CONTRACT_NUMBER
    FROM    OKL_TRX_QUOTES_B TRX,
            OKC_K_HEADERS_B KHR
    WHERE   TRX.id = p_qte_id
    AND     TRX.KHR_ID = KHR.ID;

    -- Cursor to obtain quote amount
    CURSOR  l_quote_amt_csr  ( p_qte_id   IN NUMBER) IS
    SELECT  nvl(SUM(amount),0) amount
    FROM    OKL_TXL_QUOTE_LINES_B TQL
    WHERE   TQL.qte_id = p_qte_id
    AND     TQL.qlt_code NOT IN ('AMCFIA','AMYOUB','BILL_ADJST');


    l_quote_rec         l_quote_csr%rowtype;
    l_quote_amt_rec     l_quote_amt_csr%rowtype;
    l_quote_id          NUMBER;
    l_message           VARCHAR2(32000);
    l_pos               NUMBER;
    l_noti_msg          VARCHAR2(32000);
    l_currency_code     VARCHAR2(200);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_roll_notification';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        --get the parameters from document id
        l_quote_id   := TO_NUMBER(document_id);

        --get quote and contract details
        OPEN l_quote_csr(l_quote_id);
        FETCH l_quote_csr INTO l_quote_rec;
        CLOSE l_quote_csr;

        --get quote amount
        OPEN l_quote_amt_csr(l_quote_id);
        FETCH l_quote_amt_csr INTO l_quote_amt_rec;
        CLOSE l_quote_amt_csr;

        -- Get the Currency Code
        l_currency_code  := OKL_AM_UTIL_PVT.get_chr_currency(l_quote_rec.khr_id);

-- The termination quote approval process for Contract Number, Quote Number has resulted in error.
-- The quote base amount is amount which is less than or equal to 0.
-- Please verify and change the quote amounts and re-submit the quote for approval.
        -- Get the proper message from Seed
        set_message(
                   p_app_name     => 'OKL',
                   p_msg_name     => 'OKL_AM_ROLL_NOTI_MSG',
                   p_token1       => 'CONTRACT_NUMBER',
                   p_token1_value => l_quote_rec.contract_number,
                   p_token2       => 'QUOTE_NUMBER',
                   p_token2_value => l_quote_rec.quote_number,
                   p_token3       => 'AMOUNT',
                   p_token3_value => l_quote_amt_rec.amount,
                   p_token4       => 'CURRENCY',
                   p_token4_value => l_currency_code);

        l_noti_msg := FND_MESSAGE.get;

        l_message :=  '<html><body><p>'||l_noti_msg||'</p></body></html>';

        document := l_message;
        document_type := display_type;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

        RETURN;
  EXCEPTION
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF l_quote_csr%ISOPEN THEN
           CLOSE l_quote_csr;
        END IF;

        IF l_quote_amt_csr%ISOPEN THEN
           CLOSE l_quote_amt_csr;
        END IF;

        RETURN;
  END pop_roll_notification;

  --rkuttiya 12-Nov-07 added for Sprint 2 of Loans Repossession
   PROCEDURE check_if_repo_quote(itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2,
                                actid    IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2) IS

    CURSOR check_repo_csr(p_qte_id IN NUMBER) IS
    SELECT repo_quote_indicator_yn
    FROM OKL_TRX_QUOTES_B
    WHERE id = p_qte_id;

    l_id       NUMBER;
    l_repo_yn  VARCHAR2(1);
    lx_return_sts VARCHAR2(1);
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'check_if_repo_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
   BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

     IF (funcmode = 'RUN') THEN
       l_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRANSACTION_ID');


       l_repo_yn := OKL_AM_CREATE_QUOTE_PVT.check_repo_quote(l_id,
                                                             lx_return_sts);

       IF lx_return_sts = OKL_API.G_RET_STS_SUCCESS THEN
         IF l_repo_yn = 'Y' THEN
            resultout := 'COMPLETE:Y';
         ELSIF NVL(l_repo_yn,'N') = 'N' THEN
            resultout := 'COMPLETE:N';
         END IF;
       ELSE
         RAISE G_EXCEPTION;
       END IF;
       RETURN;
     END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

   EXCEPTION
      WHEN G_EXCEPTION THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_IF_REPO_QUOTE', itemtype,
                         itemkey, actid, funcmode);
       RAISE;
      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        wf_core.context('OKL_AM_QUOTES_WF' , 'CHECK_IF_REPO_QUOTE', itemtype,
                         itemkey, actid, funcmode);
        RAISE;
   END CHECK_IF_REPO_QUOTE;


   PROCEDURE create_repo_asset_return(itemtype IN VARCHAR2,
                                    itemkey  IN VARCHAR2,
                                    actid    IN NUMBER,
                                    funcmode IN VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) IS
   CURSOR c_quote_assets_csr(p_qte_id IN NUMBER) IS
   SELECT kle_id, DATE_EFFECTIVE_FROM, CURRENCY_CODE -- 6736148
   FROM OKL_AM_ASSET_QUOTES_UV
   WHERE id = p_qte_id;

   CURSOR c_asset_return_csr(p_line_id IN NUMBER) IS
   SELECT COUNT(kle_id)
   FROM OKL_ASSET_RETURNS_B
   WHERE kle_id = p_line_id
   AND ARS_CODE <> 'CANCELLED';

   CURSOR c_khr_csr(p_qte_id IN NUMBER) IS
   SELECT khr_id
   FROM OKL_TRX_QUOTES_B
   WHERE ID = p_qte_id;

   CURSOR c_system_options(p_org_id IN NUMBER) IS
   SELECT B.NAME
   FROM   OKL_SYSTEM_PARAMS_ALL A,
          OKL_FORMULAE_B B
   WHERE  A.ORG_ID = p_org_id
   AND    A.FORMULA_ID = B.ID (+);

   l_formula_name OKL_FORMULAE_B.NAME%TYPE;

   l_id           NUMBER;
   l_ret_exists   VARCHAR2(1);
   l_count        NUMBER;
   l_contract_id  NUMBER;
   l_org_id       NUMBER;

   l_api_version               NUMBER := 1;
   lx_msg_count                NUMBER;
   lx_msg_data                 VARCHAR2(2000);
   l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;
   lx_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_repo_asset_return';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    /* Bug 6712322 start */
    l_params	       OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;
    l_asset_return_value NUMBER;
    /* Bug 6712322 end */
    /* Bug 6736148 start */
    l_func_curr_code  GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    lx_contract_currency         okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount          NUMBER;
    /* Bug 6736148 end */
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    l_func_curr_code := okl_am_util_pvt.get_functional_currency;

    IF funcmode = 'RUN' THEN
      l_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRANSACTION_ID');

      OPEN c_khr_csr(l_id);
      FETCH c_khr_csr INTO l_contract_id;
      CLOSE c_khr_csr;

      l_org_id := OKL_AM_UTIL_PVT.get_chr_org_id(l_contract_id);

      FOR l_assets IN c_quote_assets_csr(l_id) LOOP
        OPEN c_asset_return_csr(l_assets.kle_id);
        FETCH c_asset_return_csr INTO l_count;
        CLOSE c_asset_return_csr;

        IF l_count > 0 THEN
          l_ret_exists := 'Y';
        ELSE
          l_ret_exists := 'N';
        END IF;

        IF l_ret_exists = 'N' THEN
          --call the asset return api to create the return

          lp_artv_rec.kle_id := l_assets.kle_id;
          lp_artv_rec.art1_code := 'REPOS_REQUEST';
          lp_artv_rec.ars_code  := 'SCHEDULED';

          -- Set the contract org id to the application
          MO_GLOBAL.set_policy_context ('S', l_org_id);

          /* 6712322 */
          l_formula_name := NULL;
          OPEN c_system_options(l_org_id);
          FETCH c_system_options INTO l_formula_name;
          CLOSE c_system_options;

          /* 6712322 Evaluate ASSET_RETURN_VALUE formula and attach */
          -- set the operands for formula engine with quote_id
          IF (l_formula_name IS NOT NULL AND
               l_formula_name <> OKL_API.G_MISS_CHAR) THEN
            l_params(1).name := 'quote_id';
            l_params(1).value := to_char(l_id);

            /*OKL_EXECUTE_FORMULA_PUB.execute(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKL_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => lx_msg_count,
                      x_msg_data      => lx_msg_data,
                      p_formula_name  => 'ASSET_RETURN_VALUE',
                      p_contract_id   => l_contract_id,
                      p_line_id       => l_assets.kle_id,
                      x_value         => l_asset_return_value); */

              OKL_AM_UTIL_PVT.get_formula_value (
		        --p_formula_name	  => 'ASSET_RETURN_AMOUNT',
			p_formula_name	          => l_formula_name,
			p_chr_id	          => l_contract_id,
			p_cle_id                  => l_assets.kle_id,
    			p_additional_parameters   => l_params,
			x_formula_value           => l_asset_return_value,
			x_return_status	          => l_return_status);


            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;

            lp_artv_rec.asset_fmv_amount  := l_asset_return_value;

            /* Bug 6736148 start */
            IF (l_assets.CURRENCY_CODE <> l_func_curr_code) THEN

	      IF (is_debug_statement_on) THEN
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling okl_accounting_util.convert_to_functional_currency');
	      END IF;

              okl_accounting_util.convert_to_functional_currency(
   	            p_khr_id  		       => l_contract_id,
   	            p_to_currency   	       => l_func_curr_code,
   	            p_transaction_date 	       => l_assets.DATE_EFFECTIVE_FROM,
   	            p_amount 		       => l_asset_return_value,
                    x_return_status	       => l_return_status,
   	            x_contract_currency	       => lx_contract_currency,
   		    x_currency_conversion_type => lx_currency_conversion_type,
   		    x_currency_conversion_rate => lx_currency_conversion_rate,
   		    x_currency_conversion_date => lx_currency_conversion_date,
   		    x_converted_amount 	       => lx_converted_amount );

	      IF (is_debug_statement_on) THEN
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called okl_accounting_util.convert_to_functional_currency, l_return_status: ' || l_return_status);
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_contract_currency: ' || lx_contract_currency);
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_type: ' || lx_currency_conversion_type);
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_rate: ' || lx_currency_conversion_rate);
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_date: ' || lx_currency_conversion_date);
		OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_converted_amount: ' || lx_converted_amount);
	      END IF;

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              lp_artv_rec.asset_fmv_amount  := lx_converted_amount;

            END IF;
            /* Bug 6736148 end */

          END IF;

          OKL_AM_ASSET_RETURN_PVT.create_asset_return(
                             p_api_version        =>  l_api_version,
                             p_init_msg_list      => OKL_API.G_FALSE,
                             x_return_status      => l_return_status,
                             x_msg_count          => lx_msg_count,
                             x_msg_data           => lx_msg_data,
                             p_artv_rec		  => lp_artv_rec,
                             x_artv_rec		  => lx_artv_rec,
                             p_quote_id           => l_id) ;

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to OKL_AM_ASSET_RETURN_PVT.create_asset_return :'||l_return_status);
           END IF;

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION;
          ELSE
            resultout := 'COMPLETE:';
          END IF;
        ELSIF l_ret_exists = 'Y' THEN
         resultout := 'COMPLETE:';
        END IF;
      END LOOP;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
         IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN G_EXCEPTION THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

        IF c_quote_assets_csr%ISOPEN THEN
          CLOSE c_quote_assets_csr;
        END IF;

        IF c_asset_return_csr%ISOPEN THEN
          CLOSE c_asset_return_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'create_repo_asset_return',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

    WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF c_quote_assets_csr%ISOPEN THEN
          CLOSE c_quote_assets_csr;
        END IF;

        IF c_asset_return_csr%ISOPEN THEN
          CLOSE c_asset_return_csr;
        END IF;
        WF_CORE.context('OKL_AM_QUOTES_WF' , 'create_repo_asset_return',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END create_repo_asset_return;


END OKL_AM_QUOTES_WF;

/
