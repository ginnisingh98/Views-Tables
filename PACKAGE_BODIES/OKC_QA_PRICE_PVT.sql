--------------------------------------------------------
--  DDL for Package Body OKC_QA_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_PRICE_PVT" AS
/* $Header: OKCRQARB.pls 120.0 2005/05/25 18:25:56 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  TYPE NUM_TBL_TYPE  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE CHAR_TBL_TYPE IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;


  Procedure Check_Price(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER) Is

    l_cle_price_tbl          OKC_PRICE_PVT.CLE_PRICE_TBL_TYPE;
    l_control_rec            OKC_PRICE_PUB.PRICE_CONTROL_REC_TYPE;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(240);
    l_return_status          VARCHAR2(3);
    l_application_id         okc_k_headers_b.application_id%TYPE;
    l_estimated_price        okc_k_headers_b.estimated_amount%TYPE;
    l_chr_net_price          NUMBER;
    l_buy_or_sell            VARCHAR2(1);
    l_orig_system_source_code VARCHAR2(30);
    l_price_qa_check_yn      VARCHAR2(1):= 'N' ;
--
    cursor k_csr is
    select application_id,
           estimated_amount,
		 buy_or_sell,
		 orig_system_source_code
      from okc_k_headers_b
     where id = p_chr_id;

    -- execute price QA check for KOL (hdr.orig_system_source_code = 'KSSA_HDR)If there is
    -- at least one one line(top or sub line).
    -- If there is NO top or sub line exists , skip price QA check for KOL.
    ---
   CURSOR orig_sys_sourc_csr IS
   SELECT hdr.orig_system_source_code, cle.ID
   FROM OKC_K_LINES_B    cle,
         OKC_K_HEADERS_B  hdr
   WHERE hdr.id    = p_chr_id
   AND hdr.id      =  cle.dnz_chr_id (+)
   AND ROWNUM      < 2;
   rec_orig_sys_sourc_csr orig_sys_sourc_csr%ROWTYPE ;


   l_cle_id_tbl         num_tbl_type;
   l_id_tbl             num_tbl_type;
   l_line_number_tbl    char_tbl_type;
   l_lse_id_tbl         num_tbl_type;


   l_qa_covered_line_qty_mismatch BOOLEAN := FALSE;
   i                    PLS_INTEGER;



  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Check_Price');
       okc_debug.Log('1000: Entering Check_Price',2);
    END IF;
    --
    x_return_status := okc_api.g_ret_sts_success;
    If Nvl(fnd_profile.value('OKC_ADVANCED_PRICING'), 'N') <> 'Y' Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1010: Profile OKC_ADVANCED_PRICING - ' || fnd_profile.value('OKC_ADVANCED_PRICING'));
      END IF;
      -- No need to set the return status here otherwise a blank message
      -- will show up in the QA window with error/warning status
      Raise G_EXCEPTION_HALT_VALIDATION;
    End If;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1020: Before opening cursor k_csr');
    END IF;
    Open k_csr;
    Fetch k_csr
     Into l_application_id,
          l_estimated_price,
		l_buy_or_sell,
		l_orig_system_source_code;
    Close k_csr;
    IF (l_debug = 'Y') THEN
       okc_debug.log('1030: After closing cursor k_csr');
    END IF;
    --
    -- Price check is to be done only for OKC and OKO Contracts
    IF (l_debug = 'Y') THEN
       okc_debug.log('1040: Application_id - ' || To_Char(l_application_id));
    END IF;
    If l_application_id Not in (510, 871) Then
      -- No need to set the return status here
      Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

--  NO Price check for buy contracts - Advanced pricing is not used
    If l_buy_or_sell='B' Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1040: Intent - ' ||l_buy_or_sell);
      END IF;
      Raise G_EXCEPTION_HALT_VALIDATION;
    End If;
    --
--  NO Price check for Contracts created from quote/istore, always accept price from quote
    If l_orig_system_source_code = 'ASO_HDR' Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1040: Intent - ' ||l_orig_system_source_code);
      END IF;

       OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_NO_PRICE_CHECK');
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

       Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Set the p_level to QA to prevent all the updates in the pricing api
    l_control_rec.p_level := 'QA';

    OPEN orig_sys_sourc_csr;
    FETCH orig_sys_sourc_csr INTO rec_orig_sys_sourc_csr ;

    IF NVL(rec_orig_sys_sourc_csr.orig_system_source_code,'*') = 'KSSA_HDR' Then
           IF rec_orig_sys_sourc_csr.ID IS NOT NULL  THEN
              l_price_qa_check_yn := 'Y';
           END IF;
    ELSE
           l_price_qa_check_yn := 'Y';
    END IF;
   CLOSE orig_sys_sourc_csr;

    IF l_price_qa_check_yn = 'N'  THEN
       -- dont execute price_qa_check.
       -- return success and do not execute price_qa_check.
       x_return_status := okc_api.g_ret_sts_success;
       RETURN;
    ELSE
       --execute price_qa_check as earlier .
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1050: Before calling okc_price_pub');
    END IF;
    OKC_Price_Pub.Update_Contract_Price(
         p_api_version     => 1.0,
         p_init_msg_list   => OKC_API.G_FALSE,
         p_commit          => OKC_API.G_FALSE,
         p_chr_id          => p_chr_id,
         px_control_rec    => l_control_rec,
         x_cle_price_tbl   => l_cle_price_tbl,
         x_chr_net_price   => l_chr_net_price,
         x_return_status   => l_return_status,
         x_msg_count       => l_msg_count,
         x_msg_data        => l_msg_data);
    END IF; ---IF l_price_qa_check_yn = 'N'  THEN
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1060: After calling okc_price_pub');
       okc_debug.log('1070: Return status from okc_price_pub - ' || l_return_status);
    END IF;
    If (l_return_status <> 'S') Then
      -- In case of Unexpected error, return error so that it can be shown
      -- as an Error in QA window. For normal error, return Success.
      -- However in this case, clear the message stack otherwise the
      -- messages will be displayed in the QA window.
      -- Not any more, just return an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      /* If l_return_status = 'U' Then
        x_return_status := OKC_API.G_RET_STS_ERROR;
      Else
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        OKC_API.Init_Msg_List(OKC_API.G_TRUE);
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
      End If; */
      Raise G_EXCEPTION_HALT_VALIDATION;
    End If;
    --
    If nvl(l_chr_net_price, 0) <> nvl(l_estimated_price, 0) Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1080: Price stored at the header level - ' || To_Char(l_estimated_price));
      END IF;
      IF (l_debug = 'Y') THEN
         okc_debug.log('1090: Price returned from okc_price_pub - ' || To_Char(l_chr_net_price));
      END IF;
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_QA_INVALID_PRICE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      Raise G_EXCEPTION_HALT_VALIDATION;
    End If;
    -- notify caller of success
    OKC_API.set_message(
      p_app_name      => G_APP_NAME,
      p_msg_name      => G_QA_SUCCESS);
    --
    IF (l_debug = 'Y') THEN
       okc_debug.Log('1100: Exiting Check_Price', 2);
       okc_debug.Reset_Indentation;
    END IF;
    --
  Exception
    When G_EXCEPTION_HALT_VALIDATION Then
      IF (l_debug = 'Y') THEN
         okc_debug.Log('1110: Exiting Check_Price', 2);
         okc_debug.Reset_Indentation;
      END IF;
    When Others Then
      IF (l_debug = 'Y') THEN
         okc_debug.Log('1120: Exiting Check_Price', 2);
         okc_debug.Reset_Indentation;
      END IF;
      -- store SQL error message on message stack
      OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
      -- notify caller of an error as UNEXPETED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End Check_Price;
