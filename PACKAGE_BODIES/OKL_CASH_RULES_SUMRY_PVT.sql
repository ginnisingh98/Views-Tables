--------------------------------------------------------
--  DDL for Package Body OKL_CASH_RULES_SUMRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_RULES_SUMRY_PVT" AS
/* $Header: OKLRCSYB.pls 120.2 2006/07/11 09:44:45 dkagrawa noship $ */

---------------------------------------------------------------------------
-- PROCEDURE handle_cash_sumry
---------------------------------------------------------------------------

PROCEDURE handle_cash_rl_sumry  ( p_api_version	    IN  NUMBER
		                         ,p_init_msg_list   IN  VARCHAR2
				                 ,x_return_status   OUT NOCOPY VARCHAR2
				                 ,x_msg_count	    OUT NOCOPY NUMBER
				                 ,x_msg_data	    OUT NOCOPY VARCHAR2
                                 ,p_cash_rl_tbl     IN  okl_cash_rl_sumry_tbl_type
                                 ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

l_api_version 			        NUMBER := 1;
l_api_name                      CONSTANT VARCHAR2(30) := 'handle_cash_rl_sumry';
l_init_msg_list 		        VARCHAR2(1) ;
l_return_status 		        VARCHAR2(1);
l_msg_count 			        NUMBER := 0;
l_msg_data 				        VARCHAR2(2000);


------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

l_cash_rl_tbl                   OKL_CASH_RL_SUMRY_TBL_TYPE;

l_catv_rec                      OKL_CAT_PVT.CATV_REC_TYPE;
null_catv_rec                   OKL_CAT_PVT.CATV_REC_TYPE;
x_catv_rec                      OKL_CAT_PVT.CATV_REC_TYPE;

l_catv_tbl                      OKL_CAT_PVT.CATV_TBL_TYPE;
x_catv_tbl                      OKL_CAT_PVT.CATV_TBL_TYPE;

-------------------
-- DECLARE Cursors
-------------------
    CURSOR get_this_car_id( p_cat_id NUMBER ) IS
           SELECT B.cau_id, A.NAME, B.DEFAULT_RULE
           FROM   OKL_CSH_ALLCTN_RL_HDR A, OKL_CASH_ALLCTN_RLS B
           WHERE  A.ID = B.CAU_ID
           AND    B.ID = p_cat_id;

    CURSOR get_last_cat_id ( p_car_id NUMBER ) IS
           SELECT ID
           FROM   OKL_CASH_ALLCTN_RLS
           WHERE  cau_ID = p_car_id  AND
                  (end_date >= trunc(sysdate) OR end_date IS NULL)
           ORDER  BY START_DATE DESC;

-------------------
l_this_car_id       OKL_CSH_ALLCTN_RL_HDR.ID%TYPE;
l_last_cat_id       OKL_CSH_ALLCTN_RL_HDR.ID%TYPE;
l_this_car_name     OKL_CSH_ALLCTN_RL_HDR.NAME%TYPE;

l_default_rule      OKL_CASH_ALLCTN_RLS.DEFAULT_RULE%TYPE;

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


    l_cash_rl_tbl := p_cash_rl_tbl;

    FOR i IN  p_cash_rl_tbl.first..p_cash_rl_tbl.LAST LOOP

        -- Initialize Record
        l_catv_rec       := null_catv_rec;
        x_catv_rec       := null_catv_rec;

        --Check if it is the last record
        l_this_car_id    :=  NULL;
        l_last_cat_id    :=  NULL;

        OPEN  get_this_car_id( p_cash_rl_tbl(i).ID );
        FETCH get_this_car_id INTO l_this_car_id, l_this_car_name, l_default_rule;
        CLOSE get_this_car_id;

        OPEN  get_last_cat_id( l_this_car_id );
        FETCH get_last_cat_id INTO l_last_cat_id;
        CLOSE get_last_cat_id;

        IF l_default_rule = 'YES' THEN

            -- You cannot delete default rules.
            OKC_API.set_message( p_app_name      => G_APP_NAME
                                ,p_msg_name      => 'OKL_BPD_CANNOT_DEL_DEF_RL'
                               );

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;


        IF   (p_cash_rl_tbl(i).ID = l_last_cat_id) THEN
            -- Populate Record for Update
            l_catv_rec.ID       := p_cash_rl_tbl(i).ID;
            l_catv_rec.END_DATE := (TRUNC(SYSDATE) - 1);

            Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls( p_api_version    => p_api_version
                                                       ,p_init_msg_list  => p_init_msg_list
                                                       ,x_return_status  => l_return_status
                                                       ,x_msg_count      => l_msg_count
                                                       ,x_msg_data       => l_msg_data
                                                       ,p_catv_rec       => l_catv_rec
                                                       ,x_catv_rec       => x_catv_rec
                                                      );

            IF (l_return_status = OKL_API.g_ret_sts_unexp_error) THEN
                RAISE OKL_API.g_exception_unexpected_error;
            ELSIF (l_return_Status = OKL_API.g_ret_sts_error) THEN
                RAISE OKL_API.g_exception_error;
            END IF;
        ELSE

                -- Cash application rule NAME has one or more future versions.  Please delete these first.
                OKC_API.set_message( p_app_name      => G_APP_NAME
                                    ,p_msg_name      => 'OKL_BPD_DEL_FUT_RLS_FIRST'
                                    ,p_token1        => 'NAME'
                                    ,p_token1_value  => l_this_car_name
                                   );

            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END LOOP;

    /*
    IF l_cash_rl_tbl.COUNT > 0 THEN

        LOOP

            EXIT WHEN (i = l_cash_rl_tbl.LAST);
            i := i + 1;

            -- for the rules to be de-activated, set the end date to sysdate - 1

            l_catv_tbl(i).ID := l_cash_rl_tbl(i).ID;
            l_catv_tbl(i).END_DATE := (TRUNC(SYSDATE) - 1);

        END LOOP;

        -- update okl_cash_allctn_rls table

        Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls( p_api_version    => p_api_version
                                                       ,p_init_msg_list  => p_init_msg_list
                                                       ,x_return_status  => l_return_status
                                                       ,x_msg_count      => l_msg_count
                                                       ,x_msg_data       => l_msg_data
                                                       ,p_catv_tbl       => l_catv_tbl
                                                       ,x_catv_tbl       => l_catv_tbl
                                                      );

        IF (l_return_status = OKL_API.g_ret_sts_unexp_error) THEN
            RAISE OKL_API.g_exception_unexpected_error;
        ELSIF (l_return_Status = OKL_API.g_ret_sts_error) THEN
            RAISE OKL_API.g_exception_error;
        END IF;

    END IF;
    */

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

END handle_cash_rl_sumry;
END OKL_CASH_RULES_SUMRY_PVT;

/
