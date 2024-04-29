--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_PRICING_PVT" AS
/* $Header: OKCRPRIB.pls 120.0 2005/05/25 18:52:49 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/**************************************************************
   Processing:
   START OF PROCESSING FOR QTK or OTK pricing information creation


   For order to contract:
   ...
   Details for order to contract as follows:

   For quote to contract:
   OKC_OC_INT_QTK_PVT.create_k_from_quote calls this package through
   a single call to OKC_OC_INT_PRICING_PVT.create_k_pricing passing
   as parameters the contract header id, quote header id and
   PL/SQL table p_rel_tab which has contract lines along
   with related order lines.

   Details for quote to contract as follows:

    --<<GET PRICE ATTRIBUTE INFORMATION>>
      --call get_price_attr() with header level parameters
      --this does the following:-
      --get price attribute information from ASO or ONT at the HEADER level
      --and store it in global PL/SQL table g_pavv_tab

      --call get_price_attr () with line level parameters this time
      --this does the following:-
      --get price attribute information from ASO or ONT at the LINE level
      --and append it to global PL/SQL table g_pavv_tab which will then
      --contain BOTH header AND line level information

      --call OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value()
      --this puts price attributes information in OKC
    --<<END OF GETTING PRICE ATTRIBUTE INFORMATION>>



    --<<GET PRICE ADJUSTMENT INFORMATION>>
      --call get_price_adj() with header level parameters
      --this does the following:-
      --get price adjustment information from ASO or ONT at the HEADER level
      --and store it in global PL/SQL table g_patv_tab

      --call get_price_adj() with line level parameters this time
      --get price adjustment information from ASO or ONT at the LINE level
      --and append it to global PL/SQL table g_patv_tab which will then
      --contain BOTH header AND line level information

      --call OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment()
      --this puts price adjustment information in OKC

      --store the old (ASO or ONT) pat_id's along with the new (OKC) pat_id's
      --in global PL/SQL table g_price_adjustments_tab for reference later
    --<<END OF GETTING PRICE ADJUSTMENT INFORMATION>>



    --<<GET PRICE ADJUSTMENT ATTRIBUTES INFORMATION>>
      --call get_price_adj_attr ()
      --this does the following:
      --i)   loop through each ASO or ONT pat_id in global PL/SQL table
      --     g_price_adjustments_tab,
      --ii)  get all the price adjustment attributes
      --     and store them in global PL/SQL table g_paav_tab

      --call OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib()
      --this puts price adjustment attribute information in OKC
    --<<END OF GETTING PRICE ADJUSTMENT ATTRIBUTES INFORMATION>>



    --<<GET PRICE ADJUSTMENT RELATIONSHIP INFORMATION>>
       --call get_price_adj_rltship ()
       --this does the following:
       --i)   loop through each ASO or ONT pat_id in global PL/SQL table
       --     g_price_adjustments_tab,
       --ii)  get all the price adjustment relationships
       --     and store them in global PL/SQL table g_pacv_tab

       --call OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc
       --this puts price adjustment relationship information in OKC
    --<<END OF GETTING PRICE ADJUSTMENT RELATIONSHIP INFORMATION>>

   The OKX related quote pricing views concerned are:
   okx_qte_prc_atrbs_v
   okx_qte_prc_adjmnts_v
   okx_qte_prc_adj_atrbs_v
   okx_qte_prc_adj_rlshp_v

Flow:
|---OKC_OC_INT_PRICING.create_k_pricing()
    |    |---get_price_attr() called twice at header level AND line level
    |    |    |---get_pavv_tab() at header level OR line level (as called)
    |    |---OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value
    |    |---get_price_adj() called twice at header level AND line level
    |    |    |---get_patv_tab() at header level OR line level (as called)
    |    |---OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment
    |    |---get_price_adj_attr()
    |    |    |---get_paav_tab()
    |    |---OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib
    |    |---get_price_adj_rltship()
    |    |    |---get_pacv_tab()
    |    |---OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc

 END OF PROCESSING FOR QTK or OTK pricing information creation
 **************************************************************/

  TYPE price_adjustments_rec_type IS RECORD (
    old_pat_id          NUMBER := OKC_API.G_MISS_NUM,
    new_pat_id          NUMBER := OKC_API.G_MISS_NUM);
  TYPE price_adjustments_tbl_type IS TABLE OF price_adjustments_rec_type
  INDEX BY BINARY_INTEGER;
  g_price_adjustments_tab   price_adjustments_tbl_type;
  -- used to store the old (ASO or ONT) pat_id's along with
  --               the new (OKC) pat_id's

  --price attributes
  g_pavv_tab            OKC_PRICE_ADJUSTMENT_PUB.pavv_tbl_type;
  lx_pavv_tab           OKC_PRICE_ADJUSTMENT_PUB.pavv_tbl_type;

  --price adjustments
  g_patv_tab            OKC_PRICE_ADJUSTMENT_PUB.patv_tbl_type;
  lx_patv_tab           OKC_PRICE_ADJUSTMENT_PUB.patv_tbl_type;

  --price adjustment attributes
  g_paav_tab            OKC_PRICE_ADJUSTMENT_PUB.paav_tbl_type;
  lx_paav_tab           OKC_PRICE_ADJUSTMENT_PUB.paav_tbl_type;

  --price adjustment relationships
  g_pacv_tab            OKC_PRICE_ADJUSTMENT_PUB.pacv_tbl_type;
  lx_pacv_tab           OKC_PRICE_ADJUSTMENT_PUB.pacv_tbl_type;


  -- cursor to retrieve the contract number against a given contract id
  -- this cursor is used to include the contract number in error messages
  CURSOR c_knumber (c_k_id NUMBER) IS
  SELECT contract_number
  FROM   okc_k_headers_b
  WHERE  id = c_k_id;

  -- cursor to retrieve the order number against a given order id
  -- this cursor is used to include the order number in error messages
  CURSOR c_onumber (c_o_id NUMBER) IS
  SELECT TO_CHAR(order_number)
  FROM   okx_order_headers_v
  WHERE  id1 = c_o_id;

  -- cursor to retrieve the quote number against a given quote id
  -- this cursor is used to include the quote number in error messages
  CURSOR c_qnumber (c_q_id NUMBER) IS
  SELECT TO_CHAR(quote_number)
  FROM   okx_quote_headers_v
  WHERE  id1 = c_q_id;

  -- used for including in error messages
  l_order_number                 VARCHAR2(120) := OKC_API.G_MISS_CHAR;
  l_quote_number                 VARCHAR2(120) := OKC_API.G_MISS_CHAR;


  -----------------------------------------------------------------------------
  -- Procedure:           print_error
  -- Returns:
  -- Purpose:             Print the last error which occured
  -- In Parameters:       pos    position on the line to print the message
  -- Out Parameters:

  PROCEDURE print_error(pos IN NUMBER) IS
       x_msg_count NUMBER;
       x_msg_data  VARCHAR2(1000);
  BEGIN
     IF okc_util.l_trace_flag OR okc_util.l_log_flag THEN
           FND_MSG_PUB.Count_And_Get ( p_count       =>      x_msg_count,
				       p_data          =>         x_msg_data
                                      );
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(pos, '==EXCEPTION=================');
           END IF;
           x_msg_data := fnd_msg_pub.get( p_msg_index => x_msg_count,
                                          p_encoded   => 'F'
				        );
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(pos, 'Message      : '||x_msg_data);
              okc_util.print_trace(pos, '============================');
           END IF;
      END IF;
   END print_error;



   ----------------------------------------------------------------------------
   -- Procedure:           Cleanup()
   -- Returns:
   -- Purpose:             Delete pl/sql tables, so that they are not reused
   --                      when a connection is used by another client
   -- In Parameters:       No Parameters
   -- Out Parameters:      x_return_status     Varchar2
   -----------------------------------------------------------------------------
   PROCEDURE cleanup(x_return_status OUT NOCOPY varchar2 ) IS
   BEGIN
     IF (l_debug = 'Y') THEN
        okc_util.print_trace(1, '>START - OKC_OC_INT_PRICING_PVT.CLEANUP - Initialize global PL/SQL Tables');
        okc_util.print_trace(1, ' ');
     END IF;

     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2, 'Cleaning up plsql tables');
     END IF;

     g_price_adjustments_tab.DELETE;

     --price attributes
     g_pavv_tab.DELETE;
     lx_pavv_tab.DELETE;

     --price adjustments
     g_patv_tab.DELETE;
     lx_patv_tab.DELETE;

     --price adjustment attributes
     g_paav_tab.DELETE;
     lx_paav_tab.DELETE;

     --price adjustment relationships
     g_pacv_tab.DELETE;
     lx_pacv_tab.DELETE;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2, 'Done Cleaning up');
        okc_util.print_trace(1, '<END - OKC_OC_INT_PRICING_PVT.CLEANUP - Initialize global PL/SQL Tables');
     END IF;
   EXCEPTION
   WHEN OTHERS THEN
      OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   END cleanup;


  /************************************************************************
   ************************************************************************
                   START OF QTK or OTK PRICING INFORMATION CREATION
   ************************************************************************
   ***********************************************************************/
  ---------------------------------------------------------------------------
  --Procedure to contract pricing information at the header and line levels
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE create_k_pricing (
    x_return_status               OUT NOCOPY VARCHAR2,

    p_chr_id                      IN  OKC_K_HEADERS_B.ID%TYPE,
    p_o_flag                      IN  VARCHAR2 ,
    p_ohr_id                      IN  NUMBER ,
    p_q_flag                      IN  VARCHAR2 ,
    p_qhr_id                      IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                                      ,
    p_line_inf_tab                IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
    -- this PL/SQL table has quote (or order) lines against contract lines


  ) IS


    i      BINARY_INTEGER := 0;

    l_api_version         NUMBER := 1;
    lx_msg_count          NUMBER;
    lx_msg_data           VARCHAR2(2000);

    l_return_status	  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := l_return_status;


    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(1, ' ');
       OKC_UTIL.print_trace(1, '================================================');
       OKC_UTIL.print_trace(1, 'INITIALIZE GLOBAL PLSQL TABLES                  ');
       OKC_UTIL.print_trace(1, '================================================');
       OKC_UTIL.print_trace(1, ' ');
       OKC_UTIL.print_trace(1, ' ');
    END IF;

    cleanup(x_return_status => l_return_status);
    IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       x_return_status := l_return_status;
    END IF;


    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(1, ' ');
       OKC_UTIL.print_trace(1, 'Create Contract Pricing');
       OKC_UTIL.print_trace(1, '-----------------------------------------------');
       OKC_UTIL.print_trace(1, '>START - ******* OKC_OC_INT_PRICING_PVT.create_k_pricing  -');
    END IF;


    --<<begin getting price attribute information>>

    --get price attribute information from ASO or ONT at the HEADER level
    --and store it in global PL/SQL table g_pavv_tab
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Calling get_price_attr at HEADER level-');
       OKC_UTIL.print_trace(2, 'Contract Id- '|| p_chr_id);
       OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
    END IF;
    get_price_attr (
           p_chr_id         =>  p_chr_id,
           p_q_flag         =>  p_q_flag,
           p_qhr_id         =>  p_qhr_id,
           p_o_flag         =>  p_o_flag,
           p_ohr_id         =>  p_ohr_id
     );
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Header level call to get_price_attr finished successfully');
       OKC_UTIL.print_trace(2, 'Output in global PL/SQL table g_pavv_tab');
    END IF;


    --get price attribute information from ASO or ONT at the LINE level
    --and append it to global PL/SQL table g_pavv_tab which will then
    --contain BOTH header AND line level information
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Calling get_price_attr at LINE level-');
       OKC_UTIL.print_trace(2, 'Contract Id- '|| p_chr_id);
       OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
       OKC_UTIL.print_trace(2, 'PL/SQL table p_line_inf_tab- related quote or orderlines and contract lines');
    END IF;
    get_price_attr (
           p_chr_id         =>  p_chr_id,
           p_q_flag         =>  p_q_flag,
           p_qhr_id         =>  p_qhr_id,
           p_o_flag         =>  p_o_flag,
           p_ohr_id         =>  p_ohr_id,
           p_line_inf_tab   =>  p_line_inf_tab
     );
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Line level call to get_price_attr finished successfully');
       OKC_UTIL.print_trace(2, 'Output in global PL/SQL table g_pavv_tab');
    END IF;

    --now put this price attributes information in OKC
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Calling OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value');
       OKC_UTIL.print_trace(2, 'input p_pavv_tbl  => g_pavv_tab');
    END IF;
    IF g_pavv_tab.FIRST IS NOT NULL THEN
       OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value(
	   p_api_version	=> l_api_version,
           p_init_msg_list	=> OKC_API.G_FALSE,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> lx_msg_count,
           x_msg_data      	=> lx_msg_data,
                ----p_pavv_rec		=> l_pavv_rec,
                ----x_pavv_rec		=> x_pavv_rec);
           p_pavv_tbl           => g_pavv_tab,      --IN:   ASO or ONT
           x_pavv_tbl           => lx_pavv_tab);    --OUT:  OKC

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            -- get quote or order number to display in error message
            IF p_qhr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_qnumber(p_qhr_id);
                    FETCH c_qnumber INTO l_quote_number;
                    CLOSE c_qnumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            ELSIF p_ohr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_onumber(p_ohr_id);
                    FETCH c_onumber INTO l_order_number;
                    CLOSE c_onumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            END IF;

            -- put error message on stack
            --Price Attributes information from ASO or ONT table was not
            --                                                created in OKC.
            IF p_q_flag = OKC_API.G_TRUE THEN
                OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIATTR',
                   p_token1        => 'QNUMBER',
                   p_token1_value  => l_quote_number);
            ELSIF p_o_flag = OKC_API.G_TRUE THEN
                OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIATTR_ORD',
                   p_token1        => 'ONUMBER',
                   p_token1_value  => l_order_number);
            END IF;
            print_error(2);

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                ----x_return_status := l_return_status;
                ----RAISE G_EXCEPTION_HALT_VALIDATION;
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Call to OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value finished successfully');
    END IF;

    --<<end of getting price attribute information>>
    -----------------------------------------------


    --<<begin getting price adjustment information>>

    --get price adjustment information from ASO or ONT at the HEADER level
    --and store it in global PL/SQL table g_patv_tab
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Calling get_price_adj at HEADER level-');
       OKC_UTIL.print_trace(2, 'Contract Id- '|| p_chr_id);
       OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
    END IF;
    get_price_adj (
           p_chr_id             => p_chr_id,
           p_q_flag             => p_q_flag,
           p_qhr_id             => p_qhr_id,
           p_o_flag             => p_o_flag,
           p_ohr_id             => p_ohr_id
     );

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Header level call to get_price_adj finished successfully');
       OKC_UTIL.print_trace(2, 'Output is global PL/SQL table g_patv_tab');
    END IF;


    --get price adjustment information from ASO or ONT at the LINE level
    --and append it to global PL/SQL table g_patv_tab which will then
    --contain BOTH header AND line level information
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Calling get_price_adj at LINE level-');
       OKC_UTIL.print_trace(2, 'Contract Id- '|| p_chr_id);
       OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
       OKC_UTIL.print_trace(2, 'PL/SQL table p_line_inf_tab- related quote or orderlines and contract lines');
    END IF;
    get_price_adj (
           p_chr_id             => p_chr_id,
           p_q_flag             => p_q_flag,
           p_qhr_id             => p_qhr_id,
           p_o_flag             => p_o_flag,
           p_ohr_id             => p_ohr_id,
           p_line_inf_tab       => p_line_inf_tab
     );

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Line level call to get_price_adj finished successfully');
       OKC_UTIL.print_trace(2, 'Output is global PL/SQL table g_patv_tab');
    END IF;


    -- now put this price adjustment information in OKC
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment');
       OKC_UTIL.print_trace(2, 'input p_patv_tbl  => g_patv_tab');
    END IF;
    IF g_patv_tab.FIRST IS NOT NULL THEN
       OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment(
           p_api_version        => l_api_version,
           p_init_msg_list      => OKC_API.G_FALSE,
           x_return_status      => l_return_status,
           x_msg_count          => lx_msg_count,
           x_msg_data           => lx_msg_data,
           ----p_patv_rec           => l_patv_rec,
           ----x_patv_rec           => x_patv_rec);
           p_patv_tbl           => g_patv_tab,   --IN:   ASO or ONT
           x_patv_tbl           => lx_patv_tab); --OUT:  OKC

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            -- get quote or order number to display in error message
            IF p_qhr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_qnumber(p_qhr_id);
                    FETCH c_qnumber INTO l_quote_number;
                    CLOSE c_qnumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            ELSIF p_ohr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_onumber(p_ohr_id);
                    FETCH c_onumber INTO l_order_number;
                    CLOSE c_onumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            END IF;

            -- put error message on stack
            --Price Adjustments information from ASO or ONT table was not
            --                                                created in OKC.
            IF p_q_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIADJ',
                   p_token1        => 'QNUMBER',
                   p_token1_value  => l_quote_number);
            ELSIF p_o_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIADJ_ORD',
                   p_token1        => 'ONUMBER',
                   p_token1_value  => l_order_number);
            END IF;
            print_error(2);


            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                ----x_return_status := l_return_status;
                ----RAISE G_EXCEPTION_HALT_VALIDATION;
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSE
                x_return_status := l_return_status;
            END IF;
        END IF;

        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(2, ' >Call to OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment finished successfully.');
        END IF;

        -- store the old (ASO or ONT) pat_id's along with the new (OKC) pat_id's
        -- in global PL/SQL table g_price_adjustments_tab for reference later
        IF (g_patv_tab.FIRST IS NOT NULL AND lx_patv_tab.FIRST IS NOT NULL) THEN
             i := g_patv_tab.FIRST;
  	     WHILE i IS NOT NULL LOOP
                 g_price_adjustments_tab(i).old_pat_id := g_patv_tab(i).id;
                 g_price_adjustments_tab(i).new_pat_id := lx_patv_tab(i).id;
                 i := g_patv_tab.NEXT(i);    -- both have the same index
	     END LOOP;
        END IF;
     END IF;

    --<<end of getting price adjustment information>>


    --<<begin getting price adjustment attributes information>>

     --i)   loop through each ASO or ONT pat_id in global PL/SQL table
     --     g_price_adjustments_tab,
     --ii)  get all the price adjustment attributes
     --     and store them in global PL/SQL table g_paav_tab
     IF (l_debug = 'Y') THEN
        OKC_UTIL.print_trace(2, 'Calling get_price_adj_attr-');
        OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
        OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
     END IF;
     get_price_adj_attr (
           p_q_flag             => p_q_flag,
           p_qhr_id             => p_qhr_id,
           p_o_flag             => p_o_flag,
           p_ohr_id             => p_ohr_id
      );

     IF (l_debug = 'Y') THEN
        OKC_UTIL.print_trace(2, 'Call to get_price_adj_attr finished successfully');
     END IF;


    --now put this price adjustment attribute information in OKC
    --by calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib');
       OKC_UTIL.print_trace(2, 'input p_paav_tbl  => g_paav_tab');
    END IF;

    IF g_paav_tab.FIRST IS NOT NULL THEN
       --now put the price adjustment attributes in OKC
       OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib(
           p_api_version        => l_api_version,
           p_init_msg_list      => OKC_API.G_FALSE,
           x_return_status      => l_return_status,
           x_msg_count          => lx_msg_count,
           x_msg_data           => lx_msg_data,
                  ----p_paav_rec           => l_paav_rec,
                  ----x_paav_rec           => x_paav_rec
           p_paav_tbl           => g_paav_tab,
           x_paav_tbl           => lx_paav_tab);
     END IF;

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            -- get quote or order number to display in error message
            IF p_qhr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_qnumber(p_qhr_id);
                    FETCH c_qnumber INTO l_quote_number;
                    CLOSE c_qnumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            ELSIF p_ohr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_onumber(p_ohr_id);
                    FETCH c_onumber INTO l_order_number;
                    CLOSE c_onumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            END IF;

            --put error message on stack
            --Price Adjustments Attributes information from ASO or ONT table
            --was not created in OKC.
            IF p_q_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIADJATTR',
                   p_token1        => 'QNUMBER',
                   p_token1_value  => l_quote_number);
            ELSIF p_o_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIADJATTR_ORD',
                   p_token1        => 'ONUMBER',
                   p_token1_value  => l_order_number);
            END IF;
            print_error(2);

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                ----x_return_status := l_return_status;
                ----RAISE G_EXCEPTION_HALT_VALIDATION;
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSE
                x_return_status := l_return_status;
            END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Call to OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib finished successfully');
    END IF;


    --<<end of getting price adjustment attributes information>>


    --<<begin getting price adjustment relationship information>>

     --i)   loop through each ASO or ONT pat_id in global PL/SQL table
     --     g_price_adjustments_tab,
     --ii)  get all the price adjustment relationships
     --     and store them in global PL/SQL table g_pacv_tab
      IF (l_debug = 'Y') THEN
         OKC_UTIL.print_trace(2, 'Calling get_price_adj_rltship- ');
         OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
         OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
      END IF;
      get_price_adj_rltship (
           p_q_flag             =>  p_q_flag,
           p_qhr_id             =>  p_qhr_id,
           p_o_flag             =>  p_o_flag,
           p_ohr_id             =>  p_ohr_id,
	   p_line_inf_tab       =>  p_line_inf_tab
       );

     IF (l_debug = 'Y') THEN
        OKC_UTIL.print_trace(2, 'Call to get_price_adj_rltship finished successfully');
     END IF;

     --now put this price adjustment relationship information in OKC
     --by calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc');
       OKC_UTIL.print_trace(2, 'input p_pacv_tbl  => g_pacv_tab');
    END IF;

    IF g_pacv_tab.FIRST IS NOT NULL THEN
       --now put the price adjustment relationships in OKC
       OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc(
           p_api_version        => l_api_version,
           p_init_msg_list      => OKC_API.G_FALSE,
           x_return_status      => l_return_status,
           x_msg_count          => lx_msg_count,
           x_msg_data           => lx_msg_data,
           p_pacv_tbl           => g_pacv_tab,
           x_pacv_tbl           => lx_pacv_tab);
     END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Call to OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc finished successfully');
    END IF;


    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            -- get quote or order number to display in error message
            IF p_qhr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_qnumber(p_qhr_id);
                    FETCH c_qnumber INTO l_quote_number;
                    CLOSE c_qnumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            ELSIF p_ohr_id IS NOT NULL THEN
                 BEGIN
                    OPEN c_onumber(p_ohr_id);
                    FETCH c_onumber INTO l_order_number;
                    CLOSE c_onumber;
                 EXCEPTION
	         WHEN OTHERS THEN
	             NULL;
                 END;
            END IF;

            --put error message on stack
            --Price Adjustment Relationship information from ASO or ONT table
            --was not created in OKC.
            IF p_q_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIADJREL',
                   p_token1        => 'QNUMBER',
                   p_token1_value  => l_quote_number);
            ELSIF p_o_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOPRIADJREL_ORD',
                   p_token1        => 'ONUMBER',
                   p_token1_value  => l_order_number);
            END IF;
            print_error(2);

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                ----x_return_status := l_return_status;
                ----RAISE G_EXCEPTION_HALT_VALIDATION;
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSE
                x_return_status := l_return_status;
            END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Call to OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc finished successfully');
    END IF;

    --<<end of getting price adjustment relationship information>>


    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(1, '>END - ******* OKC_OC_INT_PRICING_PVT.create_k_pricing  -');
    END IF;


  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      print_error(1);

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      print_error(1);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      print_error(1);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END create_k_pricing;



  ----------------------------------------------------------------------------
  -- Procedure creates price attribute information in OKC from
  -- ASO or ONT pricing
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
   PROCEDURE get_price_attr(
    p_chr_id                    IN  NUMBER,
    p_q_flag                    IN  VARCHAR2 ,
    p_qhr_id                    IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                                    ,
    p_o_flag                    IN  VARCHAR2 ,
    p_ohr_id                    IN  NUMBER,
    p_line_inf_tab              IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
    ) IS

    i                           BINARY_INTEGER := 0;

  BEGIN
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'START --> get_price_attr- ');
       OKC_UTIL.print_trace(3, 'Contract Id - '|| p_chr_id);
       OKC_UTIL.print_trace(3, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(3, 'Order Id - '|| p_ohr_id);
    END IF;

    --get all the price attributes for the quote header (or order header)
    --for processing at the header level
    --and store them in global PL/SQL table g_pavv_tab
    IF p_q_flag = OKC_API.G_TRUE AND p_qhr_id IS NOT NULL AND p_qhr_id <> OKC_API.G_MISS_NUM AND
       p_line_inf_tab.FIRST IS NULL
    THEN
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Calling get_pavv_tab with p_chr_id and p_qhr_id/p_ohr_id for processing at header level');
       END IF;
       -- get_pavv_tab stores it's output in g_pavv_tab
       get_pavv_tab(p_chr_id    =>  p_chr_id,
                    p_q_flag    =>  p_q_flag,
                    p_qhr_id    =>  p_qhr_id
                   );

       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Call to get_pavv_tab finished successfully');
       END IF;
    ELSIF p_o_flag = OKC_API.G_TRUE AND p_ohr_id IS NOT NULL AND p_ohr_id <> OKC_API.G_MISS_NUM AND
          p_line_inf_tab.FIRST IS NULL
    THEN
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3, 'Calling get_pavv_tab with p_chr_id and p_qhr_id/p_ohr_id for processing at header level');
         END IF;
          -- get_pavv_tab stores it's output in g_pavv_tab
          get_pavv_tab(p_chr_id    =>  p_chr_id,
                       p_o_flag    =>  p_o_flag,
                       p_ohr_id    =>  p_ohr_id
		      );
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(3, 'Call to get_pavv_tab finished successfully');
          END IF;
    END IF;



    --get all the price attributes for each quote line (or order line)
    --and store them all in global PL/SQL table g_pavv_tab
    --keeping intact the header level information that g_pavv_tab may
    --already contain.
    IF p_line_inf_tab.FIRST IS NOT NULL THEN
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Calling get_pavv_tab with p_chr_id and p_qhr_id/p_ohr_id  and p_line_inf_tab for processing at line level');
       END IF;

       i := p_line_inf_tab.FIRST;
       WHILE i IS NOT NULL LOOP
	  IF p_q_flag = OKC_API.G_TRUE AND p_qhr_id IS NOT NULL AND p_qhr_id <> OKC_API.G_MISS_NUM AND
             NVL(p_line_inf_tab(i).line_type,OKC_API.G_MISS_CHAR) <> OKC_OC_INT_CONFIG_PVT.G_MODEL_LINE THEN

          -- get PRICE ATTRIBUTES information from ASO tables
                -- get_pavv_tab stores it's output in g_pavv_tab
                get_pavv_tab(p_chr_id    =>  p_chr_id,
                             p_q_flag    => p_q_flag,
                             p_qhr_id    => p_qhr_id,
                             p_cle_id    => p_line_inf_tab(i).cle_id,
                             p_qle_id    => p_line_inf_tab(i).object1_id1
			     );
          ELSIF p_o_flag = OKC_API.G_TRUE AND p_ohr_id IS NOT NULL AND p_ohr_id <> OKC_API.G_MISS_NUM AND
                NVL(p_line_inf_tab(i).line_type,OKC_API.G_MISS_CHAR) <> OKC_OC_INT_CONFIG_PVT.G_MODEL_LINE THEN
          -- get PRICE ATTRIBUTES information from ONT tables
                -- get_pavv_tab stores it's output in g_pavv_tab
                get_pavv_tab(p_chr_id    =>  p_chr_id,
                             p_o_flag    => p_o_flag,
                             p_ohr_id    => p_ohr_id,
                             p_cle_id    => p_line_inf_tab(i).cle_id,
                             p_ole_id    => p_line_inf_tab(i).object1_id1
		             );
          END IF;

          i := p_line_inf_tab.NEXT(i);
       END LOOP;
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Call to get_pavv_tab finished successfully');
       END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'END --> get_price_attr- ');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3,SQLERRM);
         END IF;
         -- Bug#2320635
         OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
         RAISE OKC_API.G_EXCEPTION_ERROR;
  END get_price_attr;


   --------------------------------------------------------------------------
   --------get price adjustments from ASO or ONT and put in OKC pricing tables
   --------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
   PROCEDURE get_price_adj(
    p_chr_id                       IN NUMBER,
    p_q_flag                       IN  VARCHAR2 ,
    p_qhr_id                       IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                                      ,
    p_o_flag                       IN  VARCHAR2 ,
    p_ohr_id                       IN NUMBER ,
    p_line_inf_tab                 IN OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
    ) IS

    i                           BINARY_INTEGER := 0;

  BEGIN
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'START --> get_price_adj- ');
       OKC_UTIL.print_trace(3, 'Contract Id - '|| p_chr_id);
       OKC_UTIL.print_trace(3, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(3, 'Order Id - '|| p_ohr_id);
    END IF;

    --get all the price adjustments for the quote header (or order header)
    --for processing at the header level
    --and store them in global PL/SQL table g_patv_tab
    IF p_q_flag = OKC_API.G_TRUE AND p_qhr_id IS NOT NULL AND p_qhr_id <> OKC_API.G_MISS_NUM AND
       p_line_inf_tab.FIRST IS NULL
    THEN
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Calling get_patv_tab with p_chr_id and p_qhr_id/p_ohr_id for processing at header level');
       END IF;
       -- get_patv_tab stores it's output in g_patv_tab
       get_patv_tab(p_chr_id    =>  p_chr_id,
                    p_q_flag    =>  p_q_flag,
                    p_qhr_id    =>  p_qhr_id
		    );
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Call to get_patv_tab finished successfully');
       END IF;

    ELSIF p_o_flag = OKC_API.G_TRUE AND p_ohr_id IS NOT NULL AND p_ohr_id <> OKC_API.G_MISS_NUM AND
          p_line_inf_tab.FIRST IS NULL
    THEN
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3, 'Calling get_patv_tab with p_chr_id and p_qhr_id/p_ohr_id for processing at header level');
         END IF;
          -- get_patv_tab stores it's output in g_patv_tab
          get_patv_tab(p_chr_id    =>  p_chr_id,
                       p_o_flag    =>  p_o_flag,
                       p_ohr_id    =>  p_ohr_id
		      );
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3, 'Call to get_patv_tab finished successfully');
         END IF;
    END IF;


    --get all the price adjustments for each quote line (or order line)
    --and store them all in global PL/SQL table g_patv_tab
    --keeping intact the header level information that g_pavv_tab may
    --already contain.
    IF p_line_inf_tab.FIRST IS NOT NULL THEN
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Calling get_patv_tab with p_chr_id and p_qhr_id/p_ohr_id    and p_line_inf_tab for processing at line level');
       END IF;

       i := p_line_inf_tab.FIRST;
       WHILE i IS NOT NULL LOOP
	  IF p_q_flag = OKC_API.G_TRUE AND p_qhr_id IS NOT NULL AND p_qhr_id <> OKC_API.G_MISS_NUM AND
             NVL(p_line_inf_tab(i).line_type, OKC_API.G_MISS_CHAR) <> OKC_OC_INT_CONFIG_PVT.G_MODEL_LINE THEN
          -- get PRICE ADJUSTMENTS information from ASO tables
                --get_patv_tab stores it's output in g_patv_tab
                get_patv_tab(p_chr_id    =>  p_chr_id,
                             p_q_flag    => p_q_flag,
                             p_qhr_id    => p_qhr_id,
                             p_cle_id    => p_line_inf_tab(i).cle_id,
                             p_qle_id    => p_line_inf_tab(i).object1_id1
			    );
          ELSIF p_o_flag = OKC_API.G_TRUE AND p_ohr_id IS NOT NULL AND p_ohr_id <> OKC_API.G_MISS_NUM AND
             NVL(p_line_inf_tab(i).line_type, OKC_API.G_MISS_CHAR) <> OKC_OC_INT_CONFIG_PVT.G_MODEL_LINE THEN
          --get PRICE ADJUSTMENTS information from ONT tables
                --get_patv_tab stores it's output in g_patv_tab
                get_patv_tab(p_chr_id    =>  p_chr_id,
                             p_o_flag    => p_o_flag,
                             p_ohr_id    => p_ohr_id,
                             p_cle_id    => p_line_inf_tab(i).cle_id,
                             p_ole_id    => p_line_inf_tab(i).object1_id1
		            );
          END IF;

          i := p_line_inf_tab.NEXT(i);
       END LOOP;
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Call to get_patv_tab finished successfully');
       END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'END --> get_price_adj- ');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(3,SQLERRM);
        END IF;
         -- Bug#2320635
        OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
        RAISE OKC_API.G_EXCEPTION_ERROR;

  END get_price_adj;
  ---------------------------------------------------------------------------


  --put PRICE ADJUSTMENT RELATIONSHIPS FROM ASO (or ONT) into OKC
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_price_adj_rltship(
    p_o_flag          IN VARCHAR2 ,
    p_ohr_id          IN NUMBER ,
    p_q_flag          IN VARCHAR2 ,
    p_qhr_id          IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                         ,
    p_line_inf_tab    IN OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
     ) IS


    l_pacv_tbl       OKC_PRICE_ADJUSTMENT_PUB.pacv_tbl_type;
    i                BINARY_INTEGER;

    x_pacv_tbl       OKC_PRICE_ADJUSTMENT_PUB.pacv_tbl_type;

    l_cle_id         NUMBER := OKC_API.G_MISS_NUM;
    l_new_pat_id     NUMBER := OKC_API.G_MISS_NUM;

  BEGIN

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'START --> get_price_adj_rltship- ');
       OKC_UTIL.print_trace(3, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(3, 'Order Id - '|| p_ohr_id);
    END IF;

    --loop through global PL/SQL table g_price_adjustments_tab
    --for each old (ASO or ONT) pat_id, get the price adjustment relationships
    --and store them all in global PL/SQL table g_pacv_tab
    IF g_price_adjustments_tab.FIRST IS NOT NULL THEN

       i := g_price_adjustments_tab.FIRST;
       WHILE i IS NOT NULL LOOP

         --get_pacv_tab stores all the price adjustment relationships
         --in g_pacv_tab
         get_pacv_tab(p_old_pat_id => g_price_adjustments_tab(i).old_pat_id,
                      p_new_pat_id   => g_price_adjustments_tab(i).new_pat_id,
                      p_q_flag       => p_q_flag,
                      p_qhr_id       => p_qhr_id,
                      p_o_flag       => p_o_flag,
                      p_ohr_id       => p_ohr_id,
		      p_line_inf_tab => p_line_inf_tab);

	   i := g_price_adjustments_tab.NEXT(i);
       END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'END --> get_price_adj_rltship- ');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3,SQLERRM);
         END IF;
         -- Bug#2320635
         OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
         RAISE OKC_API.G_EXCEPTION_ERROR;
  END get_price_adj_rltship;

  ----------------------------------------------------------------
  --put PRICE ADJUSTMENT ATTRIBUTES FROM ASO or ONT into OKC
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_price_adj_attr(
    p_o_flag                       IN VARCHAR2 ,
    p_ohr_id                       IN NUMBER ,
    p_q_flag                       IN VARCHAR2 ,
    p_qhr_id                       IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                                    ) IS

    i               BINARY_INTEGER := 0;

  BEGIN
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'START --> get_price_adj_attr- ');
       OKC_UTIL.print_trace(3, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(3, 'Order Id - '|| p_ohr_id);
    END IF;

    --loop through global PL/SQL table g_price_adjustments_tab
    --for each old (ASO or ONT) pat_id, get the price adjustment attributes
    --and store them all in global PL/SQL table g_paav_tab
    IF g_price_adjustments_tab.FIRST IS NOT NULL THEN

       i := g_price_adjustments_tab.FIRST;
       WHILE i IS NOT NULL LOOP

         --get_paav_tab stores all the price adjustment attributes in g_paav_tab
           get_paav_tab(p_old_pat_id => g_price_adjustments_tab(i).old_pat_id,
                        p_new_pat_id => g_price_adjustments_tab(i).new_pat_id,
                        p_q_flag     => p_q_flag,
                        p_qhr_id     => p_qhr_id,
                        p_o_flag     => p_o_flag,
                        p_ohr_id     => p_ohr_id);

	   i := g_price_adjustments_tab.NEXT(i);
       END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'END --> get_price_adj_attr- ');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3,SQLERRM);
         END IF;
         -- Bug#2320635
         OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
         RAISE OKC_API.G_EXCEPTION_ERROR;
  END get_price_adj_attr;


  ----------------------------------------------------------------------------
  -- PROCEDURE to get PRICE ADJUSTMENTS information from ASO or ONT tables
  -- get_patv_tab stores it's output in global PL/SQL table g_patv_tab
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
  PROCEDURE get_patv_tab(
               p_chr_id   IN OKC_K_HEADERS_B.ID%TYPE,
               p_cle_id   IN OKC_K_LINES_B.ID%TYPE ,
               p_o_flag   IN VARCHAR2 ,
               p_ohr_id   IN NUMBER ,
               p_ole_id   IN NUMBER ,
               p_q_flag   IN VARCHAR2 ,
               p_qhr_id   IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                             ,
               p_qle_id   IN OKX_QUOTE_LINES_V.ID1%TYPE
                             ) IS


     --------------l_no_data_found  BOOLEAN := TRUE;

     i                BINARY_INTEGER := 0;

     --cursor to get okx_qte_prc_adjmnts_v   or
     --              okx_ord_prc_adjmnts_v information
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
     CURSOR c_source_patv_rec (cp_q_flag IN VARCHAR2,
                        cp_qhr_id IN OKX_QUOTE_HEADERS_V.ID1%TYPE,
                        cp_qle_id IN OKX_QUOTE_LINES_V.ID1%TYPE,
                        cp_o_flag IN VARCHAR2,
                        cp_ohr_id IN NUMBER,
                        cp_ole_id IN NUMBER) IS
     --could be either ASO or ONT
     --only ONE of the following two queries in the union will be executed in
     --a call depending on which flag (p_q_flag or p_o_flag) is true

     -- first query to get okx_qte_prc_adjmnts_v  information
     SELECT                       			--parent_adjustment_id,          --not used
       pa.price_adjustment_id			price_adjustment_id,
       pa.quote_header_id 			source_header_id,
       pa.quote_line_id 				source_line_id,
       pa.modified_from				modified_from,
       pa.modified_to				modified_to,
       NVL(pa.modifier_mechanism_type_code, qh.list_type_code) modifier_mechanism_type_code,  --not used
       pa.operand					operand,
       pa.arithmetic_operator			arithmetic_operator,
       pa.automatic_flag				automatic_flag,
       pa.update_allowable_flag		update_allowable_flag,
       pa.updated_flag 				updated_flag,
       pa.applied_flag 				applied_flag,
       pa.on_invoice_flag 			on_invoice_flag,
       pa.pricing_phase_id  			pricing_phase_id,
       pa.attribute_category   		attribute_category,
       ---list_header_id      obsolete columns in ASO
       ---list_line_id
       ---list_line_type_code
       pa.modifier_header_id 			list_header_id,
       pa.modifier_line_id 			list_line_id,
       pa.modifier_line_type_code 		list_line_type_code,
       pa.change_reason_code			change_reason_code,
       pa.change_reason_text  		change_reason_text,
       pa.estimated_flag  			estimated_flag,
       pa.adjusted_amount   			adjusted_amount,
       pa.charge_type_code  			charge_type_code,
       pa.charge_subtype_code 		charge_subtype_code,
       pa.range_break_quantity 		range_break_quantity,
       pa.accrual_conversion_rate  	accrual_conversion_rate,
       pa.pricing_group_sequence  		pricing_group_sequence,
       pa.accrual_flag  				accrual_flag,
       NVL(pa.list_line_no, ql.list_line_no)	list_line_no,
       pa.source_system_code			source_system_code,
       pa.benefit_qty				benefit_qty,
       pa.benefit_uom_code			benefit_uom_code,
       pa.expiration_date			expiration_date,
       pa.modifier_level_code			modifier_level_code,
       pa.price_break_type_code		price_break_type_code,
       pa.substitution_attribute		substitution_attribute,
       pa.proration_type_code			proration_type_code,
       pa.include_on_returns_flag		include_on_returns_flag,
       pa.object_version_number		object_version_number,
       pa.attribute1				attribute1,
       pa.attribute2				attribute2,
       pa.attribute3				attribute3,
       pa.attribute4				attribute4,
       pa.attribute5				attribute5,
       pa.attribute6				attribute6,
       pa.attribute7				attribute7,
       pa.attribute8				attribute8,
       pa.attribute9				attribute9,
       pa.attribute10				attribute10,
       pa.attribute11				attribute11,
       pa.attribute12				attribute12,
       pa.attribute13				attribute13,
       pa.attribute14				attribute14,
       pa.attribute15				attribute15,
       pa.rebate_transaction_type_code	rebate_transaction_type_code
     FROM   okx_qte_prc_adjmnts_v pa,
		  qp_list_lines ql,
		  qp_list_headers_b qh
     WHERE  cp_q_flag = OKC_API.G_TRUE
       AND  pa.quote_header_id = cp_qhr_id
       AND  pa.modifier_line_type_code <> 'FREIGHT_CHARGE'  -- Bug 2054770
       AND  ((cp_qle_id = OKC_API.G_MISS_NUM  AND pa.quote_line_id IS NULL) OR
               (cp_qle_id <> OKC_API.G_MISS_NUM AND pa.quote_line_id = cp_qle_id))
	  AND  pa.modifier_header_id = qh.list_header_id
	  AND  pa.modifier_line_id = ql.list_line_id
          AND ( pa.applied_flag IS NULL OR pa.applied_flag = 'Y' )   -- Bug 2801279

     UNION ALL    -- second query to get okx_ord_prc_adjmnts_v information

     SELECT                      ------price_adjustment_id,   --not used
            pa.price_adjustment_id,
            pa.header_id source_header_id,
            pa.line_id source_line_id,
            TO_NUMBER(pa.modified_from) modified_from,
            TO_NUMBER(pa.modified_to) modified_to,
		  qh.list_type_code modifier_mechanism_type_code,
            pa.operand,
            pa.arithmetic_operator,
            pa.automatic_flag,
            pa.update_allowed,
            pa.updated_flag,
            pa.applied_flag,
            pa.invoiced_flag,
            pa.pricing_phase_id,
            pa.context,
            pa.list_header_id,
            pa.list_line_id,
            pa.list_line_type_code,
            pa.change_reason_code,
            pa.change_reason_text,
            pa.estimated_flag,
            pa.adjusted_amount,
            pa.charge_type_code,
            pa.charge_subtype_code,
            pa.range_break_quantity,
            pa.accrual_conversion_rate,
            pa.pricing_group_sequence,
            pa.accrual_flag,
            NVL(pa.list_line_no, ql.list_line_no) list_line_no,
            pa.source_system_code,
            pa.benefit_qty,
            pa.benefit_uom_code,
            pa.expiration_date,
            pa.modifier_level_code,
            pa.price_break_type_code,
            pa.substitution_attribute,
            pa.proration_type_code,
            pa.include_on_returns_flag,
            TO_NUMBER(NULL),          --object_version_number not present in order table
            pa.attribute1,
            pa.attribute2,
            pa.attribute3,
            pa.attribute4,
            pa.attribute5,
            pa.attribute6,
            pa.attribute7,
            pa.attribute8,
            pa.attribute9,
            pa.attribute10,
            pa.attribute11,
            pa.attribute12,
            pa.attribute13,
            pa.attribute14,
            pa.attribute15,
            pa.rebate_transaction_type_code
     FROM   okx_ord_prc_adjmnts_v pa,
		  qp_list_lines ql,
		  qp_list_headers_b qh
     WHERE  cp_o_flag = OKC_API.G_TRUE
       AND  pa.header_id = cp_ohr_id
       AND  pa.list_line_type_code <> 'FREIGHT_CHARGE'  -- Bug 2054770
       AND   ((cp_ole_id = OKC_API.G_MISS_NUM AND pa.line_id IS NULL) OR
               (cp_ole_id <> OKC_API.G_MISS_NUM AND pa.line_id = cp_ole_id))
       AND  pa.list_header_id = qh.list_header_id
       AND  pa.list_line_id = ql.list_line_id ;

    l_source_patv_rec  c_source_patv_rec%ROWTYPE;

    BEGIN
      IF (l_debug = 'Y') THEN
         OKC_UTIL.print_trace(4, 'START --> get_patv_tab- ');
         OKC_UTIL.print_trace(4, 'Contract Id - '|| p_chr_id);
         OKC_UTIL.print_trace(4, 'Contract Line Id - '|| p_cle_id);
         OKC_UTIL.print_trace(4, 'Quote Id - '|| p_qhr_id);
         OKC_UTIL.print_trace(4, 'Quote Line Id - '|| p_qle_id);
         OKC_UTIL.print_trace(4, 'Order Id - '|| p_ohr_id);
         OKC_UTIL.print_trace(4, 'Order Line Id - '|| p_ole_id);
      END IF;

      IF (p_q_flag = OKC_API.G_TRUE AND
          p_qhr_id IS NOT NULL AND
          p_qhr_id <> OKC_API.G_MISS_NUM) THEN
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'Processing quote pricing information for Quote Id - '|| p_qhr_id);
          END IF;
      ELSIF (p_o_flag = OKC_API.G_TRUE AND
            p_ohr_id IS NOT NULL AND
            p_ohr_id <> OKC_API.G_MISS_NUM) THEN
            IF (l_debug = 'Y') THEN
               OKC_UTIL.print_trace(4, 'Processing order pricing information for Order Id - '|| p_ohr_id);
            END IF;
      END IF;


      OPEN c_source_patv_rec(cp_q_flag => p_q_flag,
                              cp_qhr_id => p_qhr_id,
                              cp_qle_id => p_qle_id,
                              cp_o_flag => p_o_flag,
                              cp_ohr_id => p_ohr_id,
                              cp_ole_id => p_ole_id); --ASO or ONT

      LOOP
            --use COUNT to keep adding to existing records,if any, in g_pavv_tab
            --otherwise if table empty, COUNT returns 0
            i := g_patv_tab.COUNT + 1;
            FETCH c_source_patv_rec INTO l_source_patv_rec;
            EXIT WHEN c_source_patv_rec%NOTFOUND;

            g_patv_tab(i).id := l_source_patv_rec.price_adjustment_id;

            --g_patv_tab(i).PAT_ID := l_source_patv_rec.parent_adjustment_id;
            --not used

            IF l_source_patv_rec.source_header_id IS NOT NULL THEN
               g_patv_tab(i).CHR_ID := p_chr_id;
            END IF;

            IF l_source_patv_rec.source_line_id IS NOT NULL THEN
               g_patv_tab(i).CLE_ID := p_cle_id;
            END IF;

            g_patv_tab(i).MODIFIED_FROM := l_source_patv_rec.modified_from;
            g_patv_tab(i).MODIFIED_TO := l_source_patv_rec.modified_to;
            g_patv_tab(i).MODIFIER_MECHANISM_TYPE_CODE := l_source_patv_rec.modifier_mechanism_type_code;   -- not used
            g_patv_tab(i).OPERAND := l_source_patv_rec.operand;
            g_patv_tab(i).ARITHMETIC_OPERATOR := l_source_patv_rec.arithmetic_operator;
            g_patv_tab(i).AUTOMATIC_FLAG := l_source_patv_rec.automatic_flag;
            g_patv_tab(i).UPDATE_ALLOWED := l_source_patv_rec.update_allowable_flag;
            g_patv_tab(i).UPDATED_FLAG := l_source_patv_rec.updated_flag;
            g_patv_tab(i).APPLIED_FLAG := l_source_patv_rec.applied_flag;
            g_patv_tab(i).ON_INVOICE_FLAG := l_source_patv_rec.on_invoice_flag;
            g_patv_tab(i).PRICING_PHASE_ID := l_source_patv_rec.pricing_phase_id;
            g_patv_tab(i).CONTEXT := l_source_patv_rec.attribute_category;
            --g_patv_tab(i).PROGRAM_APPLICATION_ID := l_source_patv_rec.program_application_id;
            --g_patv_tab(i).PROGRAM_ID := l_source_patv_rec.program_id;
            --g_patv_tab(i).PROGRAM_UPDATE_DATE := l_source_patv_rec.program_update_date;
            --g_patv_tab(i).REQUEST_ID := l_source_patv_rec.request_id;
            g_patv_tab(i).LIST_HEADER_ID := l_source_patv_rec.list_header_id;
            g_patv_tab(i).LIST_LINE_ID := l_source_patv_rec.list_line_id;
            g_patv_tab(i).LIST_LINE_TYPE_CODE := l_source_patv_rec.list_line_type_code;
            g_patv_tab(i).CHANGE_REASON_CODE := l_source_patv_rec.change_reason_code;
            g_patv_tab(i).CHANGE_REASON_TEXT := l_source_patv_rec.change_reason_text;
            g_patv_tab(i).ESTIMATED_FLAG := l_source_patv_rec.estimated_flag;
            g_patv_tab(i).ADJUSTED_AMOUNT := l_source_patv_rec.adjusted_amount;
            g_patv_tab(i).CHARGE_TYPE_CODE := l_source_patv_rec.charge_type_code;
            g_patv_tab(i).CHARGE_SUBTYPE_CODE := l_source_patv_rec.charge_subtype_code;
            g_patv_tab(i).RANGE_BREAK_QUANTITY := l_source_patv_rec.range_break_quantity;
            g_patv_tab(i).ACCRUAL_CONVERSION_RATE := l_source_patv_rec.accrual_conversion_rate;
            g_patv_tab(i).PRICING_GROUP_SEQUENCE := l_source_patv_rec.pricing_group_sequence;
            g_patv_tab(i).ACCRUAL_FLAG := l_source_patv_rec.accrual_flag;
            g_patv_tab(i).LIST_LINE_NO := l_source_patv_rec.list_line_no;
            g_patv_tab(i).SOURCE_SYSTEM_CODE := l_source_patv_rec.source_system_code;
            g_patv_tab(i).BENEFIT_QTY := l_source_patv_rec.benefit_qty;
            g_patv_tab(i).BENEFIT_UOM_CODE := l_source_patv_rec.benefit_uom_code;
            g_patv_tab(i).EXPIRATION_DATE := l_source_patv_rec.expiration_date;
            g_patv_tab(i).MODIFIER_LEVEL_CODE := l_source_patv_rec.modifier_level_code;
            g_patv_tab(i).PRICE_BREAK_TYPE_CODE := l_source_patv_rec.price_break_type_code;
            g_patv_tab(i).SUBSTITUTION_ATTRIBUTE := l_source_patv_rec.substitution_attribute;
            g_patv_tab(i).PRORATION_TYPE_CODE := l_source_patv_rec.proration_type_code;
            g_patv_tab(i).INCLUDE_ON_RETURNS_FLAG := l_source_patv_rec.include_on_returns_flag;
            g_patv_tab(i).OBJECT_VERSION_NUMBER := l_source_patv_rec.object_version_number;
            g_patv_tab(i).ATTRIBUTE1 := l_source_patv_rec.ATTRIBUTE1;
            g_patv_tab(i).ATTRIBUTE2 := l_source_patv_rec.ATTRIBUTE2;
            g_patv_tab(i).ATTRIBUTE3 := l_source_patv_rec.ATTRIBUTE3;
            g_patv_tab(i).ATTRIBUTE4 := l_source_patv_rec.ATTRIBUTE4;
            g_patv_tab(i).ATTRIBUTE5 := l_source_patv_rec.ATTRIBUTE5;
            g_patv_tab(i).ATTRIBUTE6 := l_source_patv_rec.ATTRIBUTE6;
            g_patv_tab(i).ATTRIBUTE7 := l_source_patv_rec.ATTRIBUTE7;
            g_patv_tab(i).ATTRIBUTE8 := l_source_patv_rec.ATTRIBUTE8;
            g_patv_tab(i).ATTRIBUTE9 := l_source_patv_rec.ATTRIBUTE9;
            g_patv_tab(i).ATTRIBUTE10 := l_source_patv_rec.ATTRIBUTE10;
            g_patv_tab(i).ATTRIBUTE11 := l_source_patv_rec.ATTRIBUTE11;
            g_patv_tab(i).ATTRIBUTE12 := l_source_patv_rec.ATTRIBUTE12;
            g_patv_tab(i).ATTRIBUTE13 := l_source_patv_rec.ATTRIBUTE13;
            g_patv_tab(i).ATTRIBUTE14 := l_source_patv_rec.ATTRIBUTE14;
            g_patv_tab(i).ATTRIBUTE15 := l_source_patv_rec.ATTRIBUTE15;
            g_patv_tab(i).REBATE_TRANSACTION_TYPE_CODE := l_source_patv_rec.rebate_transaction_type_code;

      END LOOP;
      ----------IF c_source_patv_rec%ROWCOUNT > 0 THEN
      ----------   l_no_data_found := FALSE;
      ----------END IF;
      CLOSE c_source_patv_rec;


    ------IF l_no_data_found THEN
    -------  OKC_UTIL.print_trace(4, 'END --> get_patv_tab: returned error- ');
    -------- RAISE OKC_API.G_EXCEPTION_ERROR;
    ------ELSE
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4, 'Output: PL/SQL global table- g_patv_tab');
           OKC_UTIL.print_trace(4, 'END --> get_patv_tab- ');
        END IF;
    ------END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4,SQLERRM);
        END IF;
         -- Bug#2320635
        OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
        IF c_source_patv_rec%ISOPEN THEN
           CLOSE c_source_patv_rec;
        END IF;
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END get_patv_tab;

    ---------------------------------------------------------------
    -- PROCEDURE to get PRICE ADJUSTMENT RELATIONSHIP information
    -- from ASO or ONT tables
    -- get_pacv_tab stores all the price adjustment relationships in
    -- global PL/SQL table g_pacv_tab
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
    PROCEDURE get_pacv_tab(
                p_old_pat_id    IN NUMBER ,
                p_new_pat_id    IN NUMBER ,
                p_o_flag        IN VARCHAR2 ,
                p_ohr_id        IN NUMBER
                                   ,
                p_q_flag        IN VARCHAR2 ,
                p_qhr_id        IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                                   ,
                p_line_inf_tab  IN OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
                            )
    IS

    l_no_data_found      BOOLEAN := TRUE;

    i                    BINARY_INTEGER := 0;
    j                    BINARY_INTEGER := 0;
    l_cle_found_flg      BOOLEAN := FALSE;
    l_pat_id_found_flg   BOOLEAN := FALSE;

    -- cursor to get okx_qte_prc_adj_rlshp_v   and
    --               okx_ord_prc_adj_rlshp_v information
    CURSOR c_source_pacv_rec (cp_q_flag    IN VARCHAR2,
                              cp_o_flag     IN VARCHAR2,
                              cp_old_pat_id IN NUMBER) IS
    --could be either ASO or ONT
    --only ONE of the following two queries in the union will be executed in
    --a call depending on which flag (p_q_flag or p_o_flag) is true

    -- first query to get okx_qte_prc_adj_rlshp_v information
    SELECT ----price_adjustment_id,  --not needed
           price_adjustment_id,
           rltd_price_adj_id,
           quote_line_id source_line_id,
           object_version_number
    FROM   okx_qte_prc_adj_rlshp_v
    WHERE  cp_q_flag = OKC_API.G_TRUE
      AND  price_adjustment_id = cp_old_pat_id

    UNION ALL

    -- second query to get okx_ord_prc_adj_rlshp_v information
    SELECT --------price_adjustment_id,     --not needed
           price_adjustment_id,
           rltd_price_adj_id,
           line_id source_line_id,
           TO_NUMBER(NULL)     ----object_version_number   --not in order table
    FROM   okx_ord_prc_adj_rlshp_v
    WHERE  cp_o_flag = OKC_API.G_TRUE
      AND  price_adjustment_id = cp_old_pat_id;

    l_source_pacv_rec    c_source_pacv_rec%ROWTYPE;

    BEGIN

       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(4, 'START --> get_pacv_tab- ');
          OKC_UTIL.print_trace(4, 'p_old_pat_id- '|| p_old_pat_id);
          OKC_UTIL.print_trace(4, 'p_new_pat_id- '|| p_new_pat_id);
       END IF;

       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(4, 'Quote Id - '|| p_qhr_id);
          OKC_UTIL.print_trace(4, 'Order Id - '|| p_ohr_id);
          OKC_UTIL.print_trace(4, 'p_line_inf_tab: PL/SQL global table of contract lines against related quote or order lines');
       END IF;


      IF (p_q_flag = OKC_API.G_TRUE AND
          p_qhr_id IS NOT NULL AND
          p_qhr_id <> OKC_API.G_MISS_NUM) THEN
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'Processing quote pricing information for Quote Id - '|| p_qhr_id);
          END IF;
      ELSIF (p_o_flag = OKC_API.G_TRUE AND
            p_ohr_id IS NOT NULL AND
            p_ohr_id <> OKC_API.G_MISS_NUM) THEN
            IF (l_debug = 'Y') THEN
               OKC_UTIL.print_trace(4, 'Processing order pricing information for Order Id - '|| p_ohr_id);
            END IF;
      END IF;


      OPEN c_source_pacv_rec (cp_q_flag     => p_q_flag,
                              cp_o_flag     => p_o_flag,
                              cp_old_pat_id => p_old_pat_id);

      LOOP
              i := g_pacv_tab.COUNT + 1;
              --use COUNT to keep adding to existing records, if any,
              --in g_paav_tab
              --otherwise if table empty, COUNT returns 0
              FETCH c_source_pacv_rec INTO l_source_pacv_rec;
              EXIT WHEN c_source_pacv_rec%NOTFOUND;

	      -- we don't need to enter the ID because
              --                                it is automatically generated

              g_pacv_tab(i).PAT_ID_FROM := p_new_pat_id;
              -- this is the parent line

              --get the child line
              --corresponding to PRICE_ADJUSTMENT_ID from
              --ASO or ONT price adjustment relationship tables
              IF l_source_pacv_rec.price_adjustment_id IS NOT NULL THEN
                 -- get the new_pat_id against the price_adjustment_id
                 -- from g_price_adjustments_tab
		 IF g_price_adjustments_tab.FIRST IS NOT NULL THEN
		    j := g_price_adjustments_tab.FIRST;
		    WHILE (j IS NOT NULL OR l_pat_id_found_flg = FALSE) LOOP
                          -----IF g_price_adjustments_tab(j).old_pat_id = l_source_pacv_rec.price_adjustment_id THEN
                          IF g_price_adjustments_tab(j).old_pat_id = NVL(l_source_pacv_rec.rltd_price_adj_id,
0) THEN
                             g_pacv_tab(i).PAT_ID := g_price_adjustments_tab(j).new_pat_id;
                             l_pat_id_found_flg := TRUE;
                          END IF;
                          j := g_price_adjustments_tab.NEXT(j);
		    END LOOP;
		 END IF;
              END IF;


              IF l_source_pacv_rec.source_line_id IS NOT NULL THEN
                 -- get the contract line against this quote or order line from p_line_inf_tab
		 IF p_line_inf_tab.FIRST IS NOT NULL THEN
		    j := p_line_inf_tab.FIRST;
		    WHILE (j IS NOT NULL OR l_cle_found_flg = FALSE) LOOP
                          IF p_line_inf_tab(j).object1_id1 = l_source_pacv_rec.source_line_id THEN
                             g_pacv_tab(i).CLE_ID := p_line_inf_tab(j).cle_id;
                             l_cle_found_flg := TRUE;
                          END IF;
                          j := p_line_inf_tab.NEXT(j);
		    END LOOP;
		 END IF;
              END IF;

              --g_pacv_tab(i).PROGRAM_APPLICATION_ID := l_source_pacv_rec.program_application_id;
              --g_pacv_tab(i).PROGRAM_ID := l_source_pacv_rec.program_id;
              --g_pacv_tab(i).PROGRAM_UPDATE_DATE := l_source_pacv_rec.program_update_date;
              --g_pacv_tab(i).REQUEST_ID := l_source_pacv_rec.request_id;
              g_pacv_tab(i).OBJECT_VERSION_NUMBER := l_source_pacv_rec.object_version_number;

      END LOOP;
      ---------IF c_source_pacv_rec%ROWCOUNT > 0 THEN
      ------------l_no_data_found := FALSE;
      ---------END IF;
      CLOSE c_source_pacv_rec;


     --------IF l_no_data_found THEN
        ------OKC_UTIL.print_trace(4, 'END --> get_pacv_tab: returned error- ');
     ------   RAISE OKC_API.G_EXCEPTION_ERROR;
     --------ELSE
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4, 'Output: PL/SQL global table- g_pacv_tab');
           OKC_UTIL.print_trace(4, 'END --> get_pacv_tab- ');
        END IF;
     --------END IF;


    EXCEPTION
      WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         OKC_UTIL.print_trace(4,SQLERRM);
      END IF;
         -- Bug#2320635
      OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
      IF c_source_pacv_rec%ISOPEN THEN
         CLOSE c_source_pacv_rec;
      END IF;
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END get_pacv_tab;


   -----------------------------------------------------------------------------
   -- to get PRICE ADJUSTMENT ATTRIBUTES information from ASO or ONT tables
   -- get_paav_tab stores all the price adjustment attributes in global
   -- PL/SQL table g_paav_tab
   -----------------------------------------------------------------------------
    PROCEDURE get_paav_tab(p_old_pat_id IN NUMBER ,
                          p_new_pat_id IN NUMBER ,
                          p_q_flag     IN VARCHAR2 ,
                          p_qhr_id     IN NUMBER ,
                          p_o_flag     IN VARCHAR2 ,
                          p_ohr_id     IN NUMBER ) IS

    l_no_data_found BOOLEAN := TRUE;

    i              BINARY_INTEGER := 0;

    -- cursor to get okx_qte_prc_adj_atrbs_v  or
    --               okx_ord_prc_adj_atrbs_v information
    CURSOR c_source_paav_rec(cp_q_flag     IN VARCHAR2,
                             cp_o_flag     IN VARCHAR2,
                             cp_old_pat_id IN NUMBER) IS
    --could be either ASO or ONT
    --only ONE of the following two queries in the union will be executed in
    --a call depending on which flag (p_q_flag or p_o_flag) is true

    -- first query to get okx_qte_prc_adj_atrbs_v information
    SELECT ----price_adjustment_id,   --not needed
           flex_title,
           pricing_context,
           pricing_attribute,
           pricing_attr_value_from,
           pricing_attr_value_to,
           comparison_operator,
           object_version_number
    FROM   okx_qte_prc_adj_atrbs_v
    WHERE  cp_q_flag = OKC_API.G_TRUE
      AND  price_adjustment_id = cp_old_pat_id

    UNION ALL

    -- second query to get okx_ord_prc_adj_atrbs_v information
    SELECT --------price_adjustment_id,   --not needed
           flex_title,
           pricing_context,
           pricing_attribute,
           pricing_attr_value_from,
           pricing_attr_value_to,
           comparison_operator,
           TO_NUMBER(NULL)          ---object_version_number not in order table
    FROM   okx_ord_prc_adj_atrbs_v
    WHERE  cp_o_flag = OKC_API.G_TRUE
      AND  price_adjustment_id = cp_old_pat_id;

    l_source_paav_rec   c_source_paav_rec%ROWTYPE;

    BEGIN

      IF (l_debug = 'Y') THEN
         OKC_UTIL.print_trace(4, 'START --> get_paav_tab- ');
         OKC_UTIL.print_trace(4, 'p_old_pat_id- '|| p_old_pat_id);
         OKC_UTIL.print_trace(4, 'p_new_pat_id- '|| p_new_pat_id);
         OKC_UTIL.print_trace(4, 'Quote Id - '|| p_qhr_id);
         OKC_UTIL.print_trace(4, 'Order Id - '|| p_ohr_id);
      END IF;


      IF (p_q_flag = OKC_API.G_TRUE AND
          p_qhr_id IS NOT NULL AND
          p_qhr_id <> OKC_API.G_MISS_NUM) THEN
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'Processing quote pricing information for Quote Id - '|| p_qhr_id);
          END IF;
      ELSIF (p_o_flag = OKC_API.G_TRUE AND
            p_ohr_id IS NOT NULL AND
            p_ohr_id <> OKC_API.G_MISS_NUM) THEN
            IF (l_debug = 'Y') THEN
               OKC_UTIL.print_trace(4, 'Processing order pricing information for Order Id - '|| p_ohr_id);
            END IF;
      END IF;

      OPEN c_source_paav_rec(cp_q_flag     => p_q_flag,
                             cp_o_flag     => p_o_flag,
                             cp_old_pat_id => p_old_pat_id);

      LOOP
           --use COUNT to keep adding to existing records, if any, in g_paav_tab
           --otherwise if table empty, COUNT returns 0
           i := g_paav_tab.COUNT + 1;
           FETCH c_source_paav_rec INTO l_source_paav_rec;
           EXIT WHEN c_source_paav_rec%NOTFOUND;

	   -- we don't need to enter the ID because
           --                                   it is automatically generated
           g_paav_tab(i).PAT_ID := p_new_pat_id;

           IF l_source_paav_rec.flex_title IS NULL OR l_source_paav_rec.flex_title = OKC_API.G_MISS_CHAR THEN
               g_paav_tab(i).FLEX_TITLE := 'QP_ATTR_DEFNS_PRICING';
           ELSE
               g_paav_tab(i).FLEX_TITLE := l_source_paav_rec.flex_title;
           END IF;


           g_paav_tab(i).PRICING_CONTEXT := l_source_paav_rec.pricing_context;
           g_paav_tab(i).PRICING_ATTRIBUTE := l_source_paav_rec.pricing_attribute;
           g_paav_tab(i).PRICING_ATTR_VALUE_FROM := l_source_paav_rec.pricing_attr_value_from;
           g_paav_tab(i).PRICING_ATTR_VALUE_TO := l_source_paav_rec.pricing_attr_value_to;
           g_paav_tab(i).COMPARISON_OPERATOR := l_source_paav_rec.comparison_operator;
           --g_paav_tab(i).PROGRAM_APPLICATION_ID := l_source_paav_rec.program_application_id;
           --g_paav_tab(i).PROGRAM_ID := l_source_paav_rec.program_id;
           --g_paav_tab(i).PROGRAM_UPDATE_DATE := l_source_paav_rec.program_update_date;
           --g_paav_tab(i).REQUEST_ID := l_source_paav_rec.request_id;
           g_paav_tab(i).OBJECT_VERSION_NUMBER := l_source_paav_rec.object_version_number;

     END LOOP;
     --------IF c_source_paav_rec%ROWCOUNT > 0 THEN
	--------l_no_data_found := FALSE;
     --------END IF;
     CLOSE c_source_paav_rec;


     -----------IF l_no_data_found THEN
     ---------OKC_UTIL.print_trace(4, 'END --> get_paav_tab: returned error- ');
     ----------   RAISE OKC_API.G_EXCEPTION_ERROR;
     ----------ELSE
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4, 'Output: PL/SQL global table- g_paav_tab');
           OKC_UTIL.print_trace(4, 'END --> get_paav_tab- ');
        END IF;
     ----------END IF;


    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4,SQLERRM);
        END IF;
         -- Bug#2320635
        OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
        IF c_source_paav_rec%ISOPEN THEN
           CLOSE c_source_paav_rec;
        END IF;
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END get_paav_tab;


    ----------------------------------------------------------------------
    -- PROCEDURE to get PRICE ATTRIBUTES information from ASO or ONT tables
    -- get_pavv_tab stores it's output in global PL/SQL table g_pavv_tab
    ----------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
    PROCEDURE get_pavv_tab(
                p_chr_id  IN OKC_K_HEADERS_B.ID%TYPE,
                p_cle_id  IN OKC_K_LINES_B.ID%TYPE ,

                p_o_flag  IN VARCHAR2 ,
                p_ohr_id  IN NUMBER ,
                p_ole_id  IN NUMBER ,

                p_q_flag  IN VARCHAR2 ,
                p_qhr_id  IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                             ,
                p_qle_id  IN OKX_QUOTE_LINES_V.ID1%TYPE
	                     ) IS

      l_no_data_found BOOLEAN := TRUE;

      ------remove later l_aso_pavv_rec  okx_qte_prc_atrbs_v%ROWTYPE;
      -------remove later l_ont_pavv_rec  okx_ord_prc_atrbs_v%ROWTYPE;
      i               BINARY_INTEGER := 0;

      -- cursor to get okx_qte_prc_atrbs_v   or
      --               okx_ord_prc_atrbs_v information
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
      CURSOR c_source_pavv_rec (cp_q_flag IN VARCHAR2,
                        cp_qhr_id IN OKX_QUOTE_HEADERS_V.ID1%TYPE,
                        cp_qle_id IN OKX_QUOTE_LINES_V.ID1%TYPE,
                        cp_o_flag IN VARCHAR2,
                        cp_ohr_id IN NUMBER,
                        cp_ole_id IN NUMBER) IS
      --could be either ASO or ONT
      --only ONE of the following two queries in the union will be executed in
      --a call depending on which flag (p_q_flag or p_o_flag) is true

      -- first query to get okx_qte_prc_atrbs_v information
      SELECT quote_header_id source_header_id,
       quote_line_id source_line_id,
       flex_title,
       pricing_context,
       pricing_attribute1,
       pricing_attribute2,
       pricing_attribute3,
       pricing_attribute4,
       pricing_attribute5,
       pricing_attribute6,
       pricing_attribute7,
       pricing_attribute8,
       pricing_attribute9,
       pricing_attribute10,
       pricing_attribute11,
       pricing_attribute12,
       pricing_attribute13,
       pricing_attribute14,
       pricing_attribute15,
       pricing_attribute16,
       pricing_attribute17,
       pricing_attribute18,
       pricing_attribute19,
       pricing_attribute20,
       pricing_attribute21,
       pricing_attribute22,
       pricing_attribute23,
       pricing_attribute24,
       pricing_attribute25,
       pricing_attribute26,
       pricing_attribute27,
       pricing_attribute28,
       pricing_attribute29,
       pricing_attribute30,
       pricing_attribute31,
       pricing_attribute32,
       pricing_attribute33,
       pricing_attribute34,
       pricing_attribute35,
       pricing_attribute36,
       pricing_attribute37,
       pricing_attribute38,
       pricing_attribute39,
       pricing_attribute40,
       pricing_attribute41,
       pricing_attribute42,
       pricing_attribute43,
       pricing_attribute44,
       pricing_attribute45,
       pricing_attribute46,
       pricing_attribute47,
       pricing_attribute48,
       pricing_attribute49,
       pricing_attribute50,
       pricing_attribute51,
       pricing_attribute52,
       pricing_attribute53,
       pricing_attribute54,
       pricing_attribute55,
       pricing_attribute56,
       pricing_attribute57,
       pricing_attribute58,
       pricing_attribute59,
       pricing_attribute60,
       pricing_attribute61,
       pricing_attribute62,
       pricing_attribute63,
       pricing_attribute64,
       pricing_attribute65,
       pricing_attribute66,
       pricing_attribute67,
       pricing_attribute68,
       pricing_attribute69,
       pricing_attribute70,
       pricing_attribute71,
       pricing_attribute72,
       pricing_attribute73,
       pricing_attribute74,
       pricing_attribute75,
       pricing_attribute76,
       pricing_attribute77,
       pricing_attribute78,
       pricing_attribute79,
       pricing_attribute80,
       pricing_attribute81,
       pricing_attribute82,
       pricing_attribute83,
       pricing_attribute84,
       pricing_attribute85,
       pricing_attribute86,
       pricing_attribute87,
       pricing_attribute88,
       pricing_attribute89,
       pricing_attribute90,
       pricing_attribute91,
       pricing_attribute92,
       pricing_attribute93,
       pricing_attribute94,
       pricing_attribute95,
       pricing_attribute96,
       pricing_attribute97,
       pricing_attribute98,
       pricing_attribute99,
       pricing_attribute100,
       context,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       object_version_number
      FROM   okx_qte_prc_atrbs_v
      WHERE  cp_q_flag = OKC_API.G_TRUE
        AND  quote_header_id = cp_qhr_id
        AND   ((cp_qle_id = OKC_API.G_MISS_NUM AND quote_line_id IS NULL) OR
               (cp_qle_id <> OKC_API.G_MISS_NUM AND quote_line_id = cp_qle_id))

      UNION ALL

      -- second query to get okx_ord_prc_atrbs_v information
      SELECT header_id source_header_id,
       line_id source_line_id,
       flex_title,
       pricing_context,
       pricing_attribute1,
       pricing_attribute2,
       pricing_attribute3,
       pricing_attribute4,
       pricing_attribute5,
       pricing_attribute6,
       pricing_attribute7,
       pricing_attribute8,
       pricing_attribute9,
       pricing_attribute10,
       pricing_attribute11,
       pricing_attribute12,
       pricing_attribute13,
       pricing_attribute14,
       pricing_attribute15,
       pricing_attribute16,
       pricing_attribute17,
       pricing_attribute18,
       pricing_attribute19,
       pricing_attribute20,
       pricing_attribute21,
       pricing_attribute22,
       pricing_attribute23,
       pricing_attribute24,
       pricing_attribute25,
       pricing_attribute26,
       pricing_attribute27,
       pricing_attribute28,
       pricing_attribute29,
       pricing_attribute30,
       pricing_attribute31,
       pricing_attribute32,
       pricing_attribute33,
       pricing_attribute34,
       pricing_attribute35,
       pricing_attribute36,
       pricing_attribute37,
       pricing_attribute38,
       pricing_attribute39,
       pricing_attribute40,
       pricing_attribute41,
       pricing_attribute42,
       pricing_attribute43,
       pricing_attribute44,
       pricing_attribute45,
       pricing_attribute46,
       pricing_attribute47,
       pricing_attribute48,
       pricing_attribute49,
       pricing_attribute50,
       pricing_attribute51,
       pricing_attribute52,
       pricing_attribute53,
       pricing_attribute54,
       pricing_attribute55,
       pricing_attribute56,
       pricing_attribute57,
       pricing_attribute58,
       pricing_attribute59,
       pricing_attribute60,
       pricing_attribute61,
       pricing_attribute62,
       pricing_attribute63,
       pricing_attribute64,
       pricing_attribute65,
       pricing_attribute66,
       pricing_attribute67,
       pricing_attribute68,
       pricing_attribute69,
       pricing_attribute70,
       pricing_attribute71,
       pricing_attribute72,
       pricing_attribute73,
       pricing_attribute74,
       pricing_attribute75,
       pricing_attribute76,
       pricing_attribute77,
       pricing_attribute78,
       pricing_attribute79,
       pricing_attribute80,
       pricing_attribute81,
       pricing_attribute82,
       pricing_attribute83,
       pricing_attribute84,
       pricing_attribute85,
       pricing_attribute86,
       pricing_attribute87,
       pricing_attribute88,
       pricing_attribute89,
       pricing_attribute90,
       pricing_attribute91,
       pricing_attribute92,
       pricing_attribute93,
       pricing_attribute94,
       pricing_attribute95,
       pricing_attribute96,
       pricing_attribute97,
       pricing_attribute98,
       pricing_attribute99,
       pricing_attribute100,
       context,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       TO_NUMBER(NULL)  --object_version_number not present in order table
      FROM   okx_ord_prc_atrbs_v
      WHERE  cp_o_flag = OKC_API.G_TRUE
        AND  header_id = cp_ohr_id
        AND   ((cp_ole_id = OKC_API.G_MISS_NUM AND line_id IS NULL) OR
               (cp_ole_id <> OKC_API.G_MISS_NUM AND line_id = cp_ole_id));

      l_source_pavv_rec  c_source_pavv_rec%ROWTYPE;

    BEGIN

      IF (l_debug = 'Y') THEN
         OKC_UTIL.print_trace(4, 'START --> get_pavv_tab- ');
         OKC_UTIL.print_trace(4, 'Contract Id - '|| p_chr_id);
         OKC_UTIL.print_trace(4, 'Contract Line Id - '|| p_cle_id);
         OKC_UTIL.print_trace(4, 'Quote Id - '|| p_qhr_id);
         OKC_UTIL.print_trace(4, 'Quote Line Id - '|| p_qle_id);
         OKC_UTIL.print_trace(4, 'Order Id - '|| p_ohr_id);
         OKC_UTIL.print_trace(4, 'Order Line Id - '|| p_ole_id);
      END IF;


      IF (p_q_flag = OKC_API.G_TRUE AND
          p_qhr_id IS NOT NULL AND
          p_qhr_id <> OKC_API.G_MISS_NUM) THEN
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'Processing quote pricing information for Quote Id - '|| p_qhr_id);
          END IF;
      ELSIF (p_o_flag = OKC_API.G_TRUE AND
            p_ohr_id IS NOT NULL AND
            p_ohr_id <> OKC_API.G_MISS_NUM) THEN
            IF (l_debug = 'Y') THEN
               OKC_UTIL.print_trace(4, 'Processing order pricing information for Order Id - '|| p_ohr_id);
            END IF;
      END IF;


      OPEN c_source_pavv_rec (cp_q_flag => p_q_flag,
                              cp_qhr_id => p_qhr_id,
                              cp_qle_id => p_qle_id,
                              cp_o_flag => p_o_flag,
                              cp_ohr_id => p_ohr_id,
                              cp_ole_id => p_ole_id); --ASO or ONT
      LOOP
          --use COUNT to keep adding to existing records, if any, in g_pavv_tab
          --otherwise if table empty, COUNT returns 0
          i := g_pavv_tab.COUNT + 1;
          FETCH c_source_pavv_rec INTO l_source_pavv_rec;
          EXIT WHEN c_source_pavv_rec%NOTFOUND;

          -- map okx_qte_prc_atrbs_v or
          --     okx_ord_prc_atrbs_v     to OKC_PRICE_ATT_VALUES

	  -- we don't need to enter the ID because it is automatically generated

          IF l_source_pavv_rec.source_header_id IS NOT NULL THEN--quote or order
	      g_pavv_tab(i).CHR_ID := p_chr_id;
          END IF;
          IF l_source_pavv_rec.source_line_id IS NOT NULL THEN --quote or order
	      g_pavv_tab(i).CLE_ID := p_cle_id;
	  END IF;

          IF l_source_pavv_rec.flex_title IS NULL OR l_source_pavv_rec.flex_title = OKC_API.G_MISS_CHAR THEN
              IF l_source_pavv_rec.pricing_context IS NOT NULL OR l_source_pavv_rec.pricing_context <> OKC_API.G_MISS_CHAR THEN
                   g_pavv_tab(i).FLEX_TITLE  := 'QP_ATTR_DEFNS_PRICING';
              END IF;
              IF l_source_pavv_rec.CONTEXT IS NOT NULL OR l_source_pavv_rec.CONTEXT <> OKC_API.G_MISS_CHAR THEN
                   g_pavv_tab(i).FLEX_TITLE  := 'QP_ATTR_DEFNS_QUALIFIER';
              END IF;
          ELSE
                g_pavv_tab(i).FLEX_TITLE  := l_source_pavv_rec.flex_title;
          END IF;


          g_pavv_tab(i).PRICING_CONTEXT := l_source_pavv_rec.pricing_context;
          g_pavv_tab(i).PRICING_ATTRIBUTE1 := l_source_pavv_rec.pricing_attribute1;
          g_pavv_tab(i).PRICING_ATTRIBUTE2 := l_source_pavv_rec.pricing_attribute2;
          g_pavv_tab(i).PRICING_ATTRIBUTE3 := l_source_pavv_rec.pricing_attribute3;
          g_pavv_tab(i).PRICING_ATTRIBUTE4 := l_source_pavv_rec.pricing_attribute4;
          g_pavv_tab(i).PRICING_ATTRIBUTE5 := l_source_pavv_rec.PRICING_ATTRIBUTE5;
          g_pavv_tab(i).PRICING_ATTRIBUTE6 := l_source_pavv_rec.PRICING_ATTRIBUTE6;
          g_pavv_tab(i).PRICING_ATTRIBUTE7 := l_source_pavv_rec.PRICING_ATTRIBUTE7;
          g_pavv_tab(i).PRICING_ATTRIBUTE8 := l_source_pavv_rec.PRICING_ATTRIBUTE8;
          g_pavv_tab(i).PRICING_ATTRIBUTE9 := l_source_pavv_rec.PRICING_ATTRIBUTE9;
          g_pavv_tab(i).PRICING_ATTRIBUTE10 := l_source_pavv_rec.PRICING_ATTRIBUTE10;
          g_pavv_tab(i).PRICING_ATTRIBUTE11 := l_source_pavv_rec.PRICING_ATTRIBUTE11;
          g_pavv_tab(i).PRICING_ATTRIBUTE12 := l_source_pavv_rec.PRICING_ATTRIBUTE12;
          g_pavv_tab(i).PRICING_ATTRIBUTE13 := l_source_pavv_rec.PRICING_ATTRIBUTE13;
          g_pavv_tab(i).PRICING_ATTRIBUTE14 := l_source_pavv_rec.PRICING_ATTRIBUTE14;
          g_pavv_tab(i).PRICING_ATTRIBUTE15 := l_source_pavv_rec.PRICING_ATTRIBUTE15;
          g_pavv_tab(i).PRICING_ATTRIBUTE16 := l_source_pavv_rec.PRICING_ATTRIBUTE16;
          g_pavv_tab(i).PRICING_ATTRIBUTE17 := l_source_pavv_rec.PRICING_ATTRIBUTE17;
          g_pavv_tab(i).PRICING_ATTRIBUTE18 := l_source_pavv_rec.PRICING_ATTRIBUTE18;
          g_pavv_tab(i).PRICING_ATTRIBUTE19 := l_source_pavv_rec.PRICING_ATTRIBUTE19;
          g_pavv_tab(i).PRICING_ATTRIBUTE20 := l_source_pavv_rec.PRICING_ATTRIBUTE20;
          g_pavv_tab(i).PRICING_ATTRIBUTE21 := l_source_pavv_rec.PRICING_ATTRIBUTE21;
          g_pavv_tab(i).PRICING_ATTRIBUTE22 := l_source_pavv_rec.PRICING_ATTRIBUTE22;
          g_pavv_tab(i).PRICING_ATTRIBUTE23 := l_source_pavv_rec.PRICING_ATTRIBUTE23;
          g_pavv_tab(i).PRICING_ATTRIBUTE24 := l_source_pavv_rec.PRICING_ATTRIBUTE24;
          g_pavv_tab(i).PRICING_ATTRIBUTE25 := l_source_pavv_rec.PRICING_ATTRIBUTE25;
          g_pavv_tab(i).PRICING_ATTRIBUTE26 := l_source_pavv_rec.PRICING_ATTRIBUTE26;
          g_pavv_tab(i).PRICING_ATTRIBUTE27 := l_source_pavv_rec.PRICING_ATTRIBUTE27;
          g_pavv_tab(i).PRICING_ATTRIBUTE28 := l_source_pavv_rec.PRICING_ATTRIBUTE28;
          g_pavv_tab(i).PRICING_ATTRIBUTE29 := l_source_pavv_rec.PRICING_ATTRIBUTE29;
          g_pavv_tab(i).PRICING_ATTRIBUTE30 := l_source_pavv_rec.PRICING_ATTRIBUTE30;
          g_pavv_tab(i).PRICING_ATTRIBUTE31 := l_source_pavv_rec.PRICING_ATTRIBUTE31;
          g_pavv_tab(i).PRICING_ATTRIBUTE32 := l_source_pavv_rec.PRICING_ATTRIBUTE32;
          g_pavv_tab(i).PRICING_ATTRIBUTE33 := l_source_pavv_rec.PRICING_ATTRIBUTE33;
          g_pavv_tab(i).PRICING_ATTRIBUTE34 := l_source_pavv_rec.PRICING_ATTRIBUTE34;
          g_pavv_tab(i).PRICING_ATTRIBUTE35 := l_source_pavv_rec.PRICING_ATTRIBUTE35;
          g_pavv_tab(i).PRICING_ATTRIBUTE36 := l_source_pavv_rec.PRICING_ATTRIBUTE36;
          g_pavv_tab(i).PRICING_ATTRIBUTE37 := l_source_pavv_rec.PRICING_ATTRIBUTE37;
          g_pavv_tab(i).PRICING_ATTRIBUTE38 := l_source_pavv_rec.PRICING_ATTRIBUTE38;
          g_pavv_tab(i).PRICING_ATTRIBUTE39 := l_source_pavv_rec.PRICING_ATTRIBUTE39;
          g_pavv_tab(i).PRICING_ATTRIBUTE40 := l_source_pavv_rec.PRICING_ATTRIBUTE40;
          g_pavv_tab(i).PRICING_ATTRIBUTE41 := l_source_pavv_rec.PRICING_ATTRIBUTE41;
          g_pavv_tab(i).PRICING_ATTRIBUTE42 := l_source_pavv_rec.PRICING_ATTRIBUTE42;
          g_pavv_tab(i).PRICING_ATTRIBUTE43 := l_source_pavv_rec.PRICING_ATTRIBUTE43;
          g_pavv_tab(i).PRICING_ATTRIBUTE44 := l_source_pavv_rec.PRICING_ATTRIBUTE44;
          g_pavv_tab(i).PRICING_ATTRIBUTE45 := l_source_pavv_rec.PRICING_ATTRIBUTE45;
          g_pavv_tab(i).PRICING_ATTRIBUTE46 := l_source_pavv_rec.PRICING_ATTRIBUTE46;
          g_pavv_tab(i).PRICING_ATTRIBUTE47 := l_source_pavv_rec.PRICING_ATTRIBUTE47;
          g_pavv_tab(i).PRICING_ATTRIBUTE48 := l_source_pavv_rec.PRICING_ATTRIBUTE48;
          g_pavv_tab(i).PRICING_ATTRIBUTE49 := l_source_pavv_rec.PRICING_ATTRIBUTE49;
          g_pavv_tab(i).PRICING_ATTRIBUTE50 := l_source_pavv_rec.PRICING_ATTRIBUTE50;
          g_pavv_tab(i).PRICING_ATTRIBUTE51 := l_source_pavv_rec.PRICING_ATTRIBUTE51;
          g_pavv_tab(i).PRICING_ATTRIBUTE52 := l_source_pavv_rec.PRICING_ATTRIBUTE52;
          g_pavv_tab(i).PRICING_ATTRIBUTE53 := l_source_pavv_rec.PRICING_ATTRIBUTE53;
          g_pavv_tab(i).PRICING_ATTRIBUTE54 := l_source_pavv_rec.PRICING_ATTRIBUTE54;
          g_pavv_tab(i).PRICING_ATTRIBUTE55 := l_source_pavv_rec.PRICING_ATTRIBUTE55;
          g_pavv_tab(i).PRICING_ATTRIBUTE56 := l_source_pavv_rec.PRICING_ATTRIBUTE56;
          g_pavv_tab(i).PRICING_ATTRIBUTE57 := l_source_pavv_rec.PRICING_ATTRIBUTE57;
          g_pavv_tab(i).PRICING_ATTRIBUTE58 := l_source_pavv_rec.PRICING_ATTRIBUTE58;
          g_pavv_tab(i).PRICING_ATTRIBUTE59 := l_source_pavv_rec.PRICING_ATTRIBUTE59;
          g_pavv_tab(i).PRICING_ATTRIBUTE60 := l_source_pavv_rec.PRICING_ATTRIBUTE60;
          g_pavv_tab(i).PRICING_ATTRIBUTE61 := l_source_pavv_rec.PRICING_ATTRIBUTE61;
          g_pavv_tab(i).PRICING_ATTRIBUTE62 := l_source_pavv_rec.PRICING_ATTRIBUTE62;
          g_pavv_tab(i).PRICING_ATTRIBUTE63 := l_source_pavv_rec.PRICING_ATTRIBUTE63;
          g_pavv_tab(i).PRICING_ATTRIBUTE64 := l_source_pavv_rec.PRICING_ATTRIBUTE64;
          g_pavv_tab(i).PRICING_ATTRIBUTE65 := l_source_pavv_rec.PRICING_ATTRIBUTE65;
          g_pavv_tab(i).PRICING_ATTRIBUTE66 := l_source_pavv_rec.PRICING_ATTRIBUTE66;
          g_pavv_tab(i).PRICING_ATTRIBUTE67 := l_source_pavv_rec.PRICING_ATTRIBUTE67;
          g_pavv_tab(i).PRICING_ATTRIBUTE68 := l_source_pavv_rec.PRICING_ATTRIBUTE68;
          g_pavv_tab(i).PRICING_ATTRIBUTE69 := l_source_pavv_rec.PRICING_ATTRIBUTE69;
          g_pavv_tab(i).PRICING_ATTRIBUTE70 := l_source_pavv_rec.PRICING_ATTRIBUTE70;
          g_pavv_tab(i).PRICING_ATTRIBUTE71 := l_source_pavv_rec.PRICING_ATTRIBUTE71;
          g_pavv_tab(i).PRICING_ATTRIBUTE72 := l_source_pavv_rec.PRICING_ATTRIBUTE72;
          g_pavv_tab(i).PRICING_ATTRIBUTE73 := l_source_pavv_rec.PRICING_ATTRIBUTE73;
          g_pavv_tab(i).PRICING_ATTRIBUTE74 := l_source_pavv_rec.PRICING_ATTRIBUTE74;
          g_pavv_tab(i).PRICING_ATTRIBUTE75 := l_source_pavv_rec.PRICING_ATTRIBUTE75;
          g_pavv_tab(i).PRICING_ATTRIBUTE76 := l_source_pavv_rec.PRICING_ATTRIBUTE76;
          g_pavv_tab(i).PRICING_ATTRIBUTE77 := l_source_pavv_rec.PRICING_ATTRIBUTE77;
          g_pavv_tab(i).PRICING_ATTRIBUTE78 := l_source_pavv_rec.PRICING_ATTRIBUTE78;
          g_pavv_tab(i).PRICING_ATTRIBUTE79 := l_source_pavv_rec.PRICING_ATTRIBUTE79;
          g_pavv_tab(i).PRICING_ATTRIBUTE80 := l_source_pavv_rec.PRICING_ATTRIBUTE80;
          g_pavv_tab(i).PRICING_ATTRIBUTE81 := l_source_pavv_rec.PRICING_ATTRIBUTE81;
          g_pavv_tab(i).PRICING_ATTRIBUTE82 := l_source_pavv_rec.PRICING_ATTRIBUTE82;
          g_pavv_tab(i).PRICING_ATTRIBUTE83 := l_source_pavv_rec.PRICING_ATTRIBUTE83;
          g_pavv_tab(i).PRICING_ATTRIBUTE84 := l_source_pavv_rec.PRICING_ATTRIBUTE84;
          g_pavv_tab(i).PRICING_ATTRIBUTE85 := l_source_pavv_rec.PRICING_ATTRIBUTE85;
          g_pavv_tab(i).PRICING_ATTRIBUTE86 := l_source_pavv_rec.PRICING_ATTRIBUTE86;
          g_pavv_tab(i).PRICING_ATTRIBUTE87 := l_source_pavv_rec.PRICING_ATTRIBUTE87;
          g_pavv_tab(i).PRICING_ATTRIBUTE88 := l_source_pavv_rec.PRICING_ATTRIBUTE88;
          g_pavv_tab(i).PRICING_ATTRIBUTE89 := l_source_pavv_rec.PRICING_ATTRIBUTE89;
          g_pavv_tab(i).PRICING_ATTRIBUTE90 := l_source_pavv_rec.PRICING_ATTRIBUTE90;
          g_pavv_tab(i).PRICING_ATTRIBUTE91 := l_source_pavv_rec.PRICING_ATTRIBUTE91;
          g_pavv_tab(i).PRICING_ATTRIBUTE92 := l_source_pavv_rec.PRICING_ATTRIBUTE92;
          g_pavv_tab(i).PRICING_ATTRIBUTE93 := l_source_pavv_rec.PRICING_ATTRIBUTE93;
          g_pavv_tab(i).PRICING_ATTRIBUTE94 := l_source_pavv_rec.PRICING_ATTRIBUTE94;
          g_pavv_tab(i).PRICING_ATTRIBUTE95 := l_source_pavv_rec.PRICING_ATTRIBUTE95;
          g_pavv_tab(i).PRICING_ATTRIBUTE96 := l_source_pavv_rec.PRICING_ATTRIBUTE96;
          g_pavv_tab(i).PRICING_ATTRIBUTE97 := l_source_pavv_rec.PRICING_ATTRIBUTE97;
          g_pavv_tab(i).PRICING_ATTRIBUTE98 := l_source_pavv_rec.PRICING_ATTRIBUTE98;
          g_pavv_tab(i).PRICING_ATTRIBUTE99 := l_source_pavv_rec.PRICING_ATTRIBUTE99;
          g_pavv_tab(i).PRICING_ATTRIBUTE100 := l_source_pavv_rec.PRICING_ATTRIBUTE100;
          g_pavv_tab(i).QUALIFIER_CONTEXT := l_source_pavv_rec.CONTEXT;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE1 := l_source_pavv_rec.ATTRIBUTE1;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE2 := l_source_pavv_rec.ATTRIBUTE2;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE3 := l_source_pavv_rec.ATTRIBUTE3;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE4 := l_source_pavv_rec.ATTRIBUTE4;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE5 := l_source_pavv_rec.ATTRIBUTE5;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE6 := l_source_pavv_rec.ATTRIBUTE6;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE7 := l_source_pavv_rec.ATTRIBUTE7;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE8 := l_source_pavv_rec.ATTRIBUTE8;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE9 := l_source_pavv_rec.ATTRIBUTE9;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE10 := l_source_pavv_rec.ATTRIBUTE10;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE11 := l_source_pavv_rec.ATTRIBUTE11;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE12 := l_source_pavv_rec.ATTRIBUTE12;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE13 := l_source_pavv_rec.ATTRIBUTE13;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE14 := l_source_pavv_rec.ATTRIBUTE14;
          g_pavv_tab(i).QUALIFIER_ATTRIBUTE15 := l_source_pavv_rec.ATTRIBUTE15;
          g_pavv_tab(i).OBJECT_VERSION_NUMBER := l_source_pavv_rec.OBJECT_VERSION_NUMBER;
      END LOOP;
      IF c_source_pavv_rec%ROWCOUNT > 0 THEN
         l_no_data_found := FALSE;
      END IF;
      CLOSE c_source_pavv_rec;



     --IF l_no_data_found THEN
     --     OKC_UTIL.print_trace(4, 'END --> get_pavv_tab: returned error- ');
     --     RAISE OKC_API.G_EXCEPTION_ERROR;
     --ELSE
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4, 'Output: PL/SQL global table- g_pavv_tab');
           OKC_UTIL.print_trace(4, 'END --> get_pavv_tab- ');
        END IF;
     --END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4,SQLERRM);
        END IF;
         -- Bug#2320635
        OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
        IF c_source_pavv_rec%ISOPEN THEN
           CLOSE c_source_pavv_rec;
        END IF;
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END get_pavv_tab;
  ----------------------------------------------------------------------------
  /************************************************************************
   ************************************************************************
                   END OF QTK or OTK PRICING INFORMATION CREATION
   ************************************************************************
   ***********************************************************************/



