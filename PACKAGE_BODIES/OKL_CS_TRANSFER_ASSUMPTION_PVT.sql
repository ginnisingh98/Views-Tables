--------------------------------------------------------
--  DDL for Package Body OKL_CS_TRANSFER_ASSUMPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_TRANSFER_ASSUMPTION_PVT" AS
/* $Header: OKLRTRAB.pls 120.9.12010000.2 2010/04/28 00:18:34 sachandr ship $ */


  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;
  l_taav_tbl       taav_tbl_type;



  PROCEDURE Create_Requests(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            p_header_tbl                     IN  tcnv_tbl_type,
                            p_add_hdr_tbl                    IN  add_hdr_tbl_type,
                            p_old_line_tbl                   IN  l_before_trf_tbl,
                            p_new_line_tbl                   IN  l_after_trf_tbl,
                            x_header_tbl                     OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
                            x_taav_tbl                       OUT NOCOPY taav_tbl_type,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2)

  AS
     l_count    NUMBER;
     l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name              CONSTANT VARCHAR2(30) := 'Create_Request';
     l_api_version           CONSTANT NUMBER := 1;
      j    BINARY_INTEGER;


  BEGIN

     x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
 --populating the header record
    l_tcnv_rec.khr_id                    := p_header_tbl(1).khr_id;
    l_tcnv_rec.khr_id_old                := p_header_tbl(1).khr_id_old;
    l_tcnv_rec.party_rel_id1_old         := p_header_tbl(1).party_rel_id1_old;
    l_tcnv_rec.party_rel_id2_old         := p_header_tbl(1).party_rel_id2_old;
    l_tcnv_rec.party_rel_id1_new         := p_header_tbl(1).party_rel_id1_new;
    l_tcnv_rec.party_rel_id2_new         := p_header_tbl(1).party_rel_id2_new;
    l_tcnv_rec.complete_transfer_yn      := p_header_tbl(1).complete_transfer_yn;
    l_tcnv_rec.date_transaction_occurred := p_header_tbl(1).date_transaction_occurred;
    l_tcnv_rec.try_id                    := p_header_tbl(1).try_id;
    l_tcnv_rec.tsu_code                  := p_header_tbl(1).tsu_code;
    l_tcnv_rec.description               := p_header_tbl(1).description;
    l_tcnv_rec.tcn_type                  := p_header_tbl(1).tcn_type;
    l_tcnv_rec.created_by                := p_header_tbl(1).created_by;
    l_tcnv_rec.creation_date             := p_header_tbl(1).creation_date;
    l_tcnv_rec.last_updated_by           := p_header_tbl(1).last_updated_by;
    l_tcnv_rec.last_update_date          := p_header_tbl(1).last_update_date;
    l_tcnv_rec.last_update_login         := p_header_tbl(1).last_update_login;
    l_tcnv_rec.legal_entity_id           := p_header_tbl(1).legal_entity_id;    --dkagrawa added for LE uptake

  -- skgautam for bug...
    l_tcnv_rec.rjn_code                  := p_header_tbl(1).rjn_code;
    l_tcnv_rec.khr_id_new                := p_header_tbl(1).khr_id_new;
  --



  --Populating the lines

   l_count := p_old_line_tbl.COUNT;



    IF l_count > 0 THEN
      FOR i IN 1..l_count LOOP
        l_tclv_tbl(i).kle_id    := p_old_line_tbl(i).id;
        l_tclv_tbl(i).before_transfer_yn  := p_old_line_tbl(i).line_type;
        l_tclv_tbl(i).tcl_type  := 'TAA';
        l_tclv_tbl(i).line_number := i;
        l_tclv_tbl(i).amount := 100;
        l_tclv_tbl(i).khr_id := l_tcnv_rec.khr_id;
      END LOOP;

      j := l_tclv_tbl.LAST;
      l_count := p_new_line_tbl.COUNT;

      IF l_count > 0 THEN
      FOR i IN 1..l_count LOOP
        l_tclv_tbl(j + i).kle_id   := p_new_line_tbl(i).id;
        l_tclv_tbl(j + i).before_transfer_yn := p_new_line_tbl(i).line_type;
        l_tclv_tbl(j + i).tcl_type  := 'TAA';
       -- l_tclv_tbl(j + i).sty_id    := l_sty_id;
        l_tclv_tbl(j + i).line_number := j + i;
        l_tclv_tbl(j + i).amount := 100;
        l_tclv_tbl(j + i).khr_id := l_tcnv_rec.khr_id;
        l_tclv_tbl(j + i).source_column_1      := 'INSTALL_SITE_ID';
        l_tclv_tbl(j + i).source_value_1       :=  P_new_line_tbl(i).install_loc_id;
        l_tclv_tbl(j + i).source_column_2      := 'FA_LOC_ID';
        l_tclv_tbl(j + i).source_value_2       := P_new_line_tbl(i).fa_loc_id;
        l_tclv_tbl(j + i).source_column_3      := 'BILL_TO_SITE_ID';
        l_tclv_tbl(j + i).source_value_3       := P_new_line_tbl(i).bill_to_site_id;
      END LOOP;
      END IF;
    END IF;

    OKL_TRX_CONTRACTS_PUB.create_trx_contracts(p_api_version         => p_api_version,
                                              p_init_msg_list       => p_init_msg_list,
                                              x_return_status       => x_return_status,
                                              x_msg_count           => x_msg_count,
                                              x_msg_data            => x_msg_data,
                                              p_tcnv_rec            => l_tcnv_rec,
                                              p_tclv_tbl            => l_tclv_tbl,
                                              x_tcnv_rec            => lx_tcnv_rec,
                                              x_tclv_tbl            => lx_tclv_tbl);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


