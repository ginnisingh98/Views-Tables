--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_APPROVAL_PVT" as
/* $Header: OKCRCAPB.pls 120.19.12010000.2 2009/08/04 10:19:39 vgujarat ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_APPROVAL_PVT';
  G_LEVEL				CONSTANT VARCHAR2(4)   := '_PVT';
  G_MODULE               CONSTANT VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  l_api_version               CONSTANT NUMBER := 1;
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
--
  G_K_WAS_APPROVED CONSTANT   varchar2(200) := 			'OKC_ALREADY_APPROVED';
--
  G_PROCESS_NOT_FOR_APPROVAL CONSTANT   varchar2(200) := 	'OKC_PROCESS_NOT_FOR_APPROVAL';
  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 			'WF_ITEM';
  G_WF_P_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_PROCESS';
--
  G_PROCESS_NOTFOUND CONSTANT   varchar2(200) := 		'OKC_PROCESS_NOT_FOUND';
--
  G_K_ON_APPROVAL CONSTANT   varchar2(200) := 			'OKC_IS_ON_APPROVAL';
--  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_ITEM';
  G_KEY_TOKEN CONSTANT   varchar2(200) := 			'WF_KEY';
--
  G_WF_NOT_PURGED CONSTANT   varchar2(200) := 			'OKC_WF_NOT_PURGED';
--  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_ITEM';
--  G_KEY_TOKEN CONSTANT   varchar2(200) := 			'WF_KEY';
--
  G_K_NOT_ON_APPROVAL CONSTANT   varchar2(200) := 		'OKC_PROCESS_NOT_ACTIVE';
--
  G_NO_U_PRIVILEGE CONSTANT   varchar2(200) := 			'OKC_NO_RIGHT_TO_CHANGE';

PROCEDURE continue_k_process
(
 p_api_version    IN         NUMBER,
 p_init_msg_list  IN         VARCHAR2 ,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2,
 p_contract_id    IN         NUMBER,
 p_wf_item_key    IN         VARCHAR2,
 p_called_from    IN         VARCHAR2
 ) AS
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'continue_k_process';

 CURSOR l_kdetails_csr(p_chr_id NUMBER) IS
 SELECT wf_item_key
 FROM oks_k_headers_b
 WHERE chr_id = p_chr_id;

 l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_wf_attributes          OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS;
 l_wf_item_key            VARCHAR2(240);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , 'okc.plsql.'||l_api_name,
        'Entered '||G_PKG_NAME ||'.'||l_api_name||' p_contract_id='||p_contract_id
	   ||' p_called_from='||p_called_from);
 END IF;

 l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
   RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;

 IF p_wf_item_key IS NULL THEN
   OPEN l_kdetails_csr(p_contract_id);
   FETCH l_kdetails_csr INTO l_wf_item_key;
   CLOSE l_kdetails_csr;
 ELSE
   l_wf_item_key := p_wf_item_key;
 END IF;

 IF l_wf_item_key IS NOT NULL THEN
   IF NVL(p_called_from,'!') = 'APPROVE' THEN
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       ' OKS_WF_K_PROCESS_PVT.complete_activity with APPROVED result');
     END IF;
     OKS_WF_K_PROCESS_PVT.complete_activity
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_contract_id    => p_contract_id,
      p_item_key       => l_wf_item_key,
      p_resultout      => 'APPROVED',
      p_process_status => NULL,
      p_activity_name  => 'REVIEW_AND_APPROVE',
      x_return_status  => x_return_status,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' Return status='||x_return_status||' x_msg_count='||x_msg_count);
     END IF;
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

   ELSIF NVL(p_called_from,'!') = 'STOP' THEN
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       ' OKS_WF_K_PROCESS_PVT.complete_activity with STOPPED result');
     END IF;
     OKS_WF_K_PROCESS_PVT.complete_activity
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_contract_id    => p_contract_id,
      p_item_key       => l_wf_item_key,
      p_resultout      => 'STOPPED',
      p_process_status => 'ACT',
      p_activity_name  => 'REVIEW_AND_APPROVE',
      x_return_status  => x_return_status,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' Return status='||x_return_status||' x_msg_count='||x_msg_count);
     END IF;
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- update process status to 'Quote Accepted' coz approval workflow
     -- is stopped so we should effectively revert back to the original
     -- negotiation status.
/*	IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
       UPDATE oks_k_headers_b
       SET object_version_number = object_version_number + 1,
           renewal_status = 'ACT',
           last_update_date = SYSDATE,
           last_update_login = FND_GLOBAL.LOGIN_ID,
           Last_updated_by = FND_GLOBAL.USER_ID
       WHERE chr_id = p_contract_id;
     END IF;
*/
   ELSIF NVL(p_called_from,'!') = 'REJECTED' THEN
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       ' OKS_WF_K_PROCESS_PVT.complete_activity with REJECTED result');
     END IF;
     OKS_WF_K_PROCESS_PVT.complete_activity
     (
      p_api_version    => l_api_version,
      p_init_msg_list  => OKC_API.G_FALSE,
      p_contract_id    => p_contract_id,
      p_item_key       => l_wf_item_key,
      p_resultout      => NULL,
      p_process_status => 'REJECTED',
      p_activity_name  => 'REVIEW_AND_APPROVE',
      x_return_status  => x_return_status,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' Return status='||x_return_status||' x_msg_count='||x_msg_count);
     END IF;
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- update process status to 'Quote Accepted' coz approval workflow
     -- is stopped so we should effectively revert back to the original
     -- negotiation status.
