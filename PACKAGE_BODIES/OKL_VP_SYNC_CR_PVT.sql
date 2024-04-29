--------------------------------------------------------
--  DDL for Package Body OKL_VP_SYNC_CR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_SYNC_CR_PVT" AS
/* $Header: OKLRCRSB.pls 120.15 2006/09/26 11:24:46 varangan noship $ */

  -- Global Message Constants
  G_INVALID_STS_APPROVED CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INVAL_STS_APPROVED'; -- token CHANGE_REQ_NUM

  -- Global lookup_code constants
  G_PENDING_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PENDING_APPROVAL';
  G_APPROVED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'APPROVED';
  G_ARGREEMENT_TYPE_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'AGREEMENT';
  G_ASSOCIATE_TYPE_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ASSOCIATION';
  G_PROGRAM_SCS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PROGRAM';
  G_OPERATING_SCS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'OPERATING';
  G_VENDOR_PROGRAM_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'VENDOR_PROGRAM';
  G_ABANDONED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ABANDONED';
  G_COMPLETED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'COMPLETED';

  SUBTYPE khrv_rec_type IS okl_contract_pub.khrv_rec_type;
  SUBTYPE chrv_rec_type IS okl_okc_migration_pvt.chrv_rec_type;
  SUBTYPE cplv_rec_type IS okl_okc_migration_pvt.cplv_rec_type;
  SUBTYPE catv_rec_type IS okl_okc_migration_a_pvt.catv_rec_type;
  SUBTYPE ctcv_tbl_type IS okl_okc_migration_pvt.ctcv_tbl_type;
  SUBTYPE vasv_rec_type IS okl_vas_pvt.vasv_rec_type;
  SUBTYPE ech_rec_type IS okl_ech_pvt.okl_ech_rec;
  SUBTYPE ecl_tbl_type IS okl_ecl_pvt.okl_ecl_tbl;
  SUBTYPE ecv_tbl_type IS okl_ecv_pvt.okl_ecv_tbl;


  PROCEDURE sync_change_request(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_change_request_id IN okl_vp_change_requests.id%TYPE) IS
    -- cursor that determines the change request and associated agreement details
    -- for an AGREEMENT type of change request, the newly created agreement id is returned
    -- and for ASSOCIATION type of change request, the original agreement id is returned.
    CURSOR c_get_cr_details_csr (cp_change_request_id okl_vp_change_requests.id%TYPE)IS
    SELECT creq.change_type_code
          ,creq.status_code
          ,change_request_number
          ,creq.chr_id orig_agr_chr_id
          ,chr.scs_code agreement_category
      FROM okl_vp_change_requests creq
          ,okc_k_headers_b chr
     WHERE creq.id  = cp_change_request_id
       AND creq.chr_id = chr.id;

    -- cursor to find out the agreement id that was created for the change request. this agreement id
    -- is not the parent agreement id, but the one that was created using the copy api
    CURSOR c_get_creq_chr_id (cp_change_request_id okl_vp_change_requests.id%TYPE)IS
    SELECT id
      FROM okl_k_headers
     WHERE crs_id = cp_change_request_id;

    cv_get_cr_details c_get_cr_details_csr%ROWTYPE;
    lv_vcrv_rec okl_vcr_pvt.vcrv_rec_type;
    x_vcrv_rec okl_vcr_pvt.vcrv_rec_type;

    lv_creq_chr_id okc_k_headers_b.id%TYPE;
    lv_orig_chr_id okc_k_headers_b.id%TYPE;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_CHANGE_REQUEST';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_CHANGE_REQUEST';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_change_request');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name       => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- fetch the change request information
    OPEN c_get_cr_details_csr(p_change_request_id); FETCH c_get_cr_details_csr INTO cv_get_cr_details;
    CLOSE c_get_cr_details_csr;

    -- if the change request is not in Pending Approval status, error out
    IF(cv_get_cr_details.status_code NOT IN (G_PENDING_STS_CODE, G_APPROVED_STS_CODE))THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_STS_APPROVED, 'CHANGE_REQ_NUM',cv_get_cr_details.change_request_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- store the value of the original agreement id here. this would be useful in calling the sync procedures
    lv_orig_chr_id := cv_get_cr_details.orig_agr_chr_id;
    -- now fork based on change request type
    IF(G_ARGREEMENT_TYPE_CODE = cv_get_cr_details.change_type_code)THEN
      -- get the agreement associated with the change request. this is achieved by getting the id from okl_k_headers
      -- that has the supplied change request in the crs_id column, this cursor results in a full table scan of okl_k_headers
      -- the agreement associated with the change request is the agreement that was created from the parent agreement by calling the copy api
      OPEN c_get_creq_chr_id (p_change_request_id); FETCH c_get_creq_chr_id INTO lv_creq_chr_id;
      CLOSE c_get_creq_chr_id;

      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT, l_module, 'p_orig_chr_id '|| lv_orig_chr_id||' p_creq_chr_id '||lv_creq_chr_id);
      END IF;

      -- there are some steps common between AGREEMENT and PROGRAM, perform them first
      IF(G_OPERATING_SCS_CODE = cv_get_cr_details.agreement_category OR G_PROGRAM_SCS_CODE = cv_get_cr_details.agreement_category)THEN

        -- 1. synchronize header changes
        sync_agr_header(p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_return_status => x_return_status
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_orig_chr_id   => lv_orig_chr_id
                       ,p_creq_chr_id   => lv_creq_chr_id
                       );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_agr_header returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- 2. synchronize non primary parties
        sync_non_primary_parties(p_api_version   => p_api_version
                                ,p_init_msg_list => p_init_msg_list
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,p_orig_chr_id   => lv_orig_chr_id
                                ,p_creq_chr_id   => lv_creq_chr_id
                                );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_non_primary_parties returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- 3. synchronize contacts for all parties
        sync_party_contacts(p_api_version   => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_orig_chr_id   => lv_orig_chr_id
                           ,p_creq_chr_id   => lv_creq_chr_id
                           );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_party_contacts returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- 4. synchronize changes to articles
        sync_article_changes(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_orig_chr_id   => lv_orig_chr_id
                            ,p_creq_chr_id   => lv_creq_chr_id
                            );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_article_changes returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- 5. synchronize changes to the Vendor Billing Information
        sync_vendor_billing(p_api_version   => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_orig_chr_id   => lv_orig_chr_id
                           ,p_creq_chr_id   => lv_creq_chr_id
                            );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_vendor_billing returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF; -- end of G_OPERATING_SCS_CODE = cv_get_cr_details.agreement_category OR G_PROGRAM_SCS_CODE = cv_get_cr_details.agreement_category

      IF(G_PROGRAM_SCS_CODE = cv_get_cr_details.agreement_category)THEN
        -- these are PROGRAM specific changes only
        -- 1. synchronize changes to associations
        sync_agr_associations(p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_orig_chr_id   => lv_orig_chr_id
                             ,p_creq_chr_id   => lv_creq_chr_id
                             ,p_change_request_id => p_change_request_id
                             );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_agr_associations returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- 2. synchronize changes to eligibility criteria
        sync_elig_criteria(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orig_chr_id   => lv_orig_chr_id
                          ,p_creq_chr_id   => lv_creq_chr_id
                          );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_elig_criteria returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        -- 3. synchronize changes terms and conditions
        sync_terms(p_api_version   => p_api_version
                  ,p_init_msg_list => p_init_msg_list
                  ,x_return_status => x_return_status
                  ,x_msg_count     => x_msg_count
                  ,x_msg_data      => x_msg_data
                  ,p_orig_chr_id   => lv_orig_chr_id
                  ,p_creq_chr_id   => lv_creq_chr_id
                  );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_terms returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        -- 4. synchronize changes to the disbursement setup
        sync_vendor_disb_setup(p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_orig_chr_id   => lv_orig_chr_id
                              ,p_creq_chr_id   => lv_creq_chr_id
                              );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'sync_vendor_disb_setup returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF; -- end of G_PROGRAM_SCS_CODE = cv_get_cr_details_csr.agreement_category
      -- now that synchronization has happened, the agreement status has to be updated to ABANDONED
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => G_ABANDONED_STS_CODE
                                                    ,p_chr_id        => lv_creq_chr_id
                                                     );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_status_pub.update_contract_status G_ABANDONED_STS_CODE returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF(G_ASSOCIATE_TYPE_CODE = cv_get_cr_details.change_type_code)THEN
      -- 1. synchronize changes to the associations
       sync_associations(p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_orig_chr_id   => lv_orig_chr_id
                        ,p_creq_chr_id   => lv_orig_chr_id -- for ASSOCIATION type of change request, there is no additional agreement created
                        ,p_change_request_id => p_change_request_id
                        );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'sync_associations for ASSOCIATION returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of G_ARGREEMENT_TYPE_CODE = cv_get_cr_details_csr.change_type_code

    -- set the status of the change request to COMPLETED
    lv_vcrv_rec.id := p_change_request_id;
    lv_vcrv_rec.status_code := G_COMPLETED_STS_CODE;
    -- we should also record the applied date, the date on which the sync happens on the change request
    lv_vcrv_rec.applied_date := TRUNC(SYSDATE);
    okl_vp_change_request_pvt.update_change_request_header(p_api_version   => p_api_version
                                                          ,p_init_msg_list => p_init_msg_list
                                                          ,x_return_status => x_return_status
                                                          ,x_msg_count     => x_msg_count
                                                          ,x_msg_data      => x_msg_data
                                                          ,p_vcrv_rec      => lv_vcrv_rec
                                                          ,x_vcrv_rec      => x_vcrv_rec
                                                           );
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vp_change_request_pvt.update_change_request_header returned with status '||x_return_status
                              );
    END IF;

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_change_request');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_change_request;

  PROCEDURE sync_agr_header(p_api_version   IN  NUMBER
                           ,p_init_msg_list IN  VARCHAR2
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg_count     OUT NOCOPY NUMBER
                           ,x_msg_data      OUT NOCOPY VARCHAR2
                           ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                           ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                           ) IS
    CURSOR c_hdr_attribs_csr(cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT chr.short_description
          ,chr.comments
          ,chr.description
          ,chr.end_date
          ,chr.start_date
          ,chr.qcl_id
          ,chr.contract_number
          ,chr.scs_code
          ,chr.template_yn
          ,gov.chr_id_referred
          ,khr.attribute_category
          ,khr.attribute1
          ,khr.attribute2
          ,khr.attribute3
          ,khr.attribute4
          ,khr.attribute5
          ,khr.attribute6
          ,khr.attribute7
          ,khr.attribute8
          ,khr.attribute9
          ,khr.attribute10
          ,khr.attribute11
          ,khr.attribute12
          ,khr.attribute13
          ,khr.attribute14
          ,khr.attribute15
      FROM okc_k_headers_v chr
          ,okc_governances gov
          ,okl_k_headers khr
     WHERE chr.id = cp_chr_id
       AND chr.id = khr.id
       AND gov.dnz_chr_id(+) = chr.id;
    cv_hdr_attribs_orig c_hdr_attribs_csr%ROWTYPE;
    cv_hdr_attribs_new c_hdr_attribs_csr%ROWTYPE;

    l_agr_hdr_rec okl_vendor_program_pvt.program_header_rec_type;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_AGR_HEADER';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_AGR_HEADER';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_agr_header');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the old and new values into the cursor variables
    OPEN c_hdr_attribs_csr(p_orig_chr_id); FETCH c_hdr_attribs_csr INTO cv_hdr_attribs_orig;
    CLOSE c_hdr_attribs_csr;

    OPEN c_hdr_attribs_csr(p_creq_chr_id); FETCH c_hdr_attribs_csr INTO cv_hdr_attribs_new;
    CLOSE c_hdr_attribs_csr;

    -- now compare the attributes, and if there are any differences only then call the API.
    -- the comparision would save a costly DML call
    IF(
       (NVL(cv_hdr_attribs_orig.short_description, OKL_API.G_MISS_CHAR) <> NVL(cv_hdr_attribs_new.short_description, OKL_API.G_MISS_CHAR))
       OR (NVL(cv_hdr_attribs_orig.comments, OKL_API.G_MISS_CHAR) <> NVL(cv_hdr_attribs_new.comments, OKL_API.G_MISS_CHAR))
       OR (NVL(cv_hdr_attribs_orig.description, OKL_API.G_MISS_CHAR) <> NVL(cv_hdr_attribs_new.description, OKL_API.G_MISS_CHAR))
       OR (NVL(cv_hdr_attribs_orig.end_date, OKL_API.G_MISS_DATE) <> NVL(cv_hdr_attribs_new.end_date, OKL_API.G_MISS_DATE))
       OR (NVL(cv_hdr_attribs_orig.chr_id_referred, OKL_API.G_MISS_NUM) <> NVL(cv_hdr_attribs_new.chr_id_referred, OKL_API.G_MISS_NUM))
       )THEN

      l_agr_hdr_rec.p_agreement_number := cv_hdr_attribs_orig.contract_number;
      l_agr_hdr_rec.p_contract_category := cv_hdr_attribs_orig.scs_code;
      l_agr_hdr_rec.p_start_date := cv_hdr_attribs_orig.start_date;
      l_agr_hdr_rec.p_end_date := TRUNC(cv_hdr_attribs_new.end_date);
      l_agr_hdr_rec.p_short_description := cv_hdr_attribs_new.short_description;
      l_agr_hdr_rec.p_description := cv_hdr_attribs_new.description;
      l_agr_hdr_rec.p_comments := cv_hdr_attribs_new.comments;
      l_agr_hdr_rec.p_template_yn := cv_hdr_attribs_orig.template_yn;
      l_agr_hdr_rec.p_qcl_id := cv_hdr_attribs_orig.qcl_id;
      l_agr_hdr_rec.p_referred_id := NULL; -- guess this is not being used anymore

      -- added to enable sync dff from the change request to the pa. START
      -- since dff is not on the primary list of fields that could be modified, the dff sync up will only
      -- happen if one of the primary fields are modified. viz. short_desription, comments, description, end_date and/or chr_id_referred
      l_agr_hdr_rec.p_attribute_category := cv_hdr_attribs_new.attribute_category;
      l_agr_hdr_rec.p_attribute1 := cv_hdr_attribs_new.attribute1;
      l_agr_hdr_rec.p_attribute2 := cv_hdr_attribs_new.attribute2;
      l_agr_hdr_rec.p_attribute3 := cv_hdr_attribs_new.attribute3;
      l_agr_hdr_rec.p_attribute4 := cv_hdr_attribs_new.attribute4;
      l_agr_hdr_rec.p_attribute5 := cv_hdr_attribs_new.attribute5;
      l_agr_hdr_rec.p_attribute6 := cv_hdr_attribs_new.attribute6;
      l_agr_hdr_rec.p_attribute7 := cv_hdr_attribs_new.attribute7;
      l_agr_hdr_rec.p_attribute8 := cv_hdr_attribs_new.attribute8;
      l_agr_hdr_rec.p_attribute9 := cv_hdr_attribs_new.attribute9;
      l_agr_hdr_rec.p_attribute10 := cv_hdr_attribs_new.attribute10;
      l_agr_hdr_rec.p_attribute11 := cv_hdr_attribs_new.attribute11;
      l_agr_hdr_rec.p_attribute12 := cv_hdr_attribs_new.attribute12;
      l_agr_hdr_rec.p_attribute13 := cv_hdr_attribs_new.attribute13;
      l_agr_hdr_rec.p_attribute14 := cv_hdr_attribs_new.attribute14;
      l_agr_hdr_rec.p_attribute15 := cv_hdr_attribs_new.attribute15;
      -- added to enable sync dff from the change request to the pa. END

      okl_vendor_program_pvt.update_program(p_api_version        => p_api_version
                                           ,p_init_msg_list      => p_init_msg_list
                                           ,x_return_status      => x_return_status
                                           ,x_msg_count          => x_msg_count
                                           ,x_msg_data           => x_msg_data
                                           ,p_hdr_rec            => l_agr_hdr_rec
                                           ,p_program_id         => p_orig_chr_id
                                           ,p_parent_agreement_id => cv_hdr_attribs_new.chr_id_referred
                                           );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vendor_program_pvt.update_program returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF;

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of difference check


    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_agr_header');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_agr_header;

  PROCEDURE sync_non_primary_parties(p_api_version   IN  NUMBER
                                    ,p_init_msg_list IN  VARCHAR2
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    ,x_msg_count     OUT NOCOPY NUMBER
                                    ,x_msg_data      OUT NOCOPY VARCHAR2
                                    ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                    ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                    ) IS
    -- cursor that finds new non primary parties on the change request
    CURSOR new_parties_csr(cp_creq_chr_id okc_k_headers_b.id%TYPE
                           ,cp_orig_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT cpl.id,
           cpl.object1_id1,
           cpl.object1_id2,
           cpl.jtot_object1_code,
           cpl.rle_code
      FROM okc_k_party_roles_b cpl
     WHERE cpl.chr_id = cp_creq_chr_id
       AND cpl.jtot_object1_code = 'OKX_PARTY'
       AND NOT EXISTS (
           SELECT 'Y'
             FROM okc_k_party_roles_b orig
            WHERE orig.object1_id1 = cpl.object1_id1
              AND orig.object1_id2 = cpl.object1_id2
              AND orig.jtot_object1_code = cpl.jtot_object1_code
              AND orig.rle_code = cpl.rle_code
              AND orig.chr_id = cp_orig_chr_id
              AND orig.jtot_object1_code = 'OKX_PARTY'
          );
    CURSOR c_get_parties_csr(cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT id
          ,chr_id
          ,rle_code
          ,dnz_chr_id
          ,object1_id1
          ,object1_id2
          ,jtot_object1_code
          ,cognomen party_known_as
          ,alias
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
     FROM okc_k_party_roles_v
    WHERE dnz_chr_id = cp_chr_id
      AND jtot_object1_code = 'OKX_PARTY'; -- this indicates non primary parties

    CURSOR c_get_party_info_csr(cp_chr_id okc_k_headers_b.id%TYPE
                                ,cp_party_id hz_parties.party_id%TYPE) IS
    SELECT cpl.id
          ,cpl.chr_id
          ,cpl.rle_code
          ,cpl.dnz_chr_id
          ,cpl.object1_id1
          ,cpl.object1_id2
          ,cpl.jtot_object1_code
          ,cpl.cognomen party_known_as
          ,cpl.alias
/*
          ,kpl.attribute_category
          ,kpl.attribute1
          ,kpl.attribute2
          ,kpl.attribute3
          ,kpl.attribute4
          ,kpl.attribute5
          ,kpl.attribute6
          ,kpl.attribute7
          ,kpl.attribute8
          ,kpl.attribute9
          ,kpl.attribute10
          ,kpl.attribute11
          ,kpl.attribute12
          ,kpl.attribute13
          ,kpl.attribute14
          ,kpl.attribute15
*/
     FROM okc_k_party_roles_v cpl
/*         ,okl_k_party_roles_v kpl */
    WHERE cpl.dnz_chr_id = cp_chr_id
      AND cpl.object1_id1 = cp_party_id
      AND cpl.jtot_object1_code = 'OKX_PARTY'; -- this indicates non primary parties
/*      AND cpl.id = kpl.id;*/

    cv_get_party_info_rec c_get_party_info_csr%ROWTYPE;

    CURSOR c_get_role_contacts_csr(cp_cpl_id okc_k_party_roles_b.id%TYPE)IS
    SELECT id
      FROM okc_contacts
     WHERE cpl_id = cp_cpl_id;

    lv_cplv_rec cplv_rec_type;
    x_cplv_rec cplv_rec_type;
    lv_ctcv_tbl ctcv_tbl_type;
    contact_tbl_idx PLS_INTEGER;

    x_cpl_id okc_k_party_roles_b.cpl_id%TYPE;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_NON_PRIMARY_PARTIES';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_NON_PRIMARY_PARTIES';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_non_primary_parties');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- find any changes that have happened on the non primary parties on the agreement
    -- this includes deletion of non primary parties on the change request. these non primary parties have to be
    -- deleted from the originating agreement also

    -- first get the original party role record
    FOR parties_rec IN c_get_parties_csr(p_orig_chr_id) LOOP
      lv_cplv_rec := NULL;
      x_cplv_rec := NULL;
      -- since the object1_id1 is the same for the change request and the original pa, get the change request record from these values
      OPEN c_get_party_info_csr(p_creq_chr_id, parties_rec.object1_id1); FETCH c_get_party_info_csr INTO cv_get_party_info_rec;
      IF(c_get_party_info_csr%FOUND)THEN
        CLOSE c_get_party_info_csr;
        -- compare if the values of known as or alias have changed on the new change request from the agreement.
        -- call the update api only if there are changes to these two fields
        IF(
           (NVL(cv_get_party_info_rec.party_known_as, OKL_API.G_MISS_CHAR) <> NVL(parties_rec.party_known_as,OKL_API.G_MISS_CHAR))
           OR (NVL(cv_get_party_info_rec.alias, OKL_API.G_MISS_CHAR) <> NVL(parties_rec.alias, OKL_API.G_MISS_CHAR))
          )THEN
          lv_cplv_rec.id := parties_rec.id;
          lv_cplv_rec.chr_id := parties_rec.chr_id;
          lv_cplv_rec.rle_code := parties_rec.rle_code;
          lv_cplv_rec.dnz_chr_id := parties_rec.dnz_chr_id;
          lv_cplv_rec.object1_id1 := parties_rec.object1_id1;
          lv_cplv_rec.object1_id2 := parties_rec.object1_id2;
          lv_cplv_rec.jtot_object1_code := parties_rec.jtot_object1_code;
          lv_cplv_rec.cognomen := cv_get_party_info_rec.party_known_as;
          lv_cplv_rec.alias := cv_get_party_info_rec.alias;
/*
          -- party role dff added for dff implementation for party role. the flex field segment values are synchronized only when
          -- the significant fields on the party are changed. just changing the dff values would not sync on the change request
          lv_cplv_rec.attribute_category := cv_get_party_info_rec.attribute_category;
          lv_cplv_rec.attribute1 := cv_get_party_info_rec.attribute1;
          lv_cplv_rec.attribute2 := cv_get_party_info_rec.attribute2;
          lv_cplv_rec.attribute3:= cv_get_party_info_rec.attribute3;
          lv_cplv_rec.attribute4 := cv_get_party_info_rec.attribute4;
          lv_cplv_rec.attribute5 := cv_get_party_info_rec.attribute5;
          lv_cplv_rec.attribute6 := cv_get_party_info_rec.attribute6;
          lv_cplv_rec.attribute7 := cv_get_party_info_rec.attribute7;
          lv_cplv_rec.attribute8 := cv_get_party_info_rec.attribute8;
          lv_cplv_rec.attribute9 := cv_get_party_info_rec.attribute9;
          lv_cplv_rec.attribute10 := cv_get_party_info_rec.attribute10;
          lv_cplv_rec.attribute11 := cv_get_party_info_rec.attribute11;
          lv_cplv_rec.attribute12 := cv_get_party_info_rec.attribute12;
          lv_cplv_rec.attribute13 := cv_get_party_info_rec.attribute13;
          lv_cplv_rec.attribute14 := cv_get_party_info_rec.attribute14;
          lv_cplv_rec.attribute15 := cv_get_party_info_rec.attribute15;
*/
          lv_cplv_rec.created_by := parties_rec.created_by;
          lv_cplv_rec.creation_date := parties_rec.creation_date;
          lv_cplv_rec.last_updated_by := parties_rec.last_updated_by;
          lv_cplv_rec.last_update_date := parties_rec.last_update_date;
          lv_cplv_rec.last_update_login := parties_rec.last_update_login;

          okl_contract_party_pub.update_k_party_role(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_cplv_rec      => lv_cplv_rec
                                                    ,x_cplv_rec      => x_cplv_rec
                                                    );
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_contract_party_pub.update_k_party_role returned with status '||x_return_status
                                    );
          END IF;
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- end of comparision
      ELSE -- cursor not found case
        -- this is the case of the party record is not on the change request. this implies that the non primary party has been
        -- deleted. call the delete_k_party_role api on the original agreement. But before that make sure that the party role does not have
        -- any contacts. First delete the children and then delete the parent
        CLOSE c_get_party_info_csr;
        contact_tbl_idx := 0;
        FOR party_contacts_rec IN c_get_role_contacts_csr(parties_rec.id) LOOP
          contact_tbl_idx := contact_tbl_idx + 1;
          lv_ctcv_tbl(contact_tbl_idx).id := party_contacts_rec.id;
        END LOOP;
        IF(contact_tbl_idx > 0)THEN
          okl_contract_party_pub.delete_contact(p_api_version   => p_api_version
                                               ,p_init_msg_list => p_init_msg_list
                                               ,x_return_status => x_return_status
                                               ,x_msg_count     => x_msg_count
                                               ,x_msg_data      => x_msg_data
                                               ,p_ctcv_tbl      => lv_ctcv_tbl
                                               );
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_contract_party_pub.delete_contact returned with status '||x_return_status||' contact_tbl_idx '||contact_tbl_idx
                                    );
          END IF;
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        -- now its safe to delete the parent
        lv_cplv_rec.id := parties_rec.id;
        okl_contract_party_pub.delete_k_party_role(p_api_version   => p_api_version
                                                  ,p_init_msg_list => p_init_msg_list
                                                  ,x_return_status => x_return_status
                                                  ,x_msg_count     => x_msg_count
                                                  ,x_msg_data      => x_msg_data
                                                  ,p_cplv_rec      => lv_cplv_rec
                                                  );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_contract_party_pub.delete_k_party_role returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of cursor found case
    END LOOP;

    -- synchronize all the non primary parties that have been created on the change request
    -- cannot rely on primary_yn of okc_k_party_roles_b as this value is null always
    FOR new_parties_rec IN new_parties_csr(p_creq_chr_id, p_orig_chr_id) LOOP
      okl_copy_contract_pub.copy_party_roles(p_api_version   => 1.0
                                            ,p_init_msg_list => OKL_API.G_FALSE
                                            ,x_return_status => x_return_status
                                            ,x_msg_count     => x_msg_count
                                            ,x_msg_data      => x_msg_data
                                            ,p_cpl_id        => new_parties_rec.id
                                            ,p_cle_id        => NULL
                                            ,p_chr_id        => p_orig_chr_id
                                            ,p_rle_code      => new_parties_rec.rle_code
                                            ,x_cpl_id        => x_cpl_id
                                             );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_copy_contract_pub.copy_party_roles returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_non_primary_parties');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_non_primary_parties;

  PROCEDURE sync_party_contacts(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                               ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                               ) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_PARTY_CONTACTS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_PARTY_CONTACTS';
    l_debug_enabled VARCHAR2(10);

    CURSOR c_get_diff_contact_csr(cp_chr_id_1 okc_k_headers_b.id%TYPE
                            ,cp_chr_id_2 okc_k_headers_b.id%TYPE)IS
    SELECT role.object1_id1 role_party_id
          ,role.object1_id2 role_object1_id2
          ,role.rle_code
          ,role.jtot_object1_code role_object
          ,role.dnz_chr_id
          ,contact.object1_id1 contact_party_id
          ,contact.object1_id2 contact_object1_id2
          ,contact.cro_code
          ,contact.jtot_object1_code contact_object
          ,contact.id
      FROM okc_k_party_roles_b role
          ,okc_contacts contact
     WHERE role.id = contact.cpl_id
       AND role.dnz_chr_id = contact.dnz_chr_id
       AND role.dnz_chr_id = cp_chr_id_1
       AND NOT EXISTS(SELECT 'X'
                        FROM okc_k_party_roles_b role_new
                            ,okc_contacts contact_new
                       WHERE role_new.id = contact_new.cpl_id
                         AND role_new.chr_id = contact_new.dnz_chr_id
                         AND role_new.object1_id1 = role.object1_id1
                         AND role_new.object1_id2 = role.object1_id2
                         AND role_new.jtot_object1_code = role.jtot_object1_code
                         AND role_new.rle_code = role.rle_code
                         AND contact_new.object1_id1 = contact.object1_id1
                         AND contact_new.object1_id2 = contact.object1_id2
                         AND contact_new.cro_code = contact.cro_code
                         AND contact_new.jtot_object1_code = contact.jtot_object1_code
                         AND role_new.chr_id = cp_chr_id_2
                        );
    CURSOR c_get_cpl_csr(cp_dnz_chr_id okc_k_headers_b.id%TYPE
                        ,cp_rle_code okc_k_party_roles_b.rle_code%TYPE
                        ,cp_object1_id1 okc_k_party_roles_b.object1_id1%TYPE
                        ,cp_object1_id2 okc_k_party_roles_b.object1_id2%TYPE
                        ,cp_jtot_object1_code okc_k_party_roles_b.jtot_object1_code%TYPE
                        ) IS
    SELECT id
      FROM okc_k_party_roles_b
     WHERE dnz_chr_id = cp_dnz_chr_id
       AND rle_code = cp_rle_code
       AND object1_id1 = cp_object1_id1
       AND object1_id2 = cp_object1_id2
       AND jtot_object1_code = cp_jtot_object1_code;

    lv_ctcv_tbl ctcv_tbl_type;
     x_ctcv_tbl ctcv_tbl_type;
    contact_tbl_idx PLS_INTEGER;
    lv_cpl_id okc_k_party_roles_b.id%TYPE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_party_contacts');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* Logic for synchronization: All the Contacts at the Role level present on the Original Agreement and not present on the
     * Change Request Agreement are to be deleted. All the Contacts present on the Change Request Agreement and not on the
     * Original Agreement are to be added to the Original Contact for that role. Since the Party Roles have already been
     * merged in the previous step, there would not be a case where a party on the change request is not found on the original
     * agreement.
     *
     * Technically the same cursor is being used to find the diff between the Contacts by interchanging the values of the
     * agreement ids
     */
    contact_tbl_idx := 0;
    FOR old_contacts_orig_rec IN c_get_diff_contact_csr(p_orig_chr_id, p_creq_chr_id) LOOP
      -- these records are to be deleted from the original contract as they are missing on the change request counter part
      contact_tbl_idx := contact_tbl_idx + 1;
      lv_ctcv_tbl(contact_tbl_idx).id := old_contacts_orig_rec.id;
    END LOOP;

    IF(contact_tbl_idx > 0)THEN
      okl_contract_party_pub.delete_contact(p_api_version   => p_api_version
                                           ,p_init_msg_list => p_init_msg_list
                                           ,x_return_status => x_return_status
                                           ,x_msg_count     => x_msg_count
                                           ,x_msg_data      => x_msg_data
                                           ,p_ctcv_tbl      => lv_ctcv_tbl
                                           );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_party_pub.delete_contact returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    contact_tbl_idx := 0;
    -- finding new contacts that are present on the change request and not on the original agreement
    FOR new_contacts_rec IN c_get_diff_contact_csr(p_creq_chr_id, p_orig_chr_id) LOOP
      contact_tbl_idx := contact_tbl_idx + 1;
      -- note the change in the reversal of the cursor parameters
      -- these records are to be added onto the original agreement under the same role
      OPEN c_get_cpl_csr(p_orig_chr_id
                        ,new_contacts_rec.rle_code
                        ,new_contacts_rec.role_party_id
                        ,new_contacts_rec.role_object1_id2
                        ,new_contacts_rec.role_object); FETCH c_get_cpl_csr INTO lv_cpl_id;
      CLOSE c_get_cpl_csr;
      lv_ctcv_tbl(contact_tbl_idx).cpl_id := lv_cpl_id;
      lv_ctcv_tbl(contact_tbl_idx).dnz_chr_id := p_orig_chr_id;
      lv_ctcv_tbl(contact_tbl_idx).object1_id1 := new_contacts_rec.contact_party_id;
      lv_ctcv_tbl(contact_tbl_idx).object1_id2 := new_contacts_rec.contact_object1_id2;
      lv_ctcv_tbl(contact_tbl_idx).cro_code := new_contacts_rec.cro_code;
      lv_ctcv_tbl(contact_tbl_idx).jtot_object1_code := new_contacts_rec.contact_object;
    END LOOP;
    IF(contact_tbl_idx > 0)THEN
      okl_contract_party_pub.create_contact(p_api_version   => p_api_version
                                           ,p_init_msg_list => p_init_msg_list
                                           ,x_return_status => x_return_status
                                           ,x_msg_count     => x_msg_count
                                           ,x_msg_data      => x_msg_data
                                           ,p_ctcv_tbl      => lv_ctcv_tbl
                                           ,x_ctcv_tbl      => x_ctcv_tbl
                                           );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_party_pub.create_contact returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_party_contacts');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_party_contacts;

  PROCEDURE sync_article_changes(p_api_version   IN  NUMBER
                                ,p_init_msg_list IN  VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2
                                ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                ) IS
    -- cursor that fetches the new articles on the agreement (original or change request)
    CURSOR c_get_articles_csr (cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT change_req.id
          ,change_req.chr_id
          ,change_req.sav_sae_id
          ,change_req.sav_sav_release
          ,change_req.sbt_code
          ,change_req.name
          ,change_req.cat_type
          ,change_req.text
     FROM okc_k_articles_v change_req
     where change_req.dnz_chr_id = cp_chr_id       -- updated the code
     and change_req.chr_id=change_req.dnz_chr_id ; -- for performance issue bug#5484903
--    WHERE change_req.chr_id = cp_chr_id;         --commented out the old filter condition

    lv_catv_rec catv_rec_type;
    x_catv_rec catv_rec_type;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_ARTICLE_CHANGES';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_ARTICLE_CHANGES';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_article_changes');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
     * Logic for deleting Articles: Article text is stored as CLOB. It is costlier to extract the Article text
     * and inspect the text to decide if the article text on the change request needs to be synced up with the
     * Article text on the Original Agreement. So avoid this comparision and text extraction from CLOB, all the articles
     * on the original agreement are deleted and the articles from the change request are recorded against the original
     * agreement
     */

    FOR orig_articles_rec IN c_get_articles_csr(p_orig_chr_id) LOOP
      lv_catv_rec := NULL;
      lv_catv_rec.id := orig_articles_rec.id;
      okl_vp_k_article_pub.delete_k_article(p_api_version   => p_api_version
                                           ,p_init_msg_list => p_init_msg_list
                                           ,x_return_status => x_return_status
                                           ,x_msg_count     => x_msg_count
                                           ,x_msg_data      => x_msg_data
                                           ,p_catv_rec      => lv_catv_rec
                                           );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vp_k_article_pub.delete_k_article returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    -- now that the articles from the original agreement have been deleted, we need to copy all the articles from the
    -- change request back on to the original agreement
    FOR creq_articles_rec IN c_get_articles_csr(p_creq_chr_id) LOOP
      lv_catv_rec := NULL;
      x_catv_rec := NULL;
      lv_catv_rec.chr_id := p_orig_chr_id;
      lv_catv_rec.sbt_code := creq_articles_rec.sbt_code;
      lv_catv_rec.name := creq_articles_rec.name;
      lv_catv_rec.cat_type := creq_articles_rec.cat_type;

      -- for non standard articles, since the record is not comming from the ui to sync, we do not have the sae_id and sav_release
      -- this is the reason for copying the code from the create_article_by copy local procedure of okl_vp_k_article_pvt
      IF(creq_articles_rec.cat_type = 'NSD')THEN
        lv_catv_rec.cle_id := null;
        lv_catv_rec.dnz_chr_id := p_orig_chr_id;
        lv_catv_rec.object_version_number := 1.0;
        lv_catv_rec.sfwt_flag := OKC_API.G_TRUE;
        lv_catv_rec.comments := NULL;
        lv_catv_rec.fulltext_yn := NULL;
        lv_catv_rec.variation_description := NULL;
        lv_catv_rec.sav_sae_id := NULL;
        lv_catv_rec.sav_sav_release := NULL;
        okl_okc_migration_a_pvt.insert_row(
             p_api_version     => l_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_catv_rec        => lv_catv_rec,
             x_catv_rec        => x_catv_rec);
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_okc_migration_a_pvt.insert_row returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        -- now copy the text of the Non Standard Article into the new record
        x_return_status := okc_util.copy_articles_text(p_id => x_catv_rec.id
                                                      ,lang => USERENV('LANG')
                                                      ,p_text => creq_articles_rec.text);
        IF(x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

      ELSIF(creq_articles_rec.cat_type = 'STA')THEN
        lv_catv_rec.sav_sae_id := creq_articles_rec.sav_sae_id;
        lv_catv_rec.sav_sav_release := creq_articles_rec.sav_sav_release;

        okl_vp_k_article_pub.create_k_article(p_api_version   => p_api_version
                                             ,p_init_msg_list => p_init_msg_list
                                             ,x_return_status => x_return_status
                                             ,x_msg_count     => x_msg_count
                                             ,x_msg_data      => x_msg_data
                                             ,p_catv_rec      => lv_catv_rec
                                             ,x_catv_rec      => x_catv_rec
                                             );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_vp_k_article_pub.create_k_article returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_article_changes');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_article_changes;

  PROCEDURE sync_vendor_billing(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                               ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                ) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_VENDOR_BILLING';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_VENDOR_BILLING';
    l_debug_enabled VARCHAR2(10);

    -- cursor to fetch the rule group role definitions id for the source Vendor
    CURSOR c_get_rrd_id_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT rrd.id
      FROM okc_k_headers_b chr
          ,okc_subclass_roles sre
          ,okc_role_sources rse
          ,okc_subclass_rg_defs srd
          ,okc_rg_role_defs rrd
    WHERE chr.id = cp_chr_id
      AND sre.scs_code = chr.scs_code
      AND sre.rle_code = rse.rle_code
      AND rse.rle_code = 'OKL_VENDOR'
      AND rse.buy_or_sell = chr.buy_or_sell
      AND srd.scs_code = chr.scs_code
      AND srd.rgd_code = 'LAVENB'
      AND rrd.srd_id  = srd.id
      AND rrd.sre_id  = sre.id;
    lv_orig_rrd_id okc_rg_role_defs.id%TYPE;

   -- cursor that fetches party role id of Lease Vendor
   CURSOR c_get_cpl_id_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
   SELECT id
         ,object1_id1
     FROM okc_k_party_roles_b
    WHERE dnz_chr_id = cp_chr_id
      AND rle_code = 'OKL_VENDOR'
      AND jtot_object1_code = 'OKX_VENDOR';
   lv_orig_chr_cpl_id okc_k_party_roles_b.id%TYPE;
   lv_creq_chr_cpl_id okc_k_party_roles_b.id%TYPE;

   lv_orig_chr_object1 okc_k_party_roles_b.object1_id1%TYPE;
   lv_creq_chr_object1 okc_k_party_roles_b.object1_id1%TYPE;

   -- cursor to fetch customer information from the billing page
   CURSOR c_get_cust_info_csr(cp_chr_id okc_k_headers_b.id%TYPE, cp_cpl_id okc_k_party_roles_b.id%TYPE) IS
   SELECT chrb.id chr_id,
          rgpb.id rgp_id,
          cplv.id cpl_id,
          rulb.id cust_rule_id,
          rulb.object1_id1 cust_id,
          hzp.party_name cust_name,
          cplv.cust_acct_id cust_acct_id,
          hzc.account_number cust_account_number,
          hzc.account_name cust_account_name,
          cplv.bill_to_site_use_id bill_to_site_use_id,
          hzcsu.location bill_to_site_use_name,
          cplv.cognomen cognomen,
          cplv.alias alias,
          chrb.authoring_org_id authoring_org_id
     FROM okc_k_headers_b chrb,
          okc_k_party_roles_v cplv,
          hz_cust_accounts hzc,
          hz_cust_site_uses_all hzcsu,
          okc_rg_party_roles rgrp,
          okc_rule_groups_b rgpb,
          hz_parties hzp,
          okc_rules_b rulb
    WHERE cplv.dnz_chr_id = chrb.id
      and cplv.chr_id = chrb.id
      and hzc.cust_account_id(+) = cplv.cust_acct_id
      and hzcsu.site_use_id(+) = cplv.bill_to_site_use_id
      and rgpb.rgd_code(+) = 'LAVENB'
      and rgrp.rgp_id = rgpb.id(+)
      and rgrp.cpl_id(+) = cplv.id
      and rulb.rule_information_category(+) = 'LAVENC'
      and rulb.rgp_id(+) = rgpb.id
      and hzp.party_id(+) = rulb.object1_id1
      and chrb.id = cp_chr_id
      and cplv.id = cp_cpl_id;
    c_get_cust_info_orig_rec c_get_cust_info_csr%ROWTYPE;
    c_get_cust_info_creq_rec c_get_cust_info_csr%ROWTYPE;

   -- cursor to fetch other billing details from the billing page
   -- Updated the sql for performance issue - bug#5484903 - sql id: 20567146
   -- varangan - 26-9-06
   CURSOR c_get_cust_bill_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
   SELECT chr.id chr_id
         ,rgp_lavenb.id lavenb_rgp_id
         ,rul_lainpr.id lainpr_rul_id
         ,rul_lainpr.rule_information1 rul_lainpr_ri1
--         ,to_date(rul_lainpr.rule_information2,'YYYY/MM/DD HH24:MI:SS') rul_lainpr_ri2
         ,rul_lainpr.rule_information2 rul_lainpr_ri2
         ,rul_lainvd.id lainvd_rul_id
         ,rul_lainvd.rule_information1 rul_lainvd_ri1
         ,rul_lainvd.rule_information4 rul_lainvd_ri4
         ,rul_labacc.id labacc_rul_id
         ,rul_labacc.object1_id1 rul_labacc_o1id1
         ,rul_labacc.object1_id2 rul_labacc_o1id2
         ,rul_lapmth.id lapmth_rul_id
         ,rul_lapmth.object1_id1 rul_lapmth_o1id1
         ,rul_lapmth.object1_id2 rul_lapmth_o1id2
    FROM okc_k_headers_b chr
        ,okl_k_headers khr
        ,okc_rule_groups_b rgp_lavenb
        ,okc_rules_b rul_lainpr
        ,okc_rules_b rul_lainvd
        ,okc_rules_b rul_labacc
        ,okc_rules_b rul_lapmth
   WHERE chr.id = khr.id
     AND rgp_lavenb.dnz_chr_id(+) = chr.id
     AND rgp_lavenb.rgd_code(+) = 'LAVENB'
     AND rgp_lavenb.id = rul_lainpr.rgp_id(+)
     AND rul_lainpr.rule_information_category(+) = 'LAINPR'
     AND rgp_lavenb.id = rul_lainvd.rgp_id(+)
     AND rul_lainvd.rule_information_category(+) = 'LAINVD'
     AND rgp_lavenb.id = rul_labacc.rgp_id(+)
     AND rul_labacc.rule_information_category(+) = 'LABACC'
     AND rgp_lavenb.id = rul_lapmth.rgp_id(+)
     AND rul_lapmth.rule_information_category(+) = 'LAPMTH'
     AND chr.id = cp_chr_id;

   c_get_cust_bill_orig_rec c_get_cust_bill_csr%ROWTYPE;
   c_get_cust_bill_creq_rec c_get_cust_bill_csr%ROWTYPE;

   lv_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
   x_cplv_rec okl_okc_migration_pvt.cplv_rec_type;

   lv_rgr_tbl okl_rgrp_rules_process_pvt.rgr_tbl_type;
   idx PLS_INTEGER;

   lv_review_until_date DATE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_vendor_billing');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- first fetch the party role information for original agreement and the change request.
    -- cpl_id of these two entities should be the same as primary party information is not changed
    OPEN c_get_cpl_id_csr(p_orig_chr_id); FETCH c_get_cpl_id_csr INTO lv_orig_chr_cpl_id,lv_orig_chr_object1;
    CLOSE c_get_cpl_id_csr;

    OPEN c_get_cpl_id_csr(p_creq_chr_id); FETCH c_get_cpl_id_csr INTO lv_creq_chr_cpl_id,lv_creq_chr_object1;
    CLOSE c_get_cpl_id_csr;

    -- second, get the customer information from the chr_id and the party role id
    OPEN c_get_cust_info_csr(p_orig_chr_id, lv_orig_chr_cpl_id); FETCH c_get_cust_info_csr INTO c_get_cust_info_orig_rec;
    CLOSE c_get_cust_info_csr;

    OPEN c_get_cust_info_csr(p_creq_chr_id, lv_creq_chr_cpl_id); FETCH c_get_cust_info_csr INTO c_get_cust_info_creq_rec;
    CLOSE c_get_cust_info_csr;

    -- update customer information only if the customer has changed on the change request, or customer account has been changed
    -- or the bill to site info has been changed on the change request. for all other changes, the update is not necessary
    IF( NVL(c_get_cust_info_orig_rec.cust_id,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_info_creq_rec.cust_id,OKL_API.G_MISS_NUM) OR
        NVL(c_get_cust_info_orig_rec.cust_acct_id,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_info_creq_rec.cust_acct_id,OKL_API.G_MISS_NUM) OR
        NVL(c_get_cust_info_orig_rec.bill_to_site_use_id,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_info_creq_rec.bill_to_site_use_id,OKL_API.G_MISS_NUM)
      )THEN
      lv_cplv_rec.id := lv_orig_chr_cpl_id;
      lv_cplv_rec.chr_id := p_orig_chr_id;
      lv_cplv_rec.dnz_chr_id := p_orig_chr_id;
      lv_cplv_rec.rle_code := 'OKL_VENDOR';
      lv_cplv_rec.bill_to_site_use_id := c_get_cust_info_creq_rec.bill_to_site_use_id;
      lv_cplv_rec.cust_acct_id := c_get_cust_info_creq_rec.cust_acct_id;
      lv_cplv_rec.cognomen := c_get_cust_info_creq_rec.cognomen;
      lv_cplv_rec.alias := c_get_cust_info_creq_rec.alias;
      lv_cplv_rec.object1_id1 := lv_orig_chr_object1;
      lv_cplv_rec.object1_id2 := '#';
      lv_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
      lv_cplv_rec.created_by := fnd_global.user_id;
      lv_cplv_rec.creation_date := trunc(sysdate);
      lv_cplv_rec.last_updated_by := fnd_global.user_id;
      lv_cplv_rec.last_update_date := trunc(sysdate);
      lv_cplv_rec.last_update_login := fnd_global.login_id;

      okl_contract_party_pub.update_k_party_role(p_api_version   => p_api_version
                                                ,p_init_msg_list => p_init_msg_list
                                                ,x_return_status => x_return_status
                                                ,x_msg_count     => x_msg_count
                                                ,x_msg_data      => x_msg_data
                                                ,p_cplv_rec      => lv_cplv_rec
                                                ,x_cplv_rec      => x_cplv_rec
                                                );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_party_pub.update_k_party_role returned with status '||x_return_status
                                );
      END IF;

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- if the customer has changed, then update the rule info too
      IF( NVL(c_get_cust_info_orig_rec.cust_id,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_info_creq_rec.cust_id,OKL_API.G_MISS_NUM))THEN
        -- now we need to update the rule information with the above changes
        idx := 1;
        lv_rgr_tbl(idx).rgd_code := 'LAVENB';
        lv_rgr_tbl(idx).rule_information_category := 'LAVENC';
        lv_rgr_tbl(idx).dnz_chr_id := p_orig_chr_id;
        lv_rgr_tbl(idx).sfwt_flag := 'N';
        lv_rgr_tbl(idx).std_template_yn := 'N';
        lv_rgr_tbl(idx).warn_yn := 'N';
        lv_rgr_tbl(idx).created_by := fnd_global.user_id;
        lv_rgr_tbl(idx).creation_date := trunc(sysdate);
        lv_rgr_tbl(idx).last_updated_by := fnd_global.user_id;
        lv_rgr_tbl(idx).last_update_date := trunc(sysdate);
        lv_rgr_tbl(idx).last_update_login := fnd_global.login_id;

        IF(c_get_cust_info_orig_rec.rgp_id IS NOT NULL AND c_get_cust_info_orig_rec.rgp_id <> OKL_API.G_MISS_NUM)THEN
          lv_rgr_tbl(idx).rgp_id := c_get_cust_info_orig_rec.rgp_id;
        END IF;

        IF(c_get_cust_info_orig_rec.cust_rule_id IS NOT NULL AND c_get_cust_info_orig_rec.cust_rule_id <> OKL_API.G_MISS_NUM)THEN
          lv_rgr_tbl(idx).rule_id := c_get_cust_info_orig_rec.cust_rule_id;
        END IF;

        lv_rgr_tbl(idx).object1_id1 := c_get_cust_info_creq_rec.cust_id;
        lv_rgr_tbl(idx).jtot_object1_code := 'OKX_PARTY';

        OPEN c_get_rrd_id_csr(p_orig_chr_id); FETCH c_get_rrd_id_csr INTO lv_orig_rrd_id;
        CLOSE c_get_rrd_id_csr;

        okl_rgrp_rules_process_pvt.process_rule_group_rules(p_api_version   => p_api_version
                                                           ,p_init_msg_list => p_init_msg_list
                                                           ,x_return_status => x_return_status
                                                           ,x_msg_count     => x_msg_count
                                                           ,x_msg_data      => x_msg_data
                                                           ,p_chr_id        => p_orig_chr_id
                                                           ,p_line_id       => null
                                                           ,p_cpl_id        => lv_orig_chr_cpl_id
                                                           ,p_rrd_id        => lv_orig_rrd_id
                                                           ,p_rgr_tbl       => lv_rgr_tbl
                                                            );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_rgrp_rules_process_pvt.process_rule_group_rules for customer info returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF; -- end of NVL(c_get_cust_info_orig_rec.cust_id,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_info_creq_rec.cust_id,OKL_API.G_MISS_NUM)
    END IF; -- end of value comparision

    -- now fetch the billing information like bank account, payment method, review invoice from original agreement and change request
    -- and compare.
    OPEN c_get_cust_bill_csr(p_orig_chr_id); FETCH c_get_cust_bill_csr INTO c_get_cust_bill_orig_rec;
    CLOSE c_get_cust_bill_csr;

    OPEN c_get_cust_bill_csr(p_creq_chr_id); FETCH c_get_cust_bill_csr INTO c_get_cust_bill_creq_rec;
    CLOSE c_get_cust_bill_csr;

    OPEN c_get_rrd_id_csr(p_orig_chr_id); FETCH c_get_rrd_id_csr INTO lv_orig_rrd_id;
    CLOSE c_get_rrd_id_csr;

    -- initialize the rule group pl/sql table
    lv_rgr_tbl.DELETE;
    idx := 0;
    -- compare the Vendor Billing information and update the rules information only if there is a change
    IF(
       NVL(c_get_cust_bill_orig_rec.rul_lainpr_ri1,OKL_API.G_MISS_CHAR) <> NVL(c_get_cust_bill_creq_rec.rul_lainpr_ri1,OKL_API.G_MISS_CHAR) OR
       NVL(c_get_cust_bill_orig_rec.rul_lainpr_ri2,OKL_API.G_MISS_DATE) <> NVL(c_get_cust_bill_creq_rec.rul_lainpr_ri2,OKL_API.G_MISS_DATE)
      )THEN
      idx := idx + 1;

      -- check if the original record had vendor billing informaation and populate the rule group and rule ids accordingly.
      IF(c_get_cust_bill_orig_rec.lavenb_rgp_id IS NOT NULL AND c_get_cust_bill_orig_rec.lavenb_rgp_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rgp_id := c_get_cust_bill_orig_rec.lavenb_rgp_id;
      END IF;

      IF(c_get_cust_bill_orig_rec.lainpr_rul_id IS NOT NULL AND c_get_cust_bill_orig_rec.lainpr_rul_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rule_id := c_get_cust_bill_orig_rec.lainpr_rul_id;
      END IF;
      lv_rgr_tbl(idx).rgd_code := 'LAVENB';
      lv_rgr_tbl(idx).rule_information_category := 'LAINPR';
      lv_rgr_tbl(idx).dnz_chr_id := p_orig_chr_id;
      lv_rgr_tbl(idx).sfwt_flag := 'N';
      lv_rgr_tbl(idx).std_template_yn := 'N';
      lv_rgr_tbl(idx).warn_yn := 'N';

      lv_rgr_tbl(idx).rule_information1 := c_get_cust_bill_creq_rec.rul_lainpr_ri1;
      lv_rgr_tbl(idx).rule_information2 := c_get_cust_bill_creq_rec.rul_lainpr_ri2;
    END IF;

    IF(
       NVL(c_get_cust_bill_orig_rec.rul_lainvd_ri1,OKL_API.G_MISS_CHAR) <> NVL(c_get_cust_bill_creq_rec.rul_lainvd_ri1,OKL_API.G_MISS_CHAR) OR
       NVL(c_get_cust_bill_orig_rec.rul_lainvd_ri4,OKL_API.G_MISS_CHAR) <> NVL(c_get_cust_bill_creq_rec.rul_lainvd_ri4,OKL_API.G_MISS_CHAR)
      )THEN
      idx := idx + 1;

      -- check if the original record had vendor billing informaation and populate the rule group and rule ids accordingly.
      IF(c_get_cust_bill_orig_rec.lavenb_rgp_id IS NOT NULL AND c_get_cust_bill_orig_rec.lavenb_rgp_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rgp_id := c_get_cust_bill_orig_rec.lavenb_rgp_id;
      END IF;

      IF(c_get_cust_bill_orig_rec.lainvd_rul_id IS NOT NULL AND c_get_cust_bill_orig_rec.lainvd_rul_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rule_id := c_get_cust_bill_orig_rec.lainvd_rul_id;
      END IF;
      lv_rgr_tbl(idx).rgd_code := 'LAVENB';
      lv_rgr_tbl(idx).rule_information_category := 'LAINVD';
      lv_rgr_tbl(idx).dnz_chr_id := p_orig_chr_id;
      lv_rgr_tbl(idx).sfwt_flag := 'N';
      lv_rgr_tbl(idx).std_template_yn := 'N';
      lv_rgr_tbl(idx).warn_yn := 'N';

      lv_rgr_tbl(idx).rule_information1 := c_get_cust_bill_creq_rec.rul_lainvd_ri1;
      lv_rgr_tbl(idx).rule_information4 := c_get_cust_bill_creq_rec.rul_lainvd_ri4;
    END IF;

    IF(
       NVL(c_get_cust_bill_orig_rec.rul_labacc_o1id1,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_bill_creq_rec.rul_labacc_o1id1, OKL_API.G_MISS_NUM)
      )THEN
      idx := idx + 1;

      -- check if the original record had vendor billing informaation and populate the rule group and rule ids accordingly.
      IF(c_get_cust_bill_orig_rec.lavenb_rgp_id IS NOT NULL AND c_get_cust_bill_orig_rec.lavenb_rgp_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rgp_id := c_get_cust_bill_orig_rec.lavenb_rgp_id;
      END IF;

      IF(c_get_cust_bill_orig_rec.labacc_rul_id IS NOT NULL AND c_get_cust_bill_orig_rec.labacc_rul_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rule_id := c_get_cust_bill_orig_rec.labacc_rul_id;
      END IF;
      lv_rgr_tbl(idx).rgd_code := 'LAVENB';
      lv_rgr_tbl(idx).rule_information_category := 'LABACC';
      lv_rgr_tbl(idx).dnz_chr_id := p_orig_chr_id;
      lv_rgr_tbl(idx).sfwt_flag := 'N';
      lv_rgr_tbl(idx).std_template_yn := 'N';
      lv_rgr_tbl(idx).warn_yn := 'N';

      lv_rgr_tbl(idx).object1_id1 := c_get_cust_bill_creq_rec.rul_labacc_o1id1;
      lv_rgr_tbl(idx).object1_id2 := c_get_cust_bill_creq_rec.rul_labacc_o1id2;
      lv_rgr_tbl(idx).jtot_object1_code := 'OKX_CUSTBKAC';

    END IF;

    IF(
       NVL(c_get_cust_bill_orig_rec.rul_lapmth_o1id1,OKL_API.G_MISS_NUM) <> NVL(c_get_cust_bill_creq_rec.rul_lapmth_o1id1, OKL_API.G_MISS_NUM)
       )THEN
      idx := idx + 1;

      -- check if the original record had vendor billing informaation and populate the rule group and rule ids accordingly.
      IF(c_get_cust_bill_orig_rec.lavenb_rgp_id IS NOT NULL AND c_get_cust_bill_orig_rec.lavenb_rgp_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rgp_id := c_get_cust_bill_orig_rec.lavenb_rgp_id;
      END IF;

      IF(c_get_cust_bill_orig_rec.lapmth_rul_id IS NOT NULL AND c_get_cust_bill_orig_rec.lapmth_rul_id <> OKL_API.G_MISS_NUM)THEN
        lv_rgr_tbl(idx).rule_id := c_get_cust_bill_orig_rec.lapmth_rul_id;
      END IF;
      lv_rgr_tbl(idx).rgd_code := 'LAVENB';
      lv_rgr_tbl(idx).rule_information_category := 'LAPMTH';
      lv_rgr_tbl(idx).dnz_chr_id := p_orig_chr_id;
      lv_rgr_tbl(idx).sfwt_flag := 'N';
      lv_rgr_tbl(idx).std_template_yn := 'N';
      lv_rgr_tbl(idx).warn_yn := 'N';

      lv_rgr_tbl(idx).object1_id1 := c_get_cust_bill_creq_rec.rul_lapmth_o1id1;
      lv_rgr_tbl(idx).object1_id2 := c_get_cust_bill_creq_rec.rul_lapmth_o1id2;
      lv_rgr_tbl(idx).jtot_object1_code := 'OKX_RCPTMTH';
    END IF;

    IF(idx > 0)THEN
      okl_rgrp_rules_process_pvt.process_rule_group_rules(p_api_version   => p_api_version
                                                         ,p_init_msg_list => p_init_msg_list
                                                         ,x_return_status => x_return_status
                                                         ,x_msg_count     => x_msg_count
                                                         ,x_msg_data      => x_msg_data
                                                         ,p_chr_id        => p_orig_chr_id
                                                         ,p_line_id       => null
                                                         ,p_cpl_id        => lv_orig_chr_cpl_id
                                                         ,p_rrd_id        => lv_orig_rrd_id
                                                         ,p_rgr_tbl       => lv_rgr_tbl
                                                          );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_rgrp_rules_process_pvt.process_rule_group_rules for billing info returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_vendor_billing');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_vendor_billing;

  PROCEDURE sync_associations(p_api_version   IN NUMBER
                             ,p_init_msg_list IN VARCHAR2
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_count     OUT NOCOPY NUMBER
                             ,x_msg_data      OUT NOCOPY VARCHAR2
                             ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                             ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                             ,p_change_request_id IN okl_vp_change_requests.id%TYPE
                             ) IS

    -- cursor to get all the associations for the given change request
    CURSOR c_get_creq_assoc(cp_chr_id okc_k_headers_b.id%TYPE
                           ,cp_change_request_id okl_vp_change_requests.id%TYPE
                           ,cp_assoc_object_id okl_vp_associations.assoc_object_id%TYPE
                           ,cp_assoc_object_code okl_vp_associations.assoc_object_type_code%TYPE
                           ,cp_assoc_object_version okl_vp_associations.assoc_object_version%TYPE
                            )IS
    SELECT crs_id
          ,start_date
          ,end_date
          ,description
          ,assoc_object_type_code
          ,assoc_object_id
          ,assoc_object_version
      FROM okl_vp_associations
     WHERE crs_id = cp_change_request_id
       AND chr_id = cp_chr_id
       AND assoc_object_id = cp_assoc_object_id
       AND assoc_object_type_code = cp_assoc_object_code
       AND nvl(assoc_object_version,1) = nvl(cp_assoc_object_version,1);
    cv_creq_assoc_rec c_get_creq_assoc%ROWTYPE;

    -- get the associations on the original agreement. this cursor is valid
    -- for both ASSOCIATION change requests and AGREEMENT change requests
    CURSOR c_get_orig_assoc(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT chr_id
          ,start_date
          ,end_date
          ,description
          ,assoc_object_type_code
          ,assoc_object_id
          ,assoc_object_version
          ,id
      FROM okl_vp_associations
     WHERE crs_id IS NULL
       AND chr_id = cp_chr_id;

    CURSOR c_new_creq_assoc_csr(cp_change_request_id okl_vp_change_requests.id%TYPE
                               ,cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT creq.chr_id
          ,creq.crs_id
          ,creq.start_date
          ,creq.end_date
          ,creq.description
          ,creq.assoc_object_type_code
          ,creq.assoc_object_id
          ,creq.assoc_object_version
      FROM okl_vp_associations creq
     WHERE crs_id = cp_change_request_id
       AND NOT EXISTS (
           SELECT 'X'
             FROM okl_vp_associations orig
            WHERE orig.chr_id = cp_chr_id
              AND orig.crs_id IS NULL
              AND orig.start_date = creq.start_date
              AND NVL(orig.end_date, TRUNC(SYSDATE)) = NVL(creq.end_date,TRUNC(SYSDATE))
              AND NVL(orig.description, 'X') = NVL(creq.description, 'X')
              AND orig.assoc_object_type_code = creq.assoc_object_type_code
              AND orig.assoc_object_id = creq.assoc_object_id
              AND NVL(orig.assoc_object_version,1) = NVL(creq.assoc_object_version,1)
           );
    lv_vasv_rec vasv_rec_type;
    x_vasv_rec vasv_rec_type;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_ASSOCIATIONS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_ASSOCIATIONS';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_associations');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- technical note: for a change request of type AGREEMENT, the parameters p_orig_chr_id and p_creq_chr_id
    -- point to the original agreement and the agreement associated with the change request respectively.
    -- but for an ASSOCIATION type of change request, the parameter values p_orig_chr_id and p_creq_chr_id are the
    -- same.

    -- first find out if the original associations are on the change request too
    FOR orig_assoc_rec IN c_get_orig_assoc(p_orig_chr_id) LOOP
      -- now check if this association record exists on the change request too.
      OPEN c_get_creq_assoc(p_creq_chr_id
                           ,p_change_request_id
                           ,orig_assoc_rec.assoc_object_id
                           ,orig_assoc_rec.assoc_object_type_code
                           ,orig_assoc_rec.assoc_object_version);
      FETCH c_get_creq_assoc INTO cv_creq_assoc_rec;
      IF(c_get_creq_assoc%FOUND)THEN
        CLOSE c_get_creq_assoc;
        -- compare other attributes of the template now that it has not been removed. other attribs include start date, end date, comments
        IF((TRUNC(orig_assoc_rec.start_date) <> TRUNC(cv_creq_assoc_rec.start_date))
           OR(NVL(orig_assoc_rec.end_date,OKL_API.G_MISS_DATE) <> NVL(cv_creq_assoc_rec.end_date,OKL_API.G_MISS_DATE))
           OR(NVL(orig_assoc_rec.description,OKL_API.G_MISS_CHAR) <> NVL(cv_creq_assoc_rec.description,OKL_API.G_MISS_CHAR)))THEN
           -- if either of the start date, end date or comments have been updated on the change request, we need to sync them back to the
           -- agreement
           lv_vasv_rec := NULL;
           x_vasv_rec := NULL;
           lv_vasv_rec.id := orig_assoc_rec.id;
           lv_vasv_rec.assoc_object_id := orig_assoc_rec.assoc_object_id;
           lv_vasv_rec.assoc_object_type_code := orig_assoc_rec.assoc_object_type_code;
           lv_vasv_rec.assoc_object_version := cv_creq_assoc_rec.assoc_object_version;
           lv_vasv_rec.start_date := TRUNC(cv_creq_assoc_rec.start_date);
           lv_vasv_rec.end_date := cv_creq_assoc_rec.end_date;
           lv_vasv_rec.description := cv_creq_assoc_rec.description;
           lv_vasv_rec.chr_id := p_orig_chr_id;
           okl_vp_associations_pvt.update_vp_associations(p_api_version   => p_api_version
                                                         ,p_init_msg_list => p_init_msg_list
                                                         ,x_return_status => x_return_status
                                                         ,x_msg_count     => x_msg_count
                                                         ,x_msg_data      => x_msg_data
                                                         ,p_vasv_rec      => lv_vasv_rec
                                                         ,x_vasv_rec      => x_vasv_rec
                                                          );
           IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                     l_module,
                                     'okl_vp_associations_pvt.update_vp_associations returned with status '||x_return_status
                                     );
           END IF;
           IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;  -- end of attrib comparision
      ELSE
        CLOSE c_get_creq_assoc;
        -- since the record is not present on the change request, delete this record from the original agreement too
        lv_vasv_rec := NULL;
        lv_vasv_rec.id := orig_assoc_rec.id;
        okl_vp_associations_pvt.delete_vp_associations(p_api_version   => p_api_version
                                                      ,p_init_msg_list => p_init_msg_list
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count     => x_msg_count
                                                      ,x_msg_data      => x_msg_data
                                                      ,p_vasv_rec      => lv_vasv_rec
                                                       );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_vp_associations_pvt.delete_vp_associations returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of attribute comparision
    END LOOP;
    -- now we need to add back all the new records that have been created or whose associated object has been changed by updating the
    -- LOV field on the change request
    FOR new_creq_rec IN c_new_creq_assoc_csr(p_change_request_id, p_creq_chr_id) LOOP
      lv_vasv_rec := NULL;
      x_vasv_rec := NULL;
      lv_vasv_rec.chr_id := p_orig_chr_id;
      lv_vasv_rec.start_date := new_creq_rec.start_date;
      lv_vasv_rec.end_date := new_creq_rec.end_date;
      lv_vasv_rec.description := new_creq_rec.description;
      lv_vasv_rec.assoc_object_type_code := new_creq_rec.assoc_object_type_code;
      lv_vasv_rec.assoc_object_id := new_creq_rec.assoc_object_id;
      lv_vasv_rec.assoc_object_version := new_creq_rec.assoc_object_version;
      okl_vp_associations_pvt.create_vp_associations(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_vasv_rec      => lv_vasv_rec
                                                    ,x_vasv_rec      => x_vasv_rec
                                                     );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vp_associations_pvt.create_vp_associations returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_associations');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_associations;

  PROCEDURE sync_agr_associations(p_api_version   IN NUMBER
                                 ,p_init_msg_list IN VARCHAR2
                                 ,x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count     OUT NOCOPY NUMBER
                                 ,x_msg_data      OUT NOCOPY VARCHAR2
                                 ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                 ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                 ,p_change_request_id IN okl_vp_change_requests.id%TYPE
                                 ) IS

    -- cursor to get all the associations for the given change request of type AGREEMENT
    CURSOR c_get_creq_assoc(cp_chr_id okc_k_headers_b.id%TYPE
                           ,cp_assoc_object_id okl_vp_associations.assoc_object_id%TYPE
                           ,cp_assoc_object_code okl_vp_associations.assoc_object_type_code%TYPE
                           ,cp_assoc_object_version okl_vp_associations.assoc_object_version%TYPE
                            )IS
    SELECT crs_id
          ,start_date
          ,end_date
          ,description
          ,assoc_object_type_code
          ,assoc_object_id
          ,assoc_object_version
      FROM okl_vp_associations
     WHERE chr_id = cp_chr_id
       AND assoc_object_id = cp_assoc_object_id
       AND assoc_object_type_code = cp_assoc_object_code
       AND nvl(assoc_object_version,1) = nvl(cp_assoc_object_version,1);
    cv_creq_assoc_rec c_get_creq_assoc%ROWTYPE;

    -- get the associations on the original agreement. this cursor is valid
    -- for both ASSOCIATION change requests and AGREEMENT change requests
    CURSOR c_get_orig_assoc(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT chr_id
          ,start_date
          ,end_date
          ,description
          ,assoc_object_type_code
          ,assoc_object_id
          ,assoc_object_version
          ,id
      FROM okl_vp_associations
     WHERE crs_id IS NULL
       AND chr_id = cp_chr_id;

    CURSOR c_new_creq_assoc_csr(cp_chr_id_orig okl_vp_change_requests.id%TYPE
                               ,cp_chr_id_creq okc_k_headers_b.id%TYPE) IS
    SELECT creq.chr_id
          ,creq.crs_id
          ,creq.start_date
          ,creq.end_date
          ,creq.description
          ,creq.assoc_object_type_code
          ,creq.assoc_object_id
          ,creq.assoc_object_version
      FROM okl_vp_associations creq
     WHERE chr_id = cp_chr_id_creq
       AND NOT EXISTS (
           SELECT 'X'
             FROM okl_vp_associations orig
            WHERE orig.chr_id = cp_chr_id_orig
              AND orig.crs_id IS NULL
              AND orig.start_date = creq.start_date
              AND NVL(orig.end_date, TRUNC(SYSDATE)) = NVL(creq.end_date,TRUNC(SYSDATE))
              AND NVL(orig.description, 'X') = NVL(creq.description, 'X')
              AND orig.assoc_object_type_code = creq.assoc_object_type_code
              AND orig.assoc_object_id = creq.assoc_object_id
              AND NVL(orig.assoc_object_version,1) = NVL(creq.assoc_object_version,1)
           );
    lv_vasv_rec vasv_rec_type;
    x_vasv_rec vasv_rec_type;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_ASSOCIATIONS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_ASSOCIATIONS';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_associations');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- first find out if the original associations are on the change request too
    FOR orig_assoc_rec IN c_get_orig_assoc(p_orig_chr_id) LOOP
      -- now check if this association record exists on the change request too.
      OPEN c_get_creq_assoc(p_creq_chr_id
                           ,orig_assoc_rec.assoc_object_id
                           ,orig_assoc_rec.assoc_object_type_code
                           ,orig_assoc_rec.assoc_object_version);
      FETCH c_get_creq_assoc INTO cv_creq_assoc_rec;
      IF(c_get_creq_assoc%FOUND)THEN
        CLOSE c_get_creq_assoc;
        -- compare other attributes of the template now that it has not been removed. other attribs include start date, end date, comments
        IF((TRUNC(orig_assoc_rec.start_date) <> TRUNC(cv_creq_assoc_rec.start_date))
           OR(NVL(orig_assoc_rec.end_date,OKL_API.G_MISS_DATE) <> NVL(cv_creq_assoc_rec.end_date,OKL_API.G_MISS_DATE))
           OR(NVL(orig_assoc_rec.description,OKL_API.G_MISS_CHAR) <> NVL(cv_creq_assoc_rec.description,OKL_API.G_MISS_CHAR)))THEN
           -- if either of the start date, end date or comments have been updated on the change request, we need to sync them back to the
           -- agreement
           lv_vasv_rec := NULL;
           x_vasv_rec := NULL;
           lv_vasv_rec.id := orig_assoc_rec.id;
           lv_vasv_rec.assoc_object_id := orig_assoc_rec.assoc_object_id;
           lv_vasv_rec.assoc_object_type_code := orig_assoc_rec.assoc_object_type_code;
           lv_vasv_rec.assoc_object_version := cv_creq_assoc_rec.assoc_object_version;
           lv_vasv_rec.start_date := TRUNC(cv_creq_assoc_rec.start_date);
           lv_vasv_rec.end_date := cv_creq_assoc_rec.end_date;
           lv_vasv_rec.description := cv_creq_assoc_rec.description;
           lv_vasv_rec.chr_id := p_orig_chr_id;
           okl_vp_associations_pvt.update_vp_associations(p_api_version   => p_api_version
                                                         ,p_init_msg_list => p_init_msg_list
                                                         ,x_return_status => x_return_status
                                                         ,x_msg_count     => x_msg_count
                                                         ,x_msg_data      => x_msg_data
                                                         ,p_vasv_rec      => lv_vasv_rec
                                                         ,x_vasv_rec      => x_vasv_rec
                                                          );
           IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                     l_module,
                                     'okl_vp_associations_pvt.update_vp_associations returned with status '||x_return_status
                                     );
           END IF;
           IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;  -- end of attrib comparision
      ELSE
        CLOSE c_get_creq_assoc;
        -- since the record is not present on the change request, delete this record from the original agreement too
        lv_vasv_rec := NULL;
        lv_vasv_rec.id := orig_assoc_rec.id;
        okl_vp_associations_pvt.delete_vp_associations(p_api_version   => p_api_version
                                                      ,p_init_msg_list => p_init_msg_list
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count     => x_msg_count
                                                      ,x_msg_data      => x_msg_data
                                                      ,p_vasv_rec      => lv_vasv_rec
                                                       );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_vp_associations_pvt.delete_vp_associations returned with status '||x_return_status
                                  );
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of attribute comparision
    END LOOP;
    -- now we need to add back all the new records that have been created or whose associated object has been changed by updating the
    -- LOV field on the change request
    FOR new_creq_rec IN c_new_creq_assoc_csr(p_orig_chr_id, p_creq_chr_id) LOOP
      lv_vasv_rec := NULL;
      x_vasv_rec := NULL;
      lv_vasv_rec.chr_id := p_orig_chr_id;
      lv_vasv_rec.start_date := new_creq_rec.start_date;
      lv_vasv_rec.end_date := new_creq_rec.end_date;
      lv_vasv_rec.description := new_creq_rec.description;
      lv_vasv_rec.assoc_object_type_code := new_creq_rec.assoc_object_type_code;
      lv_vasv_rec.assoc_object_id := new_creq_rec.assoc_object_id;
      lv_vasv_rec.assoc_object_version := new_creq_rec.assoc_object_version;
      okl_vp_associations_pvt.create_vp_associations(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_vasv_rec      => lv_vasv_rec
                                                    ,x_vasv_rec      => x_vasv_rec
                                                     );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vp_associations_pvt.create_vp_associations returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_associations');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_agr_associations;


  PROCEDURE sync_elig_criteria(p_api_version   IN  NUMBER
                              ,p_init_msg_list IN  VARCHAR2
                              ,x_return_status OUT NOCOPY VARCHAR2
                              ,x_msg_count     OUT NOCOPY NUMBER
                              ,x_msg_data      OUT NOCOPY VARCHAR2
                              ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                              ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                              )IS
    CURSOR c_get_agrmt_dates_csr(cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT start_date
          ,end_date
      FROM okc_k_headers_b
     WHERE id = cp_chr_id;
    cv_get_agrmnt_dates c_get_agrmt_dates_csr%ROWTYPE;

    lx_ech_rec ech_rec_type;
    lx_ecl_tbl ecl_tbl_type;
    lx_ecv_tbl ecv_tbl_type;

    x_ech_rec ech_rec_type;
    x_ecl_tbl ecl_tbl_type;
    x_ecv_tbl ecv_tbl_type;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_ELIG_CRITERIA';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_ELIG_CRITERIA';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_elig_criteria');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- the effective start and end dates of the original agreement are derived to pass to the eligibility criteria API
    -- note that by the time control reaches this place, the extended effective end date on the change request would
    -- have been synced on to the original agreement. this is the reason for not picking up the effective dates from the
    -- change request.
    OPEN c_get_agrmt_dates_csr(p_orig_chr_id); FETCH c_get_agrmt_dates_csr INTO cv_get_agrmnt_dates;
    CLOSE c_get_agrmt_dates_csr;

    -- first, delete the eligibility criteria on the original agreement
    okl_ecc_values_pvt.delete_eligibility_criteria(p_api_version     => p_api_version
                                                  ,p_init_msg_list   => p_init_msg_list
                                                  ,x_return_status   => x_return_status
                                                  ,x_msg_count       => x_msg_count
                                                  ,x_msg_data        => x_msg_data
                                                  ,p_source_id       => p_orig_chr_id
                                                  ,p_source_type     => G_VENDOR_PROGRAM_CODE
                                                  );
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_ecc_values_pvt.delete_eligibility_criteria returned with status '||x_return_status
                              );
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- now that the eligibility criteria has been deleted successfully,
    -- get the eligibility criteria from the change request agreement
    okl_ecc_values_pvt.get_eligibility_criteria(p_api_version    => p_api_version
                                               ,p_init_msg_list  => p_init_msg_list
                                               ,x_return_status  => x_return_status
                                               ,x_msg_count      => x_msg_count
                                               ,x_msg_data       => x_msg_data
                                               ,p_source_id      => p_creq_chr_id
                                               ,p_source_type    => G_VENDOR_PROGRAM_CODE
                                               ,x_ech_rec        => lx_ech_rec
                                               ,x_ecl_tbl        => lx_ecl_tbl
                                               ,x_ecv_tbl        => lx_ecv_tbl
                                               );
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_ecc_values_pvt.get_eligibility_criteria returned with status '||x_return_status
                              );
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(lx_ecl_tbl.count > 0)THEN
      -- set the eligibility criteria headers id to the original agreement id
      -- and the source to VENDOR_PROGRAM
      lx_ech_rec.source_id := p_orig_chr_id;
      lx_ech_rec.source_object_code := G_VENDOR_PROGRAM_CODE;

      -- pass the criteria set id as null to indicate creation of the eligibility criteria on the original agreement
      lx_ech_rec.criteria_set_id := NULL;

      FOR i IN lx_ecl_tbl.FIRST..lx_ecl_tbl.LAST LOOP
        -- is_new_flag = Y indicates create mode
        lx_ecl_tbl(i).is_new_flag := 'Y';
      END LOOP;

      FOR i IN lx_ecv_tbl.FIRST..lx_ecv_tbl.LAST LOOP
        lx_ecv_tbl(i).criterion_value_id := NULL;
        -- validate_record = N indicates that the values in crit_cat_value1 and crit_cat_value2 will not be
        -- validated again. since this is the case of synchronization, the validation would have happened while
        -- saving the criteria values on the change request
        lx_ecv_tbl(i).validate_record := 'N';
      END LOOP;

      --call handle_eligibility_criteria
      okl_ecc_values_pvt.handle_eligibility_criteria(p_api_version     => p_api_version
                                                    ,p_init_msg_list   => p_init_msg_list
                                                    ,x_return_status   => x_return_status
                                                    ,x_msg_count       => x_msg_count
                                                    ,x_msg_data        => x_msg_data
                                                    ,p_source_eff_from => cv_get_agrmnt_dates.start_date
                                                    ,p_source_eff_to   => cv_get_agrmnt_dates.end_date
                                                    ,x_ech_rec         => x_ech_rec -- OUT
                                                    ,x_ecl_tbl         => x_ecl_tbl -- OUT
                                                    ,x_ecv_tbl         => x_ecv_tbl -- OUT
                                                    ,p_ech_rec         => lx_ech_rec -- IN
                                                    ,p_ecl_tbl         => lx_ecl_tbl -- IN
                                                    ,p_ecv_tbl         => lx_ecv_tbl -- IN
                                                     );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_ecc_values_pvt.handle_eligibility_criteria returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_elig_criteria');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_elig_criteria;

  PROCEDURE sync_terms(p_api_version   IN  NUMBER
                      ,p_init_msg_list IN  VARCHAR2
                      ,x_return_status OUT NOCOPY VARCHAR2
                      ,x_msg_count     OUT NOCOPY NUMBER
                      ,x_msg_data      OUT NOCOPY VARCHAR2
                      ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                      ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                      ) IS

    -- cursor that finds out missing rule group records from the change request
    -- so that these records can be deleted from the original program agreement too
    CURSOR c_get_miss_rl_csr(cp_orig_chr_id okc_k_headers_b.id%TYPE
                            ,cp_creq_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT orig.id
          ,orig.dnz_chr_id
          ,orig.rgd_code
      FROM okc_rule_groups_v orig
     WHERE chr_id = cp_orig_chr_id
       AND cle_id IS NULL
       AND dnz_chr_id = cp_orig_chr_id
       AND NOT EXISTS (
           SELECT 'X'
             FROM okc_rule_groups_v creq
            WHERE creq.chr_id = cp_creq_chr_id
              AND creq.rgd_code = orig.rgd_code
              AND creq.dnz_chr_id = cp_creq_chr_id
              AND creq.cle_id IS NULL);

    -- cursor that finds common rule group records on the change request as well as the originating
    -- program agreement
    CURSOR c_get_comm_rl_csr(cp_orig_chr_id okc_k_headers_b.id%TYPE
                            ,cp_creq_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT creq.id
          ,creq.dnz_chr_id
          ,creq.rgd_code
      FROM okc_rule_groups_v creq
     WHERE chr_id = cp_creq_chr_id
       AND cle_id IS NULL
       AND dnz_chr_id = cp_creq_chr_id
       AND EXISTS (
           SELECT 'X'
             FROM okc_rule_groups_v orig
            WHERE orig.chr_id = cp_orig_chr_id
              AND orig.rgd_code = creq.rgd_code
              AND orig.dnz_chr_id = cp_orig_chr_id
              AND orig.cle_id IS NULL);

    CURSOR c_rl_exist_csr (cp_rul_info_cat okc_rules_b.rule_information_category%TYPE,
                           cp_chr_id okc_k_headers_b.id%TYPE,
                           cp_rgd_code okc_rule_groups_b.rgd_code%TYPE) IS
    SELECT rul.id
          ,rul.rgp_id
          ,rul.object_version_number
      FROM okc_rules_b rul
          ,okc_rule_groups_b rgp
     WHERE rgp.id = rul.rgp_id
       AND rgp.chr_id = rul.dnz_chr_id
       AND rul.rule_information_category = cp_rul_info_cat
       AND rgp.chr_id = cp_chr_id
       AND rgp.rgd_code = cp_rgd_code;

    -- cursor that finds out new rule group records from the change request
    -- so that these records can be added to the original program agreement
    CURSOR c_get_new_rl_csr(cp_orig_chr_id okc_k_headers_b.id%TYPE
                            ,cp_creq_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT creq.id
          ,creq.dnz_chr_id
          ,creq.rgd_code
          ,creq.rgp_type
      FROM okc_rule_groups_v creq
     WHERE chr_id = cp_creq_chr_id
       AND cle_id IS NULL
       AND dnz_chr_id = cp_creq_chr_id
       AND NOT EXISTS (
           SELECT 'X'
             FROM okc_rule_groups_v orig
            WHERE orig.chr_id = cp_orig_chr_id
              AND orig.rgd_code = creq.rgd_code
              AND orig.dnz_chr_id = cp_orig_chr_id
              AND orig.cle_id IS NULL);

    CURSOR c_get_residual_grp(cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT id
      FROM okc_rule_groups_b
     WHERE dnz_chr_id = cp_chr_id
       AND rgd_code = 'VGLRS';

    lv_rule_group_id okc_rule_groups_b.id%TYPE;

    cv_rl_exist_rec c_rl_exist_csr%ROWTYPE;

    lv_rule_info_tbl okl_rgrp_rules_process_pvt.rgr_tbl_type;

    lv_rgpv_r1_rec OKL_RULE_PUB.rgpv_rec_type;
    lv_rgpv_r2_rec OKL_RULE_PUB.rgpv_rec_type;
    lx_rulv1_tbl OKL_RULE_PUB.rulv_tbl_type;
    lx_new_rgp_tbl okl_okc_migration_pvt.rgpv_tbl_type;
    lv_new_rgp_tbl okl_okc_migration_pvt.rgpv_tbl_type;
    x_new_rgp_rec okl_rule_pub.rgpv_rec_type;
    x_rulv2_tbl okl_rule_pub.rulv_tbl_type;
    lv_rgp_id okc_rule_groups_b.id%TYPE;
    lx_rulv2_tbl OKL_RULE_PUB.rulv_tbl_type;
    lv_rgpv_del_tbl okl_vp_rule_pub.rgpv_tbl_type;
    lv_rule_information1 okc_rules_b.rule_information1%TYPE;

    lx_rulv_count NUMBER;
    lv_rulv2_count NUMBER;
    lv_process_idx PLS_INTEGER;
    lx_new_rg_count NUMBER;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_TERMS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_TERMS';
    l_debug_enabled VARCHAR2(10);

    FUNCTION get_original_cpl_id(p_new_cpl_id okc_k_party_roles_b.id%TYPE
                                ,p_orig_chr_id okc_k_headers_b.id%TYPE
                                ,p_creq_chr_id okc_k_headers_b.id%TYPE
                                ) RETURN NUMBER IS
      CURSOR c_get_cpl_id_csr (cp_cpl_id okc_k_party_roles_b.id%TYPE
                              ,cp_orig_chr_id okc_k_headers_b.id%TYPE
                              ,cp_creq_chr_id okc_k_headers_b.id%TYPE) IS
      SELECT cpl.id
        FROM okc_k_party_roles_b cpl
            ,okc_k_party_roles_b cpl1
       WHERE cpl.chr_id = cp_orig_chr_id
         AND cpl.rle_code = cpl1.rle_code
         AND cpl1.chr_id = cp_creq_chr_id
         AND cpl.object1_id1 = cpl1.object1_id1
         AND cpl.object1_id2 = cpl1.object1_id2
         AND cpl.jtot_object1_code = cpl1.jtot_object1_code
         AND cpl1.id = cp_cpl_id;

      lv_return_cpl_id okc_k_party_roles_b.id%TYPE;
    BEGIN
      -- the value is always guaranteed in this cursor as the terms are being synced after the parties
      -- sync. so even if the party was not on the original agreement, we would still get the id from okc_k_party_roles_b
      -- as that record would have been inserted in the table before executing sync_terms api
      OPEN c_get_cpl_id_csr (cp_cpl_id => p_new_cpl_id
                            ,cp_orig_chr_id => p_orig_chr_id
                            ,cp_creq_chr_id => p_creq_chr_id);
      FETCH c_get_cpl_id_csr INTO lv_return_cpl_id;
      CLOSE c_get_cpl_id_csr;
      RETURN lv_return_cpl_id;
    END get_original_cpl_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_terms');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- since it is possible for the user to go and delete a party after associating a residual share percent to that party,
    -- we have to delete the rule group and the information from the parent contract and get it re-created from the change request
    -- get the rule group information for the VGLRS rule group
    OPEN c_get_residual_grp(cp_chr_id => p_orig_chr_id); FETCH c_get_residual_grp INTO lv_rule_group_id;
    IF(c_get_residual_grp%FOUND)THEN
      CLOSE c_get_residual_grp;
      lv_rgpv_del_tbl(1).id := lv_rule_group_id;
      lv_rgpv_del_tbl(1).chr_id := p_orig_chr_id;
      lv_rgpv_del_tbl(1).rgd_code := 'VGLRS';
      okl_vp_rule_pub.delete_rule_group(p_api_version   => p_api_version
                                       ,p_init_msg_list => p_init_msg_list
                                       ,x_return_status => x_return_status
                                       ,x_msg_count     => x_msg_count
                                       ,x_msg_data      => x_msg_data
                                       ,p_rgpv_tbl      => lv_rgpv_del_tbl
                                       );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      CLOSE c_get_residual_grp;
    END IF;

    -- process all the rule groups that have been deleted from the change request, but are present on the
    -- originating agreement. these rule groups have to be deleted from the originating agreement

    /*
    FOR cv_get_miss_rl_rec IN c_get_miss_rl_csr(cp_orig_chr_id => p_orig_chr_id, cp_creq_chr_id => p_creq_chr_id) LOOP
      lv_del_idx := lv_del_idx + 1;
      lv_rgpv_del_tbl(lv_del_idx).id := cv_get_miss_rl_rec.id;
      lv_rgpv_del_tbl(lv_del_idx).chr_id := cv_get_miss_rl_rec.dnz_chr_id;
      lv_rgpv_del_tbl(lv_del_idx).rgd_code := cv_get_miss_rl_rec.rgd_code;
    END LOOP;
    -- see if there are any records to delete from the originating agreement
    IF(lv_rgpv_del_tbl.COUNT > 0)THEN
      okl_vp_rule_pub.delete_rule_group(p_api_version   => p_api_version
                                       ,p_init_msg_list => p_init_msg_list
                                       ,x_return_status => x_return_status
                                       ,x_msg_count     => x_msg_count
                                       ,x_msg_data      => x_msg_data
                                       ,p_rgpv_tbl      => lv_rgpv_del_tbl
                                       );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    */
    -- now find the rules that have been modified/created on the change request and whose rule groups
    -- exist on the original agreement, since the rule group information is not updateable, we process
    -- only the rule information here

    FOR cv_get_comm_rl_rec IN c_get_comm_rl_csr(cp_orig_chr_id => p_orig_chr_id, cp_creq_chr_id => p_creq_chr_id) LOOP
      -- populate the rule group information record required to be passed to the rule retrieval api
      lv_rgpv_r1_rec.id := cv_get_comm_rl_rec.id;
      lv_rgpv_r1_rec.rgd_code := cv_get_comm_rl_rec.rgd_code;
      lv_rgpv_r1_rec.chr_id := cv_get_comm_rl_rec.dnz_chr_id;
      lv_rgpv_r1_rec.dnz_chr_id := cv_get_comm_rl_rec.dnz_chr_id;
      lx_rulv_count := 0;
      -- now get the rule(s) for this rule group
      okl_rule_apis_pvt.get_contract_rules(p_api_version   => p_api_version
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_rgpv_rec      => lv_rgpv_r1_rec
                                          ,p_rdf_code      => null -- we want all the rules under this rule group
                                          ,x_return_status => x_return_status
                                          ,x_msg_count     => x_msg_count
                                          ,x_msg_data      => x_msg_data
                                          ,x_rulv_tbl      => lx_rulv1_tbl
                                          ,x_rule_count    => lx_rulv_count
                                          );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_rule_apis_pvt.get_contract_rules returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      lv_process_idx := 0;
      IF(lx_rulv_count > 0)THEN
        FOR idx1 IN 1..lx_rulv_count LOOP
          OPEN c_rl_exist_csr(lx_rulv1_tbl(idx1).rule_information_category, p_orig_chr_id, cv_get_comm_rl_rec.rgd_code);
          FETCH c_rl_exist_csr INTO cv_rl_exist_rec;
          IF(c_rl_exist_csr%FOUND)THEN
            -- this is the case of update
            lv_process_idx := lv_process_idx + 1;
            lv_rule_info_tbl(lv_process_idx).rule_id := cv_rl_exist_rec.id;
            lv_rule_info_tbl(lv_process_idx).dnz_chr_id := p_orig_chr_id;
            lv_rule_info_tbl(lv_process_idx).rgp_id := cv_rl_exist_rec.rgp_id;
            lv_rule_info_tbl(lv_process_idx).object_version_number := cv_rl_exist_rec.object_version_number;
          ELSE -- c_rl_exist_csr NOTFOUND case
            lv_process_idx := lv_process_idx + 1;
            -- this is the case of inserting a new rule record under an existing rule group
            -- find the header rule group id for the parent agreement
            lv_rgp_id := okl_rgrp_rules_process_pvt.get_header_rule_group_id(p_api_version   => p_api_version
                                                                            ,p_init_msg_list => p_init_msg_list
                                                                            ,x_return_status => x_return_status
                                                                            ,x_msg_count     => x_msg_count
                                                                            ,x_msg_data      => x_msg_data
                                                                            ,p_chr_id        => p_orig_chr_id
                                                                            ,p_rgd_code      => cv_get_comm_rl_rec.rgd_code
                                                                            );
            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                      l_module,
                                      'okl_rgrp_rules_process_pvt.get_header_rule_group_id returned with status '||x_return_status||' lv_rgp_id '||lv_rgp_id
                                      );
            END IF;
            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- since we are creating the rule record, pass the rule_id as null
            lv_rule_info_tbl(lv_process_idx).rule_id := null;
            lv_rule_info_tbl(lv_process_idx).dnz_chr_id := p_orig_chr_id;
            -- the rgp id should be the rgp_id of the original agreement
            lv_rule_info_tbl(lv_process_idx).rgp_id := lv_rgp_id;
            lv_rule_info_tbl(lv_process_idx).object_version_number := 1;
          END IF;
            CLOSE c_rl_exist_csr;
            lv_rule_info_tbl(lv_process_idx).rgd_code := cv_get_comm_rl_rec.rgd_code;
            lv_rule_info_tbl(lv_process_idx).object1_id1 := lx_rulv1_tbl(idx1).object1_id1;
            lv_rule_info_tbl(lv_process_idx).object2_id1 := lx_rulv1_tbl(idx1).object2_id1;
            lv_rule_info_tbl(lv_process_idx).object3_id1 := lx_rulv1_tbl(idx1).object3_id1;
            lv_rule_info_tbl(lv_process_idx).object1_id2 := lx_rulv1_tbl(idx1).object1_id2;
            lv_rule_info_tbl(lv_process_idx).object2_id2 := lx_rulv1_tbl(idx1).object2_id2;
            lv_rule_info_tbl(lv_process_idx).object3_id2 := lx_rulv1_tbl(idx1).object3_id2;
            lv_rule_info_tbl(lv_process_idx).jtot_object1_code := lx_rulv1_tbl(idx1).jtot_object1_code;
            lv_rule_info_tbl(lv_process_idx).jtot_object2_code := lx_rulv1_tbl(idx1).jtot_object2_code;
            lv_rule_info_tbl(lv_process_idx).jtot_object3_code := lx_rulv1_tbl(idx1).jtot_object3_code;
            lv_rule_info_tbl(lv_process_idx).priority := lx_rulv1_tbl(idx1).priority;
            lv_rule_info_tbl(lv_process_idx).std_template_yn := lx_rulv1_tbl(idx1).std_template_yn;
            lv_rule_info_tbl(lv_process_idx).comments := lx_rulv1_tbl(idx1).comments;
            lv_rule_info_tbl(lv_process_idx).warn_yn := lx_rulv1_tbl(idx1).warn_yn;
            lv_rule_info_tbl(lv_process_idx).rule_information_category := lx_rulv1_tbl(idx1).rule_information_category;
            lv_rule_info_tbl(lv_process_idx).rule_information1 := lx_rulv1_tbl(idx1).rule_information1;
            lv_rule_info_tbl(lv_process_idx).rule_information2 := lx_rulv1_tbl(idx1).rule_information2;
            lv_rule_info_tbl(lv_process_idx).rule_information3 := lx_rulv1_tbl(idx1).rule_information3;
            lv_rule_info_tbl(lv_process_idx).rule_information4 := lx_rulv1_tbl(idx1).rule_information4;
            lv_rule_info_tbl(lv_process_idx).rule_information5 := lx_rulv1_tbl(idx1).rule_information5;
            lv_rule_info_tbl(lv_process_idx).rule_information6 := lx_rulv1_tbl(idx1).rule_information6;
            lv_rule_info_tbl(lv_process_idx).rule_information7 := lx_rulv1_tbl(idx1).rule_information7;
            lv_rule_info_tbl(lv_process_idx).rule_information8 := lx_rulv1_tbl(idx1).rule_information8;
            lv_rule_info_tbl(lv_process_idx).rule_information9 := lx_rulv1_tbl(idx1).rule_information9;
            lv_rule_info_tbl(lv_process_idx).rule_information10 := lx_rulv1_tbl(idx1).rule_information10;
            lv_rule_info_tbl(lv_process_idx).rule_information11 := lx_rulv1_tbl(idx1).rule_information11;
            lv_rule_info_tbl(lv_process_idx).rule_information12 := lx_rulv1_tbl(idx1).rule_information12;
            lv_rule_info_tbl(lv_process_idx).rule_information13 := lx_rulv1_tbl(idx1).rule_information13;
            lv_rule_info_tbl(lv_process_idx).rule_information14 := lx_rulv1_tbl(idx1).rule_information14;
            lv_rule_info_tbl(lv_process_idx).rule_information15 := lx_rulv1_tbl(idx1).rule_information15;
            lv_rule_info_tbl(lv_process_idx).template_yn  := lx_rulv1_tbl(idx1).template_yn;
            lv_rule_info_tbl(lv_process_idx).ans_set_jtot_object_code := lx_rulv1_tbl(idx1).ans_set_jtot_object_code;
            lv_rule_info_tbl(lv_process_idx).ans_set_jtot_object_id1 := lx_rulv1_tbl(idx1).ans_set_jtot_object_id1;
            lv_rule_info_tbl(lv_process_idx).ans_set_jtot_object_id2 := lx_rulv1_tbl(idx1).ans_set_jtot_object_id2;
            lv_rule_info_tbl(lv_process_idx).display_sequence := lx_rulv1_tbl(idx1).display_sequence;
          EXIT WHEN (idx1 = lx_rulv_count);
        END LOOP; -- end of loop next to lx_rulv_count > 0
        IF(lv_process_idx > 0)THEN
          okl_rgrp_rules_process_pvt.process_rule_group_rules(p_api_version   => p_api_version
                                                             ,p_init_msg_list => p_init_msg_list
                                                             ,x_return_status => x_return_status
                                                             ,x_msg_count     => x_msg_count
                                                             ,x_msg_data      => x_msg_data
                                                             ,p_chr_id        => p_orig_chr_id
                                                             ,p_line_id       => null
                                                             ,p_cpl_id        => null
                                                             ,p_rrd_id        => null
                                                             ,p_rgr_tbl       => lv_rule_info_tbl
                                                              );
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_rgrp_rules_process_pvt.process_rule_group_rules returned with status '||x_return_status
                                    );
          END IF;
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF; -- end of lx_rulv_count > 0
    END LOOP; -- end of for loop

    -- now process for the new rule group records that have been added and their child rules
    FOR cv_get_new_rl_rec IN c_get_new_rl_csr(p_orig_chr_id, p_creq_chr_id) LOOP
      okl_rule_apis_pvt.get_contract_rgs(p_api_version   => p_api_version
                                        ,p_init_msg_list => p_init_msg_list
                                        ,p_chr_id        => p_creq_chr_id
                                        ,p_cle_id        => null
                                        ,p_rgd_code      => cv_get_new_rl_rec.rgd_code
                                        ,x_return_status => x_return_status
                                        ,x_msg_count     => x_msg_count
                                        ,x_msg_data      => x_msg_data
                                        ,x_rgpv_tbl      => lx_new_rgp_tbl
                                        ,x_rg_count      => lx_new_rg_count
                                        );
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_rule_apis_pvt.get_contract_rgs returned with status '||x_return_status
                                );
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF(lx_new_rg_count > 0)THEN
        lv_new_rgp_tbl := lx_new_rgp_tbl;
        FOR i IN 1..lv_new_rgp_tbl.COUNT LOOP
          lv_new_rgp_tbl(i).id := NULL;
          lv_new_rgp_tbl(i).chr_id := p_orig_chr_id;
          lv_new_rgp_tbl(i).dnz_chr_id := p_orig_chr_id;
          lv_new_rgp_tbl(i).cle_id := NULL;
          okl_okc_migration_pvt.create_rule_group(p_api_version   => p_api_version
                                                 ,p_init_msg_list => p_init_msg_list
                                                 ,x_return_status => x_return_status
                                                 ,x_msg_count     => x_msg_count
                                                 ,x_msg_data      => x_msg_data
                                                 ,p_rgpv_rec      => lv_new_rgp_tbl(i)
                                                 ,x_rgpv_rec      => x_new_rgp_rec
                                                 );
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_okc_migration_pvt.create_rule_group returned with status '||x_return_status
                                    );
          END IF;
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- this is a new rule group all together that has to be created on the original agreement
          -- for the older rule group on the change request, we need to determine the rules that
          -- were present on the change request and copy those rules under this new rule group
          lv_rgpv_r2_rec.id := cv_get_new_rl_rec.id;
          lv_rgpv_r2_rec.rgd_code := cv_get_new_rl_rec.rgd_code;
          lv_rgpv_r2_rec.chr_id := p_creq_chr_id;
          lv_rgpv_r2_rec.dnz_chr_id := p_creq_chr_id;
          -- now create the rule based on the rule group record creation status
          -- for the rule record, the rgp_id should be the generated id of the new rule group record
          -- fetch the rule information for this rule group record
          okl_rule_apis_pvt.get_contract_rules(p_api_version   => p_api_version
                                              ,p_init_msg_list => p_init_msg_list
                                              ,p_rgpv_rec      => lv_rgpv_r2_rec
                                              ,p_rdf_code      => null -- we want all the rules under this rule group
                                              ,x_return_status => x_return_status
                                              ,x_msg_count     => x_msg_count
                                              ,x_msg_data      => x_msg_data
                                              ,x_rulv_tbl      => lx_rulv2_tbl
                                              ,x_rule_count    => lv_rulv2_count
                                              );
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_rule_apis_pvt.get_contract_rules1 returned with status '||x_return_status
                                    );
          END IF;
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          FOR j IN 1..lv_rulv2_count LOOP
            lx_rulv2_tbl(j).rgp_id := x_new_rgp_rec.id;
            lx_rulv2_tbl(j).dnz_chr_id := p_orig_chr_id;
            -- sjalasut: take care of the rule_information1 column that we populate with cpl_id for the vendor
            -- residual shre. this column now needs to point to the id of okc_k_party_roles on the original
            -- program agreement. the value from the get_contract_rules gives us the cpl_id that points to the
            -- change request
            -- vendor residual share percent is a very specific case. test if the rule belongs to vendor residual
            -- percentage before assigning the new cpl_id to the rule_information1 field.
            IF(lx_rulv2_tbl(j).rule_information_category = 'VGLRSP')THEN
              lv_rule_information1 := null;
              lv_rule_information1 := get_original_cpl_id(p_new_cpl_id => lx_rulv2_tbl(j).rule_information1
                                                         ,p_orig_chr_id => p_orig_chr_id
                                                         ,p_creq_chr_id => p_creq_chr_id
                                                         );
              lx_rulv2_tbl(j).rule_information1 :=lv_rule_information1;
            END IF;
          END LOOP;
          IF(lv_rulv2_count > 0)THEN
            okl_rule_pub.create_rule(p_api_version   => p_api_version
                                    ,p_init_msg_list => p_init_msg_list
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,p_rulv_tbl      => lx_rulv2_tbl
                                    ,x_rulv_tbl      => x_rulv2_tbl
                                    );
            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                      l_module,
                                      'okl_rule_pub.create_rule returned with status '||x_return_status
                                      );
            END IF;
            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END LOOP; -- end of for loop for processing new rule group and new rules

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_terms');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_terms;

  PROCEDURE sync_vendor_disb_setup(p_api_version   IN  NUMBER
                                  ,p_init_msg_list IN  VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                  ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                  ) IS
    CURSOR c_get_disb_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT pay.pay_site_id
          ,pay.payment_term_id
          ,pay.payment_method_code
          ,pay.pay_group_code
          ,pay.vendor_id
          ,pay.id
          ,role.rle_code
          ,role.object1_id1
          ,role.object1_id2
          ,role.jtot_object1_code
          ,role.id cpl_id
      FROM okl_party_payment_dtls pay
          ,okc_k_party_roles_b role
     WHERE pay.cpl_id = role.id
       AND role.cle_id IS NULL
       AND role.dnz_chr_id = cp_chr_id;

    CURSOR c_get_orig_disb_csr(cp_chr_id okc_k_headers_b.id%TYPE
                              ,cp_rle_code okc_k_party_roles_b.rle_code%TYPE
                              ,cp_object1_id1 okc_k_party_roles_b.object1_id1%TYPE
                              ,cp_object1_id2 okc_k_party_roles_b.object1_id2%TYPE
                              ,cp_jtot_code okc_k_party_roles_b.jtot_object1_code%TYPE)IS
    SELECT role.id
          ,payment.id payment_id
      FROM okc_k_party_roles_b role
          ,okl_party_payment_dtls payment
     WHERE role.dnz_chr_id = p_orig_chr_id
       AND role.chr_id IS NOT NULL
       AND role.chr_id = cp_chr_id
       AND role.rle_code = cp_rle_code
       AND role.object1_id1 = cp_object1_id1
       AND role.object1_id2 = cp_object1_id2
       AND role.jtot_object1_code = cp_jtot_code
       AND role.id = payment.cpl_id;
       --udhenuko Bug 5201243 Commenting as the vendor and party need not be same
       --AND payment.vendor_id = cp_object1_id1;

    CURSOR c_get_party_role_csr(cp_chr_id okc_k_headers_b.id%TYPE
                               ,cp_rle_code okc_k_party_roles_b.rle_code%TYPE
                               ,cp_object1_id1 okc_k_party_roles_b.object1_id1%TYPE
                               ,cp_object1_id2 okc_k_party_roles_b.object1_id2%TYPE
                               ,cp_jtot_code okc_k_party_roles_b.jtot_object1_code%TYPE)IS
    SELECT role.id
      FROM okc_k_party_roles_b role
     WHERE role.dnz_chr_id = cp_chr_id
       AND role.chr_id IS NOT NULL
       AND role.chr_id = p_orig_chr_id
       AND role.rle_code = cp_rle_code
       AND role.object1_id1 = cp_object1_id1
       AND role.object1_id2 = cp_object1_id2
       AND role.jtot_object1_code = cp_jtot_code;

    lv_cpl_id okc_k_party_roles_b.id%TYPE;
    lv_payment_id okl_party_payment_dtls.id%TYPE;

    lv_srfvv_rec okl_subsidy_rfnd_dtls_pvt.srfvv_rec_type;
    x_srfvv_rec okl_subsidy_rfnd_dtls_pvt.srfvv_rec_type;
    lv_party_role_id okc_k_party_roles_b.id%TYPE;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SYNC_VENDOR_DISB_SETUP';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_SYNC_CR_PVT.SYNC_VENDOR_DISB_SETUP';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRCRSB.pls call sync_vendor_disb_setup');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- by the time control reaches here, the party records would have been merged. therefore the logic of merging the
    -- Disbursement setup is, to find the correct party record on PA and see if that party has disbursement info set, if so then update that info
    -- if something has changed between the PA and the CR. if the PA does not have a disbursement info, then create it from the CR (if CR has one)

    -- get all the disbursement setup records from the change request parties
    FOR creq_disb_rec IN c_get_disb_csr(cp_chr_id => p_creq_chr_id) LOOP
      -- now find the cpl_id on the original agreement for this party information
      OPEN c_get_orig_disb_csr(cp_chr_id => p_orig_chr_id
                               ,cp_rle_code => creq_disb_rec.rle_code
                               ,cp_object1_id1 => creq_disb_rec.object1_id1
                               ,cp_object1_id2 => creq_disb_rec.object1_id2
                               ,cp_jtot_code => creq_disb_rec.jtot_object1_code
                               );
      FETCH c_get_orig_disb_csr INTO lv_cpl_id, lv_payment_id;
      IF(c_get_orig_disb_csr%FOUND)THEN
        CLOSE c_get_orig_disb_csr;
        -- this is the case of update the original disbursement record on the Program Agreement
        lv_srfvv_rec.cpl_id := lv_cpl_id;
        lv_srfvv_rec.id := lv_payment_id;

        lv_srfvv_rec.vendor_id := creq_disb_rec.vendor_id;
        lv_srfvv_rec.pay_site_id := creq_disb_rec.pay_site_id;
        lv_srfvv_rec.payment_term_id := creq_disb_rec.payment_term_id;
        lv_srfvv_rec.payment_method_code := creq_disb_rec.payment_method_code;
        lv_srfvv_rec.pay_group_code := creq_disb_rec.pay_group_code;

        --udhenuko Bug 5201243 Calling OKL_VP_PARTY_PAYMENT_PVT API for update
        OKL_VP_PARTY_PAYMENT_PVT.update_party_pymnt_dtls(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_srfvv_rec     => lv_srfvv_rec
                                                    ,x_srfvv_rec     => x_srfvv_rec
                                                     );
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT, l_module, 'okl_subsidy_rfnd_dtls_pvt.update_refund_dtls '|| x_return_status);
        END IF;

        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        CLOSE c_get_orig_disb_csr;
        -- we need to create a Disbursement Setup Record for the Program Agreement
        -- we need to determine the id of okc_k_headers_b for the party in context. this value will be used to populate the cpl_id
        -- in okl_party_payment_dtls
        OPEN c_get_party_role_csr(cp_chr_id => p_orig_chr_id
                                 ,cp_rle_code => creq_disb_rec.rle_code
                                 ,cp_object1_id1 => creq_disb_rec.object1_id1
                                 ,cp_object1_id2 => creq_disb_rec.object1_id2
                                 ,cp_jtot_code => creq_disb_rec.jtot_object1_code
                                 );
        FETCH c_get_party_role_csr INTO lv_party_role_id;
        IF(c_get_party_role_csr%FOUND)THEN
          CLOSE c_get_party_role_csr;
          lv_srfvv_rec.id := NULL;
          lv_srfvv_rec.cpl_id := lv_party_role_id;
          lv_srfvv_rec.vendor_id := creq_disb_rec.vendor_id;
          lv_srfvv_rec.pay_site_id := creq_disb_rec.pay_site_id;
          lv_srfvv_rec.payment_term_id := creq_disb_rec.payment_term_id;
          lv_srfvv_rec.payment_method_code := creq_disb_rec.payment_method_code;
          lv_srfvv_rec.pay_group_code := creq_disb_rec.pay_group_code;

          --udhenuko Bug 5201243 Calling OKL_VP_PARTY_PAYMENT_PVT API for create
          OKL_VP_PARTY_PAYMENT_PVT.create_party_pymnt_dtls(p_api_version   => p_api_version
                                                      ,p_init_msg_list => p_init_msg_list
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count     => x_msg_count
                                                      ,x_msg_data      => x_msg_data
                                                      ,p_srfvv_rec     => lv_srfvv_rec
                                                      ,x_srfvv_rec     => x_srfvv_rec
                                                       );
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT, l_module, 'okl_subsidy_rfnd_dtls_pvt.create_refund_dtls '|| x_return_status);
          END IF;

          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          CLOSE c_get_party_role_csr;
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT, l_module, 'could not determine the original party on the parent pa '||
            creq_disb_rec.rle_code||' '||creq_disb_rec.object1_id1||' '||creq_disb_rec.object1_id2||' '||creq_disb_rec.jtot_object1_code );
          END IF;
          -- need to log here because this is an exception case - unable to find the original party on the PA
        END IF; -- end of c_get_party_role_csr%FOUND

      END IF;
    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRCRSB.pls call sync_vendor_disb_setup');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END sync_vendor_disb_setup;

END okl_vp_sync_cr_pvt;

/