--geting the output header record
   x_header_tbl(1).trx_number := lx_tcnv_rec.trx_number;
   x_header_tbl(1).id         := lx_tcnv_rec.id;

   --populating the additional Lessee information in the t a entity.
    l_taav_tbl(1).tcn_id                  := x_header_tbl(1).id;
    l_taav_tbl(1).new_contract_number     := p_add_hdr_tbl(1).new_contract_number;
    l_taav_tbl(1).bill_to_site_id         := p_add_hdr_tbl(1).bill_to_site_id;
    l_taav_tbl(1).cust_acct_id            := p_add_hdr_tbl(1).cust_acct_id;
    l_taav_tbl(1).bank_acct_id            := p_add_hdr_tbl(1).bank_acct_id;
    l_taav_tbl(1).invoice_format_id       := p_add_hdr_tbl(1).invoice_format_id;
    l_taav_tbl(1).payment_mthd_id         := p_add_hdr_tbl(1).payment_mthd_id;
    l_taav_tbl(1).mla_id                  := p_add_hdr_tbl(1).mla_id;
    l_taav_tbl(1).credit_line_id          := p_add_hdr_tbl(1).credit_line_id;
    l_taav_tbl(1).insurance_yn            := p_add_hdr_tbl(1).insurance_yn;
    l_taav_tbl(1).lease_policy_yn         := p_add_hdr_tbl(1).lease_policy_yn;

    --inserting the lessee details into t a entity

      OKL_TAA_PVT.insert_row( p_api_version        =>   l_api_version ,
                              p_init_msg_list      =>   'F',
                              x_return_status      =>    l_return_status,
                              x_msg_count          =>    x_msg_count,
                              x_msg_data           =>    x_msg_data,
                              p_taav_tbl           =>    l_taav_tbl,
                              x_taav_tbl           =>    x_taav_tbl);

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );


  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');

  END Create_Requests;



  PROCEDURE Accept_Requests(p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                            p_header_tbl                     IN  tcnv_tbl_type,
                            p_upd_hdr_tbl                    IN  upd_hdr_tbl_type,
                            p_old_line_tbl                   IN  l_before_trf_tbl,
                            p_new_line_tbl                   IN  l_after_trf_tbl,
                            x_header_tbl                     OUT NOCOPY Okl_Trx_Contracts_Pub.tcnv_tbl_type,
                            x_taaV_tbl                       OUT NOCOPY taav_tbl_type,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2)
   AS

  l_api_name     varchar2(100) := 'Accept_Requests';
  l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version           CONSTANT NUMBER := 1;


  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;
  l_count          NUMBER;
  j                NUMBER;

  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --populating the header record
    l_tcnv_rec.id                        := p_header_tbl(1).id;
    l_tcnv_rec.khr_id                    := p_header_tbl(1).khr_id;
    l_tcnv_rec.party_rel_id1_old         := p_header_tbl(1).party_rel_id1_old;
    l_tcnv_rec.party_rel_id1_new         := p_header_tbl(1).party_rel_id1_new;
    l_tcnv_rec.party_rel_id2_new         := p_header_tbl(1).party_rel_id2_new;
    l_tcnv_rec.complete_transfer_yn      := p_header_tbl(1).complete_transfer_yn;
    l_tcnv_rec.date_transaction_occurred := p_header_tbl(1).date_transaction_occurred;
    l_tcnv_rec.tsu_code                  := p_header_tbl(1).tsu_code;
    l_tcnv_rec.description               := p_header_tbl(1).description;

    l_tcnv_rec.last_updated_by       := p_header_tbl(1).last_updated_by;
    l_tcnv_rec.last_update_date      := p_header_tbl(1).last_update_date;
    l_tcnv_rec.last_update_login     := p_header_tbl(1).last_update_login;
    l_tcnv_rec.legal_entity_id       := p_header_tbl(1).legal_entity_id;    --dkagrawa added for LE uptake


     --Populating the lines

   l_count := p_old_line_tbl.COUNT;


     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version         => p_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_tcnv_rec            => l_tcnv_rec,
                                                p_tclv_tbl            => l_tclv_tbl,
                                                x_tcnv_rec            => lx_tcnv_rec,
                                                x_tclv_tbl            => lx_tclv_tbl);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


