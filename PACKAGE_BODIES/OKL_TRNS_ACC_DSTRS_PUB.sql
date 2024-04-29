--------------------------------------------------------
--  DDL for Package Body OKL_TRNS_ACC_DSTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRNS_ACC_DSTRS_PUB" AS
/* $Header: OKLPTABB.pls 120.6.12010000.3 2008/10/01 23:23:19 rkuttiya ship $ */

  PROCEDURE add_language IS
  BEGIN
--    okl_tab_pvt.add_language;
    NULL;
  END add_language;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ae_line_type
  ---------------------------------------------------------------------------
    PROCEDURE validate_ae_line_type(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS
    l_dummy			      VARCHAR2(1) ;
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tabv_rec.ae_line_type IS NULL) OR (p_tabv_rec.ae_line_type = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'AE_LINE_TYPE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                   (p_lookup_type => 'OKL_ACCOUNTING_LINE_TYPE',
                    p_lookup_code => p_tabv_rec.ae_line_type);
    IF l_dummy = okl_api.g_false THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'ae_line_type');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ae_line_type;

---------------------------------------------------------------------------
  -- PROCEDURE validate_cr_dr_flag
---------------------------------------------------------------------------
    PROCEDURE validate_cr_dr_flag(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS

    l_dummy			      VARCHAR2(1) := OKC_API.G_FALSE;
    l_app_id  NUMBER := 101;
    l_view_app_id NUMBER := 101;
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tabv_rec.cr_dr_flag IS NULL) OR (p_tabv_rec.cr_dr_flag = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'cr_dr_flag');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                        (p_lookup_type => 'CR_DR',
                         p_lookup_code => p_tabv_rec.cr_dr_flag,
                         p_app_id      => l_app_id,
                         p_view_app_id => l_view_app_id);

    IF (l_dummy  = okc_api.G_FALSE) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'cr_dr_flag');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_cr_dr_flag;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ccid
  ---------------------------------------------------------------------------
    PROCEDURE validate_ccid(
      x_return_status OUT NOCOPY VARCHAR2,
      p_tabv_rec IN  tabv_rec_type
    ) IS
    l_dummy			      VARCHAR2(1) := okl_api.g_false;
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tabv_rec.code_combination_id IS NULL) OR (p_tabv_rec.code_combination_id = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ACCOUNT');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
 EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ccid;
---------------------------------------------------------------------------
  -- FUNCTION validate_Attributes_for_ats
 ---------------------------------------------------------------------------
 FUNCTION validate_Attributes_for_ats (
    p_tabv_rec IN  tabv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
     validate_ccid(x_return_status, p_tabv_rec);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
     validate_cr_dr_flag(x_return_status, p_tabv_rec);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
     validate_ae_line_type(x_return_status, p_tabv_rec);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;
RETURN(l_return_status);
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
END validate_Attributes_for_ats;

 ---------------------------------------------------------------------------
  -- PROCEDURE insert_trns_acc_dstrs
 ---------------------------------------------------------------------------

  PROCEDURE insert_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_rec                     IN  tabv_rec_type
                        ,x_tabv_rec                     OUT NOCOPY tabv_rec_type
                        ) IS
    l_tabv_rec                        tabv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_trns_acc_dstrs';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_acct_der          VARCHAR(4);
    l_row_notfound                    BOOLEAN := FALSE;
    item_not_found_error              EXCEPTION;
    CURSOR acc_temp_name_csr(template_id NUMBER) IS
    SELECT NAME
    FROM okl_ae_templates
    WHERE id = template_id;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_trns_acc_dstrs;
    l_tabv_rec := p_tabv_rec;
-- Added as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 start
 IF(p_tabv_rec.template_id IS NOT NULL AND p_tabv_rec.template_id <> Okc_Api.G_MISS_NUM) THEN
    IF(p_tabv_rec.accounting_template_name IS NULL OR p_tabv_rec.accounting_template_name = OKC_API.G_MISS_CHAR) THEN
      OPEN acc_temp_name_csr(p_tabv_rec.template_id);
      FETCH acc_temp_name_csr INTO l_tabv_rec.accounting_template_name;
      l_row_notfound := acc_temp_name_csr%NOTFOUND;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_ID');
          RAISE item_not_found_error;
        END IF;
      CLOSE acc_temp_name_csr;

    END IF;
  END IF;
    l_acct_der := okl_Accounting_util.get_account_derivation;
    IF(l_acct_der='ATS') THEN
      l_return_status := validate_Attributes_for_ats(p_tabv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

-- Added as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 end
    okl_tab_pvt.insert_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_tabv_rec      => l_tabv_rec
                              ,x_tabv_rec      => x_tabv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_tabv_rec := x_tabv_rec;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','insert_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_trns_acc_dstrs;


  PROCEDURE insert_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_tbl                     IN  tabv_tbl_type
                        ,x_tabv_tbl                     OUT NOCOPY tabv_tbl_type
                        ) IS
    l_tabv_tbl                        tabv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                        NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_trns_acc_dstrs;
    l_tabv_tbl :=  p_tabv_tbl;



    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;

      LOOP
        insert_trns_acc_dstrs (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tabv_rec      => p_tabv_tbl(i)
                          ,x_tabv_rec      => x_tabv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_tabv_tbl.LAST);

          i := p_tabv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local table structure using output table from pvt api */
    l_tabv_tbl := x_tabv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','insert_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_trns_acc_dstrs;

  PROCEDURE lock_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_rec                     IN  tabv_rec_type
                        ) IS

    l_tabv_rec                        tabv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_trns_acc_dstrs;
    l_tabv_rec := p_tabv_rec;

    okl_tab_pvt.lock_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_tabv_rec      => l_tabv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','lock_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_trns_acc_dstrs;

  PROCEDURE lock_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_tbl                     IN  tabv_tbl_type
                        ) IS

    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_trns_acc_dstrs;

    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;

      LOOP
        lock_trns_acc_dstrs (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tabv_rec      => p_tabv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
 		 	    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_tabv_tbl.LAST);

          i := p_tabv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','lock_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_trns_acc_dstrs;

  PROCEDURE update_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_rec                     IN  tabv_rec_type
                        ,x_tabv_rec                     OUT NOCOPY tabv_rec_type
                        ) IS
    l_tabv_rec                        tabv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_trns_acc_dstrs;
    l_tabv_rec := p_tabv_rec;



    okl_tab_pvt.update_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_tabv_rec      => l_tabv_rec
                              ,x_tabv_rec      => x_tabv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_tabv_rec := x_tabv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','update_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_trns_acc_dstrs;


  PROCEDURE update_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_tbl                     IN  tabv_tbl_type
                        ,x_tabv_tbl                     OUT NOCOPY tabv_tbl_type
                        ) IS
    l_tabv_tbl                        tabv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_trns_acc_dstrs;
    l_tabv_tbl :=  p_tabv_tbl;



    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;

      LOOP
        update_trns_acc_dstrs (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tabv_rec      => p_tabv_tbl(i)
                          ,x_tabv_rec      => x_tabv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_tabv_tbl.LAST);

          i := p_tabv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local table structure using output table from pvt api */
    l_tabv_tbl := x_tabv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','update_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_trns_acc_dstrs;

  PROCEDURE delete_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_rec                     IN  tabv_rec_type
                        ) IS
    l_tabv_rec                        tabv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;