/*	IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
       UPDATE oks_k_headers_b
       SET object_version_number = object_version_number + 1,
           renewal_status = 'REJ',
           last_update_date = SYSDATE,
           last_update_login = FND_GLOBAL.LOGIN_ID,
           Last_updated_by = FND_GLOBAL.USER_ID
       WHERE chr_id = p_contract_id;
     END IF;
*/
   END IF;
 -- Following code is executed only after migration of  pre-R12
 -- contracts that are in the approval process (no prior OKS Contract
 -- Process wf existing) and being either approved or rejected by approver.
 ELSE
   IF NVL(p_called_from,'!') = 'APPROVE' THEN
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Updating Negotiation status to Complete');
      END IF;
      -- We just want to update the negotiation status; NO interaction
      -- or email or notification is sent for these scenarios
      UPDATE oks_k_headers_b
      SET renewal_status       = 'COMPLETE',
         object_version_number = object_version_number + 1,
         last_update_date      = SYSDATE,
         last_updated_by       = FND_GLOBAL.USER_ID,
         last_update_login     = FND_GLOBAL.LOGIN_ID
     WHERE chr_id              = p_contract_id;
   ELSIF NVL(p_called_from,'!') = 'REJECTED' THEN
     -- Launch process workflow for existing service contracts created prior to r12
     -- as they would not have process workflow associated as they had been in the
     -- Approval process. We'll have to place it in salesrep queue in Rejected status
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Preparing to launch workflow ...');
     END IF;
     l_wf_attributes.CONTRACT_ID := p_contract_id;
     l_wf_attributes.NEGOTIATION_STATUS := 'REJECTED';
     l_wf_attributes.ITEM_KEY := p_contract_id||to_char(sysdate,'YYYYMMDDHH24MISS');
     l_wf_attributes.IRR_FLAG := 'Y';
     l_wf_attributes.PROCESS_TYPE := 'MANUAL';
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                       ' OKS_WF_K_PROCESS_PVT.launch_k_process_wf p_contract_id '||
                       p_contract_id);
   END IF;
     OKS_WF_K_PROCESS_PVT.launch_k_process_wf
            (
             p_api_version          => 1.0,
             p_init_msg_list        => 'T',
             p_wf_attributes        => l_wf_attributes,
             x_return_status        => x_return_status,
             x_msg_count            => x_msg_count,
             x_msg_data             => x_msg_data
            ) ;
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                       'OKS_WF_K_PROCESS_PVT.launch_k_process_wf x_return_status=>'||
                       x_return_status);
     END IF;
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
      UPDATE oks_k_headers_b
     SET object_version_number = object_version_number + 1,
         wf_item_key = l_wf_attributes.ITEM_KEY,
         renewal_status = l_wf_attributes.NEGOTIATION_STATUS,
         last_update_date = SYSDATE,
         last_update_login = FND_GLOBAL.LOGIN_ID,
         Last_updated_by = FND_GLOBAL.USER_ID
     WHERE chr_id = l_wf_attributes.contract_id;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE||l_api_name,
                       ' Updated negotiation status to REJECTED');
     END IF;
   END IF;
 END IF;
 -- Explicit commit needed
 COMMIT;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okc.plsql.'||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
 WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
 WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
 WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
END continue_k_process;

-- Start of comments
--
-- Procedure Name  : k_approval_start
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_start(
                    p_api_version       IN  NUMBER,
                    p_init_msg_list     IN  VARCHAR2 ,
                    x_return_status     OUT NOCOPY VARCHAR2,
                    x_msg_count         OUT NOCOPY NUMBER,
                    x_msg_data          OUT NOCOPY VARCHAR2,
                    p_contract_id       IN number,
                    p_process_id        IN number,
                    p_do_commit         IN VARCHAR2,
                    p_access_level      IN VARCHAR2,
                    p_user_id           IN  NUMBER default null,
                    p_resp_id           IN  NUMBER default null,
                    p_resp_appl_id      IN  NUMBER default null,
                    p_security_group_id IN  NUMBER default null
			) is
l_api_name                     CONSTANT VARCHAR2(30) := 'k_approval_start';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--
l_key varchar2(240);
l_contract_number varchar2(120);
l_contract_number_modifier varchar2(120);
l_date_approved date;
--
l_wf_name_active varchar2(150);
l_wf_name varchar2(150);
l_wf_process_name varchar2(150);
l_usage varchar2(60);
--
l_q varchar2(1);
--
L_PAR_NAME      	VARCHAR2(150);
L_PAR_TYPE       VARCHAR2(90);
L_PAR_VALUE   VARCHAR2(2000);
--
L_NLS_VALUE VARCHAR2(30);
--
L1_CPSV_REC  OKC_CONTRACT_PUB.cpsv_rec_type;
L2_CPSV_REC  OKC_CONTRACT_PUB.cpsv_rec_type;
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);
l_err_name   VARCHAR2(30);
l_err_stack  VARCHAR2(2000);

cursor k_pid is
  select ID
  from okc_k_processes_v
  where CHR_ID = p_contract_id
    and PDF_ID = p_process_id
--because of bug in lock API
	for update of process_id nowait;
--
cursor k_header_csr is
  select H.CONTRACT_NUMBER,
    H.CONTRACT_NUMBER_MODIFIER,
    H.DATE_APPROVED,
	S.MEANING,
	S.STE_CODE
  from okc_k_headers_all_b H, okc_statuses_v S
  where H.ID = p_contract_id
	and H.STS_CODE=S.CODE;
l_status varchar2(100);
l_status_type varchar2(100);
--
cursor process_def_csr is
  select WF_NAME, WF_PROCESS_NAME, USAGE
  from OKC_PROCESS_DEFS_B
     where ID = p_process_id
  and begin_date<=sysdate
  and (end_date is NULL or end_date>=sysdate) and PDF_TYPE='WPS';
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='APPROVE' and PDF_TYPE='WPS')
   and item_key = l_key
   and end_date is NULL;

--
cursor for_purge_csr is
  select '!'
  from WF_ITEMS
  where item_type = l_wf_name
   and item_key = l_key;
--
cursor defined_parameters_csr is
  select
    NAME,
    DATA_TYPE,
    DEFAULT_VALUE
  from OKC_PROCESS_DEF_PARAMETERS_V
  where PDF_ID = p_process_id;
--
begin
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'p_contract_id=>'||p_contract_id||' p_process_id=>'||
			    p_process_id||' p_do_commit=>'|| p_do_commit);
 END IF;
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
			    'OKC_API.START_ACTIVITY return status '||l_return_status);
 END IF;
--
  -- Modified for Bug 2046890
  -- Below IF added because context does not set thru background processes
  -- that's why need to bypass it
