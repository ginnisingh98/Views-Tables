--------------------------------------------------------
--  DDL for Package Body OKS_WF_K_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_WF_K_PROCESS_PVT" AS
/* $Header: OKSVKWFB.pls 120.59.12010000.5 2009/10/29 07:08:21 vgujarat ship $ */

 ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKS_WF_K_PROCESS_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKS';

  G_LEVEL_PROCEDURE            CONSTANT   NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'oks.plsql.'||g_pkg_name||'.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=515; -- OKS Application

  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_WARNING            CONSTANT   VARCHAR2(1) := 'W';
  G_RET_STS_ALREADY_PUBLISHED  CONSTANT   VARCHAR2(1) := 'P';
  G_RET_STS_ACTION_NOT_ALWD    CONSTANT   VARCHAR2(1) := 'C';

  G_ITEM_TYPE                  CONSTANT   VARCHAR2(30)  := 'OKSKPRCS';
  G_MAIN_PROCESS               CONSTANT   VARCHAR2(30)  := 'K_PROCESS';

  G_RENEW_TYPE_ONLINE        CONSTANT   VARCHAR2(30) := 'ERN';
  G_RENEW_TYPE_EVERGREEN     CONSTANT   VARCHAR2(30) := 'EVN';
  G_RENEW_TYPE_MANUAL        CONSTANT   VARCHAR2(30) := 'NSR';
  G_NEW_CONTRACT             CONSTANT   VARCHAR2(30) := 'MANUAL';

  G_NEG_STS_PRE_DRAFT        CONSTANT   VARCHAR2(30) := 'PREDRAFT';
  G_NEG_STS_DRAFT            CONSTANT   VARCHAR2(30) := 'DRAFT';
  G_NEG_STS_QUOTE_SENT       CONSTANT   VARCHAR2(30) := 'SNT';
  G_NEG_STS_QPUB_QA_FAIL     CONSTANT   VARCHAR2(30) := 'QPUB_QA_FAIL';
  G_NEG_STS_PEND_PUBLISH     CONSTANT   VARCHAR2(30) := 'PEND_PUBLISH';
  G_NEG_STS_PEND_IA          CONSTANT   VARCHAR2(30) := 'PENDING_IA';
  G_NEG_STS_REJECTED         CONSTANT   VARCHAR2(30) := 'REJECTED';
  G_NEG_STS_ASSIST_REQD      CONSTANT   VARCHAR2(30) := 'ASSIST_REQD';
  G_NEG_STS_IA_QA_FAIL       CONSTANT   VARCHAR2(30) := 'IA_QA_FAIL';
  G_NEG_STS_IA_FAIL          CONSTANT   VARCHAR2(30) := 'IA_FAIL';
  G_NEG_STS_PEND_ACTIVATION  CONSTANT   VARCHAR2(30) := 'PEND_ACTIVATION';
  -- In order to keep the compatibility maintained the same code
  G_NEG_STS_QUOTE_ACPTD      CONSTANT   VARCHAR2(30) := 'ACT';
  G_NEG_STS_QUOTE_DECLD      CONSTANT   VARCHAR2(30) := 'QUOTE_DECLD';
  G_NEG_STS_QUOTE_CNCLD      CONSTANT   VARCHAR2(30) := 'QUOTE_CNCLD';
  G_NEG_STS_COMPLETE         CONSTANT   VARCHAR2(30) := 'COMPLETE';

  G_SALESREP_ACTION          CONSTANT   VARCHAR2(30) := 'SALESREP_ACTION';
  G_CUST_ACTION              CONSTANT   VARCHAR2(30) := 'CUST_ACTION';

  G_PERFORMED_BY_CUST        CONSTANT   VARCHAR2(30) := 'CUSTOMER';

  G_IRR_FLAG_AUTOMATIC       CONSTANT   VARCHAR2(1) := 'A';
  G_IRR_FLAG_MANUAL          CONSTANT   VARCHAR2(1) := 'M';
  G_IRR_FLAG_REQD            CONSTANT   VARCHAR2(1) := 'Y';
  G_IRR_FLAG_NOT_REQD        CONSTANT   VARCHAR2(1) := 'N';

  G_NTF_TYPE_ACCEPT          CONSTANT   VARCHAR2(30) := 'ACCEPT';
  G_NTF_TYPE_DECLINE         CONSTANT   VARCHAR2(30) := 'DECLINE';
  G_NTF_TYPE_ERROR           CONSTANT   VARCHAR2(30) := 'ERROR';
  G_NTF_TYPE_MESSAGE         CONSTANT   VARCHAR2(30) := 'MESSAGE';
  G_NTF_TYPE_QA_FAIL         CONSTANT   VARCHAR2(30) := 'QA_FAILURE';
  G_NTF_TYPE_QUOTE_PB        CONSTANT   VARCHAR2(30) := 'QUOTE_PB';
  G_NTF_TYPE_ACTIVE          CONSTANT   VARCHAR2(30) := 'ACTIVE';
  G_NTF_TYPE_RENEWED         CONSTANT   VARCHAR2(30) := 'RENEWED';

  G_REPORT_TYPE_ACCEPT       CONSTANT   VARCHAR2(30) := 'ACCEPT';
  G_REPORT_TYPE_ACTIVE       CONSTANT   VARCHAR2(30) := 'ACTIVE';
  G_REPORT_TYPE_CANCEL       CONSTANT   VARCHAR2(30) := 'CANCEL';
  G_REPORT_TYPE_QUOTE        CONSTANT   VARCHAR2(30) := 'QUOTE';

  G_DEFAULT_NTF_PERFORMER    CONSTANT   VARCHAR2(30) := 'SYSADMIN';

  G_LKUP_TYPE_NEGO_STATUS    CONSTANT   VARCHAR2(30) := 'OKS_AUTO_RENEW_STATUS';
  G_LKUP_TYPE_CNCL_REASON    CONSTANT   VARCHAR2(30) := 'OKS_CANCEL_REASON';
  G_LKUP_VNDR_CNCL_REASON    CONSTANT   VARCHAR2(30) := 'OKC_STS_CHG_REASON';
  G_LKUP_TYPE_PAY_TYPES      CONSTANT   VARCHAR2(30) := 'OKS_OA_PAYMENT_TYPES';

  G_MEDIA_TYPE_WEB_FORM      CONSTANT   VARCHAR2(30) := 'WEB FORM';

--cgopinee bugfix for 6787913
  G_MUTE_PROFILE	     CONSTANT VARCHAR2(30)   := 'OKC_SUPPRESS_EMAILS';
  G_WF_NAME                     varchar2(100)  := 'OKSKPRCS';
  G_PROCESS_NAME                varchar2(100)  := 'K_PROCESS';

  ------------------------------------------------------------------------------
  -- EXCEPTIONS
  ------------------------------------------------------------------------------
  InvalidContractException  EXCEPTION;
  NegStatusUpdateException  EXCEPTION;
  ActionNotAllowedException EXCEPTION;
  AlreadyPublishedException EXCEPTION;

FUNCTION get_fnd_message RETURN VARCHAR2 IS
 i               NUMBER := 0;
 l_return_status VARCHAR2(1);
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);
 l_msg_index_out NUMBER;
 l_mesg          VARCHAR2(2000) := NULL;
BEGIN
 FOR i in 1..fnd_msg_pub.count_msg
 LOOP
    fnd_msg_pub.get
    (
      p_msg_index     => i,
      p_encoded       => 'F',
      p_data          => l_msg_data,
      p_msg_index_out => l_msg_index_out
    );
    IF l_mesg IS NULL THEN
       l_mesg := i || ':' || l_msg_data;
    ELSE
       l_mesg := l_mesg || ':' || i || ':' || l_msg_data;
    END IF;
 END LOOP;
 RETURN l_mesg;
END get_fnd_message;

FUNCTION replace_token
(
 p_message        IN VARCHAR2,
 p_token          IN VARCHAR2,
 p_value          IN VARCHAR2
) RETURN VARCHAR2 AS

 l_api_name     CONSTANT VARCHAR2(30) := 'replace_token';
 l_search_str             VARCHAR2(50);
 l_message               VARCHAR2(2000);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

 IF p_message IS NOT NULL THEN
   l_search_str := '&' || p_token;
   IF INSTR(p_message, l_search_str) <> 0 then
     l_message := substrb(REPLACE(p_message, l_search_str, p_value),1,2000);
   ELSE
     l_message := substrb(p_message||' ('||p_token||'='||p_value||')',1,2000);
   END IF;
 ELSE
   l_message := NULL;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Message: ' ||l_message);
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 RETURN l_message;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END replace_token;

FUNCTION get_message
(
 p_message_name      IN VARCHAR2,
 p_language          IN VARCHAR2
) RETURN VARCHAR2 AS

 l_api_name           CONSTANT VARCHAR2(30) := 'get_message';

 CURSOR l_fnd_msg_csr (p_msg_name VARCHAR2, p_lang VARCHAR2) IS
 SELECT message_text
 FROM fnd_new_messages m, fnd_application a
 WHERE p_msg_name = m.message_name
 AND p_lang = m.language_code
 AND G_APP_NAME = a.application_short_name
 AND m.application_id = a.application_id;

 l_rownotfound           BOOLEAN := FALSE;
 l_message               VARCHAR2(2000);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

 IF p_language IS NOT NULL THEN
   OPEN l_fnd_msg_csr(p_message_name,p_language);
   FETCH l_fnd_msg_csr INTO l_message;
   l_rownotfound := l_fnd_msg_csr%NOTFOUND;
   CLOSE l_fnd_msg_csr;
 END IF;

 IF l_rownotfound THEN
   l_message := NULL;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Message: ' ||l_message);
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 RETURN l_message;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END get_message;

FUNCTION get_concat_k_number
(
 p_contract_id          IN NUMBER
) RETURN VARCHAR2 AS

 l_api_name           CONSTANT VARCHAR2(30) := 'get_concat_k_number';
 l_item_key           wf_items.item_key%TYPE :=NULL;

 CURSOR l_kdetails_csr(p_contract_id NUMBER) IS
 SELECT contract_number,contract_number_modifier
 FROM okc_k_headers_all_b
 WHERE id = p_contract_id;

 l_kdetails_rec       l_kdetails_csr%ROWTYPE;
 l_rownotfound        BOOLEAN := FALSE;
 l_concat_k_number    VARCHAR2(250);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

 OPEN l_kdetails_csr(p_contract_id);
 FETCH l_kdetails_csr INTO l_kdetails_rec;
 l_rownotfound := l_kdetails_csr%NOTFOUND;
 CLOSE l_kdetails_csr;

 IF l_rownotfound THEN
   l_concat_k_number := NULL;
 ELSE
   IF l_kdetails_rec.contract_number_modifier IS NULL THEN
     l_concat_k_number := l_kdetails_rec.contract_number;
   ELSE
     l_concat_k_number := l_kdetails_rec.contract_number || ' - ' ||
                          l_kdetails_rec.contract_number_modifier;
   END IF;
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Contract Number: ' ||l_concat_k_number);
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 RETURN l_concat_k_number;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END get_concat_k_number;

FUNCTION get_lookup_meaning
(
 p_lookup_code          IN VARCHAR2,
 p_lookup_type          IN VARCHAR2
) RETURN VARCHAR2 AS

l_api_name          CONSTANT VARCHAR2(30) := 'get_lookup_meaning';
l_meaning                    VARCHAR2(250);

CURSOR l_lookup_csr IS
SELECT meaning
  FROM FND_LOOKUPS
 WHERE lookup_code = p_lookup_code
 AND   lookup_type = p_lookup_type;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  OPEN l_lookup_csr;
  FETCH l_lookup_csr INTO l_meaning;
  CLOSE l_lookup_csr;

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Meaning: ' ||l_meaning);
  END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  RETURN l_meaning;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END get_lookup_meaning;

FUNCTION get_wf_item_key
(
 p_contract_id          IN NUMBER
) RETURN VARCHAR2 AS

l_api_name                 CONSTANT VARCHAR2(30) := 'get_wf_item_key';
l_item_key                 wf_items.item_key%TYPE :=NULL;


CURSOR csr_k_item_key IS
SELECT wf_item_key
  FROM oks_k_headers_b
 WHERE chr_id = p_contract_id;

l_rownotfound BOOLEAN := FALSE;
BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  OPEN csr_k_item_key;
  FETCH csr_k_item_key INTO l_item_key;
  l_rownotfound := csr_k_item_key%NOTFOUND;
  CLOSE csr_k_item_key;

  IF l_rownotfound OR l_item_key IS NULL  THEN
     l_item_key := NULL;
  END IF; -- item_key is null

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Item Key: ' ||l_item_key);
  END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  RETURN l_item_key;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END get_wf_item_key;

-- Check if a template is defined for a particular type of document
-- like ACTIVE, ACCEPT or DECLINE etc
PROCEDURE is_template_defined
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_contract_id          IN         NUMBER,
 p_document_type        IN         VARCHAR2,
 x_template_defined_yn  OUT NOCOPY VARCHAR2,
 x_email_attr_rec       OUT NOCOPY email_attr_rec,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'is_template_defined';

 CURSOR l_acceptedby_csr(p_user_id NUMBER) IS
 SELECT user_name
 FROM fnd_user fndu
 WHERE fndu.user_id = p_user_id;

 CURSOR l_party_csr(p_chr_id NUMBER) IS
 SELECT b.party_name
 FROM OKC_K_PARTY_ROLES_B a, hz_parties b
 WHERE a.dnz_chr_id = p_chr_id
 AND a.object1_id1 = b.party_id;

 CURSOR l_kdetails_csr(p_chr_id NUMBER) IS
 SELECT contract_number,contract_number_modifier,
 to_char(OKS_EXTWAR_UTIL_PVT.round_currency_amt(estimated_amount,currency_code),
         fnd_currency.get_format_mask(currency_code, 50)
        ) estimated_amount, currency_code
 FROM okc_k_headers_all_b
 WHERE id = p_chr_id;

 CURSOR l_install_lang_csr IS
 SELECT language_code
 FROM fnd_languages
 WHERE installed_flag = 'B';

 l_language               VARCHAR2(50);
 l_email_body_id          NUMBER;
 l_attachment_id          NUMBER;
 l_attachment_name        VARCHAR2(150);
 l_contract_status        VARCHAR2(30);

 l_kdetails_rec           l_kdetails_csr%ROWTYPE;
 l_party_name             VARCHAR2(360);
 l_concat_k_number        VARCHAR2(300);
 l_accepted_by            VARCHAR2(100);
 l_iso_language           VARCHAR2(6);
 l_iso_territory          VARCHAR2(6);
 l_gcd_language           VARCHAR2(50);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name||' with parameters');
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Contract ID: '||p_contract_id||
                    ' Document Type: '||p_document_type);
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status       := G_RET_STS_SUCCESS;
 x_template_defined_yn := 'N';

 IF p_contract_id IS NULL THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
   FND_MESSAGE.SET_TOKEN('HDR_ID','null');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;
 okc_context.set_okc_org_context(p_chr_id => p_contract_id);

 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                  'OKS_TEMPLATE_SET_PUB.get_template_set_dtls(p_contract_id= '
                  ||p_contract_id||' p_document_type ='||p_document_type||')');
 END IF;

 OKS_TEMPLATE_SET_PUB.get_template_set_dtls
 (
  p_api_version            => l_api_version,
  p_init_msg_list          => G_FALSE,
  p_contract_id            => p_contract_id,
  p_document_type          => p_document_type,
  x_template_language      => l_language,
  x_message_template_id    => x_email_attr_rec.email_body_id,
  x_attachment_template_id => x_email_attr_rec.attachment_id,
  x_attachment_name        => x_email_attr_rec.attachment_name,
  x_contract_update_status => x_email_attr_rec.contract_status,
  x_return_status          => x_return_status,
  x_msg_data               => x_msg_data,
  x_msg_count              => x_msg_count
 );

 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_TEMPLATE_SET_PUB.get_template_set_dtls(x_return_status= '||x_return_status||
                  ' x_msg_count ='||x_msg_count||')');
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' x_template_language ='||l_language||
                  ' x_message_template_id ='||x_email_attr_rec.email_body_id||
                  ' x_attachment_template_id ='||x_email_attr_rec.attachment_id||
                  ' x_attachment_name ='||x_email_attr_rec.attachment_name||
                  ' x_contract_update_status ='||x_email_attr_rec.contract_status);
 END IF;
 IF x_return_status <> G_RET_STS_SUCCESS THEN
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF NVL(x_email_attr_rec.email_body_id,x_email_attr_rec.attachment_id) IS NOT NULL THEN
    x_template_defined_yn := 'Y';
 ELSE
    x_template_defined_yn := 'N';
 END IF;

 IF p_document_type IN (G_REPORT_TYPE_ACCEPT,G_REPORT_TYPE_CANCEL) THEN
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKS_RENEW_UTIL_PVT.get_language_info(p_contract_id= '
                     ||p_contract_id||' p_document_type ='||p_document_type||')');
    END IF;
    OKS_RENEW_UTIL_PVT.get_language_info
    (
     p_api_version          => l_api_version,
     p_init_msg_list        => G_FALSE,
     p_contract_id          => p_contract_id,
     p_document_type        => p_document_type,
     p_template_id          => NVL(x_email_attr_rec.email_body_id,x_email_attr_rec.attachment_id),
     p_template_language    => l_language,
     x_fnd_language         => l_language,
     x_fnd_iso_language     => l_iso_language,
     x_fnd_iso_territory    => l_iso_territory,
     x_gcd_template_lang    => l_gcd_language,
     x_return_status        => x_return_status,
     x_msg_count            => x_msg_count,
     x_msg_data             => x_msg_data
    );
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKS_RENEW_UTIL_PVT.get_language_info(x_return_status= '
                     ||x_return_status||' x_msg_count ='||x_msg_count||')');
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     ' x_fnd_language ='||l_language||
                     ' x_fnd_iso_language ='||l_iso_language||
                     ' x_fnd_iso_territory ='||l_iso_territory);
    END IF;
    IF x_return_status <> G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_language IS NULL THEN
      OPEN l_install_lang_csr;
      FETCH l_install_lang_csr INTO l_language;
      CLOSE l_install_lang_csr;
    END IF;

    OPEN l_kdetails_csr(p_contract_id);
    FETCH l_kdetails_csr INTO l_kdetails_rec;
    CLOSE l_kdetails_csr;

    OPEN l_party_csr(p_contract_id);
    FETCH l_party_csr INTO l_party_name;
    CLOSE l_party_csr;

    IF l_kdetails_rec.CONTRACT_NUMBER_MODIFIER IS NULL THEN
      l_concat_k_number   := l_kdetails_rec.CONTRACT_NUMBER;
    ELSE
      l_concat_k_number   := l_kdetails_rec.CONTRACT_NUMBER || ' - ' ||
                             l_kdetails_rec.CONTRACT_NUMBER_MODIFIER;
    END IF;

    -- Depending on the type of email being sent get appropriate email subject
    -- interaction history subject and message
    -- Quote has been accepted by either salesrep or Customer
    IF p_document_type = G_REPORT_TYPE_ACCEPT THEN
       x_email_attr_rec.ih_subject := get_message('OKS_IH_SUBJECT_ACCEPT',l_language);
       -- assemble interaction history body
       OPEN l_acceptedby_csr(FND_GLOBAL.USER_ID);
       FETCH l_acceptedby_csr INTO l_accepted_by;
       CLOSE l_acceptedby_csr;

       x_email_attr_rec.ih_message := get_message('OKS_IH_MESSAGE_ACCEPT',l_language);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'K_NUMBER',l_concat_k_number);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'CURRENCY',l_kdetails_rec.currency_code);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'CUST_NAME',l_party_name);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'ACCEPTED_BY',l_accepted_by);

       IF x_template_defined_yn = 'Y' THEN
          x_email_attr_rec.email_subject := get_message('OKS_EMAIL_SUB_ACCEPT',l_language);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'K_NUMBER',l_concat_k_number);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'K_AMOUNT',l_kdetails_rec.estimated_amount);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'CURRENCY',l_kdetails_rec.currency_code);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'CUST_NAME',l_party_name);
       END IF;

    -- Quote has been declined by customer or cancelled by salesrep
    ELSIF p_document_type = G_REPORT_TYPE_CANCEL THEN
       x_email_attr_rec.ih_subject := get_message('OKS_IH_SUBJECT_CANCEL',l_language);
       -- assemble interaction history body
       x_email_attr_rec.ih_message := get_message('OKS_IH_MESSAGE_CANCEL',l_language);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'K_NUMBER',l_concat_k_number);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'CURRENCY',l_kdetails_rec.currency_code);
       x_email_attr_rec.ih_message := replace_token(x_email_attr_rec.ih_message,'CUST_NAME',l_party_name);

       IF x_template_defined_yn = 'Y' THEN
          x_email_attr_rec.email_subject := get_message('OKS_EMAIL_SUB_CANCEL',l_language);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'K_NUMBER',l_concat_k_number);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'K_AMOUNT',l_kdetails_rec.estimated_amount);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'CURRENCY',l_kdetails_rec.currency_code);
          x_email_attr_rec.email_subject := replace_token(x_email_attr_rec.email_subject,'CUST_NAME',l_party_name);
       END IF;

    END IF;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                       substr('IH Subject '||x_email_attr_rec.ih_subject,1,240) ||
                       substr(' IH Message '||x_email_attr_rec.ih_message,1,240)||
                       substr(' Email subject '||x_email_attr_rec.email_subject,1,240));
    END IF;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,get_fnd_message);
    END IF;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END is_template_defined;

FUNCTION get_irr_flag
(
 p_contract_id          IN NUMBER,
 p_item_key             IN VARCHAR2
) RETURN VARCHAR2 AS

 l_api_name      CONSTANT VARCHAR2(30) := 'get_irr_flag';
 l_item_key               wf_items.item_key%TYPE :=NULL;
 l_irr_flag               VARCHAR2(1)  := NULL;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Entered '||G_PKG_NAME ||'.'||l_api_name||
                  ' with p_contract_id: '||p_contract_id||'p_item_key '||p_item_key);
 END IF;

 IF p_item_key IS NULL THEN
   IF p_contract_id IS NOT NULL THEN
     l_item_key := get_wf_item_key(p_contract_id);
   ELSE
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   l_item_key := p_item_key;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Item Key: ' ||l_item_key);
 END IF;

 l_irr_flag := wf_engine.GetItemAttrText(
                       itemtype   => G_ITEM_TYPE,
                       itemkey    => l_item_key,
                       aname      => 'IRR_FLAG');

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Irr Flag: ' ||NVL(l_irr_flag,'NULL'));
 END IF;

 IF l_irr_flag IN (G_IRR_FLAG_AUTOMATIC,G_IRR_FLAG_MANUAL,G_IRR_FLAG_REQD) THEN
    l_irr_flag := G_IRR_FLAG_REQD;
 ELSIF l_irr_flag = G_IRR_FLAG_NOT_REQD THEN
    l_irr_flag := G_IRR_FLAG_NOT_REQD;
 ELSE
    l_irr_flag := G_IRR_FLAG_REQD;
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Leaving '||G_PKG_NAME ||'.'||l_api_name||' with l_irr_flag '||l_irr_flag);
 END IF;

 RETURN l_irr_flag;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Leaving with Exception '||G_PKG_NAME ||'.'||l_api_name);
    END IF;
    RETURN NULL;
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END get_irr_flag;

FUNCTION activity_exist_in_process
(
 p_item_type          IN VARCHAR2,
 p_item_key           IN VARCHAR2,
 p_activity_name      IN VARCHAR2
) RETURN BOOLEAN AS

l_activity_status VARCHAR2(3);
l_rowfound BOOLEAN := FALSE;
l_api_name      CONSTANT VARCHAR2(50) := 'activity_exist_in_process';
CURSOR check_activity_csr IS
      SELECT '1'
      FROM wf_item_activity_statuses wias, wf_process_activities wpa
      WHERE wias.item_type = p_item_type
      AND wias.item_key  = p_item_key
      AND wias.process_activity = wpa.instance_id
      AND wpa.ACTIVITY_ITEM_TYPE = p_item_type
      AND wpa.activity_name = p_activity_name
      AND wias.activity_status = 'NOTIFIED';
BEGIN

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name );
  END IF;
  OPEN  check_activity_csr;
  FETCH check_activity_csr INTO l_activity_status;
  l_rowfound := check_activity_csr%FOUND;
  CLOSE  check_activity_csr;
  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
       'Leaving '||G_PKG_NAME ||'.'||l_api_name||' l_activity_status='||l_activity_status);
  END IF;
  RETURN l_rowfound;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  RETURN FALSE;
END activity_exist_in_process;

FUNCTION get_notified_activity
(
 p_item_type          IN VARCHAR2,
 p_item_key           IN VARCHAR2
) RETURN VARCHAR2 AS

l_activity_name VARCHAR2(30) := NULL;
l_api_name      CONSTANT VARCHAR2(50) := 'get_notified_activity';

CURSOR check_activity_csr IS
      SELECT ACTIVITY_NAME
      FROM wf_item_activity_statuses wias, wf_process_activities wpa
      WHERE wias.item_type = p_item_type
      AND wias.item_key  = p_item_key
      AND wias.process_activity = wpa.instance_id
      AND wpa.ACTIVITY_ITEM_TYPE = p_item_type
      AND wias.activity_status = 'NOTIFIED';
BEGIN

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name );
  END IF;
  OPEN  check_activity_csr;
  FETCH check_activity_csr INTO l_activity_name;
  CLOSE  check_activity_csr;
  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name||' l_activity_name='||l_activity_name);
  END IF;
  RETURN nvl(l_activity_name, '?');
EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  RETURN 'ERR';
END get_notified_activity;

/*=========================================================================
  API name      : is_online_k_yn
  Type          : Private.
  Function      : This procedure determines whether the contract is going
                  through online process (either by qualification or by
                  being submitted by salesrep).
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id    IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2   Required
                     Contract process workflow's item key.
  OUT           : x_online_yn     OUT VARCHAR2(1)
                     Returns 'Y' if going through online process else 'N'.
                : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE is_online_k_yn
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 x_online_yn            OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'is_online_k_yn';

 l_item_key               wf_items.item_key%TYPE;
 l_publish_manually       VARCHAR2(1);
 l_process_type           VARCHAR2(30);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name||'with Contract Id '||p_contract_id);
 END IF;

 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    x_return_status := G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
       FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Item Key found '||l_item_key);
 END IF;

 l_publish_manually := wf_engine.GetItemAttrText(
                       itemtype  => G_ITEM_TYPE,
                       itemkey   => l_item_key,
                       aname     => 'PUBLISH_MAN_YN');
 IF NVL(l_publish_manually,'N') = 'Y' THEN
   x_online_yn := 'Y';
 ELSE
   l_process_type   := wf_engine.GetItemAttrText(
                       itemtype  => G_ITEM_TYPE,
                       itemkey   => l_item_key,
                       aname     => 'PROCESS_TYPE');
   -- bug fix 5661529
   IF NVL(l_process_type, G_RENEW_TYPE_MANUAL) = G_RENEW_TYPE_ONLINE THEN
     x_online_yn := 'Y';
   ELSE
     x_online_yn := 'N';
   END IF;
 END IF;
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Publish manual Flag '||l_publish_manually ||
                    ' Process Type '|| l_process_type ||
                    ' Online YN ' || x_online_yn);
 END IF;
 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,get_fnd_message);
    END IF;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END is_online_k_yn;

PROCEDURE complete_activity
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_contract_id          IN NUMBER,
 p_item_key             IN VARCHAR2,
 p_resultout            IN VARCHAR2,
 p_process_status       IN VARCHAR2,
 p_activity_name        IN VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) AS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'complete_activity';
l_item_key                 wf_items.item_key%TYPE;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
          'Entered '||G_PKG_NAME ||'.'||l_api_name||' with p_contract_id '||p_contract_id);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
          'and p_item_key '||p_item_key||' p_resultout ='||p_resultout||
          ' p_process_status ='||p_process_status||' p_activity_name ='||p_activity_name);
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

    IF p_item_key IS NULL THEN
      l_item_key := get_wf_item_key(p_contract_id);
      IF l_item_key IS NULL THEN
         FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      l_item_key := p_item_key;
    END IF;  -- p_item_key IS NULL

    -- if p_process_status is passed then update the renewal status in oks_k_headers_b
    IF p_process_status IS NOT NULL THEN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Updating Contract '||G_PKG_NAME ||'.'||l_api_name);
       END IF;

       UPDATE oks_k_headers_b
          SET renewal_status = p_process_status ,
-- commented and replaced following 2 lines. Accepted by and date accepted were getting cleared
--              accepted_by = DECODE(p_process_status,G_NEG_STS_QUOTE_ACPTD,FND_GLOBAL.USER_ID,accepted_by),
--              date_accepted = DECODE(p_process_status,G_NEG_STS_QUOTE_ACPTD,sysdate,date_accepted),
              accepted_by = DECODE(p_process_status,G_NEG_STS_QUOTE_ACPTD,NVL(accepted_by,FND_GLOBAL.USER_ID),accepted_by),
              date_accepted = DECODE(p_process_status,G_NEG_STS_QUOTE_ACPTD,NVL(date_accepted,sysdate),date_accepted),
              object_version_number = object_version_number + 1,
              last_update_date = SYSDATE,
              last_updated_by =   FND_GLOBAL.USER_ID,
              last_update_login = FND_GLOBAL.LOGIN_ID
        WHERE chr_id = p_contract_id;

/* MKS 10/12/2005  Bug#4643300
        -- bump up the minor version number
       UPDATE okc_k_vers_numbers
          SET minor_version = minor_version + 1,
              object_version_number = object_version_number + 1,
              last_update_date = SYSDATE,
              last_updated_by =   FND_GLOBAL.USER_ID,
              last_update_login = FND_GLOBAL.LOGIN_ID
        WHERE chr_id = p_contract_id;
*/
    END IF; -- p_process_status is passed

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Completing Activity '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    -- Call the wf complete activity
    wf_engine.completeactivityinternalname
    (
     itemtype      => G_ITEM_TYPE,
     itemkey       => l_item_key,
     activity      => p_activity_name,
     result        => p_resultout
    );


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END complete_activity;

FUNCTION get_negotiation_status
(
 p_contract_id          IN NUMBER
) RETURN VARCHAR2 AS

l_api_name            CONSTANT VARCHAR2(30) := 'get_negotiation_status';

 CURSOR l_NegotiationStatus_csr(l_contract_id NUMBER) IS
 SELECT renewal_status
 FROM oks_k_headers_b
 WHERE chr_id = l_contract_id;

 l_negotiation_status VARCHAR2(30);
BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
            'Entered '||G_PKG_NAME ||'.'||l_api_name||' with p_contract_id '||p_contract_id);
  END IF;

  -- Get negotiation status
  OPEN l_NegotiationStatus_csr(p_contract_id);
  FETCH l_NegotiationStatus_csr INTO l_negotiation_status;
  CLOSE l_NegotiationStatus_csr;

  IF l_negotiation_status IS NULL THEN
     fnd_message.set_name(G_APP_NAME,'OKS_INVALID_NEG_STATUS');
     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
        'Leaving '||G_PKG_NAME ||'.'||l_api_name||' with negotiation status '||l_negotiation_status);
  END IF;

  RETURN l_negotiation_status;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Leaving with Exception '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
    END IF;
    RETURN NULL;
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;

END get_negotiation_status;

/*=========================================================================
  API name      : in_process_yn
  Type          : Private.
  Function      : This procedure determines whether the contract is going
                  through approval process so that Authoring can open the
                  contract in read-only more. This is a replacement api for
                  IN_PROCESS_YN in OKSAUDET.pld. Signature is kept so as to
                  make it no impact for Authoring.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_contract_number          IN VARCHAR2 Required
                     Contract Number
                : p_contract_number_modifier IN VARCHAR2 Required
                     Contract Number Modifier
                : p_workflow_name            IN VARCHAR2 Required
                     Approval Workflow Name
                : p_chr_id                   IN NUMBER
                     Contract header Id
  OUT           : x_active                  OUT VARCHAR2(1)
                     Returns 'Y' if in process else 'N'
  Note          :
=========================================================================*/
FUNCTION in_process_yn
(
 p_contract_number          IN VARCHAR2,
 p_contract_number_modifier IN VARCHAR2,
 p_workflow_name            IN VARCHAR2,
 p_chr_id                   IN NUMBER DEFAULT NULL
) RETURN VARCHAR2 AS

 l_api_name           CONSTANT VARCHAR2(30) := 'in_process_yn';

 CURSOR l_wfactive_csr IS
 SELECT 'Y'
 FROM wf_items
 WHERE item_type = p_workflow_name
 AND item_key    = p_contract_number || p_contract_number_modifier
 AND end_date IS NULL;

 CURSOR l_chrid_csr IS
 SELECT id
 FROM okc_k_headers_all_b
 WHERE contract_number        = p_contract_number
 AND contract_number_modifier = p_contract_number_modifier;

 l_rownotfound        BOOLEAN     := FALSE;
 l_chr_id             NUMBER;
 l_negotiation_status VARCHAR2(30);
 x_active             VARCHAR2(1) := 'N';

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

 OPEN l_wfactive_csr;
 FETCH l_wfactive_csr INTO x_active;
 l_rownotfound := l_wfactive_csr%NOTFOUND;
 CLOSE l_wfactive_csr;

 IF l_rownotfound THEN
   IF p_chr_id IS NULL THEN
     OPEN l_chrid_csr;
     FETCH l_chrid_csr INTO l_chr_id;
     CLOSE l_chrid_csr;
     l_negotiation_status := get_negotiation_status(p_contract_id => l_chr_id);
   ELSE
     l_negotiation_status := get_negotiation_status(p_contract_id => p_chr_id);
   END IF;

   IF NVL(l_negotiation_status,'X') IN ('PEND_PUBLISH','PEND_ACTIVATION') THEN
     x_active := 'Y';
   END IF;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,'In process? '||x_active);
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 RETURN x_active;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END in_process_yn;

FUNCTION get_qto_email
(
 p_contract_id          IN NUMBER
) RETURN VARCHAR2 AS

 l_api_name            CONSTANT VARCHAR2(30) := 'get_qto_email';

 CURSOR l_QToContact_csr ( l_contract_id NUMBER ) IS
 SELECT quote_to_email_id
 FROM oks_k_headers_b
 WHERE chr_id = l_contract_id;

 CURSOR l_emailAddress_csr ( p_contactPoint_id NUMBER ) IS
 SELECT email_address
 FROM hz_contact_points
 WHERE contact_point_id = p_contactPoint_id
 AND content_source_type = 'USER_ENTERED';

 l_qto_email    VARCHAR2(2000);
 l_contact_id   NUMBER;
BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
        'Entered '||G_PKG_NAME ||'.'||l_api_name||' with p_contract_id '||p_contract_id);
  END IF;

  -- Get contact point id of Quote To contact's email address
  OPEN l_QToContact_csr(p_contract_id);
  FETCH l_QToContact_csr INTO l_contact_id;
  CLOSE l_QToContact_csr;

  IF l_contact_id IS NULL THEN
     fnd_message.set_name(G_APP_NAME,'OKS_NO_QTO_CONTACT');
     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN l_emailAddress_csr (l_contact_id) ;
  FETCH l_emailAddress_csr INTO l_qto_email;
  CLOSE l_emailAddress_csr;

  IF l_qto_email IS NULL THEN
     fnd_message.set_name(G_APP_NAME,'OKS_NO_QTO_EMAIL');
     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
         'Leaving '||G_PKG_NAME ||'.'||l_api_name||' with l_qto_email '||l_qto_email);
  END IF;

  RETURN l_qto_email;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Leaving with Exception '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
    END IF;
    RETURN NULL;
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;

END get_qto_email;

