--------------------------------------------------------
--  DDL for Package Body OKL_MAINTAIN_FEE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MAINTAIN_FEE_PVT" as
 /* $Header: OKLRFEEB.pls 120.56.12010000.2 2009/07/17 09:08:12 rpillay ship $ */

/*
-- vthiruva, 09/01/2004
-- Added Constants to enable Business Event
*/
G_WF_EVT_FEE_REMOVED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.remove_fee';
G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30) := 'CONTRACT_ID';
G_WF_ITM_FEE_LINE_ID CONSTANT VARCHAR2(30) := 'FEE_LINE_ID';
G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30) := 'CONTRACT_PROCESS';

--Bug# 4899328
TYPE link_asset_rec_type IS RECORD (link_line_id   NUMBER,
                                    link_item_id   NUMBER,
                                    fin_asset_id   NUMBER,
                                    amount         NUMBER,
                                    asset_number   VARCHAR2(15));

TYPE link_asset_tbl_type IS TABLE OF link_asset_rec_type INDEX BY BINARY_INTEGER;

--Murthy passthru changes begin
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
  subtype pphv_rec_type is OKL_PARTY_PAYMENTS_PVT.pphv_rec_type;
  subtype ppydv_rec_type is OKL_PYD_PVT.ppydv_rec_type;
  subtype ppydv_tbl_type is OKL_PYD_PVT.ppydv_tbl_type;

  CURSOR party_payment_csr(p_dnz_chr_id NUMBER, p_cle_id NUMBER, p_passthru_term VARCHAR2) IS
  select id, passthru_term
  from   okl_party_payment_hdr
  where
         dnz_chr_id = p_dnz_chr_id and cle_id = p_cle_id  and
         passthru_term = p_passthru_term;
  party_payment_rec party_payment_csr%ROWTYPE;

-- Modified by zrehman on 18-Jan-2008 Bug#6763287
-- Check whether contract or IA
  CURSOR chk_inv_csr(p_dnz_chr_id NUMBER) IS
  select 1
  from okc_k_headers_all_b
  where id = p_dnz_chr_id
  and scs_code = 'INVESTOR';

 PROCEDURE get_base_evg_recs(p_from   IN passthru_dtl_rec_type,
                             x_base   OUT NOCOPY ppydv_rec_type,
                             x_evg    OUT NOCOPY ppydv_rec_type) IS
  BEGIN
--base record population
    x_base.object_version_number      := OKL_API.G_MISS_NUM;
    x_base.created_by                 := OKL_API.G_MISS_NUM;
    x_base.creation_date              := OKL_API.G_MISS_DATE;
    x_base.last_updated_by            := OKL_API.G_MISS_NUM;
    x_base.last_update_date           := OKL_API.G_MISS_DATE;
    x_base.last_update_login          := OKL_API.G_MISS_NUM;
    x_base.id                         := p_from.b_payment_dtls_id;
    x_base.cpl_id                     := p_from.b_cpl_id;
    x_base.pay_site_id                := p_from.b_pay_site_id;
    x_base.pay_group_code             := p_from.b_pay_group_code;
    x_base.payment_hdr_id             := p_from.b_payment_hdr_id;
    x_base.payment_term_id            := p_from.b_payment_term_id;
    x_base.payment_method_code        := p_from.b_payment_method_code;
    x_base.payment_basis              := p_from.b_payment_basis;
    x_base.payment_start_date         := p_from.b_payment_start_date;
    x_base.payment_frequency          := p_from.b_payment_frequency;
    x_base.remit_days                 := p_from.b_remit_days;
    x_base.disbursement_basis        := p_from.b_disbursement_basis;
    x_base.disbursement_fixed_amount := p_from.b_disbursement_fixed_amount;
    x_base.disbursement_percent      := p_from.b_disbursement_percent;
    x_base.processing_fee_basis      := p_from.b_processing_fee_basis;
    x_base.processing_fee_fixed_amount := p_from.b_processing_fee_fixed_amount;
    x_base.processing_fee_percent    := p_from.b_processing_fee_percent;
    --x_base.processing_fee_formula    := p_from.b_processing_fee_formula;
-- evergreen record population
    x_evg.object_version_number      := OKL_API.G_MISS_NUM;
    x_evg.created_by                 := OKL_API.G_MISS_NUM;
    x_evg.creation_date              := OKL_API.G_MISS_DATE;
    x_evg.last_updated_by            := OKL_API.G_MISS_NUM;
    x_evg.last_update_date           := OKL_API.G_MISS_DATE;
    x_evg.last_update_login          := OKL_API.G_MISS_NUM;
    x_evg.id                         := p_from.e_payment_dtls_id;
    x_evg.cpl_id                     := p_from.e_cpl_id;
    x_evg.pay_site_id                := p_from.e_pay_site_id;
    x_evg.pay_group_code             := p_from.e_pay_group_code;
    x_evg.payment_hdr_id             := p_from.e_payment_hdr_id;
    x_evg.payment_term_id            := p_from.e_payment_term_id;
    x_evg.payment_method_code        := p_from.e_payment_method_code;
    x_evg.payment_basis              := p_from.e_payment_basis;
    x_evg.payment_start_date         := p_from.e_payment_start_date;
    x_evg.payment_frequency          := p_from.e_payment_frequency;
    x_evg.remit_days                 := p_from.e_remit_days;
    x_evg.disbursement_basis         := p_from.e_disbursement_basis;
    x_evg.disbursement_fixed_amount  := p_from.e_disbursement_fixed_amount;
    x_evg.disbursement_percent       := p_from.e_disbursement_percent;
    x_evg.processing_fee_basis       := p_from.e_processing_fee_basis;
    x_evg.processing_fee_fixed_amount:= p_from.e_processing_fee_fixed_amount;
    x_evg.processing_fee_percent     := p_from.e_processing_fee_percent;
    --x_evg.processing_fee_formula     := p_from.e_processing_fee_formula;
  END get_base_evg_recs;

   PROCEDURE delete_passthru_party(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_cpl_id                       IN  NUMBER
     ) IS

/* not required as cpl_id is passed
     CURSOR cpl_csr (p_chr_id NUMBER,
                     p_cle_id NUMBER,
                     p_vendor_id NUMBER) IS
     SELECT id
     FROM   okc_k_party_roles_v
     WHERE  dnz_chr_id  = p_chr_id
     AND    cle_id      = p_cle_id
     AND    object1_id1 = 6
     AND    rle_code    = 'OKL_VENDOR';
*/
     CURSOR pmnt_dtl_csr (p_cpl_id NUMBER) IS
     SELECT id
     FROM   okl_party_payment_dtls
     WHERE  cpl_id = p_cpl_id;

     i NUMBER;
     j NUMBER;
     l_cplv_rec          OKL_OKC_MIGRATION_PVT.CPLV_REC_TYPE;
     l_ppydv_tbl         ppydv_tbl_type;

     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_PASSTHRU_PARTY';
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     --Bug# 4558486
     l_kplv_rec          OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
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

     IF (p_cpl_id IS NULL) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

     i := 0;
     l_cplv_rec.id := p_cpl_id;

     FOR pmnt_dtl_rec IN pmnt_dtl_csr (p_cpl_id)
     LOOP
        i := i + 1;
        l_ppydv_tbl(i).id := pmnt_dtl_rec.id;
        -- delete party payment details
     END LOOP;

     IF (l_ppydv_tbl.COUNT > 0) THEN
        OKL_PARTY_PAYMENTS_PVT.delete_party_payment_dtls(
               p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_ppydv_tbl     => l_ppydv_tbl);

        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
    	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
    	  raise OKL_API.G_EXCEPTION_ERROR;
        End If;
        l_ppydv_tbl.DELETE;
     END IF;

     IF (l_cplv_rec.id IS NOT NULL) THEN
        --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
        --              to delete records in tables
        --              okc_k_party_roles_b and okl_k_party_roles
        /*
        okl_okc_migration_pvt.delete_k_party_role(
               p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_cplv_rec      => l_cplv_rec);
        */

        l_kplv_rec.id := l_cplv_rec.id;
        okl_k_party_roles_pvt.delete_k_party_role(
               p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_cplv_rec      => l_cplv_rec,
               p_kplv_rec      => l_kplv_rec);

        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
    	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
    	  raise OKL_API.G_EXCEPTION_ERROR;
        End If;
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
   END delete_passthru_party;


  PROCEDURE create_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_passthru_dtl_rec             IN  passthru_dtl_rec_type,
    x_passthru_dtl_rec             OUT NOCOPY passthru_dtl_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'create_payment_dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_base_create boolean := TRUE;
    l_evg_create boolean  := TRUE;

    l_passthru_dtl_rec passthru_dtl_rec_type := p_passthru_dtl_rec;
    l_base ppydv_rec_type ;
    l_evg  ppydv_rec_type ;
    x_ppydv_rec ppydv_rec_type;
    l_exists VARCHAR2(1);

  CURSOR party_object1_id1(p_cpl_id NUMBER) IS
  select object1_id1
  from   okc_k_party_roles_b
  where
        id = p_cpl_id;
  id1 NUMBER;

  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

      get_base_evg_recs(p_from => l_passthru_dtl_rec, x_base => l_base, x_evg => l_evg);

      l_exists := 'N';
      OPEN party_object1_id1(l_base.cpl_id);
      FETCH party_object1_id1 INTO id1;
      IF party_object1_id1%FOUND THEN
        l_exists := 'Y';
      END IF;
      CLOSE party_object1_id1;

      if(l_exists = 'N') Then
         RAISE G_EXCEPTION_HALT_VALIDATION;
      end if;

--Murthy check for rows found here

      l_base.vendor_id := id1;
      l_evg.vendor_id := id1;

--Base details created or updated only if Base header exists for the line.

     l_base_create := l_base.pay_site_id IS NOT NULL
                   OR l_base.pay_group_code IS NOT NULL
                   OR l_base.payment_term_id IS NOT NULL
                   OR l_base.payment_basis IS NOT NULL
                   OR l_base.payment_start_date IS NOT NULL
                   OR l_base.payment_method_code IS NOT NULL
                   OR l_base.payment_frequency IS NOT NULL
                   OR l_base.remit_days IS NOT NULL
                   OR l_base.disbursement_basis IS NOT NULL
                   OR l_base.disbursement_fixed_amount IS NOT NULL
                   OR l_base.disbursement_percent IS NOT NULL
                   OR l_base.processing_fee_basis IS NOT NULL
                   OR l_base.processing_fee_fixed_amount IS NOT NULL
                   OR l_base.processing_fee_percent IS NOT NULL;


     If( l_base_create AND l_base.payment_hdr_id IS NOT NULL AND (l_base.id IS NULL OR l_base.id = OKL_API.G_MISS_NUM) ) Then
       okl_party_payments_pvt.create_party_payment_dtls(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_ppydv_rec        => l_base,
             x_ppydv_rec        => x_ppydv_rec);
        null;

       -- check if activity started successfully
       If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
       End If;
     ElsIf ( l_base.payment_hdr_id IS NOT NULL AND l_base.id IS NOT NULL) Then
       okl_party_payments_pvt.update_party_payment_dtls(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_ppydv_rec        => l_base,
             x_ppydv_rec        => x_ppydv_rec);
        null;

       -- check if activity started successfully
       If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
       End If;
     End If;


--Evergreen  details created or updated only if Evergreen header exists for the line.

     l_evg_create := l_evg.pay_site_id IS NOT NULL
                   OR l_evg.pay_group_code IS NOT NULL
                   OR l_evg.payment_term_id IS NOT NULL
                   OR l_evg.payment_basis IS NOT NULL
                   OR l_evg.payment_start_date IS NOT NULL
                   OR l_evg.payment_method_code IS NOT NULL
                   OR l_evg.payment_frequency IS NOT NULL
                   OR l_evg.remit_days IS NOT NULL
                   OR l_evg.disbursement_basis IS NOT NULL
                   OR l_evg.disbursement_fixed_amount IS NOT NULL
                   OR l_evg.disbursement_percent IS NOT NULL
                   OR l_evg.processing_fee_basis IS NOT NULL
                   OR l_evg.processing_fee_fixed_amount IS NOT NULL
                   OR l_evg.processing_fee_percent IS NOT NULL;


     If( l_evg_create AND l_evg.payment_hdr_id IS NOT NULL AND l_evg.id IS NULL) Then
       okl_party_payments_pvt.create_party_payment_dtls(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_ppydv_rec        => l_evg,
             x_ppydv_rec        => x_ppydv_rec);
          null;

       -- check if activity started successfully
       If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
       End If;
     ElsIf ( l_evg.payment_hdr_id IS NOT NULL AND l_evg.id IS NOT NULL) Then
       okl_party_payments_pvt.update_party_payment_dtls(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_ppydv_rec        => l_evg,
             x_ppydv_rec        => x_ppydv_rec);

       -- check if activity started successfully
       If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
       End If;
     End If;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);


  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_payment_dtls;


----------------------------
  PROCEDURE create_payment_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_passthru_rec                 IN  passthru_rec_type,
    x_passthru_rec                 OUT NOCOPY passthru_rec_type) IS


    l_api_name		CONSTANT VARCHAR2(30) := 'create_payment_hdrs';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_passthru_rec passthru_rec_type := p_passthru_rec;
    l_pphv_rec pphv_rec_type ;
    l_pphv_evg_rec pphv_rec_type ;
    x_pphv_rec pphv_rec_type;
    l_party_payment_rec party_payment_csr%ROWTYPE;

    --Bug# 4884423
    --Bug# 8652738: Modified cursor to fetch payout
    --              basis from original contract
    CURSOR l_old_passthru_csr(p_cle_id IN NUMBER,
                              p_passthru_term in VARCHAR2) IS
    SELECT payout_basis
    FROM okl_party_payment_hdr
    WHERE cle_id = p_cle_id
    AND passthru_term = p_passthru_term;

    CURSOR l_cle_csr(p_cle_id IN NUMBER) IS
    SELECT orig_system_id1
    FROM okc_k_lines_b
    WHERE id = p_cle_id;

    l_cle_rec               l_cle_csr%ROWTYPE;
    l_chk_rebook_chr        VARCHAR2(1);
    l_base_payout_basis_upd VARCHAR2(1);
    l_evgn_payout_basis_upd VARCHAR2(1);
    --Bug# 4884423
  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   --Bug# 4884423
   -- Update of Payout Basis is not allowed during Rebook
   l_chk_rebook_chr := OKL_LLA_UTIL_PVT.check_rebook_contract(p_chr_id => l_passthru_rec.dnz_chr_id);
   IF (NVL(l_chk_rebook_chr,OKL_API.G_MISS_CHAR) = OKL_API.G_TRUE) THEN

    OPEN l_cle_csr(p_cle_id => l_passthru_rec.cle_id);
    FETCH l_cle_csr INTO l_cle_rec;
    CLOSE l_cle_csr;

    -- Validation required for only existing fee lines, not
    -- for newly added fee lines
    IF (l_cle_rec.orig_system_id1 IS NOT NULL) THEN

     l_base_payout_basis_upd := OKL_API.G_FALSE;
     l_evgn_payout_basis_upd := OKL_API.G_FALSE;

     --Bug# 8652738: Modifications to compare payout basis with value in original contract
     IF ((l_passthru_rec.base_id IS NULL OR l_passthru_rec.base_id = OKL_API.G_MISS_NUM )
             AND l_passthru_rec.payout_basis IS NOT NULL) THEN
           l_base_payout_basis_upd := OKL_API.G_FALSE;

     ELSIF NOT (l_passthru_rec.base_id IS NULL OR l_passthru_rec.base_id =  OKL_API.G_MISS_NUM)
     THEN

       FOR l_old_passthru_rec IN l_old_passthru_csr(p_cle_id => l_cle_rec.orig_system_id1,
                                                    p_passthru_term => 'BASE') LOOP
         IF (NVL(l_old_passthru_rec.payout_basis,OKL_API.G_MISS_CHAR) <>
             NVL(l_passthru_rec.payout_basis,OKL_API.G_MISS_CHAR)) THEN

           l_base_payout_basis_upd := OKL_API.G_TRUE;

         END IF;
       END LOOP;
     END IF;

     IF (l_base_payout_basis_upd = OKL_API.G_TRUE) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LA_RBK_BASE_PYT_BS_UPD');
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 8652738: Modifications to compare payout basis with value in original contract
     IF ((l_passthru_rec.evergreen_id IS NULL OR l_passthru_rec.evergreen_id = OKL_API.G_MISS_NUM )
             AND l_passthru_rec.evergreen_payout_basis IS NOT NULL) THEN
           l_evgn_payout_basis_upd := OKL_API.G_FALSE;

     ELSIF NOT (l_passthru_rec.evergreen_id IS NULL OR l_passthru_rec.evergreen_id =  OKL_API.G_MISS_NUM)
     THEN
       FOR l_old_passthru_rec IN l_old_passthru_csr(p_cle_id => l_cle_rec.orig_system_id1,
                                                    p_passthru_term => 'EVERGREEN') LOOP
         IF (NVL(l_old_passthru_rec.payout_basis,OKL_API.G_MISS_CHAR) <>
             NVL(l_passthru_rec.evergreen_payout_basis,OKL_API.G_MISS_CHAR)) THEN

           l_evgn_payout_basis_upd := OKL_API.G_TRUE;

         END IF;
       END LOOP;
     END IF;

     IF (l_evgn_payout_basis_upd = OKL_API.G_TRUE) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LA_RBK_EVGN_PYT_BS_UPD');
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
    END IF;
   END IF;
   --Bug# 4884423

------------------------------------------------------------------
--Create  base and evergreen if we are actually in Create mode
------------------------------------------------------------------
--create payment header base term
    If ( (l_passthru_rec.base_id IS NULL OR l_passthru_rec.base_id = OKL_API.G_MISS_NUM )
             AND l_passthru_rec.payout_basis IS NOT NULL) Then

      l_pphv_rec.dnz_chr_id := l_passthru_rec.dnz_chr_id;
      l_pphv_rec.cle_id := l_passthru_rec.cle_id;
      l_pphv_rec.passthru_start_date := l_passthru_rec.passthru_start_date;
      l_pphv_rec.payout_basis := l_passthru_rec.payout_basis;
      l_pphv_rec.passthru_term := 'BASE';
      l_pphv_rec.passthru_stream_type_id := l_passthru_rec.base_stream_type_id;
      --l_pphv_rec.passthru_stream_type_id := l_passthru_rec.passthru_stream_type_id;


      okl_party_payments_pvt.create_party_payment_hdr(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_pphv_rec		=> l_pphv_rec,
	 x_pphv_rec		=> x_pphv_rec);

      --setting the out record
      x_passthru_rec.base_id := x_pphv_rec.id;
      x_passthru_rec.base_stream_type_id := x_pphv_rec.passthru_stream_type_id;

      -- check return status
      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    End If;

--create payment header evergreen term
    If ( (l_passthru_rec.evergreen_id IS NULL OR l_passthru_rec.evergreen_id = OKL_API.G_MISS_NUM )
             AND l_passthru_rec.evergreen_payout_basis IS NOT NULL) Then
             --AND l_passthru_rec.evergreen_eligible_yn = 'Y') Then
      --create payment header evergreen term
      l_pphv_evg_rec.dnz_chr_id := l_passthru_rec.dnz_chr_id;
      l_pphv_evg_rec.cle_id := l_passthru_rec.cle_id;
      l_pphv_evg_rec.passthru_start_date := l_passthru_rec.passthru_start_date;
      l_pphv_evg_rec.payout_basis := l_passthru_rec.evergreen_payout_basis;
      l_pphv_evg_rec.passthru_term := 'EVERGREEN';
      l_pphv_evg_rec.payout_basis_formula := l_passthru_rec.evergreen_payout_basis_formula;
      l_pphv_evg_rec.passthru_stream_type_id := l_passthru_rec.evg_stream_type_id;
      --l_pphv_rec.passthru_stream_type_id := l_passthru_rec.passthru_stream_type_id;

      okl_party_payments_pvt.create_party_payment_hdr(
  	 p_api_version	        => p_api_version,
  	 p_init_msg_list	=> p_init_msg_list,
  	 x_return_status 	=> x_return_status,
  	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_pphv_rec		=> l_pphv_evg_rec,
	 x_pphv_rec		=> x_pphv_rec);

      --setting the out record
      x_passthru_rec.evergreen_id := x_pphv_rec.id;
      x_passthru_rec.evg_stream_type_id := x_pphv_rec.passthru_stream_type_id;

      -- check return status
      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    End If;


