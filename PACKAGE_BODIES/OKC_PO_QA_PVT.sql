--------------------------------------------------------
--  DDL for Package Body OKC_PO_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PO_QA_PVT" AS
/* $Header: OKCRPQAB.pls 120.0 2005/05/25 22:43:34 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');



----------------------------------------------------------------------------
--  Global Constants--------------------------------------------------------
----------------------------------------------------------------------------
--  Standard API Constants

  G_DESCRIPTIVE_FLEXFIELD_NAME CONSTANT VARCHAR2(200) := 'OKC Rule Developer DF';
  G_DF_COUNT                   CONSTANT NUMBER(2)     := 15;
  G_PACKAGE  Varchar2(33) := '  OKC_PO_QA_PVT.';
  G_MSG_NAME Varchar2(30);
  G_LINE     Varchar2(4) := 'LINE';
  G_TOKEN    Varchar2(30);





------------------------------------------------------------------------------
---------------- Procedure: Set_QA_Message -------------------------
------------------------------------------------------------------------------
-- Purpose: Serves to set the error messages in the screen
--
-- Parameters: As specified below.
--
-- Out Parameters: None
--
-------------------------------------------------------------------------------

  PROCEDURE Set_QA_Message(p_chr_id IN OKC_K_LINES_V.chr_id%TYPE,
                           p_cle_id IN OKC_K_LINES_V.id%TYPE,
                           p_msg_name IN VARCHAR2,
                           p_token1 IN VARCHAR2 ,
                           p_token1_value IN VARCHAR2 ,
                           p_token2 IN VARCHAR2 ,
                           p_token2_value IN VARCHAR2 ,
                           p_token3 IN VARCHAR2 ,
                           p_token3_value IN VARCHAR2 ,
                           p_token4 IN VARCHAR2 ,
                           p_token4_value IN VARCHAR2 ) IS
    l_line Varchar2(200);
    l_token1_value Varchar2(200) := p_token1_value;
    l_token2_value Varchar2(200) := p_token2_value;
    l_token3_value Varchar2(200) := p_token3_value;
    l_token4_value Varchar2(200) := p_token4_value;
    l_return_status Varchar2(3);
  BEGIN
    If p_cle_id Is Not Null Then
      l_line := okc_contract_pub.get_concat_line_no(p_cle_id,
                                                    l_return_status);
      If p_token1 = g_line Then
        l_token1_value := l_line;
      Elsif p_token2 = g_line Then
        l_token2_value := l_line;
      Elsif p_token3 = g_line Then
        l_token3_value := l_line;
      Elsif p_token4 = g_line Then
        l_token4_value := l_line;
      End If;
    End If;

    OKC_API.set_message(
                 p_app_name     => G_APP_NAME,
                 p_msg_name     => p_msg_name,
                 p_token1       => p_token1,
                 p_token1_value => l_token1_value,
                 p_token2       => p_token2,
                 p_token2_value => l_token2_value,
                 p_token3       => p_token3,
                 p_token3_value => l_token3_value,
                 p_token4       => p_token4,
                 p_token4_value => l_token4_value);
  END;



----------------------------------------------------------------------------
--  Public Procedure -------------------------------------------------------
----------------------------------------------------------------------------

--------------------------------------------------------------------------------
------------- Procedure: Validate_K_FOR_PO  ---------------------
--------------------------------------------------------------------------------
-- Purpose: to check QA validations required for PO
--
-- In Parameters:  p_chr_id    Contract header id

--
-- Out Parameters: x_return_status  Standard return status
----------------------------------------------------------------------------------

  PROCEDURE Validate_K_FOR_PO(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);



    lcontract_intent OKC_K_HEADERS_B.BUY_OR_SELL%TYPE;
    l_nlines NUMBER := 0;


    CURSOR l_oklb_csr IS
    SELECT  oklb.item_to_price_yn item_priced,
            oklb.price_level_ind priced,
            oklb.price_negotiated net_price
      FROM OKC_K_LINES_b oklb
     WHERE oklb.dnz_chr_id = p_chr_id
     AND    oklb.cle_id IS NULL;
    l_oklb_rec l_oklb_csr%ROWTYPE;


    CURSOR l_oki_csr IS
    SELECT oki.number_of_items qty,
           oki.uom_code UOM_CODE
      FROM OKC_K_LINES_b oklb,
           OKC_K_ITEMS oki
     WHERE oklb.dnz_chr_id = oki.dnz_chr_id
     AND oklb.cle_id IS NULL
     AND   oklb.dnz_chr_id = p_chr_id;
    l_oki_rec l_oki_csr%ROWTYPE;

    g_rg_shipping                          CONSTANT VARCHAR2(12)  := 'OKPSHIPPING';
    g_rg_payment                           CONSTANT VARCHAR2(12)  := 'PAYMENT';


    lshipping_gr_count NUMBER := 0;
    lpayment_gr_count NUMBER := 0;


    lno_of_vendors NUMBER := 0;
    lno_of_customers NUMBER := 0;
    lbuyer_contact NUMBER := 0;



   --
   l_proc varchar2(72) := g_package||'check_required_values';
   l_line Varchar2(200);
   --
  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;




/*********To Check if the intent of the contract is BUY***************/

SELECT buy_or_sell
INTO   lcontract_intent
FROM OKC_K_HEADERS_b okhb
WHERE okhb.id = p_chr_id;

    IF (lcontract_intent <> 'B') THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_QA_INTENT_BUY',
        p_token1       => 'CONTRACT_INTENT',
        p_token1_value => 'BUY');

      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
     /*********CONTRACT SHOULD HAVE ATLEAST ONE LINE***************/
