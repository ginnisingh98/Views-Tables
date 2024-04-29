--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_SALESCDT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_SALESCDT_PVT" AS
/*  $Header: OKCRSCTB.pls 120.2 2006/03/01 13:46:28 smallya noship $   */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/**************************************************************
   Processing:


   For order to contract:
   ...
   Details for order to contract as follows:

   For quote to contract:
   OKC_OC_INT_QTK_PVT.create_k_from_quote calls this package through
   a single call to OKC_OC_INT_SALESCDT_PVT.create_k_sales_credit passing
   as parameters the contract header id, quote header id and
   PL/SQL table p_rel_tab which has contract lines along
   with related order lines.

   Details for quote to contract as follows:

    --<<GET SALES CREDIT INFORMATION>>
      --call get_sales_credit() with header level parameters
      --this does the following:-
      --get sales credit information from ASO or ONT at the HEADER level
      --and store it in global PL/SQL table g_sales_credit_tab

      --call get_sales_credit () with line level parameters this time
      --this does the following:-
      --get sales credit information from ASO or ONT at the LINE level
      --and append it to global PL/SQL table g_sales_credit_tab which will then
      --contain BOTH header AND line level information

      --call OKC_SALES_CREDIT_PVT.create_sales_credit()
      --this puts sales credits information in OKC
    --<<END OF GETTING SALES CREDIT INFORMATION>>



   The OKX related quote pricing views concerned are:
   okx_qte_sls_credits_v


Flow:
|---OKC_OC_INT_SALESCDT_PVT.create_k_sales_credit()
    |    |---get_sales_credit() called twice at header level AND line level
    |    |    |---get_sales_credit_tab() at header level OR line level
    |    |        (as called)
    |    |---OKC_SALES_CREDIT_PVT.create_sales_credit

 **************************************************************/
  --sales credits
  g_sales_credit_tab   OKC_SALES_CREDIT_PVT.scrv_tbl_type;
  lx_sales_credit_tab  OKC_SALES_CREDIT_PVT.scrv_tbl_type;


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
        okc_util.print_trace(1, '>START - OKC_OC_INT_SALESCDT_PVT.CLEANUP - Initialize global PL/SQL Tables');
        okc_util.print_trace(1, ' ');
     END IF;

     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2, 'Cleaning up plsql tables');
     END IF;

     --sales credits
     g_sales_credit_tab.DELETE;
     lx_sales_credit_tab.DELETE;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2, 'Done Cleaning up');
        okc_util.print_trace(1, '<END - OKC_OC_INT_SALESCDT_PVT.CLEANUP - Initialize global PL/SQL Tables');
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



  ---------------------------------------------------------------------------
  --Procedure to create contract sales credit information at the header and line levels
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE create_k_sales_credit (
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
       OKC_UTIL.print_trace(1, 'Create Contract Sales Credit');
       OKC_UTIL.print_trace(1, '-----------------------------------------------');
       OKC_UTIL.print_trace(1, '>START - ******* OKC_OC_INT_SALESCDT_PVT.create_k_sales_credit  -');
    END IF;


    --<<begin getting sales credit information>>

    --get sales credit information from ASO or ONT at the HEADER level
    --and store it in global PL/SQL table g_sales_credit_tab
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Calling get_sales_credit at HEADER level-');
       OKC_UTIL.print_trace(2, 'Contract Id- '|| p_chr_id);
       OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
    END IF;
    get_sales_credit (
           p_chr_id         =>  p_chr_id,
           p_q_flag         =>  p_q_flag,
           p_qhr_id         =>  p_qhr_id,
           p_o_flag         =>  p_o_flag,
           p_ohr_id         =>  p_ohr_id
     );
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Header level call to get_sales_credit finished successfully');
       OKC_UTIL.print_trace(2, 'Output in global PL/SQL table g_sales_credit_tab');
    END IF;


    --get sales credit information from ASO or ONT at the LINE level
    --and append it to global PL/SQL table g_sales_credit_tab which will then
    --contain BOTH header AND line level information
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Calling get_sales_credit at LINE level-');
       OKC_UTIL.print_trace(2, 'Contract Id- '|| p_chr_id);
       OKC_UTIL.print_trace(2, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(2, 'Order Id - '|| p_ohr_id);
       OKC_UTIL.print_trace(2, 'PL/SQL table p_line_inf_tab- related quote or order lines and contract lines');
    END IF;
    get_sales_credit (
           p_chr_id         =>  p_chr_id,
           p_q_flag         =>  p_q_flag,
           p_qhr_id         =>  p_qhr_id,
           p_o_flag         =>  p_o_flag,
           p_ohr_id         =>  p_ohr_id,
           p_line_inf_tab   =>  p_line_inf_tab
     );
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, 'Line level call to get_sales_credit finished successfully');
       OKC_UTIL.print_trace(2, 'Output in global PL/SQL table g_sale_credits_tab');
    END IF;

    --now put this sales credits information in OKC
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(2, ' >Calling OKC_SALES_CREDIT_PVT.create_sales_credit');
       OKC_UTIL.print_trace(2, 'input p_scrv_tbl  => g_sales_credit_tab');
    END IF;
    IF g_sales_credit_tab.FIRST IS NOT NULL THEN

        OKC_SALES_CREDIT_PVT.create_sales_credit(
	   p_api_version	=> l_api_version,
           p_init_msg_list	=> OKC_API.G_FALSE,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> lx_msg_count,
           x_msg_data      	=> lx_msg_data,
           p_scrv_tbl           => g_sales_credit_tab,     --IN:   ASO or ONT
           x_scrv_tbl           => lx_sales_credit_tab); --OUT:  OKC


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
            --Sales Credit information from ASO or ONT table was not
            --                                                created in OKC.
            IF p_q_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOSALESCDT',
                   p_token1        => 'QNUMBER',
                   p_token1_value  => l_quote_number);
            ELSIF p_o_flag = OKC_API.G_TRUE THEN
               OKC_API.set_message(p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKC_Q2K_NOSALESCDT_ORD',
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
       OKC_UTIL.print_trace(2, ' >Call to OKC_SALES_CREDIT_PVT.create_sales_credit finished successfully');
    END IF;
    --<<end of getting sales credit information>>
    -----------------------------------------------


    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(1, '>END - ******* OKC_OC_INT_SALESCDT_PVT.create_k_sales_credit  -');
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

  END create_k_sales_credit;



  ----------------------------------------------------------------------------
  -- Procedure creates sales credit information in OKC from
  -- ASO or ONT sales credit
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_sales_credit(
    p_chr_id                    IN  NUMBER,
    p_q_flag                    IN  VARCHAR2 ,
    p_qhr_id                    IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                                    ,
    p_o_flag                    IN  VARCHAR2 ,
    p_ohr_id                    IN  NUMBER ,
    p_line_inf_tab              IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type

    ) IS

    i                           BINARY_INTEGER := 0;

  BEGIN
    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'START --> get_sales_credit- ');
       OKC_UTIL.print_trace(3, 'Contract Id - '|| p_chr_id);
       OKC_UTIL.print_trace(3, 'Quote Id - '|| p_qhr_id);
       OKC_UTIL.print_trace(3, 'Order Id - '|| p_ohr_id);
    END IF;

    --get all the sales credit for the quote header (or order header)
    --for processing at the header level
    --and store them in global PL/SQL table g_sales_credit_tab
    IF p_q_flag = OKC_API.G_TRUE AND p_qhr_id IS NOT NULL AND p_qhr_id <> OKC_API.G_MISS_NUM AND
       p_line_inf_tab.FIRST IS NULL
    THEN
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Calling get_sales_credit_tab with p_chr_id and p_qhr_id/p_ohr_id for processing at header level');
       END IF;
       -- get_sales_credit_tab stores it's output in g_sales_credit_tab
       get_sales_credit_tab(p_chr_id    =>  p_chr_id,
                    p_q_flag    =>  p_q_flag,
                    p_qhr_id    =>  p_qhr_id
                   );
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Call to get_sales_credit_tab finished successfully');
       END IF;

    ELSIF p_o_flag = OKC_API.G_TRUE AND p_ohr_id IS NOT NULL AND p_ohr_id <> OKC_API.G_MISS_NUM AND
          p_line_inf_tab.FIRST IS NULL
    THEN
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3, 'Calling get_sales_credit_tab with p_chr_id and p_qhr_id/p_ohr_id for processing at header level');
         END IF;
          -- get_sales_credit_tab stores it's output in g_sales_credit_tab
          get_sales_credit_tab(p_chr_id    =>  p_chr_id,
                       p_o_flag    =>  p_o_flag,
                       p_ohr_id    =>  p_ohr_id
		      );
         IF (l_debug = 'Y') THEN
            OKC_UTIL.print_trace(3, 'Call to get_sales_credit_tab finished successfully');
         END IF;
    END IF;



    --get all the sales credits for each quote line (or order line)
    --and store them all in global PL/SQL table g_sales_credit_tab
    --keeping intact the header level information that g_sales_credit_tab may
    --already contain.
    IF p_line_inf_tab.FIRST IS NOT NULL THEN
       IF (l_debug = 'Y') THEN
          OKC_UTIL.print_trace(3, 'Calling get_sales_credit_tab with p_chr_id and p_qhr_id/p_ohr_id    and p_line_inf_tab for processing at line level');
       END IF;

       i := p_line_inf_tab.FIRST;
       WHILE i IS NOT NULL LOOP
	  IF p_q_flag = OKC_API.G_TRUE AND p_qhr_id IS NOT NULL AND p_qhr_id <> OKC_API.G_MISS_NUM AND
             p_line_inf_tab(i).line_type <> OKC_OC_INT_CONFIG_PVT.G_BASE_LINE THEN
          -- get SALES CREDITS information from ASO tables
                -- get_sales_credit_tab stores it's output in g_sales_credit_tab
                get_sales_credit_tab(p_chr_id    =>  p_chr_id,
                             p_q_flag    => p_q_flag,
                             p_qhr_id    => p_qhr_id,
                             p_cle_id    => p_line_inf_tab(i).cle_id,
                             p_qle_id    => p_line_inf_tab(i).object1_id1
			     );
          ELSIF p_o_flag = OKC_API.G_TRUE AND p_ohr_id IS NOT NULL AND p_ohr_id <> OKC_API.G_MISS_NUM AND
                p_line_inf_tab(i).line_type <> OKC_OC_INT_CONFIG_PVT.G_BASE_LINE THEN
          -- get SALES CREDITS information from ONT tables
                -- get_sales_credit_tab stores it's output in g_sales_credit_tab
                get_sales_credit_tab(p_chr_id    =>  p_chr_id,
                             p_o_flag    => p_o_flag,
                             p_ohr_id    => p_ohr_id,
                             p_cle_id    => p_line_inf_tab(i).cle_id,
                             p_ole_id    => p_line_inf_tab(i).object1_id1
		             );
          END IF;

          i := p_line_inf_tab.NEXT(i);
       END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       OKC_UTIL.print_trace(3, 'Call to get_sales_credit_tab finished successfully');
       OKC_UTIL.print_trace(3, 'END --> get_sales_credit ');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
  END get_sales_credit;



    ----------------------------------------------------------------------
    -- PROCEDURE to get SALES CREDITS information from ASO or ONT tables
    -- get_sales_credit_tab stores it's output in global PL/SQL table g_sales_credit_tab
    ----------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
    PROCEDURE get_sales_credit_tab(
                p_chr_id  IN OKC_K_HEADERS_B.ID%TYPE,
                p_cle_id  IN OKC_K_LINES_B.ID%TYPE ,

                p_o_flag  IN VARCHAR2 ,
                p_ohr_id  IN NUMBER ,
                p_ole_id  IN NUMBER ,

                p_q_flag  IN VARCHAR2 ,
                p_qhr_id  IN OKX_QUOTE_HEADERS_V.ID1%TYPE ,
                p_qle_id  IN OKX_QUOTE_LINES_V.ID1%TYPE ) IS

      l_no_data_found BOOLEAN := TRUE;

      i               BINARY_INTEGER := 0;

      -- cursor to get okx_qte_sls_credits_v   or
      --               okx_ord_sls_credits_v information
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
      CURSOR c_source_sales_credit_rec (cp_q_flag IN VARCHAR2,
                        cp_qhr_id IN OKX_QUOTE_HEADERS_V.ID1%TYPE,
                        cp_qle_id IN OKX_QUOTE_LINES_V.ID1%TYPE,
                        cp_o_flag IN VARCHAR2,
                        cp_ohr_id IN NUMBER,
                        cp_ole_id IN NUMBER) IS
      --could be either ASO or ONT
      --only ONE of the following two queries in the union will be executed in
      --a call depending on which flag (p_q_flag or p_o_flag) is true

      -- first query to get okx_qte_sls_credits_v information
      SELECT a.quote_header_id source_header_id,
       a.quote_line_id source_line_id,
       a.percent,
       b.id1 salesrep_id,
       a.resource_group_id,        --no matching column in OKC
       -----employee_person_id,  --obsolete column in ASO replace by resource id
       a.sales_credit_type_id,
       a.attribute_category_code,   --new column needed in OKC
       a.object_version_number
      FROM   okx_qte_sls_credits_v a
            ,okx_salesreps_v       b
      WHERE  cp_q_flag = OKC_API.G_TRUE
        AND  a.quote_header_id = cp_qhr_id
        AND   ((cp_qle_id = OKC_API.G_MISS_NUM AND a.quote_line_id IS NULL) OR
               (cp_qle_id <> OKC_API.G_MISS_NUM AND a.quote_line_id = cp_qle_id))
        AND  a.resource_id = b.resource_id
        AND  b.org_id = SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID')

      UNION ALL

      -- second query to get okx_ord_sls_credits_v information
      SELECT header_id source_header_id,
       line_id source_line_id,
       percent,
       salesrep_id,
       -------sales_credit_type_id,
       TO_NUMBER(NULL),
       sales_credit_type_id,
       TO_CHAR(NULL),
       TO_NUMBER(NULL)    --object_version_number not present in order table
      FROM   okx_ord_sls_credits_v
      WHERE  cp_o_flag = OKC_API.G_TRUE
        AND  header_id = cp_ohr_id
        AND   ((cp_ole_id = OKC_API.G_MISS_NUM AND line_id IS NULL) OR
               (cp_ole_id <> OKC_API.G_MISS_NUM AND line_id = cp_ole_id));


      CURSOR c_get_contact_id(b_chr_id NUMBER,b_salesrep_ctrol VARCHAR2,b_object_id VARCHAR2) is
      SELECT id
      FROM   okc_contacts
      WHERE  dnz_chr_id = b_chr_id
        AND  cro_code = b_salesrep_ctrol
        AND  object1_id1=b_object_id
        AND  rownum = 1;

      l_supplier_role_id         OKC_K_PARTY_ROLES_B.ID%TYPE;
      l_source_sales_credit_rec  c_source_sales_credit_rec%ROWTYPE;
      l_return_status	         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

      IF (l_debug = 'Y') THEN
         OKC_UTIL.print_trace(4, 'START --> get_sales_credit_tab- ');
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
             OKC_UTIL.print_trace(4, 'Processing sales credit information for Quote Id - '|| p_qhr_id);
          END IF;
      ELSIF (p_o_flag = OKC_API.G_TRUE AND
            p_ohr_id IS NOT NULL AND
            p_ohr_id <> OKC_API.G_MISS_NUM) THEN
            IF (l_debug = 'Y') THEN
               OKC_UTIL.print_trace(4, 'Processing sales credit information for Order Id - '|| p_ohr_id);
            END IF;
      END IF;


      OPEN c_source_sales_credit_rec (cp_q_flag => p_q_flag,
                              cp_qhr_id => p_qhr_id,
                              cp_qle_id => p_qle_id,
                              cp_o_flag => p_o_flag,
                              cp_ohr_id => p_ohr_id,
                              cp_ole_id => p_ole_id); --ASO or ONT
      LOOP
          --use COUNT to keep adding to existing records, if any, in g_sales_credit_tab
          --otherwise if table empty, COUNT returns 0
          i := g_sales_credit_tab.COUNT + 1;
          FETCH c_source_sales_credit_rec INTO l_source_sales_credit_rec;
          EXIT WHEN c_source_sales_credit_rec%NOTFOUND;

          -- map okx_qte_sls_credits_v or
          --     okx_ord_sls_credits_v     to OKC_K_SALES_CREDITS

	  -- we don't need to enter the ID because it is automatically generated

          IF l_source_sales_credit_rec.source_header_id IS NOT NULL THEN
          --quote or order
	      g_sales_credit_tab(i).CHR_ID := p_chr_id;
	      g_sales_credit_tab(i).DNZ_CHR_ID := p_chr_id;
          END IF;
          IF l_source_sales_credit_rec.source_line_id IS NOT NULL THEN
          --quote or order
	      g_sales_credit_tab(i).CLE_ID := p_cle_id;
	  END IF;

          g_sales_credit_tab(i).percent := l_source_sales_credit_rec.percent;
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'percent: '|| l_source_sales_credit_rec.percent);
          END IF;

          /*********** contact creation no longer needed   ***********
          --each SALESREP_ID from the quote (or order) is created as a contact
          --in OKC_CONTACTS
          --OKC_K_SALES_CREDITS.CTC_ID is a foreign key pointing to
          --OKC_CONTACTS.ID
          OPEN c_get_contact_id(p_chr_id,G_SALESREP_CTROL,l_source_sales_credit_rec.salesrep_id);
             FETCH c_get_contact_id into g_sales_credit_tab(i).ctc_id;
             IF c_get_contact_id%NOTFOUND then
                 SELECT id into  l_supplier_role_id FROM OKC_K_PARTY_ROLES_B
                                                    WHERE dnz_chr_id = p_chr_id
                                                    AND   rle_code = 'SUPPLIER';

                 OKO_OM_INT_OTK_PVT.create_contact_for_contract(
                       p_cro_code       => G_SALESREP_CTROL
                      ,p_rle_code       => 'SUPPLIER'
                      ,p_buy_or_sell    => 'S'
                      ,p_chr_id         => p_chr_id
                      ,p_object_id1     => l_source_sales_credit_rec.salesrep_id
                      ,p_object_id2     => '#'
                      ,p_contact_seq    => NULL
                      ,p_cpl_id         => l_supplier_role_id
                      ,x_return_status  => l_return_status
                 );

                --IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                --    x_return_status := l_return_status;
                --END IF;
                IF (l_debug = 'Y') THEN
                   okc_util.print_trace(4, 'OUTPUT RECORD - OKO_OM_INT_OTK_PVT.create_contact_for_contract :');
                   okc_util.print_trace(4, '===============================================');
                END IF;
                --okc_util.print_trace(4, 'Status               = '||x_return_status);
                IF (l_debug = 'Y') THEN
                   okc_util.print_trace(4, 'Status               = '||l_return_status);
                END IF;
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    IF (l_debug = 'Y') THEN
                       OKC_UTIL.print_trace(4,SQLERRM);
                    END IF;
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    IF (l_debug = 'Y') THEN
                       OKC_UTIL.print_trace(4,SQLERRM);
                    END IF;
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

                IF c_get_contact_id%ISOPEN then
                   CLOSE c_get_contact_id;
                   OPEN c_get_contact_id(p_chr_id,G_SALESREP_CTROL, l_source_sales_credit_rec.salesrep_id);
                   FETCH c_get_contact_id into g_sales_credit_tab(i).ctc_id;
                END IF;

             END IF;
           CLOSE c_get_contact_id;
           **************************************************************************/

          ---obsolete column g_sales_credit_tab(i).ctc_id := l_source_sales_credit_rec.salesrep_id;
          g_sales_credit_tab(i).salesrep_id1 := l_source_sales_credit_rec.salesrep_id;
          g_sales_credit_tab(i).salesrep_id2 := '#';
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'salesrep_id1: '|| l_source_sales_credit_rec.salesrep_id);
             OKC_UTIL.print_trace(4, 'salesrep_id2: #');
          END IF;


          ----g_sales_credit_tab(i). := l_source_sales_credit_rec.resource_group_id;
          --no matching column in OKC

          g_sales_credit_tab(i).sales_credit_type_id1 := l_source_sales_credit_rec.sales_credit_type_id;
          g_sales_credit_tab(i).sales_credit_type_id2 := '#';
          -----g_sales_credit. := l_source_sales_credit_rec.attribute_category_code
          --new column needed in OKC
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'sales_credit_type_id1: '|| l_source_sales_credit_rec.sales_credit_type_id);
             OKC_UTIL.print_trace(4, 'sales_credit_type_id2: #');
          END IF;

          g_sales_credit_tab(i).object_version_number := l_source_sales_credit_rec.object_version_number;
          IF (l_debug = 'Y') THEN
             OKC_UTIL.print_trace(4, 'object_version_number: '|| l_source_sales_credit_rec.object_version_number);
          END IF;

      END LOOP;
      --IF c_source_sales_credit_rec%ROWCOUNT > 0 THEN
      --   l_no_data_found := FALSE;
      --END IF;
      CLOSE c_source_sales_credit_rec;



     --IF l_no_data_found THEN
     --   OKC_UTIL.print_trace(4, 'END --> get_sales_credit_tab: returned error- ');
     --   RAISE OKC_API.G_EXCEPTION_ERROR;
     --ELSE
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4, 'Output: PL/SQL global table- g_sale_credits_tab');
           OKC_UTIL.print_trace(4, 'END --> get_sales_credit_tab- ');
        END IF;
     --END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           OKC_UTIL.print_trace(4,SQLERRM);
        END IF;
        IF c_source_sales_credit_rec%ISOPEN THEN
           CLOSE c_source_sales_credit_rec;
        END IF;
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END get_sales_credit_tab;