--  =========================================================================
--  =========================================================================
--                   START OF KTQ or KTO PRICING INFORMATION CREATION
--                                   or UPDATE
--  =========================================================================
--  =========================================================================

---------------------------------------------------------------------------
   PROCEDURE get_price_adj(p_chr_id 	IN NUMBER,
			p_cle_id 	IN NUMBER,
		--
			p_qhr_id        IN NUMBER,
			p_qle_id        IN NUMBER,
			p_q_flag	IN VARCHAR2,
		--
			p_ohr_id	IN NUMBER,
			p_ole_id	IN NUMBER,
			p_o_flag	IN VARCHAR2,
		--
			p_level		IN VARCHAR2,
		--
			p_nqhr_id	IN NUMBER,
			p_nqle_idx	IN NUMBER,
		--
			x_k_price_adj_tab OUT NOCOPY k_price_adj_tab_type,
			x_price_adj_tab   OUT NOCOPY ASO_QUOTE_PUB.price_adj_tbl_type) IS

--
-- Cursor to identify the price adjustments which have to be deleted taking into
-- account those marked as to be updated or created.
--
--
  CURSOR c_price_adj(	b_q_flag VARCHAR,b_qh_id NUMBER,b_ql_id NUMBER,
			b_o_flag VARCHAR, b_oh_id NUMBER, b_ol_id NUMBER) IS
  SELECT
        qpadj.PRICE_ADJUSTMENT_ID   -- quote(header or line) price adj ID
  FROM
        OKX_QTE_PRC_ADJMNTS_V qpadj
  WHERE
	b_q_flag = OKC_API.G_TRUE
  AND   qpadj.quote_header_id = b_qh_id
  AND   ((b_ql_id IS NULL AND qpadj.quote_line_id IS NULL) OR
                (b_ql_id IS NOT NULL AND qpadj.quote_line_id=b_ql_id))

  UNION

  SELECT
	PRICE_ADJUSTMENT_ID   -- quote(header or line) price adj ID
  FROM
	OKX_ORD_PRC_ADJMNTS_V opadj
  WHERE
	b_o_flag = OKC_API.G_TRUE
  AND	opadj.header_id = b_oh_id
  AND ((b_ol_id IS NULL AND opadj.line_id IS NULL) OR
		(b_ol_id IS NOT NULL AND opadj.line_id=b_ol_id));

