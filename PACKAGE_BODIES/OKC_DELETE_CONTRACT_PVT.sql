--------------------------------------------------------
--  DDL for Package Body OKC_DELETE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DELETE_CONTRACT_PVT" as
/* $Header: OKCRDELB.pls 120.2 2006/06/06 20:56:49 dneetha noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

     l_api_version		NUMBER := 1;
     l_init_msg_list     VARCHAR2(1) := 'T';
     l_msg_count         NUMBER;
     l_msg_data		VARCHAR2(2000);
	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

-- Start of comments
-- BUG#4122038 HKAMDAR 10-FEB-2005 Part 1
-- Procedure Name  : is_rule_allowed
-- Description     : Checks if rules are allowed for contracts class,
-- Business Rules  :
-- Version         : 1.0
-- End of comments

Procedure is_rule_allowed(p_id number,
                          x_return       out NOCOPY varchar2) IS

CURSOR  cur_k_appl_id is
SELECT  application_id
FROM    okc_k_headers_b
WHERE   id = p_id;

k_appl_id number;

BEGIN

	OPEN cur_k_appl_id;
	FETCH cur_k_appl_id INTO k_appl_id;
	CLOSE cur_k_appl_id;

 --For OKS no rule/rule group allowed
     If k_appl_id =515 Then
        x_return :='N';
     Else
        x_return := 'Y';
     End If;

END Is_rule_allowed;
-- BUG#4122038 End Part 1

--Function DELETE_ARTICLE_TRANS

--FUNCTION DELETE_ARTICLE_TRANS( p_chr_id number) Return varchar2 IS
--
--  l_atnv_tbl_in	okc_k_article_pub.atnv_tbl_type;
--
--  CURSOR l_atn_csr (p_id  IN NUMBER) IS
--    SELECT ID
--     FROM OKC_ARTICLE_TRANS_V
--     WHERE dnz_chr_id = p_id;
--Begin
--   l_return_status := OKC_API.G_RET_STS_SUCCESS;
--
--   FOR rec IN l_atn_csr(p_chr_id)
--   LOOP
--	  l_atnv_tbl_in(1).ID := rec.id;
--	  okc_k_article_pub.delete_article_translation(
--			p_api_version     => l_api_version,
--			p_init_msg_list   => l_init_msg_list,
--			x_return_status   => l_return_status,
--			x_msg_count       => l_msg_count,
--			x_msg_data        => l_msg_data,
--			p_atnv_tbl        => l_atnv_tbl_in);
--
--	     If (l_return_status <> 'S') Then
--             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
--                                 p_msg_name     => G_CANNOT_DELETE,
--                                 p_token1       => G_TABLE_NAME_TOKEN,
--                                 p_token1_value => 'Article Translations',
--                                 p_token2       => G_SQLCODE_TOKEN,
--                                 p_token2_value => sqlcode,
--                                 p_token3       => G_SQLERRM_TOKEN,
--                                 p_token3_value => sqlerrm);
--	   Exit;
--	End If;
--   END LOOP;
--   return l_return_status;
--  EXCEPTION
--       -- other appropriate handlers
--       When others then
--       -- store SQL error message on message stack
--             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
--                                 p_msg_name     => G_UNEXPECTED_ERROR,
--                                 p_token1       => G_SQLCODE_TOKEN,
--                                 p_token1_value => sqlcode,
--                                 p_token2       => G_SQLERRM_TOKEN,
--                                 p_token2_value => sqlerrm);
--
--       -- notify  UNEXPECTED error
--             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
--             return l_return_status;
--END DELETE_ARTICLE_TRANS;

--Function DELETE_CONDITION_HEADERS

FUNCTION DELETE_CONDITION_HEADERS( p_chr_id number) Return varchar2 IS

  l_cnhv_tbl_in	OKC_CONDITIONS_PUB.cnhv_tbl_type;

  CURSOR l_cnhv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_CONDITION_HEADERS_V
     WHERE dnz_chr_id = p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cnhv_csr(p_chr_id)
   LOOP
		l_cnhv_tbl_in(1).ID := rec.id;

		OKC_CONDITIONS_PUB.DELETE_COND_HDRS(
			p_api_version     => l_api_version,
			p_init_msg_list   => l_init_msg_list,
			x_return_status   => l_return_status,
			x_msg_count       => l_msg_count,
			x_msg_data        => l_msg_data,
			p_cnhv_tbl        => l_cnhv_tbl_in);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Condition Headers',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_CONDITION_HEADERS;

--Function DELETE_CONDITION_LINES

FUNCTION DELETE_CONDITION_LINES( p_chr_id number) Return varchar2 IS

  l_cnlv_tbl_in	OKC_CONDITIONS_PUB.cnlv_tbl_type;

  CURSOR l_cnlb_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_CONDITION_LINES_V
     WHERE dnz_chr_id= p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cnlb_csr(p_chr_id)
   LOOP
		l_cnlv_tbl_in(1).ID := rec.id;

		OKC_CONDITIONS_PUB.DELETE_COND_LINES(
			p_api_version     => l_api_version,
			p_init_msg_list   => l_init_msg_list,
			x_return_status   => l_return_status,
			x_msg_count       => l_msg_count,
			x_msg_data        => l_msg_data,
			p_cnlv_tbl        => l_cnlv_tbl_in);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Condition Lines',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_CONDITION_LINES;

----

FUNCTION DELETE_PRICE_ADJUSTMENTS( p_chr_id number) Return varchar2 IS

  l_patv_tbl_in OKC_PRICE_ADJUSTMENT_PVT.patv_tbl_type;

  CURSOR l_patb_csr (p_id  IN NUMBER) IS
    SELECT ID,cle_id
     FROM OKC_PRICE_ADJUSTMENTS_V
     WHERE chr_id= p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_patb_csr(p_chr_id)
   LOOP
                l_patv_tbl_in(1).ID := rec.id;
			 l_patv_tbl_in(1).chr_id := p_chr_id;
			 If rec.cle_id is not null then
			   l_patv_tbl_in(1).cle_id := rec.cle_id;
			 End If;

                OKC_PRICE_ADJUSTMENT_PUB.delete_price_adjustment(
                        p_api_version     => l_api_version,
                        p_init_msg_list   => l_init_msg_list,
                        x_return_status   => l_return_status,
                        x_msg_count       => l_msg_count,
                        x_msg_data        => l_msg_data,
                        p_patv_tbl        => l_patv_tbl_in);

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Condition Lines',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
   EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_PRICE_ADJUSTMENTS;

----
/*******
---Following code is commented out for Bug.1850500
---Alternate code is added in OKCCPATB.pls .

    FUNCTION DELETE_PRICE_ADJ_ASSOCS( p_chr_id number) Return varchar2 IS

  l_pacv_tbl_in OKC_PRICE_ADJUSTMENT_PVT.pacv_tbl_type;

  CURSOR l_pacb_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_PRICE_ADJ_ASSOCS_V
     WHERE  pat_id_from IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_id
             );


Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_pacb_csr(p_chr_id)
   LOOP
                l_pacv_tbl_in(1).ID := rec.id;

                OKC_PRICE_ADJUSTMENT_PUB.delete_price_adj_assoc(
                        p_api_version     => l_api_version,
                        p_init_msg_list   => l_init_msg_list,
                        x_return_status   => l_return_status,
                        x_msg_count       => l_msg_count,
                        x_msg_data        => l_msg_data,
                        p_pacv_tbl        => l_pacv_tbl_in);

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Condition Lines',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
   EXCEPTION
       -- other appropriate handlers
    When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_PRICE_ADJ_ASSOCS;

------
 FUNCTION DELETE_PRICE_ADJ_ATTRIBS( p_chr_id number) Return varchar2 IS

  l_paav_tbl_in OKC_PRICE_ADJUSTMENT_PVT.paav_tbl_type;

  CURSOR l_paab_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_PRICE_ADJ_ATTRIBS_V
     WHERE  pat_id IN
        ( SELECT id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_id
             );

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_paab_csr(p_chr_id)
   LOOP
                l_paav_tbl_in(1).ID := rec.id;

                OKC_PRICE_ADJUSTMENT_PUB.delete_price_adj_attrib(
                        p_api_version     => l_api_version,
                        p_init_msg_list   => l_init_msg_list,
                        x_return_status   => l_return_status,
                        x_msg_count       => l_msg_count,
                        x_msg_data        => l_msg_data,
                        p_paav_tbl        => l_paav_tbl_in);

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Condition Lines',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
   EXCEPTION
       -- other appropriate handlers
      When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_PRICE_ADJ_ATTRIBS;

---This code is commented out for Bug.1850500
---Alternate code is added in OKCCPATB.pls.
*/
---------
        FUNCTION DELETE_PRICE_ATT_VALUES( p_chr_id number) Return varchar2 IS

  l_pavv_tbl_in OKC_PRICE_ADJUSTMENT_PVT.pavv_tbl_type;

  CURSOR l_pavb_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_PRICE_ATT_VALUES_V
     WHERE chr_id= p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_pavb_csr(p_chr_id)
   LOOP
                l_pavv_tbl_in(1).ID := rec.id;

                OKC_PRICE_ADJUSTMENT_PUB.delete_price_att_value(
                        p_api_version     => l_api_version,
                        p_init_msg_list   => l_init_msg_list,
                        x_return_status   => l_return_status,
                        x_msg_count       => l_msg_count,
                        x_msg_data        => l_msg_data,
                        p_pavv_tbl        => l_pavv_tbl_in);

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Condition Lines',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
   EXCEPTION
       -- other appropriate handlers
     When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_PRICE_ATT_VALUES;



