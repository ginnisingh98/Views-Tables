--------------------------------------------------------
--  DDL for Package Body OKL_VP_PARTY_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_PARTY_PAYMENT_PVT" AS
/* $Header: OKLRVPDB.pls 120.1 2005/11/11 10:22:50 sjalasut noship $ */

   PROCEDURE validate_party_pymnt_record(
     x_return_status                OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PYMNT_RECORD';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

   BEGIN

     x_return_status := l_return_status;
     If( p_srfvv_rec.pay_site_id IS NULL) Then
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Pay Site');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;
     /*
     If( p_srfvv_rec.payment_term_id IS NULL) Then
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payment Term');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;
     If (p_srfvv_rec.payment_method_code IS NULL) Then
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payment Method');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;
     */

   EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_party_pymnt_record;

   PROCEDURE create_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type,
     x_srfvv_rec                    OUT NOCOPY srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     -- sjalasut, added cursor to derive the chr_id for flipping the agreement status to INCOMPLETE
     CURSOR c_get_chr_csr(cp_cpl_id okc_k_party_roles_b.id%TYPE)IS
     SELECT dnz_chr_id
       FROM okc_k_party_roles_b
      WHERE id = cp_cpl_id;
     lv_dnz_chr_id okc_k_headers_b.id%TYPE;

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_PYD_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_rec,
                            x_srfvv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     validate_party_pymnt_record(x_return_status, x_srfvv_rec);
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- sjalasut, added passed_to_incomplete. START
     -- whenever party payment details are created or updated, if the context agreement is PASSED, then
     -- we need to flip back the status to incomplete
     IF(p_srfvv_rec.cpl_id IS NOT NULL AND p_srfvv_rec.cpl_id <> OKL_API.G_MISS_NUM)THEN
       OPEN c_get_chr_csr(cp_cpl_id => p_srfvv_rec.cpl_id); FETCH c_get_chr_csr INTO lv_dnz_chr_id;
       CLOSE c_get_chr_csr;
       IF(lv_dnz_chr_id IS NOT NULL AND lv_dnz_Chr_id <> OKL_API.G_MISS_NUM)THEN -- how can a fetched value be g_miss
         okl_vendor_program_pvt.passed_to_incomplete(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_program_id    => lv_dnz_chr_id
                                                     );
         IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     END IF;
     -- sjalasut, added passed_to_incomplete. END

     x_return_status := l_return_status;
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_party_pymnt_dtls;

   PROCEDURE create_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type,
     x_srfvv_tbl                    OUT NOCOPY srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         create_party_pymnt_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_tbl(i),
                            x_srfvv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_srfvv_tbl.LAST);
       i := p_srfvv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_party_pymnt_dtls;

   PROCEDURE lock_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_PYD_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_party_pymnt_dtls;

   PROCEDURE lock_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         lock_party_pymnt_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_srfvv_tbl.LAST);
       i := p_srfvv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_party_pymnt_dtls;

   PROCEDURE delete_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_PYD_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_party_pymnt_dtls;

   PROCEDURE delete_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         delete_party_pymnt_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_srfvv_tbl.LAST);
       i := p_srfvv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_party_pymnt_dtls;

   PROCEDURE update_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type,
     x_srfvv_rec                    OUT NOCOPY srfvv_rec_type
     ) IS

     -- sjalasut, added cursor to derive the chr_id for flipping the agreement status to INCOMPLETE
     CURSOR c_get_chr_csr(cp_cpl_id okc_k_party_roles_b.id%TYPE)IS
     SELECT dnz_chr_id
       FROM okc_k_party_roles_b
      WHERE id = cp_cpl_id;
     lv_dnz_chr_id okc_k_headers_b.id%TYPE;

     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_PYD_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_rec,
                            x_srfvv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     validate_party_pymnt_record(x_return_status, x_srfvv_rec);
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- sjalasut, added passed_to_incomplete. START
     -- whenever party payment details are created or updated, if the context agreement is PASSED, then
     -- we need to flip back the status to incomplete
     IF(p_srfvv_rec.cpl_id IS NOT NULL AND p_srfvv_rec.cpl_id <> OKL_API.G_MISS_NUM)THEN
       OPEN c_get_chr_csr(cp_cpl_id => p_srfvv_rec.cpl_id); FETCH c_get_chr_csr INTO lv_dnz_chr_id;
       CLOSE c_get_chr_csr;
       IF(lv_dnz_chr_id IS NOT NULL AND lv_dnz_Chr_id <> OKL_API.G_MISS_NUM)THEN -- how can a fetched value be g_miss
         okl_vendor_program_pvt.passed_to_incomplete(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_program_id    => lv_dnz_chr_id
                                                     );
         IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     END IF;
     -- sjalasut, added passed_to_incomplete. END

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_party_pymnt_dtls;

   PROCEDURE update_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type,
     x_srfvv_tbl                    OUT NOCOPY srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;

   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         update_party_pymnt_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_tbl(i),
                            x_srfvv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_srfvv_tbl.LAST);
       i := p_srfvv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_party_pymnt_dtls;

   PROCEDURE validate_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_PYD_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_party_pymnt_dtls;

   PROCEDURE validate_party_pymnt_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PYMNT_DTLS';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         validate_party_pymnt_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_srfvv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_srfvv_tbl.LAST);
       i := p_srfvv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_party_pymnt_dtls;

END OKL_VP_PARTY_PAYMENT_PVT;

/