--
-- Cursor to identify the quote price adjustments which have to be created,updated or deleted
--

  CURSOR c_k_price_adj( b_kh_id NUMBER,b_kl_id NUMBER,
			b_q_flag VARCHAR,b_qh_id NUMBER,b_ql_id NUMBER,
			b_o_flag VARCHAR,b_oh_id NUMBER,b_ol_id NUMBER) IS
    SELECT
        DECODE(qpadj.modifier_header_id,NULL,g_aso_op_code_create,
                DECODE(qpadj.modifier_line_id,NULL,g_aso_op_code_create,
                        DECODE(qpadj.modifier_line_type_code,NULL,
					g_aso_op_code_create,g_aso_op_code_update)
                        )
                ) OPERATION_CODE,
        qpadj.PRICE_ADJUSTMENT_ID,  -- quote(header or line) price adj ID
        kpadj.id,                       -- contract(header or line) price adj ID
	kpadj.pat_id,
	kpadj.chr_id,
	kpadj.cle_id,
	kpadj.modified_from,
	kpadj.modified_to,
	kpadj.modifier_mechanism_type_code,
	kpadj.operand,
	kpadj.arithmetic_operator,
	kpadj.automatic_flag,
	kpadj.update_allowed,
	kpadj.updated_flag,
	kpadj.applied_flag,
	kpadj.on_invoice_flag,
	kpadj.pricing_phase_id,
	kpadj.context,
	kpadj.attribute1,
	kpadj.attribute2,
	kpadj.attribute3,
	kpadj.attribute4,
	kpadj.attribute5,
	kpadj.attribute6,
	kpadj.attribute7,
	kpadj.attribute8,
	kpadj.attribute9,
	kpadj.attribute10,
	kpadj.attribute11,
	kpadj.attribute12,
	kpadj.attribute13,
	kpadj.attribute14,
	kpadj.attribute15,
	kpadj.list_header_id,
	kpadj.list_line_id,
	kpadj.list_line_type_code,
	kpadj.change_reason_code,
	kpadj.change_reason_text,
	kpadj.estimated_flag,
	kpadj.adjusted_amount,
	kpadj.charge_type_code,
	kpadj.charge_subtype_code,
	kpadj.range_break_quantity,
	kpadj.accrual_conversion_rate,
	kpadj.pricing_group_sequence,
	kpadj.accrual_flag,
	kpadj.list_line_no,
	kpadj.source_system_code,
	kpadj.benefit_qty,
	kpadj.benefit_uom_code,
	kpadj.expiration_date,
	kpadj.modifier_level_code,
	kpadj.price_break_type_code,
	kpadj.substitution_attribute,
	kpadj.proration_type_code,
	kpadj.include_on_returns_flag,
	kpadj.rebate_transaction_type_code,
	kpadj.creation_date
  FROM
        OKC_PRICE_ADJUSTMENTS           kpadj,
        OKX_QTE_PRC_ADJMNTS_V   qpadj
  WHERE
	  b_q_flag = OKC_API.g_true
  AND 	  (kpadj.chr_id = b_kh_id)
  AND     ((b_kl_id IS NULL and kpadj.cle_id IS NULL ) OR (b_kl_id IS NOT NULL AND kpadj.cle_id = b_kl_id))