/*=========================================================================
  API name      : set_notification_attributes
  Type          : Private.
  Function      : This procedure sets all the relavant wf item attribute
                  values that will be used in notifications.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_notif_attr     IN VARCHAR2   Required
                     Workflow item attributes related to notifications.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE set_notification_attributes
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_notif_attr           IN         notif_attr_rec,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER
) IS
 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'set_notification_attributes';

 CURSOR l_party_csr(p_chr_id NUMBER) IS
 SELECT b.party_name
 FROM OKC_K_PARTY_ROLES_B a, hz_parties b
 WHERE a.dnz_chr_id = p_chr_id
 AND a.object1_id1 = b.party_id;

 CURSOR l_kdetails_csr(p_chr_id NUMBER) IS
 SELECT okch.contract_number,okch.contract_number_modifier,
        to_char(OKS_EXTWAR_UTIL_PVT.round_currency_amt(okch.estimated_amount,okch.currency_code),
                fnd_currency.get_format_mask(okch.currency_code, 50)
               ) estimated_amount,okch.currency_code,hro.name,okch.short_description
 FROM okc_k_headers_all_v okch, hr_all_organization_units hro
 WHERE okch.id = p_chr_id
 AND hro.organization_id = okch.authoring_org_id;

 -- Get Vendor contact or helpdesk name
 CURSOR l_contact_name_csr(p_user_name VARCHAR2) IS
 SELECT source_name
 FROM jtf_rs_resource_extns
 WHERE user_name = p_user_name;

 -- Get quote To contact fnd user name
 CURSOR l_qto_name_csr(p_chr_id NUMBER) IS
 SELECT fu.user_name
 FROM oks_k_headers_b ks, fnd_user fu
 WHERE ks.chr_id = p_chr_id
 AND   fu.person_party_id = ks.person_party_id;

 -- Get quote To contact name
 CURSOR l_qtocontact_name_csr(p_chr_id NUMBER) IS
 select SUBSTRB(P.PERSON_LAST_NAME,1,50) || ', ' || SUBSTRB(P.PERSON_FIRST_NAME,1,40) name
 FROM OKS_K_HEADERS_B OKSH,
      HZ_CUST_ACCOUNT_ROLES CAR,
      HZ_PARTIES P,
      HZ_RELATIONSHIPS R
 WHERE OKSH.quote_to_contact_id = car.CUST_ACCOUNT_ROLE_ID
   AND CAR.ROLE_TYPE = 'CONTACT'
   AND R.PARTY_ID = CAR.PARTY_ID
   AND R.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
   AND P.PARTY_ID = R.SUBJECT_ID
   AND R.DIRECTIONAL_FLAG = 'F'
   AND oksh.chr_id = p_chr_id;

-- Get original contract number and modifier of the renewed contract
 CURSOR l_old_k_num(p_chr_id NUMBER) IS
 SELECT decode(kh.contract_number_modifier,NULL,kh.contract_number, kh.contract_number||' - '|| kh.contract_number_modifier)
 FROM okc_operation_lines ol,
      okc_operation_instances oi,
      okc_class_operations co,
      okc_k_headers_all_b kh
 WHERE co.cls_code = 'SERVICE'
 AND co.opn_code = 'RENEWAL'
 AND co.id = oi.cop_id
 AND ol.oie_id = oi.id
 AND ol.subject_chr_id = p_chr_id
 AND ol.object_chr_id IS NOT NULL
 AND ol.object_cle_id IS NULL
 AND ol.subject_cle_id IS NULL
 AND ol.process_flag = 'P'
 AND ol.object_chr_id = kh.id;

 l_kdetails_rec           l_kdetails_csr%ROWTYPE;
 l_item_key               wf_items.item_key%TYPE;
 l_party_name             VARCHAR2(360);
 l_notif_subject          VARCHAR2(2000);
 l_salesrep_id            NUMBER;
 l_salesrep_name          VARCHAR2(100);
 l_concat_k_number        VARCHAR2(250);
 l_old_k_number           VARCHAR2(250);
 l_vc_name                VARCHAR2(360);
 l_from_role              VARCHAR2(360);
 l_rownotfound            BOOLEAN := FALSE;
 l_counter                NUMBER;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);
 l_msg_index_out          NUMBER;
 l_qtocontact_name        VARCHAR2(220);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name||' with parameters');
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
              'Contract Id ' ||p_notif_attr.CONTRACT_ID||
              ' Item Key '   ||p_notif_attr.ITEM_KEY   ||
              ' NTF type'    ||p_notif_attr.NTF_TYPE   ||
              ' NTF subject' ||p_notif_attr.NTF_SUBJECT||
              ' Subject '    ||p_notif_attr.SUBJECT);
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 OPEN l_kdetails_csr(p_notif_attr.CONTRACT_ID);
 FETCH l_kdetails_csr INTO l_kdetails_rec;
 l_rownotfound := l_kdetails_csr%NOTFOUND;
 CLOSE l_kdetails_csr;
 IF l_rownotfound THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
   FND_MESSAGE.SET_TOKEN('HDR_ID',p_notif_attr.CONTRACT_ID);
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF l_kdetails_rec.contract_number_modifier IS NULL THEN
   l_concat_k_number := l_kdetails_rec.contract_number;
 ELSE
   l_concat_k_number := l_kdetails_rec.contract_number || ' - ' ||
                        l_kdetails_rec.contract_number_modifier;
 END IF;

 OPEN l_party_csr(p_notif_attr.CONTRACT_ID);
 FETCH l_party_csr INTO l_party_name;
 CLOSE l_party_csr;

 okc_context.set_okc_org_context(p_chr_id => p_notif_attr.CONTRACT_ID);
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,'Party name '||l_party_name);
 END IF;

 IF p_notif_attr.ITEM_KEY IS NULL THEN
    l_item_key := get_wf_item_key(p_notif_attr.CONTRACT_ID);
 ELSE
    l_item_key := p_notif_attr.ITEM_KEY;
 END IF;

 IF p_notif_attr.REQ_ASSIST_ROLE IS NOT NULL THEN
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'REQ_ASSIST_ROLE',
    avalue   => p_notif_attr.REQ_ASSIST_ROLE
   );
 END IF;

 IF p_notif_attr.PERFORMER IS NOT NULL THEN
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'PERFORMER',
    avalue   => p_notif_attr.PERFORMER
   );
   l_salesrep_name := p_notif_attr.PERFORMER;
 ELSE
   -- Get Salesrep user name which will be used as performer
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(p_chr_id= '
                    ||p_notif_attr.CONTRACT_ID||')');
   END IF;
   OKS_RENEW_CONTRACT_PVT.GET_USER_NAME
   (
    p_api_version   => l_api_version,
    p_init_msg_list => G_FALSE,
    x_return_status => x_return_status,
    x_msg_count     => x_msg_count,
    x_msg_data      => x_msg_data,
    p_chr_id        => p_notif_attr.CONTRACT_ID,
    p_hdesk_user_id => NULL,
    x_user_id       => l_salesrep_id,
    x_user_name     => l_salesrep_name
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(x_return_status= '||
                    x_return_status||' x_msg_count ='||x_msg_count||')');
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    ' x_user_id ='||l_salesrep_id||
                    ' x_user_name ='||l_salesrep_name);
   END IF;
   IF x_return_status <> G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'PERFORMER',
    avalue   => NVL(l_salesrep_name,G_DEFAULT_NTF_PERFORMER)
   );
 END IF;

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'OPERATING_UNIT',
  avalue   => l_kdetails_rec.name
 );

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'K_DESCRIPTION',
  avalue   => l_kdetails_rec.short_description
 );

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'CONCAT_K_NUMBER',
  avalue   => l_concat_k_number
 );

 OPEN l_contact_name_csr(l_salesrep_name);
 FETCH l_contact_name_csr INTO l_vc_name;
 CLOSE l_contact_name_csr;

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'VC_NAME',
  avalue   => l_vc_name
 );

 -- Notification is sent from Vendor contact or Helpdesk by default
 -- but will change to quote to contact in case of request for assistance
 IF p_notif_attr.NTF_TYPE = G_NTF_TYPE_MESSAGE THEN
   OPEN l_qto_name_csr(p_notif_attr.CONTRACT_ID);
   FETCH l_qto_name_csr INTO l_from_role;
   CLOSE l_qto_name_csr;
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'FROM',
    avalue   => l_from_role
   );
 ELSE
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'FROM',
    avalue   => l_salesrep_name
   );
 END IF;

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'NTF_TYPE',
  avalue   => p_notif_attr.NTF_TYPE
 );

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'SUBJECT',
  avalue   => p_notif_attr.SUBJECT
 );

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                  'Notification Type: '|| p_notif_attr.NTF_TYPE);
 END IF;

 IF p_notif_attr.NTF_TYPE = G_NTF_TYPE_ACCEPT THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_ACCEPTED');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_DECLINE THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_DECLINED');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_RENEWED THEN
   -- Reset notification type since notification doesn't have any special region
   -- to be rendered.
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'NTF_TYPE',
    avalue   => NULL
   );

   OPEN l_old_k_num(p_notif_attr.CONTRACT_ID);
   FETCH l_old_k_num INTO l_old_k_number;
   CLOSE l_old_k_num;

   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_RENEWED');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_old_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_ERROR THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_WF_ERROR');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_MESSAGE THEN

   OPEN l_qtocontact_name_csr(p_notif_attr.CONTRACT_ID);
   FETCH l_qtocontact_name_csr INTO l_qtocontact_name;
   CLOSE l_qtocontact_name_csr;

   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_REQUEST_ASSIST');
   FND_MESSAGE.SET_TOKEN('QTO_CONTACT',l_qtocontact_name);
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_QA_FAIL THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_QA_FAIL');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_QUOTE_PB THEN
   -- Reset notification type since notification doesn't have any special region
   -- to be rendered.
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'NTF_TYPE',
    avalue   => NULL
   );

   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_QPUB_SUCCESS');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSIF p_notif_attr.NTF_TYPE = G_NTF_TYPE_ACTIVE THEN
   -- Reset notification type since notification doesn't have any special region
   -- to be rendered.
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'NTF_TYPE',
    avalue   => NULL
   );

   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NTF_SUB_ACTIVATED');
   FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
   FND_MESSAGE.SET_TOKEN('K_AMOUNT',l_kdetails_rec.estimated_amount);
   FND_MESSAGE.SET_TOKEN('CURRENCY',l_kdetails_rec.currency_code);
   FND_MESSAGE.SET_TOKEN('CUST_NAME',l_party_name);
   l_notif_subject := FND_MESSAGE.GET;

 ELSE
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'NTF_SUBJECT',
  avalue   => l_notif_subject
 );

 -- Initialize all message attributes to Null other than in QA Failure case
 IF p_notif_attr.NTF_TYPE <> G_NTF_TYPE_QA_FAIL THEN
   FOR l_counter IN 1 .. 10 LOOP
     wf_engine.SetItemAttrText
     (
      itemtype   => G_ITEM_TYPE,
      itemkey    => l_item_key,
      aname      => 'MESSAGE' || l_counter,
      avalue     => NULL
     );
   END LOOP;
 END IF;

 -- If this flag is set to Y, retrieve messages from error stack and assign them
 -- to the message attibutes.
 IF NVL(p_notif_attr.MSGS_FROM_STACK_YN,'N') = 'Y' THEN
   l_msg_count := NVL(fnd_msg_pub.count_msg,0);
   IF l_msg_count>0 THEN

     IF l_msg_count>10 THEN l_msg_count := 10; END IF;
     FOR l_counter in 1..l_msg_count Loop
        fnd_msg_pub.get
        (
         p_msg_index     => l_counter,
         p_encoded       => 'F',
         p_data          => l_msg_data,
         p_msg_index_out => l_msg_index_out
        );

        wf_engine.SetItemAttrText
        (
         itemtype   => G_ITEM_TYPE,
         itemkey    => l_item_key,
         aname      => 'MESSAGE' || l_counter,
         avalue     => l_msg_data
        );
     END LOOP;
     FND_MESSAGE.CLEAR;
   END IF;
 -- Messages are passed so assign them to wf message attibutes.
 ELSE
   IF p_notif_attr.MESSAGE1 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE1',
      avalue   => p_notif_attr.MESSAGE1
     );
   END IF;

   IF p_notif_attr.MESSAGE2 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE2',
      avalue   => p_notif_attr.MESSAGE2
     );
   END IF;

   IF p_notif_attr.MESSAGE3 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE3',
      avalue   => p_notif_attr.MESSAGE3
     );
   END IF;

   IF p_notif_attr.MESSAGE4 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE4',
      avalue   => p_notif_attr.MESSAGE4
     );
   END IF;

   IF p_notif_attr.MESSAGE5 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE5',
      avalue   => p_notif_attr.MESSAGE5
     );
   END IF;

   IF p_notif_attr.MESSAGE6 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE6',
      avalue   => p_notif_attr.MESSAGE6
     );
   END IF;

   IF p_notif_attr.MESSAGE7 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE7',
      avalue   => p_notif_attr.MESSAGE7
     );
   END IF;

   IF p_notif_attr.MESSAGE8 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE8',
      avalue   => p_notif_attr.MESSAGE8
     );
   END IF;

   IF p_notif_attr.MESSAGE9 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE9',
      avalue   => p_notif_attr.MESSAGE9
     );
   END IF;

   IF p_notif_attr.MESSAGE10 IS NOT NULL THEN
     wf_engine.SetItemAttrText
     (
      itemtype => G_ITEM_TYPE,
      itemkey  => l_item_key,
      aname    => 'MESSAGE10',
      avalue   => p_notif_attr.MESSAGE10
     );
   END IF;
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                    'Successfully set workflow attributes ');
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,get_fnd_message);
    END IF;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END set_notification_attributes;

/*=========================================================================
  API name      : set_email_attributes
  Type          : Private.
  Function      : This procedure sets all the relavant wf item attribute
                  values that will be used while sending out an email. If
                  the values that need to be set are null, existing values
                  are reset to NULL so that incorrect data will not be used.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_email_attr     IN VARCHAR2   Required
                     Workflow item attributes related to email delivery.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE set_email_attributes
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_email_attr           IN         email_attr_rec,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER
) IS
 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'set_email_attributes';

 CURSOR l_email_csr(p_user_id VARCHAR2) IS
 SELECT source_email
    FROM jtf_rs_resource_extns
    WHERE user_id = p_user_id;

 CURSOR l_acceptedby_csr(p_user_id NUMBER) IS
 SELECT user_name
 FROM fnd_user fndu
 WHERE fndu.user_id = p_user_id;

 CURSOR l_party_csr(p_chr_id NUMBER) IS
 SELECT b.party_name
 FROM OKC_K_PARTY_ROLES_B a, hz_parties b
 WHERE a.dnz_chr_id = p_chr_id
 AND a.object1_id1 = b.party_id;

 CURSOR l_kdetails_csr(p_chr_id NUMBER) IS
 SELECT contract_number,contract_number_modifier,
 to_char(OKS_EXTWAR_UTIL_PVT.round_currency_amt(estimated_amount,currency_code),
         fnd_currency.get_format_mask(currency_code, 50)
        ) estimated_amount, currency_code
 FROM okc_k_headers_all_b
 WHERE id = p_chr_id;

 CURSOR l_install_lang_csr IS
 SELECT language_code
 FROM fnd_languages
 WHERE installed_flag = 'B';

 l_language               VARCHAR2(50);
 l_email_body_id          NUMBER;
 l_attachment_id          NUMBER;
 l_attachment_name        VARCHAR2(150);
 l_contract_status        VARCHAR2(30);
 l_rownotfound            BOOLEAN := FALSE;
 l_qto_email              VARCHAR2(4000);
 l_sender_email           VARCHAR2(4000);
 l_salesrep_id            NUMBER;
 l_salesrep_name          VARCHAR2(100);
 l_email_subject          VARCHAR2(4000);
 l_ih_subject             VARCHAR2(4000);
 l_ih_message             VARCHAR2(4000);

 l_kdetails_rec           l_kdetails_csr%ROWTYPE;
 l_item_key               wf_items.item_key%TYPE;
 l_party_name             VARCHAR2(360);
 l_concat_k_number        VARCHAR2(300);
 l_accepted_by            VARCHAR2(100);
 l_iso_language           VARCHAR2(6);
 l_iso_territory          VARCHAR2(6);
 l_gcd_language           VARCHAR2(50);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name||' with parameters');
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
              'Contract ID:'   ||p_email_attr.CONTRACT_ID||
              ' Item Key:'     ||p_email_attr.ITEM_KEY||
              ' Email Type:'   ||p_email_attr.EMAIL_TYPE);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
              'To Email:'       ||p_email_attr.TO_EMAIL||
              ' Sender Email:'  ||p_email_attr.SENDER_EMAIL||
              ' Email Subject:' ||substr(p_email_attr.EMAIL_SUBJECT,1,150));
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
              'IH subject:'     ||substr(p_email_attr.IH_SUBJECT,1,150)||
              ' IH message:'    ||substr(p_email_attr.IH_MESSAGE,1,150));
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
              'Message Template: '    ||p_email_attr.email_body_id||
              ' Attachment Template: '||p_email_attr.attachment_id||
              ' Attachment Name: '    ||p_email_attr.attachment_name||
              ' Contract status: '    ||p_email_attr.contract_status);
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_email_attr.CONTRACT_ID IS NULL THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
   FND_MESSAGE.SET_TOKEN('HDR_ID','null');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_email_attr.TO_EMAIL IS NULL THEN
    l_qto_email := get_qto_email(p_contract_id => p_email_attr.CONTRACT_ID);
    IF l_qto_email IS NULL THEN
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name,'Quote To email not found');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_qto_email := p_email_attr.TO_EMAIL;
 END IF;

 IF p_email_attr.SENDER_EMAIL IS NULL THEN

    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(p_chr_id= '
                     ||p_email_attr.CONTRACT_ID||')');
    END IF;
    OKS_RENEW_CONTRACT_PVT.GET_USER_NAME
    (
     p_api_version   => l_api_version,
     p_init_msg_list => G_FALSE,
     x_return_status => x_return_status,
     x_msg_count     => x_msg_count,
     x_msg_data      => x_msg_data,
     p_chr_id        => p_email_attr.CONTRACT_ID,
     p_hdesk_user_id => NULL,
     x_user_id       => l_salesrep_id,
     x_user_name     => l_salesrep_name
    );
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(x_return_status= '||x_return_status||
                  ' x_msg_count ='||x_msg_count||')');
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' x_user_id ='||l_salesrep_id||
                  ' x_user_name ='||l_salesrep_name);
    END IF;
    IF x_return_status <> G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN l_email_csr(l_salesrep_id);
    FETCH l_email_csr INTO l_sender_email;
    l_rownotfound := l_email_csr%NOTFOUND;
    CLOSE l_email_csr;

    IF l_rownotfound THEN
      -- Sender email is not found
      FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_EMAIL_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('USER_NAME',l_salesrep_name);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_sender_email := p_email_attr.SENDER_EMAIL;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                    substr('To: '||l_qto_email,1,4000));
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                    substr('Sender: '||l_sender_email,1,4000));
 END IF;

 -- Get item key in order to retrieve contract information
 IF p_email_attr.ITEM_KEY IS NULL THEN
   l_item_key := get_wf_item_key(p_contract_id => p_email_attr.CONTRACT_ID);
   IF l_item_key IS NULL THEN
     FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   l_item_key := p_email_attr.ITEM_KEY;
 END IF;

 IF ((p_email_attr.IH_SUBJECT IS NULL) OR
     (p_email_attr.IH_MESSAGE IS NULL) OR
     (p_email_attr.EMAIL_SUBJECT IS NULL)) THEN

   okc_context.set_okc_org_context(p_chr_id => p_email_attr.CONTRACT_ID);

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_TEMPLATE_SET_PUB.get_template_set_dtls(p_contract_id= '
                    ||p_email_attr.CONTRACT_ID||
                    ' p_document_type ='||p_email_attr.EMAIL_TYPE||')');
   END IF;

   OKS_TEMPLATE_SET_PUB.get_template_set_dtls
   (
    p_api_version            => l_api_version,
    p_init_msg_list          => G_FALSE,
    p_contract_id            => p_email_attr.CONTRACT_ID,
    p_document_type          => p_email_attr.EMAIL_TYPE,
    x_template_language      => l_language,
    x_message_template_id    => l_email_body_id,
    x_attachment_template_id => l_attachment_id,
    x_attachment_name        => l_attachment_name,
    x_contract_update_status => l_contract_status,
    x_return_status          => x_return_status,
    x_msg_data               => x_msg_data,
    x_msg_count              => x_msg_count
   );

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_TEMPLATE_SET_PUB.get_template_set_dtls(x_return_status= '||x_return_status||
                    ' x_msg_count ='||x_msg_count||')');
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    ' x_template_language ='||l_language||
                    ' x_message_template_id ='||l_email_body_id||
                    ' x_attachment_template_id ='||l_attachment_id||
                    ' x_attachment_name ='||l_attachment_name||
                    ' x_contract_update_status ='||l_contract_status);
   END IF;
   IF x_return_status <> G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_RENEW_UTIL_PVT.get_language_info(p_contract_id= '
                    ||p_email_attr.CONTRACT_ID||
                    ' p_document_type ='||p_email_attr.EMAIL_TYPE||')');
   END IF;
   OKS_RENEW_UTIL_PVT.get_language_info
   (
    p_api_version          => l_api_version,
    p_init_msg_list        => G_FALSE,
    p_contract_id          => p_email_attr.CONTRACT_ID,
    p_document_type        => p_email_attr.EMAIL_TYPE,
    p_template_id          => l_attachment_id,
    p_template_language    => l_language,
    x_fnd_language         => l_language,
    x_fnd_iso_language     => l_iso_language,
    x_fnd_iso_territory    => l_iso_territory,
    x_gcd_template_lang    => l_gcd_language,
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_RENEW_UTIL_PVT.get_language_info(x_return_status= '
                    ||x_return_status||' x_msg_count ='||x_msg_count||')');
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    ' x_fnd_language ='||l_language||
                    ' x_fnd_iso_language ='||l_iso_language||
                    ' x_fnd_iso_territory ='||l_iso_territory);
   END IF;
   IF x_return_status <> G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_language IS NULL THEN
     OPEN l_install_lang_csr;
     FETCH l_install_lang_csr INTO l_language;
     CLOSE l_install_lang_csr;
   END IF;

   OPEN l_kdetails_csr(p_email_attr.CONTRACT_ID);
   FETCH l_kdetails_csr INTO l_kdetails_rec;
   CLOSE l_kdetails_csr;

   OPEN l_party_csr(p_email_attr.CONTRACT_ID);
   FETCH l_party_csr INTO l_party_name;
   CLOSE l_party_csr;

   IF l_kdetails_rec.CONTRACT_NUMBER_MODIFIER IS NULL THEN
     l_concat_k_number   := l_kdetails_rec.CONTRACT_NUMBER;
   ELSE
     l_concat_k_number   := l_kdetails_rec.CONTRACT_NUMBER || ' - ' ||
                            l_kdetails_rec.CONTRACT_NUMBER_MODIFIER;
   END IF;

   -- Depending on the type of email being sent get appropriate email subject
   -- interaction history subject and message
   -- Quote has been accepted by either salesrep or Customer
   IF p_email_attr.EMAIL_TYPE = G_REPORT_TYPE_ACCEPT THEN
     IF p_email_attr.IH_SUBJECT IS NULL THEN
       l_ih_subject := get_message('OKS_IH_SUBJECT_ACCEPT',l_language);
     ELSE
       l_ih_subject := p_email_attr.IH_SUBJECT;
     END IF;
     -- assemble interaction history body
     IF p_email_attr.IH_MESSAGE IS NULL THEN
       OPEN l_acceptedby_csr(FND_GLOBAL.USER_ID);
       FETCH l_acceptedby_csr INTO l_accepted_by;
       CLOSE l_acceptedby_csr;

       l_ih_message := get_message('OKS_IH_MESSAGE_ACCEPT',l_language);
       l_ih_message := replace_token(l_ih_message,'K_NUMBER',l_concat_k_number);
       l_ih_message := replace_token(l_ih_message,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       l_ih_message := replace_token(l_ih_message,'CURRENCY',l_kdetails_rec.currency_code);
       l_ih_message := replace_token(l_ih_message,'CUST_NAME',l_party_name);
       l_ih_message := replace_token(l_ih_message,'ACCEPTED_BY',l_accepted_by);
     ELSE
       l_ih_message := p_email_attr.IH_MESSAGE;
     END IF;
     IF p_email_attr.EMAIL_SUBJECT IS NULL THEN
       l_email_subject := get_message('OKS_EMAIL_SUB_ACCEPT',l_language);
       l_email_subject := replace_token(l_email_subject,'K_NUMBER',l_concat_k_number);
       l_email_subject := replace_token(l_email_subject,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       l_email_subject := replace_token(l_email_subject,'CURRENCY',l_kdetails_rec.currency_code);
       l_email_subject := replace_token(l_email_subject,'CUST_NAME',l_party_name);
     ELSE
       l_email_subject := p_email_attr.EMAIL_SUBJECT;
     END IF;

   -- Activation confirmation
   ELSIF p_email_attr.EMAIL_TYPE = G_REPORT_TYPE_ACTIVE THEN
     IF p_email_attr.IH_SUBJECT IS NULL THEN
       l_ih_subject := get_message('OKS_IH_SUBJECT_ACTIVE',l_language);
     ELSE
       l_ih_subject := p_email_attr.IH_SUBJECT;
     END IF;
     -- assemble interaction history body
     IF p_email_attr.IH_MESSAGE IS NULL THEN
       l_ih_message := get_message('OKS_IH_MESSAGE_ACTIVE',l_language);
       l_ih_message := replace_token(l_ih_message,'K_NUMBER',l_concat_k_number);
       l_ih_message := replace_token(l_ih_message,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       l_ih_message := replace_token(l_ih_message,'CURRENCY',l_kdetails_rec.currency_code);
       l_ih_message := replace_token(l_ih_message,'CUST_NAME',l_party_name);
     ELSE
       l_ih_message := p_email_attr.IH_MESSAGE;
     END IF;
     IF p_email_attr.EMAIL_SUBJECT IS NULL THEN
       l_email_subject := get_message('OKS_EMAIL_SUB_ACTIVE',l_language);
       l_email_subject := replace_token(l_email_subject,'K_NUMBER',l_concat_k_number);
       l_email_subject := replace_token(l_email_subject,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       l_email_subject := replace_token(l_email_subject,'CURRENCY',l_kdetails_rec.currency_code);
       l_email_subject := replace_token(l_email_subject,'CUST_NAME',l_party_name);
     ELSE
       l_email_subject := p_email_attr.EMAIL_SUBJECT;
     END IF;

   -- Quote has been declined by customer or cancelled by salesrep
   ELSIF p_email_attr.EMAIL_TYPE = G_REPORT_TYPE_CANCEL THEN
     IF p_email_attr.IH_SUBJECT IS NULL THEN
       l_ih_subject := get_message('OKS_IH_SUBJECT_CANCEL',l_language);
     ELSE
       l_ih_subject := p_email_attr.IH_SUBJECT;
     END IF;
     -- assemble interaction history body
     IF p_email_attr.IH_MESSAGE IS NULL THEN
       l_ih_message := get_message('OKS_IH_MESSAGE_CANCEL',l_language);
       l_ih_message := replace_token(l_ih_message,'K_NUMBER',l_concat_k_number);
       l_ih_message := replace_token(l_ih_message,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       l_ih_message := replace_token(l_ih_message,'CURRENCY',l_kdetails_rec.currency_code);
       l_ih_message := replace_token(l_ih_message,'CUST_NAME',l_party_name);
     ELSE
       l_ih_message := p_email_attr.IH_MESSAGE;
     END IF;
     IF p_email_attr.EMAIL_SUBJECT IS NULL THEN
       l_email_subject := get_message('OKS_EMAIL_SUB_CANCEL',l_language);
       l_email_subject := replace_token(l_email_subject,'K_NUMBER',l_concat_k_number);
       l_email_subject := replace_token(l_email_subject,'K_AMOUNT',l_kdetails_rec.estimated_amount);
       l_email_subject := replace_token(l_email_subject,'CURRENCY',l_kdetails_rec.currency_code);
       l_email_subject := replace_token(l_email_subject,'CUST_NAME',l_party_name);
     ELSE
       l_email_subject := p_email_attr.EMAIL_SUBJECT;
     END IF;

   -- Quote is being sent to customer for online acceptance
   ELSIF p_email_attr.EMAIL_TYPE = G_REPORT_TYPE_QUOTE THEN
     IF p_email_attr.IH_SUBJECT IS NULL THEN
       l_ih_subject := get_message('OKS_INT_HISTORY_SUBJECT',l_language);
     ELSE
       l_ih_subject := p_email_attr.IH_SUBJECT;
     END IF;
     -- assemble interaction history body
     IF p_email_attr.IH_MESSAGE IS NULL THEN
       l_ih_message := get_message('OKS_INT_HISTORY_MSG_BODY',l_language);
       l_ih_message := replace_token(l_ih_message,'TOKEN1',l_kdetails_rec.contract_number);
       l_ih_message := replace_token(l_ih_message,'TOKEN2',l_kdetails_rec.contract_number_modifier);
       l_ih_message := replace_token(l_ih_message,'TOKEN3',l_qto_email);
     ELSE
       l_ih_message := p_email_attr.IH_MESSAGE;
     END IF;
     IF p_email_attr.EMAIL_SUBJECT IS NULL THEN
       l_email_subject := get_message('OKS_ERN_QEMAIL_SUBJECT',l_language);
       l_email_subject := replace_token(l_email_subject,'TOKEN1',l_concat_k_number);
     ELSE
       l_email_subject := p_email_attr.EMAIL_SUBJECT;
     END IF;

   ELSE
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                    substr('IH Subject '||l_ih_subject,1,1000) ||
                    substr(' IH Message '||l_ih_message,1,1000) ||
                    substr(' Email Subject '||l_email_subject,1,1000));
   END IF;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                    'Setting workflow attributes ');
 END IF;

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'TO_EMAIL',
  avalue   =>  l_qto_email
 );

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'SENDER_EMAIL',
  avalue   =>  l_sender_email
 );

 WF_ENGINE.SetItemAttrNumber
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'ATTACHMENT_ID',
  avalue   =>  NVL(p_email_attr.attachment_id,l_attachment_id)
 );

 WF_ENGINE.SetItemAttrNumber
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'EMAIL_BODY_ID',
  avalue   =>  NVL(p_email_attr.email_body_id,l_email_body_id)
 );

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'ATTACHMENT_NAME',
  avalue   =>  NVL(p_email_attr.attachment_name,l_attachment_name)
 );

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'CONTRACT_STATUS',
  avalue   =>  NVL(p_email_attr.contract_status,l_contract_status)
 );

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'IH_SUBJECT',
  avalue   =>  NVL(p_email_attr.ih_subject,l_ih_subject)
 );

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'IH_MESSAGE',
  avalue   =>  NVL(p_email_attr.ih_message,l_ih_message)
 );

 WF_ENGINE.SetItemAttrText
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'EMAIL_SUBJECT',
  avalue   =>  NVL(p_email_attr.email_subject,l_email_subject)
 );

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                    'Successfully set workflow attributes ');
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,get_fnd_message);
    END IF;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END set_email_attributes;

---------------------------------------------------
PROCEDURE customer_accept_quote
(
 p_api_version    IN         NUMBER,
 p_init_msg_list  IN         VARCHAR2,
 p_commit         IN         VARCHAR2 DEFAULT 'F',
 p_contract_id    IN         NUMBER,
 p_item_key       IN         VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER
) AS

 l_api_version   CONSTANT NUMBER := 1;
 l_api_name      CONSTANT VARCHAR2(30) := 'customer_accept_quote';

 l_send_email_yn          VARCHAR2(1) := 'N';
 l_item_key               wf_items.item_key%TYPE;
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;
 l_notif_attr_rec         OKS_WF_K_PROCESS_PVT.notif_attr_rec;

 CURSOR l_payment_csr(p_chr_id NUMBER) IS
 SELECT fndl.meaning
 FROM okc_k_headers_all_b okch,
      oks_k_headers_b oksh,
      fnd_lookups fndl
 WHERE okch.id = oksh.chr_id
 AND oksh.chr_id = p_chr_id
 AND fndl.lookup_code = DECODE(oksh.payment_type, NULL, okch.payment_instruction_type)
 AND fndl.lookup_type = G_LKUP_TYPE_PAY_TYPES;

BEGIN

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
            'Entered '||G_PKG_NAME ||'.'||l_api_name||' with p_contract_id'||
            p_contract_id||' p_item_key'||p_item_key);
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
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

 IF p_item_key IS NULL THEN
   l_item_key := get_wf_item_key(p_contract_id);
   IF l_item_key IS NULL THEN
     FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   l_item_key := p_item_key;
 END IF;  -- p_item_key IS NULL

 IF activity_exist_in_process (
          p_item_type          =>  G_ITEM_TYPE,
          p_item_key           =>  l_item_key,
          p_activity_name      =>  G_CUST_ACTION ) THEN

   -- bug 5845505, send email only if template for the document type is setup
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.is_template_defined('||
                    ' Contract ID ='||p_contract_id||
                    ' Document Type ='||G_REPORT_TYPE_ACCEPT||')');
   END IF;
   is_template_defined (
                  p_api_version         => l_api_version,
                  p_init_msg_list       => G_FALSE,
                  p_contract_id         => p_contract_id,
                  p_document_type       => G_REPORT_TYPE_ACCEPT,
                  x_template_defined_yn => l_send_email_yn,
                  x_email_attr_rec      => l_email_attr_rec,
                  x_return_status       => x_return_status,
                  x_msg_data            => x_msg_data,
                  x_msg_count           => x_msg_count
                );

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.is_template_defined(x_return_status= '||
                    x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   wf_engine.SetItemAttrText
   (
     itemtype   => G_ITEM_TYPE,
     itemkey    => l_item_key,
     aname      => 'SEND_CONFIRM',
     avalue     => l_send_email_yn
   );

   --log interaction (media type WEB FORM) that customer has accepted the quote
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                    ' Contract ID = '||p_contract_id||
                    substr(' IH Subject = '||l_email_attr_rec.ih_subject,1,100)||
                    substr(' IH Message = '||l_email_attr_rec.ih_message||')',1,100));
   END IF;
   OKS_AUTO_REMINDER.log_interaction (
      p_api_version     => l_api_version,
      p_init_msg_list   => G_FALSE,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chr_id          => p_contract_id,
      p_subject         => l_email_attr_rec.ih_subject,
      p_msg_body        => l_email_attr_rec.ih_message,
      p_sent2_email     => NULL,
      p_media_type      => G_MEDIA_TYPE_WEB_FORM
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_AUTO_REMINDER.log_interaction(x_return_status= '||
                    x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF NVL(l_send_email_yn,'N') = 'Y' THEN
      l_email_attr_rec.CONTRACT_ID       := p_contract_id;
      l_email_attr_rec.ITEM_KEY          := l_item_key;
      l_email_attr_rec.EMAIL_TYPE        := G_REPORT_TYPE_ACCEPT;
      l_email_attr_rec.TO_EMAIL          := NULL;
      l_email_attr_rec.SENDER_EMAIL      := NULL;

      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                       ' Contract ID ='||p_contract_id||
                       ' Email Type ='||l_email_attr_rec.EMAIL_TYPE||')');
      END IF;
      set_email_attributes
      (
       p_api_version    => l_api_version,
       p_init_msg_list  => OKC_API.G_FALSE,
       p_email_attr     => l_email_attr_rec,
       x_return_status  => x_return_status,
       x_msg_data       => x_msg_data,
       x_msg_count      => x_msg_count
      );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                       'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||
                       x_return_status||' x_msg_count ='||x_msg_count||')');
      END IF;
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   OPEN l_payment_csr(p_contract_id);
   FETCH l_payment_csr INTO l_notif_attr_rec.SUBJECT;
   CLOSE l_payment_csr;

   l_notif_attr_rec.CONTRACT_ID       := p_contract_id;
   l_notif_attr_rec.ITEM_KEY          := l_item_key;
   l_notif_attr_rec.PERFORMER         := NULL;
   l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_ACCEPT;
   l_notif_attr_rec.NTF_SUBJECT       := NULL;
   l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                     ' Contract ID ='||p_contract_id||
                     ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                     ' Message Subject ='||l_notif_attr_rec.SUBJECT||')');
   END IF;
   set_notification_attributes
   (
    p_api_version    => l_api_version,
    p_init_msg_list  => OKC_API.G_FALSE,
    p_notif_attr     => l_notif_attr_rec,
    x_return_status  => x_return_status,
    x_msg_data       => x_msg_data,
    x_msg_count      => x_msg_count
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                     x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- valid activity , complete the wf activity
   complete_activity
   (
    p_api_version     => 1,
    p_init_msg_list   => G_FALSE,
    p_contract_id     => p_contract_id,
    p_item_key        => l_item_key,
    p_resultout       => 'ACCEPT',
    p_process_status  => G_NEG_STS_QUOTE_ACPTD,
    p_activity_name   => G_CUST_ACTION,
    x_return_status   => x_return_status,
    x_msg_data	      => x_msg_data,
    x_msg_count	      => x_msg_count
   );

   -- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   -- invalid activity
   fnd_message.set_name(G_APP_NAME,'OKS_INVALID_CUST_ACPT_ACTION');
   fnd_message.set_token('K_NUMBER',get_concat_k_number(p_contract_id));
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 -- end debug log
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END customer_accept_quote;

---------------------------------------------------
PROCEDURE customer_decline_quote
(
 p_api_version    IN         NUMBER,
 p_init_msg_list  IN         VARCHAR2,
 p_commit         IN         VARCHAR2 DEFAULT 'F',
 p_contract_id    IN         NUMBER,
 p_item_key       IN         VARCHAR2,
 p_reason_code    IN         VARCHAR2,
 p_comments       IN         VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER
) AS

 l_api_version     CONSTANT NUMBER := 1;
 l_api_name        CONSTANT VARCHAR2(30) := 'customer_decline_quote';

 CURSOR c_old_sts (p_contract_id IN NUMBER) is
    SELECT STS_CODE
             FROM OKC_K_HEADERS_ALL_B okck,
                  OKC_STATUSES_B sts
             WHERE sts.ste_code = 'ENTERED'
               AND id = p_contract_id
               AND sts.code = okck.sts_code;

 CURSOR l_new_sts_code_csr IS
    SELECT CODE FROM okc_statuses_b
    WHERE ste_code = 'CANCELLED'
    AND default_yn = 'Y'
    AND sysdate BETWEEN START_DATE AND NVL(end_date,SYSDATE+1);

 l_send_email_yn          VARCHAR2(1) := 'N';
 l_item_key               wf_items.item_key%TYPE;
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;
 l_notif_attr_rec         OKS_WF_K_PROCESS_PVT.notif_attr_rec;
 l_old_sts                OKC_STATUSES_B.CODE%TYPE;
 l_new_sts                OKC_STATUSES_B.CODE%TYPE;
 l_rownotfound            BOOLEAN := FALSE;
 l_reason                 VARCHAR2(250);

BEGIN
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                  'Entered '||G_PKG_NAME ||'.'||l_api_name||' with p_contract_id'||
                  p_contract_id||' p_item_key:'||p_item_key);
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                  'p_reason_code:'||p_reason_code||' p_comments:'||p_comments);
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
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

 IF p_item_key IS NULL THEN
   l_item_key := get_wf_item_key(p_contract_id);
   IF l_item_key IS NULL THEN
     FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   l_item_key := p_item_key;
 END IF;  -- p_item_key IS NULL

 IF activity_exist_in_process (
          p_item_type          =>  G_ITEM_TYPE,
          p_item_key           =>  l_item_key,
          p_activity_name      =>  G_CUST_ACTION ) THEN

   -- bug 5845505, send email only if template for the document type is setup
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.is_template_defined('||
                    ' Contract ID ='||p_contract_id||
                    ' Document Type ='||G_REPORT_TYPE_CANCEL||')');
   END IF;
   is_template_defined (
                  p_api_version         => l_api_version,
                  p_init_msg_list       => G_FALSE,
                  p_contract_id         => p_contract_id,
                  p_document_type       => G_REPORT_TYPE_CANCEL,
                  x_template_defined_yn => l_send_email_yn,
                  x_email_attr_rec      => l_email_attr_rec,
                  x_return_status       => x_return_status,
                  x_msg_data            => x_msg_data,
                  x_msg_count           => x_msg_count
                );

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.is_template_defined(x_return_status= '||
                    x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   wf_engine.SetItemAttrText
   (
     itemtype   => G_ITEM_TYPE,
     itemkey    => l_item_key,
     aname      => 'SEND_CONFIRM',
     avalue     => l_send_email_yn
   );

   l_reason := get_lookup_meaning(p_reason_code,G_LKUP_TYPE_CNCL_REASON);

   --log interaction (media type WEB FORM) that customer has declined the quote
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                    ' Contract ID = '||p_contract_id||
                    substr(' IH Message = '||p_comments,1,100)||
                    substr(' IH Subject = '||l_reason||')',1,100));
   END IF;
   OKS_AUTO_REMINDER.log_interaction (
      p_api_version     => l_api_version,
      p_init_msg_list   => G_FALSE,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chr_id          => p_contract_id,
      p_subject         => l_reason,
      p_msg_body        => p_comments,
      p_sent2_email     => NULL,
      p_media_type      => G_MEDIA_TYPE_WEB_FORM
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_AUTO_REMINDER.log_interaction(x_return_status= '||
                    x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF NVL(l_send_email_yn,'N') = 'Y' THEN

     l_email_attr_rec.CONTRACT_ID       := p_contract_id;
     l_email_attr_rec.ITEM_KEY          := l_item_key;
     l_email_attr_rec.EMAIL_TYPE        := G_REPORT_TYPE_CANCEL;
     l_email_attr_rec.TO_EMAIL          := NULL;
     l_email_attr_rec.SENDER_EMAIL      := NULL;

     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                      'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                      ' Contract ID ='||p_contract_id||
                      ' Email Type ='||l_email_attr_rec.EMAIL_TYPE||')');
     END IF;
     set_email_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_email_attr     => l_email_attr_rec,
      x_return_status  => x_return_status,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                      'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||
                      x_return_status||' x_msg_count ='||x_msg_count||')');
     END IF;
     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   l_notif_attr_rec.CONTRACT_ID       := p_contract_id;
   l_notif_attr_rec.ITEM_KEY          := l_item_key;
   l_notif_attr_rec.PERFORMER         := NULL;
   l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_DECLINE;
   l_notif_attr_rec.NTF_SUBJECT       := NULL;
   l_notif_attr_rec.SUBJECT           := l_reason;
   l_notif_attr_rec.MESSAGE1          := p_comments;
   l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||p_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
   END IF;
   set_notification_attributes
   (
    p_api_version    => l_api_version,
    p_init_msg_list  => OKC_API.G_FALSE,
    p_notif_attr     => l_notif_attr_rec,
    x_return_status  => x_return_status,
    x_msg_data       => x_msg_data,
    x_msg_count      => x_msg_count
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                     x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN c_old_sts(p_contract_id);
   FETCH c_old_sts INTO l_old_sts;
   l_rownotfound := c_old_sts%NOTFOUND;
   CLOSE c_old_sts;
   IF NOT l_rownotfound THEN

     -- Bug fix 5893728
     OPEN l_new_sts_code_csr;
     FETCH l_new_sts_code_csr INTO l_new_sts;
     CLOSE l_new_sts_code_csr;

     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS(p_id= '||p_contract_id||
                    ' p_old_sts_code ='||l_old_sts||' p_comments ='||substr(p_comments,1,250)||
                    ' p_canc_reason_code ='||p_reason_code||')');
     END IF;
     OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS (
                               x_return_status      => x_return_status,
                               x_msg_data           => x_msg_data,
                               x_msg_count          => x_msg_count,
                               p_init_msg_list      => G_FALSE,
                               p_id                 => p_contract_id,
                               p_new_sts_code       => l_new_sts,
                               p_old_sts_code       => l_old_sts,
                               p_canc_reason_code   => p_reason_code,
                               p_comments           => p_comments,
                               p_term_cancel_source => G_PERFORMED_BY_CUST,
                               p_date_cancelled     => SYSDATE,
                               p_validate_status    => 'N') ;
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                      'OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS(x_return_status= '||x_return_status||
                      ' x_msg_count ='||x_msg_count||')');
     END IF;
     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   ELSE
     FND_MESSAGE.set_name('OKS','OKS_CANT_CANCEL_K');  -- set the message here
     FND_MESSAGE.set_token('K_NUMBER',get_concat_k_number(p_contract_id));
     fnd_msg_pub.add;
     RAISE  FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   -- invalid activity
   fnd_message.set_name(G_APP_NAME,'OKS_INVALID_CUST_DCLN_ACTION');
   fnd_message.set_token('K_NUMBER',get_concat_k_number(p_contract_id));
   fnd_msg_pub.add;
   RAISE  FND_API.G_EXC_ERROR;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 -- end debug log
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END customer_decline_quote;

---------------------------------------------------
PROCEDURE customer_request_assistance
(
 p_api_version    IN         NUMBER,
 p_init_msg_list  IN         VARCHAR2,
 p_commit         IN         VARCHAR2 DEFAULT 'F',
 p_contract_id    IN         NUMBER,
 p_item_key       IN         VARCHAR2,
 p_to_email       IN         VARCHAR2,
 p_cc_email       IN         VARCHAR2,
 p_subject        IN         VARCHAR2,
 p_message        IN         VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER
) AS

 l_api_version              CONSTANT NUMBER := 1;
 l_api_name                 CONSTANT VARCHAR2(30) := 'customer_request_assistance';
 l_item_key                 wf_items.item_key%TYPE;
 l_interaction_subject      VARCHAR2(4000);
 l_interaction_message      VARCHAR2(4000);
 l_role_name                wf_roles.name%TYPE := NULL;
 l_role_email               wf_roles.email_address%TYPE;
 l_notif_attr_rec           OKS_WF_K_PROCESS_PVT.notif_attr_rec;
 l_salesrep_email           VARCHAR2(240);
 l_salesrep_username        VARCHAR2(100);
 l_display_rolename         VARCHAR2(360);

tmp_email_list VARCHAR2(8000) ;
i NUMBER := 0;
j NUMBER := 0;

TYPE l_user_list       IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
l_user_tbl               l_user_list;
l_user_name            VARCHAR2(4000);
x_user_name            VARCHAR2(4000);


BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name||
                    '(p_contract_id=>'||p_contract_id||
                    ',p_item_key=>'||p_item_key||
                    ',p_to_email=>'||p_to_email||')');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'p_cc_email=>'||p_cc_email||
                    ',p_subject=>'||p_subject||
                    ',p_message=>'||p_message||')');
  END IF;

  DBMS_TRANSACTION.SAVEPOINT(l_api_name);
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

  IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id);
    IF l_item_key IS NULL THEN
      FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_item_key := p_item_key;
  END IF;  -- p_item_key IS NULL

  IF activity_exist_in_process (
          p_item_type          =>  G_ITEM_TYPE,
          p_item_key           =>  l_item_key,
          p_activity_name      =>  G_CUST_ACTION ) THEN

    -- Ignore the p_to_email value and get the salesrep email and FND username again
    -- Due to big impact of changing the signature we r taking this route
    -- This changes are done due to the requirement to send notification to Salesrep
    -- and an email to cc'ed guys
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_CUSTOMER_ACCEPTANCE_PVT.get_contract_salesrep_details('||
                    ' Contract ID ='||p_contract_id||')');
    END IF;
    OKS_CUSTOMER_ACCEPTANCE_PVT.get_contract_salesrep_details
    (
     p_chr_id            => p_contract_id,
     x_salesrep_email    => l_salesrep_email,
     x_salesrep_username => l_salesrep_username,
     x_return_status     => x_return_status,
     x_msg_data          => x_msg_data,
     x_msg_count         => x_msg_count
    );
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_CUSTOMER_ACCEPTANCE_PVT.get_contract_salesrep_details(x_salesrep_email= '||
                    l_salesrep_email||' x_salesrep_username= '||l_salesrep_username||
                    'x_return_status= '||x_return_status||' x_msg_count ='||x_msg_count||')');
    END IF;
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_cc_email IS NOT NULL THEN
      -- Create a adhoc user and role for wf to send the email
      l_role_name := p_contract_id||' - '||to_char(sysdate,'DDMMYYYYHHMISS');

      -- Create adhoc user for wf
      --Convert email list (string) to PL/SQL Array for creating adhoc users
      tmp_email_list := p_cc_email;

      LOOP
        i := INSTR(tmp_email_list,',');

        -- debug log
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                          G_MODULE||l_api_name,'i : '||i);
        END IF;

        IF i > 0 THEN
          -- comma found

          l_user_tbl(j) := SUBSTR(tmp_email_list,1,i-1);

          -- debug log
          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE||l_api_name,'j :'||j);
          END IF;

          tmp_email_list := SUBSTR(tmp_email_list,i+1, length(tmp_email_list) - i);

          -- debug log
          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            'tmp_email_list : '||tmp_email_list);
          END IF;

          j := j + 1;
        ELSE
          -- no comma found i.e last contract id
          l_user_tbl(j) := tmp_email_list;
          EXIT;
        END IF;

      END LOOP;

      -- debug log
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        'After Converting email list to pl/sql');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        'Count of Emails is : '||l_user_tbl.COUNT);
      END IF;


      -- for each email create a adhoc user
      FOR k IN NVL(l_user_tbl.FIRST,0)..NVL(l_user_tbl.LAST,-1)
      LOOP

         x_user_name := '';

         IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                      'Wf_Directory.CreateAdHocUser(email_address ='||l_user_tbl(k)||')');
         END IF;

         BEGIN
           WF_DIRECTORY.CreateAdHocUser(
              name                    => x_user_name,
              display_name            => x_user_name,
              language                => null,
              territory               => null,
              description             => 'OKS: Renewal Adhoc User',
              notification_preference => 'MAILHTML',
              email_address           => l_user_tbl(k),
              status                  => 'ACTIVE',
              expiration_date         => SYSDATE+1 ,
              parent_orig_system      => null,
              parent_orig_system_id   => null);
         EXCEPTION
           WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_CREATE_ADHOC_USER_FAILED');
              FND_MESSAGE.set_token('USER_NAME',l_user_tbl(k));
              FND_MESSAGE.set_token('SQL_ERROR',SQLERRM);
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
         END;


         IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                      'Wf_Directory.CreateAdHocUser SUCCESS created user : '||x_user_name);
         END IF;

         -- build concatinated list of user name for adhoc role
         l_user_name := l_user_name||','||x_user_name;

      END LOOP;


      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'Wf_Directory.CreateAdHocRole(email_address ='||p_cc_email||')');
      END IF;

      -- call wf api to create the adhoc role
      BEGIN
        l_display_rolename := substr(p_cc_email,1,360);
        Wf_Directory.CreateAdHocRole
        (
         role_name               => l_role_name,
         role_display_name       => l_role_name, --l_display_rolename, COMMENTED COZ EMAIL NOT DELIVERED
         language                => null,
         territory               => null,
         role_description        => 'OKS: Renewal Adhoc role',
         notification_preference => 'MAILHTML',
         role_users              => l_user_name,
         email_address           => NULL,
         fax                     => null,
         status                  => 'ACTIVE',
         expiration_date         => SYSDATE+1,
         parent_orig_system      => null,
         parent_orig_system_id   => null,
         owner_tag               => null
        );
      EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_CREATE_ADHOC_ROLE_FAILED');
            FND_MESSAGE.set_token('ROLE_NAME',l_role_name);
            FND_MESSAGE.set_token('SQL_ERROR',SQLERRM);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
      END;

      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'Wf_Directory.CreateAdHocRole - Success');
      END IF;
    END IF;

    l_notif_attr_rec.CONTRACT_ID       := p_contract_id;
    l_notif_attr_rec.ITEM_KEY          := l_item_key;
    l_notif_attr_rec.PERFORMER         := l_salesrep_username;
    l_notif_attr_rec.REQ_ASSIST_ROLE   := l_role_name;
    l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_MESSAGE;
    l_notif_attr_rec.NTF_SUBJECT       := NULL;
    l_notif_attr_rec.SUBJECT           := p_subject;
    l_notif_attr_rec.MESSAGE1          := p_message;
    l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;

    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                     ' Contract ID ='||p_contract_id||
                     ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                     ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
    END IF;
    set_notification_attributes
    (
     p_api_version    => l_api_version,
     p_init_msg_list  => OKC_API.G_FALSE,
     p_notif_attr     => l_notif_attr_rec,
     x_return_status  => x_return_status,
     x_msg_data       => x_msg_data,
     x_msg_count      => x_msg_count
    );
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                     x_return_status||' x_msg_count ='||x_msg_count||')');
    END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- log interaction history
    fnd_message.set_name(G_APP_NAME,'OKS_IH_SUBJECT_CUST_ASS');
    l_interaction_subject := fnd_message.get;

    fnd_message.set_name(G_APP_NAME,'OKS_IH_MESSAGE_CUST_ASS');
    fnd_message.set_token('K_NUMBER',get_concat_k_number(p_contract_id));
    fnd_message.set_token('SUBJECT',p_subject);
    fnd_message.set_token('MESSAGE',p_message);
    l_interaction_message  := fnd_message.get;

    IF p_cc_email IS NULL THEN
      l_role_email := l_salesrep_email;
    ELSE
      l_role_email := l_salesrep_email||','||p_cc_email;
    END IF;

    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKS_AUTO_REMINDER.log_interaction(p_contract_id= '
                     ||p_contract_id||' p_subject='||l_interaction_subject||
                     ' p_msg_body='||l_interaction_message||
                     ' p_sent2_email='||l_role_email||')');
    END IF;
    OKS_AUTO_REMINDER.log_interaction
    (
     p_api_version    => l_api_version,
     p_init_msg_list  => G_FALSE,
     x_return_status  => x_return_status,
     x_msg_count      => x_msg_data,
     x_msg_data       => x_msg_count,
     p_chr_id         => p_contract_id,
     p_subject        => l_interaction_subject,
     p_msg_body       => l_interaction_message,
     p_sent2_email    => l_role_email
    );
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_AUTO_REMINDER.log_interaction(x_return_status= '||x_return_status||
                  ' x_msg_count ='||x_msg_count||')');
    END IF;
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- valid activity , complete the wf activity
    complete_activity
    (
     p_api_version     => 1,
     p_init_msg_list   => FND_API.G_FALSE,
     p_contract_id     => p_contract_id,
     p_item_key        => l_item_key,
     p_resultout       => 'REQUEST_ASSISTANCE',
     p_process_status  => G_NEG_STS_ASSIST_REQD,
     p_activity_name   => G_CUST_ACTION,
     x_return_status   => x_return_status,
     x_msg_data        => x_msg_data,
     x_msg_count       => x_msg_count
    );
    -- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE
    -- invalid activity
    FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_REQ_ASST_ACTION');
    fnd_message.set_token('K_NUMBER',get_concat_k_number(p_contract_id));
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END customer_request_assistance;

/*=========================================================================
  API name      : update_negotiation_status
  Type          : Private.
  Function      : This procedure updates renewal status in OKS_K_HEADERS_B
                  and bumps up the version.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_chr_id         IN NUMBER         Required
                     Contract header Id
                : p_negotiation_status IN VARCHAR2   Required
                     New negotiation status that is to be updated.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE update_negotiation_status
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_chr_id               IN         NUMBER,
 p_negotiation_status   IN         VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'update_negotiation_status';

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
            'Entered '||G_PKG_NAME ||'.'||l_api_name||
            '(p_chr_id=>'||p_chr_id||'p_negotiation_status=>'||p_negotiation_status||')');
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_negotiation_status IS NOT NULL THEN
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Updating Contract: '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
   UPDATE oks_k_headers_b
       SET renewal_status        = p_negotiation_status,
           object_version_number = object_version_number + 1,
           last_update_date      = SYSDATE,
           last_updated_by       = FND_GLOBAL.USER_ID,
           last_update_login     = FND_GLOBAL.LOGIN_ID,
           /* Added by sjanakir for Bug# 7639337 */
           quote_sent_flag       = DECODE(p_negotiation_status,G_NEG_STS_QUOTE_SENT,'Y',quote_sent_flag)
       WHERE chr_id              = p_chr_id;