-------------
------------
-----------
---------

--Function DELETE_CONTACTS

FUNCTION DELETE_CONTACTS( p_chr_id number) Return varchar2 IS

  l_ctcv_tbl_in	OKC_CONTRACT_PARTY_PUB.ctcv_tbl_type;

  CURSOR l_ctc_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_CONTACTS_V
     WHERE dnz_chr_id = p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_ctc_csr(p_chr_id)
   LOOP

	 l_ctcv_tbl_in(1).ID := rec.id;

	 OKC_CONTRACT_PARTY_PUB.Delete_Contact(
			p_api_version     => l_api_version,
			p_init_msg_list   => l_init_msg_list,
			x_return_status   => l_return_status,
			x_msg_count       => l_msg_count,
			x_msg_data        => l_msg_data,
			p_ctcv_tbl        => l_ctcv_tbl_in);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contacts',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_CONTACTS;

/*
--------------This has taken care from Delete_Rule API-----------------------

--Function DELETE_COVER_TIMES

FUNCTION DELETE_COVER_TIMES( p_chr_id number ) Return varchar2 IS

  l_ctiv_tbl_in	OKC_RULE_PUB.ctiv_tbl_type;

  CURSOR l_ctiv_csr (p_id  IN NUMBER) IS
    SELECT RUL_ID, TVE_ID
     FROM OKC_COVER_TIMES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_ctiv_csr(p_chr_id)
   LOOP
	 l_ctiv_tbl_in(1).RUL_ID := rec.rul_id;
	 l_ctiv_tbl_in(1).TVE_ID := rec.tve_id;

	 OKC_RULE_PUB.delete_cover_time(
			p_api_version     => l_api_version,
			p_init_msg_list   => l_init_msg_list,
			x_return_status   => l_return_status,
			x_msg_count       => l_msg_count,
			x_msg_data        => l_msg_data,
			p_ctiv_tbl        => l_ctiv_tbl_in);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Cover Times',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_COVER_TIMES;
*/