--
  AND     (qpadj.quote_header_id(+) = b_qh_id)
--
  AND     NVL(qpadj.quote_line_id(+),0) = NVL(b_ql_id,0)
--
  AND     qpadj.modifier_header_id(+) = kpadj.list_header_id
  AND     qpadj.modifier_line_id(+) = kpadj.list_line_id
  AND     qpadj.modifier_line_type_code(+) = kpadj.list_line_type_code
UNION
    SELECT
        DECODE(opadj.list_header_id,NULL,g_aso_op_code_create,
                DECODE(opadj.list_line_id,NULL,g_aso_op_code_create,
                        DECODE(opadj.list_line_type_code,NULL,
					g_aso_op_code_create,g_aso_op_code_update)
                        )
                ) OPERATION_CODE,
        opadj.PRICE_ADJUSTMENT_ID,  -- order(header or line) price adj ID
        kpadj.id,                       -- contract(header or line) price adj ID
	kpadj.pat_id,
	kpadj.chr_id,
	kpadj.cle_id,
	kpadj.modified_from,
	kpadj.modified_to,
	kpadj.modifier_mechanism_type_code,
	kpadj.operand,
	kpadj.arithmetic_operator,
	kpadj.automatic_flag,
	kpadj.update_allowed,
	kpadj.updated_flag,
	kpadj.applied_flag,
	kpadj.on_invoice_flag,
	kpadj.pricing_phase_id,
	kpadj.context,
	kpadj.attribute1,
	kpadj.attribute2,
	kpadj.attribute3,
	kpadj.attribute4,
	kpadj.attribute5,
	kpadj.attribute6,
	kpadj.attribute7,
	kpadj.attribute8,
	kpadj.attribute9,
	kpadj.attribute10,
	kpadj.attribute11,
	kpadj.attribute12,
	kpadj.attribute13,
	kpadj.attribute14,
	kpadj.attribute15,
	kpadj.list_header_id,
	kpadj.list_line_id,
	kpadj.list_line_type_code,
	kpadj.change_reason_code,
	kpadj.change_reason_text,
	kpadj.estimated_flag,
	kpadj.adjusted_amount,
	kpadj.charge_type_code,
	kpadj.charge_subtype_code,
	kpadj.range_break_quantity,
	kpadj.accrual_conversion_rate,
	kpadj.pricing_group_sequence,
	kpadj.accrual_flag,
	kpadj.list_line_no,
	kpadj.source_system_code,
	kpadj.benefit_qty,
	kpadj.benefit_uom_code,
	kpadj.expiration_date,
	kpadj.modifier_level_code,
	kpadj.price_break_type_code,
	kpadj.substitution_attribute,
	kpadj.proration_type_code,
	kpadj.include_on_returns_flag,
	kpadj.rebate_transaction_type_code,
	kpadj.creation_date
  FROM
        OKC_PRICE_ADJUSTMENTS           kpadj,
        OKX_ORD_PRC_ADJMNTS_V   opadj
  WHERE
	  b_o_flag = OKC_API.g_true
  AND 	  (kpadj.chr_id = b_kh_id)
  AND     ((b_kl_id IS NULL and kpadj.cle_id IS NULL ) OR (b_kl_id IS NOT NULL AND kpadj.cle_id = b_kl_id))
--
  AND     (opadj.header_id(+) = b_oh_id)
--
  AND     NVL(opadj.line_id(+),0) = NVL(b_ol_id,0)
--
  AND     opadj.list_header_id(+) = kpadj.list_header_id
  AND     opadj.list_line_id(+) = kpadj.list_line_id
  AND     opadj.list_line_type_code(+) = kpadj.list_line_type_code
--
  ORDER BY
        1,	-- kpadj.operation_code,         -- CREATE, UPDATE
       34, 	-- kpadj.list_header_id,
       35, 	-- kpadj.list_line_id,
       36, 	-- kpadj.list_line_type_code,
        3, 	-- kpadj.id,
       58; 	-- kpadj.creation_date;


-- Variables
--
  l_prec_okc_price_adj_id	okc_price_adjustments.id%TYPE ;
  l_prec_prc_adj_procesd 	VARCHAR2(1) := OKC_API.G_FALSE;
  g_miss_price_adj_rec		c_k_price_adj%ROWTYPE;
  l_prec_price_adj_rec		c_k_price_adj%ROWTYPE := g_miss_price_adj_rec;
  l_price_adj_insert		VARCHAR2(1) := OKC_API.G_TRUE;

  l_price_adj_rec	ASO_QUOTE_PUB.price_adj_rec_type;
  l_price_adj_tab	ASO_QUOTE_PUB.price_adj_tbl_type;
  l_k_tmp_price_adj_tab	k_price_adj_tab_type;

--
-- Variables to keep track of count for the l_price_adj_tab and
-- l_k_tmp_price_adj_tab tables
--
  x  BINARY_INTEGER;
  y  BINARY_INTEGER;

BEGIN

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'---------------------------------');
   	okc_util.print_trace(1,'>> start : Get price adjustments ');
   	okc_util.print_trace(1,'---------------------------------');
	END IF;

--
-- housekeeping
--
 l_price_adj_tab.DELETE;
 l_k_tmp_price_adj_tab.DELETE;

 x_k_price_adj_tab.DELETE;
 x_price_adj_tab.DELETE;

x := l_price_adj_tab.COUNT;
y := l_k_tmp_price_adj_tab.COUNT;

IF x = 0 THEN
   x:=x+1;
END IF;

IF y = 0 THEN
   y:=y+1;
END IF;
--
-- Fill in the l_price_adj_tab variable with price adjustment to be created or updated.
--
----------------------------------------------------------------------------------
-- Display the price adjustment records

-- IF p_level = 'L' THEN
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'*********************************************');
  END IF;
  FOR price_adj_rec IN c_k_price_adj(p_chr_id, p_cle_id,
					p_q_flag,p_qhr_id ,p_qle_id,
					p_o_flag,p_ohr_id,p_ole_id) LOOP
 IF c_k_price_adj%FOUND THEN
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'  ');
     okc_util.print_trace(1,'---------------------------------------------');
     okc_util.print_trace(1,'Values from c_k_price_adj cursor - contract price adjustments');
     okc_util.print_trace(1,'operation code       '||price_adj_rec.operation_code);
     okc_util.print_trace(1,'quote price adj id   '||price_adj_rec.price_adjustment_id);
     okc_util.print_trace(1,'prc adj ID           '||price_adj_rec.id);
     okc_util.print_trace(1,'---------------------------------------------');
     okc_util.print_trace(1,'  ');
  END IF;
 END IF;

  END LOOP;
-- END IF;
-----------------------------------------------------------------------------------------------
  FOR price_adj_rec IN c_k_price_adj(p_chr_id, p_cle_id,
					p_q_flag,p_qhr_id ,p_qle_id,
					p_o_flag,p_ohr_id,p_ole_id) LOOP
    l_price_adj_insert :=  OKC_API.G_TRUE;

	IF price_adj_rec.operation_code = g_aso_op_code_create THEN

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'step 1-1 operation code = '||price_adj_rec.operation_code);
END IF;

--	  Populate l_price_adj_rec with infomation from price_adj_rec;


	l_price_adj_rec.operation_code 		:= price_adj_rec.operation_code;
	l_price_adj_rec.price_adjustment_id 	:= price_adj_rec.price_adjustment_id;
	l_price_adj_rec.modifier_mechanism_type_code := price_adj_rec.modifier_mechanism_type_code;
	l_price_adj_rec.modified_from		:= price_adj_rec.modified_from;
	l_price_adj_rec.modified_to		:= price_adj_rec.modified_to;
	l_price_adj_rec.operand			:= price_adj_rec.operand;
	l_price_adj_rec.arithmetic_operator	:= price_adj_rec.arithmetic_operator;
	l_price_adj_rec.automatic_flag		:= price_adj_rec.automatic_flag;
        l_price_adj_rec.update_allowable_flag   := price_adj_rec.update_allowed;
        l_price_adj_rec.updated_flag		:= price_adj_rec.updated_flag;
        l_price_adj_rec.applied_flag		:= price_adj_rec.applied_flag;
        l_price_adj_rec.on_invoice_flag		:= price_adj_rec.on_invoice_flag;
        l_price_adj_rec.pricing_phase_id	:= price_adj_rec.pricing_phase_id;
        l_price_adj_rec.attribute_category	:= price_adj_rec.context;
        l_price_adj_rec.attribute1		:= price_adj_rec.attribute1;
        l_price_adj_rec.attribute2		:= price_adj_rec.attribute2;
        l_price_adj_rec.attribute3		:= price_adj_rec.attribute3;
        l_price_adj_rec.attribute4		:= price_adj_rec.attribute4;
        l_price_adj_rec.attribute5		:= price_adj_rec.attribute5;
        l_price_adj_rec.attribute6		:= price_adj_rec.attribute6;
        l_price_adj_rec.attribute7		:= price_adj_rec.attribute7;
        l_price_adj_rec.attribute8		:= price_adj_rec.attribute8;
        l_price_adj_rec.attribute9		:= price_adj_rec.attribute9;
        l_price_adj_rec.attribute10		:= price_adj_rec.attribute10;
        l_price_adj_rec.attribute11		:= price_adj_rec.attribute11;
        l_price_adj_rec.attribute12		:= price_adj_rec.attribute12;
        l_price_adj_rec.attribute13		:= price_adj_rec.attribute13;
        l_price_adj_rec.attribute14		:= price_adj_rec.attribute14;
        l_price_adj_rec.attribute15		:= price_adj_rec.attribute15;
        l_price_adj_rec.modifier_header_id	:= price_adj_rec.list_header_id;
        l_price_adj_rec.modifier_line_id	:= price_adj_rec.list_line_id;
        l_price_adj_rec.modifier_line_type_code	:= price_adj_rec.list_line_type_code;
        l_price_adj_rec.change_reason_code	:= price_adj_rec.change_reason_code;
        l_price_adj_rec.change_reason_text	:= price_adj_rec.change_reason_text;
        l_price_adj_rec.estimated_flag		:= price_adj_rec.estimated_flag;
        l_price_adj_rec.adjusted_amount		:= price_adj_rec.adjusted_amount;
        l_price_adj_rec.charge_type_code	:= price_adj_rec.charge_type_code;
        l_price_adj_rec.charge_subtype_code	:= price_adj_rec.charge_subtype_code;
        l_price_adj_rec.range_break_quantity	:= price_adj_rec.range_break_quantity;
        l_price_adj_rec.accrual_conversion_rate := price_adj_rec.accrual_conversion_rate;
	l_price_adj_rec.pricing_group_sequence  := price_adj_rec.pricing_group_sequence;
        l_price_adj_rec.accrual_flag		:= price_adj_rec.accrual_flag;
        l_price_adj_rec.list_line_no		:= price_adj_rec.list_line_no;
        l_price_adj_rec.source_system_code	:= price_adj_rec.source_system_code;
        l_price_adj_rec.benefit_qty		:= price_adj_rec.benefit_qty;
        l_price_adj_rec.benefit_uom_code	:= price_adj_rec.benefit_uom_code;
  --    l_price_adj_rec.expiration_date		:= price_adj_rec.expiration_date;
        l_price_adj_rec.modifier_level_code	:= price_adj_rec.modifier_level_code;
        l_price_adj_rec.price_break_type_code	:= price_adj_rec.price_break_type_code;
        l_price_adj_rec.substitution_attribute	:= price_adj_rec.substitution_attribute;
        l_price_adj_rec.proration_type_code	:= price_adj_rec.proration_type_code;
        l_price_adj_rec.include_on_returns_flag := price_adj_rec.include_on_returns_flag;
        l_price_adj_rec.rebate_transaction_type_code := price_adj_rec.rebate_transaction_type_code;

	   l_price_adj_rec.quote_header_id := p_qhr_id;
	   l_price_adj_rec.quote_line_id := p_qle_id;

		IF p_level = 'L' AND p_qhr_id IS NULL AND p_qle_id IS NULL THEN
						 -- related quote line has to be created
			l_price_adj_rec.quote_header_id := p_nqhr_id;
			l_price_adj_rec.qte_line_index := p_nqle_idx;
		END IF;
		l_price_adj_rec.price_adjustment_id := OKC_API.G_MISS_NUM;
	END IF;

	IF price_adj_rec.operation_code = g_aso_op_code_update THEN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1,'step 1-2 operation code = '||price_adj_rec.operation_code);
		END IF;
	   IF NVL(l_prec_okc_price_adj_id,0) <> price_adj_rec.id  THEN

	-- Need to check if the related quote price adjustment is not already planned to be
	-- updated in the l_price_adj_tab variable
	   IF l_price_adj_tab.first IS NOT NULL THEN
		FOR i IN l_price_adj_tab.first..l_price_adj_tab.last LOOP
		   IF l_price_adj_tab(i).price_adjustment_id = price_adj_rec.price_adjustment_id THEN
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'step 1-3 related quote price adjustment is already planned to be updated');
END IF;
			l_price_adj_insert := OKC_API.G_FALSE;
			exit;
		   END IF;
		END LOOP;
	    END IF;
	ELSE
	-- current contract price adjustment matches with multiple quote price adjustments
	-- and will be disregarded if already processed or if related quote price adjustment is
	-- not already planned to be updated in the l_price_adj_tab variable.
	--
	   IF l_prec_prc_adj_procesd = OKC_API.G_TRUE THEN
		l_price_adj_insert  := OKC_API.G_FALSE;
		l_prec_prc_adj_procesd  := OKC_API.G_FALSE;
	   ELSE
		IF l_price_adj_tab.first IS NOT NULL THEN
                FOR i IN l_price_adj_tab.first..l_price_adj_tab.last LOOP
		     IF l_price_adj_tab(i).price_adjustment_id = price_adj_rec.price_adjustment_id THEN
			 l_price_adj_insert := OKC_API.G_FALSE;
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(1,'step 1-4 checking ctrct pr adj with multiple qte prc adj');
			END IF;
			 exit;
		     END IF;
		END LOOP;
	    END IF;
	END IF;	-- IF l_prec_prc_adj_procesd := okc_api.g_true then..
   END IF;  -- IF l_prec_okc_price_adj_id <> price_adj_rec.id and ..

   IF NVL(l_prec_okc_price_adj_id,0) <> price_adj_rec.id THEN
      IF l_prec_okc_price_adj_id IS NOT NULL AND l_prec_prc_adj_procesd = OKC_API.G_FALSE THEN
	-- Populate l_price_adj_rec with information from l_prec_price_adj_rec;


	l_price_adj_rec.modifier_mechanism_type_code := l_prec_price_adj_rec.modifier_mechanism_type_code;
	l_price_adj_rec.modified_from		:= l_prec_price_adj_rec.modified_from;
	l_price_adj_rec.modified_to		:= l_prec_price_adj_rec.modified_to;
	l_price_adj_rec.operand			:= l_prec_price_adj_rec.operand;
	l_price_adj_rec.arithmetic_operator	:= l_prec_price_adj_rec.arithmetic_operator;
	l_price_adj_rec.automatic_flag		:= l_prec_price_adj_rec.automatic_flag;
        l_price_adj_rec.update_allowable_flag	:= l_prec_price_adj_rec.update_allowed;
        l_price_adj_rec.updated_flag		:= l_prec_price_adj_rec.updated_flag;
        l_price_adj_rec.applied_flag		:= l_prec_price_adj_rec.applied_flag;
        l_price_adj_rec.on_invoice_flag		:= l_prec_price_adj_rec.on_invoice_flag;
        l_price_adj_rec.pricing_phase_id	:= l_prec_price_adj_rec.pricing_phase_id;
        l_price_adj_rec.attribute_category	:= l_prec_price_adj_rec.context;
        l_price_adj_rec.attribute1		:= l_prec_price_adj_rec.attribute1;
        l_price_adj_rec.attribute2		:= l_prec_price_adj_rec.attribute2;
        l_price_adj_rec.attribute3		:= l_prec_price_adj_rec.attribute3;
        l_price_adj_rec.attribute4		:= l_prec_price_adj_rec.attribute4;
        l_price_adj_rec.attribute5		:= l_prec_price_adj_rec.attribute5;
        l_price_adj_rec.attribute6		:= l_prec_price_adj_rec.attribute6;
        l_price_adj_rec.attribute7		:= l_prec_price_adj_rec.attribute7;
        l_price_adj_rec.attribute8		:= l_prec_price_adj_rec.attribute8;
        l_price_adj_rec.attribute9		:= l_prec_price_adj_rec.attribute9;
        l_price_adj_rec.attribute10		:= l_prec_price_adj_rec.attribute10;
        l_price_adj_rec.attribute11		:= l_prec_price_adj_rec.attribute11;
        l_price_adj_rec.attribute12		:= l_prec_price_adj_rec.attribute12;
        l_price_adj_rec.attribute13		:= l_prec_price_adj_rec.attribute13;
        l_price_adj_rec.attribute14		:= l_prec_price_adj_rec.attribute14;
        l_price_adj_rec.attribute15		:= l_prec_price_adj_rec.attribute15;
        l_price_adj_rec.modifier_header_id	:= l_prec_price_adj_rec.list_header_id;
        l_price_adj_rec.modifier_line_id	:= l_prec_price_adj_rec.list_line_id;
        l_price_adj_rec.modifier_line_type_code	:= l_prec_price_adj_rec.list_line_type_code;
        l_price_adj_rec.change_reason_code	:= l_prec_price_adj_rec.change_reason_code;
        l_price_adj_rec.change_reason_text	:= l_prec_price_adj_rec.change_reason_text;
        l_price_adj_rec.estimated_flag		:= l_prec_price_adj_rec.estimated_flag;
        l_price_adj_rec.adjusted_amount		:= l_prec_price_adj_rec.adjusted_amount;
        l_price_adj_rec.charge_type_code	:= l_prec_price_adj_rec.charge_type_code;
        l_price_adj_rec.charge_subtype_code	:= l_prec_price_adj_rec.charge_subtype_code;
        l_price_adj_rec.range_break_quantity	:= l_prec_price_adj_rec.range_break_quantity;
        l_price_adj_rec.accrual_conversion_rate := l_prec_price_adj_rec.accrual_conversion_rate;
	l_price_adj_rec.pricing_group_sequence  := l_prec_price_adj_rec.pricing_group_sequence;
        l_price_adj_rec.accrual_flag		:= l_prec_price_adj_rec.accrual_flag;
        l_price_adj_rec.list_line_no		:= l_prec_price_adj_rec.list_line_no;
        l_price_adj_rec.source_system_code	:= l_prec_price_adj_rec.source_system_code;
        l_price_adj_rec.benefit_qty		:= l_prec_price_adj_rec.benefit_qty;
        l_price_adj_rec.benefit_uom_code	:= l_prec_price_adj_rec.benefit_uom_code;
   --   l_price_adj_rec.expiration_date		:= l_prec_price_adj_rec.expiration_date;
        l_price_adj_rec.modifier_level_code	:= l_prec_price_adj_rec.modifier_level_code;
        l_price_adj_rec.price_break_type_code	:= l_prec_price_adj_rec.price_break_type_code;
        l_price_adj_rec.substitution_attribute	:= l_prec_price_adj_rec.substitution_attribute;
        l_price_adj_rec.proration_type_code	:= l_prec_price_adj_rec.proration_type_code;
        l_price_adj_rec.include_on_returns_flag := l_prec_price_adj_rec.include_on_returns_flag;
        l_price_adj_rec.rebate_transaction_type_code := l_prec_price_adj_rec.rebate_transaction_type_code;


	   l_price_adj_rec.operation_code := g_aso_op_code_create;
	   l_price_adj_rec.quote_header_id := p_qhr_id;
	   l_price_adj_rec.quote_line_id := p_qle_id;
	   l_price_adj_rec.price_adjustment_id := OKC_API.G_MISS_NUM;

	   l_price_adj_tab(x) := l_price_adj_rec;
	   x := x + 1;