/* COMMENTING THE CODE DUE TO DEADLOCK ISSUES ENCOUNTERED WHILE COMPLETING WF
    -- bump up the minor version number
    UPDATE okc_k_vers_numbers
       SET minor_version         = minor_version + 1,
           object_version_number = object_version_number + 1,
           last_update_date      = SYSDATE,
           last_updated_by       = FND_GLOBAL.USER_ID,
           last_update_login     = FND_GLOBAL.LOGIN_ID
       WHERE chr_id              = p_chr_id;
*/
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END update_negotiation_status;

/*=========================================================================
  API name      : set_notification_attr
  Type          : Private.
  Function      : This procedure sets all the relavant wf item attribute
                  values that will be used in notifications. This api is called
                  from workflow node and is a wrapper for set_notification_attributes
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE set_notification_attr
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'set_notification_attr';
 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(4000);

 l_contract_id            NUMBER;
 l_notif_type             VARCHAR2(30);
 l_notif_attr_rec         OKS_WF_K_PROCESS_PVT.notif_attr_rec;

 l_send_email_yn          VARCHAR2(1) := 'N';
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'itemtype: ' || itemtype ||
                ' itemkey: ' || itemkey  ||
                ' actid: ' || to_char(actid) ||
                ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

   l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

   l_notif_type := wf_engine.GetActivityAttrText
                   (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    actid    => actid,
                    aname    => 'NOTIF_TYPE'
                   );

   l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
   l_notif_attr_rec.ITEM_KEY          := itemkey;
   l_notif_attr_rec.PERFORMER         := NULL;
   l_notif_attr_rec.NTF_TYPE          := l_notif_type;
   l_notif_attr_rec.NTF_SUBJECT       := NULL;
   l_notif_attr_rec.SUBJECT           := NULL;
   l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||')');
   END IF;
   set_notification_attributes
   (
    p_api_version    => l_api_version,
    p_init_msg_list  => OKC_API.G_FALSE,
    p_notif_attr     => l_notif_attr_rec,
    x_return_status  => l_return_status,
    x_msg_data       => l_msg_data,
    x_msg_count      => l_msg_count
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                  l_return_status||' x_msg_count ='||l_msg_count||')');
   END IF;
   IF l_return_status <> G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- check if a template is defined to send a Activation
   -- confirmation message only in activation flow
   IF l_notif_type = G_NTF_TYPE_ACTIVE THEN

     -- bug 5845505, send email only if template for the document type is setup
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                      'OKS_WF_K_PROCESS_PVT.is_template_defined('||
                      ' Contract ID ='||l_contract_id||
                      ' Document Type ='||G_REPORT_TYPE_ACTIVE||')');
     END IF;
     is_template_defined (
                p_api_version         => l_api_version,
                p_init_msg_list       => G_FALSE,
                p_contract_id         => l_contract_id,
                p_document_type       => G_REPORT_TYPE_ACTIVE,
                x_template_defined_yn => l_send_email_yn,
                x_email_attr_rec      => l_email_attr_rec,
                x_return_status       => l_return_status,
                x_msg_data            => l_msg_data,
                x_msg_count           => l_msg_count
              );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                       'OKS_WF_K_PROCESS_PVT.is_template_defined(x_return_status= '||
                       l_return_status||' x_msg_count ='||l_msg_count||')');
      END IF;
      IF l_return_status <> G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      wf_engine.SetItemAttrText
      (
       itemtype   => itemtype,
       itemkey    => itemkey,
       aname      => 'SEND_CONFIRM',
       avalue     => l_send_email_yn
      );
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
   END IF;
   RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.FND_API.G_EXC_ERROR'
          ||' Itemtype: '||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END set_notification_attr;

/*=========================================================================
  API name      : set_notification_attr
  Type          : Private.
  Function      : This procedure sets all the relavant wf item attribute
                  values that will be used in notifications. This api is called
                  from concurrent program and is a wrapper for
                  set_notification_attributes. Since table structure is not
                  supported in Java (CP), we need to use this wrapper.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id    IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2       Required
                     Contract process workflow's item key.
                : p_performer      IN VARCHAR2       Required
                     Notification performer; Person to whom this notification
                     will be sent and who will act on the notification.
                : p_notif_type     IN VARCHAR2       Required
                     Type of notification. In case of errors it'll be 'ERROR'.
                     This is used for rendering correct region in notification.
                : p_notif_subject  IN VARCHAR2       Required
                     Subject of the notification.
                : p_message1       IN VARCHAR2       Required
                     Messages 1 to 10; detailed information in the notification.
                : p_message2       IN VARCHAR2       Required
                : p_message3       IN VARCHAR2       Required
                : p_message4       IN VARCHAR2       Required
                : p_message5       IN VARCHAR2       Required
                : p_message6       IN VARCHAR2       Required
                : p_message7       IN VARCHAR2       Required
                : p_message8       IN VARCHAR2       Required
                : p_message9       IN VARCHAR2       Required
                : p_message10      IN VARCHAR2       Required
                : p_subject        IN VARCHAR2       Required
                     Subject of the sharable region in the notification.
                : p_msgs_from_stack_yn IN VARCHAR2   Required
                     Flag to specify whether to read message stack while populating
                     error messages.
  OUT           : x_return_status  OUT  VARCHAR2
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE set_notification_attr
(
 p_api_version          IN        NUMBER,
 p_init_msg_list        IN        VARCHAR2,
 p_contract_id          IN        NUMBER,
 p_performer            IN        VARCHAR2,
 p_notif_type           IN        VARCHAR2,
 p_notif_subject        IN        VARCHAR2,
 p_message1             IN        VARCHAR2,
 p_message2             IN        VARCHAR2,
 p_message3             IN        VARCHAR2,
 p_message4             IN        VARCHAR2,
 p_message5             IN        VARCHAR2,
 p_message6             IN        VARCHAR2,
 p_message7             IN        VARCHAR2,
 p_message8             IN        VARCHAR2,
 p_message9             IN        VARCHAR2,
 p_message10            IN        VARCHAR2,
 p_subject              IN        VARCHAR2,
 p_msgs_from_stack_yn   IN        VARCHAR2,
 x_return_status       OUT nocopy VARCHAR2,
 x_msg_count           OUT NOCOPY VARCHAR2,
 x_msg_data            OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'set_notification_attr';

 l_notif_attr_rec         OKS_WF_K_PROCESS_PVT.notif_attr_rec;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'p_contract_id: ' || p_contract_id ||
                ' p_performer: ' || p_performer  ||
                ' p_notif_type: ' || p_notif_type ||
                ' p_notif_subject: ' || p_notif_subject);
 END IF;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 l_notif_attr_rec.CONTRACT_ID        := p_contract_id;
 l_notif_attr_rec.ITEM_KEY           := get_wf_item_key(p_contract_id);
 l_notif_attr_rec.PERFORMER          := p_performer;
 l_notif_attr_rec.NTF_TYPE           := p_notif_type;
 l_notif_attr_rec.NTF_SUBJECT        := p_notif_subject;
 l_notif_attr_rec.SUBJECT            := p_subject;
 l_notif_attr_rec.ACCEPT_DECLINE_BY  := NULL;
 l_notif_attr_rec.MESSAGE1           := p_message1;
 l_notif_attr_rec.MESSAGE2           := p_message2;
 l_notif_attr_rec.MESSAGE3           := p_message3;
 l_notif_attr_rec.MESSAGE4           := p_message4;
 l_notif_attr_rec.MESSAGE5           := p_message5;
 l_notif_attr_rec.MESSAGE6           := p_message6;
 l_notif_attr_rec.MESSAGE7           := p_message7;
 l_notif_attr_rec.MESSAGE8           := p_message8;
 l_notif_attr_rec.MESSAGE9           := p_message9;
 l_notif_attr_rec.MESSAGE10          := p_message10;
 l_notif_attr_rec.MSGS_FROM_STACK_YN := p_msgs_from_stack_yn;

 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                  'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                  ' Contract ID ='||l_notif_attr_rec.CONTRACT_ID||
                  ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||')');
 END IF;
 set_notification_attributes
 (
  p_api_version    => l_api_version,
  p_init_msg_list  => OKC_API.G_FALSE,
  p_notif_attr     => l_notif_attr_rec,
  x_return_status  => x_return_status,
  x_msg_data       => x_msg_data,
  x_msg_count      => x_msg_count
 );
 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                  x_return_status||' x_msg_count ='||x_msg_count||')');
 END IF;
 IF x_return_status <> G_RET_STS_SUCCESS THEN
   RAISE FND_API.G_EXC_ERROR;
 END IF;
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
         'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,get_fnd_message);
    END IF;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END set_notification_attr;

/*=========================================================================
  API name      : set_email_attr
  Type          : Private.
  Function      : This procedure sets all the relavant wf item attribute
                  values that will be used while sending email. This api is called
                  from workflow node and is a wrapper for set_email_attributes.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE set_email_attr
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'set_email_attr';
 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(4000);

 l_contract_id            NUMBER;
 l_email_type             VARCHAR2(30);
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'itemtype: ' || itemtype ||
                ' itemkey: ' || itemkey  ||
                ' actid: ' || to_char(actid) ||
                ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

   l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

   l_email_type := wf_engine.GetActivityAttrText
                   (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    actid    => actid,
                    aname    => 'EMAIL_TYPE'
                   );

   l_email_attr_rec.CONTRACT_ID       := l_contract_id;
   l_email_attr_rec.ITEM_KEY          := itemkey;
   l_email_attr_rec.EMAIL_TYPE        := l_email_type;
   l_email_attr_rec.TO_EMAIL          := NULL;
   l_email_attr_rec.SENDER_EMAIL      := NULL;
   l_email_attr_rec.EMAIL_SUBJECT     := NULL;
   l_email_attr_rec.IH_SUBJECT        := NULL;
   l_email_attr_rec.IH_MESSAGE        := NULL;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                    ' Contract ID ='||l_email_attr_rec.CONTRACT_ID||
                    ' Email Type ='||l_email_attr_rec.EMAIL_TYPE||')');
   END IF;
   set_email_attributes
   (
    p_api_version    => l_api_version,
    p_init_msg_list  => OKC_API.G_FALSE,
    p_email_attr     => l_email_attr_rec,
    x_return_status  => l_return_status,
    x_msg_data       => l_msg_data,
    x_msg_count      => l_msg_count
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
   END IF;
   IF l_return_status <> G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
   END IF;
   RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.FND_API.G_EXC_ERROR'
          ||' Itemtype: '||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END set_email_attr;

--cgopinee start bugfix for 6787913
/*=========================================================================
  API name      : email_mute
  Type          : Private.
  Function      : This procedure sets all the relavant wf item attribute
                  values that will be used while for suppressing or sending
                  a mail for based on profile option OKC_SUPPRESS_EMAIL.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
procedure email_mute(	itemtype	in varchar2,
			itemkey  	in varchar2,
			actid		in number,
			funcmode	in varchar2,
			resultout out nocopy varchar2	)
			is
l_api_name  CONSTANT VARCHAR2(30) := 'email_mute';

l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'NTF_TYPE');
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'PERFORMER');
cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;
l_user_id number;
l_p_value varchar2(3);


begin

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
               'Entered email_mute'||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  if (funcmode = 'RUN') then
	open c1(l_user_name);
	fetch c1 into l_user_id;
	close c1;
	l_p_value := FND_PROFILE.VALUE_SPECIFIC
			(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
			 USER_ID 	=> l_user_id,
			 RESPONSIBILITY_ID => NULL,
			 APPLICATION_ID => NULL);

	if (l_p_value is NULL) then
	   l_p_value := FND_PROFILE.VALUE_SPECIFIC
			(NAME 		=> G_MUTE_PROFILE,
			 USER_ID 	=> l_user_id,
			 RESPONSIBILITY_ID=> NULL,
			 APPLICATION_ID => NULL);
	end if;

	if (l_p_value is NULL or l_p_value='N') then
	    wf_engine.SetItemAttrText
	    		(itemtype 	=> G_WF_NAME,
	      		 itemkey  	=> itemkey,
  	      		 aname 	=> '.MAIL_QUERY',
 			avalue	=> ' ');
	else
	    wf_engine.SetItemAttrText
	    		(itemtype 	=> G_WF_NAME,
	      		 itemkey  	=> itemkey,
  	      		 aname 	=> '.MAIL_QUERY',
			 avalue	=> l_user_name);
  	end if;
  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
		          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
	END IF;

  end if;

  if (funcmode = 'CANCEL') then
	--                                                                                                 31.01.2008 14:49
  	resultout := 'COMPLETE:';

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
	          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    	END IF;

	return;
	--
  end if;

  --
  -- TIMEOUT mode
  --
  if (funcmode = 'TIMEOUT') then
  --
	resultout := 'COMPLETE:';

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
	          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
        END IF;

	return;
		--
  end if;

exception
	when others then
	 IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
	          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
	          ||SQLCODE||', sqlerrm = '||SQLERRM);
	 END IF;

	 wf_core.CONTEXT
	    (
	      pkg_name  => G_PKG_NAME,
	      proc_name => l_api_name,
	      arg1      => itemtype,
	      arg2      => itemkey,
	      arg3      => to_char(actid),
	      arg4      => funcmode,
	      arg5      => SQLCODE,
	      arg6      => SQLERRM
	    );

end email_mute;

--cgopinee end bugfix for 6787913

/*=========================================================================
  API name      : launch_k_process_wf
  Type          : Private.
  Function      : This procedure launches the Service Contracts Process
                  workflow. Whenever a contract is created this api will
                  be called to launch the wf instance.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_wf_attributes  IN VARCHAR2       Required
                     Workflow item attribute values that have to be
                     initialized while launching it.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE launch_k_process_wf
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_wf_attributes        IN         OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'launch_k_process_wf';

 CURSOR l_kdetails_csr(l_contract_id NUMBER) IS
 SELECT contract_number, contract_number_modifier
 FROM okc_k_headers_all_b
 WHERE id = l_contract_id;

  /*start bug8705707*/
 CURSOR wf_cur(p_wf_item_key varchar2) IS
 SELECT ITEM_TYPE
   FROM WF_ITEMS
  WHERE item_key = p_wf_item_key;

 l_item_type VARCHAR2(30);
 /*end bug8705707*/

 l_contract_number    VARCHAR2(120);
 l_contract_modifier  VARCHAR2(120);
 l_item_key           wf_items.item_key%TYPE;
 l_user_key           VARCHAR2(240);
 l_save_threshold     NUMBER;