--Function DELETE_FUNCTION_EXPR_PARAMS

FUNCTION DELETE_FUNCTION_EXPR_PARAMS( p_chr_id number) Return varchar2 IS

  l_fepv_tbl_in	OKC_CONDITIONS_PUB.fepv_tbl_type;

  CURSOR l_fepv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_FUNCTION_EXPR_PARAMS_V
     WHERE dnz_chr_id = p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_fepv_csr(p_chr_id)
   LOOP

	 l_fepv_tbl_in(1).ID := rec.id;

	 OKC_CONDITIONS_PUB.DELETE_FUNC_EXPRS(
			p_api_version     => l_api_version,
			p_init_msg_list   => l_init_msg_list,
			x_return_status   => l_return_status,
			x_msg_count       => l_msg_count,
			x_msg_data        => l_msg_data,
			p_fepv_tbl        => l_fepv_tbl_in);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Function Exp. Parameters',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_FUNCTION_EXPR_PARAMS;


--Function DELETE_GOVERNANCES

FUNCTION DELETE_GOVERNANCES( p_chr_id number) Return varchar2 IS

  l_gvev_tbl_in	okc_contract_pub.gvev_tbl_type;

  CURSOR l_gvev_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_GOVERNANCES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_gvev_csr(p_chr_id)
   LOOP

  	 l_gvev_tbl_in(1).ID := rec.id;

  	 okc_contract_pub.delete_governance (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_gvev_tbl		=> l_gvev_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Governances',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_GOVERNANCES;

--Function DELETE_K_ACCESSES

FUNCTION DELETE_K_ACCESSES( p_chr_id number) Return varchar2 IS

  l_cacv_tbl_in	okc_contract_pub.cacv_tbl_type;

  CURSOR l_cacv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_ACCESSES_V
     WHERE chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cacv_csr(p_chr_id)
   LOOP
  	 l_cacv_tbl_in(1).ID := rec.id;

  	 OKC_CONTRACT_PUB.Delete_Contract_Access (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_cacv_tbl		=> l_cacv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Accesses',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_ACCESSES;

--Function DELETE_K_ARTICLES

--FUNCTION DELETE_K_ARTICLES( p_chr_id number) Return varchar2 IS
--
--  l_catv_tbl_in	okc_k_article_pub.catv_tbl_type;
--  CURSOR l_catv_csr (p_id  IN NUMBER) IS
--    SELECT ID
--     FROM OKC_K_ARTICLES_V
--     WHERE dnz_chr_id = p_id;
--
--Begin
--
--   l_return_status := OKC_API.G_RET_STS_SUCCESS;
--
--   FOR rec IN l_catv_csr(p_chr_id)
--   LOOP
--  	 l_catv_tbl_in(1).ID := rec.id;
--
--  	 okc_k_article_pub.delete_k_article (
--  		p_api_version		=> l_api_version,
--  		p_init_msg_list	=> l_init_msg_list,
--  		x_return_status	=> l_return_status,
--  		x_msg_count		=> l_msg_count,
--  		x_msg_data		=> l_msg_data,
--  		p_catv_tbl		=> l_catv_tbl_in
--  		);
--
--	     If (l_return_status <> 'S') Then
--             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
--                                 p_msg_name     => G_CANNOT_DELETE,
--                                 p_token1       => G_TABLE_NAME_TOKEN,
--                                 p_token1_value => 'Contract Articles',
--                                 p_token2       => G_SQLCODE_TOKEN,
--                                 p_token2_value => sqlcode,
--                                 p_token3       => G_SQLERRM_TOKEN,
--                                 p_token3_value => sqlerrm);
--		   Exit;
--		End If;
--   END LOOP;
--   return l_return_status;
--  EXCEPTION
--       -- other appropriate handlers
--       When others then
--       -- store SQL error message on message stack
--             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
--                                 p_msg_name     => G_UNEXPECTED_ERROR,
--                                 p_token1       => G_SQLCODE_TOKEN,
--                                 p_token1_value => sqlcode,
--                                 p_token2       => G_SQLERRM_TOKEN,
--                                 p_token2_value => sqlerrm);
--
--       -- notify  UNEXPECTED error
--             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
--             return l_return_status;
--END DELETE_K_ARTICLES;

