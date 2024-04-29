--------------------------------------------------------
--  DDL for Package Body OKS_AUTH_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_AUTH_INT_PUB" AS
/* $Header: OKSPAITB.pls 120.1 2005/10/13 16:47:32 tweichen noship $*/

Function Check_For_Active_Process
                  (p_contract_number          VARCHAR2
                  ,p_contract_number_modifier VARCHAR2
                  )Return Boolean
IS
  l_wf_name  VARCHAR2(150);
  l_wf_process_name VARCHAR2(150);
  l_package_name VARCHAR2(150);
  l_procedure_name  VARCHAR2(150);
  l_usage  VARCHAR2(150);
  l_api_version  CONSTANT NUMBER := 1.0;
  l_init_msg_list CONSTANT VARCHAR2(1) := 'T';
  l_return_status   VARCHAR2(1);
  l_msg_count    NUMBER;
  l_msg_data    VARCHAR2(2000);
  l_contract_number          VARCHAR2 (120);
  l_contract_number_modifier VARCHAR2 (120);

Begin

  OKC_CONTRACT_PUB.Get_Active_Process (
          p_api_version                 => l_api_version,
          p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data,
          p_contract_number             => l_contract_number,
          p_contract_number_modifier    => l_contract_number_modifier,
          x_wf_name                     => l_wf_name,
          x_wf_process_name             => l_wf_process_name,
          x_package_name                => l_package_name,
          x_procedure_name              => l_procedure_name,
          x_usage                       => l_usage);

  If NVL(l_return_status, '*') = 'S' then
     If l_wf_name IS NOT NULL then
        Return(TRUE);
     Else
        Return(FALSE);
     End If;
  Else
     Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End if;
End Check_For_Active_Process;


FUNCTION ok_to_commit    (p_api_version             IN  NUMBER
                         ,p_init_msg_list           IN  VARCHAR2
                         ,p_doc_id                  IN  NUMBER
                         ,p_doc_validation_string   IN  VARCHAR2
                         ,x_return_status           OUT NOCOPY VARCHAR2
                         ,x_msg_count               OUT NOCOPY NUMBER
                         ,x_msg_data                OUT NOCOPY VARCHAR2
                         )RETURN BOOLEAN
  IS

  --
  CURSOR hdr_details_cur (p_doc_id   IN NUMBER )
  IS
  SELECT  id,
          start_date,
          contract_number,
          contract_number_modifier,
          object_version_number,
          sts_code
  FROM
          okc_k_headers_all_b
  WHERE
          document_id = p_doc_id;
  --
  l_header_details hdr_details_cur%ROWTYPE;
  l_access_mode              VARCHAR2 (40);
  l_doc_id                   NUMBER;
  l_doc_number               VARCHAR2 (40);
  l_doc_version_no           NUMBER;
  l_doc_type                 VARCHAR2 (3) := 'OKS';
  l_doc_validation_string    VARCHAR2(2000);
  l_commit                   BOOLEAN := FALSE;

  l_api_version              Number      := 1.0;
  l_init_msg_list            Varchar2(1) := 'F';
  l_msg_count                Number;
  l_msg_data                 Varchar2(2000);
  l_return_status            Varchar2(1) := 'S';
  l_sts_code                 VARCHAR2(30);
  l_ste_code                 VARCHAR2(30);
  l_contract_number_modifier VARCHAR2(120);
  l_active_process           VARCHAR2(1);
  l_chr_id                   number;


BEGIN
  OPEN  hdr_details_cur(p_doc_id);
  FETCH hdr_details_cur INTO l_header_details;
    If hdr_details_cur%Notfound then
       Close hdr_details_cur;
       x_return_status := 'E';
       RAISE G_EXCEPTION_HALT_VALIDATION;
    Else
       CLOSE hdr_details_cur;
    End If;

    l_chr_id         := p_doc_id;
    l_doc_version_no := l_header_details.object_version_number;
    l_doc_number     := l_header_details.contract_number;
    l_sts_code       := l_header_details.sts_code;
    l_ste_code       := oks_extwar_util_pub.get_ste_code(p_sts_code => l_sts_code);
    l_contract_number_modifier := l_header_details.contract_number_modifier;

    IF NOT Check_For_Active_Process
                  (p_contract_number          => l_doc_number
                  ,p_contract_number_modifier => l_contract_number_modifier
                  ) then
       l_active_process := 'N';
    End If;

--l_doc_validation_string := ('ste code || ':' 'active process?'||':'||'can commit?'');
  l_doc_validation_string := (l_ste_code || '-' || l_active_process);

  If l_doc_validation_string = p_doc_validation_string then
     l_commit := TRUE;
  End If;

  return l_commit;
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    RETURN(null);

    WHEN OTHERS then
    RETURN(null);
    x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME_OKS, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END ok_to_commit;





END OKS_AUTH_INT_PUB;

/
