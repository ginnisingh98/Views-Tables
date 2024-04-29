--------------------------------------------------------
--  DDL for Package Body OKL_VP_CHANGE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_CHANGE_REQUEST_PVT" AS
/* $Header: OKLRVCRB.pls 120.4 2005/09/21 07:19:11 sjalasut noship $ */

  -- Global Message Constants
  G_PENDING_CHANGE_REQ_EXISTS CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_PEND_CREQ_EXIST'; -- token AGR_NUMBER
  G_NOT_NEW_PASS_CR CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_NOT_NEW_PASS_CR'; -- token CHANGE_REQ_NUM
  G_NO_AGR_COPY CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_NO_AGR_COPY_FOUND'; -- token CHANGE_REQ_NUM
  G_CR_PARMS_MISSING CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_CR_PARAM_MISSING'; -- no token
  G_NO_PARAM_STS_CODE CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_CR_NO_STS_PARAM'; -- no token
  G_INVALID_STS_INCOMP CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INVAL_STS_INCOMP'; -- token CHANGE_REQ_NUM
  G_INVALID_STS_PENDING CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INVAL_STS_PENDING'; -- token CHANGE_REQ_NUM
  G_INVALID_STS_APPROVED CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INVAL_STS_APPROVED'; -- token CHANGE_REQ_NUM
  G_NOT_ACTIVE_AGREEMENT CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_NOT_ACTIVE_AGREEMENT'; -- token AGR_NUMBER
  G_INVALID_STS_PASSED CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INVAL_STS_PASSED'; -- token CHANGE_REQ_NUM
  G_ONE_REASON_REQD CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_ONE_CR_REASON_REQD';
  G_SYSTEM_COPY_MSG fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_CR_SYSTEM_COPY';

  G_NO_ROWS_SELECTED CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_LLA_NO_ROW_SELECTED';
  -- Global lookup_code constants
  G_ARGREEMENT_TYPE_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'AGREEMENT';
  G_ASSOCIATE_TYPE_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ASSOCIATION';

  G_ABANDONED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ABANDONED';
  G_APPROVED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'APPROVED';
  G_COMPLETED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'COMPLETED';
  G_INCOMPLETE_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'INCOMPLETE';
  G_NEW_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'NEW';
  G_PENDING_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PENDING_APPROVAL';
  G_REJECTED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'REJECTED';
  G_PASSED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PASSED';
  G_ACTIVE_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ACTIVE';
  G_SYSTEM_REASON_CD CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'SYSTEM';

  -- local procedures/functions. START

  FUNCTION generate_change_req_num RETURN okl_vp_change_requests.change_request_number%TYPE IS
    -- cursor to fetch the next available change request number
    CURSOR c_get_next_cr_num IS
    SELECT okl_vp_change_req_num_seq.NEXTVAL
      FROM dual;
    lv_new_change_request_number okl_vp_change_requests.change_request_number%TYPE;
  BEGIN
    OPEN c_get_next_cr_num; FETCH c_get_next_cr_num INTO lv_new_change_request_number;
    CLOSE c_get_next_cr_num;
    RETURN lv_new_change_request_number;
  END generate_change_req_num;

  PROCEDURE historize_agreement(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_vcrv_rec      IN  vcrv_rec_type
                               ,p_agreement_number IN okc_k_headers_b.contract_number%TYPE
                               ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                ) IS
    lv_vcrv_rec vcrv_rec_type;
    lv_calc_agr_number VARCHAR2(100);
    lv_vagr_hdr_rec  okl_vp_copy_contract_pvt.copy_header_rec_type;
    lx_new_agr_id okc_k_headers_b.id%TYPE;
    lv_khrv_rec okl_khr_pvt.khrv_rec_type;
    x_khrv_rec okl_khr_pvt.khrv_rec_type;
    lv_vrrv_rec okl_vrr_pvt.vrrv_rec_type;
    x_vrrv_rec okl_vrr_pvt.vrrv_rec_type;

  BEGIN
    -- get the change request number from the sequence, this call is necessary as change request number is used
    -- in the construction of the new agreement number
    lv_vcrv_rec.change_request_number := generate_change_req_num;

    lv_calc_agr_number := TRIM(RPAD(SUBSTR(LPAD((p_agreement_number || lv_vcrv_rec.change_request_number),120,' ') ,
                          length(LPAD((p_agreement_number || lv_vcrv_rec.change_request_number),120,' ')) - 120),120, ' '));
    -- construct the record to call copy vendor program api
    lv_vagr_hdr_rec := NULL;
    lv_vagr_hdr_rec.p_id := p_vcrv_rec.chr_id; -- this is the original agreement id whose change request has been requested
    lv_vagr_hdr_rec.p_to_agreement_number := lv_calc_agr_number;
    lv_vagr_hdr_rec.p_template_yn := 'N';
    -- create a new agreement from the existing agreement, this new agreement is created for the first time for tracking history
    okl_vp_copy_contract_pub.copy_contract(p_api_version   => p_api_version
                                          ,p_init_msg_list => p_init_msg_list
                                          ,x_return_status => x_return_status
                                          ,x_msg_count     => x_msg_count
                                          ,x_msg_data      => x_msg_data
                                          ,p_copy_rec      => lv_vagr_hdr_rec
                                          ,x_new_contract_id => lx_new_agr_id
                                           );
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                  ,p_init_msg_list => p_init_msg_list
                                                  ,x_return_status => x_return_status
                                                  ,x_msg_count     => x_msg_count
                                                  ,x_msg_data      => x_msg_data
                                                  ,p_khr_status    => G_ABANDONED_STS_CODE
                                                  ,p_chr_id        => lx_new_agr_id -- this is the id of the backup copy agmnt
                                                   );
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- construct other parameters for the change request. the chr_id of this change request is the parent agreement
    -- the new agreement can be derived via the crs_id value in the okl_k_headers table
    lv_vcrv_rec.chr_id := p_vcrv_rec.chr_id;
    lv_vcrv_rec.change_type_code := p_vcrv_rec.change_type_code;
    lv_vcrv_rec.status_code := G_COMPLETED_STS_CODE;
    -- the request date will be the date on which the first change request has been initiated
    lv_vcrv_rec.request_date := TRUNC(SYSDATE);

    create_change_request_header(p_api_version   => p_api_version
                                ,p_init_msg_list => p_init_msg_list
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,p_vcrv_rec      => lv_vcrv_rec
                                ,x_vcrv_rec      => x_vcrv_rec
                                 );
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- since this is a system back up copy of the agreement, we need to mark this agreement as a SYSTEM copy
    -- to achieve this, we create a reason code on the backed up change request and put the notes as
    -- 'System generated change request to maintain history'
    -- populate the reason record
    lv_vrrv_rec.crs_id := x_vcrv_rec.id;
    lv_vrrv_rec.reason_code := G_SYSTEM_REASON_CD;
    -- now also populate the notes for this reason, the note is derived from fnd_new_messages
    fnd_message.set_name(G_APP_NAME, G_SYSTEM_COPY_MSG);
    lv_vrrv_rec.note := fnd_message.get;

    okl_vrr_pvt.insert_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_vrrv_rec      => lv_vrrv_rec
                          ,x_vrrv_rec      => x_vrrv_rec
                          );
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- now that the agreement copy is created, set the change request id in the okl_k_headers to the created change request
    lv_khrv_rec.id := lx_new_agr_id;
    lv_khrv_rec.crs_id := x_vcrv_rec.id;
    okl_khr_pvt.update_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_khrv_rec      => lv_khrv_rec
                          ,x_khrv_rec      => x_khrv_rec);
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  END historize_agreement;

  -- local procedures/functions. END

  PROCEDURE create_change_request_header(p_api_version   IN  NUMBER
                                        ,p_init_msg_list IN  VARCHAR2
                                        ,x_return_status OUT NOCOPY VARCHAR2
                                        ,x_msg_count     OUT NOCOPY NUMBER
                                        ,x_msg_data      OUT NOCOPY VARCHAR2
                                        ,p_vcrv_rec      IN  vcrv_rec_type
                                        ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                         ) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CHANGE_REQUEST_HDR';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.CREATE_CHANGE_REQUEST_HEADER';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call create_change_request_header');
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

    okl_vcr_pvt.insert_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_vcrv_rec      => p_vcrv_rec
                          ,x_vcrv_rec      => x_vcrv_rec
                           );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vcr_pvt.insert_row returned with status '||x_return_status||' x_msg_data '||x_msg_data||' id '||x_vcrv_rec.id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call create_change_request_header');
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

  END create_change_request_header;

  PROCEDURE update_change_request_header(p_api_version   IN  NUMBER
                                        ,p_init_msg_list IN  VARCHAR2
                                        ,x_return_status OUT NOCOPY VARCHAR2
                                        ,x_msg_count     OUT NOCOPY NUMBER
                                        ,x_msg_data      OUT NOCOPY VARCHAR2
                                        ,p_vcrv_rec      IN  vcrv_rec_type
                                        ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                         ) IS

    CURSOR c_get_chr_id (cp_change_request_id okl_vp_change_requests.id%TYPE)IS
    SELECT chr_id
      FROM okl_vp_change_requests
     WHERE id = cp_change_request_id;
    lv_chr_id okc_k_headers_b.id%TYPE;

    lv_vcrv_rec okl_vcr_pvt.vcrv_rec_type;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'UPDATE_CHANGE_REQUEST_HDR';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.UPDATE_CHANGE_REQUEST_HEADER';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call update_change_request_header');
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

    lv_vcrv_rec := p_vcrv_rec;
    -- get the chr_id if not passed
    IF(lv_vcrv_rec.chr_id IS NULL)THEN
      OPEN c_get_chr_id(lv_vcrv_rec.id); FETCH c_get_chr_id INTO lv_chr_id;
      CLOSE c_get_chr_id;
      lv_vcrv_rec.chr_id := lv_chr_id;
    END IF;
    okl_vcr_pvt.update_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_vcrv_rec      => lv_vcrv_rec
                          ,x_vcrv_rec      => x_vcrv_rec
                           );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vcr_pvt.update_row returned with status '||x_return_status||' x_msg_data '||x_msg_data||' id '||x_vcrv_rec.id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call update_change_request_header');
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
  END update_change_request_header;

  PROCEDURE create_change_request_lines(p_api_version   IN  NUMBER
                                       ,p_init_msg_list IN  VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vrrv_tbl      IN  vrrv_tbl_type
                                       ,x_vrrv_tbl      OUT NOCOPY vrrv_tbl_type
                                       ,x_request_status OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        ) IS
    lv_crs_id okl_vp_change_requests.id%TYPE;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CHANGE_REQUEST_LNS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.CREATE_CHANGE_REQUEST_LINES';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call create_change_request_lines');
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

    okl_vrr_pvt.insert_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_vrrv_tbl      => p_vrrv_tbl
                          ,x_vrrv_tbl      => x_vrrv_tbl
                           );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vrr_pvt.insert_row returned with status '||x_return_status||' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the master change request id and re-set the status of the change request if needed
    -- this scenario could be possible if the user adds more reasons once the change request is validated successfully.
    lv_crs_id := p_vrrv_tbl(p_vrrv_tbl.FIRST).crs_id;
    IF(p_vrrv_tbl.COUNT > 0 AND lv_crs_id IS NOT NULL AND lv_crs_id <> OKL_API.G_MISS_NUM)THEN
      cascade_request_status_edit(p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_vp_crq_id     => lv_crs_id
                                 ,x_status_code   => x_request_status
                                  );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call create_change_request_lines');
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
  END create_change_request_lines;

  PROCEDURE update_change_request_lines(p_api_version   IN  NUMBER
                                       ,p_init_msg_list IN  VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vrrv_tbl      IN  vrrv_tbl_type
                                       ,x_vrrv_tbl      OUT NOCOPY vrrv_tbl_type
                                       ,x_request_status OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        ) IS
    lv_crs_id okl_vp_change_requests.id%TYPE;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'UPDATE_CHANGE_REQUEST_LNS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.UPDATE_CHANGE_REQUEST_LINES';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call update_change_request_lines');
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

    okl_vrr_pvt.update_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_vrrv_tbl      => p_vrrv_tbl
                          ,x_vrrv_tbl      => x_vrrv_tbl
                           );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_vrr_pvt.update_row returned with status '||x_return_status||' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the master change request id and re-set the status of the change request if needed
    -- this scenario could be possible if the user updates one or more reasons once the change request is validated successfully.
    lv_crs_id := p_vrrv_tbl(p_vrrv_tbl.FIRST).crs_id;
    IF(p_vrrv_tbl.COUNT > 0 AND lv_crs_id IS NOT NULL AND lv_crs_id <> OKL_API.G_MISS_NUM)THEN
      cascade_request_status_edit(p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_vp_crq_id     => lv_crs_id
                                 ,x_status_code   => x_request_status
                                  );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call update_change_request_lines');
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
  END update_change_request_lines;

  PROCEDURE delete_change_request_lines(p_api_version   IN  NUMBER
                                       ,p_init_msg_list IN  VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vrrv_tbl      IN  vrrv_tbl_type
                                       ,x_request_status OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        ) IS
    CURSOR c_get_more_reasons_csr(cp_creq_id okl_vp_change_requests.id%TYPE)IS
    SELECT 'X'
      FROM okl_vp_cr_reasons
     WHERE crs_id = cp_creq_id;
    lv_dummy VARCHAR2(1);
    lv_crs_id okl_vp_change_requests.id%TYPE;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'DELETE_CHANGE_REQUEST_LNS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.DELETE_CHANGE_REQUEST_LINES';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call delete_change_request_lines');
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
    IF(p_vrrv_tbl.COUNT > 0)THEN
      okl_vrr_pvt.delete_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_vrrv_tbl      => p_vrrv_tbl
                             );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vrr_pvt.delete_row returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- now check if there are any change request reasons still for this change request. if there are no change request reasons
      -- then raise an error. Atleast One Change Request Reason is mandatory for a Change Request
      OPEN c_get_more_reasons_csr(p_vrrv_tbl(p_vrrv_tbl.FIRST).crs_id); FETCH c_get_more_reasons_csr INTO lv_dummy;
      CLOSE c_get_more_reasons_csr;
      IF(NVL(lv_dummy,'Y')<>'X')THEN
        OKL_API.set_message(G_APP_NAME, G_ONE_REASON_REQD);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- get the master change request id and re-set the status of the change request if needed
      -- this scenario could be possible if the user removes one or more reasons once the change request is validated successfully.
      lv_crs_id := p_vrrv_tbl(p_vrrv_tbl.FIRST).crs_id;
      IF(lv_crs_id IS NOT NULL AND lv_crs_id <> OKL_API.G_MISS_NUM)THEN
        cascade_request_status_edit(p_api_version   => p_api_version
                                   ,p_init_msg_list => p_init_msg_list
                                   ,x_return_status => x_return_status
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,p_vp_crq_id     => lv_crs_id
                                   ,x_status_code   => x_request_status
                                    );
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    ELSE
      OKL_API.set_message(G_APP_NAME, G_NO_ROWS_SELECTED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call delete_change_request_lines');
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
  END delete_change_request_lines;


  /* Logic for Creating Change Request: If a Change Request has been requested for Agreement A1 (say)
   *   If this change request is the first one for this agreement, then a backup of the Agreement is taken
   *   and tied with a new change request. The status of the Agreement is set to ABANDONED and the status
   *   of the change request is set to COMPLETED. After this, another copy of the Agreement A1 is created (say A2)
   *   and is tied with a new change Request. The status of the Change Request and the Ageement is NEW. This
   *   is the Change Request which can be modified and submitted for Approval. If such a Change Request is
   *   approved, then the changes between the Agreement attached with this Change Request and the original
   *   agreement A1 are synchornized onto A1
   *
   *   For the case when the Change Request is not the first one, new agreement is created from the originating
   *   agreement and attached with a new change request. The status of the new agreement copy and the change
   *   request is set to NEW. When this agreement attached with the change request is approved, the changes are
   *   synchronized on the main copy. Note that in this scenario, no back up of the original agreement is taken
   *
   */
  PROCEDURE create_change_request(p_api_version   IN  NUMBER
                                 ,p_init_msg_list IN  VARCHAR2
                                 ,x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count     OUT NOCOPY NUMBER
                                 ,x_msg_data      OUT NOCOPY VARCHAR2
                                 ,p_vcrv_rec      IN  vcrv_rec_type
                                 ,p_vrrv_tbl      IN  vrrv_tbl_type
                                 ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                 ,x_vrrv_tbl      OUT NOCOPY vrrv_tbl_type
                                  ) IS
    -- cursor to check if there are any existing change requests
    CURSOR c_chk_pending_req_csr (cp_agreement_id okc_k_headers_b.id%TYPE) IS
    SELECT 'X'
      FROM okl_vp_change_requests creq
     WHERE creq.chr_id = cp_agreement_id
       AND creq.status_code IN ('NEW','INCOMPELTE','REJECTED','PENDING_APPROVAL','PASSED');

    -- cursor to get the agreement number
    CURSOR c_get_agr_num_csr (cp_agreement_id okc_k_headers_b.id%TYPE) IS
    SELECT contract_number, sts_code
      FROM okc_k_headers_b
     WHERE id = cp_agreement_id;

    -- cursor to check if this is the first change request of type AGREEMENT for the agreement
    -- this can be derived by looking at change requests of type AGREEMENT in the context of the original agreement
    CURSOR c_chk_first_cr_csr (cp_agreement_id okc_k_headers_b.id%TYPE)IS
    SELECT 'X'
      FROM okl_vp_change_requests crq
     WHERE crq.chr_id = cp_agreement_id
--       AND crq.change_type_code <> 'ASSOCIATION'
       AND crq.status_code = G_COMPLETED_STS_CODE;

    lv_vcrv_rec vcrv_rec_type;
    xc_vcrv_rec vcrv_rec_type;
    lv_pending_req_cvar VARCHAR2(1);
    lv_agreement_number okc_k_headers_b.contract_number%TYPE;
    lv_agreement_status okc_k_headers_b.sts_code%TYPE;
    lv_calc_agr_number VARCHAR2(100);
    lv_vagr_hdr_rec okl_vp_copy_contract_pvt.copy_header_rec_type;
    lx_new_agr_id okc_k_headers_b.id%TYPE;
    lv_is_first_cr VARCHAR2(1);
    lv_khrv_rec okl_khr_pvt.khrv_rec_type;
    x_khrv_rec okl_khr_pvt.khrv_rec_type;
    x_request_status okl_vp_change_requests.status_code%TYPE;
    lv_vrrv_tbl vrrv_tbl_type;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CHANGE_REQUEST';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.CREATE_CHANGE_REQUEST';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call create_change_request');
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

    lv_vcrv_rec := p_vcrv_rec;

    -- first: verify if all the parameters required for processing are passed.
    IF(lv_vcrv_rec.chr_id IS NULL OR lv_vcrv_rec.chr_id = OKL_API.G_MISS_NUM)THEN
      OKL_API.set_message(G_APP_NAME, G_CR_PARMS_MISSING);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- second: check if there exists a change request already in status NEW, PENDING_APPROVAL, REJCTED, INCOMPLETE or PASSED
    OPEN c_chk_pending_req_csr (lv_vcrv_rec.chr_id); FETCH c_chk_pending_req_csr INTO lv_pending_req_cvar;
    CLOSE c_chk_pending_req_csr;

    -- fetch the agreement number to display in the error message and also for later use
    OPEN c_get_agr_num_csr(lv_vcrv_rec.chr_id); FETCH c_get_agr_num_csr INTO lv_agreement_number, lv_agreement_status;
    CLOSE c_get_agr_num_csr;

    IF(NVL(lv_pending_req_cvar,'Y') = 'X')THEN
      OKL_API.set_message(G_APP_NAME, G_PENDING_CHANGE_REQ_EXISTS, 'AGR_NUMBER', lv_agreement_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- third: check if the agreement is ACTIVE. Change Requests cannot be created for non active agreements
    IF(lv_agreement_status <> G_ACTIVE_STS_CODE)THEN
      OKL_API.set_message(G_APP_NAME, G_NOT_ACTIVE_AGREEMENT, 'AGR_NUMBER', lv_agreement_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- fourth: check there is atleast one change request reason for the AGREEMENT or ASSOCIATION type of change request
    IF(p_vrrv_tbl.COUNT <= 0)THEN
      OKL_API.set_message(G_APP_NAME, G_ONE_REASON_REQD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check if this is the first change request for this vendor agreement and if so, take a backup
    -- of the original agreement and associate with another change request whose status is created as COMPLETED
    -- the status of this backed up agreement should be set to ABANDONED
    OPEN c_chk_first_cr_csr(lv_vcrv_rec.chr_id); FETCH c_chk_first_cr_csr INTO lv_is_first_cr;
    CLOSE c_chk_first_cr_csr;
    -- take a backup of the Agreement
    IF(NVL(lv_is_first_cr,'Y')<>'X')THEN
      historize_agreement(p_api_version   => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_vcrv_rec      => lv_vcrv_rec
                         ,p_agreement_number => lv_agreement_number
                         ,x_vcrv_rec      => xc_vcrv_rec
                          );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of NVL(lv_is_first_cr,'Y')<>'X'

    IF(lv_vcrv_rec.change_type_code=G_ARGREEMENT_TYPE_CODE)THEN
      -- get the change request number from the sequence
      lv_vcrv_rec.change_request_number := generate_change_req_num;

      -- construct the new internal agreement number that would serve as agreement number on the
      -- new copied agreement record. the format is last 30 char of the concatenated string of
      -- agreement number, and the change_request_number (using sequence okl_vp_change_req_num_seq)
      -- lv_calc_agr_number finally returns last 30 characters of the concatenated value
      -- if there are less than 30 char in the resultant string, then lv_calc_agr_number is as good as the resultant string
      lv_calc_agr_number := TRIM(RPAD(SUBSTR(LPAD((lv_agreement_number || lv_vcrv_rec.change_request_number),120,' ') ,
                            length(LPAD((lv_agreement_number || lv_vcrv_rec.change_request_number),120,' ')) - 120),120, ' '));

      -- construct the record to call copy vendor program api
      lv_vagr_hdr_rec := NULL;
      lv_vagr_hdr_rec.p_id := lv_vcrv_rec.chr_id;
      lv_vagr_hdr_rec.p_to_agreement_number := lv_calc_agr_number;
      lv_vagr_hdr_rec.p_template_yn := 'N';
      okl_vp_copy_contract_pub.copy_contract(p_api_version   => p_api_version
                                            ,p_init_msg_list => p_init_msg_list
                                            ,x_return_status => x_return_status
                                            ,x_msg_count     => x_msg_count
                                            ,x_msg_data      => x_msg_data
                                            ,p_copy_rec      => lv_vagr_hdr_rec
                                            ,x_new_contract_id => lx_new_agr_id
                                             );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- create change request header and change request reasons
      lv_vcrv_rec.status_code := 'NEW';
      lv_vcrv_rec.chr_id := lv_vcrv_rec.chr_id;

      -- the request date of the change request is the date on which it was created successfully
      lv_vcrv_rec.request_date := TRUNC(SYSDATE);

      create_change_request_header(p_api_version   => p_api_version
                                  ,p_init_msg_list => p_init_msg_list
                                  ,x_return_status => x_return_status
                                  ,x_msg_count     => x_msg_count
                                  ,x_msg_data      => x_msg_data
                                  ,p_vcrv_rec      => lv_vcrv_rec
                                  ,x_vcrv_rec      => x_vcrv_rec
                                   );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- make sure there are reasons to record and call the api.
      IF(p_vrrv_tbl.COUNT > 0)THEN
        lv_vrrv_tbl := p_vrrv_tbl;
        -- copy the change request id to the child records.
        FOR idx IN 1 .. p_vrrv_tbl.COUNT LOOP
          lv_vrrv_tbl(idx).crs_id :=  x_vcrv_rec.id;
        END LOOP;
        create_change_request_lines(p_api_version   => p_api_version
                                   ,p_init_msg_list => p_init_msg_list
                                   ,x_return_status => x_return_status
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,p_vrrv_tbl      => lv_vrrv_tbl
                                   ,x_vrrv_tbl      => x_vrrv_tbl
                                   ,x_request_status => x_request_status
                                    );
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of p_vrrv_tbl.COUNT > 0

      -- now that the agreement copy is created, set the change request id in the okl_k_headers to the created change request
      -- commenting this call because okl_khr_pvt has not been modified to incl crs_id, template_type_code yet
      lv_khrv_rec.id := lx_new_agr_id;
      lv_khrv_rec.crs_id := x_vcrv_rec.id;
      okl_khr_pvt.update_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_khrv_rec      => lv_khrv_rec
                            ,x_khrv_rec      => x_khrv_rec);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- now copy the out variable of x_vcrv_rec.chr_id to the new agreement id that was created for this
      -- AGREEMENT type of change request. this is essential because the UI depends on this parameter.
      -- this value need not be the same as parent agreement id in case of AGREEMENT type of change request
      x_vcrv_rec.chr_id := lx_new_agr_id;

    ELSIF(lv_vcrv_rec.change_type_code=G_ASSOCIATE_TYPE_CODE)THEN
      -- create change request header and change request reasons
      lv_vcrv_rec.status_code := 'NEW';
      -- get the change request number from the sequence
      lv_vcrv_rec.change_request_number := generate_change_req_num;

      -- the request date of the change request is the date on which it was created successfully
      lv_vcrv_rec.request_date := TRUNC(SYSDATE);

      create_change_request_header(p_api_version   => p_api_version
                                  ,p_init_msg_list => p_init_msg_list
                                  ,x_return_status => x_return_status
                                  ,x_msg_count     => x_msg_count
                                  ,x_msg_data      => x_msg_data
                                  ,p_vcrv_rec      => lv_vcrv_rec
                                  ,x_vcrv_rec      => x_vcrv_rec
                                   );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- make sure there are reasons to record and call the api.
      IF(p_vrrv_tbl.COUNT > 0)THEN
        lv_vrrv_tbl := p_vrrv_tbl;
        -- copy the change request id to the child records.
        FOR idx IN 1 .. p_vrrv_tbl.COUNT LOOP
          lv_vrrv_tbl(idx).crs_id :=  x_vcrv_rec.id;
        END LOOP;
        create_change_request_lines(p_api_version   => p_api_version
                                   ,p_init_msg_list => p_init_msg_list
                                   ,x_return_status => x_return_status
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,p_vrrv_tbl      => lv_vrrv_tbl
                                   ,x_vrrv_tbl      => x_vrrv_tbl
                                   ,x_request_status => x_request_status
                                    );
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of p_vrrv_tbl.COUNT > 0

      -- for ASSOCIATION type of change requests, the associations on the original agreements are copied over to the
      -- new change request. the copy of the original agreement is not created and associated with the change request
      -- (backup is taken in this case too)
      OKL_VP_ASSOCIATIONS_PVT.copy_crs_associations(p_api_version   => p_api_version
                                                   ,p_init_msg_list => p_init_msg_list
                                                   ,x_return_status => x_return_status
                                                   ,x_msg_count     => x_msg_count
                                                   ,x_msg_data      => x_msg_data
                                                   ,p_chr_id        => lv_vcrv_rec.chr_id
                                                   ,p_crs_id        => x_vcrv_rec.id
                                                    );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end if for lv_vcrv_rec.change_type_code=G_ARGREEMENT_TYPE_CODE

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call create_change_request');
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
  END create_change_request;

  PROCEDURE abandon_change_request(p_api_version   IN  NUMBER
                                  ,p_init_msg_list IN  VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_vcrv_rec      IN  vcrv_rec_type
                                  ,x_vcrv_rec      OUT NOCOPY vcrv_rec_type
                                   ) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'ABANDON_CHANGE_REQUEST';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.ABANDON_CHANGE_REQUEST';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call abandon_change_request');
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

    set_change_request_status(p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_vp_crq_id     => p_vcrv_rec.id
                             ,p_status_code   => G_ABANDONED_STS_CODE
                              );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'set_change_request_status for '||p_vcrv_rec.id||' from abandon_change_request returned with status '||x_return_status
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- now set the OUT variables for calling UI or API use
    x_vcrv_rec.id := p_vcrv_rec.id;
    x_vcrv_rec.status_code := G_ABANDONED_STS_CODE;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call abandon_change_request');
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
  END abandon_change_request;

  PROCEDURE set_change_request_status(p_api_version   IN NUMBER
                                     ,p_init_msg_list IN VARCHAR2
                                     ,x_return_status OUT NOCOPY VARCHAR2
                                     ,x_msg_count     OUT NOCOPY NUMBER
                                     ,x_msg_data      OUT NOCOPY VARCHAR2
                                     ,p_vp_crq_id     IN okl_vp_change_requests.id%TYPE
                                     ,p_status_code   IN okl_vp_change_requests.status_code%TYPE
                                      ) IS
    -- cursor to fetch the status of the change request
    CURSOR c_get_cr_dtls_csr (cp_change_req_id okl_vp_change_requests.id%TYPE)IS
    SELECT status_code
          ,change_request_number
          ,change_type_code
          ,chr_id -- this chr_id is for only ASSOCIATION type of change request
      FROM okl_vp_change_requests
     WHERE id = cp_change_req_id;
    cv_get_cr_dtls c_get_cr_dtls_csr%ROWTYPE;

    -- cursor to get the agreement id that is tied to the change request. this agreement id is not the parent agreement
    -- but the agreement that is copied from the parent agreement. this copy will have the crs_id value in okl_k_headers
    CURSOR c_get_creq_chr_id_csr (cp_change_req_id okl_vp_change_requests.id%TYPE)IS
    SELECT chr.id
      FROM okc_k_headers_b chr
          ,okl_k_headers khr
     WHERE chr.id = khr.id
       AND khr.crs_id = cp_change_req_id;
    lv_creq_chr_id okc_k_headers_b.id%TYPE;

    lv_vcrv_rec vcrv_rec_type;
    x_vcrv_rec vcrv_rec_type;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SET_CHANGE_REQUEST_STS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.SET_CHANGE_REQUEST_STATUS';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call set_change_request_status');
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

    IF(p_vp_crq_id IS NULL OR p_vp_crq_id = OKL_API.G_MISS_NUM OR p_status_code IS NULL OR p_status_code = OKL_API.G_MISS_CHAR)THEN
      OKL_API.set_message(G_APP_NAME, G_NO_PARAM_STS_CODE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN c_get_cr_dtls_csr(p_vp_crq_id); FETCH c_get_cr_dtls_csr INTO cv_get_cr_dtls;
    CLOSE c_get_cr_dtls_csr;

    -- if status code is being set to incomplete then the status code in the db should be either PASSED or REJECTED
    -- error otherwise
    IF(G_INCOMPLETE_STS_CODE = p_status_code)THEN
      IF(cv_get_cr_dtls.status_code NOT IN(G_NEW_STS_CODE, G_PASSED_STS_CODE, G_REJECTED_STS_CODE))THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_STS_INCOMP, 'CHANGE_REQ_NUM',cv_get_cr_dtls.change_request_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF(G_PENDING_STS_CODE = p_status_code)THEN
      -- check useful from preventing the user from resubmitting the change request and also to prevent the same workflow
      -- being re-launched
      IF(cv_get_cr_dtls.status_code NOT IN(G_PASSED_STS_CODE))THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_STS_PENDING, 'CHANGE_REQ_NUM',cv_get_cr_dtls.change_request_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF(G_APPROVED_STS_CODE = p_status_code)THEN
      -- if a change request to be approved, the prior status should have been PENDING_APPROVAL, error otherwise
      IF(cv_get_cr_dtls.status_code NOT IN(G_PENDING_STS_CODE))THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_STS_APPROVED, 'CHANGE_REQ_NUM',cv_get_cr_dtls.change_request_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      lv_vcrv_rec.approved_date := TRUNC(SYSDATE);
    ELSIF(G_ABANDONED_STS_CODE = p_status_code)THEN
      -- verify if the change request whose abandonment is requested is in status NEW, PASSED, INCOMPLETE or REJECTED. error otherwise
      -- this check will also prevent user from re-abandoning the change request by use of browser refresh button
      IF(cv_get_cr_dtls.status_code NOT IN ('NEW','PASSED','INCOMPLETE','REJECTED'))THEN
        OKL_API.set_message(G_APP_NAME, G_NOT_NEW_PASS_CR, 'CHANGE_REQ_NUM', cv_get_cr_dtls.change_request_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- for AGREEMENT type of change request, the referred agreement has also be set to status that was set
    -- at the change request level
    -- note that for ASSOCIATION type of change request, there is no agreement copy to update and the original agreement
    -- should not be updated
    IF(cv_get_cr_dtls.change_type_code = G_ARGREEMENT_TYPE_CODE)THEN
      -- now get the copied agreement from okl_k_headers using the change request id
      lv_creq_chr_id := NULL;
      OPEN c_get_creq_chr_id_csr (p_vp_crq_id);
      FETCH c_get_creq_chr_id_csr INTO lv_creq_chr_id; CLOSE c_get_creq_chr_id_csr;
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => p_status_code
                                                    ,p_chr_id        => lv_creq_chr_id -- this is the id of the backup copy agmnt
                                                     );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_status_pub.update_contract_status returned with status '||x_return_status||' x_msg_data '||x_msg_data||' id '||x_vcrv_rec.id
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- now set the status of the change request once the copy agreement has been changed
    -- the updation of this record is applicable to both AGREEMENT type of change request and ASSOCIATION type too.
    lv_vcrv_rec.id := p_vp_crq_id;
    lv_vcrv_rec.chr_id := cv_get_cr_dtls.chr_id; -- this chr_id is the parent agreement id
    lv_vcrv_rec.change_type_code := cv_get_cr_dtls.change_type_code;
    lv_vcrv_rec.change_request_number := cv_get_cr_dtls.change_request_number;
    lv_vcrv_rec.status_code := p_status_code;

    update_change_request_header(p_api_version   => p_api_version
                                ,p_init_msg_list => p_init_msg_list
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,p_vcrv_rec      => lv_vcrv_rec
                                ,x_vcrv_rec      => x_vcrv_rec
                                 );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'update_change_request_header returned with status '||x_return_status||' x_msg_data '||x_msg_data||' id '||x_vcrv_rec.id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call set_change_request_status');
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
  END set_change_request_status;

  PROCEDURE cascade_request_status_edit(p_api_version   IN NUMBER
                                       ,p_init_msg_list IN VARCHAR2
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_vp_crq_id     IN okl_vp_change_requests.id%TYPE
                                       ,x_status_code   OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                        ) IS
    -- cursor to fetch the status of the change request
    CURSOR c_get_cr_sts_csr (cp_change_req_id okl_vp_change_requests.id%TYPE)IS
    SELECT status_code
      FROM okl_vp_change_requests
     WHERE id = cp_change_req_id;
    c_get_cr_sts_rec c_get_cr_sts_csr%ROWTYPE;

    lv_vcrv_rec vcrv_rec_type;
    x_vcrv_rec vcrv_rec_type;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CASCADE_REQUEST_STS';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.CASCADE_REQUEST_STATUS_EDIT';
    l_debug_enabled VARCHAR2(10);

  BEGIN
   x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call cascade_request_status_edit');
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

    IF(p_vp_crq_id IS NULL OR p_vp_crq_id = OKL_API.G_MISS_NUM)THEN
      OKL_API.set_message(G_APP_NAME, OKL_API.G_REQUIRED_VALUE, OKL_API.G_COL_NAME_TOKEN, 'ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- if the change request is in status PASSED then we need to set it back to INCOMPLETE
    OPEN c_get_cr_sts_csr(p_vp_crq_id); FETCH c_get_cr_sts_csr INTO c_get_cr_sts_rec;
    CLOSE c_get_cr_sts_csr;
    -- for a PASSED change request and REJECTED change request, when updated, the status should be toggled back
    -- to INCOMPLETE
    IF(c_get_cr_sts_rec.status_code = G_PASSED_STS_CODE OR c_get_cr_sts_rec.status_code = G_REJECTED_STS_CODE)THEN
      set_change_request_status(p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_vp_crq_id     => p_vp_crq_id
                               ,p_status_code   => G_INCOMPLETE_STS_CODE
                                );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'set_change_request_status returned with status '||x_return_status||' x_msg_data '||x_msg_data||' id '||x_vcrv_rec.id
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      x_status_code := G_INCOMPLETE_STS_CODE;
    ELSE
      x_status_code := c_get_cr_sts_rec.status_code;
    END IF; -- end of c_get_cr_sts_rec.status_code = G_PASSED_STS_CODE

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call cascade_request_status_edit');
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
  END cascade_request_status_edit;

  PROCEDURE submit_cr_for_approval(p_api_version   IN NUMBER
                                  ,p_init_msg_list IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                  ,x_status_code   OUT NOCOPY okl_vp_change_requests.status_code%TYPE
                                   ) IS

    -- cursor to identify the change request from the passed in agreement id
    CURSOR c_get_change_req_csr(cp_chr_id okl_k_headers.id%TYPE)IS
    SELECT id
      FROM okl_vp_change_requests
     WHERE chr_id = cp_chr_id
       AND status_code = G_PASSED_STS_CODE;
    lv_change_request_id okl_vp_change_requests.id%TYPE;

    CURSOR c_get_crs_id_csr(cp_chr_id okl_k_headers.id%TYPE)IS
    SELECT khr.crs_id
      FROM okl_k_headers khr
          ,okc_k_headers_b chr
     WHERE chr.id = khr.id
       AND chr.sts_code = G_PASSED_STS_CODE
       AND chr.id = cp_chr_id;

    l_approval_process VARCHAR2(30);
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_CR_FOR_APPROVAL';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_CHANGE_REQUEST_PVT.SUBMIT_CR_FOR_APPROVAL';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVCRB.pls call submit_cr_for_approval');
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

    -- get the change request id from the agreement id; error if no change request found
    OPEN c_get_change_req_csr(p_chr_id); FETCH c_get_change_req_csr INTO lv_change_request_id;
    IF(c_get_change_req_csr%NOTFOUND)THEN
      CLOSE c_get_change_req_csr;
      -- this is the case of AGREEMENT type of change request. from the chr_id, we need to derive the crs_id from okl_k_headers
      -- if no crs_id exists, then error
      OPEN c_get_crs_id_csr(p_chr_id); FETCH c_get_crs_id_csr INTO lv_change_request_id;
      IF(c_get_crs_id_csr%NOTFOUND)THEN
        CLOSE c_get_crs_id_csr;
        OKL_API.set_message(G_APP_NAME, G_CR_PARMS_MISSING);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
        CLOSE c_get_crs_id_csr;
      END IF;
    ELSE
      CLOSE c_get_change_req_csr;
    END IF;

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'lv_change_request_id '||lv_change_request_id||' from cursor '
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    x_status_code := G_PENDING_STS_CODE;
    -- now set the change request to PENDING_APPROVAL
    -- this procedure will automatically set the ageement associated with the change request (only in case of AGREEMENT type of change request)
    -- to PENDING_APPROVAL
    set_change_request_status(p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_vp_crq_id     => lv_change_request_id
                             ,p_status_code   => G_PENDING_STS_CODE
                              );
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- read the profile OKL: Change Request Approval Process
    l_approval_process := fnd_profile.value('OKL_VP_CR_APPROVAL_PROCESS');
    IF(NVL(l_approval_process,'NONE')='NONE')THEN
      -- since no option is set at the profile, approve the change request by default
      -- before approving the change request, we need to sync up the change request
      -- agreement and the original agreement. the details and combinations are handled in the API
      -- please note that the sync API is also responsible for updating the change request to COMPLETED
      -- and the associated agreement (only for AGREEMENT type of change  request) to ABANDONED
      okl_vp_sync_cr_pvt.sync_change_request(p_api_version       => p_api_version
                                            ,p_init_msg_list     => p_init_msg_list
                                            ,x_return_status     => x_return_status
                                            ,x_msg_count         => x_msg_count
                                            ,x_msg_data          => x_msg_data
                                            ,p_change_request_id => lv_change_request_id
                                            );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vp_sync_cr_pvt.sync_change_request on change request id '||lv_change_request_id||' returned with status '||x_return_status
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- when the change request is synced up successfully, the status of the change request is COMPLETED and the status of the agreement
      -- associated with the change request is set to ABANDONED.
      -- the OUT variable is assigned to COMPLETED so that this value can be utillized by the caller program or UI
      x_status_code := G_COMPLETED_STS_CODE;

    ELSIF(l_approval_process in ('AME','WF'))THEN
      okl_vp_cr_wf.raise_cr_event_approval(p_api_version    => p_api_version
                                          ,p_init_msg_list  => p_init_msg_list
                                          ,x_return_status  => x_return_status
                                          ,x_msg_count      => x_msg_count
                                          ,x_msg_data       => x_msg_data
                                          ,p_vp_crq_id      => lv_change_request_id);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vp_cr_wf.raise_oa_event_approval on change request id '||lv_change_request_id||' returned with status '||x_return_status
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- copy the OUT variable as PENDING_APPROVAL
      x_status_code := G_PENDING_STS_CODE;
    END IF; -- end of NVL(l_approval_process,'NONE')='NONE'

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count, x_msg_data  => x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVCRB.pls call submit_cr_for_approval');
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
    END submit_cr_for_approval;

  FUNCTION get_assoc_agr_number(p_change_request_id IN okl_vp_change_requests.id%TYPE) RETURN VARCHAR2 IS
    CURSOR c_get_chreq_csr (cp_ch_req_id okl_vp_change_requests.id%TYPE) IS
    SELECT chr_id
          ,change_type_code
          ,status_code
      FROM okl_vp_change_requests
     WHERE id = cp_ch_req_id;
    cv_chreq_rec c_get_chreq_csr%ROWTYPE;

    CURSOR c_get_chr_num_csr(cp_ch_req_id okl_vp_change_requests.id%TYPE) IS
    SELECT contract_number
      FROM okc_k_headers_b chr
          ,okl_k_headers khr
     WHERE chr.id = khr.id
       AND khr.crs_id = cp_ch_req_id;

    CURSOR c_get_chr (cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT contract_number
      FROM okc_k_headers_b
     WHERE id = cp_chr_id;

    lv_ageement_number okc_k_headers_b.contract_number%TYPE;
  BEGIN
    IF(p_change_request_id IS NOT NULL AND p_change_request_id <> OKL_API.G_MISS_NUM)THEN
      OPEN c_get_chreq_csr(cp_ch_req_id => p_change_request_id);
      FETCH c_get_chreq_csr INTO cv_chreq_rec;
      CLOSE c_get_chreq_csr;

      -- find the agreement that is attached to this change request by looking into the okl_k_headers table
      IF(G_ARGREEMENT_TYPE_CODE = cv_chreq_rec.change_type_code)THEN
        OPEN c_get_chr_num_csr(cp_ch_req_id => p_change_request_id);
        FETCH c_get_chr_num_csr INTO lv_ageement_number;
        CLOSE c_get_chr_num_csr;
      -- for ASSOCIATION type of change request, first we need to check if an agreement exists for this
      -- change request in the okl_k_headers table (such record can exist which was created as a backup copy)
      -- if no such record found then the contract_number associated to the chr_id from the change requests table
      -- is what we are interested in
      ELSIF(G_ASSOCIATE_TYPE_CODE = cv_chreq_rec.change_type_code)THEN
        OPEN c_get_chr_num_csr(cp_ch_req_id => p_change_request_id);
        FETCH c_get_chr_num_csr INTO lv_ageement_number;
        IF(c_get_chr_num_csr%NOTFOUND)THEN
          CLOSE c_get_chr_num_csr;
          -- this implies that the change request is an working copy (or that was merged with the originating agreement)
          -- that was created for modifications.
          OPEN c_get_chr(cp_chr_id => cv_chreq_rec.chr_id);
          FETCH c_get_chr INTO lv_ageement_number;
          CLOSE c_get_chr;
        ELSIF(c_get_chr_num_csr%FOUND)THEN
          CLOSE c_get_chr_num_csr;
        END IF;
      END IF; -- end of G_ARGREEMENT_TYPE_CODE = cv_chreq_rec.change_type_code
    END IF; -- end of p_change_request_id IS NOT NULL AND p_change_request_id <> OKL_API.G_MISS_NUM
    RETURN lv_ageement_number;
  END get_assoc_agr_number;

  FUNCTION get_assoc_agr_id(p_change_request_id IN okl_vp_change_requests.id%TYPE) RETURN NUMBER IS
    CURSOR c_get_chreq_csr (cp_ch_req_id okl_vp_change_requests.id%TYPE) IS
    SELECT chr_id
          ,change_type_code
          ,status_code
      FROM okl_vp_change_requests
     WHERE id = cp_ch_req_id;
    cv_chreq_rec c_get_chreq_csr%ROWTYPE;

    CURSOR c_get_chr_id_csr(cp_ch_req_id okl_vp_change_requests.id%TYPE) IS
    SELECT chr.id
      FROM okc_k_headers_b chr
          ,okl_k_headers khr
     WHERE chr.id = khr.id
       AND khr.crs_id = cp_ch_req_id;

    lv_chr_id okc_k_headers_b.id%TYPE;
  BEGIN
    IF(p_change_request_id IS NOT NULL AND p_change_request_id <> OKL_API.G_MISS_NUM)THEN
      OPEN c_get_chreq_csr(cp_ch_req_id => p_change_request_id);
      FETCH c_get_chreq_csr INTO cv_chreq_rec;
      CLOSE c_get_chreq_csr;

      -- find the agreement that is attached to this change request by looking into the okl_k_headers table
      IF(G_ARGREEMENT_TYPE_CODE = cv_chreq_rec.change_type_code)THEN
        OPEN c_get_chr_id_csr(cp_ch_req_id => p_change_request_id);
        FETCH c_get_chr_id_csr INTO lv_chr_id;
        CLOSE c_get_chr_id_csr;
      ELSIF(G_ASSOCIATE_TYPE_CODE = cv_chreq_rec.change_type_code)THEN
        OPEN c_get_chr_id_csr(cp_ch_req_id => p_change_request_id);
        FETCH c_get_chr_id_csr INTO lv_chr_id;
        IF(c_get_chr_id_csr%NOTFOUND)THEN
          CLOSE c_get_chr_id_csr;
          -- this implies that the change request is an working copy (or that was merged with the originating agreement)
          -- that was created for modifications.
          lv_chr_id := cv_chreq_rec.chr_id;
        ELSIF(c_get_chr_id_csr%FOUND)THEN
          CLOSE c_get_chr_id_csr;
        END IF;
      END IF; -- end of G_ARGREEMENT_TYPE_CODE = cv_chreq_rec.change_type_code
    END IF; -- end of p_change_request_id IS NOT NULL AND p_change_request_id <> OKL_API.G_MISS_NUM
    RETURN lv_chr_id;
  END get_assoc_agr_id;
END okl_vp_change_request_pvt;

/