--
	   l_k_tmp_price_adj_tab(y).id := l_prec_price_adj_rec.id;
	   l_k_tmp_price_adj_tab(y).level := p_level;
	   y := y + 1;

	   l_prec_prc_adj_procesd := okc_api.g_true;
      END IF;
      l_prec_okc_price_adj_id := price_adj_rec.id;
      l_prec_prc_adj_procesd := OKC_API.G_FALSE;
   END IF;

   IF l_price_adj_insert = OKC_API.G_TRUE THEN
	l_price_adj_rec.quote_header_id := p_qhr_id;
	l_price_adj_rec.quote_line_id := p_qle_id;

	l_price_adj_rec.operation_code 		:= price_adj_rec.operation_code;
	l_price_adj_rec.price_adjustment_id 	:= price_adj_rec.price_adjustment_id;
	l_price_adj_rec.modifier_mechanism_type_code := price_adj_rec.modifier_mechanism_type_code;
	l_price_adj_rec.modified_from		:= price_adj_rec.modified_from;
	l_price_adj_rec.modified_to		:= price_adj_rec.modified_to;
	l_price_adj_rec.operand			:= price_adj_rec.operand;
	l_price_adj_rec.arithmetic_operator	:= price_adj_rec.arithmetic_operator;
	l_price_adj_rec.automatic_flag		:= price_adj_rec.automatic_flag;
        l_price_adj_rec.update_allowable_flag	:= price_adj_rec.update_allowed;
        l_price_adj_rec.updated_flag		:= price_adj_rec.updated_flag;
        l_price_adj_rec.applied_flag		:= price_adj_rec.applied_flag;
        l_price_adj_rec.on_invoice_flag		:= price_adj_rec.on_invoice_flag;
        l_price_adj_rec.pricing_phase_id	:= price_adj_rec.pricing_phase_id;
        l_price_adj_rec.attribute_category	:= price_adj_rec.context;
        l_price_adj_rec.attribute1		:= price_adj_rec.attribute1;
        l_price_adj_rec.attribute2		:= price_adj_rec.attribute2;
        l_price_adj_rec.attribute3		:= price_adj_rec.attribute3;
        l_price_adj_rec.attribute4		:= price_adj_rec.attribute4;
        l_price_adj_rec.attribute5		:= price_adj_rec.attribute5;
        l_price_adj_rec.attribute6		:= price_adj_rec.attribute6;
        l_price_adj_rec.attribute7		:= price_adj_rec.attribute7;
        l_price_adj_rec.attribute8		:= price_adj_rec.attribute8;
        l_price_adj_rec.attribute9		:= price_adj_rec.attribute9;
        l_price_adj_rec.attribute10		:= price_adj_rec.attribute10;
        l_price_adj_rec.attribute11		:= price_adj_rec.attribute11;
        l_price_adj_rec.attribute12		:= price_adj_rec.attribute12;
        l_price_adj_rec.attribute13		:= price_adj_rec.attribute13;
        l_price_adj_rec.attribute14		:= price_adj_rec.attribute14;
        l_price_adj_rec.attribute15		:= price_adj_rec.attribute15;
        l_price_adj_rec.modifier_header_id	:= price_adj_rec.list_header_id;
        l_price_adj_rec.modifier_line_id	:= price_adj_rec.list_line_id;
        l_price_adj_rec.modifier_line_type_code	:= price_adj_rec.list_line_type_code;
        l_price_adj_rec.change_reason_code	:= price_adj_rec.change_reason_code;
        l_price_adj_rec.change_reason_text	:= price_adj_rec.change_reason_text;
        l_price_adj_rec.estimated_flag		:= price_adj_rec.estimated_flag;
        l_price_adj_rec.adjusted_amount		:= price_adj_rec.adjusted_amount;
        l_price_adj_rec.charge_type_code	:= price_adj_rec.charge_type_code;
        l_price_adj_rec.charge_subtype_code	:= price_adj_rec.charge_subtype_code;
        l_price_adj_rec.range_break_quantity	:= price_adj_rec.range_break_quantity;
        l_price_adj_rec.accrual_conversion_rate := price_adj_rec.accrual_conversion_rate;
	l_price_adj_rec.pricing_group_sequence  := price_adj_rec.pricing_group_sequence;
        l_price_adj_rec.accrual_flag		:= price_adj_rec.accrual_flag;
        l_price_adj_rec.list_line_no		:= price_adj_rec.list_line_no;
        l_price_adj_rec.source_system_code	:= price_adj_rec.source_system_code;
        l_price_adj_rec.benefit_qty		:= price_adj_rec.benefit_qty;
        l_price_adj_rec.benefit_uom_code	:= price_adj_rec.benefit_uom_code;
   --   l_price_adj_rec.expiration_date		:= price_adj_rec.expiration_date;
        l_price_adj_rec.modifier_level_code	:= price_adj_rec.modifier_level_code;
        l_price_adj_rec.price_break_type_code	:= price_adj_rec.price_break_type_code;
        l_price_adj_rec.substitution_attribute	:= price_adj_rec.substitution_attribute;
        l_price_adj_rec.proration_type_code	:= price_adj_rec.proration_type_code;
        l_price_adj_rec.include_on_returns_flag := price_adj_rec.include_on_returns_flag;
        l_price_adj_rec.rebate_transaction_type_code := price_adj_rec.rebate_transaction_type_code;

   END IF;
 END IF; -- IF price_adj_rec.operation_code = 'UPADTE' then...


   IF l_price_adj_insert = OKC_API.G_TRUE THEN

	l_price_adj_tab(x) := l_price_adj_rec;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'INDEX VALUE x = '||x);
   okc_util.print_trace(1,'=========================================================');
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'operation code = '||l_price_adj_tab(x).operation_code);
   okc_util.print_trace(1,'quote header id = '||l_price_adj_tab(x).quote_header_id);
   okc_util.print_trace(1,'quote line id = '||l_price_adj_tab(x).quote_line_id);
   okc_util.print_trace(1,'price adjustment id = '||l_price_adj_tab(x).price_adjustment_id);
   okc_util.print_trace(1,'modifier_mechanism_type_code = '||l_price_adj_tab(x).modifier_mechanism_type_code);
   okc_util.print_trace(1,'modified_from = '||l_price_adj_tab(x).modified_from);
   okc_util.print_trace(1,'modified_to = '||l_price_adj_tab(x).modified_to);
   okc_util.print_trace(1,'operand = '||l_price_adj_tab(x).operand);
   okc_util.print_trace(1,'arithmetic_operator = '||l_price_adj_tab(x).arithmetic_operator);
   okc_util.print_trace(1,'automatic_flag = '||l_price_adj_tab(x).automatic_flag);
   okc_util.print_trace(1,'update_allowable flag = '||l_price_adj_tab(x).update_allowable_flag);
   okc_util.print_trace(1,'updated_flag = '||l_price_adj_tab(x).updated_flag);
   okc_util.print_trace(1,'applied_flag = '||l_price_adj_tab(x).applied_flag);
   okc_util.print_trace(1,'on_invoice_flag = '||l_price_adj_tab(x).on_invoice_flag);
   okc_util.print_trace(1,'pricing_phase_id = '||l_price_adj_tab(x).pricing_phase_id);
   okc_util.print_trace(1,'attribute_category = '||l_price_adj_tab(x).attribute_category);
   okc_util.print_trace(1,'attribute1 = '||l_price_adj_tab(x).attribute1);
   okc_util.print_trace(1,'attribute2 = '||l_price_adj_tab(x).attribute2);
   okc_util.print_trace(1,'attribute3 = '||l_price_adj_tab(x).attribute3);
   okc_util.print_trace(1,'attribute4 = '||l_price_adj_tab(x).attribute4);
   okc_util.print_trace(1,'attribute5 = '||l_price_adj_tab(x).attribute5);
   okc_util.print_trace(1,'attribute6 = '||l_price_adj_tab(x).attribute6);
   okc_util.print_trace(1,'attribute7 = '||l_price_adj_tab(x).attribute7);
   okc_util.print_trace(1,'attribute8 = '||l_price_adj_tab(x).attribute8);
   okc_util.print_trace(1,'attribute9 = '||l_price_adj_tab(x).attribute9);
   okc_util.print_trace(1,'attribute10 = '||l_price_adj_tab(x).attribute10);
   okc_util.print_trace(1,'attribute11 = '||l_price_adj_tab(x).attribute11);
   okc_util.print_trace(1,'attribute12 = '||l_price_adj_tab(x).attribute12);
   okc_util.print_trace(1,'attribute13 = '||l_price_adj_tab(x).attribute13);
   okc_util.print_trace(1,'attribute14 = '||l_price_adj_tab(x).attribute14);
   okc_util.print_trace(1,'attribute15 = '||l_price_adj_tab(x).attribute15);
   okc_util.print_trace(1,'modifier_header_id = '||l_price_adj_tab(x).modifier_header_id);
   okc_util.print_trace(1,'modifier_line_id = '||l_price_adj_tab(x).modifier_line_id);
   okc_util.print_trace(1,'modifier_line_type_code = '||l_price_adj_tab(x).modifier_line_type_code);
   okc_util.print_trace(1,'change_reason_code = '||l_price_adj_tab(x).change_reason_code);
   okc_util.print_trace(1,'change_reason_text = '||l_price_adj_tab(x).change_reason_text);
   okc_util.print_trace(1,'estimated_flag = '||l_price_adj_tab(x).estimated_flag);
   okc_util.print_trace(1,'adjusted_amount = '||l_price_adj_tab(x).adjusted_amount);
   okc_util.print_trace(1,'charge_type_code = '||l_price_adj_tab(x).charge_type_code);
   okc_util.print_trace(1,'charge_subtype_code = '||l_price_adj_tab(x).charge_subtype_code);
   okc_util.print_trace(1,'range_break_quantity = '||l_price_adj_tab(x).range_break_quantity);
   okc_util.print_trace(1,'accrual_conversion_rate = '||l_price_adj_tab(x).accrual_conversion_rate);
   okc_util.print_trace(1,'pricing_group_sequence = '||l_price_adj_tab(x).pricing_group_sequence);
   okc_util.print_trace(1,'accrual_flag = '||l_price_adj_tab(x).accrual_flag);
   okc_util.print_trace(1,'list_line_no = '||l_price_adj_tab(x).list_line_no);
   okc_util.print_trace(1,'source_system_code = '||l_price_adj_tab(x).source_system_code);
   okc_util.print_trace(1,'benefit_qty = '||l_price_adj_tab(x).benefit_qty);
   okc_util.print_trace(1,'benefit_uom_code = '||l_price_adj_tab(x).benefit_uom_code);
END IF;
-- okc_util.print_trace(1,'expiration_date = '||l_price_adj_tab(x).expiration_date);
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'modifier_level_code = '||l_price_adj_tab(x).modifier_level_code);
   okc_util.print_trace(1,'price_break_type_code = '||l_price_adj_tab(x).price_break_type_code);
   okc_util.print_trace(1,'substitution_attribute = '||l_price_adj_tab(x).substitution_attribute);
   okc_util.print_trace(1,'proration_type_code = '||l_price_adj_tab(x).proration_type_code);
   okc_util.print_trace(1,'include_on_returns_flag = '||l_price_adj_tab(x).include_on_returns_flag);
   okc_util.print_trace(1,'rebate_transaction_type_code = '||l_price_adj_tab(x).rebate_transaction_type_code);
   okc_util.print_trace(1,'  ');
END IF;

	x := x + 1;
--
	l_k_tmp_price_adj_tab(y).id := price_adj_rec.id;
	l_k_tmp_price_adj_tab(y).level := p_level;
	y := y + 1;
--
	l_prec_prc_adj_procesd := OKC_API.G_TRUE;
   END IF;

       l_prec_price_adj_rec := price_adj_rec;

END LOOP;   --- FOR price_adj_rec IN c_k_price_adj

--	Case of a new occurance of an existing price adjustment, not processed before because
--	the related quote price adjustments have already been marked to be processed.

IF  l_prec_price_adj_rec.operation_code = g_aso_op_code_update AND
	l_prec_okc_price_adj_id IS NOT NULL AND l_prec_prc_adj_procesd = OKC_API.G_FALSE THEN
-- populate l_price_adj_rec with infomation from l_prec_price_adj_rec;

	l_price_adj_rec.modifier_mechanism_type_code := l_prec_price_adj_rec.modifier_mechanism_type_code;
	l_price_adj_rec.modified_from		:= l_prec_price_adj_rec.modified_from;
	l_price_adj_rec.modified_to		:= l_prec_price_adj_rec.modified_to;
	l_price_adj_rec.operand			:= l_prec_price_adj_rec.operand;
	l_price_adj_rec.arithmetic_operator	:= l_prec_price_adj_rec.arithmetic_operator;
	l_price_adj_rec.automatic_flag		:= l_prec_price_adj_rec.automatic_flag;
        l_price_adj_rec.update_allowable_flag	:= l_prec_price_adj_rec.update_allowed;
        l_price_adj_rec.updated_flag		:= l_prec_price_adj_rec.updated_flag;
        l_price_adj_rec.applied_flag		:= l_prec_price_adj_rec.applied_flag;
        l_price_adj_rec.on_invoice_flag		:= l_prec_price_adj_rec.on_invoice_flag;
        l_price_adj_rec.pricing_phase_id	:= l_prec_price_adj_rec.pricing_phase_id;
        l_price_adj_rec.attribute_category	:= l_prec_price_adj_rec.context;
        l_price_adj_rec.attribute1		:= l_prec_price_adj_rec.attribute1;
        l_price_adj_rec.attribute2		:= l_prec_price_adj_rec.attribute2;
        l_price_adj_rec.attribute3		:= l_prec_price_adj_rec.attribute3;
        l_price_adj_rec.attribute4		:= l_prec_price_adj_rec.attribute4;
        l_price_adj_rec.attribute5		:= l_prec_price_adj_rec.attribute5;
        l_price_adj_rec.attribute6		:= l_prec_price_adj_rec.attribute6;
        l_price_adj_rec.attribute7		:= l_prec_price_adj_rec.attribute7;
        l_price_adj_rec.attribute8		:= l_prec_price_adj_rec.attribute8;
        l_price_adj_rec.attribute9		:= l_prec_price_adj_rec.attribute9;
        l_price_adj_rec.attribute10		:= l_prec_price_adj_rec.attribute10;
        l_price_adj_rec.attribute11		:= l_prec_price_adj_rec.attribute11;
        l_price_adj_rec.attribute12		:= l_prec_price_adj_rec.attribute12;
        l_price_adj_rec.attribute13		:= l_prec_price_adj_rec.attribute13;
        l_price_adj_rec.attribute14		:= l_prec_price_adj_rec.attribute14;
        l_price_adj_rec.attribute15		:= l_prec_price_adj_rec.attribute15;
        l_price_adj_rec.modifier_header_id	:= l_prec_price_adj_rec.list_header_id;
        l_price_adj_rec.modifier_line_id	:= l_prec_price_adj_rec.list_line_id;
        l_price_adj_rec.modifier_line_type_code	:= l_prec_price_adj_rec.list_line_type_code;
        l_price_adj_rec.change_reason_code	:= l_prec_price_adj_rec.change_reason_code;
        l_price_adj_rec.change_reason_text	:= l_prec_price_adj_rec.change_reason_text;
        l_price_adj_rec.estimated_flag		:= l_prec_price_adj_rec.estimated_flag;
        l_price_adj_rec.adjusted_amount		:= l_prec_price_adj_rec.adjusted_amount;
        l_price_adj_rec.charge_type_code	:= l_prec_price_adj_rec.charge_type_code;
        l_price_adj_rec.charge_subtype_code	:= l_prec_price_adj_rec.charge_subtype_code;
        l_price_adj_rec.range_break_quantity	:= l_prec_price_adj_rec.range_break_quantity;
        l_price_adj_rec.accrual_conversion_rate := l_prec_price_adj_rec.accrual_conversion_rate;
	l_price_adj_rec.pricing_group_sequence  := l_prec_price_adj_rec.pricing_group_sequence;
        l_price_adj_rec.accrual_flag		:= l_prec_price_adj_rec.accrual_flag;
        l_price_adj_rec.list_line_no		:= l_prec_price_adj_rec.list_line_no;
        l_price_adj_rec.source_system_code	:= l_prec_price_adj_rec.source_system_code;
        l_price_adj_rec.benefit_qty		:= l_prec_price_adj_rec.benefit_qty;
        l_price_adj_rec.benefit_uom_code	:= l_prec_price_adj_rec.benefit_uom_code;
   --   l_price_adj_rec.expiration_date		:= l_prec_price_adj_rec.expiration_date;
        l_price_adj_rec.modifier_level_code	:= l_prec_price_adj_rec.modifier_level_code;
        l_price_adj_rec.price_break_type_code	:= l_prec_price_adj_rec.price_break_type_code;
        l_price_adj_rec.substitution_attribute	:= l_prec_price_adj_rec.substitution_attribute;
        l_price_adj_rec.proration_type_code	:= l_prec_price_adj_rec.proration_type_code;
        l_price_adj_rec.include_on_returns_flag := l_prec_price_adj_rec.include_on_returns_flag;
        l_price_adj_rec.rebate_transaction_type_code := l_prec_price_adj_rec.rebate_transaction_type_code;

	l_price_adj_rec.operation_code := g_aso_op_code_create;
	l_price_adj_rec.quote_header_id := p_qhr_id;
	l_price_adj_rec.quote_line_id := p_qle_id;
	l_price_adj_rec.price_adjustment_id := OKC_API.G_MISS_NUM;
--
	l_price_adj_tab(x) := l_price_adj_rec;
	x:= x+1;
--
	l_k_tmp_price_adj_tab(y).id := l_prec_price_adj_rec.id;
	l_k_tmp_price_adj_tab(y).level := p_level;
	y:=y+1;

	l_prec_prc_adj_procesd := OKC_API.G_TRUE;
END IF;
--
--
-- Fill in the l_price_adj_tab variable with price adjustment to be deleted.
--

FOR l_price_adj IN c_price_adj(p_q_flag,p_qhr_id, p_qle_id,
				p_o_flag,p_ohr_id,p_ole_id) LOOP

 l_price_adj_insert := OKC_API.G_TRUE;
--
-- Need to check if the related quote price adjustment is not already planned to be updated
-- in the l_price_adj_tab_variable
--
	IF l_price_adj_tab.FIRST IS NOT NULL THEN
	  FOR i IN l_price_adj_tab.first..l_price_adj_tab.last LOOP
		IF l_price_adj_tab(i).price_adjustment_id = l_price_adj.price_adjustment_id THEN
			l_price_adj_insert := OKC_API.G_FALSE;
			exit;
		END IF;
	  END LOOP;
	END IF;
	IF l_price_adj_insert = OKC_API.G_TRUE THEN
-- populate l_price_adj_rec with information from l_price_adj
		l_price_adj_rec.operation_code := g_aso_op_code_delete;
		l_price_adj_rec.quote_header_id := p_qhr_id;
		l_price_adj_rec.quote_line_id := p_qle_id;

		l_price_adj_rec.price_adjustment_id := l_price_adj.price_adjustment_id;
--
		l_price_adj_tab(x) := l_price_adj_rec;
		x:=x+1;
	END IF;
END LOOP;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'-----------------------------------------');
   okc_util.print_trace(1,' values contained in the l_price_adj_tab ');
   okc_util.print_trace(1,'-----------------------------------------');
   okc_util.print_trace(1,'  ');
END IF;

 IF l_price_adj_tab.first IS NOT NULL THEN
    FOR i IN l_price_adj_tab.first..l_price_adj_tab.last LOOP
	IF l_price_adj_tab.EXISTS(i) THEN

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'index value  = '||i);
   okc_util.print_trace(1,'operation code = '||l_price_adj_tab(i).operation_code);
   okc_util.print_trace(1,'quote header id = '||l_price_adj_tab(i).quote_header_id);
   okc_util.print_trace(1,'quote line id = '||l_price_adj_tab(i).quote_line_id);
   okc_util.print_trace(1,'price adjustment id = '||l_price_adj_tab(i).price_adjustment_id);
   okc_util.print_trace(1,'modifier_mechanism_type_code = '||l_price_adj_tab(i).modifier_mechanism_type_code);
   okc_util.print_trace(1,'modified_from = '||l_price_adj_tab(i).modified_from);
   okc_util.print_trace(1,'modified_to = '||l_price_adj_tab(i).modified_to);
   okc_util.print_trace(1,'operand = '||l_price_adj_tab(i).operand);
   okc_util.print_trace(1,'arithmetic_operator = '||l_price_adj_tab(i).arithmetic_operator);
   okc_util.print_trace(1,'automatic_flag = '||l_price_adj_tab(i).automatic_flag);
   okc_util.print_trace(1,'update_allowable flag = '||l_price_adj_tab(i).update_allowable_flag);
   okc_util.print_trace(1,'updated_flag = '||l_price_adj_tab(i).updated_flag);
   okc_util.print_trace(1,'applied_flag = '||l_price_adj_tab(i).applied_flag);
   okc_util.print_trace(1,'on_invoice_flag = '||l_price_adj_tab(i).on_invoice_flag);
   okc_util.print_trace(1,'pricing_phase_id = '||l_price_adj_tab(i).pricing_phase_id);
   okc_util.print_trace(1,'attribute_category = '||l_price_adj_tab(i).attribute_category);
   okc_util.print_trace(1,'attribute1 = '||l_price_adj_tab(i).attribute1);
   okc_util.print_trace(1,'attribute2 = '||l_price_adj_tab(i).attribute2);
   okc_util.print_trace(1,'attribute3 = '||l_price_adj_tab(i).attribute3);
   okc_util.print_trace(1,'attribute4 = '||l_price_adj_tab(i).attribute4);
   okc_util.print_trace(1,'attribute5 = '||l_price_adj_tab(i).attribute5);
   okc_util.print_trace(1,'attribute6 = '||l_price_adj_tab(i).attribute6);
   okc_util.print_trace(1,'attribute7 = '||l_price_adj_tab(i).attribute7);
   okc_util.print_trace(1,'attribute8 = '||l_price_adj_tab(i).attribute8);
   okc_util.print_trace(1,'attribute9 = '||l_price_adj_tab(i).attribute9);
   okc_util.print_trace(1,'attribute10 = '||l_price_adj_tab(i).attribute10);
   okc_util.print_trace(1,'attribute11 = '||l_price_adj_tab(i).attribute11);
   okc_util.print_trace(1,'attribute12 = '||l_price_adj_tab(i).attribute12);
   okc_util.print_trace(1,'attribute13 = '||l_price_adj_tab(i).attribute13);
   okc_util.print_trace(1,'attribute14 = '||l_price_adj_tab(i).attribute14);
   okc_util.print_trace(1,'attribute15 = '||l_price_adj_tab(i).attribute15);
   okc_util.print_trace(1,'modifier_header_id = '||l_price_adj_tab(i).modifier_header_id);
   okc_util.print_trace(1,'modifier_line_id = '||l_price_adj_tab(i).modifier_line_id);
   okc_util.print_trace(1,'modifier_line_type_code = '||l_price_adj_tab(i).modifier_line_type_code);
   okc_util.print_trace(1,'change_reason_code = '||l_price_adj_tab(i).change_reason_code);
   okc_util.print_trace(1,'change_reason_text = '||l_price_adj_tab(i).change_reason_text);
   okc_util.print_trace(1,'estimated_flag = '||l_price_adj_tab(i).estimated_flag);
   okc_util.print_trace(1,'adjusted_amount = '||l_price_adj_tab(i).adjusted_amount);
   okc_util.print_trace(1,'charge_type_code = '||l_price_adj_tab(i).charge_type_code);
   okc_util.print_trace(1,'charge_subtype_code = '||l_price_adj_tab(i).charge_subtype_code);
   okc_util.print_trace(1,'range_break_quantity = '||l_price_adj_tab(i).range_break_quantity);
   okc_util.print_trace(1,'accrual_conversion_rate = '||l_price_adj_tab(i).accrual_conversion_rate);
   okc_util.print_trace(1,'pricing_group_sequence = '||l_price_adj_tab(i).pricing_group_sequence);
   okc_util.print_trace(1,'accrual_flag = '||l_price_adj_tab(i).accrual_flag);
   okc_util.print_trace(1,'list_line_no = '||l_price_adj_tab(i).list_line_no);
   okc_util.print_trace(1,'source_system_code = '||l_price_adj_tab(i).source_system_code);
   okc_util.print_trace(1,'benefit_qty = '||l_price_adj_tab(i).benefit_qty);
   okc_util.print_trace(1,'benefit_uom_code = '||l_price_adj_tab(i).benefit_uom_code);
END IF;
-- okc_util.print_trace(1,'expiration_date = '||l_price_adj_tab(i).expiration_date);
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'modifier_level_code = '||l_price_adj_tab(i).modifier_level_code);
   okc_util.print_trace(1,'price_break_type_code = '||l_price_adj_tab(i).price_break_type_code);
   okc_util.print_trace(1,'substitution_attribute = '||l_price_adj_tab(i).substitution_attribute);
   okc_util.print_trace(1,'proration_type_code = '||l_price_adj_tab(i).proration_type_code);
   okc_util.print_trace(1,'include_on_returns_flag = '||l_price_adj_tab(i).include_on_returns_flag);
   okc_util.print_trace(1,'rebate_transaction_type_code = '||l_price_adj_tab(i).rebate_transaction_type_code);
   okc_util.print_trace(1,'  ');
END IF;
	END IF;
    END LOOP;
 END IF;



IF l_k_tmp_price_adj_tab.count > 0 THEN
	FOR i IN l_k_tmp_price_adj_tab.FIRST..l_k_tmp_price_adj_tab.LAST LOOP
    		x_k_price_adj_tab(x_k_price_adj_tab.COUNT+1) := l_k_tmp_price_adj_tab(i);
	END LOOP;
END IF;

IF l_price_adj_tab.COUNT > 0 THEN
	FOR i IN l_price_adj_tab.FIRST..l_price_adj_tab.LAST LOOP
		x_price_adj_tab(x_price_adj_tab.COUNT+1) := l_price_adj_tab(i);
	END LOOP;
END IF;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,' FINAL VALUES CONTAINED IN THE X_PRICE_ADJ_TAB ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,'  ');
END IF;

 IF x_price_adj_tab.first IS NOT NULL THEN
    FOR i IN x_price_adj_tab.first..x_price_adj_tab.last LOOP
	IF x_price_adj_tab.EXISTS(i) THEN

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'index value  = '||i);
   okc_util.print_trace(1,'operation code = '||x_price_adj_tab(i).operation_code);
   okc_util.print_trace(1,'quote header id = '||x_price_adj_tab(i).quote_header_id);
   okc_util.print_trace(1,'quote line id = '||x_price_adj_tab(i).quote_line_id);
   okc_util.print_trace(1,'price adjustment id = '||x_price_adj_tab(i).price_adjustment_id);
   okc_util.print_trace(1,'modifier_mechanism_type_code = '||x_price_adj_tab(i).modifier_mechanism_type_code);
   okc_util.print_trace(1,'modified_from = '||x_price_adj_tab(i).modified_from);
   okc_util.print_trace(1,'modified_to = '||x_price_adj_tab(i).modified_to);
   okc_util.print_trace(1,'operand = '||x_price_adj_tab(i).operand);
   okc_util.print_trace(1,'arithmetic_operator = '||x_price_adj_tab(i).arithmetic_operator);
   okc_util.print_trace(1,'automatic_flag = '||x_price_adj_tab(i).automatic_flag);
   okc_util.print_trace(1,'update_allowable flag = '||x_price_adj_tab(i).update_allowable_flag);
   okc_util.print_trace(1,'updated_flag = '||x_price_adj_tab(i).updated_flag);
   okc_util.print_trace(1,'applied_flag = '||x_price_adj_tab(i).applied_flag);
   okc_util.print_trace(1,'on_invoice_flag = '||x_price_adj_tab(i).on_invoice_flag);
   okc_util.print_trace(1,'pricing_phase_id = '||x_price_adj_tab(i).pricing_phase_id);
   okc_util.print_trace(1,'attribute_category = '||x_price_adj_tab(i).attribute_category);
   okc_util.print_trace(1,'attribute1 = '||x_price_adj_tab(i).attribute1);
   okc_util.print_trace(1,'attribute2 = '||x_price_adj_tab(i).attribute2);
   okc_util.print_trace(1,'attribute3 = '||x_price_adj_tab(i).attribute3);
   okc_util.print_trace(1,'attribute4 = '||x_price_adj_tab(i).attribute4);
   okc_util.print_trace(1,'attribute5 = '||x_price_adj_tab(i).attribute5);
   okc_util.print_trace(1,'attribute6 = '||x_price_adj_tab(i).attribute6);
   okc_util.print_trace(1,'attribute7 = '||x_price_adj_tab(i).attribute7);
   okc_util.print_trace(1,'attribute8 = '||x_price_adj_tab(i).attribute8);
   okc_util.print_trace(1,'attribute9 = '||x_price_adj_tab(i).attribute9);
   okc_util.print_trace(1,'attribute10 = '||x_price_adj_tab(i).attribute10);
   okc_util.print_trace(1,'attribute11 = '||x_price_adj_tab(i).attribute11);
   okc_util.print_trace(1,'attribute12 = '||x_price_adj_tab(i).attribute12);
   okc_util.print_trace(1,'attribute13 = '||x_price_adj_tab(i).attribute13);
   okc_util.print_trace(1,'attribute14 = '||x_price_adj_tab(i).attribute14);
   okc_util.print_trace(1,'attribute15 = '||x_price_adj_tab(i).attribute15);
   okc_util.print_trace(1,'modifier_header_id = '||x_price_adj_tab(i).modifier_header_id);
   okc_util.print_trace(1,'modifier_line_id = '||x_price_adj_tab(i).modifier_line_id);
   okc_util.print_trace(1,'modifier_line_type_code = '||x_price_adj_tab(i).modifier_line_type_code);
   okc_util.print_trace(1,'change_reason_code = '||x_price_adj_tab(i).change_reason_code);
   okc_util.print_trace(1,'change_reason_text = '||x_price_adj_tab(i).change_reason_text);
   okc_util.print_trace(1,'estimated_flag = '||x_price_adj_tab(i).estimated_flag);
   okc_util.print_trace(1,'adjusted_amount = '||x_price_adj_tab(i).adjusted_amount);
   okc_util.print_trace(1,'charge_type_code = '||x_price_adj_tab(i).charge_type_code);
   okc_util.print_trace(1,'charge_subtype_code = '||x_price_adj_tab(i).charge_subtype_code);
   okc_util.print_trace(1,'range_break_quantity = '||x_price_adj_tab(i).range_break_quantity);
   okc_util.print_trace(1,'accrual_conversion_rate = '||x_price_adj_tab(i).accrual_conversion_rate);
   okc_util.print_trace(1,'pricing_group_sequence = '||x_price_adj_tab(i).pricing_group_sequence);
   okc_util.print_trace(1,'accrual_flag = '||x_price_adj_tab(i).accrual_flag);
   okc_util.print_trace(1,'list_line_no = '||x_price_adj_tab(i).list_line_no);
   okc_util.print_trace(1,'source_system_code = '||x_price_adj_tab(i).source_system_code);
   okc_util.print_trace(1,'benefit_qty = '||x_price_adj_tab(i).benefit_qty);
   okc_util.print_trace(1,'benefit_uom_code = '||x_price_adj_tab(i).benefit_uom_code);