--geting the output header record
   x_header_tbl(1).trx_number := lx_tcnv_rec.trx_number;
   x_header_tbl(1).id         := lx_tcnv_rec.id;

    --populating the additional Lessee information in the t  a entity.
    l_taav_tbl(1).id                      := p_upd_hdr_tbl(1).id;
    l_taav_tbl(1).tcn_id                  := x_header_tbl(1).id;
    l_taav_tbl(1).new_contract_number     := p_upd_hdr_tbl(1).new_contract_number;
    l_taav_tbl(1).bill_to_site_id         := p_upd_hdr_tbl(1).bill_to_site_id;
    l_taav_tbl(1).cust_acct_id            := p_upd_hdr_tbl(1).cust_acct_id;
    l_taav_tbl(1).bank_acct_id            := p_upd_hdr_tbl(1).bank_acct_id;
    l_taav_tbl(1).invoice_format_id       := p_upd_hdr_tbl(1).invoice_format_id;
    l_taav_tbl(1).payment_mthd_id         := p_upd_hdr_tbl(1).payment_mthd_id;
    l_taav_tbl(1).mla_id                  := p_upd_hdr_tbl(1).mla_id;
    l_taav_tbl(1).credit_line_id          := p_upd_hdr_tbl(1).credit_line_id;
    l_taav_tbl(1).insurance_yn            := p_upd_hdr_tbl(1).insurance_yn;
    l_taav_tbl(1).lease_policy_yn         := p_upd_hdr_tbl(1).lease_policy_yn;

    --updating the lessee details into t  a entity

      OKL_TAA_PVT.update_row( p_api_version        =>   l_api_version ,
                              p_init_msg_list      =>   'F',
                              x_return_status      =>    l_return_status,
                              x_msg_count          =>    x_msg_count,
                              x_msg_data           =>    x_msg_data,
                              p_taav_tbl           =>    l_taav_tbl,
                              x_taav_tbl           =>    x_taav_tbl);



    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );


  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');


  END Accept_Requests;


  PROCEDURE Update_Requests(p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                            p_header_tbl                     IN  tcnv_tbl_type,
                            p_upd_hdr_tbl                    IN  upd_hdr_tbl_type,
                            p_old_line_tbl                   IN  l_before_trf_tbl,
                            p_new_line_tbl                   IN  l_after_trf_tbl,
                            x_header_tbl                     OUT NOCOPY Okl_Trx_Contracts_Pub.tcnv_tbl_type,
                            x_taaV_tbl                       OUT NOCOPY taav_tbl_type,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2)
   AS

  l_api_name     varchar2(100) := 'Update_Requests';
  l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version           CONSTANT NUMBER := 1;

  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;
  l_count          NUMBER;
  j                NUMBER;

  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --populating the header record
    l_tcnv_rec.id                        := p_header_tbl(1).id;
    l_tcnv_rec.party_rel_id1_old         := p_header_tbl(1).party_rel_id1_old;
    l_tcnv_rec.party_rel_id1_new         := p_header_tbl(1).party_rel_id1_new;
    l_tcnv_rec.party_rel_id2_new         := p_header_tbl(1).party_rel_id2_new;
    l_tcnv_rec.date_transaction_occurred := p_header_tbl(1).date_transaction_occurred;
    l_tcnv_rec.description               := p_header_tbl(1).description;
    l_tcnv_rec.tsu_code                  := p_header_tbl(1).tsu_code;

    l_tcnv_rec.last_updated_by       := p_header_tbl(1).last_updated_by;
    l_tcnv_rec.last_update_date      := p_header_tbl(1).last_update_date;
    l_tcnv_rec.last_update_login     := p_header_tbl(1).last_update_login;
    l_tcnv_rec.legal_entity_id       := p_header_tbl(1).legal_entity_id;    --dkagrawa added for LE uptake



    OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version         => p_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_tcnv_rec            => l_tcnv_rec,
                                                p_tclv_tbl            => l_tclv_tbl,
                                                x_tcnv_rec            => lx_tcnv_rec,
                                                x_tclv_tbl            => lx_tclv_tbl);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


