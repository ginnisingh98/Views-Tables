--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_RFND_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_RFND_DTLS_PVT" AS
/* $Header: OKLRSRFB.pls 120.4 2006/02/22 17:37:28 rpillay noship $ */

   PROCEDURE validate_refund_record(
     x_return_status                OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_REFUND_RECORD';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     --cursor to find if vendor id is the subsidy provider party
     cursor l_cplb_csr(p_vendor_id in number,
                       p_cpl_id    in number) is
     select 'Y'
     from   okc_k_party_roles_b cplb
     where  id   = p_cpl_id
     and    object1_id1 = to_char(p_vendor_id);

     l_exists varchar2(1) default 'N';

   BEGIN

     x_return_status := l_return_status;
     If( p_srfvv_rec.pay_site_id IS NULL) Then
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Pay Site');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;
/*     If( p_srfvv_rec.payment_term_id IS NULL) Then
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
     --validate vendor id
     l_exists := 'N';
     open l_cplb_csr(p_vendor_id => p_srfvv_rec.vendor_id,
                     p_cpl_id    => p_srfvv_rec.cpl_id);
     fetch l_cplb_csr into l_exists;
     if l_cplb_csr%NOTFOUND then
         Null;
     end if;
     close l_cplb_csr;
     If l_exists = 'N' then
         OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Vendor_Id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;
     --end validate vendor id

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
   END validate_refund_record;

   PROCEDURE create_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type,
     x_srfvv_rec                    OUT NOCOPY srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     --Bug# 4959361
     CURSOR l_cpl_csr(p_cpl_id IN NUMBER) IS
     SELECT cle_id
     FROM okc_k_party_roles_b cpl
     WHERE cpl.id = p_cpl_id;

     l_cpl_rec l_cpl_csr%ROWTYPE;
     --Bug# 4959361

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

     --Bug# 4959361
     OPEN l_cpl_csr(p_cpl_id => p_srfvv_rec.cpl_id);
     FETCH l_cpl_csr INTO l_cpl_rec;
     CLOSE l_cpl_csr;

     IF l_cpl_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_cpl_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

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

     validate_refund_record(x_return_status, x_srfvv_rec);
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

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
   END create_refund_dtls;

   PROCEDURE create_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type,
     x_srfvv_tbl                    OUT NOCOPY srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         create_refund_dtls(p_api_version,
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
   END create_refund_dtls;

   PROCEDURE lock_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_SUBSIDY_REFUND';
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
   END lock_refund_dtls;

   PROCEDURE lock_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         lock_refund_dtls(p_api_version,
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
   END lock_refund_dtls;

   PROCEDURE delete_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     --Bug# 4959361
     CURSOR l_cpl_csr(p_pyd_id IN NUMBER) IS
     SELECT cpl.cle_id
     FROM  okc_k_party_roles_b cpl,
           okl_party_payment_dtls pyd
     WHERE pyd.id = p_pyd_id
     AND   cpl.id = pyd.cpl_id;

     l_cpl_rec l_cpl_csr%ROWTYPE;
     --Bug# 4959361

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

     --Bug# 4959361
     OPEN l_cpl_csr(p_pyd_id => p_srfvv_rec.id);
     FETCH l_cpl_csr INTO l_cpl_rec;
     CLOSE l_cpl_csr;

     IF l_cpl_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_cpl_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

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
   END delete_refund_dtls;

   PROCEDURE delete_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         delete_refund_dtls(p_api_version,
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
   END delete_refund_dtls;

   PROCEDURE update_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type,
     x_srfvv_rec                    OUT NOCOPY srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     --Bug# 4959361
     CURSOR l_cpl_csr(p_cpl_id IN NUMBER) IS
     SELECT cle_id
     FROM okc_k_party_roles_b cpl
     WHERE cpl.id = p_cpl_id;

     l_cpl_rec l_cpl_csr%ROWTYPE;
     --Bug# 4959361

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

     --Bug# 4959361
     OPEN l_cpl_csr(p_cpl_id => p_srfvv_rec.cpl_id);
     FETCH l_cpl_csr INTO l_cpl_rec;
     CLOSE l_cpl_csr;

     IF l_cpl_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_cpl_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

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

     validate_refund_record(x_return_status, x_srfvv_rec);
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

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
   END update_refund_dtls;

   PROCEDURE update_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type,
     x_srfvv_tbl                    OUT NOCOPY srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;

   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         update_refund_dtls(p_api_version,
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
   END update_refund_dtls;

   PROCEDURE validate_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_rec                    IN srfvv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY_REFUND';
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
   END validate_refund_dtls;

   PROCEDURE validate_refund_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_srfvv_tbl                    IN srfvv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY_REFUND';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_srfvv_tbl.COUNT > 0 Then
       i := p_srfvv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         validate_refund_dtls(p_api_version,
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
   END validate_refund_dtls;

END OKL_SUBSIDY_RFND_DTLS_PVT;

/