--  ========================================================================
--              START OF KTQ or KTO SALES CREDIT INFORMATION CREATION
--                                   or UPDATE
--  ========================================================================

   PROCEDURE get_sales_credit(p_chr_id     IN NUMBER,
                        p_cle_id        IN NUMBER,
                --
                        p_qhr_id        IN NUMBER,
                        p_qle_id        IN NUMBER,
                        p_q_flag        IN VARCHAR2,
                --
                        p_ohr_id        IN NUMBER,
                        p_ole_id        IN NUMBER,
                        p_o_flag        IN VARCHAR2,
                --
                        p_level         IN VARCHAR2,
                --
                        p_nqhr_id       IN NUMBER,
                        p_nqle_idx      IN NUMBER,
                --
                        x_k_sales_credit_tab OUT NOCOPY k_sales_credit_tab_type,
                        x_sales_credit_tab   OUT NOCOPY ASO_QUOTE_PUB.sales_credit_tbl_type) IS

--
-- CURSOR to identify the sales credits which have to be deleted taking
-- into account those marked as to be updated or created: any quote sales
-- credit not yet referenced in l_sales_credit_tab will be added as to be deleted.
--

CURSOR c_sales_credit (b_q_flag VARCHAR, b_qh_id NUMBER, b_ql_id NUMBER,
			b_o_flag VARCHAR, b_oh_id NUMBER, b_ol_id NUMBER)  IS
