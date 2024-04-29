--------------------------------------------------------
--  DDL for Package Body OKS_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CONTRACTS_PUB" AS
/* $Header: OKSPKCRB.pls 120.3 2006/06/06 23:38:00 upillai noship $ */

l_api_version       CONSTANT       NUMBER       := 1.0;


Function get_top_line_number(p_chr_id IN Number) return Number;
Function get_sub_line_number(p_chr_id IN Number,p_cle_id IN Number) return Number;

TYPE numeric_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;

TYPE Party_Role_Rec Is Record
(
       authoring_org_id           Number,
       party_id                   Number,
       bill_to_id                 Number,
       third_party_role           VARCHAR2(30),
       scs_code                   VARCHAR2(30)
);
-------------------------------------------------------------------------
-- Procedure for checking effectivity of line effectivities
-------------------------------------------------------------------------

PROCEDURE CHECK_LINE_EFFECTIVITY
(
    p_cle_id                    IN      NUMBER,
    p_srv_sdt                   IN      DATE,
    p_srv_edt                   IN      DATE,
    x_line_sdt                  OUT NOCOPY  DATE,
    x_line_edt                  OUT NOCOPY   DATE,
    x_status                    OUT NOCOPY    VarChar2
)
IS
    CURSOR  l_line_csr  Is
    SELECT Start_Date, End_Date From OKC_K_LINES_V
    WHERE  id = p_cle_id;

    l_line_csr_rec      l_line_csr%ROWTYPE;
    l_msg_data          Varchar2(2000);
    l_msg_count         Number;
    l_return_status     Varchar2(1);

BEGIN

    OPEN l_line_csr;
    FETCH l_line_csr Into l_line_csr_rec;

    ----dbms_output.put_line('service_start_date'||p_srv_sdt ||'start date '|| l_line_csr_rec.Start_Date);
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CHECK_LINE_EFFECTIVITY ::  Srv Start date : '|| p_srv_sdt );
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CHECK_LINE_EFFECTIVITY ::  Srv End date   : '|| p_srv_edt );
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CHECK_LINE_EFFECTIVITY ::  Line Start_date: '|| l_line_csr_rec.Start_Date );
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CHECK_LINE_EFFECTIVITY ::  Line End_date  : '|| l_line_csr_rec.End_Date );

    If l_line_csr%FOUND Then
        If  TRUNC(p_srv_sdt) >= TRUNC(l_line_csr_rec.Start_Date) And
            TRUNC(p_srv_edt) <= TRUNC(l_line_csr_rec.End_Date) Then

            x_Status := 'N';
        Else
            If p_srv_sdt >= l_line_csr_rec.Start_Date Then
                x_line_sdt := l_line_csr_rec.Start_Date;
            Else
                x_line_sdt := p_srv_sdt;
            End If;

            If p_srv_edt >= l_line_csr_rec.End_Date Then
                x_line_edt := p_srv_edt;
            Else
                x_line_edt := l_line_csr_rec.End_Date;
            End If;
            x_Status := 'Y';

        End If;
    Else
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CHECK_LINE_EFFECTIVITY ::   Start date and End date of the Line not Found');
        x_Status := 'E';
    End If;
EXCEPTION
    WHEN OTHERS THEN
         OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CHECK_LINE_EFFECTIVITY :: Error:'||SQLCODE ||':'||SQLERRM);

END CHECK_LINE_EFFECTIVITY;
-----------------------------------------------------------------------------
-- Procedure for creating party roles
-----------------------------------------------------------------------------

PROCEDURE  PARTY_ROLE (  p_ChrId          IN NUMBER,
                         p_cleid          IN NUMBER,
                         p_Rle_Code       IN VARCHAR2,
                         p_PartyId        IN NUMBER,
                         p_Object_Code    IN VARCHAR2,
                         x_roleid        OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2
)
IS

  l_api_version         CONSTANT NUMBER      := 1.0;
  l_init_msg_list       CONSTANT VARCHAR2(1) := 'F';
  l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  l_index                   VARCHAR2(240);

--Party Role
  l_cplv_tbl_in                 okc_contract_party_pub.cplv_tbl_type;
  l_cplv_tbl_out                okc_contract_party_pub.cplv_tbl_type;

  Cursor l_party_csr  Is
  Select Id From OKC_K_PARTY_ROLES_B
  Where  dnz_chr_id = p_chrid
  And    cle_id Is Null
  And    rle_code = p_rle_code;

  Cursor l_lparty_csr  Is  Select Id From OKC_K_PARTY_ROLES_B
                           Where  dnz_chr_id = p_chrid
                           And    cle_id = p_cleid
                           And    rle_code = p_rle_code;

  l_roleid                      Number;

Begin

      If p_cleid Is Null Then

             Open  l_party_csr;
             Fetch l_party_csr Into l_roleid;
             Close l_party_csr;

             If l_roleid Is Not Null Then
                  x_roleid := l_roleid;
                  Return;
             End If;

             l_cplv_tbl_in(1).chr_id   := p_chrid;

       Else

             Open  l_lparty_csr;
             Fetch l_lparty_csr Into l_roleid;
             Close l_lparty_csr;

             If l_roleid Is Not Null Then
                   x_roleid := l_roleid;
                   Return;
             End If;

             l_cplv_tbl_in(1).cle_id  := p_cleid;

       End If;

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Party_Role ::  rle_code: '|| p_rle_code );
       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Party_Role ::  p_partyid: '|| p_partyid );
       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Party_Role ::  p_object_code: '|| p_object_code );
       ----dbms_output.put_line('party role rle_code'||p_rle_code);
       ----dbms_output.put_line('party role p_partyid'||p_partyid);
       ----dbms_output.put_line('party role p_object_code'||p_object_code);

       l_cplv_tbl_in(1).sfwt_flag                      := 'N';
       l_cplv_tbl_in(1).rle_code                    := p_rle_code;
       l_cplv_tbl_in(1).object1_id1                    := p_partyid;
       l_cplv_tbl_in(1).Object1_id2                    := '#';
       l_cplv_tbl_in(1).jtot_object1_code              := p_object_code;
       l_cplv_tbl_in(1).dnz_chr_id                      := p_chrid;

       Okc_contract_party_pub.create_k_party_role
       (
            p_api_version       => l_api_version,
            p_init_msg_list     => l_init_msg_list,
            x_return_status     => l_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_cplv_tbl          => l_cplv_tbl_in,
            x_cplv_tbl          => l_cplv_tbl_out
       );

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Party_Role ::  create_k_party_role status: '|| l_return_status);
       ----dbms_output.put_line('party role:'||l_return_status);

       If l_return_status = OKC_API.G_RET_STS_SUCCESS Then

             x_roleid := l_cplv_tbl_out(1).id;
       Else
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,           p_rle_code || ' Party Role (HEADER)');
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB):Party_Role ::   Error in Create_k_party role' );
             Raise   G_EXCEPTION_HALT_VALIDATION;


       End if;
       x_return_status := l_return_status;

 EXCEPTION
      WHEN  G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status ;
      WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB):Party_Role :: Error:'||SQLCODE ||':'||SQLERRM );

 End Party_Role;

/*
----------------------------------------------------------------------------
-- Function for checking the rules exist or not
----------------------------------------------------------------------------
Function Check_Rule_Exists
(
    p_rgp_id    IN NUMBER,
    p_rule_type IN VARCHAR2
)   Return NUMBER
Is
     v_id NUMBER;
Begin
     If p_rgp_id is null Then
         Return(null);
     Else
         Select ID Into V_ID From OKC_RULES_V
         Where  rgp_id = p_rgp_id
         And    Rule_information_category = p_rule_type;

         If v_id Is NULL Then
            return(null);
         Else
            return(V_ID);
         End If;
     End if;


Exception
  WHEN No_Data_Found Then
            Return (null);

End Check_Rule_Exists;


-----------------------------------------------------------------------------
-- Check whether rule group exist or not
-----------------------------------------------------------------------------

Function CHECK_RULE_GRP_EXISTS
(
        p_chr_id IN NUMBER,
        p_cle_id IN NUMBER
) Return NUMBER
Is
            v_id NUMBER;
Begin


    If (p_chr_id IS NOT NULL) Then
        SELECT ID INTO V_ID FROM OKC_RULE_GROUPS_V
        WHERE  Dnz_CHR_ID = p_chr_id
        And    cle_id is null ;
        If V_ID IS NULL Then
            return(NULL);
        Else
            return(V_ID);
        End If;
    End If;

    If (p_cle_id IS NOT NULL) Then
        SELECT ID INTO V_ID FROM OKC_RULE_GROUPS_V WHERE CLE_ID = p_cle_id;
        If V_ID IS NULL Then
            return(NULL);
        Else
            return(V_ID);
        End If;
    End If;

Exception
    When OTHERS Then
        RETURN(NULL);

End CHECK_RULE_GRP_EXISTS;

*/
--------------------------------------------------------------------------------
-- Create Articles
--------------------------------------------------------------------------------

procedure Create_articles
(
 p_articles_tbl       IN  obj_articles_tbl
,p_contract_id       IN  NUMBER
,p_cle_id               IN  NUMBER
,p_dnz_chr_id       IN  NUMBER
,x_return_status    OUT NOCOPY Varchar2
,x_msg_count       OUT  NOCOPY Number
,x_msg_data         OUT NOCOPY Varchar2
)
Is

   Cursor l_art_csr(p_name Varchar2) Is
   Select id
   From   okc_std_articles_v
   Where  name = p_name;

   Cursor l_art_release_csr(p_sae_id Number) Is
   Select sav_release
   From   okc_std_art_versions_v
   Where  sae_id = p_sae_id;


   l_catv_tbl_in  OKC_K_ARTICLE_PUB.catv_tbl_type;
   l_catv_tbl_out  OKC_K_ARTICLE_PVT.catv_tbl_type;

   l_sae_id                     Number;
   l_sae_release                Varchar2(100);
   l_api_version                CONSTANT NUMBER      := 1.0;
   l_init_msg_list              CONSTANT VARCHAR2(1) := 'F';
   l_return_status              VARCHAR2(1)          := OKC_API.G_RET_STS_SUCCESS;
   l_index                      VARCHAR2(240);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);



Begin
   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   For l_ptr in 1..P_Articles_tbl.count
   Loop

       Open l_art_csr(p_articles_tbl(l_ptr).name);
       Fetch l_art_csr Into l_sae_id;
       Close l_art_csr;

       Open l_art_release_csr(l_sae_id);
       Fetch l_art_release_csr into l_sae_release;
       Close l_art_release_csr;

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CREATE_ARTICLES :: l_sae_id:'|| l_sae_id);
       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CREATE_ARTICLES :: l_sae_release:'|| l_sae_release);

       l_catv_tbl_in(1).sav_sae_id        := l_sae_id;
       l_catv_tbl_in(1).sbt_code          := p_articles_tbl(l_ptr).subject_code;
       l_catv_tbl_in(1).cat_type          := 'STA';
       l_catv_tbl_in(1).chr_id            := p_contract_id;
       l_catv_tbl_in(1).cle_id            := p_cle_id;
       l_catv_tbl_in(1).cat_id            := NULL;
       l_catv_tbl_in(1).dnz_chr_id        := p_dnz_chr_id;
       l_catv_tbl_in(1).fulltext_yn       := p_articles_tbl(l_ptr).full_text_yn;
       l_catv_tbl_in(1).sav_sav_release   := l_sae_release;


       Okc_k_article_pub. create_k_article
        (
             p_api_version    => l_api_version,
             p_init_msg_list  => l_init_msg_list,
             x_return_status  => l_return_status,
             x_msg_count      => l_msg_count      ,
             x_msg_data       => l_msg_data        ,
             p_catv_tbl       => l_catv_tbl_in     ,
             x_catv_tbl       => l_catv_tbl_out
        );
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CREATE_ARTICLES ::  Create_k_article status:'|| l_return_status);
        x_return_status := l_return_status;

        If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARITCLES (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;

        End If;


   End Loop;
   x_return_status := l_return_status;

   EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status ;

          WHEN  Others THEN
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).CREATE_ARTICLES :: Error : '||SQLCODE ||':'|| SQLERRM);

End Create_articles;
------------------------------------------------------------------------------------------
/*********function to validate credit card  WHICH  Returns 0' failure,  1' success*****/
------------------------------------------------------------------------------------------

FUNCTION Validate_credit_card
         (
          p_cc_num_stripped       IN  VARCHAR2
         )
  RETURN number IS

  l_stripped_num_table      numeric_tab_typ;   /* Holds credit card number stripped of white spaces */
  l_product_table           numeric_tab_typ;   /* Table of cc digits multiplied by 2 or 1,for validity check */
  l_len_credit_card_num     number := 0;       /* Length of credit card number stripped of white spaces */
  l_product_tab_sum         number := 0;       /* Sum of digits in product table */
  l_actual_cc_check_digit   number := 0;       /* First digit of credit card, numbered from right to left */
  l_mod10_check_digit       number := 0;       /* Check digit after mod10 algorithm is applied */
  j                         number := 0;       /* Product table index */

  BEGIN

        SELECT length(p_cc_num_stripped)
        INTO   l_len_credit_card_num
        FROM   dual;

        FOR i in 1..l_len_credit_card_num
        LOOP
               SELECT to_number(substr(p_cc_num_stripped,i,1))
               INTO   l_stripped_num_table(i)
               FROM   dual;
        END LOOP;

        l_actual_cc_check_digit := l_stripped_num_table(l_len_credit_card_num);

        FOR i in 1..l_len_credit_card_num-1
        LOOP
            IF ( mod(l_len_credit_card_num+1-i,2) > 0 ) THEN

                -- Odd numbered digit.  Store as is, in the product table.
                j := j+1;
                l_product_table(j) := l_stripped_num_table(i);

            ELSE
                -- Even numbered digit.  Multiply digit by 2 and store in the product table.
                -- Numbers beyond 5 result in 2 digits when multiplied by 2. So handled seperately.

                IF (l_stripped_num_table(i) >= 5) THEN

                     j := j+1;
                     l_product_table(j) := 1;
                     j := j+1;
                     l_product_table(j) := (l_stripped_num_table(i) - 5) * 2;

                ELSE

                     j := j+1;
                     l_product_table(j) := l_stripped_num_table(i) * 2;

                END IF;
            END IF;
        END LOOP;

        -- Sum up the product table's digits

        FOR k in 1..j
        LOOP
            l_product_tab_sum := l_product_tab_sum + l_product_table(k);
        END LOOP;

        l_mod10_check_digit := mod( (10 - mod( l_product_tab_sum, 10)), 10);

        -- If actual check digit and check_digit after mod10 don't match, the credit card is an invalid one.

        IF ( l_mod10_check_digit <> l_actual_cc_check_digit) THEN
            return(0);
        ELSE
            return(1);
        END IF;

EXCEPTION
        When Others Then
             OKS_RENEW_PVT.DEBUG_LOG( 'VALIDATE CREDIT CARD ::  Error in Validate Credit card');
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Validate_Credit_Card;


---------------------------------------------------------------------------------------------------
-- function to validate line records WHICH  Returns 0' failure,  1' success
---------------------------------------------------------------------------------------------------

PROCEDURE Validate_Line_Record(
                  p_line_rec        IN   line_Rec_Type,
                  x_return_status   OUT NOCOPY VARCHAR2
)
IS

BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;



     IF   p_line_rec.srv_id IS NULL THEN

          x_return_status :=  OKC_API.G_RET_STS_ERROR;
          ----dbms_output.put_line('K LINE VALIDATION :- SRV ID REQUIRED FOR LINE RECORD');
          OKS_RENEW_PVT.DEBUG_LOG( 'OKS_CONTARACTS_PUB .VALIDATE_LINE_RECORD ::   SRV_Id required for line record');
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' SRV ID REQUIRED FOR LINE RECORD');
          Raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF p_line_rec.organization_id IS NULL THEN

           x_return_status :=  OKC_API.G_RET_STS_ERROR;
           ----dbms_output.put_line('(OKS_CONTRACTS_PUB): K LINE VALIDATION :-  ORGANIZATION ID REQUIRED FOR LINE RECORD');
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::   Organization_Id required for line record');
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' ORGANIZATION ID REQUIRED FOR LINE RECORD');
           Raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF p_line_rec.srv_sdt IS NULL THEN

           x_return_status :=  OKC_API.G_RET_STS_ERROR;
           ----dbms_output.put_line('K LINE VALIDATION :-   SRV START DATE REQUIRED FOR LINE RECORD');
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::   SRV Start_Date required for line record');
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' SRV START DATE REQUIRED FOR LINE RECORD');
           Raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF p_line_rec.srv_edt IS NULL THEN

           x_return_status :=  OKC_API.G_RET_STS_ERROR;
           ----dbms_output.put_line('K LINE VALIDATION :-   SRV END DATE REQUIRED FOR LINE RECORD');
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::   SRV End_Date required for line record');
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' SRV END DATE REQUIRED FOR LINE RECORD');
           Raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF  p_line_rec.k_hdr_id IS NULL THEN

            x_return_status :=  OKC_API.G_RET_STS_ERROR;
            ----dbms_output.put_line('K LINE VALIDATION :-   K_hdr_id REQUIRED FOR LINE RECORD');
            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::   Header_Id required for line record');
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' K_hdr_id REQUIRED FOR LINE RECORD');
            Raise G_EXCEPTION_HALT_VALIDATION;


     ELSIF p_line_rec.org_id IS NULL THEN

           x_return_status :=  OKC_API.G_RET_STS_ERROR;
           ----dbms_output.put_line('K LINE VALIDATION :-   ORG_ID REQUIRED FOR LINE RECORD');
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::   ORG Id required for line record');
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' ORG_ID REQUIRED FOR LINE RECORD');
           Raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (p_line_rec.usage_type = 'VRT' OR p_line_rec.usage_type = 'QTY' OR p_line_rec.usage_type = 'FRT')
           AND ( p_line_rec.usage_period IS NULL) THEN

           x_return_status :=  OKC_API.G_RET_STS_ERROR;
           ----dbms_output.put_line('K LINE VALIDATION :-   USAGE PERIOD REQUIRED FOR LINE RECORD');
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::   Usage_Period required for line record');
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' USAGE PERIOD REQUIRED FOR LINE RECORD');
           Raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (p_line_rec.usage_type = 'VRT' OR p_line_rec.usage_type = 'QTY') AND (p_line_rec.invoicing_rule_type <> -3) THEN

           x_return_status :=  OKC_API.G_RET_STS_ERROR;
           ----dbms_output.put_line('K LINE VALIDATION :-   ARRERS INVOICE TYPE REQUIRED FOR LINE RECORD');
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::  Arrers Invoice Type required for line record');
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, ' ARRERS INVOICE TYPE REQUIRED.');
           Raise G_EXCEPTION_HALT_VALIDATION;

     END IF;

EXCEPTION

   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
   WHEN  Others THEN
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::  Error :'||SQLCODE ||':'|| SQLERRM);

END Validate_Line_Record;


------------------------------------------------------------------------------------------------------
-- Procedure to validate covered product Record
------------------------------------------------------------------------------------------------------

PROCEDURE Validate_Cp_Rec
(
                 p_cp_rec        IN  Covered_level_Rec_Type,
                 p_usage_type    IN  VARCHAR2,
                 x_return_status OUT  NOCOPY VARCHAR2
)
IS

l_msg_data          Varchar2(2000);
l_msg_count         Number;

BEGIN

x_return_status :=  OKC_API.G_RET_STS_SUCCESS;

IF    p_cp_rec.Product_start_date IS NULL THEN

      x_return_status :=  OKC_API.G_RET_STS_ERROR;
      ----dbms_output.put_line('K COVERED PRODUCT VALIDATION :-   PRODUCT START DATE REQUIRED FOR COVERED PRODUCT');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::   Product_Start_Date required for CP');
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRODUCT START DATE REQUIRED FOR COVERED PRODUCT');
      Raise G_EXCEPTION_HALT_VALIDATION;

ELSIF p_cp_rec.Product_end_date IS NULL THEN

      x_return_status :=  OKC_API.G_RET_STS_ERROR;
      ----dbms_output.put_line('K COVERED PRODUCT VALIDATION :-   PRODUCT END DATE REQUIRED FOR COVERED PRODUCT');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::   Product_End_Date required for CP');
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRODUCT END DATE REQUIRED FOR COVERED PRODUCT');
      Raise G_EXCEPTION_HALT_VALIDATION;

ELSIF p_cp_rec.Customer_Product_Id IS NULL THEN

      x_return_status :=  OKC_API.G_RET_STS_ERROR;
      ----dbms_output.put_line('K COVERED PRODUCT VALIDATION :-   PRODUCTID REQUIRED FOR COVERED PRODUCT');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::   Product_Id required for CP');
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRODUCT ID REQUIRED FOR COVERED PRODUCT');
      Raise G_EXCEPTION_HALT_VALIDATION;

ELSIF p_usage_type = 'FRT' AND p_cp_rec.fixed_qty IS NULL THEN

      x_return_status :=  OKC_API.G_RET_STS_ERROR;
      ----dbms_output.put_line('K COVERED PRODUCT VALIDATION :-   FIXED_QTY REQUIRED FOR COVERED PRODUCT');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::  Fixed_qty required for CP');
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'FIXED_QTY REQUIRED FOR COVERED PRODUCT');
      Raise G_EXCEPTION_HALT_VALIDATION;

ELSIF p_usage_type = 'NPR' AND p_cp_rec.negotiated_amount IS NULL THEN

      x_return_status :=  OKC_API.G_RET_STS_ERROR;
      ----dbms_output.put_line('K COVERED PRODUCT VALIDATION :-   NEGOTIATED_AMOUNT REQUIRED FOR COVERED PRODUCT');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::  Negotiated_amount required for CP');
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'NEGOTIATED_AMOUNT REQUIRED FOR COVERED PRODUCT');
      Raise G_EXCEPTION_HALT_VALIDATION;

ELSIF (p_usage_type = 'VRT' OR p_usage_type = 'QTY')AND
      (p_cp_rec.default_qty IS NULL OR p_cp_rec.base_reading IS NULL)THEN

      x_return_status :=  OKC_API.G_RET_STS_ERROR;
      ----dbms_output.put_line('K COVERED PRODUCT VALIDATION :-   DEFAULT_QTY AND BASE_READING REQUIRED REQUIRED FOR COVERED PRODUCT');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::  Default_Qty and Base_reading required for CP');
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DEFAULT_QTY AND BASE_READING REQUIRED FOR COVERED PRODUCT');
      Raise G_EXCEPTION_HALT_VALIDATION;

END IF;

EXCEPTION

  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
  WHEN  Others THEN
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_CP_REC ::  Error :' || SQLCODE ||':'|| SQLERRM);
END Validate_Cp_Rec;


-------------------------------------------------------------------------------------
-- create time value For Billing Schedule
-------------------------------------------------------------------------------------

PROCEDURE Create_timeval( p_line_id        IN   NUMBER,
                          x_time_val       OUT NOCOPY NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2
)
IS

CURSOR l_line_csr(p_cle_id NUMBER) IS
       SELECT dnz_chr_id, start_date
       FROM okc_k_lines_b
       WHERE id = p_cle_id;

l_line_rec            l_line_csr%ROWTYPE;

--Time value
l_tavv_tbl_in         okc_time_pub.tavv_tbl_type;
l_tavv_tbl_out        okc_time_pub.tavv_tbl_type;
l_msg_count           Number;
l_msg_data            VARCHAR2(2000);
l_return_status       VARCHAR2(10) := OKC_API.G_RET_STS_SUCCESS;
l_init_msg_list       VARCHAR2(2000) := OKC_API.G_FALSE;

BEGIN

    OPEN l_line_csr(p_line_id);
    FETCH l_line_csr INTO l_line_rec;

    IF l_line_csr%NOTFOUND THEN

       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'LINE NOT FOUND - CREATE_TIMEVAL');
       Raise G_EXCEPTION_HALT_VALIDATION ;
       Close l_line_csr;
       RETURN;

    ELSE
       Close l_line_csr;
    END IF;

    l_tavv_tbl_in(1).dnz_chr_id  := l_line_rec.dnz_chr_id;
    l_tavv_tbl_in(1).datetime    := l_line_rec.start_date;

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRCACTS_PUB).CREATE_TIMEVAL :: dnz_chr_id: '||l_line_rec.dnz_chr_id);
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRCACTS_PUB).CREATE_TIMEVAL :: datetime: '||l_line_rec.start_date);


    OKC_TIME_PUB.CREATE_TPA_VALUE
     (
      p_api_version     =>    l_api_version,
      p_init_msg_list   =>    l_init_msg_list,
      x_return_status   =>    l_return_status,
      x_msg_count       =>    l_msg_count,
      x_msg_data        =>    l_msg_data,
      p_tavv_tbl        =>    l_tavv_tbl_in,
      x_tavv_tbl        =>    l_tavv_tbl_out
      );

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRCACTS_PUB).CREATE_TIMEVAL :: CREATE_TPA_VALUE status: '||l_return_status);

     x_return_status  := l_return_status;
     If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
           x_time_val  := l_tavv_tbl_out(1).id;
     Else

        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'CREATE_TPA_VALUE');
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRCACTS_PUB).CREATE_TIMEVAL ::  Error in create timeval');
        Raise G_EXCEPTION_HALT_VALIDATION ;

     End If;

    x_return_status := l_return_status;

EXCEPTION

   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
   WHEN  Others THEN
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).VALIDATE_LINE_RECORD ::  Error :'||SQLCODE ||':'|| SQLERRM);

END Create_timeval;



------------------------------------------------------------------------------------------
-- Procedure to create Billing Schedule for recursive billing
------------------------------------------------------------------------------------------

Procedure Create_Bill_Schedule
(
     p_billing_sch         IN    VARCHAR2,
     p_strm_level_tbl      IN    OKS_BILL_SCH.StreamLvl_tbl,
     p_invoice_rule_id     IN    Number,
     x_return_status       OUT NOCOPY VARCHAR2
)
IS
l_bil_sch_out_tbl       OKS_BILL_SCH.ItemBillSch_tbl;
--l_slh_rec               OKS_BILL_SCH.StreamHdr_type;
l_time_val              NUMBER;
l_invoice_rule_id       NUMBER;
l_msg_data              Varchar2(2000);
l_msg_count             Number;

BEGIN

    IF p_strm_level_tbl(1).cle_id IS NULL THEN

             x_return_status := OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE ID REQUIRED FOR SLH');
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Bill_Schedule :: Line Id required for SLH');
            Raise G_EXCEPTION_HALT_VALIDATION ;

    END IF;

-- Commented
-- Rules re-architecture project for 11.5.10
/*
                     l_slh_rec := p_Strm_hdr_rec;
                     If l_slh_rec.Object1_Id1 IS NULL THEN
                         l_slh_rec.Object1_Id1 := '1';
                     END IF;

                     Create_timeval
                     (
                         p_line_id        => l_slh_rec.cle_id,
                         x_time_val       => l_time_val,
                         x_return_status  => x_return_status
                     );

                     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Bill_Schedule :: Create_timeval status:'|| x_return_status);

                     IF x_return_status = 'S' THEN
                           l_slh_rec.Object2_Id1 := l_time_val;
                     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                     END IF;
*/
    l_invoice_rule_id := p_invoice_rule_id;
    IF l_invoice_rule_id IS NULL THEN
       l_invoice_rule_id := -3;
    END IF;

    OKS_BILL_SCH.Create_Bill_Sch_Rules
    (
           p_billing_type         => p_billing_sch ,
           p_sll_tbl              => p_strm_level_tbl,
           p_invoice_rule_id      => l_invoice_rule_id,
           x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
           x_return_status        => x_return_status
     );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Bill_Schedule :: Create_bill_sch_rules status:'|| x_return_status);
     --FND_FILE.PUT_LINE (FND_FILE.LOG,'K BILL SCHEDULE STATUS:-  ' || x_return_status);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

EXCEPTION

   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
      NULL;

  WHEN  Others THEN
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Bill_Schedule :: Error: '||SQLCODE ||':'|| SQLERRM);

END Create_Bill_Schedule;


-----------------------------------------------------------------------------------
-- Billing schedule for one time billing
-----------------------------------------------------------------------------------
Procedure Create_Billing_Schd
(
  P_srv_sdt          IN  Date
, P_srv_edt          IN  Date
, P_amount           IN  Number
, P_chr_id           IN  Number
, P_rule_id          IN  Varchar2
, P_line_id          IN  Number
, P_invoice_rule_id  IN  Number
, X_msg_data        OUT NOCOPY Varchar2
, X_msg_count       OUT NOCOPY Number
, X_Return_status   OUT NOCOPY Varchar2
)
Is

--Scedule Billing
      --l_slh_rec                           OKS_BILL_SCH.StreamHdr_type;
      l_sll_tbl                           OKS_BILL_SCH.StreamLvl_tbl;
      l_bil_sch_out                       OKS_BILL_SCH.ItemBillSch_tbl;
---Time value
      l_tavv_tbl_in                       okc_time_pub.tavv_tbl_type;
      l_tavv_tbl_out                      okc_time_pub.tavv_tbl_type;
      l_tpa_id                            Number;

      l_api_version                       CONSTANT NUMBER       := 1.0;
      l_init_msg_list                     CONSTANT VARCHAR2(1)  := 'F';
      l_return_status                     VARCHAR2(1)  := 'S';
      l_duration                          Number;
      l_timeunits                         Varchar2(25);
  Begin

         x_return_status              := OKC_API.G_RET_STS_SUCCESS;
