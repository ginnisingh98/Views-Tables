--------------------------------------------------------
--  DDL for Package Body OKC_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TEST" as
/* $Header: OKCTESTB.pls 115.7 2002/02/06 01:04:46 pkm ship       $ */


PROCEDURE upd_comments(p_api_version    IN NUMBER,
		       p_init_msg_list  IN VARCHAR2,
		       p_old_kid        IN NUMBER,
	  	       p_new_k_number   IN VARCHAR2,
	  	       p_new_k_modifier IN VARCHAR2,
		       p_comments       IN VARCHAR2,
		       x_msg_count     OUT NUMBER,
		       x_msg_data      OUT VARCHAR2,
		       x_return_status OUT VARCHAR2) IS
 CURSOR k_cur IS
 SELECT
   ID
   ,OBJECT_VERSION_NUMBER
   ,SFWT_FLAG
   ,CHR_ID_RESPONSE
   ,CHR_ID_AWARD
--   ,CHR_ID_RENEWED              obsolete
   ,INV_ORGANIZATION_ID
   ,STS_CODE
   ,QCL_ID
   ,SCS_CODE
   ,CONTRACT_NUMBER
   ,CURRENCY_CODE
   ,CONTRACT_NUMBER_MODIFIER
   ,ARCHIVED_YN
   ,DELETED_YN
   ,CUST_PO_NUMBER_REQ_YN
   ,PRE_PAY_REQ_YN
   ,CUST_PO_NUMBER
   ,SHORT_DESCRIPTION
   ,COMMENTS
   ,DESCRIPTION
   ,DPAS_RATING
   ,COGNOMEN
   ,TEMPLATE_YN
   ,TEMPLATE_USED
   ,DATE_APPROVED
   ,DATETIME_CANCELLED
   ,AUTO_RENEW_DAYS
   ,DATE_ISSUED
   ,DATETIME_RESPONDED
   ,NON_RESPONSE_REASON
   ,NON_RESPONSE_EXPLAIN
   ,RFP_TYPE
   ,CHR_TYPE
   ,KEEP_ON_MAIL_LIST
   ,SET_ASIDE_REASON
   ,SET_ASIDE_PERCENT
   ,RESPONSE_COPIES_REQ
   ,DATE_CLOSE_PROJECTED
   ,DATETIME_PROPOSED
   ,DATE_SIGNED
   ,DATE_TERMINATED
   ,DATE_RENEWED
   ,TRN_CODE
   ,START_DATE
   ,END_DATE
   ,AUTHORING_ORG_ID
   ,BUY_OR_SELL
   ,ISSUE_OR_RECEIVE
   ,ESTIMATED_AMOUNT
--    ,CHR_ID_RENEWED_TO        -- obsolete
   ,ESTIMATED_AMOUNT_RENEWED
   ,CURRENCY_CODE_RENEWED
   ,UPG_ORIG_SYSTEM_REF
   ,UPG_ORIG_SYSTEM_REF_ID
   ,ATTRIBUTE_CATEGORY
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
FROM   okc_k_headers_v
WHERE  id = p_old_kid;
 l_chrv_rec  OKC_CONTRACT_PUB.chrv_rec_type;
v_chrv_rec  k_cur%ROWTYPE;
 x_chrv_rec  OKC_CONTRACT_PUB.chrv_rec_type;
 l_return_status   varchar2(1) := 'S';
 l_msg_count       number;
 l_msg_data        varchar2(2000);
BEGIN
  OPEN k_cur;
  FETCH k_cur INTO v_chrv_rec;
  v_chrv_rec.comments:=v_chrv_rec.comments||p_comments||
                       ': New Contract Number/Modifier are : '||p_new_k_number||'/'||p_new_k_modifier;
  l_chrv_rec.ID := v_chrv_rec.ID;
  l_chrv_rec.OBJECT_VERSION_NUMBER := v_chrv_rec.OBJECT_VERSION_NUMBER;
  l_chrv_rec.SFWT_FLAG := v_chrv_rec.SFWT_FLAG;
  l_chrv_rec.CHR_ID_RESPONSE := v_chrv_rec.CHR_ID_RESPONSE;
  l_chrv_rec.CHR_ID_AWARD := v_chrv_rec.CHR_ID_AWARD;