-- Added by Santonyr to fix the bug 3089327 on 07th Aug, 2003

  l_tcn_id OKL_TRX_CONTRACTS.ID%TYPE;
  l_tsu_code OKL_TRX_CONTRACTS.TSU_CODE%TYPE;

  CURSOR tcl_csr(v_source_id NUMBER) IS
  SELECT tcn_id
  FROM OKL_TXL_CNTRCT_LNS
  WHERE ID = v_source_id;

  CURSOR tcn_csr(v_tcn_id NUMBER) IS
  SELECT tsu_code
  FROM OKL_TRX_CONTRACTS
  WHERE ID = v_tcn_id;
--
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_trns_acc_dstrs;
    l_tabv_rec := p_tabv_rec;



-- Added by Santonyr to fix the bug 3089327 on 07th Aug, 2003

   OPEN tcl_csr(l_tabv_rec.source_id);
   FETCH tcl_csr INTO l_tcn_id;
   CLOSE tcl_csr;

   OPEN tcn_csr(l_tcn_id);
   FETCH tcn_csr INTO l_tsu_code;
   CLOSE tcn_csr;

   IF (l_tsu_code = 'CANCELED') THEN

      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_TRX_CANCELED');

      RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;


    okl_tab_pvt.delete_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_tabv_rec      => l_tabv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','delete_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_trns_acc_dstrs;


  PROCEDURE delete_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_tbl                     IN  tabv_tbl_type
                        ) IS
    l_tabv_tbl                        tabv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_trns_acc_dstrs;
    l_tabv_tbl :=  p_tabv_tbl;



    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;

      LOOP
        delete_trns_acc_dstrs (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tabv_rec      => p_tabv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_tabv_tbl.LAST);

          i := p_tabv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','delete_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_trns_acc_dstrs;

  PROCEDURE validate_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_rec                     IN  tabv_rec_type
                        ) IS
    l_tabv_rec                        tabv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_trns_acc_dstrs;
    l_tabv_rec := p_tabv_rec;



    okl_tab_pvt.validate_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_tabv_rec      => l_tabv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','validate_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_trns_acc_dstrs;


  PROCEDURE validate_trns_acc_dstrs(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_tabv_tbl                     IN  tabv_tbl_type
                        ) IS
    l_tabv_tbl                        tabv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_trns_acc_dstrs';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_trns_acc_dstrs;
    l_tabv_tbl :=  p_tabv_tbl;



    IF (p_tabv_tbl.COUNT > 0) THEN
      i := p_tabv_tbl.FIRST;

      LOOP
        validate_trns_acc_dstrs (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tabv_rec      => p_tabv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_tabv_tbl.LAST);

          i := p_tabv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_trns_acc_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRNS_ACC_DSTRS_PUB','validate_trns_acc_dstrs');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_trns_acc_dstrs;


END OKL_TRNS_ACC_DSTRS_PUB;

/
