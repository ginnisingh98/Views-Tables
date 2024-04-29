--------------------------------------------------------
--  DDL for Package Body OKL_BTCH_CASH_SUMRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BTCH_CASH_SUMRY_PVT" AS
/* $Header: OKLRBASB.pls 120.2 2007/11/13 10:02:57 ansethur ship $ */

---------------------------------------------------------------------------
-- PROCEDURE handle_manual_pay
---------------------------------------------------------------------------

PROCEDURE handle_batch_sumry  ( p_api_version	   IN  NUMBER
		                       ,p_init_msg_list    IN  VARCHAR2
				               ,x_return_status    OUT NOCOPY VARCHAR2
				               ,x_msg_count	       OUT NOCOPY NUMBER
				               ,x_msg_data	       OUT NOCOPY VARCHAR2
                               ,p_btch_tbl         IN  okl_btch_sumry_tbl_type
                               ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

l_api_version 			        NUMBER := 1;
l_api_name                      CONSTANT VARCHAR2(30) := 'handle_batch_sumry';
l_init_msg_list 		        VARCHAR2(1) ;
l_return_status 		        VARCHAR2(1);
l_msg_count 			        NUMBER := 0;
l_msg_data 				        VARCHAR2(2000);

l_trx_status_code               OKL_TRX_CSH_BATCH_B.TRX_STATUS_CODE%TYPE DEFAULT NULL;

i                               NUMBER DEFAULT NULL;
j                               NUMBER DEFAULT NULL;
k                               NUMBER DEFAULT NULL;

/*
l_org_id                        OKL_TRX_CSH_BATCH_B.ORG_ID%TYPE DEFAULT NULL;

l_id                            OKL_TRX_CSH_BATCH_B.ID%TYPE DEFAULT NULL;
l_name                          OKL_TRX_CSH_BATCH_TL.NAME%TYPE DEFAULT NULL;
l_batch_qty                     OKL_TRX_CSH_BATCH_B.BATCH_QTY%TYPE DEFAULT NULL;
l_batch_total                   OKL_TRX_CSH_BATCH_B.BATCH_TOTAL%TYPE DEFAULT NULL;
l_currency_code                 OKL_TRX_CSH_RECEIPT_B.CURRENCY_CODE%TYPE DEFAULT NULL;
l_date_deposit                  OKL_TRX_CSH_BATCH_B.DATE_DEPOSIT%TYPE DEFAULT NULL;
l_date_gl_requested             OKL_TRX_CSH_BATCH_B.DATE_GL_REQUESTED%TYPE DEFAULT NULL;
l_trx_status_code               OKL_TRX_CSH_BATCH_B.TRX_STATUS_CODE%TYPE DEFAULT NULL;
*/

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

l_btch_tbl                      OKL_BTCH_SUMRY_TBL_TYPE;

l_btcv_tbl                      OKL_BTC_PVT.BTCV_TBL_TYPE;
x_btcv_tbl                      OKL_BTC_PVT.BTCV_TBL_TYPE;

l_rctv_rec                      OKL_RCT_PVT.RCTV_REC_TYPE;
x_rctv_rec                      OKL_RCT_PVT.RCTV_REC_TYPE;
l_rctv_tbl                      OKL_RCT_PVT.RCTV_TBL_TYPE;
x_rctv_tbl                      OKL_RCT_PVT.RCTV_TBL_TYPE;

l_rcav_rec                      OKL_RCA_PVT.RCAV_REC_TYPE;
x_rcav_rec                      OKL_RCA_PVT.RCAV_REC_TYPE;
l_rcav_tbl                      OKL_RCA_PVT.RCAV_TBL_TYPE;
x_rcav_tbl                      Okl_RCA_PVT.RCAV_TBL_TYPE;

l_btc_init                      OKL_BTC_PVT.BTCV_TBL_TYPE;
l_rct_init                      OKL_RCT_PVT.RCTV_TBL_TYPE;
l_rca_init                      OKL_RCA_PVT.RCAV_TBL_TYPE;

-------------------
-- DECLARE Cursors
-------------------

-- get the batch status.
   CURSOR   get_btch_stat (cp_btc_id IN NUMBER) IS
   SELECT   btc.trx_status_code
   FROM	    OKL_TRX_CSH_BATCH_V btc
   WHERE    btc.id = cp_btc_id;

-------------------
   -- get the rct_id's ready for deletion.
   CURSOR   get_rct_id (cp_btc_id IN NUMBER) IS
   SELECT   rct.id
   FROM	    OKL_TRX_CSH_RECEIPT_V rct
   WHERE    rct.btc_id = cp_btc_id;

-------------------

   -- get the rct_id's ready for deletion.
   CURSOR   get_rca_id (cp_rct_id IN NUMBER) IS
   SELECT   rca.id
   FROM	    OKL_TXL_RCPT_APPS_V rca
   WHERE    rca.rct_id_details = cp_rct_id;

-------------------

BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

    IF (l_return_status = OKL_API.g_ret_sts_unexp_error) THEN
        RAISE OKL_API.g_exception_unexpected_error;
    ELSIF (l_return_Status = OKL_API.g_ret_sts_error) THEN
        RAISE OKL_API.g_exception_error;
    END IF;

    l_btch_tbl := p_btch_tbl;

    i := 0;
    j := 0;

    IF l_btch_tbl.COUNT > 0 THEN

        l_btcv_tbl := l_btc_init;
        l_rctv_tbl := l_rct_init;
        l_rcav_tbl := l_rca_init;

        LOOP

            EXIT WHEN (i = l_btch_tbl.LAST);
            i := i + 1;

            OPEN get_btch_stat(l_btch_tbl(i).id);
            FETCH get_btch_stat INTO l_trx_status_code;
            CLOSE get_btch_stat;
             --ansethur  13-nov-2007  allow update and resubmission of errored
             --batches - removing the errored status to allow removal
            IF l_trx_status_code NOT IN ('PROCESSED') THEN  --,'ERROR'

                l_btcv_tbl(i).id := l_btch_tbl(i).id;       -- build up btc table

                OPEN  get_rct_id(l_btcv_tbl(i).id);         -- get all the rct_id's for each batch
                LOOP
                    EXIT WHEN get_rct_id%NOTFOUND;
                    j := j + 1;
                    FETCH get_rct_id INTO l_rctv_tbl(j).id;
                END LOOP;
                CLOSE get_rct_id;

            END IF;

        END LOOP;

    END IF;

    j := 0;
    k := 0;

    IF l_rctv_tbl.COUNT > 0 THEN

        LOOP

            EXIT WHEN (j = l_rctv_tbl.LAST);
            j := j + 1;

            OPEN get_rca_id(l_rctv_tbl(j).id);         -- get all the rca_id's for each rct_id
            LOOP
                EXIT WHEN get_rca_id%NOTFOUND;
                k := k + 1;
                FETCH get_rca_id INTO l_rcav_tbl(k).id;
            END LOOP;
            CLOSE get_rca_id;

        END LOOP;

    END IF;

    IF l_btcv_tbl.COUNT > 0 THEN        -- batch level

        okl_trx_csh_batch_pub.delete_trx_csh_batch( p_api_version   => l_api_version
                                                   ,p_init_msg_list => l_init_msg_list
                                                   ,x_return_status => l_return_status
                                                   ,x_msg_count     => l_msg_count
                                                   ,x_msg_data      => l_msg_data
                                                   ,p_btcv_tbl      => l_btcv_tbl
                                                   );

        IF (l_return_status = OKL_API.g_ret_sts_unexp_error) THEN
            RAISE OKL_API.g_exception_unexpected_error;
        ELSIF (l_return_Status = OKL_API.g_ret_sts_error) THEN
            RAISE OKL_API.g_exception_error;
        END IF;

    END IF;

    IF l_rctv_tbl.COUNT > 0 THEN        -- receipt level


        OKL_INCSH_PVT.delete_internal_trans(p_api_version   => l_api_version ,
                                            p_init_msg_list => l_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            p_rctv_tbl      => l_rctv_tbl
                                           );

        IF (l_return_status = OKL_API.g_ret_sts_unexp_error) THEN
            RAISE OKL_API.g_exception_unexpected_error;
        ELSIF (l_return_Status = OKL_API.g_ret_sts_error) THEN
            RAISE OKL_API.g_exception_error;
        END IF;

    END IF;

    IF l_rcav_tbl.COUNT > 0 THEN        -- receipt application level


        OKL_INCSH_PVT.delete_internal_trans(p_api_version   => l_api_version ,
                                            p_init_msg_list => l_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            p_rcav_tbl      => l_rcav_tbl
                                           );

        IF (l_return_status = OKL_API.g_ret_sts_unexp_error) THEN
            RAISE OKL_API.g_exception_unexpected_error;
        ELSIF (l_return_Status = OKL_API.g_ret_sts_error) THEN
            RAISE OKL_API.g_exception_error;
        END IF;

    END IF;

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

    OKL_API.end_activity(x_msg_count, x_msg_data);

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OKL_API.g_exception_error THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OKL_API.g_exception_unexpected_error THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        OKL_API.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END handle_batch_sumry;
END OKL_BTCH_CASH_SUMRY_PVT;

/