SELECT
	qscdt.sales_credit_id SALES_CREDIT_ID  -- quote (header or line) sales credit ID
FROM
	OKX_QTE_SLS_CREDITS_V    qscdt
WHERE 	b_q_flag = OKC_API.g_true
AND 	qscdt.quote_header_id = b_qh_id
AND 	((b_ql_id IS NULL AND qscdt.quote_line_id IS NULL)
		OR (b_ql_id IS NOT NULL AND qscdt.quote_line_id = b_ql_id))
UNION

SELECT
	oscdt.sales_credit_id SALES_CREDIT_ID  -- order (header or line) sales credit ID
FROM
	OKX_ORD_SLS_CREDITS_V    oscdt
WHERE 	b_o_flag = OKC_API.g_true
AND 	oscdt.header_id = b_oh_id
AND 	((b_ol_id IS NULL AND oscdt.line_id IS NULL)
		OR (b_ol_id IS NOT NULL AND oscdt.line_id = b_ql_id));
--
--
  CURSOR c_k_sales_credit( b_kh_id NUMBER,b_kl_id NUMBER,
                        b_q_flag VARCHAR,b_qh_id NUMBER,b_ql_id NUMBER,
                        b_o_flag VARCHAR,b_oh_id NUMBER,b_ol_id NUMBER) IS
    SELECT
        DECODE(qscdt.resource_id,NULL,g_aso_op_code_create,
                DECODE(qscdt.sales_credit_type_id,NULL,g_aso_op_code_create,
                        DECODE(qscdt.percent,NULL,g_aso_op_code_create,g_aso_op_code_update)
                       )
               ) OPERATION_CODE,
	qscdt.sales_credit_id   sales_credit_id,  -- quote(Header or line) sales credit ID