BEGIN

    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN

        SELECT 1 /*+ FIRST_ROWS */
        INTO l_nlines
        FROM OKC_K_LINES_B oklb
        WHERE oklb.dnz_chr_id = p_chr_id
        and rownum<2;

    END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKC_QA_K_LINES');

          x_return_status := OKC_API.G_RET_STS_ERROR;
    NULL;

END;

 /*********ARE ALL THE TOP LINES HAVING PRICED HAS ITEM_TO_PRICE FLAG CHECKED***************/

    -- fetch the contract header information
    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN
        OPEN  l_oklb_csr;
        LOOP
            FETCH l_oklb_csr INTO l_oklb_rec;
            EXIT WHEN l_oklb_csr%NOTFOUND;

        -- check required data for contract header
            IF (l_oklb_rec.item_priced = 'N') THEN
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_QA_ITEM_PRICED');

              -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;

            IF (l_oklb_rec.priced = 'N') THEN
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_QA_PRICED_CHECK');

              -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;

            IF (l_oklb_rec.net_price < 0 OR l_oklb_rec.net_price IS NULL) THEN
            OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => 'OKC_QA_NETPRICE_CHECK');
              -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END LOOP;
        CLOSE l_oklb_csr;
     END IF;

 /*********DO ALL THE TOP LINES HAVE qty>0, valid UOM CODE, valid net price***************/
    -- Check that at least 2 different parties have been attached
    -- to the contract header.
    -- get party count
    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN
        OPEN  l_oki_csr;
        LOOP
            FETCH l_oki_csr INTO l_oki_rec;
            EXIT WHEN l_oki_csr%NOTFOUND;


            IF (l_oki_rec.qty <= 0 OR l_oki_rec.qty IS NULL) THEN
              OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => 'OKC_QA_QTY_CHECK');
              -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            IF (l_oki_rec.UOM_CODE IS NULL) THEN
              OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => 'OKC_QA_UOMCODE_CHECK');
             -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        END LOOP;
        CLOSE l_oki_csr;
    END IF;
/*******Do the follwong rulegroups exist on the contract header---SHIPPING, PAYMENT***************/

BEGIN
    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN
        SELECT  1 /*+ FIRST_ROWS */
        INTO    lshipping_gr_count
        FROM    okc_rule_groups_b    rgp
        WHERE   rgp.dnz_chr_id         = p_chr_id
        AND     rgp.cle_id IS NULL
        AND     (rgp.rgd_code = g_rg_shipping)
        and rownum<2;

    END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKC_QA_RG_SHIPPING',
            p_token1        => 'RULE_GROUP',
            p_token1_value  => 'SHIPPING');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    NULL;
   END;

BEGIN
    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN
        SELECT  '1' /*+ FIRST_ROWS */
        INTO    lpayment_gr_count
        FROM    okc_rule_groups_b    rgp
        WHERE   rgp.dnz_chr_id         = p_chr_id
        AND     rgp.cle_id IS NULL
        AND     (rgp.rgd_code = g_rg_payment)
        and     rownum < 2;



    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKC_QA_RG_PAYMENT',
            p_token1        => 'RULE_GROUP',
            p_token1_value  => 'PAYMENT');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    NULL;
   END;


/******Is there one and only one value for each partyrole - VENDOR/CUSTOMER***********/

    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN
        SELECT count(*)
        INTO   lno_of_vendors
        FROM    okc_k_party_roles_b cpr
        WHERE   cpr.rle_code          = 'VENDOR'
        AND cpr.cle_id              IS NULL              -- header level vendors only
        AND cpr.dnz_chr_id        = p_chr_id;

         IF (lno_of_vendors <> 1) THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKC_QA_VENDOR_ROLE',
            p_token1        => 'PARTY_ROLE',
            p_token1_value  => 'VENDOR');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;


        SELECT count(*)
        INTO   lno_of_customers
        FROM okc_k_party_roles_b cpr
        WHERE   cpr.rle_code          = 'CUSTOMER'
        AND cpr.cle_id              IS NULL              -- header level customers only
        AND cpr.dnz_chr_id        = p_chr_id;

       IF (lno_of_customers <> 1) THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKC_QA_CUSTOMER_ROLE',
            p_token1        => 'PARTY_ROLE',
            p_token1_value  => 'CUSTOMER');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/************DOES THE PARTY ROLE CUSTOMER HAS A CONTACT CALLED BUYER**************************/
BEGIN
    IF (x_return_status<>OKC_API.G_RET_STS_ERROR) THEN
        SELECT 1 /*+ FIRST_ROWS */
        INTO   lbuyer_contact
        FROM   okc_contacts okcc,
               okc_k_party_roles_b okpr
        WHERE okcc.dnz_chr_id = okpr.dnz_chr_id
        AND   okcc.cro_code = 'BUYER'
        AND   okpr.rle_code = 'CUSTOMER'
        AND   okcc.dnz_chr_id = p_chr_id
        AND   rownum<2;

    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKC_QA_BUYER_CHECK',
            p_token1        => 'CONTACT_NAME',
            p_token1_value  => 'BUYER' ,
            p_token2        => 'PARTY_ROLE',
            p_token2_value  => 'CUSTOMER');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    NULL;
   END;

    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;



  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_oki_csr%ISOPEN THEN
      CLOSE l_oki_csr;
    END IF;
    IF l_oklb_csr%ISOPEN THEN
      CLOSE l_oklb_csr;
    END IF;

  END Validate_K_FOR_PO;

----------------------------------------------------------------------------------

END OKC_PO_QA_PVT;

/