--Function DELETE_K_GRPINGS

FUNCTION DELETE_K_GRPINGS(p_chr_id number ) Return varchar2 IS

  l_cgcv_tbl_in	OKC_CONTRACT_GROUP_PUB.cgcv_tbl_type;

  CURSOR l_cgcv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_GRPINGS_V
     WHERE INCLUDED_CHR_ID = p_id;
Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cgcv_csr(p_chr_id)
   LOOP
  	 l_cgcv_tbl_in(1).ID := rec.id;

  	 OKC_CONTRACT_GROUP_PUB.Delete_Contract_Grpngs (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_cgcv_tbl		=> l_cgcv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Grouping',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_GRPINGS;

--Function DELETE_K_HEADERS

FUNCTION DELETE_K_HEADERS( p_chr_id number ) Return varchar2 IS

  l_chrv_rec	OKC_CONTRACT_PUB.chrv_rec_type;
  l_clean_relink_flag VARCHAR2(10) := 'CLEAN';
Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

  	 l_chrv_rec.ID := p_chr_id;

	-- clean renewal links
	OKC_CONTRACT_PVT.CLEAN_REN_LINKS(
	    p_api_version        => l_api_version,
	    p_init_msg_list      => l_init_msg_list,
	    x_return_status      => l_return_status,
	    x_msg_count		=> l_msg_count,
	    x_msg_data	     	=> l_msg_data,
	    p_target_chr_id      => p_chr_id,
	    clean_relink_flag    => l_clean_relink_flag);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Header',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
  	     End If;

         -- clean history table
         OKC_K_HISTORY_PUB.DELETE_ALL_ROWS (
  		p_api_version		=> l_api_version,
  		p_init_msg_list		=> l_init_msg_list,
  		x_return_status		=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_chr_id		=> p_chr_id
  		);

           If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Header',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
           End If;

  	 OKC_CONTRACT_PUB.Delete_Contract_Header (
  		p_api_version		=> l_api_version,
  		p_init_msg_list		=> l_init_msg_list,
  		x_return_status		=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_chrv_rec		=> l_chrv_rec
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Header',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		End If;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_HEADERS;

--Function DELETE_K_ITEMS

FUNCTION DELETE_K_ITEMS( p_chr_id number) Return varchar2 IS

  l_cimv_tbl_in	OKC_CONTRACT_ITEM_PUB.cimv_tbl_type;

  CURSOR l_cimv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_ITEMS_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cimv_csr(p_chr_id)
   LOOP
  	 l_cimv_tbl_in(1).ID := rec.id;

  	 OKC_CONTRACT_ITEM_PUB.Delete_Contract_Item (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_cimv_tbl		=> l_cimv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Items',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_ITEMS;

--Function DELETE_K_LINES

FUNCTION DELETE_K_LINES( p_chr_id number) Return varchar2 IS

  l_clev_tbl_in	OKC_CONTRACT_PUB.clev_tbl_type;
  l_cle_id		NUMBER;
  l_not_found		BOOLEAN;

  CURSOR l_clev_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_LINES_V
     WHERE dnz_chr_id = p_id;


begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;
   --Fix for Bug 5282502
	delete from okc_ancestrys
      where cle_id in (
      select Ks.cle_id
      from okc_ancestrys KS, okc_k_lines_b Kl
      where kl.id = ks.cle_id
      And Kl.dnz_chr_id = p_chr_id);


	For rec in l_clev_csr(p_chr_id)
	Loop
		l_clev_tbl_in(1).ID := rec.id;

            OKC_CONTRACT_PUB.Delete_Contract_Line(
	       p_api_version		=> l_api_version,
	       p_init_msg_list	=> l_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> l_msg_count,
             x_msg_data      	=> l_msg_data,
             p_clev_tbl		=> l_clev_tbl_in);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Lines',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
	End Loop;

   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_LINES;

--Function DELETE_K_PARTY_ROLES

FUNCTION DELETE_K_PARTY_ROLES( p_chr_id number) Return varchar2 IS

  l_cplv_tbl_in	OKC_CONTRACT_PARTY_PUB.cplv_tbl_type;

  CURSOR l_cplv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_PARTY_ROLES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cplv_csr(p_chr_id)
   LOOP
  	 l_cplv_tbl_in(1).ID := rec.id;

  	 OKC_CONTRACT_PARTY_PUB.DELETE_K_PARTY_ROLE (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_cplv_tbl		=> l_cplv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Party Roles',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_PARTY_ROLES;


--Function DELETE_K_PROCESSES

FUNCTION DELETE_K_PROCESSES( p_chr_id number) Return varchar2 IS

  l_cpsv_tbl_in	OKC_CONTRACT_PUB.cpsv_tbl_type;

  CURSOR l_cpsv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_PROCESSES_V
     WHERE chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cpsv_csr(p_chr_id)
   LOOP
  	 l_cpsv_tbl_in(1).ID := rec.id;

  	 OKC_CONTRACT_PUB.Delete_Contract_Process (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_cpsv_tbl		=> l_cpsv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Processes',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_PROCESSES;


--Function DELETE_OUTCOME_ARGUMENTS

FUNCTION DELETE_OUTCOME_ARGUMENTS( p_chr_id number) Return varchar2 IS

  l_oatv_tbl_in	OKC_OUTCOME_PUB.oatv_tbl_type;

  CURSOR l_oatv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_OUTCOME_ARGUMENTS_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_oatv_csr(p_chr_id)
   LOOP
  	 l_oatv_tbl_in(1).ID := rec.id;

  	 OKC_OUTCOME_PUB.delete_out_arg (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_oatv_tbl		=> l_oatv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Outcome Arguments',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_OUTCOME_ARGUMENTS;

--Function DELETE_OUTCOMES

FUNCTION DELETE_OUTCOMES( p_chr_id number) Return varchar2 IS

  l_ocev_tbl_in	OKC_OUTCOME_PUB.ocev_tbl_type;

  CURSOR l_ocev_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_OUTCOMES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_ocev_csr(p_chr_id)
   LOOP
  	 l_ocev_tbl_in(1).ID := rec.id;

  	 OKC_OUTCOME_PUB.delete_outcome (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_ocev_tbl		=> l_ocev_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Outcomes',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_OUTCOMES;

/*
--------------This has taken care from Delete_Rule API-----------------------

--Function DELETE_REACT_INTERVALS

FUNCTION DELETE_REACT_INTERVALS( p_chr_id number) Return varchar2 IS

  l_rilv_tbl_in	OKC_RULE_PUB.rilv_tbl_type;

  CURSOR l_rilv_csr (p_id  IN NUMBER) IS
    SELECT TVE_ID, RUL_ID
     FROM OKC_REACT_INTERVALS_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_rilv_csr(p_chr_id)
   LOOP
  	 l_rilv_tbl_in(1).TVE_ID := rec.TVE_ID;
  	 l_rilv_tbl_in(1).RUL_ID := rec.RUL_ID;

  	 OKC_RULE_PUB.delete_react_interval (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_rilv_tbl		=> l_rilv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Reaction Intervals',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_REACT_INTERVALS;
*/

--Function DELETE_RG_PARTY_ROLES

FUNCTION DELETE_RG_PARTY_ROLES( p_chr_id number) Return varchar2 IS

  l_rmpv_tbl_in	OKC_RULE_PUB.rmpv_tbl_type;

  CURSOR l_rmpv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_RG_PARTY_ROLES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_rmpv_csr(p_chr_id)
   LOOP
  	 l_rmpv_tbl_in(1).ID := rec.id;

  	 OKC_RULE_PUB.delete_rg_mode_pty_role (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_rmpv_tbl		=> l_rmpv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Rule Group Party Roles',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_RG_PARTY_ROLES;

--Function DELETE_RULE_GROUPS

FUNCTION DELETE_RULE_GROUPS( p_chr_id number) Return varchar2 IS

  l_rgpv_tbl_in	OKC_RULE_PUB.rgpv_tbl_type;

  CURSOR l_rgpv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_RULE_GROUPS_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_rgpv_csr(p_chr_id)
   LOOP
  	 l_rgpv_tbl_in(1).ID := rec.id;

  	 OKC_RULE_PUB.delete_rule_group (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_rgpv_tbl		=> l_rgpv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Rule Groups',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_RULE_GROUPS;

--Function DELETE_RULES

FUNCTION DELETE_RULES( p_chr_id number) Return varchar2 IS

  l_rulv_tbl_in	OKC_RULE_PUB.rulv_tbl_type;

  CURSOR l_rulv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_RULES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_rulv_csr(p_chr_id)
   LOOP
  	 l_rulv_tbl_in(1).ID := rec.id;

  	 OKC_RULE_PUB.Delete_Rule (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_rulv_tbl		=> l_rulv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Rules',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_RULES;

/*
--------------This has taken care from Delete_Rule API-----------------------

--Function DELETE_TIMEVALUES

FUNCTION DELETE_TIMEVALUES( p_chr_id number) Return varchar2 IS

  l_tavv_tbl_in	OKC_TIME_PUB.tavv_tbl_type;

  CURSOR l_tavv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_TIMEVALUES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_tavv_csr(p_chr_id)
   LOOP
  	 l_tavv_tbl_in(1).ID := rec.id;

  	 OKC_TIME_PUB.DELETE_TPA_VALUE (
  		p_api_version		=> l_api_version,
  		p_init_msg_list	=> l_init_msg_list,
  		x_return_status	=> l_return_status,
  		x_msg_count		=> l_msg_count,
  		x_msg_data		=> l_msg_data,
  		p_tavv_tbl		=> l_tavv_tbl_in
  		);

	     If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Timevalues',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
		   Exit;
		End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_TIMEVALUES;
*/

--Public procedure to delete various components of a contract
PROCEDURE delete_contract(
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 ,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_chrv_rec			IN OKC_CONTRACT_PUB.chrv_rec_type) IS

    l_api_name VARCHAR2(30) := 'V_Delete_Contract';
    l_delete_allowed  VARCHAR2(1);
    DELETE_NOT_ALLOWED  Exception;
    l_doc_type                     VARCHAR2(30);
    l_doc_id                       NUMBER;

-- BUG#4122038 HKAMDAR 10-FEB-2005 Part 2
    lx_return_status     VARCHAR2(1) ;
-- BUG#4122038 HKAMDAR End Part 2

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_delete_allowed := OKC_ASSENT_PUB.HEADER_OPERATION_ALLOWED(p_header_id   => p_chrv_rec.id,
                                                                p_opn_code    => 'DELETE');

    If l_delete_allowed <> 'T' Then

      Raise DELETE_NOT_ALLOWED;
    End If;

    --delete Contacts
    l_return_status := Delete_contacts(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete price att values
    l_return_status := Delete_Price_Att_Values(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

/****For Bug.1850500.*********************************************
--delete price adjustment attributes
    l_return_status := Delete_Price_Adj_Attribs(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*****************************************************************/
/****For Bug.1850500.*********************************************
--delete price adjustment associations
    l_return_status := Delete_Price_Adj_Assocs(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*****************************************************************/

/****For Bug.1850500.*********************************************
--delete Price adjustments
    l_return_status := Delete_Price_Adjustments(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*****************************************************************/
    --delete contract party roles
    l_return_status := Delete_k_party_roles(p_chrv_rec.ID);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete cover times
    --Cover times are deleted when rules/rule-groups deleted

    --delete react intervals
    --React Intervals are deleted when rules/rule-groups deleted

    --delete outcome arguments
    l_return_status := Delete_outcome_arguments(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete outcomes
    l_return_status := Delete_outcomes(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
--    --delete Article trans
--    l_return_status := Delete_article_trans(p_chrv_rec.ID);
--
--    --- If any errors happen abort API
--    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
--    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
--      RAISE OKC_API.G_EXCEPTION_ERROR;
--    END IF;
*/

-- BUG#4122038 HKAMDAR 10-FEB-2005 Part 3
   --/Rules Migration/
    Is_rule_allowed(p_chrv_rec.ID,
                    lx_return_status);

    IF lx_return_status = 'Y' Then
-- End BUG#4122038 Part 3
    --delete Rules
       l_return_status := Delete_rules(p_chrv_rec.ID);

       --- If any errors happen abort API
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       --delete RuleGroup party roles
       l_return_status := Delete_rg_party_roles(p_chrv_rec.ID);

       --- If any errors happen abort API
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

/*
--    --delete contract articles
--    l_return_status := Delete_k_articles(p_chrv_rec.ID);
--
--    --- If any errors happen abort API
--    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
--    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
--      RAISE OKC_API.G_EXCEPTION_ERROR;
--    END IF;
*/
       --delete Rule Groups
       l_return_status := Delete_rule_groups(p_chrv_rec.ID);

       -- If any errors happen abort API
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;  -- BUG#4122038 HKAMDAR 10-FEB-2005 Part 4

    --delete contract accesses
    l_return_status := Delete_k_accesses(p_chrv_rec.ID);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete contract processes
    l_return_status := Delete_k_processes(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete function_expr_params
    l_return_status := Delete_function_expr_params(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete condition lines
    l_return_status := Delete_condition_lines(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete condition headers
    l_return_status := Delete_condition_headers(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete governances
    l_return_status := Delete_governances(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete contract items
    l_return_status := Delete_k_items(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete contract lines
    l_return_status := Delete_k_lines(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete contract groupings
    l_return_status := Delete_k_Grpings(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

         okc_terms_util_grp.get_contract_document_type_id(
                                           p_api_version   => 1,
                                           p_init_msg_list => FND_API.G_FALSE,
                                           x_return_status => l_return_status,
                                           x_msg_data      => x_msg_data,
                                           x_msg_count     => x_msg_count,
                                           p_chr_id        => p_chrv_rec.ID,
                                           x_doc_type      => l_doc_type,
                                           x_doc_id        => l_doc_id);

         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

   --Delete VERSION TERMS and Condition and Deliverables

    OKC_TERMS_UTIL_GRP.delete_doc(
                             p_api_version      => 1,
                             p_init_msg_list    => FND_API.G_FALSE,
                             p_commit           => FND_API.G_FALSE,

                             x_return_status    => l_return_status,
                             x_msg_data         => x_msg_data,
                             x_msg_count        => x_msg_count,
                             p_validate_commit  => FND_API.G_FALSE,
                             p_validation_string => NULL,

                             p_doc_type         => l_doc_type,
                             p_doc_id           => l_doc_id);

    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      	RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --delete contract header
    l_return_status := Delete_k_headers(p_chrv_rec.ID);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

---------

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := l_return_status;
    COMMIT WORK;
  EXCEPTION
    WHEN DELETE_NOT_ALLOWED Then
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_NO_DELETE_WRONG_STATUS');
    x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END Delete_Contract;

END OKC_DELETE_CONTRACT_PVT;

/