--	kscdt.ctc_id,
	sr.resource_id,
	kscdt.sales_credit_type_id1,
	kscdt.percent,
	kscdt.id,				  -- contract (Header or line) sales credit ID
	kscdt.creation_date,
	kscdt.chr_id,
	kscdt.cle_id,
        kscdt.last_update_date
--	kscdt.object_version_number
     FROM
	OKC_K_SALES_CREDITS          kscdt,
	OKX_QTE_SLS_CREDITS_V        qscdt,
	OKX_SALESREPS_V		     sr
     WHERE
	    b_q_flag = OKC_API.G_TRUE
	AND kscdt.chr_id = b_kh_id
	AND  ((b_kl_id IS NULL AND kscdt.cle_id IS NULL)
			OR (b_kl_id IS NOT NULL AND kscdt.cle_id = b_kl_id))
	AND qscdt.quote_header_id(+)  = b_qh_id
	AND NVL(qscdt. Quote_line_id(+), 0) = NVL(b_ql_id, 0)
--	AND qscdt.resource_id(+)= kscdt.ctc_id
	AND qscdt.sales_credit_type_id (+)= kscdt.sales_credit_type_id1
	AND qscdt.percent(+)= kscdt.percent
	AND sr.id1 = kscdt.salesrep_id1
	AND sr.id2 = kscdt.salesrep_id2

    UNION

    SELECT
        DECODE(oscdt.salesrep_id,NULL,g_aso_op_code_create,
                DECODE(oscdt.sales_credit_type_id,NULL,g_aso_op_code_create,
                        DECODE(oscdt.percent,NULL,g_aso_op_code_create,g_aso_op_code_update)
                       )
               ) OPERATION_CODE,
	oscdt.sales_credit_id   sales_credit_id,  -- order(Header or line) sales credit ID
--	kscdt.ctc_id,
--	sr.resource_id,
	to_number(kscdt.salesrep_id1) resource_id,
	kscdt.sales_credit_type_id1,
	kscdt.percent,
	kscdt.id,				  -- contract (Header or line) sales credit ID
	kscdt.creation_date,
	kscdt.chr_id,
	kscdt.cle_id,
	kscdt.last_update_date