END IF;
-- okc_util.print_trace(1,'expiration_date = '||x_price_adj_tab(i).expiration_date);
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'modifier_level_code = '||x_price_adj_tab(i).modifier_level_code);
   okc_util.print_trace(1,'price_break_type_code = '||x_price_adj_tab(i).price_break_type_code);
   okc_util.print_trace(1,'substitution_attribute = '||x_price_adj_tab(i).substitution_attribute);
   okc_util.print_trace(1,'proration_type_code = '||x_price_adj_tab(i).proration_type_code);
   okc_util.print_trace(1,'include_on_returns_flag = '||x_price_adj_tab(i).include_on_returns_flag);
   okc_util.print_trace(1,'rebate_transaction_type_code = '||x_price_adj_tab(i).rebate_transaction_type_code);
   okc_util.print_trace(1,'  ');
END IF;
	END IF;
    END LOOP;
 END IF;

--	x_k_price_adj_tab := l_k_tmp_price_adj_tab;
--	x_price_adj_tab := l_price_adj_tab;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,' FINAL VALUES CONTAINED IN THE X_K_PRICE_ADJ_TAB ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,'  ');
END IF;

 IF x_k_price_adj_tab.first IS NOT NULL THEN
    FOR i IN x_k_price_adj_tab.first..x_k_price_adj_tab.last LOOP
	IF x_k_price_adj_tab.EXISTS(i) THEN

     	IF (l_debug = 'Y') THEN
        	okc_util.print_trace(1,'INDEX VALUE =  '||i);
        	okc_util.print_trace(1,'Price Adj id = '||x_k_price_adj_tab(i).id);
        	okc_util.print_trace(1,'Level        = '||x_k_price_adj_tab(i).level);
     	END IF;

	END IF;

   END LOOP;
END IF;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'------------------------------');
   	okc_util.print_trace(1,'>>END : Get price adjustments ');
   	okc_util.print_trace(1,'------------------------------');
	END IF;

EXCEPTION
 WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            okc_util.print_trace(1,'inside get price adj: others exception');
            OKC_UTIL.print_trace(3,SQLERRM);
         END IF;
         -- Bug#2320635
         OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);

  IF c_k_price_adj%ISOPEN THEN
	CLOSE c_k_price_adj;
  END IF;
  IF c_price_adj%ISOPEN THEN
	CLOSE c_price_adj;
  END IF;

  RAISE OKC_API.G_EXCEPTION_ERROR;

END;	--get_price_adj

----------------------------------------------------------------------------
-- PROCEDURE get_price_adj_attr
--
----------------------------------------------------------------------------

PROCEDURE get_price_adj_attr ( p_price_adj_tab	IN ASO_QUOTE_PUB.price_adj_tbl_type,
				p_k_price_adj_tab IN k_price_adj_tab_type,
				p_q_flag	IN VARCHAR2,
				p_o_flag	IN VARCHAR2,
				p_level 	IN VARCHAR2,
				x_price_adj_attr_tab OUT NOCOPY ASO_QUOTE_PUB.price_adj_attr_tbl_type ) IS

 CURSOR c_k_price_adj_attr_c(b_kpat_id NUMBER) IS
  SELECT flex_title,
	 pricing_context,
	 pricing_attribute,
	 pricing_attr_value_from,
	 pricing_attr_value_to,
	 comparison_operator
  FROM
	okc_price_adj_attribs kpadj
  WHERE
	kpadj.pat_id = b_kpat_id;



 CURSOR c_k_price_adj_attr_u(b_kpat_id NUMBER,b_q_flag VARCHAR,b_o_flag VARCHAR,b_pat_id NUMBER) IS
  SELECT DECODE(qpadj.pricing_context,NULL,g_aso_op_code_create,
	  DECODE(qpadj.pricing_attribute,NULL,g_aso_op_code_create,g_aso_op_code_update)
		) OPERATION_CODE,
	 qpadj.price_adj_attrib_id,	-- quote price adj atribute ID
	 kpadj.id, 			-- contract price adj attribute id
	 kpadj.flex_title,
         kpadj.pricing_context,
         kpadj.pricing_attribute,
         kpadj.pricing_attr_value_from,
         kpadj.pricing_attr_value_to,
         kpadj.comparison_operator

 FROM
	okc_price_adj_attribs kpadj,
	OKX_QTE_PRC_ADJ_ATRBS_V qpadj
 WHERE
	b_q_flag = OKC_API.g_true
 AND	kpadj.pat_id	= b_kpat_id
 AND	qpadj.price_adjustment_id(+) = b_pat_id
 AND	qpadj.flex_title(+)	=kpadj.flex_title
 AND	qpadj.pricing_context(+)=kpadj.pricing_context
 AND	qpadj.pricing_attribute(+) = kpadj.pricing_attribute

UNION

  SELECT DECODE(opadj.pricing_context,NULL,g_aso_op_code_create,
	  DECODE(opadj.pricing_attribute,NULL,g_aso_op_code_create,g_aso_op_code_update)
		) OPERATION_CODE,
	 opadj.price_adj_attrib_id,	-- order price adj atribute ID
	 kpadj.id, 			-- contract price adj attribute id
         kpadj.flex_title,
         kpadj.pricing_context,
         kpadj.pricing_attribute,
         kpadj.pricing_attr_value_from,
         kpadj.pricing_attr_value_to,
         kpadj.comparison_operator
 FROM
	okc_price_adj_attribs kpadj,
	OKX_ORD_PRC_ADJ_ATRBS_V opadj
 WHERE
	b_o_flag = OKC_API.g_true
 AND	kpadj.pat_id	= b_kpat_id
 AND	opadj.price_adjustment_id(+) = b_pat_id
 AND	opadj.flex_title(+)	=kpadj.flex_title
 AND	opadj.pricing_context(+)=kpadj.pricing_context
 AND	opadj.pricing_attribute(+) = kpadj.pricing_attribute
 ORDER BY
	operation_code;



 CURSOR c_price_adj_attr(b_q_flag VARCHAR, b_o_flag VARCHAR,b_pat_id NUMBER) IS
  SELECT
	qpadj.price_adjustment_id,
	qpadj.price_adj_attrib_id,	-- quote price adj attribute id
	qpadj.flex_title,
        qpadj.pricing_context,
        qpadj.pricing_attribute,
        qpadj.pricing_attr_value_from,
        qpadj.pricing_attr_value_to,
        qpadj.comparison_operator
  FROM 	OKX_QTE_PRC_ADJ_ATRBS_V qpadj
  WHERE b_q_flag = OKC_API.g_true
  AND	qpadj.price_adjustment_id = b_pat_id

UNION

  SELECT
	opadj.price_adjustment_id,
	opadj.price_adj_attrib_id,	-- order price adj attribute id
	opadj.flex_title,
        opadj.pricing_context,
        opadj.pricing_attribute,
        opadj.pricing_attr_value_from,
        opadj.pricing_attr_value_to,
        opadj.comparison_operator
  FROM 	OKX_ORD_PRC_ADJ_ATRBS_V opadj
  WHERE b_o_flag = OKC_API.g_true
  AND	opadj.price_adjustment_id = b_pat_id;


-- variable declaration
 l_price_adj_insert	VARCHAR2(1) := OKC_API.G_TRUE;
 l_price_adj_attr_rec	ASO_QUOTE_PUB.price_adj_attr_rec_type;
 l_price_adj_attr_tab	ASO_QUOTE_PUB.price_adj_attr_tbl_type;

 x binary_integer;

BEGIN
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'-----------------------------------');
   	okc_util.print_trace(1,'>> start : Get price adj attributes ');
   	okc_util.print_trace(1,'-----------------------------------');
	END IF;

x_price_adj_attr_tab.DELETE;

l_price_adj_attr_tab.DELETE;


 x := l_price_adj_attr_tab.count;

IF x = 0 THEN
   x:=x+1;
END IF;


--
-- Print the input values to this procedure from the
-- p_k_price_adj_tab and  p_price_adj_tab
--

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'Get price adj attributes: count of p_price_adj_tab =   '||p_price_adj_tab.count);
   okc_util.print_trace(1,'Get price adj attributes: count of p_k_price_adj_tab = '||p_k_price_adj_tab.count);
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'-------------------------------------');
   okc_util.print_trace(1,' Input data from p_price_adj_tab ');
   okc_util.print_trace(1,'-------------------------------------');
END IF;

IF p_price_adj_tab.COUNT > 0 THEN
   FOR i IN p_price_adj_tab.FIRST..p_price_adj_tab.LAST LOOP
     IF (l_debug = 'Y') THEN
        okc_util.print_trace(1,'INDEX VALUE =    '||i);
        okc_util.print_trace(1,'Operation code = '||p_price_adj_tab(i).operation_code);
        okc_util.print_trace(1,'Price Adj id   = '||p_price_adj_tab(i).price_adjustment_id);
        okc_util.print_trace(1,'quote header id= '||p_price_adj_tab(i).quote_header_id);
        okc_util.print_trace(1,'quote line   id= '||p_price_adj_tab(i).quote_line_id);
     END IF;
   END LOOP;
END IF;
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'-------------------------------------');
   okc_util.print_trace(1,' Input data from p_k_price_adj_tab ');
   okc_util.print_trace(1,'-------------------------------------');
   okc_util.print_trace(1,'  ');
END IF;


 IF p_k_price_adj_tab.COUNT > 0 THEN
   FOR i IN p_k_price_adj_tab.FIRST..p_k_price_adj_tab.LAST LOOP
     IF (l_debug = 'Y') THEN
        okc_util.print_trace(1,'INDEX VALUE =  '||i);
        okc_util.print_trace(1,'Price Adj id = '||p_k_price_adj_tab(i).id);
        okc_util.print_trace(1,'Level        = '||p_k_price_adj_tab(i).level);
     END IF;
   END LOOP;
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'-------------------------------------');
   okc_util.print_trace(1,'  ');
END IF;



 IF p_k_price_adj_tab.count > 0 THEN

 IF p_k_price_adj_tab.first IS NOT NULL THEN


   FOR i in p_k_price_adj_tab.first..p_k_price_adj_tab.last LOOP
      IF p_k_price_adj_tab(i).level = p_level THEN

--
-- Fill in the l_price_adj_attr_tab variable with price adj attr to be created or updated
--
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'i = '||i);
   okc_util.print_trace(1,'1- operation_code = '||p_price_adj_tab(i).operation_code);
END IF;
    IF p_price_adj_tab(i).operation_code = g_aso_op_code_create THEN

      FOR price_adj_attr_rec IN c_k_price_adj_attr_c(p_k_price_adj_tab(i).id) LOOP
      -- populate l_price_adj_attr_rec with information from price_adj_attr_rec

	l_price_adj_attr_rec.flex_title 	:= price_adj_attr_rec.flex_title;
	l_price_adj_attr_rec.pricing_context 	:= price_adj_attr_rec.pricing_context;
	l_price_adj_attr_rec.pricing_attribute 	:= price_adj_attr_rec.pricing_attribute;
	l_price_adj_attr_rec.pricing_attr_value_from := price_adj_attr_rec.pricing_attr_value_from;
	l_price_adj_attr_rec.pricing_attr_value_to := price_adj_attr_rec.pricing_attr_value_to;
	l_price_adj_attr_rec.comparison_operator := price_adj_attr_rec.comparison_operator;

  	l_price_adj_attr_rec.operation_code := g_aso_op_code_create;
  	l_price_adj_attr_rec.price_adj_index := i;

  	l_price_adj_attr_tab(x) := l_price_adj_attr_rec;
	x:=x+1;



      END LOOP;
    END IF;

    IF p_price_adj_tab(i).operation_code = g_aso_op_code_update THEN
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'2 - operation_code = '||p_price_adj_tab(i).operation_code);
	END IF;
      FOR price_adj_attr_rec IN c_k_price_adj_attr_u(p_k_price_adj_tab(i).id,p_q_flag,p_o_flag,
							p_price_adj_tab(i).price_adjustment_id) LOOP

--   populate l_price_adj_attr_rec with information from price_adj_attr_rec

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,' 2 - populating l_price_adj_attr_rec with price_adj_attr_rec ');
   	okc_util.print_trace(1,' 2 - i.e the values from c_k_price_adj_attr_u cursor ');
	END IF;


	l_price_adj_attr_rec.operation_code := price_adj_attr_rec.operation_code;
	l_price_adj_attr_rec.flex_title 	:= price_adj_attr_rec.flex_title;
	l_price_adj_attr_rec.pricing_context 	:= price_adj_attr_rec.pricing_context;
	l_price_adj_attr_rec.pricing_attribute 	:= price_adj_attr_rec.pricing_attribute;
	l_price_adj_attr_rec.pricing_attr_value_from := price_adj_attr_rec.pricing_attr_value_from;
	l_price_adj_attr_rec.pricing_attr_value_to := price_adj_attr_rec.pricing_attr_value_to;
	l_price_adj_attr_rec.comparison_operator := price_adj_attr_rec.comparison_operator;

       	l_price_adj_attr_rec.price_adjustment_id := p_price_adj_tab(i).price_adjustment_id;

      	  IF l_price_adj_attr_rec.operation_code = g_aso_op_code_create THEN
	        IF (l_debug = 'Y') THEN
   	        okc_util.print_trace(1,'the operation code in c_k_price_adj_attr_u = '||price_adj_attr_rec.operation_code);
	        END IF;
		l_price_adj_attr_rec.price_adj_attrib_id := OKC_API.G_MISS_NUM;
	  END IF;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'2- Inserting the l_price_adj_attr_rec into the l_price_adj_attr_rec table');
       	okc_util.print_trace(1,'2- Index value for insert = '||x);
	END IF;

	l_price_adj_attr_tab(x) := l_price_adj_attr_rec;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'operation code = '||l_price_adj_attr_tab(x).operation_code);
     okc_util.print_trace(1,'price adjustment id= '||l_price_adj_attr_tab(x).price_adjustment_id);
     okc_util.print_trace(1,'flex title= '||l_price_adj_attr_tab(x).flex_title);
     okc_util.print_trace(1,'pricing context= '||l_price_adj_attr_tab(x).pricing_context);
     okc_util.print_trace(1,'pricing attribute= '||l_price_adj_attr_tab(x).pricing_attribute);
     okc_util.print_trace(1,'pricing attribute value from= '||l_price_adj_attr_tab(x).pricing_attr_value_from);
     okc_util.print_trace(1,'pricing attribute value to= '||l_price_adj_attr_tab(x).pricing_attr_value_to);
     okc_util.print_trace(1,'comparison operator= '||l_price_adj_attr_tab(x).comparison_operator);
  END IF;

	x:=x+1;

      END LOOP;

    FOR l_price_adj_attr IN c_price_adj_attr(p_q_flag,p_o_flag,p_price_adj_tab(i).price_adjustment_id) LOOP
       l_price_adj_insert := OKC_API.G_TRUE;
--
-- Need to check if the related quote price adj attribute is not already planned to be updated
-- in the l_price_adj_attr_tab variable.
--
     IF l_price_adj_attr_tab.first IS NOT NULL THEN
       FOR i IN l_price_adj_attr_tab.first..l_price_adj_attr_tab.last LOOP
  	IF l_price_adj_attr_tab(i).price_adj_attrib_id = l_price_adj_attr.price_adj_attrib_id AND
		 l_price_adj_attr_tab(i).price_adjustment_id = p_price_adj_tab(i).price_adjustment_id THEN
		 l_price_adj_insert := OKC_API.G_FALSE;
		 exit;
	END IF;
       END LOOP;
     END IF;

     IF l_price_adj_insert = OKC_API.G_TRUE THEN
-- It should be inserted, but in fact no longer valid when coming back from the contract
-- Populate l_price_adj_attr_rec with information from l_price_adj_attr.

	l_price_adj_attr_rec.price_adj_attrib_id:= l_price_adj_attr.price_adj_attrib_id;
	l_price_adj_attr_rec.flex_title 	:= l_price_adj_attr.flex_title;
	l_price_adj_attr_rec.pricing_context 	:= l_price_adj_attr.pricing_context;
	l_price_adj_attr_rec.pricing_attribute 	:= l_price_adj_attr.pricing_attribute;
	l_price_adj_attr_rec.pricing_attr_value_from := l_price_adj_attr.pricing_attr_value_from;
	l_price_adj_attr_rec.pricing_attr_value_to := l_price_adj_attr.pricing_attr_value_to;
	l_price_adj_attr_rec.comparison_operator := l_price_adj_attr.comparison_operator;

     	l_price_adj_attr_rec.operation_code := g_aso_op_code_delete;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'2 A check for delete - Inserting the l_price_adj_attr_rec ');
   	okc_util.print_trace(1,'into the l_price_adj_attr_rec table');
      	okc_util.print_trace(1,'2 A - Index value  = '||x);
	END IF;

     	l_price_adj_attr_tab(x) := l_price_adj_attr_rec;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'operation code = '||l_price_adj_attr_tab(x).operation_code);
     	okc_util.print_trace(1,'price adjustment id= '||l_price_adj_attr_tab(x).price_adjustment_id);
     	okc_util.print_trace(1,'price adj attrib id= '||l_price_adj_attr_tab(x).price_adj_attrib_id);
     	okc_util.print_trace(1,'flex title= '||l_price_adj_attr_tab(x).flex_title);
     	okc_util.print_trace(1,'pricing context= '||l_price_adj_attr_tab(x).pricing_context);
     	okc_util.print_trace(1,'pricing attribute= '||l_price_adj_attr_tab(x).pricing_attribute);
     	okc_util.print_trace(1,'pricing attribute value from= '||l_price_adj_attr_tab(x).pricing_attr_value_from);
     	okc_util.print_trace(1,'pricing attribute value to= '||l_price_adj_attr_tab(x).pricing_attr_value_to);
     	okc_util.print_trace(1,'comparison operator= '||l_price_adj_attr_tab(x).comparison_operator);
	END IF;


	x := x + 1;

     END IF;
    END LOOP;
   END IF;	-- IF p_price_adj_tab(i).operation_code = g_aso_op_code_update then..
 END IF;	-- IF p_price_adj_tab(i).level = p_level then ...
 END LOOP;
END IF;

--
-- Fill in the l_price_adj_attr_tab variable with price adj attr to be deleted
--
  IF p_price_adj_tab.first IS NOT NULL THEN
    FOR i IN p_price_adj_tab.first..p_price_adj_tab.last LOOP

  IF(p_level = 'H' AND
   p_price_adj_tab(i).quote_header_id IS NOT NULL AND
   p_price_adj_tab(i).quote_line_id IS NOT NULL)
	OR
    (p_level = 'L' AND
   p_price_adj_tab(i).quote_header_id IS NOT NULL AND
   p_price_adj_tab(i).quote_line_id IS NOT NULL)
  THEN
   IF p_price_adj_tab(i).operation_code = g_aso_op_code_delete THEN
	FOR l_price_adj_attr IN c_price_adj_attr(p_q_flag, p_o_flag,
				p_price_adj_tab(i).price_adjustment_id) LOOP

-- populate l_price_adj_attr_rec with information from l_price_adj_attr

 	l_price_adj_attr_rec.price_adjustment_id:= l_price_adj_attr.price_adjustment_id;
	l_price_adj_attr_rec.flex_title 	:= l_price_adj_attr.flex_title;
	l_price_adj_attr_rec.pricing_context 	:= l_price_adj_attr.pricing_context;
	l_price_adj_attr_rec.pricing_attribute 	:= l_price_adj_attr.pricing_attribute;
	l_price_adj_attr_rec.pricing_attr_value_from := l_price_adj_attr.pricing_attr_value_from;
	l_price_adj_attr_rec.pricing_attr_value_to := l_price_adj_attr.pricing_attr_value_to;
	l_price_adj_attr_rec.comparison_operator := l_price_adj_attr.comparison_operator;

	l_price_adj_attr_rec.operation_code := g_aso_op_code_delete;

	l_price_adj_attr_tab(x) := l_price_adj_attr_rec;
	x := x + 1;

	END LOOP;
   END IF;
 END IF;    -- IF p_level = 'H' then
 END LOOP;
END IF;
END IF;


--
-- print out information of the l_price_adj_attr_tab variable
--
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'count of l_price_adj_attr_tab is '||l_price_adj_attr_tab.count);
   okc_util.print_trace(1,'----------------------------------------------------');
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,' values from the l_price_adj_attr_tab ');
   okc_util.print_trace(1,'----------------------------------------------------');
   okc_util.print_trace(1,'  ');
END IF;


IF l_price_adj_attr_tab.first IS NOT NULL THEN
 FOR i IN l_price_adj_attr_tab.first..l_price_adj_attr_tab.last LOOP
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'Index value    = '||i);
     okc_util.print_trace(1,'operation code = '||l_price_adj_attr_tab(i).operation_code);
     okc_util.print_trace(1,'price adjustment id= '||l_price_adj_attr_tab(i).price_adjustment_id);
     okc_util.print_trace(1,'flex title= '||l_price_adj_attr_tab(i).flex_title);
     okc_util.print_trace(1,'pricing context= '||l_price_adj_attr_tab(i).pricing_context);
     okc_util.print_trace(1,'pricing attribute= '||l_price_adj_attr_tab(i).pricing_attribute);
     okc_util.print_trace(1,'pricing attribute value from= '||l_price_adj_attr_tab(i).pricing_attr_value_from);
     okc_util.print_trace(1,'pricing attribute value to= '||l_price_adj_attr_tab(i).pricing_attr_value_to);
     okc_util.print_trace(1,'comparison operator= '||l_price_adj_attr_tab(i).comparison_operator);
  END IF;
 END LOOP;
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'----------------------------------------------------');
END IF;

IF l_price_adj_attr_tab.count > 0 THEN
    FOR i IN l_price_adj_attr_tab.FIRST..l_price_adj_attr_tab.LAST LOOP
        x_price_adj_attr_tab(x_price_adj_attr_tab.COUNT+1) := l_price_adj_attr_tab(i);
    END LOOP;
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,'FINAL OUT NOCOPY VALUES FROM THE X_PRICE_ADJ_ATTR_TAB ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,'  ');
END IF;


IF x_price_adj_attr_tab.first IS NOT NULL THEN
 FOR i IN x_price_adj_attr_tab.first..x_price_adj_attr_tab.last LOOP
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'Index value    = '||i);
     okc_util.print_trace(1,'operation code = '||x_price_adj_attr_tab(i).operation_code);
     okc_util.print_trace(1,'price adjustment id= '||x_price_adj_attr_tab(i).price_adjustment_id);
     okc_util.print_trace(1,'flex title= '||x_price_adj_attr_tab(i).flex_title);
     okc_util.print_trace(1,'pricing context= '||x_price_adj_attr_tab(i).pricing_context);
     okc_util.print_trace(1,'pricing attribute= '||x_price_adj_attr_tab(i).pricing_attribute);
     okc_util.print_trace(1,'pricing attribute value from= '||x_price_adj_attr_tab(i).pricing_attr_value_from);
     okc_util.print_trace(1,'pricing attribute value to= '||x_price_adj_attr_tab(i).pricing_attr_value_to);
     okc_util.print_trace(1,'comparison operator= '||x_price_adj_attr_tab(i).comparison_operator);
     okc_util.print_trace(1,'----------------------------------------------------');
  END IF;
 END LOOP;
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'----------------------------------------------------');
END IF;

--        x_price_adj_attr_tab := l_price_adj_attr_tab;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'-----------------------------------');
   	okc_util.print_trace(1,'>> End : Get price adj attributes ');
   	okc_util.print_trace(1,'-----------------------------------');
	END IF;

EXCEPTION

WHEN OTHERS THEN

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'Inside get price adj attributes others exception handler:');
     okc_util.print_trace(1,SQLERRM);
  END IF;
         -- Bug#2320635
  OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);

 IF c_k_price_adj_attr_c%ISOPEN THEN
  CLOSE c_k_price_adj_attr_c;
 END IF;

 IF c_k_price_adj_attr_u%ISOPEN THEN
  CLOSE c_k_price_adj_attr_u;
 END IF;

 IF c_price_adj_attr%ISOPEN THEN
  CLOSE c_price_adj_attr;
 END IF;

 RAISE OKC_API.G_EXCEPTION_ERROR;

END get_price_adj_attr;


  ----------------------------------------------------------------------------
  -- PROCEDURE get_price_attr
  --
  ----------------------------------------------------------------------------

PROCEDURE get_price_attr(p_chr_id IN NUMBER,
			p_cle_id IN NUMBER,
--
			p_qhr_id IN NUMBER,
			p_qle_id IN NUMBER,
			p_q_flag IN VARCHAR2,
--
			p_ohr_id IN NUMBER,
			p_ole_id IN NUMBER,
			p_o_flag IN VARCHAR2,
--
			p_level IN VARCHAR2,

			p_nqhr_id IN NUMBER,	-- Used only for new quote line to be created
			p_nqle_idx IN NUMBER,
--
			x_price_attr_tab OUT NOCOPY ASO_QUOTE_PUB.price_attributes_tbl_type) IS


-- Cursors declaration


CURSOR c_price_attr(b_q_flag IN VARCHAR, b_qh_id NUMBER, b_ql_id NUMBER,
	 	    b_o_flag IN VARCHAR, b_oh_id NUMBER, b_ol_id NUMBER ) IS
SELECT
	qpattr.PRICE_ATTRIBUTE_ID  -- quote header price attribute id
  FROM
	OKX_QTE_PRC_ATRBS_V qpattr
  WHERE b_q_flag = OKC_API.G_TRUE
  AND   qpattr.quote_header_id = b_qh_id
  AND   (( b_ql_id IS NULL AND qpattr.quote_line_id IS NULL ) OR
		(b_ql_id IS NOT NULL AND qpattr.quote_line_id = b_ql_id ))
UNION

SELECT
	opattr.ORDER_PRICE_ATTRIB_ID  -- order header price attribute id
  FROM
	OKX_ORD_PRC_ATRBS_V opattr
  WHERE b_o_flag = OKC_API.G_TRUE
  AND   opattr.header_id = b_oh_id
  AND   (( b_ol_id IS NULL AND opattr.line_id IS NULL ) OR
		(b_ol_id IS NOT NULL AND opattr.line_id = b_ol_id ));


CURSOR c_k_price_attr(b_kh_id NUMBER,b_kl_id NUMBER) IS
  SELECT
       kpattr.flex_title,
       kpattr.pricing_context,
       kpattr.pricing_attribute1,
       kpattr.pricing_attribute2,
       kpattr.pricing_attribute3,
       kpattr.pricing_attribute4,
       kpattr.pricing_attribute5,
       kpattr.pricing_attribute6,
       kpattr.pricing_attribute7,
       kpattr.pricing_attribute8,
       kpattr.pricing_attribute9,
       kpattr.pricing_attribute10,
       kpattr.pricing_attribute11,
       kpattr.pricing_attribute12,
       kpattr.pricing_attribute13,
       kpattr.pricing_attribute14,
       kpattr.pricing_attribute15,
       kpattr.pricing_attribute16,
       kpattr.pricing_attribute17,
       kpattr.pricing_attribute18,
       kpattr.pricing_attribute19,
       kpattr.pricing_attribute20,
       kpattr.pricing_attribute21,
       kpattr.pricing_attribute22,
       kpattr.pricing_attribute23,
       kpattr.pricing_attribute24,
       kpattr.pricing_attribute25,
       kpattr.pricing_attribute26,
       kpattr.pricing_attribute27,
       kpattr.pricing_attribute28,
       kpattr.pricing_attribute29,
       kpattr.pricing_attribute30,
       kpattr.pricing_attribute31,
       kpattr.pricing_attribute32,
       kpattr.pricing_attribute33,
       kpattr.pricing_attribute34,
       kpattr.pricing_attribute35,
       kpattr.pricing_attribute36,
       kpattr.pricing_attribute37,
       kpattr.pricing_attribute38,
       kpattr.pricing_attribute39,
       kpattr.pricing_attribute40,
       kpattr.pricing_attribute41,
       kpattr.pricing_attribute42,
       kpattr.pricing_attribute43,
       kpattr.pricing_attribute44,
       kpattr.pricing_attribute45,
       kpattr.pricing_attribute46,
       kpattr.pricing_attribute47,
       kpattr.pricing_attribute48,
       kpattr.pricing_attribute49,
       kpattr.pricing_attribute50,
       kpattr.pricing_attribute51,
       kpattr.pricing_attribute52,
       kpattr.pricing_attribute53,
       kpattr.pricing_attribute54,
       kpattr.pricing_attribute55,
       kpattr.pricing_attribute56,
       kpattr.pricing_attribute57,
       kpattr.pricing_attribute58,
       kpattr.pricing_attribute59,
       kpattr.pricing_attribute60,
       kpattr.pricing_attribute61,
       kpattr.pricing_attribute62,
       kpattr.pricing_attribute63,
       kpattr.pricing_attribute64,
       kpattr.pricing_attribute65,
       kpattr.pricing_attribute66,
       kpattr.pricing_attribute67,
       kpattr.pricing_attribute68,
       kpattr.pricing_attribute69,
       kpattr.pricing_attribute70,
       kpattr.pricing_attribute71,
       kpattr.pricing_attribute72,
       kpattr.pricing_attribute73,
       kpattr.pricing_attribute74,
       kpattr.pricing_attribute75,
       kpattr.pricing_attribute76,
       kpattr.pricing_attribute77,
       kpattr.pricing_attribute78,
       kpattr.pricing_attribute79,
       kpattr.pricing_attribute80,
       kpattr.pricing_attribute81,
       kpattr.pricing_attribute82,
       kpattr.pricing_attribute83,
       kpattr.pricing_attribute84,
       kpattr.pricing_attribute85,
       kpattr.pricing_attribute86,
       kpattr.pricing_attribute87,
       kpattr.pricing_attribute88,
       kpattr.pricing_attribute89,
       kpattr.pricing_attribute90,
       kpattr.pricing_attribute91,
       kpattr.pricing_attribute92,
       kpattr.pricing_attribute93,
       kpattr.pricing_attribute94,
       kpattr.pricing_attribute95,
       kpattr.pricing_attribute96,
       kpattr.pricing_attribute97,
       kpattr.pricing_attribute98,
       kpattr.pricing_attribute99,
       kpattr.pricing_attribute100
  FROM
	okc_price_att_values kpattr
  WHERE
	kpattr.chr_id = b_kh_id
   AND
	((b_kl_id IS NULL AND kpattr.cle_id IS NULL ) OR
		(b_kl_id IS NOT  NULL AND kpattr.cle_id = b_kl_id));