--  IF FND_GLOBAL.USER_ID <> -1 THEN
IF p_access_level = 'N' THEN
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
			    'k_accesible with p_level=U User Id '||fnd_global.user_id);
 END IF;
  if k_accesible( p_contract_id => p_contract_id,
			p_user_id => fnd_global.user_id,
			p_level => 'U'
		     ) = OKC_API.G_FALSE
  then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_NO_U_PRIVILEGE);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
  END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Contract is accessible - get contract details');
 END IF;
  -- Modified for Bug 2046890
  open k_header_csr;
  fetch k_header_csr
  into L_CONTRACT_NUMBER, L_CONTRACT_NUMBER_MODIFIER, L_DATE_APPROVED, L_STATUS, L_STATUS_TYPE;
  close k_header_csr;
  if (L_DATE_APPROVED is not NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_K_WAS_APPROVED);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Got contract details L_STATUS_TYPE=>'||L_STATUS_TYPE);
 END IF;
  if (L_STATUS_TYPE <> 'ENTERED') then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => 'OKC_INVALID_K_STATUS',
                        p_token1       => 'NUMBER',
                        p_token1_value => L_CONTRACT_NUMBER||'-'||L_CONTRACT_NUMBER_MODIFIER,
                        p_token2       => 'STATUS',
                        p_token2_value => L_STATUS);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
  open process_def_csr;
  fetch process_def_csr into L_WF_NAME, L_WF_PROCESS_NAME, L_USAGE;
  close process_def_csr;
  if (L_WF_NAME is NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_PROCESS_NOTFOUND);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Got process def details L_WF_NAME=>'||L_WF_NAME||
                   ' L_WF_PROCESS_NAME=>'||L_WF_PROCESS_NAME||
                   ' L_USAGE=>'||L_USAGE);
 END IF;
  if (L_USAGE <> 'APPROVE') then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_PROCESS_NOT_FOR_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME,
                        p_token2       => G_WF_P_NAME_TOKEN,
                        p_token2_value => L_WF_PROCESS_NAME);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
  L_KEY := L_CONTRACT_NUMBER||L_CONTRACT_NUMBER_MODIFIER;
  open approval_active_csr;
  fetch approval_active_csr into L_WF_NAME_ACTIVE;
  close approval_active_csr;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'L_WF_NAME_ACTIVE=>'||L_WF_NAME_ACTIVE);
 END IF;
  if (L_WF_NAME_ACTIVE is not NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_K_ON_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME_ACTIVE,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
  L_Q:='?';
  open for_purge_csr;
  fetch for_purge_csr into L_Q;
  close for_purge_csr;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'L_Q=>'||L_Q);
 END IF;
  if (L_Q = '!') then
  begin
    --- Bug#33096950 - wf_purge.total(l_wf_name,l_key);
    wf_purge.total(l_wf_name,l_key,runtimeonly=>TRUE);
  exception
  when others then
    begin
	 -- for Bug#3096950 - wf_purge.totalPerm(l_wf_name,l_key);
      wf_purge.totalPerm(l_wf_name,l_key,runtimeonly=>TRUE);
    exception
    when others then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_WF_NOT_PURGED,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    end;
  end;
  end if;
--
  savepoint BECAUSE_OF_BUG_IN_lock;
  begin
    open k_pid;
    fetch k_pid into L1_CPSV_REC.id;
    close k_pid;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   ' L1_CPSV_REC.id=>'|| L1_CPSV_REC.id);
 END IF;
  exception
    when others then
	rollback to BECAUSE_OF_BUG_IN_lock;
      OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
      RAISE OKC_API.G_EXCEPTION_ERROR;
  end;
    L1_CPSV_REC.PROCESS_ID := L_KEY;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name||'.external_call.before',
                   ' OKC_CONTRACT_PUB.update_contract_process L1_CPSV_REC.PROCESS_ID=>'||L1_CPSV_REC.PROCESS_ID);
 END IF;
    OKC_CONTRACT_PUB.update_contract_process(
      p_api_version		=> l_api_version,
      x_return_status	=> l_return_status,
      x_msg_count		=> l_msg_count,
      x_msg_data		=> l_msg_data,
      p_cpsv_rec		=> L1_CPSV_REC,
      x_cpsv_rec		=> L2_CPSV_REC);
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name||'.external_call.after',
                   ' OKC_CONTRACT_PUB.update_contract_process x_return_status=>'||l_return_status);
 END IF;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	rollback to BECAUSE_OF_BUG_IN_lock;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	rollback to BECAUSE_OF_BUG_IN_lock;
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    ' wf_engine.CreateProcess(ItemType=>'||L_WF_NAME||
                    ' ItemKey=>'||L_KEY||' process=>'||L_WF_PROCESS_NAME||')');
 END IF;
    wf_engine.CreateProcess( ItemType => L_WF_NAME,
				 ItemKey  => L_KEY,
				 process  => L_WF_PROCESS_NAME);
    wf_engine.SetItemUserKey (ItemType	=> L_WF_NAME,
					ItemKey		=> L_KEY,
					UserKey		=> L_KEY);
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Setting wf item attributes');
 END IF;
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'PROCESS_ID',
						avalue	=> p_process_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'PROCESS_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'PROCESS_ID',
						avalue	=> p_process_id);
    end;
--
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'CONTRACT_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> NVL(p_user_id,fnd_global.user_id));
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID');
	    wf_engine.SetItemAttrNumber(itemtype	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> NVL(p_user_id,fnd_global.user_id));
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> NVL(p_resp_id,fnd_global.resp_id));
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> NVL(p_resp_id,fnd_global.resp_id));
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> NVL(p_resp_appl_id,fnd_global.RESP_APPL_id));
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> NVL(p_resp_appl_id,fnd_global.RESP_APPL_id));
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> NVL(p_security_group_id,fnd_global.SECURITY_GROUP_id));
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> NVL(p_security_group_id,fnd_global.SECURITY_GROUP_id));
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_FORMAT';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select '"'||value||'"' into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_NUMERIC_CHARACTERS';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    end;
    wf_engine.SetItemOwner (	itemtype => L_WF_NAME,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Starting approval wf');
 END IF;

 BEGIN
    wf_engine.StartProcess( 	itemtype => L_WF_NAME,
	      			itemkey  => L_KEY);
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Successfully started approval wf');
    END IF;
 EXCEPTION
    WHEN OTHERS THEN
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'In others exception ');
          l_msg_data := substr(sqlerrm,1,2000);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name, l_msg_data);
        END IF;
        IF l_msg_data IS NULL THEN
          BEGIN
             wf_core.get_error
             (
              err_name          => l_err_name,
              err_message       => l_msg_data,
              err_stack         => l_err_stack,
              maxerrstacklength => 2000
             );
             IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                               'Error starting approval wf');
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                               l_msg_data);
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                               l_err_stack);
             END IF;
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, l_err_stack);
          EXCEPTION
             WHEN OTHERS THEN
                IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                               'In exception for wf_core.get_error: '||substr(sqlerrm,1,300));
                END IF;
           END;
        END IF;
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, l_msg_data);
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Updating okc header ');
 END IF;

  --Added to fix the bug#3269709
  --issues lock if multiple users are accessing the same contract
  UPDATE okc_k_headers_all_b
  SET OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
  WHERE ID=p_contract_id;
  --
  if (p_do_commit = OKC_API.G_TRUE) then
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Committing.. ');
     END IF;
     commit;
  end if;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end k_approval_start;