--	kscdt.object_version_number
     FROM
	OKC_K_SALES_CREDITS          kscdt,
	OKX_ORD_SLS_CREDITS_V        oscdt
--	OKX_SALESREPS_V		     sr
     WHERE
	    b_o_flag = OKC_API.G_TRUE
	AND kscdt.chr_id = b_kh_id
	AND  ((b_kl_id IS NULL AND kscdt.cle_id IS NULL)
			OR (b_kl_id IS NOT NULL AND kscdt.cle_id = b_kl_id))
	AND oscdt.header_id(+)  = b_oh_id
	AND NVL(oscdt.line_id(+), 0) = NVL(b_ol_id, 0)
--	AND oscdt.salesrep_id(+)= kscdt.ctc_id
	AND oscdt.sales_credit_type_id (+)= kscdt.sales_credit_type_id1
	AND oscdt.percent(+)= kscdt.percent
--	AND sr.id1 = kscdt.salesrep_id1
--	AND sr.id2 = kscdt.salesrep_id2
ORDER BY
	1,
	3,
	4,
	5,
	6,
	7 ;

l_prec_sls_crdt_id		NUMBER := NULL;
l_prec_sls_crdt_procsd 		VARCHAR2(1) := OKC_API.G_FALSE;
g_miss_sls_crdt_rec		c_k_sales_credit%ROWTYPE;
l_prec_sls_crdt_rec		c_k_sales_credit%ROWTYPE := g_miss_sls_crdt_rec;
l_sales_credit_insert		VARCHAR2(1) := OKC_API.G_TRUE;

l_sales_credit_rec		ASO_QUOTE_PUB.sales_credit_rec_type;
l_sales_credit_tab		ASO_QUOTE_PUB.sales_credit_tbl_type;
l_k_sales_credit_tab		k_sales_credit_tab_type;

 x BINARY_INTEGER;
 y BINARY_INTEGER;

BEGIN

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(1,'---------------------------------');
           okc_util.print_trace(1,'>> start : Get sales credit ');
           okc_util.print_trace(1,'---------------------------------');
        END IF;

--
-- housekeeping
--
 l_sales_credit_tab.DELETE;
 l_k_sales_credit_tab.DELETE;

 x_sales_credit_tab.DELETE;
 x_k_sales_credit_tab.DELETE;

x := l_sales_credit_tab.COUNT;
y := l_k_sales_credit_tab.COUNT;

IF x = 0 THEN
   x:=x+1;
END IF;

IF y = 0 THEN
   y:=y+1;
END IF;

--
-- Fill in the l_sales_credit_tab variable with sales credit to be created or updated
--

FOR sales_credit_rec IN c_k_sales_credit (p_chr_id, p_cle_id,
				p_q_flag, p_qhr_id, p_qle_id,
				p_o_flag, p_ohr_id, p_ole_id ) LOOP

l_sales_credit_insert := OKC_API.G_TRUE;


	IF sales_credit_rec.operation_code = g_aso_op_code_create THEN

		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1,'step 1-1 operation code = '||sales_credit_rec.operation_code);
		END IF;

--	  Populate l_sales_credit_rec with infomation from sales_credit_rec;

	l_sales_credit_rec.quote_header_id := p_qhr_id;
	l_sales_credit_rec.quote_line_id := p_qle_id;

	l_sales_credit_rec.operation_code 		:= sales_credit_rec.operation_code;

	l_sales_credit_rec.sales_credit_id 		:= sales_credit_rec.sales_credit_id;
	l_sales_credit_rec.percent  			:= sales_credit_rec.percent;
--	l_sales_credit_rec.resource_id			:= sales_credit_rec.ctc_id;
	l_sales_credit_rec.resource_id			:= sales_credit_rec.resource_id;
        l_sales_credit_rec.sales_credit_type_id 	:= sales_credit_rec.sales_credit_type_id1;
--	l_sales_credit_rec.object_version_number	:= sales_credit_rec.object_version_number;
	l_sales_credit_rec.last_update_date		:= sales_credit_rec.last_update_date;


		IF p_level = 'L' AND p_qhr_id IS NULL AND p_qle_id IS NULL THEN
						 -- related quote line has to be created
			l_sales_credit_rec.quote_header_id := p_nqhr_id;
			l_sales_credit_rec.qte_line_index := p_nqle_idx;
		END IF;
		l_sales_credit_rec.sales_credit_id := OKC_API.G_MISS_NUM;
	END IF;



	IF sales_credit_rec.operation_code = g_aso_op_code_update THEN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1,'step 1-2 operation code = '||sales_credit_rec.operation_code);
		END IF;
	   IF NVL(l_prec_sls_crdt_id,0) <> sales_credit_rec.id  THEN

	--
	-- Need to check if the related quote sales credit is not already planned to be
	-- updated in the l_sales_credit_tab variable
	--
	   IF l_sales_credit_tab.first IS NOT NULL THEN
		FOR i IN l_sales_credit_tab.first..l_sales_credit_tab.last LOOP
		   IF l_sales_credit_tab(i).sales_credit_id = sales_credit_rec.sales_credit_id THEN

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(1,'step 1-3 related sales credit adjustment is already planned to be updated');
			END IF;

			l_sales_credit_insert := OKC_API.G_FALSE;
			exit;
		   END IF;
		END LOOP;
	    END IF;
	ELSE
	--
	-- current contract sales credit matches with multiple quote sales credits
	-- and will be disregarded if already processed or if related quote sales credit is
	-- not already planned to be updated in the l_sales_credit_tab variable.
	--
	   IF l_prec_sls_crdt_procsd = OKC_API.G_TRUE THEN
		l_sales_credit_insert  := OKC_API.G_FALSE;
      		l_prec_sls_crdt_procsd := OKC_API.G_FALSE;
	   ELSE
		IF l_sales_credit_tab.first IS NOT NULL THEN
                FOR i IN l_sales_credit_tab.first..l_sales_credit_tab.last LOOP
		     IF l_sales_credit_tab(i).sales_credit_id = sales_credit_rec.sales_credit_id THEN
			 l_sales_credit_insert := OKC_API.G_FALSE;
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(1,'step 1-4 checking ctrct sls crdt with multiple qte sls crdt');
			END IF;
			 exit;
		     END IF;
		END LOOP;
	    END IF;
	END IF;	-- IF l_prec_sls_crdt_procsd := okc_api.g_true then..
   END IF;  -- IF l_prec_sls_crdt_id <> sales_credit_rec.id and ..


   IF NVL(l_prec_sls_crdt_id,0) <> sales_credit_rec.id THEN
      IF l_prec_sls_crdt_id IS NOT NULL AND l_prec_sls_crdt_procsd = OKC_API.G_FALSE THEN
	-- Populate l_sales_credit_rec with information from l_prec_sls_crdt_rec;


	l_sales_credit_rec.sales_credit_id 		:= l_prec_sls_crdt_rec.sales_credit_id;
	l_sales_credit_rec.percent  			:= l_prec_sls_crdt_rec.percent;