--  l_chrv_rec.CHR_ID_RENEWED := v_chrv_rec.CHR_ID_RENEWED;
  l_chrv_rec.INV_ORGANIZATION_ID := v_chrv_rec.INV_ORGANIZATION_ID;
  l_chrv_rec.STS_CODE := v_chrv_rec.STS_CODE;
  l_chrv_rec.CONTRACT_NUMBER := v_chrv_rec.CONTRACT_NUMBER;
  l_chrv_rec.CURRENCY_CODE := v_chrv_rec.CURRENCY_CODE;
  l_chrv_rec.CONTRACT_NUMBER_MODIFIER := v_chrv_rec.CONTRACT_NUMBER_MODIFIER;
  l_chrv_rec.ARCHIVED_YN := v_chrv_rec.ARCHIVED_YN;
  l_chrv_rec.DELETED_YN := v_chrv_rec.DELETED_YN;
  l_chrv_rec.CUST_PO_NUMBER_REQ_YN := v_chrv_rec.CUST_PO_NUMBER_REQ_YN;
  l_chrv_rec.PRE_PAY_REQ_YN := v_chrv_rec.PRE_PAY_REQ_YN;
  l_chrv_rec.CUST_PO_NUMBER := v_chrv_rec.CUST_PO_NUMBER;
  l_chrv_rec.SHORT_DESCRIPTION := v_chrv_rec.SHORT_DESCRIPTION;
  l_chrv_rec.COMMENTS  := v_chrv_rec.COMMENTS ;
  l_chrv_rec.DESCRIPTION := v_chrv_rec.DESCRIPTION;
  l_chrv_rec.DPAS_RATING := v_chrv_rec.DPAS_RATING;
  l_chrv_rec.COGNOMEN := v_chrv_rec.COGNOMEN;
  l_chrv_rec.TEMPLATE_YN := v_chrv_rec.TEMPLATE_YN;
  l_chrv_rec.TEMPLATE_USED := v_chrv_rec.TEMPLATE_USED;
  l_chrv_rec.DATE_APPROVED:= v_chrv_rec.DATE_APPROVED;
  l_chrv_rec.DATETIME_CANCELLED := v_chrv_rec.DATETIME_CANCELLED;
  l_chrv_rec.AUTO_RENEW_DAYS := v_chrv_rec.AUTO_RENEW_DAYS;
  l_chrv_rec.DATE_ISSUED := v_chrv_rec.DATE_ISSUED;
  l_chrv_rec.DATETIME_RESPONDED := v_chrv_rec.DATETIME_RESPONDED;
  l_chrv_rec.NON_RESPONSE_REASON := v_chrv_rec.NON_RESPONSE_REASON;
  l_chrv_rec.NON_RESPONSE_EXPLAIN := v_chrv_rec.NON_RESPONSE_EXPLAIN;
  l_chrv_rec.RFP_TYPE := v_chrv_rec.RFP_TYPE;
  l_chrv_rec.CHR_TYPE := v_chrv_rec.CHR_TYPE;
  l_chrv_rec.KEEP_ON_MAIL_LIST := v_chrv_rec.KEEP_ON_MAIL_LIST;
  l_chrv_rec.SET_ASIDE_REASON := v_chrv_rec.SET_ASIDE_REASON;
  l_chrv_rec.SET_ASIDE_PERCENT := v_chrv_rec.SET_ASIDE_PERCENT;
  l_chrv_rec.RESPONSE_COPIES_REQ := v_chrv_rec.RESPONSE_COPIES_REQ;
  l_chrv_rec.DATE_CLOSE_PROJECTED := v_chrv_rec.DATE_CLOSE_PROJECTED;
  l_chrv_rec.DATETIME_PROPOSED := v_chrv_rec.DATETIME_PROPOSED;
  l_chrv_rec.DATE_SIGNED := v_chrv_rec.DATE_SIGNED;
  l_chrv_rec.DATE_TERMINATED := v_chrv_rec.DATE_TERMINATED;
  l_chrv_rec.DATE_RENEWED := v_chrv_rec.DATE_RENEWED;
  l_chrv_rec.TRN_CODE := v_chrv_rec.TRN_CODE;
  l_chrv_rec.START_DATE := v_chrv_rec.START_DATE;
  l_chrv_rec.END_DATE := v_chrv_rec.END_DATE;
  l_chrv_rec.AUTHORING_ORG_ID := v_chrv_rec.AUTHORING_ORG_ID;
  l_chrv_rec.BUY_OR_SELL := v_chrv_rec.BUY_OR_SELL;
  l_chrv_rec.ISSUE_OR_RECEIVE := v_chrv_rec.ISSUE_OR_RECEIVE;
  l_chrv_rec.ESTIMATED_AMOUNT := v_chrv_rec.ESTIMATED_AMOUNT;