BEGIN
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name||
                'CONTRACT_ID=>'||p_wf_attributes.CONTRACT_ID||
                'CONTRACT_NUMBER=>'||p_wf_attributes.CONTRACT_NUMBER||
                'CONTRACT_MODIFIER=>'||p_wf_attributes.CONTRACT_MODIFIER);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'PROCESS_TYPE=>'||p_wf_attributes.PROCESS_TYPE||
                'IRR_FLAG=>'||p_wf_attributes.IRR_FLAG||
                'NEGOTIATION_STATUS=>'||p_wf_attributes.NEGOTIATION_STATUS||
                'ITEM_KEY=>'||p_wf_attributes.ITEM_KEY||')');
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_wf_attributes.contract_id IS NULL THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
   FND_MESSAGE.SET_TOKEN('HDR_ID','NULL');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_wf_attributes.item_key IS NOT NULL THEN
    l_item_key := p_wf_attributes.item_key;
 ELSE
    l_item_key := p_wf_attributes.contract_id ||
               to_char(sysdate, 'YYYYMMDDHH24MISS');
 END IF;

 IF p_wf_attributes.contract_number IS NOT NULL THEN
   l_user_key := p_wf_attributes.contract_number;
   l_contract_number := p_wf_attributes.contract_number;
   IF p_wf_attributes.contract_modifier IS NOT NULL THEN
     l_user_key := l_user_key || ' ' || p_wf_attributes.contract_modifier;
     l_contract_modifier := p_wf_attributes.contract_modifier;
   END IF;
 ELSE
   OPEN l_kdetails_csr(p_wf_attributes.contract_id);
   FETCH l_kdetails_csr INTO l_contract_number,l_contract_modifier;
   CLOSE l_kdetails_csr;
   l_user_key := l_contract_number;
   IF l_contract_modifier IS NOT NULL THEN
      l_user_key := l_user_key || ' ' || l_contract_modifier;
   END IF;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Creating process with Item key: ' || l_item_key ||
                ' Contract Id: ' || p_wf_attributes.contract_id  ||
                ' User Key: ' || l_user_key ||' Process Type: '|| p_wf_attributes.process_type);
 END IF;

 -- If wf is being launched in the process of renewing a contract, negotiation
 -- status will be set to Pre Draft in which case we'll defer it or else wf will
 -- proceed further and wait for salesrep's action
 -- Do not defer WF for New Contract or for NSR(Manual) renewal type of Contract
 --IF p_wf_attributes.negotiation_status = G_NEG_STS_PRE_DRAFT THEN
 IF p_wf_attributes.process_type IN (G_NEW_CONTRACT, G_RENEW_TYPE_MANUAL) THEN
   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Process will be synchronous for Item key: ' || l_item_key ||
                ' Contract Id: ' || p_wf_attributes.contract_id  ||
                ' User Key: ' || l_user_key );
   END IF;
 ELSE
   l_save_threshold := WF_ENGINE.threshold;
   WF_ENGINE.threshold := -1;
   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Process will be deferred for Item key: ' || l_item_key ||
                ' Contract Id: ' || p_wf_attributes.contract_id  ||
                ' User Key: ' || l_user_key );
   END IF;
 END IF;

 -- Create the workflow process
 WF_ENGINE.CREATEPROCESS
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  process  => G_MAIN_PROCESS,
  user_key => l_user_key
 );

 wf_engine.SetItemAttrNumber
 (
  itemtype  => G_ITEM_TYPE,
  itemkey   => l_item_key,
  aname     => 'CONTRACT_ID',
  avalue    => p_wf_attributes.contract_id
 );

 WF_ENGINE.setitemattrtext
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'CONTRACT_NUMBER',
  avalue   =>  l_contract_number
 );

 WF_ENGINE.setitemattrtext
 (
  itemtype =>  G_ITEM_TYPE,
  itemkey  =>  l_item_key,
  aname    =>  'CONTRACT_MODIFIER',
  avalue   =>  l_contract_modifier
 );

 IF p_wf_attributes.process_type IS NOT NULL THEN
    WF_ENGINE.setitemattrtext
    (
     itemtype =>  G_ITEM_TYPE,
     itemkey  =>  l_item_key,
     aname    =>  'PROCESS_TYPE',
     avalue   =>  p_wf_attributes.process_type
    );
 END IF;
 IF p_wf_attributes.irr_flag IS NOT NULL THEN
    WF_ENGINE.setitemattrtext
    (
     itemtype =>  G_ITEM_TYPE,
     itemkey  =>  l_item_key,
     aname    =>  'IRR_FLAG',
     avalue   =>  p_wf_attributes.irr_flag
    );
 END IF;
 IF p_wf_attributes.negotiation_status IS NOT NULL AND
    p_wf_attributes.negotiation_status <> G_NEG_STS_PRE_DRAFT THEN

    WF_ENGINE.setitemattrtext
    (
     itemtype =>  G_ITEM_TYPE,
     itemkey  =>  l_item_key,
     aname    =>  'NEGOTIATION_STATUS',
     avalue   =>  p_wf_attributes.negotiation_status
    );
 END IF;

 -- Added 4 item attributes below to fix bug 4776175
 -- These values are passed to approval workflow
 wf_engine.SetItemAttrNumber
 (
  itemtype  => G_ITEM_TYPE,
  itemkey   => l_item_key,
  aname     => 'USER_ID',
  avalue    => fnd_global.user_id
 );

 wf_engine.SetItemAttrNumber
 (
  itemtype  => G_ITEM_TYPE,
  itemkey   => l_item_key,
  aname     => 'RESP_ID',
  avalue    => fnd_global.resp_id
 );

 wf_engine.SetItemAttrNumber
 (
  itemtype  => G_ITEM_TYPE,
  itemkey   => l_item_key,
  aname     => 'RESP_APPL_ID',
  avalue    => fnd_global.resp_appl_id
 );

 wf_engine.SetItemAttrNumber
 (
  itemtype  => G_ITEM_TYPE,
  itemkey   => l_item_key,
  aname     => 'SECURITY_GROUP_ID',
  avalue    => fnd_global.security_group_id
 );

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Starting the process after setting attributes ' ||
             ' Process Type: ' || NVL(p_wf_attributes.process_type,'NULL')||
             ' IRR Flag: ' || NVL(p_wf_attributes.irr_flag,'NULL'));
 END IF;

 -- Assign owner to the workflow instance. Bug fix 4752631
 WF_ENGINE.setitemowner
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  owner    => fnd_global.user_name
 );

 -- Start the workflow process
 WF_ENGINE.STARTPROCESS
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key
 );

 -- Update contract header with the workflow item key only if it is not
 -- updated earlier by calling modules
 IF p_wf_attributes.item_key IS NULL THEN
   UPDATE oks_k_headers_b
   SET wf_item_key = l_item_key,
       renewal_status = nvl(p_wf_attributes.negotiation_status, 'DRAFT'),
       object_version_number = object_version_number + 1,
       last_update_date      = SYSDATE,
       last_updated_by       = FND_GLOBAL.USER_ID,
       last_update_login     = FND_GLOBAL.LOGIN_ID
   WHERE chr_id              = p_wf_attributes.contract_id;

   -- Don't have to bump up minor version for updating design attributes
   -- bump up the minor version number
/*
   UPDATE okc_k_vers_numbers
   SET minor_version         = minor_version + 1,
       object_version_number = object_version_number + 1,
       last_update_date      = SYSDATE,
       last_updated_by       = FND_GLOBAL.USER_ID,
       last_update_login     = FND_GLOBAL.LOGIN_ID
   WHERE chr_id              = p_wf_attributes.contract_id;
*/
 END IF;

 --Always reset threshold or all activities in this session will be deferred.
 IF p_wf_attributes.negotiation_status = G_NEG_STS_PRE_DRAFT THEN
   WF_ENGINE.threshold := l_save_threshold;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 /*start bug8705707*/
 /*cursor to check whether process has been created successfully*/
  OPEN wf_cur(l_item_key);
  FETCH wf_cur INTO l_item_type;
  IF wf_cur%NOTFOUND THEN
    CLOSE wf_cur;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Workflow process not created for the contract ' ||
              NVL(l_contract_number,'NULL')||
              ' Please check the workflow background engine');
    END IF;
   FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NO_WF_PROCESS');
   FND_MESSAGE.SET_TOKEN('CONTRACT_NUMBER',l_contract_number);
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Workflow process created successfully for the contract ' ||
              NVL(l_contract_number,'NULL'));
    END IF;
    IF wf_cur%ISOPEN THEN
    CLOSE wf_cur;
    END IF;
  END IF;
  /*end bug8705707*/

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END launch_k_process_wf;

/*=========================================================================
  API name      : assign_new_qto_contact
  Type          : Private.
  Function      : When a Quote To contact is changed on the contract while
                  waiting for customer action (in Online process), this
                  procedure takes it off the old contact's queue and submits
                  the contract for Online QA checks and effectively re-publishing
                  the contract to the new Quote to contact.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_chr_id         IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2   Required
                     Contract process workflow's item key.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE assign_new_qto_contact
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER
) IS
 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'assign_new_qto_contact';

 l_item_key               wf_items.item_key%TYPE;
 l_activity_name          VARCHAR2(30);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
            'Entered '||G_PKG_NAME ||'.'||l_api_name||
            '(p_contract_id=>'||p_contract_id||'p_item_key=>'||p_item_key||')');
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
      FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;

 IF activity_exist_in_process (
          p_item_type          =>  G_ITEM_TYPE,
          p_item_key           =>  l_item_key,
          p_activity_name      =>  G_CUST_ACTION ) THEN

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.complete_activity('||
                    ' p_contract_id ='||p_contract_id||')');
   END IF;
   complete_activity
   (
    p_api_version    => l_api_version,
    p_init_msg_list  => G_FALSE,
    p_contract_id    => p_contract_id,
    p_item_key       => l_item_key,
    p_resultout      => 'QTO_CHANGE',
    p_process_status => G_NEG_STS_PEND_PUBLISH,
    p_activity_name  => G_CUST_ACTION,
    x_return_status  => x_return_status,
    x_msg_data       => x_msg_data,
    x_msg_count      => x_msg_count
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.complete_activity(x_return_status= '||x_return_status||
                    ' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSE
   FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_RE_PUBLISH_ACTION');
   FND_MESSAGE.set_token('K_NUMBER',get_concat_k_number(p_contract_id));
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END assign_new_qto_contact;

/*=========================================================================
  API name      : clean_wf
  Type          : Private.
  Function      : This procedure will be invoked during delete contract
                  operation which will abort the workflow instance and remove
                  all references to it.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id    IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2   Required
                     Contract process workflow's item key.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE clean_wf
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER
) IS
 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'clean_wf';

 l_item_key               wf_items.item_key%TYPE;
 l_activity_name          VARCHAR2(30);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
            'Entered '||G_PKG_NAME ||'.'||l_api_name||
            '(p_contract_id=>'||p_contract_id||'p_item_key=>'||p_item_key||')');
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
      FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Aborting workflow... ');
 END IF;

 -- Abort the workflow process and purging code goes here
 wf_engine.abortprocess
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key
 );

 -- Clear all the obsolete runtime workflow information
 wf_purge.total
 (
  itemtype    => G_ITEM_TYPE,
  itemkey     => l_item_key,
  docommit    => FALSE, -- Bug 4730775; We want to commit explicitly (below or in delete api)
  runtimeonly => TRUE
 );
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Purging workflow... ');
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END clean_wf;

/*=========================================================================
  API name      : initialize
  Type          : Private.
  Function      : This procedure initialize required workflow item attributes.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE initialize
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'initialize';
 l_contract_id        NUMBER;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'itemtype: ' || itemtype ||
                ' itemkey: ' || itemkey  ||
                ' actid: ' || to_char(actid) ||
                ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN
    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    -- Set any other optional values to item attributes
/*    WF_ENGINE.setitemattrtext
    (
       itemtype =>  itemtype,
       itemkey  =>  itemkey,
       aname    =>  'CONTRACT_NUMBER',
       avalue   =>  l_kdetails_rec.contract_number
    );

    WF_ENGINE.SetItemAttrText
    (
       itemtype =>  itemtype,
       itemkey  =>  itemkey,
       aname    =>  'CONTRACT_MODIFIER',
       avalue   =>  l_kdetails_rec.contract_number_modifier
    );
*/
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    resultout := 'COMPLETE:';
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END initialize;

/*=========================================================================
  API name      : get_old_wf_status
  Type          : Private.
  Function      : This procedure derives the status of Electronic renewals
                  workflow if exists.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE get_old_wf_status
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'get_old_wf_status';

 CURSOR l_rru_csr(p_chr_id NUMBER) IS
 SELECT oksh.renewal_type_used, fndu.user_name
 FROM oks_k_headers_b oksh, fnd_user fndu
 WHERE oksh.chr_id = p_chr_id
 AND oksh.renewal_notification_to = fndu.user_id(+);

 CURSOR l_user_dtls_csr(p_chr_id NUMBER) IS
 SELECT  wiav.name attr_name,
         wiav.number_value attr_value
 FROM    wf_item_attribute_values wiav,
         wf_item_attributes wia
 WHERE   wiav.item_type = 'OKSARENW'
 AND     wiav.item_key  = p_chr_id
 AND     wia.item_type  = wiav.item_type
 AND     wia.name       = wiav.name
 AND     wia.type       <> 'EVENT'
 AND     wiav.name IN ('USER_ID','RESP_ID','SECURITY_GROUP_ID');

 CURSOR l_resp_appl_id_csr (p_resp_id NUMBER) IS
 SELECT application_id
 FROM fnd_responsibility
 WHERE responsibility_id = p_resp_id;

 l_contract_id        NUMBER;
 l_negotiation_status VARCHAR2(30);
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);

 l_maybe_renewal_k    VARCHAR2(1) := 'N';
 l_rowfound           BOOLEAN := FALSE;
 l_renewaltype_used   VARCHAR2(30);
 l_renewalntf_to      VARCHAR2(100);
 l_notif_attr_rec     OKS_WF_K_PROCESS_PVT.notif_attr_rec;
 l_resp_id            NUMBER;
 l_resp_appl_id       NUMBER;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'itemtype: ' || itemtype ||
                ' itemkey: ' || itemkey  ||
                ' actid: ' || to_char(actid) ||
                ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN
    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    -- Get negotiation status
    l_negotiation_status := wf_engine.GetItemAttrText(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'NEGOTIATION_STATUS');

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Negotiation status: ' || l_negotiation_status);
    END IF;

    -- Check the negotiation status and route the workflow accordingly
    IF l_negotiation_status = G_NEG_STS_DRAFT then
       l_maybe_renewal_k := 'Y';
       resultout := 'COMPLETE:NA';
    ELSIF l_negotiation_status = G_NEG_STS_QUOTE_SENT then

       -- get USER_ID, RESP_ID and SECURITY_GROUP_ID from old OKSARENW wf
       -- and stamp it in the new OKSKPRCS wf. bug 5723364. R12 Upgrade script
       -- is incorrectly setting these attributes to FND_GLOBAL values
       FOR l_user_dtls_rec IN l_user_dtls_csr(l_contract_id)
       LOOP
           wf_engine.SetItemAttrNumber
           (
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => l_user_dtls_rec.attr_name,
            avalue    => l_user_dtls_rec.attr_value
           );
           IF l_user_dtls_rec.attr_name = 'RESP_ID' THEN
              l_resp_id := l_user_dtls_rec.attr_value;
           END IF;
       END LOOP;

       -- similarly RESP_APPL_ID, as it was not present in old wf
       OPEN l_resp_appl_id_csr(l_resp_id);
       FETCH l_resp_appl_id_csr INTO l_resp_appl_id;
       CLOSE l_resp_appl_id_csr;

       wf_engine.SetItemAttrNumber
       (
        itemtype  => itemtype,
        itemkey   => itemkey,
        aname     => 'RESP_APPL_ID',
        avalue    => l_resp_appl_id
       );

       resultout := 'COMPLETE:PENDING_CA';

    ELSIF l_negotiation_status like '%FAIL%' THEN
       resultout := 'COMPLETE:PROCESS_FAILURE';
    ELSIF l_negotiation_status = G_NEG_STS_QUOTE_ACPTD then
       -- This condition only will arise when Customer has accepted the quote
       -- and approval process not started. Place contract in Salesrep queue
       resultout := 'COMPLETE:NA';
    -- For any unexpected issues we want it to proceed to Salesrep
    ELSE
       l_maybe_renewal_k := 'Y';
       resultout := 'COMPLETE:NA';
    END if;

    -- Check if this is a renewed contract, if so notify the
    -- salesrep that contract has been renewed. Bug 5447773
    IF l_maybe_renewal_k = 'Y' THEN
       OPEN l_rru_csr(l_contract_id);
       FETCH l_rru_csr INTO l_renewaltype_used,l_renewalntf_to;
       l_rowfound := l_rru_csr%FOUND;
       CLOSE l_rru_csr;

       IF l_rowfound AND l_renewaltype_used IS NOT NULL THEN
          -- If its a renewal, send a notification to salesrep
          l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
          l_notif_attr_rec.ITEM_KEY          := itemkey;
          l_notif_attr_rec.PERFORMER         := l_renewalntf_to;
          l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_RENEWED;
          l_notif_attr_rec.NTF_SUBJECT       := NULL;
          l_notif_attr_rec.SUBJECT           := NULL;
          l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;

          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                           'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                           ' Contract ID ='||l_contract_id||
                           ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                           ' Performer ='||l_notif_attr_rec.PERFORMER||')');
          END IF;
          set_notification_attributes
          (
           p_api_version    => 1.0,
           p_init_msg_list  => OKC_API.G_FALSE,
           p_notif_attr     => l_notif_attr_rec,
           x_return_status  => l_return_status,
           x_msg_data       => l_msg_data,
           x_msg_count      => l_msg_count
          );
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                            'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                            l_return_status||' x_msg_count ='||l_msg_count||')');
          END IF;
          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          resultout := 'COMPLETE:RENEWAL';
       END IF;
    END IF;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Resultout: ' || resultout);
    END IF;

    -- Reset negotiation status to NULL so that no other process will
    -- update incorrect Negotiation status
    wf_engine.SetItemAttrText
    (
     itemtype  => itemtype,
     itemkey   => itemkey,
     aname     => 'NEGOTIATION_STATUS',
     avalue    => NULL
    );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END get_old_wf_status;

/*=========================================================================
  API name      : get_process_type
  Type          : Private.
  Function      : This procedure determines the renewal process this contract
                  is going to follow during its lifecycle.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE get_process_type
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name      CONSTANT VARCHAR2(30) := 'get_process_type';
 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(4000);

 l_contract_id        NUMBER;
 l_process_type       VARCHAR2(30);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    -- Get process type to determine if this is a new or a renewal contract
    -- If it is a new contract, process type is always Manual
    -- If it is a renewal contract, determine if this contract qualifies
    -- for either Online or Evergreen process
    l_process_type := wf_engine.GetItemAttrText(
                       itemtype   => itemtype,
                       itemkey    => itemkey,
                       aname      => 'PROCESS_TYPE');

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Process Type: ' ||NVL(l_process_type,'NULL'));
    END IF;

    IF l_process_type = G_RENEW_TYPE_ONLINE THEN
       -- update process status to 'Pending Publication'
       update_negotiation_status
       (
         p_api_version         => 1.0,
         p_init_msg_list       => G_TRUE,
         p_chr_id              => l_contract_id,
         p_negotiation_status  => G_NEG_STS_PEND_PUBLISH,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
       );
       IF l_return_status <> G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       resultout := 'COMPLETE:ONLINE';
    ELSIF l_process_type = G_RENEW_TYPE_EVERGREEN THEN
       resultout := 'COMPLETE:EVERGREEN';
    ELSIF l_process_type = G_NEW_CONTRACT THEN  -- New Contract do nothing.
       resultout := 'COMPLETE:';
    ELSE
       resultout := 'COMPLETE:';
    END IF;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Resultout: ' || resultout);
    END IF;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END get_process_type;

/*cgopinee bugfix for 8361496*/
/*=========================================================================
  API name      : get_curr_conv_date_validity
  Type          : Private.
  Function      : This procedure determines the validity of the currency
                  conversion date.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE get_curr_conv_date_validity
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name      CONSTANT VARCHAR2(30) := 'get_curr_conv_date_validity';
 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(4000);

CURSOR l_curr_conv_invalid_csr (p_chr_id NUMBER) IS
 SELECT 'Y' FROM okc_k_headers_all_b
 WHERE id =p_chr_id AND
 Upper(conversion_type) ='USER'
 AND conversion_rate_date NOT BETWEEN start_date AND end_date;

 l_contract_id        NUMBER;
 l_invalid            VARCHAR2(1);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    OPEN l_curr_conv_invalid_csr(l_contract_id);
    FETCH l_curr_conv_invalid_csr INTO l_invalid;
    CLOSE l_curr_conv_invalid_csr;

   IF l_invalid = 'Y' THEN
      resultout := 'Y';
   END IF;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Resultout: ' || resultout);
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END get_curr_conv_date_validity;
/*end of bugfix 8361496*/