--	l_sales_credit_rec.resource_id			:= l_prec_sls_crdt_rec.ctc_id;
	l_sales_credit_rec.resource_id			:= l_prec_sls_crdt_rec.resource_id;
        l_sales_credit_rec.sales_credit_type_id 	:= l_prec_sls_crdt_rec.sales_credit_type_id1;
--	l_sales_credit_rec.object_version_number	:= l_prec_sls_crdt_rec.object_version_number;
	l_sales_credit_rec.last_update_date		:= l_prec_sls_crdt_rec.last_update_date;

	   l_sales_credit_rec.operation_code := g_aso_op_code_create;
	   l_sales_credit_rec.quote_header_id := p_qhr_id;
	   l_sales_credit_rec.quote_line_id := p_qle_id;
	   l_sales_credit_rec.sales_credit_id := OKC_API.G_MISS_NUM;

	   l_sales_credit_tab(x) := l_sales_credit_rec;
	   x := x + 1;
--
	   l_k_sales_credit_tab(y).id := l_prec_sls_crdt_rec.id;
	   l_k_sales_credit_tab(y).level := p_level;
	   y := y + 1;

	   l_prec_sls_crdt_procsd := okc_api.g_true;

      END IF;

      l_prec_sls_crdt_id := sales_credit_rec.id;
      l_prec_sls_crdt_procsd := OKC_API.G_FALSE;
   END IF;

   IF l_sales_credit_insert = OKC_API.G_TRUE THEN

	l_sales_credit_rec.quote_header_id := p_qhr_id;
	l_sales_credit_rec.quote_line_id := p_qle_id;

	l_sales_credit_rec.sales_credit_id 		:= sales_credit_rec.sales_credit_id;
	l_sales_credit_rec.percent  			:= sales_credit_rec.percent;
--	l_sales_credit_rec.resource_id			:= sales_credit_rec.ctc_id;
	l_sales_credit_rec.resource_id			:= sales_credit_rec.resource_id;
        l_sales_credit_rec.sales_credit_type_id 	:= sales_credit_rec.sales_credit_type_id1;
--	l_sales_credit_rec.object_version_number	:= sales_credit_rec.object_version_number;
	l_sales_credit_rec.last_update_date		:= sales_credit_rec.last_update_date;

	l_sales_credit_rec.operation_code 		:= sales_credit_rec.operation_code;

   END IF;
 END IF; -- IF sales_credit_rec.operation_code = 'UPADTE' then...


   IF l_sales_credit_insert = OKC_API.G_TRUE THEN

	l_sales_credit_tab(x) := l_sales_credit_rec;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'INDEX VALUE x = '||x);
   okc_util.print_trace(1,'=========================================================');
   okc_util.print_trace(1,'  ');
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'operation code  = '||l_sales_credit_tab(x).operation_code);
   okc_util.print_trace(1,'qte hdr id      = '||l_sales_credit_tab(x).quote_header_id);
   okc_util.print_trace(1,'qte line id     = '||l_sales_credit_tab(x).quote_line_id);
   okc_util.print_trace(1,'sales credit id = '||l_sales_credit_tab(x).sales_credit_id);
   okc_util.print_trace(1,'percent         = '||l_sales_credit_tab(x).percent);
   okc_util.print_trace(1,'resource(ctc)id = '||l_sales_credit_tab(x).resource_id);
   okc_util.print_trace(1,'sls crdt typ id = '||l_sales_credit_tab(x).sales_credit_type_id);
END IF;
-- okc_util.print_trace(1,'obj ver #       = '||l_sales_credit_tab(x).object_version_number);
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'last updt date  = '||l_sales_credit_tab(x).last_update_date);
END IF;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
END IF;

	x := x + 1;
--
	l_k_sales_credit_tab(y).id := sales_credit_rec.id;
	l_k_sales_credit_tab(y).level := p_level;
	y := y + 1;
--
	l_prec_sls_crdt_procsd := OKC_API.G_TRUE;
   END IF;

       l_prec_sls_crdt_rec := sales_credit_rec;

END LOOP;   --- FOR sales_credit_rec IN c_k_sales_credit


--
--	Case of a new occurance of an existing sales credit, not processed before because
--	the related quote sales credits have already been marked to be processed.

IF  l_prec_sls_crdt_rec.operation_code = g_aso_op_code_update AND
	l_prec_sls_crdt_id IS NOT NULL AND l_prec_sls_crdt_procsd = OKC_API.G_FALSE THEN
-- populate l_sales_credit_rec with infomation from l_prec_sls_crdt_rec;

	l_sales_credit_rec.sales_credit_id 		:= l_prec_sls_crdt_rec.sales_credit_id;
	l_sales_credit_rec.percent  			:= l_prec_sls_crdt_rec.percent;
--	l_sales_credit_rec.resource_id			:= l_prec_sls_crdt_rec.ctc_id;
	l_sales_credit_rec.resource_id			:= l_prec_sls_crdt_rec.resource_id;
        l_sales_credit_rec.sales_credit_type_id 	:= l_prec_sls_crdt_rec.sales_credit_type_id1;
--	l_sales_credit_rec.object_version_number	:= l_prec_sls_crdt_rec.object_version_number;
	l_sales_credit_rec.last_update_date		:= l_prec_sls_crdt_rec.last_update_date;

	l_sales_credit_rec.operation_code := g_aso_op_code_create;
	l_sales_credit_rec.quote_header_id := p_qhr_id;
	l_sales_credit_rec.quote_line_id := p_qle_id;
	l_sales_credit_rec.sales_credit_id := OKC_API.G_MISS_NUM;
--
	l_sales_credit_tab(x) := l_sales_credit_rec;
	x:= x+1;
--
	l_k_sales_credit_tab(y).id := l_prec_sls_crdt_rec.id;
	l_k_sales_credit_tab(y).level := p_level;
	y:=y+1;

	l_prec_sls_crdt_procsd := OKC_API.G_TRUE;
END IF;
--
--
-- Fill in the l_sales_credit_tab variable with sales credit to be deleted.
--

FOR l_sales_credit IN c_sales_credit(p_q_flag,p_qhr_id, p_qle_id,
				p_o_flag,p_ohr_id,p_ole_id) LOOP

 l_sales_credit_insert := OKC_API.G_TRUE;

--
-- Need to check if the related quote sales credit is not already planned to be updated
-- in the l_sales_credit_tab_variable
--
	IF l_sales_credit_tab.FIRST IS NOT NULL THEN
	  FOR i IN l_sales_credit_tab.first..l_sales_credit_tab.last LOOP
		IF l_sales_credit_tab(i).sales_credit_id = l_sales_credit.sales_credit_id THEN
			l_sales_credit_insert := OKC_API.G_FALSE;
			exit;
		END IF;
	  END LOOP;
	END IF;

	IF l_sales_credit_insert = OKC_API.G_TRUE THEN