/* -- Rules Rearchitecture TPA id removed
         l_tavv_tbl_in(1).dnz_chr_id  := P_chr_id;
         l_tavv_tbl_in(1).datetime    := P_srv_sdt;

         OKC_TIME_PUB.CREATE_TPA_VALUE
        (
          p_api_version     =>    l_api_version,
          p_init_msg_list   =>    l_init_msg_list,
          x_return_status   =>    l_return_status,
          x_msg_count       =>    x_msg_count,
          x_msg_data        =>    x_msg_data,
          p_tavv_tbl        =>    l_tavv_tbl_in,
          x_tavv_tbl        =>    l_tavv_tbl_out
        );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Billing_Schd :: Create_TPA_value status:'|| l_return_status ||'Id'||l_tavv_tbl_out(1).id);
         ----dbms_output.put_line('TPA value status '||l_return_status);

         If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
           l_tpa_id  := l_tavv_tbl_out(1).id;
         Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CREATE_TPA_VALUE');
           Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
 */
          Okc_time_util_pub.get_duration
         (
          p_start_date    => P_srv_sdt,
          p_end_date      => P_srv_edt,
          x_duration      => l_duration,
          x_timeunit      => l_timeunits,
          x_return_status => l_return_status
         );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Billing_Schd :: get_duration status:'|| l_return_status);
         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Billing_Schd :: Duration:'|| l_duration ||'time unit' ||l_timeunits);

         ----dbms_output.put_line('get duration status '||l_return_status);

         If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
/*
         l_slh_rec.cle_id                           := P_line_id;
         l_slh_rec.Rule_Information1                := 'E';
         l_slh_rec.Object1_id1                      := '1';
         l_slh_rec.Object1_id2                      := '#';
         l_slh_rec.Jtot_Object1_code                := 'OKS_STRM_TYPE';
         l_slh_rec.Object2_id1                      := l_tpa_id;
         l_slh_rec.Object2_id2                      := '#';
         l_slh_rec.Jtot_object2_code                := 'OKS_TIMEVAL';
         l_slh_rec.Rule_information_category        := 'SLH';
         l_sll_tbl(1).Rule_Id                       := P_rule_id;
         l_sll_tbl(1).Rule_Information1             := '1';
         l_sll_tbl(1).Rule_Information3             := '1';
         l_sll_tbl(1).Rule_Information4             := l_duration;
         l_sll_tbl(1).Rule_Information5             := Null;
         l_sll_tbl(1).Rule_Information6             := p_amount;
         l_sll_tbl(1).Rule_Information7             := Null;
         l_sll_tbl(1).Rule_Information8             := Null;
         l_sll_tbl(1).Rule_Information_Category     := 'SLL';
         l_sll_tbl(1).object1_id1                   := l_timeunits;
         l_sll_tbl(1).jtot_object1_code             := 'OKS_TUOM';
*/

                  l_sll_tbl(1).cle_id                        := P_line_id;
                  l_sll_tbl(1).uom_code                      := l_timeunits;
                  l_sll_tbl(1).sequence_no                   := '1';
                  l_sll_tbl(1).level_periods                 := '1';
                  l_sll_tbl(1).start_date                    := P_srv_sdt;
                  l_sll_tbl(1).uom_per_period                := l_duration;
                  l_sll_tbl(1).advance_periods               := Null;
                  l_sll_tbl(1).level_amount                  := p_amount;
                  l_sll_tbl(1).invoice_offset_days            := Null;
                  l_sll_tbl(1).interface_offset_days         := Null;

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Billing_Schd :: P_amount   :'|| P_amount);
         ----dbms_output.put_line('before bill sch rule ');

         OKS_BILL_SCH.Create_Bill_Sch_Rules
         (
             p_billing_type       =>   'E'
           , p_sll_tbl            =>   l_sll_tbl
           , p_invoice_rule_id    =>   p_invoice_rule_id
           , x_bil_sch_out_tbl    =>   l_bil_sch_out
           , x_return_status      =>   l_return_status
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Billing_Schd :: Create_Bill_Sch_Rules status: '||l_return_status);
          ----dbms_output.put_line('K LINE CREATION :- Create_Bill_Sch_Rules STATUS ' || l_return_status );

          If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Sched Billing Rule (LINE)');
              Raise G_EXCEPTION_HALT_VALIDATION;
          End If;
          x_return_status := l_return_status;

Exception
    When  G_EXCEPTION_HALT_VALIDATION Then
          x_return_status := l_return_status;
        Null;
    When  Others Then
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Billing_Schd :: Error: '|| SQLCODE|| ':' ||SQLERRM);

End;

/*
-------------------------------------------------------------------------------------
-- Procedure to create Rule groups
-------------------------------------------------------------------------------------

Procedure Create_Rule_Grp
(
             p_dnz_chr_id     IN  Number,
             p_chr_id         IN  Number,
             p_cle_id         IN  Number,
             x_rul_grp_id     OUT NOCOPY Number,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_data       OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER
)
IS
   l_rul_grp_id               Number;
   l_return_status            VARCHAR2(100);
   l_msg_count                VARCHAR2(2000);
   l_msg_data                 Number;
   l_api_version     CONSTANT NUMBER      := 1.0;
   l_rgpv_tbl_in              okc_rule_pub.rgpv_tbl_type;
   l_rgpv_tbl_out             okc_rule_pub.rgpv_tbl_type;
   l_msg_data                 Varchar2(2000);
   l_msg_count                Number;

BEGIN

    l_rgpv_tbl_in.delete;


    -----check if rule group exists for given line id if not then create it.

    IF p_cle_id Is NOT NULL THEN         -----------for lines and sub lines level

       l_rul_grp_id := CHECK_RULE_GRP_EXISTS(Null,p_cle_id);

    ELSE               ------for contract level

       l_rul_grp_id := CHECK_RULE_GRP_EXISTS(p_chr_id, NULL);

    END IF;

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Rule_Grp :: Rule group Id:'|| l_rul_grp_id);
    ----dbms_output.put_line('l_rul_grp_id'||l_rul_grp_id);

    IF l_rul_grp_id IS NULL THEN

        ----dbms_output.put_line('G_RULE_GROUP_CODE'||G_RULE_GROUP_CODE);

       l_rgpv_tbl_in(1).chr_id                 := p_chr_id;
       l_rgpv_tbl_in(1).cle_id                 := p_cle_id;
       l_rgpv_tbl_in(1).sfwt_flag              := 'N';
       l_rgpv_tbl_in(1).rgd_code               := G_RULE_GROUP_CODE;
       l_rgpv_tbl_in(1).dnz_chr_id             := p_dnz_chr_id;
       l_rgpv_tbl_in(1).rgp_type               := 'KRG';
       l_rgpv_tbl_in(1).object_version_number  := OKC_API.G_MISS_NUM;
       l_rgpv_tbl_in(1).created_by             := OKC_API.G_MISS_NUM;
       l_rgpv_tbl_in(1).creation_date          := SYSDATE;
       l_rgpv_tbl_in(1).last_updated_by        := OKC_API.G_MISS_NUM;
       l_rgpv_tbl_in(1).last_update_date       := SYSDATE;


       OKC_RULE_PUB.create_rule_group
       (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rgpv_tbl         => l_rgpv_tbl_in,
                 x_rgpv_tbl         => l_rgpv_tbl_out
        );

        x_return_status := l_return_status;
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Rule_Grp :: create_rule_group status:'|| x_return_status);
        --dbms_output.put_line('OKC_RULE_PUB.create_rule_group  = ' || l_return_status);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

             RAISE G_EXCEPTION_HALT_VALIDATION;

        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

             RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        x_rul_grp_id := l_rgpv_tbl_out(1).id;
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Rule_Grp :: Rule group Id: '||x_rul_grp_id);
    ELSE
        x_rul_grp_id := l_rul_grp_id;
    END IF;

EXCEPTION
  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
     null;
  WHEN  Others THEN

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Rule_Grp :: Error:'||SQLCODE ||':'|| SQLERRM );

  -----end rule group check
End Create_Rule_Grp;
*/



--------------------------------------------------------------------------
-- Procedure for creating contacts
----------------------------------------------------------------------------

Procedure Create_contacts(
          p_contract_id        IN  NUMBER,
          p_line_id            IN  NUMBER,
          p_contact_info_tbl   IN  Contact_tbl,
          p_party_role         IN  Party_Role_Rec,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_data           OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER
)
IS


  CURSOR l_thirdparty_csr (p_id Number) IS
         SELECT Party_Id From OKX_CUST_SITE_USES_V
         WHERE  ID1 = p_id;

  CURSOR l_cust_csr (p_contactid Number) IS
         SELECT Party_Id From OKX_CUST_CONTACTS_V
         WHERE  Id1 = p_contactid And id2 = '#';

  CURSOR l_ra_hcontacts_cur (p_contact_id number) Is
         SELECT hzr.object_id, hzr.party_id
	  --NPALEPU
          --18-JUN-2005,08-AUG-2005
          --TCA Project
          --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts view with OKS_RA_HCONTACTS_V.
          --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
         /* FROM ra_hcontacts rah,hz_party_relationships hzr
         WHERE  rah.contact_id  = p_contact_id
         AND    rah.party_relationship_id = hzr.party_relationship_id; */
         FROM OKS_RA_HCONTACTS_V rah,hz_relationships hzr
         WHERE  rah.contact_id  = p_contact_id
         AND rah.party_relationship_id = hzr.relationship_id
         AND hzr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         AND hzr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
         AND hzr.DIRECTIONAL_FLAG = 'F';
         --END NPALEPU

  l_cplv_tbl_in                     okc_contract_party_pub.cplv_tbl_type;
  l_cplv_tbl_out                    okc_contract_party_pub.cplv_tbl_type;
  --Contacts
  l_ctcv_tbl_in                     okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out                    okc_contract_party_pub.ctcv_tbl_type;

  l_partyid_v                       NUMBER;
  l_partyid_t                       NUMBER;
  l_rah_party_id                    NUMBER;
  l_thirdparty_id                   NUMBER;
  l_thirdparty_role                 VARCHAR2(30);
  i                                 NUMBER;
  l_add2partyid                     NUMBER;
  l_hdr_contactid                   NUMBER;
  l_partyid                         NUMBER;
  l_contact_id                      NUMBER;

  l_api_version         CONSTANT    NUMBER  := 1.0;
  l_init_msg_list       CONSTANT    VARCHAR2(1) := OKC_API.G_FALSE;
  l_return_status                   VARCHAR2(1) := 'S';
  l_index                           VARCHAR2 (2000);
  l_msg_data                        VARCHAR2 (2000);
  l_msg_count                       NUMBER;

BEGIN

--Party Role Routine ('VENDOR')
--- debug messages to be included
If p_party_role.scs_code = 'SUBSCRIPTION' then

        Party_Role(
                p_ChrId          => p_contract_id,
                p_cleId          => p_line_id,
                p_Rle_Code       => 'MERCHANT',
                p_PartyId        => p_party_role.authoring_org_id,
                p_Object_Code    => G_JTF_PARTY_VENDOR,
                x_roleid         => l_partyid_v,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                x_return_status  => l_return_status
               );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Merchant Role Creation CPL_Id: '||l_partyid_v);
        --dbms_output.put_line( ' MERCHANT ROLE CREATION :- CPL ID ' || l_partyid_v);

        If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            Raise G_EXCEPTION_HALT_VALIDATION;
        End If;


        --Party Role Routine ('CUSTOMER')

        Party_Role (
                p_ChrId          => p_contract_id,
                        p_cleId          => p_line_id,
                p_Rle_Code       => 'SUBSCRIBER',
                p_PartyId        => p_party_role.party_id,
                p_Object_Code    => G_JTF_PARTY,
                x_roleid         => l_partyid,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                x_return_status  => l_return_status
               );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Subscriber Role Creation CPL_Id: '||l_partyid);
         --dbms_output.put_line( ' SUBSCRIBER ROLE CREATION :- CPL ID ' || l_partyid);

         If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
              Raise G_EXCEPTION_HALT_VALIDATION;
         End If;


Else


         Party_Role (
                p_ChrId          => p_contract_id,
                p_cleId          => p_line_id,
                p_Rle_Code       => 'VENDOR',
                p_PartyId        => p_party_role.authoring_org_id,
                p_Object_Code    => G_JTF_PARTY_VENDOR,
                x_roleid         => l_partyid_v,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                x_return_status  => l_return_status
               );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Vendor Role Creation CPL_Id: '||l_partyid_v);
         --dbms_output.put_line( ' VENDOR ROLE CREATION :- CPL ID ' || l_partyid_v);

         If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
              Raise G_EXCEPTION_HALT_VALIDATION;
         End If;


         --Party Role Routine ('CUSTOMER')

         Party_Role (
                p_ChrId          => p_contract_id,
                p_cleId          => p_line_id,
                p_Rle_Code       => 'CUSTOMER',
                p_PartyId        => p_party_role.party_id,
                p_Object_Code    => G_JTF_PARTY,
                x_roleid         => l_partyid,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                x_return_status  => l_return_status
               );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Customer Role Creation CPL_Id: '||l_partyid);
        --dbms_output.put_line( ' CUSTOMER ROLE CREATION :- CPL ID ' || l_partyid);

        If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

End If;
        Open  l_thirdparty_csr (p_party_role.bill_to_id);
        Fetch l_thirdparty_csr Into l_thirdparty_id;
        Close l_thirdparty_csr;

        If l_thirdparty_Id Is Not Null Then

            If Not l_thirdparty_Id = p_party_role.party_Id Then

                l_thirdparty_role := Nvl(p_party_role.third_party_role, 'THIRD_PARTY');

                --Party Role Routine ('THIRD_PARTY')
                Party_Role (
                       p_ChrId          => p_contract_id,
                       p_cleId          => p_line_id,
                       p_Rle_Code       => l_thirdparty_role,
                       p_PartyId        => l_thirdparty_id,
                       p_Object_Code    => G_JTF_PARTY,
                       x_roleid         => l_partyid_t,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_return_status  => l_return_status
                       );

                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Third Party Role Creation CPL_Id: '||l_partyid_t);
                 --dbms_output.put_line( ' THIRD PARTY ROLE CREATION :- CPL ID ' || l_partyid_t);

                 If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
                     Raise G_EXCEPTION_HALT_VALIDATION;
                 End If;

           End If;
     End If;


If p_contact_info_tbl.count > 0 Then
        i := p_Contact_info_tbl.First;
        Loop

            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Parrt Role: '||p_Contact_info_tbl (i).party_role);
            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Contact Id: '||p_Contact_info_tbl (i).contact_id);
            --dbms_output.put_line( ' CONTACT CREATION :- PARTY ROLE ' ||p_Contact_info_tbl (i).party_role);
            --dbms_output.put_line( ' CONTACT CREATION :- CONTACT ID ' ||p_Contact_info_tbl (i).contact_id );

            l_ctcv_tbl_in.DELETE;

            IF    p_contact_info_tbl (i).party_role = 'VENDOR' And l_partyid_v Is Not Null Then
                  l_add2partyid     := l_partyid_v;
                  l_hdr_contactid   := p_contact_info_tbl (i).contact_id;
            ELSE

                  Open  l_ra_hcontacts_cur (p_contact_info_tbl (i).contact_id);
                  fetch l_ra_hcontacts_cur into l_rah_party_id, l_hdr_contactid;
                  close l_ra_hcontacts_cur;

                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Third Party Id: '||l_thirdparty_id);
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Customer Id: '||p_party_role.party_id);
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Org contact Id: '||p_contact_info_tbl (i).contact_id);
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Rah party contact Id: '||l_rah_party_id);
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Rah contact Id: '||l_hdr_contactid );
                  --dbms_output.put_line( ' CONTACT CREATION :- THIRDP  ID ' ||l_thirdparty_id);
                  --dbms_output.put_line( ' CONTACT CREATION :- CUSTMR  ID ' ||p_party_role.party_id);
                  --dbms_output.put_line( ' CONTACT CREATION :- ORG CTC ID ' ||p_contact_info_tbl (i).contact_id );
                  --dbms_output.put_line( ' CONTACT CREATION :- RAH PTY ID ' ||l_rah_party_id );
                  --dbms_output.put_line( ' CONTACT CREATION :- RAH CTC ID ' ||l_hdr_contactid);

                  IF l_rah_party_id = l_thirdparty_id And l_partyid_t Is Not Null THEN
                     l_add2partyid     := l_partyid_t;
                  ELSE
                     l_add2partyid     := l_partyid;
                  END IF;
             End If;

             IF l_add2partyid Is Null THEN
                    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_contact_info_tbl (i).contact_role
                                        || ' Contact (HEADER) Missing Role Id ' || p_contact_info_tbl (i).contact_object_code);
                    Raise G_EXCEPTION_HALT_VALIDATION;
             End If;


             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: CPL ID: '||l_add2partyid );
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: CRO CD: '||p_contact_info_tbl (i).contact_role);
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: CTC CD: '||l_hdr_contactid);
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: JTO CD: '||p_contact_info_tbl (i).contact_object_code);
             --dbms_output.put_line( ' CONTACT CREATION :- CPL ID ' || l_add2partyid);
             --dbms_output.put_line( ' CONTACT CREATION :- CRO CD ' || p_contact_info_tbl (i).contact_role);
             --dbms_output.put_line( ' CONTACT CREATION :- CTC CD ' || l_hdr_contactid);
             --dbms_output.put_line( ' CONTACT CREATION :- JTO CD ' || p_contact_info_tbl (i).contact_object_code);

             l_ctcv_tbl_in(1).cpl_id                 := l_add2partyid;
             l_ctcv_tbl_in(1).dnz_chr_id             := p_contract_id;
             l_ctcv_tbl_in(1).cro_code               := p_contact_info_tbl (i).contact_role;
             l_ctcv_tbl_in(1).object1_id1            := p_contact_info_tbl (i).contact_id; --l_hdr_contactid;
             l_ctcv_tbl_in(1).object1_id2            := '#';
             l_ctcv_tbl_in(1).jtot_object1_code      := p_contact_info_tbl (i).contact_object_code;

             okc_contract_party_pub.create_contact
             (
                p_api_version   => l_api_version,
                p_init_msg_list => l_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_ctcv_tbl      => l_ctcv_tbl_in,
                x_ctcv_tbl      => l_ctcv_tbl_out
              );

              OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Insert contact status: '||l_return_status );
              --dbms_output.put_line('insert contact'||l_return_status);

              x_return_status := l_return_status;

              If l_return_status = OKC_API.G_RET_STS_SUCCESS then
                   l_contact_id := l_ctcv_tbl_out(1).id;
              Else
                   OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_contact_info_tbl (i).contact_role
                                             || ' Contact (HEADER) ' || p_contact_info_tbl (i).contact_object_code);
                   Raise G_EXCEPTION_HALT_VALIDATION;
              End if;

      Exit When i = p_contact_info_tbl.Last;
               i := p_Contact_info_Tbl.Next(i);
      End Loop;

End If;
 x_return_status := l_return_status;

EXCEPTION
     WHEN  G_EXCEPTION_HALT_VALIDATION THEN
           x_return_status := l_return_status;
     WHEN  Others THEN
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contacts :: Error: '||SQLCODE||':'|| SQLERRM);

END Create_Contacts;





-----------------------------------------------------------------------
-- Procedure Create groups
-----------------------------------------------------------------------

PROCEDURE Create_Groups
(
          p_contract_id     IN  NUMBER,
          p_pdf_id          IN  NUMBER,
          p_chr_group       IN  NUMBER,
          x_return_status   OUT NOCOPY VARCHAR2,
          x_msg_data        OUT NOCOPY VARCHAR2,
          x_msg_count       OUT NOCOPY NUMBER
)
IS
  --Grouping
  l_cgcv_tbl_in                     okc_contract_group_pub.cgcv_tbl_type;
  l_cgcv_tbl_out                    okc_contract_group_pub.cgcv_tbl_type;

  --Approval WorkFlow
  l_cpsv_tbl_in                     okc_contract_pub.cpsv_tbl_type;
  l_cpsv_tbl_out                    okc_contract_pub.cpsv_tbl_type;

  l_grpid                           NUMBER;
  l_pdfid                           NUMBER;
  l_ctrgrp                          NUMBER;
  l_init_msg_list                   VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status                   VARCHAR2(10);
  l_msg_count                       NUMBER;
  l_msg_data                        VARCHAR2(2000);
  l_msg_index_out                   NUMBER;
  l_msg_index                       NUMBER;

BEGIN


