--------------------------------------------------------
--  DDL for Package Body OKL_LPO_STRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LPO_STRM_PVT" AS
/* $Header: OKLRLSXB.pls 120.2 2005/10/30 04:34:58 appldev noship $ */

  PROCEDURE create_lpo_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_lpo_id						IN  NUMBER
     ) IS

    l_slx_rec            			SLX_REC_TYPE;
    x_slx_rec            			SLX_REC_TYPE;
    p_slx_rec            			SLX_REC_TYPE;

    l_return_status                 VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
    l_found							BOOLEAN;


    CURSOR l_slx_csr IS
		   /*SELECT distinct id
		   FROM okl_strm_type_b
		   WHERE BILLABLE_YN = 'Y';*/
		   SELECT sty_id
		   FROM okl_strm_tmpt_all_types_uv sty
		   WHERE sty.BILLABLE_YN = 'Y'
           and not exists (select 1 from OKL_STRM_TYPE_EXEMPT_V sem
                           where sem.lpo_id = p_lpo_id
                           and   sem.sty_id = sty.sty_id);

    BEGIN
  		FOR l_sty_rec IN l_slx_csr
        LOOP

		l_slx_rec.lpo_id 					:= p_lpo_id;
		l_slx_rec.sty_id 					:= l_sty_rec.sty_id;
		l_slx_rec.late_policy_exempt_yn		:= 'N';


        okl_strm_type_exempt_pub.insert_strm_type_exempt(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_slxv_rec	   => l_slx_rec
                          ,x_slxv_rec	   => p_slx_rec
                          );

--        IF (x_return_Status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--			   Okl_Accounting_Util.get_error_message(x_msg_count, l_msg_data);
--        END IF;


      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  END LOOP;

	    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;


END create_lpo_streams;
END OKL_LPO_STRM_PVT;

/