--geting the output header record
   x_header_tbl(1).trx_number := lx_tcnv_rec.trx_number;
   x_header_tbl(1).id         := lx_tcnv_rec.id;

    --populating the additional Lessee information in the t  a entity.
    l_taav_tbl(1).id                      := p_upd_hdr_tbl(1).id;
    l_taav_tbl(1).tcn_id                  := x_header_tbl(1).id;
    l_taav_tbl(1).new_contract_number     := p_upd_hdr_tbl(1).new_contract_number;
    l_taav_tbl(1).bill_to_site_id         := p_upd_hdr_tbl(1).bill_to_site_id;
    l_taav_tbl(1).cust_acct_id            := p_upd_hdr_tbl(1).cust_acct_id;
    l_taav_tbl(1).bank_acct_id            := p_upd_hdr_tbl(1).bank_acct_id;
    l_taav_tbl(1).invoice_format_id       := p_upd_hdr_tbl(1).invoice_format_id;
    l_taav_tbl(1).payment_mthd_id         := p_upd_hdr_tbl(1).payment_mthd_id;
    l_taav_tbl(1).mla_id                  := p_upd_hdr_tbl(1).mla_id;
    l_taav_tbl(1).credit_line_id          := p_upd_hdr_tbl(1).credit_line_id;
    l_taav_tbl(1).insurance_yn            := p_upd_hdr_tbl(1).insurance_yn;
    l_taav_tbl(1).lease_policy_yn         := p_upd_hdr_tbl(1).lease_policy_yn;

    --updating the lessee details into t a entity

      OKL_TAA_PVT.update_row( p_api_version        =>   l_api_version ,
                              p_init_msg_list      =>   'F',
                              x_return_status      =>    l_return_status,
                              x_msg_count          =>    x_msg_count,
                              x_msg_data           =>    x_msg_data,
                              p_taav_tbl           =>    l_taav_tbl,
                              x_taav_tbl           =>    x_taav_tbl);



    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );


  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');


  END Update_Requests;

   PROCEDURE Populate_new_Lessee_details( p_api_version                    IN  NUMBER,
                                          p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                          p_request_id                     IN  NUMBER,
                                          x_new_lessee_tbl                 OUT NOCOPY new_lessee_tbl_type,
                                          x_return_status                  OUT NOCOPY VARCHAR2,
                                          x_msg_count                      OUT NOCOPY NUMBER,
                                          x_msg_data                       OUT NOCOPY VARCHAR2)
  IS

  --Obtain the request record details
    CURSOR c_request_record(p_request_id IN NUMBER) IS
    SELECT *
    FROM OKL_TRX_CONTRACTS
    WHERE id = p_request_id;

    --Obtain the new lessee name
    CURSOR c_lessee(p_party_id IN NUMBER) IS
    SELECT  party_id,
            PARTY_NAME
    FROM    HZ_PARTIES PARTY
    WHERE  PARTY_ID = p_party_id;

    CURSOR c_taa_record(p_tcn_id IN NUMBER) IS
    SELECT *
    FROM okl_taa_request_details_v
    WHERE tcn_id = p_tcn_id;

    CURSOR c_bill_to(p_site_id IN NUMBER) IS
    SELECT id1,
           description
    FROM   okx_cust_site_uses_v
    WHERE ID1 = p_site_id;

    CURSOR c_bank_account(p_bank_acct_id  IN NUMBER) IS
    SELECT id1,
           -- Bug 9502479
           -- bank_account_num
           description
           -- End Bug 9502479
    FROM OKX_RCPT_METHOD_ACCOUNTS_V
    WHERE ID1 = p_bank_acct_id;


   -- Populating the customer account
    CURSOR c_cust_account(p_cust_acct_id IN NUMBER) IS
    SELECT cust_account_id,
           account_number
    FROM hz_cust_accounts
    WHERE cust_account_id = p_cust_acct_id;

   -- populating the invoice format
    CURSOR c_invoice_format(p_inv_format_id IN NUMBER) IS
    SELECT id,
           name
    FROM OKL_INVOICE_FORMATS_V
    WHERE ID = p_inv_format_id;

   -- populating the payment method
    CURSOR c_payment_mthd(p_pay_mthd_id IN NUMBER) IS
    SELECT id1,
           name
    FROM OKX_RECEIPT_METHODS_V
    WHERE id1 = p_pay_mthd_id;

   -- populating the new contract number
    CURSOR c_new_ctr_no(p_request_id IN NUMBER) IS
    SELECT new_contract_number
    FROM okl_taa_request_details_b
    WHERE tcn_id = p_request_id;

   -- populating the master lease agreement and credit line no
    CURSOR c_mla_no(p_contract_id IN NUMBER) IS
    SELECT id,
           contract_number
    FROM OKC_K_HEADERS_B
    WHERE ID = p_contract_id;



    CURSOR c_contact(p_cust_account_id  IN NUMBER,
                     p_party_id         IN NUMBER) IS
    SELECT hzp.party_id,
           hzp.party_name contact_name,
           hzp.email_address email
    FROM  hz_parties hzp,
          hz_cust_account_roles hzc
    WHERE hzc.cust_account_id = p_cust_account_id
    AND hzc.status = 'A'
    AND hzc.role_type = 'CONTACT'
    AND hzc.party_id = hzp.party_id
    and hzp.party_id = p_party_id ;