--Grouping Routine
      l_cgcv_tbl_in.DELETE;
      l_ctrgrp                                         := Nvl(p_chr_group, Nvl(Fnd_Profile.Value ('OKS_WARR_CONTRACT_GROUP'),2));
      l_cgcv_tbl_in(1).cgp_parent_id                   := l_ctrgrp;
      l_cgcv_tbl_in(1).included_chr_id                 := p_contract_id;
      l_cgcv_tbl_in(1).object_version_number           := OKC_API.G_MISS_NUM;
      l_cgcv_tbl_in(1).created_by                      := OKC_API.G_MISS_NUM;
      l_cgcv_tbl_in(1).creation_date                   := OKC_API.G_MISS_DATE;
      l_cgcv_tbl_in(1).last_updated_by                 := OKC_API.G_MISS_NUM;
      l_cgcv_tbl_in(1).last_update_date                := OKC_API.G_MISS_DATE;
      l_cgcv_tbl_in(1).last_update_login               := OKC_API.G_MISS_NUM;
      l_cgcv_tbl_in(1).included_cgp_id                 := NULL;

      okc_contract_group_pub.create_contract_grpngs
      (
           p_api_version       => l_api_version,
           p_init_msg_list     => l_init_msg_list,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_cgcv_tbl          => l_cgcv_tbl_in,
           x_cgcv_tbl          => l_cgcv_tbl_out
       );

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Groups :: create contract groups status :'|| l_return_status );
       --dbms_output.put_line( 'K HDR CREATION :- GROUPING STATUS ' || l_return_status);

       x_return_status := l_return_status;

       If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_grpid := l_cgcv_tbl_out(1).id;
       Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract Group (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
       End if;


       If p_pdf_id Is Not Null Then

             l_cpsv_tbl_in(1).pdf_id                          := p_pdf_id;
             l_cpsv_tbl_in(1).CHR_ID                          := p_contract_id;
             l_cpsv_tbl_in(1).USER_ID                         := FND_global.user_id;
             l_cpsv_tbl_in(1).IN_PROCESS_YN                   := OKC_API.G_MISS_CHAR;
             l_cpsv_tbl_in(1).object_version_number           := OKC_API.G_MISS_NUM;
             l_cpsv_tbl_in(1).created_by                      := OKC_API.G_MISS_NUM;
             l_cpsv_tbl_in(1).creation_date                   := OKC_API.G_MISS_DATE;
             l_cpsv_tbl_in(1).last_updated_by                 := OKC_API.G_MISS_NUM;
             l_cpsv_tbl_in(1).last_update_date                := OKC_API.G_MISS_DATE;
             l_cpsv_tbl_in(1).last_update_login               := OKC_API.G_MISS_NUM;

             okc_contract_pub.create_contract_process
             (
                 p_api_version        => l_api_version,
                 p_init_msg_list      => l_init_msg_list,
                 x_return_status      => l_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_cpsv_tbl           => l_cpsv_tbl_in,
                 x_cpsv_tbl           => l_cpsv_tbl_out
              );

              OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Groups :: Create contract process status: '|| l_return_status );
              --dbms_output.put_line( 'K HDR CREATION :- PROCESS DEF STATUS ' || l_return_status);

              X_return_status := l_return_status;

              If l_return_status = 'S' then
                    l_pdfid := l_cpsv_tbl_out(1).id;
              Else
                    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract WorkFlow (HEADER)');
                    Raise G_EXCEPTION_HALT_VALIDATION;
              End if;

         End If; -- pdf not null
         x_return_status := l_return_status;

EXCEPTION

  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := l_return_status;
  WHEN  Others THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Groups :: Error: '|| SQLCODE||':'|| SQLERRM);

END Create_Groups;



-------------------------------------------------------------------------------
-- Function for getting contract header Id
-------------------------------------------------------------------------------

Function Get_K_Hdr_Id
(
        P_Type       IN    VARCHAR2
       ,P_Object_ID  IN    NUMBER
       ,P_EndDate    IN    DATE

)
Return NUMBER
Is

 Cursor l_kexists_csr (p_jtf_id VARCHAR2) is
        SELECT  Chr_id
        FROM    OKC_K_REL_OBJS
        WHERE   OBJECT1_ID1 = P_Object_id
        AND     jtot_object1_code  = p_jtf_id;

 Cursor l_wexists_csr (p_jtf_id VARCHAR2) is
        SELECT  Chr_id
        FROM    OKC_K_REL_OBJS
        WHERE   OBJECT1_ID1 = P_Object_id
        AND     jtot_object1_code  = p_jtf_id
        AND     rty_code = 'CONTRACTWARRANTYORDER';

 Cursor l_hdr_csr Is
        SELECT Id Chr_Id
        FROM   OKC_K_HEADERS_V
        WHERE  Attribute1 = p_Object_Id
        AND    End_date   = p_EndDate ;

 l_wchrid       Number;
 l_kchrid       Number;
 l_jtf_id       VARCHAR2(30);

Begin

    IF P_type = 'ORDER' THEN

        l_jtf_id := G_JTF_ORDER_HDR;

        Open l_kexists_csr (l_jtf_id);
        Fetch l_kexists_csr into l_kchrid;
        If l_kexists_csr%Notfound THEN
            Close l_kexists_csr;
            Return(Null);
        END If;

        Close l_kexists_csr;
        Return(l_kchrid);

    ELSIF P_Type = 'RENEW' THEN

        Open  l_hdr_csr;
        Fetch l_hdr_csr Into l_kchrid;
        If l_hdr_csr%Notfound then
             Close l_hdr_csr;
             Return (Null);
        End If;
        Close l_hdr_csr;
        Return (l_kchrid);

     ELSIF P_Type = 'WARR' THEN

          l_jtf_id := G_JTF_ORDER_HDR;
          OPEN  l_wexists_csr (l_jtf_id);
          FETCH l_wexists_csr into l_wchrid;
          IF l_wexists_csr%Notfound THEN
              CLOSE l_wexists_csr;
              RETURN (Null);
          END IF;
          CLOSE   l_wexists_csr;
          RETURN (l_wchrid);
    END IF;

END Get_K_Hdr_Id;


/*----------------------------------------------------------------------------
 Procedure create all rules like
 TAX, QTO, PRE, PTR, CVN, BTO, STO, RPO,
 ARL, IRE, REN, RPT, SBG, RER, CCR, RVE.
-----------------------------------------------------------------------------
*/

PROCEDURE Create_All_Rules
(
          p_contract_rec     IN  OKS_CONTRACTS_PUB.header_rec_type,
          p_rule_grp_id      IN  NUMBER,
          p_dnz_chr_id       IN  NUMBER,
          x_return_status    OUT NOCOPY  VARCHAR2,
          x_msg_data         OUT NOCOPY VARCHAr2,
          x_msg_count        OUT NOCOPY NUMBER

)
IS
  --rules
   --l_rulv_tbl_in                    okc_rule_pub.rulv_tbl_type;
   --l_rulv_tbl_out                   okc_rule_pub.rulv_tbl_type;
   l_khrv_tbl_in                 oks_khr_pvt.khrv_tbl_type;
   l_khrv_tbl_out                oks_khr_pvt.khrv_tbl_type;
  --Agreements/Governance
   l_gvev_tbl_in                    okc_contract_pub.gvev_tbl_type;
   l_gvev_tbl_out                   okc_contract_pub.gvev_tbl_type;
  --miss
   l_init_msg_list                  VARCHAR2(2000) := OKC_API.G_FALSE;
   l_return_status                  VARCHAR2(10);
   l_msg_count                      NUMBER;
   l_msg_data                       VARCHAR2(2000);
   l_msg_index_out                  NUMBER;
   l_msg_index                      NUMBER;
  --program variables
   l_rule_id                        NUMBER;
   l_govern_id                      NUMBER;
   x_credit_card_no                 VARCHAR(40);
   l_validate_cc                    NUMBER;
   l_return_value                   NUMBER;
          l_email_id                    NUMBER;
          l_phone_id                    NUMBER;
          l_fax_id                      NUMBER;
          l_site_id                     NUMBER;

          -- Contact address
          CURSOR address_cur_new( p_contact_id NUMBER ) IS
               SELECT a.id1
                 FROM okx_cust_sites_v a, okx_cust_contacts_v b
                WHERE b.id1 = p_contact_id
                  AND a.id1 = b.cust_acct_site_id;

          -- Primary e-mail address
          CURSOR email_cur_new( p_contact_id NUMBER ) IS
               SELECT contact_point_id
                 FROM okx_contact_points_v
                WHERE contact_point_type = 'EMAIL'
                  AND primary_flag = 'Y'
                  AND owner_table_id = p_contact_id;

          -- Primary telephone number
          CURSOR phone_cur_new( p_contact_id NUMBER ) IS
               SELECT contact_point_id
                 FROM hz_contact_points
                WHERE contact_point_type = 'PHONE'
                  AND NVL( phone_line_type, 'GEN' ) = 'GEN'
                  AND primary_flag = 'Y'
                  AND owner_table_id = p_contact_id;

          -- Any one fax number
          CURSOR fax_cur_new( p_contact_id NUMBER ) IS
               SELECT contact_point_id
                 FROM hz_contact_points
                WHERE contact_point_type = 'PHONE'
                  AND phone_line_type = 'FAX'
                  AND owner_table_id = p_contact_id;

BEGIN


          -- Hdr rules inserted by oks

          l_khrv_tbl_in( 1 ).chr_id               := p_dnz_chr_id;
          l_khrv_tbl_in( 1 ).acct_rule_id         := p_contract_rec.accounting_rule_type;    --ARL

          IF p_contract_rec.renewal_type = 'ERN' THEN
               l_khrv_tbl_in( 1 ).electronic_renewal_flag := 'Y';
              -- l_khrv_tbl_in( 1 ).billing_profile_id      := p_contract_rec.billing_profile_id;
          END IF;

          l_khrv_tbl_in( 1 ).renewal_po_required  := NVL(p_contract_rec.renewal_po, 'N');            --RPO
          l_khrv_tbl_in( 1 ).renewal_price_list   := p_contract_rec.renewal_price_list_id; --RPT
          l_khrv_tbl_in( 1 ).renewal_pricing_type := p_contract_rec.renewal_pricing_type;  --RPT

          IF p_contract_rec.renewal_pricing_type = 'PCT' THEN                              --RPT
               l_khrv_tbl_in( 1 ).renewal_markup_percent  :=p_contract_rec.renewal_markup;
          ELSE
               l_khrv_tbl_in( 1 ).renewal_markup_percent  := NULL;
          END IF;

          IF p_contract_rec.qto_contact_id IS NOT NULL THEN                                --QTO
               l_khrv_tbl_in( 1 ).quote_to_contact_id  := p_contract_rec.qto_contact_id;
               l_khrv_tbl_in( 1 ).quote_to_site_id     := p_contract_rec.qto_site_id;
               l_khrv_tbl_in( 1 ).quote_to_email_id    := p_contract_rec.qto_email_id;
               l_khrv_tbl_in( 1 ).quote_to_phone_id    := p_contract_rec.qto_phone_id;
               l_khrv_tbl_in( 1 ).quote_to_fax_id      := p_contract_rec.qto_fax_id;
          ELSIF p_contract_rec.contact_id IS NOT NULL THEN

               OPEN address_cur_new( p_contract_rec.contact_id );
               FETCH address_cur_new INTO l_site_id;
               CLOSE address_cur_new;

               OPEN email_cur_new( p_contract_rec.contact_id );
               FETCH email_cur_new INTO l_email_id;
               CLOSE email_cur_new;

               OPEN phone_cur_new( p_contract_rec.contact_id );
               FETCH phone_cur_new INTO l_phone_id;
               CLOSE phone_cur_new;

               OPEN fax_cur_new( p_contract_rec.contact_id );
               FETCH fax_cur_new INTO l_fax_id;
               CLOSE fax_cur_new;

               l_khrv_tbl_in( 1 ).quote_to_contact_id :=p_contract_rec.contact_id;
               l_khrv_tbl_in( 1 ).quote_to_site_id    := l_site_id;
               l_khrv_tbl_in( 1 ).quote_to_email_id   := l_email_id;
               l_khrv_tbl_in( 1 ).quote_to_phone_id   := l_phone_id;
               l_khrv_tbl_in( 1 ).quote_to_fax_id     := l_fax_id;

          END IF;

          l_khrv_tbl_in( 1 ).tax_status          := p_contract_rec.tax_status_flag; --TAX
          l_khrv_tbl_in( 1 ).tax_code            := NULL;                           --TAX
          l_khrv_tbl_in( 1 ).tax_exemption_id    := p_contract_rec.tax_exemption_id; --TAX
          l_khrv_tbl_in( 1 ).inv_print_profile   := 'N';

          oks_contract_hdr_pub.create_header(
               p_api_version                   => l_api_version,
               p_init_msg_list                 => l_init_msg_list,
               x_return_status                 => l_return_status,
               x_msg_count                     => x_msg_count,
               x_msg_data                      => x_msg_data,
               p_khrv_tbl                      => l_khrv_tbl_in,
               x_khrv_tbl                      => l_khrv_tbl_out,
               p_validate_yn                   => 'N'
           );
          OKS_RENEW_PVT.DEBUG_LOG('(OKS_EXTWARPRGM_PVT).Create_K_Hdr :: OKS contract header  : '|| l_return_status);
          FND_FILE.PUT_LINE(fnd_file.LOG,'K HDR CREATION :- OKS Contract Header STATUS '|| l_return_status );

          IF NOT l_return_status = okc_api.g_ret_sts_success THEN
               OKC_API.SET_MESSAGE(
                    g_app_name,
                    g_required_value,
                    g_col_name_token,
                    'OKS (HEADER)'
                );
               RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;


/*    IF  p_contract_rec.tax_exemption_id Is Not Null THEN

        l_rulv_tbl_in.DELETE;
        l_rule_id  := Check_Rule_Exists(p_rule_grp_id, 'TAX');
        IF l_rule_id Is NULL THEN

           l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
           l_rulv_tbl_in(1).sfwt_flag                 := 'N';
           l_rulv_tbl_in(1).std_template_yn           := 'N';
           l_rulv_tbl_in(1).warn_yn                   := 'N';
           l_rulv_tbl_in(1).rule_information_category := 'TAX';
           l_rulv_tbl_in(1).object1_id1               := p_contract_rec.tax_exemption_id;
           l_rulv_tbl_in(1).object1_id2               := '#';
           l_rulv_tbl_in(1).JTOT_OBJECT1_CODE         := G_JTF_TAXEXEMP;
           l_rulv_tbl_in(1).object2_id1               := 'TAX_CONTROL_FLAG';
           l_rulv_tbl_in(1).object2_id2               := p_contract_rec.tax_status_flag;
           l_rulv_tbl_in(1).JTOT_OBJECT2_CODE         := G_JTF_TAXCTRL;
           l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
           l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
           l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
           l_rulv_tbl_in(1).creation_date             := SYSDATE;
           l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
           l_rulv_tbl_in(1).last_update_date          := SYSDATE;

           OKC_RULE_PUB.create_rule
           (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
           );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  Tax rule status:'|| l_return_status);
          --dbms_output.put_line( 'K HDR CREATION :- TAX RULE STATUS ' || l_return_Status);
          x_return_status := l_return_status;

          IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
             l_rule_id  := l_rulv_tbl_out(1).id;
          ELSE
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TAX EXEMPTION (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;
  END IF;


  IF p_contract_rec.price_list_id Is Not Null THEN

     l_rulv_tbl_in.DELETE;
     l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'PRE');
     IF  l_rule_id Is NULL THEN

         l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
         l_rulv_tbl_in(1).sfwt_flag                 := 'N';
         l_rulv_tbl_in(1).std_template_yn           := 'N';
         l_rulv_tbl_in(1).warn_yn                   := 'N';
         l_rulv_tbl_in(1).rule_information_category := 'PRE';
         l_rulv_tbl_in(1).object1_id1               := p_contract_rec.price_list_id;
         l_rulv_tbl_in(1).object1_id2               := '#';
         l_rulv_tbl_in(1).JTOT_OBJECT1_CODE         := G_JTF_PRICE;
         l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
         l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).creation_date             := SYSDATE;
         l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).last_update_date          := SYSDATE;
         OKC_RULE_PUB.create_rule
         (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
         );


         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  PRE rule status:'|| l_return_status);
         --dbms_output.put_line( 'K HDR CREATION :- PRE RULE STATUS ' || l_return_Status);
         x_return_status := l_return_status;


         IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            l_rule_id   := l_rulv_tbl_out(1).id;
         ELSE
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRICE LIST (HEADER)');
            Raise G_EXCEPTION_HALT_VALIDATION;
         END IF;

     END IF;
  END IF;
-- QTO rule

   if p_contract_rec.qto_contact_id Is Not Null Then

       l_rulv_tbl_in.delete;
       l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'QTO');
       If l_rule_id Is NULL Then

                l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
                l_rulv_tbl_in(1).sfwt_flag                 := 'N';
                l_rulv_tbl_in(1).std_template_yn           := 'N';
                l_rulv_tbl_in(1).warn_yn                   := 'N';
                l_rulv_tbl_in(1).rule_information_category := 'QTO';
                l_rulv_tbl_in(1).object1_id1               := p_contract_rec.qto_contact_id;
                l_rulv_tbl_in(1).object1_id2               := '#';
                l_rulv_tbl_in(1).JTOT_OBJECT1_CODE         := 'OKX_CCONTACT';
                l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
                l_rulv_tbl_in(1).rule_information1         := p_contract_rec.qto_email_id;
                l_rulv_tbl_in(1).rule_information2         := p_contract_rec.qto_phone_id;
                l_rulv_tbl_in(1).rule_information3         := p_contract_rec.qto_fax_id;
                l_rulv_tbl_in(1).rule_information4         := p_contract_rec.qto_site_id;

                OKC_RULE_PUB.create_rule
                (
                    p_api_version      => l_api_version,
                    x_return_status    => l_return_status,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_rulv_tbl         => l_rulv_tbl_in,
                    x_rulv_tbl         => l_rulv_tbl_out
                  );

                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  QTO rule status:'|| l_return_status);
                 --dbms_output.put_line('K HDR CREATION :- QTO RULE STATUS ' || l_return_Status);

                 If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'QTO RUle (HEADER)');
                        Raise G_EXCEPTION_HALT_VALIDATION;
                 End If;
        End If;

    Elsif p_contract_rec.contact_id Is Not Null Then

          l_rulv_tbl_in.delete;
          l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'QTO');
          If l_rule_id Is NULL Then

                OKS_EXTWAR_UTIL_PUB.Create_Qto_Rule
                (
                    p_api_version   => l_api_version,
                    p_init_msg_list => l_init_msg_list,
                    p_chr_id        => p_dnz_chr_id,
                    p_contact_id    => p_contract_rec.contact_id,
                    x_return_status => l_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data
                 );
                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  QTO rule status:'|| l_return_status);
                 --dbms_output.put_line('K HDR CREATION :- QTO RULE STATUS ' || l_return_Status);

                 If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'QTO RUle (HEADER)');
                      Raise G_EXCEPTION_HALT_VALIDATION;
                 End If;
           End If;
    End If;

    IF  p_contract_rec.payment_term_id Is Not Null THEN

        l_rulv_tbl_in.DELETE;
        l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'PTR');
        IF  l_rule_id Is NULL THEN
            l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
            l_rulv_tbl_in(1).sfwt_flag                 := 'N';
            l_rulv_tbl_in(1).std_template_yn           := 'N';
            l_rulv_tbl_in(1).warn_yn                   := 'N';
            l_rulv_tbl_in(1).rule_information_category := 'PTR';
            l_rulv_tbl_in(1).object1_id1               := p_contract_rec.payment_term_id;
            l_rulv_tbl_in(1).object1_id2               := '#';
            l_rulv_tbl_in(1).JTOT_OBJECT1_CODE         := G_JTF_PAYMENT_TERM;
            l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
            l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
            l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
            l_rulv_tbl_in(1).creation_date             := SYSDATE;
            l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
            l_rulv_tbl_in(1).last_update_date          := SYSDATE;

            OKC_RULE_PUB.create_rule
            (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
            );

            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  PTR rule status:'|| l_return_status);
            x_return_status := l_return_status;
            --dbms_output.put_line( 'K HDR CREATION :- PTR RULE STATUS ' || x_return_Status);


            IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
               l_rule_id    := l_rulv_tbl_out(1).id;
            ELSE
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PAYMENT TERM (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
    END IF;


    IF  p_contract_rec.cvn_type Is Not Null THEN

        l_rulv_tbl_in.DELETE;
        l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'CVN');
        IF l_rule_id Is NULL THEN
           l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
           l_rulv_tbl_in(1).sfwt_flag                 := 'N';
           l_rulv_tbl_in(1).std_template_yn           := 'N';
           l_rulv_tbl_in(1).warn_yn                   := 'N';
           l_rulv_tbl_in(1).rule_information_category := 'CVN';
           l_rulv_tbl_in(1).object1_id1               := p_contract_rec.cvn_type;
           l_rulv_tbl_in(1).object1_id2               := '#';
           l_rulv_tbl_in(1).JTOT_OBJECT1_CODE         := G_JTF_CONV_TYPE;
           l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
           l_rulv_tbl_in(1).rule_information1         := p_contract_rec.cvn_rate;
           l_rulv_tbl_in(1).rule_information2         := to_char(p_contract_rec.cvn_date ,'YYYY/MM/DD HH24:MI:SS') ;
           l_rulv_tbl_in(1).rule_information3         := p_contract_rec.cvn_euro_rate;
           l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
           l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
           l_rulv_tbl_in(1).creation_date             := SYSDATE;
           l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
           l_rulv_tbl_in(1).last_update_date          := SYSDATE;

           OKC_RULE_PUB.create_rule
           (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
            );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  CVN rule status:'|| l_return_status);
           x_return_status := l_return_status;
           --dbms_output.put_line( 'K HDR CREATION :- CVN RULE STATUS ' || l_return_Status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
           Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CONVERSION TYPE (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
           End If;
       END IF;
   END IF;

--Bill To Routine

   If p_contract_rec.bill_to_id Is Not Null Then

      l_rulv_tbl_in.DELETE;
      l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'BTO');
      If l_rule_id Is NULL Then
         l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
         l_rulv_tbl_in(1).sfwt_flag                 := 'N';
         l_rulv_tbl_in(1).std_template_yn           := 'N';
         l_rulv_tbl_in(1).warn_yn                   := 'N';
         l_rulv_tbl_in(1).rule_information_category := 'BTO';
         l_rulv_tbl_in(1).object1_id1               := p_contract_rec.bill_to_id;
         l_rulv_tbl_in(1).object1_id2               := '#';
         l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_BILLTO;
         l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
         l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).creation_date             := SYSDATE;
         l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).last_update_date          := SYSDATE ;

         OKC_RULE_PUB.create_rule
         (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  BTO rule status:'|| l_return_status);
          x_return_status := l_return_status;
          --dbms_output.put_line( 'K HDR CREATION :- BTO RULE STATUS ' || l_return_Status);

          If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             l_rule_id  := l_rulv_tbl_out(1).id;
          Else
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BillTo Id (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
          End If;
       End If;
   End If;

--Ship To Routine

  If p_contract_rec.ship_to_id Is Not Null Then

     l_rulv_tbl_in.DELETE;
     l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'STO');
     If l_rule_id Is NULL Then
        l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
        l_rulv_tbl_in(1).sfwt_flag                 := 'N';
        l_rulv_tbl_in(1).std_template_yn           := 'N';
        l_rulv_tbl_in(1).warn_yn                   := 'N';
        l_rulv_tbl_in(1).rule_information_category := 'STO';
        l_rulv_tbl_in(1).object1_id1               := p_contract_rec.ship_to_id;
        l_rulv_tbl_in(1).object1_id2               := '#';
        l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_SHIPTO;
        l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
        l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
        l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
        l_rulv_tbl_in(1).creation_date             := SYSDATE;
        l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
        l_rulv_tbl_in(1).last_update_date          := SYSDATE;

        OKC_RULE_PUB.create_rule
        (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
         );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  STO rule status:'|| l_return_status);
         x_return_status := l_return_status;
         --dbms_output.put_line( 'K HDR CREATION :- STO RULE STATUS ' || l_return_Status);

         If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
            l_rule_id   := l_rulv_tbl_out(1).id;
         Else
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ShipTo Id (HEADER)');
            Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
      End If;
  End If;

  If p_contract_rec.agreement_id Is Not Null Then

--Agreement ID Routine
     l_gvev_tbl_in(1).chr_id                      := p_dnz_chr_id;
     l_gvev_tbl_in(1).isa_agreement_id            := p_contract_rec.agreement_id;
     l_gvev_tbl_in(1).copied_only_yn              := 'Y';
     l_gvev_tbl_in(1).dnz_chr_id                  := p_dnz_chr_id;

      okc_contract_pub.create_governance
      (
         p_api_version      => l_api_version,
         p_init_msg_list    => l_init_msg_list,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data,
         p_gvev_tbl         => l_gvev_tbl_in,
         x_gvev_tbl         => l_gvev_tbl_out
       );


       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  Agreement rule status:'|| l_return_status);
       --dbms_output.put_line( 'K HDR CREATION :- AGREEMENT RULE STATUS ' || l_return_Status);

       x_return_status  := l_return_status;
       If l_return_status = 'S' then
          l_govern_id := l_gvev_tbl_out(1).id;
       Else
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Agreement Id (HEADER)');
          Raise G_EXCEPTION_HALT_VALIDATION;
       End if;
    End If;

--Accounting Rule ID  Routine

    If p_contract_rec.accounting_rule_type Is Not Null Then

       l_rulv_tbl_in.DELETE;
       l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'ARL');

       If l_rule_id Is NULL Then
          l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
          l_rulv_tbl_in(1).sfwt_flag                 := 'N';
          l_rulv_tbl_in(1).std_template_yn           := 'N';
          l_rulv_tbl_in(1).warn_yn                   := 'N';
          l_rulv_tbl_in(1).rule_information_category := 'ARL';
          l_rulv_tbl_in(1).object1_id1               := p_contract_rec.accounting_rule_type;
          l_rulv_tbl_in(1).object1_id2               := '#';
          l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_ARL;
          l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
          l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).creation_date             := SYSDATE;
          l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).last_update_date          := SYSDATE;

       OKC_RULE_PUB.create_rule
          (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
           );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  ARL rule status:'|| l_return_status);
           x_return_status := l_return_status;
           --dbms_output.put_line( 'K HDR CREATION :- ARL RULE STATUS ' || l_return_Status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
           Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Accounting Id (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
           End If;
       End If;
   End If;

--Invoice Rule ID  Routine

   If p_contract_rec.invoice_rule_type Is Not Null Then

       l_rulv_tbl_in.DELETE;
       l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'IRE');
       If l_rule_id Is NULL Then
          l_rulv_tbl_in(1).rgp_id                      := p_rule_grp_id;
          l_rulv_tbl_in(1).sfwt_flag                   := 'N';
          l_rulv_tbl_in(1).std_template_yn             := 'N';
          l_rulv_tbl_in(1).warn_yn                     := 'N';
          l_rulv_tbl_in(1).rule_information_category   := 'IRE';
          l_rulv_tbl_in(1).object1_id1                 := p_contract_rec.invoice_rule_type;
          l_rulv_tbl_in(1).object1_id2                 := '#';
          l_rulv_tbl_in(1).jtot_object1_code           := G_JTF_IRE;
          l_rulv_tbl_in(1).dnz_chr_id                  := p_dnz_chr_id;
          l_rulv_tbl_in(1).object_version_number       := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).created_by                  := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).creation_date               := SYSDATE;
          l_rulv_tbl_in(1).last_updated_by             := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).last_update_date            := SYSDATE;

          OKC_RULE_PUB.create_rule
          (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
           );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  IRE rule status:'|| l_return_status);
           x_return_status := l_return_status;
           --dbms_output.put_line( 'K HDR CREATION :- IRE RULE STATUS ' || l_return_Status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
           Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Invoice Id (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
           End If;
       End If;
   End If;


--Renewal Type Routine

   If p_contract_rec.renewal_type Is Not Null Then

      l_rulv_tbl_in.DELETE;
      l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'REN');
      If l_rule_id Is NULL Then
         l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
         l_rulv_tbl_in(1).sfwt_flag                 := 'N';
         l_rulv_tbl_in(1).std_template_yn           := 'N';
         l_rulv_tbl_in(1).warn_yn                   := 'N';
         l_rulv_tbl_in(1).rule_information_category := 'REN';
         l_rulv_tbl_in(1).rule_information1         := p_contract_rec.renewal_type;
         l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
         l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).creation_date             := SYSDATE;
         l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).last_update_date          := SYSDATE;

         OKC_RULE_PUB.create_rule
         (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  REN rule status:'|| l_return_status);
          x_return_status := l_return_status;
          --dbms_output.put_line( 'K HDR CREATION :- REN RULE STATUS ' || l_return_Status);

          If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             l_rule_id  := l_rulv_tbl_out(1).id;
          Else
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Renewal Type (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
          End If;
       End If;
   End If;


--Renewal Pricing Type

   If p_contract_rec.renewal_pricing_type Is Not Null Then

      l_rulv_tbl_in.DELETE;
      l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'RPT');
      If l_rule_id Is NULL Then
          If p_contract_rec.renewal_pricing_type = 'PCT' Then
               l_rulv_tbl_in(1).rule_information2  := p_contract_rec.renewal_markup;
          Else
               l_rulv_tbl_in(1).rule_information2  := Null;
          End If;

          l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
          l_rulv_tbl_in(1).sfwt_flag                 := 'N';
          l_rulv_tbl_in(1).std_template_yn           := 'N';
          l_rulv_tbl_in(1).warn_yn                   := 'N';
          l_rulv_tbl_in(1).rule_information_category := 'RPT';
          l_rulv_tbl_in(1).object1_id1               := to_char(p_contract_rec.renewal_price_list_id);
          l_rulv_tbl_in(1).object1_id2               := '#';
          l_rulv_tbl_in(1).JTOT_OBJECT1_CODE         := G_JTF_PRICE;
          l_rulv_tbl_in(1).rule_information1         := p_contract_rec.renewal_pricing_type;
          l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
          l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).creation_date             := SYSDATE;
          l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).last_update_date          := SYSDATE;

          OKC_RULE_PUB.create_rule
          (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
           );


           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  RPT rule status:'|| l_return_status);
           x_return_status := l_return_status;
           --dbms_output.put_line( 'K HDR CREATION :- RPT RULE STATUS ' || l_return_Status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
           Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Renewal Pricing  (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
           End If;
       End If;
   End If;

--Renewal PO Required

   If p_contract_rec.renewal_po Is Not Null Then

      l_rulv_tbl_in.DELETE;
      l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'RPO');
      If l_rule_id Is NULL Then

         l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
         l_rulv_tbl_in(1).sfwt_flag                 := 'N';
         l_rulv_tbl_in(1).std_template_yn           := 'N';
         l_rulv_tbl_in(1).warn_yn                   := 'N';
         l_rulv_tbl_in(1).rule_information_category := 'RPO';
         l_rulv_tbl_in(1).rule_information1         := p_contract_rec.renewal_po;
         l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
         l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).creation_date             := SYSDATE;
         l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).last_update_date          := SYSDATE;

         OKC_RULE_PUB.create_rule
         (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  RPO rule status:'|| l_return_status);
          x_return_status := l_return_status;
          --dbms_output.put_line( 'K HDR CREATION :- RPO RULE STATUS ' || l_return_Status);

          If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             l_rule_id  := l_rulv_tbl_out(1).id;
          Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Renewal PO (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
          End If;
      End If;
  End If;

---AR Interface rule

  IF  p_contract_rec.Ar_interface_yn = 'Y' THEN

      l_rulv_tbl_in.DELETE;
      l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'SBG');

      If l_rule_id Is NULL Then
          l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
          l_rulv_tbl_in(1).sfwt_flag                 := 'N';
          l_rulv_tbl_in(1).std_template_yn           := 'N';
          l_rulv_tbl_in(1).warn_yn                   := 'N';
          l_rulv_tbl_in(1).rule_information_category := 'SBG';
          l_rulv_tbl_in(1).object1_id1               := p_contract_rec.transaction_type;
          l_rulv_tbl_in(1).object1_id2               := '#';
          l_rulv_tbl_in(1).jtot_object1_code         := 'OKS_TRXTYPE';
          l_rulv_tbl_in(1).rule_information11        := p_contract_rec.Ar_interface_yn;
          l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
          l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).creation_date             := SYSDATE;
          l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
          l_rulv_tbl_in(1).last_update_date          := SYSDATE;

          OKC_RULE_PUB.create_rule
          (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
           );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  SBG rule status:'|| l_return_status);
           x_return_status := l_return_status;
           --dbms_output.put_line( 'K HDR CREATION :- SBG RULE STATUS ' || l_return_Status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
           Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'AR Interface (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
           End If;
       End If;
   End If;

--estimated percent
   IF p_contract_rec.estimate_percent IS NOT NULL THEN

      l_rulv_tbl_in.DELETE;
      l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'RER');

      If l_rule_id Is NULL Then
         l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
         l_rulv_tbl_in(1).sfwt_flag                 := 'N';
         l_rulv_tbl_in(1).std_template_yn           := 'N';
         l_rulv_tbl_in(1).warn_yn                   := 'N';
         l_rulv_tbl_in(1).rule_information_category := 'RER';
         l_rulv_tbl_in(1).rule_information1         := TO_CHAR(p_contract_rec.estimate_percent);
         l_rulv_tbl_in(1).rule_information2         := TO_CHAR(p_contract_rec.estimate_duration);
         l_rulv_tbl_in(1).rule_information3         := p_contract_rec.estimate_period;
         l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
         l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).creation_date             := SYSDATE;
         l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).last_update_date          := SYSDATE;

         OKC_RULE_PUB.create_rule
         (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  RER rule status:'|| l_return_status);
          x_return_status := l_return_status;
          --dbms_output.put_line( 'K HDR CREATION :- RER RULE STATUS ' || l_return_Status);

          If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
          Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Estimated Percent (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
          End If;
      End If;
  End If;

--Payment Details
  IF p_contract_rec.Credit_card_no IS NOT NULL THEN

     l_rulv_tbl_in.DELETE;
     l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'CCR');
     If l_rule_id Is NULL Then

        OKS_EXTWAR_UTIL_PVT.strip_white_spaces
        (
                 p_credit_card_num => p_contract_rec.Credit_card_no,
                 p_stripped_cc_num => x_credit_card_no
         );

        l_validate_cc := Validate_Credit_Card(p_cc_num_stripped => x_credit_card_no);

        IF l_validate_cc = 0 THEN            ---failure
              OKC_API.SET_MESSAGE
              (           p_app_name     => 'OKS'
                         ,p_msg_name     => G_INVALID_VALUE
                         ,p_token1       => G_COL_NAME_TOKEN
                         ,p_token1_value => 'Credit Card Number'
               );
               x_return_status := OKC_API.G_RET_STS_ERROR;
               Raise G_EXCEPTION_HALT_VALIDATION;

         ELSIF l_validate_cc = 1 THEN
               ------ERROROUT_AD('ccr rule creation starting : ');

               l_rulv_tbl_in(1).rgp_id                          := p_rule_grp_id;
               l_rulv_tbl_in(1).sfwt_flag                       := 'N';
               l_rulv_tbl_in(1).std_template_yn                 := 'N';
               l_rulv_tbl_in(1).warn_yn                         := 'N';
               l_rulv_tbl_in(1).rule_information_category       := 'CCR';
               l_rulv_tbl_in(1).rule_information1               := x_credit_card_no;
               l_rulv_tbl_in(1).rule_information2               := TO_CHAR(p_contract_rec.Expiry_date ,'YYYY/MM/DD HH24:MI:SS');
               l_rulv_tbl_in(1).dnz_chr_id                      := p_dnz_chr_id;
               l_rulv_tbl_in(1).object_version_number           := OKC_API.G_MISS_NUM;
               l_rulv_tbl_in(1).created_by                      := OKC_API.G_MISS_NUM;
               l_rulv_tbl_in(1).creation_date                   := SYSDATE;
               l_rulv_tbl_in(1).last_updated_by                 := OKC_API.G_MISS_NUM;
               l_rulv_tbl_in(1).last_update_date                := SYSDATE;

               OKC_RULE_PUB.create_rule
               (
                      p_api_version      => l_api_version,
                      x_return_status    => l_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_rulv_tbl         => l_rulv_tbl_in,
                      x_rulv_tbl         => l_rulv_tbl_out
                );

                OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  CCR rule status:'|| l_return_status);
                x_return_status := l_return_status;
                --dbms_output.put_line( 'K HDR CREATION :- CCR RULE STATUS ' || l_return_Status);

                If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                       l_rule_id    := l_rulv_tbl_out(1).id;
                Else
                       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Creadit Card Rule (HEADER)');
                       Raise G_EXCEPTION_HALT_VALIDATION;
                End If;
          END IF;       ---credit card valid
      End If;     ---rule does not exit
  End If;        ----credit card not null


--Payment details estimation
  IF p_contract_rec.estimate_percent IS NOT NULL THEN

     l_rulv_tbl_in.DELETE;
     l_rule_id     := Check_Rule_Exists(p_rule_grp_id, 'RVE');

     If l_rule_id Is NULL Then
        l_rulv_tbl_in(1).rgp_id                    := p_rule_grp_id;
        l_rulv_tbl_in(1).sfwt_flag                 := 'N';
        l_rulv_tbl_in(1).std_template_yn           := 'N';
        l_rulv_tbl_in(1).rule_information_category := 'RVE';
        l_rulv_tbl_in(1).warn_yn                   := 'N';
        l_rulv_tbl_in(1).rule_information1         := p_contract_rec.rve_percent;
        l_rulv_tbl_in(1).rule_information2         := TO_CHAR(p_contract_rec.rve_end_date, 'YYYY/MM/DD HH24:MI:SS');
        l_rulv_tbl_in(1).dnz_chr_id                := p_dnz_chr_id;
        l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
        l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
        l_rulv_tbl_in(1).creation_date             := SYSDATE;
        l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
        l_rulv_tbl_in(1).last_update_date          := SYSDATE;

        OKC_RULE_PUB.create_rule
        (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
         );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  REV rule status:'|| l_return_status);
         x_return_status := l_return_status;
         --dbms_output.put_line( 'K HDR CREATION :- RVE RULE STATUS ' || l_return_Status);

         If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
         Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payment Details Estimation (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
     End If;
 End If;
*/

 x_return_status := l_return_status;

 EXCEPTION
    WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          x_return_status := l_return_status;
    WHEN  Others THEN
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_All_Rules ::  Error:'|| SQLCODE||':'|| SQLERRM);

END Create_All_Rules;


-------------------------------------------------------------------------
-- Procedure Create Sales credits
-------------------------------------------------------------------------

PROCEDURE Create_Sales_Credits
(
          p_salescredit_tbl_in    IN  OKS_CONTRACTS_PUB.SalesCredit_tbl,
          p_contract_id           IN  NUMBER,
          p_line_id               IN  NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2,
          x_msg_data              OUT NOCOPY VARCHAR2,
          x_msg_count             OUT NOCOPY NUMBER
)
IS

--SalesCredit
l_scrv_tbl_in                   oks_sales_credit_pub.scrv_tbl_type;
l_scrv_tbl_out                  oks_sales_credit_pub.scrv_tbl_type;

l_counter                       NUMBER;
l_salescredit_id                NUMBER;
l_api_version       CONSTANT    NUMBER      := 1.0;
l_init_msg_list     CONSTANT    VARCHAR2(1) := OKC_API.G_FALSE;
l_return_status                 VARCHAR2(1) := 'S';
l_index                         VARCHAR2(2000);



 BEGIN

    If p_salescredit_tbl_in.count > 0 Then

       l_counter := p_salescredit_Tbl_in.First;
       Loop

           l_scrv_tbl_in (1).percent                 := p_salescredit_tbl_in(l_counter).percent;
           l_scrv_tbl_in (1).chr_id                  := p_contract_id;
           l_scrv_tbl_in (1).cle_id                  := p_line_id;
           l_scrv_tbl_in (1).ctc_id                  := p_salescredit_tbl_in(l_counter).ctc_id;
           l_scrv_tbl_in (1).sales_credit_type_id1   := p_salescredit_tbl_in(l_counter).sales_credit_type_id;
           l_scrv_tbl_in (1).sales_credit_type_id2   := '#';



            OKS_SALES_CREDIT_PUB.Insert_Sales_Credit
            (
                              p_api_version     => 1.0,
                              p_init_msg_list   => OKC_API.G_FALSE,
                              x_return_status   => l_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_scrv_tbl        => l_scrv_tbl_in,
                              x_scrv_tbl        => l_scrv_tbl_out
              );

              OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Sales_Credits   ::  Insert sales credit status:'|| l_return_status);
              x_return_status := l_return_status;
              --dbms_output.put_line('K LINE CREATION :- SALESCREDIT STATUS ' || l_return_status);

              If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                     l_salescredit_id := l_scrv_tbl_out(1).id;
              Else
                     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Sales Credit Failure');
                     Raise G_EXCEPTION_HALT_VALIDATION;
              End if;

              Exit When l_counter = p_salescredit_Tbl_in.Last;
              l_counter := p_SalesCredit_Tbl_in.Next(l_counter);
          End Loop;
     End If;
     x_return_status := l_return_status;

EXCEPTION
        WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          x_return_status := l_return_status;

        When Others Then
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
              OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Sales_Credits   :: Error:'|| SQLCODE||':'||SQLERRM);


END Create_Sales_Credits;


-----------------------------------------------------------------------------
-- Procedure for creating Object relation
------------------------------------------------------------------------------

Procedure Create_Obj_Rel
(
    p_K_id           IN  Number
,   p_line_id        IN  Number
,   p_orderhdrid     IN  Number
,   p_orderlineid    IN  Number
,   x_return_status  OUT NOCOPY Varchar2
,   x_msg_count      OUT NOCOPY Number
,   x_msg_data       OUT NOCOPY Varchar2
)
Is

 l_api_version   CONSTANT NUMBER       := 1.0;
 l_init_msg_list CONSTANT VARCHAR2(1)  := 'F';
 l_return_status          VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
 l_crjv_tbl_in            OKC_K_REL_OBJS_PUB.crjv_tbl_type;
 l_crjv_tbl_out           OKC_K_REL_OBJS_PUB.crjv_tbl_type;

Begin

    x_return_status := l_return_status;

    If  p_orderhdrid Is Not Null Then

        l_crjv_tbl_in(1).chr_id            := p_K_id;
        l_crjv_tbl_in(1).object1_id1       := p_orderhdrid;
        l_crjv_tbl_in(1).jtot_object1_code := 'OKX_ORDERHEAD';
        l_crjv_tbl_in(1).rty_code          := 'CONTRACTSERVICESORDER';

        OKC_K_REL_OBJS_PUB.CREATE_ROW
        (
           P_API_VERSION    => l_api_version,
           P_INIT_MSG_LIST  => l_init_msg_list,
           X_RETURN_STATUS  => l_return_status,
           X_MSG_COUNT      => x_msg_count,
           X_MSG_DATA       => x_msg_data,
           P_CRJV_TBL       => l_crjv_tbl_in,
           X_CRJV_TBL       => l_crjv_tbl_out
         );
         x_return_status := l_return_status;

         If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then

                     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'OKC_k_rel_objs Create row Error');
                     Raise G_EXCEPTION_HALT_VALIDATION;
         End if;

     ElsIf p_orderlineid Is Not Null Then

           l_crjv_tbl_in(1).cle_id := p_line_id;
           l_crjv_tbl_in(1).object1_id1 := p_orderlineid;
           l_crjv_tbl_in(1).jtot_object1_code := 'OKX_ORDERLINE';
           l_crjv_tbl_in(1).rty_code := 'CONTRACTSERVICESORDER';

           OKC_K_REL_OBJS_PUB.CREATE_ROW
           (
                 P_API_VERSION    => l_api_version,
                 P_INIT_MSG_LIST  => l_init_msg_list,
                 X_RETURN_STATUS  => l_return_status,
                 X_MSG_COUNT      => x_msg_count,
                 X_MSG_DATA       => x_msg_data,
                 P_CRJV_TBL       => l_crjv_tbl_in,
                 X_CRJV_TBL       => l_crjv_tbl_out
             );
             x_return_status := l_return_status;
             If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then

                     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'OKC_k_rel_objs Create row Error');
                     Raise G_EXCEPTION_HALT_VALIDATION;
             End if;

       End If;