/*=========================================================================
  API name      : salesrep_action
  Type          : Private.
  Function      : This procedure makes the workflow process wait for
                  salesrep action.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE salesrep_action
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'salesrep_action';
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN
    resultout := 'NOTIFIED:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END salesrep_action;

/*=========================================================================
  API name      : is_submit_for_approval_allowed
  Type          : Private.
  Function      : This procedure determines whether the contract is eligible
                  to be submitted for approval.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_chr_id         IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2   Required
                     Contract process workflow's item key.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE is_submit_for_approval_allowed
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 x_activity_name        OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'is_submit_for_approval_allowed';
 l_item_key               wf_items.item_key%TYPE;
 l_contract_number        VARCHAR2(120);
 l_contract_modifier      VARCHAR2(120);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name||'with Contract Id '||p_contract_id);
 END IF;

 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    x_return_status := G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
       FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Item Key found '||l_item_key);
 END IF;

 x_activity_name := get_notified_activity
                       (
                        p_item_type     => G_ITEM_TYPE
                       ,p_item_key      => l_item_key
                       );

 IF x_activity_name = G_SALESREP_ACTION THEN
    x_return_status := G_RET_STS_SUCCESS;
 ELSIF x_activity_name = G_CUST_ACTION THEN
    FND_MESSAGE.set_name(G_APP_NAME,'OKS_WAIT_CUST_ACCEPTANCE');
    FND_MESSAGE.SET_TOKEN('K_NUMBER',get_concat_k_number(p_contract_id));
    FND_MSG_PUB.add;
    x_return_status := G_RET_STS_WARNING;
    x_activity_name := G_CUST_ACTION;
 ELSE
    FND_MESSAGE.set_name(G_APP_NAME,'OKS_SUBMIT_APRVL_NOT_ALWD');
    FND_MESSAGE.SET_TOKEN('K_NUMBER',get_concat_k_number(p_contract_id));
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Activity: '||x_activity_name||' Return status '||x_return_status);
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,get_fnd_message);
    END IF;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END is_submit_for_approval_allowed;

FUNCTION set_user_context
(
 p_wf_item_key       IN         VARCHAR2,
 p_user_id           IN         NUMBER,
 p_resp_id           IN         NUMBER,
 p_resp_appl_id      IN         NUMBER,
 p_security_group_id IN         NUMBER,
 p_commit            IN         VARCHAR2
) RETURN VARCHAR2 AS

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_api_name  CONSTANT VARCHAR2(30) := 'set_user_context';
 l_return_status      VARCHAR2(1)  := G_RET_STS_SUCCESS;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name||
                ' Item Key =>'||p_wf_item_key||
                ' User Id=>'||p_user_id||'Resp Id=>'||p_resp_id||
                ' Resp Appl Id=>'||p_resp_appl_id||
                ' Security Group Id=>'||p_security_group_id );
   END IF;
   -- Reset following item attributes to reflect the current user
   begin
      wf_engine.SetItemAttrNumber(
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'USER_ID',
                           avalue   => p_user_id);
   exception
      when others then
	    wf_engine.AddItemAttr (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'USER_ID');

	    wf_engine.SetItemAttrNumber (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'USER_ID',
                           avalue   => p_user_id);
   end;
   begin
      wf_engine.SetItemAttrNumber(
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'RESP_ID',
                           avalue   => p_resp_id);
   exception
      when others then
	    wf_engine.AddItemAttr (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'RESP_ID');

	    wf_engine.SetItemAttrNumber (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'RESP_ID',
                           avalue   => p_resp_id);
   end;
   begin
      wf_engine.SetItemAttrNumber(
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'RESP_APPL_ID',
                           avalue   => p_resp_appl_id);
   exception
      when others then
	    wf_engine.AddItemAttr (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'RESP_APPL_ID');

	    wf_engine.SetItemAttrNumber (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'RESP_APPL_ID',
                           avalue   => p_resp_appl_id);
   end;
   begin
      wf_engine.SetItemAttrNumber(
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'SECURITY_GROUP_ID',
                           avalue   => p_security_group_id);
   exception
      when others then
	    wf_engine.AddItemAttr (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'SECURITY_GROUP_ID');

	    wf_engine.SetItemAttrNumber (
                           itemtype => G_ITEM_TYPE,
                           itemkey  => p_wf_item_key,
                           aname    => 'SECURITY_GROUP_ID',
                           avalue   => p_security_group_id);
   end;

   IF FND_API.to_boolean( p_commit ) THEN
      COMMIT;
   END IF;
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                  'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
   RETURN l_return_status;
END;

/*=========================================================================
  API name      : submit_for_approval
  Type          : Private.
  Function      : This procedure determines whether the contract is eligible
                  to be submitted for approval.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_chr_id         IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2       Required
                     Contract process workflow's item key.
                : p_validate_yn    IN VARCHAR2       Required
                     Flag to check if submit for approval action is allowed.
                : p_qa_required_yn IN VARCHAR2       Required
                     If Y QA checks will be performed else skipped.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE submit_for_approval
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 p_validate_yn          IN         VARCHAR2,
 p_qa_required_yn       IN         VARCHAR2,
 x_negotiation_status   OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'submit_for_approval';

 l_send_email_yn          VARCHAR2(1) := 'N';
 l_item_key               wf_items.item_key%TYPE;
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;
 l_activity_name          VARCHAR2(30);
 l_irr_flag               VARCHAR2(1);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                   'Entered '||G_PKG_NAME ||'.'||l_api_name||
                   ' with Contract Id '||p_contract_id ||
                   ' p_validate_yn '||p_validate_yn||' p_qa_required_yn '||p_qa_required_yn);
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Check whether submit for approval actions is applicable for this contract
 -- If k is not in 'Entered' status, we should not allow submit for approval
 IF OKS_K_ACTIONS_PVT.validateForRenewalAction(p_chr_id => p_contract_id) = 'N' THEN
   x_return_status := G_RET_STS_ACTION_NOT_ALWD;
   RAISE ActionNotAllowedException;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
       FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;

 -- Skip the submit for approval allowed check when
 -- this api is called for the 2nd time.
 IF p_validate_yn = 'Y' THEN
    is_submit_for_approval_allowed
    (
      p_api_version   => l_api_version,
      p_init_msg_list => G_FALSE,
      p_contract_id   => p_contract_id,
      p_item_key      => l_item_key,
      x_activity_name => l_activity_name,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data
    );
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = G_RET_STS_WARNING THEN
        Raise ActionNotAllowedException;
    END IF;
 ELSE
    -- Only check if the contract is in either Salesrep / Customer queue
    l_activity_name := get_notified_activity
                       (
                        p_item_type     => G_ITEM_TYPE
                       ,p_item_key      => l_item_key
                       );
    IF l_activity_name   NOT IN (G_SALESREP_ACTION, G_CUST_ACTION) THEN
      FND_MESSAGE.set_name(G_APP_NAME,'OKS_SUBMIT_APPROVAL_NOT_ALLOWED');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_activity_name = G_CUST_ACTION THEN

      -- bug 5845505, send email only if template for the document type is setup
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       'OKS_WF_K_PROCESS_PVT.is_template_defined('||
                       ' Contract ID ='||p_contract_id||
                       ' Document Type ='||G_REPORT_TYPE_ACCEPT||')');
      END IF;
      is_template_defined (
                  p_api_version         => l_api_version,
                  p_init_msg_list       => G_FALSE,
                  p_contract_id         => p_contract_id,
                  p_document_type       => G_REPORT_TYPE_ACCEPT,
                  x_template_defined_yn => l_send_email_yn,
                  x_email_attr_rec      => l_email_attr_rec,
                  x_return_status       => x_return_status,
                  x_msg_data            => x_msg_data,
                  x_msg_count           => x_msg_count
                );

      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                       'OKS_WF_K_PROCESS_PVT.is_template_defined(x_return_status= '||
                       x_return_status||' x_msg_count ='||x_msg_count||')');
      END IF;
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      wf_engine.SetItemAttrText
      (
        itemtype   => G_ITEM_TYPE,
        itemkey    => l_item_key,
        aname      => 'SEND_CONFIRM',
        avalue     => l_send_email_yn
      );

      --log interaction (media type WEB FORM) that customer has accepted the quote
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                       ' Contract ID = '||p_contract_id||
                       substr(' IH Subject = '||l_email_attr_rec.ih_subject,1,100)||
                       substr(' IH Message = '||l_email_attr_rec.ih_message||')',1,100));
      END IF;
      OKS_AUTO_REMINDER.log_interaction (
         p_api_version     => l_api_version,
         p_init_msg_list   => G_FALSE,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => p_contract_id,
         p_subject         => l_email_attr_rec.ih_subject,
         p_msg_body        => l_email_attr_rec.ih_message,
         p_sent2_email     => NULL,
         p_media_type      => G_MEDIA_TYPE_WEB_FORM
      );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                       'OKS_AUTO_REMINDER.log_interaction(x_return_status= '||
                       x_return_status||' x_msg_count ='||x_msg_count||')');
      END IF;
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF NVL(l_send_email_yn,'N') = 'Y' THEN

        l_email_attr_rec.CONTRACT_ID       := p_contract_id;
        l_email_attr_rec.ITEM_KEY          := l_item_key;
        l_email_attr_rec.EMAIL_TYPE        := G_REPORT_TYPE_ACCEPT;
        l_email_attr_rec.TO_EMAIL          := NULL;
        l_email_attr_rec.SENDER_EMAIL      := NULL;

        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                         'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                         ' Contract ID ='||p_contract_id||
                         ' Email Type ='||l_email_attr_rec.EMAIL_TYPE||')');
        END IF;
        set_email_attributes
        (
         p_api_version    => l_api_version,
         p_init_msg_list  => OKC_API.G_FALSE,
         p_email_attr     => l_email_attr_rec,
         x_return_status  => x_return_status,
         x_msg_data       => x_msg_data,
         x_msg_count      => x_msg_count
        );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                         'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||
                         x_return_status||' x_msg_count ='||x_msg_count||')');
        END IF;
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;
 END IF;

 -- If submit for approval action is taken at Authoring set this flag to 'N' so
 -- that QA check is not performed but when taken at Workbench, set it to 'Y'.
 wf_engine.SetItemAttrText
 (
  itemtype   => G_ITEM_TYPE,
  itemkey    => l_item_key,
  aname      => 'QA_REQUIRED_YN',
  avalue     => p_qa_required_yn
 );

 -- Set wf item attributes to reflect the current user submitting for approval
 x_return_status :=  set_user_context(
                           p_wf_item_key       => l_item_key,
                           p_user_id           => fnd_global.user_id,
                           p_resp_id           => fnd_global.resp_id,
                           p_resp_appl_id      => fnd_global.resp_appl_id,
                           p_security_group_id => fnd_global.security_group_id,
                           p_commit            => G_TRUE
                        );

 -- This call is made for Authoring so that they don't have to access DB to get
 -- the latest Negotiation status. Authoring shud consider the return parameter.
 l_irr_flag := get_irr_flag(p_contract_id => NULL,p_item_key => l_item_key);
 IF l_irr_flag = G_IRR_FLAG_REQD THEN
   x_negotiation_status := G_NEG_STS_PEND_IA;
 ELSIF l_irr_flag = G_IRR_FLAG_NOT_REQD THEN
   x_negotiation_status := G_NEG_STS_PEND_ACTIVATION;
 ELSE
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                   'Starting complete_activity with Activity '||l_activity_name);
 END IF;
 complete_activity
 (
  p_api_version    => l_api_version,
  p_init_msg_list  => G_FALSE,
  p_contract_id    => p_contract_id,
  p_item_key       => l_item_key,
  p_resultout      => 'SUBMIT',
  p_process_status => x_negotiation_status,
  p_activity_name  => l_activity_name,
  x_return_status  => x_return_status,
  x_msg_data       => x_msg_data,
  x_msg_count      => x_msg_count
 );
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    ' Return status '||x_return_status||' x_msg_count '||x_msg_count);
 END IF;
 IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 ELSIF x_return_status = G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;
 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN ActionNotAllowedException THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
             'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ActionNotAllowedException '||
             ' Contract is either waiting for customer acceptance or not in entered status');
      END IF;
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END submit_for_approval;

/*=========================================================================
  API name      : publish_to_customer
  Type          : Private.
  Function      : This procedure determines whether the contract is eligible
                  to be submitted for approval.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id         IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2   Required
                     Contract process workflow's item key.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE publish_to_customer
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'publish_to_customer';

 l_item_key               VARCHAR2(80);
 l_activity_name          VARCHAR2(30);
 l_negotiation_status     VARCHAR2(30);

 CURSOR l_nego_sts_csr (p_chr_id NUMBER) IS
 SELECT renewal_status FROM oks_k_headers_b
 WHERE chr_id = p_chr_id;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
            'Entered '||G_PKG_NAME ||'.'||l_api_name||
            '(p_contract_id=>'||p_contract_id||'p_item_key=>'||p_item_key||')');
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 OPEN l_nego_sts_csr (p_contract_id);
 FETCH l_nego_sts_csr INTO l_negotiation_status;
 CLOSE l_nego_sts_csr;

 -- Updating the negotiation status to Quote Published coz when
 -- customer requests assistance, the contract is still in customers queue
 -- and salesrep in a way is republishing the contract
 -- Bug fix 5331882.
 IF NVL(l_negotiation_status,'X') = G_NEG_STS_ASSIST_REQD THEN
   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Updating Negotiation status ' || l_negotiation_status || ' to Quote Published');
   END IF;
   update oks_k_headers_b set renewal_status = G_NEG_STS_QUOTE_SENT
   where chr_id = p_contract_id;
 ELSE
   -- Check whether publish to customer action is applicable for this contract
   -- If k is not in 'Entered' status, we should not allow for publishing it online
   IF OKS_K_ACTIONS_PVT.validateForRenewalAction(p_chr_id => p_contract_id) = 'N' THEN
     RAISE ActionNotAllowedException;
   END IF;

   IF p_item_key IS NULL THEN
     l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
     IF l_item_key IS NULL THEN
       FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   ELSE
     l_item_key := p_item_key;
   END IF;

   IF activity_exist_in_process(
          p_item_type     => G_ITEM_TYPE
         ,p_item_key      => l_item_key
         ,p_activity_name => G_SALESREP_ACTION) THEN
      l_activity_name := G_SALESREP_ACTION;
   ELSE
      RAISE AlreadyPublishedException;
   END IF;

   complete_activity
   (
     p_api_version    => l_api_version,
     p_init_msg_list  => G_FALSE,
     p_contract_id    => p_contract_id,
     p_item_key       => l_item_key,
     p_resultout      => 'PUBLISH_ONLINE',
     p_process_status => G_NEG_STS_PEND_PUBLISH,
     p_activity_name  => l_activity_name,
     x_return_status  => x_return_status,
     x_msg_data       => x_msg_data,
     x_msg_count      => x_msg_count
   );
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Set this item attribute to 'Y' which indicates that this contract was
   -- published online manually. This is an important attribute since this is the only
   -- contract information that specifies that a contract is going thru online process
   wf_engine.SetItemAttrText
   (
    itemtype => G_ITEM_TYPE,
    itemkey  => l_item_key,
    aname    => 'PUBLISH_MAN_YN',
    avalue   => 'Y'
   );
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN ActionNotAllowedException THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
             'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ActionNotAllowedException '||
             ' Contract cannot be published since it is not in entered status');
      END IF;
      x_return_status := G_RET_STS_ACTION_NOT_ALWD;
  WHEN AlreadyPublishedException THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from AlreadyPublishedException');
      END IF;
      x_return_status := G_RET_STS_ALREADY_PUBLISHED;
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END publish_to_customer;

/*=========================================================================
  API name      : check_qa
  Type          : Private.
  Function      : This procedure executes all required QA checks during
                  contract activation process. If the contract is going thru
                  online process additional checks like Quote To Email address
                  validation are performed.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE check_qa
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name      CONSTANT VARCHAR2(50) := 'check_qa';
 l_api_version   CONSTANT NUMBER       := 1.0;
 l_return_status          VARCHAR2(1)  := G_RET_STS_SUCCESS;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);

 CURSOR l_qa_csr ( p_chr_id NUMBER ) IS
 SELECT contract_number, contract_number_modifier, qcl_id,
        authoring_org_id, inv_organization_id
 FROM okc_k_headers_all_b
 WHERE id = p_chr_id;

 l_contract_id        NUMBER;
 l_qa_rec             l_qa_csr%ROWTYPE;
 l_msg_tbl            OKC_QA_CHECK_PUB.MSG_TBL_TYPE;
 l_count              BINARY_INTEGER;
 l_msg_ctr            BINARY_INTEGER := 1;
 l_qto_email          VARCHAR2(2000);
 l_negotiation_status VARCHAR2(30);
 l_qa_calling_process VARCHAR2(30);
 l_online_yn          VARCHAR2(1);
 l_stop               VARCHAR2(1) := 'N';
 l_email_attr_rec     OKS_WF_K_PROCESS_PVT.email_attr_rec;
 l_notif_attr_rec     OKS_WF_K_PROCESS_PVT.notif_attr_rec;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

   l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

   -- Initialize workflow message attributes to Null.
   FOR l_count IN 1 .. 10 LOOP
     wf_engine.SetItemAttrText
     (
      itemtype   => itemtype,
      itemkey    => itemkey,
      aname      => 'MESSAGE' || l_count,
      avalue     => NULL
     );
   END LOOP;

   -- Get QA checklist associated with contract
   OPEN  l_qa_csr (l_contract_id);
   FETCH l_qa_csr INTO l_qa_rec;
   IF l_qa_csr%NOTFOUND OR l_qa_rec.qcl_id IS NULL THEN
     CLOSE l_qa_csr;
     FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVALID_QA_CHECKLIST');
     IF l_qa_rec.contract_number_modifier IS NOT NULL THEN
       FND_MESSAGE.SET_TOKEN('CONTRACT_NUM',l_qa_rec.contract_number ||' - ' ||
                                            l_qa_rec.contract_number_modifier);
     ELSE
       FND_MESSAGE.SET_TOKEN('CONTRACT_NUM',l_qa_rec.contract_number);
     END IF;
     FND_MSG_PUB.add;
     IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR ,G_MODULE||l_api_name,'Invalid QA checklist ');
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE l_qa_csr;

   -- Initializing the context to global
   okc_context.set_okc_org_context(p_org_id => l_qa_rec.authoring_org_id,
                          p_organization_id => l_qa_rec.inv_organization_id);

   -- distinguish the process in which this QA check is invoked
   -- it can be either Pending IA or Pending Publication
   l_qa_calling_process := get_negotiation_status(p_contract_id => l_contract_id);

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKC_QA_CHECK_PUB.execute_qa_check_list(p_qcl_id= '||l_qa_rec.qcl_id||
                    ' p_chr_id ='||l_contract_id||')');
   END IF;
   -- Execute the default and service contracts QA checklists
   OKC_QA_CHECK_PUB.execute_qa_check_list
   (
     p_api_version   => l_api_version,
     p_init_msg_list => OKC_API.G_FALSE,
     x_return_status => l_return_status,
     x_msg_count     => l_msg_count,
     x_msg_data      => l_msg_data,
     p_qcl_id        => l_qa_rec.qcl_id,
     p_chr_id        => l_contract_id,
     x_msg_tbl       => l_msg_tbl
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKC_QA_CHECK_PUB.execute_qa_check_list(x_return_status= '||l_return_status||
                    ' x_msg_tbl.count ='||l_msg_tbl.count||')');
   END IF;
   IF l_return_status <> G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check if any of the QA checks have failed. If so populate error message
   -- into workflow item attributes and mark the negotiation status coz we want to
   -- distinguish between online process QA failure and regular QA failure.
   IF l_msg_tbl.count >0 THEN
     l_count := l_msg_tbl.first;
     LOOP
       IF l_msg_tbl(l_count).error_status='E' THEN
         -- If this QA check is not called from Online process / Publish Online
         --  process then set the negotiation status to 'Internal Approval QA Failed'
         IF l_qa_calling_process = G_NEG_STS_PEND_PUBLISH THEN
           l_negotiation_status := G_NEG_STS_QPUB_QA_FAIL;
         ELSE
           l_negotiation_status := G_NEG_STS_IA_QA_FAIL;
         END IF;

         IF l_msg_ctr <= 10 THEN
           wf_engine.SetItemAttrText
           (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'MESSAGE' || l_msg_ctr,
            avalue   => l_msg_tbl(l_count).data
           );
           l_msg_ctr := l_msg_ctr + 1;
         END IF;
       END IF;
       -- Stop populating wf messages when all 10 item attributes are full or
       -- we are at the end of the error message table
       IF (l_msg_ctr > 10) OR (l_count = l_msg_tbl.LAST) THEN
         l_stop := 'Y';
       END IF;
       EXIT WHEN l_stop = 'Y';
       l_count:=l_msg_tbl.next(l_count);
     END LOOP;
   END IF;

   -- Perform these additional checks if the contract is going thru online process
   IF l_qa_calling_process = G_NEG_STS_PEND_PUBLISH THEN

      -- Message stack is initialized since QA checks above will post
      -- 'Contracts QA process has completed successfully' message after completion
      FND_MSG_PUB.initialize;
      -- Since we are here we know that this QA check is called from Online process
      -- There are two qualifying paths for which a process can enter into this IF condition
      -- 1.Online process, 2.Publish quote online process
      BEGIN
         l_qto_email := get_qto_email(p_contract_id => l_contract_id);
         IF l_qto_email IS NULL THEN
           IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name,'Quote To email not found');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
           FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => l_msg_count, p_data => l_msg_data );
           -- Set the message only when a vacant message item attribute is available
           IF (l_msg_ctr < 10) THEN
             wf_engine.SetItemAttrText
             (
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'MESSAGE' || l_msg_ctr,
              avalue   => substr(get_fnd_message,1,1500)
             );
             l_msg_ctr := l_msg_ctr + 1;
           END IF;

           -- Update negotiation status to 'Publish QA Failed'
           l_negotiation_status := G_NEG_STS_QPUB_QA_FAIL;
      END;
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Negotiation Status: '||l_negotiation_status );
      END IF;
      -- Once all QA checks are successful, set all the email related attributes
      -- so that an email along with Quote can be sent to Quote To contact.
      -- THIS IF LOOP SHOULD BE ENTERED ONLY FOR CONTRACTS GOING THRU ONLINE
      -- PROCESS AND HAS SUCCESSFULLY COMPLETED ALL THE QA CHECKS.
      IF l_negotiation_status IS NULL then
        l_email_attr_rec.CONTRACT_ID       := l_contract_id;
        l_email_attr_rec.ITEM_KEY          := itemkey;
        l_email_attr_rec.EMAIL_TYPE        := G_REPORT_TYPE_QUOTE;
        l_email_attr_rec.TO_EMAIL          := l_qto_email;
        l_email_attr_rec.SENDER_EMAIL      := NULL;
        l_email_attr_rec.EMAIL_SUBJECT     := NULL;
        l_email_attr_rec.IH_SUBJECT        := NULL;
        l_email_attr_rec.IH_MESSAGE        := NULL;

        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Email Type ='||l_email_attr_rec.TO_EMAIL||
                    ' To Email ='||l_qto_email||')');
        END IF;
        set_email_attributes
        (
         p_api_version    => l_api_version,
         p_init_msg_list  => OKC_API.G_FALSE,
         p_email_attr     => l_email_attr_rec,
         x_return_status  => l_return_status,
         x_msg_data       => l_msg_data,
         x_msg_count      => l_msg_count
        );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||l_return_status||
                    ' x_msg_count ='||l_msg_count||')');
        END IF;
        IF l_return_status <> G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
   END IF;

   IF l_negotiation_status IS NOT NULL then
     -- update process status to either 'Quote Publish QA Failed' or 'Internal Approval QA Failed'
     update_negotiation_status
     (
      p_api_version         => 1.0,
      p_init_msg_list       => G_TRUE,
      p_chr_id              => l_contract_id,
      p_negotiation_status  => l_negotiation_status,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
     );
     IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- In case of errors, set wf attributes that'll be used by the notification
     -- which will be rendered by OAF embedded region.
     l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
     l_notif_attr_rec.ITEM_KEY          := itemkey;
     l_notif_attr_rec.PERFORMER         := NULL;
     l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_QA_FAIL;
     l_notif_attr_rec.NTF_SUBJECT       := NULL;
     l_notif_attr_rec.SUBJECT           := get_lookup_meaning(l_negotiation_status,G_LKUP_TYPE_NEGO_STATUS);
     l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;

     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
     END IF;
     set_notification_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_notif_attr     => l_notif_attr_rec,
      x_return_status  => l_return_status,
      x_msg_data       => l_msg_data,
      x_msg_count      => l_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
     END IF;
     IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     resultout := 'COMPLETE:F';
   ELSE
     resultout := 'COMPLETE:T';
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
   RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    resultout := 'COMPLETE:F';
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    -- Since this is the primary cause of the error, we have to communicate it
    -- even with an expense of loosing a populated message.
    IF l_msg_ctr > 10 THEN
      l_msg_ctr := 10;
    END IF;
    wf_engine.SetItemAttrText
    (
     itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'MESSAGE' || l_msg_ctr,
     avalue   => l_msg_data
    );
    BEGIN
     l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
     l_notif_attr_rec.ITEM_KEY          := itemkey;
     l_notif_attr_rec.PERFORMER         := NULL;
     l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_QA_FAIL;
     l_notif_attr_rec.NTF_SUBJECT       := NULL;
     l_notif_attr_rec.SUBJECT           := substr(get_fnd_message,1,200);
     l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
     END IF;
     set_notification_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_notif_attr     => l_notif_attr_rec,
      x_return_status  => l_return_status,
      x_msg_data       => l_msg_data,
      x_msg_count      => l_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
     END IF;
    EXCEPTION
      WHEN others THEN
         IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
              'Leaving '||G_PKG_NAME ||'.'||l_api_name||'G_EXC_ERROR.Others sqlcode = '
                        ||SQLCODE||', sqlerrm = '||SQLERRM);
         END IF;
    END;
  WHEN others THEN
    resultout := 'COMPLETE:F';
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    -- Since this is the primary cause of the error, we have to communicate it
    -- even with an expense of loosing a populated message.
    IF l_msg_ctr > 10 THEN
      l_msg_ctr := 10;
    END IF;
    wf_engine.SetItemAttrText
    (
     itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'MESSAGE' || l_msg_ctr,
     avalue   => SQLCODE||':'||SQLERRM
    );
    BEGIN
     l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
     l_notif_attr_rec.ITEM_KEY          := itemkey;
     l_notif_attr_rec.PERFORMER         := NULL;
     l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_QA_FAIL;
     l_notif_attr_rec.NTF_SUBJECT       := NULL;
     l_notif_attr_rec.SUBJECT           := substr(SQLERRM,1,200);
     l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
     END IF;
     set_notification_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_notif_attr     => l_notif_attr_rec,
      x_return_status  => l_return_status,
      x_msg_data       => l_msg_data,
      x_msg_count      => l_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
     END IF;
    EXCEPTION
      WHEN others THEN
         IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||'OTHERS.Others sqlcode = '
                        ||SQLCODE||', sqlerrm = '||SQLERRM);
         END IF;
    END;
END check_qa;

/*=========================================================================
  API name      : customer_action
  Type          : Private.
  Function      : This procedure makes the workflow process wait for
                  customer action.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE customer_action
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'customer_action';
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN
    resultout := 'NOTIFIED:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END customer_action;

/*=========================================================================
  API name      : get_approval_flag
  Type          : Private.
  Function      : This procedure determines whether this contract requires explicit
                  action by Salesrep when a contract is accepted by customer during
                  online process. The possible values are 'A' - Automatic,
                  'M' - Manual and 'N' - Not required.
                  New contracts always require internal review.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE get_approval_flag
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'get_approval_flag';
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);

 l_contract_id        NUMBER;
 l_irr_flag           VARCHAR2(1);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    -- Get submit for approval flag to determine if this contract
    -- requires explict action by salesrep.
    l_irr_flag := wf_engine.GetItemAttrText(
                       itemtype   => itemtype,
                       itemkey    => itemkey,
                       aname      => 'IRR_FLAG');

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Irr Flag: ' ||NVL(l_irr_flag,'NULL'));
    END IF;

    -- 1. Require explicit action from Salesrep
    -- 2. For new contracts, Salesrep action is always required
    IF NVL(l_irr_flag,G_IRR_FLAG_REQD) IN (G_IRR_FLAG_MANUAL, G_IRR_FLAG_REQD) THEN
      resultout := 'COMPLETE:MANUAL';
      update_negotiation_status
      (
       p_api_version         => 1.0,
       p_init_msg_list       => G_FALSE,
       p_chr_id              => l_contract_id,
       p_negotiation_status  => G_NEG_STS_QUOTE_ACPTD,
       x_return_status       => l_return_status,
       x_msg_count           => l_msg_count,
       x_msg_data            => l_msg_data
      );
      IF l_return_status <> G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    -- 3. Doesn't require explicit action from Salesrep
    ELSE
      resultout := 'COMPLETE:';
    END IF;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Resultout: ' || resultout);
    END IF;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
     pkg_name  => G_PKG_NAME,
     proc_name => l_api_name,
     arg1      => itemtype,
     arg2      => itemkey,
     arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END get_approval_flag;

/*=========================================================================
  API name      : is_approval_required
  Type          : Private.
  Function      : This procedure determines whether this contract requires
                  internal review or not. The possible values are 'A' Automatic
                  'M' manual, 'Y' Required and 'N' Not required.
                  New contracts always require internal review.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE is_approval_required
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'is_approval_required';
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);

 l_irr_flag           VARCHAR2(1);
 l_contract_id        NUMBER;
BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

   l_irr_flag := get_irr_flag(p_contract_id => NULL,p_item_key => itemkey);
   IF l_irr_flag IS NOT NULL THEN
     resultout  := 'COMPLETE:'||l_irr_flag;
   ELSE
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Resultout: ' || resultout);
   END IF;
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
   END IF;
   RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
     pkg_name  => G_PKG_NAME,
     proc_name => l_api_name,
     arg1      => itemtype,
     arg2      => itemkey,
     arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END is_approval_required;

/*=========================================================================
  API name      : process_negotiation_status
  Type          : Private.
  Function      : This procedure updates renewal status in OKS_K_HEADERS_B
                  and bumps up the version. This is invoked from the workflow.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE process_negotiation_status
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name  CONSTANT VARCHAR2(30) := 'process_negotiation_status';
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR2(4000);

 l_contract_id        NUMBER;
 l_negotiation_status VARCHAR2(30);
 l_irr_flag           VARCHAR2(1);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'itemtype: ' || itemtype ||
                ' itemkey: ' || itemkey  ||
                ' actid: ' || to_char(actid) ||
                ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    l_negotiation_status := wf_engine.GetActivityAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 actid    => actid,
                                 aname     => 'TARGET_NEGO_STATUS');

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Id: ' || l_contract_id ||
                ' Negotiation status: ' || l_negotiation_status);
    END IF;

    -- If internal approval is required update the negotiation status to
    -- Pending Internal review else Pending Activation.
    IF l_negotiation_status = G_NEG_STS_PEND_IA THEN
       l_irr_flag := get_irr_flag(p_contract_id => l_contract_id,p_item_key => itemkey);
       IF l_irr_flag = G_IRR_FLAG_REQD THEN
         l_negotiation_status := G_NEG_STS_PEND_IA;
       ELSIF l_irr_flag = G_IRR_FLAG_NOT_REQD THEN
         l_negotiation_status := G_NEG_STS_PEND_ACTIVATION;
       ELSE
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    update_negotiation_status
    (
      p_api_version         => 1.0,
      p_init_msg_list       => G_TRUE,
      p_chr_id              => l_contract_id,
      p_negotiation_status  => l_negotiation_status,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE NegStatusUpdateException;
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
           'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=RUN');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')

EXCEPTION
 WHEN NegStatusUpdateException THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.NegStatusUpdateException'
          ||' Itemtype: '||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
    );
 WHEN FND_API.G_EXC_ERROR THEN
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
    END IF;
    wf_core.CONTEXT
    (
     pkg_name  => G_PKG_NAME,
     proc_name => l_api_name,
     arg1      => itemtype,
     arg2      => itemkey,
     arg3      => l_msg_data
    );
 WHEN others THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
    );
END process_negotiation_status;

/*=========================================================================
  API name      : k_approval_start
  Type          : Private.
  Function      : This is a wrapper procedure to launch the approval
                  workflow. Used to make it autonomous.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_cotract_id     IN NUMBER         Required
                     Contract header Id
                : p_process_id     IN NUMBER         Required
                     Process definition id of approval process.
                : p_commit         IN VARCHAR2       Required
                    Commit or not to commit. That is the question :)
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE k_approval_start
(
 p_api_version    IN         NUMBER,
 p_init_msg_list  IN         VARCHAR2,
 p_contract_id    IN         NUMBER,
 p_process_id     IN         NUMBER,
 p_commit         IN         VARCHAR2,
 p_wf_item_key    IN         VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER
) AS

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_api_name        CONSTANT VARCHAR2(50) := 'k_approval_start';
 l_user_id                  NUMBER;
 l_resp_id                  NUMBER;
 l_resp_appl_id             NUMBER;
 l_security_group_id        NUMBER;

BEGIN
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'p_contract_id: ' || p_contract_id ||
                    ' p_process_id: ' || p_process_id  ||
                    ' p_commit: ' || p_commit ||
                    ' p_wf_item_key: ' || p_wf_item_key);
 END IF;
 BEGIN
   l_user_id := wf_engine.GetItemAttrNumber
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'USER_ID'
              );
 EXCEPTION
    WHEN OTHERS THEN
       wf_engine.AddItemAttr
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'USER_ID'
              );
       wf_engine.SetItemAttrNumber
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'USER_ID',
               avalue    => null
              );
 END;
 BEGIN
   l_resp_id := wf_engine.GetItemAttrNumber
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'RESP_ID'
              );
 EXCEPTION
    WHEN OTHERS THEN
       wf_engine.AddItemAttr
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'RESP_ID'
              );
       wf_engine.SetItemAttrNumber
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'RESP_ID',
               avalue    => null
              );
 END;
 BEGIN
   l_resp_appl_id := wf_engine.GetItemAttrNumber
                   (
                    itemtype  => G_ITEM_TYPE,
                    itemkey   => p_wf_item_key,
                    aname     => 'RESP_APPL_ID'
                   );

 EXCEPTION
    WHEN OTHERS THEN
       wf_engine.AddItemAttr
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'RESP_APPL_ID'
              );
       wf_engine.SetItemAttrNumber
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'RESP_APPL_ID',
               avalue    => null
              );
 END;
 BEGIN
   l_security_group_id := wf_engine.GetItemAttrNumber
                        (
                         itemtype  => G_ITEM_TYPE,
                         itemkey   => p_wf_item_key,
                         aname     => 'SECURITY_GROUP_ID'
                        );
 EXCEPTION
    WHEN OTHERS THEN
       wf_engine.AddItemAttr
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'SECURITY_GROUP_ID'
              );
       wf_engine.SetItemAttrNumber
              (
               itemtype  => G_ITEM_TYPE,
               itemkey   => p_wf_item_key,
               aname     => 'SECURITY_GROUP_ID',
               avalue    => null
              );
 END;

 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                  'OKC_CONTRACT_APPROVAL_PUB.k_approval_start(p_contract_id= '||
                  p_contract_id||' p_process_id='||p_process_id||')');
 END IF;

 BEGIN
    OKC_CONTRACT_APPROVAL_PUB.k_approval_start
    (
     p_api_version       => p_api_version,
     p_init_msg_list     => p_init_msg_list,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,
     p_contract_id       => p_contract_id,
     p_process_id        => p_process_id,
     p_do_commit         => p_commit,
     p_access_level      => 'Y',
     p_user_id           => l_user_id,
     p_resp_id           => l_resp_id,
     p_resp_appl_id      => l_resp_appl_id,
     p_security_group_id => l_security_group_id
    );
 EXCEPTION
     WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name,
              'In Others exception for OKS_WF_K_PROCESS_PVT.k_approval_start');
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name,
              'Error: '|| substr(SQLERRM,1,500));
       END IF;
 END;
 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKC_CONTRACT_APPROVAL_PUB.k_approval_start(x_return_status= '||
                  x_return_status||' x_msg_count='||x_msg_count||')');
 END IF;
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
END;

/*=========================================================================
  API name      : launch_approval_wf
  Type          : Private.
  Function      : This procedure launches the approval workflow.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_chr_id         IN NUMBER         Required
                     Contract header Id
                : p_negotiation_status IN VARCHAR2   Required
                     New negotiation status that is to be updated.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE launch_approval_wf
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name      CONSTANT VARCHAR2(50) := 'launch_approval_wf';
 l_api_version   CONSTANT NUMBER       := 1.0;
 l_return_status          VARCHAR2(1)  := G_RET_STS_SUCCESS;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);

 CURSOR l_pdf_csr(p_chr_id number) is
 SELECT pdf_id
 FROM okc_k_processes kp, okc_process_defs_b pd
 WHERE kp.chr_id=p_chr_id and kp.pdf_id=pd.id and pd.usage='APPROVE';

 l_contract_id            NUMBER;
 l_pdf_id                 NUMBER;
 l_notif_attr_rec         OKS_WF_K_PROCESS_PVT.notif_attr_rec;

BEGIN
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

   l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

   OPEN l_pdf_csr(l_contract_id);
   FETCH l_pdf_csr into l_pdf_id;
   CLOSE l_pdf_csr;

   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,'Pdf Id: ' || l_pdf_id);
   END IF;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKC_CONTRACT_APPROVAL_PUB.k_approval_start(p_contract_id= '||
                     l_contract_id||' p_process_id='||l_pdf_id||')');
   END IF;
   BEGIN
     k_approval_start
     (
      p_api_version   => l_api_version,
      p_init_msg_list => G_FALSE,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      p_contract_id   => l_contract_id,
      p_process_id    => l_pdf_id,
      p_commit        => G_TRUE,
      p_wf_item_key   => itemkey
     );
   EXCEPTION
     WHEN OTHERS THEN
       l_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name,
              'In Others exception for OKS_WF_K_PROCESS_PVT.k_approval_start');
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name,
              'Error: '|| substr(SQLERRM,1,500));
       END IF;
   END;
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKC_CONTRACT_APPROVAL_PUB.k_approval_start(x_return_status= '||
                     l_return_status||' x_msg_count='||l_msg_count||')');
   END IF;

   IF l_return_status <> G_RET_STS_SUCCESS THEN
     update_negotiation_status
     (
      p_api_version         => l_api_version,
      p_init_msg_list       => G_FALSE,
      p_chr_id              => l_contract_id,
      p_negotiation_status  => G_NEG_STS_IA_FAIL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
     );
     IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- In case of errors, set wf attributes that'll be used by the notification
     -- and will be rendered by OAF embedded region.
     l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
     l_notif_attr_rec.ITEM_KEY          := itemkey;
     l_notif_attr_rec.PERFORMER         := NULL;
     l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_ERROR;
     l_notif_attr_rec.NTF_SUBJECT       := NULL;
     l_notif_attr_rec.SUBJECT           := get_lookup_meaning(G_NEG_STS_IA_FAIL,G_LKUP_TYPE_NEGO_STATUS);
     l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;
     l_notif_attr_rec.MSGS_FROM_STACK_YN:= 'Y';

     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
     END IF;
     set_notification_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_notif_attr     => l_notif_attr_rec,
      x_return_status  => l_return_status,
      x_msg_data       => l_msg_data,
      x_msg_count      => l_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
     END IF;
     IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     resultout := 'COMPLETE:ERROR';
   ELSE
     resultout := 'NOTIFIED:';
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
   RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    resultout := 'COMPLETE:ERROR';
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
     END IF;
     wf_core.CONTEXT
     (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
     );
  WHEN others THEN
     resultout := 'COMPLETE:ERROR';
     IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
     END IF;
     wf_core.CONTEXT
     (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => to_char(actid),
      arg4      => funcmode,
      arg5      => SQLCODE,
      arg6      => SQLERRM
     );
END launch_approval_wf;

/*=========================================================================
  API name      : accept_quote
  Type          : Private.
  Function      : This procedure will complete the workflow activities after
                  quote has been accepted by Salesrep on behalf of customer
                  while waiting for salesrep / customer action.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id    IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2   Required
                     Contract process workflow's item key.
                : p_accept_confirm_yn IN VARCHAR2   Required
                     Flag to send acceptance confirmation eamil to customer
                     after quote has been accepted. Valid values are 'Y', 'N'.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE accept_quote
(

 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 p_accept_confirm_yn    IN         VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data             OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

 l_api_version            CONSTANT NUMBER        := 1.0;
 l_api_name               CONSTANT VARCHAR2(30)  := 'accept_quote';

 l_item_key               wf_items.item_key%TYPE;
 l_activity_name          VARCHAR2(30);
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;

BEGIN
 -- start debug log
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Item key: ' || NVL(p_item_key,'NULL') ||
                    ' Accept Confirm Flag: ' || p_accept_confirm_yn);
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID','NULL');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
       FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;

 -- Check if a confirmation email has to be delivered or not
 wf_engine.SetItemAttrText
 (
  itemtype => G_ITEM_TYPE,
  itemkey  => l_item_key,
  aname    => 'SEND_CONFIRM',
  avalue   => p_accept_confirm_yn
 );

 IF p_accept_confirm_yn = 'Y' THEN
   l_email_attr_rec.CONTRACT_ID       := p_contract_id;
   l_email_attr_rec.ITEM_KEY          := l_item_key;
   l_email_attr_rec.EMAIL_TYPE        := G_REPORT_TYPE_ACCEPT;
   l_email_attr_rec.TO_EMAIL          := NULL;
   l_email_attr_rec.SENDER_EMAIL      := NULL;
   l_email_attr_rec.EMAIL_SUBJECT     := NULL;
   l_email_attr_rec.IH_SUBJECT        := NULL;
   l_email_attr_rec.IH_MESSAGE        := NULL;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                    ' Contract ID ='||p_contract_id||
                    ' Email Type ='||l_email_attr_rec.EMAIL_TYPE||')');
   END IF;
   set_email_attributes
   (
    p_api_version    => l_api_version,
    p_init_msg_list  => OKC_API.G_FALSE,
    p_email_attr     => l_email_attr_rec,
    x_return_status  => x_return_status,
    x_msg_data       => x_msg_data,
    x_msg_count      => x_msg_count
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||
                    x_return_status||' x_msg_count ='||x_msg_count||')');
   END IF;
   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;

 l_activity_name := get_notified_activity
                       (
                        p_item_type     => G_ITEM_TYPE
                       ,p_item_key      => l_item_key
                       );
 IF l_activity_name NOT IN (G_SALESREP_ACTION, G_CUST_ACTION) THEN
    FND_MESSAGE.set_name(G_APP_NAME,'OKS_INV_SALESREP_ACPT_ACTION');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Item key: ' || l_item_key ||
                    ' Completing activity - Activity Name: ' || l_activity_name);
 END IF;

 complete_activity
 (
  p_api_version    => l_api_version,
  p_init_msg_list  => G_FALSE,
  p_contract_id    => p_contract_id,
  p_item_key       => l_item_key,
  p_resultout      => 'SR_ACPTD',
  p_process_status => G_NEG_STS_QUOTE_ACPTD,
  p_activity_name  => l_activity_name,
  x_return_status  => x_return_status,
  x_msg_data       => x_msg_data,
  x_msg_count      => x_msg_count
 );
 IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 ELSIF x_return_status = G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END accept_quote;

/*=========================================================================
  API name      : cancel_contract
  Type          : Private.
  Function      : This procedure will complete the workflow activities after
                  quote has been declined or contract is cancelled by Salesrep
                  on behalf of customer while waiting for salesrep/customer action.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id    IN NUMBER         Required
                     Contract header Id
                : p_item_key       IN VARCHAR2       Required
                     Contract process workflow's item key.
                : p_cancellation_reason IN VARCHAR2  Required
                     Reason code of cancellation reason.
                : p_cancellation_date IN VARCHAR2    Required
                     Date on which contract is cancelled.
                : p_cancel_source  IN VARCHAR2       Required
                     Parameter to identify cancellation source. This is
                     significant in case of Quote To contact declines
                     the renewal through Online process.
                : p_comments       IN VARCHAR2       Required
                     Any comments that were passed while cancelling contract.
  OUT           : x_return_status  OUT  VARCHAR2(1)
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE cancel_contract
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_commit               IN         VARCHAR2 DEFAULT 'F',
 p_contract_id          IN         NUMBER,
 p_item_key             IN         VARCHAR2,
 p_cancellation_reason  IN         VARCHAR2,
 p_cancellation_date    IN         DATE,
 p_cancel_source        IN         VARCHAR2,
 p_comments             IN         VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_data	            OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

 l_api_version            CONSTANT NUMBER        := 1.0;
 l_api_name               CONSTANT VARCHAR2(30)  := 'cancel_contract';

 l_send_email_yn          VARCHAR2(1) := 'N';
 l_reason                 VARCHAR2(250);

 l_item_key               wf_items.item_key%TYPE;
 l_result_out             wf_item_activity_statuses.activity_result_code%TYPE;
 l_process_status         VARCHAR2(30);
 l_activity_name          VARCHAR2(30);
 l_email_attr_rec         OKS_WF_K_PROCESS_PVT.email_attr_rec;

BEGIN
 -- start debug log
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Item key: ' || NVL(l_item_key,'NULL')||' Cancel source '||p_cancel_source);
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Cancellation reason: ' || substr(NVL(p_cancellation_reason,'NULL'),1,1500)
                 || ' Cancellation date: ' || to_char(p_cancellation_date));
 END IF;

 DBMS_TRANSACTION.SAVEPOINT(l_api_name);
 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID','NULL');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF p_item_key IS NULL THEN
    l_item_key := get_wf_item_key(p_contract_id => p_contract_id);
    IF l_item_key IS NULL THEN
       FND_MESSAGE.set_name(G_APP_NAME,'OKS_INVALID_WF_ITEM_KEY');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_item_key := p_item_key;
 END IF;
 -- Salesrep is cancelling the contract while the contract is in his queue
 l_activity_name := get_notified_activity
                       (
                        p_item_type     => G_ITEM_TYPE
                       ,p_item_key      => l_item_key
                       );
 IF l_activity_name = G_SALESREP_ACTION THEN
    l_result_out    := 'SR_CNCLD';
    l_process_status:= G_NEG_STS_QUOTE_CNCLD;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Salesrep Cancelling: '||G_PKG_NAME ||'.'||l_api_name);
    END IF;
 ELSIF l_activity_name = G_CUST_ACTION THEN
    -- Customer is decling the quote
    IF NVL(p_cancel_source,'!') = G_PERFORMED_BY_CUST THEN
       l_result_out    := 'DECLINE';
       l_process_status:= G_NEG_STS_QUOTE_DECLD;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Customer Declining: '||G_PKG_NAME ||'.'||l_api_name);
       END IF;

    -- Salesrep canceling the contract while waiting for customer action.
    ELSE
       l_result_out    := 'SR_CNCLD';
       l_process_status:= G_NEG_STS_QUOTE_CNCLD;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                    'Salesrep Cancelling for Customer: '||G_PKG_NAME ||'.'||l_api_name);
       END IF;

       -- bug 5845505, send email only if template for the document type is setup
       IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                        'OKS_WF_K_PROCESS_PVT.is_template_defined('||
                        ' Contract ID ='||p_contract_id||
                        ' Document Type ='||G_REPORT_TYPE_CANCEL||')');
       END IF;
       is_template_defined (
                  p_api_version         => l_api_version,
                  p_init_msg_list       => G_FALSE,
                  p_contract_id         => p_contract_id,
                  p_document_type       => G_REPORT_TYPE_CANCEL,
                  x_template_defined_yn => l_send_email_yn,
                  x_email_attr_rec      => l_email_attr_rec,
                  x_return_status       => x_return_status,
                  x_msg_data            => x_msg_data,
                  x_msg_count           => x_msg_count
                );

       IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                        'OKS_WF_K_PROCESS_PVT.is_template_defined(x_return_status= '||
                        x_return_status||' x_msg_count ='||x_msg_count||')');
       END IF;
       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       wf_engine.SetItemAttrText
       (
         itemtype   => G_ITEM_TYPE,
         itemkey    => l_item_key,
         aname      => 'SEND_CONFIRM',
         avalue     => l_send_email_yn
       );

       -- get the vendor side cancellation reason as customer side reasons are not
       -- accessible to vendor
       l_reason := get_lookup_meaning(p_cancellation_reason,G_LKUP_VNDR_CNCL_REASON);

       --log interaction (media type WEB FORM) that salesrep has declined the quote
       IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                        'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                        ' Contract ID = '||p_contract_id||
                        substr(' IH Message = '||p_comments,1,100)||
                        substr(' IH Subject = '||l_reason||')',1,100));
       END IF;
       OKS_AUTO_REMINDER.log_interaction (
          p_api_version     => l_api_version,
          p_init_msg_list   => G_FALSE,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_chr_id          => p_contract_id,
          p_subject         => l_reason,
          p_msg_body        => p_comments,
          p_sent2_email     => NULL,
          p_media_type      => G_MEDIA_TYPE_WEB_FORM
       );
       IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                        'OKS_AUTO_REMINDER.log_interaction(x_return_status= '||
                        x_return_status||' x_msg_count ='||x_msg_count||')');
       END IF;
       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF NVL(l_send_email_yn,'N') = 'Y' THEN
         -- Log interaction and send cancellation confirmation email to customer
         l_email_attr_rec.CONTRACT_ID       := p_contract_id;
         l_email_attr_rec.ITEM_KEY          := l_item_key;
         l_email_attr_rec.EMAIL_TYPE        := G_REPORT_TYPE_CANCEL;
         l_email_attr_rec.TO_EMAIL          := NULL;
         l_email_attr_rec.SENDER_EMAIL      := NULL;

         IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                          'OKS_WF_K_PROCESS_PVT.set_email_attributes('||
                          ' Contract ID ='||p_contract_id||
                          ' Email Type ='||l_email_attr_rec.EMAIL_TYPE||')');
         END IF;
         set_email_attributes
         (
          p_api_version    => l_api_version,
          p_init_msg_list  => OKC_API.G_FALSE,
          p_email_attr     => l_email_attr_rec,
          x_return_status  => x_return_status,
          x_msg_data       => x_msg_data,
          x_msg_count      => x_msg_count
         );
         IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                          'OKS_WF_K_PROCESS_PVT.set_email_attributes(x_return_status= '||
                          x_return_status||' x_msg_count ='||x_msg_count||')');
         END IF;
         IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
    END IF;
 ELSE

--  MKS 10/12/2005  Bug#4643300: Need to stamp even for non salesrep/customer nodes.

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Aborting Process and Updating Contract '||G_PKG_NAME ||'.'||l_api_name);
    END IF;
    UPDATE oks_k_headers_b
       SET renewal_status = G_NEG_STS_QUOTE_CNCLD,
           accepted_by = NULL,
           date_accepted = NULL,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by =   FND_GLOBAL.USER_ID,
           last_update_login = FND_GLOBAL.LOGIN_ID
        WHERE chr_id = p_contract_id;
    wf_engine.AbortProcess (G_ITEM_TYPE, l_item_key);
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  'Updated Contract and Process Aborted '||G_PKG_NAME ||'.'||l_api_name);
    END IF;
 END IF;

 IF l_activity_name  IN (G_SALESREP_ACTION, G_CUST_ACTION) THEN
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKS_WF_K_PROCESS_PVT.complete_activity(p_contract_id= '||
                     p_contract_id||' p_resultout ='||l_result_out||
                     ' p_process_status ='||l_process_status||
                     ' p_activity_name ='||l_activity_name||')');
    END IF;
    complete_activity
    (
     p_api_version          => 1.0,
     p_init_msg_list        => G_FALSE,
     p_contract_id          => p_contract_id,
     p_item_key             => l_item_key,
     p_resultout            => l_result_out,
     p_process_status       => l_process_status,
     p_activity_name        => l_activity_name,
     x_return_status        => x_return_status,
     x_msg_count            => x_msg_count,
     x_msg_data             => x_msg_data
    ) ;
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKS_WF_K_PROCESS_PVT.complete_activity(x_return_status= '||
                     x_return_status||' x_msg_count ='||x_msg_count||')');
    END IF;
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 END IF;

 IF FND_API.to_boolean( p_commit ) THEN
   COMMIT;
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from G_EXC_UNEXPECTED_ERROR');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,get_fnd_message);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END cancel_contract;

/*=========================================================================
  API name      : activate_contract
  Type          : Private.
  Function      : This procedure will approve and sign the contract.
  Pre-reqs      : None.
  Parameters    :
  IN            : itemtype         IN VARCHAR2       Required
                     Workflow item type parameter
                : itemkey          IN VARCHAR2       Required
                     Workflow item key parameter
                : actid            IN VARCHAR2       Required
                     Workflow actid parameter
                : funcmode         IN VARCHAR2       Required
                     Workflow function mode parameter
  OUT           : resultout        OUT  VARCHAR2(1)
                     Workflow standard out parameter
  Note          :
=========================================================================*/
PROCEDURE activate_contract
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2,
 actid                  IN         NUMBER,
 funcmode               IN         VARCHAR2,
 resultout              OUT nocopy VARCHAR2
) IS

 l_api_name      CONSTANT VARCHAR2(50) := 'activate_contract';
 l_api_version   CONSTANT NUMBER       := 1.0;
 l_return_status          VARCHAR2(1)  := G_RET_STS_SUCCESS;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);

 l_contract_id            NUMBER;
 l_notif_attr_rec     OKS_WF_K_PROCESS_PVT.notif_attr_rec;

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'itemtype: ' || itemtype ||
                    ' itemkey: ' || itemkey  ||
                    ' actid: ' || to_char(actid) ||
                    ' funcmode: ' || funcmode);
 END IF;
 IF (funcmode = 'RUN') THEN

   l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
        'OKC_CONTRACT_APPROVAL_PUB.k_approved(p_contract_id= '||l_contract_id||')');
   END IF;
   -- update the date approved of the contract
   OKC_CONTRACT_APPROVAL_PUB.k_approved
   (
    p_contract_id   => l_contract_id,
    x_return_status => l_return_status
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
        'OKC_CONTRACT_APPROVAL_PUB.k_approved(x_return_status= '||l_return_status||')');
   END IF;
   IF l_return_status <> G_RET_STS_SUCCESS THEN
     update_negotiation_status
     (
      p_api_version         => l_api_version,
      p_init_msg_list       => G_FALSE,
      p_chr_id              => l_contract_id,
      p_negotiation_status  => G_NEG_STS_IA_FAIL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
     );
     IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- In case of errors, set wf attributes that'll be used by the notification
     -- and will be rendered by OAF embedded region.
     l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
     l_notif_attr_rec.ITEM_KEY          := itemkey;
     l_notif_attr_rec.PERFORMER         := NULL;
     l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_ERROR;
     l_notif_attr_rec.NTF_SUBJECT       := NULL;
     l_notif_attr_rec.SUBJECT           := get_lookup_meaning(G_NEG_STS_IA_FAIL,G_LKUP_TYPE_NEGO_STATUS);
     l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;
     l_notif_attr_rec.MSGS_FROM_STACK_YN:= 'Y';

     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
     END IF;
     set_notification_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_notif_attr     => l_notif_attr_rec,
      x_return_status  => l_return_status,
      x_msg_data       => l_msg_data,
      x_msg_count      => l_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
        'OKC_CONTRACT_APPROVAL_PUB.k_signed(p_contract_id= '||l_contract_id||')');
   END IF;
   -- sign the contract
   OKC_CONTRACT_APPROVAL_PUB.k_signed
   (
    p_contract_id     => l_contract_id,
    p_complete_k_prcs => 'N',
    x_return_status   => l_return_status
   );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
        'OKC_CONTRACT_APPROVAL_PUB.k_signed(x_return_status= '||l_return_status||')');
   END IF;
   IF l_return_status <> G_RET_STS_SUCCESS THEN
     update_negotiation_status
     (
      p_api_version         => l_api_version,
      p_init_msg_list       => G_FALSE,
      p_chr_id              => l_contract_id,
      p_negotiation_status  => G_NEG_STS_IA_FAIL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
     );
     IF l_return_status <> G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- In case of errors, set wf attributes that'll be used by the notification
     -- and will be rendered by OAF embedded region.
     l_notif_attr_rec.CONTRACT_ID       := l_contract_id;
     l_notif_attr_rec.ITEM_KEY          := itemkey;
     l_notif_attr_rec.PERFORMER         := NULL;
     l_notif_attr_rec.NTF_TYPE          := G_NTF_TYPE_ERROR;
     l_notif_attr_rec.NTF_SUBJECT       := NULL;
     l_notif_attr_rec.SUBJECT           := get_lookup_meaning(G_NEG_STS_IA_FAIL,G_LKUP_TYPE_NEGO_STATUS);
     l_notif_attr_rec.ACCEPT_DECLINE_BY := NULL;
     l_notif_attr_rec.MSGS_FROM_STACK_YN:= 'Y';

     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes('||
                    ' Contract ID ='||l_contract_id||
                    ' Notification Type ='||l_notif_attr_rec.NTF_TYPE||
                    ' Subject ='||l_notif_attr_rec.NTF_SUBJECT||')');
     END IF;
     set_notification_attributes
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_notif_attr     => l_notif_attr_rec,
      x_return_status  => l_return_status,
      x_msg_data       => l_msg_data,
      x_msg_count      => l_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                    'OKS_WF_K_PROCESS_PVT.set_notification_attributes(x_return_status= '||
                    l_return_status||' x_msg_count ='||l_msg_count||')');
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   resultout := 'COMPLETE:T';
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
   RETURN;
 END IF; -- (funcmode = 'RUN')

 IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=CANCEL');
    END IF;
    RETURN;
 END IF; -- (funcmode = 'CANCEL')

 IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from funcmode=TIMEOUT');
    END IF;
    RETURN;
 END IF;  -- (funcmode = 'TIMEOUT')
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    resultout := 'COMPLETE:F';
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'Error: Itemtype: '
          ||NVL(itemtype,'NULL')||' Itemkey: '||NVL(itemkey,'NULL'));
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,l_msg_data);
     END IF;
     wf_core.CONTEXT
     (
      pkg_name  => G_PKG_NAME,
      proc_name => l_api_name,
      arg1      => itemtype,
      arg2      => itemkey,
      arg3      => l_msg_data
     );
  WHEN others THEN
    resultout := 'COMPLETE:F';
    l_msg_data := get_fnd_message;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    wf_core.CONTEXT
    (
     pkg_name  => G_PKG_NAME,
     proc_name => l_api_name,
     arg1      => itemtype,
     arg2      => itemkey,
     arg3      => to_char(actid),
     arg4      => funcmode,
     arg5      => SQLCODE,
     arg6      => SQLERRM
    );