-- populate l_sales_credit_rec with information from l_sales_credit

		l_sales_credit_rec.operation_code := g_aso_op_code_delete;
		l_sales_credit_rec.quote_header_id := p_qhr_id;
		l_sales_credit_rec.quote_line_id := p_qle_id;

		l_sales_credit_rec.sales_credit_id := l_sales_credit.sales_credit_id;
--
		l_sales_credit_tab(x) := l_sales_credit_rec;
		x:=x+1;
	END IF;
END LOOP;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'-----------------------------------------');
   okc_util.print_trace(1,' values contained in the l_sales_credit_tab ');
   okc_util.print_trace(1,'-----------------------------------------');
   okc_util.print_trace(1,'  ');
END IF;

 IF l_sales_credit_tab.first IS NOT NULL THEN
    FOR i IN l_sales_credit_tab.first..l_sales_credit_tab.last LOOP
	IF l_sales_credit_tab.EXISTS(i) THEN

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'index value     = '||i);
   okc_util.print_trace(1,'operation code  = '||l_sales_credit_tab(i).operation_code);
   okc_util.print_trace(1,'qte hdr id      = '||l_sales_credit_tab(i).quote_header_id);
   okc_util.print_trace(1,'qte line id     = '||l_sales_credit_tab(i).quote_line_id);
   okc_util.print_trace(1,'sales credit id = '||l_sales_credit_tab(i).sales_credit_id);
   okc_util.print_trace(1,'percent         = '||l_sales_credit_tab(i).percent);
   okc_util.print_trace(1,'resource(ctc)id = '||l_sales_credit_tab(i).resource_id);
   okc_util.print_trace(1,'sls crdt typ id = '||l_sales_credit_tab(i).sales_credit_type_id);
END IF;
-- okc_util.print_trace(1,'obj ver #       = '||l_sales_credit_tab(i).object_version_number);
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'last updt date  = '||l_sales_credit_tab(i).last_update_date);
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
END IF;
	END IF;
    END LOOP;
 END IF;



IF l_k_sales_credit_tab.count > 0 THEN
	FOR i IN l_k_sales_credit_tab.FIRST..l_k_sales_credit_tab.LAST LOOP
    		x_k_sales_credit_tab(x_k_sales_credit_tab.COUNT+1) := l_k_sales_credit_tab(i);
	END LOOP;
END IF;

IF l_sales_credit_tab.COUNT > 0 THEN
	FOR i IN l_sales_credit_tab.FIRST..l_sales_credit_tab.LAST LOOP
		x_sales_credit_tab(x_sales_credit_tab.COUNT+1) := l_sales_credit_tab(i);
	END LOOP;
END IF;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,' FINAL VALUES CONTAINED IN THE X_SALES_CREDIT_TAB ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,'  ');
END IF;

 IF x_sales_credit_tab.first IS NOT NULL THEN
    FOR i IN x_sales_credit_tab.first..x_sales_credit_tab.last LOOP
	IF x_sales_credit_tab.EXISTS(i) THEN

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'index value     = '||i);
   okc_util.print_trace(1,'operation code  = '||l_sales_credit_tab(i).operation_code);
   okc_util.print_trace(1,'qte hdr id      = '||l_sales_credit_tab(i).quote_header_id);
   okc_util.print_trace(1,'qte line id     = '||l_sales_credit_tab(i).quote_line_id);
   okc_util.print_trace(1,'sales credit id = '||l_sales_credit_tab(i).sales_credit_id);
   okc_util.print_trace(1,'percent         = '||l_sales_credit_tab(i).percent);
   okc_util.print_trace(1,'resource(ctc)id = '||l_sales_credit_tab(i).resource_id);
   okc_util.print_trace(1,'sls crdt typ id = '||l_sales_credit_tab(i).sales_credit_type_id);
END IF;
-- okc_util.print_trace(1,'obj ver #       = '||l_sales_credit_tab(i).object_version_number);
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'last updt date  = '||l_sales_credit_tab(i).last_update_date);
   okc_util.print_trace(1,'  ');
END IF;

	END IF;
    END LOOP;
 END IF;

--	x_k_sales_credit_tab := l_k_sales_credit_tab;
--	x_sales_credit_tab := l_sales_credit_tab;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'  ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,' FINAL VALUES CONTAINED IN THE X_K_SALES_CREDIT_TAB ');
   okc_util.print_trace(1,'====================================================');
   okc_util.print_trace(1,'  ');
END IF;

 IF x_k_sales_credit_tab.first IS NOT NULL THEN
    FOR i IN x_k_sales_credit_tab.first..x_k_sales_credit_tab.last LOOP
	IF x_k_sales_credit_tab.EXISTS(i) THEN

     	IF (l_debug = 'Y') THEN
        	okc_util.print_trace(1,'INDEX VALUE =  '||i);
        	okc_util.print_trace(1,'okc_k_sales_credits - id = '||x_k_sales_credit_tab(i).id);
        	okc_util.print_trace(1,'Level        = '||x_k_sales_credit_tab(i).level);
     	END IF;

	END IF;

   END LOOP;
END IF;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(1,'------------------------------');
   	okc_util.print_trace(1,'>>END : Get sales credits ');
   	okc_util.print_trace(1,'------------------------------');
	END IF;

EXCEPTION
 WHEN OTHERS THEN
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'inside get sales credit : others exception');
END IF;

  IF c_k_sales_credit%ISOPEN THEN
	CLOSE c_k_sales_credit;
  END IF;
  IF c_sales_credit%ISOPEN THEN
	CLOSE c_sales_credit;
  END IF;

RAISE;

END;	-- get_sales_credit


-- ========================================
--
-- procedure build_sales_credit_from_k
--
-- ========================================

PROCEDURE build_sales_credit_from_k(
        p_chr_id           IN  OKC_K_HEADERS_B.id%TYPE,
        p_kl_rel_tab       IN  okc_oc_int_config_pvt.line_rel_tab_type
,
     --
        p_q_flag           IN  VARCHAR2                             ,
        p_qhr_id           IN  OKX_QUOTE_HEADERS_V.id1%TYPE         ,
        p_qle_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      ,
     --
        p_o_flag           IN  VARCHAR2                             ,
        p_ohr_id           IN  OKX_ORDER_HEADERS_V.id1%TYPE         ,
        p_ole_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      ,
     --
        x_hd_sales_credit_tab           OUT NOCOPY ASO_QUOTE_PUB.sales_credit_tbl_type,
        x_ln_sales_credit_tab           OUT NOCOPY ASO_QUOTE_PUB.sales_credit_tbl_type,
     --
        x_return_status                 OUT NOCOPY  VARCHAR2 ) IS

k	BINARY_INTEGER;
x_ln_temp_sls_crdt_tab	ASO_QUOTE_PUB.sales_credit_tbl_type;
l_cle_id	okc_k_lines_b.id%TYPE;

