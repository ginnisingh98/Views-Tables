--------------------------------------------------------
--  DDL for Package Body OKL_BPD_CAP_PURPOSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_CAP_PURPOSE_PVT" AS
 /* $Header: OKLRCPUB.pls 120.8 2007/08/24 05:54:13 asawanka noship $ */
---------------------------------------------------------------------------
-- PROCEDURE create_purpose
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_purpose
  -- Description     : procedure for inserting the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE create_purpose( p_api_version	   IN  NUMBER
		                 ,p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				         ,x_return_status  OUT NOCOPY VARCHAR2
				         ,x_msg_count	   OUT NOCOPY NUMBER
			             ,x_msg_data	   OUT NOCOPY VARCHAR2
                         ,p_strm_tbl       IN  okl_cash_dtls_tbl_type
                         ,x_strm_tbl       OUT NOCOPY okl_cash_dtls_tbl_type
             	        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  l_strm_rec                 okl_cash_dtls_rec_type;
  l_strm_tbl                 okl_cash_dtls_tbl_type;
  l_cust_num                 AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL;
  l_rct_id_details           OKL_TXL_RCPT_APPS_B.RCT_ID_DETAILS%TYPE DEFAULT NULL;
  l_total_amount_applied     OKL_TXL_RCPT_APPS_B.AMOUNT%TYPE DEFAULT NULL;
  l_receipt_amount           OKL_TXL_RCPT_APPS_B.AMOUNT%TYPE DEFAULT NULL;
  l_org_id			         OKL_TXL_RCPT_APPS_B.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  i                          NUMBER DEFAULT NULL;
  j                          NUMBER DEFAULT NULL;
  l_api_version			     NUMBER := 1.0;
  l_init_msg_list	    	 VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		     VARCHAR2(1);
  l_msg_count		    	 NUMBER := 0;
  l_msg_data	    		 VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'create_purpose';

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;

  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

-------------------
-- DECLARE Cursors
-------------------

-- cursor to fetch the receipt id.
CURSOR c_get_int_recpt_id (cp_receipt_id IN l_strm_rec.receipt_id%TYPE)
IS
  SELECT int.id
  FROM OKL_TRX_CSH_RECEIPT_B int--,
--       OKL_EXT_CSH_RCPTS_B ext
--  WHERE int.id = ext.RCT_ID
--   and ext.ID = cp_receipt_id;
     WHERE int.cash_receipt_id = cp_receipt_id;
----------

-- cursor to fetch the amount for the receipt
--asawanka modified cursor for receipts project
CURSOR c_get_recpt_amt (cp_receipt_id IN l_strm_rec.receipt_id%TYPE)
IS
  SELECT amount
  FROM ar_cash_receipts_all b
  WHERE b.cash_receipt_id = cp_receipt_id;
----------

-- get org_id for contract
   CURSOR   c_get_org_id (cp_contract_id IN VARCHAR2) IS
   SELECT  authoring_org_id
   FROM   OKC_K_HEADERS_B
   WHERE  id = cp_contract_id;

----------


BEGIN
OKC_API.init_msg_list(p_init_msg_list);
SAVEPOINT create_purpose_PVT;
  -- Initialize....
    l_strm_tbl := p_strm_tbl;
    IF l_strm_tbl.COUNT = 0 THEN
   -- Message Text: no allocation required  if no records are found in the table...
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_NO_ALLOC_REQ');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

   -- check, amount applied = the receipt amount ...
    j := l_strm_tbl.FIRST;
    l_strm_rec := l_strm_tbl(j);

    -- Check the amount against stream amounts
    OPEN c_get_int_recpt_id (l_strm_rec.receipt_id);
    FETCH c_get_int_recpt_id INTO l_rct_id_details;
    CLOSE c_get_int_recpt_id;

    OPEN c_get_recpt_amt (l_strm_rec.receipt_id);
    FETCH c_get_recpt_amt INTO l_receipt_amount;
    CLOSE c_get_recpt_amt;

    IF  l_strm_rec.contract_id IS NOT NULL THEN
      OPEN c_get_org_id(l_strm_rec.contract_id);
      FETCH c_get_org_id into l_org_id;
      CLOSE c_get_org_id;
    END IF;

    l_total_amount_applied := 0;
    LOOP
       l_total_amount_applied := l_total_amount_applied + l_strm_tbl(j).amount;
       EXIT WHEN j = (l_strm_tbl.LAST);
          j := l_strm_tbl.next(j);
    END LOOP;


    IF l_receipt_amount < l_total_amount_applied THEN
    -- Message Text: the amount applied must be equal to receipt amount
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_RCPT_ALLOC_ERR');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


   i := l_strm_tbl.FIRST;
   j := l_strm_tbl.FIRST;

   LOOP
     l_rcav_tbl(i).rct_id_details := l_rct_id_details;
     l_rcav_tbl(i).sty_id := l_strm_tbl(j).sty_id;
     IF (l_rcav_tbl(i).sty_id = NULL OR
       l_rcav_tbl(i).sty_id = Okl_Api.G_MISS_NUM ) THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_RCPT_ALLOC_ERR');
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

     l_rcav_tbl(i).amount := l_strm_tbl(j).amount;
     l_rcav_tbl(i).ile_id := l_strm_tbl(j).customer_id;
     l_rcav_tbl(i).khr_id := l_strm_tbl(j).contract_id;
     l_rcav_tbl(i).org_id := l_org_id;
     EXIT WHEN (j = l_strm_tbl.LAST);
     i := l_strm_tbl.next(i);
     j := i;
   END LOOP;

    -- Inserting record into the table.
   okl_Txl_Rcpt_Apps_Pub.insert_txl_rcpt_apps( l_api_version,
                                               l_init_msg_list,
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data,
                                               l_rcav_tbl,
                                               x_rcav_tbl
                                             );

    x_return_status := l_return_status;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  -- exceptions........

EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        ROLLBACK TO create_purpose_PVT;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                  ,p_data    => x_msg_data);


     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       ROLLBACK TO create_purpose_PVT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

     WHEN OTHERS THEN
       ROLLBACK TO create_purpose_PVT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Bpd_Cap_Purpose_Pvt','create_purpose');
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END create_purpose;
---------------------------------------------------------------------------
-- PROCEDURE update_purpose
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_purpose
  -- Description     : procedure for updating the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE update_purpose( p_api_version	   IN  NUMBER
		                 ,p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				         ,x_return_status  OUT NOCOPY VARCHAR2
				         ,x_msg_count	   OUT NOCOPY NUMBER
			             ,x_msg_data	   OUT NOCOPY VARCHAR2
                         ,p_strm_tbl       IN  okl_cash_dtls_tbl_type
                         ,x_strm_tbl       OUT NOCOPY okl_cash_dtls_tbl_type
             	        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  l_strm_rec                 okl_cash_dtls_rec_type;
  l_strm_tbl                 okl_cash_dtls_tbl_type;
  l_org_id			                OKL_TXL_RCPT_APPS_B.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  i                          NUMBER DEFAULT NULL;
  j                          NUMBER DEFAULT NULL;
  l_api_version			     NUMBER := 1.0;
  l_init_msg_list	    	 VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		     VARCHAR2(1);
  l_msg_count		    	 NUMBER := 0;
  l_msg_data	    		 VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'create_purpose';

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;

  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

-------------------
-- DECLARE Cursors
-------------------

-- get org_id for contract
   CURSOR   c_get_org_id (cp_contract_id IN VARCHAR2) IS
   SELECT  authoring_org_id
   FROM   OKC_K_HEADERS_B
   WHERE  id = cp_contract_id;

----------


BEGIN
OKC_API.init_msg_list(p_init_msg_list);
SAVEPOINT update_purpose_PVT;
  -- Initialize....
    l_strm_tbl := p_strm_tbl;
    IF l_strm_tbl.COUNT = 0 THEN
   -- Message Text: no allocation required  if no records are found in the table...
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_NO_ALLOC_REQ');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    j := l_strm_tbl.FIRST;
    l_strm_rec := l_strm_tbl(j);

    IF  l_strm_rec.contract_id IS NOT NULL THEN
      OPEN c_get_org_id(l_strm_rec.contract_id);
      FETCH c_get_org_id into l_org_id;
      CLOSE c_get_org_id;
    END IF;

   i := l_strm_tbl.FIRST;
   j := l_strm_tbl.FIRST;

   LOOP
     l_rcav_tbl(i).id := l_strm_tbl(j).id;
     l_rcav_tbl(i).sty_id := l_strm_tbl(j).sty_id;
     IF (l_rcav_tbl(i).sty_id = NULL OR
       l_rcav_tbl(i).sty_id = Okl_Api.G_MISS_NUM ) THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_RCPT_ALLOC_ERR');
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     l_rcav_tbl(i).amount := l_strm_tbl(j).amount;
     l_rcav_tbl(i).org_id := l_org_id;
     EXIT WHEN (j = l_strm_tbl.LAST);
     i := l_strm_tbl.next(i);
     j := i;
   END LOOP;

    -- Updating record into the table.
   okl_Txl_Rcpt_Apps_Pub.update_txl_rcpt_apps( l_api_version,
                                               l_init_msg_list,
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data,
                                               l_rcav_tbl,
                                               x_rcav_tbl
                                             );

    x_return_status := l_return_status;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  -- exceptions........

EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        ROLLBACK TO update_purpose_PVT;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                  ,p_data    => x_msg_data);


     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       ROLLBACK TO update_purpose_PVT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

     WHEN OTHERS THEN
       ROLLBACK TO update_purpose_PVT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Bpd_Cap_Purpose_Pvt','create_purpose');
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END update_purpose;