-- Variables declaration

l_price_attr_rec	ASO_QUOTE_PUB.price_attributes_rec_type;
l_price_attr_tab	ASO_QUOTE_PUB.price_attributes_tbl_type;
x Binary_integer;

BEGIN

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'-------------------------------');
   	okc_util.print_trace(1,'>> start : Get price attributes ');
   	okc_util.print_trace(1,'-------------------------------');
	END IF;

x_price_attr_tab.DELETE;

l_price_attr_tab.DELETE;


x := l_price_attr_tab.count;

IF x = 0 THEN
   x:=x+1;
END IF;

--
-- Fill in the l_price_attr_tab with price attributes to be deleted.
--
 FOR l_price_attr IN c_price_attr(p_q_flag,p_qhr_id, p_qle_id,
				  p_o_flag,p_ohr_id, p_ole_id) LOOP

-- populate l_price_attr_rec with information from l_price_attr

   l_price_attr_rec.price_attribute_id 	:= l_price_attr.price_attribute_id;

   l_price_attr_rec.operation_code := g_aso_op_code_delete;
   l_price_attr_rec.quote_header_id := p_qhr_id;
   l_price_attr_rec.quote_line_id := p_qle_id;

   l_price_attr_tab(x) := l_price_attr_rec;
   x := x + 1;

 END LOOP;

--
-- Fill in the l_price_attr_tab with price attributes to be created.
--
 FOR price_attr_rec IN c_k_price_attr(p_chr_id, p_cle_id) LOOP

-- poputate l_price_attr_rec with information from price_attr_rec

   l_price_attr_rec.flex_title 		:= price_attr_rec.flex_title;
   l_price_attr_rec.pricing_context 	:= price_attr_rec.pricing_context;
   l_price_attr_rec.pricing_attribute1  := price_attr_rec.pricing_attribute1;
   l_price_attr_rec.pricing_attribute2  := price_attr_rec.pricing_attribute2;
   l_price_attr_rec.pricing_attribute3  := price_attr_rec.pricing_attribute3;
   l_price_attr_rec.pricing_attribute4  := price_attr_rec.pricing_attribute4;
   l_price_attr_rec.pricing_attribute5  := price_attr_rec.pricing_attribute5;
   l_price_attr_rec.pricing_attribute6  := price_attr_rec.pricing_attribute6;
   l_price_attr_rec.pricing_attribute7  := price_attr_rec.pricing_attribute7;
   l_price_attr_rec.pricing_attribute8  := price_attr_rec.pricing_attribute8;
   l_price_attr_rec.pricing_attribute9  := price_attr_rec.pricing_attribute9;
   l_price_attr_rec.pricing_attribute10 := price_attr_rec.pricing_attribute10;
   l_price_attr_rec.pricing_attribute11 := price_attr_rec.pricing_attribute11;
   l_price_attr_rec.pricing_attribute12 := price_attr_rec.pricing_attribute12;
   l_price_attr_rec.pricing_attribute13 := price_attr_rec.pricing_attribute13;
   l_price_attr_rec.pricing_attribute14 := price_attr_rec.pricing_attribute14;
   l_price_attr_rec.pricing_attribute15 := price_attr_rec.pricing_attribute15;
   l_price_attr_rec.pricing_attribute16 := price_attr_rec.pricing_attribute16;
   l_price_attr_rec.pricing_attribute17 := price_attr_rec.pricing_attribute17;
   l_price_attr_rec.pricing_attribute18 := price_attr_rec.pricing_attribute18;
   l_price_attr_rec.pricing_attribute19 := price_attr_rec.pricing_attribute19;
   l_price_attr_rec.pricing_attribute20 := price_attr_rec.pricing_attribute20;
   l_price_attr_rec.pricing_attribute21 := price_attr_rec.pricing_attribute21;
   l_price_attr_rec.pricing_attribute22 := price_attr_rec.pricing_attribute22;
   l_price_attr_rec.pricing_attribute23 := price_attr_rec.pricing_attribute23;
   l_price_attr_rec.pricing_attribute24 := price_attr_rec.pricing_attribute24;
   l_price_attr_rec.pricing_attribute25 := price_attr_rec.pricing_attribute25;
   l_price_attr_rec.pricing_attribute26 := price_attr_rec.pricing_attribute26;
   l_price_attr_rec.pricing_attribute27 := price_attr_rec.pricing_attribute27;
   l_price_attr_rec.pricing_attribute28 := price_attr_rec.pricing_attribute28;
   l_price_attr_rec.pricing_attribute29 := price_attr_rec.pricing_attribute29;
   l_price_attr_rec.pricing_attribute30 := price_attr_rec.pricing_attribute30;
   l_price_attr_rec.pricing_attribute31 := price_attr_rec.pricing_attribute31;
   l_price_attr_rec.pricing_attribute32 := price_attr_rec.pricing_attribute32;
   l_price_attr_rec.pricing_attribute33 := price_attr_rec.pricing_attribute33;
   l_price_attr_rec.pricing_attribute34 := price_attr_rec.pricing_attribute34;
   l_price_attr_rec.pricing_attribute35 := price_attr_rec.pricing_attribute35;
   l_price_attr_rec.pricing_attribute36 := price_attr_rec.pricing_attribute36;
   l_price_attr_rec.pricing_attribute37 := price_attr_rec.pricing_attribute37;
   l_price_attr_rec.pricing_attribute38 := price_attr_rec.pricing_attribute38;
   l_price_attr_rec.pricing_attribute39 := price_attr_rec.pricing_attribute39;
   l_price_attr_rec.pricing_attribute40 := price_attr_rec.pricing_attribute40;
   l_price_attr_rec.pricing_attribute41 := price_attr_rec.pricing_attribute41;
   l_price_attr_rec.pricing_attribute42 := price_attr_rec.pricing_attribute42;
   l_price_attr_rec.pricing_attribute43 := price_attr_rec.pricing_attribute43;
   l_price_attr_rec.pricing_attribute44 := price_attr_rec.pricing_attribute44;
   l_price_attr_rec.pricing_attribute45 := price_attr_rec.pricing_attribute45;
   l_price_attr_rec.pricing_attribute46 := price_attr_rec.pricing_attribute46;
   l_price_attr_rec.pricing_attribute47 := price_attr_rec.pricing_attribute47;
   l_price_attr_rec.pricing_attribute48 := price_attr_rec.pricing_attribute48;
   l_price_attr_rec.pricing_attribute49 := price_attr_rec.pricing_attribute49;
   l_price_attr_rec.pricing_attribute50 := price_attr_rec.pricing_attribute50;
   l_price_attr_rec.pricing_attribute51 := price_attr_rec.pricing_attribute51;
   l_price_attr_rec.pricing_attribute52 := price_attr_rec.pricing_attribute52;
   l_price_attr_rec.pricing_attribute53 := price_attr_rec.pricing_attribute53;
   l_price_attr_rec.pricing_attribute54 := price_attr_rec.pricing_attribute54;
   l_price_attr_rec.pricing_attribute55 := price_attr_rec.pricing_attribute55;
   l_price_attr_rec.pricing_attribute56 := price_attr_rec.pricing_attribute56;
   l_price_attr_rec.pricing_attribute57 := price_attr_rec.pricing_attribute57;
   l_price_attr_rec.pricing_attribute58 := price_attr_rec.pricing_attribute58;
   l_price_attr_rec.pricing_attribute59 := price_attr_rec.pricing_attribute59;
   l_price_attr_rec.pricing_attribute60 := price_attr_rec.pricing_attribute60;
   l_price_attr_rec.pricing_attribute61 := price_attr_rec.pricing_attribute61;
   l_price_attr_rec.pricing_attribute62 := price_attr_rec.pricing_attribute62;
   l_price_attr_rec.pricing_attribute63 := price_attr_rec.pricing_attribute63;
   l_price_attr_rec.pricing_attribute64 := price_attr_rec.pricing_attribute64;
   l_price_attr_rec.pricing_attribute65 := price_attr_rec.pricing_attribute65;
   l_price_attr_rec.pricing_attribute66 := price_attr_rec.pricing_attribute66;
   l_price_attr_rec.pricing_attribute67 := price_attr_rec.pricing_attribute67;
   l_price_attr_rec.pricing_attribute68 := price_attr_rec.pricing_attribute68;
   l_price_attr_rec.pricing_attribute69 := price_attr_rec.pricing_attribute69;
   l_price_attr_rec.pricing_attribute70 := price_attr_rec.pricing_attribute70;
   l_price_attr_rec.pricing_attribute71 := price_attr_rec.pricing_attribute71;
   l_price_attr_rec.pricing_attribute72 := price_attr_rec.pricing_attribute72;
   l_price_attr_rec.pricing_attribute73 := price_attr_rec.pricing_attribute73;
   l_price_attr_rec.pricing_attribute74 := price_attr_rec.pricing_attribute74;
   l_price_attr_rec.pricing_attribute75 := price_attr_rec.pricing_attribute75;
   l_price_attr_rec.pricing_attribute76 := price_attr_rec.pricing_attribute76;
   l_price_attr_rec.pricing_attribute77 := price_attr_rec.pricing_attribute77;
   l_price_attr_rec.pricing_attribute78 := price_attr_rec.pricing_attribute78;
   l_price_attr_rec.pricing_attribute79 := price_attr_rec.pricing_attribute79;
   l_price_attr_rec.pricing_attribute80 := price_attr_rec.pricing_attribute80;
   l_price_attr_rec.pricing_attribute81 := price_attr_rec.pricing_attribute81;
   l_price_attr_rec.pricing_attribute82 := price_attr_rec.pricing_attribute82;
   l_price_attr_rec.pricing_attribute83 := price_attr_rec.pricing_attribute83;
   l_price_attr_rec.pricing_attribute84 := price_attr_rec.pricing_attribute84;
   l_price_attr_rec.pricing_attribute85 := price_attr_rec.pricing_attribute85;
   l_price_attr_rec.pricing_attribute86 := price_attr_rec.pricing_attribute86;
   l_price_attr_rec.pricing_attribute87 := price_attr_rec.pricing_attribute87;
   l_price_attr_rec.pricing_attribute88 := price_attr_rec.pricing_attribute88;
   l_price_attr_rec.pricing_attribute89 := price_attr_rec.pricing_attribute89;
   l_price_attr_rec.pricing_attribute90 := price_attr_rec.pricing_attribute90;
   l_price_attr_rec.pricing_attribute91 := price_attr_rec.pricing_attribute91;
   l_price_attr_rec.pricing_attribute92 := price_attr_rec.pricing_attribute92;
   l_price_attr_rec.pricing_attribute93 := price_attr_rec.pricing_attribute93;
   l_price_attr_rec.pricing_attribute94 := price_attr_rec.pricing_attribute94;
   l_price_attr_rec.pricing_attribute95 := price_attr_rec.pricing_attribute95;
   l_price_attr_rec.pricing_attribute96 := price_attr_rec.pricing_attribute96;
   l_price_attr_rec.pricing_attribute97 := price_attr_rec.pricing_attribute97;
   l_price_attr_rec.pricing_attribute98 := price_attr_rec.pricing_attribute98;
   l_price_attr_rec.pricing_attribute99 := price_attr_rec.pricing_attribute99;
   l_price_attr_rec.pricing_attribute100:= price_attr_rec.pricing_attribute100;

   l_price_attr_rec.operation_code := g_aso_op_code_create;
   l_price_attr_rec.quote_header_id := p_qhr_id;
   l_price_attr_rec.quote_line_id := p_qle_id;

   IF p_level = 'L' AND p_qhr_id IS NULL THEN  -- related quote line has to be created

	l_price_attr_rec.quote_header_id := p_nqhr_id;
	l_price_attr_rec.qte_line_index  := p_nqle_idx;

   END IF;

        l_price_attr_tab(x) := l_price_attr_rec;
	x := x + 1;

 END LOOP;

--
-- print out information of the l_price_attr_variable
--


	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,' Count of l_price_attr_tab = '||l_price_attr_tab.COUNT);
	END IF;

   IF l_price_attr_tab.COUNT > 0 THEN
	FOR i IN l_price_attr_tab.FIRST..l_price_attr_tab.LAST LOOP

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,' l_price_attr_tab record '||i);
   	okc_util.print_trace(1,' ');
   	okc_util.print_trace(1,'operation code      = '||l_price_attr_tab(i).operation_code);
   	okc_util.print_trace(1,'price attribute id  = '||l_price_attr_tab(i).price_attribute_id);
   	okc_util.print_trace(1,'quote header id     = '||l_price_attr_tab(i).quote_header_id);
   	okc_util.print_trace(1,'quote line id       = '||l_price_attr_tab(i).quote_line_id);
   	okc_util.print_trace(1,'qte line index      = '||l_price_attr_tab(i).qte_line_index);
   	okc_util.print_trace(1,'flex title          = '||l_price_attr_tab(i).flex_title);
   	okc_util.print_trace(1,'Pricing context     = '||l_price_attr_tab(i).pricing_context);
	END IF;

	END LOOP;
   END IF;


IF l_price_attr_tab.COUNT > 0 THEN
	FOR i IN l_price_attr_tab.FIRST..l_price_attr_tab.LAST LOOP
		x_price_attr_tab(x_price_attr_tab.COUNT+1) := l_price_attr_tab(i);
	END LOOP;
END IF;

--	x_price_attr_tab := l_price_attr_tab;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'-------------------------------');
   	okc_util.print_trace(1,'>> End : Get price attributes ');
   	okc_util.print_trace(1,'-------------------------------');
	END IF;

EXCEPTION

WHEN OTHERS THEN

         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3,SQLERRM);
         END IF;
         -- Bug#2320635
  OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);

 IF c_k_price_attr%ISOPEN THEN
  CLOSE c_k_price_attr;
 END IF;

 IF c_price_attr%ISOPEN THEN
  CLOSE c_price_attr;
 END IF;

 RAISE OKC_API.G_EXCEPTION_ERROR;


END; 	-- get_price_attr


  ----------------------------------------------------------------------------
  -- PROCEDURE get_price_adj_rltship
  --
  ----------------------------------------------------------------------------

PROCEDURE get_price_adj_rltship (  p_price_adj_tab  	IN ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
				   p_k_price_adj_tab 	IN k_price_adj_tab_type,
				--
				   p_line_tab 		IN ASO_QUOTE_PUB.qte_line_tbl_type,
				   p_kl_rel_tab 	IN okc_oc_int_config_pvt.line_rel_tab_type,
				   p_line_shipment_tab 	IN ASO_QUOTE_PUB.shipment_tbl_type,
				--
				   p_q_flag 		IN VARCHAR2,
				   p_o_flag 		IN VARCHAR2,
				   p_level 		IN VARCHAR2,
				--
 				   x_price_adj_rltship_tab  OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type) IS
--
-- Cursors declaration
--

CURSOR c_k_price_adj_rltship (b_kpat_id NUMBER) IS
 SELECT pat_id_from,
	cle_id,
	pat_id
 FROM  OKC_PRICE_ADJ_ASSOCS  kpadj
 WHERE kpadj.pat_id_from  = b_kpat_id;

--
--

CURSOR c_price_adj_rltship_rltd(b_q_flag VARCHAR, b_o_flag VARCHAR, b_pat_id NUMBER)   IS
 SELECT
	qpadj.ADJ_RELATIONSHIP_ID, --quote or order price adj rltship ID
 	qpadj.price_adjustment_id   PRICE_ADJUSTMENT_ID,
	qpadj.quote_shipment_id  SHIPMENT_ID,
	qpadj.quote_line_id      LINE_ID
 FROM   OKX_QTE_PRC_ADJ_RLSHP_V    qpadj
 WHERE b_q_flag = OKC_API.g_true
  AND  qpadj.rltd_price_adj_id = b_pat_id

UNION

 SELECT
	opadj.PRICE_ADJ_ASSOC_ID,  -- PRICE_ADJ_ASSOC_ID,  --  quote price adj rltship ID
	opadj.price_adjustment_id,
	to_number(NULL),        --qpadj.quote_shipment_id
	opadj.line_id
 FROM   OKX_ORD_PRC_ADJ_RLSHP_V    opadj
 WHERE  b_o_flag = OKC_API.g_true
 AND    opadj.rltd_price_adj_id = b_pat_id;


--
--

CURSOR  c_price_adj_rltship(b_q_flag VARCHAR, b_o_flag VARCHAR2, b_pat_id NUMBER, b_ln_id NUMBER)   IS
 SELECT
	qpadj.ADJ_RELATIONSHIP_ID, -- quote or order price adj rltship ID
	qpadj.price_adjustment_id PRICE_ADJUSTMENT_ID,
	qpadj.quote_shipment_id  SHIPMENT_ID,
	qpadj.quote_line_id  LINE_ID,
 	qpadj.rltd_price_adj_id
 FROM   OKX_QTE_PRC_ADJ_RLSHP_V   qpadj
 WHERE 	b_q_flag = OKC_API.g_true
 AND	qpadj.price_adjustment_id = b_pat_id
 AND	((b_ln_id IS NOT NULL AND qpadj.quote_line_id  = b_ln_id) OR b_ln_id IS NULL)

UNION

 SELECT opadj.PRICE_ADJ_ASSOC_ID, -- quote price adj rltship ID
	opadj.price_adjustment_id,
	to_number(NULL),        --qpadj.quote_shipment_id
	opadj.line_id,
	opadj.rltd_price_adj_id
 FROM   OKX_ORD_PRC_ADJ_RLSHP_V    opadj
 WHERE 	b_o_flag = OKC_API.g_true
 AND   	opadj.price_adjustment_id = b_pat_id
 AND   ((b_ln_id IS NOT NULL AND opadj.line_id  = b_ln_id) OR b_ln_id IS NULL);


--
-- Variables declaration
--
l_ql		INTEGER;
l_qs		INTEGER;
l_kpat		INTEGER;
l_shipment 	VARCHAR2(1);
l_kl_id		okc_k_lines_b.id%TYPE;

v_price_adj_rltship 	c_price_adj_rltship%ROWTYPE;
l_price_adj_rltship 	c_price_adj_rltship%ROWTYPE;
l_price_adj_insert	VARCHAR2(1) := OKC_API.G_TRUE;

l_price_adj_rltship_rec		ASO_QUOTE_PUB.price_adj_rltship_rec_type;
l_price_adj_rltship_tab		ASO_QUOTE_PUB.price_adj_rltship_tbl_type;

x binary_integer;

BEGIN

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'---------------------------------------------');
   	okc_util.print_trace(1,'>> start : Get price adjustment relationship ');
   	okc_util.print_trace(1,'---------------------------------------------');
	END IF;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'p_k_price_adj_tab count '||p_k_price_adj_tab.count);
   okc_util.print_trace(1,'p_price_adj_tab count '||p_price_adj_tab.count);
END IF;

x_price_adj_rltship_tab.DELETE;

l_price_adj_rltship_tab.DELETE;

x := l_price_adj_rltship_tab.count;

IF x = 0 THEN
   x:=x+1;
END IF;

IF p_k_price_adj_tab.count <> 0 THEN

IF p_k_price_adj_tab IS NOT NULL THEN
  FOR i IN p_k_price_adj_tab.first..p_k_price_adj_tab.last LOOP
    IF p_k_price_adj_tab(i).level = p_level THEN
--
-- Fill in the l_price_adj_rltship_tab variable with price relationship
-- to be created or updated
--
 IF p_price_adj_tab(i).operation_code = g_aso_op_code_create THEN
  FOR price_adj_rltship_rec IN c_k_price_adj_rltship(p_k_price_adj_tab(i).id) LOOP
   l_price_adj_rltship_rec.operation_code := g_aso_op_code_create;
   l_price_adj_rltship_rec.price_adj_index := i;

-- Need to check up on the operation code of each related quote line
-- At this level, there is a relationship between a price adj and a valid contract line id, therefore
-- if the related quote line id cannot be found (quote line id or index), an exception must be raised.


-- Process associated contract line id
  IF price_adj_rltship_rec.cle_id IS NOT NULL THEN
   l_price_adj_insert := okc_api.g_false;
   IF p_kl_rel_tab.FIRST IS NOT NULL THEN
     l_ql := 0;
     FOR j IN p_kl_rel_tab.FIRST..p_kl_rel_tab.LAST LOOP
       IF p_kl_rel_tab(j).k_line_id = price_adj_rltship_rec.cle_id THEN
	 l_price_adj_insert := okc_api.g_true;
	 l_ql:= p_kl_rel_tab(j).q_line_idx;
	 l_kl_id := p_kl_rel_tab(j).k_line_id; -- Bug 2543112
	 EXIT;
       END IF;
     END LOOP;
   END IF;


   IF l_price_adj_insert  = okc_api.g_true THEN
      IF p_line_tab(l_ql).operation_code = g_aso_op_code_create THEN
         l_price_adj_rltship_rec.qte_line_index:=l_ql; -- p_line_tab(l_ql).line_number
      ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_update THEN
	 l_price_adj_rltship_rec.quote_line_id:= p_line_tab(l_ql).quote_line_id;
      ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_delete THEN

	 --set a specific error message, print it out and raise an exception

	 OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL1',
                          p_token1        => 'KLINEID',
                          p_token1_value  => l_kl_id);
            print_error(4);
         RAISE e_exit;

      END IF;
   ELSE

     --set a specific error message, print it out and raise an exception

	 OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL2',
                          p_token1        => 'PRICEADJID',
                          p_token1_value  => price_adj_rltship_rec.pat_id );
            print_error(4);
         RAISE e_exit;


   END IF;
 END IF; --IF price_adj_rltship_rec.cle_id IS NOT NULL THEN

--Process associated price adjustment id
 IF price_adj_rltship_rec.pat_id IS NOT NULL THEN
  l_price_adj_insert := okc_api.g_false;
  l_kpat:=0;
  FOR k in p_k_price_adj_tab.first .. p_k_price_adj_tab.last LOOP
   IF p_k_price_adj_tab(k).id = price_adj_rltship_rec.pat_id THEN
    l_price_adj_insert := okc_api.g_true;
    l_kpat:=k;
    EXIT;
   END IF;
  END LOOP;
    IF l_price_adj_insert  = okc_api.g_true THEN
      IF p_price_adj_tab(l_kpat).operation_code = g_aso_op_code_create THEN
	l_price_adj_rltship_rec.rltd_price_adj_index:=l_kpat;
      ELSIF p_price_adj_tab(l_kpat).operation_code = g_aso_op_code_update THEN
	l_price_adj_rltship_rec.rltd_price_adj_id:= p_price_adj_tab(l_kpat).price_adjustment_id;
      ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_delete THEN
	--set a specific error message, print it out and raise an exception

	 OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL3',
                          p_token1        => 'PRICEADJID',
                          p_token1_value  => price_adj_rltship_rec.pat_id );
            print_error(4);
         RAISE e_exit;

      END IF;
    ELSE
	--set a specific error message, print it out and raise an exception

	 OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL4',
                          p_token1        => 'KLINEID',
                          p_token1_value  =>  l_kl_id);
            print_error(4);
         RAISE e_exit;


    END IF;
 END IF;  --IF price_adj_rltship_rec.pat_id IS NOT NULL THEN

  l_price_adj_rltship_tab(x) := l_price_adj_rltship_rec;
  x := x +1;

 END LOOP;
END IF; -- IF p_price_adj_tab(i).operation_code = g_aso_op_code_create THEN


  IF p_price_adj_tab(i).operation_code = g_aso_op_code_update THEN
    FOR price_adj_rltship_rec IN c_k_price_adj_rltship (p_k_price_adj_tab(i).id) LOOP

-- Need to check up on the operation code of each related quote line
-- At this level, there is a relationship between a price adj and a valid contract line id, therefore
-- if the related quote line id cannot be found (quote line id or index), an exception must be raised.
--
       IF price_adj_rltship_rec.cle_id IS NOT NULL THEN
	 l_price_adj_insert := okc_api.g_false;
	  IF p_kl_rel_tab.FIRST  is NOT NULL THEN
	   l_ql := 0;
	    FOR j IN p_kl_rel_tab.FIRST .. p_kl_rel_tab.LAST LOOP
	      IF p_kl_rel_tab(j).k_line_id = price_adj_rltship_rec.cle_id THEN
		l_price_adj_insert := okc_api.g_true;
		l_ql:= p_kl_rel_tab(j).q_line_idx;
		EXIT;
	      END IF;
	    END LOOP;
	   END IF;

	 IF l_price_adj_insert  = okc_api.g_true THEN

	  IF p_line_tab(l_ql).operation_code = g_aso_op_code_create THEN
	     l_price_adj_rltship_rec.operation_code := g_aso_op_code_create;
	     l_price_adj_rltship_rec.price_adjustment_id := p_price_adj_tab(i).price_adjustment_id;
	    l_price_adj_rltship_rec.qte_line_index:=l_ql;

	  ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_update THEN
	     --Need to check if the related quote line id is associated to the quote price adj id
	    OPEN c_price_adj_rltship(p_q_flag, p_o_flag,
		p_price_adj_tab(i).price_adjustment_id, p_line_tab(l_ql).quote_line_id);
	    FETCH c_price_adj_rltship INTO v_price_adj_rltship;
	    CLOSE c_price_adj_rltship;

	    IF c_price_adj_rltship%NOTFOUND THEN
	      l_price_adj_rltship_rec.operation_code := g_aso_op_code_create;
	      l_price_adj_rltship_rec.price_adjustment_id := p_price_adj_tab(i).price_adjustment_id;
	      l_price_adj_rltship_rec.quote_line_id:= p_line_tab(l_ql).quote_line_id;
	    ELSE  -- NEED to UPDATE OR NOT with shipment id?
	      -- Need to check if the quote adj rltship involves a shipment id
	      IF v_price_adj_rltship.shipment_id IS NOT NULL THEN
	    --    Need to check if we have a shipment line for the related quote line id
		  l_shipment := okc_api.g_false;
		IF p_line_shipment_tab.FIRST IS NOT NULL THEN
		  FOR k IN p_line_shipment_tab.FIRST..p_line_shipment_tab.LAST LOOP
		    IF p_line_shipment_tab(k).quote_header_id = p_line_tab(l_ql).quote_header_id AND
			 p_line_shipment_tab(k).quote_line_id = p_line_tab(l_ql).quote_line_id THEN
		       l_shipment:=okc_api.g_true;
			l_qs := k;
		       EXIT;
		    END IF;
                  END LOOP;
	        END IF;

		IF l_shipment = okc_api.g_false THEN
	 		--  set an error on the stack, print it out and raise an exception

	 		OKC_API.set_message(p_app_name   => g_app_name,
                          	p_msg_name      => 'OKO_PRC_PADJREL5',
                          	p_token1        => 'QLINEID',
                          	p_token1_value  => p_line_tab(l_ql).quote_line_id);
            		print_error(4);
         		RAISE e_exit;

		 ELSE
		  IF p_line_shipment_tab(l_qs).operation_code = g_aso_op_code_update THEN
		   l_price_adj_rltship_rec.operation_code := g_aso_op_code_update;
		   l_price_adj_rltship_rec.adj_relationship_id := v_price_adj_rltship.adj_relationship_id;
		   l_price_adj_rltship_rec.price_adjustment_id := p_price_adj_tab(i).price_adjustment_id;
		   l_price_adj_rltship_rec.quote_line_id:= p_line_tab(l_ql).quote_line_id;
			-- And we keep the same shipment id which is planned to be updated
		  ELSIF p_line_shipment_tab(l_qs).operation_code = g_aso_op_code_delete THEN
		    l_price_adj_rltship_rec.operation_code := g_aso_op_code_update;
		    l_price_adj_rltship_rec.adj_relationship_id := v_price_adj_rltship.adj_relationship_id;
		    l_price_adj_rltship_rec.price_adjustment_id := p_price_adj_tab(i).price_adjustment_id;
		    l_price_adj_rltship_rec.quote_line_id:= p_line_tab(l_ql).quote_line_id;
		    l_price_adj_rltship_rec.quote_shipment_id:= NULL;
		  END IF;
		 END IF;
		ELSE
		 --Even if we have a contract shipment line id, we cannot decide to attach it to the price adj id
		   l_price_adj_rltship_rec.operation_code := g_aso_op_code_update;
		   l_price_adj_rltship_rec.adj_relationship_id := v_price_adj_rltship.adj_relationship_id;
		   l_price_adj_rltship_rec.price_adjustment_id := p_price_adj_tab(i).price_adjustment_id;
		   l_price_adj_rltship_rec.quote_line_id:= p_line_tab(l_ql).quote_line_id;
		END IF;
	       END IF;

	     ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_delete THEN
		--set a specific error message, print it out and raise an exception

		         OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL6');
            print_error(4);
         RAISE e_exit;


	 END IF; -- ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_update THEN

      ELSE
	--set a specific error message, print it out and raise an exception

         OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL7',
                          p_token1        => 'KLINEID',
                          p_token1_value  => price_adj_rltship_rec.cle_id);
            print_error(4);
         RAISE e_exit;


     END IF;  -- IF l_price_adj_insert  = okc_api.g_true THEN
    END IF;  --IF price_adj_rltship_rec.cle_id IS NOT NULL THEN

    --Process associated price adjustement id
     IF price_adj_rltship_rec.pat_id IS NOT NULL THEN
	 l_price_adj_insert := okc_api.g_false;
	 l_kpat:=0;
	  FOR k in p_k_price_adj_tab.first .. p_k_price_adj_tab.last LOOP
	    IF p_k_price_adj_tab(k).id = price_adj_rltship_rec.pat_id THEN
		l_price_adj_insert := okc_api.g_true;
		l_kpat:=k;
	        EXIT;
	    END IF;
	  END LOOP;
	IF l_price_adj_insert  = okc_api.g_true THEN
	 IF p_price_adj_tab(l_kpat).operation_code = g_aso_op_code_create THEN
	   l_price_adj_rltship_rec.rltd_price_adj_index:=l_kpat;
	 ELSIF p_price_adj_tab(l_kpat).operation_code = g_aso_op_code_update THEN
	    l_price_adj_rltship_rec.rltd_price_adj_id:= p_price_adj_tab(l_kpat).price_adjustment_id;
	 ELSIF p_line_tab(l_ql).operation_code = g_aso_op_code_delete THEN
	   --set a specific error message, print it out and raise an exception

         OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL8',
                          p_token1        => 'PRICEADJID',
                          p_token1_value  => price_adj_rltship_rec.pat_id );
            print_error(4);
         RAISE e_exit;

	 END IF;
	ELSE
	    --set a specific error message, print it out and raise an exception

         OKC_API.set_message(p_app_name   => g_app_name,
                          p_msg_name      => 'OKO_PRC_PADJREL9',
                          p_token1        => 'KLINEID',
                          p_token1_value  => price_adj_rltship_rec.cle_id);
            print_error(4);
         RAISE e_exit;


	END IF;
      END IF; --IF price_adj_rltship_rec.pat_id IS NOT NULL THEN

	l_price_adj_rltship_tab(x) := l_price_adj_rltship_rec;
	x := x+1;

   END LOOP;
   FOR l_price_adj_rltship IN c_price_adj_rltship(p_q_flag, p_o_flag,
				p_price_adj_tab(i).price_adjustment_id, NULL) LOOP
    l_price_adj_insert:=okc_api.g_true;
    -- Need to check if the related quote price adj rltship is not already planned to
    -- be updated in the l_price_adj_rltship_tab variable

	IF l_price_adj_rltship_tab.first IS NOT NULL THEN
	  FOR i in l_price_adj_rltship_tab.first..l_price_adj_rltship_tab.last LOOP
	    IF (l_price_adj_rltship_tab(i).adj_relationship_id = l_price_adj_rltship.adj_relationship_id           AND
	       l_price_adj_rltship_tab(i).price_adjustment_id = l_price_adj_rltship.price_adjustment_id            AND
	       (l_price_adj_rltship_tab(i).quote_line_id= l_price_adj_rltship.line_id  OR
	       (l_price_adj_rltship_tab(i).quote_line_id IS NULL AND l_price_adj_rltship.line_id IS NULL))         AND
	       (l_price_adj_rltship_tab(i).quote_shipment_id= l_price_adj_rltship.shipment_id  OR
	       (l_price_adj_rltship_tab(i).quote_shipment_id IS NULL AND l_price_adj_rltship.shipment_id IS NULL)) AND
	       (l_price_adj_rltship_tab(i).rltd_price_adj_id= l_price_adj_rltship.rltd_price_adj_id  OR
	       (l_price_adj_rltship_tab(i).rltd_price_adj_id IS NULL AND l_price_adj_rltship.rltd_price_adj_id IS NULL)))
            THEN
	       l_price_adj_insert:=okc_api.g_false;
	       EXIT;
	    END IF;
          END LOOP;
        END IF;

	IF l_price_adj_insert=okc_api.g_true THEN