Exception

   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          x_return_status := l_return_status;

   When Others Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Obj_Rel ::Error :'||SQLCODE||':'|| SQLERRM);

END Create_Obj_Rel;



-------------------------------------------------------------------
-- Function for Geeting the line id
-------------------------------------------------------------------

Function Get_K_Cle_Id
(
        p_ChrId        Number
     ,  p_InvServiceId Number
     ,  p_StartDate    Date
     ,  p_EndDate      Date
 )  Return Number Is

    Cursor l_Service_Csr  Is
                     Select KL.Id Cle_Id
                     From   OKC_K_LINES_V  KL
                           ,OKC_K_ITEMS_V  KI
                     Where  KL.dnz_chr_id  =  p_ChrId
                     And    KL.lse_id      In (14, 19)
                     And    KL.Id          =  KI.cle_Id
                     And    KI.Object1_Id1 =  p_InvServiceId
--                   And    KL.StartDate   >= p_StartDate
                     And    KL.End_Date    =  p_EndDate;


l_cle_Id          Number;

Begin
        l_cle_id := Null;

        Open l_Service_Csr;
        Fetch l_Service_Csr Into l_cle_Id;
        Close l_Service_csr;
        Return (l_cle_id);

End Get_K_Cle_Id;


--------------------------------------------------------------------
-- Check header Effectivity
--------------------------------------------------------------------

Procedure Check_hdr_Effectivity
(
    p_chr_id      IN NUMBER,
    p_srv_sdt     IN DATE,
    p_srv_edt     IN DATE,
    x_hdr_sdt    OUT NOCOPY DATE,
    x_hdr_edt    OUT NOCOPY DATE,
    x_org_id     OUT NOCOPY Number,
    x_status     OUT NOCOPY  VarChar2
)
Is
    Cursor l_hdr_csr        Is
           Select Start_Date, End_Date ,
                  Authoring_Org_Id From OKC_K_HEADERS_V
           Where  id = p_chr_id;

    l_hdr_csr_rec       l_hdr_csr%ROWTYPE;

Begin

    Open l_hdr_csr;
    Fetch l_hdr_csr Into l_hdr_csr_rec;

    If l_hdr_csr%FOUND Then
        x_org_id := l_hdr_csr_rec.authoring_org_id;
        IF TRUNC(p_srv_sdt) >= TRUNC(l_hdr_csr_rec.Start_Date) AND
                      TRUNC(p_srv_edt) <= TRUNC(l_hdr_csr_rec.End_Date) THEN

            x_Status := 'N';
        ELSE
            If p_srv_sdt >= l_hdr_csr_rec.Start_Date Then
                x_hdr_sdt := l_hdr_csr_rec.Start_Date;
            Else
                x_hdr_sdt := p_srv_sdt;
            End If;

            If p_srv_edt >= l_hdr_csr_rec.End_Date Then
                x_hdr_edt := p_srv_edt;
            Else
                x_hdr_edt := l_hdr_csr_rec.End_Date;
            End If;
            x_Status := 'Y';

         END IF;
    ELSE
        x_Status := 'E';
    END IF;

Exception
    When Others Then
         OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Check_hdr_Effectivity ::Error:  '||SQLCODE ||':'||SQLERRM );

End Check_hdr_Effectivity;
---------------------------------------------------------------------------
-- Priced YN
---------------------------------------------------------------------------

Function Priced_YN
(
      P_LSE_ID IN NUMBER
) RETURN VARCHAR2 IS

  Cursor C_PRICED_YN IS
         Select PRICED_YN
         From  okc_line_styles_B
         Where ID = P_LSE_ID;

  V_PRICED VARCHAR2(50) := 'N';

Begin
   For CUR_C_PRICED_YN IN C_PRICED_YN
   Loop

        V_PRICED := CUR_C_PRICED_YN.PRICED_YN;
        EXIT;

   End Loop;
   Return (V_PRICED);
End Priced_YN;

/*
-----------------------------------------------------------------------------
-- Create rules
------------------------------------------------------------------------------


Procedure create_rules
(
       p_rulv_tbl      IN  okc_rule_pub.rulv_tbl_type
      ,x_rulv_tbl      OUT NOCOPY okc_rule_pub.rulv_tbl_type
      ,x_return_status OUT NOCOPY Varchar2
      ,x_msg_count     OUT NOCOPY Number
      ,x_msg_data      OUT NOCOPY Varchar2
)
Is
  l_rulv_tbl_in            okc_rule_pub.rulv_tbl_type;
  l_rulv_tbl_out           okc_rule_pub.rulv_tbl_type;
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_init_msg_list CONSTANT VARCHAR2(1) := 'F';
  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_index                  NUMBER;
  l_module                 VARCHAR2(50) := 'TBL_RULE.CREATE_ROWS';
  l_debug                  BOOLEAN      := TRUE;

Begin

  x_return_status := l_return_status;

  l_rulv_tbl_in := p_rulv_tbl;

  okc_rule_pub.create_rule
  (
      p_api_version      => l_api_version,
      p_init_msg_list    => l_init_msg_list,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_rulv_tbl         => l_rulv_tbl_in,
      x_rulv_tbl         => l_rulv_tbl_out
   );

   If l_return_status = 'S'  Then
      x_rulv_tbl := l_rulv_tbl_out;
   Else
      x_return_status := l_return_status;
   End If;


Exception
When Others Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).create_rules :: Error:  '||SQLCODE||':'||SQLERRM );

End create_rules;
------------------------------------------------------------------------------------
-- Check for usage
------------------------------------------------------------------------------------
*/

Procedure Check_for_usage
(
     p_CP_id IN Number
   , x_counter_tbl   OUT NOCOPY counter_tbl
   , x_return_status OUT NOCOPY VARCHAR2
   , x_msg_data      OUT NOCOPY VARCHAR2
   , x_msg_count     OUT NOCOPY NUMBER
)
Is

   l_counter_group_id  number ;
   l_counter_id   number ;
   l_usage_item_id number ;
   i number ;


  CURSOR l_Counter_group_csr IS
  SELECT ccg.COUNTER_GROUP_ID COUNTER_GROUP_ID
  FROM   cs_csi_counter_groups ccg,
         csi_counters_b ccb,
         csi_counter_associations cca
  WHERE  ccg.template_flag = 'N'
    AND  ccg.counter_group_id = ccb.group_id
    AND  ccb.counter_id = cca.counter_id
    AND  cca.source_object_code = 'CP'
    AND  cca.source_object_id = p_cp_id;

  CURSOR l_counter_csr (p_counter_group_id NUMBER ) IS
  SELECT counter_id  , usage_item_id
  FROM  csi_counters_b
  WHERE group_id = p_counter_group_id
    AND usage_item_id IS NOT NULL
  ORDER BY usage_item_id;

Begin
    x_return_status := 'S';
    x_counter_tbl.delete;

    Open  l_Counter_group_csr ;
    Fetch l_Counter_group_csr  into l_counter_group_id  ;
    Close l_Counter_group_csr ;

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Check_for_usage :: Counter group Id:  '||l_counter_group_id );
    --dbms_output.put_line('in check for usage'||p_CP_id||'     '||l_counter_group_id);

    i := 1;

    If l_counter_group_id is not null then

        Open l_counter_csr(l_counter_group_id ) ;
        Loop
        Fetch l_counter_csr into l_usage_item_id  , l_counter_id  ;
        Exit When l_counter_csr%notfound ;
                 x_counter_tbl(i).usage_item_id  := l_usage_item_id  ;
                 x_counter_tbl(i).counter_id     := l_counter_id     ;
                 i := i + 1;
        End loop;
        close l_counter_csr ;
    End If;

Exception

When Others Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Check_for_usage ::Error:  '||SQLCODE ||':'||SQLERRM );

End ;

--------------------------------------------------------------------------
-- Create Contract header
--------------------------------------------------------------------------

Procedure Create_Contract_Header
(
      p_K_header_rec                   IN  OKS_CONTRACTS_PUB.header_rec_type
,     p_header_contacts_tbl            IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_header_sales_crd_tbl           IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_header_articles_tbl            IN  OKS_CONTRACTS_PUB.obj_articles_tbl
,     x_chrid                          OUT NOCOPY Number
,     x_return_status                  OUT NOCOPY VARCHAR2
,     x_msg_count                      OUT NOCOPY Number
,     x_msg_data                       OUT NOCOPY VARCHAR2
)

Is


--Contract Header
  l_chrv_tbl_in                 Okc_contract_pub.chrv_tbl_type;
  l_chrv_tbl_out                Okc_contract_pub.chrv_tbl_type;
  l_party_role                  Party_Role_Rec;

--Return IDs

  l_chrid                       NUMBER;
  l_rule_group_id               NUMBER;
  l_rule_id                     NUMBER;
  l_govern_id                   NUMBER;
  l_time_value_id               NUMBER;
  l_contact_id                  NUMBER;
  l_cust_partyid                NUMBER;
  l_findparty_id                NUMBER;
  l_hdr_contactid               NUMBER;
--Miss
  l_api_version     CONSTANT    NUMBER      := 1.0;
  l_init_msg_list   CONSTANT    VARCHAR2(1) := OKC_API.G_FALSE;
  l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_index                       VARCHAR2(2000);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_msg_index_out               NUMBER;
  l_msg_index                   NUMBER;