------------------------------------------------------------------
--Update base and evergreen if we are actually in update mode
------------------------------------------------------------------
--Update base
    If NOT (l_passthru_rec.base_id IS NULL OR l_passthru_rec.base_id =  OKL_API.G_MISS_NUM) Then
      --l_pphv_rec.id := l_party_payment_rec.id;
      l_pphv_rec.id := l_passthru_rec.base_id;
      l_pphv_rec.passthru_term  := 'BASE';
      l_pphv_rec.dnz_chr_id := l_passthru_rec.dnz_chr_id;
      l_pphv_rec.cle_id := l_passthru_rec.cle_id;
      l_pphv_rec.passthru_start_date := l_passthru_rec.passthru_start_date;
      l_pphv_rec.payout_basis := l_passthru_rec.payout_basis;
      l_pphv_rec.passthru_stream_type_id := l_passthru_rec.base_stream_type_id;
      --l_pphv_rec.passthru_stream_type_id := l_passthru_rec.passthru_stream_type_id;

      okl_party_payments_pvt.update_party_payment_hdr(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_pphv_rec		=> l_pphv_rec,
	 x_pphv_rec		=> x_pphv_rec);

      --setting the out record
      x_passthru_rec.base_id := x_pphv_rec.id;
      x_passthru_rec.base_stream_type_id := x_pphv_rec.passthru_stream_type_id;

      -- check return status
      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    End If;
--Update evergreen
    If NOT (l_passthru_rec.evergreen_id IS NULL OR l_passthru_rec.evergreen_id =  OKL_API.G_MISS_NUM) Then
      --l_pphv_rec.id := l_party_payment_rec.id;
      l_pphv_rec.id := l_passthru_rec.evergreen_id;
      l_pphv_rec.passthru_term  := 'EVERGREEN';
      l_pphv_rec.dnz_chr_id := l_passthru_rec.dnz_chr_id;
      l_pphv_rec.cle_id := l_passthru_rec.cle_id;
      l_pphv_rec.passthru_start_date := l_passthru_rec.passthru_start_date;
      l_pphv_rec.payout_basis := l_passthru_rec.evergreen_payout_basis;
      l_pphv_rec.payout_basis_formula := l_passthru_rec.evergreen_payout_basis_formula;
      l_pphv_rec.passthru_stream_type_id := l_passthru_rec.evg_stream_type_id;
      --l_pphv_rec.passthru_stream_type_id := l_passthru_rec.passthru_stream_type_id;


      okl_party_payments_pvt.update_party_payment_hdr(
            p_api_version	=> p_api_version,
            p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
  	    x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_pphv_rec		=> l_pphv_rec,
            x_pphv_rec		=> x_pphv_rec);

      --setting the out record
      x_passthru_rec.evergreen_id := x_pphv_rec.id;
      x_passthru_rec.evg_stream_type_id := x_pphv_rec.passthru_stream_type_id;

      -- check return status
      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    End If;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_payment_hdrs;


  PROCEDURE delete_payment_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_passthru_rec                 IN  passthru_rec_type) IS


    l_api_name		CONSTANT VARCHAR2(30) := 'delete_payment_hdrs';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_passthru_rec passthru_rec_type := p_passthru_rec;
    l_pphv_rec pphv_rec_type := null;
    l_party_payment_rec party_payment_csr%ROWTYPE;
    l_row_found      BOOLEAN := FALSE;
  BEGIN
    --delete payment header base term

    OPEN party_payment_csr(l_passthru_rec.dnz_chr_id,l_passthru_rec.cle_id, 'BASE');
    FETCH party_payment_csr INTO l_party_payment_rec;
    l_row_found := party_payment_csr%FOUND;
    CLOSE party_payment_csr;
    l_pphv_rec.id := l_party_payment_rec.id;

    If (l_row_found) Then
      okl_party_payments_pvt.delete_party_payment_hdr(
         p_api_version	=> p_api_version,
         p_init_msg_list	=> p_init_msg_list,
         x_return_status 	=> x_return_status,
         x_msg_count     	=> x_msg_count,
         x_msg_data      	=> x_msg_data,
         p_pphv_rec		=> l_pphv_rec);

      -- check return status
      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    End If;

    --delete payment header evergreen term

    If (l_passthru_rec.evergreen_eligible_yn = 'Y') Then
      OPEN party_payment_csr(l_passthru_rec.dnz_chr_id,l_passthru_rec.cle_id, 'EVERGREEN');
      FETCH party_payment_csr INTO l_party_payment_rec;
      l_row_found := party_payment_csr%FOUND;
      CLOSE party_payment_csr;
      l_pphv_rec.id := l_party_payment_rec.id;

      --If (l_row_found) Then
      okl_party_payments_pvt.delete_party_payment_hdr(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> x_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_pphv_rec		=> l_pphv_rec);

        -- check return status
        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
        End If;
      --End If;
    End If;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END delete_payment_hdrs;

--Murthy passthru changes end

/*
-- vthiruva, 09/01/2004
-- START, Added PROCEDURE to enable Business Event
*/
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : local_procedure, raises business event by making a call to
--                   okl_wf_pvt.raise_event
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--
PROCEDURE raise_business_event(
                p_api_version       IN NUMBER,
                p_init_msg_list     IN VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_chr_id            IN okc_k_headers_b.id%TYPE,
                p_fee_line_id       IN okc_k_lines_b.id%TYPE,
                p_event_name        IN wf_events.name%TYPE) IS

l_parameter_list      wf_parameter_list_t;
l_contract_process    VARCHAR2(30);
BEGIN
    --create the parameter list to pass to raise_event
    wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
    wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID,p_fee_line_id,l_parameter_list);

    -- wrapper API to get contract process. this API determines in which status the
    -- contract in question is.
    l_contract_process := okl_lla_util_pvt.get_contract_process(p_chr_id => p_chr_id);
    -- add the contract status to the event parameter list
    wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_contract_process,l_parameter_list);

    OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_event_name     => p_event_name,
                           p_parameters     => l_parameter_list);

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END raise_business_event;

/*
-- vthiruva, 09/01/2004
-- END, PROCEDURE to enable Business Event
*/


-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments


  FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
  RETURN VARCHAR2 IS

  	CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	SELECT a.attribute_label_long
	FROM ak_region_items ri, AK_REGIONS r, AK_ATTRIBUTES_vL a
	WHERE ri.region_code = r.region_code
	AND ri.attribute_code = a.attribute_code
	AND ri.attribute_application_id = a.attribute_application_id
	AND ri.region_application_id = r.region_application_id
	AND ri.attribute_code = p_ak_attribute
	AND ri.region_code  =  p_ak_region;

  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	return(l_ak_prompt);
  END;

-- Start of comments
--
-- Procedure Name  : validate_fee_type
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE validate_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 ) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'validate_fee_type';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_supp_id   okx_vendors_v.id1%type := null;
    l_party_name   okx_vendors_v.name%type := null;
    l_item_id     NUMBER:= null;
    l_item_name   OKL_STRMTYP_SOURCE_V.name%type := null;
    l_start_date okc_k_headers_b.start_date%type := null;
    l_pdt_id     okl_k_headers.pdt_id%type := null;
    l_qte_id     okl_k_lines.qte_id%type := null;
    l_chk_qte_id     okl_k_lines.qte_id%type := null;
    l_roll_qt     OKL_TRX_QUOTES_B.QUOTE_NUMBER%type := null;
    l_khr_id     okl_k_headers.khr_id%type := null;

    CURSOR l_supp_name_csr IS
    select id1
    from okx_vendors_v
    where name = p_fee_types_rec.party_name;

    CURSOR l_supp_id1_csr IS
    select name
    from okx_vendors_v
    where id1 = p_fee_types_rec.party_id1;

    CURSOR l_ft_general_item_id_csr IS
    select OKL_STRMTYP.id1
    from OKL_STRMTYP_SOURCE_V OKL_STRMTYP
    where OKL_STRMTYP.name = p_fee_types_rec.item_name
    and OKL_STRMTYP.STATUS = 'A';

    Cursor l_ft_capitalized_item_id_csr(p_pdt_id okl_k_headers.pdt_id%type, p_start_date date) IS
    SELECT  sty_id
    FROM okl_strm_tmpt_full_uv
    WHERE nvl(CAPITALIZE_YN,'N') = 'Y'
    AND STY_PURPOSE = 'EXPENSE'
    AND pdt_id = p_pdt_id
    AND trunc(p_start_date) BETWEEN trunc(okl_strm_tmpt_full_uv.START_DATE)
    AND nvl(trunc(okl_strm_tmpt_full_uv.END_DATE),p_start_date+1)
    AND sty_name = p_fee_types_rec.item_name;

    Cursor l_ft_income_item_id_csr(p_pdt_id okl_k_headers.pdt_id%type, p_start_date date) IS
    SELECT  sty_id
    FROM okl_strm_tmpt_full_uv
    WHERE STY_PURPOSE = 'FEE_PAYMENT'
    AND pdt_id = p_pdt_id
    AND trunc(p_start_date) BETWEEN trunc(okl_strm_tmpt_full_uv.START_DATE)
    AND nvl(trunc(okl_strm_tmpt_full_uv.END_DATE),p_start_date+1)
    AND sty_name = p_fee_types_rec.item_name;

    Cursor l_ft_passthrough_item_id_csr(p_pdt_id okl_k_headers.pdt_id%type, p_start_date date) IS
    SELECT  sty_id
    FROM okl_strm_tmpt_full_uv
    WHERE STY_PURPOSE = 'PASS_THROUGH_FEE'
    AND pdt_id = p_pdt_id
    AND trunc(p_start_date) BETWEEN trunc(okl_strm_tmpt_full_uv.START_DATE)
    AND nvl(trunc(okl_strm_tmpt_full_uv.END_DATE),p_start_date+1)
    AND sty_name = p_fee_types_rec.item_name;

    Cursor l_ft_secdeposit_item_id_csr(p_pdt_id okl_k_headers.pdt_id%type, p_start_date date) IS
    SELECT  sty_id
    FROM okl_strm_tmpt_full_uv
    WHERE STY_PURPOSE = 'SECURITY_DEPOSIT'
    AND pdt_id = p_pdt_id
    AND trunc(p_start_date) BETWEEN trunc(okl_strm_tmpt_full_uv.START_DATE)
    AND nvl(trunc(okl_strm_tmpt_full_uv.END_DATE),p_start_date+1)
    AND sty_name = p_fee_types_rec.item_name;

    Cursor l_ft_others_item_id_csr(p_pdt_id okl_k_headers.pdt_id%type, p_start_date date)  IS
    SELECT  sty_id
    FROM okl_strm_tmpt_full_uv
    WHERE STY_PURPOSE = 'EXPENSE'
    AND pdt_id = p_pdt_id
    AND trunc(p_start_date) BETWEEN trunc(okl_strm_tmpt_full_uv.START_DATE)
    AND nvl(trunc(okl_strm_tmpt_full_uv.END_DATE),p_start_date+1)
    AND sty_name = p_fee_types_rec.item_name;

    CURSOR l_item_name_csr IS
    select name
    from OKL_STRMTYP_SOURCE_V OKL_STRMTYP
    where OKL_STRMTYP.id1 = p_fee_types_rec.item_id1
    and OKL_STRMTYP.STATUS = 'A';

    cursor l_start_date_csr IS
    select chr.start_date, khr.pdt_id
    from okc_k_headers_b chr, okl_k_headers khr
    where chr.id = p_fee_types_rec.dnz_chr_id
    and chr.id = khr.id;

    CURSOR l_roll_qt_csr(p_start_date okc_k_lines_b.start_date%type) IS
    SELECT rqt.qte_id
    FROM OKL_LA_ROLLOVER_FEE_UV rqt,
         OKC_K_HEADERS_B chr
    WHERE CHR.CUST_ACCT_ID = rqt.cust_acct_id
    AND   rqt.rollover_quote = p_fee_types_rec.roll_qt
    AND   trunc(p_start_date) between nvl(trunc(date_effective_from),trunc(p_start_date))
    and   nvl(trunc(date_effective_to),trunc(p_start_date+1))
    AND   chr.id = p_fee_types_rec.dnz_chr_id;

    CURSOR l_qte_id_csr(p_start_date okc_k_lines_b.start_date%type) IS
    SELECT rqt.rollover_quote
    FROM OKL_LA_ROLLOVER_FEE_UV rqt,
         OKC_K_HEADERS_B chr,
         okl_k_headers khr
    WHERE chr.id = khr.id
    and   chr.currency_code = rqt.currency_code
    and   CHR.CUST_ACCT_ID = rqt.cust_acct_id
    AND   rqt.qte_id = p_fee_types_rec.qte_id
    AND   trunc(p_start_date) between nvl(trunc(date_effective_from),trunc(p_start_date))
    and   nvl(trunc(date_effective_to),trunc(p_start_date+1))
    AND   chr.id = p_fee_types_rec.dnz_chr_id;

    CURSOR l_qte_id_prog_csr(p_start_date okc_k_lines_b.start_date%type) IS
    SELECT rqt.rollover_quote
    FROM  OKL_LA_ROLLOVER_FEE_UV rqt,
          OKC_K_HEADERS_B chr,
          okl_k_headers khr
    WHERE chr.id = khr.id
    and   chr.currency_code = rqt.currency_code
    and   CHR.CUST_ACCT_ID = rqt.cust_acct_id
    AND   rqt.qte_id = p_fee_types_rec.qte_id
    AND   trunc(p_start_date) between nvl(trunc(date_effective_from),trunc(p_start_date))
                              and   nvl(trunc(date_effective_to),trunc(p_start_date+1))
    and   khr.khr_id = rqt.khr_id
    and   chr.id = p_fee_types_rec.dnz_chr_id;

    CURSOR l_khr_id_csr IS
    select khr_id
    from okl_k_headers
    where id = p_fee_types_rec.dnz_chr_id;

    CURSOR l_chk_roll_qt_upd_csr(p_qte_id okl_k_lines.qte_id%type) IS
    select 1
    from okl_k_lines kle,
         okc_k_lines_b cle
    where cle.id = kle.id
    and   kle.qte_id = p_qte_id
    and   cle.dnz_chr_id = p_fee_types_rec.dnz_chr_id
    and   cle.id <> p_fee_types_rec.line_id;

    CURSOR l_chk_roll_qt_crt_csr(p_qte_id okl_k_lines.qte_id%type) IS
    select 1
    from okl_k_lines kle,
         okc_k_lines_b cle
    where cle.id = kle.id
    and   kle.qte_id = p_qte_id
    and   cle.dnz_chr_id = p_fee_types_rec.dnz_chr_id;

    CURSOR l_fee_purpose_csr(p_fee_purpose_code okl_k_lines.FEE_PURPOSE_CODE%type) IS
    select lookup_code
    from   fnd_lookups fnd
    where fnd.lookup_type = G_OKL_FEE_PURPOSE_LOOKUP_TYPE
    and   fnd.lookup_code = p_fee_purpose_code;
    l_fee_purpose_code okl_k_lines.fee_purpose_code%type := null;

-- Modified by zrehman for Bug#6763287 on 17-Jan-2008 start
    CURSOR l_inv_id_csr IS
    select hz.party_name
    from
      okc_k_lines_b cle
    , okc_k_headers_all_b chr
    , hz_parties hz
    , hz_cust_accounts hca
    where
        cle.chr_id = chr.id
    and chr.scs_code = 'INVESTOR'
    -- and chr.sts_code='NEW'
    and hca.cust_account_id = cle.cust_acct_id
    and hz.party_id = hca.party_id
    and hz.party_id = p_fee_types_rec.party_id1
    and chr.id = p_fee_types_rec.dnz_chr_id;

    CURSOR l_inv_name_csr IS
    select hz.party_id
    from
      okc_k_lines_b cle
    , okc_k_headers_all_b chr
    , hz_parties hz
    , hz_cust_accounts hca
    where
        cle.chr_id = chr.id
    and chr.scs_code = 'INVESTOR'
    -- and chr.sts_code='NEW'
    and hca.cust_account_id = cle.cust_acct_id
    and hz.party_id = hca.party_id
    and hz.party_name = p_fee_types_rec.party_name
    and chr.id = p_fee_types_rec.dnz_chr_id;

    l_investor_name HZ_PARTIES.PARTY_NAME%TYPE;
    l_investor_id HZ_PARTIES.PARTY_ID%TYPE;
    l_is_ivestor NUMBER;
