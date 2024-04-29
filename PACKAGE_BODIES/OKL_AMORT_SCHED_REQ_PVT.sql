--------------------------------------------------------
--  DDL for Package Body OKL_AMORT_SCHED_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AMORT_SCHED_REQ_PVT" AS
 /* $Header: OKLRAMRB.pls 120.6 2008/02/12 18:55:13 srsreeni noship $ */
  -- Start of comments
  --
  -- API name       : populate_trx_table
  -- Pre-reqs       : None
  -- Function       : This procedure prepares the data to be inserted into the
  --				  request table
  -- Parameters     :
  -- IN             : p_chr_id - The Contract ID
  --                  p_comments - Comments
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  -- 				  p_trqv_tbl_type - The data structure containing information to be inserted
  -- Version        : 1.0
  -- History        : srsreeni created.
  PROCEDURE populate_trx_table(p_chr_id in okc_k_headers_b.id%type,p_comments in varchar2 default null,
  							   p_trqv_tbl_type OUT NOCOPY okl_trx_requests_pub.trqv_tbl_type,
                               x_return_status OUT NOCOPY VARCHAR2,x_msg_count OUT NOCOPY NUMBER,x_msg_data OUT NOCOPY VARCHAR2) IS

  CURSOR curr_code_org_id_csr(p_chr_id IN NUMBER) IS
  SELECT currency_code,org_id
  FROM OKC_K_HEADERS_B
  WHERE ID = p_chr_id;

  l_currency_code VARCHAR2(15);
  l_org_id	okc_k_headers_b.org_id%type;
  l_return_status varchar2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

  OPEN curr_code_org_id_csr(p_chr_id);
  FETCH curr_code_org_id_csr INTO l_currency_code,l_org_id;
  CLOSE curr_code_org_id_csr;

  p_trqv_tbl_type(1).created_by := OKL_API.G_MISS_NUM;
  p_trqv_tbl_type(1).creation_date := OKL_API.G_MISS_DATE;
  p_trqv_tbl_type(1).last_updated_by := OKL_API.G_MISS_NUM;
  p_trqv_tbl_type(1).last_update_date := OKL_API.G_MISS_DATE;
  p_trqv_tbl_type(1).request_number := OKL_API.G_MISS_CHAR;
  p_trqv_tbl_type(1).ID := OKL_API.G_MISS_NUM;
  p_trqv_tbl_type(1).request_status_code :=  'PROCESSED';
  p_trqv_tbl_type(1).request_type_code := 'AMORITIZATION_SCHEDULE_CURRENT';
  p_trqv_tbl_type(1).comments :=  p_comments;
  p_trqv_tbl_type(1).dnz_khr_id :=  p_chr_id;
  p_trqv_tbl_type(1).org_id := l_org_id;
  p_trqv_tbl_type(1).legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_chr_id);
  p_trqv_tbl_type(1).currency_code := l_currency_code;
  p_trqv_tbl_type(1).start_date :=  sysdate;
  p_trqv_tbl_type(1).end_date :=  sysdate;
  x_return_status := l_return_status;
 EXCEPTION
 	WHEN OTHERS THEN
        	x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
          	x_msg_data := substr(sqlerrm,1,255);
          	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END populate_trx_table;

  -- API name       : process_trx_request
  -- Pre-reqs       : None
  -- Function       : This procedure inserts the data into the TRX_REQUESTS table.
  -- Parameters     :
  -- IN             : p_chr_id - The Contract ID
  --				  p_api_version - Standard Input Parameters
  --				  p_init_msg_list - Standard Input Parameters
  --                  p_comments - Comments
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  -- 				  x_trx_req_id - The transaction_request_id created for this request
  --				x_summ_flag - Flag to indicate if Summary data is present or not
 PROCEDURE process_trx_request(p_chr_id in okc_k_headers_b.id%type,p_api_version IN NUMBER,
								  p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,p_comments in varchar2 default null,p_user_id in number,
			  x_return_status OUT NOCOPY VARCHAR2,x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2,x_trx_req_id OUT NOCOPY okl_trx_requests.id%type,x_summ_flag OUT NOCOPY BOOLEAN) IS

 l_trqv_tbl  okl_trx_requests_pub.trqv_tbl_type;
 x_trqv_tbl  okl_trx_requests_pub.trqv_tbl_type;
 i    BINARY_INTEGER;
 l_api_name		CONSTANT VARCHAR2(30) := 'PROCESS_TRX_REQUEST';

 BEGIN
	x_return_status := OKL_API.G_RET_STS_SUCCESS;
    	x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    	END IF;
   		populate_trx_table(p_chr_id => p_chr_id,p_trqv_tbl_type => l_trqv_tbl,
                      		x_return_status => x_return_status,
                      		x_msg_count => x_msg_count,
                      		x_msg_data => x_msg_data);
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
   		okl_trx_requests_pub.insert_trx_requests(p_api_version         => p_api_version,
                                                p_init_msg_list       =>  p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
--Invoke the procedure to insert the Amoritization Schedule Data
	  okl_amort_sched_process_pvt.generate_amor_sched(
		p_chr_id => p_chr_id,
		p_api_version => p_api_version,
	  	p_init_msg_list => p_init_msg_list,
	  	p_trx_req_id => x_trqv_tbl(1).id,
		p_user_id => p_user_id,
    		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
	  	x_msg_data => x_msg_data,
		x_summ_flag => x_summ_flag);

	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
	OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);
	commit;
		x_trx_req_id := x_trqv_tbl(1).id;
	exception
	    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	      --rollback;
	      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
	          p_api_name  => l_api_name,
	          p_pkg_name  => G_PKG_NAME,
	          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
	          x_msg_count => x_msg_count,
	          x_msg_data  => x_msg_data,
	          p_api_type  => '_PVT');
	    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	      --rollback;
	      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
	          p_api_name  => l_api_name,
	          p_pkg_name  => G_PKG_NAME,
	          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
	          x_msg_count => x_msg_count,
	          x_msg_data  => x_msg_data,
	          p_api_type  => '_PVT');
	    WHEN OTHERS THEN
	      --rollback;
	      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
	          p_api_name  => l_api_name,
	          p_pkg_name  => G_PKG_NAME,
	          p_exc_name  => 'OTHERS',
	          x_msg_count => x_msg_count,
	          x_msg_data  => x_msg_data,
	          p_api_type  => '_PVT');
  END process_trx_request;
END OKL_AMORT_SCHED_REQ_PVT;

/