-- Start of comments
--
-- Procedure Name  : wf_monitor_url
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function wf_monitor_url(
		p_contract_id IN number,
		p_process_id IN number,
		p_mode IN varchar2
	    ) return varchar2 is
--  to be used by fnd_utilities.open_url
l_wf_name varchar2(150);
l_key varchar2(240);
l_q varchar2(1);
l_admin varchar2(3);
--
cursor wf_name_csr is
  select WF_NAME
  from OKC_PROCESS_DEFS_B
     where ID = p_process_id and PDF_TYPE='WPS';
--
cursor wf_key_csr is
  select CONTRACT_NUMBER||CONTRACT_NUMBER_MODIFIER wf_key
  from okc_k_headers_all_b
  where ID = p_contract_id;
--
cursor wf_exist_csr is
  select '!'
  from WF_ITEMS
  where item_type = l_wf_name
   and item_key = l_key;
--
begin
  open wf_name_csr;
  fetch wf_name_csr into L_WF_NAME;
  close wf_name_csr;
--
  open wf_key_csr;
  fetch wf_key_csr into L_KEY;
  close wf_key_csr;
--
  l_q := '?';
  open wf_exist_csr;
  fetch wf_exist_csr into L_Q;
  close wf_exist_csr;
--
  if l_q = '?' then return NULL;
  else
    if p_mode = 'ADMIN' then l_admin := 'YES';
    else l_admin := 'NO';
    end if;
    return wf_monitor.GetDiagramURL(
	 X_AGENT => WF_CORE.TRANSLATE('WF_WEB_AGENT'),
	 X_ITEM_TYPE => L_WF_NAME,
	 X_ITEM_KEY => L_KEY,
	 X_ADMIN_MODE => l_admin);
  end if;
end wf_monitor_url;

-- Start of comments
--
-- Procedure Name  : k_approval_stop
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_stop(
			p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
			p_contract_id number,
			p_do_commit IN VARCHAR2
		    ) is
l_api_name                     CONSTANT VARCHAR2(30) := 'k_approval_stop';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--
l_q varchar2(1);
l_scs_code varchar2(30);
l_key varchar2(240);
l_wf_name_active varchar2(150);
l_contract_number varchar2(120);
l_contract_number_modifier varchar2(120);
L_K_SHORT_DESCRIPTION varchar2(2000);
L_NLS_VALUE VARCHAR2(30);
--
cursor wf_key_csr is
  select CONTRACT_NUMBER||CONTRACT_NUMBER_MODIFIER wf_key,
	CONTRACT_NUMBER, CONTRACT_NUMBER_MODIFIER,
	short_description, scs_code
  from OKC_K_HDR_AGREEDS_V
  where ID = p_contract_id;
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='APPROVE' and PDF_TYPE='WPS')
   and item_key = l_key
   and end_date is NULL;
--
cursor abort_csr is
  select '!'
  from wf_activities
  where item_type=l_wf_name_active
  and TYPE='PROCESS' and NAME='ABORT_PROCESS'
;
--
cursor C_INITIATOR_DISPLAY_NAME is
/*
  select display_name
  from wf_roles
  where orig_system = 'FND_USR'
  and orig_system_id=fnd_global.user_id
-- changed to boost perf
*/
  select user_name display_name from fnd_user where user_id=fnd_global.user_id and EMPLOYEE_ID is null
  	union all
  select
       PER.FULL_NAME display_name
  from
       PER_PEOPLE_F PER,
       FND_USER USR
  where  trunc(SYSDATE)
      between PER.EFFECTIVE_START_DATE and PER.EFFECTIVE_END_DATE
    and    PER.PERSON_ID       = USR.EMPLOYEE_ID
    and USR.USER_ID = fnd_global.user_id
;

CURSOR k_process_csr(p_contract_id IN NUMBER ) IS
SELECT wf_item_key FROM OKS_K_HEADERS_B
WHERE chr_id = p_contract_id;
--
L_INITIATOR_NAME varchar2(100);
L_FINAL_APPROVER_UNAME varchar2(100);
L_INITIATOR_DISPLAY_NAME varchar2(200);
l_rownotfound      BOOLEAN := FALSE;
l_wf_attributes    OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS;
l_wf_item_key      VARCHAR2(240);
--
begin
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'p_contract_id=>'||p_contract_id||
			    ' p_do_commit=>'|| p_do_commit);
 END IF;
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
			    'OKC_API.START_ACTIVITY return status '||l_return_status);
 END IF;
--
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
			    'k_accesible with p_level=U User Id '||fnd_global.user_id);
 END IF;
  if k_accesible( p_contract_id => p_contract_id,
			p_user_id => fnd_global.user_id,
			p_level => 'U'
		     ) = OKC_API.G_FALSE
  then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_NO_U_PRIVILEGE);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Contract is accessible - get contract details');
 END IF;
  open wf_key_csr;
  fetch wf_key_csr into L_KEY,l_contract_number,l_contract_number_modifier,L_K_SHORT_DESCRIPTION, l_scs_code;
  close wf_key_csr;
--
  open approval_active_csr;
  fetch approval_active_csr into l_wf_name_active;
  close approval_active_csr;
--
  if l_wf_name_active is NULL then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_K_NOT_ON_APPROVAL);
      raise OKC_API.G_EXCEPTION_ERROR;
  end if;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Got wf details l_wf_name_active=>'||l_wf_name_active);
 END IF;
  wf_engine.abortprocess(l_wf_name_active,l_key);
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name||'.external_call.before',
                   'k_erase_approved p_contract_id=>'||p_contract_id);
 END IF;
  k_erase_approved(
			p_contract_id => p_contract_id,
                  x_return_status => l_return_status
		    );
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name||'.external_call.before',
                   'k_erase_approved x_return_status=>'||l_return_status);
 END IF;
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--+
  L_Q:='?';
  open abort_csr;
  fetch abort_csr into L_Q;
  close abort_csr;