Begin

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      Okc_context.set_okc_org_context (p_K_header_rec.authoring_org_id, p_K_header_rec.organization_id);

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::CREATE CONTRACT HEADER: ');
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Header merge type     : '||p_k_header_rec.merge_type  );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Header Status code    : '||p_k_header_rec.sts_code  );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Header SCS code       : '||p_k_header_rec.scs_code  );


       If p_k_header_rec.merge_type = 'NEW' Then

          If (p_k_header_rec.merge_object_id Is Not NULL) Then
              l_chrid := p_k_header_rec.merge_object_id;
          Else
              l_chrid := Null;
          End if;

      ElsIf p_k_header_rec.merge_type = 'LTC' Then

              l_chrid := p_k_header_rec.merge_object_id;

      ElsIf p_k_header_rec.merge_type Is Not Null Then

              l_chrid := GET_K_HDR_ID (
                                       p_type        => p_k_header_rec.merge_type,
                                       p_object_id   => p_k_header_rec.merge_object_id ,
                                       p_enddate     => p_k_header_rec.end_date
                                       );
      End If;


      If l_chrid Is Not Null Then

            --dbms_output.put_line('K HDR CREATION :- CHR ID IS NOT NULL ');
            --dbms_output.put_line('K HDR CREATION :- CHR ID Status '||p_k_header_rec.sts_code);

            If p_k_header_rec.sts_code Not In ('TERMINATED','EXPIRED','CANCELLED') Then

                x_chrid := l_chrid;
                l_return_status := OKC_API.G_RET_STS_SUCCESS;
                Raise G_EXCEPTION_HALT_VALIDATION;

            End If;

      End If;

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header :: Header Id:   '||to_char(l_chrid) );
      --Contract Header Routine

      If Nvl(p_k_header_rec.sts_code,'ENTERED') = 'ACTIVE' Then
          l_chrv_tbl_in(1).date_signed     := p_k_header_rec.start_date;
          l_chrv_tbl_in(1).date_approved   := p_k_header_rec.start_date;
      Else
          l_chrv_tbl_in(1).date_signed     := Null;
          l_chrv_tbl_in(1).date_approved   := Null;
      End If;

      If p_k_header_rec.cust_po_number is not null then
             l_chrv_tbl_in(1).cust_po_number_req_yn := 'Y';
      Else
            l_chrv_tbl_in(1).cust_po_number_req_yn := 'N';
      End If;


      l_chrv_tbl_in(1).sfwt_flag                      := 'N';
      l_chrv_tbl_in(1).contract_number                := p_k_header_rec.contract_number;
      l_chrv_tbl_in(1).sts_code                       := NVL(p_k_header_rec.sts_code, 'ACTIVE');
      l_chrv_tbl_in(1).scs_code                       := NVL(p_k_header_rec.scs_code, 'WARRANTY');
      l_chrv_tbl_in(1).authoring_org_id               := p_k_header_rec.authoring_org_id;
      l_chrv_tbl_in(1).inv_organization_id            := okc_context.get_okc_organization_id;
      l_chrv_tbl_in(1).pre_pay_req_yn                 := 'N';
      l_chrv_tbl_in(1).cust_po_number                 := p_k_header_rec.cust_po_number;
      l_chrv_tbl_in(1).qcl_id                         := p_k_header_rec.qcl_id ;
      l_chrv_tbl_in(1).short_description              := Nvl(p_k_header_rec.short_description,'Warranty/Extended Warranty');
      l_chrv_tbl_in(1).template_yn                    := 'N';
      l_chrv_tbl_in(1).start_date                     := p_k_header_rec.start_date;
      l_chrv_tbl_in(1).end_date                       := p_k_header_rec.end_date;
      l_chrv_tbl_in(1).chr_type                       := OKC_API.G_MISS_CHAR;
      l_chrv_tbl_in(1).archived_yn                    := 'N';
      l_chrv_tbl_in(1).deleted_yn                     := 'N';
      l_chrv_tbl_in(1).created_by                     := OKC_API.G_MISS_NUM;
      l_chrv_tbl_in(1).creation_date                  := SYSDATE;
      l_chrv_tbl_in(1).last_updated_by                := OKC_API.G_MISS_NUM;
      l_chrv_tbl_in(1).last_update_date               := SYSDATE;
      l_chrv_tbl_in(1).currency_code                  := p_k_header_rec.currency;
      l_chrv_tbl_in(1).buy_or_sell                    := 'S';
      l_chrv_tbl_in(1).issue_or_receive               := 'I';
      l_chrv_tbl_in(1).Attribute1                     := p_k_header_rec.attribute1;
      l_chrv_tbl_in(1).Attribute2                     := p_k_header_rec.attribute2;
      l_chrv_tbl_in(1).Attribute3                     := p_k_header_rec.attribute3;
      l_chrv_tbl_in(1).Attribute4                     := p_k_header_rec.attribute4;
      l_chrv_tbl_in(1).Attribute5                     := p_k_header_rec.attribute5;
      l_chrv_tbl_in(1).Attribute6                     := p_k_header_rec.attribute6;
      l_chrv_tbl_in(1).Attribute7                     := p_k_header_rec.attribute7;
      l_chrv_tbl_in(1).Attribute8                     := p_k_header_rec.attribute8;
      l_chrv_tbl_in(1).Attribute9                     := p_k_header_rec.attribute9;
      l_chrv_tbl_in(1).Attribute10                    := p_k_header_rec.attribute10;
      l_chrv_tbl_in(1).Attribute11                    := p_k_header_rec.attribute11;
      l_chrv_tbl_in(1).Attribute12                    := p_k_header_rec.attribute12;
      l_chrv_tbl_in(1).Attribute13                    := p_k_header_rec.attribute13;
      l_chrv_tbl_in(1).Attribute14                    := p_k_header_rec.attribute14;
      l_chrv_tbl_in(1).Attribute15                    := p_k_header_rec.attribute15;
      -- rules seeded by okc
      l_chrv_tbl_in( 1 ).price_list_id        := p_k_header_rec.price_list_id;                               --PRE
      l_chrv_tbl_in( 1 ).payment_term_id      := p_k_header_rec.payment_term_id;                             --PTR
      l_chrv_tbl_in( 1 ).conversion_type      := p_k_header_rec.cvn_type;                                    --CVN
      l_chrv_tbl_in( 1 ).conversion_rate      := p_k_header_rec.cvn_rate;                                    --CVN
      l_chrv_tbl_in( 1 ).conversion_rate_date := TO_CHAR( p_k_header_rec.cvn_date, 'YYYY/MM/DD HH24:MI:SS' );--CVN
      l_chrv_tbl_in( 1 ).conversion_euro_rate := p_k_header_rec.cvn_euro_rate;                               --CVN
      l_chrv_tbl_in( 1 ).bill_to_site_use_id  := p_k_header_rec.bill_to_id;                                  --BTO
      l_chrv_tbl_in( 1 ).ship_to_site_use_id  := p_k_header_rec.ship_to_id;                                  --STO
      l_chrv_tbl_in( 1 ).inv_rule_id          := p_k_header_rec.invoice_rule_type;                             --IRE

      IF p_k_header_rec.renewal_type IS NOT NULL THEN --REN
               IF p_k_header_rec.renewal_type = 'ERN' THEN
                    l_chrv_tbl_in( 1 ).renewal_type_code := 'NSR';
               ELSE
                    l_chrv_tbl_in( 1 ).renewal_type_code :=  p_k_header_rec.renewal_type;
               END IF;
      END IF;


      If p_k_header_rec.merge_type = 'RENEW' Then
          l_chrv_tbl_in(1).Attribute1 := p_k_header_rec.merge_object_id;
      End If;

      Okc_contract_pub.create_contract_header
      (
          p_api_version     => l_api_version,
          p_init_msg_list       => l_init_msg_list,
          p_chrv_tbl            => l_chrv_tbl_in,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_chrv_tbl            => l_chrv_tbl_out
       );

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header :: Create_contract_header status:  '||l_return_status  );
       --dbms_output.put_line( 'K HDR CREATION :- HDR STATUS ' || l_return_status);
       x_return_status := l_return_status;

       If l_return_status = 'S' then
             l_chrid := l_chrv_tbl_out(1).id;
             x_chrid := l_chrv_tbl_out(1).id;
       Else
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'HEADER (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
       End if;

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header :: Header Id:   '||to_char(l_chrid) );

      /* ----create rules group

       Create_Rule_grp
        (
         p_dnz_chr_id    => l_chrid,
         p_chr_id        => l_chrid,
         p_cle_id        => NULL,
         x_rul_grp_id    => l_rule_group_id,
         x_return_status => l_return_status,
         x_msg_data      => x_msg_data,
         x_msg_count     => x_msg_count
        );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Create_Rule_grp status :  '||l_return_status  );

        x_return_status := l_return_status;
        If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
        End If;*/

        --dbms_output.put_line( 'K HDR CREATION :- RULE GROUP STATUS '||l_return_status);

        l_party_role.authoring_org_id  := p_k_header_rec.authoring_org_id;
        l_party_role.party_id          := p_k_header_rec.party_id;
        l_party_role.bill_to_id        := p_k_header_rec.bill_to_id;
        l_party_role.third_party_role  := p_k_header_rec.third_party_role;
        l_party_role.scs_code          := p_k_header_rec.scs_code;


        --------creating contacts info

        Create_contacts
        (
           p_contract_id       => l_chrid,
           p_line_id           => NULL,
           p_contact_info_tbl  => p_header_contacts_tbl,
           p_party_role        => l_party_role,
           x_return_status     => l_return_status,
           x_msg_data          => x_msg_data,
           x_msg_count         => x_msg_count
        );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Create_contacts status :  '||l_return_status  );
        --dbms_output.put_line('COntacts'||l_return_status);
        x_return_status := l_return_status;

        If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
            Raise G_EXCEPTION_HALT_VALIDATION;
        End If;


        -------end creating contacts info

        ----CONTRACT GROUPING and approval work flow

        Create_Groups
        (
           p_contract_id     => l_chrid,
           p_pdf_id          => p_k_header_rec.pdf_id,
           p_chr_group       => p_k_header_rec.chr_group,
           x_return_status   => l_return_status,
           x_msg_data        => x_msg_data,
           x_msg_count       => x_msg_count
        );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Create_Groups status :  '||l_return_status  );
        --dbms_output.put_line('create group'||l_return_status);
        x_return_status := l_return_status;

        If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
              Raise G_EXCEPTION_HALT_VALIDATION;
        End If;


        ----END CONTRACT GROUPING


        Create_All_Rules
        (
          p_contract_rec   => p_k_header_rec,
          p_rule_grp_id    => l_rule_group_id,
          p_dnz_chr_id     => l_chrid,
          x_return_status  => l_return_status,
          x_msg_data       => x_msg_data,
          x_msg_count      => x_msg_count
        );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Create_All_Rules status :  '||l_return_status  );
         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Rule group Id :  '||to_char(l_rule_group_id)  );

         x_return_status := l_return_status;

         If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'HEADER RULES NOT CREATED (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

         --dbms_output.put_line( 'K HDR CREATION :- RULES CREATION STATUS '||l_return_status);

         ----create sales credit
         Create_Sales_Credits
         (
            p_salescredit_tbl_in  => p_header_sales_crd_tbl,
            p_contract_id         => l_chrid,
            p_line_id             => NULL,
            x_return_status       => l_return_status,
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count
         );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Create_Sales_Credits status :  '||l_return_status  );
         x_return_status := l_return_status;

         --dbms_output.put_line( 'K HDR CREATION :- Sales Credit STATUS '||l_return_status);

         If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

         ----create obj rel
         Create_Obj_Rel
         (
           p_K_id            => l_chrid,
           p_line_id         => Null,
           p_orderhdrid      => p_k_header_rec.order_hdr_id,
           p_orderlineid     => Null,
           x_return_status   => l_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Create_Obj_Rel status :  '||l_return_status  );
          x_return_status := l_return_status;

          If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
            Raise G_EXCEPTION_HALT_VALIDATION;
          End If;

          --dbms_output.put_line( 'K HDR CREATION :- OBJ RULE STATUS ' || l_return_Status);


         Create_articles
         (
             p_articles_tbl  => p_header_articles_tbl,
             p_contract_id   => l_chrid,
             p_cle_id        => NULL,
             P_dnz_chr_id    => l_chrid,
             x_return_status => l_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::create_articles status :  '||l_return_status  );
          x_return_status := l_return_status;
          --dbms_output.put_line( 'K HDR CREATION :- ARTICLE CREATION ' || l_return_Status);

          If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
          End If;

          x_chrid := l_chrid;

  EXCEPTION
          WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          x_return_status := l_return_status;
  WHEN  Others THEN
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract_Header ::Error :  '||SQLCODE|| ':'||SQLERRM  );

  END Create_Contract_Header;

-----------------------------------------------------------------------------
-- Get top line and sub line numbers
-----------------------------------------------------------------------------

Function get_top_line_number(p_chr_id IN Number)
Return Number
Is
max_line_number Number;
Cursor get_line_number Is
     Select  NVL(Max(TO_NUMBER(line_number)),0) +1
     From okc_k_lines_b
     Where  dnz_chr_id = p_chr_id
     And    lse_id in (1,12,14,19,46);

Begin

   open get_line_number;
   Fetch get_line_number Into max_line_number;
   close get_line_number;

   Return(max_line_number);

End get_top_line_number;





Function get_sub_line_number(p_chr_id IN Number,p_cle_id IN NUMBER)
Return Number
Is
max_line_number Number;
Cursor get_line_number Is
     Select  NVL(Max(TO_NUMBER(line_number)),0) +1
     From okc_k_lines_b
     Where  dnz_chr_id = p_chr_id
     And    cle_id = p_cle_id
     And    lse_id in (35,7,8,9,10,11,13,18,25);

Begin

   open get_line_number;
   Fetch get_line_number Into max_line_number;
   close get_line_number;

   Return(max_line_number);

End get_sub_line_number;


-------------------------------------------------------------------------
-- Create service line
-------------------------------------------------------------------------

Procedure Create_Service_Line
(
   p_k_line_rec          IN     line_Rec_Type
  ,p_Contact_tbl         IN     Contact_Tbl
  ,p_line_sales_crd_tbl  IN     SalesCredit_Tbl
  ,x_service_line_id     OUT NOCOPY   Number
  ,x_return_status       OUT NOCOPY   Varchar2
  ,x_msg_count           OUT NOCOPY   Number
  ,x_msg_data            OUT NOCOPY   Varchar2
)
Is

    l_api_version             CONSTANT  NUMBER  := 1.0;
    l_init_msg_list           CONSTANT  VARCHAR2(1) := OKC_API.G_FALSE;
    l_return_status                     VARCHAR2(1) := 'S';
    l_index                             VARCHAR2(2000);

    l_ctcv_tbl_in                       Okc_contract_party_pub.ctcv_tbl_type;
    l_ctcv_tbl_out                      Okc_contract_party_pub.ctcv_tbl_type;
    l_bill_sch_out                      OKS_BILL_SCH.ItemBillSch_tbl;
    l_msg_index                         Number;
    l_klnv_tbl_in                 oks_kln_pvt.klnv_tbl_type;
    l_klnv_tbl_out                oks_kln_pvt.klnv_tbl_type;


    Cursor l_ctr_csr (p_id Number) Is
                  Select Counter_Group_id
                  From   OKX_CTR_ASSOCIATIONS_V
                  Where  Source_Object_Id = p_id;

    Cursor l_billto_csr (p_billto Number) Is
                  Select cust_account_id from OKX_CUST_SITE_USES_V
                  where  id1 = p_billto and id2 = '#';

    Cursor l_ra_hcontacts_cur (p_contact_id number) Is
                  Select hzr.object_id, hzr.party_id
		  --NPALEPU
                  --18-JUN-2005,08-AUG-2005
                  --TCA Project
                  --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts view with OKS_RA_HCONTACTS_V
                  --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
                  /* From ra_hcontacts rah,  hz_party_relationships hzr
                  Where  rah.contact_id  = p_contact_id
                  And    rah.party_relationship_id = hzr.party_relationship_id; */
                  From OKS_RA_HCONTACTS_V rah,  hz_relationships hzr
                  Where  rah.contact_id  = p_contact_id
                  And    rah.party_relationship_id = hzr.relationship_id
                  AND hzr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
                  AND hzr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
                  AND hzr.DIRECTIONAL_FLAG = 'F';
                  --END NPALEPU

    CURSOR l_header_csr (p_header_id number) IS
                  SELECT id,scs_code
                  FROM okc_k_headers_b
                  WHERE id =  p_header_id;

    CURSOR l_template_csr (p_srv_id  NUMBER, p_orgid  NUMBER) IS
                  SELECT coverage_template_id
                  FROM okx_system_items_v
                  WHERE id1 = p_srv_id
                  AND organization_id = p_orgid;


    l_header_rec                        l_header_csr%ROWTYPE;
    l_ctr_grpid                         Varchar2(40);
    l_template_id                       NUMBER;

    --Contract Line Table
    l_clev_tbl_in                       okc_contract_pub.clev_tbl_type;
    l_clev_tbl_out                      okc_contract_pub.clev_tbl_type;

    --Contract Item
    l_cimv_tbl_in                       okc_contract_item_pub.cimv_tbl_type;
    l_cimv_tbl_out                      okc_contract_item_pub.cimv_tbl_type;

    --Rule Related

    --l_rgpv_tbl_in                       okc_rule_pub.rgpv_tbl_type;
    --l_rgpv_tbl_out                      okc_rule_pub.rgpv_tbl_type;

    --l_rulv_tbl_in                       okc_rule_pub.rulv_tbl_type;
    --l_rulv_tbl_out                      okc_rule_pub.rulv_tbl_type;

    --Time Value Related
    l_isev_ext_tbl_in                   okc_time_pub.isev_ext_tbl_type;
    l_isev_ext_tbl_out                  okc_time_pub.isev_ext_tbl_type;

    --SalesCredit
    l_scrv_tbl_in                       oks_sales_credit_pub.scrv_tbl_type;
    l_scrv_tbl_out                      oks_sales_credit_pub.scrv_tbl_type;

    --Obj Rel
    l_crjv_tbl_out                      OKC_K_REL_OBJS_PUB.crjv_tbl_type;

    --Coverage
    l_cov_rec                           OKS_COVERAGES_PUB.ac_rec_type;

    --Counters
    l_ctr_grp_id_template               NUMBER;
    l_ctr_grp_id_instance               NUMBER;

    --Return IDs

    l_line_id                           NUMBER;
    l_rule_group_id                     NUMBER;
    l_rule_id                           NUMBER;
    l_line_item_id                      NUMBER;
    l_time_value_id                     NUMBER;
    l_cov_id                            NUMBER;
    l_salescredit_id                    NUMBER;
    l_organization_id                   NUMBER;


    --TimeUnits
    l_duration                          NUMBER;
    l_timeunits                         VARCHAR2(240);


    --General
    l_hdrsdt                            DATE;
    l_hdredt                            DATE;
    l_hdrstatus                         CHAR;
    l_hdrorgid                          Number;
    l_line_lse_id                       NUMBER;
    l_line_jtot_obj_code                VARCHAR2(30) := NULL;
    i                                   NUMBER;
    l_can_object                        NUMBER;
    l_line_party_role_id                NUMBER;
    l_lin_party_id                      NUMBER;
    l_lin_contactid                     NUMBER;
    l_line_contact_id                   NUMBER;
    l_role                              VARCHAR2(40);
    l_obj                               VARCHAR2(40);
    l_msg_index_out                     NUMBER;
    l_org                               Number;
    l_msg_data                          Varchar2(2000);
    l_msg_count                         Number;


    BEGIN

     x_return_status                := OKC_API.G_RET_STS_SUCCESS;

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: CREATE SERVICE LINE FOR LINE TYPE :  '||p_k_line_rec.line_type  );

     Validate_Line_Record
     (         p_line_rec => p_k_line_rec,
               x_return_status  => l_return_status
     );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Validate_Line_Record status       :  '||l_return_status  );
     --dbms_output.put_line('validate line rec'||l_return_status);

     IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
         Raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

     OPEN l_header_csr(p_k_line_rec.k_hdr_id);
     FETCH l_header_csr INTO l_header_rec;

     IF l_header_csr%NOTFOUND THEN
         Close l_header_csr;
         l_return_status := 'E';
         Raise G_EXCEPTION_HALT_VALIDATION;
     ELSE
         Close l_header_csr;
     END IF;

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line   :: Header Scs code                  :  '||l_header_rec.scs_code  );
     --dbms_output.put_line('header id '|| l_header_rec.id);
     --dbms_output.put_line('header scs code '||l_header_rec.scs_code ||' line type' ||p_K_line_rec.line_type );

     Okc_context.set_okc_org_context (p_K_line_rec.org_id, p_K_line_rec.organization_id);


     IF l_header_rec.scs_code = 'WARRANTY' AND p_K_line_rec.line_type = 'W' THEN          ----warranty
         l_line_lse_id := 14;
         l_line_jtot_obj_code := 'OKX_WARRANTY';

     ELSIF l_header_rec.scs_code = 'WARRANTY' AND p_K_line_rec.line_type = 'E' THEN       ---ext warranty
         l_line_lse_id := 19;
         l_line_jtot_obj_code := 'OKX_SERVICE';

     ELSIF l_header_rec.scs_code = 'SERVICE' AND p_K_line_rec.line_type = 'U' THEN        ----usage
         l_line_lse_id := 12;
         l_line_jtot_obj_code := 'OKX_USAGE';

     ELSIF l_header_rec.scs_code = 'SERVICE' AND p_K_line_rec.line_type = 'S' THEN        ---SERVICE
         l_line_lse_id := 1;
         l_line_jtot_obj_code := 'OKX_SERVICE';

     ELSIF l_header_rec.scs_code = 'SUBSCRIPTION' AND p_K_line_rec.line_type = 'SB' THEN  -- SUBSCRIPTION
         l_line_lse_id := 46;
         l_line_jtot_obj_code := 'OKS_SUBSCRIPTION' ; --'OKX_CUSTPROD';

     ELSIF l_header_rec.scs_code = 'SUBSCRIPTION' AND p_K_line_rec.line_type = 'S' THEN   -- SUBSCRIPTION
         l_line_lse_id := 1;
         l_line_jtot_obj_code := 'OKX_SERVICE';

     ELSE
         x_return_status := 'E';
         Raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Line Lse Id :  '||l_line_lse_id  );
     --dbms_output.put_line('Line lse id'||l_line_lse_id);


     l_Line_id := Get_K_Cle_Id
                  (
                       p_ChrId        => l_header_rec.id
                    ,  p_InvServiceId => p_k_line_rec.srv_id
                    ,  p_StartDate    => p_k_line_rec.srv_sdt
                    ,  p_EndDate      => p_k_line_rec.srv_edt
                  );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Line Id :  '||to_char(l_line_id ));
     --dbms_output.put_line('K LINE CREATION :- LINE ID ' || l_line_id);

     If l_line_id Is Not Null Then
             x_Service_Line_id := l_line_id;
             x_return_status := OKC_API.G_RET_STS_SUCCESS;
     End If;


     Check_hdr_effectivity
     (
          p_chr_id          =>  l_header_rec.id,
          p_srv_sdt         =>  p_k_line_rec.srv_sdt,
          p_srv_edt         =>  p_k_line_rec.srv_edt,
          x_hdr_sdt         =>  l_hdrsdt,
          x_hdr_edt         =>  l_hdredt,
          x_org_id          =>  l_hdrorgid,
          x_status          =>  l_hdrstatus
      );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: check_hdr_effectivity status :  '||l_hdrstatus  );
     --x_return_status := l_return_status;

     If l_hdrstatus = 'N' Then
            NULL;

     ElsIf l_hdrstatus = 'Y' Then
           x_return_status := OKC_API.G_RET_STS_ERROR;
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE EFFECTIVITY SHOULD BE WITH IN CONTRACT EFFECTIVITY');
           Raise G_EXCEPTION_HALT_VALIDATION;

     End If;
     --dbms_output.put_line('Check header Effectivity status '||x_return_status);



     If p_k_line_rec.line_type = 'SB' then
            l_clev_tbl_in(1).price_negotiated    := p_k_line_rec.negotiated_amount;
     Else
            l_clev_tbl_in(1).price_negotiated    := Null;
     End If;

     l_clev_tbl_in(1).chr_id              := l_header_rec.id;
     l_clev_tbl_in(1).sfwt_flag           := 'N';
     l_clev_tbl_in(1).lse_id              := l_line_lse_id;
     --l_clev_tbl_in(1).line_number       := p_k_line_rec.k_line_number;
     l_clev_tbl_in(1).line_number         := get_top_line_number(p_k_line_rec.k_hdr_id);
     l_clev_tbl_in(1).sts_code            := NVL(p_k_line_rec.line_sts_code, 'ACTIVE');
     l_clev_tbl_in(1).display_sequence    := 1;
     l_clev_tbl_in(1).dnz_chr_id          := l_header_rec.id;
     --l_clev_tbl_in(1).name              := Substr(p_k_line_rec.srv_segment1,1,50);
     l_clev_tbl_in(1).name                := Null;
     l_clev_tbl_in(1).item_description    := p_k_line_rec.srv_desc;
     l_clev_tbl_in(1).start_date          := p_k_line_rec.srv_sdt;
     l_clev_tbl_in(1).end_date            := p_k_line_rec.srv_edt;
     l_clev_tbl_in(1).exception_yn        := 'N';
     l_clev_tbl_in(1).currency_code       := p_k_line_rec.currency;
     l_clev_tbl_in(1).price_level_ind     := Priced_YN(l_line_lse_id);
     l_clev_tbl_in(1).trn_code            := p_k_line_rec.reason_code;
     l_clev_tbl_in(1).comments            := p_k_line_rec.reason_comments;
     l_clev_tbl_in(1).Attribute1          := p_k_line_rec.attribute1;
     l_clev_tbl_in(1).Attribute2          := p_k_line_rec.attribute2;
     l_clev_tbl_in(1).Attribute3          := p_k_line_rec.attribute3;
     l_clev_tbl_in(1).Attribute4          := p_k_line_rec.attribute4;
     l_clev_tbl_in(1).Attribute5          := p_k_line_rec.attribute5;
     l_clev_tbl_in(1).Attribute6          := p_k_line_rec.attribute6;
     l_clev_tbl_in(1).Attribute7          := p_k_line_rec.attribute7;
     l_clev_tbl_in(1).Attribute8          := p_k_line_rec.attribute8;
     l_clev_tbl_in(1).Attribute9          := p_k_line_rec.attribute9;
     l_clev_tbl_in(1).Attribute10         := p_k_line_rec.attribute10;
     l_clev_tbl_in(1).Attribute11         := p_k_line_rec.attribute11;
     l_clev_tbl_in(1).Attribute12         := p_k_line_rec.attribute12;
     l_clev_tbl_in(1).Attribute13         := p_k_line_rec.attribute13;
     l_clev_tbl_in(1).Attribute14         := p_k_line_rec.attribute14;
     l_clev_tbl_in(1).Attribute15         := p_k_line_rec.attribute15;
-- Rules inserted by okc
          l_can_object := NULL;
          OPEN l_billto_csr( p_k_line_rec.bill_to_id );
          FETCH l_billto_csr INTO l_can_object;
          CLOSE l_billto_csr;

          --ramesh added on jan-26-01 for ib html interface
          IF l_can_object IS NULL THEN
               l_can_object := p_k_line_rec.cust_account;
          END IF;

          l_clev_tbl_in( 1 ).cust_acct_id           := l_can_object;                                 --CAN
          l_clev_tbl_in( 1 ).inv_rule_id            := p_k_line_rec.invoicing_rule_type;               --IRE
          l_clev_tbl_in( 1 ).line_renewal_type_code := NVL( p_k_line_rec.line_renewal_type, 'FUL' ); --LRT
          l_clev_tbl_in( 1 ).bill_to_site_use_id    := p_k_line_rec.bill_to_id;                      --BTO
          l_clev_tbl_in( 1 ).ship_to_site_use_id    := p_k_line_rec.ship_to_id;                      --STO

    okc_contract_pub.create_contract_line
    (
       p_api_version                    => l_api_version,
       p_init_msg_list                  => l_init_msg_list,
       x_return_status                  => l_return_status,
       x_msg_count                      => x_msg_count,
       x_msg_data                       => x_msg_data,
       p_clev_tbl                       => l_clev_tbl_in,
       x_clev_tbl                       => l_clev_tbl_out
    );

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: create_contract_line for' ||p_k_line_rec.line_type||' status :  '||l_return_status  );
    --dbms_output.put_line('K LINE CREATION :- LINE STATUS ' || l_return_status);

    x_return_status := l_return_status;

    If l_return_status = 'S' then
       l_line_id := l_clev_tbl_out(1).id;
    Else
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Line (LINE)');
       Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

-- rules inserted by oks --IRT

          OKS_RENEW_PVT.DEBUG_LOG('Accounting id  ' || p_k_line_rec.accounting_rule_type);
          --OKS_RENEW_PVT.DEBUG_LOG('commitment id  ' || p_k_line_rec.commitment_id );

          l_klnv_tbl_in( 1 ).cle_id                := l_line_id;
          l_klnv_tbl_in( 1 ).dnz_chr_id            := l_header_rec.id;
          l_klnv_tbl_in( 1 ).invoice_text          := Substr(p_k_line_rec.srv_desc,1,50);                               --IRT

          l_klnv_tbl_in( 1 ).acct_rule_id          := p_k_line_rec.accounting_rule_type; --ARL
          --l_klnv_tbl_in( 1 ).commitment_id       := p_k_line_rec.commitment_id;      --PAYMENT METHOD
          l_klnv_tbl_in( 1 ).cust_po_number_req_yn := 'N';   -- po number required
          l_klnv_tbl_in( 1 ).inv_print_flag        := 'N';   -- print flag
	  l_klnv_tbl_in( 1 ).usage_type            := p_k_line_rec.usage_type; --passing usagetype(fix for 4151328)
	  l_klnv_tbl_in( 1 ).usage_period          := p_k_line_rec.usage_period; --passing usageperiod(fix for 4151328)


          oks_contract_line_pub.create_line(
               p_api_version                   => l_api_version,
               p_init_msg_list                 => l_init_msg_list,
               x_return_status                 => l_return_status,
               x_msg_count                     => x_msg_count,
               x_msg_data                      => x_msg_data,
               p_klnv_tbl                      => l_klnv_tbl_in,
               x_klnv_tbl                      => l_klnv_tbl_out,
               p_validate_yn                   => 'N'
           );

          IF NOT l_return_status = 'S' THEN
               OKC_API.SET_MESSAGE(
                    g_app_name,
                    g_required_value,
                    g_col_name_token,
                    'OKS Contract LINE'
                );
               RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

          OKS_RENEW_PVT.DEBUG_LOG('(OKS_EXTWARPRGM_PVT).Create_K_Service_Lines :: OKS create line Status   : ' || l_return_status );
          FND_FILE.PUT_LINE( fnd_file.LOG, 'OKS K LINE CREATION :- LINE STATUS ' || l_return_status );


    okc_time_util_pub.get_duration
    (
          p_start_date    => p_k_line_rec.srv_sdt,
          p_end_date      => p_k_line_rec.srv_edt,
          x_duration      => l_duration,
          x_timeunit      => l_timeunits,
          x_return_status => l_return_status
    );

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: get_duration status :  '||l_return_status  );
    x_return_status := l_return_status;
    --dbms_output.put_line('get duration status = ' || x_return_status );

    If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
         Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Line jtot_obj_code :  '||l_line_jtot_obj_code  );
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Srv Id             :  '||p_k_line_rec.srv_id  );
    --dbms_output.put_line('jtot_object1_code'||l_line_jtot_obj_code||'id'||p_k_line_rec.srv_id);

    --Create Contract Item
    --If l_line_lse_id = 46 Then
    --        l_cimv_tbl_in(1).object1_id2 := '#';
    --Else
            l_cimv_tbl_in(1).object1_id2  := okc_context.get_okc_organization_id;
    --End If;

    l_cimv_tbl_in(1).cle_id             := l_line_id;
    l_cimv_tbl_in(1).dnz_chr_id         := l_header_rec.id;
    l_cimv_tbl_in(1).object1_id1        := p_k_line_rec.srv_id;
    l_cimv_tbl_in(1).jtot_object1_code  := l_line_jtot_obj_code;
    l_cimv_tbl_in(1).exception_yn       := 'N';
    l_cimv_tbl_in(1).number_of_items    := p_k_line_rec.quantity;  --l_duration;
    l_cimv_tbl_in(1).uom_code           := p_k_line_rec.uom_code;  --l_timeunits;

    --dbms_output.put_line('l_cimv_tbl_in(1).object1_id1 '||    l_cimv_tbl_in(1).object1_id1);

    okc_contract_item_pub.create_contract_item
    (
        p_api_version               => l_api_version,
        p_init_msg_list             => l_init_msg_list,
        x_return_status             => l_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
        p_cimv_tbl                  => l_cimv_tbl_in,
        x_cimv_tbl                  => l_cimv_tbl_out
    );

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: create_contract_item status :  '||l_return_status  );
    --dbms_output.put_line('K LINE CREATION :- KITEM STATUS ' || l_return_status);

    x_return_status := l_return_status;

    If l_return_status = OKC_API.G_RET_STS_SUCCESS then
         l_line_item_id := l_cimv_tbl_out(1).id;
    Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Service Inventory Item ID ' || p_k_line_rec.srv_id || ' ORG ' + okc_context.get_okc_organization_id);
         Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

    ----create sales credit

    Create_Sales_Credits
    (
            p_salescredit_tbl_in  => p_line_sales_crd_tbl,
            p_contract_id         => l_header_rec.id,
            p_line_id             => l_line_id,
            x_return_status       => l_return_status,
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count
     );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Create_Sales_Credits status :  '||l_return_status  );
     x_return_status := l_return_status;
     --dbms_output.put_line('LINE CREATION :- SALES CREDIT STATUS ' || l_return_status);

/*
     --Rule Group Routine
     ------check/create rules group

     Create_Rule_grp
     (
        p_dnz_chr_id    => l_header_rec.id,
        p_chr_id        => NULL,
        p_cle_id        => l_line_id,
        x_rul_grp_id    => l_rule_group_id,
        x_return_status => l_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Create_Rule_grp status :  '||l_return_status  );
      x_return_status := l_return_status;
      --dbms_output.put_line( 'LINE CREATION :- RULE GROUP STATUS '||l_return_status);

      --Customer Account

      Open  l_billto_csr (p_k_line_rec.bill_to_id);
      Fetch l_billto_csr into l_can_object;
      Close l_billto_csr;

      l_rulv_tbl_in.delete;

      l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'CAN');

      If l_rule_id Is NULL Then

             l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
             l_rulv_tbl_in(1).sfwt_flag                 := 'N';
             l_rulv_tbl_in(1).std_template_yn           := 'N';
             l_rulv_tbl_in(1).warn_yn                   := 'N';
             l_rulv_tbl_in(1).rule_information_category := 'CAN';
             l_rulv_tbl_in(1).object1_id1               := l_can_object;
             l_rulv_tbl_in(1).object1_id2               := '#';
             l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_CUSTACCT;
             l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

             Create_rules
             (
                    p_rulv_tbl      =>  l_rulv_tbl_in,
                    x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status => l_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data
              );

              OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Create CAN Rule status :  '||l_return_status  );
              --dbms_output.put_line('K LINE CREATION :- CAN RULE STATUS ' || l_return_status);
              x_return_status := l_return_status;

              If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                      l_rule_id := l_rulv_tbl_out(1).id;
              Else
                      OKC_API.set_message
                      (
                           p_app_name     => 'OKS',
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Customer Account (LINE)'
                       );

                       Raise G_EXCEPTION_HALT_VALIDATION;
              End If;

      End If;
*/

      --CONTACT CREATION ROUTINE STARTS


      If p_contact_tbl.count > 0 Then

         i := p_Contact_Tbl.First;
         Loop

             Open  l_ra_hcontacts_cur (p_Contact_tbl (i).contact_id);
             Fetch l_ra_hcontacts_cur into l_lin_party_id, l_lin_contactid;
             Close l_ra_hcontacts_cur;

             If i = p_contact_tbl.first Then

                  If l_header_rec.scs_code = 'SUBSCRIPTION' then
                        Party_Role
                        (
                          p_chrId          => l_header_rec.id,
                          p_cleId          => l_line_id,
                          p_Rle_Code       => 'SUBSCRIBER',
                          p_PartyId        => l_lin_party_id,
                          p_Object_Code    => G_JTF_PARTY,
                          x_roleid         => l_line_party_role_id,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => l_return_status
                        );

                       --dbms_output.put_line(' LINE PARTY ROLE  CREATION :- CPL ID ' || l_line_party_role_id);

                   Else

                        Party_Role
                        (
                          p_chrId          => l_header_rec.id,
                          p_cleId          => l_line_id,
                          p_Rle_Code       => 'CUSTOMER',
                          p_PartyId        => l_lin_party_id,
                          p_Object_Code    => G_JTF_PARTY,
                          x_roleid         => l_line_party_role_id,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => l_return_status
                         );

                        --dbms_output.put_line(' LINE PARTY ROLE  CREATION :- CPL ID ' || l_line_party_role_id);
                    End If;
             End If;

             If p_contact_tbl(i).contact_role like '%BILLING%' Then
                    l_role := 'CUST_BILLING';
                    l_obj  := 'OKX_CONTBILL';
             Elsif p_contact_tbl(i).contact_role like '%ADMIN%' Then
                    l_role := 'CUST_ADMIN';
                    l_obj  := 'OKX_CONTADMN';
             Elsif p_contact_tbl(i).contact_role like '%SHIP%' Then
                    l_role := 'CUST_SHIPPING';
                    l_obj  := 'OKX_CONTSHIP';
             End if;

             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: CPL Id         :  '||l_line_party_role_id  );
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Line Party Id  :  '||l_lin_party_id  );
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Org Contact Id :  '||p_Contact_tbl (i).contact_id  );
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: RAH Contact Id :  '||l_lin_contactid  );
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Contact Role   :  '||p_Contact_tbl (i).contact_role  );
             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Contact OBJ    :  '||p_Contact_tbl (i).contact_object_code  );

             l_ctcv_tbl_in(1).cpl_id                  := l_line_party_role_id;
             l_ctcv_tbl_in(1).dnz_chr_id              := l_header_rec.id;
             l_ctcv_tbl_in(1).cro_code                := l_role;
             l_ctcv_tbl_in(1).object1_id1             := p_contact_tbl(i).contact_id;
             l_ctcv_tbl_in(1).object1_id2             := '#';
             l_ctcv_tbl_in(1).jtot_object1_code       := l_obj;

             okc_contract_party_pub.create_contact
             (
                   p_api_version                       => l_api_version,
                   p_init_msg_list                     => l_init_msg_list,
                   x_return_status                     => l_return_status,
                   x_msg_count                         => x_msg_count,
                   x_msg_data                          => x_msg_data,
                   p_ctcv_tbl                          => l_ctcv_tbl_in,
                   x_ctcv_tbl                          => l_ctcv_tbl_out
               );

               OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: create_contact '||i||':'||l_return_status );
               x_return_status := l_return_status;

               If l_return_status = OKC_API.G_RET_STS_SUCCESS then
                    l_line_contact_id := l_ctcv_tbl_out(1).id;
               Else
                    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_Contact_tbl (i).contact_role
                                             || ' Contact (LINE) ' || p_Contact_tbl (i).contact_object_code);
                    Raise G_EXCEPTION_HALT_VALIDATION;
               End if;

       Exit When i = p_Contact_Tbl.Last;
       i := p_Contact_Tbl.Next(i);

    End Loop;

    End If;

/*
---TAX creation

  IF p_k_line_rec.tax_exemption_id Is Not Null THEN

    l_rulv_tbl_in.DELETE;

    l_rule_id  := Check_Rule_Exists(l_rule_group_id, 'TAX');

    IF l_rule_id Is NULL THEN

         l_rulv_tbl_in(1).rgp_id                      := l_rule_group_id;
         l_rulv_tbl_in(1).sfwt_flag                   := 'N';
         l_rulv_tbl_in(1).std_template_yn             := 'N';
         l_rulv_tbl_in(1).warn_yn                     := 'N';
         l_rulv_tbl_in(1).rule_information_category   := 'TAX';
         l_rulv_tbl_in(1).object1_id1                 := p_k_line_rec.tax_exemption_id;
         l_rulv_tbl_in(1).object1_id2                 := '#';
         l_rulv_tbl_in(1).JTOT_OBJECT1_CODE           := G_JTF_TAXEXEMP;
         l_rulv_tbl_in(1).object2_id1                 := 'TAX_CONTROL_FLAG';
         l_rulv_tbl_in(1).object2_id2                 := p_k_line_rec.tax_status_flag;
         l_rulv_tbl_in(1).JTOT_OBJECT2_CODE           := G_JTF_TAXCTRL;
         l_rulv_tbl_in(1).dnz_chr_id                  := p_k_line_rec.k_hdr_id;
         l_rulv_tbl_in(1).object_version_number       := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).created_by                  := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).creation_date               := SYSDATE;
         l_rulv_tbl_in(1).last_updated_by             := OKC_API.G_MISS_NUM;
         l_rulv_tbl_in(1).last_update_date            := SYSDATE;

         OKC_RULE_PUB.create_rule
         (
                 p_api_version      => l_api_version,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rulv_tbl         => l_rulv_tbl_in,
                 x_rulv_tbl         => l_rulv_tbl_out
          );

          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  TAX rule Status:'||l_return_status );
          --dbms_output.put_line( 'K LINE CREATION :- TAX RULE STATUS ' || l_return_Status);

          x_return_status := l_return_status;

          IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
             l_rule_id  := l_rulv_tbl_out(1).id;
          ELSE
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TAX EXEMPTION (LINE)');
             Raise G_EXCEPTION_HALT_VALIDATION;
          END IF;

    END IF;

  END IF;

 --CONTACT CREATION ROUTINE ENDS


--Accounting Rule ID  Routine

    If p_k_line_rec.accounting_rule_type Is Not Null Then

    l_rulv_tbl_in.delete;

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'ARL');

    If l_rule_id Is NULL Then

        l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
        l_rulv_tbl_in(1).sfwt_flag                 := 'N';
        l_rulv_tbl_in(1).std_template_yn           := 'N';
        l_rulv_tbl_in(1).warn_yn                   := 'N';
        l_rulv_tbl_in(1).rule_information_category := 'ARL';
        l_rulv_tbl_in(1).object1_id1               := p_k_line_rec.accounting_rule_type;
        l_rulv_tbl_in(1).object1_id2               := '#';
        l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_ARL;
        l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

        create_rules
        (
                   p_rulv_tbl      => l_rulv_tbl_in,
                   x_rulv_tbl      => l_rulv_tbl_out,
                   x_return_status => l_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data
         );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  ARL rule Status:'||l_return_status );
         --dbms_output.put_line('K LINE CREATION :- ARL RULE STATUS ' || l_return_status);
         x_return_status := l_return_status;

         If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             l_rule_id  := l_rulv_tbl_out(1).id;
         Else
             OKC_API.set_message
             (
                   p_app_name     => 'OKS',
                   p_msg_name     => G_REQUIRED_VALUE,
                   p_token1       => G_COL_NAME_TOKEN,
                   p_token1_value => 'Customer Account (LINE)'
              );
              Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

      End If;

  End If;



--QRE rule for usage only
--rule will be created only for usage item i.e, for lse_id = 12

  If l_line_lse_id = 12 THEN

    l_rulv_tbl_in.delete;

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'QRE');

    If l_rule_id Is NULL Then

        l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
        l_rulv_tbl_in(1).sfwt_flag                 := 'N';
        l_rulv_tbl_in(1).std_template_yn           := 'N';
        l_rulv_tbl_in(1).warn_yn                   := 'N';
        l_rulv_tbl_in(1).rule_information_category := 'QRE';
      --l_rulv_tbl_in(1).rule_information1         := Substr(p_k_line_rec.srv_desc,1,50);
        l_rulv_tbl_in(1).rule_information11        := p_k_line_rec.usage_period;
        l_rulv_tbl_in(1).rule_information2         := p_k_line_rec.usage_period;
        l_rulv_tbl_in(1).rule_information6         := 'N';
        l_rulv_tbl_in(1).rule_information9         := 'N';
        l_rulv_tbl_in(1).ATTRIBUTE11               := p_k_line_rec.usage_period;
        l_rulv_tbl_in(1).rule_information10        := p_k_line_rec.usage_type;
        l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

      create_rules
      (
            p_rulv_tbl      =>  l_rulv_tbl_in,
            x_rulv_tbl      =>  l_rulv_tbl_out,
            x_return_status =>  l_return_status,
            x_msg_count     =>  x_msg_count,
            x_msg_data      =>  x_msg_data
       );

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  QRE rule Status:'||l_return_status );
       --dbms_output.put_line('K LINE CREATION :- QRE RULE STATUS ' || l_return_status);

       x_return_status := l_return_status;

       If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             l_rule_id  := l_rulv_tbl_out(1).id;
       Else
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'USAGE ITEM (LINE)');
             Raise G_EXCEPTION_HALT_VALIDATION;
       End If;

    End If;

  End if;


-- Line Invoicing Rule ONLY FOR USAGE AND SERVICE

-- IF l_line_lse_id = 1 or l_line_lse_id = 12 THEN

If p_k_line_rec.invoicing_rule_type Is Not Null Then

        l_rulv_tbl_in.delete;
        l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRE');

        If l_rule_id Is NULL Then

           l_rulv_tbl_in(1).rgp_id                      := l_rule_group_id;
           l_rulv_tbl_in(1).sfwt_flag                   := 'N';
           l_rulv_tbl_in(1).std_template_yn             := 'N';
           l_rulv_tbl_in(1).warn_yn                     := 'N';
           l_rulv_tbl_in(1).rule_information_category   := 'IRE';
           l_rulv_tbl_in(1).object1_id1                 := p_k_line_rec.invoicing_rule_type;
           l_rulv_tbl_in(1).object1_id2                 := '#';
           l_rulv_tbl_in(1).jtot_object1_code           := G_JTF_IRE;
           l_rulv_tbl_in(1).dnz_chr_id                  := l_header_rec.id;

           create_rules
           (
                p_rulv_tbl      =>  l_rulv_tbl_in,
                x_rulv_tbl      =>  l_rulv_tbl_out,
                x_return_status =>  l_return_status,
                x_msg_count     =>  x_msg_count,
                x_msg_data      =>  x_msg_data
           );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  IRE rule Status:'||l_return_status );
           --dbms_output.put_line( 'K LINE CREATION :- IRE RULE STATUS ' || l_return_Status);

           x_return_status := l_return_status;

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              l_rule_id := l_rulv_tbl_out(1).id;
           Else
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Invoice Id (LINE)');
              Raise G_EXCEPTION_HALT_VALIDATION;
           End If;

       End If;

End If;

--End If;

--Invoice Text Routine
 IF p_k_line_rec.srv_desc IS NOT NULL THEN
    l_rulv_tbl_in.delete;

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRT');

    If l_rule_id Is NULL Then

          l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
          l_rulv_tbl_in(1).sfwt_flag                 := 'N';
          l_rulv_tbl_in(1).std_template_yn           := 'N';
          l_rulv_tbl_in(1).warn_yn                   := 'N';
          l_rulv_tbl_in(1).rule_information_category := 'IRT';
          l_rulv_tbl_in(1).rule_information1         := Substr(p_k_line_rec.srv_desc,1,50);
          l_rulv_tbl_in(1).rule_information2         := 'Y';
          l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

          create_rules
          (
                 p_rulv_tbl      =>  l_rulv_tbl_in,
                 x_rulv_tbl      =>  l_rulv_tbl_out,
                 x_return_status => l_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data
         );

         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  IRT rule Status:'||l_return_status );
         --dbms_output.put_line('K LINE CREATION :- IRT RULE STATUS ' || l_return_status);
         x_return_status := l_return_status;

         If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
            l_rule_id   := l_rulv_tbl_out(1).id;
         Else
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'INVOICE TEXT (LINE)');
            Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

    End If;
  END IF;

--Line Renewal Type To Routine

l_rulv_tbl_in.delete;
l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'LRT');

If l_rule_id Is NULL Then

            l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
            l_rulv_tbl_in(1).sfwt_flag                 := 'N';
            l_rulv_tbl_in(1).std_template_yn           := 'N';
            l_rulv_tbl_in(1).warn_yn                   := 'N';
            l_rulv_tbl_in(1).rule_information_category := 'LRT';
            l_rulv_tbl_in(1).rule_information1         := Nvl(p_k_line_rec.line_renewal_type,'FUL');
            l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

            create_rules
            (
                    p_rulv_tbl      =>  l_rulv_tbl_in,
                    x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status =>  l_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data
            );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  LRT rule Status:'||l_return_status );
           --dbms_output.put_line('K LINE CREATION :- LRT RULE STATUS ' || l_return_status);
           x_return_status := l_return_status;

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
               l_rule_id    := l_rulv_tbl_out(1).id;
           Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE RENEWAL TYPE (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
           End If;

    End If;

--Bill To Routine

If p_k_line_rec.bill_to_id Is Not Null Then

    l_rulv_tbl_in.delete;

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'BTO');

    If l_rule_id Is NULL Then

        l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
        l_rulv_tbl_in(1).sfwt_flag                 := 'N';
        l_rulv_tbl_in(1).std_template_yn           := 'N';
        l_rulv_tbl_in(1).warn_yn                   := 'N';
        l_rulv_tbl_in(1).rule_information_category := 'BTO';
        l_rulv_tbl_in(1).object1_id1               := p_k_line_rec.bill_to_id;
        l_rulv_tbl_in(1).object1_id2               := '#';
        l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_BILLTO;
        l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

        create_rules
        (
                    p_rulv_tbl      =>  l_rulv_tbl_in,
                    x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status => l_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data
        );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  BTO rule Status:'||l_return_status );
        --dbms_output.put_line('K LINE CREATION :- BTO RULE STATUS ' || l_return_status);
        x_return_status := l_return_status;

        If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
               l_rule_id    := l_rulv_tbl_out(1).id;
        Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BillTo ID (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

    End If;

End If;

--Ship To Routine

If p_k_line_rec.ship_to_id Is Not Null Then

    l_rulv_tbl_in.delete;
    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'STO');

    If l_rule_id Is NULL Then

        l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
        l_rulv_tbl_in(1).sfwt_flag                 := 'N';
        l_rulv_tbl_in(1).std_template_yn           := 'N';
        l_rulv_tbl_in(1).warn_yn                   := 'N';
        l_rulv_tbl_in(1).rule_information_category := 'STO';
        l_rulv_tbl_in(1).object1_id1               := p_k_line_rec.ship_to_id;
        l_rulv_tbl_in(1).object1_id2               := '#';
        l_rulv_tbl_in(1).jtot_object1_code         := G_JTF_SHIPTO;
        l_rulv_tbl_in(1).dnz_chr_id                := l_header_rec.id;

        create_rules
        (
                    p_rulv_tbl      =>  l_rulv_tbl_in,
                    x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status =>  l_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data
        );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line ::  STO rule Status:'||l_return_status );
        --dbms_output.put_line('K LINE CREATION :- STO RULE STATUS ' || l_return_status);

        x_return_status := l_return_status;

        If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
           l_rule_id    := l_rulv_tbl_out(1).id;
        Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ShipTo ID (LINE)');
           Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

    End If;

End If;           --end ship to id null

*/

----create objrel only for ext warranty

IF l_line_lse_id = 19 AND  p_k_line_rec.order_line_id Is Not Null Then


       Create_Obj_Rel
       (
             p_K_id               => Null,
             p_line_id            => l_line_id,
             p_orderhdrid         => Null,
             p_orderlineid        => p_k_line_rec.order_line_id,
             x_return_status      => l_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data
       );

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Create_Obj_Rel Status:'||l_return_status );
       --dbms_output.put_line('K LINE CREATION :- OBJ REL STATUS ' || l_return_status);

       x_return_status := l_return_status;

       If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Line Id (LINE)');
          Raise G_EXCEPTION_HALT_VALIDATION;
       End If;

End If;                      ----------end objrel only for ext warranty

----coverage for service,ext war, war

IF l_line_lse_id not in (12,46) THEN  --- No coverages for usage lines

     l_organization_id := Okc_context.get_okc_organization_id ;
     --dbms_output.put_line('serv_id '||p_k_line_rec.srv_id );

     OPEN l_template_csr(p_k_line_rec.srv_id, l_organization_id);
     FETCH l_template_csr INTO l_template_id;

     IF l_template_csr%NOTFOUND THEN
         Close l_template_csr;
         x_return_status := OKC_API.G_RET_STS_ERROR ;
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TEMPLATE ID NOT FOUND (LINE)');
         Raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
         Close l_template_csr;
      END IF;

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Template Id:'||l_template_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: SRV ID     :'||p_k_line_rec.srv_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Line Id    :'||l_line_id );

      --dbms_output.put_line('l_line_id :: '|| l_line_id);
      --dbms_output.put_line('l_template_id:: '|| l_template_id);
      --dbms_output.put_line('start date:: '||p_k_line_rec.srv_sdt );

      l_cov_rec.Svc_cle_Id := l_line_id;
      l_cov_rec.Tmp_cle_Id := l_template_id;
      l_cov_rec.Start_date := p_k_line_rec.srv_sdt;
      l_cov_rec.End_Date   := p_k_line_rec.srv_edt;

      OKS_COVERAGES_PUB.CREATE_ACTUAL_COVERAGE
      (
          p_api_version           => 1.0,
          p_init_msg_list         => OKC_API.G_FALSE,
          x_return_status         => l_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          P_ac_rec_in             => l_cov_rec,
          x_Actual_coverage_id    => l_cov_id
      );


      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Create_Actual_Coverage Status :'||l_return_status );
      --dbms_output.put_line('K LINE CREATION :- COV STATUS ' || l_return_status);
      x_return_status := l_return_status;

      If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CoverageInstantiate (LINE)');
             Raise G_EXCEPTION_HALT_VALIDATION;
      End If;

End if; -- for coverages



l_ctr_grpid := Null;

IF l_line_lse_id not in (46) THEN

         Open  l_ctr_csr (p_k_line_rec.srv_id);
         Fetch l_ctr_csr Into l_ctr_grpid;
         Close l_ctr_csr;

         If l_ctr_grpid Is Not Null Then

             cs_counters_pub.autoinstantiate_counters
             (
                    P_API_VERSION                  => 1.0,
                    P_INIT_MSG_LIST                => 'T',
                    P_COMMIT                       => 'F',
                    X_RETURN_STATUS                => l_return_status,
                    X_MSG_COUNT                    => x_msg_count,
                    X_MSG_DATA                     => x_msg_data,
                    P_SOURCE_OBJECT_ID_TEMPLATE    => p_k_line_rec.srv_id,
                    P_SOURCE_OBJECT_ID_INSTANCE    => l_line_id,
                    X_CTR_GRP_ID_TEMPLATE          => l_ctr_grp_id_template,
                    X_CTR_GRP_ID_INSTANCE          => l_ctr_grp_id_instance
             );

             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: autoinstantiate_counters Status :'||l_return_status );
             --dbms_output.put_line('K LINE CREATION :- CTR STATUS ' || l_return_status);
             x_return_status := l_return_status;

             If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Counter Instantiate (LINE)');
                  Raise G_EXCEPTION_HALT_VALIDATION;
             End If;

          End If;
     End if;
 x_service_line_id := l_line_id;

Exception

    When  G_EXCEPTION_HALT_VALIDATION Then
        x_return_status := l_return_status;
    When  Others Then
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Service_Line :: Error:'||SQLCODE ||':'|| SQLERRM);

End Create_Service_line;






-----------------------------------------------------------------------
-- Procedure for creating Covered line
--------------------------------------------------------------------------

Procedure Create_Covered_Line
(
      p_k_covd_rec                  IN    Covered_level_Rec_Type
,     p_PRICE_ATTRIBS               IN    Pricing_attributes_Type
,     x_cp_line_id                  OUT NOCOPY  NUMBER
,     x_return_status               OUT NOCOPY   Varchar2
,     x_msg_count                   OUT NOCOPY  Number
,     x_msg_data                    OUT NOCOPY  Varchar2
)
Is

    l_api_version       CONSTANT    NUMBER  := 1.0;
    l_init_msg_list     CONSTANT    VARCHAR2(1) := OKC_API.G_FALSE;
    l_return_status                 VARCHAR2(1) := 'S';
    l_index                         VARCHAR2(2000);

--Contract Line Table
    l_clev_tbl_in                  okc_contract_pub.clev_tbl_type;
    l_clev_tbl_out                 okc_contract_pub.clev_tbl_type;

--Contract Item
    l_cimv_tbl_in                  okc_contract_item_pub.cimv_tbl_type;
    l_cimv_tbl_out                 okc_contract_item_pub.cimv_tbl_type;

--Pricing Attributes
    l_pavv_tbl_in                  okc_price_adjustment_pvt.pavv_tbl_type;
    l_pavv_tbl_out                 okc_price_adjustment_pvt.pavv_tbl_type;


--Rule Related

    --l_rgpv_tbl_in                  okc_rule_pub.rgpv_tbl_type;
    --l_rgpv_tbl_out                 okc_rule_pub.rgpv_tbl_type;
    --l_rulv_tbl_in                  okc_rule_pub.rulv_tbl_type;
    --l_rulv_tbl_out                 okc_rule_pub.rulv_tbl_type;
      l_klnv_tbl_in                 oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out                oks_kln_pvt.klnv_tbl_type;
--Return IDs
    l_line_id                      NUMBER;
    l_rule_group_id                NUMBER;
    l_rule_id                      NUMBER;
    l_line_item_id                 NUMBER;
    l_cp_lse_id                    NUMBER;
    l_cp_jtot_object               VARCHAR2(30) := NULL;
    l_hdrsdt                       DATE;
    l_hdredt                       DATE;
    l_hdrorgid                     Number;
    l_line_sdt                     DATE;
    l_line_edt                     DATE;
    l_hdrstatus                    VARCHAR2(3);
    l_line_status                  VARCHAR2(3);
    l_priceattrib_id               NUMBER;


    Cursor l_mtl_csr(p_inventory_id Number, p_organization_id Number) Is
                  Select  MTL.SERVICE_ITEM_FLAG
                         ,MTL.USAGE_ITEM_FLAG
                  From    OKX_SYSTEM_ITEMS_V MTL
                  Where   MTL.id1   = p_Inventory_id
                  And     MTL.Organization_id = p_organization_id;

   l_mtl_rec     l_mtl_csr%rowtype;

   CURSOR l_parent_line_csr (p_line_id Number) IS
                 SELECT id, lse_id
                 FROM okc_k_lines_b
                 WHERE id =  p_line_id;
/*
   CURSOR l_usage_type_csr(p_line_id NUMBER) IS
                 SELECT rule_information10
                 FROM okc_rules_b rul, okc_rule_groups_b rg
                 WHERE rul.rgp_id = rg.id AND rg.cle_id = p_line_id
                 AND rule_information_category = 'QRE';*/

CURSOR l_usage_type_csr(p_line_id NUMBER) IS
                 SELECT usage_type
                 FROM oks_k_lines_b
                 WHERE cle_id = p_line_id;


  l_parent_line_rec                       l_parent_line_csr%ROWTYPE;
  l_usage_type                            VARCHAR2(450);
  l_warranty_flag                         VARCHAR2(10);


  Begin


     x_return_status            := OKC_API.G_RET_STS_SUCCESS;

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: CREATE COVERED LINE FOR LINE :'||p_k_covd_rec.Attach_2_Line_id );
     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Attached to line type        :'||p_k_covd_rec.product_sts_code );

     IF p_k_covd_rec.Attach_2_Line_id IS NULL THEN

        x_return_status :=  OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ATTACH_2_LINE_ID REQUIRED FOR COVERED PRODUCT');
        Raise G_EXCEPTION_HALT_VALIDATION;

     END IF;

     --dbms_output.put_line('line_id '|| p_k_covd_rec.Attach_2_Line_id );

     OPEN l_parent_line_csr(p_k_covd_rec.Attach_2_Line_id);
     FETCH l_parent_line_csr INTO l_parent_line_rec;

     IF l_parent_line_csr%NOTFOUND THEN
         Close l_parent_line_csr;
         ---message debug and okc.api
         x_return_status := OKC_API.G_RET_STS_ERROR;
         Raise G_EXCEPTION_HALT_VALIDATION;
     ELSE
         Close l_parent_line_csr;
     END IF;

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Parent line Id     :'||to_char(l_parent_line_rec.id) );
     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Parent line Lse Id :'||to_char(l_parent_line_rec.lse_id) );

     IF l_parent_line_rec.lse_id = 12 THEN

         OPEN l_usage_type_csr(l_parent_line_rec.id);
         FETCH l_usage_type_csr INTO l_usage_type;

         IF l_usage_type_csr%NOTFOUND THEN
             Close l_usage_type_csr;
             l_usage_type := NULL;
         ELSE
             Close l_usage_type_csr;
         END IF;

      ELSE
         l_usage_type := NULL;
      END IF;

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Usage Type :'||l_usage_type );

     Validate_Cp_Rec
     (
           p_cp_rec        => p_k_covd_rec,
           p_usage_type    => l_usage_type,
           x_return_status => l_return_status
     );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Validate_Cp_Rec Status :'||l_return_status );


     IF NOT l_return_status =  OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
            Raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

     --dbms_output.put_line('validate CP '||l_return_status );

     Check_line_effectivity
     (
        p_cle_id      =>    p_k_covd_rec.Attach_2_Line_id,
        p_srv_sdt     =>    p_k_covd_rec.Product_start_date,
        p_srv_edt     =>    p_k_covd_rec.Product_end_date,
        x_line_sdt    =>    l_line_sdt,
        x_line_edt    =>    l_line_edt,
        x_status      =>    l_return_status
     );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Check_line_effectivity Status :'||l_return_status );
      x_return_status := l_return_status;
      --dbms_output.put_line('validate line effectivity '|| x_return_status );

      If l_return_status = OKC_API.G_RET_STS_ERROR Then

           x_return_status := OKC_API.G_RET_STS_ERROR;
           Raise G_EXCEPTION_HALT_VALIDATION;

      ElsIf l_return_status = 'Y' Then

            check_hdr_effectivity
            (
                p_chr_id          =>    p_k_covd_rec.k_id,
                p_srv_sdt         =>    l_line_sdt,
                p_srv_edt         =>    l_line_edt,
                x_hdr_sdt         =>    l_hdrsdt,
                x_hdr_edt         =>    l_hdredt,
                x_org_id          =>    l_hdrorgid,
                x_status          =>    l_hdrstatus
             );

             OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: check_hdr_effectivity Status :'||l_hdrstatus );
             x_return_status := l_hdrstatus;
             --dbms_output.put_line('hdr effectivity  '|| x_return_status );


             If l_hdrstatus = 'N' Then
                  NULL;

             ElsIf l_hdrstatus = 'Y' Then

                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CP EFFECTIVITY SHOULD BE WITH IN CONTRACT EFFECTIVITY');
                  Raise G_EXCEPTION_HALT_VALIDATION;
             End If;
      End if;

     --dbms_output.put_line('parent lse_id = ' || to_char(l_parent_line_rec.lse_id ));

     IF l_parent_line_rec.lse_id  = 1 THEN                       --service
          l_cp_lse_id := 9;
          l_cp_jtot_object := 'OKX_CUSTPROD';
     ELSIF l_parent_line_rec.lse_id   = 12 THEN                  --usage
          l_cp_lse_id := 13;
          l_cp_jtot_object := 'OKX_COUNTER';
     ELSIF l_parent_line_rec.lse_id  = 14 THEN                   --warranty
          l_cp_lse_id := 18;
          l_cp_jtot_object := 'OKX_CUSTPROD';
     ELSIF l_parent_line_rec.lse_id   = 19 THEN                  --ext warranty
          l_cp_lse_id := 25;
          l_cp_jtot_object := 'OKX_CUSTPROD';

     END IF;

    --dbms_output.put_line('l_cp_lse_id = ' || (l_cp_lse_id));
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: CP Lse Id       :'|| to_char(l_cp_lse_id) );
    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: CP Jtot_object  :'||l_cp_jtot_object );

    l_clev_tbl_in(1).chr_id                 := Null;
    l_clev_tbl_in(1).sfwt_flag              := 'N';
    l_clev_tbl_in(1).lse_id                 := l_cp_lse_id;
   --l_clev_tbl_in(1).line_number           := p_k_covd_rec.line_number;
    l_clev_tbl_in(1).line_number            := get_sub_line_number(p_k_covd_rec.k_id,p_k_covd_rec.Attach_2_Line_Id);
    l_clev_tbl_in(1).sts_code               := Nvl(p_k_covd_rec.product_sts_code,'ACTIVE');
    l_clev_tbl_in(1).display_sequence       := 2;
    l_clev_tbl_in(1).dnz_chr_id             := p_k_covd_rec.k_id;
    --l_clev_tbl_in(1).name                 := Substr(p_k_covd_rec.Product_segment1,1,50);
    l_clev_tbl_in(1).name                   := Null;
    l_clev_tbl_in(1).item_description       := p_k_covd_rec.Product_desc;
    l_clev_tbl_in(1).start_date             := p_k_covd_rec.Product_start_date;
    l_clev_tbl_in(1).end_date               := p_k_covd_rec.Product_end_date;
    l_clev_tbl_in(1).exception_yn           := 'N';
    l_clev_tbl_in(1).price_negotiated       := p_k_covd_rec.negotiated_amount;
    l_clev_tbl_in(1).currency_code          := p_k_covd_rec.currency_code;
    l_clev_tbl_in(1).price_unit             := p_k_covd_rec.list_price;
    l_clev_tbl_in(1).cle_id                 := p_k_covd_rec.Attach_2_Line_Id;
    l_clev_tbl_in(1).price_level_ind        := Priced_YN(l_cp_lse_id);
    l_clev_tbl_in(1).trn_code               := p_k_covd_rec.reason_code;
    l_clev_tbl_in(1).comments               := p_k_covd_rec.reason_comments;
    l_clev_tbl_in(1).Attribute1             := p_k_covd_rec.attribute1;
    l_clev_tbl_in(1).Attribute2             := p_k_covd_rec.attribute2;
    l_clev_tbl_in(1).Attribute3             := p_k_covd_rec.attribute3;
    l_clev_tbl_in(1).Attribute4             := p_k_covd_rec.attribute4;
    l_clev_tbl_in(1).Attribute5             := p_k_covd_rec.attribute5;
    l_clev_tbl_in(1).Attribute6             := p_k_covd_rec.attribute6;
    l_clev_tbl_in(1).Attribute7             := p_k_covd_rec.attribute7;
    l_clev_tbl_in(1).Attribute8             := p_k_covd_rec.attribute8;
    l_clev_tbl_in(1).Attribute9             := p_k_covd_rec.attribute9;
    l_clev_tbl_in(1).Attribute10            := p_k_covd_rec.attribute10;
    l_clev_tbl_in(1).Attribute11            := p_k_covd_rec.attribute11;
    l_clev_tbl_in(1).Attribute12            := p_k_covd_rec.attribute12;
    l_clev_tbl_in(1).Attribute13            := p_k_covd_rec.attribute13;
    l_clev_tbl_in(1).Attribute14            := p_k_covd_rec.attribute14;
    l_clev_tbl_in(1).Attribute15            := p_k_covd_rec.attribute15;
    l_clev_tbl_in(1).line_renewal_type_code := NVL( p_k_covd_rec.line_renewal_type, 'FUL' ); --LRT
    okc_contract_pub.create_contract_line
      (
        p_api_version                   => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        x_return_status                 => l_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data,
        p_clev_tbl                      => l_clev_tbl_in,
        x_clev_tbl                      => l_clev_tbl_out
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: create_contract_line status:'|| l_return_status);
      --dbms_output.put_line('K COVD LINE CREATION :- LINE  STATUS ' || l_return_status);
      x_return_status := l_return_status;

      If l_return_status = OKC_API.G_RET_STS_SUCCESS then
           l_line_id := l_clev_tbl_out(1).id;
      Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'K LINE (SUB LINE)');
           Raise G_EXCEPTION_HALT_VALIDATION;
      End if;

      -- cov rules inserted by oks
          l_klnv_tbl_in( 1 ).cle_id                 := l_line_id; --p_k_covd_rec.attach_2_line_id;
          l_klnv_tbl_in( 1 ).dnz_chr_id             := p_k_covd_rec.k_id;
IF l_cp_lse_id <> 13 THEN

          l_klnv_tbl_in( 1 ).invoice_text           := 'Counter'||Substr(p_k_covd_rec.Product_desc,1,50);                    --IRT

Else
                    l_klnv_tbl_in(1).UOM_QUANTIFIED              := p_k_covd_rec.period;
                    l_klnv_tbl_in(1).minimum_quantity                 := p_k_covd_rec.minimum_qty;
                    l_klnv_tbl_in(1).default_quantity             := p_k_covd_rec.default_qty;
                    l_klnv_tbl_in(1).amcv_flag        := p_k_covd_rec.amcv_flag;
                    l_klnv_tbl_in(1).fixed_quantity                     := p_k_covd_rec.fixed_qty;
                   -- ??? uom_per_period mapping column does not exist in the table
                   -- l_klnv_tbl_in(1).UOM_PER_PERIOD           := 1;
                    l_klnv_tbl_in(1).level_yn                 := p_k_covd_rec.level_yn;
                    l_klnv_tbl_in(1).base_reading      := p_k_covd_rec.base_reading;
                    l_klnv_tbl_in(1).price_uom           := p_k_covd_rec.uom_code;
                    l_klnv_tbl_in(1).dnz_chr_id               := p_k_covd_rec.k_id;

End If;
          OKS_CONTRACT_LINE_PUB.CREATE_LINE(
               p_api_version                   => l_api_version,
               p_init_msg_list                 => l_init_msg_list,
               x_return_status                 => l_return_status,
               x_msg_count                     => x_msg_count,
               x_msg_data                      => x_msg_data,
               p_klnv_tbl                      => l_klnv_tbl_in,
               x_klnv_tbl                      => l_klnv_tbl_out,
               p_validate_yn                   => 'N'
           );
          OKS_RENEW_PVT.DEBUG_LOG('(OKS_EXTWARPRGM_PVT).OKS create cov lvl status :: ' || l_return_status );
          FND_FILE.PUT_LINE(fnd_file.LOG, 'OKS COV LINE CREATION :- LINE STATUS '|| l_return_status );

          IF NOT l_return_status = 'S' THEN
               OKC_API.SET_MESSAGE(
                    g_app_name,
                    g_required_value,
                    g_col_name_token,
                    'OKS Contract COV LINE'
                );
               RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;


      --Create Contract Item

      l_cimv_tbl_in(1).cle_id                   := l_line_id;
      l_cimv_tbl_in(1).dnz_chr_id               := p_k_covd_rec.k_id;
      l_cimv_tbl_in(1).object1_id1              := to_char(p_k_covd_rec.Customer_Product_Id);
      l_cimv_tbl_in(1).object1_id2              := '#';
      l_cimv_tbl_in(1).jtot_object1_code        := l_cp_jtot_object;
      l_cimv_tbl_in(1).exception_yn             := 'N';
      l_cimv_tbl_in(1).number_of_items          := p_k_covd_rec.quantity;
      l_cimv_tbl_in(1).uom_code                 := p_k_covd_rec.uom_code;

      Okc_contract_item_pub.create_contract_item
      (
        p_api_version                   => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        x_return_status                 => l_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data,
        p_cimv_tbl                      => l_cimv_tbl_in,
        x_cimv_tbl                      => l_cimv_tbl_out
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: create_contract_item status:'|| l_return_status);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Item Id :'|| l_cimv_tbl_out(1).id );
      --dbms_output.put_line('K COVD LINE CREATION :- KITEM  STATUS ' || l_return_status);

      x_return_status := l_return_status;

      If l_return_status = OKC_API.G_RET_STS_SUCCESS then
           l_line_item_id := l_cimv_tbl_out(1).id;
           --dbms_output.put_line('item id  '||l_cimv_tbl_out(1).id );
      Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'KItem (SUB LINE)');
           Raise G_EXCEPTION_HALT_VALIDATION;
      End if;

 /*
      --Rule Group Routine

      Create_Rule_grp
      (
        p_dnz_chr_id    => p_k_covd_rec.k_id,
        p_chr_id        => NULL,
        p_cle_id        => l_line_id,
        x_rul_grp_id    => l_rule_group_id,
        x_return_status => l_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Create_Rule_grp status :'|| l_return_status );
      --dbms_output.put_line('K COVD LINE CREATION :- RGP  STATUS ' || l_return_status);
      x_return_status := l_return_status;

      If NOT l_return_status = OKC_API.G_RET_STS_SUCCESS Then
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Rule Group (SUB LINE)');
            Raise G_EXCEPTION_HALT_VALIDATION;
      End If;

      --Invoice Text Routine
      IF l_cp_lse_id <> 13 THEN
           l_rulv_tbl_in.DELETE;
           l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRT');

           If l_rule_id Is NULL Then

                l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
                l_rulv_tbl_in(1).sfwt_flag                 := 'N';
                l_rulv_tbl_in(1).std_template_yn           := 'N';
                l_rulv_tbl_in(1).warn_yn                   := 'N';
                l_rulv_tbl_in(1).rule_information_category := 'IRT';
                l_rulv_tbl_in(1).rule_information1         := 'Counter'||Substr(p_k_covd_rec.Product_desc,1,50);
                l_rulv_tbl_in(1).rule_information2         := 'Y';
                l_rulv_tbl_in(1).dnz_chr_id                := p_k_covd_rec.k_id;

                Create_rules
                (
                    p_rulv_tbl      =>  l_rulv_tbl_in,
                    x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status =>  l_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data
                );

                OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: IRT Rule status :'|| l_return_status );
                --dbms_output.put_line('K COVD LINE CREATION :- IRT RULE STATUS ' || l_return_status);
                x_return_status := l_return_status;

                If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                      l_rule_id := l_rulv_tbl_out(1).id;
                Else
                      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'INVOICE TEXT (SUB LINE)');
                      Raise G_EXCEPTION_HALT_VALIDATION;
                End If;

           End If;
      End If;

      IF l_cp_lse_id= 13 THEN -- validation for usage rules

             --- QRE rule for usages
             l_rulv_tbl_in.DELETE;
             l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'QRE');

             If l_rule_id Is NULL Then

                    l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
                    l_rulv_tbl_in(1).sfwt_flag                 := 'N';
                    l_rulv_tbl_in(1).std_template_yn           := 'N';
                    l_rulv_tbl_in(1).warn_yn                   := 'N';
                    l_rulv_tbl_in(1).rule_information_category := 'QRE';
                    --   l_rulv_tbl_in(1).rule_information1         := Substr(p_k_covd_rec.Product_desc,1,50);
                    l_rulv_tbl_in(1).rule_information2         := p_k_covd_rec.period;
                    l_rulv_tbl_in(1).rule_information4         := p_k_covd_rec.minimum_qty;
                    l_rulv_tbl_in(1).rule_information5         := p_k_covd_rec.default_qty;
                    l_rulv_tbl_in(1).rule_information6         := p_k_covd_rec.amcv_flag;
                    l_rulv_tbl_in(1).rule_information7         := p_k_covd_rec.fixed_qty;
                    l_rulv_tbl_in(1).rule_information8         := 1;
                    l_rulv_tbl_in(1).rule_information9         := p_k_covd_rec.level_yn;
                    l_rulv_tbl_in(1).rule_information12        := p_k_covd_rec.base_reading;
                    l_rulv_tbl_in(1).rule_information11        := p_k_covd_rec.uom_code;
                    l_rulv_tbl_in(1).dnz_chr_id                := p_k_covd_rec.k_id;

                    Create_rules
                    (
                      p_rulv_tbl      =>  l_rulv_tbl_in,
                      x_rulv_tbl      =>  l_rulv_tbl_out,
                      x_return_status =>  l_return_status,
                      x_msg_count     =>  x_msg_count,
                      x_msg_data      =>  x_msg_data
                    );

                    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: QRE Rule status :'|| l_return_status );
                    --dbms_output.put_line('K COVD LINE CREATION :- QRE RULE STATUS ' || l_return_status);
                    x_return_status := l_return_status;

                    If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                              l_rule_id := l_rulv_tbl_out(1).id;
                    Else
                              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'USAGE ITEM (SUB LINE)');
                              Raise G_EXCEPTION_HALT_VALIDATION;
                    End If;

            End If;  -- end if for QRE rule

      ELSE

            --Line Renewal Type To Routine

            l_rulv_tbl_in.DELETE;

            l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'LRT');

            If l_rule_id Is NULL Then
                 --dbms_output.put_line('rgp'||l_rule_group_id);
                 --dbms_output.put_line('rule_information1'||p_k_covd_rec.line_renewal_type);

                 l_rulv_tbl_in(1).rgp_id                    := l_rule_group_id;
                 l_rulv_tbl_in(1).sfwt_flag                 := 'N';
                 l_rulv_tbl_in(1).std_template_yn           := 'N';
                 l_rulv_tbl_in(1).warn_yn                   := 'N';
                 l_rulv_tbl_in(1).rule_information_category := 'LRT';
                 l_rulv_tbl_in(1).rule_information1         := Nvl(p_k_covd_rec.line_renewal_type,'FUL');
                 l_rulv_tbl_in(1).dnz_chr_id                := p_k_covd_rec.k_id;

                 Create_rules
                 (
                    p_rulv_tbl      =>  l_rulv_tbl_in,
                    x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status =>  l_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data
                 );

                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: LRT Rule status :'|| l_return_status );
                 --dbms_output.put_line('K COVD LINE CREATION :- LRT RULE STATUS ' || l_return_status);
                 x_return_status := l_return_status;

                 If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                      l_rule_id := l_rulv_tbl_out(1).id;
                 Else
                      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE RENEWAL TYPE (SUB LINE)');
                      Raise G_EXCEPTION_HALT_VALIDATION;
                 End If;

              End If;

       End if;  -- validation for usage rules
*/
       --Create Pricing Attributes

       If p_price_attribs.pricing_context Is Not Null Then

                l_pavv_tbl_in(1).cle_id                 :=   l_line_id;
                l_pavv_tbl_in(1).flex_title             :=   'QP_ATTR_DEFNS_PRICING';
                l_pavv_tbl_in(1).pricing_context        :=   p_price_attribs.PRICING_CONTEXT;
                l_pavv_tbl_in(1).pricing_attribute1     :=   p_price_attribs.PRICING_ATTRIBUTE1;
                l_pavv_tbl_in(1).pricing_attribute2     :=   p_price_attribs.PRICING_ATTRIBUTE2;
                l_pavv_tbl_in(1).pricing_attribute3     :=   p_price_attribs.PRICING_ATTRIBUTE3;
                l_pavv_tbl_in(1).pricing_attribute4     :=   p_price_attribs.PRICING_ATTRIBUTE4;
                l_pavv_tbl_in(1).pricing_attribute5     :=   p_price_attribs.PRICING_ATTRIBUTE5;
                l_pavv_tbl_in(1).pricing_attribute6     :=   p_price_attribs.PRICING_ATTRIBUTE6;
                l_pavv_tbl_in(1).pricing_attribute7     :=   p_price_attribs.PRICING_ATTRIBUTE7;
                l_pavv_tbl_in(1).pricing_attribute8     :=   p_price_attribs.PRICING_ATTRIBUTE8;
                l_pavv_tbl_in(1).pricing_attribute9     :=   p_price_attribs.PRICING_ATTRIBUTE9;
                l_pavv_tbl_in(1).pricing_attribute10    :=   p_price_attribs.PRICING_ATTRIBUTE10;
                l_pavv_tbl_in(1).pricing_attribute11    :=   p_price_attribs.PRICING_ATTRIBUTE11;
                l_pavv_tbl_in(1).pricing_attribute12    :=   p_price_attribs.PRICING_ATTRIBUTE12;
                l_pavv_tbl_in(1).pricing_attribute13    :=   p_price_attribs.PRICING_ATTRIBUTE13;
                l_pavv_tbl_in(1).pricing_attribute14    :=   p_price_attribs.PRICING_ATTRIBUTE14;
                l_pavv_tbl_in(1).pricing_attribute15    :=   p_price_attribs.PRICING_ATTRIBUTE15;
                l_pavv_tbl_in(1).pricing_attribute16    :=   p_price_attribs.PRICING_ATTRIBUTE16;
                l_pavv_tbl_in(1).pricing_attribute17    :=   p_price_attribs.PRICING_ATTRIBUTE17;
                l_pavv_tbl_in(1).pricing_attribute18    :=   p_price_attribs.PRICING_ATTRIBUTE18;
                l_pavv_tbl_in(1).pricing_attribute19    :=   p_price_attribs.PRICING_ATTRIBUTE19;
                l_pavv_tbl_in(1).pricing_attribute20    :=   p_price_attribs.PRICING_ATTRIBUTE20;
                l_pavv_tbl_in(1).pricing_attribute21    :=   p_price_attribs.PRICING_ATTRIBUTE21;
                l_pavv_tbl_in(1).pricing_attribute22    :=   p_price_attribs.PRICING_ATTRIBUTE22;
                l_pavv_tbl_in(1).pricing_attribute23    :=   p_price_attribs.PRICING_ATTRIBUTE23;
                l_pavv_tbl_in(1).pricing_attribute24    :=   p_price_attribs.PRICING_ATTRIBUTE24;
                l_pavv_tbl_in(1).pricing_attribute25    :=   p_price_attribs.PRICING_ATTRIBUTE25;
                l_pavv_tbl_in(1).pricing_attribute26    :=   p_price_attribs.PRICING_ATTRIBUTE26;
                l_pavv_tbl_in(1).pricing_attribute27    :=   p_price_attribs.PRICING_ATTRIBUTE27;
                l_pavv_tbl_in(1).pricing_attribute28    :=   p_price_attribs.PRICING_ATTRIBUTE28;
                l_pavv_tbl_in(1).pricing_attribute29    :=   p_price_attribs.PRICING_ATTRIBUTE29;
                l_pavv_tbl_in(1).pricing_attribute30    :=   p_price_attribs.PRICING_ATTRIBUTE30;
                l_pavv_tbl_in(1).pricing_attribute31    :=   p_price_attribs.PRICING_ATTRIBUTE31;
                l_pavv_tbl_in(1).pricing_attribute32    :=   p_price_attribs.PRICING_ATTRIBUTE32;
                l_pavv_tbl_in(1).pricing_attribute33    :=   p_price_attribs.PRICING_ATTRIBUTE33;
                l_pavv_tbl_in(1).pricing_attribute34    :=   p_price_attribs.PRICING_ATTRIBUTE34;
                l_pavv_tbl_in(1).pricing_attribute35    :=   p_price_attribs.PRICING_ATTRIBUTE35;
                l_pavv_tbl_in(1).pricing_attribute36    :=   p_price_attribs.PRICING_ATTRIBUTE36;
                l_pavv_tbl_in(1).pricing_attribute37    :=   p_price_attribs.PRICING_ATTRIBUTE37;
                l_pavv_tbl_in(1).pricing_attribute38    :=   p_price_attribs.PRICING_ATTRIBUTE38;
                l_pavv_tbl_in(1).pricing_attribute39    :=   p_price_attribs.PRICING_ATTRIBUTE39;
                l_pavv_tbl_in(1).pricing_attribute40    :=   p_price_attribs.PRICING_ATTRIBUTE40;
                l_pavv_tbl_in(1).pricing_attribute41    :=   p_price_attribs.PRICING_ATTRIBUTE41;
                l_pavv_tbl_in(1).pricing_attribute42    :=   p_price_attribs.PRICING_ATTRIBUTE42;
                l_pavv_tbl_in(1).pricing_attribute43    :=   p_price_attribs.PRICING_ATTRIBUTE43;
                l_pavv_tbl_in(1).pricing_attribute44    :=   p_price_attribs.PRICING_ATTRIBUTE44;
                l_pavv_tbl_in(1).pricing_attribute45    :=   p_price_attribs.PRICING_ATTRIBUTE45;
                l_pavv_tbl_in(1).pricing_attribute46    :=   p_price_attribs.PRICING_ATTRIBUTE46;
                l_pavv_tbl_in(1).pricing_attribute47    :=   p_price_attribs.PRICING_ATTRIBUTE47;
                l_pavv_tbl_in(1).pricing_attribute48    :=   p_price_attribs.PRICING_ATTRIBUTE48;
                l_pavv_tbl_in(1).pricing_attribute49    :=   p_price_attribs.PRICING_ATTRIBUTE49;
                l_pavv_tbl_in(1).pricing_attribute50    :=   p_price_attribs.PRICING_ATTRIBUTE50;
                l_pavv_tbl_in(1).pricing_attribute51    :=   p_price_attribs.PRICING_ATTRIBUTE51;
                l_pavv_tbl_in(1).pricing_attribute52    :=   p_price_attribs.PRICING_ATTRIBUTE52;
                l_pavv_tbl_in(1).pricing_attribute53    :=   p_price_attribs.PRICING_ATTRIBUTE53;
                l_pavv_tbl_in(1).pricing_attribute54    :=   p_price_attribs.PRICING_ATTRIBUTE54;
                l_pavv_tbl_in(1).pricing_attribute55    :=   p_price_attribs.PRICING_ATTRIBUTE55;
                l_pavv_tbl_in(1).pricing_attribute56    :=   p_price_attribs.PRICING_ATTRIBUTE56;
                l_pavv_tbl_in(1).pricing_attribute57    :=   p_price_attribs.PRICING_ATTRIBUTE57;
                l_pavv_tbl_in(1).pricing_attribute58    :=   p_price_attribs.PRICING_ATTRIBUTE58;
                l_pavv_tbl_in(1).pricing_attribute59    :=   p_price_attribs.PRICING_ATTRIBUTE59;
                l_pavv_tbl_in(1).pricing_attribute60    :=   p_price_attribs.PRICING_ATTRIBUTE60;
                l_pavv_tbl_in(1).pricing_attribute61    :=   p_price_attribs.PRICING_ATTRIBUTE61;
                l_pavv_tbl_in(1).pricing_attribute62    :=   p_price_attribs.PRICING_ATTRIBUTE62;
                l_pavv_tbl_in(1).pricing_attribute63    :=   p_price_attribs.PRICING_ATTRIBUTE63;
                l_pavv_tbl_in(1).pricing_attribute64    :=   p_price_attribs.PRICING_ATTRIBUTE64;
                l_pavv_tbl_in(1).pricing_attribute65    :=   p_price_attribs.PRICING_ATTRIBUTE65;
                l_pavv_tbl_in(1).pricing_attribute66    :=   p_price_attribs.PRICING_ATTRIBUTE66;
                l_pavv_tbl_in(1).pricing_attribute67    :=   p_price_attribs.PRICING_ATTRIBUTE67;
                l_pavv_tbl_in(1).pricing_attribute68    :=   p_price_attribs.PRICING_ATTRIBUTE68;
                l_pavv_tbl_in(1).pricing_attribute69    :=   p_price_attribs.PRICING_ATTRIBUTE69;
                l_pavv_tbl_in(1).pricing_attribute70    :=   p_price_attribs.PRICING_ATTRIBUTE70;
                l_pavv_tbl_in(1).pricing_attribute71    :=   p_price_attribs.PRICING_ATTRIBUTE71;
                l_pavv_tbl_in(1).pricing_attribute72    :=   p_price_attribs.PRICING_ATTRIBUTE72;
                l_pavv_tbl_in(1).pricing_attribute73    :=   p_price_attribs.PRICING_ATTRIBUTE73;
                l_pavv_tbl_in(1).pricing_attribute74    :=   p_price_attribs.PRICING_ATTRIBUTE74;
                l_pavv_tbl_in(1).pricing_attribute75    :=   p_price_attribs.PRICING_ATTRIBUTE75;
                l_pavv_tbl_in(1).pricing_attribute76    :=   p_price_attribs.PRICING_ATTRIBUTE76;
                l_pavv_tbl_in(1).pricing_attribute77    :=   p_price_attribs.PRICING_ATTRIBUTE77;
                l_pavv_tbl_in(1).pricing_attribute78    :=   p_price_attribs.PRICING_ATTRIBUTE78;
                l_pavv_tbl_in(1).pricing_attribute79    :=   p_price_attribs.PRICING_ATTRIBUTE79;
                l_pavv_tbl_in(1).pricing_attribute80    :=   p_price_attribs.PRICING_ATTRIBUTE80;
                l_pavv_tbl_in(1).pricing_attribute81    :=   p_price_attribs.PRICING_ATTRIBUTE81;
                l_pavv_tbl_in(1).pricing_attribute82    :=   p_price_attribs.PRICING_ATTRIBUTE82;
                l_pavv_tbl_in(1).pricing_attribute83    :=   p_price_attribs.PRICING_ATTRIBUTE83;
                l_pavv_tbl_in(1).pricing_attribute84    :=   p_price_attribs.PRICING_ATTRIBUTE84;
                l_pavv_tbl_in(1).pricing_attribute85    :=   p_price_attribs.PRICING_ATTRIBUTE85;
                l_pavv_tbl_in(1).pricing_attribute86    :=   p_price_attribs.PRICING_ATTRIBUTE86;
                l_pavv_tbl_in(1).pricing_attribute87    :=   p_price_attribs.PRICING_ATTRIBUTE87;
                l_pavv_tbl_in(1).pricing_attribute88    :=   p_price_attribs.PRICING_ATTRIBUTE88;
                l_pavv_tbl_in(1).pricing_attribute89    :=   p_price_attribs.PRICING_ATTRIBUTE89;
                l_pavv_tbl_in(1).pricing_attribute90    :=   p_price_attribs.PRICING_ATTRIBUTE90;
                l_pavv_tbl_in(1).pricing_attribute91    :=   p_price_attribs.PRICING_ATTRIBUTE91;
                l_pavv_tbl_in(1).pricing_attribute92    :=   p_price_attribs.PRICING_ATTRIBUTE92;
                l_pavv_tbl_in(1).pricing_attribute93    :=   p_price_attribs.PRICING_ATTRIBUTE93;
                l_pavv_tbl_in(1).pricing_attribute94    :=   p_price_attribs.PRICING_ATTRIBUTE94;
                l_pavv_tbl_in(1).pricing_attribute95    :=   p_price_attribs.PRICING_ATTRIBUTE95;
                l_pavv_tbl_in(1).pricing_attribute96    :=   p_price_attribs.PRICING_ATTRIBUTE96;
                l_pavv_tbl_in(1).pricing_attribute97    :=   p_price_attribs.PRICING_ATTRIBUTE97;
                l_pavv_tbl_in(1).pricing_attribute98    :=   p_price_attribs.PRICING_ATTRIBUTE98;
                l_pavv_tbl_in(1).pricing_attribute99    :=   p_price_attribs.PRICING_ATTRIBUTE99;
                l_pavv_tbl_in(1).pricing_attribute100   :=   p_price_attribs.PRICING_ATTRIBUTE100;

                okc_price_adjustment_pvt.create_price_att_value
                (
                   p_api_version        => l_api_version,
                   p_init_msg_list      => l_init_msg_list,
                   x_return_status      => l_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data,
                   p_pavv_tbl           => l_pavv_tbl_in,
                   x_pavv_tbl           => l_pavv_tbl_out
                );

                OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: create_price_att_value status :'|| l_return_status );
                --dbms_output.put_line('K COVD LINE CREATION :- PRICE ATTRIB STATUS ' || l_return_status);

                x_return_status := l_return_status;

                If l_return_status = OKC_API.G_RET_STS_SUCCESS then
                    l_priceattrib_id := l_pavv_tbl_out(1).id;
                Else
                    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRICE ATTRIBUTES (SUB LINE)');
                    Raise G_EXCEPTION_HALT_VALIDATION;
                End if;
          End If;
          x_cp_line_id := l_line_id;