END activate_contract;

    /*
        This procedure is a concurrent program, that launches wf for all
        ENTERED status contracts, that do not have a workflow associated with them
        and have not been submitted for approval.
    */
    PROCEDURE launch_wf_conc_prog
    (
     ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY NUMBER
     )
    IS

    -- The following cursor will pick up all contracts which are in ENTERED status
    -- without any existing active renewal/process workflow (obviously !!!)
    -- and not been submitted for approval
    CURSOR c_old_k IS
        SELECT oksk.CHR_ID CHR_ID,
            nvl(oksk.RENEWAL_TYPE_USED, G_RENEW_TYPE_MANUAL) RENEWAL_TYPE_USED,
            nvl(oksk.APPROVAL_TYPE_USED, G_IRR_FLAG_REQD) APPROVAL_TYPE_USED,
            okck.CONTRACT_NUMBER CONTRACT_NUMBER,
            nvl(okck.CONTRACT_NUMBER_MODIFIER, FND_API.G_MISS_CHAR) CONTRACT_NUMBER_MODIFIER,
            nvl(oksk.RENEWAL_STATUS, G_NEG_STS_DRAFT) RENEWAL_STATUS
        FROM OKS_K_HEADERS_B oksk,
            OKC_K_HEADERS_ALL_B okck,
            OKC_STATUSES_B sts
        WHERE oksk.chr_id = okck.id
            AND sts.ste_code = 'ENTERED'
            AND sts.code = okck.sts_code
            AND okck.template_yn = 'N'
            --no active approval workflow exists
            AND NOT EXISTS
                (SELECT 1
                FROM   WF_ITEMS WF,
                    OKC_PROCESS_DEFS_B KPDF
                WHERE WF.item_key = okck.contract_number || okck.contract_number_modifier
                    AND   WF.end_date IS NULL
                    AND   WF.item_type = KPDF.wf_name
                    AND   KPDF.pdf_type = 'WPS')
            --for an ENTERED status contract, no active base workflow exists
            AND NOT EXISTS
                (SELECT 1
                FROM   WF_ITEMS WF
                WHERE WF.item_key = oksk.wf_item_key
                    AND   WF.end_date IS NULL
                    AND   WF.item_type = G_ITEM_TYPE);

    TYPE k_rec_tbl_type IS TABLE OF c_old_k%ROWTYPE INDEX BY BINARY_INTEGER;

    l_return_status VARCHAR2(1) := 'S';
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    l_k_rec_tbl k_rec_tbl_type;
    l_wf_attributes_tbl WF_ATTR_DETAILS_TBL;

    l_rollcount NUMBER := 0;
    l_wfcount NUMBER := 0;
    l_errcount NUMBER := 0;

    BEGIN
        retcode := 0; --0 for success, 1 for warning, 2 for error

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting Concurrent Program, time: '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        OPEN c_old_k;
        LOOP

            FETCH c_old_k BULK COLLECT INTO l_k_rec_tbl LIMIT 1000;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Bulk fetched '||l_k_rec_tbl.COUNT ||' rows');

            EXIT WHEN (l_k_rec_tbl.COUNT = 0);
            l_rollcount := l_rollcount + l_k_rec_tbl.COUNT;

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Launching Workflow ');

            FOR i IN l_k_rec_tbl.FIRST..l_k_rec_tbl.LAST LOOP
                l_wf_attributes_tbl(i).CONTRACT_ID := l_k_rec_tbl(i).chr_id;
                l_wf_attributes_tbl(i).CONTRACT_NUMBER := l_k_rec_tbl(i).contract_number;
                IF (l_k_rec_tbl(i).contract_number_modifier = FND_API.G_MISS_CHAR) THEN
                    l_wf_attributes_tbl(i).CONTRACT_MODIFIER := NULL;
                ELSE
                    l_wf_attributes_tbl(i).CONTRACT_MODIFIER := l_k_rec_tbl(i).contract_number_modifier;
                END IF;
                l_wf_attributes_tbl(i).PROCESS_TYPE := l_k_rec_tbl(i).renewal_type_used;
                l_wf_attributes_tbl(i).IRR_FLAG := l_k_rec_tbl(i).approval_type_used;
                l_wf_attributes_tbl(i).NEGOTIATION_STATUS := l_k_rec_tbl(i).renewal_status;
            END LOOP;

            l_return_status := 'S';

            --if any errors happen, this procedure will roll it back for all the records passed in
            launch_k_process_wf_blk(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_TRUE,
                p_commit => FND_API.G_FALSE,
                p_wf_attributes_tbl => l_wf_attributes_tbl,
                p_update_item_key => 'Y',
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data);

            --if unexpected error happens - we abort, for other errors we will
            --try the next batch
            IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                l_errcount := l_errcount + l_k_rec_tbl.COUNT;
                FOR j IN 1..l_msg_count LOOP
                    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.get(j, 'F'));
                END LOOP;
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                --just log the error and continue
                l_errcount := l_errcount + l_k_rec_tbl.COUNT;
                retcode := 1;
                FOR j IN 1..l_msg_count LOOP
                    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.get(j, 'F'));
                END LOOP;
            ELSE
                l_wfcount := l_wfcount + l_k_rec_tbl.COUNT;
            END IF;

            --delete for the the next loop
            l_wf_attributes_tbl.DELETE;
            COMMIT;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows processed so far: ' || l_rollcount);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows errored so far: ' || l_errcount);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows successful so far: '|| l_wfcount);


        END LOOP; -- main cursor loop
        CLOSE c_old_k;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Total Rows processed: '|| l_rollcount);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Total Rows errored: '|| l_errcount);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Total Rows succesful: '|| l_wfcount);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'End Concurrent Program - Success, time: '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')||' ,retcode='||retcode);

    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2;
            IF (c_old_k%isopen) THEN
                CLOSE c_old_k;
            END IF;
            errbuf := sqlcode||sqlerrm;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'End Concurrent Program - Error, time: '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')||' ,retcode='||retcode);

    END launch_wf_conc_prog;


    /* Bulk API for launching wf for ENTERED status Service Contracts
	This procedure launches the workflow for a Service Contract. From R12 onwards every
    Service Contract when created has a workflow associated with it, that routes the
    contract till it is activated.

    Parameters
        p_wf_attributes_tbl     :   table of records containg the details of the workflow to be
                                     launched
        p_update_item_key       :  Y|N indicating if oks_k_headers_b and oks_k_headers_bh are to be
                                    updated with the passed item keys

    Rules for input record fiels
        1. Contract_id must be passed, if not passed the record is ignored
        2. Contract number and modifier must be passed, they are set as item attributes for the
           workflow
        3. Process_type and irr_flag are optional, they are stamped as workflow item
            attributes. Defaulted as -  procees_type = NSR and irr_flag = Y
        4. Negotiation_status is optional, if NULL or PREDRAFT, it is defaulted as DRAFT. It is
           stamped as workflow item attribute.
        5. Item_key is optional, if not passed it is defaulted as
           contract_id || to_char(sysdate, 'YYYYMMDDHH24MISS').

    */
    PROCEDURE launch_k_process_wf_blk
    (
     p_api_version              IN NUMBER DEFAULT 1.0,
     p_init_msg_list            IN VARCHAR2 DEFAULT 'F',
     p_commit                   IN VARCHAR2 DEFAULT 'F',
     p_wf_attributes_tbl        IN WF_ATTR_DETAILS_TBL,
     p_update_item_key          IN VARCHAR2 DEFAULT 'Y',
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'launch_k_process_wf_blk';
    l_api_version               CONSTANT NUMBER := 1;
    l_mod_name                  VARCHAR2(256) := G_MODULE || l_api_name;
    l_error_text                VARCHAR2(512);

    l_wf_err_name               VARCHAR2(30);
    l_wf_err_msg                VARCHAR2(2000);
    l_wf_err_stack              VARCHAR2(4000);

    l_item_keys                 WF_ENGINE_BULK.itemkeytabtype;
    l_user_keys                 WF_ENGINE_BULK.userkeytabtype;
    l_owner_roles               WF_ENGINE_BULK.ownerroletabtype;

    l_contract_id_names         WF_ENGINE.nametabtyp;
    l_contract_number_names     WF_ENGINE.nametabtyp;
    l_contract_modifier_names   WF_ENGINE.nametabtyp;
    l_process_type_names        WF_ENGINE.nametabtyp;
    l_irr_flag_names            WF_ENGINE.nametabtyp;
    l_neg_status_names          WF_ENGINE.nametabtyp;
    l_user_id_names             WF_ENGINE.nametabtyp;
    l_responsibility_id_names   WF_ENGINE.nametabtyp;
    l_resp_appl_id_names        WF_ENGINE.nametabtyp;
    l_security_group_id_names   WF_ENGINE.nametabtyp;

    l_contract_id_values        WF_ENGINE.numtabtyp;
    l_contract_number_values    WF_ENGINE.texttabtyp;
    l_contract_modifier_values  WF_ENGINE.texttabtyp;
    l_process_type_values       WF_ENGINE.texttabtyp;
    l_irr_flag_values           WF_ENGINE.texttabtyp;
    l_neg_status_values         WF_ENGINE.texttabtyp;
    l_user_id_values            WF_ENGINE.numtabtyp;
    l_responsibility_id_values  WF_ENGINE.numtabtyp;
    l_resp_appl_id_values       WF_ENGINE.numtabtyp;
    l_security_group_id_values  WF_ENGINE.numtabtyp;

    l_contract_id_count         NUMBER := 0;
    l_date                      DATE := sysdate;

    BEGIN
    --log key input parameters
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_api_version=' || p_api_version ||' ,p_commit='|| p_commit ||' ,p_wf_attributes_tbl.count='|| p_wf_attributes_tbl.count||' ,p_update_item_key='||p_update_item_key);
    END IF;

    --standard api initilization and checks
    SAVEPOINT launch_k_process_wf_blk_PVT;
    IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF FND_API.to_boolean(p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_wf_attributes_tbl.count = 0 ) THEN
        RETURN;
    END IF;

    FOR i IN p_wf_attributes_tbl.FIRST..p_wf_attributes_tbl.LAST LOOP
        IF (p_wf_attributes_tbl(i).contract_id IS NOT NULL) THEN

            l_contract_id_count := l_contract_id_count + 1;

            l_item_keys(l_contract_id_count) := nvl(p_wf_attributes_tbl(i).item_key,
                p_wf_attributes_tbl(i).contract_id ||to_char(l_date, 'YYYYMMDDHH24MISS'));

            l_user_keys(l_contract_id_count) := p_wf_attributes_tbl(i).contract_number;
            IF (p_wf_attributes_tbl(i).contract_modifier IS NOT NULL) THEN
                l_user_keys(l_contract_id_count) := l_user_keys(l_contract_id_count) || ' ' ||
                    p_wf_attributes_tbl(i).contract_modifier;
            END IF;

            --setting it to null, ideally we should set it to contract salesrep,
            --but since it is expensive we can defer it to later in the Workflow
            l_owner_roles(l_contract_id_count) := NULL;

            l_contract_id_names(l_contract_id_count) := 'CONTRACT_ID';
            l_contract_id_values(l_contract_id_count) := p_wf_attributes_tbl(i).contract_id;

            l_contract_number_names(l_contract_id_count) := 'CONTRACT_NUMBER';
            l_contract_number_values(l_contract_id_count) := p_wf_attributes_tbl(i).contract_number;

            l_contract_modifier_names(l_contract_id_count) := 'CONTRACT_MODIFIER';
            l_contract_modifier_values(l_contract_id_count) :=
                p_wf_attributes_tbl(i).contract_modifier;

            l_process_type_names(l_contract_id_count) := 'PROCESS_TYPE';
            l_process_type_values(l_contract_id_count) := nvl(p_wf_attributes_tbl(i).process_type,G_RENEW_TYPE_MANUAL);

            l_irr_flag_names(l_contract_id_count) := 'IRR_FLAG';
            l_irr_flag_values(l_contract_id_count) := nvl(p_wf_attributes_tbl(i).irr_flag, G_IRR_FLAG_REQD);

            l_user_id_names(l_contract_id_count) := 'USER_ID';
            l_user_id_values(l_contract_id_count) := fnd_global.user_id;

            l_responsibility_id_names(l_contract_id_count) := 'RESP_ID';
            l_responsibility_id_values(l_contract_id_count) := fnd_global.resp_id;

            l_resp_appl_id_names(l_contract_id_count) := 'RESP_APPL_ID';
            l_resp_appl_id_values(l_contract_id_count) := fnd_global.resp_appl_id;

            l_security_group_id_names(l_contract_id_count) := 'SECURITY_GROUP_ID';
            l_security_group_id_values(l_contract_id_count) := fnd_global.security_group_id;

            l_neg_status_names(l_contract_id_count) := 'NEGOTIATION_STATUS';
            IF (p_wf_attributes_tbl(i).negotiation_status IS NULL OR
                p_wf_attributes_tbl(i).negotiation_status = G_NEG_STS_PRE_DRAFT) THEN
                l_neg_status_values(l_contract_id_count) := G_NEG_STS_DRAFT;
            ELSE
                l_neg_status_values(l_contract_id_count) := p_wf_attributes_tbl(i).negotiation_status;
            END IF;

        END IF;
    END LOOP;

    IF (l_contract_id_count > 0) THEN

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.bulk_wf', 'l_contract_id_count='||l_contract_id_count||' ,calling WF_ENGINE_BULK.createprocess');
        END IF;

        WF_ENGINE_BULK.createprocess(
            itemtype => G_ITEM_TYPE,
            itemkeys  =>  l_item_keys,
            process  => G_MAIN_PROCESS,
            user_keys =>  l_user_keys,
            owner_roles => l_owner_roles);

        WF_ENGINE_BULK.setitemattrnumber(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_contract_id_names,
            avalues  => l_contract_id_values);

        WF_ENGINE_BULK.setitemattrtext(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_contract_number_names,
            avalues  => l_contract_number_values);

        WF_ENGINE_BULK.setitemattrtext(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_contract_modifier_names,
            avalues  => l_contract_modifier_values);

        WF_ENGINE_BULK.setitemattrtext(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_process_type_names,
            avalues  => l_process_type_values);

        WF_ENGINE_BULK.setitemattrtext(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_irr_flag_names,
            avalues  => l_irr_flag_values);

        WF_ENGINE_BULK.setitemattrtext(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_neg_status_names,
            avalues  => l_neg_status_values);

        WF_ENGINE_BULK.setitemattrnumber(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_user_id_names,
            avalues  => l_user_id_values);

        WF_ENGINE_BULK.setitemattrnumber(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_responsibility_id_names,
            avalues  => l_responsibility_id_values);

        WF_ENGINE_BULK.setitemattrnumber(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_resp_appl_id_names,
            avalues  => l_resp_appl_id_values);

        WF_ENGINE_BULK.setitemattrnumber(
            itemtype => G_ITEM_TYPE,
            itemkeys => l_item_keys,
            anames   => l_security_group_id_names,
            avalues  => l_security_group_id_values);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.bulk_wf', ',calling WF_ENGINE_BULK.startprocess');
        END IF;

        WF_ENGINE_BULK.startprocess(
            itemtype => G_ITEM_TYPE,
            itemkeys  =>  l_item_keys);

        IF ( nvl(p_update_item_key, 'N') = 'Y' ) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update', ',upating  oks_k_headers_b');
            END IF;

            FORALL i IN l_contract_id_values.FIRST..l_contract_id_values.LAST
                UPDATE oks_k_headers_b
                    SET wf_item_key = l_item_keys(i),
                        renewal_status = nvl(renewal_status,G_NEG_STS_DRAFT),
                        object_version_number = object_version_number + 1,
                        last_update_date = SYSDATE,
                        last_updated_by = FND_GLOBAL.USER_ID,
                        last_update_login = FND_GLOBAL.LOGIN_ID
                    WHERE chr_id = l_contract_id_values(i);

            FORALL i IN l_contract_id_values.FIRST..l_contract_id_values.LAST
                UPDATE oks_k_headers_bh
                    SET wf_item_key = l_item_keys(i),
                        object_version_number = object_version_number + 1,
                        renewal_status = nvl(renewal_status,G_NEG_STS_DRAFT),
                        last_update_date = SYSDATE,
                        last_updated_by = FND_GLOBAL.USER_ID,
                        last_update_login = FND_GLOBAL.LOGIN_ID
                    WHERE chr_id = l_contract_id_values(i);
        END IF;
    END IF;

    --standard check of p_commit
    IF FND_API.to_boolean( p_commit ) THEN
        COMMIT;
    END IF;
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
    END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO launch_k_process_wf_blk_PVT;
        x_return_status := FND_API.g_ret_sts_error ;

        IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO launch_k_process_wf_blk_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO launch_k_process_wf_blk_PVT;

        --since we are calling  workflow api's we need to check for workflow errors
        WF_CORE.get_error(l_wf_err_name, l_wf_err_msg, l_wf_err_stack, 4000);

        IF (l_wf_err_name IS NOT NULL) THEN
            --workflow error
            WF_CORE.clear;
            --set the status to error, so that calling program can handle it
            x_return_status := FND_API.g_ret_sts_error ;
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_wf_err_name||' '||l_wf_err_msg);

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_workflow_error', 'x_return_status=' || x_return_status);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_workflow_error', 'err_name=' || l_wf_err_name||', err_msg='|| l_wf_err_msg||',err_stack='|| l_wf_err_stack);
            END IF;

        ELSE
            --other error
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
        END IF;

        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

END launch_k_process_wf_blk;

END OKS_WF_K_PROCESS_PVT;

/