--+
--+ if abort process defined
--+
  if (L_Q = '!') then
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Abort process defined ');
 END IF;
-- previous initiator Uname
    L_INITIATOR_NAME := wf_engine.GetItemAttrText(l_wf_name_active,L_KEY,'INITIATOR_NAME');
-- last approver Uname
    L_FINAL_APPROVER_UNAME := NVL(
	wf_engine.GetItemAttrText(l_wf_name_active,L_KEY,'NEXT_PERFORMER_USERNAME'),
	wf_engine.GetItemAttrText(l_wf_name_active,L_KEY,'FINAL_APPROVER_UNAME')
      );
    if (L_FINAL_APPROVER_UNAME = L_INITIATOR_NAME) then
	L_FINAL_APPROVER_UNAME := NULL;
    end if;
    begin
      --Bug#3096950 - wf_purge.total(l_wf_name_active,l_key);
      wf_purge.total(l_wf_name_active,l_key,runtimeonly=>TRUE);
    exception
    when others then
      begin
        --for Bug#3096950 - wf_purge.totalPerm(l_wf_name_active,l_key);
	   wf_purge.totalPerm(l_wf_name_active, l_key, runtimeonly=>TRUE);
      exception
        when others then
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_WF_NOT_PURGED,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => l_wf_name_active,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      end;
    end;
    wf_engine.CreateProcess( ItemType => l_wf_name_active,
				 ItemKey  => L_KEY,
				 process  => 'ABORT_PROCESS');
    wf_engine.SetItemUserKey (ItemType	=> l_wf_name_active,
					ItemKey		=> L_KEY,
					UserKey		=> L_KEY);
--+
--+ attributes
--+
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'CONTRACT_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION',
						avalue	=> L_K_SHORT_DESCRIPTION);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION',
						avalue	=> L_K_SHORT_DESCRIPTION);
    end;
-- current initiator Dname
    open C_INITIATOR_DISPLAY_NAME;
    fetch C_INITIATOR_DISPLAY_NAME into L_INITIATOR_DISPLAY_NAME;
    close C_INITIATOR_DISPLAY_NAME;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_DISPLAY_NAME',
						avalue	=> L_INITIATOR_DISPLAY_NAME);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_DISPLAY_NAME');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_DISPLAY_NAME',
						avalue	=> L_INITIATOR_DISPLAY_NAME);
    end;
-- previous initiator Uname
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_NAME',
						avalue	=> L_INITIATOR_NAME);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_NAME');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_NAME',
						avalue	=> L_INITIATOR_NAME);
    end;
-- previous approver Uname
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'FINAL_APPROVER_UNAME',
						avalue	=> L_FINAL_APPROVER_UNAME);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'FINAL_APPROVER_UNAME');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'FINAL_APPROVER_UNAME',
						avalue	=> L_FINAL_APPROVER_UNAME);
    end;
--
-- environment
--
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID');
	    wf_engine.SetItemAttrNumber(itemtype	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> fnd_global.SECURITY_GROUP_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> fnd_global.SECURITY_GROUP_id);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_FORMAT';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select '"'||value||'"' into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_NUMERIC_CHARACTERS';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    end;
--
-- start
--
    wf_engine.SetItemOwner (	itemtype => l_wf_name_active,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);
    wf_engine.StartProcess( 	itemtype => l_wf_name_active,
	      			itemkey  => L_KEY);

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Started Abort process successfully');
 END IF;
  end if;--+ abort process exists
--
-- Launch process workflow for existing service contracts created prior to r12 as they would not have process workflow associated
-- as they had been in the Approval node
--
  if l_scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION') THEN
    open k_process_csr(p_contract_id);
    fetch k_process_csr INTO l_wf_item_key;
    l_rownotfound := k_process_csr%NOTFOUND;
    CLOSE k_process_csr;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'l_wf_item_key=> '||l_wf_item_key);
 END IF;
    IF l_rownotfound OR l_wf_item_key IS NULL THEN
       l_wf_attributes.CONTRACT_ID := p_contract_id;
       l_wf_attributes.CONTRACT_NUMBER := l_contract_number;
       l_wf_attributes.CONTRACT_MODIFIER := l_contract_number_modifier;
       l_wf_attributes.NEGOTIATION_STATUS := 'ACT';
       l_wf_attributes.ITEM_KEY := p_contract_id||to_char(sysdate,'YYYYMMDDHH24MISS');
       l_wf_attributes.IRR_FLAG := 'Y';
       l_wf_attributes.PROCESS_TYPE := 'MANUAL';
       x_return_status := 'S';
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     ' OKS_WF_K_PROCESS_PVT.launch_k_process_wf p_contract_id '||p_contract_id);
   END IF;
       OKS_WF_K_PROCESS_PVT.launch_k_process_wf
              (
               p_api_version          => 1.0,
               p_init_msg_list        => 'T',
               p_wf_attributes        => l_wf_attributes,
               x_return_status        => l_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data
              ) ;
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKS_WF_K_PROCESS_PVT.launch_k_process_wf l_return_status=>'||l_return_status);
   END IF;
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       UPDATE oks_k_headers_b
       SET object_version_number = object_version_number + 1,
           wf_item_key = l_wf_attributes.ITEM_KEY,
           renewal_status = l_wf_attributes.NEGOTIATION_STATUS,
           last_update_date = SYSDATE,
           last_update_login = FND_GLOBAL.LOGIN_ID,
           Last_updated_by = FND_GLOBAL.USER_ID
       WHERE chr_id = l_wf_attributes.contract_id;
    ELSE
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'continue_k_process(p_contract_id=>'||p_contract_id||')');
   END IF;
      -- Complete the Service Contracts Process workflow
      continue_k_process
      (
       p_api_version    => l_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_contract_id    => p_contract_id,
       p_wf_item_key    => l_wf_item_key,
       p_called_from    => 'STOP'
      );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'continue_k_process(x_return_status=>'||x_return_status||')');
   END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
  END IF;
  if (p_do_commit = OKC_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end k_approval_stop;

-- Start of comments
--
-- Procedure Name  : wf_copy_env
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure wf_copy_env(	p_item_type varchar2,
				p_item_key varchar2) is
L_NLS_VALUE1 varchar2(40);
L_NLS_VALUE2 varchar2(40);
L_NLS_VALUE3 varchar2(40);
L_NLS_VALUE4 varchar2(40);
L_NLS_VALUE11 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_LANGUAGE');
L_NLS_VALUE12 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_DATE_FORMAT');
L_NLS_VALUE13 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_DATE_LANGUAGE');
L_NLS_VALUE14 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_NUMERIC_CHARACTERS');
cursor c1(p varchar2) is
  select value
  from NLS_SESSION_PARAMETERS
  where PARAMETER=p;
begin
    open c1('NLS_LANGUAGE');
    fetch c1 into L_NLS_VALUE1;
    close c1;
    open c1('NLS_DATE_FORMAT');
    fetch c1 into L_NLS_VALUE2;
    close c1;
    open c1('NLS_DATE_LANGUAGE');
    fetch c1 into L_NLS_VALUE3;
    close c1;
    open c1('NLS_NUMERIC_CHARACTERS');
    fetch c1 into L_NLS_VALUE4;
    L_NLS_VALUE4 := '"'||L_NLS_VALUE4||'"';
    close c1;
   if not(
	(L_NLS_VALUE11 = L_NLS_VALUE1) and
	(L_NLS_VALUE12 = L_NLS_VALUE2) and
	(L_NLS_VALUE13 = L_NLS_VALUE3) and
	(L_NLS_VALUE14 = L_NLS_VALUE4)
   ) then
    fnd_global.set_nls_context
    (
	P_NLS_LANGUAGE => L_NLS_VALUE11,
	P_NLS_DATE_FORMAT => L_NLS_VALUE12,
	P_NLS_DATE_LANGUAGE => L_NLS_VALUE13,
	P_NLS_NUMERIC_CHARACTERS => L_NLS_VALUE14);
  end if;
  fnd_global.apps_initialize
    (
	user_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'USER_ID'),
	resp_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'RESP_ID'),
	resp_appl_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'RESP_APPL_ID'),
	security_group_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'SECURITY_GROUP_ID')
  );