--rkraya added for bug:2451527
    CURSOR c_phone(p_party_id  IN NUMBER) IS
    SELECT  decode(nvl(phone_country_code,''),(phone_country_code || '-'),'') || phone_area_code || phone_number phone
    FROM hz_contact_points
    WHERE owner_table_id = p_party_id
    AND   contact_point_type = 'PHONE';


    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name              CONSTANT VARCHAR2(30) := 'Populate';
    l_api_version           CONSTANT NUMBER := 1;
    l_id1                VARCHAR2(40);
    l_id2                VARCHAR2(200);
    l_lessee_name        VARCHAR2(360);
    l_party_id           NUMBER;
    l_contact_email      VARCHAR2(2000);
    l_billto_address     VARCHAR2(4000);
    l_billto_id          NUMBER;
    l_contact_name       VARCHAR2(300);
    l_contact_party_id   NUMBER;
    l_phone              VARCHAR2(30);
    l_request_record     OKL_TRX_CONTRACTS%ROWTYPE;
    l_taa_record         OKL_TAA_REQUEST_DETAILS_B%rowtype;
    l_ctr_no             VARCHAR2(120);
    l_acct_no            VARCHAR2(30);
    l_acct_id            NUMBER;
    l_location           VARCHAR2(4000);
    l_bank               VARCHAR2(100);
    l_bank_acct_id       NUMBER;
    l_pay_mthd           VARCHAR2(30);
    l_pay_mthd_id        NUMBER;
    l_inv_fmt            VARCHAR2(450);
    l_inv_fmt_id         NUMBER;
    l_master_lease       VARCHAR2(120);
    l_mla_id             NUMBER;
    l_credit_line        VARCHAR2(120);
    l_crd_id             NUMBER;


  BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_New_Lessee_details','Begin(+)');
   END IF;
 --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_New_Lessee_details',
              'p_api_version :'||p_api_version);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_New_Lessee_details',
              'p_init_msg_list :'||p_init_msg_list);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_New_Lessee_details',
              'p_request_id :'||p_request_id);
   END IF;

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                            '_PVT',
                                              x_return_status);



   --Fetch the request details
     OPEN c_request_record(p_requesT_id);
     FETCH c_request_record INTO l_request_record;
     CLOSE c_request_record;



   --Fetch the new Lessee Details
     OPEN c_lessee(l_request_record.party_rel_id2_new);
     FETCH c_lessee INTO l_party_id,l_lessee_name;
     CLOSE c_lessee;


    OPEN c_taa_record(p_request_id);
    FETCH c_taa_record INTO l_taa_record;
    CLOSE c_taa_record;

   --populating the bill to address
     OPEN c_bill_to(l_taa_record.bill_to_site_id);
     FETCH c_bill_to INTO l_billto_id,l_billto_address;
     CLOSE c_bill_to;


   -- populating the bank account
     OPEN c_bank_account(l_taa_record.bank_acct_id);
     FETCH c_bank_account INTO l_bank_acct_id,l_bank;
     CLOSE c_bank_account;


   -- Populating the customer account
     OPEN c_cust_account(l_taa_record.cust_acct_id);
     FETCH c_cust_account INTO l_acct_id,l_acct_no;
     CLOSE c_cust_account;

   -- populating the invoice format
     OPEN c_invoice_format(l_taa_record.invoice_format_id) ;
     FETCH c_invoice_format INTO l_inv_fmt_id,l_inv_fmt;
     CLOSE c_invoice_format;

   -- populating the payment method
      OPEN c_payment_mthd(l_taa_record.payment_mthd_id);
      FETCH c_payment_mthd INTO l_pay_mthd_id,l_pay_mthd;
      CLOSE c_payment_mthd;

   -- populating the new contract number
      OPEN c_new_ctr_no(p_request_id) ;
      FETCH c_new_ctr_no INTO l_ctr_no;
      CLOSE c_new_ctr_no;

   -- populating the master lease agreement
      OPEN c_mla_no(l_taa_record.mla_id);
      FETCH c_mla_no INTO l_mla_id,l_master_lease;
      CLOSE c_mla_no;

    -- populating the credit line number
      OPEN c_mla_no(l_taa_record.credit_line_id);
      FETCH c_mla_no INTO l_crd_id,l_credit_line;
      CLOSE c_mla_no;

   --Fetching the contact details for the new lessee



      OPEN c_contact(l_taa_record.cust_acct_id,l_request_record.party_rel_id1_new);
      FETCH c_contact INTO  l_contact_party_id,l_contact_name,l_contact_email;
      CLOSE c_contact;



      OPEN c_phone(l_contact_party_id);
      FETCH c_phone INTO l_phone;
      CLOSE c_phone;


      --Populating the output variables
     x_new_lessee_tbl(1).taa_id                := l_taa_record.id;
     x_new_lessee_tbl(1).new_contract_number   := l_taa_record.new_contract_number;
     x_new_lessee_tbl(1).new_lessee            := l_lessee_name;
     x_new_lessee_tbl(1).new_party_id          := l_party_id;
     x_new_lessee_tbl(1).contact_name          := l_contact_name ;
     x_new_lessee_tbl(1).contact_id            := l_contact_party_id;
     x_new_lessee_tbl(1).contact_email         := l_contact_email;
     x_new_lessee_tbl(1).contact_phone         := l_phone;
     x_new_lessee_tbl(1).bill_to_address       := l_billto_address;
     x_new_lessee_tbl(1).bill_to_id            := l_billto_id;
     x_new_lessee_tbl(1).cust_acct_number      := l_acct_no;
     x_new_lessee_tbl(1).cust_acct_id          := l_acct_id;
     x_new_lessee_tbl(1).bank_account          := l_bank;
     x_new_lessee_tbl(1).bank_acct_id          := l_bank_acct_id;
     x_new_lessee_tbl(1).invoice_format        := l_inv_fmt;
     x_new_lessee_tbl(1).inv_fmt_id            := l_inv_fmt_id;
     x_new_lessee_tbl(1).payment_method        := l_pay_mthd;
     x_new_lessee_tbl(1).pay_mthd_id           := l_pay_mthd_id;
     x_new_lessee_tbl(1).master_lease          := l_master_lease;
     x_new_lessee_tbl(1).mla_id                := l_mla_id;
     x_new_lessee_tbl(1).credit_line_no        := l_credit_line;
     x_new_lessee_tbl(1).credit_line_id        := l_crd_id;
     x_new_lessee_tbl(1).insurance_yn          := l_taa_record.insurance_yn;
     x_new_lessee_tbl(1).lease_policy_yn       := l_taa_record.lease_policy_yn;

     x_return_status := l_return_status;

   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PROCESS_TAX.Create_Tax_Schedule ','End(-)');
  END IF;

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
  END Populate_new_Lessee_details;

  PROCEDURE Populate_ThirdParty_Insurance( p_api_version                    IN  NUMBER,
                                         p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                         p_taa_id                         IN  NUMBER,
                                         x_insurance_tbl                  OUT NOCOPY insurance_tbl_type,
                                         x_return_status                  OUT NOCOPY VARCHAR2,
                                         x_msg_count                      OUT NOCOPY NUMBER,
                                         x_msg_data                       OUT NOCOPY VARCHAR2)
  IS
   --Obtain the insuance details  of the taa request.
  -- changed tcn_id to id for bug:4094898
    CURSOR c_taa_record(p_taa_id IN NUMBER) IS
    SELECT *
    FROM okl_taa_request_details_v
    WHERE id = p_taa_id;

    --Obtain the insurer/insurance_agent name
    CURSOR c_lessee(p_party_id IN NUMBER) IS
    SELECT  PARTY_NAME
    FROM    HZ_PARTIES PARTY
    WHERE  PARTY_ID = p_party_id;


    l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name            CONSTANT VARCHAR2(30) := 'Populate_Insurance_Details';
    l_api_version         CONSTANT NUMBER := 1;

    l_insurer             VARCHAR2(360);
    l_insurance_agent     VARCHAR2(360);
    l_taa_record          OKL_TAA_REQUEST_DETAILS_B%rowtype;

  BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_New_Lessee_details','Begin(+)');
   END IF;
 --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_Insurance_Details',
              'p_api_version :'||p_api_version);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_Insurance_Details',
              'p_init_msg_list :'||p_init_msg_list);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_Insurance_Details',
              'p_taa_id :'||p_taa_id);
   END IF;

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);

   --Fetch the insuance details tied to the ta request

    OPEN c_taa_record(p_taa_id);
    FETCH c_taa_record INTO l_taa_record;
    CLOSE c_taa_record;

    --Fetch the Insurer Name
     OPEN c_lessee(l_taa_record.isu_id);
     FETCH c_lessee INTO l_insurer;
     CLOSE c_lessee;

      --Fetch the Insurer Agent name
     OPEN c_lessee(l_taa_record.int_id);
     FETCH c_lessee INTO l_insurance_agent;
     CLOSE c_lessee;

      x_insurance_tbl(1).insurer                := l_insurer;
      x_insurance_tbl(1).insurance_agent        := l_insurance_agent;
      x_insurance_tbl(1).policy_number          := l_taa_record.policy_number;
      x_insurance_tbl(1).covered_amount         := l_taa_record.covered_amt;
      x_insurance_tbl(1).deductible_amount      := l_taa_record.deductible_amt;
      x_insurance_tbl(1).effective_from         := l_taa_record.effective_from_date;
      x_insurance_tbl(1).effective_to           := l_taa_record.effective_to_date;
      x_insurance_tbl(1).proof_provided         := l_taa_record.proof_provided_date;
      x_insurance_tbl(1).proof_required         := l_taa_record.proof_required_date;
      x_insurance_tbl(1).lessor_insured_yn      := l_taa_record.lessor_insured_yn;
      x_insurance_tbl(1).lessor_payee_yn        := l_taa_record.lessor_payee_yn;

   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_TRANSFER_ASSUMPTION_PVT.populate_thirdparty_insurance','End(-)');
  END IF;

 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
  END Populate_thirdparty_insurance;



END OKL_CS_TRANSFER_ASSUMPTION_PVT;



/