BEGIN

--
-- housekeeping
--

  x_hd_sales_credit_tab.DELETE;
  x_ln_sales_credit_tab.DELETE;

  x_ln_temp_sls_crdt_tab.DELETE;
  l_k_sales_credit_tab.DELETE;
  l_line_tab.DELETE;


  IF p_q_flag = OKC_API.g_true THEN
        l_line_tab:=p_qle_tab;
  ELSIF p_o_flag = OKC_API.g_true THEN
        l_line_tab:=p_ole_tab;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

---------------------------------------------------------------
-- Select sales credit information at the contract header level
---------------------------------------------------------------

--
-- Get the sales credit information into the x_hd_sales_credit_tab variable
--
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'=============================================');
     okc_util.print_trace(1,'START : GET SALES CREDITS AT HEADER LEVEL    ');
     okc_util.print_trace(1,'=============================================');
  END IF;

  get_sales_credit(p_chr_id => p_chr_id,
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
                        x_k_sales_credit_tab => l_k_sales_credit_tab,
                        x_sales_credit_tab   => x_hd_sales_credit_tab );

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'===========================================');
     okc_util.print_trace(1,'  END : GET SALES CREDITS AT HEADER LEVEL    ');
     okc_util.print_trace(1,'===========================================');
  END IF;


--------------------------------------------------------------
-- Select sales credit information at the contract Line level
--------------------------------------------------------------

--
-- Select sales credit information into the x_ln_sales_credit_tab variable
--

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'===========================================');
     okc_util.print_trace(1,'START : GET SALES CREDITS AT LINE LEVEL    ');
     okc_util.print_trace(1,'===========================================');
  END IF;

  IF l_line_tab.FIRST IS NOT NULL THEN

	FOR i IN l_line_tab.FIRST..l_line_tab.LAST LOOP

--
-- Need to ensure that the Top model line is processed for the configuration item,
-- since the sales credit information is stored at the Top model line level
--
-- Also the index value i is the same in l_line_tab and p_kl_rel_tab because
-- when the quote line table was populated px_k2q_line_id(l_ql).q_line_idx := l_ql
-- the value of l_ql,q_line_idx are the same
--

	IF p_kl_rel_tab(i).q_item_type_code = g_aso_model_item THEN  -- MDL
		l_cle_id := p_kl_rel_tab(i).k_parent_line_id;
	ELSE
		l_cle_id := p_kl_rel_tab(i).k_line_id;
	END IF;


	  IF l_line_tab(i).operation_code= g_aso_op_code_create THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_sales_credit(p_chr_id => p_chr_id,
				    p_cle_id => l_cle_id,
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
				    x_k_sales_credit_tab   => l_k_sales_credit_tab,
				    x_sales_credit_tab     => x_ln_temp_sls_crdt_tab);

	  ELSIF l_line_tab(i).operation_code= g_aso_op_code_update THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_sales_credit(p_chr_id => p_chr_id,
				    p_cle_id => l_cle_id,
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
				    x_k_sales_credit_tab   => l_k_sales_credit_tab,
				    x_sales_credit_tab     => x_ln_temp_sls_crdt_tab);

	  ELSIF l_line_tab(i).operation_code= g_aso_op_code_delete THEN

--		okc_util.print_trace(1,'operation code '||l_line_tab(i).operation_code);

		 get_sales_credit(p_chr_id => NULL,
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
				    x_k_sales_credit_tab   => l_k_sales_credit_tab,
				    x_sales_credit_tab     => x_ln_temp_sls_crdt_tab);
	  END IF;

	  IF x_ln_temp_sls_crdt_tab.COUNT > 0 THEN
	     FOR k in x_ln_temp_sls_crdt_tab.first..x_ln_temp_sls_crdt_tab.last LOOP
		x_ln_sales_credit_tab(x_ln_sales_credit_tab.COUNT+1) := x_ln_temp_sls_crdt_tab(k);
	     END LOOP;
	  END IF;

	END LOOP;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'===========================================');
     okc_util.print_trace(1,'  END : GET SALES CREDITS AT LINE LEVEL    ');
     okc_util.print_trace(1,'===========================================');
  END IF;

EXCEPTION

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

END build_sales_credit_from_k;

--  ========================================================================
--              END OF KTQ or KTO SALES CREDIT INFORMATION CREATION
--                                   or UPDATE
--  ========================================================================



----------------------------------------------------------------------
--
-- Function get_party_name to retrieve a party name against    -------
-- the jtot_object1_code and object1_id1                       -------
--
-- This is a general function that can be used anywhere to retrieve
-- the party name for eg. from the OKCSLCRD.fmb sales credit form
FUNCTION get_party_name (p_object1_id1 varchar2,  p_jtot_object1_code varchar2) RETURN VARCHAR2 IS
   l_sql_stmt VARCHAR2(10000);
   l_from_clause varchar2(200);
   l_where_clause varchar2(2000);
   l_order_by_clause varchar2(200);
   l_party_name varchar2(500);

   l_cursor_id  INTEGER;
   l_dummy INTEGER;

BEGIN

   l_cursor_id := DBMS_SQL.OPEN_CURSOR;

   l_sql_stmt := 'SELECT FROM_TABLE, WHERE_CLAUSE, ORDER_BY_CLAUSE ';
   l_sql_stmt := l_sql_stmt ||  ' FROM jtf_objects_b';
   l_sql_stmt := l_sql_stmt ||  ' WHERE OBJECT_CODE = :jtot_object1_code';

   DBMS_SQL.PARSE(l_cursor_id,  l_sql_stmt, 2);
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':jtot_object1_code', p_jtot_object1_code);

   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_from_clause, 200);
   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 2, l_where_clause, 2000);
   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 3, l_order_by_clause, 200);

   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);
   IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

   DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_from_clause);
   DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2, l_where_clause);
   DBMS_SQL.COLUMN_VALUE(l_cursor_id, 3, l_order_by_clause);

   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);




   l_cursor_id := DBMS_SQL.OPEN_CURSOR;

   l_sql_stmt := 'SELECT NAME FROM ' || l_from_clause;
   l_sql_stmt := l_sql_stmt ||  '  WHERE ' || l_where_clause;
   l_sql_stmt := l_sql_stmt ||  '  AND ID1 = :object1_id';
   l_sql_stmt := l_sql_stmt ||  '  ORDER BY ' || l_order_by_clause;

   DBMS_SQL.PARSE(l_cursor_id,  l_sql_stmt, 2);
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':object1_id', p_object1_id1);

   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_party_name, 500);

   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);
   IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

   DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_party_name);
   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);


   RETURN(l_party_name);
EXCEPTION
   WHEN OTHERS THEN
        OKC_API.set_message(G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            SQLERRM );
        print_error(2);
END;





END OKC_OC_INT_SALESCDT_PVT ;

/