--  okc_context.set_okc_org_context;
end wf_copy_env;

-- Start of comments
--
-- Procedure Name  : k_accesible
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function k_accesible(
			p_contract_id IN number,
			p_user_id IN number,
			p_level IN varchar2
		     ) return varchar2 is
l_q varchar2(1);
/*
 cursor check_access_csr is
(select '!'
 from OKC_K_ACCESSES
 where chr_id = p_contract_id
 and user_id = p_user_id
 and (p_level='R' or access_level='U')
)
  UNION ALL
(select '!' from dual
 where exists
 (select agp_code
  from OKC_K_ACCESSES
  where chr_id = P_CONTRACT_ID
  and (p_level='R' or access_level='U')
    INTERSECT
  SELECT AGP_CODE
  FROM okc_acc_group_members
  where begin_date<=sysdate
   and (end_date is null or end_date>=sysdate)
  start with user_id = p_user_id
  CONNECT BY PRIOR AGP_CODE = AGP_CODE_COMPOSED_OF
 )
);
*/
begin
  l_q :=okc_util.get_k_access_level(p_chr_id => p_contract_id);
  if ((l_q = p_level) or (l_q = 'U'))
    then return OKC_API.G_TRUE;
    else return OKC_API.G_FALSE;
  end if;
/*
--
  open check_access_csr;
  fetch check_access_csr into l_q;
  close check_access_csr;
--

  if l_q = '?' then return OKC_API.G_FALSE;
  else return OKC_API.G_TRUE;
  end if;
*/

end k_accesible;

--
-- private procedure
-- to set context of db failure
--
procedure db_failed(p_oper varchar2) is
begin
      FND_MESSAGE.SET_NAME(application => G_APP_NAME,
                      	name     => 'OKC_DB_OPERATION_FAILED');
-- OKC_SIGN  OKC_APPROVE OKC_REVOKE
      FND_MESSAGE.SET_TOKEN(token => 'OPERATION',
                      	value     => p_oper,
				translate => TRUE);
      FND_MSG_PUB.add;
end db_failed;


-- Start of comments
--
-- Procedure Name  : k_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approved(
		p_contract_id IN number,
		p_date_approved IN date ,
		x_return_status OUT NOCOPY varchar2
	    ) is
L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
cursor lock_csr(p number) is
  	select object_version_number , org_id --mmadhavi added org_id for MOAC project
  	from okc_k_headers_all_b
  	where ID = p
;
l_api_name                     CONSTANT VARCHAR2(30) := 'k_approved';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
begin

--start
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKC_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--lock
  L1_header_rec.id := p_contract_id;
  open lock_csr(p_contract_id);
  fetch lock_csr into L1_header_rec.object_version_number, L1_header_rec.org_id;
  close lock_csr;

--npalepu 02-DEC-2005 modified for the bug # 4775848
--/Rules Migration/
--Set context before validation, new rules columns require context for validations
  OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_org_id => L1_header_rec.org_id) ;
--
--end npalepu

  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--update
  L1_header_rec.date_approved := p_date_approved;