--

  PROCEDURE check_covered_line_qty (
    p_chr_id             IN  okc_k_headers_b.ID%TYPE,
    x_return_status      OUT NOCOPY VARCHAR2) IS



    l_cle_price_tbl          OKC_PRICE_PVT.CLE_PRICE_TBL_TYPE;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(240);
    l_return_status          VARCHAR2(3);
    l_application_id         okc_k_headers_b.application_id%TYPE;
    l_buy_or_sell            VARCHAR2(1);
    l_orig_system_source_code VARCHAR2(30);
    l_new_qa_check_yn      VARCHAR2(1):= 'N' ;
--
    cursor k_csr is
    select application_id,
		 buy_or_sell,
		 orig_system_source_code
      from okc_k_headers_b
     where id = p_chr_id;

    -- execute new QA check for KOL (hdr.orig_system_source_code = 'KSSA_HDR)If there is
    -- at least one one line(top or sub line).
    -- If there is NO top or sub line exists , skip new QA check for KOL.
    ---
    CURSOR orig_sys_sourc_csr IS
    SELECT hdr.orig_system_source_code, cle.ID
    FROM   OKC_K_LINES_B    cle,
           OKC_K_HEADERS_B  hdr
    WHERE  hdr.id    = p_chr_id
    AND    hdr.id    =  cle.dnz_chr_id (+)
    AND ROWNUM      < 2;
    rec_orig_sys_sourc_csr orig_sys_sourc_csr%ROWTYPE ;


    l_cle_id_tbl         num_tbl_type;
    l_id_tbl             num_tbl_type;
    l_line_number_tbl    char_tbl_type;
    l_lse_id_tbl         num_tbl_type;


    l_qa_covered_line_qty_mismatch BOOLEAN := FALSE;
    i                    PLS_INTEGER;



    -------------------------------------------------------------------------------
    -- Procedure:       validate_covered_line_qty
    -- Version:         1.0
    -- Purpose:         check to ensure that the quantity of a (sub) line of linestyle 'covered line' matches
    --                  that of the (top) line to which it points.
    --                  This check is done regardless of whether Advanced Pricing is enabled
    -- In Parameters:   p_cle_id        the (sub) line of linestyle 'covered line'
    --

    -- Out Parameters:  x_return_status
    --
    -- Comments:       This procedure is to be called only by QA

   PROCEDURE validate_covered_line_qty
                            (p_chr_id             IN  okc_k_headers_b.ID%TYPE,
                             p_cle_id             IN  okc_k_lines_b.ID%TYPE,
                             p_l_id_tbl           IN  num_tbl_type,
                             p_l_cle_id_tbl       IN  num_tbl_type,
                             p_l_line_number_tbl  IN  char_tbl_type,
                             x_return_status      OUT NOCOPY VARCHAR2
        	                 ) IS


     --gets quantity of (sub) line of linestyle 'covered line'
     --also gets the id (object1_id1) of the parent line which is being pointed to
     --NOTE: validate_covered_line_qty is to be called ONLY for (sub) lines with lse_id = 41 as we support only
     --      this particular linestyle for 'OKX_COVLINE' object code
     CURSOR c_get_quantity1 (b_cle_id NUMBER) is
     SELECT object1_id1, number_of_items qty
     FROM   okc_k_items
     WHERE  cle_id = b_cle_id
     AND    dnz_chr_id = p_chr_id
     AND    jtot_object1_code = 'OKX_COVLINE';


     --gets the quantity of the parent non-service item line being pointed to
     CURSOR c_get_quantity2 (b_cle_id NUMBER) is
     SELECT number_of_items qty
     FROM   okc_k_items
     WHERE  cle_id = b_cle_id
     AND    dnz_chr_id = p_chr_id;


     l_return_status     VARCHAR2(1);

     l_qty1                NUMBER := OKC_API.G_MISS_NUM;
     l_qty2                NUMBER := OKC_API.G_MISS_NUM;
     l_parent_cle_id       OKC_K_LINES_B.ID%TYPE;
     l_line_number         OKC_K_LINES_B.LINE_NUMBER%TYPE := '0';
     l_parent_line_number  OKC_K_LINES_B.LINE_NUMBER%TYPE := '0';
     i                     PLS_INTEGER := 0;
     l_top_line_id         NUMBER := OKC_API.G_MISS_NUM;

   BEGIN
     x_return_status := okc_api.g_ret_sts_success;
     IF (l_debug = 'Y') THEN
        okc_debug.Set_Indentation('validate_covered_line_qty');
     END IF;

     IF (l_debug = 'Y') THEN
        okc_debug.Log('Start : okc_price_pvt.validate_covered_line_qty ',3);
     END IF;
     /* Note: we already perform validation to ensure that the contract is for intent of sale and for OKC, OKO
        in OKC_QA_PRICE_PVT.Check_Price */


     /* Get quantity of (sub) line of linestyle 'covered line'  */
     IF (l_debug = 'Y') THEN
        okc_debug.Log('Get quantity of line with id: ' || p_cle_id, 5);
        okc_debug.Log('Get quantity of line p_cle_id = ' || p_cle_id || 'with jtot_object=''OKX_COVLINE'' and lse_id=41',5);
     END IF;
     IF c_get_quantity1%ISOPEN THEN
        CLOSE c_get_quantity1;
     END IF;
     OPEN c_get_quantity1 (b_cle_id => p_cle_id);
     FETCH c_get_quantity1 INTO l_parent_cle_id, l_qty1;
     CLOSE c_get_quantity1;
     IF (l_debug = 'Y') THEN
        okc_debug.Log('l_qty1: ' || l_qty1, 5);
     END IF;


     /* Get quantity of parent (top) line being pointed to */
     IF (l_debug = 'Y') THEN
        okc_debug.Log('Get quantity of parent (top) line being pointed to: '||l_parent_cle_id, 5);
     END IF;
     IF c_get_quantity2%ISOPEN THEN
        CLOSE c_get_quantity2;
     END IF;
     OPEN c_get_quantity2 (b_cle_id => l_parent_cle_id);
     FETCH c_get_quantity2 INTO l_qty2;
     CLOSE c_get_quantity2;
     IF (l_debug = 'Y') THEN
        okc_debug.Log('l_qty2: ' || l_qty2, 5);
     END IF;


     IF l_qty1 <> OKC_API.G_MISS_NUM AND l_qty2 <> OKC_API.G_MISS_NUM
        AND l_qty1 <> l_qty2
     THEN
          IF (l_debug = 'Y') THEN
             okc_debug.Log('l_qty1 and l_qty2 are not the same so setting error message on stack...',5);
          END IF;

         /* get the line number of the immediate (top) line  */
          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = p_cle_id THEN
                 l_top_line_id := p_l_cle_id_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;

          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = l_top_line_id THEN
                 l_line_number := p_l_line_number_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;


          --now concatenate it with the line number of the (sub) line of linestyle 'covered line'
          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = p_cle_id THEN
                 l_line_number := l_line_number || '.' || p_l_line_number_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;

         /* finally get the line number of the parent (top) line which is being pointed to */
          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = l_parent_cle_id THEN
                 l_parent_line_number := p_l_line_number_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;


          OKC_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKC_QA_MISMATCH_QTY',
                              p_token1        => 'LNUMB1',
                              p_token1_value  =>  l_line_number,
                              p_token2        => 'LNUMB2',
                              p_token2_value  =>  l_parent_line_number);
           IF (l_debug = 'Y') THEN
              okc_debug.Log('Covered line number ' || l_line_number || 'and id: ' || p_cle_id || 'serviceable product have a quantity mismatch.',5);
              okc_debug.Log('l_qty1: ' || l_qty1,5);
              okc_debug.Log('l_qty2: ' || l_qty2,5);
           END IF;
           x_return_status := OKC_API.G_RET_STS_ERROR;

     END IF;


     If x_return_status <>  OKC_API.G_RET_STS_ERROR then
        IF (l_debug = 'Y') THEN
           okc_debug.Log('passed okc_price_pvt.validate_covered_line_qty');
        END IF;
     End if;

   IF (l_debug = 'Y') THEN
      okc_debug.Log('End : okc_price_pvt.validate_covered_line_qty ',3);
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('Error : unexpected error in okc_price_pvt.validate_covered_line_qty ',3);
        okc_debug.Log('Error : '|| sqlerrm, 3);
     END IF;

     IF c_get_quantity1%ISOPEN THEN
        CLOSE c_get_quantity1;
     END IF;
     IF c_get_quantity2%ISOPEN THEN
        CLOSE c_get_quantity2;
     END IF;
     OKC_API.set_message(G_APP_NAME,
                         G_UNEXPECTED_ERROR,
                         G_SQLCODE_TOKEN,
                         SQLCODE,
                         G_SQLERRM_TOKEN,
                         SQLERRM);
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_covered_line_qty;



  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('check_covered_line_qty');
       okc_debug.Log('1000: Entering check_covered_line_qty',2);
    END IF;
    --
    x_return_status := okc_api.g_ret_sts_success;

    /*******************************************************************
    We carry out nocopy the check regardless of whether Advanced Pricing is enabled

    IF Nvl(fnd_profile.value('OKC_ADVANCED_PRICING'), 'N') = 'Y' THEN
	   don't run this QA check if advanced pricing is turned on because the
	     fix for Bug 2386767 made in OKC_PRICE_PVT corrects a mismatch between
		the covered line quantity and the non service line quantity.
	   If advanced pricing is off, we need to run this QA check to raise a QA error
		in case the covered line quantity and non service quantity don't match.

      IF (l_debug = 'Y') THEN
         okc_debug.log('1010: Profile OKC_ADVANCED_PRICING - ' || fnd_profile.value('OKC_ADVANCED_PRICING'));
      END IF;
      -- No need to set the return status here otherwise a blank message
      -- will show up in the QA window with error/warning status
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    *****************************************************************/
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1020: Before opening cursor k_csr');
    END IF;
    OPEN k_csr;
    FETCH k_csr
    INTO  l_application_id,
          l_buy_or_sell,
          l_orig_system_source_code;
    CLOSE k_csr;
    IF (l_debug = 'Y') THEN
       okc_debug.log('1030: After closing cursor k_csr');
    END IF;

    --
    /* covered line/non-service qty's check is to be done only for OKC
       and OKO Contracts  */
    IF (l_debug = 'Y') THEN
       okc_debug.log('1040: Application_id - ' || To_Char(l_application_id));
    END IF;
    If l_application_id Not in (510, 871) Then
      -- No need to set the return status here
      Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    --  perform only for sell contracts
    IF l_buy_or_sell='B' THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1045: Intent - ' ||l_buy_or_sell);
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    --

    --  NO Price check for Contracts created from quote/istore, always accept price from quote
    If l_orig_system_source_code = 'ASO_HDR' Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1050: Intent - ' ||l_orig_system_source_code);
      END IF;

       OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_NO_PRICE_CHECK');
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

       Raise G_EXCEPTION_HALT_VALIDATION;
    End If;


    /* execute new QA check for KOL only if there is at least one
       one line(top or sub line).  */
    OPEN orig_sys_sourc_csr;
    FETCH orig_sys_sourc_csr INTO rec_orig_sys_sourc_csr ;

    IF NVL(rec_orig_sys_sourc_csr.orig_system_source_code,'*') = 'KSSA_HDR' Then
           IF rec_orig_sys_sourc_csr.ID IS NOT NULL  THEN
              l_new_qa_check_yn := 'Y';
           END IF;
    ELSE
           l_new_qa_check_yn := 'Y';
    END IF;
    CLOSE orig_sys_sourc_csr;


    IF l_new_qa_check_yn = 'N'  THEN
       -- do not execute new_qa_check.
       -- return success and do not execute new_qa_check.
       x_return_status := okc_api.g_ret_sts_success;
       RETURN;
    ELSE
       --execute new_qa_check as earlier .
       --
       IF (l_debug = 'Y') THEN
          okc_debug.log('1055: Before looping thorough all lines/subines for contract');
       END IF;

       SELECT            cle_id, id, line_number, lse_id
       BULK COLLECT INTO l_cle_id_tbl,l_id_tbl, l_line_number_tbl, l_lse_id_tbl
       FROM okc_k_lines_b
       CONNECT BY PRIOR id = cle_id
       START WITH chr_id   = p_chr_id;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('1060 : select rowcount'||SQL%ROWCOUNT, 1);
       END IF;

       i:= l_id_tbl.first;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('1065 :starting out nocopy loop to check non-service/covered line quantities', 1);
       END IF;
       WHILE i is not null LOOP
          IF l_lse_id_tbl(i) = 41 THEN
             /** perform validation to ensure that the quantity of a (sub) line of linestyle 'covered line'
                 matches  that of the (top) line to which it points.  **/

              IF (l_debug = 'Y') THEN
                 okc_debug.Log('1070 : before calling validate_covered_line_qty ', 3);
                 okc_debug.Log('1075 : p_chr_id: ' || to_char(p_chr_id), 3);
                 okc_debug.Log('1080 : p_cle_id: ' || to_char(l_id_tbl(i)), 3);
              END IF;
              validate_covered_line_qty (p_chr_id          =>  p_CHR_ID,
                                     p_cle_id             =>  l_id_tbl(i),
                                     p_l_id_tbl           =>  l_id_tbl,
                                     p_l_cle_id_tbl       =>  l_cle_id_tbl,
                                     p_l_line_number_tbl  =>  l_line_number_tbl,
                                     x_return_status      =>  l_return_status
                                   );
              IF (l_debug = 'Y') THEN
                 okc_debug.Log('1085 : after calling validate_covered_line_qty ' || 'l_return_status: ' || l_return_status, 3);
              END IF;

             IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                --we want QA to pick up all the error messages on the stack
                l_qa_covered_line_qty_mismatch := TRUE;
             END IF;

             IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             END IF;
        End If;

        i:=l_id_tbl.NEXT(i);
      END LOOP;

    END IF; ---IF l_new_qa_check_yn = 'N'  THEN
    --
    IF (l_debug = 'Y') THEN
       okc_debug.Log('1090 : after loop to check non-service/covered line quantities', 1);
    END IF;

    IF l_qa_covered_line_qty_mismatch = TRUE THEN
       /*  this means that validate_covered_line_qty() has put some error
           messages on the error stack which we now want QA to display in the
           QA results     */
       l_return_status := OKC_API.G_RET_STS_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('1095 : l_qa_covered_line_qty_mismatch: TRUE', 1);
       END IF;
    ELSE
       IF (l_debug = 'Y') THEN
          okc_debug.Log('1100 : l_qa_covered_line_qty_mismatch: FALSE', 1);
       END IF;
    END IF;


    IF (l_return_status <> 'S') THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    --

    -- notify caller of success
    OKC_API.set_message(
      p_app_name      => G_APP_NAME,
      p_msg_name      => G_QA_SUCCESS);
    --
    IF (l_debug = 'Y') THEN
       okc_debug.Log('1105: Exiting check_covered_line_qty', 2);
       okc_debug.Reset_Indentation;
    END IF;
    --
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (l_debug = 'Y') THEN
         okc_debug.Log('1110: Exiting check_covered_line_qty', 2);
         okc_debug.Reset_Indentation;
      END IF;
    WHEN Others THEN
      IF (l_debug = 'Y') THEN
         okc_debug.Log('1120: Exiting check_covered_line_qty', 2);
         okc_debug.Reset_Indentation;
      END IF;
      -- store SQL error message on message stack
      OKC_API.SET_MESSAGE(
          p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM);
          -- notify caller of an error as UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END check_covered_line_qty;
--

END OKC_QA_PRICE_PVT;

/
