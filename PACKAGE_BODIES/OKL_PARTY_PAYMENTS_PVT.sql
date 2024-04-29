--------------------------------------------------------
--  DDL for Package Body OKL_PARTY_PAYMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PARTY_PAYMENTS_PVT" AS
/* $Header: OKLRPPMB.pls 120.2 2006/02/24 21:31:35 rpillay noship $ */


  --------------------------------------------------------
  -- Get cle related infor for evg migration            --
  --------------------------------------------------------

   PROCEDURE create_evgrn_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
	p_vendor_id					   IN NUMBER,
	x_cpl_id					   OUT NOCOPY NUMBER
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_EVGRN_PARTY_ROLES';
     l_return_status     VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status    VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;

	 CURSOR chr_party_role_csr (p_chr_id IN NUMBER, p_vendor_id IN NUMBER) IS
	 SELECT '1'
	 FROM okc_k_party_roles_b cpl
	 WHERE  cpl.chr_id = p_chr_id
	 AND    cpl.rle_code='OKL_VENDOR'
	 AND    cpl.object1_id1 = p_vendor_id;

	 l_chr_role_exists VARCHAR2(1);
	 l_cplv_rec  cplv_rec_type;
	 x_cplv_rec  cplv_rec_type;

       --Bug# 4558486
       l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
       x_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

   BEGIN
     -- Create party if evg vendor does not exists in contract parties --
     OPEN chr_party_role_csr (p_chr_id, p_vendor_id);
	 FETCH chr_party_role_csr INTO l_chr_role_exists;
	 CLOSE chr_party_role_csr;

	 IF (l_chr_role_exists IS NULL) THEN
       l_cplv_rec := NULL;
	   l_cplv_rec.chr_id     := p_chr_id;
	   l_cplv_rec.dnz_chr_id := p_chr_id;
       l_cplv_rec.cle_id     := NULL;

       l_cplv_rec.object1_id1         := TO_CHAR(p_vendor_id);
       l_cplv_rec.object1_id2       := '#';
       l_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
       l_cplv_rec.rle_code          := 'OKL_VENDOR';

         --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
         --              to create records in tables
         --              okc_k_party_roles_b and okl_k_party_roles
         /*
	   Okl_Okc_Migration_Pvt.create_k_party_role(
                                                p_api_version   => 1.0,
                                                p_init_msg_list => Okl_Api.G_FALSE,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_cplv_rec      => l_cplv_rec,
                                                x_cplv_rec      => x_cplv_rec
                                               );
         */

         okl_k_party_roles_pvt.create_k_party_role(
           p_api_version      => 1.0,
           p_init_msg_list    => Okl_Api.G_FALSE,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_cplv_rec         => l_cplv_rec,
           x_cplv_rec         => x_cplv_rec,
           p_kplv_rec         => l_kplv_rec,
           x_kplv_rec         => x_kplv_rec);

       IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
     END IF;
	 x_cpl_id := x_cplv_rec.id;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN

     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_evgrn_party_roles;

  --------------------------------------------------------
  -- Get cle related infor for evg migration            --
  --------------------------------------------------------

   PROCEDURE create_evgrn_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
	p_vendor_id					   IN NUMBER,
	x_cle_tbl					   OUT NOCOPY evg_cle_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_EVGRN_PARTY_ROLES';
     l_return_status     VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status    VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                   NUMBER        := 0;
     lx_cle_tbl          evg_cle_tbl_type;

	 CURSOR chr_party_role_csr (p_chr_id IN NUMBER, p_vendor_id IN NUMBER) IS
	 SELECT '1'
	 FROM okc_k_party_roles_b cpl
	 WHERE  cpl.chr_id = p_chr_id
	 AND    cpl.rle_code='OKL_VENDOR'
	 AND    cpl.object1_id1 = p_vendor_id;

	 l_chr_role_exists VARCHAR2(1);
	 l_cplv_rec  cplv_rec_type;
	 x_cplv_rec  cplv_rec_type;

	 CURSOR lines_csr (p_chr_id IN NUMBER) IS
	 SELECT cle.id,
	 		cle.start_date
	 FROM okc_k_lines_v cle,
     	  OKL_K_LINES kle,
	 	  okc_line_styles_b lse
	 WHERE cle.id = kle.id
	 AND   lse.id = cle.lse_id
	 AND   cle.dnz_chr_id = p_chr_id
	 --AND   lse.lty_code IN ('FREE_FORM1','SOLD_SERVICE')
	 AND   lse.lty_code = 'SOLD_SERVICE'
     AND   cle.sts_code NOT IN ('ABANDONED','CANCELLED','EXPIRED','TERMINATED');

     TYPE line_tbl_type IS TABLE OF lines_csr%ROWTYPE;
     l_line_tbl line_tbl_type;

	 CURSOR cle_party_role_csr (p_chr_id IN NUMBER, p_cle_id IN NUMBER,p_vendor_id IN NUMBER) IS
	 SELECT id
	 FROM okc_k_party_roles_b
	 WHERE dnz_chr_id = p_chr_id
	 AND cle_id = p_cle_id
	 AND rle_code='OKL_VENDOR'
	 AND object1_id1 = p_vendor_id;

	 l_cpl_id  NUMBER;

       --Bug# 4558486
       l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
       x_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

   BEGIN
     -- Create party if evg vendor does not exists in contract parties --
     OPEN chr_party_role_csr (p_chr_id, p_vendor_id);
	 FETCH chr_party_role_csr INTO l_chr_role_exists;
	 CLOSE chr_party_role_csr;

	 IF (l_chr_role_exists IS NULL) THEN
       l_cplv_rec := NULL;
	   l_cplv_rec.chr_id     := p_chr_id;
	   l_cplv_rec.dnz_chr_id := p_chr_id;
       l_cplv_rec.cle_id     := NULL;

       l_cplv_rec.object1_id1         := TO_CHAR(p_vendor_id);
       l_cplv_rec.object1_id2       := '#';
       l_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
       l_cplv_rec.rle_code          := 'OKL_VENDOR';

         --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
         --              to create records in tables
         --              okc_k_party_roles_b and okl_k_party_roles
         /*
	   Okl_Okc_Migration_Pvt.create_k_party_role(
                                                p_api_version   => 1.0,
                                                p_init_msg_list => Okl_Api.G_FALSE,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_cplv_rec      => l_cplv_rec,
                                                x_cplv_rec      => x_cplv_rec
                                               );
         */

         okl_k_party_roles_pvt.create_k_party_role(
           p_api_version      => 1.0,
           p_init_msg_list    => Okl_Api.G_FALSE,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_cplv_rec         => l_cplv_rec,
           x_cplv_rec         => x_cplv_rec,
           p_kplv_rec         => l_kplv_rec,
           x_kplv_rec         => x_kplv_rec);

       IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
     END IF;

	 -- Find out service lines for the contract --
     OPEN lines_csr (p_chr_id);
     FETCH lines_csr BULK COLLECT INTO l_line_tbl;
     CLOSE lines_csr;

	 i:= 0;
     IF l_line_tbl.COUNT > 0 THEN
       i := l_line_tbl.FIRST;
       LOOP
	     -- find out same party as evg vendor for the line--
         OPEN cle_party_role_csr (p_chr_id, l_line_tbl(i).id, p_vendor_id);
	     FETCH cle_party_role_csr INTO l_cpl_id;
	     CLOSE cle_party_role_csr;

	     IF (l_cpl_id IS NULL) THEN
	       l_cplv_rec := NULL;
	       l_cplv_rec.chr_id     := NULL;
           l_cplv_rec.dnz_chr_id := p_chr_id;
	       l_cplv_rec.cle_id := l_line_tbl(i).id;

           l_cplv_rec.object1_id1         := TO_CHAR(p_vendor_id);
           l_cplv_rec.object1_id2       := '#';
           l_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
           l_cplv_rec.rle_code          := 'OKL_VENDOR';

               --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
               --              to create records in tables
               --              okc_k_party_roles_b and okl_k_party_roles
               /*
		   Okl_Okc_Migration_Pvt.create_k_party_role(
                                                p_api_version   => 1.0,
                                                p_init_msg_list => Okl_Api.G_FALSE,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_cplv_rec      => l_cplv_rec,
                                                x_cplv_rec      => x_cplv_rec
                                               );
               */

               okl_k_party_roles_pvt.create_k_party_role(
                 p_api_version      => 1.0,
                 p_init_msg_list    => Okl_Api.G_FALSE,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_cplv_rec         => l_cplv_rec,
                 x_cplv_rec         => x_cplv_rec,
                 p_kplv_rec         => l_kplv_rec,
                 x_kplv_rec         => x_kplv_rec);

           lx_cle_tbl(i).cle_id := x_cplv_rec.cle_id;
           lx_cle_tbl(i).cpl_id := x_cplv_rec.id;
           lx_cle_tbl(i).cle_start_date :=  l_line_tbl(i).start_date;

           IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
             RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;
		 ELSE
           lx_cle_tbl(i).cle_id := l_line_tbl(i).id;
           lx_cle_tbl(i).cpl_id := l_cpl_id;
           lx_cle_tbl(i).cle_start_date :=  l_line_tbl(i).start_date;
         END IF;

         -- populate the out parameter --
         x_cle_tbl(i).cle_id := lx_cle_tbl(i).cle_id;
         x_cle_tbl(i).cpl_id := lx_cle_tbl(i).cpl_id;
         x_cle_tbl(i).cle_start_date := lx_cle_tbl(i).cle_start_date;

       EXIT WHEN (i = l_line_tbl.LAST);
       i := l_line_tbl.NEXT(i);
       END LOOP;
     END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN

     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_evgrn_party_roles;


  --------------------------------------------------------
  -- Validations for the header
  --------------------------------------------------------

  PROCEDURE validate_hdr_record (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type
    ) IS
	l_api_name        	VARCHAR2(30) := 'VALIDATE_HDR_RECORD';
    l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := l_return_status;
     IF (p_pphv_rec.passthru_term = 'BASE' ) THEN
	    IF (p_pphv_rec.payout_basis NOT IN ('BILLING','DUE_DATE','PARTIAL_RECEIPT','FULL_RECEIPT')) THEN
           Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,
		                    G_COL_NAME_TOKEN,'Payout Basis');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

        IF (p_pphv_rec.passthru_start_date IS NULL) THEN
           Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Passthru Start Date');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

     END IF;

     IF (p_pphv_rec.passthru_term = 'EVERGREEN') THEN

	   IF (p_pphv_rec.payout_basis NOT IN ('BILLING','FORMULA','PARTIAL_RECEIPT','FULL_RECEIPT')) THEN
         Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,
		                    G_COL_NAME_TOKEN,'Payout Basis');
         x_return_status := Okl_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
	   END IF;

       IF (p_pphv_rec.payout_basis = 'FORMULA') THEN
         IF (p_pphv_rec.passthru_stream_type_id IS NULL) THEN
           Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Passthru Stream Type');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
		 END IF;

         IF (p_pphv_rec.payout_basis_formula IS NULL) THEN
           Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payout Basis Formula');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
	   END IF;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END validate_hdr_record;

   PROCEDURE create_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type,
    x_pphv_rec                     OUT NOCOPY pphv_rec_type
	) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

	 CURSOR get_start_date_csr (p_chr_id NUMBER)IS
	 SELECT start_date
	 FROM okc_k_headers_b
	 WHERE id = p_chr_id;
	 l_start_date		 DATE;
	 l_pphv_rec			 pphv_rec_type;

	 -- fmiao 25-OCT-2005 cle_id can be null in case of EVERGREEN
	 -- for all asset line on contract level, hence the DEFAILT --
	 CURSOR check_duplicate_csr (p_chr_id NUMBER,
	 							 p_cle_id NUMBER,
								 p_passthru_term VARCHAR2) IS
	 SELECT '1'
	 FROM OKL_PARTY_PAYMENT_HDR
	 WHERE dnz_chr_id = p_chr_id
	 AND   NVL(cle_id,-1) = NVL(p_cle_id,-1)
	 AND   passthru_term = p_passthru_term;
	 l_exist VARCHAR2(1);
   BEGIN

     x_return_status := l_return_status;

     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);

     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
     IF p_pphv_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => p_pphv_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

	 -- Check duplidates: each line should have only 1 BASE or/and 1 EVERGREEN --
	 OPEN check_duplicate_csr (p_pphv_rec.dnz_chr_id,
	 	  					   p_pphv_rec.cle_id,
							   p_pphv_rec.passthru_term);
	 FETCH check_duplicate_csr INTO l_exist;
	 CLOSE check_duplicate_csr;
	 IF (l_exist IS NOT NULL) THEN
	   Okc_Api.SET_MESSAGE( p_app_name => g_app_name,
                            p_msg_name => 'OKL_PPM_PASSTHRU_TERM_EXISTS'
                           );
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
	 END IF;

	 -- Defaulting effective_from from contract start date--
	 OPEN get_start_date_csr (p_pphv_rec.dnz_chr_id);
	 FETCH get_start_date_csr INTO l_start_date;
	 CLOSE get_start_date_csr;

	 l_pphv_rec := p_pphv_rec;
	 l_pphv_rec.effective_from := l_start_date;

     Okl_Ldb_Pvt.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_pphv_rec,
                            x_pphv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     validate_hdr_record(x_return_status, x_pphv_rec);

     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;
	 x_return_status := l_return_status;

	 -- Bug 4917691: fmiao start
	 -- Need to change contract status to INCOMPLETE when create/update ppy
	 -- cascade edit status on to lines
	 okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_chr_id          => l_pphv_rec.dnz_chr_id);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
       raise OKL_API.G_EXCEPTION_ERROR;
     End If;
	 -- Bug 4917691: fmiao end

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_party_payment_hdr;

   PROCEDURE create_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_tbl                     IN pphv_tbl_type,
     x_pphv_tbl                     OUT NOCOPY pphv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_pphv_tbl.COUNT > 0 THEN
       i := p_pphv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         create_party_payment_hdr(p_api_version,
                           		  p_init_msg_list,
                          		  x_return_status,
                            	  x_msg_count,
                            	  x_msg_data,
                            	  p_pphv_tbl(i),
                            	  x_pphv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_pphv_tbl.LAST);
       i := p_pphv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_party_payment_hdr;

   PROCEDURE lock_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_rec                    IN pphv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     Okl_Ldb_Pvt.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_pphv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_party_payment_hdr;

   PROCEDURE lock_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_tbl                     IN pphv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_pphv_tbl.COUNT > 0 THEN
       i := p_pphv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         lock_party_payment_hdr(p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_pphv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_pphv_tbl.LAST);
       i := p_pphv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_party_payment_hdr;

   PROCEDURE delete_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_rec                    IN pphv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

     --Bug# 4959361
     CURSOR l_pph_csr(p_pph_id IN NUMBER) IS
     SELECT cle_id
     FROM okl_party_payment_hdr pph
     WHERE pph.id = p_pph_id;

     l_pph_rec l_pph_csr%ROWTYPE;
     --Bug# 4959361

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
     OPEN l_pph_csr(p_pph_id => p_pphv_rec.id);
     FETCH l_pph_csr INTO l_pph_rec;
     CLOSE l_pph_csr;

     IF l_pph_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_pph_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

     Okl_Ldb_Pvt.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_pphv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_party_payment_hdr;

   PROCEDURE delete_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_tbl                     IN pphv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_pphv_tbl.COUNT > 0 THEN
       i := p_pphv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         delete_party_payment_hdr(p_api_version,
                                  p_init_msg_list,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data,
                                  p_pphv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_pphv_tbl.LAST);
       i := p_pphv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_party_payment_hdr;

   PROCEDURE update_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_rec                     IN pphv_rec_type,
     x_pphv_rec                     OUT NOCOPY pphv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

     --Bug# 4959361
     CURSOR l_pph_csr(p_pph_id IN NUMBER) IS
     SELECT cle_id
     FROM okl_party_payment_hdr pph
     WHERE pph.id = p_pph_id;

     l_pph_rec l_pph_csr%ROWTYPE;
     --Bug# 4959361

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
     OPEN l_pph_csr(p_pph_id => p_pphv_rec.id);
     FETCH l_pph_csr INTO l_pph_rec;
     CLOSE l_pph_csr;

     IF l_pph_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_pph_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

     Okl_Ldb_Pvt.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_pphv_rec,
                            x_pphv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     validate_hdr_record(x_return_status, x_pphv_rec);

     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

	 -- Bug 4917691: fmiao start
	 -- Need to change contract status to INCOMPLETE when create/update ppy
	 -- cascade edit status on to lines
	 okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_chr_id          => x_pphv_rec.dnz_chr_id);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
       raise OKL_API.G_EXCEPTION_ERROR;
     End If;
	 -- Bug 4917691: fmiao end

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_party_payment_hdr;

   PROCEDURE update_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_tbl                     IN pphv_tbl_type,
     x_pphv_tbl                     OUT NOCOPY pphv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;

   BEGIN

     IF p_pphv_tbl.COUNT > 0 THEN
       i := p_pphv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         update_party_payment_hdr(p_api_version,
                                  p_init_msg_list,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data,
                                  p_pphv_tbl(i),
                                  x_pphv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_pphv_tbl.LAST);
       i := p_pphv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_party_payment_hdr;

   PROCEDURE validate_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_rec                     IN pphv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     Okl_Ldb_Pvt.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_pphv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_party_payment_hdr;

   PROCEDURE validate_party_payment_hdr(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pphv_tbl                     IN pphv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PAYMENT_HDR';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_pphv_tbl.COUNT > 0 THEN
       i := p_pphv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         validate_party_payment_hdr(p_api_version,
                          		    p_init_msg_list,
                          			x_return_status,
                          			x_msg_count,
                         			x_msg_data,
                          			p_pphv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_pphv_tbl.LAST);
       i := p_pphv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_party_payment_hdr;

   ------------------------------------------------------------------
   --Processing for the details -- for qa checker                  --
   --not used currently                                            --
   --NOTES: handle cle_id optional when use this procedure         --
   ------------------------------------------------------------------
   PROCEDURE validate_passthru_qa (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER
                     ) AS
      l_api_name        VARCHAR2(30) := 'validate_passthru_qa';
      l_api_version     CONSTANT NUMBER     := 1.0;

    CURSOR line_amount_csr(p_chr_id IN NUMBER) IS
    SELECT kle.amount,
		   kle.id
    FROM okc_k_lines_b cle,
         OKL_K_LINES kle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND   cle.chr_id =  p_chr_id
    AND   kle.id = cle.id
    AND   cle.lse_id = lse.id
    AND   lse.lty_code IN ('FEE', 'SOLD_SERVICE');

	l_kle_amount   OKL_K_LINES.amount%TYPE := 0;
	l_kle_id       OKL_K_LINES.id%TYPE;

	CURSOR vendor_amount_csr(p_cle_id IN NUMBER, p_chr_id IN NUMBER) IS
    SELECT pyd.disbursement_basis,
		   pyd.disbursement_fixed_amount,
		   pyd.disbursement_percent,
		   pyd.vendor_id
    FROM   OKL_PARTY_PAYMENT_HDR pph, OKL_PARTY_PAYMENT_DTLS pyd
    WHERE pph.dnz_chr_id = p_chr_id
    AND   pph.cle_id =  p_cle_id
	AND   pph.id = pyd.payment_hdr_id;

	l_disbursement_basis         OKL_PARTY_PAYMENT_DTLS.disbursement_basis%TYPE;
	l_disbursement_fixed_amount  OKL_PARTY_PAYMENT_DTLS.disbursement_fixed_amount%TYPE;
	l_disbursement_percent       OKL_PARTY_PAYMENT_DTLS.disbursement_percent%TYPE;
	l_vendor_id                  OKL_PARTY_PAYMENT_DTLS.vendor_id%TYPE;
	l_vendor_total_amt           NUMBER := 0;
	l_chr_id                     NUMBER;

	CURSOR line_type_csr(p_chr_id IN NUMBER) IS
	SELECT DISTINCT(pph.cle_id),pph.payout_basis,lse.lty_code
	FROM okc_line_styles_b lse, okc_k_lines_b cle, OKL_PARTY_PAYMENT_HDR pph
	WHERE lse.id = cle.lse_id
	AND lse.lty_code = 'FEE'
	AND cle.id= pph.cle_id
	AND pph.dnz_chr_id =p_chr_id;

	CURSOR fee_line_amount_csr(p_chr_id IN NUMBER) IS
    SELECT kle.amount,
		   kle.id
    FROM okc_k_lines_b cle,
         OKL_K_LINES kle,
         okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND   cle.chr_id =  p_chr_id
    AND   kle.id = cle.id
    AND   cle.lse_id = lse.id
    AND   lse.lty_code = 'FEE';

	l_fee_line_amt OKL_K_LINES.amount%TYPE := 0;
	l_fee_line_id  NUMBER;

	CURSOR fee_payment_amt_csr (p_cle_id IN NUMBER, p_chr_id IN NUMBER) IS
	SELECT TO_NUMBER(sll.rule_information3) periods,
		   TO_NUMBER(sll.rule_information6) amount,
           TO_NUMBER(sll.rule_information8) stub_amount
	FROM okc_rules_b sll,
     	 okc_rule_groups_b rgp
	WHERE rgp.dnz_chr_id = p_chr_id
	AND rgp.cle_id = p_cle_id
	AND rgp.rgd_code = 'LALEVL'
	AND sll.rule_information_category = 'LASLL'
	AND sll.rgp_id = rgp.id;

	l_periods  NUMBER := 0;
	l_amount   NUMBER := 0;
	l_stub_amount NUMBER := 0;
	l_payment_amt NUMBER := 0;

	CURSOR s_line_type_csr(p_chr_id IN NUMBER) IS
	SELECT DISTINCT(pph.cle_id),pph.payout_basis
	FROM okc_line_styles_b lse, okc_k_lines_b cle, OKL_PARTY_PAYMENT_HDR pph
	WHERE lse.id = cle.lse_id
	AND lse.lty_code = 'SOLD_SERVICE'
	AND cle.id= pph.cle_id
	AND pph.dnz_chr_id =p_chr_id;

	CURSOR s_payment_amt_csr (p_cle_id IN NUMBER, p_chr_id IN NUMBER) IS
	SELECT TO_NUMBER(sll.rule_information6) amount
    FROM okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp
    WHERE rgp.dnz_chr_id = p_chr_id
	AND rgp.cle_id = p_cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND slh.rgp_id = rgp.id
    AND slh.rule_information_category = 'LASLH'
    AND sll.object2_id1 = slh.id
    AND sll.rule_information_category = 'LASLL'
    AND sll.rgp_id = rgp.id;

   BEGIN

      l_chr_id  := p_chr_id;
      IF Okl_Context.get_okc_org_id  IS NULL THEN
         Okl_Context.set_okc_org_context(p_chr_id => l_chr_id );
      END IF;

      x_return_status := Okc_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;
     x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	 -- Sum of the vendors amounts for one cle id should match line amount--
	 FOR line_amount_rec IN line_amount_csr (p_chr_id => l_chr_id)
     LOOP
        l_kle_id := line_amount_rec.id;
        l_kle_amount := line_amount_rec.amount;
		l_vendor_total_amt := 0;
		FOR vendor_amount_rec IN vendor_amount_csr (p_cle_id => l_kle_id,
		                                            p_chr_id => l_chr_id)
		LOOP
		   l_disbursement_basis := vendor_amount_rec.disbursement_basis;
		   l_disbursement_fixed_amount := vendor_amount_rec.disbursement_fixed_amount;
		   l_disbursement_percent := vendor_amount_rec.disbursement_percent;
		   l_vendor_id := vendor_amount_rec.vendor_id;
		   IF (l_disbursement_fixed_amount IS NOT NULL OR l_disbursement_percent IS NOT NULL) THEN
		   	  IF (l_disbursement_basis = 'PERCENT') THEN
		      	 l_vendor_total_amt := l_vendor_total_amt + l_disbursement_percent*l_kle_amount;
		   	  ELSE
		      	 l_vendor_total_amt := l_vendor_total_amt + l_disbursement_fixed_amount;
		   	  END IF;
		   END IF;
		END LOOP;
--dbms_output.put_line('l_vendor_total_amt: '||l_vendor_total_amt||
--                     ' l_kle_amount: '||l_kle_amount);
		IF (l_vendor_total_amt <> 0 AND l_vendor_total_amt <> l_kle_amount) THEN
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           Okc_Api.SET_MESSAGE(   p_app_name => g_app_name
                                , p_msg_name => 'OKL_PPM_AMT_NOT_MATCH'
                              );
           RAISE Okc_Api.G_EXCEPTION_ERROR;
		END IF;
     END LOOP;

	 --Disbursement amount (line amount) should not exceed fee payemnt amount
	 FOR line_type_rec IN line_type_csr (p_chr_id => l_chr_id)
     LOOP
	    OPEN fee_line_amount_csr (p_chr_id => l_chr_id);
		FETCH fee_line_amount_csr INTO l_fee_line_amt, l_fee_line_id;
		CLOSE fee_line_amount_csr;

	 	OPEN fee_payment_amt_csr(p_chr_id => l_chr_id,
		                         p_cle_id => l_fee_line_id);
		FETCH fee_payment_amt_csr INTO l_periods, l_amount, l_stub_amount;
		CLOSE fee_payment_amt_csr;

		IF (l_stub_amount IS NOT NULL) THEN
		   l_payment_amt := l_amount*l_periods + l_stub_amount;
		ELSE
		   l_payment_amt := l_amount*l_periods;
		END IF;

--dbms_output.put_line('l_fee_line_amt: '||l_fee_line_amt||
--                     ' l_payment_amt: '||l_payment_amt);
		IF (l_payment_amt <> 0) THEN
		   IF (l_fee_line_amt > l_payment_amt) THEN
           	  x_return_status := Okc_Api.G_RET_STS_ERROR;
           	  Okc_Api.SET_MESSAGE(   p_app_name => g_app_name
                                , p_msg_name => 'OKL_PPM_LINE_GT_PMNT'
                              );
           	  RAISE Okc_Api.G_EXCEPTION_ERROR;
		   END IF;
		END IF;

		-- payment required if payout basis in the folling values
		IF (line_type_rec.payout_basis IN ('DUE_DATE','BILLING',
		                             'FULL_RECEIPT','PARTIAL_RECEIPT') AND
		   NVL(l_amount,0) = 0) THEN
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           Okc_Api.SET_MESSAGE(   p_app_name => g_app_name
                                , p_msg_name => 'OKL_PPM_PMNT_REQ'
                              );
           RAISE Okc_Api.G_EXCEPTION_ERROR;
		END IF;
     END LOOP;

	 l_amount := 0;
	 --service line, only the following values can have amount --
	 FOR s_line_type_rec IN s_line_type_csr (p_chr_id => l_chr_id)
     LOOP
	 	OPEN s_payment_amt_csr(p_chr_id => l_chr_id,
		                       p_cle_id => s_line_type_rec.cle_id);
		FETCH s_payment_amt_csr INTO l_amount;
		CLOSE s_payment_amt_csr;
--dbms_output.put_line('s_line_type_rec.payout_basis: '||s_line_type_rec.payout_basis||
--                    ' l_amount: '||l_amount);
		IF (s_line_type_rec.payout_basis NOT IN ('DUE_DATE','BILLING',
		                                  'PARTIAL_RECEIPT','FULL_RECEIPT') AND
		    l_amount <> 0) THEN
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           Okc_Api.SET_MESSAGE(   p_app_name => g_app_name
                                , p_msg_name => 'OKL_PPM_PAYOUT_NO_PMNT'
                              );
           RAISE Okc_Api.G_EXCEPTION_ERROR;
		END IF;
	 END LOOP;

     Okc_Api.END_ACTIVITY(x_msg_count      => x_msg_count,
                         x_msg_data     => x_msg_data);
   EXCEPTION
      WHEN Okc_Api.G_EXCEPTION_ERROR THEN
         x_return_status := Okc_Api.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

      WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := Okc_Api.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

      WHEN OTHERS THEN
         x_return_status := Okc_Api.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

   END validate_passthru_qa;


  ------------------------------------------------------------------
  --Get passthru parameters --
  ------------------------------------------------------------------
  PROCEDURE get_passthru_parameters(
  			         p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER,
                     p_cle_id              IN   NUMBER,
                     p_vendor_id           IN   NUMBER,
    				 x_passthru_param_tbl  OUT NOCOPY passthru_param_tbl_type
  ) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'GET_PASSTHRU_PARAMETERS';
    l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

	CURSOR get_passthru_param_csr (p_chr_id NUMBER) IS
    SELECT pph.dnz_chr_id,
		   pph.cle_id,
		   pph.ppl_id,
		   pph.passthru_term,
		   pph.passthru_stream_type_id,
		   pph.passthru_start_date,
		   pph.payout_basis,
		   pph.payout_basis_formula,
		   pph.effective_from,
		   pph.effective_to,
		   pyd.id,
		   pyd.cpl_id,
		   pyd.vendor_id,
		   pyd.pay_site_id,
		   pyd.payment_term_id,
		   pyd.payment_method_code,
		   pyd.pay_group_code,
		   pyd.payment_hdr_id,
		   pyd.payment_basis,
		   pyd.payment_start_date,
		   pyd.payment_frequency,
		   pyd.remit_days,
		   pyd.disbursement_basis,
		   pyd.disbursement_fixed_amount,
		   pyd.disbursement_percent,
		   pyd.processing_fee_basis,
		   pyd.processing_fee_fixed_amount,
		   pyd.processing_fee_percent,
		   --pyd.processing_fee_formula,
		   --pyd.include_in_yield_flag,
		   pyd.attribute_category,
		   pyd.attribute1,
		   pyd.attribute2,
		   pyd.attribute3,
		   pyd.attribute4,
		   pyd.attribute5,
		   pyd.attribute6,
		   pyd.attribute7,
		   pyd.attribute8,
		   pyd.attribute9,
		   pyd.attribute10,
		   pyd.attribute11,
		   pyd.attribute12,
		   pyd.attribute13,
		   pyd.attribute14,
		   pyd.attribute15
    FROM OKL_PARTY_PAYMENT_HDR pph,
         OKL_PARTY_PAYMENT_DTLS pyd
	WHERE pph.dnz_chr_id = p_chr_id
	AND   pph.id = pyd.payment_hdr_id;

	i NUMBER;
	l_passthru_param_rec passthru_param_rec_type;
  BEGIN

     x_return_status := l_return_status;

	 i:= 1;
	 FOR get_passthru_param_rec IN get_passthru_param_csr (p_chr_id)
	 LOOP
	 	IF (p_cle_id IS NULL OR (p_cle_id IS NOT NULL AND p_cle_id = get_passthru_param_rec.cle_id)) AND
		   (p_vendor_id IS NULL OR (p_vendor_id IS NOT NULL AND p_vendor_id = get_passthru_param_rec.vendor_id)) THEN
		   l_passthru_param_rec.dnz_chr_id := get_passthru_param_rec.dnz_chr_id;
		   l_passthru_param_rec.cle_id := get_passthru_param_rec.cle_id;
		   l_passthru_param_rec.ppl_id := get_passthru_param_rec.ppl_id;
		   l_passthru_param_rec.passthru_term := get_passthru_param_rec.passthru_term;
		   l_passthru_param_rec.passthru_stream_type_id := get_passthru_param_rec.passthru_stream_type_id;
		   l_passthru_param_rec.passthru_start_date := get_passthru_param_rec.passthru_start_date;
		   l_passthru_param_rec.payout_basis := get_passthru_param_rec.payout_basis;
		   l_passthru_param_rec.payout_basis_formula := get_passthru_param_rec.payout_basis_formula;
		   l_passthru_param_rec.effective_from := get_passthru_param_rec.effective_from;
		   l_passthru_param_rec.effective_to := get_passthru_param_rec.effective_to;
		   l_passthru_param_rec.payment_dtls_id:= get_passthru_param_rec.id;
		   l_passthru_param_rec.cpl_id:=get_passthru_param_rec.cpl_id;
		   l_passthru_param_rec.vendor_id:=get_passthru_param_rec.vendor_id;
		   l_passthru_param_rec.pay_site_id:=get_passthru_param_rec.pay_site_id;
		   l_passthru_param_rec.payment_term_id:= get_passthru_param_rec.payment_term_id;
		   l_passthru_param_rec.payment_method_code:= get_passthru_param_rec.payment_method_code;
		   l_passthru_param_rec.pay_group_code:= get_passthru_param_rec.pay_group_code;
		   l_passthru_param_rec.payment_hdr_id:= get_passthru_param_rec.payment_hdr_id;
		   l_passthru_param_rec.payment_basis:= get_passthru_param_rec.payment_basis;
		   l_passthru_param_rec.payment_start_date:= get_passthru_param_rec.payment_start_date;
		   l_passthru_param_rec.payment_frequency:= get_passthru_param_rec.payment_frequency;
		   l_passthru_param_rec.remit_days:= get_passthru_param_rec.remit_days;
		   l_passthru_param_rec.disbursement_basis:= get_passthru_param_rec.disbursement_basis;
		   l_passthru_param_rec.disbursement_fixed_amount:= get_passthru_param_rec.disbursement_fixed_amount;
		   l_passthru_param_rec.disbursement_percent:= get_passthru_param_rec.disbursement_percent;
		   l_passthru_param_rec.processing_fee_basis:= get_passthru_param_rec.processing_fee_basis;
		   l_passthru_param_rec.processing_fee_fixed_amount:= get_passthru_param_rec.processing_fee_fixed_amount;
		   l_passthru_param_rec.processing_fee_percent:= get_passthru_param_rec.processing_fee_percent;
		   --l_passthru_param_rec.processing_fee_formula:= get_passthru_param_rec.processing_fee_formula;
		   --l_passthru_param_rec.include_in_yield_flag:= get_passthru_param_rec.include_in_yield_flag;
		   l_passthru_param_rec.attribute_category:= get_passthru_param_rec.attribute_category;
		   l_passthru_param_rec.attribute1:= get_passthru_param_rec.attribute1;
		   l_passthru_param_rec.attribute2:= get_passthru_param_rec.attribute2;
		   l_passthru_param_rec.attribute3:= get_passthru_param_rec.attribute3;
		   l_passthru_param_rec.attribute4:= get_passthru_param_rec.attribute4;
		   l_passthru_param_rec.attribute5:= get_passthru_param_rec.attribute5;
		   l_passthru_param_rec.attribute6:= get_passthru_param_rec.attribute6;
		   l_passthru_param_rec.attribute7:= get_passthru_param_rec.attribute7;
		   l_passthru_param_rec.attribute8:= get_passthru_param_rec.attribute8;
		   l_passthru_param_rec.attribute9:= get_passthru_param_rec.attribute9;
		   l_passthru_param_rec.attribute10:= get_passthru_param_rec.attribute10;
		   l_passthru_param_rec.attribute11:= get_passthru_param_rec.attribute11;
		   l_passthru_param_rec.attribute12:= get_passthru_param_rec.attribute12;
		   l_passthru_param_rec.attribute13:= get_passthru_param_rec.attribute13;
		   l_passthru_param_rec.attribute14:= get_passthru_param_rec.attribute14;
		   l_passthru_param_rec.attribute15:= get_passthru_param_rec.attribute15;
		   x_passthru_param_tbl(i) := l_passthru_param_rec;
		END IF;
		i := i+1;
	 END LOOP;

     x_return_status := l_return_status;

   EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
   END get_passthru_parameters;

  ----------------------------------------------------------
  -- Validate detail record before insert/update
  ----------------------------------------------------------
  PROCEDURE validate_dtls_record(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type
    ) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_DTLS_RECORD';
    l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

    --cursor to find if vendor id is proper party --
    CURSOR l_cplb_csr(p_vendor_id IN NUMBER,
                      p_cpl_id    IN NUMBER) IS
    SELECT 'Y'
    FROM   okc_k_party_roles_b cplb
    WHERE  id   = p_cpl_id
    AND    object1_id1 = TO_CHAR(p_vendor_id);

    l_exists VARCHAR2(1) DEFAULT 'N';

    -- find out whether header exists --
	CURSOR l_hdr_csr(p_payment_hdr_id IN NUMBER) IS
    SELECT 'Y'
    FROM   OKL_PARTY_PAYMENT_HDR
    WHERE  id   = p_payment_hdr_id;

	--find out the passthru term --
	CURSOR passthru_term_csr (p_hdr_id IN NUMBER) IS
	SELECT passthru_term
	FROM OKL_PARTY_PAYMENT_HDR
	WHERE id = p_hdr_id;

	l_passthru_term         OKL_PARTY_PAYMENT_HDR.passthru_term%TYPE := NULL;

  BEGIN

     -- check for required columns --
     x_return_status := l_return_status;
     IF( p_ppydv_rec.pay_site_id IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Pay Site');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     IF( p_ppydv_rec.payment_term_id IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payment Term');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     IF( p_ppydv_rec.pay_group_code IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Pay Group Code');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

     IF (p_ppydv_rec.payment_hdr_id IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payment Header Id');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
	 ELSE
	   --find out whether header exists
	   l_exists := 'N';
       OPEN l_hdr_csr(p_payment_hdr_id => p_ppydv_rec.payment_hdr_id);
       FETCH l_hdr_csr INTO l_exists;
       IF l_hdr_csr%NOTFOUND THEN
         NULL;
       END IF;
       CLOSE l_hdr_csr;
       IF l_exists = 'N' THEN
         Okc_Api.SET_MESSAGE(   p_app_name => g_app_name
                              , p_msg_name => 'OKL_PPM_HEADER_MISSING'
                               );
         x_return_status := Okl_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

     END IF;

     IF (p_ppydv_rec.payment_basis IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Payment Basis');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     IF (p_ppydv_rec.disbursement_basis IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Disbursement Basis');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

	 --can be done from UI--
	 -- Remittance Days required if basis is 'PROCESSINGDATE'--
  	 IF (p_ppydv_rec.payment_basis = 'PROCESS_DATE' AND
  	     p_ppydv_rec.REMIT_DAYS IS NULL) THEN
        Okc_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_PPM_REMIT_DAYS_REQED'
                            );
        x_return_status := Okc_Api.g_ret_sts_error;
        RAISE G_EXCEPTION_HALT_VALIDATION;
	 END IF;
     --Validate Disbursement Fixed Amount
     IF (p_ppydv_rec.disbursement_basis = 'AMOUNT' AND
	     p_ppydv_rec.disbursement_fixed_amount IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Disbursement Fixed Amount');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
	 --Validate Disbursement Percent
     IF (p_ppydv_rec.disbursement_basis = 'PERCENT' AND
	     p_ppydv_rec.disbursement_percent IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Disbursement Percent');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
	 --Validate Processing fee fixed Amount
     IF (p_ppydv_rec.processing_fee_basis = 'AMOUNT' AND
	     p_ppydv_rec.processing_fee_fixed_amount IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Processing Fee Fixed Amount');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
	 --Validate Processing fee Percent
     IF (p_ppydv_rec.processing_fee_basis = 'PERCENT' AND
	     p_ppydv_rec.processing_fee_percent IS NULL) THEN
       Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Processing Fee Percent');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
	 --Validate Processing fee Formula
	 /*
     IF (p_ppydv_rec.processing_fee_basis = 'FORMULA' AND
	     p_ppydv_rec.processing_fee_formula IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Processing Fee Formula');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;	*/
	 --the above can be done from UI--

     --validate vendor id and cpl id--
     l_exists := 'N';
     OPEN l_cplb_csr(p_vendor_id => p_ppydv_rec.vendor_id,
                     p_cpl_id    => p_ppydv_rec.cpl_id);
     FETCH l_cplb_csr INTO l_exists;
     IF l_cplb_csr%NOTFOUND THEN
         NULL;
     END IF;
     CLOSE l_cplb_csr;
     IF l_exists = 'N' THEN
        Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,
		                    G_COL_NAME_TOKEN,'Vendor_Id');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

	 -- Velidation based on payment basis  --
	 OPEN passthru_term_csr(p_ppydv_rec.payment_hdr_id);
	 FETCH passthru_term_csr INTO l_passthru_term;
	 CLOSE passthru_term_csr;

	 IF (l_passthru_term = 'BASE') THEN
  	    -- Start date and frequency are mandatory if basis is 'SCHEDULED'
	    IF (p_ppydv_rec.payment_basis = 'SCHEDULED') AND
  	       (p_ppydv_rec.payment_start_date IS NULL OR
		   p_ppydv_rec.payment_frequency IS NULL) THEN
           Okc_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                               p_msg_name => 'OKL_PPM_DF_REQED'
                               );
           x_return_status := Okc_Api.g_ret_sts_error;
           RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	    -- Processing fee basis not 'FORMULA' for 'BASE' --
		/*
  	    IF (p_ppydv_rec.processing_fee_basis = 'FORMULA') THEN
           OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                               p_msg_name => 'OKL_PPM_INV_PROC_FEE_BASIS'
                               );
           x_return_status := OKC_API.g_ret_sts_error;
           RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;

	    -- disbursment basis should not have 'FORMULA' value
  	    IF (p_ppydv_rec.disbursement_basis = 'FORMULA') THEN
           OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                               p_msg_name => 'OKL_PPM_INV_DISB_BASIS'
                               );
           x_return_status := OKC_API.g_ret_sts_error;
           RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;	 */
		-- Processing fee basis not 'FORMULA' for 'BASE' if INCLUDE_IN_YIELD_FLAG = 'Y'--
  	    /*IF (p_ppydv_rec.include_in_yield_flag = 'Y' AND
  	        p_ppydv_rec.PROCESSING_FEE_BASIS = 'FORMULA') THEN
           OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                               p_msg_name => 'OKL_PPM_INV_PRO_FEE_BASIS'
                               );
           x_return_status := OKC_API.g_ret_sts_error;
           RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF; */
	 ELSE
	    -- payment basis has processing days only
		IF (p_ppydv_rec.payment_basis = 'SCHEDULED') THEN
           Okc_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                               p_msg_name => 'OKL_PPM_INV_PMNT_BASIS'
                               );
           x_return_status := Okc_Api.g_ret_sts_error;
           RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;
	 END IF;

	 -- raise the exception if status is not s
     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
	 --x_return_status := l_return_status;
   EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
   END validate_dtls_record;

   PROCEDURE create_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_rec                    IN ppydv_rec_type,
     x_ppydv_rec                    OUT NOCOPY ppydv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

	 CURSOR check_duplicate_csr (p_payment_hdr_id NUMBER,
	 							 p_vendor_id NUMBER) IS
	 SELECT '1'
	 FROM OKL_PARTY_PAYMENT_DTLS
	 WHERE payment_hdr_id = p_payment_hdr_id
	 AND   vendor_id = p_vendor_id;
	 l_exist VARCHAR2(1);

	 -- Bug 4917691: fmiao start
	 CURSOR chr_id_csr (p_payment_hdr_id NUMBER) IS
	 SELECT distinct(pph.dnz_chr_id)
	 FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
	 WHERE ppy.payment_hdr_id = p_payment_hdr_id
	 AND ppy.payment_hdr_id = pph.id;
	 l_chr_id NUMBER;
	 -- Bug 4917691: fmiao end

       --Bug# 4959361
       CURSOR l_pph_csr(p_pph_id IN NUMBER) IS
       SELECT cle_id
       FROM okl_party_payment_hdr pph
       WHERE pph.id = p_pph_id;

       l_pph_rec l_pph_csr%ROWTYPE;
       --Bug# 4959361

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
     OPEN l_pph_csr(p_pph_id => p_ppydv_rec.payment_hdr_id);
     FETCH l_pph_csr INTO l_pph_rec;
     CLOSE l_pph_csr;

     IF l_pph_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_pph_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

	 -- Check duplidates: each line should have only 1 BASE or/and 1 EVERGREEN --
	 OPEN check_duplicate_csr (p_ppydv_rec.payment_hdr_id,
	 	  					   p_ppydv_rec.vendor_id);
	 FETCH check_duplicate_csr INTO l_exist;
	 CLOSE check_duplicate_csr;
	 IF (l_exist IS NOT NULL) THEN
	   Okc_Api.SET_MESSAGE( p_app_name => g_app_name,
                            p_msg_name => 'OKL_PPM_VENDOR_EXISTS'
                           );
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
	 END IF;

	 Okl_Pyd_Pvt.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_rec,
                            x_ppydv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     validate_dtls_record(x_return_status, x_ppydv_rec);

     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;
	 x_return_status := l_return_status;

	 -- Bug 4917691: fmiao start
	 -- Need to change contract status to INCOMPLETE when create/update ppy
	 -- cascade edit status on to lines
	 IF (p_ppydv_rec.payment_hdr_id IS NOT NULL) THEN
	   OPEN chr_id_csr (p_ppydv_rec.payment_hdr_id);
	   FETCH chr_id_csr INTO l_chr_id;
	   CLOSE chr_id_csr;

       okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_chr_id          => l_chr_id);

       If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
         raise OKL_API.G_EXCEPTION_ERROR;
       End If;
	 END IF;
	 -- Bug 4917691: fmiao end

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_party_payment_dtls;

   PROCEDURE create_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_tbl                    IN ppydv_tbl_type,
     x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_ppydv_tbl.COUNT > 0 THEN
       i := p_ppydv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         create_party_payment_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_tbl(i),
                            x_ppydv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_ppydv_tbl.LAST);
       i := p_ppydv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_party_payment_dtls;

   PROCEDURE lock_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_rec                    IN ppydv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

	 Okl_Pyd_Pvt.lock_row  (p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_party_payment_dtls;

   PROCEDURE lock_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_tbl                    IN ppydv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_ppydv_tbl.COUNT > 0 THEN
       i := p_ppydv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         lock_party_payment_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_ppydv_tbl.LAST);
       i := p_ppydv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_party_payment_dtls;

   PROCEDURE delete_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_rec                    IN ppydv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

     --Bug# 4959361
     CURSOR l_pyd_csr(p_pyd_id IN NUMBER) IS
     SELECT pph.cle_id
     FROM   okl_party_payment_hdr pph,
            okl_party_payment_dtls pyd
     WHERE  pyd.id = p_pyd_id
     AND    pph.id = pyd.payment_hdr_id;

     l_pyd_rec l_pyd_csr%ROWTYPE;
     --Bug# 4959361

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
     OPEN l_pyd_csr(p_pyd_id => p_ppydv_rec.id);
     FETCH l_pyd_csr INTO l_pyd_rec;
     CLOSE l_pyd_csr;

     IF l_pyd_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_pyd_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

	 Okl_Pyd_Pvt.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_party_payment_dtls;

   PROCEDURE delete_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_tbl                    IN ppydv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_ppydv_tbl.COUNT > 0 THEN
       i := p_ppydv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         delete_party_payment_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_ppydv_tbl.LAST);
       i := p_ppydv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_party_payment_dtls;

   PROCEDURE update_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_rec                    IN ppydv_rec_type,
     x_ppydv_rec                    OUT NOCOPY ppydv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;


	 -- Bug 4917691: fmiao start
	 CURSOR chr_id_csr (p_payment_hdr_id NUMBER) IS
	 SELECT distinct(pph.dnz_chr_id)
	 FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
	 WHERE ppy.payment_hdr_id = p_payment_hdr_id
	 AND ppy.payment_hdr_id = pph.id;
	 l_chr_id NUMBER;
	 -- Bug 4917691: fmiao end

       --Bug# 4959361
       CURSOR l_pyd_csr(p_pyd_id IN NUMBER) IS
       SELECT pph.cle_id
       FROM  okl_party_payment_hdr pph,
             okl_party_payment_dtls pyd
       WHERE pyd.id = p_pyd_id
       AND   pph.id = pyd.payment_hdr_id;

       l_pyd_rec l_pyd_csr%ROWTYPE;
       --Bug# 4959361

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
     OPEN l_pyd_csr(p_pyd_id => p_ppydv_rec.id);
     FETCH l_pyd_csr INTO l_pyd_rec;
     CLOSE l_pyd_csr;

     IF l_pyd_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_pyd_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

	 Okl_Pyd_Pvt.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_rec,
                            x_ppydv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     validate_dtls_record(x_return_status, x_ppydv_rec);
     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

	 -- Bug 4917691: fmiao start
	 -- Need to change contract status to INCOMPLETE when create/update ppy
	 -- cascade edit status on to lines
	 IF (p_ppydv_rec.payment_hdr_id IS NOT NULL) THEN
	   OPEN chr_id_csr (x_ppydv_rec.payment_hdr_id);
	   FETCH chr_id_csr INTO l_chr_id;
	   CLOSE chr_id_csr;

       okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_chr_id          => l_chr_id);

       If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
         raise OKL_API.G_EXCEPTION_ERROR;
       End If;
	 END IF;
	 -- Bug 4917691: fmiao end


     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_party_payment_dtls;

   PROCEDURE update_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_tbl                    IN ppydv_tbl_type,
     x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;

   BEGIN

     IF p_ppydv_tbl.COUNT > 0 THEN
       i := p_ppydv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         update_party_payment_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_tbl(i),
                            x_ppydv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_ppydv_tbl.LAST);
       i := p_ppydv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_party_payment_dtls;

   PROCEDURE validate_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_rec                    IN ppydv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := Okc_Api.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     END IF;

	 Okl_Pyd_Pvt.validate_row(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_ppydv_rec);

     IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     Okc_Api.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_party_payment_dtls;

   PROCEDURE validate_party_payment_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ppydv_tbl                    IN ppydv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PARTY_PAYMENT_DTLS';
     l_return_status     VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     IF p_ppydv_tbl.COUNT > 0 THEN
       i := p_ppydv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         validate_party_payment_dtls(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_ppydv_tbl(i));
         IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;

       EXIT WHEN (i = p_ppydv_tbl.LAST);
       i := p_ppydv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     END IF;

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   EXCEPTION
     WHEN Okc_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okc_Api.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_party_payment_dtls;

END Okl_Party_Payments_Pvt;

/