Exception
    When  G_EXCEPTION_HALT_VALIDATION Then

        x_return_status := l_return_status;
        Null;
    When  Others Then

          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Covered_Line :: Error :'|| SQLCODE||':'|| SQLERRM);


End Create_Covered_Line;



----------------------------------------------------------------------------------------
-- Procedure for creating instance of subscription item
----------------------------------------------------------------------------------------

PROCEDURE create_item
 (
     p_instance_rec_out      IN OUT NOCOPY csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status            OUT NOCOPY    VARCHAR2
    ,x_msg_count                OUT NOCOPY    NUMBER
    ,x_msg_data                 OUT NOCOPY    VARCHAR2
 )
IS

    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_ITEM';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    l_debug_level                   VARCHAR2(1);
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_instance_rec_out              CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
    l_ext_attrib_values_tbl         CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
    l_party_tbl                     CSI_DATASTRUCTURES_PUB.PARTY_TBL;
    l_account_tbl                   CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
    l_pricing_attrib_tbl            CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
    l_org_assignments_tbl           CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
    l_asset_assignment_tbl          CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
    l_txn_rec                       CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
    l_return_status                 VARCHAR2(2000);
    l_msg_index_out                 NUMBER;
    t_output                        VARCHAR2(2000);
    t_msg_dummy                     NUMBER;