--  l_chrv_rec.CHR_ID_RENEWED_TO := v_chrv_rec.CHR_ID_RENEWED_TO;
  l_chrv_rec.ESTIMATED_AMOUNT_RENEWED := v_chrv_rec.ESTIMATED_AMOUNT_RENEWED;
  l_chrv_rec.CURRENCY_CODE_RENEWED := v_chrv_rec.CURRENCY_CODE_RENEWED;
  l_chrv_rec.UPG_ORIG_SYSTEM_REF := v_chrv_rec.UPG_ORIG_SYSTEM_REF;
  l_chrv_rec.UPG_ORIG_SYSTEM_REF_ID := v_chrv_rec.UPG_ORIG_SYSTEM_REF_ID;
  l_chrv_rec.ATTRIBUTE_CATEGORY := v_chrv_rec.ATTRIBUTE_CATEGORY;
  l_chrv_rec.ATTRIBUTE1 := v_chrv_rec.ATTRIBUTE1;
  l_chrv_rec.ATTRIBUTE2 := v_chrv_rec.ATTRIBUTE2;
  l_chrv_rec.ATTRIBUTE3 := v_chrv_rec.ATTRIBUTE3;
  l_chrv_rec.ATTRIBUTE4 := v_chrv_rec.ATTRIBUTE4;
  l_chrv_rec.ATTRIBUTE5 := v_chrv_rec.ATTRIBUTE5;
  l_chrv_rec.ATTRIBUTE6 := v_chrv_rec.ATTRIBUTE6;
  l_chrv_rec.ATTRIBUTE7 := v_chrv_rec.ATTRIBUTE7;
  l_chrv_rec.ATTRIBUTE8 := v_chrv_rec.ATTRIBUTE8;
  l_chrv_rec.ATTRIBUTE9 := v_chrv_rec.ATTRIBUTE9;
  l_chrv_rec.ATTRIBUTE10 := v_chrv_rec.ATTRIBUTE10;
  l_chrv_rec.ATTRIBUTE11 := v_chrv_rec.ATTRIBUTE11;
  l_chrv_rec.ATTRIBUTE12 := v_chrv_rec.ATTRIBUTE12;
  l_chrv_rec.ATTRIBUTE13 := v_chrv_rec.ATTRIBUTE13;
  l_chrv_rec.ATTRIBUTE14 := v_chrv_rec.ATTRIBUTE14;
  l_chrv_rec.ATTRIBUTE15 := v_chrv_rec.ATTRIBUTE15;
  l_chrv_rec.CREATED_BY := v_chrv_rec.CREATED_BY;
  l_chrv_rec.CREATION_DATE := v_chrv_rec.CREATION_DATE;
  l_chrv_rec.LAST_UPDATED_BY := v_chrv_rec.LAST_UPDATED_BY;
  l_chrv_rec.LAST_UPDATE_DATE := v_chrv_rec.LAST_UPDATE_DATE;
  l_chrv_rec.LAST_UPDATE_LOGIN := v_chrv_rec.LAST_UPDATE_LOGIN;

			 OKC_CONTRACT_PUB.update_contract_header(
			   p_api_version     => 1
			   ,p_init_msg_list  => OKC_API.G_FALSE
			   ,x_return_status  =>  l_return_status
			   ,x_msg_count      => l_msg_count
			   ,x_msg_data       => l_msg_data
			   ,p_restricted_update => OKC_API.G_FALSE
			   ,p_chrv_rec       => l_chrv_rec
			   ,x_chrv_rec       => x_chrv_rec);
  CLOSE k_cur;
    OKC_API.set_message(p_app_name => 'OKC',
			p_msg_name => 'OKC_OC_SUCCESS',
		        p_token1       => 'PROCESS',
	                p_token1_value => 'OKC_TEST.UPD_COMMENTS');
   x_return_status := 'S';