---------------------------------------------------------------------------
-- PROCEDURE delete_purpose
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_purpose
  -- Description     : procedure for deleting the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE delete_purpose( p_api_version	   IN  NUMBER
		                 ,p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				         ,x_return_status  OUT NOCOPY VARCHAR2
				         ,x_msg_count	   OUT NOCOPY NUMBER
			             ,x_msg_data	   OUT NOCOPY VARCHAR2
                         ,p_strm_tbl       IN  okl_cash_dtls_tbl_type
                         ,x_strm_tbl       OUT NOCOPY okl_cash_dtls_tbl_type
             	        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  l_strm_rec                 okl_cash_dtls_rec_type;
  l_strm_tbl                 okl_cash_dtls_tbl_type;
  l_org_id			                OKL_TXL_RCPT_APPS_B.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  i                          NUMBER DEFAULT NULL;
  j                          NUMBER DEFAULT NULL;
  l_api_version			     NUMBER := 1.0;
  l_init_msg_list	    	 VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		     VARCHAR2(1);
  l_msg_count		    	 NUMBER := 0;
  l_msg_data	    		 VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'create_purpose';

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;

  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

-------------------
-- DECLARE Cursors
-------------------

-- get org_id for contract
   CURSOR   c_get_org_id (cp_contract_id IN VARCHAR2) IS
   SELECT  authoring_org_id
   FROM   OKC_K_HEADERS_B
   WHERE  id = cp_contract_id;

----------


BEGIN
OKC_API.init_msg_list(p_init_msg_list);
SAVEPOINT delete_purpose_PVT;
  -- Initialize....
    l_strm_tbl := p_strm_tbl;
    IF l_strm_tbl.COUNT = 0 THEN
   -- Message Text: no allocation required  if no records are found in the table...
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_NO_ALLOC_REQ');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    j := l_strm_tbl.FIRST;
    l_strm_rec := l_strm_tbl(j);

    IF  l_strm_rec.contract_id IS NOT NULL THEN
      OPEN c_get_org_id(l_strm_rec.contract_id);
      FETCH c_get_org_id into l_org_id;
      CLOSE c_get_org_id;
    END IF;


   i := l_strm_tbl.FIRST;
   j := l_strm_tbl.FIRST;

   LOOP
     l_rcav_tbl(i).id := l_strm_tbl(j).id;
     l_rcav_tbl(i).org_id := l_org_id;
     l_rcav_tbl(i).amount := l_strm_tbl(j).amount;
   EXIT WHEN (j = l_strm_tbl.LAST);
     i := l_strm_tbl.next(i);
     j := i;
   END LOOP;

    -- deleting record into the table.
   okl_Txl_Rcpt_Apps_Pub.delete_txl_rcpt_apps( l_api_version,
                                               l_init_msg_list,
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data,
                                               l_rcav_tbl
                                             );

    x_return_status := l_return_status;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  -- exceptions........

EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        ROLLBACK TO delete_purpose_PVT;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                  ,p_data    => x_msg_data);


     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       ROLLBACK TO delete_purpose_PVT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

     WHEN OTHERS THEN
       ROLLBACK TO delete_purpose_PVT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Bpd_Cap_Purpose_Pvt','create_purpose');
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END delete_purpose;
END OKL_BPD_CAP_PURPOSE_PVT;


/