--npalepu moved the context setting code to above the OKC_CONTRACT_PUB.lock_contract_header API.
--for bug # 4775848 on 02-DEC-2005.
/*--/Rules Migration/
--Set context before validation, new rules columns require context for validations
  OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_org_id => L1_header_rec.org_id) ;
--*/
--end npalepu

  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    p_init_msg_list     => OKC_API.G_TRUE,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_chrv_rec		=> L1_header_rec,
    x_chrv_rec		=> L2_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--end
  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
	 db_failed('OKC_APPROVE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	 db_failed('OKC_APPROVE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
	 db_failed('OKC_APPROVE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
end k_approved;

-- Start of comments
--
-- Procedure Name  : k_erase_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_erase_approved(
			p_contract_id IN number,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
dummy varchar2(1) := '?';
cursor c1 is
  select '!'
  from okc_k_headers_all_b
  where ID = p_contract_id and date_approved is not null;
--
cursor lock_csr(p number) is
  	select object_version_number
  	from okc_k_headers_all_b
  	where ID = p
;
l_api_name                     CONSTANT VARCHAR2(30) := 'k_erase_approved';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
begin

--check if do anything
  open c1;
  fetch c1 into dummy;
  close c1;
  if (dummy = '?') then
	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	return;
  end if;

--start
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKC_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--lock
  L1_header_rec.id := p_contract_id;
  open lock_csr(p_contract_id);
  fetch lock_csr into L1_header_rec.object_version_number;
  close lock_csr;
  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--update
  L1_header_rec.date_approved := NULL;
  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_chrv_rec		=> L1_header_rec,
    x_chrv_rec		=> L2_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--end
  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
	 db_failed('OKC_REVOKE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	 db_failed('OKC_REVOKE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
	 db_failed('OKC_REVOKE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
end k_erase_approved;

-- Start of comments
--
-- Procedure Name  : k_signed
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_signed(
               p_contract_id        IN        number,
               p_date_signed        IN        date     default sysdate,
               p_complete_k_prcs    IN        VARCHAR2 default 'Y',
               x_return_status     OUT NOCOPY VARCHAR2
		    ) is
l_api_name                     CONSTANT VARCHAR2(30) := 'k_signed';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);

L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
--Bug:3675868 fetch sts_code to set L1_header_rec.old_sts_code
cursor lock_csr(p number) is
  	select object_version_number, START_DATE, END_DATE, sts_code, scs_code
  	from okc_k_headers_all_b
  	where ID = p
;
--
l_new_status varchar2(30);
l_signed_status varchar2(30);
l_active_status varchar2(30);
l_expired_status varchar2(30);
l_scs_code       VARCHAR2(30);
l_sysdate           DATE;

cursor c1 is
  select code from okc_statuses_b
  where ste_code='SIGNED'
    and default_yn='Y';
cursor c2 is
  select code from okc_statuses_b
  where ste_code='ACTIVE'
    and default_yn='Y';
cursor c3 is
  select code from okc_statuses_b
  where ste_code='EXPIRED'
    and default_yn='Y';
--
cursor lock1_csr is
  	select L.ID ID, L.object_version_number
,decode(sign(months_between(sysdate-1, NVL(L.end_date,sysdate))),-1,
  decode(sign(months_between(p_date_signed-1,sysdate)),-1,
    decode(sign(months_between(L.start_date-1,sysdate)),-1,
	l_active_status,l_signed_status),l_signed_status),l_expired_status) STS_CODE
from okc_k_lines_b L
	, okc_statuses_b S
  	where L.dnz_chr_id = p_contract_id
	and S.code = L.sts_code
	and S.ste_code='ENTERED'
;
--
loc1_rec lock1_csr%ROWTYPE;
i number :=0;
--
l1_lines okc_contract_pub.clev_tbl_type;
l2_lines okc_contract_pub.clev_tbl_type;
l3_lines okc_contract_pub.clev_tbl_type;
--
call_time varchar2(1);

begin
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
--start
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKC_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
			    'OKC_API.START_ACTIVITY return status '||l_return_status);
 END IF;

--npalepu added on 02-DEC-2005 for bug # 4775848 to set the context.
  OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_chr_id => p_contract_id) ;
--end npalepu

--lock header
  L1_header_rec.id := p_contract_id;
  open lock_csr(p_contract_id);
--Bug:3675868 fetch sts_code into L1_header_rec.old_sts_code
  fetch lock_csr into
     L1_header_rec.object_version_number,L1_header_rec.START_DATE,L1_header_rec.END_DATE,L1_header_rec.old_sts_code,l_scs_code;
  close lock_csr;
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     ' OKC_CONTRACT_PUB.lock_contract_header');
   END IF;
  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     ' OKC_CONTRACT_PUB.lock_contract_header(x_return_status=>'||x_return_status||')');
   END IF;
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--update header
  L1_header_rec.date_signed := p_date_signed;
--
  open c1;
  fetch c1 into l_signed_status;
  close c1;
--
  open c2;
  fetch c2 into l_active_status;
  close c2;
--
  open c3;
  fetch c3 into l_expired_status;
  close c3;
--
  l_new_status := l_signed_status; call_time := 'Y';
  if (L1_header_rec.date_signed <= sysdate
	and L1_header_rec.START_DATE <= sysdate
	and (L1_header_rec.END_DATE is NULL or sysdate<=L1_header_rec.END_DATE+1)) then
    l_new_status := l_active_status; call_time := 'Y';
  end if;
  if (sysdate>L1_header_rec.END_DATE+1) then
    l_new_status := l_expired_status; call_time := 'N';
  end if;

--Bug:3675868 set L1_header_rec.old_ste_code
  select ste_code
  into L1_header_rec.old_ste_code
  from okc_statuses_b
  where code = L1_header_rec.old_sts_code;

--Bug:3675868 set L1_header_rec.new_ste_code
  select ste_code
  into L1_header_rec.new_ste_code
  from okc_statuses_b
  where code = l_new_status;

--Bug:3675868 set L1_header_rec.new_sts_code
  L1_header_rec.new_sts_code := l_new_status;

  L1_header_rec.STS_CODE := l_new_status;

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                    'OKC_CONTRACT_PUB.update_contract_header');
   END IF;
  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_chrv_rec		=> L1_header_rec,
    x_chrv_rec		=> L2_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKC_CONTRACT_PUB.update_contract_header(x_return_status=>'||x_return_status||')');
   END IF;



   --Bug 5442886, for service contracts use different logic for performance reasons
   IF (l_scs_code IN ('SERVICE', 'WARRANTY', 'SUBSCRIPTION')) THEN

            --for service contracts directly update the status of all lines in the contract
            --using the exact same logic to derive sts_code

            --Note: When we call OKC_CONTRACT_PUB.update_contract_line, there is some logic
            --inside it to call OKC_KL_STS_CHG_ASMBLR_PVT.Acn_Assemble, action assembler
            --for line status change. However, currently this call is not made because
            --we never pass values for old/new sts/ste_code.

            --Bug 3675868, fixes this issue for the header, but there is no corresponding
            --fix for the lines, meaning customers have been signing contracts without the
            --line level status change action assembler being called. So, we are leaving the
            --call to this action assembler for the time being. If ever we do need to make a call
            --we should anyway check for OKC_K_SIGN_ASMBLR_PVT.isActionEnabled as per bug 4033775
            --before making that call.

            l_sysdate := SYSDATE;

            IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT, G_MODULE || l_api_name || '.direct_line_status_change',
                               'updating line status');
            END IF;
            /*modified for bug8530862*/
            UPDATE (SELECT l.sts_code, l.start_date, l.end_date, l.last_update_date, l.last_update_login, l.Last_updated_by
                    FROM okc_k_lines_b l, okc_statuses_b s
                    WHERE l.dnz_chr_id = p_contract_id
                    AND s.code = l.sts_code
                    AND s.ste_code = 'ENTERED') oks
            SET
                oks.sts_code =
                    decode( sign(months_between(l_sysdate - 1, NVL(oks.end_date, l_sysdate))),
                        -1, decode(sign(months_between(p_date_signed - 1, l_sysdate)),
                            -1, decode(sign(months_between(oks.start_date - 1, l_sysdate)),
                                -1, l_active_status, l_signed_status), l_signed_status), l_expired_status),
                oks.last_update_date = l_sysdate,
                oks.last_update_login = FND_GLOBAL.LOGIN_ID,
                oks.last_updated_by = FND_GLOBAL.USER_ID;

            IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT, G_MODULE || l_api_name || '.direct_line_status_change',
                               'done line status update');
            END IF;


   ELSE

            --for all other contracts use existing logic

            -- lock lines
            for lock1_rec in lock1_csr LOOP
          	i := i+1;
	          l1_lines(i).id := lock1_rec.id;
          	l1_lines(i).object_version_number := lock1_rec.object_version_number;