EXCEPTION
  when others then
  OKC_API.SET_MESSAGE(p_app_name     => 'OKC',
		      p_msg_name     => 'OKC_OC_FAILED',
		      p_token1       => 'PROCESS',
	              p_token1_value => 'OKC_TEST.UPD_COMMENTS',
		      p_token2       => 'MESSAGE1',
	              p_token2_value => 'Error Stack is :',
	              p_token3       => 'MESSAGE2',
		      p_token3_value => l_msg_data);
   x_return_status := l_return_status;
END upd_comments;

FUNCTION party_exists(p_kid        IN NUMBER,
		      p_party_name IN VARCHAR2,
		      p_role       IN  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR party_cur IS
select 'X'
from  okc_k_party_roles_v role,
      okx_parties_v party
where role.object1_id1 = party.id1
and   role.object1_id2 = party.id2
and   role.jtot_object1_code in ('OKX_PARTY','OKX_OPERUNIT')
and   upper(role.rle_code) = upper(p_role)
and   role.chr_id = p_kid
and   party.name = p_party_name;
party_rec  party_cur%ROWTYPE;

BEGIN
   OPEN party_cur;
   FETCH party_cur INTO party_rec;
     IF party_cur%FOUND THEN
       RETURN('T');
     ELSE
       RETURN('F');
     END IF;
   CLOSE party_cur;
EXCEPTION
  WHEN others THEN
  RETURN('F');
END party_exists;

PROCEDURE proc1(p_val_1 IN VARCHAR2,
		p_val_2 IN NUMBER,
		p_val_3 IN date default null,
		p_api_version IN NUMBER DEFAULT 1.0,
		p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data  OUT NOCOPY VARCHAR2) IS

	var1	VARCHAR2(100);
	var2    varchar2(20);
	l_process_name varchar2(200) := 'TEST_PLSQL.PROC1';
BEGIN
	x_msg_data := 'geeeeeeeeeeeee';
	x_return_status := 'E';
	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
			    p_msg_name     => 'OKC_OC_FAILED',
			    p_token1       => 'PROCESS',
			    p_token1_value => 'TEST_PLSQL.PROC1',
			    p_token2       => 'MESSAGE1',
		            p_token2_value => 'Error Stack is :',
			    p_token3       => 'MESSAGE2',
		            p_token3_value => 'geeeeeeeeeee');
	return;

	/*	var1 := p_val_1 ||','|| p_val_2||','||p_val_3;
		var2 := to_char(p_val_3,'DD-MON-YY');
			       OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
						   p_msg_name     => 'OKC_OC_SUCCESS',
						   p_token1       => 'PROCESS',
						   p_token1_value => l_process_name);
	        x_return_status := 'S';  */
EXCEPTION
		when others then
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);


		x_return_status := 'E';
END proc1;

FUNCTION func1 RETURN VARCHAR2 IS
BEGIN
  RETURN('T');
END func1;


END OKC_TEST;

/