--	   populate l_price_adj_rltship_rec with information from l_price_adj_rltship
----
	   l_price_adj_rltship_rec.adj_relationship_id := l_price_adj_rltship.adj_relationship_id;
	   l_price_adj_rltship_rec.quote_line_id       := l_price_adj_rltship.line_id;
	   l_price_adj_rltship_rec.quote_shipment_id   := l_price_adj_rltship.shipment_id;
	   l_price_adj_rltship_rec.price_adjustment_id := l_price_adj_rltship.price_adjustment_id;

	   l_price_adj_rltship_rec.operation_code := g_aso_op_code_delete;

	   l_price_adj_rltship_tab(x) := l_price_adj_rltship_rec;
	   x := x +1;

	END IF;
      END LOOP;
     END IF; -- IF p_price_adj_tab(i).operation_code = g_aso_op_code_update THEN
    END IF; --IF p_k_price_adj_tab(i).level = p_level THEN
   END LOOP; -- FOR i IN p_k_price_adj_tab.FIRST
 END IF;  -- IF p_k_price_adj_tab.FIRST IS NOT NULL

END IF;   -- IF p_k_price_adj_tab.count <> 0

--
-- Fill in the l_price_adj_rltship_tab variable with price adj rltship to be deleted
--

  IF p_price_adj_tab.first IS NOT NULL THEN

    FOR i in p_price_adj_tab.first .. p_price_adj_tab.last LOOP

	IF  (p_level = 'H' AND
	     p_price_adj_tab(i).quote_header_id IS NOT NULL AND
	     p_price_adj_tab(i).quote_line_id IS  NULL)
			OR
	     (p_level ='L' AND
	     p_price_adj_tab(i).quote_header_id IS NOT NULL AND
	     p_price_adj_tab(i).quote_line_id IS  NOT NULL)
	THEN


	    IF p_price_adj_tab(i).operation_code = g_aso_op_code_delete THEN

	   --Delete all relationships pertaining directly to this quote price adj

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'p_price_adj_tab - price_adjustment_id '||p_price_adj_tab(i).price_adjustment_id);
END IF;

	       FOR  l_price_adj_rltship IN c_price_adj_rltship (p_q_flag,p_o_flag,
					p_price_adj_tab(i).price_adjustment_id,to_number(NULL)) LOOP
----	         populate l_price_adj_rltship_rec with information from l_price_adj_rltship

	   	 l_price_adj_rltship_rec.adj_relationship_id := l_price_adj_rltship.adj_relationship_id;
	   	 l_price_adj_rltship_rec.quote_line_id       := l_price_adj_rltship.line_id;
	   	 l_price_adj_rltship_rec.quote_shipment_id   := l_price_adj_rltship.shipment_id;
	   	 l_price_adj_rltship_rec.price_adjustment_id := l_price_adj_rltship.price_adjustment_id;

	         l_price_adj_rltship_rec.operation_code := g_aso_op_code_delete;

	         l_price_adj_rltship_tab(x) := l_price_adj_rltship_rec;
		 x := x+1;

	       END LOOP;

--	Update all relationships pertaining indirectly to this quote price adj refered as rltd_price_adj_id
--
	       FOR  l_price_adj_rltship IN c_price_adj_rltship_rltd (p_q_flag, p_o_flag,
		 p_price_adj_tab(i).price_adjustment_id ) LOOP
----		 populate l_price_adj_rltship_rec with information from l_price_adj_rltship

	   	 l_price_adj_rltship_rec.adj_relationship_id := l_price_adj_rltship.adj_relationship_id;
	   	 l_price_adj_rltship_rec.quote_line_id       := l_price_adj_rltship.line_id;
	   	 l_price_adj_rltship_rec.quote_shipment_id   := l_price_adj_rltship.shipment_id;
	   	 l_price_adj_rltship_rec.price_adjustment_id := l_price_adj_rltship.price_adjustment_id;

		 l_price_adj_rltship_rec.operation_code := g_aso_op_code_update;
		 l_price_adj_rltship_rec.rltd_price_adj_id := to_number(NULL);

		 l_price_adj_rltship_tab(x) := l_price_adj_rltship_rec;
		 x := x + 1;

	       END LOOP;
	     END IF;
	END IF;
    END LOOP;
  END IF;

--
-- Print out the main information of the l_price_adj_rltship_tab variable
--

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,' Count of l_price_adj_rltship_tab = '||l_price_adj_rltship_tab.COUNT);
	END IF;

   IF l_price_adj_rltship_tab.COUNT > 0 THEN
	FOR i IN l_price_adj_rltship_tab.FIRST..l_price_adj_rltship_tab.LAST LOOP

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,' l_price_adj_rltship_tab record '||i);
   	okc_util.print_trace(1,' ');
   	okc_util.print_trace(1,'operation code      = '||l_price_adj_rltship_tab(i).operation_code);
   	okc_util.print_trace(1,'price adjustment id = '||l_price_adj_rltship_tab(i).price_adjustment_id);
   	okc_util.print_trace(1,'quote line id       = '||l_price_adj_rltship_tab(i).quote_line_id);
   	okc_util.print_trace(1,'qte line index      = '||l_price_adj_rltship_tab(i).qte_line_index);
   	okc_util.print_trace(1,'quote shipment id   = '||l_price_adj_rltship_tab(i).quote_shipment_id);
   	okc_util.print_trace(1,'rltd price adj id   = '||l_price_adj_rltship_tab(i).rltd_price_adj_id);
	END IF;

	END LOOP;
   END IF;


IF l_price_adj_rltship_tab.COUNT > 0 THEN
	FOR i IN l_price_adj_rltship_tab.FIRST..l_price_adj_rltship_tab.LAST LOOP
		x_price_adj_rltship_tab(x_price_adj_rltship_tab.COUNT+1):=l_price_adj_rltship_tab(i);
	END LOOP;
END IF;

--	x_price_adj_rltship_tab:=l_price_adj_rltship_tab;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'---------------------------------------------');
   	okc_util.print_trace(1,'>>   End : Get price adjustment relationship ');
   	okc_util.print_trace(1,'---------------------------------------------');
	END IF;

EXCEPTION

WHEN e_exit THEN
         -- Bug#2320635
  OKC_API.set_message(G_APP_NAME,
                        G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,
                        SQLCODE,
                        G_SQLERRM_TOKEN,
                        SQLERRM);
  IF c_k_price_adj_rltship%ISOPEN THEN
	CLOSE c_k_price_adj_rltship;
  END IF;

  IF c_price_adj_rltship_rltd%ISOPEN THEN
	CLOSE c_k_price_adj_rltship;
  END IF;

  RAISE OKC_API.G_EXCEPTION_ERROR;

END; -- get_price_adj_rltship



-----------------------------------------------------------------------------------------
-- procedure build_pricing_from_k
-----------------------------------------------------------------------------------------

-- Notes for the impact of configuration items on Pricing information
-- for k->Q update and K->O creation.
--
--	Quote			Contract
--	-----			--------
--	QL1 <----------------   KL1	   Top Model line (Contains sales credit, rule info)
--	      |______________    |__KSL1   Top Base line  (Contains Price adjustment info)
--				    |
--	QL2 <----------------	    |- KSL1.1  Config	  (Contains Price adjustment info)
--	QL3 <----------------	    |_ KSL1.2  Config	  (Contains Price adjustment info)
--
-- The Top model line and the Top base line information is stored into the same
-- quote line as shown above and when the relationship PL/SQL table is constructed
-- the first relationship between KL1 and QL1 is overwritten by the second
-- relationship. Therefore the line id that is against the QL1 is the id
-- of the top base line.So there is no impact of configuration items on
-- Pricing information because all the information is available
--


PROCEDURE build_pricing_from_k(
        p_chr_id           IN  OKC_K_HEADERS_B.id%TYPE,
        p_kl_rel_tab       IN  okc_oc_int_config_pvt.line_rel_tab_type ,
     --
        p_q_flag           IN  VARCHAR2                             ,
        p_qhr_id           IN  OKX_QUOTE_HEADERS_V.id1%TYPE         ,
        p_qle_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      ,
        p_qle_shipment_tab IN  ASO_QUOTE_PUB.shipment_tbl_type      ,
     --
        p_o_flag           IN  VARCHAR2                             ,
        p_ohr_id           IN  OKX_ORDER_HEADERS_V.id1%TYPE         ,
        p_ole_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      ,
        p_ole_shipment_tab IN  ASO_QUOTE_PUB.shipment_tbl_type      ,
     --
        x_hd_price_adj_tab              OUT NOCOPY ASO_QUOTE_PUB.price_adj_tbl_type,
        x_ln_price_adj_tab              OUT NOCOPY ASO_QUOTE_PUB.price_adj_tbl_type,
        x_hd_price_adj_attr_tab         OUT NOCOPY ASO_QUOTE_PUB.price_adj_attr_tbl_type,
        x_ln_price_adj_attr_tab         OUT NOCOPY ASO_QUOTE_PUB.price_adj_attr_tbl_type,
        x_hd_price_attr_tab             OUT NOCOPY ASO_QUOTE_PUB.price_attributes_tbl_type,
        x_ln_price_attr_tab             OUT NOCOPY ASO_QUOTE_PUB.price_attributes_tbl_type,
        x_hd_price_adj_rltship_tab      OUT NOCOPY ASO_QUOTE_PUB.price_adj_rltship_tbl_type,
        x_ln_price_adj_rltship_tab      OUT NOCOPY ASO_QUOTE_PUB.price_adj_rltship_tbl_type,
     --
        x_return_status                 OUT NOCOPY  VARCHAR2 ) IS

 k BINARY_INTEGER;
 x_ln_tmp_price_adj_tab              ASO_QUOTE_PUB.price_adj_tbl_type;
 x_ln_tmp_price_attr_tab             ASO_QUOTE_PUB.price_attributes_tbl_type;
 l_k_temp_price_adj_tab		     k_price_adj_tab_type;

BEGIN
  --
  -- Delete pl/sql tables, so that they are not reused
  -- when a connection is used by another client
  --
  -- housekeeping
  --
  l_line_tab.DELETE;
  l_line_shipment_tab.DELETE;
  l_k_price_adj_tab.DELETE;
  l_k_temp_price_adj_tab.DELETE;

  x_ln_tmp_price_adj_tab.DELETE;
  x_ln_tmp_price_attr_tab.DELETE;

  x_hd_price_adj_tab.DELETE;
  x_ln_price_adj_tab.DELETE;
  x_hd_price_adj_attr_tab.DELETE;
  x_ln_price_adj_attr_tab.DELETE;
  x_hd_price_attr_tab.DELETE;
  x_ln_price_attr_tab.DELETE;
  x_hd_price_adj_rltship_tab.DELETE;
  x_ln_price_adj_rltship_tab.DELETE;

  IF p_q_flag = OKC_API.g_true THEN
	l_line_tab:=p_qle_tab;
	l_line_shipment_tab:=p_qle_shipment_tab;
  ELSIF p_o_flag = OKC_API.g_true THEN
	l_line_tab:=p_ole_tab;
	l_line_shipment_tab:=p_ole_shipment_tab;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


----------------------------------------------------------
-- Select pricing information at the contract header level
----------------------------------------------------------

--
-- Get the price adjustments into the x_hd_price_adj_tab variable
--
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=============================================');
     okc_util.print_trace(1,'START : GET PRICE ADJUSTMENTS AT HEADER LEVEL');
     okc_util.print_trace(1,'=============================================');
  END IF;

  get_price_adj(p_chr_id => p_chr_id,
                        p_cle_id   => NULL,
                --
                        p_qhr_id   => p_qhr_id,
                        p_qle_id   => NULL,
                        p_q_flag   => p_q_flag,
                --
                        p_ohr_id   => p_ohr_id,
                        p_ole_id   => NULL,
                        p_o_flag   => p_o_flag,
                --
                        p_level    => 'H',
                --
                        p_nqhr_id  => NULL,
                        p_nqle_idx => NULL,
                --
                        x_k_price_adj_tab => l_k_price_adj_tab,
                        x_price_adj_tab   => x_hd_price_adj_tab );

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'===========================================');
     okc_util.print_trace(1,'END : GET PRICE ADJUSTMENTS AT HEADER LEVEL');
     okc_util.print_trace(1,'===========================================');
  END IF;

--
-- Get the price adjustment attributes into the x_hd_price_adj_attr_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=======================================================');
     okc_util.print_trace(1,'START : GET PRICE ADJUSTMENT ATTRIBUTES AT HEADER LEVEL');
     okc_util.print_trace(1,'=======================================================');
  END IF;

  get_price_adj_attr ( p_price_adj_tab   => x_hd_price_adj_tab,
                      p_k_price_adj_tab => l_k_price_adj_tab,
                      p_q_flag		=> p_q_flag,
                      p_o_flag		=> p_o_flag,
                      p_level		=> 'H',
                      x_price_adj_attr_tab => x_hd_price_adj_attr_tab );

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=======================================================');
     okc_util.print_trace(1,'  END : GET PRICE ADJUSTMENT ATTRIBUTES AT HEADER LEVEL');
     okc_util.print_trace(1,'=======================================================');
  END IF;

--
-- Get the price adjustment relationship into the x_hd_price_adj_rltship_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=========================================================');
     okc_util.print_trace(1,'START : GET PRICE ADJUSTMENT RELATIONSHIP AT HEADER LEVEL');
     okc_util.print_trace(1,'=========================================================');
  END IF;

  get_price_adj_rltship (  p_price_adj_tab   => x_hd_price_adj_tab,
                          p_k_price_adj_tab => l_k_price_adj_tab,
		--
                          p_line_tab	    => l_line_tab,
                          p_kl_rel_tab      => p_kl_rel_tab,
                          p_line_shipment_tab => l_line_shipment_tab,
		--
                          p_q_flag 	    => p_q_flag,
                          p_o_flag	    => p_o_flag,
                          p_level	    => 'H',
		--
	   		  x_price_adj_rltship_tab  => x_hd_price_adj_rltship_tab );

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=========================================================');
     okc_util.print_trace(1,'  END : GET PRICE ADJUSTMENT RELATIONSHIP AT HEADER LEVEL');
     okc_util.print_trace(1,'=========================================================');
  END IF;

--
-- Get the price attributes into the x_hd_price_attr_tab variable
--
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'============================================');
     okc_util.print_trace(1,'START : GET PRICE ATTRIBUTES AT HEADER LEVEL');
     okc_util.print_trace(1,'============================================');
  END IF;

  get_price_attr(p_chr_id => p_chr_id,
                         p_cle_id => NULL,
		--
                         p_qhr_id => p_qhr_id,
                         p_qle_id => NULL,
                         p_q_flag => p_q_flag,
		--
                         p_ohr_id => p_ohr_id,
                         p_ole_id => NULL,
                         p_o_flag => p_o_flag,
		--
                         p_level  => 'H',

                         p_nqhr_id => NULL,
                         p_nqle_idx => NULL,
		--
                         x_price_attr_tab => x_hd_price_attr_tab );

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'============================================');
     okc_util.print_trace(1,'  END : GET PRICE ATTRIBUTES AT HEADER LEVEL');
     okc_util.print_trace(1,'============================================');
  END IF;

----------------------------------------------------------
-- Select pricing information at the contract Line level
----------------------------------------------------------


--
-- At this point processing the price adjustments at the header level
-- has been completed and the contents of l_k_price_adj_tab can be
-- deleted as it contains data pertaining to header level
--
   l_k_price_adj_tab.DELETE;



--
-- Select price adjustments into the x_ln_price_adj_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=============================================');
     okc_util.print_trace(1,'START : GET PRICE ADJUSTMENTS AT LINE  LEVEL');
     okc_util.print_trace(1,'=============================================');
  END IF;

  IF l_line_tab.FIRST IS NOT NULL THEN
	FOR i IN l_line_tab.FIRST..l_line_tab.LAST LOOP

	  IF l_line_tab(i).operation_code= g_aso_op_code_create THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);
--
-- Also the index value i is the same in l_line_tab and p_kl_rel_tab because
-- when the quote line table was populated px_k2q_line_id(l_ql).q_line_idx := l_ql
-- the value of l_ql,q_line_idx are the same
--

		 get_price_adj(p_chr_id => p_chr_id,
				    p_cle_id => p_kl_rel_tab(i).k_line_id,
				--
				    p_qhr_id => NULL,
				    p_qle_id => NULL,
				    p_q_flag => p_q_flag,
				--
				    p_ohr_id => NULL,
				    p_ole_id => NULL,
			    	    p_o_flag => p_o_flag,
				--
				    p_level   =>'L',
				--
				    p_nqhr_id => p_qhr_id,
				    p_nqle_idx => i,
				--
				    x_k_price_adj_tab   => l_k_temp_price_adj_tab,
				    x_price_adj_tab     => x_ln_tmp_price_adj_tab);

	  ELSIF l_line_tab(i).operation_code= g_aso_op_code_update THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_price_adj(p_chr_id => p_chr_id,
				    p_cle_id => p_kl_rel_tab(i).k_line_id,
				--
				    p_qhr_id => p_qhr_id,
				    p_qle_id => l_line_tab(i).quote_line_id,
				    p_q_flag => p_q_flag,
				--
				    p_ohr_id => p_ohr_id,
				    p_ole_id => l_line_tab(i).quote_line_id,
						--Not valid now in case of an Order update  from a contract
						--Will need to be modified when K -> O for update will be
						--required to be developed

			    	    p_o_flag => p_o_flag,
				--
				    p_level   =>'L',
				--
				    p_nqhr_id => NULL,
				    p_nqle_idx => NULL,
				--
				    x_k_price_adj_tab   => l_k_temp_price_adj_tab,
				    x_price_adj_tab     => x_ln_tmp_price_adj_tab);

	  ELSIF l_line_tab(i).operation_code= g_aso_op_code_delete THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_price_adj(p_chr_id => NULL,
				    p_cle_id => NULL,
				--
				    p_qhr_id => p_qhr_id,
				    p_qle_id => l_line_tab(i).quote_line_id,
				    p_q_flag => p_q_flag,
				--
				    p_ohr_id => p_ohr_id,
				    p_ole_id => l_line_tab(i).quote_line_id,
						--Not valid now in case of an Order update  from a contract
						--Will need to be modified when K -> O for update will be
						--required to be developed

			    	    p_o_flag => p_o_flag,
				--
				    p_level   =>'L',
				--
				    p_nqhr_id => NULL,
				    p_nqle_idx => NULL,
				--
				    x_k_price_adj_tab   => l_k_temp_price_adj_tab,
				    x_price_adj_tab     => x_ln_tmp_price_adj_tab);
	  END IF;

 --
 -- The processing below, is required to ensure that for every line processed
 -- the contents of the temp tables are loaded to the main tables, thereby
 -- ensuring that the table is not overwritten
 --

	  IF l_k_temp_price_adj_tab.COUNT > 0 THEN
	     FOR k IN l_k_temp_price_adj_tab.FIRST..l_k_temp_price_adj_tab.LAST LOOP
		l_k_price_adj_tab(l_k_price_adj_tab.COUNT+1) := l_k_temp_price_adj_tab(k);
	     END LOOP;
	  END IF;

	  IF x_ln_tmp_price_adj_tab.COUNT > 0 THEN
	     FOR k IN x_ln_tmp_price_adj_tab.FIRST..x_ln_tmp_price_adj_tab.LAST LOOP
		x_ln_price_adj_tab(x_ln_price_adj_tab.COUNT+1) := x_ln_tmp_price_adj_tab(k);
	     END LOOP;
	  END IF;


	END LOOP;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=============================================');
     okc_util.print_trace(1,'  END : GET PRICE ADJUSTMENTS AT LINE  LEVEL');
     okc_util.print_trace(1,'=============================================');
  END IF;

--
-- Select price adjustment attributes into the x_ln_price_adj_attr_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=======================================================');
     okc_util.print_trace(1,'START : GET PRICE ADJUSTMENT ATTRIBUTES AT LINE LEVEL');
     okc_util.print_trace(1,'=======================================================');
  END IF;

 get_price_adj_attr ( p_price_adj_tab   => x_ln_price_adj_tab,
				p_k_price_adj_tab => l_k_price_adj_tab,
				p_q_flag	  => p_q_flag,
				p_o_flag          => p_o_flag,
				p_level           => 'L',
			        x_price_adj_attr_tab  => x_ln_price_adj_attr_tab);

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=======================================================');
     okc_util.print_trace(1,' END : GET PRICE ADJUSTMENT ATTRIBUTES AT LINE LEVEL');
     okc_util.print_trace(1,'=======================================================');
  END IF;

--
-- Select price adjustment relationship into the x_ln_price_adj_rltship_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=========================================================');
     okc_util.print_trace(1,'START : GET PRICE ADJUSTMENT RELATIONSHIP AT LINE LEVEL');
     okc_util.print_trace(1,'=========================================================');
  END IF;

 get_price_adj_rltship( p_price_adj_tab => x_ln_price_adj_tab,
				  p_k_price_adj_tab => l_k_price_adj_tab,
			  --
				  p_line_tab => l_line_tab,
				  p_kl_rel_tab => p_kl_rel_tab,
				  p_line_shipment_tab => l_line_shipment_tab,
			--
				  p_q_flag   => p_q_flag,
				  p_o_flag   => p_o_flag,
				  p_level    => 'L',
			--
             			  x_price_adj_rltship_tab => x_ln_price_adj_rltship_tab);

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=========================================================');
     okc_util.print_trace(1,'  END : GET PRICE ADJUSTMENT RELATIONSHIP AT LINE LEVEL');
     okc_util.print_trace(1,'=========================================================');
  END IF;

--
-- Select price attributes into the x_ln_price_attr_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'============================================');
     okc_util.print_trace(1,'START : GET PRICE ATTRIBUTES AT LINE LEVEL');
     okc_util.print_trace(1,'============================================');
  END IF;

  IF l_line_tab.FIRST IS NOT NULL THEN
	FOR i IN l_line_tab.FIRST..l_line_tab.LAST LOOP

	  IF l_line_tab(i).operation_code= g_aso_op_code_create THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);
--
-- Also the index value i is the same in l_line_tab and p_kl_rel_tab because
-- when the quote line table was populated px_k2q_line_id(l_ql).q_line_idx := l_ql
-- the value of l_ql,q_line_idx are the same
--

		 get_price_attr(p_chr_id => p_chr_id,
				    p_cle_id => p_kl_rel_tab(i).k_line_id,
				--
				    p_qhr_id => NULL,
				    p_qle_id => NULL,
				    p_q_flag => p_q_flag,
				--
				    p_ohr_id => NULL,
				    p_ole_id => NULL,
			    	    p_o_flag => p_o_flag,
				--
				    p_level   =>'L',
				--
				    p_nqhr_id => p_qhr_id,
				    p_nqle_idx => i,   -- px_k2q_line_rel_tbl(i).q_line_idx = i
						       -- px_qte_line_tbl(i).line_number = i
				--
				    x_price_attr_tab     => x_ln_tmp_price_attr_tab);

	  ELSIF l_line_tab(i).operation_code= g_aso_op_code_update THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_price_attr(p_chr_id => p_chr_id,
				    p_cle_id => p_kl_rel_tab(i).k_line_id,
				--
				    p_qhr_id => p_qhr_id,
				    p_qle_id => l_line_tab(i).quote_line_id,
				    p_q_flag => p_q_flag,
				--
				    p_ohr_id => p_ohr_id,
				    p_ole_id => l_line_tab(i).quote_line_id,
						--Not valid now in case of an Order update  from a contract
						--Will need to be modified when K -> O for update will be
						--required to be developed

			    	    p_o_flag => p_o_flag,
				--
				    p_level   =>'L',
				--
				    p_nqhr_id => NULL,
				    p_nqle_idx => NULL,
				--
				    x_price_attr_tab     => x_ln_tmp_price_attr_tab);

	  ELSIF l_line_tab(i).operation_code= g_aso_op_code_delete THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_price_attr(p_chr_id => NULL,
				    p_cle_id => NULL,
				--
				    p_qhr_id => p_qhr_id,
				    p_qle_id => l_line_tab(i).quote_line_id,
				    p_q_flag => p_q_flag,
				--
				    p_ohr_id => p_ohr_id,
				    p_ole_id => l_line_tab(i).quote_line_id,
						--Not valid now in case of an Order update  from a contract
						--Will need to be modified when K -> O for update will be
						--required to be developed

			    	    p_o_flag => p_o_flag,
				--
				    p_level   =>'L',
				--
				    p_nqhr_id => NULL,
				    p_nqle_idx => NULL,
				--
				    x_price_attr_tab  => x_ln_tmp_price_attr_tab);
	  END IF;

          IF x_ln_tmp_price_attr_tab.COUNT > 0 THEN
             FOR k IN x_ln_tmp_price_attr_tab.FIRST..x_ln_tmp_price_attr_tab.LAST LOOP
                x_ln_price_attr_tab(x_ln_price_attr_tab.COUNT+1) := x_ln_tmp_price_attr_tab(k);
             END LOOP;
          END IF;

	END LOOP;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'============================================');
     okc_util.print_trace(1,'  END : GET PRICE ATTRIBUTES AT LINE LEVEL');
     okc_util.print_trace(1,'============================================');
  END IF;

EXCEPTION

 WHEN e_exit THEN

 x_return_status := OKC_API.G_RET_STS_ERROR;


 WHEN OTHERS THEN
	OKC_API.set_message(G_APP_NAME,
			    G_UNEXPECTED_ERROR,
		  	    G_SQLCODE_TOKEN,
			    SQLCODE,
			    G_SQLERRM_TOKEN,
			    SQLERRM );
	print_error(2);

-- notify caller of an unexpected error

x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END build_pricing_from_k;


--  =========================================================================
--  =========================================================================
--                   END OF KTQ or KTO PRICING INFORMATION CREATION
--                                   or UPDATE
--  =========================================================================
--  =========================================================================


END OKC_OC_INT_PRICING_PVT;

/