-- Modified by zrehman for Bug#6763287 on 17-Jan-2008 end
  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   x_fee_types_rec := p_fee_types_rec;

   If ( p_fee_types_rec.dnz_chr_id is null or p_fee_types_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_FEE_TYPE');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => 'dnz_chr_id'
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If ( p_fee_types_rec.fee_type is null or p_fee_types_rec.fee_type = OKC_API.G_MISS_CHAR ) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_FEE_TYPE');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

-- Modified by zrehman for Bug#6763287 on 17-Jan-2008 start
   OPEN  chk_inv_csr(p_fee_types_rec.dnz_chr_id);
   FETCH chk_inv_csr INTO l_is_ivestor;
   CLOSE chk_inv_csr;

   open  l_start_date_csr;
   fetch l_start_date_csr into l_start_date, l_pdt_id;
   close l_start_date_csr;

   --Bug# 6917539: Investor agreement validation causes regression issues
   --              for contracts as NULL value is not handled
   IF NVL(l_is_ivestor,0) <> 1 THEN
-- start validation for Contracts
-- Modified by zrehman on 17-Jan-2008 end

   If (
        p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
        p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS or
        p_fee_types_rec.fee_type = G_FT_FINANCED or
        p_fee_types_rec.fee_type = G_FT_INCOME or
        p_fee_types_rec.fee_type = G_FT_ABSORBED or
        p_fee_types_rec.fee_type = G_FT_SECDEPOSIT or
        p_fee_types_rec.fee_type = G_FT_ROLLOVER or
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then

      If ( NOT (p_fee_types_rec.item_id1 is null or p_fee_types_rec.item_id1 = OKC_API.G_MISS_CHAR )) Then

        l_item_name := null;
        open  l_item_name_csr;
        fetch l_item_name_csr into l_item_name;
        close l_item_name_csr;

        If(l_item_name  is null) Then
          x_return_status := OKC_API.g_ret_sts_error;
          l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
          OKC_API.SET_MESSAGE(    p_app_name => g_app_name
      				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
      				, p_token1 => 'COL_NAME'
      				, p_token1_value => l_ak_prompt
      			   );
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        x_fee_types_rec.item_name := l_item_name;
        x_fee_types_rec.item_id1 := p_fee_types_rec.item_id1;

      ElsIf (NOT( p_fee_types_rec.item_name is null or p_fee_types_rec.item_name = OKC_API.G_MISS_CHAR )) Then

        /*open  l_start_date_csr;
        fetch l_start_date_csr into l_start_date, l_pdt_id;
        close l_start_date_csr;*/

        If(p_fee_types_rec.fee_type = G_FT_CAPITALIZED) Then

         l_item_id := null;
         open  l_ft_capitalized_item_id_csr(l_pdt_id, l_start_date);
         fetch l_ft_capitalized_item_id_csr into l_item_id;
         close l_ft_capitalized_item_id_csr;

        ElsIf(p_fee_types_rec.fee_type = G_FT_INCOME) Then

         l_item_id := null;
         open  l_ft_income_item_id_csr(l_pdt_id, l_start_date);
         fetch l_ft_income_item_id_csr into l_item_id;
         close l_ft_income_item_id_csr;

        ElsIf(p_fee_types_rec.fee_type = G_FT_PASSTHROUGH) Then

         l_item_id := null;
         open  l_ft_passthrough_item_id_csr(l_pdt_id, l_start_date);
         fetch l_ft_passthrough_item_id_csr into l_item_id;
         close l_ft_passthrough_item_id_csr;

        ElsIf(p_fee_types_rec.fee_type = G_FT_SECDEPOSIT) Then

         l_item_id := null;
         open  l_ft_secdeposit_item_id_csr( l_pdt_id, l_start_date);
         fetch l_ft_secdeposit_item_id_csr into l_item_id;
         close l_ft_secdeposit_item_id_csr;

        ElsIf(p_fee_types_rec.fee_type = G_FT_GENERAL) Then

         l_item_id := null;
         open  l_ft_general_item_id_csr;
         fetch l_ft_general_item_id_csr into l_item_id;
         close l_ft_general_item_id_csr;

        Else

         l_item_id := null;
         open  l_ft_others_item_id_csr(l_pdt_id, l_start_date);
         fetch l_ft_others_item_id_csr into l_item_id;
         close l_ft_others_item_id_csr;

        End IF;

        If(l_item_id is null) Then
          x_return_status := OKC_API.g_ret_sts_error;
          l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
          OKC_API.SET_MESSAGE(      p_app_name => g_app_name
      				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
      				, p_token1 => 'COL_NAME'
      				, p_token1_value => l_ak_prompt
      			   );
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        x_fee_types_rec.item_id1 := l_item_id;

      Else

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
   				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
   				, p_token1_value => l_ak_prompt
   			   );
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

   Else

        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_INVALID_FEE_TYPE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => p_fee_types_rec.fee_type
    			   );
        raise OKC_API.G_EXCEPTION_ERROR;

   End If;

   If (
        --Murthy
        --p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
        p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        p_fee_types_rec.fee_type = G_FT_FINANCED or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS or
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then

      If ( NOT (p_fee_types_rec.party_id1 is null or p_fee_types_rec.party_id1 = OKC_API.G_MISS_CHAR )) Then

        l_party_name := null;
        open  l_supp_id1_csr;
        fetch l_supp_id1_csr into l_party_name;
        close l_supp_id1_csr;

        If(l_party_name  is null) Then
          x_return_status := OKC_API.g_ret_sts_error;
          l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
          OKC_API.SET_MESSAGE(    p_app_name => g_app_name
      				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
      				, p_token1 => 'COL_NAME'
      				, p_token1_value => l_ak_prompt
      			   );
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        x_fee_types_rec.party_name := l_party_name;
        x_fee_types_rec.party_id1 := p_fee_types_rec.party_id1;


      ElsIf (NOT( p_fee_types_rec.party_name is null or p_fee_types_rec.party_name = OKC_API.G_MISS_CHAR )) Then

       l_supp_id := null;
       open  l_supp_name_csr;
       fetch l_supp_name_csr into l_supp_id;
       close l_supp_name_csr;

       If(l_supp_id is null) Then
        x_return_status := OKC_API.g_ret_sts_error;
        l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => l_ak_prompt
    			   );
        raise OKC_API.G_EXCEPTION_ERROR;
       End If;

        x_fee_types_rec.party_id1 := l_supp_id;

      Else

        If (NOT(p_fee_types_rec.fee_type = G_FT_CAPITALIZED or p_fee_types_rec.fee_type = G_FT_FINANCED)) Then

           x_return_status := OKC_API.g_ret_sts_error;
           l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
           OKC_API.SET_MESSAGE(     p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
   				, p_token1 => 'COL_NAME'
   				, p_token1_value => l_ak_prompt
   			   );
           raise OKC_API.G_EXCEPTION_ERROR;

        End If;

      End If;

   ElsIf (p_fee_types_rec.party_name is not null and p_fee_types_rec.fee_type = G_FT_SECDEPOSIT) Then

        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_INVLD_FT_PRTY'
    			   );
        raise OKC_API.G_EXCEPTION_ERROR;

   End If;

   If (
        p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
        p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS or
        p_fee_types_rec.fee_type = G_FT_FINANCED or
        p_fee_types_rec.fee_type = G_FT_ROLLOVER or
        p_fee_types_rec.fee_type = G_FT_INCOME or
        p_fee_types_rec.fee_type = G_FT_ABSORBED or
        p_fee_types_rec.fee_type = G_FT_SECDEPOSIT or
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then
	If ( p_fee_types_rec.effective_from is null or p_fee_types_rec.effective_from = OKC_API.G_MISS_DATE ) Then
	   x_return_status := OKC_API.g_ret_sts_error;
	   l_ak_prompt := GET_AK_PROMPT('OKL_LA_MLA_DTAIL', 'OKL_START_DATE');
	   OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_REQUIRED_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
	  			   );
	   raise OKC_API.G_EXCEPTION_ERROR;
	End If;

   End If;

   If (
        p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
        p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS or
        p_fee_types_rec.fee_type = G_FT_FINANCED or
        p_fee_types_rec.fee_type = G_FT_ROLLOVER or
        p_fee_types_rec.fee_type = G_FT_INCOME or
        p_fee_types_rec.fee_type = G_FT_ABSORBED or
        p_fee_types_rec.fee_type = G_FT_SECDEPOSIT or
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then

	If ( p_fee_types_rec.effective_to is null or p_fee_types_rec.effective_to = OKC_API.G_MISS_DATE ) Then
	   x_return_status := OKC_API.g_ret_sts_error;
	   l_ak_prompt := GET_AK_PROMPT('OKL_LA_MLA_DTAIL', 'OKL_END_DATE');
	   OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_REQUIRED_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
	  			   );
	   raise OKC_API.G_EXCEPTION_ERROR;
	End If;

   End If;


   If ( p_fee_types_rec.fee_type = G_FT_ROLLOVER) Then

     If ( NOT (p_fee_types_rec.qte_id is null or p_fee_types_rec.qte_id = OKC_API.G_MISS_NUM )) Then

        l_khr_id := null;
        open l_khr_id_csr;
        fetch l_khr_id_csr into l_khr_id;
        close l_khr_id_csr;

        If( l_khr_id is null) Then

         l_roll_qt := null;
         open  l_qte_id_csr(p_fee_types_rec.effective_from);
         fetch l_qte_id_csr into l_roll_qt;
         close l_qte_id_csr;

        Else -- program agreement attached to the contract

         l_roll_qt := null;
         open  l_qte_id_prog_csr(p_fee_types_rec.effective_from);
         fetch l_qte_id_prog_csr into l_roll_qt;
         close l_qte_id_prog_csr;

        End If;

        If(l_roll_qt is null) Then

          x_return_status := OKC_API.g_ret_sts_error;
          l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ROLL_QT');
          If(l_ak_prompt is null) Then
           l_ak_prompt := 'QTE_ID';
          End if;

          OKC_API.SET_MESSAGE(    p_app_name => g_app_name
      				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
      				, p_token1 => 'COL_NAME'
      				, p_token1_value => l_ak_prompt
      			   );
          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

       x_fee_types_rec.qte_id := p_fee_types_rec.qte_id;
       l_qte_id := p_fee_types_rec.qte_id;

     ElsIf(NOT ( p_fee_types_rec.roll_qt is null or p_fee_types_rec.roll_qt = OKC_API.G_MISS_NUM )) Then

       l_qte_id := null;


       open  l_roll_qt_csr(p_fee_types_rec.effective_from);
       fetch l_roll_qt_csr into l_qte_id;
       close l_roll_qt_csr;

       If(l_qte_id is null) Then
        x_return_status := OKC_API.g_ret_sts_error;
        l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ROLL_QT');
        If(l_ak_prompt is null) then
          l_ak_prompt := 'Rollover Quote';
        End If;
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
       				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
       				, p_token1 => 'COL_NAME'
       				, p_token1_value => l_ak_prompt
           			   );
        raise OKC_API.G_EXCEPTION_ERROR;
       End If;

       x_fee_types_rec.qte_id := l_qte_id;


     Else

       x_return_status := OKC_API.g_ret_sts_error;
       l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ROLL_QT');
       If(l_ak_prompt is null) then
       	l_ak_prompt := 'Rollover Quote';
       End If;

       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
   				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
	  			   );
       raise OKC_API.G_EXCEPTION_ERROR;

     End If;


     If(NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) Then

       -- check if rollover quote already associated to a line
       l_chk_qte_id := null;
       open  l_chk_roll_qt_upd_csr(l_qte_id);
       fetch l_chk_roll_qt_upd_csr into l_chk_qte_id;
       close l_chk_roll_qt_upd_csr;

       If(l_chk_qte_id is not null ) Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
       				, p_msg_name => 'OKL_QA_DUP_TERM_QUOTE'
           			   );
          raise OKC_API.G_EXCEPTION_ERROR;
       End If;

      Else

       l_chk_qte_id := null;
       open  l_chk_roll_qt_crt_csr(l_qte_id);
       fetch l_chk_roll_qt_crt_csr into l_chk_qte_id;
       close l_chk_roll_qt_crt_csr;

       If(l_chk_qte_id is not null ) Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
       				, p_msg_name => 'OKL_QA_DUP_TERM_QUOTE'
           			   );
          raise OKC_API.G_EXCEPTION_ERROR;
       End If;

     End If;

   End If;

   If (
        p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
        p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS or
        p_fee_types_rec.fee_type = G_FT_FINANCED or
        p_fee_types_rec.fee_type = G_FT_ROLLOVER or
        p_fee_types_rec.fee_type = G_FT_INCOME or
        p_fee_types_rec.fee_type = G_FT_ABSORBED or
        p_fee_types_rec.fee_type = G_FT_SECDEPOSIT or
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then

	   If ( p_fee_types_rec.amount is null or p_fee_types_rec.amount = OKC_API.G_MISS_NUM ) Then
	      x_return_status := OKC_API.g_ret_sts_error;
	      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
	      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_REQUIRED_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
	  			   );
	      raise OKC_API.G_EXCEPTION_ERROR;
	   End If;

     End If;


   If (
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS or
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then

     If( p_fee_types_rec.initial_direct_cost is not null and p_fee_types_rec.initial_direct_cost > p_fee_types_rec.amount) Then

	      x_return_status := OKC_API.g_ret_sts_error;
	      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_FEE_IDC_AMT'
	  			   );
	      raise OKC_API.G_EXCEPTION_ERROR;

      End If;

   ElsIf (
        (( NOT ( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM)) and
                (p_fee_types_rec.fee_type = G_FT_GENERAL)
                )
   ) Then

     If( NOT (p_fee_types_rec.initial_direct_cost is not null and p_fee_types_rec.initial_direct_cost = p_fee_types_rec.amount)) Then

	      x_return_status := OKC_API.g_ret_sts_error;
	      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_FEE_IDC_AMT_ABSORBED'
	  			   );
	      raise OKC_API.G_EXCEPTION_ERROR;

      End If;

    Else

      If (p_fee_types_rec.initial_direct_cost is not null and
              (
               p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
               p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
               p_fee_types_rec.fee_type = G_FT_FINANCED or
               p_fee_types_rec.fee_type = G_FT_INCOME or
               p_fee_types_rec.fee_type = G_FT_SECDEPOSIT
               )
       ) Then
   	        x_return_status := OKC_API.g_ret_sts_error;
	        l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE_IDC');
	        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_INVALID_VALUE'
	    				, p_token1 => 'COL_NAME'
	    				, p_token1_value => l_ak_prompt
	    			   );
                 raise OKC_API.G_EXCEPTION_ERROR;
       End If;

    End If;

   If (        p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
               p_fee_types_rec.fee_type = G_FT_FINANCED
      ) Then

           IF (p_fee_types_rec.fee_purpose_code is not null AND p_fee_types_rec.fee_purpose_code <> OKL_API.G_MISS_CHAR) THEN

              l_fee_purpose_code := null;
              open l_fee_purpose_csr(p_fee_types_rec.fee_purpose_code);
              fetch l_fee_purpose_csr into l_fee_purpose_code;
              close l_fee_purpose_csr;
/*
              If ( l_fee_purpose_code is null) Then
   	        x_return_status := OKC_API.g_ret_sts_error;
	        l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE_PURPOSE_MEANING');
	        if(l_ak_prompt is null) Then  l_ak_prompt := 'Fee Purpose Code';  End if;
	        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_INVALID_VALUE'
	    				, p_token1 => 'COL_NAME'
	    				, p_token1_value => l_ak_prompt
	    			   );
                 raise OKC_API.G_EXCEPTION_ERROR;
               End If;
*/
            End If;

       End If;

--   x_return_status := OKC_API.G_RET_STS_SUCCESS;


-- Modified by zrehman for Bug#6763287 on 17-Jan-2008 start
   --Bug# 6917539: Investor agreement validation causes regression issues
   --              for contracts as NULL value is not handled
   ELSIF NVL(l_is_ivestor,0) = 1 THEN -- start validation of fee type for Investor Agreement
     If (
          p_fee_types_rec.fee_type = G_FT_INCOME or
          p_fee_types_rec.fee_type = G_FT_EXPENSE
        ) Then

	If ( NOT (p_fee_types_rec.item_id1 is null or p_fee_types_rec.item_id1 = OKC_API.G_MISS_CHAR )) Then
          l_item_name := null;
          open  l_item_name_csr;
          fetch l_item_name_csr into l_item_name;
          close l_item_name_csr;
          If(l_item_name  is null) Then
            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
            OKC_API.SET_MESSAGE(    p_app_name => g_app_name
      	        		  , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
      				  , p_token1 => 'COL_NAME'
      				  , p_token1_value => l_ak_prompt
      			       );
            raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         x_fee_types_rec.item_name := l_item_name;
         x_fee_types_rec.item_id1 := p_fee_types_rec.item_id1;
	ElsIf (NOT( p_fee_types_rec.item_name is null or p_fee_types_rec.item_name = OKC_API.G_MISS_CHAR )) Then

	  If(p_fee_types_rec.fee_type = G_FT_EXPENSE) Then
            l_item_id := null;
            open  l_ft_others_item_id_csr(l_pdt_id, l_start_date);
            fetch l_ft_others_item_id_csr into l_item_id;
            close l_ft_others_item_id_csr;

	  ElsIf(p_fee_types_rec.fee_type = G_FT_INCOME) Then
            l_item_id := null;
            open  l_ft_income_item_id_csr(l_pdt_id, l_start_date);
            fetch l_ft_income_item_id_csr into l_item_id;
            close l_ft_income_item_id_csr;
	  End If;

          If(l_item_id is null) Then
            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
            OKC_API.SET_MESSAGE(    p_app_name => g_app_name
      			          , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
      				  , p_token1 => 'COL_NAME'
      				  , p_token1_value => l_ak_prompt
      			        );
            raise OKC_API.G_EXCEPTION_ERROR;
          End If;
          x_fee_types_rec.item_id1 := l_item_id;

	Else -- item name, item id are null
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
   				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
   				, p_token1_value => l_ak_prompt
   			   );
         raise OKC_API.G_EXCEPTION_ERROR;
	End If; -- check for item_id1 and item_name

	 -- validation for party_id1 start
	 If ( NOT(p_fee_types_rec.party_id1 is null or p_fee_types_rec.party_id1 = OKC_API.G_MISS_NUM)) Then
             OPEN l_inv_id_csr;
	     FETCH l_inv_id_csr into l_investor_name;
	     CLOSE l_inv_id_csr;

	     If l_investor_name IS NULL THEN
                x_return_status := OKC_API.g_ret_sts_error;
     	        l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_LA_INVESTOR');
	        OKC_API.SET_MESSAGE(       p_app_name => g_app_name
	  				  , p_msg_name => 'OKL_INVALID_VALUE'
	  			  	  , p_token1 => 'COL_NAME'
	  				  , p_token1_value => l_ak_prompt
	  			    );
	        raise OKC_API.G_EXCEPTION_ERROR;
	     End If;
	     x_fee_types_rec.party_name := l_investor_name;
	 ElsIf ( NOT(p_fee_types_rec.party_name is null or p_fee_types_rec.party_name = OKC_API.G_MISS_CHAR)) Then
             OPEN l_inv_name_csr;
	     FETCH l_inv_name_csr into l_investor_id;
	     CLOSE l_inv_name_csr;
	     IF l_investor_id is NULL THEN
               l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_LA_INVESTOR');
	       OKC_API.SET_MESSAGE(       p_app_name => g_app_name
	  				, p_msg_name => 'OKL_INVALID_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
  				);
              raise OKC_API.G_EXCEPTION_ERROR;
	     END IF;

	     x_fee_types_rec.party_id1 := l_investor_id;
	 End If;
	 -- validation for party_id1 end
	 --validation for feeamount for investor
	  If (  (l_investor_name is not null and   p_fee_types_rec.fee_type = G_FT_EXPENSE) and (p_fee_types_rec.amount < 0) ) Then
	      x_return_status := OKC_API.g_ret_sts_error;
	      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_INV_AMOUNT_CHECK'
	  			   );
	      raise OKC_API.G_EXCEPTION_ERROR;
	 End If;

	-- validation for effective_from start
	 If ( p_fee_types_rec.effective_from is null or p_fee_types_rec.effective_from = OKC_API.G_MISS_DATE ) Then
	   x_return_status := OKC_API.g_ret_sts_error;
	   l_ak_prompt := GET_AK_PROMPT('OKL_LA_MLA_DTAIL', 'OKL_START_DATE');
	   OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_REQUIRED_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
	  			   );
	   raise OKC_API.G_EXCEPTION_ERROR;
	 End If;
	 -- validation for effective_from end

	 -- validation for effective_to start
	 If ( p_fee_types_rec.effective_to is null or p_fee_types_rec.effective_to = OKC_API.G_MISS_DATE ) Then
	   x_return_status := OKC_API.g_ret_sts_error;
	   l_ak_prompt := GET_AK_PROMPT('OKL_LA_MLA_DTAIL', 'OKL_END_DATE');
	   OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_REQUIRED_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
	  			   );
	   raise OKC_API.G_EXCEPTION_ERROR;
	 End If;
	 -- validation for effective_to end

	 -- validation for amount start
	 If ( p_fee_types_rec.amount is null or p_fee_types_rec.amount = OKC_API.G_MISS_NUM ) Then
	      x_return_status := OKC_API.g_ret_sts_error;
	      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
	      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
	  				, p_msg_name => 'OKL_REQUIRED_VALUE'
	  				, p_token1 => 'COL_NAME'
	  				, p_token1_value => l_ak_prompt
	  			   );
	      raise OKC_API.G_EXCEPTION_ERROR;
	 End If;
	 -- validation for amount end

     --End If;
    Else -- fee type is not among valid ones
        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_INVALID_FEE_TYPE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => p_fee_types_rec.fee_type
    			   );
        raise OKC_API.G_EXCEPTION_ERROR;

    END IF; -- end validation of fee type for Investor Agreement
 END IF; -- Check if contract or investor

 -- Modified by zrehman on 17-Jan-2008 end
   OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END validate_fee_type;

