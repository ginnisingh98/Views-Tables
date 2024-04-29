--------------------------------------------------------
--  DDL for Package Body OKC_OKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OKS_PUB" as
/* $Header: OKCPOKSB.pls 120.1 2006/02/17 05:26:37 hkamdar noship $ */

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  OKS_UPDATE_CONTRACT
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_from_id          NUMBER   - Id of the Old Parent
   --     p_to_id            NUMBER   - Id of the New Parent
   --   OUT:
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   End of Comments
   --

PROCEDURE OKS_UPDATE_CONTRACT
(    p_from_id           in  hz_merge_parties.from_party_id%type,
     p_to_id             in  hz_merge_parties.to_party_id%type,
     x_return_status     out  nocopy varchar2)
IS
 l_proc_name  varchar2(30) := 'OKS_UPDATE_CONTRACT';
 g_api_name   varchar2(30) := 'OKC_OKS_PUB';
   -- Cursor to get all the ext warr. contracts originated from order

--Modified cursor for bug 4104671
   CURSOR l_get_contracts_csr
   IS
   	SELECT hdr.id, contract_number
     FROM okc_k_headers_b      hdr,
          okc_k_party_roles_b pty
     WHERE hdr.id=pty.chr_id
    AND pty.rle_code='CUSTOMER'
    AND pty.object1_id1= to_char(p_to_id)
    AND hdr.id IN (SELECT DISTINCT (dnz_chr_id)
                   FROM okc_k_lines_b lin
                   WHERE upg_orig_system_ref = 'ORDER'
                   AND lse_id IN (14, 19)
                   AND pty.dnz_chr_id = lin.chr_id);

   -- Cursor to get party name

   CURSOR l_get_custname_csr (p_chr_id NUMBER)
   IS
      SELECT party.NAME
      FROM okc_k_party_roles_v prole,
           okx_parties_v party
      WHERE party.id1 = prole.object1_id1
	 -- hkamdar 17-Feb-2006 Bug # 5012249
	   AND prole.dnz_chr_id = p_chr_id
--      AND prole.chr_id = p_chr_id
      AND prole.cle_id IS NULL
      AND prole.rle_code IN ('CUSTOMER', 'SUBSCRIBER');

   l_chr_id       		NUMBER;
   l_party_name   		VARCHAR2 (240);
   l_chrv_tbl_in            	okc_contract_pub.chrv_tbl_type;
   l_chrv_tbl_out           	okc_contract_pub.chrv_tbl_type;
   l_api_version      		NUMBER:= 1;
   l_init_msg_list    		VARCHAR2(2000);
   l_return_status    		VARCHAR2(1);
   l_msg_count        		NUMBER;
   l_msg_data         		VARCHAR2(2000);
   l_index              	NUMBER;
BEGIN
l_index :=1;
FOR l_get_contracts_rec IN l_get_contracts_csr
LOOP
  OPEN l_get_custname_csr (l_get_contracts_rec.id);
  FETCH l_get_custname_csr INTO l_party_name;
  CLOSE l_get_custname_csr;
  l_chrv_tbl_in(l_index).id                    := l_get_contracts_rec.id;
  l_chrv_tbl_in(l_index).sfwt_flag             := 'N';
  l_chrv_tbl_in(l_index).short_description     :=  'CUSTOMER : '|| l_party_name|| ' Warranty/Extended Warranty Contract';
  l_index :=l_index+1;
END LOOP;
okc_contract_pub.update_contract_header (
     p_api_version  	=> l_api_version,
     p_init_msg_list  	=> l_init_msg_list,
     x_return_status  	=> l_return_status,
     x_msg_count  	=> l_msg_count,
     x_msg_data  	=> l_msg_data,
     p_restricted_update     => 'F',
     p_chrv_tbl  	=> l_chrv_tbl_in,
     x_chrv_tbl  	=> l_chrv_tbl_out
    );
EXCEPTION
     when OTHERS then
      arp_message.set_line(g_api_name||'.'||l_proc_name||': '||sqlerrm);
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      raise;

END OKS_UPDATE_CONTRACT;

--   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  IS_RENEW_ALLOWED
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_chr_id           NUMBER   - Contract id
   --   OUT:
   --     x_return_status    VARCHAR2 - Return the status of the procedure
   --
   --   End of Comments
   --

/*
 * A source contract is allowed to be renewed if it the status is in
 * ('ACTIVE','EXPIRED','SIGNED') and at least one sub line has not
 * been consolidated/renewed.
*/
FUNCTION Is_Renew_Allowed(p_chr_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2)
         RETURN BOOLEAN IS

l_can_renew boolean := true;
l_hdr_status VARCHAR2(30);
l_k VARCHAR2(255);
l_mod okc_k_headers_b.contract_number_modifier%TYPE;

-- Bug 3280617
CURSOR c_chr(p_chr_id number) is
select contract_number, contract_number_modifier
from okc_k_headers_b
where id = p_chr_id;

cursor get_source_status(l_chr_id number) is
select a.sts_code
from okc_k_headers_b a, okc_statuses_b b
where a.id = l_chr_id and a.sts_code = b.code
and  b.ste_code in ('ACTIVE','EXPIRED','SIGNED');

 -- Gets all the sublines of the source contract.
Cursor get_sublines(l_chr_id number) is
select a.id, a.lse_id
from okc_k_lines_b a, okc_statuses_b b
where a.cle_id is not null and a.dnz_chr_id = l_chr_id
and a.lse_id in (7,8,9,10,11,18,25,35) and a.sts_code = b.code --Bug 3453752
and  b.ste_code in ('ACTIVE','EXPIRED','SIGNED');