BEGIN

-- calling Ib API to craete item instance
   csi_item_instance_pub.create_item_instance
   (
      p_api_version              => 1.0
     ,p_commit                   => 'F'
     ,p_init_msg_list            => 'F'
     ,p_validation_level         => 1
     ,p_instance_rec             => p_instance_rec_out
     ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
     ,p_party_tbl                => p_party_tbl
     ,p_account_tbl              => p_account_tbl
     ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
     ,p_org_assignments_tbl      => p_org_assignments_tbl
     ,p_asset_assignment_tbl     => p_asset_assignment_tbl
     ,p_txn_rec                  => p_txn_rec
     ,x_return_status            => l_return_status
     ,x_msg_count                => x_msg_count
     ,x_msg_data                 => x_msg_data
   );

    OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Item :: create_item_instance status :'|| l_return_status );
    --dbms_output.put_line('create item instance status:-  ' || l_return_status);

    IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;
Exception
    When  G_EXCEPTION_HALT_VALIDATION Then
        x_return_status := l_return_status;
        Null;
    When  Others Then
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Item :: Error :'|| SQLCODE||':'||SQLERRM );
End create_item;



---------------------------------------------------------------------------------------
-- Procedure for Creating contract for subscription item
---------------------------------------------------------------------------------------

PROCEDURE Create_Subscription
(                              p_K_header_rec                   IN  OKS_CONTRACTS_PUB.header_rec_type
                         ,     p_K_Support_rec                  IN  OKS_CONTRACTS_PUB.line_rec_type
                         ,     p_Support_contacts_tbl_in        IN  OKS_CONTRACTS_PUB.contact_tbl
                         ,     p_Support_sales_crd_tbl_in       IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
                         ,     p_k_line_rec                     IN  OKS_CONTRACTS_PUB.line_rec_type
                         ,     p_line_contacts_tbl_in           IN  OKS_CONTRACTS_PUB.contact_tbl
                         ,     p_line_sales_crd_tbl_in          IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
                         ,     p_price_attribs_in               IN  OKS_CONTRACTS_PUB.pricing_attributes_type
                         ,     p_contract_header_id             IN  NUMBER
                         ,     bill_type                        IN  varchar2
                         ,     p_strm_level_tbl                 IN  OKS_BILL_SCH.StreamLvl_tbl
                         ,     x_return_status                  OUT NOCOPY VARCHAR2
                         ,     x_msg_count                      OUT NOCOPY NUMBER
                         ,     x_msg_data                       OUT NOCOPY varchar2
) IS

-- Cursor for getting name and description of the product/item
Cursor l_line_Csr(p_inventory_id Number,p_organization_id Number) Is
                  Select  MTL.Name
                         ,MTL.Description
                         ,MTL.Primary_UOM_Code
                         ,MTL.Service_starting_delay
                  From    OKX_SYSTEM_ITEMS_V MTL
                  Where   MTL.id1   = p_Inventory_id
                  And     MTL.Organization_id = okc_context.get_okc_organization_id;

l_line_dtl_rec     l_line_csr%rowtype;

--  cursor for getting rule informations
Cursor l_rule_dtl_csr Is
       Select  ks.averaging_interval
             , ks.uom_quantified
             --, ks.rule_information3
             , ks.minimum_quantity
             , ks.default_quantity
             , ks.amcv_flag
             , ks.fixed_quantity
             , ks.level_yn
             , ks.usage_type
             --, ks.rule_information10
             , ks.base_reading
        From oks_k_lines_b ks,
             okc_k_lines_v kc
        Where ks.cle_id = kc.id
        And   kc.lse_id = 12;

  l_rule_dtl_rec     l_rule_dtl_csr%rowtype;

  Cursor l_subscr_scr (p_line_id number, p_hdr_id number) is
  Select instance_id from oks_subscr_header_b
  Where  cle_id = p_line_id
  And    dnz_chr_id = p_hdr_id;

 -- local variables
  i                        NUMBER;
  l_contract_header_id     NUMBER;
  l_sb_service_line_id     NUMBER;                                          -- Service line id for Subscription line
  l_su_service_line_id     NUMBER;                                          -- Service line id for Support line
  l_u_service_line_id      NUMBER;                                          -- Service line id for Usage line
  l_cp_line_id             NUMBER;
  l_time_val               NUMBER;
  cp_id                    NUMBER;
  l_return_status          VARCHAR2(2000) := OKC_API.G_RET_STS_SUCCESS;
  l_K_line_rec             OKS_CONTRACTS_PUB.line_Rec_Type;                 -- subscription line record
  l_counter_tbl            OKS_CONTRACTS_PUB.counter_tbl;                   -- counter table
  l_K_support_rec          OKS_CONTRACTS_PUB.line_Rec_Type;                 -- Support line record
  l_K_usage_rec            OKS_CONTRACTS_PUB.line_Rec_Type;                 -- Usage line record
  l_K_covd_rec             OKS_CONTRACTS_PUB.Covered_level_Rec_Type;        -- Covered level record for support line
  l_K_counter_rec          OKS_CONTRACTS_PUB.Covered_level_Rec_Type;        -- covered level record for usage line
  l_k_hdr_rec              OKS_CONTRACTS_PUB.header_rec_type;               -- Header record
  p_instance_rec           CSI_DATASTRUCTURES_PUB.INSTANCE_REC;             -- Item Instance record
  p_ext_attrib_values_tbl  CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL; -- Attributes value table
  p_party_tbl              CSI_DATASTRUCTURES_PUB.PARTY_TBL;
  p_account_tbl            CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
  p_pricing_attrib_tbl     CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
  p_org_assignments_tbl    CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
  p_asset_assignment_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
  p_txn_rec                CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
  l_bil_sch_out_tbl        OKS_BILL_SCH.ItemBillSch_tbl;
  --l_slh_rec                OKS_BILL_SCH.StreamHdr_type;
  l_msg_index              Number;
  l_inst_id                Number;


BEGIN

      DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTIONS');

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  SRV Id for Subscription line        :'|| p_k_line_rec.srv_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  SRV Id for Support Line             :'|| p_K_support_rec.srv_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Negotiated amount for SB line       :'|| p_k_line_rec.negotiated_amount );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Negotiated amount for SU line       :'|| p_K_support_rec.negotiated_amount );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Negotiated amount for Covered line  :'|| p_K_support_rec.negotiated_amount );

      l_contract_header_id := p_contract_header_id;

      -- calling create item procedure to create CP
      p_instance_rec.location_type_code               := p_k_line_rec.location_type_code;
      p_instance_rec.location_Id                      := p_k_line_rec.location_Id;
      p_instance_rec.Inv_organization_Id              := p_k_line_rec.Inv_organization_Id;
      p_instance_rec.Inv_subinventory_name            := p_k_line_rec.Inv_subinventory_name;
      p_instance_rec.Inv_locator_Id                   := p_k_line_rec.Inv_locator_Id;
      p_instance_rec.Pa_project_Id                    := p_k_line_rec.Pa_project_Id;
      p_instance_rec.Pa_project_task_Id               := p_k_line_rec.Pa_project_task_Id;
      p_instance_rec.In_transit_order_line_Id         := p_k_line_rec.In_transit_order_line_Id;
      p_instance_rec.wip_job_Id                       := p_k_line_rec.wip_job_Id;
      p_instance_rec.po_order_line_Id                 := p_k_line_rec.po_order_line_Id;
      p_instance_rec.inventory_item_id                := p_k_line_rec.srv_id ; -- inventory item id
      p_instance_rec.vld_organization_id              := okc_context.get_okc_organization_id;
      p_instance_rec.inventory_revision               := 'A';
      p_instance_rec.inv_master_organization_id       := okc_context.get_okc_organization_id;
      p_instance_rec.quantity                         := 1;
      p_instance_rec.unit_of_measure                  := 'Ea';
      p_instance_rec.instance_condition_id            := 1; --NULL;
      p_instance_rec.active_start_date                := FND_API.G_MISS_DATE;
      p_instance_rec.active_end_date                  := FND_API.G_MISS_DATE;  --TO_DATE('Null');
      p_instance_rec.in_transit_order_line_id         := okc_api.g_miss_num;
      p_party_tbl(1).party_source_table               := 'HZ_PARTIES';
      p_party_tbl(1).party_id                         := p_k_header_rec.party_id;--1000; --NULL;
      p_party_tbl(1).relationship_type_code           := 'OWNER';
      p_party_tbl(1).contact_flag                     := 'N';
      p_account_tbl(1).ip_account_id                  := NULL;
      p_account_tbl(1).parent_tbl_index               := 1; --NULL;
      p_account_tbl(1).instance_party_id              := NULL;
      p_account_tbl(1).party_account_id               := p_k_line_rec.cust_account;--1000; --NULL;
      p_account_tbl(1).relationship_type_code         := 'OWNER';
      p_org_assignments_tbl(1).operating_unit_id      := p_k_line_rec.org_id; --NULL;
      p_org_assignments_tbl(1).relationship_type_code := 'SOLD_FROM';
      p_txn_rec.transaction_type_id                   := 1; --NULL;
      p_txn_rec.source_transaction_date               := SYSDATE;
      p_txn_rec.transaction_date                      := SYSDATE;


      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: ord Id for Item          :'|| p_instance_rec.vld_organization_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Uom for Item             :'|| p_instance_rec.unit_of_measure );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Active Satrt date of Item:'|| p_instance_rec.active_start_date );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Active End Date of Item  :'|| p_instance_rec.active_end_date  );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Party account Id of Item :'|| p_account_tbl(1).party_account_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Inventory Item Id        :'|| p_instance_rec.inventory_item_id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Po order line Id  of Item:'|| p_instance_rec.po_order_line_Id );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Location Id of Item      :'|| p_instance_rec.location_Id );