--
          	l2_lines(i).id := lock1_rec.id;
          	l2_lines(i).object_version_number := lock1_rec.object_version_number;
          	l2_lines(i).sts_code := lock1_rec.sts_code;
            end LOOP;
            OKC_CONTRACT_PUB.lock_contract_line(
              p_api_version		=> l_api_version,
              x_return_status	=> x_return_status,
              x_msg_count		=> l_msg_count,
              x_msg_data		=> l_msg_data,
              p_clev_tbl    	=> l1_lines);
            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKC_CONTRACT_PUB.update_contract_line');
            END IF;
            -- update lines
           OKC_CONTRACT_PUB.update_contract_line(
               p_api_version		=> l_api_version,
               x_return_status	=> x_return_status,
               x_msg_count		=> l_msg_count,
               x_msg_data		=> l_msg_data,
               p_restricted_update	=> OKC_API.G_TRUE,
               p_clev_tbl => l2_lines,
               x_clev_tbl => l3_lines);
              IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                                'OKC_CONTRACT_PUB.update_contract_line(x_return_status=>'||x_return_status||')');
              END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

   END IF; --of IF (L1_header_rec.scs_code IN ('SERVICE', 'WARRANTY', 'SUBSCRIPTION')) THEN



/* Commented for bug 5069035. Not used in R12 and commenting out to avoid performance overhead.
-- call time ...
   if (call_time = 'Y') then
     OKC_TIME_RES_PUB.Res_Time_New_K(L2_header_rec.id, l_api_version,OKC_API.G_FALSE,x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
   end if;
*/

-- Call to Price Hold API to create QP entries If there are any Price Hold Information on contract

  IF l_new_status = l_active_status OR
     l_new_status = l_signed_status THEN


     --Bug 5442886, for service contracts no need to process price holds
	IF (l_scs_code IN ('SERVICE', 'WARRANTY', 'SUBSCRIPTION')) THEN

	   --do nothing
        NULL;
     ELSE

        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKC_PHI_PVT.process_price_hold(p_chr_id=>'||p_contract_id||')');
        END IF;

        OKC_PHI_PVT.process_price_hold(p_api_version     => l_api_version
                                   ,p_init_msg_list   => OKC_API.G_FALSE
                                   ,p_chr_id          => p_contract_id
                                   ,p_operation_code  => 'UPDATE'
							,p_termination_date => Null
                                   ,x_return_status   => x_return_status
                                   ,x_msg_count       => l_msg_count
                                   ,x_msg_data        => l_msg_data);
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                          'OKC_PHI_PVT.process_price_hold(x_return_status=>'||x_return_status||')');
        END IF;

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
	END IF;

  END IF;

-- End ** Call to Price Hold API to create QP entries If there are any Price Hold Information on contract

   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'OKC_K_SIGN_ASMBLR_PVT.acn_assemble(p_contract_id=>'||x_return_status||')');
   END IF;
-- raise event
  OKC_K_SIGN_ASMBLR_PVT.acn_assemble(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_contract_id     	=> p_contract_id);
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'OKC_K_SIGN_ASMBLR_PVT.acn_assemble(x_return_status=>'||x_return_status||')');
   END IF;
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--end

  IF l_scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')  AND p_complete_k_prcs = 'Y' THEN
    -- Complete the Service Contracts Process workflow if applicable
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                     'continue_k_process(p_contract_id=>'||p_contract_id||')');
   END IF;
    continue_k_process
    (
     p_api_version    => l_api_version,
     p_init_msg_list  => OKC_API.G_FALSE,
     x_return_status  => x_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data,
     p_contract_id    => p_contract_id,
     p_wf_item_key    => NULL,
     p_called_from    => 'APPROVE'
    );
   IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                     'continue_k_process(x_return_status=>'||x_return_status||')');
   END IF;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
	 db_failed('OKC_SIGN');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	 db_failed('OKC_SIGN');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
	 db_failed('OKC_SIGN');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
end k_signed;

-- Procedure Name  : Activate_Template
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure activate_template (
			p_contract_id   IN number,
         x_return_status OUT NOCOPY	VARCHAR2 ) is
--
l_api_name                     CONSTANT VARCHAR2(30) := 'activate_template';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
--
L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;

cursor lock_csr is
  	select object_version_number
  	from okc_k_headers_all_b
  	where ID = p_contract_id;
--
l_active_status varchar2(30) := 'ACTIVE';

begin

  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKC_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  --lock header
  L1_header_rec.id := p_contract_id;
  open lock_csr;
  fetch lock_csr into
	L1_header_rec.object_version_number;
  close lock_csr;
  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;



  L1_header_rec.STS_CODE := l_active_status;

  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		   => l_api_version,
    x_return_status	   => x_return_status,
    x_msg_count	      => l_msg_count,
    x_msg_data		      => l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_chrv_rec		      => L1_header_rec,
    x_chrv_rec		      => L2_header_rec);

  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);

EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);

end activate_template;

end OKC_CONTRACT_APPROVAL_PVT;

/