-- If all the sublines are source lines for other contracts then do not consolidate.
Cursor is_consolidated(l_cle_id number) is
select a.object_cle_id
FROM okc_operation_lines a,okc_operation_instances  b,
 okc_class_operations c
 where a.object_chr_id=p_chr_id
 and c.id=b.cop_id
 and c.opn_code in ('REN_CON')
 and b.id=a.oie_id
 and a.subject_cle_id is not null
 and a.subject_chr_id is not null
 and a.process_flag = 'P'
 and a.object_cle_id = l_cle_id;

l_target_id number;
Begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- Bug 3280617
    OPEN c_chr(p_chr_id);
    FETCH c_chr INTO l_k, l_mod;
    CLOSE c_chr;

    IF(l_mod is NULL) and (l_mod <> OKC_API.G_MISS_CHAR) then
     l_k := l_k ||'-'||l_mod;
    END IF;

    -- Check headers status ------
    Open get_source_status(p_chr_id);
    Fetch get_source_status into l_hdr_status;
    If get_source_status%NOTFOUND Then
       -- Bug 3280617
       OKC_API.set_message(p_app_name => g_app_name,
                           p_msg_name => 'OKC_INVALID_STS',
                           p_token1   => 'component',
                           p_token1_value => l_k);
       return false;
    End If;
    Close get_source_status;

    --- Go through each sub line and see if there's at least one sub line
    -- that has not been consolidated.
 	For get_sublines_rec in get_sublines(p_chr_id)
    	Loop
        	Open is_consolidated(get_sublines_rec.id);
        	Fetch is_consolidated into l_target_id;
        	If is_consolidated%NOTFOUND Then
            		Close is_consolidated;
            		l_can_renew := true;
            		Exit;
        	Else
            		l_can_renew := false;
        	End If;
        	Close is_consolidated;
 	End Loop;

        -- Bug 3408853
        -- Bug 3482145 Setting the error message outside the For loop if l_can_renew is false
        -- to prevent the error message getting displayed multiple times.
        if not l_can_renew then
           OKC_API.set_message(p_app_name => g_app_name,
                               p_msg_name => 'OKC_K_RENEW_CONSOLIDATED');
        end if;
    Return l_can_renew;

EXCEPTION
        WHEN    Others  THEN
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             OKC_API.set_message
               (
                G_APP_NAME,
                G_UNEXPECTED_ERROR,
                G_SQLCODE_TOKEN,
                SQLCODE,
                G_SQLERRM_TOKEN,
                SQLERRM
               );
            Return l_can_renew;

End Is_Renew_Allowed;

/* Bug 3584224
1. Checks if contract is Service, Warranty or Subscription
2. Check if all sub lines are terminated. Returns false if all sub lines
are terminated.
*/
FUNCTION VALIDATE_OKS_LINES(p_chr_id        IN  NUMBER
                            ) RETURN VARCHAR2 IS

l_chr_id number;
l_line_id number;
l_sub_line_id number;
l_return_flag varchar2(1) := OKC_API.G_TRUE;

cursor check_contr_type(l_chr_id number) is
select id
from okc_k_headers_b
where scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION') and id = l_chr_id;


cursor get_subscr_toplines(l_chr_id number) is
select id
from okc_k_lines_b
where dnz_chr_id = l_chr_id and chr_id is not null
and lse_id = 46
and (date_terminated is null or date_terminated >= sysdate);

-- if it doensn't return anything then all sub lines are terminated.
cursor get_sub_lines(l_chr_id number) is
select id
from okc_k_lines_b
where dnz_chr_id = l_chr_id and cle_id is not null
and lse_id in (7, 8, 9, 10, 11, 13, 18, 25, 35)
and date_terminated is null;


begin
    -- If contract is not an OKS contract then no need for further checks.
    Open check_contr_type(p_chr_id);
    Fetch check_contr_type into l_chr_id;
        If check_contr_type%NOTFOUND Then
            Close check_contr_type;
            return OKC_API.G_TRUE;
        End If;
    Close check_contr_type;


    Open get_sub_lines(p_chr_id);
    Fetch get_sub_lines into l_sub_line_id;
    If get_sub_lines%NOTFOUND Then
        -- If contract has at least one subscription line then it's okay if it doens't
        -- have any sub lines.
            Open get_subscr_toplines(l_chr_id);
            Fetch get_subscr_toplines into l_line_id;
            If get_subscr_toplines%FOUND Then
                l_return_flag := OKC_API.G_TRUE;
            Else
                OKC_API.set_message(p_app_name => g_app_name,
          		                    p_msg_name => 'OKC_LINES_SUBLINES_TERMINATED');
                l_return_flag := OKC_API.G_FALSE;
             End If;
             Close get_subscr_toplines;
    End If;
    Close get_sub_lines;


  return l_return_flag;

EXCEPTION
        WHEN    Others  THEN
             l_return_flag := OKC_API.G_FALSE;
             OKC_API.set_message
               (
                G_APP_NAME,
                G_UNEXPECTED_ERROR,
                G_SQLCODE_TOKEN,
                SQLCODE,
                G_SQLERRM_TOKEN,
                SQLERRM
               );

 return l_return_flag;

End VALIDATE_OKS_LINES;

END OKC_OKS_PUB;

/