-- Start of comments
--
-- Procedure Name  : fill_fee_type_info
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE fill_fee_type_info(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fee_types_rec                IN  fee_types_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY okl_kle_pvt.klev_rec_type,
    x_cimv_rec                     OUT NOCOPY okl_okc_migration_pvt.cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'fill_fee_type_info';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_lse_id OKC_LINE_STYLES_B.id%type := null;
    l_currency_code okc_k_headers_b.currency_code%type := null;
    l_sts_code okc_k_headers_b.sts_code%type := null;

    CURSOR get_lse_id_csr IS
     select  id
     from okc_line_styles_v
     where lty_code = 'FEE';

    CURSOR get_cur_sts_code_csr(chr_id NUMBER) IS
     select  currency_code,sts_code
     from okc_k_headers_b
     where id = chr_id;

    -- Modified by zrehman for Bug#6763287 on 17-Jan-2008 start
    l_is_investor NUMBER;

    -- Modified by zrehman on 17-Jan-2008 end
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_lse_id := null;
    open get_lse_id_csr;
    fetch get_lse_id_csr into l_lse_id;
    close get_lse_id_csr;

    If(l_lse_id is null) Then
       x_return_status := OKC_API.g_ret_sts_error;
       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_INVALID_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'LSE_ID'
    			   );
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_currency_code := null;
    l_sts_code := null;
    open get_cur_sts_code_csr(p_fee_types_rec.dnz_chr_id);
    fetch get_cur_sts_code_csr into l_currency_code,l_sts_code;
    close get_cur_sts_code_csr;

    If(l_currency_code is null) Then
       x_return_status := OKC_API.g_ret_sts_error;
       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_INVALID_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'CURRENCY_CODE'
    			   );
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    If(l_sts_code is null) Then
       x_return_status := OKC_API.g_ret_sts_error;
       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_INVALID_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'STS_CODE'
    			   );
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- Modified by zrehman on 17-Jan-2008 start
    OPEN chk_inv_csr(p_fee_types_rec.dnz_chr_id);
    FETCH chk_inv_csr INTO l_is_investor;
    CLOSE chk_inv_csr;
    -- Modified by zrehman on 17-Jan-2008 end

    x_clev_rec.currency_code := l_currency_code;
    x_clev_rec.sts_code := l_sts_code;
    x_clev_rec.lse_id := l_lse_id;

    x_clev_rec.line_number := '1';
    x_clev_rec.exception_yn := 'N';
    x_clev_rec.display_sequence := 1;
    x_clev_rec.cle_id := null;
    x_clev_rec.dnz_chr_id := p_fee_types_rec.dnz_chr_id;
    x_clev_rec.chr_id := p_fee_types_rec.dnz_chr_id;
    x_clev_rec.name := p_fee_types_rec.item_name;
    x_clev_rec.id := p_fee_types_rec.line_id;
    x_clev_rec.start_date := p_fee_types_rec.effective_from;
    x_clev_rec.end_date := p_fee_types_rec.effective_to;

    x_klev_rec.kle_id := x_clev_rec.id;
    x_klev_rec.initial_direct_cost := p_fee_types_rec.initial_direct_cost;
    x_klev_rec.amount := p_fee_types_rec.amount;
    x_klev_rec.fee_type := p_fee_types_rec.fee_type;

    If( p_fee_types_rec.fee_type = G_FT_ROLLOVER ) Then
      x_klev_rec.qte_id := p_fee_types_rec.qte_id;
    End If;

    x_klev_rec.funding_date := p_fee_types_rec.funding_date;

    If( p_fee_types_rec.fee_type = G_FT_CAPITALIZED ) Then
      x_klev_rec.capital_amount := p_fee_types_rec.amount;
    End If;

    If( p_fee_types_rec.fee_type = G_FT_ABSORBED) Then
      x_klev_rec.initial_direct_cost := p_fee_types_rec.amount;
    End If;

    -- sales tax changes
    --Bug# 6917539: Investor agreement validation causes regression issues
    --              for contracts as NULL value is not handled
    If( NVL(l_is_investor,0) <> 1 AND (p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKL_API.G_MISS_NUM)  and
        (p_fee_types_rec.fee_type = G_FT_CAPITALIZED OR p_fee_types_rec.fee_type = G_FT_FINANCED)
         OR (p_fee_types_rec.fee_type = G_FT_ABSORBED AND p_fee_types_rec.fee_purpose_code
         <> OKL_API.G_MISS_CHAR AND p_fee_types_rec.fee_purpose_code = 'RVI') ) Then
      x_klev_rec.fee_purpose_code := p_fee_types_rec.fee_purpose_code;
    End If;

    --Bug# 4558486
    x_klev_rec.attribute_category := p_fee_types_rec.attribute_category;
    x_klev_rec.attribute1         := p_fee_types_rec.attribute1;
    x_klev_rec.attribute2         := p_fee_types_rec.attribute2;
    x_klev_rec.attribute3         := p_fee_types_rec.attribute3;
    x_klev_rec.attribute4         := p_fee_types_rec.attribute4;
    x_klev_rec.attribute5         := p_fee_types_rec.attribute5;
    x_klev_rec.attribute6         := p_fee_types_rec.attribute6;
    x_klev_rec.attribute7         := p_fee_types_rec.attribute7;
    x_klev_rec.attribute8         := p_fee_types_rec.attribute8;
    x_klev_rec.attribute9         := p_fee_types_rec.attribute9;
    x_klev_rec.attribute10        := p_fee_types_rec.attribute10;
    x_klev_rec.attribute11        := p_fee_types_rec.attribute11;
    x_klev_rec.attribute12        := p_fee_types_rec.attribute12;
    x_klev_rec.attribute13        := p_fee_types_rec.attribute13;
    x_klev_rec.attribute14        := p_fee_types_rec.attribute14;
    x_klev_rec.attribute15        := p_fee_types_rec.attribute15;
    x_klev_rec.validate_dff_yn    := p_fee_types_rec.validate_dff_yn;

    x_cimv_rec.cle_id := x_clev_rec.id;
    x_cimv_rec.cle_id_for := null;
    x_cimv_rec.chr_id := null;
    x_cimv_rec.exception_yn := 'N';
    x_cimv_rec.number_of_items := 1;
    x_cimv_rec.dnz_chr_id := p_fee_types_rec.dnz_chr_id;
    x_cimv_rec.id := p_fee_types_rec.item_id;
    x_cimv_rec.object1_id1 := p_fee_types_rec.item_id1;
    x_cimv_rec.object1_id2 := '#';
    x_cimv_rec.jtot_object1_code := 'OKL_STRMTYP';

    x_cplv_rec.dnz_chr_id := p_fee_types_rec.dnz_chr_id;
    x_cplv_rec.cle_id := x_clev_rec.id;
    x_cplv_rec.id := p_fee_types_rec.party_id;
    x_cplv_rec.object1_id1 := p_fee_types_rec.party_id1;
    x_cplv_rec.object1_id2 := '#';
    x_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
    x_cplv_rec.rle_code := 'OKL_VENDOR';

    -- Modified by zrehman on 17-Jan-2008 start
    --Bug# 6917539: Investor agreement validation causes regression issues
    --              for contracts as NULL value is not handled
    IF (NVL(l_is_investor,0) = 1) THEN
     x_clev_rec.chr_id := p_fee_types_rec.dnz_chr_id;
     x_klev_rec.kle_id := x_clev_rec.cle_id;
     x_klev_rec.initial_direct_cost := null;
     x_cplv_rec.jtot_object1_code := 'OKX_PARTY';
     x_cplv_rec.rle_code := 'INVESTOR';
    END IF;
    -- Modified by zrehman on 17-Jan-2008 end

    -- Bug# 4721428
    -- Reverted commenting out NOT predicate, as this is causes UI issues
    --Bug# 6917539: Investor agreement validation causes regression issues
    --              for contracts as NULL value is not handled
    If ( NVL(l_is_investor,0) <> 1 AND (
          p_fee_types_rec.fee_type = G_FT_PASSTHROUGH or
        --p_fee_types_rec.fee_type = G_FT_CAPITALIZED or
        p_fee_types_rec.fee_type = G_FT_EXPENSE or
        --p_fee_types_rec.fee_type = G_FT_FINANCED or
        p_fee_types_rec.fee_type = G_FT_MISCELLANEOUS)
        and ( (NOT ( p_fee_types_rec.party_id is null or p_fee_types_rec.party_id = OKC_API.G_MISS_NUM)) and
                p_fee_types_rec.party_name is null)

    ) Then

        x_return_status := OKC_API.g_ret_sts_error;
        l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
         				, p_msg_name => 'OKL_REQUIRED_VALUE'
         				, p_token1 => 'COL_NAME'
         				, p_token1_value => l_ak_prompt
         			   );
        raise OKC_API.G_EXCEPTION_ERROR;

     End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END fill_fee_type_info;


  PROCEDURE create_fee_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  okl_kle_pvt.klev_rec_type,
    p_cimv_rec                     IN  okl_okc_migration_pvt.cimv_rec_type,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY okl_kle_pvt.klev_rec_type,
    x_cimv_rec                     OUT NOCOPY okl_okc_migration_pvt.cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type := p_clev_rec;
    l_klev_rec okl_kle_pvt.klev_rec_type := p_klev_rec;
    l_cimv_rec okl_okc_migration_pvt.cimv_rec_type := p_cimv_rec;
    l_cplv_rec okl_okc_migration_pvt.cplv_rec_type := p_cplv_rec;

    l_chr_id  l_clev_rec.dnz_chr_id%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'create_fee_top_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    --Bug# 4558486
    l_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
    x_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

  BEGIN

    l_chr_id := l_clev_rec.dnz_chr_id;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    okl_contract_pvt.create_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

   l_cimv_rec.cle_id :=  x_clev_rec.id;

    okl_okc_migration_pvt.create_contract_item(
	 p_api_version	        => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cimv_rec		=> l_cimv_rec,
	 x_cimv_rec		=> x_cimv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   l_cplv_rec.cle_id :=  x_clev_rec.id;

   If ( l_cplv_rec.object1_id1 is not null and l_cplv_rec.object1_id2 is not null) Then

    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to create records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    okl_okc_migration_pvt.create_k_party_role(
	 p_api_version	        => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
	 x_cplv_rec		=> x_cplv_rec);
    */

    okl_k_party_roles_pvt.create_k_party_role(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_cplv_rec             => l_cplv_rec,
         x_cplv_rec             => x_cplv_rec,
         p_kplv_rec             => l_kplv_rec,
         x_kplv_rec             => x_kplv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   End if;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_fee_top_line;



-- Start of comments
--
-- Procedure Name  : create_fee_type
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE create_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 ) IS

    lp_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type := p_fee_types_rec;
    lx_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

    lp_klev_rec  okl_kle_pvt.klev_rec_type;
    lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;
    lp_cimv_rec  okl_okc_migration_pvt.cimv_rec_type;
    lp_cplv_rec  okl_okc_migration_pvt.cplv_rec_type;

    lx_klev_rec  okl_kle_pvt.klev_rec_type;
    lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;
    lx_cimv_rec  okl_okc_migration_pvt.cimv_rec_type;
    lx_cplv_rec  okl_okc_migration_pvt.cplv_rec_type;

    l_chr_id         okc_k_headers_b.id%type := p_fee_types_rec.dnz_chr_id;

    l_api_name	     CONSTANT VARCHAR2(30) := 'create_fee_type';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;

  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   OKL_MAINTAIN_FEE_PVT.validate_fee_type(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_fee_types_rec       => lp_fee_types_rec,
          x_fee_types_rec       => lx_fee_types_rec
      );

  If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  fill_fee_type_info(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_fee_types_rec       => lx_fee_types_rec,
          x_clev_rec            => lx_clev_rec,
          x_klev_rec            => lx_klev_rec,
          x_cimv_rec            => lx_cimv_rec,
          x_cplv_rec            => lx_cplv_rec);

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  lp_clev_rec := lx_clev_rec;
  lp_klev_rec := lx_klev_rec;
  lp_cimv_rec := lx_cimv_rec;
  lp_cplv_rec := lx_cplv_rec;

  If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

  OKL_MAINTAIN_FEE_PVT.create_fee_top_line(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_clev_rec            => lp_clev_rec,
          p_klev_rec            => lp_klev_rec,
          p_cimv_rec            => lp_cimv_rec,
          p_cplv_rec            => lp_cplv_rec,
          x_clev_rec            => lx_clev_rec,
          x_klev_rec            => lx_klev_rec,
          x_cimv_rec            => lx_cimv_rec,
          x_cplv_rec            => lx_cplv_rec
    );

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  x_fee_types_rec.line_id := lx_clev_rec.id;
  x_fee_types_rec.item_id := lx_cimv_rec.id;
  x_fee_types_rec.party_id := lx_cplv_rec.id;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;


  PROCEDURE update_fee_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  okl_kle_pvt.klev_rec_type,
    p_cimv_rec                     IN  okl_okc_migration_pvt.cimv_rec_type,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY okl_kle_pvt.klev_rec_type,
    x_cimv_rec                     OUT NOCOPY okl_okc_migration_pvt.cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type := p_clev_rec;
    l_klev_rec okl_kle_pvt.klev_rec_type := p_klev_rec;
    l_cimv_rec okl_okc_migration_pvt.cimv_rec_type := p_cimv_rec;
    l_cplv_rec okl_okc_migration_pvt.cplv_rec_type := p_cplv_rec;

    l_chr_id  l_clev_rec.dnz_chr_id%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'update_fee_top_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    --Bug# 4558486
    l_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
    x_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

    --Bug# 4721428
    CURSOR fee_subline_csr (p_cle_id IN NUMBER,
                            p_chr_id IN NUMBER) IS
    SELECT cle.id,
           cle.start_date,
           cle.end_date
    FROM   okc_k_lines_b cle
    WHERE  cle.cle_id   = p_cle_id
    AND    cle.dnz_chr_id = p_chr_id;

    l_sub_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_sub_klev_rec okl_kle_pvt.klev_rec_type;

    x_sub_clev_rec okl_okc_migration_pvt.clev_rec_type;
    x_sub_klev_rec okl_kle_pvt.klev_rec_type;

  BEGIN

    l_chr_id := l_clev_rec.dnz_chr_id;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    okl_contract_pvt.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    --Bug# 4721428
    For fee_subline_rec In fee_subline_csr(p_cle_id => l_clev_rec.id,
                                           p_chr_id => l_clev_rec.dnz_chr_id) Loop

      If ( (NVL(l_clev_rec.start_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE AND
            fee_subline_rec.start_date <> l_clev_rec.start_date) OR
           (NVL(l_clev_rec.end_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE AND
            fee_subline_rec.end_date <> l_clev_rec.end_date) ) Then

        l_sub_clev_rec.id := fee_subline_rec.id;
        l_sub_klev_rec.id := fee_subline_rec.id;
        l_sub_clev_rec.start_date :=l_clev_rec.start_date;
        l_sub_clev_rec.end_date :=l_clev_rec.end_date;

        OKL_CONTRACT_PVT.update_contract_line(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_clev_rec            => l_sub_clev_rec,
          p_klev_rec            => l_sub_klev_rec,
          x_clev_rec            => x_sub_clev_rec,
          x_klev_rec            => x_sub_klev_rec
        );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      End If;
    End Loop;
    --Bug# 4721428

   l_cimv_rec.cle_id :=  x_clev_rec.id;

    okl_okc_migration_pvt.update_contract_item(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cimv_rec		=> l_cimv_rec,
	 x_cimv_rec		=> x_cimv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   l_cplv_rec.cle_id :=  x_clev_rec.id;


   If ( (l_cplv_rec.id is null or l_cplv_rec.id = OKC_API.G_MISS_NUM ) and ( l_cplv_rec.object1_id1 is not null )) Then

    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to create records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    okl_okc_migration_pvt.create_k_party_role(
	 p_api_version	        => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
	 x_cplv_rec		=> x_cplv_rec);
    */
    okl_k_party_roles_pvt.create_k_party_role(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             =>  x_msg_data,
         p_cplv_rec             => l_cplv_rec,
         x_cplv_rec             => x_cplv_rec,
         p_kplv_rec             => l_kplv_rec,
         x_kplv_rec             => x_kplv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   ElsIf ( l_cplv_rec.id is not null and l_cplv_rec.object1_id1 is not null ) Then

       --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
       --              to update records in tables
       --              okc_k_party_roles_b and okl_k_party_roles
       /*
       okl_okc_migration_pvt.update_k_party_role(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
	 x_cplv_rec		=> x_cplv_rec);
       */

       l_kplv_rec.id := l_cplv_rec.id;
       okl_k_party_roles_pvt.update_k_party_role(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_cplv_rec             => l_cplv_rec,
         x_cplv_rec             => x_cplv_rec,
         p_kplv_rec             => l_kplv_rec,
         x_kplv_rec             => x_kplv_rec );

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   Elsif ( l_cplv_rec.id is not null and l_cplv_rec.object1_id1 is null ) Then

       --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
       --              to delete records in tables
       --              okc_k_party_roles_b and okl_k_party_roles
       /*
       okl_okc_migration_pvt.delete_k_party_role(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec);
       */

       l_kplv_rec.id := l_cplv_rec.id;
       okl_k_party_roles_pvt.delete_k_party_role(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_cplv_rec             => l_cplv_rec,
         p_kplv_rec             => l_kplv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   End if;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END update_fee_top_line;


-- Start of comments
--
-- Procedure Name  : update_fee_type
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE update_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 ) IS

    lp_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type := p_fee_types_rec;
    lx_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

    lp_klev_rec  okl_kle_pvt.klev_rec_type;
    lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;
    lp_cimv_rec  okl_okc_migration_pvt.cimv_rec_type;
    lp_cplv_rec  okl_okc_migration_pvt.cplv_rec_type;

    lx_klev_rec  okl_kle_pvt.klev_rec_type;
    lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;
    lx_cimv_rec  okl_okc_migration_pvt.cimv_rec_type;
    lx_cplv_rec  okl_okc_migration_pvt.cplv_rec_type;

    l_chr_id         okc_k_headers_b.id%type := p_fee_types_rec.dnz_chr_id;
    l_rgp_id  okc_rules_v.id%type := null;
    l_rul_id  okc_rules_v.id%type := null;

    l_api_name	     CONSTANT VARCHAR2(30) := 'update_fee_type';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;

    CURSOR l_strm_type_rul_csr IS
      select rgp.id,
             rul.id
      from okc_rules_v rul,
                  okc_rule_groups_v rgp
       where rgp.id = rul.rgp_id
       and rgp.rgd_code = 'LAPSTH'
       and rul.rule_information_category = 'LASTRM'
       and rgp.cle_id = p_fee_types_rec.line_id
       and rul.dnz_chr_id = p_fee_types_rec.dnz_chr_id
       and rgp.dnz_chr_id = p_fee_types_rec.dnz_chr_id;

    --Bug# 4899328
    l_chk_rebook_chr VARCHAR2(1);

    CURSOR l_line_csr(p_cle_id IN NUMBER) IS
    SELECT kle.qte_id,
           cle.orig_system_id1
    FROM   okl_k_lines kle,
           okc_k_lines_b cle
    WHERE  cle.id = p_cle_id
    AND    kle.id = cle.id;

    -- Bug# 6438785
    CURSOR c_orig_cle_csr(p_cle_id IN NUMBER) IS
    SELECT cle.start_date
    FROM   okc_k_lines_b cle
    WHERE  cle.id = p_cle_id;

    l_orig_cle_rec c_orig_cle_csr%ROWTYPE;

  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   --Bug# 4959361
   OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => lp_fee_types_rec.line_id);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   --Bug# 4959361

   OKL_MAINTAIN_FEE_PVT.validate_fee_type(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_fee_types_rec       => lp_fee_types_rec,
          x_fee_types_rec       => lx_fee_types_rec
      );

  If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  --Bug# 4899328
  l_chk_rebook_chr := OKL_LLA_UTIL_PVT.check_rebook_contract(p_chr_id => lp_fee_types_rec.dnz_chr_id);
  If (l_chk_rebook_chr = OKL_API.G_TRUE and lp_fee_types_rec.fee_type = G_FT_ROLLOVER) Then

    For l_line_rec In l_line_csr(p_cle_id => lp_fee_types_rec.line_id) Loop

      If (l_line_rec.orig_system_id1 IS NOT NULL And
          l_line_rec.qte_id <>  lp_fee_types_rec.qte_id) Then

        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LA_RBK_ROLL_QT_UPDATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;

      End If;
    End Loop;
  End If;
  --Bug# 4899328

  fill_fee_type_info(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_fee_types_rec       => lp_fee_types_rec,
          x_clev_rec            => lx_clev_rec,
          x_klev_rec            => lx_klev_rec,
          x_cimv_rec            => lx_cimv_rec,
          x_cplv_rec            => lx_cplv_rec);

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  lp_clev_rec := lx_clev_rec;
  lp_klev_rec := lx_klev_rec;
  lp_cimv_rec := lx_cimv_rec;
  lp_cplv_rec := lx_cplv_rec;

  If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

  -- Bug# 6438785
  -- Fetch original fee line start date for checking
  -- whether start date has been changed
  OPEN c_orig_cle_csr(p_cle_id => lp_clev_rec.id);
  FETCH c_orig_cle_csr INTO l_orig_cle_rec;
  CLOSE c_orig_cle_csr;

  OKL_MAINTAIN_FEE_PVT.update_fee_top_line(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_clev_rec            => lp_clev_rec,
          p_klev_rec            => lp_klev_rec,
          p_cimv_rec            => lp_cimv_rec,
          p_cplv_rec            => lp_cplv_rec,
          x_clev_rec            => lx_clev_rec,
          x_klev_rec            => lx_klev_rec,
          x_cimv_rec            => lx_cimv_rec,
          x_cplv_rec            => lx_cplv_rec
    );

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  x_fee_types_rec.line_id := lx_clev_rec.id;
  x_fee_types_rec.item_id := lx_cimv_rec.id;
  x_fee_types_rec.party_id := lx_cplv_rec.id;

  -- Bug# 6438785
  -- When the fee line start date is changed, update the
  -- start dates for all fee and sub-line payments based on
  -- the new line start date

  IF (lx_clev_rec.start_date <> l_orig_cle_rec.start_date) THEN

    OKL_LA_PAYMENTS_PVT.update_pymt_start_date
      (p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_chr_id         => lx_clev_rec.dnz_chr_id,
       p_cle_id         => lx_clev_rec.id);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
      raise OKL_API.G_EXCEPTION_ERROR;
    End If;

  END IF;
  -- Bug# 6438785


  l_rgp_id := null;
  l_rul_id := null;
  open l_strm_type_rul_csr;
  fetch l_strm_type_rul_csr into l_rgp_id,l_rul_id;
  close l_strm_type_rul_csr;

  If( l_rgp_id is not null and l_rul_id is not null) Then

    update_strmtp_rul(
       p_api_version	=> p_api_version,
       p_init_msg_list	=> p_init_msg_list,
       x_return_status 	=> x_return_status,
       x_msg_count     	=> x_msg_count,
       x_msg_data      	=> x_msg_data,
       p_chr_id		=> p_fee_types_rec.dnz_chr_id,
       p_cle_id		=> p_fee_types_rec.line_id,
       p_rgp_id         => l_rgp_id,
       p_rul_id         => l_rul_id
       );

      -- check return status
      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    End If;


  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

-- Start of comments
--
-- Procedure Name  : delete_fee_type
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE delete_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type
 ) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type ;
    l_klev_rec okl_kle_pvt.klev_rec_type ;
    x_clev_rec okl_okc_migration_pvt.clev_rec_type ;
    x_klev_rec okl_kle_pvt.klev_rec_type ;

    l_sl_clev_rec okl_okc_migration_pvt.clev_rec_type ;
    l_sl_klev_rec okl_kle_pvt.klev_rec_type ;
    x_sl_clev_rec okl_okc_migration_pvt.clev_rec_type ;
    x_sl_klev_rec okl_kle_pvt.klev_rec_type ;

    l_chr_id  l_clev_rec.dnz_chr_id%type;
    l_line_id  l_clev_rec.dnz_chr_id%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'delete_fee_type';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_fee_type          okl_k_lines.fee_type%type := null;
    l_rebook_yn         varchar2(5) := null;

    CURSOR get_fee_purpose_code_csr (p_line_id IN NUMBER) IS
     SELECT fee_purpose_code
     FROM  okl_k_lines
     WHERE ID = p_line_id;
    l_fee_purpose_code okl_k_lines.fee_purpose_code%type;

    CURSOR l_rebook_csr IS
     select 'Y'
     from OKC_K_HEADERS_B chr
     where chr.id = p_fee_types_rec.dnz_chr_id
     and chr.orig_system_source_code = 'OKL_REBOOK';

    CURSOR c_sub_line_csr( p_line_id IN NUMBER, p_chr_id IN NUMBER) IS
     select cle.id
     from okc_k_lines_b cle
     where cle.dnz_chr_id = p_chr_id
     and cle.cle_id =  p_line_id;

    --Bug# 3877032
    --Bug# 6787858: Allow delete of 'GENERAL' fee and fees newly added during rebook
    CURSOR l_fee_type_csr IS
     select kle.fee_type,
            cle.orig_system_id1
     from okc_k_lines_b cle,
          okl_k_lines kle
     where cle.id = kle.id
     and cle.dnz_chr_id =  p_fee_types_rec.dnz_chr_id
     and cle.id =  p_fee_types_rec.line_id;

--Bug# 3877032 : cursor to determine line type and to find covered assets if any
    cursor l_cov_ast_csr (p_cle_id in number) is
    select kle_fee.fee_type,
           cim.object1_id1,
           cim.dnz_chr_id
    from   okc_k_items cim,
           okc_k_lines_b cleb,
           okl_k_lines   kle_fee,
           okc_k_lines_b cleb_fee,
           okc_line_styles_b lseb_fee
    where  cim.cle_id            =  cleb.id
    and    cim.dnz_chr_id        = cleb.dnz_chr_id
    and    cim.jtot_object1_code = 'OKX_COVASST'
    and    cleb.cle_id           = cleb_fee.id
    and    cleb.dnz_chr_id       = cleb_fee.dnz_chr_id
    and    kle_fee.id            = cleb_fee.id
    and    lseb_fee.id           = cleb_fee.lse_id
    and    lseb_fee.lty_code     = 'FEE'
    and    cleb_fee.id           = p_cle_id
    --Bug# 6512668: Exclude asset lines in Abandoned status
    and    cleb.sts_code <> 'ABANDONED';

    l_cov_ast_rec l_cov_ast_csr%ROWTYPE;

    l_fin_clev_tbl    okl_okc_migration_pvt.clev_tbl_type;
    l_fin_klev_tbl    okl_contract_pub.klev_tbl_type;
    lx_fin_clev_tbl   okl_okc_migration_pvt.clev_tbl_type;
    lx_fin_klev_tbl   okl_contract_pub.klev_tbl_type;
    i                 number;
    --End Bug# 3877032

    --Bug# 6787858
    l_orig_system_id1 okc_k_lines_b.orig_system_id1%TYPE;

  BEGIN

    l_line_id := p_fee_types_rec.line_id;
    l_chr_id := p_fee_types_rec.dnz_chr_id;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    If( p_fee_types_rec.line_id is null or p_fee_types_rec.line_id = OKC_API.G_MISS_NUM) Then
       x_return_status := OKC_API.g_ret_sts_error;
       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_REQUIRED_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'CLE_ID'
    			   );
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    If( p_fee_types_rec.dnz_chr_id is null or p_fee_types_rec.dnz_chr_id = OKC_API.G_MISS_NUM) Then
       x_return_status := OKC_API.g_ret_sts_error;
       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_REQUIRED_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'CHR_ID'
    			   );
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    --Bug#4552772
    open get_fee_purpose_code_csr(l_line_id);
    fetch get_fee_purpose_code_csr into l_fee_purpose_code;
    close get_fee_purpose_code_csr;

    IF(( l_fee_purpose_code is not null) and  (l_fee_purpose_code <> OKC_API.G_MISS_CHAR) and (l_fee_purpose_code = 'RVI')) Then
      IF (p_fee_types_rec.fee_purpose_code is not null) and (p_fee_types_rec.fee_purpose_code <> 'RVI_DUMMY') THEN
         x_return_status := OKC_API.g_ret_sts_error;
          OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                   p_msg_name      => 'OKL_LA_RVI_DELETE_NOT_ALLOWED');

           RAISE OKC_API.G_EXCEPTION_ERROR;
      End If;
    END IF;

    l_rebook_yn := null;
    open l_rebook_csr;
    fetch l_rebook_csr into l_rebook_yn;
    close l_rebook_csr;

    If(l_rebook_yn = 'Y'
            and p_fee_types_rec.line_id is not null
                               and p_fee_types_rec.line_id <> OKC_API.G_MISS_NUM) Then

     l_fee_type := null;
     l_orig_system_id1 := null;

     --Bug# : 3877032
     --Bug# 6787858: Allow delete of 'GENERAL' fee and fees newly added during rebook
     open l_fee_type_csr;
     fetch l_fee_type_csr into l_fee_type, l_orig_system_id1;
     close l_fee_type_csr;

     --Bug# 6787858: Allow delete of 'GENERAL' fee and fees newly added during rebook
     If (l_fee_type = 'GENERAL' OR l_orig_system_id1 IS NULL) Then
       NULL;
     ELSE
       x_return_status := OKC_API.g_ret_sts_error;
       OKC_API.SET_MESSAGE(    p_app_name => g_app_name
                             , p_msg_name => 'OKL_FEE_REBK_DEL_ERR' -- seed an error message
      			   );
       raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     l_clev_rec.chr_id := p_fee_types_rec.dnz_chr_id;
     l_clev_rec.id := p_fee_types_rec.line_id;
     l_klev_rec.id := l_clev_rec.id;
     l_clev_rec.sts_code := 'ABANDONED';

     okl_contract_pvt.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR l_sub_line_csr IN c_sub_line_csr(p_line_id => p_fee_types_rec.line_id,p_chr_id => p_fee_types_rec.dnz_chr_id)
      LOOP

        l_sl_clev_rec.id := l_sub_line_csr.id;
        l_sl_clev_rec.sts_code := 'ABANDONED';
        l_sl_klev_rec.id := l_sub_line_csr.id;

        okl_contract_pvt.update_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => l_sl_clev_rec,
          p_klev_rec      => l_sl_klev_rec,
          x_clev_rec      => x_sl_clev_rec,
          x_klev_rec      => x_sl_klev_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         raise OKC_API.G_EXCEPTION_ERROR;
       END IF;

     END LOOP;

    ElsIf( l_rebook_yn is null and p_fee_types_rec.line_id is not null and p_fee_types_rec.line_id <> OKC_API.G_MISS_NUM) Then

       --bug# 3877032
       i := 0;
     For l_cov_Ast_rec in l_cov_ast_csr (p_cle_id => p_fee_types_rec.line_id)
     Loop
     IF l_cov_ast_rec.fee_type = 'CAPITALIZED'  and l_cov_ast_rec.object1_id1 is not NULL then
               i := i+1;
               l_fin_clev_tbl(i).id            := to_number(l_cov_ast_rec.object1_id1);
               l_fin_klev_tbl(i).id            := to_number(l_cov_ast_rec.object1_id1);
               l_fin_clev_tbl(i).dnz_chr_id    := l_cov_ast_rec.dnz_chr_id;
     End If;
     End Loop;
     -- Bug# 3877032

     okl_contract_pub.delete_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_line_id       => l_line_id
      );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

    End If;

  --Bug# 3877032
    If l_fin_klev_tbl.COUNT > 0 then
    For i in l_fin_klev_tbl.FIRST..l_fin_klev_tbl.LAST
    Loop
           OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_formula_name  => 'LINE_CAP_AMNT',
                                           p_contract_id   => l_fin_clev_tbl(i).dnz_chr_id,
                                           p_line_id       => l_fin_clev_tbl(i).id,
                                           x_value         => l_fin_klev_tbl(i).capital_amount);
               If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                       raise OKC_API.G_EXCEPTION_ERROR;
               End If;
     End Loop;

     okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_clev_tbl      => l_fin_clev_tbl,
                                           p_klev_tbl      => l_fin_klev_tbl,
                                           x_clev_tbl      => lx_fin_clev_tbl,
                                           x_klev_tbl      => lx_fin_klev_tbl);

     If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
             raise OKC_API.G_EXCEPTION_ERROR;
     End If;
    End If;
    --Bug# 3877032

   /*
   -- vthiruva, 09/01/2004
   -- START, Code change to enable Business Event
   */
   --raise the business event for remove fee if its a lease contract
    IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE)THEN
	  raise_business_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_chr_id         => l_chr_id,
                           p_fee_line_id    => l_line_id,
                           p_event_name     => G_WF_EVT_FEE_REMOVED);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
   /*
   -- vthiruva, 09/01/2004
   -- END, Code change to enable Business Event
   */

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END;

