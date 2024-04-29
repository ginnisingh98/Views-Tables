--------------------------------------------------------
--  DDL for Package Body OKS_WARRDATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_WARRDATA_PUB" As
/* $Header: OKSPWDFB.pls 120.0 2005/05/25 17:51:18 appldev noship $ */

PROCEDURE WARRANTY_DATAFIX (
P_INSTANCE_ID         IN               NUMBER,
X_msg_Count           OUT NOCOPY       Number,
X_msg_Data            OUT NOCOPY       Varchar2,
x_return_status       OUT NOCOPY       Varchar2
)

IS

   CURSOR l_get_sublines_csr
   IS
       SELECT KL.id,
              KL.sts_code,
              KL.start_date,
              KL.end_date

        FROM  okc_k_headers_v KH,
              okc_k_lines_v   KL,
              okc_k_items_v   KI,
              okc_statuses_v  ST

       WHERE  KI.object1_id1       = to_char(P_INSTANCE_ID)
         AND  KI.jtot_object1_code = 'OKX_CUSTPROD'
         AND  KI.cle_id            = KL.id
         AND  KL.lse_id            = 18
         AND  KL.dnz_chr_id        = KH.id
         AND  KH.scs_code          = 'WARRANTY'
         AND  KL.date_terminated is not null
         AND  KL.sts_code          = ST.code
         AND  ST.ste_code not in   ('EXPIRED' , 'CANCELLED');



BEGIN

 FOR l_get_sublines_rec IN l_get_sublines_csr
 LOOP
      UPDATE okc_k_lines_b
      Set date_terminated = null
      where id =  l_get_sublines_rec.id;

      If l_get_sublines_rec.sts_code = 'TERMINATED' Then

          If trunc(l_get_sublines_rec.start_date) > trunc(Sysdate) Then
                   Update OKC_K_LINES_B set sts_code = 'SIGNED'  Where id = l_get_sublines_rec.id;
          Else
                   If trunc(Sysdate)  between l_get_sublines_rec.start_date and l_get_sublines_rec.end_date Then
                             Update Okc_k_lines_b Set sts_code = 'ACTIVE' Where id = l_get_sublines_rec.id;
                   End If;
          End If;

      End If;

 END LOOP;
Exception
When  Others Then
             x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
             OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
END;

END OKS_WARRDATA_PUB;



/