/*
      Create_item
     (
         p_instance_rec_out      => p_instance_rec
        ,p_ext_attrib_values_tbl => p_ext_attrib_values_tbl
        ,p_party_tbl             => p_party_tbl
        ,p_account_tbl           => p_account_tbl
        ,p_pricing_attrib_tbl    => p_pricing_attrib_tbl
        ,p_org_assignments_tbl   => p_org_assignments_tbl
        ,p_asset_assignment_tbl  => p_asset_assignment_tbl
        ,p_txn_rec               => p_txn_rec
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
     );

     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: create_item status :'|| l_return_status );
     OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Item Id            :'||p_instance_rec.instance_id );
     --dbms_output.put_line('create item status:-  ' || l_return_status);
     --dbms_output.put_line('create item status :: item id:-  ' || p_instance_rec.instance_id);

     IF  Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
*/

     -- create service line for subscription line but it will not have a covered level

     l_K_line_rec          := p_K_line_rec;
     l_K_line_rec.k_hdr_id := l_contract_header_id;
     l_k_line_rec.srv_id   := p_k_line_rec.srv_id ;  --p_instance_rec.instance_id;

     --dbms_output.put_line('l_k_line_rec.srv_id '||   p_k_line_rec.srv_id);

     Create_Service_Line
     (
       p_k_line_rec         => l_K_line_rec
      ,p_Contact_tbl        => p_line_contacts_tbl_in
      ,p_line_sales_crd_tbl => p_line_sales_crd_tbl_in
      ,x_service_line_id    => l_sb_service_line_id
      ,x_return_status      => l_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Create SB Service Line status :'|| l_return_status );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Service line Id for SB Line   :'|| l_sb_service_line_id );
      --dbms_output.put_line('K SUBSCRIPTION LINE CREATION STATUS:-  ' || l_return_status);

      IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
             DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
             RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- Create default schedule

      oks_subscription_pvt.create_default_schedule
      (
                 p_api_version   => 1.0,
                 p_init_msg_list => 'T' ,
                 x_return_status => l_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_cle_id        => l_sb_service_line_id,
                 p_intent        => Null);

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Create default sch status :'|| l_return_status );
      --dbms_output.put_line('K SUBSCRIPTION LINE CREATION STATUS:-  ' || l_return_status);

      IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
             DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
             RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      OPEN l_subscr_scr(l_sb_service_line_id,l_contract_header_id);
      FETCH l_subscr_scr into l_inst_id;
      close l_subscr_scr;

      -- create a service line for support serive line and covered level for that

      l_K_support_rec          := p_K_Support_rec ;
      l_K_support_rec.k_hdr_id := l_contract_header_id;

      --dbms_output.put_line(' support line id '|| l_K_support_rec.srv_id);

      Create_Service_Line
      (
          p_k_line_rec         => l_K_support_rec
         ,p_Contact_tbl        => p_support_contacts_tbl_in
         ,p_line_sales_crd_tbl => p_support_sales_crd_tbl_in
         ,x_service_line_id    => l_su_service_line_id
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Create SU Service Line status :'|| l_return_status);
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Service line Id for Su Line   :'|| l_su_service_line_id);
      --dbms_output.put_line('K CONTRACT SUPPORT SERVICE LINE CREATION STATUS:-  ' || l_return_status);

      IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- Get the name description details of the product

      Open l_line_Csr(p_instance_rec.Inventory_Item_Id ,l_k_support_rec.org_id );
      Fetch l_line_Csr into l_line_dtl_rec;

      If l_line_Csr%notfound Then
             Close l_line_Csr ;
             l_return_status := OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message(G_APP_NAME,'OKS_CUST_PROD_DTLS_NOT_FOUND','CUSTOMER_PRODUCT',p_instance_rec.instance_id);
--             message 'OKS_CUSTPROD' to be changed
             Raise G_EXCEPTION_HALT_VALIDATION;
      End if;

      Close l_line_Csr;

      -- creating covered level for support service line
      l_K_covd_rec.k_id                 := l_contract_header_id;
      l_K_covd_rec.Attach_2_Line_id     := l_su_service_line_id;
      l_K_covd_rec.line_number          := 1;
      l_K_covd_rec.product_sts_code     := p_k_support_rec.line_sts_code;
      l_K_covd_rec.Customer_Product_Id  := l_inst_id ;           --p_instance_rec.instance_id ;
      l_K_covd_rec.Product_Desc         := l_line_dtl_rec.description;
      l_K_covd_rec.Product_Start_Date   := p_k_header_rec.start_date;
      l_K_covd_rec.Product_End_Date     := p_k_header_rec.end_date;
      l_K_covd_rec.Quantity             := p_instance_rec.Quantity;
      l_K_covd_rec.uom_code             := l_line_dtl_rec.primary_uom_code;-- p_instance_rec.unit_of_measure;
      l_K_covd_rec.list_price           := l_k_support_rec.list_price ;
      l_K_covd_rec.negotiated_amount    := l_k_support_rec.negotiated_amount;
      l_K_covd_rec.currency_code        := l_k_support_rec.currency;
      l_K_covd_rec.reason_code          := l_k_support_rec.reason_code;
      l_K_covd_rec.reason_comments      := l_k_support_rec.reason_comments;
      l_K_covd_rec.line_renewal_type    := p_k_line_rec.line_renewal_type;

      Create_Covered_Line
      (
            p_k_covd_rec             => l_K_covd_rec
            ,p_PRICE_ATTRIBS         => p_price_attribs_in
            ,x_cp_line_id            => l_cp_line_id
            ,x_return_status         => l_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Create_Covered_Line for SU line status :'|| l_return_status );
      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Covered line id for support line       :'|| l_cp_line_id );
      --dbms_output.put_line('K COVERED PRODUCT CREATION FOR SUPPORT SERVICE LINE STATUS:-  ' || l_return_status);

      IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
           DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
           RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

     /* -- if CP has a counter then create a covered usage line  - for counter
      cp_id := p_instance_rec.instance_id;
      --dbms_output.put_line('Customer product Id '|| cp_id );

      -- Check if any usage is associated with the product
      Check_for_usage
      (
                p_CP_id         =>cp_id
            ,   x_counter_tbl   => l_counter_tbl
            ,   x_return_status => x_return_status
            ,   x_msg_data      => x_msg_data
            ,   x_msg_count     => x_msg_count
       );

       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Check_for_usage status :'|| x_return_status);
       OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Number of Usage Lines  :'|| l_counter_tbl.count );
       --dbms_output.put_line('CHECK FOR USAGE LINE STATUS:-  ' || x_return_status||' ctr tbl'||l_counter_tbl.count);

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

       -- opening rule detail cursor :
       -- rule_information1  :: Average_bill_flag
       -- rule_information2  :: Period
       -- rule_information3  :: Settlement_flag
       -- rule_information4  :: Minimum
       -- rule_information5  :: Default
       -- rule_information6  :: Amcv
       -- rule_information7  :: Fixed
       -- rule_information8
       -- rule_information9  :: Level
       -- rule_information10 :: Usage_type
       -- rule_information11
       -- rule_information12 :: Base


       Open l_rule_dtl_Csr;
       Fetch l_rule_dtl_Csr into l_rule_dtl_rec;
       If l_rule_dtl_Csr%notfound Then
             Close l_rule_dtl_Csr ;
             x_return_status := OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message(G_APP_NAME,'OKS_CUST_PROD_DTLS_NOT_FOUND','CUSTOMER_PRODUCT',p_instance_rec.instance_id);
             Raise G_EXCEPTION_HALT_VALIDATION;
       End if;
       Close l_rule_dtl_Csr;

       -- create service line and covered lines for usage and counters associated with the product.
       If l_counter_tbl.count > 0 Then
             i := l_Counter_Tbl.First;

             LOOP
             if (l_counter_tbl(i).usage_item_id <> Null) then
                  l_K_usage_rec                     :=   p_K_Support_rec ;
                  l_K_usage_rec.k_hdr_id            :=   l_contract_header_id;
                  l_k_usage_rec.customer_product_id :=   l_counter_tbl(i).usage_item_id;
                  l_k_usage_rec.usage_type          :=   l_rule_dtl_rec.rule_information10;
                  l_k_usage_rec.usage_period        :=   l_rule_dtl_rec.rule_information2;
                  l_k_usage_rec.line_type           :=   'U';

                  Create_Service_Line
                  (
                         p_k_line_rec         => l_K_usage_rec
                        ,p_Contact_tbl        => p_support_contacts_tbl_in
                        ,p_line_sales_crd_tbl => p_support_sales_crd_tbl_in
                        ,x_service_line_id    => l_u_service_line_id
                        ,x_return_status      => x_return_status
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                   );
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Create_Service_Line status     :'|| x_return_status );
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Service Line Id sor usage line :'|| l_u_service_line_id );

                  --dbms_output.put_line('K CONTRACT USAGE LINE CREATION STATUS:-  ' || x_return_status);

                  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;

                  -- opening line cursor
                  Open l_line_Csr(l_counter_tbl(i).usage_item_id,l_k_usage_rec.org_id ); --to pass invetory item id
                  Fetch l_line_Csr into l_line_dtl_rec;
                  If l_line_Csr%notfound Then
                        Close l_line_Csr ;
                        l_return_status := OKC_API.G_RET_STS_ERROR;
                        OKC_API.set_message(G_APP_NAME,'OKS_CUST_PROD_DTLS_NOT_FOUND','CUSTOMER_PRODUCT',p_instance_rec.instance_id);
                        Raise G_EXCEPTION_HALT_VALIDATION;
                  End if;
                  Close l_line_Csr;


                  l_K_counter_rec.k_id                 := l_contract_header_id;
                  l_K_counter_rec.Attach_2_Line_id     := l_u_service_line_id;
                  l_K_counter_rec.line_number          := 1;
                  l_K_counter_rec.product_sts_code     := 'OKX_COUNTER';
                  l_K_counter_rec.Customer_Product_Id  := l_counter_tbl(i).usage_item_id;
                  l_K_counter_rec.Product_Desc         := l_line_dtl_rec.description;
                  l_K_counter_rec.Product_Start_Date   := p_k_header_rec.start_date;
                  l_K_counter_rec.Product_End_Date     := p_k_header_rec.end_date;
                --  l_K_counter_rec.Quantity             := p_instance_rec.Quantity;
                --  l_K_counter_rec.uom_code             := l_line_dtl_rec.primary_uom_code;
                  l_K_counter_rec.list_price           := l_k_usage_rec.list_price;
                  l_K_counter_rec.negotiated_amount    := l_k_usage_rec.negotiated_amount;
                  l_K_counter_rec.currency_code        := l_k_usage_rec.currency;
                  l_K_counter_rec.reason_code          := l_k_usage_rec.reason_code;
                  l_K_counter_rec.reason_comments      := l_k_usage_rec.reason_comments;
                  l_K_counter_rec.line_renewal_type    := p_k_header_rec.renewal_type;
                  l_K_counter_rec.minimum_qty          := l_rule_dtl_rec.rule_information4;
                  l_K_counter_rec.default_qty          := l_rule_dtl_rec.rule_information5;
                  l_K_counter_rec.period               := l_rule_dtl_rec.rule_information2;
                  l_K_counter_rec.amcv_flag            := l_rule_dtl_rec.rule_information6;
                  l_K_counter_rec.fixed_qty            := l_rule_dtl_rec.rule_information7;
                  l_K_counter_rec.level_yn             := l_rule_dtl_rec.rule_information9;
                  l_K_counter_rec.base_reading         := l_rule_dtl_rec.rule_information12;
                  l_K_counter_rec.settlement_flag      := l_rule_dtl_rec.rule_information3;
                  l_K_counter_rec.average_bill_flag    := l_rule_dtl_rec.rule_information1;
                  l_K_counter_rec.invoice_print_flag   := '';
                  l_K_counter_rec.ATTRIBUTE1           := '';
                  l_K_counter_rec.ATTRIBUTE2           := '';
                  l_K_counter_rec.ATTRIBUTE3           := '';
                  l_K_counter_rec.ATTRIBUTE4           := '';
                  l_K_counter_rec.ATTRIBUTE5           := '';
                  l_K_counter_rec.ATTRIBUTE6           := '';
                  l_K_counter_rec.ATTRIBUTE7           := '';
                  l_K_counter_rec.ATTRIBUTE8           := '';
                  l_K_counter_rec.ATTRIBUTE9           := '';
                  l_K_counter_rec.ATTRIBUTE10          := '';
                  l_K_counter_rec.ATTRIBUTE11          := '';
                  l_K_counter_rec.ATTRIBUTE12          := '';
                  l_K_counter_rec.ATTRIBUTE13          := '';
                  l_K_counter_rec.ATTRIBUTE14          := '';
                  l_K_counter_rec.ATTRIBUTE15          := '';

                  Create_Covered_Line
                  (
                            p_k_covd_rec               => l_K_counter_rec
                            ,p_PRICE_ATTRIBS           => p_price_attribs_in
                            ,x_cp_line_id              => l_cp_line_id
                            ,x_return_status           => x_return_status
                            ,x_msg_count               => x_msg_count
                            ,x_msg_data                => x_msg_data
                   );
                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Create_Covered_Line status     :'|| x_return_status );
                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Line Id for usage covered line :'|| l_cp_line_id );

                 --dbms_output.put_line('K COVERED PRODUCT CREATION FOR USAGE LINE STATUS:-  ' || x_return_status);

                  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;

                  --  Billing schedule for usage line

                  l_slh_rec := p_Strm_hdr_rec;
                  l_slh_rec.cle_id := l_u_service_line_id;
                  IF l_slh_rec.Object1_Id1 IS NULL THEN
                     l_slh_rec.Object1_Id1 := '1';
                  END IF;

                  IF l_slh_rec.Object2_Id1 IS NULL THEN
                      Create_timeval
                      (
                          p_line_id        => l_slh_rec.cle_id,
                          x_time_val       => l_time_val,
                          x_return_status  => x_return_status
                       );

                       --dbms_output.put_line('create time val '|| x_return_status);
                       IF x_return_status = 'S' THEN
                          l_slh_rec.Object2_Id1 := l_time_val;
                       ELSE
                          x_return_status := OKC_API.G_RET_STS_ERROR;
                          DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                          Raise G_EXCEPTION_HALT_VALIDATION;
                       END IF;
                   END IF;

                   --dbms_output.put_line('rule information catagory '|| l_slh_rec.Rule_Information_Category );
                   OKS_BILL_SCH.Create_Bill_Sch_Rules
                   (
                       p_billing_type         => p_billing_sch_type,
                       p_sll_tbl              => p_strm_level_tbl,
                       p_invoice_rule_id      => l_K_support_rec.invoicing_rule_type,
                       x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
                       x_return_status        => x_return_status
                    );

                    --dbms_output.put_line('K BILL SCHEDULE FOR USAGE LINE STATUS  ' || x_return_status);
                    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    -- End of Billing Schedule for Usage Line
            END If;
            i := l_Counter_Tbl.Next(i);
         END LOOP;  -- End of counter_tbl.count
      End If;    -- End of counter_tbl.count IF


*/


-- create billing schd for subscription lines :one time billing

IF (l_k_line_rec.line_type = 'SB') THEN

   --dbms_output.put_line('amount'||l_k_line_rec.negotiated_amount);

   Create_Billing_Schd
   (
        P_srv_sdt             => p_k_header_rec.start_date
      , P_srv_edt             => p_k_header_rec.end_date
      , P_amount              => l_k_line_rec.negotiated_amount
      , P_chr_id              => l_contract_header_id
      , P_rule_id             => NULL
      , P_line_id             => l_sb_service_line_id
      , P_invoice_rule_id     => l_k_line_rec.invoicing_rule_type
      , X_msg_data            => X_msg_data
      , X_msg_count           => X_msg_count
      , X_Return_status       => l_Return_status
   );

   OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Create_Billing_Schd for SB Line status :'|| l_return_status );
   --dbms_output.put_line('SUBSCRIPTION LINE BILL SCHEDULE STATUS:-  ' || l_return_status);

   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

END If;  -- end of billing for subscription line

-- for support line recursive billing

IF(l_k_support_rec.line_type = 'S') then

 Create_Billing_Schd
   (
        P_srv_sdt             => p_k_support_rec.srv_sdt
      , P_srv_edt             => p_k_support_rec.srv_edt
      , P_amount              => null --l_k_line_rec.negotiated_amount
      , P_chr_id              => l_contract_header_id
      , P_rule_id             => NULL
      , P_line_id             => l_su_service_line_id
      , P_invoice_rule_id     => l_k_line_rec.invoicing_rule_type
      , X_msg_data            => X_msg_data
      , X_msg_count           => X_msg_count
      , X_Return_status       => l_Return_status
   );

    -- l_slh_rec := p_Strm_hdr_rec;
    -- l_slh_rec.cle_id := l_su_service_line_id;

    -- IF l_slh_rec.Object1_Id1 IS NULL THEN
    --    l_slh_rec.Object1_Id1 := '1';
    -- END IF;

   --  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Object2_id1             :'|| l_slh_rec.Object2_Id1 );
 /*
     IF l_slh_rec.Object2_Id1 IS NULL THEN
        Create_timeval
        (
           p_line_id        => l_slh_rec.cle_id,
           x_time_val       => l_time_val,
           x_return_status  => l_return_status
         );

        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::Create_timeval            :'|| l_return_status );
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::Time val                  :'|| l_time_val );
        OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::Rule Information catagory :'|| l_slh_rec.Rule_Information_Category  );
        --dbms_output.put_line('create time val '|| x_return_status);

        IF l_return_status = 'S' THEN
              l_slh_rec.Object2_Id1 := l_time_val;
        ELSE
             l_return_status := OKC_API.G_RET_STS_ERROR;
             DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
             Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
     END IF;

     --dbms_output.put_line('rule information catagory '|| l_slh_rec.Rule_Information_Category );
     OKS_BILL_SCH.Create_Bill_Sch_Rules
     (
       p_billing_type         => bill_type,
       p_sll_tbl              => p_strm_level_tbl,
       p_invoice_rule_id      => l_K_line_rec.invoicing_rule_type,
       x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
       x_return_status        => l_return_status
      );

      OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription ::  Create_Bill_Sch_Rules for Support Line status :'|| l_return_status );
      --dbms_output.put_line('K BILL SCHEDULE FOR SERVICE LINE STATUS  ' || l_return_status);
*/
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

END IF;  -- end of billing for line type = 'SU'

IF    l_return_status <> 'S' THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTIONS');
END IF;

x_return_status := l_return_status;

Exception
    When  G_EXCEPTION_HALT_VALIDATION Then
        x_return_status := l_return_status;
        Null;
    When  Others Then
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Subscription :: Error :'|| SQLCODE || SQLERRM);

END Create_subscription;





---------------------------------------------------------------------------------
-- Procedure for creating contracts
---------------------------------------------------------------------------------



Procedure Create_Contract
(
      p_K_header_rec                   IN  OKS_CONTRACTS_PUB.header_rec_type
,     p_header_contacts_tbl            IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_header_sales_crd_tbl           IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_header_articles_tbl            IN  OKS_CONTRACTS_PUB.obj_articles_tbl
,     p_K_line_rec                     IN  OKS_CONTRACTS_PUB.line_rec_type
,     p_line_contacts_tbl              IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_line_sales_crd_tbl             IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_K_Support_rec                  IN  OKS_CONTRACTS_PUB.line_rec_type
,     p_Support_contacts_tbl           IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_Support_sales_crd_tbl          IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_K_covd_rec                     IN  OKS_CONTRACTS_PUB.Covered_level_Rec_Type
,     p_price_attribs_in               IN  OKS_CONTRACTS_PUB.pricing_attributes_type
,     p_merge_rule                     IN  Varchar2
,     p_usage_instantiate              IN  Varchar2
,     p_ib_creation                    IN  Varchar2
,     p_billing_sch_type               IN  Varchar2
,     p_strm_level_tbl                 IN  OKS_BILL_SCH.StreamLvl_tbl
,     x_chrid                          OUT NOCOPY Number
,     x_return_status                  OUT NOCOPY Varchar2
,     x_msg_count                      OUT NOCOPY Number
,     x_msg_data                       OUT NOCOPY Varchar2
)
IS

      l_contract_header_id    NUMBER;
      l_service_line_id       NUMBER;
      l_cp_line_id            NUMBER;
      l_bil_sch_out_tbl       OKS_BILL_SCH.ItemBillSch_tbl;
      --l_slh_rec               OKS_BILL_SCH.StreamHdr_type;
      l_K_line_rec            OKS_CONTRACTS_PUB.line_Rec_Type;
      l_k_support_rec         OKS_CONTRACTS_PUB.line_Rec_Type;
      l_k_hdr_rec             OKS_CONTRACTS_PUB.header_Rec_Type;
      l_K_covd_rec            OKS_CONTRACTS_PUB.Covered_level_Rec_Type;
      l_time_val              NUMBER;
      l_return_status         Varchar2(1);
      BEGIN

           DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Line Style                    :'|| p_K_line_rec.line_type );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Support line style            :'|| p_K_Support_rec.line_type );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Usage type                    :'|| p_K_line_rec.usage_type );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Header Renewal type           :'|| p_K_header_rec.renewal_type );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Line Renewal type             :'|| p_K_line_rec.line_renewal_type );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Coverage Renewal type         :'|| p_K_covd_rec.line_renewal_type );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Header Start Date             :'|| p_K_header_rec.start_date );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Header End Date               :'|| p_K_header_rec.end_date );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Customer Product Id           :'|| p_K_covd_rec.customer_product_id );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Product Description           :'|| p_K_covd_rec.product_desc );


           Create_Contract_Header
           (
               p_K_header_rec         => p_K_header_rec,
               p_header_contacts_tbl  => p_header_contacts_tbl,
               p_header_sales_crd_tbl => p_header_sales_crd_tbl,
               p_header_articles_tbl  => p_header_articles_tbl,
               x_chrid                => l_contract_header_id,
               x_return_status        => l_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data
           );

           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Create_Contract_Header status :'|| l_return_status );
           OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Contract Header Id            :'|| to_char(l_contract_header_id) );
           --dbms_output.put_line('K CONTRACT HEADER CREATION STATUS:-  ' || l_return_status);

           IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
               RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;



           If ( p_K_line_rec.line_type = 'SB') then
                l_k_support_rec := p_k_support_rec;
                l_k_line_rec    := p_k_line_rec;
                l_k_hdr_rec     := p_k_header_rec;
                --l_slh_rec       := p_Strm_hdr_rec;

                Create_Subscription
                (
                     p_K_header_rec                   => l_k_hdr_rec
                    ,p_K_Support_rec                  => l_k_support_rec
                    ,p_Support_contacts_tbl_in        => p_Support_contacts_tbl
                    ,p_Support_sales_crd_tbl_in       => p_Support_sales_crd_tbl
                    ,p_k_line_rec                     => l_k_line_rec
                    ,p_line_contacts_tbl_in           => p_line_contacts_tbl
                    ,p_line_sales_crd_tbl_in          => p_line_sales_crd_tbl
                    ,p_price_attribs_in               => p_price_attribs_in
                    ,p_contract_header_id             => l_contract_header_id
                    ,bill_type                        => p_billing_sch_type
                    ,p_strm_level_tbl                 => p_strm_level_tbl
                    ,x_return_status                  => l_return_status
                    ,x_msg_count                      => x_msg_count
                    ,x_msg_data                       => x_msg_data
                 );

                 OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Create_Subscription status :'|| l_return_status);
                 --dbms_output.put_line('CREATE SUBSCRIPTION STATUS:-  ' || l_return_status);

                 IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;
            ELSE


                 l_K_line_rec := p_K_line_rec;
                 l_K_line_rec.k_hdr_id := l_contract_header_id;

                 IF (p_K_header_rec.scs_code = 'SERVICE' AND l_K_line_rec.line_type = 'U') AND
                    (l_K_line_rec.usage_type = 'VRT' OR l_K_line_rec.usage_type = 'QTY') THEN

                    l_K_line_rec.invoicing_rule_type := -3;
                 END IF;

                 Create_Service_Line
                 (
                      p_k_line_rec         => l_K_line_rec,
                      p_Contact_tbl        => p_line_contacts_tbl,
                      p_line_sales_crd_tbl => p_line_sales_crd_tbl,
                      x_service_line_id    => l_service_line_id,
                      x_return_status      => l_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data
                  );
                  OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Create_Service_Line status :'|| l_return_status );
                  --dbms_output.put_line('K CONTRACT SERVICE LINE CREATION STATUS:-  ' || l_return_status);
                  IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;


                  l_K_covd_rec                  := p_K_covd_rec;
                  l_K_covd_rec.k_id             := l_contract_header_id;
                  l_K_covd_rec.Attach_2_Line_id := l_service_line_id;

                  Create_Covered_Line
                  (
                     p_k_covd_rec            => l_K_covd_rec,
                     p_PRICE_ATTRIBS         => p_price_attribs_in,
                     x_cp_line_id            => l_cp_line_id,
                     x_return_status         => l_return_status,
                     x_msg_count             => x_msg_count,
                     x_msg_data              => x_msg_data
                   );

                   OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Create_Covered_Line status :'|| l_return_status );
                   --dbms_output.put_line('K COVERED PRODUCT LINE CREATION STATUS:-  ' || l_return_status);

                   IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                   END IF;

                   IF p_K_header_rec.scs_code = 'WARRANTY' AND p_K_line_rec.line_type = 'W' THEN     ----warranty
                       NULL;

                   ELSE
                        /*--l_slh_rec := p_Strm_hdr_rec;
                        l_slh_rec.cle_id := l_service_line_id;

                        IF l_slh_rec.Object1_Id1 IS NULL THEN
                           l_slh_rec.Object1_Id1 := '1';
                        END IF;

                        IF l_slh_rec.Object2_Id1 IS NULL THEN
                           Create_timeval
                           (
                               p_line_id        => l_slh_rec.cle_id,
                               x_time_val       => l_time_val,
                               x_return_status  => x_return_status
                            );


                            IF l_return_status = 'S' THEN
                                l_slh_rec.Object2_Id1 := l_time_val;
                            ELSE
                                x_return_status := OKC_API.G_RET_STS_ERROR;
                                OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TIME VALUE REQUIRED FOR SLH');
                                DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                                Raise G_EXCEPTION_HALT_VALIDATION;
                            END IF;
                        END IF;*/

                        OKS_BILL_SCH.Create_Bill_Sch_Rules
                        (
                           p_billing_type         => p_billing_sch_type,
                           p_sll_tbl              => p_strm_level_tbl,
                           p_invoice_rule_id      => l_K_line_rec.invoicing_rule_type,
                           x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
                           x_return_status        => l_return_status
                         );

                         OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Create_Bill_Sch_Rules status :'|| l_return_status );
                         --dbms_output.put_line('K BILL SCHEDULE STATUS:-  ' || l_return_status);

                         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

                             DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                             RAISE G_EXCEPTION_HALT_VALIDATION;
                         END IF;


                    END IF;
            End If;

            Update Okc_k_headers_b
            Set    Estimated_amount = (Select nvl(sum(nvl(price_negotiated,0)),0)
            from   Okc_k_lines_b
            Where  dnz_chr_id = l_contract_header_id
            and    lse_id in (9,25,46))
            Where  id = l_contract_header_id ;

            x_chrid := l_contract_header_id;
            --dbms_output.put_line('Contract header Id:-  ' || TO_CHAR(l_contract_header_id));
            OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Contract header Id    :'|| TO_CHAR(l_contract_header_id) );

     Exception
            When  G_EXCEPTION_HALT_VALIDATION Then
               x_return_status := l_return_status;
               Null;
            When  Others Then
               x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
               OKS_RENEW_PVT.DEBUG_LOG( '(OKS_CONTRACTS_PUB).Create_Contract ::  Error :'|| SQLCODE || ':'|| SQLERRM );
   END Create_Contract;

/* dummy overloaded procedure for OKL*/

Procedure Create_Bill_Schedule(p_Strm_hdr_rec        IN	   OKS_BILL_SCH.StreamHdr_Type,
                               p_strm_level_tbl      IN    OKS_BILL_SCH.StreamLvl_tbl,
                               p_invoice_rule_id     IN    Number,
                               x_return_status       OUT NOCOPY  VARCHAR2
)

is
Begin

x_return_status := 'S';

End Create_Bill_Schedule;


End OKS_CONTRACTS_PUB;


/