PROCEDURE process_strmtp_rul(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER,
            p_object1_id1            IN  VARCHAR2
 ) IS

    lp_lapsth_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_lapsth_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_lastrm_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_lastrm_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    l_chr_id  okc_k_headers_b.id%type;
    l_rul_id okc_rules_v.id%type := null;
    l_rgp_id okc_rules_v.id%type := null;
    l_lapsth_rgp_id okc_rules_v.id%type := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'process_strmtp_rul';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_lapsth_rgp_csr IS
     select id
     from okc_rule_groups_v
     where cle_id = p_cle_id
     and chr_id is null
     and dnz_chr_id = p_chr_id
     and rgd_code = 'LAPSTH';

    CURSOR l_strm_type_rul_csr IS
     select rgp.id,
            rul.id
     from okc_rules_v rul,
          okc_rule_groups_v rgp
     where rgp.id = rul.rgp_id
     and rgp.rgd_code = 'LAPSTH'
     and rul.rule_information_category = 'LASTRM'
     and rgp.cle_id = p_cle_id
     and rgp.chr_id is null
     and rul.dnz_chr_id = p_chr_id
     and rgp.dnz_chr_id = p_chr_id;

  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_rgp_id := null;
    l_rul_id := null;
    open l_strm_type_rul_csr;
    fetch l_strm_type_rul_csr into l_rgp_id,l_rul_id;
    close l_strm_type_rul_csr;

    l_lapsth_rgp_id := null;
    open l_lapsth_rgp_csr;
    fetch l_lapsth_rgp_csr into l_lapsth_rgp_id;
    close l_lapsth_rgp_csr;

    If (l_rgp_id is not null and l_rul_id is not null and p_object1_id1 is not null) Then

    lp_lapsth_rgpv_rec.id := l_rgp_id;
    lp_lapsth_rgpv_rec.rgd_code := 'LAPSTH';
    lp_lapsth_rgpv_rec.dnz_chr_id := p_chr_id;
    lp_lapsth_rgpv_rec.chr_id := null;
    lp_lapsth_rgpv_rec.cle_id := p_cle_id;
    lp_lapsth_rgpv_rec.rgp_type := 'KRG';


    OKL_RULE_PUB.update_rule_group(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rgpv_rec       => lp_lapsth_rgpv_rec,
            x_rgpv_rec       => lx_lapsth_rgpv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
             raise OKC_API.G_EXCEPTION_ERROR;
      End If;

     lp_lastrm_rulv_rec.id := l_rul_id;
     lp_lastrm_rulv_rec.rgp_id := lx_lapsth_rgpv_rec.id;
     lp_lastrm_rulv_rec.rule_information_category := 'LASTRM';
     lp_lastrm_rulv_rec.dnz_chr_id := p_chr_id;
     lp_lastrm_rulv_rec.object1_id1 := p_object1_id1;
     lp_lastrm_rulv_rec.object1_id2 := '#';
     lp_lastrm_rulv_rec.jtot_object1_code := 'OKL_STRMTYP';
     lp_lastrm_rulv_rec.WARN_YN := 'N';
     lp_lastrm_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lastrm_rulv_rec,
        x_rulv_rec       => lx_lastrm_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    ElsIf (l_rgp_id is null and l_rul_id is null and p_object1_id1 is not null) Then

    If( l_lapsth_rgp_id is null) Then

    lp_lapsth_rgpv_rec.id := null;
    lp_lapsth_rgpv_rec.rgd_code := 'LAPSTH';
    lp_lapsth_rgpv_rec.dnz_chr_id := p_chr_id;
    lp_lapsth_rgpv_rec.chr_id := null;
    lp_lapsth_rgpv_rec.cle_id := p_cle_id;
    lp_lapsth_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.create_rule_group(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rgpv_rec       => lp_lapsth_rgpv_rec,
            x_rgpv_rec       => lx_lapsth_rgpv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
             raise OKC_API.G_EXCEPTION_ERROR;
      End If;

     End If;

     lp_lastrm_rulv_rec.id := null;

     If(l_lapsth_rgp_id is not null) Then
      lp_lastrm_rulv_rec.rgp_id := l_lapsth_rgp_id;
     Else
      lp_lastrm_rulv_rec.rgp_id := lx_lapsth_rgpv_rec.id;
     End If;

     lp_lastrm_rulv_rec.rule_information_category := 'LASTRM';
     lp_lastrm_rulv_rec.dnz_chr_id := p_chr_id;
     lp_lastrm_rulv_rec.object1_id1 := p_object1_id1;
     lp_lastrm_rulv_rec.object1_id2 := '#';
     lp_lastrm_rulv_rec.jtot_object1_code := 'OKL_STRMTYP';
     lp_lastrm_rulv_rec.WARN_YN := 'N';
     lp_lastrm_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lastrm_rulv_rec,
        x_rulv_rec       => lx_lastrm_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    ElsIf (l_rgp_id is not null and l_rul_id is not null and p_object1_id1 is null) Then

    -- call the package to create rule
     lp_lastrm_rulv_rec.id := l_rul_id;

     OKL_RULE_PUB.delete_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lastrm_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;
/*
    lp_lapsth_rgpv_rec.id := l_rgp_id;

     OKL_RULE_PUB.delete_rule_group(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rgpv_rec       => lp_lapsth_rgpv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
             raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    */


    End If;


    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END;

PROCEDURE create_strmtp_rul(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER
 ) IS

    lp_lapsth_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_lapsth_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_lastrm_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_lastrm_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    l_chr_id  okc_k_headers_b.id%type;
    l_object1_id1 okc_k_items_v.object1_id1%type := null;
    l_object1_id2 okc_k_items_v.object1_id2%type := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'create_strmtp_rul';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_strm_type_item_csr IS
     select object1_id1,object1_id2
     from okc_k_items_v
     where cle_id = p_cle_id
     and dnz_chr_id = p_chr_id;

    CURSOR l_strm_type_rul_csr IS
     select rul.object1_id1,
            rul.object1_id2
     from okc_rules_v rul,
          okc_rule_groups_v rgp
     where rgp.id = rul.rgp_id
     and rgp.rgd_code = 'LAPSTH'
     and rul.rule_information_category = 'LASTRM'
     and rgp.cle_id = p_cle_id
     and rgp.chr_id is null
     and rul.dnz_chr_id = p_chr_id
     and rgp.dnz_chr_id = p_chr_id;


  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_object1_id1 := null;
    l_object1_id2 := null;

    open l_strm_type_rul_csr;
    fetch l_strm_type_rul_csr into l_object1_id1,l_object1_id2;
    close l_strm_type_rul_csr;

    If (l_object1_id1 is not null and l_object1_id2 is not null) Then
     return;
    End If;

    l_object1_id1 := null;
    l_object1_id2 := null;

    open l_strm_type_item_csr;
    fetch l_strm_type_item_csr into l_object1_id1,l_object1_id2;
    close l_strm_type_item_csr;

    If( l_object1_id1 is null or l_object1_id2 is null) Then
    -- Not a valid record, Item object1_id1 not found
    null;
    End If;

    -- call the package to create rule

    lp_lapsth_rgpv_rec.id := null;
    lp_lapsth_rgpv_rec.rgd_code := 'LAPSTH';
    lp_lapsth_rgpv_rec.dnz_chr_id := p_chr_id;
    lp_lapsth_rgpv_rec.chr_id := null;
    lp_lapsth_rgpv_rec.cle_id := p_cle_id;
    lp_lapsth_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.create_rule_group(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rgpv_rec       => lp_lapsth_rgpv_rec,
            x_rgpv_rec       => lx_lapsth_rgpv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
             raise OKC_API.G_EXCEPTION_ERROR;
      End If;

     lp_lastrm_rulv_rec.id := null;
     lp_lastrm_rulv_rec.rgp_id := lx_lapsth_rgpv_rec.id;
     lp_lastrm_rulv_rec.rule_information_category := 'LASTRM';
     lp_lastrm_rulv_rec.dnz_chr_id := p_chr_id;
     lp_lastrm_rulv_rec.object1_id1 := l_object1_id1;
     lp_lastrm_rulv_rec.object1_id2 := l_object1_id2;
     lp_lastrm_rulv_rec.jtot_object1_code := 'OKL_STRMTYP';
     lp_lastrm_rulv_rec.WARN_YN := 'N';
     lp_lastrm_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lastrm_rulv_rec,
        x_rulv_rec       => lx_lastrm_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;


    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END;

 PROCEDURE update_strmtp_rul(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER,
            p_rgp_id                 IN  NUMBER,
            p_rul_id                 IN  NUMBER

 ) IS

    lp_lapsth_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_lapsth_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_lastrm_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_lastrm_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    l_chr_id  okc_k_headers_b.id%type;
    l_rgp_id  okc_k_headers_b.id%type;
    l_object1_id1 okc_k_items_v.object1_id1%type := null;
    l_object1_id2 okc_k_items_v.object1_id2%type := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'update_strmtp_rul';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_strm_type_item_csr IS
     select object1_id1,object1_id2
     from okc_k_items_v
     where cle_id = p_cle_id
     and dnz_chr_id = p_chr_id;


  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_object1_id1 := null;
    l_object1_id2 := null;

    open l_strm_type_item_csr;
    fetch l_strm_type_item_csr into l_object1_id1,l_object1_id2;
    close l_strm_type_item_csr;

    If( l_object1_id1 is null or l_object1_id2 is null) Then
    -- Not a valid record, Item object1_id1 not found
    null;
    End If;

    -- call the package to create rule
     lp_lastrm_rulv_rec.id := p_rul_id;
     lp_lastrm_rulv_rec.rgp_id := p_rgp_id;
     lp_lastrm_rulv_rec.rule_information_category := 'LASTRM';
     lp_lastrm_rulv_rec.dnz_chr_id := p_chr_id;
     lp_lastrm_rulv_rec.object1_id1 := l_object1_id1;
     lp_lastrm_rulv_rec.object1_id2 := l_object1_id2;
     lp_lastrm_rulv_rec.jtot_object1_code := 'OKL_STRMTYP';
     lp_lastrm_rulv_rec.warn_yn := 'N';
     lp_lastrm_rulv_rec.std_template_yn := 'N';

     OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lastrm_rulv_rec,
        x_rulv_rec       => lx_lastrm_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;


    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END;

    ----------------------------------------------------------------------------
    --start of comments
    --API Name    : validate_rollover_feeLine
    --Description : API called to validate the rollover quote on a contract.
    --              Check if the Rollover fee amount is equal to Rollover
    --              qupte amount.
    --Parameters  : IN - p_chr_id - Contract Number
    --                   p_qte_id - Rollover Quote Number
    --              OUT - x_return_status - Return Status
    --History     : 16-Aug-2004 Manu Created
    --
    --
    --end of comments
    -----------------------------------------------------------------------------

    PROCEDURE validate_rollover_feeLine(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  OKC_K_HEADERS_B.ID%TYPE,
            p_qte_id          IN  OKL_K_LINES.QTE_ID%TYPE,
            p_for_qa_check    IN  BOOLEAN DEFAULT FALSE)  IS

      l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_ROLLOVER_FEELINE';
      l_api_version     CONSTANT NUMBER       := 1.0;

      l_return_status   VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

      l_not_found       BOOLEAN := FALSE;
      l_amt             NUMBER;
      l_found           VARCHAR2(1);
      l_k_num           OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
      l_q_num           OKL_TRX_QUOTES_B.QUOTE_NUMBER%TYPE;
      l_fee_name        OKC_K_LINES_V.NAME%TYPE;

      l_rebook_yn VARCHAR2(1) := null;
      l_ln_orig_sys_id1 okc_k_lines_b.orig_system_id1%type := null;
      l_mass_rebook_cnt NUMBER := null;
      l_do_validation   VARCHAR2(1);

      /* Cursor to get the contract number and quote number. */

      CURSOR l_con_qte_csr ( chrID OKC_K_HEADERS_B.ID%TYPE,
                             qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT khr.contract_number, qte.quote_number
      FROM okc_k_headers_v khr,okl_trx_quotes_b qte
      WHERE khr.id = chrID
            AND qte.id = qteID;

      /* Cursor to get the Fee Name. */

      CURSOR l_fee_name_csr ( chrID OKC_K_HEADERS_B.ID%TYPE,
                              qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT cle.name
      FROM okc_k_headers_b khr,
           okl_k_lines kle,
           okc_k_lines_v cle,
           okl_trx_quotes_b qte
      WHERE cle.id = kle.id
      AND khr.id = chrID
      AND khr.id = cle.dnz_chr_id
      AND qte.id = qteID
      AND kle.qte_id = qte.id;

      /* Cursor to check if the Customer Account on the current Contract
         and the contract on the quote match, if not throw an error. */

      CURSOR l_cust_accnt_csr ( chrID OKC_K_HEADERS_B.ID%TYPE,
                              qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT 1 FROM okc_k_headers_b
      WHERE id = chrID
      AND cust_acct_id = (SELECT khr.cust_acct_id FROM okc_k_headers_b khr,okl_trx_quotes_b qte
                        WHERE khr.id = qte.khr_id
                        AND qte.id = qteID);

      /* Cursor to check if the Currency Code on the current Contract
         and the contract on the quote match, if not throw an error. */

      CURSOR l_curr_code_csr ( chrID OKC_K_HEADERS_B.ID%TYPE,
                             qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT 1 FROM okc_k_headers_b
      WHERE id = chrID
      AND currency_code = (SELECT khr.currency_code FROM okc_k_headers_b khr,okl_trx_quotes_b qte
                         WHERE khr.id = qte.khr_id
                         AND qte.id = qteID);

      /* Cursor to check if the Quote status is Approved, if not throw an error. */

      CURSOR l_qts_code_csr ( qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT 1 FROM okl_trx_quotes_b
      WHERE id = qteID
      AND qst_code = 'APPROVED';

      /* Cursor to check if the Quote Consolidate flag is set to N, if not throw an error. */

      CURSOR l_con_yn_csr ( qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT 1 FROM okl_trx_quotes_b
      WHERE id = qteID
      AND consolidated_yn = 'N';

      /* Cursor to check if the Quote Type is either TER_ROLL_PURCHASE or
         TER_ROLL_WO_PURCHASE, if not throw an error. */

      CURSOR l_qte_typ_csr ( qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT 1 FROM okl_trx_quotes_b
      WHERE id = qteID
      AND qtp_code IN ('TER_ROLL_PURCHASE' , 'TER_ROLL_WO_PURCHASE');

      /* Cursor to check if the Rollover Fee Start date is between Quote
         effective dates, if not throw an error. */

      CURSOR l_rq_fee_check_csr (  chrID OKC_K_HEADERS_B.ID%TYPE,
                                 qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      SELECT 1
      FROM okc_k_headers_b khr,
           okl_k_lines kle,
           okc_k_lines_b cle,
           okl_trx_quotes_b qte
      WHERE cle.id = kle.id
      AND khr.id = chrID
      AND khr.id = cle.dnz_chr_id
      AND qte.id = qteID
      AND kle.qte_id = qte.id
      AND trunc(qte.date_effective_from) <= cle.start_date
      AND nvl(trunc(qte.date_effective_to), cle.start_date) >= cle.start_date
      AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cle.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'))
      AND NOT EXISTS (
            SELECT 'Y'
            FROM okc_k_headers_b khr1
            WHERE khr1.id = chrID
            AND khr1.orig_system_source_code IN ('OKL_RELEASE'));

      /* Cursor to check if the Rollover Quote Amount is equal to
         Rollover Fee line amount on the contract, if not throw an error. */

      -- AKJAIN fixed bug 4198968
      CURSOR l_rq_amt_check_csr (  chrID OKC_K_HEADERS_B.ID%TYPE,
                                 qteID OKL_K_LINES.QTE_ID%TYPE ) IS
      (SELECT SUM(tql.amount)
      FROM okl_trx_quotes_b qte, okl_txl_quote_lines_b tql
      WHERE qte.id = qteID
      AND tql.qte_id= qte.id
      AND tql.qlt_code not in ('AMCFIA', 'AMCTAX', 'AMYOUB', 'BILL_ADJST'))
      INTERSECT
      (SELECT SUM(KLE1.amount) FROM okc_k_lines_b cleb, okl_k_lines kle1
      WHERE cleb.dnz_chr_id = chrID
      AND kle1.ID = cleb.ID
      AND kle1.fee_type = 'ROLLOVER'
      AND kle1.qte_id = qteID
      AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'))
      /* Added to exclude this check for Re-lease contracts. */
      AND NOT EXISTS (
            SELECT 'Y'
            FROM okc_k_headers_b khr1
            WHERE khr1.id = chrID
            AND khr1.orig_system_source_code IN ('OKL_RELEASE')));

      /* Cursor to check if it is a Re-book contract.
      	 If yes, ignore approval step else continue all the checks  */
      CURSOR l_rebook_chk_csr ( p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
         SELECT 'Y'
         FROM   okc_k_headers_b
         WHERE  orig_system_source_code = 'OKL_REBOOK'
         AND    id = p_chr_id;

      /* Cursor to check if orig_system_id1 exists for a re-book contract
      	 If yes, ignore approval step else continue all the checks  */
      CURSOR l_orig_sys_id1_csr ( p_chr_id OKC_K_HEADERS_B.ID%TYPE, p_qte_id OKL_K_LINES.QTE_ID%TYPE ) IS
         SELECT  orig_system_id1
         FROM   okc_k_lines_b cle,
                okl_k_lines kle
         WHERE  cle.id = kle.id
         AND    dnz_chr_id = p_chr_id
         AND    kle.qte_id = p_qte_id;

      /* Check if it a mass re-book contract */
      CURSOR l_mass_rebook_csr ( p_chr_id OKC_K_HEADERS_B.ID%TYPE ) IS
 	SELECT COUNT(1)
 	FROM   okl_rbk_selected_contract
 	WHERE  khr_id = p_chr_id
 	AND    NVL(status,'NEW') = 'UNDER REVISION';



  BEGIN

       IF (NOT p_for_qa_check) THEN
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
       END IF;
      /*
      x_return_status := OKL_API.START_ACTIVITY(
                          p_api_name      => l_api_name,
                          p_pkg_name      => g_pkg_name,
                          p_init_msg_list => p_init_msg_list,
                          l_api_version   => l_api_version,
                          p_api_version   => p_api_version,
                          p_api_type      => G_API_TYPE,
                          x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */

      /* check if it is a mass rebook contract */
      l_mass_rebook_cnt := null;
      OPEN l_mass_rebook_csr ( p_chr_id );
      FETCH l_mass_rebook_csr INTO l_mass_rebook_cnt;
      CLOSE l_mass_rebook_csr;

      /* find if it is a re-book contract */

      l_rebook_yn    := null;
      OPEN l_rebook_chk_csr ( p_chr_id );
      FETCH l_rebook_chk_csr INTO l_rebook_yn;
      CLOSE l_rebook_chk_csr;

      /* find if it is a copied line */

      l_ln_orig_sys_id1 := null;
      OPEN l_orig_sys_id1_csr ( p_chr_id, p_qte_id );
      FETCH l_orig_sys_id1_csr INTO l_ln_orig_sys_id1;
      CLOSE l_orig_sys_id1_csr;


      /* Get Contract Number and Quote Number. */

      OPEN l_con_qte_csr ( p_chr_id, p_qte_id );
      FETCH l_con_qte_csr INTO l_k_num, l_q_num;
      CLOSE l_con_qte_csr;

      /* Get FeeName. */

      OPEN l_fee_name_csr ( p_chr_id, p_qte_id );
      FETCH l_fee_name_csr INTO l_fee_name;
      CLOSE l_fee_name_csr;

      /* Check if the Customer Account on the current Contract
         and the contract on the quote match, if not throw an error. */

      OPEN l_cust_accnt_csr ( p_chr_id, p_qte_id );
      FETCH l_cust_accnt_csr INTO l_found;
      l_not_found := l_cust_accnt_csr%NOTFOUND;
      CLOSE l_cust_accnt_csr;

      IF( l_not_found ) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          l_not_found := NULL;
          l_found := NULL;
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_CUST_NO_MATCH',
         	     p_token1        => 'CONTRACT_NUMBER',
                     p_token1_value  => l_k_num,
         	     p_token2        => 'QUOTE_NUMBER',
                     p_token2_value  => l_q_num,
         	     p_token3        => 'FEE_LINE',
                     p_token3_value  => l_fee_name);

          IF (NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

      /* Check if the Currency Code on the current Contract
         and the contract on the quote match, if not throw an error. */

      OPEN l_curr_code_csr ( p_chr_id, p_qte_id );
      FETCH l_curr_code_csr INTO l_found;
      l_not_found := l_curr_code_csr%NOTFOUND;
      CLOSE l_curr_code_csr;

      IF( l_not_found ) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          l_not_found := NULL;
          l_found := NULL;
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_CURR_NO_MATCH',
         	     p_token1        => 'CONTRACT_NUMBER',
                     p_token1_value  => l_k_num,
         	     p_token2        => 'QUOTE_NUMBER',
                     p_token2_value  => l_q_num,
         	     p_token3        => 'FEE_LINE',
                     p_token3_value  => l_fee_name);

          IF (NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;


     IF l_rebook_yn  is not null THEN
        IF l_ln_orig_sys_id1 is not null THEN
         l_do_validation := 'N';
        ELSE
          l_do_validation := 'Y';
        END IF;
     ELSIF (l_mass_rebook_cnt > 0) THEN
         l_do_validation := 'N';
     ELSE
         l_do_validation := 'Y';
     END IF;

      /* Check if quote status is Approved, if not throw an error. */

     IF (l_do_validation = 'Y') THEN

      OPEN l_qts_code_csr ( p_qte_id );
      FETCH l_qts_code_csr INTO l_found;
      l_not_found := l_qts_code_csr%NOTFOUND;
      CLOSE l_qts_code_csr;

      IF( l_not_found ) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          l_not_found := NULL;
          l_found := NULL;
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_STS_NOT_APPROVED',
         	     p_token1        => 'QUOTE_NUMBER',
                     p_token1_value  => l_q_num,
         	     p_token2        => 'FEE_LINE',
                     p_token2_value  => l_fee_name);

          IF (NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

     END IF;

      /* Check if the Quote Consolidate flag is set to N, if not throw an error. */

      OPEN l_con_yn_csr ( p_qte_id );
      FETCH l_con_yn_csr INTO l_found;
      l_not_found := l_con_yn_csr%NOTFOUND;
      CLOSE l_con_yn_csr;

      IF( l_not_found ) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          l_not_found := NULL;
          l_found := NULL;
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_CON_FLG_NOT_Y',
         	     p_token1        => 'QUOTE_NUMBER',
                     p_token1_value  => l_q_num);

          IF ( NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

      /* Check if the Quote Type is either TER_ROLL_PURCHASE or
         TER_ROLL_WO_PURCHASE, if not throw an error. */

      OPEN l_qte_typ_csr ( p_qte_id );
      FETCH l_qte_typ_csr INTO l_found;
      l_not_found := l_qte_typ_csr%NOTFOUND;
      CLOSE l_qte_typ_csr;

      IF( l_not_found ) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          l_not_found := NULL;
          l_found := NULL;
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_TYP_NOT_CORRECT',
         	     p_token1        => 'QUOTE_NUMBER',
                     p_token1_value  => l_q_num);

          IF ( NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

      /* Check if the Rollover Fee Start date is between Quote
         effective dates, if not throw an error. */

      OPEN l_rq_fee_check_csr ( p_chr_id, p_qte_id );
      FETCH l_rq_fee_check_csr INTO l_found;
      l_not_found := l_rq_fee_check_csr%NOTFOUND;
      CLOSE l_rq_fee_check_csr;

      IF( l_not_found ) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          l_not_found := NULL;
          l_found := NULL;
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_FEE_NOT_CORRECT',
         	     p_token1        => 'FEE_LINE',
                     p_token1_value  => l_fee_name,
         	     p_token2        => 'QUOTE_NUMBER',
                     p_token2_value  => l_q_num);

          IF (NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

      /* Check if the Rollover Quote Amount is equal to
         Rollover Fee line amount on the contract, if not throw an error. */

      OPEN l_rq_amt_check_csr ( p_chr_id, p_qte_id );
      FETCH l_rq_amt_check_csr INTO l_amt;
      l_not_found := l_rq_amt_check_csr%NOTFOUND;
      CLOSE l_rq_amt_check_csr;

      IF( l_not_found ) THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_AMT_NOT_EQUAL',
         	     p_token1        => 'FEE_LINE',
                     p_token1_value  => l_fee_name,
         	     p_token2        => 'QUOTE_NUMBER',
                     p_token2_value  => l_q_num);

          IF ( NOT p_for_qa_check) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;


     EXCEPTION

          WHEN OKL_API.G_EXCEPTION_ERROR THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;


                IF l_con_qte_csr%ISOPEN THEN
                        CLOSE l_con_qte_csr;
                END IF;

                IF l_fee_name_csr%ISOPEN THEN
                        CLOSE l_fee_name_csr;
                END IF;

                IF l_cust_accnt_csr%ISOPEN THEN
                        CLOSE l_cust_accnt_csr;
                END IF;

                IF l_curr_code_csr%ISOPEN THEN
                        CLOSE l_curr_code_csr;
                END IF;

                IF l_qts_code_csr%ISOPEN THEN
                        CLOSE l_qts_code_csr;
                END IF;

                IF l_con_yn_csr%ISOPEN THEN
                        CLOSE l_con_yn_csr;
                END IF;

                IF l_qte_typ_csr%ISOPEN THEN
                        CLOSE l_qte_typ_csr;
                END IF;

                IF l_rq_fee_check_csr%ISOPEN THEN
                        CLOSE l_rq_fee_check_csr;
                END IF;

                IF l_rq_amt_check_csr%ISOPEN THEN
                        CLOSE l_rq_amt_check_csr;
                END IF;

          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


                IF l_con_qte_csr%ISOPEN THEN
                        CLOSE l_con_qte_csr;
                END IF;

                IF l_fee_name_csr%ISOPEN THEN
                        CLOSE l_fee_name_csr;
                END IF;

                IF l_cust_accnt_csr%ISOPEN THEN
                        CLOSE l_cust_accnt_csr;
                END IF;

                IF l_curr_code_csr%ISOPEN THEN
                        CLOSE l_curr_code_csr;
                END IF;

                IF l_qts_code_csr%ISOPEN THEN
                        CLOSE l_qts_code_csr;
                END IF;

                IF l_con_yn_csr%ISOPEN THEN
                        CLOSE l_con_yn_csr;
                END IF;

                IF l_qte_typ_csr%ISOPEN THEN
                        CLOSE l_qte_typ_csr;
                END IF;

                IF l_rq_fee_check_csr%ISOPEN THEN
                        CLOSE l_rq_fee_check_csr;
                END IF;

                IF l_rq_amt_check_csr%ISOPEN THEN
                        CLOSE l_rq_amt_check_csr;
                END IF;

          WHEN OTHERS THEN


                IF l_con_qte_csr%ISOPEN THEN
                        CLOSE l_con_qte_csr;
                END IF;

                IF l_fee_name_csr%ISOPEN THEN
                        CLOSE l_fee_name_csr;
                END IF;

                IF l_cust_accnt_csr%ISOPEN THEN
                        CLOSE l_cust_accnt_csr;
                END IF;

                IF l_curr_code_csr%ISOPEN THEN
                        CLOSE l_curr_code_csr;
                END IF;

                IF l_qts_code_csr%ISOPEN THEN
                        CLOSE l_qts_code_csr;
                END IF;

                IF l_con_yn_csr%ISOPEN THEN
                        CLOSE l_con_yn_csr;
                END IF;

                IF l_qte_typ_csr%ISOPEN THEN
                        CLOSE l_qte_typ_csr;
                END IF;

                IF l_rq_fee_check_csr%ISOPEN THEN
                        CLOSE l_rq_fee_check_csr;
                END IF;

                IF l_rq_amt_check_csr%ISOPEN THEN
                        CLOSE l_rq_amt_check_csr;
                END IF;

                x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  End validate_rollover_feeLine;

  ----------------------------------------------------------------------------
  --start of comments
  --API Name    : rollover_fee
  --Description : API called to update the the rollover quote amount on a contract
  --              to the referencing creditline contract column tot_cl_transfer_amt
  --
  --Parameters  : IN - p_chr_id - Contract Number
  --                   p_cl_id - Referenced Creditline contract
  --              OUT  x_return_status - Return Status
  --
  --History     : 10-Nov-2004 smereddy Created
  --
  --
  --end of comments
  -----------------------------------------------------------------------------

  PROCEDURE rollover_fee(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  NUMBER, -- contract id
            p_cl_id              IN  NUMBER, -- creditline id
            x_rem_amt            OUT NOCOPY NUMBER
  ) IS

    cursor c_roll_fee(p_chr_id number) is
    select nvl(sum(kle.amount),0) amt
    from   okc_k_lines_b cle,
       okl_k_lines kle,
       okc_line_styles_b lse
    where cle.id = kle.id
    and   cle.dnz_chr_id = p_chr_id
    and   lse.id = cle.lse_id
    and   lse.lty_code = 'FEE'
    and   fee_type = 'ROLLOVER';

    l_chr_id            okc_k_headers_b.id%type;
    l_prev_roll_amount  number := null;
    l_roll_amt          number := null;
    l_tot_roll_amt      number := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'rollover_fee';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

      -- get the previous booked contracts rollover amount;pull data from new column and set to 0 if it is null
      l_prev_roll_amount := OKL_SEEDED_FUNCTIONS_PVT.rollover_fee(p_cl_id);

      If(l_prev_roll_amount is null) Then
       l_prev_roll_amount := 0;
      End If;

      -- get the  current rollover amount
      open c_roll_fee(l_chr_id);
      fetch c_roll_fee into l_roll_amt;
      close c_roll_fee;

      -- total rollover amount for the creditline
      l_tot_roll_amt := l_prev_roll_amount + l_roll_amt;

      lp_khrv_rec.id := p_cl_id;
      lp_chrv_rec.id := p_cl_id;
      lp_khrv_rec.tot_cl_transfer_amt := l_tot_roll_amt;

      -- update contract header for the tot. rollover creditline
      OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        p_edit_mode             => 'N',
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END;

  ----------------------------------------------------------------------------
  --start of comments
  --API Name    : rollover_fee
  --Description : API called to throw warning message if the rollove amount
  --              exceeds the total available/remaining credit limit amount
  --
  --Parameters  : IN - p_chr_id - Contract Number
  --              OUT  x_rem_amt - Return Status
  --
  --History     : 10-Nov-2004 smereddy Created
  --
  --
  --end of comments
  -----------------------------------------------------------------------------

  PROCEDURE rollover_fee(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  NUMBER, -- contract id
            x_rem_amt            OUT NOCOPY NUMBER
  ) IS

    /* smereddy 09-Nov-2004 Start
    Cursor to get the rollover fee lines for a contract
    that is booked for the first time. */

    CURSOR l_rq_fee_lns_bkg_csr ( p_chr_id number ) IS
    SELECT kle.qte_id
    FROM okc_k_headers_b khr, okc_k_lines_b cleb, okl_k_lines kle
    WHERE khr.id = p_chr_id
        AND cleb.dnz_chr_id = khr.id
        AND kle.ID = cleb.ID
        AND kle.fee_type = 'ROLLOVER';

    CURSOR l_orig_src_code_csr ( p_chr_id number ) IS
    SELECT nvl(ORIG_SYSTEM_SOURCE_CODE,'XXX')
    FROM okc_k_headers_b khr
    WHERE khr.id = p_chr_id;

    l_orig_src_code okc_k_headers_b.orig_system_source_code%type := null;
    l_cl_roll_amt       NUMBER := 0;
    l_cl_tot_roll_amt   NUMBER := 0;
    l_chr_id            okc_k_headers_b.id%type;
    l_cl_id             okc_k_headers_b.id%type := null;
    l_qte_id            number := null;
    l_cl_rem_amt        number := null;
    l_prev_roll_amount  number := null;
    l_roll_amt          number := null;
    l_tot_roll_amt      number := null;
    l_tot_cl_rem_amt    number := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'rollover_fee';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

      l_orig_src_code := null;

      open l_orig_src_code_csr(p_chr_id);
      fetch l_orig_src_code_csr into l_orig_src_code;
      close l_orig_src_code_csr;

      If(l_orig_src_code = 'OKL_SPLIT' OR l_orig_src_code = 'OKL_RELEASE') Then
        x_rem_amt := 0;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        return;
      End If;

      open  l_rq_fee_lns_bkg_csr(p_chr_id);
      fetch l_rq_fee_lns_bkg_csr into l_qte_id;
      close l_rq_fee_lns_bkg_csr;

      -- check whether rollover quote and cleditline exists
      If(l_qte_id is null OR l_qte_id = OKC_API.G_MISS_NUM) Then
        x_rem_amt := 0;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        return;
      End If;

      -- check whether creditline exists
      l_cl_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_chr_id);

      If(l_cl_id is null OR l_cl_id = OKC_API.G_MISS_NUM) Then
        x_rem_amt := 0;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        return;
      End If;

      -- get the remaining amount
      l_cl_rem_amt := OKL_SEEDED_FUNCTIONS_PVT.creditline_total_remaining(l_cl_id,null);

      -- get the previous booked contracts rollover amount;pull data from new column and set to 0 if it is null
      l_prev_roll_amount := OKL_SEEDED_FUNCTIONS_PVT.rollover_fee(l_cl_id);

      If(l_prev_roll_amount is null) Then
       l_prev_roll_amount := 0;
      Else
       l_roll_amt := l_prev_roll_amount;
      End If;

      -- total rollover amount for the creditline
      l_tot_roll_amt := l_roll_amt;

      -- total credit limit
      l_tot_cl_rem_amt := l_cl_rem_amt - l_tot_roll_amt;

      x_rem_amt := l_tot_cl_rem_amt;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

  --Bug# 4899328
  PROCEDURE create_update_link_assets (p_api_version        IN  NUMBER,
                                       p_init_msg_list      IN  VARCHAR2 DEFAULT G_FALSE,
                                       p_cle_id             IN  NUMBER,
                                       p_chr_id             IN  NUMBER,
                                       p_capitalize_yn      IN  VARCHAR2,
                                       p_link_asset_tbl     IN  link_asset_tbl_type,
                                       p_derive_assoc_amt   IN  VARCHAR2,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_msg_count          OUT NOCOPY NUMBER,
                                       x_msg_data           OUT NOCOPY VARCHAR2) IS

    l_program_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_update_link_assets';

    l_create_line_item_tbl      okl_contract_line_item_pvt.line_item_tbl_type;
    l_update_line_item_tbl      okl_contract_line_item_pvt.line_item_tbl_type;
    lx_line_item_tbl            okl_contract_line_item_pvt.line_item_tbl_type;

    l_link_asset_tbl            link_asset_tbl_type;

    k                           BINARY_INTEGER  := 1;  -- create table index
    m                           BINARY_INTEGER  := 1;  -- update table index

    l_line_amount               NUMBER;
    l_asset_oec                 NUMBER;
    l_oec_total                 NUMBER       := 0;
    l_assoc_amount              NUMBER;
    l_assoc_total               NUMBER       := 0;
    l_currency_code             VARCHAR2(15);
    l_compare_amt               NUMBER;
    l_diff                      NUMBER;
    l_adj_rec                   BINARY_INTEGER;
    lx_return_status            VARCHAR2(1);

    CURSOR c_asset_number(p_fin_asset_id IN NUMBER,
                          p_chr_id       IN NUMBER) IS
    SELECT txl.asset_number
    FROM   okc_k_lines_b cle,
           okc_line_styles_b lse,
           okl_txl_assets_b txl
    WHERE  cle.id = txl.kle_id
    AND    cle.lse_id = lse.id
    AND    lse.lty_code = 'FIXED_ASSET'
    AND    cle.cle_id = p_fin_asset_id
    AND    cle.dnz_chr_id = p_chr_id
    AND    txl.dnz_khr_id = p_chr_id;

    CURSOR c_term_sub_lines(p_cle_id IN NUMBER,
                            p_chr_id IN NUMBER) is
    SELECT SUM(NVL(kle.capital_amount,kle.amount)) amount
    FROM   okc_k_lines_b cle,
           okl_k_lines kle
    WHERE  cle.cle_id = p_cle_id
    AND    cle.dnz_chr_id = p_chr_id
    AND    cle.sts_code = 'TERMINATED'
    AND    kle.id = cle.id;

    l_term_sub_lines_amt NUMBER;
    l_release_contract_yn VARCHAR2(1);

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    SELECT NVL(amount, 0)
    INTO   l_line_amount
    FROM   okl_k_lines
    WHERE  id = p_cle_id;

    -- Exclude Terminated sub-line amounts from
    -- total amount available for allocation
    l_term_sub_lines_amt := 0;
    OPEN c_term_sub_lines(p_cle_id => p_cle_id,
                          p_chr_id => p_chr_id);
    FETCH c_term_sub_lines INTO l_term_sub_lines_amt;
    CLOSE c_term_sub_lines;

    l_line_amount := l_line_amount - NVL(l_term_sub_lines_amt,0);

    IF l_line_amount < 0 THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                         ,p_msg_name     => 'OKL_LA_NEGATIVE_COV_AST_AMT'
                         ,p_token1       => 'AMOUNT'
                         ,p_token1_value => TO_CHAR(NVL(l_term_sub_lines_amt,0)));
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT currency_code
    INTO   l_currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_link_asset_tbl  :=  p_link_asset_tbl;

    IF (l_link_asset_tbl.COUNT > 0) THEN

      l_release_contract_yn := okl_api.g_false;
      l_release_contract_yn := okl_lla_util_pvt.check_release_contract(p_chr_id => p_chr_id);

      ------------------------------------------------------------------
      -- 1. Loop through to get OEC total of all assets being associated
      ------------------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          --Bug# 4631549
          If l_release_contract_yn = okl_api.g_true then
            SELECT NVL(expected_asset_cost, 0)
            INTO   l_asset_oec
            FROM   okl_k_lines
            WHERE  id = l_link_asset_tbl(i).fin_asset_id;
          else
            SELECT NVL(oec, 0)
            INTO   l_asset_oec
            FROM   okl_k_lines
            WHERE  id = l_link_asset_tbl(i).fin_asset_id;
          end if;

          l_oec_total := l_oec_total + l_asset_oec;

        END IF;

      END LOOP;

      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts and round off the amounts
      ----------------------------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          IF p_derive_assoc_amt = 'N' THEN

            l_assoc_amount := l_link_asset_tbl(i).amount;

          ELSIF l_oec_total = 0 THEN

            l_assoc_amount := l_line_amount / l_link_asset_tbl.COUNT;

          ELSE

            -- LLA APIs ensure asset OEC and line amount are rounded
            --Bug# 4631549
            If l_release_contract_yn = okl_api.g_true then
              SELECT NVL(expected_asset_cost, 0)
              INTO   l_asset_oec
              FROM   okl_k_lines
              WHERE  id = l_link_asset_tbl(i).fin_asset_id;
            Else
              SELECT NVL(oec, 0)
              INTO   l_asset_oec
              FROM   okl_k_lines
              WHERE  id = l_link_asset_tbl(i).fin_asset_id;
            End If;

            IF l_link_asset_tbl.COUNT = 1 THEN

              l_assoc_amount := l_line_amount;

            ELSE

              l_assoc_amount := l_line_amount * l_asset_oec / l_oec_total;

            END IF;
          END IF;

          l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                             p_currency_code => l_currency_code);

          l_assoc_total := l_assoc_total + l_assoc_amount;

          l_link_asset_tbl(i).amount := l_assoc_amount;
        END IF;

      END LOOP;

      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_line_amount THEN

        l_diff := ABS(l_assoc_total - l_line_amount);

        FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

          IF l_link_asset_tbl.EXISTS(i) THEN

            -- if the total split amount is less than line amount add the difference amount to the
            -- asset with less amount and if the total split amount is greater than the line amount
            -- than subtract the difference amount from the asset with highest amount

            IF i = l_link_asset_tbl.FIRST THEN

              l_adj_rec     := i; -- Bug#3404844
              l_compare_amt := l_link_asset_tbl(i).amount;

            ELSIF (l_assoc_total < l_line_amount) AND (l_link_asset_tbl(i).amount <= l_compare_amt) OR
                  (l_assoc_total > l_line_amount) AND (l_link_asset_tbl(i).amount >= l_compare_amt) THEN

                l_adj_rec     := i;
                l_compare_amt := l_link_asset_tbl(i).amount;

            END IF;

          END IF;

        END LOOP;

        IF l_assoc_total < l_line_amount THEN

          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount + l_diff;

        ELSE

          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount - l_diff;

        END IF;

      END IF;

      ------------------------------------------------------
      -- 4. Prepare arrays to pass to create and update APIs
      ------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          l_assoc_amount := l_link_asset_tbl(i).amount;

          IF l_link_asset_tbl(i).link_line_id IS NULL THEN

            l_create_line_item_tbl(k).chr_id            := p_chr_id;
            l_create_line_item_tbl(k).parent_cle_id     := p_cle_id;
            l_create_line_item_tbl(k).item_id1          := l_link_asset_tbl(i).fin_asset_id;
            l_create_line_item_tbl(k).item_id2          := '#';
            l_create_line_item_tbl(k).item_object1_code := 'OKX_COVASST';
            l_create_line_item_tbl(k).serv_cov_prd_id   := NULL;

            -- The linked amount is always passed in as 'capital_amount' even though capital amount
            -- is applicable only for CAPITALIZED fee types.  The LLA API will ensure that
            -- the linked amount is stored in the appropriate column (AMOUNT vs CAPITAL_AMOUNT)
            l_create_line_item_tbl(k).capital_amount := l_assoc_amount;

            IF l_link_asset_tbl(i).asset_number IS NOT NULL THEN
              l_create_line_item_tbl(k).name := l_link_asset_tbl(i).asset_number;
            ELSE
              OPEN c_asset_number(p_fin_asset_id => l_link_asset_tbl(i).fin_asset_id,
                                  p_chr_id       => p_chr_id);
              FETCH c_asset_number INTO l_create_line_item_tbl(k).name;
              CLOSE c_asset_number;
            END IF;

            k := k + 1;

          ELSE

            l_update_line_item_tbl(m).cle_id            := l_link_asset_tbl(i).link_line_id;
            l_update_line_item_tbl(m).item_id           := l_link_asset_tbl(i).link_item_id;
            l_update_line_item_tbl(m).chr_id            := p_chr_id;
            l_update_line_item_tbl(m).parent_cle_id     := p_cle_id;
            l_update_line_item_tbl(m).item_id1          := l_link_asset_tbl(i).fin_asset_id;
            l_update_line_item_tbl(m).item_id2          := '#';
            l_update_line_item_tbl(m).item_object1_code := 'OKX_COVASST';
            l_update_line_item_tbl(m).serv_cov_prd_id   := NULL;

            -- The linked amount is always passed in as 'capital_amount' even though capital amount
            -- is applicable only for CAPITALIZED fee types.  The LLA API will ensure that
            -- the linked amount is stored in the appropriate column (AMOUNT vs CAPITAL_AMOUNT)
            l_update_line_item_tbl(m).capital_amount := l_assoc_amount;

            IF l_link_asset_tbl(i).asset_number IS NOT NULL THEN
              l_update_line_item_tbl(m).name := l_link_asset_tbl(i).asset_number;
            ELSE
              OPEN c_asset_number(p_fin_asset_id => l_link_asset_tbl(i).fin_asset_id,
                                  p_chr_id       => p_chr_id);
              FETCH c_asset_number INTO l_update_line_item_tbl(m).name;
              CLOSE c_asset_number;
            END IF;

            m := m + 1;

          END IF;

        END IF;

      END LOOP;

      IF l_create_line_item_tbl.COUNT > 0 THEN

        okl_contract_line_item_pvt.create_contract_line_item( p_api_version        => p_api_version,
                                                              p_init_msg_list      => p_init_msg_list,
                                                              x_return_status      => lx_return_status,
                                                              x_msg_count          => x_msg_count,
                                                              x_msg_data           => x_msg_data,
                                                              p_line_item_tbl      => l_create_line_item_tbl,
                                                              x_line_item_tbl      => lx_line_item_tbl);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

      IF l_update_line_item_tbl.COUNT > 0 THEN

        okl_contract_line_item_pvt.update_contract_line_item( p_api_version        => p_api_version,
                                                              p_init_msg_list      => p_init_msg_list,
                                                              x_return_status      => lx_return_status,
                                                              x_msg_count          => x_msg_count,
                                                              x_msg_data           => x_msg_data,
                                                              p_line_item_tbl      => l_update_line_item_tbl,
                                                              x_line_item_tbl      => lx_line_item_tbl);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END create_update_link_assets;
  --Bug# 4899328

  PROCEDURE allocate_amount(p_api_version         IN         NUMBER,
                            p_init_msg_list       IN         VARCHAR2 DEFAULT G_FALSE,
                            p_transaction_control IN         VARCHAR2 DEFAULT G_TRUE,
                            p_cle_id              IN         NUMBER,
                            p_chr_id              IN         NUMBER,
                            p_capitalize_yn       IN         VARCHAR2,
                            x_cle_id              OUT NOCOPY NUMBER,
                            x_chr_id              OUT NOCOPY NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_chr_id            okc_k_headers_b.id%type := null;
    l_cl_id             okc_k_headers_b.id%type := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'allocate_amount';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    --Bug# 4899328
    CURSOR c_assets(p_chr_id IN NUMBER) IS
    SELECT cle.id   fin_asset_id,
           cle.name asset_number
    FROM   okc_k_lines_v cle,
           okc_line_styles_b lse,
           okc_statuses_b sts
    WHERE  cle.chr_id = p_chr_id
      AND  cle.dnz_chr_id = p_chr_id
      AND  cle.lse_id = lse.id
      AND  lse.lty_code = 'FREE_FORM1'
      AND  cle.sts_code = sts.code
      AND  sts.ste_code NOT IN ('CANCELLED','TERMINATED');

    CURSOR c_cov_asset_line(p_chr_id     IN NUMBER,
                            p_fee_cle_id IN NUMBER,
                            p_fin_ast_id IN NUMBER) IS
    SELECT cov_ast_cle.id cov_ast_cle_id,
           cov_ast_cim.id cov_ast_cim_id
    FROM   okc_k_lines_b cov_ast_cle,
           okc_k_items cov_ast_cim
    WHERE  cov_ast_cle.dnz_chr_id = p_chr_id
    AND    cov_ast_cle.cle_id = p_fee_cle_id
    AND    cov_ast_cim.cle_id = cov_ast_cle.id
    AND    cov_ast_cim.object1_id1 = TO_CHAR(p_fin_ast_id)
    AND    cov_ast_cim.object1_id2 = '#'
    and    cov_ast_cim.jtot_object1_code = 'OKX_COVASST';

    l_link_asset_tbl        link_asset_tbl_type;

    i NUMBER;

  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

      --Bug# 4899328: Start
      /*
      OKL_SALES_QUOTE_LINES_PVT.allocate_amount(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        p_transaction_control   => p_transaction_control,
        p_cle_id                => p_cle_id,
        p_chr_id                => p_chr_id,
        p_capitalize_yn         => p_capitalize_yn,
        x_cle_id                => x_cle_id,
        x_chr_id                => x_chr_id,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data
        );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      */

    i := 0;
    FOR l_asset IN c_assets(p_chr_id => p_chr_id) LOOP
      i := i + 1;

      l_link_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
      l_link_asset_tbl(i).asset_number := l_asset.asset_number;

      l_link_asset_tbl(i).link_line_id := NULL;
      l_link_asset_tbl(i).link_item_id := NULL;
      FOR r_cov_asset_line IN c_cov_asset_line(p_chr_id     => p_chr_id,
                                               p_fee_cle_id => p_cle_id,
                                               p_fin_ast_id => l_asset.fin_asset_id)
      LOOP
        l_link_asset_tbl(i).link_line_id := r_cov_asset_line.cov_ast_cle_id;
        l_link_asset_tbl(i).link_item_id := r_cov_asset_line.cov_ast_cim_id;
      END LOOP;
    END LOOP;

    IF l_link_asset_tbl.COUNT > 0 THEN

      create_update_link_assets (p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 p_cle_id             => p_cle_id,
                                 p_chr_id             => p_chr_id,
                                 p_capitalize_yn      => p_capitalize_yn,
                                 p_link_asset_tbl     => l_link_asset_tbl,
                                 p_derive_assoc_amt   => 'Y',
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    --Bug# 4899328: End

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END allocate_amount;

  -- Guru added the following api for RVI

   PROCEDURE process_rvi_stream(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_check_box_value        IN VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 ) IS

 -- cursor to get contract details

    --Bug# 4524091
    CURSOR get_k_details_csr ( p_chr_id IN number ) IS
    SELECT
        START_DATE, END_DATE, ORIG_SYSTEM_SOURCE_CODE, ORIG_SYSTEM_ID1
    FROM OKL_K_HEADERS_FULL_V
    WHERE id = p_chr_id;




 -- cursor to get pricing engine

 CURSOR get_pricing_engine_csr  (p_chr_id IN  NUMBER) IS
 SELECT
   gts.pricing_engine
FROM
  okl_k_headers khr,
  okl_products_v pdt,
  okl_ae_tmpt_sets_v aes,
  OKL_ST_GEN_TMPT_SETS gts
WHERE
  khr.pdt_id = pdt.id AND
  pdt.aes_id = aes.id AND
  aes.gts_id = gts.id AND
  khr.id  = p_chr_id;

  -- cursor to get check box value
  CURSOR get_rvi_check_value_csr (p_chr_id in NUMBER) IS
  SELECT rule_information1
  FROM okc_rules_v rul, okc_rule_groups_v rgb
  WHERE rul.dnz_chr_id = p_chr_id AND
  rule_information_category = 'LARVAU' AND
  rgb.id = rul.rgp_id AND rgd_code like 'LARVIN';

  -- cursor to get fee line id and amount
  CURSOR get_fee_line_id (p_chr_id in NUMBER) IS
  SELECT kleb.id,Kleb.amount
  FROM
    okc_k_lines_b cleb,okl_k_lines kleb,okc_line_styles_b lseb
  WHERE cleb.dnz_chr_id = p_chr_id AND
  kleb.id = cleb.id AND
  cleb.lse_id = lseb.id AND
  lseb.lty_code = 'FEE' AND
  kleb.fee_purpose_code = 'RVI';

  -- cursor to get stream name and stream id

  CURSOR get_stream_name_csr (p_chr_id in NUMBER) IS
   SELECT styb.id, styb.code
FROM   okl_strm_type_b styb,
      okc_k_items     cim,
      okc_k_lines_b   cleb,
      okl_k_lines     kle
WHERE  styb.id      =  cim.object1_id1
AND    '#'          =  cim.object1_id2
AND    cim.jtot_object1_code = 'OKL_STRMTYP'
AND    cim.cle_id            = cleb.id
AND    cim.dnz_chr_id        = cleb.dnz_chr_id
AND    cleb.lse_id           = 52
AND    kle.id                = cleb.id
AND    kle.fee_type          = 'ABSORBED'
AND    kle.fee_purpose_code  = 'RVI'
AND    cleb.dnz_chr_id       = p_chr_id;

-- cursor to get okc_k_items id

CURSOR get_okc_k_items_csr (fee_line_id IN NUMBER) IS
SELECT id
FROM okc_k_items_v
WHERE cle_id = fee_line_id;


   l_return_status                VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     VARCHAR2(200) := 'process_rvi_stream';

l_fee_types_rec    fee_types_rec_type := p_fee_types_rec;
l_line_id               okc_k_lines_b.id%type;
 l_chr_id            okc_k_lines_b.dnz_chr_id%type;
 l_check_box_value VARCHAR2(450);
 l_strm_id okl_strm_type_b.id%type;
 l_strm_name okl_strm_type_b.code%type;
 l_fee_line_id okl_k_lines.id%type;
 l_amount   okl_k_lines.amount%type;

    l_start_date DATE;
    l_end_date   DATE;

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_price_engine   OKL_ST_GEN_TMPT_SETS.pricing_engine%type;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;
    l_check_box_val VARCHAR2(450);
    l_cim_id NUMBER;
    --Bug# 4524091
    l_orig_system_source_code okc_k_headers_b.orig_system_source_code%type;

    --Bug# 8652738
    l_orig_check_box_value OKC_RULES_B.rule_information1%TYPE;
    l_orig_chr_id          OKC_K_HEADERS_B.id%TYPE;

 BEGIN

    l_chr_id := p_fee_types_rec.dnz_chr_id;
    l_line_id := p_fee_types_rec.line_id;
    l_check_box_val := p_check_box_value;
    If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);


    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

     -- initialize return variables
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --  added for bug 4524091

    open get_k_details_csr (l_chr_id);
    fetch get_k_details_csr into l_start_date, l_end_date,l_orig_system_source_code,l_orig_chr_id;
    close get_k_details_csr;

    --Bug# 8652738: Support of RVI T and C added during rebook
    /*if ((l_orig_system_source_code is not null) and (l_orig_system_source_code = 'OKL_REBOOK')) then
    -- not allowed to change RVI in T and C during rebook.
                             OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                         p_msg_name      => 'OKL_RVI_STRM_CANNOT_CHANGED');
                             RAISE OKC_API.G_EXCEPTION_ERROR;
     end if;*/
     -- end 4524091

     If ( p_fee_types_rec.dnz_chr_id is null or p_fee_types_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_FEE_TYPE');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => 'dnz_chr_id'
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;



    open get_rvi_check_value_csr(l_chr_id);
    fetch get_rvi_check_value_csr into l_check_box_value;
    close get_rvi_check_value_csr;


    open get_pricing_engine_csr(l_chr_id);
    fetch get_pricing_engine_csr into l_price_engine;
    close get_pricing_engine_csr;


    open get_stream_name_csr(l_chr_id);
    fetch get_stream_name_csr into l_strm_id, l_strm_name;
    close get_stream_name_csr;


    open get_fee_line_id (l_chr_id);
    fetch get_fee_line_id into l_fee_line_id,l_amount;
    close get_fee_line_id;

  --  p_check_box_value1 := 'Y';
    if (l_check_box_val = 'Y') then
        if ((l_price_engine is not null) and (l_price_engine = 'INTERNAL' ))THEN
        -- not allowed for internal stream generation
            OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                 p_msg_name      => 'OKL_LA_RVI_NO_ISG');
                                 RAISE OKC_API.G_EXCEPTION_ERROR;
        elsif ((l_price_engine is not null) and (l_price_engine = 'EXTERNAL' ))THEN
       -- it is external stream generation


               if  ((p_fee_types_rec.item_id1 is null) or  (p_fee_types_rec.item_id1 = OKL_API.G_MISS_CHAR)) THEN
                   -- throw error message stm name is manditory
                         OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                         p_msg_name      => 'OKL_RVI_STREAM_REQD');
                                         RAISE OKC_API.G_EXCEPTION_ERROR;
               end if;

                if ((l_strm_id IS NOT NULL) AND (l_strm_id <> OKL_API.G_MISS_NUM)) THEN

                 open get_okc_k_items_csr (l_fee_line_id);
                 fetch get_okc_k_items_csr into l_cim_id;
                 close get_okc_k_items_csr;

                   l_fee_types_rec.line_id := l_fee_line_id;
                   l_fee_types_rec.item_id := l_cim_id;
                  -- l_fee_types_rec.fee_type := 'ABSORBED';
                  -- l_fee_types_rec.dnz_chr_id := l_chr_id;
                   l_fee_types_rec.item_name := p_fee_types_rec.item_name;
                   l_fee_types_rec.item_id1 := to_char(p_fee_types_rec.item_id1);
		           l_fee_types_rec.fee_purpose_code := 'RVI';
		            l_fee_types_rec.amount := 0;
                    l_fee_types_rec.effective_from := l_start_date;
                    l_fee_types_rec.effective_to := l_end_date;

                    l_fee_types_rec.PARTY_ID := NULL;
                    l_fee_types_rec.PARTY_NAME := NULL;
                    l_fee_types_rec.PARTY_ID1 := NULL;
                    l_fee_types_rec.PARTY_ID2 := NULL;

                    update_fee_type(
                         p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => l_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_fee_types_rec    => l_fee_types_rec,
                         x_fee_types_rec    => x_fee_types_rec);


                   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                ELSIF  (p_fee_types_rec.item_id1 IS NOT NULL) THEN


                    l_fee_types_rec.fee_type := 'ABSORBED';
		    l_fee_types_rec.fee_purpose_code := 'RVI';
		    l_fee_types_rec.amount := 0;
                    l_fee_types_rec.effective_from := l_start_date;
                    l_fee_types_rec.effective_to := l_end_date;

                     l_fee_types_rec.PARTY_ID := NULL;
		     l_fee_types_rec.PARTY_NAME := NULL;
		     l_fee_types_rec.PARTY_ID1 := NULL;
		     l_fee_types_rec.PARTY_ID2 := NULL;
                     l_fee_types_rec.INITIAL_DIRECT_COST := NULL;

                    create_fee_type(
                         p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => l_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_fee_types_rec    => l_fee_types_rec,
                         x_fee_types_rec    => x_fee_types_rec);


                    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
                  end if;   -- end of create
             end if;    -- else

     elsif  (l_check_box_val = 'N') then

         --Bug# 8652738: Change in Automatically Calculate RVI flag from 'Yes' to 'No' is
         -- not supported during rebook
         if ((l_orig_system_source_code is not null) and (l_orig_system_source_code = 'OKL_REBOOK')) then

           l_orig_check_box_value := NULL;
           open get_rvi_check_value_csr(l_orig_chr_id);
           fetch get_rvi_check_value_csr into l_orig_check_box_value;
           close get_rvi_check_value_csr;

           IF (NVL(l_orig_check_box_value,'N') <> l_check_box_val) THEN
             OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                                 p_msg_name      => 'OKL_LA_RVI_UPD_NOT_ALLOWED');
             RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

         end if;

         if  ((l_price_engine is not null) and (l_price_engine = 'EXTERNAL' ))THEN
             --Bug# 8652738
             if (l_fee_line_id is not null) then

                open get_okc_k_items_csr (l_fee_line_id);
                fetch get_okc_k_items_csr into l_cim_id;
                close get_okc_k_items_csr;

                         l_fee_types_rec.line_id := l_fee_line_id;
                         l_fee_types_rec.item_id := l_cim_id;
                         l_fee_types_rec.fee_purpose_code:= 'RVI_DUMMY'; -- since rvi can't be delted from delte screen

                   delete_fee_type(
                         p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => l_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_fee_types_rec    => l_fee_types_rec);


                         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                             RAISE OKC_API.G_EXCEPTION_ERROR;
                         END IF;

             elsif ((p_fee_types_rec.item_id1 IS NOT null) AND  (p_fee_types_rec.item_id1 <> OKL_API.G_MISS_CHAR)) then
                                   -- throw error message check box has to be checkd
                   OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                         p_msg_name      => 'OKL_RVI_CHECK_BOX_REQD');
                                         RAISE OKC_API.G_EXCEPTION_ERROR;
             end if;

         --Bug# 8652738
         elsif  ((l_price_engine is not null) and (l_price_engine = 'INTERNAL' ))THEN

           if (l_fee_line_id is not null) then
             open get_okc_k_items_csr (l_fee_line_id);
             fetch get_okc_k_items_csr into l_cim_id;
             close get_okc_k_items_csr;

             l_fee_types_rec.line_id := l_fee_line_id;
             l_fee_types_rec.item_id := l_cim_id;
             l_fee_types_rec.fee_purpose_code:= 'RVI_DUMMY'; -- since rvi can't be delted from delte screen

             delete_fee_type(
               p_api_version      => p_api_version,
               p_init_msg_list    => p_init_msg_list,
               x_return_status    => l_return_status,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data,
               p_fee_types_rec    => l_fee_types_rec);


             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
           end if;
         end if;
       end if;
                 -- set return variables
     x_return_status := l_return_status;

     -- end the transaction

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

 END process_rvi_stream;


 PROCEDURE create_party(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_kpl_rec                      IN  party_rec_type,
       x_kpl_rec                      OUT NOCOPY party_rec_type
       ) AS

 l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT varchar2(30) := 'create_party';
 l_api_version          CONSTANT NUMBER := 1.0;

 lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
 lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
 lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
 lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

 Begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY (
                                l_api_name
                                ,p_init_msg_list
                                ,'_PVT'
                                ,x_return_status);
     -- Check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     lp_cplv_rec.id := p_kpl_rec.id;
     lp_cplv_rec.object1_id1 := p_kpl_rec.object1_id1;
     lp_cplv_rec.object1_id2 := p_kpl_rec.object1_id2;
     lp_cplv_rec.jtot_object1_code := p_kpl_rec.jtot_object1_code;
     lp_cplv_rec.rle_code := p_kpl_rec.rle_code;
     lp_cplv_rec.dnz_chr_id := p_kpl_rec.dnz_chr_id;
     lp_cplv_rec.cle_id := p_kpl_rec.cle_id;
     lp_kplv_rec.attribute_category := p_kpl_rec.attribute_category;
     lp_kplv_rec.attribute1 := p_kpl_rec.attribute1;
     lp_kplv_rec.attribute2 := p_kpl_rec.attribute2;
     lp_kplv_rec.attribute3 := p_kpl_rec.attribute3;
     lp_kplv_rec.attribute4 := p_kpl_rec.attribute4;
     lp_kplv_rec.attribute5 := p_kpl_rec.attribute5;
     lp_kplv_rec.attribute6 := p_kpl_rec.attribute6;
     lp_kplv_rec.attribute7 := p_kpl_rec.attribute7;
     lp_kplv_rec.attribute8 := p_kpl_rec.attribute8;
     lp_kplv_rec.attribute9 := p_kpl_rec.attribute9;
     lp_kplv_rec.attribute10 := p_kpl_rec.attribute10;
     lp_kplv_rec.attribute11 := p_kpl_rec.attribute11;
     lp_kplv_rec.attribute12 := p_kpl_rec.attribute12;
     lp_kplv_rec.attribute13 := p_kpl_rec.attribute13;
     lp_kplv_rec.attribute14 := p_kpl_rec.attribute14;
     lp_kplv_rec.attribute15 := p_kpl_rec.attribute15;

     IF(p_kpl_rec.rle_code IS NOT NULL AND
     	NOT (p_kpl_rec.rle_code = 'LESSEE' OR p_kpl_rec.rle_code = 'LESSOR')) THEN
      lp_kplv_rec.validate_dff_yn := 'Y';
     END IF;

     okl_k_party_roles_pvt.create_k_party_role(
       p_api_version      => p_api_version,
       p_init_msg_list    => p_init_msg_list,
       x_return_status    => x_return_status,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data,
       p_cplv_rec         => lp_cplv_rec,
       x_cplv_rec         => lx_cplv_rec,
       p_kplv_rec         => lp_kplv_rec,
       x_kplv_rec         => lx_kplv_rec);

     x_kpl_rec.id := lx_cplv_rec.id;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

     EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OTHERS',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');

 end;

PROCEDURE update_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                      IN  party_rec_type,
      x_kpl_rec                      OUT NOCOPY party_rec_type
      ) AS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'update_party';
l_api_version          CONSTANT NUMBER := 1.0;

lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_cplv_rec.id := p_kpl_rec.id;
    lp_cplv_rec.object1_id1 := p_kpl_rec.object1_id1;
    lp_cplv_rec.object1_id2 := p_kpl_rec.object1_id2;
    lp_cplv_rec.rle_code := p_kpl_rec.rle_code;
    lp_cplv_rec.dnz_chr_id := p_kpl_rec.dnz_chr_id;
    lp_cplv_rec.cle_id := p_kpl_rec.cle_id;
    lp_kplv_rec.attribute_category := p_kpl_rec.attribute_category;
    lp_kplv_rec.attribute1 := p_kpl_rec.attribute1;
    lp_kplv_rec.attribute2 := p_kpl_rec.attribute2;
    lp_kplv_rec.attribute3 := p_kpl_rec.attribute3;
    lp_kplv_rec.attribute4 := p_kpl_rec.attribute4;
    lp_kplv_rec.attribute5 := p_kpl_rec.attribute5;
    lp_kplv_rec.attribute6 := p_kpl_rec.attribute6;
    lp_kplv_rec.attribute7 := p_kpl_rec.attribute7;
    lp_kplv_rec.attribute8 := p_kpl_rec.attribute8;
    lp_kplv_rec.attribute9 := p_kpl_rec.attribute9;
    lp_kplv_rec.attribute10 := p_kpl_rec.attribute10;
    lp_kplv_rec.attribute11 := p_kpl_rec.attribute11;
    lp_kplv_rec.attribute12 := p_kpl_rec.attribute12;
    lp_kplv_rec.attribute13 := p_kpl_rec.attribute13;
    lp_kplv_rec.attribute14 := p_kpl_rec.attribute14;
    lp_kplv_rec.attribute15 := p_kpl_rec.attribute15;
    lp_kplv_rec.validate_dff_yn := 'Y';

    okl_k_party_roles_pvt.update_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);


    x_kpl_rec.id := lx_cplv_rec.id;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

end;

END OKL_MAINTAIN_FEE_PVT;

/
