--------------------------------------------------------
--  DDL for Package Body OKL_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RELEASE_PVT" as
/* $Header: OKLRREKB.pls 120.36.12010000.9 2010/04/06 11:34:24 nikshah ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_COPY_HEADER                 CONSTANT VARCHAR2(200) := 'OKL_LLA_COPY_HEADER';
  G_COPY_LINE                   CONSTANT VARCHAR2(200) := 'OKL_LLA_COPY_LINE';
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT  VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED	        CONSTANT  VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED	        CONSTANT  VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED    CONSTANT  VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE               CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	        CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_FETCHING_INFO               CONSTANT  VARCHAR2(200) := 'OKL_LLA_FETCHING_INFO';
  G_LINE_RECORD                 CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_RELEASE_PVT';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_ERROR                       CONSTANT  VARCHAR2(200) := 'OKL_COPY_ASSET_LINES';
  G_CREATION_ERROR              CONSTANT  VARCHAR2(200) := 'Error Occurred in Creation';
  G_ID2                         CONSTANT  VARCHAR2(200) := '#';
  G_TRY_NAME                              OKL_TRX_TYPES_V.NAME%TYPE       := 'CREATE ASSET LINES';
  G_TRY_TYPE                              OKL_TRX_TYPES_V.TRY_TYPE%TYPE   := 'TIE';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';
  G_YN_ERROR                    CONSTANT  VARCHAR2(200) := 'Invalid Value for ';
-------------------------------------------------------------------------------------------------
-- GLOBAL COMPOSITE TYPE VARIABLES
-------------------------------------------------------------------------------------------------
  TYPE g_top_line_tbl IS TABLE OF OKC_K_LINES_V.ID%TYPE
        INDEX BY BINARY_INTEGER;
  TYPE g_asset_num_tbl IS TABLE OF OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
  subtype clev_rec_type is OKL_OKC_MIGRATION_PVT.CLEV_REC_TYPE;
  subtype klev_tbl_type is OKL_CONTRACT_PUB.klev_tbl_type;
  subtype cimv_rec_type is OKL_OKC_MIGRATION_PVT.cimv_rec_type;
  subtype trxv_rec_type is OKL_TRX_ASSETS_PUB.thpv_rec_type;
-------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 	   --Start of comments
 	   --
 	   --Procedure Name        : create_ubb_contract
 	   --Purpose               : Check if Release Contract has usage line
 	   --                       If true then create a usage contract only in case
 	   --                       of full TnA
 	   --                        - used internally
 	   --Modification History  :
 	   --09-jan-2008    rajnisku   Created : Bug 6657564
 	 ------------------------------------------------------------------------------

 	   PROCEDURE create_ubb_contract(p_api_version   IN  NUMBER,
 	                                p_init_msg_list IN  VARCHAR2,
 	                                x_return_status OUT NOCOPY VARCHAR2,
 	                                x_msg_count     OUT NOCOPY NUMBER,
 	                                x_msg_data      OUT NOCOPY VARCHAR2,
 	                                p_chr_id        IN  NUMBER,
 	                                p_source_trx_id IN NUMBER
 	                                                            ) IS

 	    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 	    l_api_name        CONSTANT VARCHAR2(30) := 'create_ubb_contract';
 	    l_api_version     CONSTANT NUMBER    := 1.0;

 	     --cursor to check if usage line exists on the contract
 	     CURSOR l_chk_usage_csr (p_chr_id IN Number) IS
 	     SELECT '!'
 	     FROM   dual
 	     where exists (SELECT 1
 	                  FROM OKC_LINE_STYLES_B lse,
 	                       OKC_K_LINES_B     cle,
 	                       okc_statuses_b sts
 	                  WHERE  lse.id = cle.lse_id
 	                  AND    lse.lty_code = 'USAGE'
 	                  AND    cle.dnz_chr_id = p_chr_id
 	                  AND sts.code =cle.sts_code
 	                  AND sts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED')
 	                  );

 	   CURSOR taa_request_csr(p_source_trx_id IN NUMBER)
 	   IS
 	   SELECT tsu_code,
 	        complete_transfer_yn,
 	        date_transaction_occurred
 	   FROM okl_trx_contracts
 	   where id = p_source_trx_id;

 	   taa_request_rec        taa_request_csr%ROWTYPE;

 	   l_usage_khr varchar2(1);
 	   l_usage_create_yn VARCHAR2(1):='N';
 	   l_service_chr_id NUMBER;

 	  begin
 	     --check if usage line is there on the contract
 	       l_usage_khr := '?';
 	       OPEN l_chk_usage_csr (p_chr_id => p_chr_id);
 	       FETCH l_chk_usage_csr INTO l_usage_khr;
 	       IF l_chk_usage_csr%NOTFOUND THEN
 	          NULL;
 	       END IF;
 	       CLOSE l_chk_usage_csr;

 	       IF l_usage_khr = '!' THEN
 	            --check whether partial/full T n A request
 	            --create a usage contract only in case of full TnA
 	           l_usage_create_yn:='N';

 	           IF p_source_trx_id IS NOT NULL THEN
 	            open taa_request_csr(p_source_trx_id => p_source_trx_id );
 	            fetch taa_request_csr into taa_request_rec;
 	            close taa_request_csr;

 	            IF NVL(taa_request_rec.complete_transfer_yn,'X') = 'Y' THEN
 	                 l_usage_create_yn:='Y';
 	            END IF;
 	           ELSE -- source id null.
 	             l_usage_create_yn:='Y';
 	           END IF;

 	           IF l_usage_create_yn='Y' THEN
 	            --call ubb api for service contracts creation
 	            okl_ubb_integration_pub.create_ubb_contract(
 	                           p_api_version   => p_api_version,
 	                           p_init_msg_list => p_init_msg_list,
 	                           x_return_status => x_return_status,
 	                           x_msg_count     => x_msg_count,
 	                           x_msg_data      => x_msg_data,
 	                           p_chr_id        => p_chr_id,
 	                           x_chr_id        => l_service_chr_id
 	                          );
 	            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
 	                     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
 	             ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
 	                     RAISE Okl_Api.G_EXCEPTION_ERROR;
 	             END IF;
 	           END IF;

 	         End If;

 	    EXCEPTION
 	       when OKL_API.G_EXCEPTION_ERROR then

 	         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
 	                         p_api_name  => l_api_name,
 	                         p_pkg_name  => G_PKG_NAME,
 	                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
 	                         x_msg_count => x_msg_count,
 	                         x_msg_data  => x_msg_data,
 	                         p_api_type  => G_API_TYPE);

 	       when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

 	         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
 	                         p_api_name  => l_api_name,
 	                         p_pkg_name  => G_PKG_NAME,
 	                         p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
 	                         x_msg_count => x_msg_count,
 	                         x_msg_data  => x_msg_data,
 	                         p_api_type  => G_API_TYPE);

 	       when OTHERS then

 	         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
 	                         p_api_name  => l_api_name,
 	                         p_pkg_name  => G_PKG_NAME,
 	                         p_exc_name  => 'OTHERS',
 	                         x_msg_count => x_msg_count,
 	                         x_msg_data  => x_msg_data,
 	                         p_api_type  => G_API_TYPE);
 	  end create_ubb_contract;



 	 ------------------------------------------------------------------------------
 	   --Start of comments
 	   --
 	   --Procedure Name        : adjust_usage_lines
 	   --Purpose               : Update/Delete usage line on Release contract
 	   --
 	   --
 	   --                        - used internally
 	   --Modification History  :
 	   --09-Jan-2008    rirawat   Created : Bug 6657564
 	 ------------------------------------------------------------------------------

 	    PROCEDURE adjust_usage_lines(p_api_version   IN  NUMBER,
 	                                p_init_msg_list IN  VARCHAR2,
 	                                x_return_status OUT NOCOPY VARCHAR2,
 	                                x_msg_count     OUT NOCOPY NUMBER,
 	                                x_msg_data      OUT NOCOPY VARCHAR2,
 	                                p_chr_id        IN  NUMBER,
 	                                p_release_date  IN  DATE) IS

 	     l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 	     l_api_name        CONSTANT VARCHAR2(30) := 'ADJUST_USAGE_LINES';
 	     l_api_version     CONSTANT NUMBER   := 1.0;

 	   --This cursor find usage lines in the release contract which are not
 	   -- linked to any asset

 	   CURSOR non_linked_usage_csr (p_chr_id NUMBER)  IS
 	     SELECT cle.id usage_line_id
 	     FROM okc_line_styles_b lse,
 	          okc_k_lines_b cle,
 	          okc_statuses_v okcsts
 	     WHERE cle.dnz_chr_id = p_chr_id
 	     AND cle.lse_id = lse.id
 	     AND lse.lse_parent_id is null
 	     AND lse.lty_code ='USAGE'
 	     and okcsts.code = cle.sts_code
 	     AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED')
 	     AND NOT EXISTS (
 	         SELECT 1
 	        FROM okc_k_lines_b line,
 	        okc_line_styles_b lse,
 	        okc_statuses_b sts
 	        WHERE  line.dnz_chr_id = p_chr_id
 	        AND    line.cle_id     = cle.id
 	        AND    line.lse_id = lse.id
 	        AND    lse.lty_code ='LINK_USAGE_ASSET'
 	        AND sts.code = line.sts_code
 	        AND sts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED')
 	     );


 	     CURSOR usage_csr (p_chr_id NUMBER) IS
 	     SELECT cle.id usage_line_id
 	     FROM okc_line_styles_b lse,
 	          okc_k_lines_b cle,okc_statuses_v okcsts
 	     WHERE cle.dnz_chr_id = p_chr_id
 	     AND cle.lse_id = lse.id
 	     AND lse.lse_parent_id is null
 	     AND lse.lty_code ='USAGE'
 	     and okcsts.code = cle.sts_code
 	     AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED');


 	    CURSOR link_asset_csr (p_chr_id        NUMBER,
 	                           p_usage_line_id NUMBER) IS
 	    SELECT line.id
 	    FROM okc_k_lines_b line,
 	    okc_line_styles_b lse,
 	    okc_statuses_b okcsts
 	    WHERE  line.dnz_chr_id = p_chr_id
 	    AND    line.cle_id     = p_usage_line_id
 	    AND    line.lse_id = lse.id
 	    AND    lse.lty_code ='LINK_USAGE_ASSET'
 	    AND okcsts.code = line.sts_code
 	    AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED');

 	    lp_klev_rec  okl_kle_pvt.klev_rec_type;
 	     lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;
 	     lp_clev_temp_rec okl_okc_migration_pvt.clev_rec_type;
 	     lp_klev_temp_rec okl_kle_pvt.klev_rec_type;
 	     lx_klev_rec  okl_kle_pvt.klev_rec_type;
 	     lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

 	  begin

 	      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
 	     -- Call start_activity to create savepoint, check compatibility
 	     -- and initialize message list
 	     l_return_status := Okl_Api.START_ACTIVITY(
 	                         p_api_name      => l_api_name,
 	                         p_pkg_name      => g_pkg_name,
 	                         p_init_msg_list => p_init_msg_list,
 	                         l_api_version   => l_api_version,
 	                         p_api_version   => p_api_version,
 	                         p_api_type      => '_PVT',
 	                         x_return_status => x_return_status);
 	     -- Check if activity started successfully
 	     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
 	        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
 	     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
 	        RAISE Okl_Api.G_EXCEPTION_ERROR;
 	     END IF;

 	    --Remove all the usage lines without any assets associated with it.
 	    FOR non_linked_usage_rec In non_linked_usage_csr(p_chr_id) LOOP

 	         OKL_CONTRACT_PUB.delete_contract_line(
 	             p_api_version   =>p_api_version,
 	             p_init_msg_list => p_init_msg_list,
 	             x_return_status => x_return_status,
 	             x_msg_count     => x_msg_count,
 	             x_msg_data      => x_msg_data,
 	             p_line_id       => non_linked_usage_rec.usage_line_id
 	         );

 	         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
 	           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
 	           RAISE OKL_API.G_EXCEPTION_ERROR;
 	         END IF;

 	    END LOOP;

 	     --update the start date of the usage and linked asset lines with the
 	     -- release date

 	     FOR usage_rec IN usage_csr (p_chr_id)
 	     LOOP
 	       lp_clev_rec     := lp_clev_temp_rec;
 	       lp_klev_rec     := lp_klev_temp_rec;
 	       lp_clev_rec.id := usage_rec.usage_line_id;
 	       lp_clev_rec.start_date := p_release_date;
 	       lp_klev_rec.id := usage_rec.usage_line_id;

 	       OKL_CONTRACT_PUB.update_contract_line(
 	            p_api_version         => p_api_version,
 	            p_init_msg_list       => p_init_msg_list,
 	            x_return_status       => x_return_status,
 	            x_msg_count           => x_msg_count,
 	            x_msg_data            => x_msg_data,
 	            p_clev_rec            => lp_clev_rec,
 	            p_klev_rec            => lp_klev_rec,
 	            x_clev_rec            => lx_clev_rec,
 	            x_klev_rec            => lx_klev_rec
 	         );
 	         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
 	           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
 	           RAISE OKL_API.G_EXCEPTION_ERROR;
 	         END IF;

 	           FOR link_asset_rec IN link_asset_csr (p_chr_id,usage_rec.usage_line_id)
 	           LOOP
 	               lp_clev_rec     := lp_clev_temp_rec;
 	           lp_klev_rec     := lp_klev_temp_rec;

 	               lp_clev_rec.id := link_asset_rec.id;
 	               lp_clev_rec.start_date := p_release_date;
 	               lp_klev_rec.id := link_asset_rec.id;

 	         OKL_CONTRACT_PUB.update_contract_line(
 	            p_api_version         => p_api_version,
 	            p_init_msg_list       => p_init_msg_list,
 	            x_return_status       => x_return_status,
 	            x_msg_count           => x_msg_count,
 	            x_msg_data            => x_msg_data,
 	            p_clev_rec            => lp_clev_rec,
 	            p_klev_rec            => lp_klev_rec,
 	            x_clev_rec            => lx_clev_rec,
 	            x_klev_rec            => lx_klev_rec
 	           );
 	         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
 	          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
 	           RAISE OKL_API.G_EXCEPTION_ERROR;
 	         END IF;
 	           END LOOP;

 	     END LOOP;
 	      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
 	                          x_msg_data    => x_msg_data);
 	   EXCEPTION
 	       when OKL_API.G_EXCEPTION_ERROR then

 	         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
 	                         p_api_name  => l_api_name,
 	                         p_pkg_name  => G_PKG_NAME,
 	                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
 	                         x_msg_count => x_msg_count,
 	                         x_msg_data  => x_msg_data,
 	                         p_api_type  => G_API_TYPE);

 	       when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

 	         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
 	                         p_api_name  => l_api_name,
 	                         p_pkg_name  => G_PKG_NAME,
 	                         p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
 	                         x_msg_count => x_msg_count,
 	                         x_msg_data  => x_msg_data,
 	                         p_api_type  => G_API_TYPE);

 	       when OTHERS then

 	         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
 	                         p_api_name  => l_api_name,
 	                         p_pkg_name  => G_PKG_NAME,
 	                         p_exc_name  => 'OTHERS',
 	                         x_msg_count => x_msg_count,
 	                         x_msg_data  => x_msg_data,
 	                         p_api_type  => G_API_TYPE);


 	  end adjust_usage_lines;
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_tasv_rec
-- Description          : Get Transaction Header Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION  get_tasv_rec(p_tas_id   IN  NUMBER,
                         x_trxv_rec OUT NOCOPY trxv_rec_type)
  RETURN  VARCHAR2
  IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_trxv_rec(p_tas_id NUMBER)
    IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           ICA_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           TAS_TYPE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           TSU_CODE,
           TRY_ID,
           DATE_TRANS_OCCURRED,
           TRANS_NUMBER,
           COMMENTS,
           REQ_ASSET_ID,
           TOTAL_MATCH_AMOUNT
    FROM OKL_TRX_ASSETS
    WHERE id = p_tas_id;
  BEGIN
    OPEN c_trxv_rec(p_tas_id);
    FETCH c_trxv_rec INTO
           x_trxv_rec.ID,
           x_trxv_rec.OBJECT_VERSION_NUMBER,
           x_trxv_rec.ICA_ID,
           x_trxv_rec.ATTRIBUTE_CATEGORY,
           x_trxv_rec.ATTRIBUTE1,
           x_trxv_rec.ATTRIBUTE2,
           x_trxv_rec.ATTRIBUTE3,
           x_trxv_rec.ATTRIBUTE4,
           x_trxv_rec.ATTRIBUTE5,
           x_trxv_rec.ATTRIBUTE6,
           x_trxv_rec.ATTRIBUTE7,
           x_trxv_rec.ATTRIBUTE8,
           x_trxv_rec.ATTRIBUTE9,
           x_trxv_rec.ATTRIBUTE10,
           x_trxv_rec.ATTRIBUTE11,
           x_trxv_rec.ATTRIBUTE12,
           x_trxv_rec.ATTRIBUTE13,
           x_trxv_rec.ATTRIBUTE14,
           x_trxv_rec.ATTRIBUTE15,
           x_trxv_rec.TAS_TYPE,
           x_trxv_rec.CREATED_BY,
           x_trxv_rec.CREATION_DATE,
           x_trxv_rec.LAST_UPDATED_BY,
           x_trxv_rec.LAST_UPDATE_DATE,
           x_trxv_rec.LAST_UPDATE_LOGIN,
           x_trxv_rec.TSU_CODE,
           x_trxv_rec.TRY_ID,
           x_trxv_rec.DATE_TRANS_OCCURRED,
           x_trxv_rec.TRANS_NUMBER,
           x_trxv_rec.COMMENTS,
           x_trxv_rec.REQ_ASSET_ID,
           x_trxv_rec.TOTAL_MATCH_AMOUNT;
    IF c_trxv_rec%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_trxv_rec;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     IF c_trxv_rec%ISOPEN THEN
        CLOSE c_trxv_rec;
     END IF;
      -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     RETURN(x_return_status);
  END get_tasv_rec;
-------------------------------------------------------------------------------------------------
  FUNCTION get_rec_chrv (p_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                         x_chrv_rec  OUT NOCOPY chrv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_chrv_pk_csr(p_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           CHR_ID_RESPONSE,
           CHR_ID_AWARD,
           INV_ORGANIZATION_ID,
           STS_CODE,
           QCL_ID,
           SCS_CODE,
           CONTRACT_NUMBER,
           CURRENCY_CODE,
           CONTRACT_NUMBER_MODIFIER,
           ARCHIVED_YN,
           DELETED_YN,
           CUST_PO_NUMBER_REQ_YN,
           PRE_PAY_REQ_YN,
           CUST_PO_NUMBER,
           SHORT_DESCRIPTION,
           COMMENTS,
           DESCRIPTION,
           DPAS_RATING,
           COGNOMEN,
           TEMPLATE_YN,
           TEMPLATE_USED,
           DATE_APPROVED,
           DATETIME_CANCELLED,
           AUTO_RENEW_DAYS,
           DATE_ISSUED,
           DATETIME_RESPONDED,
           NON_RESPONSE_REASON,
           NON_RESPONSE_EXPLAIN,
           RFP_TYPE,
           CHR_TYPE,
           KEEP_ON_MAIL_LIST,
           SET_ASIDE_REASON,
           SET_ASIDE_PERCENT,
           RESPONSE_COPIES_REQ,
           DATE_CLOSE_PROJECTED,
           DATETIME_PROPOSED,
           DATE_SIGNED,
           DATE_TERMINATED,
           DATE_RENEWED,
           TRN_CODE,
           START_DATE,
           END_DATE,
           AUTHORING_ORG_ID,
           BUY_OR_SELL,
           ISSUE_OR_RECEIVE,
           ESTIMATED_AMOUNT,
           ESTIMATED_AMOUNT_RENEWED,
           CURRENCY_CODE_RENEWED,
	   UPG_ORIG_SYSTEM_REF,
           UPG_ORIG_SYSTEM_REF_ID,
           APPLICATION_ID,
           ORIG_SYSTEM_SOURCE_CODE,
           ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_REFERENCE1,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
     FROM okc_k_headers_v chrv
     WHERE chrv.id = p_id;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_chrv_pk_csr (p_id);
    FETCH okc_chrv_pk_csr INTO
          x_chrv_rec.ID,
          x_chrv_rec.OBJECT_VERSION_NUMBER,
          x_chrv_rec.SFWT_FLAG,
          x_chrv_rec.CHR_ID_RESPONSE,
          x_chrv_rec.CHR_ID_AWARD,
          x_chrv_rec.INV_ORGANIZATION_ID,
          x_chrv_rec.STS_CODE,
          x_chrv_rec.QCL_ID,
          x_chrv_rec.SCS_CODE,
          x_chrv_rec.CONTRACT_NUMBER,
          x_chrv_rec.CURRENCY_CODE,
          x_chrv_rec.CONTRACT_NUMBER_MODIFIER,
          x_chrv_rec.ARCHIVED_YN,
          x_chrv_rec.DELETED_YN,
          x_chrv_rec.CUST_PO_NUMBER_REQ_YN,
          x_chrv_rec.PRE_PAY_REQ_YN,
          x_chrv_rec.CUST_PO_NUMBER,
          x_chrv_rec.SHORT_DESCRIPTION,
          x_chrv_rec.COMMENTS,
          x_chrv_rec.DESCRIPTION,
          x_chrv_rec.DPAS_RATING,
          x_chrv_rec.COGNOMEN,
          x_chrv_rec.TEMPLATE_YN,
          x_chrv_rec.TEMPLATE_USED,
          x_chrv_rec.DATE_APPROVED,
          x_chrv_rec.DATETIME_CANCELLED,
          x_chrv_rec.AUTO_RENEW_DAYS,
          x_chrv_rec.DATE_ISSUED,
          x_chrv_rec.DATETIME_RESPONDED,
          x_chrv_rec.NON_RESPONSE_REASON,
          x_chrv_rec.NON_RESPONSE_EXPLAIN,
          x_chrv_rec.RFP_TYPE,
          x_chrv_rec.CHR_TYPE,
          x_chrv_rec.KEEP_ON_MAIL_LIST,
          x_chrv_rec.SET_ASIDE_REASON,
          x_chrv_rec.SET_ASIDE_PERCENT,
          x_chrv_rec.RESPONSE_COPIES_REQ,
          x_chrv_rec.DATE_CLOSE_PROJECTED,
          x_chrv_rec.DATETIME_PROPOSED,
          x_chrv_rec.DATE_SIGNED,
          x_chrv_rec.DATE_TERMINATED,
          x_chrv_rec.DATE_RENEWED,
          x_chrv_rec.TRN_CODE,
          x_chrv_rec.START_DATE,
          x_chrv_rec.END_DATE,
          x_chrv_rec.AUTHORING_ORG_ID,
          x_chrv_rec.BUY_OR_SELL,
          x_chrv_rec.ISSUE_OR_RECEIVE,
          x_chrv_rec.ESTIMATED_AMOUNT,
          x_chrv_rec.ESTIMATED_AMOUNT_RENEWED,
          x_chrv_rec.CURRENCY_CODE_RENEWED,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF_ID,
          x_chrv_rec.APPLICATION_ID,
          x_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
          x_chrv_rec.ORIG_SYSTEM_ID1,
          x_chrv_rec.ORIG_SYSTEM_REFERENCE1,
          x_chrv_rec.ATTRIBUTE_CATEGORY,
          x_chrv_rec.ATTRIBUTE1,
          x_chrv_rec.ATTRIBUTE2,
          x_chrv_rec.ATTRIBUTE3,
          x_chrv_rec.ATTRIBUTE4,
          x_chrv_rec.ATTRIBUTE5,
          x_chrv_rec.ATTRIBUTE6,
          x_chrv_rec.ATTRIBUTE7,
          x_chrv_rec.ATTRIBUTE8,
          x_chrv_rec.ATTRIBUTE9,
          x_chrv_rec.ATTRIBUTE10,
          x_chrv_rec.ATTRIBUTE11,
          x_chrv_rec.ATTRIBUTE12,
          x_chrv_rec.ATTRIBUTE13,
          x_chrv_rec.ATTRIBUTE14,
          x_chrv_rec.ATTRIBUTE15,
          x_chrv_rec.CREATED_BY,
          x_chrv_rec.CREATION_DATE,
          x_chrv_rec.LAST_UPDATED_BY,
          x_chrv_rec.LAST_UPDATE_DATE,
          x_chrv_rec.LAST_UPDATE_LOGIN;
    IF okc_chrv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_chrv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- if the cursor is open
      IF okc_chrv_pk_csr%ISOPEN THEN
         CLOSE okc_chrv_pk_csr;
      END IF;
      RETURN(x_return_status);
  END get_rec_chrv;
----------------------------------------------------------------------------
-- FUNCTION get_rec for: OKC_K_ITEMS_V
---------------------------------------------------------------------------
  FUNCTION get_rec_cimv(p_cle_id      IN  OKC_K_ITEMS_V.CLE_ID%TYPE,
                        p_dnz_chr_id  IN  OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE,
                        x_cimv_rec OUT NOCOPY cimv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_cimv_pk_csr(p_cle_id     OKC_K_ITEMS_V.CLE_ID%TYPE,
                           p_dnz_chr_id OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE) IS
    SELECT CIM.ID,
           CIM.OBJECT_VERSION_NUMBER,
           CIM.CLE_ID,
           CIM.CHR_ID,
           CIM.CLE_ID_FOR,
           CIM.DNZ_CHR_ID,
           CIM.OBJECT1_ID1,
           CIM.OBJECT1_ID2,
           CIM.JTOT_OBJECT1_CODE,
           CIM.UOM_CODE,
           CIM.EXCEPTION_YN,
           CIM.NUMBER_OF_ITEMS,
           CIM.UPG_ORIG_SYSTEM_REF,
           CIM.UPG_ORIG_SYSTEM_REF_ID,
           CIM.PRICED_ITEM_YN,
           CIM.CREATED_BY,
           CIM.CREATION_DATE,
           CIM.LAST_UPDATED_BY,
           CIM.LAST_UPDATE_DATE,
           CIM.LAST_UPDATE_LOGIN
    FROM okc_k_items_v cim
    WHERE cim.dnz_chr_id = p_dnz_chr_id
    AND cim.cle_id = p_cle_id;
    l_okc_cimv_pk              okc_cimv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_cimv_pk_csr(p_cle_id,
                         p_dnz_chr_id);
    FETCH okc_cimv_pk_csr INTO
              x_cimv_rec.ID,
              x_cimv_rec.OBJECT_VERSION_NUMBER,
              x_cimv_rec.CLE_ID,
              x_cimv_rec.CHR_ID,
              x_cimv_rec.CLE_ID_FOR,
              x_cimv_rec.DNZ_CHR_ID,
              x_cimv_rec.OBJECT1_ID1,
              x_cimv_rec.OBJECT1_ID2,
              x_cimv_rec.JTOT_OBJECT1_CODE,
              x_cimv_rec.UOM_CODE,
              x_cimv_rec.EXCEPTION_YN,
              x_cimv_rec.NUMBER_OF_ITEMS,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_cimv_rec.PRICED_ITEM_YN,
              x_cimv_rec.CREATED_BY,
              x_cimv_rec.CREATION_DATE,
              x_cimv_rec.LAST_UPDATED_BY,
              x_cimv_rec.LAST_UPDATE_DATE,
              x_cimv_rec.LAST_UPDATE_LOGIN;
    IF okc_cimv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    IF (okc_cimv_pk_csr%ROWCOUNT > 1) THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_cimv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_cimv_pk_csr%ISOPEN THEN
        CLOSE okc_cimv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_cimv;
--Bug# 4631549 : validate_release_date to be called from validate_release_contract
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : validate_release_date
  --Purpose               : Check if Release Contract Start Date
  --                        falls within the current open FA period
  --                        - used internally
  --Modification History  :
  --08-Jul-2004    rpillay   Created
------------------------------------------------------------------------------
PROCEDURE  validate_release_date
                 (p_api_version     IN  NUMBER,
                  p_init_msg_list   IN  VARCHAR2,
                  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2,
                  p_book_type_code  IN  VARCHAR2,
                  p_release_date    IN  DATE) IS

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'validate_release_date';
  l_api_version     CONSTANT NUMBER     := 1.0;

  CURSOR open_period_cur(p_book_type_code IN VARCHAR2) IS
  select period_name,
         calendar_period_open_date,
         calendar_period_close_date
  from fa_deprn_periods
  where book_type_code = p_book_type_code
  and period_close_date is null;

  open_period_rec          open_period_cur%rowtype;
  l_current_open_period    varchar2(240) default null;

  l_icx_date_format        varchar2(240);
BEGIN

   open open_period_cur(p_book_type_code);
   fetch open_period_cur into open_period_rec;
   close open_period_cur;

   IF NOT ( p_release_date BETWEEN open_period_rec.calendar_period_open_date AND
            open_period_rec.calendar_period_close_date ) THEN

     l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

     l_current_open_period := open_period_rec.period_name||' ('||
                  to_char(open_period_rec.calendar_period_open_date,l_icx_date_format)
                  ||' - '||to_char(open_period_rec.calendar_period_close_date,l_icx_date_format)||')';
     OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_LLA_RELEASE_DATE_INVALID',
                         p_token1       => 'BOOK_TYPE_CODE',
                         p_token1_value => p_book_type_code,
                         p_token2       => 'OPEN_PERIOD',
                         p_token2_value => l_current_open_period
                                 );
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR Then
    x_return_status := OKL_API.G_RET_STS_ERROR;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END validate_release_date;

----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_update_contract_header
-- Description          : Update Contract Header
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_update_contract_header(p_api_version        IN  NUMBER,
                                      p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                      x_return_status     OUT NOCOPY VARCHAR2,
                                      x_msg_count         OUT NOCOPY NUMBER,
                                      x_msg_data          OUT NOCOPY VARCHAR2,
                                      p_restricted_update IN  VARCHAR2 DEFAULT 'F',
                                      p_chrv_rec          IN  chrv_rec_type,
                                      p_khrv_rec          IN  khrv_rec_type,
                                      x_chrv_rec          OUT NOCOPY chrv_rec_type,
                                      x_khrv_rec          OUT NOCOPY khrv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'L_UPDATE_CONTRACT_HEADER';

     -- Added below for bug 5769216 - Start
      -- Cursor to get top line id
      Cursor top_cle_csr (p_chr_id IN NUMBER) is
      SELECT cle.id
      From   okc_k_lines_b cle,
             okc_statuses_b sts
      where  cle.dnz_chr_id = cle.chr_id
      and    cle.chr_id     = p_chr_id
      and    sts.code = cle.sts_code;


      l_top_cle_id OKC_K_LINES_B.ID%TYPE;
      l_chr_id OKC_K_HEADERS_B.ID%TYPE;
      l_cle_id           OKC_K_LINES_B.ID%TYPE;
      l_cle_start_date   OKC_K_LINES_B.START_DATE%TYPE;
      l_cle_end_date     OKC_K_LINES_B.END_DATE%TYPE;
      l_clev_rec          OKL_OKC_MIGRATION_PVT.clev_rec_type;
      lx_clev_rec         OKL_OKC_MIGRATION_PVT.clev_rec_type;
      l_parent_cle_id    OKC_K_LINES_B.orig_system_id1%TYPE;

       --Cursor to check if lease chr has lines to change effectivity

       Cursor  cle_csr(p_cle_id IN NUMBER) is
       SELECT  cle.id,
               cle.start_date,
               cle.end_date
       From    okc_k_lines_b cle
       connect by prior cle.id = cle.cle_id
       start with cle.id = p_cle_id
       and exists (select 1
                   from okc_statuses_b sts
                   where sts.code = cle.sts_code);
      -- bug 5769216 - End

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
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

    -- Bug 5769216 -- Start
       Open top_cle_csr(p_chr_id => p_chrv_rec.id);
         Loop
             Fetch top_cle_csr into l_top_cle_id;
             Exit when top_cle_csr%NOTFOUND;
             Open cle_csr (p_cle_id => l_top_cle_id);
             Loop
                 Fetch Cle_Csr into l_cle_id,
                                    l_cle_start_date,
                                    l_cle_end_date;
                 Exit When Cle_Csr%NOTFOUND;

                 l_clev_rec.id         := l_cle_id;
                 l_clev_rec.start_date := p_khrv_rec.date_deal_transferred;

                 okl_okc_migration_pvt.update_contract_line(
                      p_api_version        => p_api_version,
                      p_init_msg_list        => p_init_msg_list,
                      x_return_status         => x_return_status,
                      x_msg_count             => x_msg_count,
                      x_msg_data              => x_msg_data,
                      p_clev_rec                => l_clev_rec,
                      x_clev_rec                => lx_clev_rec);
                  -- check return status
                  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
              End Loop;
              Close Cle_Csr;
           End Loop;
       Close top_cle_csr;
     -- Bug 5769216 - End

    OKL_OKC_MIGRATION_PVT.update_contract_header(
       p_api_version        => p_api_version,
       p_init_msg_list      => p_init_msg_list,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       p_restricted_update  => p_restricted_update,
       p_chrv_rec           => p_chrv_rec,
       x_chrv_rec           => x_chrv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_KHR_PVT.Update_Row(
       p_api_version   => p_api_version,
       p_init_msg_list => p_init_msg_list,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_khrv_rec      => p_khrv_rec,
       x_khrv_rec      => x_khrv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

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
  END l_update_contract_header;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : l_copy_contract
-- Description          : Copy of the contract
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE l_copy_contract(p_api_version               IN  NUMBER,
                            p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status             OUT NOCOPY VARCHAR2,
                            x_msg_count                 OUT NOCOPY NUMBER,
                            x_msg_data                  OUT NOCOPY VARCHAR2,
                            p_commit        	        IN  VARCHAR2 DEFAULT 'F',
                            p_old_chr_id                IN  NUMBER,
                            p_new_contract_number       IN  VARCHAR2,
                            p_release_date              IN  DATE,
                            p_term_duration             IN NUMBER,
                            x_new_chrv_rec              OUT NOCOPY chrv_rec_type,
                            x_new_khrv_rec              OUT NOCOPY khrv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'LOCAL_COPY_CONTRACT';
    l_chrv_rec               chrv_rec_type;
    l_khrv_rec               khrv_rec_type;
    ln_new_chr_id            OKC_K_HEADERS_V.ID%TYPE;
    ln_new_cle_id            OKC_K_LINES_V.ID%TYPE;
    lt_klev_tbl_type         klev_tbl_type;
    ltx_klev_tbl_type        klev_tbl_type;
    i                        number := 0;

    CURSOR c_get_old_k_top_line(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id top_line
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE
    AND lse.id = stl.lse_Id
    AND stl.scs_code = 'LEASE';

    CURSOR larles_csr(p_chr_id IN NUMBER) IS
    select rul.id rul_id,
           rgp.id rgp_id,
           rul.rule_information1
    from okc_rule_groups_b rgp,
         okc_rules_b rul
    where rgp.id = rul.rgp_id
    and rgp.rgd_code = 'LARLES'
    and rul.rule_information_category = 'LARLES'
    and rgp.dnz_chr_id = p_chr_id
    and rgp.chr_id = p_chr_id
    and rul.dnz_chr_id = p_chr_id;

    larles_rec         larles_csr%ROWTYPE;
    lp_larles_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_larles_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_larles_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_larles_rulv_rec Okl_Rule_Pub.rulv_rec_type;

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
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
    -- TO copy the Copy the contract first
    OKL_COPY_CONTRACT_PUB.copy_lease_contract_new(
                          p_api_version              => p_api_version,
                          p_init_msg_list            => p_init_msg_list,
                          x_return_status            => x_return_status,
                          x_msg_count                => x_msg_count,
                          x_msg_data                 => x_msg_data,
                          p_commit                   => OKL_API.G_FALSE,
                          p_chr_id                   => p_old_chr_id,
                          p_contract_number          => p_new_contract_number,
                          p_contract_number_modifier => null,
                          p_to_template_yn           => 'N',
                          p_renew_ref_yn             => 'N',
                          p_copy_lines_yn            => 'Y',
                          p_override_org             => 'N',
                          p_trans_type               => 'CRL',
                          x_chr_id                   => ln_new_chr_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_COPY_HEADER);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_COPY_HEADER);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okc_context.set_okc_org_context(p_chr_id => ln_new_chr_id);

    -- Update Contract Header Start Date to Release Date
    -- Update Term Duration to new contract duration
    l_chrv_rec.id          := ln_new_chr_id;
    l_chrv_rec.start_date  := p_release_date;
    l_chrv_rec.orig_system_source_code := 'OKL_RELEASE';

    l_khrv_rec.id          := ln_new_chr_id;
    l_khrv_rec.term_duration := p_term_duration;
    l_khrv_rec.date_deal_transferred := p_release_date;

    --Added by bkatraga for bug 9369915
    --Delete trade-in info at contract level
    l_khrv_rec.date_tradein := null;
    l_khrv_rec.tradein_amount := null;
    l_khrv_rec.tradein_description := null;
    --end bkatraga

    l_update_contract_header(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             p_restricted_update  => OKL_API.G_FALSE,
                             p_chrv_rec           => l_chrv_rec,
                             p_khrv_rec           => l_khrv_rec,
                             x_chrv_rec           => x_new_chrv_rec,
                             x_khrv_rec           => x_new_khrv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set Re-lease Asset flag to 'Y'
    open larles_csr(p_chr_id => x_new_chrv_rec.id);
    fetch larles_csr into larles_rec;
    if larles_csr%NOTFOUND then

      lp_larles_rgpv_rec.id := null;
      lp_larles_rgpv_rec.rgd_code := 'LARLES';
      lp_larles_rgpv_rec.dnz_chr_id := x_new_chrv_rec.id;
      lp_larles_rgpv_rec.chr_id := x_new_chrv_rec.id;
      lp_larles_rgpv_rec.rgp_type := 'KRG';

      OKL_RULE_PUB.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larles_rgpv_rec,
        x_rgpv_rec       => lx_larles_rgpv_rec);

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      lp_larles_rulv_rec.id := null;
      lp_larles_rulv_rec.rgp_id := lx_larles_rgpv_rec.id;
      lp_larles_rulv_rec.rule_information_category := 'LARLES';
      lp_larles_rulv_rec.dnz_chr_id := x_new_chrv_rec.id;
      lp_larles_rulv_rec.rule_information1 := 'Y';
      lp_larles_rulv_rec.WARN_YN := 'N';
      lp_larles_rulv_rec.STD_TEMPLATE_YN := 'N';

      OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larles_rulv_rec,
        x_rulv_rec       => lx_larles_rulv_rec);

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      End If;

    else
      if larles_rec.rule_information1 <> 'Y' then

        lp_larles_rulv_rec.id := larles_rec.rul_id;
        lp_larles_rulv_rec.rgp_id := larles_rec.rgp_id;
        lp_larles_rulv_rec.rule_information_category := 'LARLES';
        lp_larles_rulv_rec.dnz_chr_id := x_new_chrv_rec.id;
        lp_larles_rulv_rec.rule_information1 := 'Y';
        lp_larles_rulv_rec.WARN_YN := 'N';
        lp_larles_rulv_rec.STD_TEMPLATE_YN := 'N';

        OKL_RULE_PUB.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_larles_rulv_rec,
          x_rulv_rec       => lx_larles_rulv_rec);

        If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        End If;
      end if;
    end if;

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
  END l_copy_contract;
-----------------------------------------------------------------------------------------------------------------------
  FUNCTION get_k_tls_asset(p_dnz_chr_id    IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                           x_top_line_tbl  OUT NOCOPY g_top_line_tbl,
                           x_asset_num_tbl OUT NOCOPY g_asset_num_tbl)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    i                          NUMBER := 0;
    j                          NUMBER := 0;

    CURSOR c_get_old_k_top_line(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id top_line
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE
    AND lse.id = stl.lse_Id
    AND stl.scs_code = 'LEASE';

    CURSOR c_get_old_k_asset(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT av.asset_number asset_number
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okx_assets_v av,
         okc_k_items cim,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND cim.object1_id1 = av.id1
    AND cim.object1_id2 = av.id2
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_type = G_SLS_TYPE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_Id
    AND stl.scs_code = 'LEASE';

  BEGIN
   --  Getting the TOP Line STS CODE
   IF (p_dnz_chr_id IS NOT NULL OR
      p_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      -- Getting the all the top lines
      FOR r_get_old_k_top_line IN c_get_old_k_top_line(p_dnz_chr_id) LOOP
        x_top_line_tbl(i) := r_get_old_k_top_line.top_line;
        IF c_get_old_k_top_line%NOTFOUND THEN
           -- store SQL error message on message stack
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'dnz_chr_id');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        i := i + 1;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- Getting the all the asset number
      FOR r_get_old_k_asset IN c_get_old_k_asset(p_dnz_chr_id) LOOP
        x_asset_num_tbl(j) := r_get_old_k_asset.asset_number;
        IF c_get_old_k_asset%NOTFOUND THEN
         -- store SQL error message on message stack
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Asset Number');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        j := j + 1;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- Check we got any record
      IF x_top_line_tbl.count = 0 THEN
         -- store SQL error message on message stack
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Top Line id');
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      IF x_asset_num_tbl.count = 0 THEN
         -- store SQL error message on message stack
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Asset Number');
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   ELSE
      -- store SQL error message on message stack
      -- Notify Error
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Dnz_chr_id');
      RAISE G_EXCEPTION_STOP_VALIDATION;
   END IF;
   RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- If the cursor is open then it has to be closed
     IF c_get_old_k_top_line%ISOPEN THEN
        CLOSE c_get_old_k_top_line;
     END IF;
     -- if the cursor is open
     IF c_get_old_k_asset%ISOPEN THEN
        CLOSE c_get_old_k_asset;
     END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
     RETURN(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     IF c_get_old_k_top_line%ISOPEN THEN
        CLOSE c_get_old_k_top_line;
     END IF;
     -- if the cursor is open
     IF c_get_old_k_asset%ISOPEN THEN
        CLOSE c_get_old_k_asset;
     END IF;
     RETURN(x_return_status);
 END get_k_tls_asset;
-----------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_offlease_asset
-- Description          : validation with OKX_ASSET_LINES_V and OKL_ASSET_RETURNS_V
-- Business Rules       : We first need to get the parent line id and
--                        Asset number of the old contract number.
--                        And Now the check the top_line_id present in OKL_ASSET_RETURNS_V
--                        which significe that the asset are off lease and ready for release
--
--                        Again we now check Asset number against OKX_ASSET_LINES_V to make sure
--                        asset number are not in lease with any other conract by looking for
--                        status of that line as TERMINATED , EXPIRED etc....
-- Parameters           : 1.P_dnz_chr_id Old Contract id
-- Version              : 1.0
-- End of Commnets
  FUNCTION validate_assets_offlease(p_dnz_chr_id    IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE)
  RETURN VARCHAR2 IS
    lt_top_line_tbl            g_top_line_tbl;
    lt_asset_num_tbl           g_asset_num_tbl;
    i                          NUMBER := 0;
    j                          NUMBER := 0;
    ln_top_present             NUMBER := 0;
    ln_asset_present           NUMBER := 0;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_validate_top_line(p_cle_id    OKC_K_LINES_V.ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_ASSET_RETURNS_B
                  WHERE kle_id = p_cle_id
                  AND ars_code = 'RE_LEASE');

    CURSOR c_validate_asset_number(p_asset_number   OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE)
    IS
    SELECT 1
    FROM dual
    WHERE EXISTS (SELECT '1'
                  FROM okx_asset_lines_v
                  WHERE asset_number = p_asset_number
                  AND line_status not in ('EXPIRED','TERMINATED','ABANDONED'));

  BEGIN
    -- data is required
    IF (p_dnz_chr_id = OKL_API.G_MISS_NUM) OR
       (p_dnz_chr_id IS NULL) THEN
       -- halt validation
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := get_k_tls_asset(p_dnz_chr_id    => p_dnz_chr_id,
                                       x_top_line_tbl  => lt_top_line_tbl,
                                       x_asset_num_tbl => lt_asset_num_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF (lt_top_line_tbl.COUNT > 0) THEN
      i := lt_top_line_tbl.FIRST;
      LOOP
        OPEN  c_validate_top_line(lt_top_line_tbl(i));
        IF c_validate_top_line%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'Top Line for Contract Number');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        FETCH c_validate_top_line INTO ln_top_present;
        CLOSE c_validate_top_line;
        EXIT WHEN (ln_top_present = null);
        EXIT WHEN (i = lt_top_line_tbl.LAST);
        i := lt_top_line_tbl.NEXT(i);
      END LOOP;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (lt_asset_num_tbl.COUNT > 0) THEN
      j := lt_asset_num_tbl.FIRST;
      LOOP
        OPEN  c_validate_asset_number(lt_asset_num_tbl(j));
        IF c_validate_asset_number%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'Asset Number');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        FETCH c_validate_asset_number INTO ln_asset_present;
        CLOSE c_validate_asset_number;
        EXIT WHEN (ln_asset_present <> null);
        EXIT WHEN (j = lt_asset_num_tbl.LAST);
        j := lt_asset_num_tbl.NEXT(j);
      END LOOP;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF ln_asset_present IS NOT NULL AND
       ln_top_present IS NULL THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF ln_asset_present IS NOT NULL OR
       ln_top_present IS NULL THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Cle_id');
    -- If the cursor is open then it has to be closed
    IF c_validate_asset_number%ISOPEN THEN
       CLOSE c_validate_asset_number;
    END IF;
    IF c_validate_top_line%ISOPEN THEN
       CLOSE c_validate_top_line;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
     RETURN(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack
      OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                      p_msg_name => G_UNEXPECTED_ERROR,
                      p_token1 => G_SQLCODE_TOKEN,
                      p_token1_value => SQLCODE,
                      p_token2 => G_SQLERRM_TOKEN,
                      p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_validate_asset_number%ISOPEN THEN
       CLOSE c_validate_asset_number;
    END IF;
    IF c_validate_top_line%ISOPEN THEN
       CLOSE c_validate_top_line;
    END IF;
    -- notify caller of an error as UNEXPETED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     RETURN(x_return_status);
  END validate_assets_offlease;

  -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Create_Release_Transaction
-- Description          : Create Re-lease Transaction
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE create_release_transaction
                         (p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_chr_id             IN  OKC_K_HEADERS_B.ID%TYPE,
                          p_new_chr_id         IN  OKC_K_HEADERS_B.ID%TYPE,
                          p_reason_code        IN  VARCHAR2,
                          p_description        IN  VARCHAR2,
                          p_trx_date           IN  DATE,
                          p_source_trx_id      IN  NUMBER,
                          p_source_trx_type    IN  VARCHAR2,
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_RELEASE_TRANSACTION';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR con_header_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT currency_code,
           authoring_org_id
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR try_csr(p_trx_type_name VARCHAR2) IS
    SELECT id
    FROM   okl_trx_types_tl
    WHERE  language = 'US'
    AND    name = p_trx_type_name;

    l_dummy         VARCHAR2(1);
    l_try_id        NUMBER;
    l_tcnv_rec      tcnv_rec_type;
    l_out_tcnv_rec  tcnv_rec_type;
    l_currency_code okc_k_headers_b.currency_code%TYPE;
    l_org_id        okc_k_headers_b.authoring_org_id%TYPE;

    --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  l_cntrct_number         OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Validate Re-lease Reason Code
    IF p_reason_code NOT IN ('CUSTOMER_CHANGE','PRODUCT_CHANGE') THEN
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LA_REV_RELCODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  con_header_csr(p_chr_id);
    FETCH con_header_csr INTO l_currency_code,
                              l_org_id;
    CLOSE con_header_csr;

    -- Validate Re-lease Transaction Type
    OPEN try_csr (p_trx_type_name => 'Release');
    FETCH try_csr INTO l_try_id;
    IF try_csr%NOTFOUND THEN
      CLOSE try_csr;
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LA_NO_TRY',
                          'TRX_TYPE',
                          'Release'
                         );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE try_csr;

    l_tcnv_rec.try_id                    := l_try_id;
    l_tcnv_rec.tsu_code                  := 'ENTERED';
    l_tcnv_rec.rbr_code                  := p_reason_code;
    l_tcnv_rec.description               := p_description;
    l_tcnv_rec.tcn_type                  := 'MAE';
    l_tcnv_rec.khr_id                    := p_chr_id;
    l_tcnv_rec.khr_id_old                := p_chr_id;
    l_tcnv_rec.khr_id_new                := p_new_chr_id;
    l_tcnv_rec.currency_code             := l_currency_code;
    l_tcnv_rec.date_transaction_occurred := p_trx_date;
    l_tcnv_rec.org_id                    := l_org_id;

    if (p_source_trx_id is not null and p_source_trx_type is not null )then
      l_tcnv_rec.source_trx_id   := p_source_trx_id;
      l_tcnv_rec.source_trx_type := p_source_trx_type;
    end if;
    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    okl_trx_contracts_pub.create_trx_contracts
       (p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_tcnv_rec       => l_tcnv_rec,
        x_tcnv_rec       => l_out_tcnv_rec
       );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_tcnv_rec := l_out_tcnv_rec;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

       x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END create_release_transaction;

  --Bug# 5005869
  -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Validate_Taa_Request_Info
-- Description          : Validations for the information entered in the
--                        Transfer and Assumption Request from Customer Service
--
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE validate_taa_request_info(p_api_version   IN  NUMBER,
                                      p_init_msg_list IN  VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      p_chr_id        IN  NUMBER,
                                      p_release_date  IN  DATE,
                                      p_source_trx_id IN  NUMBER,
                                      p_currency_code IN  VARCHAR2) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_TAA_REQUEST_INFO';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR taa_party_info_csr(p_taa_trx_id IN NUMBER) IS
    SELECT party_rel_id2_new,
           trx_number
    FROM okl_trx_contracts
    WHERE id = p_taa_trx_id;

    taa_party_info_rec taa_party_info_csr%ROWTYPE;

    CURSOR taa_chr_hdr_dtl_csr(p_taa_trx_id IN NUMBER) IS
    SELECT bill_to_site_id,
           cust_acct_id,
           bank_acct_id,
           invoice_format_id,
           payment_mthd_id,
           mla_id,
           credit_line_id,
           --Bug# 4191851
           insurance_yn,
           lease_policy_yn,
           ipy_type,
           policy_number,
           covered_amt,
           deductible_amt,
           effective_to_date,
           effective_from_date,
           proof_provided_date,
           proof_required_date,
           lessor_insured_yn,
           lessor_payee_yn,
           int_id,
           isu_id,
           agency_site_id,
           agent_site_id,
           territory_code
    FROM okl_taa_request_details_b
    WHERE tcn_id = p_taa_trx_id;

    taa_chr_hdr_dtl_rec taa_chr_hdr_dtl_csr%ROWTYPE;

    CURSOR taa_lines_csr(p_chr_id     IN NUMBER,
                        p_taa_trx_id IN NUMBER) IS
    SELECT cle.id,
           cle.name,
           tcl.source_column_1,
           tcl.source_value_1,
           tcl.source_column_2,
           tcl.source_value_2,
           tcl.source_column_3,
           tcl.source_value_3
    FROM okc_k_lines_v cle,
         okc_line_styles_b lse,
         okl_txl_cntrct_lns tcl
    WHERE cle.chr_id = p_chr_id
    AND cle.dnz_chr_id = p_chr_id
    AND lse.lty_code = 'FREE_FORM1'
    AND cle.lse_id = lse.id
    AND tcl.tcn_id = p_taa_trx_id
    AND tcl.kle_id = cle.id
    AND tcl.before_transfer_yn = 'N';

    CURSOR chk_party_csr(p_party_id IN NUMBER) IS
    SELECT 'Y'
    FROM   hz_parties prt
    WHERE  prt.party_id = p_party_id
    AND    prt.party_type IN ('PERSON','ORGANIZATION');

    CURSOR chk_cust_acc_csr(p_cust_acc_id IN NUMBER,
                            p_party_id IN NUMBER) is
    SELECT 'Y'
    FROM   hz_cust_accounts cas
    WHERE  cas.party_id = p_party_id
    AND    cas.cust_account_id = p_cust_acc_id;

    CURSOR chk_bill_to_csr(p_bill_to_site_id IN NUMBER,
                           p_cust_acc_id IN NUMBER,
                           p_party_id IN NUMBER,
                           p_chr_id IN NUMBER) is
    SELECT 'Y'
    FROM   okx_cust_site_uses_v site_use,
           hz_cust_acct_sites_all site,
           okc_k_headers_b chr
    WHERE  chr.id = p_chr_id
    AND    site.cust_acct_site_id   = site_use.cust_acct_site_id
    AND    site_use.party_id        = p_party_id
    AND    site_use.id1             = p_bill_to_site_id
    AND    site_use.cust_account_id = p_cust_acc_id
    AND    site_use.site_use_code   = 'BILL_TO'
    AND    site_use.b_status        = 'A'
    AND    site.status              = 'A'
    AND    site_use.org_id          = chr.authoring_org_id
    AND    site.org_id              = chr.authoring_org_id;

    CURSOR chk_bank_acc_csr(p_bank_acc_id  IN NUMBER,
                            p_bill_to_site_id IN NUMBER,
                            p_cust_acc_id IN NUMBER,
                            p_chr_id IN NUMBER) is
    SELECT 'Y'
    FROM   okx_rcpt_method_accounts_v rma,
           okc_k_headers_b chr
    WHERE  chr.id          = p_chr_id
    AND    rma.id1             = p_bank_acc_id
    AND    rma.customer_id     = p_cust_acc_id
    AND    rma.org_id          = chr.authoring_org_id
    AND    TRUNC(SYSDATE) between NVL(rma.start_date_active, TRUNC(SYSDATE))
           AND NVL(rma.end_date_active,TRUNC(SYSDATE));

    CURSOR chk_pymt_mthd_csr(p_payment_mthd_id  IN NUMBER,
                             p_bill_to_site_id IN NUMBER,
                             p_cust_acc_id IN NUMBER) IS
    SELECT 'Y'
    FROM   okx_receipt_methods_v
    WHERE  id1  = p_payment_mthd_id
    AND    customer_id  = p_cust_acc_id
--Bug 8325912    AND    site_use_id  = p_bill_to_site_id
    AND    TRUNC(SYSDATE) between NVL(start_date_active, TRUNC(SYSDATE))
           AND NVL(end_date_active,TRUNC(SYSDATE));


    CURSOR chk_inv_format_csr(p_invoice_format_id IN NUMBER) IS
    SELECT 'Y'
    FROM   okl_invoice_formats_v
    WHERE  id   = p_invoice_format_id
    AND    TRUNC(SYSDATE) between NVL(start_date, TRUNC(SYSDATE))
           AND NVL(end_date,TRUNC(SYSDATE));

    CURSOR chk_mla_csr(p_mla_id IN NUMBER) is
    SELECT 'Y'
    FROM okc_k_headers_b chr
    WHERE chr.id = p_mla_id
    AND chr.scs_code = 'MASTER_LEASE'
    AND chr.sts_code = 'ACTIVE'
    AND chr.template_yn = 'N'
    AND chr.buy_or_sell = 'S';

    CURSOR chk_credit_line_csr(p_credit_line_id IN NUMBER,
                               p_cust_id        IN NUMBER,
                               p_cust_acct_id   IN NUMBER,
                               p_currency_code  IN VARCHAR2) is
    SELECT 'Y'
    FROM okl_k_hdr_crdtln_uv crd,
         okc_k_headers_b chr
    WHERE crd.id = p_credit_line_id
    AND chr.id = crd.id
    AND crd.end_date >= p_release_date
    AND crd.cust_object1_id1 = p_cust_id
    AND crd.currency_code = p_currency_code
    AND chr.cust_acct_id = p_cust_acct_id;

    CURSOR chk_install_site_csr(p_install_site_id IN NUMBER,
                                p_cust_id        IN NUMBER) is
    SELECT 'Y'
    FROM   okx_party_site_uses_v
    WHERE  id1  = p_install_site_id
    AND    site_use_type = 'INSTALL_AT'
    AND    party_id      = p_cust_id
    AND    status = 'A';

    CURSOR chk_fa_loc_csr(p_location_id IN NUMBER) IS
    SELECT 'Y'
    FROM   okx_ast_locs_v
    WHERE  id1= p_location_id
    AND    NVL(enabled_flag,'Y') = 'Y'
    AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active, TRUNC(SYSDATE))
           AND NVL(end_date_active, TRUNC(SYSDATE));

    l_found VARCHAR2(1);

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN taa_party_info_csr(p_taa_trx_id => p_source_trx_id);
    FETCH taa_party_info_csr INTO taa_party_info_rec;
    CLOSE taa_party_info_csr;

    OPEN taa_chr_hdr_dtl_csr(p_taa_trx_id => p_source_trx_id);
    FETCH taa_chr_hdr_dtl_csr INTO taa_chr_hdr_dtl_rec;
    CLOSE taa_chr_hdr_dtl_csr;

    -- Validate Lessee
    IF (taa_party_info_rec.party_rel_id2_new IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_party_csr(p_party_id => taa_party_info_rec.party_rel_id2_new);
      FETCH chk_party_csr INTO l_found;
      CLOSE chk_party_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_CUST',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validate Customer Account
    IF (taa_chr_hdr_dtl_rec.cust_acct_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_cust_acc_csr(p_party_id    => taa_party_info_rec.party_rel_id2_new,
                            p_cust_acc_id => taa_chr_hdr_dtl_rec.cust_acct_id);
      FETCH chk_cust_acc_csr INTO l_found;
      CLOSE chk_cust_acc_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_CUST_ACC',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validate Bill-To-Site
    IF (taa_chr_hdr_dtl_rec.bill_to_site_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_bill_to_csr(p_chr_id => p_chr_id,
                           p_bill_to_site_id    => taa_chr_hdr_dtl_rec.bill_to_site_id,
                           p_party_id    => taa_party_info_rec.party_rel_id2_new,
                           p_cust_acc_id => taa_chr_hdr_dtl_rec.cust_acct_id);
      FETCH chk_bill_to_csr INTO l_found;
      CLOSE chk_bill_to_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_BILL_TO',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validate Bank Account
    IF (taa_chr_hdr_dtl_rec.bank_acct_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_bank_acc_csr(p_chr_id => p_chr_id,
                            p_bank_acc_id => taa_chr_hdr_dtl_rec.bank_acct_id,
                            p_bill_to_site_id => taa_chr_hdr_dtl_rec.bill_to_site_id,
                            p_cust_acc_id => taa_chr_hdr_dtl_rec.cust_acct_id);
      FETCH chk_bank_acc_csr INTO l_found;
      CLOSE chk_bank_acc_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_BANK_ACC',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validate Payment Method
    IF (taa_chr_hdr_dtl_rec.payment_mthd_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_pymt_mthd_csr(p_payment_mthd_id => taa_chr_hdr_dtl_rec.payment_mthd_id,
                             p_bill_to_site_id => taa_chr_hdr_dtl_rec.bill_to_site_id,
                             p_cust_acc_id => taa_chr_hdr_dtl_rec.cust_acct_id);
      FETCH chk_pymt_mthd_csr INTO l_found;
      CLOSE chk_pymt_mthd_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_PYMT_MTHD',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validate Invoice Format
    IF (taa_chr_hdr_dtl_rec.invoice_format_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_inv_format_csr(p_invoice_format_id => taa_chr_hdr_dtl_rec.invoice_format_id);
      FETCH chk_inv_format_csr INTO l_found;
      CLOSE chk_inv_format_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_INV_FMT',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- Validate MLA
    IF (taa_chr_hdr_dtl_rec.mla_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_mla_csr(p_mla_id => taa_chr_hdr_dtl_rec.mla_id);
      FETCH chk_mla_csr INTO l_found;
      CLOSE chk_mla_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_MLA',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validate Credit Line
    IF (taa_chr_hdr_dtl_rec.credit_line_id IS NOT NULL) THEN
      l_found := 'N';
      OPEN chk_credit_line_csr(p_credit_line_id => taa_chr_hdr_dtl_rec.credit_line_id,
                       p_cust_id => taa_party_info_rec.party_rel_id2_new,
                       p_cust_acct_id => taa_chr_hdr_dtl_rec.cust_acct_id,
                       p_currency_code => p_currency_code);
      FETCH chk_credit_line_csr INTO l_found;
      CLOSE chk_credit_line_csr;

      IF l_found = 'N' THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_INVALID_CL',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_party_info_rec.trx_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;


    FOR taa_lines_rec IN taa_lines_csr(p_chr_id     => p_chr_id,
                                       p_taa_trx_id => p_source_trx_id)
    LOOP

      -- Asset Line level Install At Location
      IF (taa_lines_rec.source_column_1 = 'INSTALL_SITE_ID'
         AND taa_lines_rec.source_value_1 IS NOT NULL) THEN
        l_found := 'N';
        OPEN chk_install_site_csr(p_install_site_id => taa_lines_rec.source_value_1,
                                  p_cust_id         => taa_party_info_rec.party_rel_id2_new);
        FETCH chk_install_site_csr INTO l_found;
        CLOSE chk_install_site_csr;

        IF l_found = 'N' THEN
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_REL_INVALID_INS_SITE',
                              p_token1       => 'REQ_NUM',
                              p_token1_value => taa_party_info_rec.trx_number,
                              p_token2       => 'ASSET_NUM',
                              p_token2_value => taa_lines_rec.name);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

     -- Asset Line level Fixed asset location
      IF (taa_lines_rec.source_column_2 = 'FA_LOC_ID'
         AND taa_lines_rec.source_value_2 IS NOT NULL) THEN
        l_found := 'N';
        OPEN chk_fa_loc_csr(p_location_id => taa_lines_rec.source_value_2);
        FETCH chk_fa_loc_csr INTO l_found;
        CLOSE chk_fa_loc_csr;

        IF l_found = 'N' THEN
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_REL_INVALID_FA_LOC',
                              p_token1       => 'REQ_NUM',
                              p_token1_value => taa_party_info_rec.trx_number,
                              p_token2       => 'ASSET_NUM',
                              p_token2_value => taa_lines_rec.name);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- Asset Line level Bill-To-Site
      IF (taa_lines_rec.source_column_3 = 'BILL_TO_SITE_ID'
         AND taa_lines_rec.source_value_3 IS NOT NULL) THEN
        l_found := 'N';
        OPEN chk_bill_to_csr(p_chr_id          => p_chr_id,
                             p_bill_to_site_id => taa_lines_rec.source_value_3,
                             p_party_id    => taa_party_info_rec.party_rel_id2_new,
                             p_cust_acc_id     => taa_chr_hdr_dtl_rec.cust_acct_id);
        FETCH chk_bill_to_csr INTO l_found;
        CLOSE chk_bill_to_csr;

        IF l_found = 'N' THEN
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_REL_INVALID_AST_BILL',
                              p_token1       => 'REQ_NUM',
                              p_token1_value => taa_party_info_rec.trx_number,
                              p_token2       => 'ASSET_NUM',
                              p_token2_value => taa_lines_rec.name);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END validate_taa_request_info;
  --Bug# 5005869
  -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Furong Miao            19-NOV-2004
-- Procedure Name       : Validate_Release_Contract
-- Description          : Validations upon creation and activation of
--                        re-leased contract
--
-- Business Rules       : This procedure will be overloaded with one more
--                        parameter p_call_program which indicates from where
--                        this procedure is being called. It can be 'RELEASE' or
--                        'ACTIVATE'
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE validate_release_contract(p_api_version   IN  NUMBER,
                                      p_init_msg_list IN  VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      p_chr_id        IN  NUMBER,
                                      p_release_date  IN  DATE,
                                      p_source_trx_id IN  NUMBER,
									  p_call_program  IN  VARCHAR2) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_REL_CONTRACT';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR chr_csr(p_chr_id       IN NUMBER) IS
    SELECT chr.start_date,
           chr.end_date,
           chr.contract_number,
           khr.deal_type,
           sts_code,
	   	   chr.cust_acct_id,
           --Bug# 4173345
           chr.orig_system_source_code,
           --Bug# 4631549
           chr.currency_code
	FROM okc_k_headers_b chr,
         okl_k_headers khr
    WHERE chr.id = p_chr_id
    AND   chr.id = khr.id;

    chr_rec   chr_csr%ROWTYPE;

   -- Called at activation to exclude the current contract --
    CURSOR pending_trx_act_csr(p_chr_id IN NUMBER)
    IS
    SELECT 'Y'
    FROM   okl_trx_contracts tcn
    WHERE  tcn.khr_id = p_chr_id
    AND    tcn.tsu_code IN ('ENTERED','WORKING','WAITING','SUBMITTED')
--rkuttiya added for 12.1.1 Multi GAAP
    AND    tcn.representation_type = 'PRIMARY'
--
    AND   (tcn.tcn_type IN ('TRBK','RVS','SPLC'));

    CURSOR taa_request_csr(p_source_trx_id IN NUMBER)
    IS
    SELECT tsu_code,
           complete_transfer_yn,
           trx_number
    FROM okl_trx_contracts
    where id = p_source_trx_id;

    taa_request_rec        taa_request_csr%ROWTYPE;

    CURSOR chk_chr_accept_term_qte_csr
                 (p_orig_chr_id IN NUMBER)
    IS
    SELECT fin_ast_cle.id,
           fin_ast_cle.name
    FROM okc_k_lines_v fin_ast_cle,
         okc_k_headers_b chr,
         okc_line_styles_b fin_ast_lse,
         okl_trx_quotes_b qte,
         okl_txl_quote_lines_b tql
    WHERE chr.id = p_orig_chr_id
    AND   fin_ast_cle.chr_id = chr.id
    AND   fin_ast_cle.dnz_chr_id = chr.id
    AND   fin_ast_cle.sts_code = chr.sts_code
    AND   fin_ast_cle.lse_id = fin_ast_lse.id
    AND   fin_ast_lse.lty_code = 'FREE_FORM1'
    AND   tql.kle_id = fin_ast_cle.id
    AND   tql.qte_id = qte.id
    AND   tql.qlt_code = 'AMCFIA'
    AND   NVL(qte.accepted_yn,'N') = 'Y'
    AND   NVL(qte.consolidated_yn,'N') = 'N';

    CURSOR chk_taa_accept_term_qte_csr
                 (p_orig_chr_id    IN NUMBER
                 ,p_source_trx_id  IN NUMBER)
    IS
    SELECT fin_ast_cle.id,
           fin_ast_cle.name
    FROM okl_txl_cntrct_lns tcl,
         okc_k_lines_v fin_ast_cle,
         okl_trx_quotes_b qte,
         okl_txl_quote_lines_b tql
    WHERE tcl.tcn_id = p_source_trx_id
    AND   tcl.before_transfer_yn = 'N'
    AND   fin_ast_cle.chr_id = p_orig_chr_id
    AND   fin_ast_cle.dnz_chr_id = p_orig_chr_id
    AND   fin_ast_cle.id = tcl.kle_id
    AND   tql.kle_id = fin_ast_cle.id
    AND   tql.qte_id = qte.id
    AND   tql.qlt_code = 'AMCFIA'
    AND   NVL(qte.accepted_yn,'N') = 'Y'
    AND   NVL(qte.consolidated_yn,'N') = 'N';

    CURSOR chk_chr_equip_exch_req_csr
                  (p_orig_chr_id IN NUMBER)
    IS
    SELECT fin_ast_cle.id,
           fin_ast_cle.name
    FROM okc_k_lines_v fin_ast_cle,
         okc_k_headers_b chr,
         okc_line_styles_b fin_ast_lse,
         okl_trx_assets ota,
         okl_txl_assets_b otl
    WHERE chr.id = p_orig_chr_id
    AND   fin_ast_cle.chr_id = chr.id
    AND   fin_ast_cle.dnz_chr_id = chr.id
    AND   fin_ast_cle.sts_code = chr.sts_code
    AND   fin_ast_cle.lse_id = fin_ast_lse.id
    AND   fin_ast_lse.lty_code = 'FREE_FORM1'
    AND   otl.kle_id = fin_ast_cle.id
    AND   ota.tas_type IN ('LLT','LLP','NLP')
    AND   ota.id = otl.tas_id
    AND   otl.tal_type = 'OAS'
    AND   ota.tsu_code = 'PROCESSED';

    CURSOR chk_taa_equip_exch_req_csr
                  (p_orig_chr_id    IN NUMBER
                  ,p_source_trx_id  IN NUMBER)
    IS
    SELECT fin_ast_cle.id,
           fin_ast_cle.name
    FROM okl_txl_cntrct_lns tcl,
         okc_k_lines_v fin_ast_cle,
         okl_trx_assets ota,
         okl_txl_assets_b otl
    WHERE tcl.tcn_id = p_source_trx_id
    AND   tcl.before_transfer_yn = 'N'
    AND   fin_ast_cle.chr_id = p_orig_chr_id
    AND   fin_ast_cle.dnz_chr_id = p_orig_chr_id
    AND   fin_ast_cle.id = tcl.kle_id
    AND   otl.kle_id = fin_ast_cle.id
    AND   ota.tas_type IN ('LLT','LLP','NLP')
    AND   ota.id = otl.tas_id
    AND   otl.tal_type = 'OAS'
    AND   ota.tsu_code = 'PROCESSED';

    CURSOR chk_linked_serv_chr_csr(p_chr_id IN NUMBER)
    IS
    SELECT 'Y'
    FROM okc_k_rel_objs_v
    WHERE chr_id = p_chr_id
    AND jtot_object1_code = 'OKL_SERVICE'
   -- AND rty_code IN ('OKLUBB','OKLSRV')
        AND rty_code = 'OKLSRV';
  --rajnisku: Bug 6657564  : End

    l_found VARCHAR2(30);
    l_icx_date_format     VARCHAR2(240);
    l_funding_remaining   NUMBER;
    l_term_duration       NUMBER;
    l_asset_num_token     VARCHAR2(2000);
	l_receipt_date        DATE;
	l_acceptance_date     DATE;
	l_invoice_date        DATE;

	--Cursor for obtaining the last receipt date
    /*--Bug# 4061058
    CURSOR last_receipt_date_csr(p_cust_acct_number IN VARCHAR2) IS
    SELECT max(receipt_date)
    FROM okl_ext_csh_rcpts_b
    WHERE customer_number = p_cust_acct_number;*/

    --Cusor for obtaining the last accepted termination quote date.
    CURSOR last_trq_date_csr(p_contract_id IN NUMBER) IS
    SELECT max(date_accepted)
    FROM okl_trx_quotes_b
    WHERE khr_id = p_contract_id
    AND QST_CODE = 'ACCEPTED';

    -- Cursor for obtaining the last credit memo date
    CURSOR last_credit_date_csr(p_contract_id IN NUMBER) IS
    SELECT max(date_invoiced)
    FROM  okl_trx_ar_invoices_b tar,
          okl_trx_types_b  typ
    WHERE tar.khr_id = p_contract_id
    AND   tar.amount<0
    AND   tar.try_id = typ.id
    AND   typ.aep_code = 'CREDIT_MEMO';

    --Bug# 4151222
    l_fully_funded_flag BOOLEAN;

    --Bug# 4631549
    --cusror to fetch all lines expected_asset_cost
    Cursor l_exp_cost_csr(p_chr_id IN NUMBER) is
    Select kle.expected_Asset_Cost,
           cleb.orig_system_id1 orig_cle_id,
           chrb.id              new_chr_id,
           cleb.id              new_cle_id
    From
           okc_k_lines_b   cleb,
           okl_k_lines     kle,
           okc_k_headers_b chrb
    where  kle.id                       = cleb.id
    and    cleb.dnz_chr_id              = chrb.id
    and    cleb.lse_id                  = 33 --financial asset line
    and    cleb.sts_code                = 'APPROVED'
    and    cleb.orig_system_id1 is NOT NULL
    and    chrb.orig_system_id1         = p_chr_id
    and    chrb.orig_system_source_code = 'OKL_RELEASE'
    and    chrb.sts_code                = 'APPROVED';

    l_exp_cost_rec l_exp_cost_csr%ROWTYPE;

    --cusror to fetch fixed asset details
    cursor l_fa_csr (p_cle_id in number,
                     p_chr_id in number) is
    select fb.asset_id,
           fb.book_type_code
    from   fa_books fb,
           fa_book_controls fbc,
           okc_k_items cim,
           okc_k_lines_b cleb_fa
    where  fb.asset_id      = cim.object1_id1
    and    fb.book_type_code = fbc.book_type_code
    and    fbc.book_class   = 'CORPORATE'
    and    fb.transaction_header_id_out is NULL
    and    cim.jtot_object1_code = 'OKX_ASSET'
    and    cim.object1_id2       = '#'
    and    cim.dnz_chr_id        = cleb_fa.dnz_chr_id
    and    cim.cle_id            = cleb_fa.id
    and    cleb_fa.cle_id        = p_cle_id
    and    cleb_fa.dnz_chr_id    = p_chr_id
    and    cleb_fa.lse_id        = 42; -- fixed asset

    l_fa_rec l_fa_csr%ROWTYPE;

    --cursor to fetch number of units of the asset
    cursor l_units_csr (p_cle_id in number,
                        p_chr_id in number) is
    select cleb_model.id  model_cle_id,
           cim_model.number_of_items
    from   okc_k_lines_b  cleb_model,
           okc_k_items    cim_model
    where  cim_model.cle_id       = cleb_model.id
    and    cim_model.dnz_chr_id   = p_chr_id
    and    cleb_model.cle_id      = p_cle_id
    and    cleb_model.dnz_chr_id  = p_chr_id
    and    cleb_model.lse_id      = 34; --model line

    l_units_rec l_units_csr%ROWTYPE;


    --cursor to fetch asset number
    cursor l_asset_num_csr(p_asset_id in number) is
    select asset_number
    from   fa_additions_b
    where  asset_id = p_Asset_id;

    l_asset_num_rec l_asset_num_csr%ROWTYPE;

    l_corp_net_book_value  NUMBER;
    l_expected_cost        NUMBER;
    l_exp_cost_mismatch_yn VARCHAR2(1);
    l_capital_amount       NUMBER;
    l_capitalized_interest NUMBER;

    l_model_clev_rec        okc_contract_pub.clev_rec_type;
    lx_model_clev_rec       okc_contract_pub.clev_rec_type;
    l_finast_clev_rec       okl_okc_migration_pvt.clev_rec_type;
    lx_finast_clev_rec      okl_okc_migration_pvt.clev_rec_type;
    l_finast_klev_rec       okl_contract_pub.klev_rec_type;
    lx_finast_klev_rec      okl_contract_pub.klev_rec_type;
    l_finast_clev_rec2       okl_okc_migration_pvt.clev_rec_type;
    lx_finast_clev_rec2      okl_okc_migration_pvt.clev_rec_type;
    l_finast_klev_rec2       okl_contract_pub.klev_rec_type;
    lx_finast_klev_rec2      okl_contract_pub.klev_rec_type;

    --cursor to fetch new contract currency
    cursor l_new_chr_hdr_csr (p_chr_id in number) is
    select currency_code
    from   okc_k_headers_b
    where  id = p_chr_id;

    l_new_chr_hdr_rec l_new_chr_hdr_csr%ROWTYPE;
    --End Bug# 4631549
         --rajnisku: Bug 6657564
 	     --cursor to check whether the TNA request contains asset
 	     --associated to a Usage line
 	     cursor l_chk_link_usage_csr (p_source_trx_id NUMBER) IS
 	     select '!' from dual
 	     where exists (
 	         select 1
 	         from okc_k_items UITEM ,
 	         OKC_K_LINES_B USAGE,
 	         OKC_K_LINES_B USUB_LINE,
 	         okc_k_items LINK_ITEM,
 	         okc_k_lines_b top_line,
 	         okl_txl_cntrct_lns tcl
 	         where UITEM.dnz_chr_id=tcl.khr_id
 	         and UITEM.JTOT_OBJECT1_CODE = 'OKL_USAGE'
 	         and UITEM.OBJECT1_ID2='#'
 	         and USAGE.id=UITEM.cle_id
 	         and USUB_LINE.cle_id=USAGE.id
 	         and USUB_LINE.lse_id=(select id from okc_line_styles_v where lty_code = 'LINK_USAGE_ASSET')
 	         and LINK_ITEM.cle_id=USUB_LINE.id
 	         and LINK_ITEM.OBJECT1_ID1=top_line.id
 	         and LINK_ITEM.OBJECT1_ID2='#'
 	         and top_line.lse_id=(select id from okc_line_styles_v where lty_code = 'FREE_FORM1')
 	         and top_line.id = tcl.kle_id
 	         and tcl.tcn_id = p_source_trx_id
 	         AND tcl.before_transfer_yn = 'N'
 	     );

 	    cursor l_ubb_contract_csr(p_orig_chr_id number) IS
 	    SELECT oks.date_terminated,sts.ste_code
 	     FROM okc_k_rel_objs_v krelobj ,
 	          okc_k_headers_b oks,
 	          okc_statuses_b sts
 	     WHERE krelobj.JTOT_OBJECT1_CODE = 'OKL_SERVICE'
 	     AND krelobj.RTY_CODE = 'OKLUBB'
 	     and krelobj.OBJECT1_ID1 = oks.id
 	     and krelobj.OBJECT1_ID2='#'
 	     and krelobj.CHR_ID = p_orig_chr_id --original contract id
 	     and sts.code=oks.sts_code;

 	    l_ubb_contract_rec l_ubb_contract_csr%ROWTYPE;
 	    l_link_usage varchar2(1);
 	    l_chk_ubb_terminated_yn varchar2(1):='N';
 	   --rajnisku: Bug 6657564  :End

    --Bug# 7456516 start
    CURSOR c_last_invoice_date(p_khr_id IN NUMBER) IS
    SELECT INVOICE_DATE FROM( SELECT MAX(HD.DATE_CONSOLIDATED) INVOICE_DATE
    FROM AR_PAYMENT_SCHEDULES_ALL PS,
         OKL_CNSLD_AR_STRMS_B ST,
         OKL_CNSLD_AR_LINES_B LN,
         OKL_CNSLD_AR_HDRS_B HD,
         OKC_K_HEADERS_B CN
    WHERE PS.CLASS = 'INV'
    AND ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID
    AND LN.ID = ST.LLN_ID
    AND HD.ID = LN.CNR_ID
    AND CN.ID = ST.KHR_ID
    AND PS.AMOUNT_DUE_REMAINING < PS.AMOUNT_DUE_ORIGINAL
    AND CN.ID = p_khr_id
    AND HD.ORG_ID = CN.AUTHORING_ORG_ID
    UNION
    SELECT max(ractrx.trx_date) INVOICE_DATE
    FROM  ra_customer_trx_all ractrx,
      ra_customer_trx_lines_all ractrl,
      ar_payment_schedules_all ps,
      okc_k_headers_b chr
    WHERE chr.id = p_khr_id
    AND   chr.contract_number = ractrl.interface_line_attribute6
    AND   ractrx.customer_trx_id = ractrl.customer_trx_id
    AND   ractrl.line_type = 'LINE'
    AND   ractrl.interface_line_attribute1 IS NULL -- Assume 1 as cnsld inv
    AND   ractrl.amount_due_remaining < ractrl.amount_due_original
    AND   ps.customer_trx_id = ractrx.customer_trx_id
    AND   ps.class = 'INV')
    WHERE INVOICE_DATE IS NOT NULL;
    --Bug# 7456516 end

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	open chr_csr(p_chr_id => p_chr_id);
    fetch chr_csr into chr_rec;
    close chr_csr;

	if (p_call_program in ('RELEASE','ACTIVATE') ) then

      -- Validate that Contract status is valid
      if chr_rec.sts_code NOT IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD',
                                'LITIGATION_HOLD') then
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_REL_INVALID_STATUS',
                          p_token1       => 'CONTRACT_NUM',
                          p_token1_value => chr_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;

      -- Validate if Linked Service Contract exists
      l_found := 'N';
      open chk_linked_serv_chr_csr(p_chr_id => p_chr_id);
      fetch chk_linked_serv_chr_csr into l_found;
      close chk_linked_serv_chr_csr;
      if (l_found = 'Y') then
        OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_REL_LINK_SERV_CNTRCT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;

      -- T and A Validations
      -- Validate that T and A request is Approved
      IF p_source_trx_id IS NOT NULL THEN

        open taa_request_csr(p_source_trx_id => p_source_trx_id);
        fetch taa_request_csr into taa_request_rec;
        close taa_request_csr;
        if taa_request_rec.tsu_code <> 'APPROVED' then
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_TAA_REQ_NO_APPRVD',
                            p_token1       => 'REQ_NUM',
                            p_token1_value => taa_request_rec.trx_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        end if;
      END IF;

      -- Validations that assets are not a part of any
      -- Accepted Termination quote or
      -- Processed Equipment Exchange

      -- T and A transaction
      if (p_source_trx_id IS NOT NULL) then

        l_found := 'N';
        l_asset_num_token := null;
        for chk_taa_accept_term_qte_rec in
            chk_taa_accept_term_qte_csr
                        (p_orig_chr_id   => p_chr_id
                        ,p_source_trx_id => p_source_trx_id) loop

          l_found := 'Y';
          if l_asset_num_token is null then
            l_asset_num_token := l_asset_num_token ||chk_taa_accept_term_qte_rec.name;
          else
            l_asset_num_token := l_asset_num_token ||', '||chk_taa_accept_term_qte_rec.name;
          end if;
        end loop;

        if l_found = 'Y' then
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_NO_ACCEPT_TQ',
                            p_token1       => 'ASST_NUM',
                            p_token1_value => l_asset_num_token);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        end if;

        l_found := 'N';
        l_asset_num_token := null;
        for chk_taa_equip_exch_req_rec in
            chk_taa_equip_exch_req_csr
                       (p_orig_chr_id   => p_chr_id
                       ,p_source_trx_id => p_source_trx_id) loop

          l_found := 'Y';
          if l_asset_num_token is null then
            l_asset_num_token := l_asset_num_token ||chk_taa_equip_exch_req_rec.name;
          else
            l_asset_num_token := l_asset_num_token ||', '||chk_taa_equip_exch_req_rec.name;
          end if;
        end loop;

        if l_found = 'Y' then
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_NO_PROCESSED_EQ',
                            p_token1       => 'ASSET_NUM',
                            p_token1_value => l_asset_num_token);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        end if;

      -- Re-lease contract
      else
        l_found := 'N';
        l_asset_num_token := null;
        for chk_chr_accept_term_qte_rec in
            chk_chr_accept_term_qte_csr
                        (p_orig_chr_id   => p_chr_id) loop

          l_found := 'Y';
          if l_asset_num_token is null then
            l_asset_num_token := l_asset_num_token ||chk_chr_accept_term_qte_rec.name;
          else
            l_asset_num_token := l_asset_num_token ||', '||chk_chr_accept_term_qte_rec.name;
          end if;
        end loop;

        if l_found = 'Y' then
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_NO_ACCEPT_TQ',
                            p_token1       => 'ASST_NUM',
                            p_token1_value => l_asset_num_token);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        end if;

        l_found := 'N';
        l_asset_num_token := null;
        for chk_chr_equip_exch_req_rec in
            chk_chr_equip_exch_req_csr
                       (p_orig_chr_id   => p_chr_id) loop

          l_found := 'Y';
          if l_asset_num_token is null then
            l_asset_num_token := l_asset_num_token ||chk_chr_equip_exch_req_rec.name;
          else
            l_asset_num_token := l_asset_num_token ||', '||chk_chr_equip_exch_req_rec.name;
          end if;
        end loop;

        if l_found = 'Y' then
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_NO_PROCESSED_EQ',
                            p_token1       => 'ASSET_NUM',
                            p_token1_value => l_asset_num_token);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        end if;
      end if;

      -- Validate that the Contract is fully funded
      /* Bug# 4151222: Funding validation api call changed
      l_funding_remaining :=
           OKL_FUNDING_PVT.get_chr_canbe_funded_rem(p_contract_id => p_chr_id);
      --Bug# 4080102 - Changed to check for Funding remaining > 0
      if (l_funding_remaining > 0) then
        OKL_API.SET_MESSAGE(G_APP_NAME,
                            'OKL_LLA_REL_NOT_FULLY_FUNDED');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;*/

      --Bug# 4151222
      --Bug# 7435888: Removed check for contract being fully funded
      /*l_fully_funded_flag := false;

      --Bug# 4173345
      -- Re-leased contracts should be treated as fully funded
      if NVL(chr_rec.orig_system_source_code,OKL_API.G_MISS_CHAR) = 'OKL_RELEASE' then
        l_fully_funded_flag := true;
      else
        OKL_FUNDING_PVT.is_contract_fully_funded(
          p_api_version                  => p_api_version
         ,p_init_msg_list                => p_init_msg_list
         ,x_return_status                => x_return_status
         ,x_msg_count                    => x_msg_count
         ,x_msg_data                     => x_msg_data
         ,x_value                        => l_fully_funded_flag
         ,p_contract_id                  => p_chr_id);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
      end if;
      --Bug# 4173345

      if (l_fully_funded_flag = false) then
        OKL_API.SET_MESSAGE(G_APP_NAME,
                            'OKL_LLA_REL_NOT_FULLY_FUNDED');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;
      */ --Bug# 7435888

	  -- Validate whether the release date is after
	  -- last Receipt Date, last Credit Memo Date and
	  -- last accepted Termination Quote date.

        --Bug# 7456516 start
        -- Corrected query to get latest invoice date
        -- for an invoice against which receipt has
        -- been applied

        open c_last_invoice_date(p_khr_id => p_chr_id);
	  fetch c_last_invoice_date into l_receipt_date;
	  close c_last_invoice_date;
        --Bug# 7456516 end

	  open last_trq_date_csr (p_contract_id => p_chr_id);
      fetch last_trq_date_csr into l_acceptance_date;
	  close last_trq_date_csr;

	  open last_credit_date_csr (p_contract_id => p_chr_id);
	  fetch last_credit_date_csr into l_invoice_date;
	  close last_credit_date_csr;

        -- Bug# 4072796
	  if (l_receipt_date IS NOT NULL) and (p_release_date <= l_receipt_date ) then
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_CS_TF_RECEIPT_DATE',
                            p_token1       => 'INVOICE_DATE',
                            p_token1_value => l_receipt_date);
        RAISE OKL_API.G_EXCEPTION_ERROR;
	  elsif (l_acceptance_date IS NOT NULL) and (p_release_date <= l_acceptance_date ) then
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_CS_TF_QUOTE_DATE',
                            p_token1       => 'QUOTE_DATE',
                            p_token1_value => l_acceptance_date);
        RAISE OKL_API.G_EXCEPTION_ERROR;
	  elsif (l_invoice_date IS NOT NULL) and (p_release_date <= l_invoice_date) then
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_CS_TF_CREDITMEMO_DATE',
                            p_token1       => 'CREDIT_MEMO',
                            p_token1_value => l_invoice_date);
        RAISE OKL_API.G_EXCEPTION_ERROR;
	  end if;
	end if;
		      -- T and A Validations
 	      --rajnisku: Bug 6657564  : Added validation to block TNA
 	      --if the transferred asset is associated to a Usage line
 	      --or if service contract is not terminated

 	      IF p_source_trx_id IS NOT NULL THEN
 	            l_link_usage := '?';
 	            l_chk_ubb_terminated_yn:='N';
 	            --check any transferred asset line is associated to a usage line
 	            OPEN l_chk_link_usage_csr (p_source_trx_id => p_source_trx_id);
 	            FETCH l_chk_link_usage_csr INTO l_link_usage;
 	            IF l_chk_link_usage_csr%NOTFOUND THEN
 	              NULL;
 	            END IF;
 	            CLOSE l_chk_link_usage_csr;

 	            IF l_link_usage = '!'
 	              AND NVL(taa_request_rec.complete_transfer_yn,'X')='N' THEN
 	                 --set message
 	                 --The transfer is not permitted because one of the transferred
 	                 --asset is associated to a usage line.
 	                  OKL_API.SET_MESSAGE(G_APP_NAME,
 	                                   'OKL_CS_TA_ASSET_WITH_UBB_NA');
 	                  RAISE OKL_API.G_EXCEPTION_ERROR;
 	            END IF;

 	            IF l_link_usage = '!' AND
 	               NVL(taa_request_rec.complete_transfer_yn,'X')='Y' THEN
 	                 l_chk_ubb_terminated_yn:='Y';
 	             END IF;

 	         ELSE -- p_source_trx_id is null
 	          --full TnA performed from html screen without TnA request
 	           l_chk_ubb_terminated_yn:='Y';
 	        END IF;

 	        --check whether the associated usage contract is terminated
 	        IF l_chk_ubb_terminated_yn='Y'  THEN

 	          OPEN l_ubb_contract_csr (p_orig_chr_id => p_chr_id);
 	          FETCH l_ubb_contract_csr INTO l_ubb_contract_rec;
 	          IF l_ubb_contract_csr%NOTFOUND THEN
 	              NULL;
 	          ELSE
 	              IF NVL(l_ubb_contract_rec.ste_code,'X')<>'TERMINATED' THEN
 	             --set message
 	             --You must terminate the associated service contract before
 	             --release is permitted.
 	              OKL_API.SET_MESSAGE(G_APP_NAME,
 	                           'OKL_LLA_REL_TERM_SERV_CNTRCT');
 	             RAISE OKL_API.G_EXCEPTION_ERROR;
 	           END IF;
 	          END IF;
 	          CLOSE l_ubb_contract_csr;
 	        END IF; --check
 	      --rajnisku: Bug 6657564  :End

	-- Validation at activation --
      -- Bug# 4072796
	if (p_call_program = 'ACTIVATE') then
      if (p_release_date > TRUNC(sysdate)) then
        OKL_API.SET_MESSAGE(G_APP_NAME,
                            'OKL_CS_NO_TF_FUTURE_DATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
	  end if;

      -- Validate if Contract is undergoing Revision
      l_found := 'N';
      open pending_trx_act_csr(p_chr_id => p_chr_id);
      fetch pending_trx_act_csr into l_found;
      close pending_trx_act_csr;
      if (l_found = 'Y') then
        OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_REV_IN_PROGRESS');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;
	end if;

    --Bug# 4631549
    --Validate if the expected asset value has changed since the time the asset was authored
    If (p_call_program = 'ACTIVATE') then
    l_exp_cost_mismatch_yn := 'N';
    Open l_exp_cost_csr(p_chr_id => p_chr_id);
    loop
        fetch l_exp_cost_csr into l_exp_cost_rec;
        Exit when l_exp_cost_csr%NOTFOUND;
        open l_fa_csr(p_cle_id => l_exp_cost_rec.orig_cle_id,
                      p_chr_id => p_chr_id);
        fetch l_fa_csr into l_fa_rec;
        If l_fa_csr%NOTFOUND Then
            NULL;
        End If;
        close l_fa_csr;

        --Bug# 4631549 : Date validation removed to fix GE bug# 4873420
        -- Release contract start date should fall in the current
        -- open period in FA
        --validate_release_date
                         --(p_api_version     => p_api_version,
                          --p_init_msg_list   => p_init_msg_list,
                          --x_return_status   => x_return_status,
                          --x_msg_count       => x_msg_count,
                          --x_msg_data        => x_msg_data,
                          --p_book_type_code  => l_fa_rec.book_type_code,
                          --p_release_date    => p_release_date);

        --IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        --ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            --RAISE OKL_API.G_EXCEPTION_ERROR;
        --END IF;

        -- Calculate  Expected asset cost (cost of the asset expected after re-lease)
        Calculate_Expected_Cost
                               (p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_new_chr_id     => l_exp_cost_rec.new_chr_id,
                                p_orig_chr_id    => p_chr_id,
                                p_orig_cle_id    => l_exp_cost_rec.orig_cle_id,
                                p_asset_id       => l_fa_rec.asset_id,
                                p_book_type_code => l_fa_rec.book_type_code,
                                p_release_date   => p_release_date,
                                p_nbv            => l_corp_net_book_value,
                                x_expected_cost  => l_expected_cost);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        If nvl(l_expected_cost,0) <> nvl(l_exp_cost_rec.expected_Asset_cost,0) then
            l_exp_cost_mismatch_yn := 'Y';
            open l_asset_num_csr(p_asset_id => l_fa_rec.asset_id);
            fetch l_asset_num_csr into l_asset_num_rec;
            close l_asset_num_csr;
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name      => 'OKL_LA_EXPECTED_ASSET_COST_MOD',
                                p_token1        => 'ASSET_NUMBER',
                                p_token1_value  => l_asset_num_rec.asset_number);
        Elsif nvl(l_expected_cost,0) = nvl(l_exp_cost_rec.expected_asset_cost,0) then
            open l_units_csr(p_cle_id => l_exp_cost_rec.new_cle_id,
                             p_chr_id => l_exp_cost_rec.new_chr_id
                             );
            fetch l_units_csr into l_units_rec;
            If l_units_csr%NOTFOUND then
                Null;
            End If;
            close l_units_csr;

            If nvl(l_units_rec.number_of_items,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
               --modify the model line
               l_model_clev_rec.id := l_units_rec.model_cle_id;
               l_model_clev_rec.price_unit := (l_expected_cost/l_units_rec.number_of_items);

               open l_new_chr_hdr_csr (p_chr_id => l_exp_cost_rec.new_chr_id);
               fetch l_new_chr_hdr_csr into l_new_chr_hdr_rec;
               close l_new_chr_hdr_csr;

               l_model_clev_rec.price_unit := OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                           (p_amount        => l_model_clev_rec.price_unit,
                            p_currency_code => l_new_chr_hdr_rec.currency_code);


               OKC_CONTRACT_PUB.update_contract_line
                                 (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_clev_rec       => l_model_clev_rec,
                                  x_clev_rec       => lx_model_clev_rec
                                 );
               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END IF;
               --modify the OEC on financial asset line

               l_finast_clev_rec.id  := l_exp_cost_rec.new_cle_id;
               l_finast_klev_rec.id  := l_exp_cost_rec.new_cle_id;
               l_finast_klev_rec.oec := l_expected_cost;

               OKL_CONTRACT_PUB.update_contract_line
                               (p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_clev_rec       => l_finast_clev_rec,
                                p_klev_rec       => l_finast_klev_rec,
                                p_edit_mode      => 'N',
                                x_clev_rec       => lx_finast_clev_rec,
                                x_klev_rec       => lx_finast_klev_rec);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END IF;

               --modify the capital amount on financial assrt line
               OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_formula_name  => 'LINE_CAP_AMNT',
                                               p_contract_id   => l_exp_cost_rec.new_chr_id,
                                               p_line_id       => l_exp_cost_rec.new_cle_id,
                                               x_value         => l_capital_amount);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END IF;

               OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_formula_name  => 'LINE_CAPITALIZED_INTEREST',
                                               p_contract_id   => l_exp_cost_rec.new_chr_id,
                                               p_line_id       => l_exp_cost_rec.new_cle_id,
                                               x_value         => l_capitalized_interest);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END IF;

               l_finast_klev_rec2.capital_amount   := (l_capital_amount - l_capitalized_interest);
               l_finast_klev_rec2.id               := l_exp_cost_rec.new_cle_id;
               l_finast_clev_rec2.id               := l_exp_cost_rec.new_cle_id;

               OKL_CONTRACT_PUB.update_contract_line
                               (p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_clev_rec       => l_finast_clev_rec2,
                                p_klev_rec       => l_finast_klev_rec2,
                                p_edit_mode      => 'N',
                                x_clev_rec       => lx_finast_clev_rec2,
                                x_klev_rec       => lx_finast_klev_rec2);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END IF;

            End If;
        End If;
    End Loop;
    Close l_exp_cost_csr;
    If l_exp_cost_mismatch_yn = 'Y' then
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_LA_UPDATE_ASSET');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;
    End If;
    --End Bug# 4631549



    --End Bug# 4631549

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END validate_release_contract;

  -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Validate_Release_Contract
-- Description          : Validations for the Re-lease contract
--
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE validate_release_contract(p_api_version   IN  NUMBER,
                                      p_init_msg_list IN  VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      p_chr_id        IN  NUMBER,
                                      p_release_date  IN  DATE,
                                      p_source_trx_id IN  NUMBER,
				      p_release_reason_code IN VARCHAR2) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_RELEASE_CONTRACT';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR chr_csr(p_chr_id       IN NUMBER) IS
    SELECT chr.start_date,
           chr.end_date,
           chr.contract_number,
           khr.deal_type,
           sts_code,
           --Bug# 5005869
           chr.currency_code
    FROM okc_k_headers_b chr,
         okl_k_headers khr
    WHERE chr.id = p_chr_id
    AND   chr.id = khr.id;

    chr_rec   chr_csr%ROWTYPE;

    CURSOR rul_csr(p_chr_id   IN NUMBER,
                   p_rgd_code IN VARCHAR2,
                   p_rul_cat  IN VARCHAR2
                   ) IS
    SELECT crl.rule_information1
    FROM   okc_rule_groups_b crg,
           okc_rules_b crl
    WHERE  crl.rgp_id = crg.id
    AND    crg.rgd_code = p_rgd_code
    AND    crl.rule_information_category = p_rul_cat
    AND    crg.dnz_chr_id = p_chr_id;

    rul_rec                rul_csr%ROWTYPE;

    CURSOR chk_usage_csr(p_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT 'Y'
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.chr_id = p_chr_id
    AND cle.dnz_chr_id = p_chr_id
    AND lse.id = cle.lse_id
    AND lse.lty_code = 'USAGE'
    AND rownum = 1;

    -- Bug# 4072796
    -- Called at release --
    CURSOR pending_trx_csr(p_chr_id IN NUMBER)
    IS
    SELECT 'Y'
    FROM   okl_trx_contracts tcn
    WHERE  tcn.khr_id = p_chr_id
    AND    tcn.tsu_code IN ('ENTERED','WORKING','WAITING','SUBMITTED')
--rkuttiya added for 12.1.1 Multi GAAP
    AND   tcn.representation_type = 'PRIMARY'
    AND   (tcn.tcn_type IN ('TRBK','RVS','SPLC')
--
           OR (tcn.tcn_type = 'MAE' AND tcn.try_id IN (SELECT try.id
                                                   FROM okl_trx_types_tl try
                                                   WHERE try.name = 'Release'
                                                   AND try.language= 'US')));

    --Bug# 4905732
    CURSOR chk_chr_asset_pymt_csr
           (p_orig_chr_id IN NUMBER)
    IS
    SELECT fin_ast_cle.id,
           fin_ast_cle.name
    FROM okc_k_lines_v fin_ast_cle,
         okc_k_headers_b chr,
         okc_line_styles_b fin_ast_lse
    WHERE chr.id = p_orig_chr_id
    AND   fin_ast_cle.chr_id = chr.id
    AND   fin_ast_cle.dnz_chr_id = chr.id
    AND   fin_ast_cle.sts_code = chr.sts_code
    AND   fin_ast_cle.lse_id = fin_ast_lse.id
    AND   fin_ast_lse.lty_code = 'FREE_FORM1';

    CURSOR chk_taa_asset_pymt_csr
                  (p_orig_chr_id    IN NUMBER
                  ,p_source_trx_id  IN NUMBER)
    IS
    SELECT fin_ast_cle.id,
           fin_ast_cle.name
    FROM okl_txl_cntrct_lns tcl,
         okc_k_lines_v fin_ast_cle
    WHERE tcl.tcn_id = p_source_trx_id
    AND   tcl.before_transfer_yn = 'N'
    AND   fin_ast_cle.chr_id = p_orig_chr_id
    AND   fin_ast_cle.dnz_chr_id = p_orig_chr_id
    AND   fin_ast_cle.id = tcl.kle_id;

    CURSOR chk_payment_csr
           (p_chr_id       IN NUMBER,
            p_cle_id       IN NUMBER) IS
    SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
           DECODE(sll.rule_information7, NULL,
                 (ADD_MONTHS(FND_DATE.canonical_to_date(sll.rule_information2),
                   NVL(TO_NUMBER(sll.rule_information3),1) *
                   DECODE(sll.object1_id1, 'M',1,'Q',3,'S',6,'A',12)) - 1),
                 FND_DATE.canonical_to_date(sll.rule_information2) +
                   TO_NUMBER(sll.rule_information7) - 1) end_date
    FROM okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
         okl_strm_type_b sty
    WHERE rgp.dnz_chr_id = p_chr_id
    AND rgp.cle_id = p_cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND slh.rgp_id = rgp.id
    AND slh.rule_information_category = 'LASLH'
    AND sll.object2_id1 = slh.id
    AND sll.rule_information_category = 'LASLL'
    AND sll.rgp_id = rgp.id
    AND sty.id = TO_NUMBER(slh.object1_id1)
    AND sty.stream_type_purpose = 'RENT';

    l_payment_exists VARCHAR2(1);
    --Bug# 4905732

    l_found VARCHAR2(30);
    l_icx_date_format     VARCHAR2(240);
    l_funding_remaining   NUMBER;
    l_term_duration       NUMBER;
    l_asset_num_token     VARCHAR2(2000);

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Revision date is mandatory
    if (p_release_date IS NULL) then
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_MISSING_TRX_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Revision Date should be between Contract Start and End dates
    open chr_csr(p_chr_id => p_chr_id);
    fetch chr_csr into chr_rec;
    close chr_csr;
    -- Bug# 4072796
    if NOT (p_release_date BETWEEN (chr_rec.start_date + 1) AND chr_rec.end_date) then
      l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_WRONG_TRX_DATE',
                          'START_DATE',
                          TO_CHAR(chr_rec.start_date,l_icx_date_format),
                          'END_DATE',
                          TO_CHAR(chr_rec.end_date,l_icx_date_format)
                          );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- The new Term duration (Re-lease Date to Contract end date)
    -- must be a whole number of months
    l_term_duration := MONTHS_BETWEEN(chr_rec.end_date + 1,p_release_date);
    if (MOD(l_term_duration,1) <> 0) then
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_REL_INVALID_DURATION');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Validate if Deal Type is Loan or Revolving Loan
    if chr_rec.deal_type IN ('LOAN','LOAN-REVOLVING') then
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_REL_NOT_ALLOW_LOAN');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Validate if Contract has Variable Interest Rate
    open rul_csr(p_chr_id   => p_chr_id
                ,p_rgd_code => 'LAIIND'
                ,p_rul_cat  => 'LAINTP');
    fetch rul_csr into rul_rec;
    close rul_csr;

    if (rul_rec.rule_information1 = 'Y') then
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_REL_NOT_ALLOW_VAR_RT');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;
   --rajnisku: Bug 6657564
  --added if condition to allow TnA for contract with Usage line
 	     if NVL(p_release_reason_code,'X') <> 'CUSTOMER_CHANGE' THEN
    -- Validate if Usage Line exists
    l_found := 'N';
    open chk_usage_csr(p_chr_id => p_chr_id);
    fetch chk_usage_csr into l_found;
    close chk_usage_csr;
    if (l_found = 'Y') then
      OKL_API.SET_MESSAGE(G_APP_NAME,
                          'OKL_LLA_REL_NO_USAGE_LINES');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;
         end if;
 	     --rajnisku: Bug 6657564  : end

    -- Bug# 4072796
    -- Validate if Contract is undergoing Revision
    l_found := 'N';
    open pending_trx_csr(p_chr_id => p_chr_id);
    fetch pending_trx_csr into l_found;
    close pending_trx_csr;
    if (l_found = 'Y') then
      OKL_API.SET_MESSAGE(G_APP_NAME,
                        'OKL_LLA_REV_IN_PROGRESS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    --Bug# 4905732
    -- Validation that assets selected for Re-lease
    -- have incomplete Payments

    -- T and A transaction
    if (p_source_trx_id IS NOT NULL) then

      l_asset_num_token := null;
      for chk_taa_asset_pymt_rec in
          chk_taa_asset_pymt_csr
                        (p_orig_chr_id   => p_chr_id
                        ,p_source_trx_id => p_source_trx_id) loop

        l_payment_exists := 'N';
        for chk_payment_rec in chk_payment_csr
                                  (p_chr_id => p_chr_id,
                                   p_cle_id => chk_taa_asset_pymt_rec.id) loop
          if (chk_payment_rec.end_date >= p_release_date) then
            l_payment_exists := 'Y';
            exit;
          end if;
        end loop;

        if l_payment_exists = 'N' then
          if l_asset_num_token is null then
            l_asset_num_token := l_asset_num_token ||chk_taa_asset_pymt_rec.name;
          else
            l_asset_num_token := l_asset_num_token ||', '||chk_taa_asset_pymt_rec.name;
          end if;
        end if;
      end loop;

      if l_asset_num_token IS NOT NULL then
        l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_REL_ASSET_NO_PYMT',
                            p_token1       => 'ASSET_NUMBER',
                            p_token1_value => l_asset_num_token,
                            p_token2       => 'RELEASE_DATE',
                            p_token2_value => to_char(p_release_date,l_icx_date_format));
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;

    -- Re-lease contract
    else

      l_asset_num_token := null;
      for chk_chr_asset_pymt_rec in
          chk_chr_asset_pymt_csr
            (p_orig_chr_id   => p_chr_id) loop

        l_payment_exists := 'N';
        for chk_payment_rec in chk_payment_csr
                                  (p_chr_id => p_chr_id,
                                   p_cle_id => chk_chr_asset_pymt_rec.id) loop
          if (chk_payment_rec.end_date >= p_release_date) then
            l_payment_exists := 'Y';
            exit;
          end if;
        end loop;

        if l_payment_exists = 'N' then
          if l_asset_num_token is null then
            l_asset_num_token := l_asset_num_token ||chk_chr_asset_pymt_rec.name;
          else
            l_asset_num_token := l_asset_num_token ||', '||chk_chr_asset_pymt_rec.name;
          end if;
        end if;
      end loop;

      if l_asset_num_token IS NOT NULL then
        l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');
        OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_REL_ASSET_NO_PYMT',
                              p_token1       => 'ASSET_NUMBER',
                              p_token1_value => l_asset_num_token,
                              p_token2       => 'RELEASE_DATE',
                              p_token2_value => to_char(p_release_date,l_icx_date_format));
        RAISE OKL_API.G_EXCEPTION_ERROR;
      end if;

    end if;
    --Bug# 4905732

     --Bug# 5005869
    -- Validate information from the
    -- Transfer and Assumption request
    if (p_source_trx_id IS NOT NULL) then

      validate_taa_request_info
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_chr_id        => p_chr_id,
         p_release_date  => p_release_date,
         p_source_trx_id => p_source_trx_id,
         p_currency_code => chr_rec.currency_code);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    end if;
    --Bug# 5005869

    -- Start change fmiao 19-NOV-04 for release date check --
    -- Perform the shared validations
    validate_release_contract(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_chr_id        => p_chr_id,
                              p_release_date  => p_release_date,
                              p_source_trx_id => p_source_trx_id,
							  p_call_program  => 'RELEASE');
    -- End change fmiao 19-NOV-04 for release date check --

      -- Bug# 4072796
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END validate_release_contract;

   -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Adjust_Payment_Lines
-- Description          : Adjust Payment lines on the Re-lease contract
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE adjust_payment_lines(p_api_version  IN  NUMBER,
                                 p_init_msg_list IN  VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_chr_id        IN  NUMBER,
                                 p_release_date  IN  DATE) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'ADJUST_PAYMENT_LINES';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    --Made changes by bkatraga for bug 9369915 to fetch stream_type_purpose
    CURSOR contract_payment_csr
           (p_chr_id       IN NUMBER,
            p_release_date IN DATE) IS
    SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
           DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)factor,
           TO_NUMBER(sll.rule_information3) periods,
           DECODE(sll.rule_information7, NULL,
                 (ADD_MONTHS(FND_DATE.canonical_to_date(sll.rule_information2),
                   NVL(TO_NUMBER(sll.rule_information3),1) *
                   DECODE(sll.object1_id1, 'M',1,'Q',3,'S',6,'A',12)) - 1),
                 FND_DATE.canonical_to_date(sll.rule_information2) +
                   TO_NUMBER(sll.rule_information7) - 1) end_date,
           sll.rule_information10   arrears_yn,
           TO_NUMBER(sll.rule_information6) amount,
           TO_NUMBER(sll.rule_information8) stub_amount,
           sll.rule_information5,
           sll.rgp_id,
           sll.object1_id1,
           sll.object1_id2,
           sll.jtot_object1_code,
           sll.object2_id1,
           sll.object2_id2,
           sll.jtot_object2_code,
           sll.id sll_id,
           sty.stream_type_purpose
    FROM okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
         okl_strm_type_b sty
    WHERE rgp.dnz_chr_id = p_chr_id
    AND rgp.rgd_code = 'LALEVL'
    AND slh.rgp_id = rgp.id
    AND slh.rule_information_category = 'LASLH'
    AND slh.object1_id1 = sty.id
    AND sll.object2_id1 = slh.id
    AND sll.rule_information_category = 'LASLL'
    AND sll.rgp_id = rgp.id
    AND FND_DATE.canonical_to_date(sll.rule_information2) < p_release_date;

    CURSOR slh_csr(p_chr_id       IN NUMBER) IS
    SELECT slh.id slh_id
    FROM okc_rules_b slh
    WHERE slh.dnz_chr_id = p_chr_id
    AND   slh.rule_information_category = 'LASLH'
    AND NOT EXISTS (SELECT NULL FROM okc_rules_b sll
                    WHERE sll.object2_id1 = slh.id
                    AND sll.rule_information_category = 'LASLL'
                    AND sll.dnz_chr_id = slh.dnz_chr_id);

    CURSOR rgp_csr(p_chr_id       IN NUMBER) IS
    SELECT rgp.id rgp_id
    FROM  okc_rule_groups_b rgp
    WHERE rgp.dnz_chr_id = p_chr_id
    AND   rgp.rgd_code = 'LALEVL'
    AND NOT EXISTS (SELECT NULL FROM okc_rules_b slh
                    WHERE slh.rgp_id = rgp.id
                    AND slh.rule_information_category = 'LASLH');

    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
    lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;
    l_rgpv_rec  OKL_RULE_PUB.rgpv_rec_type;

    l_rulv_temp_rec  OKL_RULE_PUB.rulv_rec_type;
    l_rgpv_temp_rec  OKL_RULE_PUB.rgpv_rec_type;

    l_no_of_periods   NUMBER;
    l_periods_to_skip NUMBER;
    l_new_start_date  DATE;
    l_stub_amount     NUMBER;
    l_stub_days       NUMBER;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    for contract_payment_rec in contract_payment_csr
                                  (p_chr_id => p_chr_id,
                                   p_release_date => p_release_date) loop

      l_rulv_rec := l_rulv_temp_rec;

      --Added OR clause in the below IF condition by bkatraga for bug 9369915
      -- Delete SLL where End Date is earlier than Re-lease date
      if ((contract_payment_rec.end_date < p_release_date)
       OR (contract_payment_rec.stream_type_purpose = 'DOWN_PAYMENT')) then
        l_rulv_rec.id := contract_payment_rec.sll_id; -- SLL Rule ID
        okl_rule_pub.delete_rule(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_rec       => l_rulv_rec
                        );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      -- Update SLL Start Date, Periods and Amount where End Date is greater than
      -- or equal to Re-lease date and Start Date is less than Re-lease date
      elsif (contract_payment_rec.end_date >= p_release_date) then

        -- Convert Payment line to a Stub starting on Re-lease date
        -- if there is only 1 period or if it is a stub payment
        if NVL(contract_payment_rec.periods,1) = 1 then

            l_rulv_rec.id := contract_payment_rec.sll_id; -- SLL Rule ID

            l_stub_days :=  contract_payment_rec.end_date - p_release_date + 1;

            -- Payment in Arrears
            if (contract_payment_rec.arrears_yn = 'Y') then
                l_stub_amount := NVL(contract_payment_rec.amount,contract_payment_rec.stub_amount);

            -- Payment in Advance
            else
              l_stub_amount := 0;
            end if;

            l_rulv_rec.rule_information2 := FND_DATE.date_to_canonical(p_release_date);
            l_rulv_rec.rule_information3 := NULL;
            l_rulv_rec.rule_information6 := NULL;
            l_rulv_rec.rule_information7 := TO_CHAR(l_stub_days);
            l_rulv_rec.rule_information8 := TO_CHAR(l_stub_amount);

            OKL_RULE_PUB.update_rule(
                    p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_rulv_rec           => l_rulv_rec,
                    x_rulv_rec           => lx_rulv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        elsif (contract_payment_rec.periods > 1) then

          if (contract_payment_rec.factor IS NOT NULL and contract_payment_rec.factor > 0 ) then

              l_rulv_rec.id := contract_payment_rec.sll_id; -- SLL Rule ID

              l_periods_to_skip :=
                CEIL(CEIL(MONTHS_BETWEEN(p_release_date,contract_payment_rec.start_date))/contract_payment_rec.factor);

              l_new_start_date := ADD_MONTHS(contract_payment_rec.start_date,
                                           l_periods_to_skip * contract_payment_rec.factor);

              if (l_new_start_date > contract_payment_rec.end_date) then

                -- No periodic payment, only stub payment needed
                OKL_RULE_PUB.delete_rule(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_rec       => l_rulv_rec
                        );
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

              else

                l_rulv_rec.rule_information2 := FND_DATE.date_to_canonical(l_new_start_date);

                l_no_of_periods := MONTHS_BETWEEN((contract_payment_rec.end_date + 1),l_new_start_date)/contract_payment_rec.factor;
                l_rulv_rec.rule_information3 := TO_CHAR(l_no_of_periods);

                OKL_RULE_PUB.update_rule(
                    p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_rulv_rec           => l_rulv_rec,
                    x_rulv_rec           => lx_rulv_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              end if;

              -- Create Stub payment line for 1st payment
              l_rulv_rec := l_rulv_temp_rec;

              l_stub_days :=  l_new_start_date - p_release_date;
              if (l_stub_days > 0) then

                -- Payment in Arrears
                if (contract_payment_rec.arrears_yn = 'Y') then
                  l_stub_amount := contract_payment_rec.amount;

                -- Payment in Advance
                else
                  l_stub_amount := 0;
                end if;

                l_rulv_rec.dnz_chr_id        := p_chr_id;
                l_rulv_rec.rgp_id            := contract_payment_rec.rgp_id;
                l_rulv_rec.object1_id1       := contract_payment_rec.object1_id1;
                l_rulv_rec.object1_id2       := contract_payment_rec.object1_id2;
                l_rulv_rec.jtot_object1_code := contract_payment_rec.jtot_object1_code;
                l_rulv_rec.object2_id1       := contract_payment_rec.object2_id1;
                -- nikshah 25-Nov-08 bug # 6697542
                l_rulv_rec.object2_id2       := '#'; --contract_payment_rec.object2_id2;
                -- nikshah 25-Nov-08 bug # 6697542
                l_rulv_rec.jtot_object2_code := contract_payment_rec.jtot_object2_code;
                l_rulv_rec.std_template_yn   := 'N';
                l_rulv_rec.warn_yn           := 'N';
                l_rulv_rec.template_yn       := 'N';
                l_rulv_rec.sfwt_flag         := 'N';
                l_rulv_rec.rule_information_category := 'LASLL';
                l_rulv_rec.rule_information2 := FND_DATE.date_to_canonical(p_release_date);
                l_rulv_rec.rule_information5 := contract_payment_rec.rule_information5;
                l_rulv_rec.rule_information7 := TO_CHAR(l_stub_days);
                l_rulv_rec.rule_information8 := TO_CHAR(l_stub_amount);
                l_rulv_rec.rule_information10 := contract_payment_rec.arrears_yn;

                OKL_RULE_PUB.create_rule(
                    p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_rulv_rec           => l_rulv_rec,
                    x_rulv_rec           => lx_rulv_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              end if; --Stub days greater than 0
          end if; --Factor is not null
        end if; --Periods equal/greater than 1
      end if; --End date less/greater than Release date
    end loop;

    for slh_rec in slh_csr(p_chr_id => p_chr_id) loop
        l_rulv_rec := l_rulv_temp_rec;

        l_rulv_rec.id := slh_rec.slh_id; -- SLH Rule ID
        okl_rule_pub.delete_rule(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_rec       => l_rulv_rec
                        );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    end loop;

    for rgp_rec in rgp_csr(p_chr_id => p_chr_id) loop
        l_rgpv_rec := l_rgpv_temp_rec;

        l_rgpv_rec.id := rgp_rec.rgp_id; -- Rule Group ID
        okl_rule_pub.delete_rule_group(
                     p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_rgpv_rec       => l_rgpv_rec
                     );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    end loop;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END adjust_payment_lines;

-----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Get_Principal_bal
-- Description          : Get prinicipal balance amount
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE  get_principal_bal(p_api_version         IN  NUMBER,
                               p_init_msg_list       IN  VARCHAR2,
                               p_pymt_sty_id         IN  NUMBER,
                               p_orig_chr_id         IN  NUMBER,
                               p_orig_cle_id         IN  NUMBER,
                               p_release_date        IN  DATE,
                               x_principal_balance   OUT NOCOPY NUMBER,
                               x_accumulated_int     OUT NOCOPY NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_msg_data            OUT NOCOPY VARCHAR2) IS

  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Principal_Bal';
  l_api_version     CONSTANT NUMBER	:= 1.0;

  CURSOR streams_csr(p_chr_id IN NUMBER,
                     p_cle_id IN NUMBER,
                     p_sty_id IN NUMBER)
  IS
  SELECT  stm.id
  FROM    okl_streams       stm
  WHERE   stm.khr_id      = p_chr_id
  AND     stm.kle_id      = p_cle_id
  AND     stm.sty_id      = p_sty_id
  AND     stm.active_yn   = 'Y'
  AND     stm.say_code    = 'CURR';

  streams_rec streams_csr%ROWTYPE;

  CURSOR principal_bal_csr(p_stm_id IN NUMBER,
                           p_release_date IN DATE)
  IS
  SELECT stream_element_date,
         amount
  FROM   okl_strm_elements_v sel
  WHERE  sel.stm_id = p_stm_id
  AND    stream_element_date < p_release_date
  ORDER BY stream_element_date DESC;

  principal_bal_rec principal_bal_csr%ROWTYPE;
  l_principal_bal NUMBER;
  l_principal_bal_sty_id NUMBER;

BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Fetch Stream information from Original Contract
    l_principal_bal_sty_id := null;
    OKL_STREAMS_UTIL.get_dependent_stream_type
       (p_khr_id                  => p_orig_chr_id,
        p_primary_sty_id          => p_pymt_sty_id,
        p_dependent_sty_purpose   => 'PRINCIPAL_BALANCE',
        x_return_status           => x_return_status,
        x_dependent_sty_id        => l_principal_bal_sty_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_principal_bal := 0;
    if (l_principal_bal_sty_id IS NOT NULL) then
      open streams_csr(p_chr_id => p_orig_chr_id,
                       p_cle_id => p_orig_cle_id,
                       p_sty_id => l_principal_bal_sty_id);
      fetch streams_csr into streams_rec;
      close streams_csr;

      if (streams_rec.id IS NOT NULL) then

        open principal_bal_csr(p_stm_id       => streams_rec.id,
                               p_release_date => p_release_date);
        fetch principal_bal_csr into principal_bal_rec;
        close principal_bal_csr;

        l_principal_bal := principal_bal_rec.amount;

      end if; --Fee Payment Stream Id is not null
    end if; --Fee Payment Stream Type Id is not null

    x_principal_balance := l_principal_bal;
    x_accumulated_int := 0;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END get_principal_bal;

-----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Adjust_Fee_Lines
-- Description          : Adjust Fee lines on the Re-lease contract
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE adjust_fee_lines(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_chr_id        IN  NUMBER,
                             p_orig_chr_id   IN  NUMBER,
                             p_release_date  IN  DATE) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'ADJUST_FEE_LINES';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR contract_fee_csr
           (p_chr_id       IN NUMBER) IS
    SELECT cle.id,
           cle.start_date,
           cle.end_date,
           kle.amount,
           kle.initial_direct_cost,
           kle.fee_type,
           cle.chr_id,
           cle.dnz_chr_id,
           cle.cle_id,
           sts.ste_code,
           cle.orig_system_id1
    FROM okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_statuses_b sts
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.chr_id =  p_chr_id
    AND  kle.id = cle.id
    AND  cle.lse_id = lse.id
    AND  lse.lty_code = 'FEE'
    AND  cle.sts_code = sts.code;

    CURSOR orig_cle_sts_csr(p_cle_id IN NUMBER)
    IS
    SELECT sts.ste_code
    FROM   okc_k_lines_b cle,
           okc_statuses_b sts
    WHERE  cle.id = p_cle_id
    AND    cle.sts_code = sts.code;

    orig_cle_sts_rec orig_cle_sts_csr%ROWTYPE;

    CURSOR fee_expense_csr
           (p_chr_id       IN NUMBER,
            p_cle_id       IN NUMBER) IS
    SELECT DECODE(rul_lafreq.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)factor,
           TO_NUMBER(rul_lafexp.rule_information1) periods,
           TO_NUMBER(rul_lafexp.rule_information2) amount,
           rul_lafexp.id  rul_lafexp_id,
           rul_lafreq.id  rul_lafreq_id,
           rgp.id         rgp_id
    FROM   okc_rules_b rul_lafexp,
           okc_rules_b rul_lafreq,
           okc_rule_groups_b rgp
    WHERE  rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id = p_cle_id
    AND   rgp.rgd_code = 'LAFEXP'
    AND   rul_lafreq.rgp_id = rgp.id
    AND   rul_lafreq.rule_information_category = 'LAFREQ'
    AND   rul_lafexp.rgp_id = rgp.id
    AND   rul_lafexp.rule_information_category = 'LAFEXP';

    fee_expense_rec fee_expense_csr%ROWTYPE;

    CURSOR fee_subline_csr (p_cle_id IN NUMBER,
                            p_chr_id IN NUMBER) IS
    SELECT cle.id,
           NVL(kle.capital_amount,0) capital_amount,
           NVL(kle.amount,0) amount,
           cle.chr_id,
           cle.dnz_chr_id,
           cle.cle_id,
           --avsingh
           cle.orig_system_id1
    FROM   okc_k_lines_b cle,
           okl_k_lines kle
    WHERE  cle.cle_id   = p_cle_id
    AND    cle.dnz_chr_id = p_chr_id
    AND    cle.id = kle.id;

	CURSOR check_pymts_csr(p_chr_id IN NUMBER,
                           p_cle_id IN NUMBER) IS
    SELECT 'Y'  pymt_exists,
           rgp.id
    FROM   okc_rule_groups_b rgp
    WHERE  rgp.cle_id   = p_cle_id
    AND    rgp.dnz_chr_id = p_chr_id
    AND    rgp.rgd_code  = 'LALEVL';

    l_pymt_exists VARCHAR2(30);
    l_rgp_id      okc_rule_groups_b.id%TYPE;

    CURSOR fee_item_csr(p_chr_id IN NUMBER,
                        p_cle_id IN NUMBER) IS
    SELECT fee_cim.id,
           fee_cim.object1_id1
    FROM   okc_k_items fee_cim
    WHERE  fee_cim.cle_id = p_cle_id
    AND    fee_cim.dnz_chr_id = p_chr_id
    AND    fee_cim.jtot_object1_code = 'OKL_STRMTYP';

    fee_item_rec fee_item_csr%ROWTYPE;

    CURSOR pymt_details_csr(p_chr_id   IN NUMBER,
                            p_rgp_id   IN NUMBER,
                            p_rul_cat  IN VARCHAR2) IS
    SELECT crl.object1_id1,
           crl.rule_information3,
           crl.rule_information6,
           crl.rule_information8
    FROM   okc_rules_b crl
    WHERE  crl.rgp_id = p_rgp_id
    AND    crl.dnz_chr_id = p_chr_id
    AND    crl.rule_information_category = p_rul_cat;

    pymt_details_rec pymt_details_csr%ROWTYPE;

    l_pymt_amount NUMBER;

    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
    lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;

    l_rgpv_rec  OKL_RULE_PUB.rgpv_rec_type;

    l_periods_bef_release NUMBER;
    l_orig_no_of_periods  NUMBER;
    l_new_no_of_periods   NUMBER;
    l_new_fee_amount      NUMBER;
    l_new_idc_amount      NUMBER;

    lp_klev_rec  okl_kle_pvt.klev_rec_type;
    lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lx_klev_rec  okl_kle_pvt.klev_rec_type;
    lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lp_sub_clev_tbl  okl_okc_migration_pvt.clev_tbl_type;
    lx_sub_clev_tbl  okl_okc_migration_pvt.clev_tbl_type;
    lp_sub_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lp_sub_klev_tbl  okl_kle_pvt.klev_tbl_type;
    lx_sub_klev_tbl  okl_kle_pvt.klev_tbl_type;
    lp_sub_klev_rec  okl_kle_pvt.klev_rec_type;

    lp_cimv_rec      okl_okc_migration_pvt.cimv_rec_type;
    lx_cimv_rec      okl_okc_migration_pvt.cimv_rec_type;

    lp_clev_temp_tbl okl_okc_migration_pvt.clev_tbl_type;
    lp_clev_temp_rec okl_okc_migration_pvt.clev_rec_type;
    lp_klev_temp_tbl okl_kle_pvt.klev_tbl_type;
    lp_klev_temp_rec okl_kle_pvt.klev_rec_type;
    lp_cimv_temp_rec okl_okc_migration_pvt.cimv_rec_type;
    l_rulv_temp_rec  okl_rule_pub.rulv_rec_type;

    l_subline_present      VARCHAR2(1);
    l_sub_cap_amt          NUMBER;
    i NUMBER;
    l_idc_sty_id           NUMBER;
    l_fin_fee_pymt_sty_id  NUMBER;
    l_rlvr_fee_pymt_sty_id NUMBER;

    CURSOR streams_csr(p_chr_id IN NUMBER,
                       p_cle_id IN NUMBER,
                       p_sty_id IN NUMBER)
    IS
    SELECT  stm.id
    FROM    okl_streams       stm
    WHERE   stm.khr_id      = p_chr_id
    AND     stm.kle_id      = p_cle_id
    AND     stm.sty_id      = p_sty_id
    AND     stm.active_yn   = 'Y'
    AND     stm.say_code    = 'CURR';

    streams_rec streams_csr%ROWTYPE;

    CURSOR unamort_idc_exp_csr(p_stm_id IN NUMBER,
                               p_release_date IN DATE)
    IS
    SELECT SUM(amount) amount
    FROM   okl_strm_elements_v sel
    WHERE  sel.stm_id = p_stm_id
    AND    stream_element_date >= p_release_date;

    unamort_idc_exp_rec unamort_idc_exp_csr%ROWTYPE;

    CURSOR principal_bal_csr(p_stm_id IN NUMBER,
                             p_release_date IN DATE)
    IS
    SELECT stream_element_date,
           amount
    FROM   okl_strm_elements_v sel
    WHERE  sel.stm_id = p_stm_id
    AND    stream_element_date < p_release_date
    ORDER BY stream_element_date DESC;

    principal_bal_rec principal_bal_csr%ROWTYPE;

    l_rlvr_sub_amt   NUMBER;
    l_rlvr_sub_total NUMBER;
    l_sum            NUMBER;

    CURSOR curr_hdr_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

    l_principal_bal NUMBER;
    l_accumulated_int NUMBER;

	-- Start change for rollover by fmiao on 12-NOV-2004--
	CURSOR fee_type_csr (p_line_id NUMBER) IS
	SELECT fee_type
	FROM   okl_k_lines
    WHERE  id = p_line_id;

	l_fee_type   okl_k_lines.fee_type%TYPE;
	-- End change for rollover by fmiao on 12-NOV-2004--

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_currency_code := '?';
    open curr_hdr_csr (p_chr_id);
    fetch curr_hdr_csr into l_currency_code;
    close curr_hdr_csr;

    if (l_currency_code = '?') then

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Currency Code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    for contract_fee_rec in contract_fee_csr
                                 (p_chr_id => p_chr_id) loop

      l_rulv_rec      := l_rulv_temp_rec;
      lp_clev_rec     := lp_clev_temp_rec;
      lp_klev_rec     := lp_klev_temp_rec;
      lp_sub_clev_rec := lp_clev_temp_rec;
      lp_sub_clev_tbl := lp_clev_temp_tbl;
      lp_sub_klev_rec := lp_klev_temp_rec;
      lp_sub_klev_tbl := lp_klev_temp_tbl;
      lp_cimv_rec     := lp_cimv_temp_rec;

      -- Delete Fee Lines where End Date is earlier than Re-lease date
      -- or Fee Type = Security Deposit
      -- or Line Status is not Active

      -- Fetch Status of the Line in original contract
      open orig_cle_sts_csr(p_cle_id => contract_fee_rec.orig_system_id1);
      fetch orig_cle_sts_csr into orig_cle_sts_rec;
      close orig_cle_sts_csr;

      if (contract_fee_rec.end_date < p_release_date) or
         (contract_fee_rec.ste_code IN ('TERMINATED', 'EXPIRED', 'CANCELLED')) or
         (orig_cle_sts_rec.ste_code IN ('TERMINATED', 'EXPIRED', 'CANCELLED')) then

        OKL_CONTRACT_PUB.delete_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_line_id       => contract_fee_rec.id
        );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      -- If Fee Line Start date is greater than or equal to Re-lease Date
      -- make updates for Covered assets not moved over
      elsif (contract_fee_rec.start_date >= p_release_date) then

        -- Update Capitalized Fee Amount to Sum of Covered Asset amounts
        -- if they are not equal
        if (contract_fee_rec.fee_type = 'CAPITALIZED') then

          l_subline_present := 'N';
          l_sub_cap_amt     := 0;

          i := 0;
          for fee_subline_rec in fee_subline_csr
                (p_cle_id => contract_fee_rec.id,
                 p_chr_id => p_chr_id)
          loop
            i := i + 1;
            l_subline_present := 'Y';
            l_sub_cap_amt := l_sub_cap_amt + fee_subline_rec.capital_amount;
          end loop;

          -- No Covered assets associated with Fee
          if (l_subline_present = 'N') then

            -- Delete Capitalized Fee line if no Covered Assets are present
            OKL_CONTRACT_PUB.delete_contract_line(
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_line_id       => contract_fee_rec.id
               );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          -- Covered assets associated with Fee
          else

            -- Set the capital_amount on capitalized fee top line equal
            -- to the sum of capital_amount on capitalized fee sublines
            if (contract_fee_rec.amount <> l_sub_cap_amt) then

              lp_clev_rec.id := contract_fee_rec.id;

              lp_klev_rec.id := contract_fee_rec.id;
              lp_klev_rec.amount :=l_sub_cap_amt;
              lp_klev_rec.capital_amount := l_sub_cap_amt;

              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_rec            => lp_clev_rec,
                p_klev_rec            => lp_klev_rec,
                x_clev_rec            => lx_clev_rec,
                x_klev_rec            => lx_klev_rec
              );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            end if;

          end if; --Subline Present Y/N

        -- Update Rollover Fee Amount to Sum of Covered Asset amounts
        -- if they are not equal
        elsif (contract_fee_rec.fee_type = 'ROLLOVER') then

          l_subline_present := 'N';
          l_rlvr_sub_total  := 0;

          i := 0;
          for fee_subline_rec in fee_subline_csr
              (p_cle_id => contract_fee_rec.id,
               p_chr_id => p_chr_id)
          loop
            i := i + 1;
            l_subline_present := 'Y';
            l_rlvr_sub_total := l_rlvr_sub_total + fee_subline_rec.amount;

          end loop;

          if ((l_subline_present = 'Y') and (contract_fee_rec.amount <> l_rlvr_sub_total)) then

            lp_clev_rec.id := contract_fee_rec.id;

            lp_klev_rec.id := contract_fee_rec.id;
            lp_klev_rec.amount :=l_rlvr_sub_total;

            OKL_CONTRACT_PUB.update_contract_line(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_clev_rec            => lp_clev_rec,
              p_klev_rec            => lp_klev_rec,
              x_clev_rec            => lx_clev_rec,
              x_klev_rec            => lx_klev_rec
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          end if; -- Subline exists and Fee Amount <> Sum of Covered asset amounts

        end if; --Capitalized Fee / Rollover fee

      -- Update Fee Line Start Date and Amount where End Date is greater than
      -- or equal to Re-lease date and Start Date is less than Re-lease date
      elsif (contract_fee_rec.start_date < p_release_date) then

        open fee_expense_csr(p_chr_id => p_chr_id,
                             p_cle_id => contract_fee_rec.id);
        fetch fee_expense_csr into fee_expense_rec;

        -- No Expense associated with Fee
        if fee_expense_csr%NOTFOUND THEN
          close fee_expense_csr;

          if (contract_fee_rec.fee_type = 'CAPITALIZED') then

            l_subline_present := 'N';
            l_sub_cap_amt     := 0;

            i := 0;
            for fee_subline_rec in fee_subline_csr
                  (p_cle_id => contract_fee_rec.id,
                   p_chr_id => p_chr_id)
            loop
              i := i + 1;
              l_subline_present := 'Y';
              l_sub_cap_amt := l_sub_cap_amt + fee_subline_rec.capital_amount;

              lp_sub_clev_rec.id := fee_subline_rec.id;
              lp_sub_clev_rec.start_date := p_release_date;

              lp_sub_clev_tbl(i) := lp_sub_clev_rec;
              lp_sub_klev_tbl(i) := lp_klev_temp_rec;
            end loop;

            -- No Covered assets associated with Fee
            if (l_subline_present = 'N') then

              -- Delete Capitalized Fee line if no Covered Assets are present
              OKL_CONTRACT_PUB.delete_contract_line(
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_line_id       => contract_fee_rec.id
               );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            -- Covered assets associated with Fee
            else

              -- Set Fee line Start Date equal to Release Date
              lp_clev_rec.id := contract_fee_rec.id;
              lp_clev_rec.start_date := p_release_date;

              -- Set the capital_amount on capitalized fee top line equal
              -- to the sum of capital_amount on capitalized fee sublines
              if (contract_fee_rec.amount <> l_sub_cap_amt) then
                lp_klev_rec.id := contract_fee_rec.id;
                lp_klev_rec.amount :=l_sub_cap_amt;
                lp_klev_rec.capital_amount := l_sub_cap_amt;
              end if;

              -- Set Fee Top Line Start Date equal to Release Date
              -- and Amount equal to sum of capital_amounts
              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_rec            => lp_clev_rec,
                p_klev_rec            => lp_klev_rec,
                x_clev_rec            => lx_clev_rec,
                x_klev_rec            => lx_klev_rec
              );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              -- Set Covered Asset line Start Dates equal to Release Date
              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_tbl            => lp_sub_clev_tbl,
                p_klev_tbl            => lp_sub_klev_tbl,
                x_clev_tbl            => lx_sub_clev_tbl,
                x_klev_tbl            => lx_sub_klev_tbl
               );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            end if; --Subline Present Y/N

          -- Fee type is not 'CAPITALIZED'
          else

            l_pymt_exists := 'N';
            open check_pymts_csr(p_chr_id => p_chr_id
                                ,p_cle_id => contract_fee_rec.id);
            fetch check_pymts_csr into l_pymt_exists,l_rgp_id;
            close check_pymts_csr;

			if ( l_pymt_exists = 'N') then
              -- Start change for rollover by fmiao on 12-OCT-2004--
			  OPEN fee_type_csr (contract_fee_rec.id);
			  FETCH fee_type_csr INTO l_fee_type;
			  CLOSE fee_type_csr;

			  if (l_fee_type <> 'ROLLOVER') then

                -- Delete Fee line if no Payments or Expenses are present
                OKL_CONTRACT_PUB.delete_contract_line(
                  p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_line_id       => contract_fee_rec.id
                 );

              	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              	END IF;

			  --avsingh : payment may exist at the sub-line level
              elsif (l_fee_type = 'ROLLOVER') then

			    l_subline_present := 'N';
                l_rlvr_sub_total  := 0;

                i := 0;
                for fee_subline_rec in fee_subline_csr
                  (p_cle_id => contract_fee_rec.id,
                   p_chr_id => p_chr_id)
                loop
                  i := i + 1;
                  l_subline_present := 'Y';

                  l_principal_bal := 0;
                  l_accumulated_int := 0;
    			  okl_stream_generator_pvt.get_sched_principal_bal(
				                  p_api_version         => p_api_version,
                                  p_init_msg_list       => p_init_msg_list,
                                  p_khr_id              => p_orig_chr_id,
                                  p_kle_id              => fee_subline_rec.orig_system_id1,
                                  p_date                => p_release_date,
                                  x_principal_balance   => l_principal_bal,
                                  x_accumulated_int     => l_accumulated_int,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data);


                  lp_sub_clev_rec.id := fee_subline_rec.id;
                  lp_sub_clev_rec.start_date := p_release_date;

                  lp_sub_klev_rec.id := fee_subline_rec.id;
                  lp_sub_klev_rec.amount :=l_principal_bal + l_accumulated_int;

                  --Bug# 4080102 - Round Rollover Fee subline amount
                  lp_sub_klev_rec.amount :=
                         OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                           (p_amount        => lp_sub_klev_rec.amount,
                            p_currency_code => l_currency_code);

                  l_rlvr_sub_total := l_rlvr_sub_total + lp_sub_klev_rec.amount;

                  lp_sub_clev_tbl(i) := lp_sub_clev_rec;
                  lp_sub_klev_tbl(i) := lp_sub_klev_rec;
                end loop;

                l_new_fee_amount :=
                         OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                           (p_amount        => l_rlvr_sub_total,
                            p_currency_code => l_currency_code);

                if (l_subline_present = 'Y') then
                  -- Set Covered Asset line Start Dates equal to Release Date
                  -- and Amount proportionate to the new fee amount
                  OKL_CONTRACT_PUB.update_contract_line(
                    p_api_version         => p_api_version,
                    p_init_msg_list       => p_init_msg_list,
                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data,
                    p_clev_tbl            => lp_sub_clev_tbl,
                    p_klev_tbl            => lp_sub_klev_tbl,
                    x_clev_tbl            => lx_sub_clev_tbl,
                    x_klev_tbl            => lx_sub_klev_tbl
                   );

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                lp_clev_rec.id := contract_fee_rec.id;
                lp_clev_rec.start_date := p_release_date;
                lp_klev_rec.id := contract_fee_rec.id;
                lp_klev_rec.amount := l_new_fee_amount;
                lp_klev_rec.initial_direct_cost := l_new_idc_amount;

                -- Set Fee Top Line Start Date equal to Release Date
                -- Retain Fee Amount equal to the amount from original contract
                -- Set IDC to Null, as no Expenses present
                OKL_CONTRACT_PUB.update_contract_line(
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_clev_rec            => lp_clev_rec,
                  p_klev_rec            => lp_klev_rec,
                  x_clev_rec            => lx_clev_rec,
                  x_klev_rec            => lx_klev_rec
                );

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

              else --sublines not found

                -- Delete Fee line if no Payments or Expenses are present
                OKL_CONTRACT_PUB.delete_contract_line(
                  p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_line_id       => contract_fee_rec.id
                );

              	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              	END IF;

              end if; -- Subline exists
              --avsingh : payment may exist at sub-line level
			  end if;
			  -- End change for rollover by fmiao on 12-OCT-2004--

            elsif (l_pymt_exists = 'Y') then

              -- Retain Fee Amount equal to the amount from original contract
              -- Set IDC to Null, as no Expenses present

              l_new_fee_amount := contract_fee_rec.amount;
              l_new_idc_amount := null;

              -- For Income and Passthrough Fee, set the fee line amount
              -- equal to the total of the payments
              if (contract_fee_rec.fee_type IN ('PASSTHROUGH', 'INCOME')) then

                l_pymt_amount := 0;
                for pymt_details_rec in pymt_details_csr(p_chr_id => p_chr_id,
                                                         p_rgp_id => l_rgp_id,
                                                         p_rul_cat => 'LASLL')
                loop
                  if (pymt_details_rec.rule_information8 IS NOT NULL) THEN
                    l_pymt_amount := l_pymt_amount +
                                  TO_NUMBER(pymt_details_rec.rule_information8);
                  else
                    l_pymt_amount := l_pymt_amount +
                      (TO_NUMBER(NVL(pymt_details_rec.rule_information6,'0')) *
                       TO_NUMBER(NVL(pymt_details_rec.rule_information3,'1')) );
                  end if;
                end loop;

                l_new_fee_amount := l_pymt_amount;

              -- For Rollover Fee, if Payment Incomplete then set Fee Amount
              -- equal to Closing Principal Balance prior to the Re-lease Date and
              -- update covered asset amount for each covered asset
              -- proportionate to the new Fee Amount

              elsif  (contract_fee_rec.fee_type = 'ROLLOVER') then

                -- Fetch Primary Stream Type Id for Fee Payment
                pymt_details_rec := null;
                open pymt_details_csr(p_chr_id  => p_chr_id,
                                      p_rgp_id  => l_rgp_id,
                                      p_rul_cat => 'LASLH');
                fetch pymt_details_csr into pymt_details_rec;
                close pymt_details_csr;

                l_principal_bal := 0;
                l_accumulated_int := 0;
				-- Start change for accrued interest by fmiao 09-NOV-04--
                okl_stream_generator_pvt.get_sched_principal_bal(
				                  p_api_version         => p_api_version,
                                  p_init_msg_list       => p_init_msg_list,
                                  p_khr_id              => p_orig_chr_id,
                                  p_kle_id              => contract_fee_rec.orig_system_id1,
                                  p_date                => p_release_date,
                                  x_principal_balance   => l_principal_bal,
                                  x_accumulated_int     => l_accumulated_int,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data);

				-- End change for accrued interest by fmiao 09-NOV-04--

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_new_fee_amount := l_principal_bal + l_accumulated_int;

                l_subline_present := 'N';
                l_rlvr_sub_total  := 0;

                i := 0;
                for fee_subline_rec in fee_subline_csr
                  (p_cle_id => contract_fee_rec.id,
                   p_chr_id => p_chr_id)
                loop
                  i := i + 1;
                  l_subline_present := 'Y';
                  l_rlvr_sub_total := l_rlvr_sub_total + fee_subline_rec.amount;

                  lp_sub_clev_rec.id := fee_subline_rec.id;
                  lp_sub_clev_rec.start_date := p_release_date;

                  lp_sub_klev_rec.id := fee_subline_rec.id;
                  lp_sub_klev_rec.amount := fee_subline_rec.amount;

                  lp_sub_clev_tbl(i) := lp_sub_clev_rec;
                  lp_sub_klev_tbl(i) := lp_sub_klev_rec;
                end loop;

                -- If not all covered assets have moved over then adjust
                -- New Fee amount proportionate to the Covered assets
                -- moved over
                if (contract_fee_rec.amount <> l_rlvr_sub_total) then
                  l_new_fee_amount := l_new_fee_amount * (l_rlvr_sub_total/contract_fee_rec.amount);

                  l_new_fee_amount :=
                         OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                           (p_amount        => l_new_fee_amount,
                            p_currency_code => l_currency_code);
                end if;

                -- Set Sub-line amount proportionate to the new fee amount
                l_sum := 0;
                for i in 1..lp_sub_klev_tbl.COUNT loop

                  if (i = lp_sub_klev_tbl.COUNT) then
                    lp_sub_klev_tbl(i).amount :=  l_new_fee_amount - l_sum;

                  else

                    l_rlvr_sub_amt := l_new_fee_amount *
                                      lp_sub_klev_tbl(i).amount / l_rlvr_sub_total;

                    lp_sub_klev_tbl(i).amount :=
                         OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                         (p_amount        => l_rlvr_sub_amt,
                          p_currency_code => l_currency_code);

                    l_sum := l_sum + lp_sub_klev_tbl(i).amount;

                  end if;
                end loop;

                if (l_subline_present = 'Y') then
                  -- Set Covered Asset line Start Dates equal to Release Date
                  -- and Amount proportionate to the new fee amount
                  OKL_CONTRACT_PUB.update_contract_line(
                    p_api_version         => p_api_version,
                    p_init_msg_list       => p_init_msg_list,
                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data,
                    p_clev_tbl            => lp_sub_clev_tbl,
                    p_klev_tbl            => lp_sub_klev_tbl,
                    x_clev_tbl            => lx_sub_clev_tbl,
                    x_klev_tbl            => lx_sub_klev_tbl
                   );

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                end if; -- Subline exists
              end if; -- Fee Type - Income / Passthrough /Rollover

              lp_clev_rec.id := contract_fee_rec.id;
              lp_clev_rec.start_date := p_release_date;

              lp_klev_rec.id := contract_fee_rec.id;
              lp_klev_rec.amount := l_new_fee_amount;
              lp_klev_rec.initial_direct_cost := l_new_idc_amount;

              -- Set Fee Top Line Start Date equal to Release Date
              -- Retain Fee Amount equal to the amount from original contract
              -- Set IDC to Null, as no Expenses present
              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_rec            => lp_clev_rec,
                p_klev_rec            => lp_klev_rec,
                x_clev_rec            => lx_clev_rec,
                x_klev_rec            => lx_klev_rec
              );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            end if; --Payment exists Y/N
          end if;  --Capitalized Fee Y/N

        -- Expense associated with Fee
        else
          close fee_expense_csr;

          l_periods_bef_release :=
              CEIL(CEIL(MONTHS_BETWEEN(p_release_date,contract_fee_rec.start_date))/fee_expense_rec.factor);

          l_new_no_of_periods := fee_expense_rec.periods - l_periods_bef_release;

          if (l_new_no_of_periods > 0) then

            l_new_fee_amount :=  fee_expense_rec.amount * l_new_no_of_periods;

            -- New IDC Expense is equal to
            -- Total of Unpaid Recurring Expenses * (Original IDC / Original Fee Amount)
            -- Less Total Unamortized IDC Exp

            l_new_idc_amount := null;
            if (contract_fee_rec.initial_direct_cost IS NOT NULL) then

              l_new_idc_amount := l_new_fee_amount *
                       (contract_fee_rec.initial_direct_cost/contract_fee_rec.amount);

              /* Old Formula - Uncomment if required
              -- Fetch Primary Stream Type Id for Fee Expense
              open fee_item_csr(p_chr_id => p_chr_id,
                                p_cle_id => contract_fee_rec.id);
              fetch fee_item_csr into fee_item_rec;
              close fee_item_csr;

              -- Fetch Stream information from Original Contract
              l_idc_sty_id := null;
              OKL_STREAMS_UTIL.get_dependent_stream_type
                (p_khr_id                  => p_orig_chr_id,
                 p_primary_sty_id          => fee_item_rec.object1_id1,
                 p_dependent_sty_purpose   => 'AMORTIZED_FEE_EXPENSE',
                 x_return_status           => x_return_status,
                 x_dependent_sty_id        => l_idc_sty_id);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              if (l_idc_sty_id IS NOT NULL) then

                open streams_csr(p_chr_id => p_orig_chr_id,
                                 p_cle_id => contract_fee_rec.orig_system_id1,
                                 p_sty_id => l_idc_sty_id);
                fetch streams_csr into streams_rec;
                close streams_csr;

                if (streams_rec.id IS NOT NULL) then

                  open unamort_idc_exp_csr(p_stm_id       => streams_rec.id,
                                           p_release_date => p_release_date);
                  fetch unamort_idc_exp_csr into unamort_idc_exp_rec;
                  close unamort_idc_exp_csr;

                  l_new_idc_amount :=
                  (l_new_fee_amount * (contract_fee_rec.initial_direct_cost/contract_fee_rec.amount))
                     - NVL(unamort_idc_exp_rec.amount,0);

                end if; --IDC Stream Id is not null
              end if; -- IDC Stream Type Id is not null
            */

            end if; -- IDC is not null

            l_rulv_rec.id                 := fee_expense_rec.rul_lafexp_id;
            l_rulv_rec.rule_information1  := TO_CHAR(l_new_no_of_periods);

            -- Set Expense periods equal to New No. of periods
            OKL_RULE_PUB.update_rule(
                    p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_rulv_rec           => l_rulv_rec,
                    x_rulv_rec           => lx_rulv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            lp_clev_rec.id := contract_fee_rec.id;
            lp_clev_rec.start_date := p_release_date;

            lp_klev_rec.id := contract_fee_rec.id;
            lp_klev_rec.amount := l_new_fee_amount;
            lp_klev_rec.initial_direct_cost := l_new_idc_amount;

            -- For Misellaneous Fee, if Expense Incomplete and Payment Complete
            -- then change Fee Type to EXPENSE
            if (contract_fee_rec.fee_type = 'MISCELLANEOUS') then

              l_pymt_exists := 'N';
              open check_pymts_csr(p_chr_id => p_chr_id
                                  ,p_cle_id => contract_fee_rec.id);
              fetch check_pymts_csr into l_pymt_exists, l_rgp_id;
              close check_pymts_csr;

              if (l_pymt_exists = 'N') then
                lp_klev_rec.fee_type := 'EXPENSE';
              end if; -- Payment does not exist
            end if; -- Miscellaneous Fee

            -- Set Fee Top Line Start Date equal to Release Date
            -- and Amount equal to Expense per period Amount * New No. of periods
            OKL_CONTRACT_PUB.update_contract_line(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_clev_rec            => lp_clev_rec,
              p_klev_rec            => lp_klev_rec,
              x_clev_rec            => lx_clev_rec,
              x_klev_rec            => lx_klev_rec
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          -- No. of periods <= 0
          else

            l_pymt_exists := 'N';
            open check_pymts_csr(p_chr_id => p_chr_id
                                ,p_cle_id => contract_fee_rec.id);
            fetch check_pymts_csr into l_pymt_exists, l_rgp_id;
            close check_pymts_csr;

            if ( l_pymt_exists = 'N') then

              -- Delete Fee line if Expenses are complete
              -- and no Payments present
              OKL_CONTRACT_PUB.delete_contract_line(
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_line_id       => contract_fee_rec.id
               );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            elsif (l_pymt_exists = 'Y') then

              -- Retain Fee Amount equal to the amount from original contract
              -- Set IDC to Null, as no Expenses present
              -- Delete Expense Rules as No. of periods <= 0

              l_new_fee_amount := contract_fee_rec.amount;
              l_new_idc_amount := null;

              lp_clev_rec.id := contract_fee_rec.id;
              lp_clev_rec.start_date := p_release_date;

              lp_klev_rec.id := contract_fee_rec.id;
              lp_klev_rec.amount := l_new_fee_amount;
              lp_klev_rec.initial_direct_cost := l_new_idc_amount;

              -- For Misellaneous Fee, if Expense Complete and Payment Incomplete
              -- then Change Fee Type to INCOME
              -- Set Fee Line Amount equal to total of the Payments
              -- Set Stream Type on the Fee to the Stream associated with Payments
              if (contract_fee_rec.fee_type = 'MISCELLANEOUS') then

                lp_klev_rec.fee_type := 'INCOME';

                -- Update Fee line Amount to total of the Payments
                l_pymt_amount := 0;
                for pymt_details_rec in pymt_details_csr(p_chr_id  => p_chr_id,
                                                         p_rgp_id  => l_rgp_id,
                                                         p_rul_cat => 'LASLL')
                loop
                  if (pymt_details_rec.rule_information8 IS NOT NULL) THEN
                    l_pymt_amount := l_pymt_amount +
                                  TO_NUMBER(pymt_details_rec.rule_information8);
                  else
                    l_pymt_amount := l_pymt_amount +
                      (TO_NUMBER(NVL(pymt_details_rec.rule_information6,'0')) *
                       TO_NUMBER(NVL(pymt_details_rec.rule_information3,'1')) );
                  end if;
                end loop;
                lp_klev_rec.amount := l_pymt_amount;

                -- Update Stream Type on the Fee to Stream associated with
                -- Payments
                pymt_details_rec := null;
                open pymt_details_csr(p_chr_id  => p_chr_id,
                                      p_rgp_id  => l_rgp_id,
                                      p_rul_cat => 'LASLH');
                fetch pymt_details_csr into pymt_details_rec;
                close pymt_details_csr;

                if (pymt_details_rec.object1_id1 IS NOT NULL) then
                  open fee_item_csr(p_chr_id => p_chr_id,
                                    p_cle_id => contract_fee_rec.id);
                  fetch fee_item_csr into fee_item_rec;
                  close fee_item_csr;

                  if (fee_item_rec.id IS NOT NULL) then
                    lp_cimv_rec.id           := fee_item_rec.id;
                    lp_cimv_rec.object1_id1  := pymt_details_rec.object1_id1;

                    OKL_OKC_MIGRATION_PVT.update_contract_item
                      (p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_cimv_rec       => lp_cimv_rec,
                       x_cimv_rec       => lx_cimv_rec);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    END IF;

                  end if; --Fee item exists
                end if; -- Payment Stream Type exists


              -- For Financed Fee, if Expense Complete and Payment Incomplete
              -- then set Fee and Expense Amount equal to Closing Principal
              -- Balance prior to the Re-lease Date and
              -- Expense periods equal to 1
              elsif (contract_fee_rec.fee_type = 'FINANCED') then

                -- Fetch Primary Stream Type Id for Fee Payment
                pymt_details_rec := null;
                open pymt_details_csr(p_chr_id  => p_chr_id,
                                      p_rgp_id  => l_rgp_id,
                                      p_rul_cat => 'LASLH');
                fetch pymt_details_csr into pymt_details_rec;
                close pymt_details_csr;

                l_principal_bal := 0;
                l_accumulated_int := 0;
				-- Start change for accrued interest by fmiao 09-NOV-04--
				okl_stream_generator_pvt.get_sched_principal_bal(
				                  p_api_version         => p_api_version,
                                  p_init_msg_list       => p_init_msg_list,
                                  p_khr_id              => p_orig_chr_id,
                                  p_kle_id              => contract_fee_rec.orig_system_id1,
                                  p_date                => p_release_date,
                                  x_principal_balance   => l_principal_bal,
                                  x_accumulated_int     => l_accumulated_int,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data);
				-- End change for accrued interest by fmiao 09-NOV-04--

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                lp_klev_rec.amount := l_principal_bal + l_accumulated_int;

                --Bug# 4080102 - Round Financed Fee amount
                lp_klev_rec.amount :=
                         OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                         (p_amount        => lp_klev_rec.amount,
                          p_currency_code => l_currency_code);

                l_rulv_rec.id                 := fee_expense_rec.rul_lafexp_id;
                l_rulv_rec.rule_information1  := '1';
                l_rulv_rec.rule_information2  := TO_CHAR(lp_klev_rec.amount);

                -- Set Expense periods equal to 1 and
                -- Amount equal to Closing principal balance
                OKL_RULE_PUB.update_rule(
                  p_api_version        => p_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_rulv_rec           => l_rulv_rec,
                  x_rulv_rec           => lx_rulv_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

              end if; -- Fee Type - Miscellaneous / Financed

              -- Set Fee Top Line Start Date equal to Release Date
              -- Retain Amount equal to the amount from original contract
              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_rec            => lp_clev_rec,
                p_klev_rec            => lp_klev_rec,
                x_clev_rec            => lx_clev_rec,
                x_klev_rec            => lx_klev_rec
              );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              if (contract_fee_rec.fee_type <> 'FINANCED') then
                -- Delete Expense Rules as No. of periods is <= 0
                l_rgpv_rec.id := fee_expense_rec.rgp_id; -- LAFEXP Rule Group ID
                OKL_RULE_PUB.delete_rule_group(
                  p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_rgpv_rec       => l_rgpv_rec
                  );
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              end if;

            end if; --Payment exists Y/N
          end if; --New No. of periods > 0
        end if; --Expense associated with Fee

      end if; --Fee line End Date >= Release Date
    end loop;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        IF fee_expense_csr%ISOPEN THEN
          close fee_expense_csr;
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        IF fee_expense_csr%ISOPEN THEN
          close fee_expense_csr;
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        IF fee_expense_csr%ISOPEN THEN
          close fee_expense_csr;
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END adjust_fee_lines;

  -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Adjust_Service_Lines
-- Description          : Adjust Service lines on the Re-lease contract
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE adjust_service_lines(p_api_version   IN  NUMBER,
                                 p_init_msg_list IN  VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_chr_id        IN  NUMBER,
                                 p_orig_chr_id   IN  NUMBER,
                                 p_release_date  IN  DATE) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'ADJUST_SERVICE_LINES';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR contract_service_csr
           (p_chr_id       IN NUMBER) IS
    SELECT cle.id,
           cle.start_date,
           cle.end_date,
           kle.amount,
           cle.chr_id,
           cle.dnz_chr_id,
           cle.cle_id,
           cle.orig_system_id1,
           sts.ste_code
    FROM okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_statuses_b sts
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.chr_id =  p_chr_id
    AND  kle.id = cle.id
    AND  cle.lse_id = lse.id
    AND  lse.lty_code = 'SOLD_SERVICE'
    AND  cle.sts_code = sts.code;

    CURSOR orig_cle_sts_csr(p_cle_id IN NUMBER)
    IS
    SELECT sts.ste_code
    FROM   okc_k_lines_b cle,
           okc_statuses_b sts
    WHERE  cle.id = p_cle_id
    AND    cle.sts_code = sts.code;

    orig_cle_sts_rec orig_cle_sts_csr%ROWTYPE;

    CURSOR service_expense_csr
           (p_chr_id       IN NUMBER,
            p_cle_id       IN NUMBER) IS
    SELECT DECODE(rul_lafreq.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)factor,
           TO_NUMBER(rul_lafexp.rule_information1) periods,
           TO_NUMBER(rul_lafexp.rule_information2) amount,
           rul_lafexp.id  rul_lafexp_id,
           rul_lafreq.id  rul_lafreq_id,
           rgp.id         rgp_id
    FROM   okc_rules_b rul_lafexp,
           okc_rules_b rul_lafreq,
           okc_rule_groups_b rgp
    WHERE  rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id = p_cle_id
    AND   rgp.rgd_code = 'LAFEXP'
    AND   rul_lafreq.rgp_id = rgp.id
    AND   rul_lafreq.rule_information_category = 'LAFREQ'
    AND   rul_lafexp.rgp_id = rgp.id
    AND   rul_lafexp.rule_information_category = 'LAFEXP';

    service_expense_rec service_expense_csr%ROWTYPE;

    CURSOR service_subline_csr (p_chr_id IN NUMBER,
                                p_cle_id IN NUMBER) IS
    SELECT cle.id,
           NVL(kle.capital_amount,0) capital_amount,
           cle.chr_id,
           cle.dnz_chr_id,
           cle.cle_id
    FROM   okc_k_lines_b cle,
           okl_k_lines kle
    WHERE  cle.cle_id   = p_cle_id
    AND    cle.dnz_chr_id = p_chr_id
    AND    cle.id = kle.id;

    CURSOR curr_hdr_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

    CURSOR check_pymts_csr(p_chr_id IN NUMBER,
                           p_cle_id IN NUMBER) IS
    SELECT 'Y'  pymt_exists
    FROM   okc_rule_groups_b rgp
    WHERE  rgp.cle_id   = p_cle_id
    AND    rgp.dnz_chr_id = p_chr_id
    AND    rgp.rgd_code  = 'LALEVL';

    l_pymt_exists VARCHAR2(30);

    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
    lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;

    l_rgpv_rec  OKL_RULE_PUB.rgpv_rec_type;

    l_periods_bef_release NUMBER;
    l_orig_no_of_periods  NUMBER;
    l_new_no_of_periods   NUMBER;
    l_new_service_amount  NUMBER;
    l_per_period_amount   NUMBER;

    lp_klev_rec  okl_kle_pvt.klev_rec_type;
    lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lx_klev_rec  okl_kle_pvt.klev_rec_type;
    lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lp_sub_clev_tbl  okl_okc_migration_pvt.clev_tbl_type;
    lx_sub_clev_tbl  okl_okc_migration_pvt.clev_tbl_type;
    lp_sub_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lp_sub_klev_tbl  okl_kle_pvt.klev_tbl_type;
    lx_sub_klev_tbl  okl_kle_pvt.klev_tbl_type;
    lp_sub_klev_rec  okl_kle_pvt.klev_rec_type;

    lp_clev_temp_tbl okl_okc_migration_pvt.clev_tbl_type;
    lp_clev_temp_rec okl_okc_migration_pvt.clev_rec_type;
    lp_klev_temp_tbl okl_kle_pvt.klev_tbl_type;
    lp_klev_temp_rec okl_kle_pvt.klev_rec_type;
    l_rulv_temp_rec  okl_rule_pub.rulv_rec_type;
    l_rgpv_temp_rec  okl_rule_pub.rgpv_rec_type;

    l_subline_present     VARCHAR2(1);
    l_sub_cap_amt         NUMBER;
    l_capital_amount      NUMBER;
    l_sum                 NUMBER;
    i NUMBER;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_currency_code := '?';
    open curr_hdr_csr (p_chr_id);
    fetch curr_hdr_csr into l_currency_code;
    close curr_hdr_csr;

    if (l_currency_code = '?') then

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Currency Code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    for contract_service_rec in contract_service_csr
                                 (p_chr_id => p_chr_id) loop

      l_rulv_rec      := l_rulv_temp_rec;
      l_rgpv_rec      := l_rgpv_temp_rec;
      lp_clev_rec     := lp_clev_temp_rec;
      lp_klev_rec     := lp_klev_temp_rec;
      lp_sub_clev_rec := lp_clev_temp_rec;
      lp_sub_clev_tbl := lp_clev_temp_tbl;
      lp_sub_klev_rec := lp_klev_temp_rec;
      lp_sub_klev_tbl := lp_klev_temp_tbl;

      -- Delete Service Lines where End Date is earlier than Re-lease date
      -- or Line status is not Active

      -- Fetch Status of the Line in original contract
      open orig_cle_sts_csr(p_cle_id => contract_service_rec.orig_system_id1);
      fetch orig_cle_sts_csr into orig_cle_sts_rec;
      close orig_cle_sts_csr;

      if (contract_service_rec.end_date < p_release_date) or
         (contract_service_rec.ste_code IN ('TERMINATED','EXPIRED','CANCELLED')) or
         (orig_cle_sts_rec.ste_code IN ('TERMINATED', 'EXPIRED', 'CANCELLED')) then

        OKL_CONTRACT_PUB.delete_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_line_id       => contract_service_rec.id
        );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      -- If Service Line Start Date is greater than or equal to Re-lease date
      -- Update Service Top line Amount equal to sum of covered assets
      -- if its not equal
      -- Update Expense Per Period amount as New Service Amount / Periods
      elsif (contract_service_rec.start_date >= p_release_date) then

        l_subline_present := 'N';

        i := 0;
        l_sub_cap_amt     := 0;
        for service_subline_rec in service_subline_csr
                                 (p_chr_id => p_chr_id,
                                  p_cle_id => contract_service_rec.id)
        loop
          i := i + 1;
          l_subline_present := 'Y';
          l_sub_cap_amt := l_sub_cap_amt + service_subline_rec.capital_amount;
        end loop;

        -- Covered assets associated with Service
        if ((l_subline_present = 'Y') and (contract_service_rec.amount <> l_sub_cap_amt)) then

          l_new_service_amount := l_sub_cap_amt;

          open service_expense_csr(p_chr_id => p_chr_id,
                                   p_cle_id => contract_service_rec.id);
          fetch service_expense_csr into service_expense_rec;

          -- Expense associated with Service
          if service_expense_csr%FOUND THEN
            close service_expense_csr;

            if (service_expense_rec.periods > 0) then
              l_per_period_amount :=  l_new_service_amount / service_expense_rec.periods;

              l_per_period_amount :=
                       OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                         (p_amount        => l_per_period_amount,
                          p_currency_code => l_currency_code);

              l_rulv_rec.id                 := service_expense_rec.rul_lafexp_id;
              l_rulv_rec.rule_information2  := TO_CHAR(l_per_period_amount);

              -- Set Per period Amount equal to Rounded value of
              -- (Sum of Covered Asset Capital Amounts / No. of periods)
              OKL_RULE_PUB.update_rule(
                  p_api_version        => p_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_rulv_rec           => l_rulv_rec,
                  x_rulv_rec           => lx_rulv_rec);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            end if; --Periods > 0

          -- No Expenses associated with service
          else
            close service_expense_csr;
          end if;

          lp_clev_rec.id := contract_service_rec.id;

          lp_klev_rec.id := contract_service_rec.id;
          lp_klev_rec.amount := l_new_service_amount;

          -- Set Service Top Line Amount equal to sum of capital_amounts
          OKL_CONTRACT_PUB.update_contract_line(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_clev_rec            => lp_clev_rec,
            p_klev_rec            => lp_klev_rec,
            x_clev_rec            => lx_clev_rec,
            x_klev_rec            => lx_klev_rec
          );

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        end if; --Subline present = 'Y'

      -- Update Service Line Start Date and Amount where End Date is greater than
      -- or equal to Re-lease date and Start Date is less than Re-lease date
      elsif (contract_service_rec.start_date < p_release_date) then

        l_subline_present := 'N';

        i := 0;
        l_sub_cap_amt     := 0;
        for service_subline_rec in service_subline_csr
                                 (p_chr_id => p_chr_id,
                                  p_cle_id => contract_service_rec.id)
        loop
          i := i + 1;
          l_subline_present := 'Y';
          l_sub_cap_amt := l_sub_cap_amt + service_subline_rec.capital_amount;

          lp_sub_clev_rec.id := service_subline_rec.id;
          lp_sub_clev_rec.start_date := p_release_date;

          lp_sub_klev_rec.id := service_subline_rec.id;
          lp_sub_klev_rec.capital_amount := service_subline_rec.capital_amount;

          lp_sub_clev_tbl(i) := lp_sub_clev_rec;
          lp_sub_klev_tbl(i) := lp_sub_klev_rec;
        end loop;

        -- Covered assets associated with Service
        if (l_subline_present = 'Y') then

          open service_expense_csr(p_chr_id => p_chr_id,
                                   p_cle_id => contract_service_rec.id);
          fetch service_expense_csr into service_expense_rec;

          -- Expense associated with Service
          if service_expense_csr%FOUND THEN
            close service_expense_csr;

            l_periods_bef_release :=
                CEIL(CEIL(MONTHS_BETWEEN(p_release_date,contract_service_rec.start_date))/service_expense_rec.factor);
            l_new_no_of_periods := service_expense_rec.periods - l_periods_bef_release;

            if (l_new_no_of_periods > 0) then

              l_per_period_amount :=  service_expense_rec.amount * l_sub_cap_amt / contract_service_rec.amount;

              l_per_period_amount :=
                       OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                         (p_amount        => l_per_period_amount,
                          p_currency_code => l_currency_code);

              l_new_service_amount := l_per_period_amount *  l_new_no_of_periods;

              l_sum := 0;
              for i in 1..lp_sub_klev_tbl.COUNT loop

                if (i = lp_sub_klev_tbl.COUNT) then
                   lp_sub_klev_tbl(i).capital_amount :=  l_new_service_amount - l_sum;

                else

                  l_capital_amount := lp_sub_klev_tbl(i).capital_amount *
                                      l_new_no_of_periods / service_expense_rec.periods;

                  lp_sub_klev_tbl(i).capital_amount :=
                       OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                         (p_amount        => l_capital_amount,
                          p_currency_code => l_currency_code);

                  l_sum := l_sum + lp_sub_klev_tbl(i).capital_amount;

                end if;
              end loop;

              l_rulv_rec.id                 := service_expense_rec.rul_lafexp_id;
              l_rulv_rec.rule_information1  := TO_CHAR(l_new_no_of_periods);
              l_rulv_rec.rule_information2  := TO_CHAR(l_per_period_amount);

              -- Set Expense periods equal to New No. of periods and
              -- per period Amount equal to Rounded value of
              -- (Sum of Covered Asset Capital Amounts / New No. of periods)
              OKL_RULE_PUB.update_rule(
                  p_api_version        => p_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_rulv_rec           => l_rulv_rec,
                  x_rulv_rec           => lx_rulv_rec);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            --New No. of periods <= 0
            else

              l_new_service_amount := l_sub_cap_amt;

              -- Delete Expense Rules as No. of periods is <= 0
              l_rgpv_rec.id := service_expense_rec.rgp_id; -- LAFEXP Rule Group ID
              OKL_RULE_PUB.delete_rule_group(
                  p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_rgpv_rec       => l_rgpv_rec
                  );
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            end if;

          -- No Expense associated with Service
          else

            l_new_service_amount := l_sub_cap_amt;
            close service_expense_csr;
          end if;

          -- Set Service line Start Date equal to Release Date
          lp_clev_rec.id := contract_service_rec.id;
          lp_clev_rec.start_date := p_release_date;

          lp_klev_rec.id := contract_service_rec.id;
          lp_klev_rec.amount := l_new_service_amount;

          -- Set Service Top Line Start Date equal to Release Date
          -- and Amount equal to sum of capital_amounts
          OKL_CONTRACT_PUB.update_contract_line(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_clev_rec            => lp_clev_rec,
            p_klev_rec            => lp_klev_rec,
            x_clev_rec            => lx_clev_rec,
            x_klev_rec            => lx_klev_rec
          );

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- Set Covered Asset line Start Dates equal to Release Date
          OKL_CONTRACT_PUB.update_contract_line(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_clev_tbl            => lp_sub_clev_tbl,
            p_klev_tbl            => lp_sub_klev_tbl,
            x_clev_tbl            => lx_sub_clev_tbl,
            x_klev_tbl            => lx_sub_klev_tbl
          );

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        -- No Covered asset associated with Service
        else

          open service_expense_csr(p_chr_id => p_chr_id,
                                   p_cle_id => contract_service_rec.id);
          fetch service_expense_csr into service_expense_rec;

          -- No Expense associated with Service
          if service_expense_csr%NOTFOUND THEN
            close service_expense_csr;

            lp_clev_rec.id := contract_service_rec.id;
            lp_clev_rec.start_date := p_release_date;

            lp_klev_rec.id := contract_service_rec.id;

            -- Set Service Top Line Start Date equal to Release Date
            -- and retain Amount equal to the Amount from original contract
            OKL_CONTRACT_PUB.update_contract_line(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_clev_rec            => lp_clev_rec,
              p_klev_rec            => lp_klev_rec,
              x_clev_rec            => lx_clev_rec,
              x_klev_rec            => lx_klev_rec
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          -- Expense is associated with Service
          else
            close service_expense_csr;
            l_periods_bef_release :=
              CEIL(CEIL(MONTHS_BETWEEN(p_release_date,contract_service_rec.start_date))/service_expense_rec.factor);

            l_new_no_of_periods := service_expense_rec.periods - l_periods_bef_release;

            if (l_new_no_of_periods > 0) then

              l_new_service_amount :=  service_expense_rec.amount * l_new_no_of_periods;

              l_rulv_rec.id                 := service_expense_rec.rul_lafexp_id;
              l_rulv_rec.rule_information1  := TO_CHAR(l_new_no_of_periods);

              -- Set Expense periods equal to New No. of periods
              OKL_RULE_PUB.update_rule(
                  p_api_version        => p_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_rulv_rec           => l_rulv_rec,
                  x_rulv_rec           => lx_rulv_rec);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              lp_clev_rec.id := contract_service_rec.id;
              lp_clev_rec.start_date := p_release_date;

              lp_klev_rec.id := contract_service_rec.id;
              lp_klev_rec.amount := l_new_service_amount;

              -- Set Service Top Line Start Date equal to Release Date
              -- and Amount equal to Expense per period Amount * New No. of periods
              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_rec            => lp_clev_rec,
                p_klev_rec            => lp_klev_rec,
                x_clev_rec            => lx_clev_rec,
                x_klev_rec            => lx_klev_rec
                );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            -- No. of periods <= 0
            else

              -- Retain Service Amount equal to the amount from original contract
              -- Delete Expense Rules as No. of periods <= 0

              lp_clev_rec.id := contract_service_rec.id;
              lp_clev_rec.start_date := p_release_date;

              lp_klev_rec.id := contract_service_rec.id;

              -- Set Service Top Line Start Date equal to Release Date
              -- and retin Amount equal to the Amount from original contract
              OKL_CONTRACT_PUB.update_contract_line(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_clev_rec            => lp_clev_rec,
                p_klev_rec            => lp_klev_rec,
                x_clev_rec            => lx_clev_rec,
                x_klev_rec            => lx_klev_rec
              );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              -- Delete Expense Rules as No. of periods is <= 0
              l_rgpv_rec.id := service_expense_rec.rgp_id; -- LAFEXP Rule Group ID
              OKL_RULE_PUB.delete_rule_group(
                p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_rgpv_rec       => l_rgpv_rec
                );
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            end if; --New No. of periods > 0
          end if; --Expense associated with Service
        end if; --Asset associated with Service
      end if; --Service line End Date >= Release Date
    end loop;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        IF service_expense_csr%ISOPEN THEN
          close service_expense_csr;
        END IF;

        IF service_subline_csr%ISOPEN THEN
          close service_subline_csr;
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        IF service_expense_csr%ISOPEN THEN
          close service_expense_csr;
        END IF;

        IF service_subline_csr%ISOPEN THEN
          close service_subline_csr;
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        IF service_expense_csr%ISOPEN THEN
          close service_expense_csr;
        END IF;

        IF service_subline_csr%ISOPEN THEN
          close service_subline_csr;
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END adjust_service_lines;


  -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Adjust_Partial_Taa_Pymt
-- Description          : Adjust Payment lines on the Re-lease contract for Partial TA
--                        when Service and Rollover fee payments are defined at Top line level
--                        and not all Covered assets move over to the new contract
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE adjust_partial_taa_pymt(p_api_version   IN  NUMBER,
                                    p_init_msg_list IN  VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_chr_id        IN  NUMBER) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'ADJUST_PARTIAL_TAA_PYMT';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR fee_serv_csr(p_chr_id    IN NUMBER)
    IS
    SELECT cle.id,
           kle.amount
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse,
         okl_k_lines kle
    WHERE cle.chr_id = p_chr_id
    AND cle.dnz_chr_id = p_chr_id
    AND lse.lty_code IN ('FEE','SOLD_SERVICE')
    AND cle.lse_id = lse.id
    AND kle.id = cle.id
    AND NVL(kle.fee_type,'XXXX') <> 'CAPITALIZED';

    CURSOR subline_csr (p_chr_id IN NUMBER,
                        p_cle_id IN NUMBER) IS
    SELECT SUM(NVL(kle.capital_amount,kle.amount)) sum_amount
    FROM   okc_k_lines_b cle,
           okl_k_lines kle
    WHERE  cle.cle_id   = p_cle_id
    AND    cle.dnz_chr_id = p_chr_id
    AND    kle.id = cle.id;

    CURSOR contract_payment_csr
           (p_chr_id       IN NUMBER,
            p_cle_id       IN NUMBER) IS
    SELECT TO_NUMBER(sll.rule_information6) amount,
           TO_NUMBER(sll.rule_information8) stub_amount,
           sll.id sll_id
    FROM okc_rules_b sll,
         okc_rule_groups_b rgp
    WHERE rgp.dnz_chr_id = p_chr_id
    AND rgp.cle_id = p_cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND sll.rule_information_category = 'LASLL'
    AND sll.rgp_id = rgp.id;

    CURSOR curr_hdr_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

    l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
    lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;

    l_rulv_temp_rec  OKL_RULE_PUB.rulv_rec_type;

    l_amount NUMBER;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_currency_code := '?';
    open curr_hdr_csr (p_chr_id);
    fetch curr_hdr_csr into l_currency_code;
    close curr_hdr_csr;

    if (l_currency_code = '?') then

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Currency Code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    for fee_serv_rec in fee_serv_csr(p_chr_id  => p_chr_id)loop

      for subline_rec in subline_csr(p_chr_id => p_chr_id,
                                     p_cle_id => fee_serv_rec.id) loop

        if  (fee_serv_rec.amount <> subline_rec.sum_amount) then

          for contract_payment_rec in contract_payment_csr
                                  (p_chr_id => p_chr_id,
                                   p_cle_id => fee_serv_rec.id) loop

            l_rulv_rec := l_rulv_temp_rec;

            l_rulv_rec.id := contract_payment_rec.sll_id; -- SLL Rule ID

            l_amount := NVL(contract_payment_rec.amount,contract_payment_rec.stub_amount)
                           * (subline_rec.sum_amount/fee_serv_rec.amount);

            l_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                          (p_amount        => l_amount,
                           p_currency_code => l_currency_code);

            if (contract_payment_rec.amount IS NOT NULL) then
              l_rulv_rec.rule_information6 := TO_CHAR(l_amount);
            else
              l_rulv_rec.rule_information8 := TO_CHAR(l_amount);
            end if;

            OKL_RULE_PUB.update_rule(
                    p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_rulv_rec           => l_rulv_rec,
                    x_rulv_rec           => lx_rulv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          end loop;
        end if;
      end loop;
    end loop;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END adjust_partial_taa_pymt;

  ------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_nbv
  --Purpose               : Get Net Book Value- used internally
  --Modification History  :
  --13-Oct-2004    rpillay   Created
  ------------------------------------------------------------------------------
  PROCEDURE get_nbv(p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    p_asset_id        IN  NUMBER,
                    p_book_type_code  IN  VARCHAR2,
                    p_chr_id          IN  NUMBER,
                    p_release_date    IN  DATE,
                    x_nbv             OUT NOCOPY Number) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'GET_NBV';
    l_api_version	    CONSTANT NUMBER	:= 1.0;

    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

    l_nbv                      NUMBER;
    l_converted_amount         NUMBER;
    l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
    l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
    l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

  BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_asset_hdr_rec.asset_id          := p_asset_id;
     l_asset_hdr_rec.book_type_code    := p_book_type_code;

     if NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Asset Current Cost
     if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => 'P'
              ) then

       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_ASSET_FIN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Depreciation Reserve
     if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => 'P'
                 ) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     l_nbv := l_asset_fin_rec.cost - l_asset_deprn_rec.deprn_reserve;

     l_converted_amount := 0;
     OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
        p_khr_id                   => p_chr_id,
        p_from_currency            => NULL,
        p_transaction_date         => p_release_date,
        p_amount                   => l_nbv,
        x_return_status            => x_return_status,
        x_contract_currency        => l_contract_currency,
        x_currency_conversion_type => l_currency_conversion_type,
        x_currency_conversion_rate => l_currency_conversion_rate,
        x_currency_conversion_date => l_currency_conversion_date,
        x_converted_amount         => l_converted_amount);

      IF(x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                            p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_nbv := l_converted_amount;

     --Call end Activity
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR Then
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS
    (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
    );
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS
    (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_UNEXP_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
    );
  WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS
    (
      l_api_name,
      G_PKG_NAME,
      'OTHERS',
      x_msg_count,
      x_msg_data,
      '_PVT'
    );
  END get_nbv;

-------------
--Bug# 4631549
--------------
   -----------------------------------------------------------------------------------------------
-- Start of Comments
-- avsingh
-- Procedure Name       : Calculate_Expected_Cost
-- Description          : Calculate Expected Asset Cost based on the same formula used by offlease
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
 PROCEDURE Calculate_expected_cost
            (p_api_version    IN  NUMBER,
             p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER,
             x_msg_data       OUT NOCOPY VARCHAR2,
             p_new_chr_id     IN  NUMBER,
             p_orig_chr_id    IN  NUMBER,
             p_orig_cle_id    IN  NUMBER,
             p_asset_id       IN  NUMBER,
             p_book_type_code IN  VARCHAR2,
             p_nbv            IN  NUMBER,
             p_release_date   IN  DATE,
             x_expected_cost  OUT NOCOPY NUMBER) IS

  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'CALCULATE EXPECTED COST';
  l_api_version          CONSTANT NUMBER := 1.0;


  --cursor to fetch deal type and taxowner
  Cursor l_book_class_csr (p_chr_id IN NUMBER) is
  select khr.deal_type          deal_type,
         rulb.rule_information1 tax_owner
  from   okl_k_headers khr,
         okc_rules_b   rulb
  where  rulb.dnz_chr_id                = p_chr_id
  and    rulb.rule_information_category = 'LATOWN'
  and    khr.id                         = p_chr_id;

  l_book_class_rec  l_book_class_csr%ROWTYPE;
  l_additional_parameters okl_execute_formula_pub.ctxt_val_tbl_type;
  l_expected_cost   NUMBER;

  l_converted_amount         NUMBER;
  l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
  l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
  l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
  l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      Open l_book_class_csr(p_chr_id => p_orig_chr_id);
      fetch l_book_class_csr into l_book_class_rec;
      Close l_book_class_csr;

      IF l_book_class_rec.deal_type = 'LEASEOP' then

          IF nvl(p_nbv,0) = 0 Then
              -- Fetch NBV for Corporate Book
              l_expected_cost := 0;
              get_nbv(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_asset_id        => p_asset_id,
                      p_book_type_code  => p_book_type_code,
                      p_chr_id          => p_new_chr_id,
                      p_release_date    => p_release_date,
                      x_nbv             => l_expected_cost);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;


          ElsIf nvl(p_nbv,0) <> 0 then
              l_expected_cost := p_nbv;
          END IF;

     ELSIF l_book_class_rec.deal_type in ('LEASEDF','LEASEST') then

          l_additional_parameters(1).name  := 'quote_effective_from_date';
          l_additional_parameters(1).value := to_char(p_release_date - 1,'MM/DD/YYYY');

          okl_execute_formula_pub.execute (
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                --bug# 4631549
                p_formula_name  => 'LINE_EXPECTED_ASSET_COST',
                --p_formula_name  => 'LINE_ASSET_NET_INVESTMENT',
                p_contract_id   => p_orig_chr_id,
                p_line_id       => p_orig_cle_id,
                p_additional_parameters => l_additional_parameters,
                x_value         => l_expected_cost);

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_converted_amount := 0;
          OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
                              p_khr_id                   => p_new_chr_id,
                              p_from_currency            => NULL,
                              p_transaction_date         => p_release_date,
                              p_amount                   => l_expected_cost,
                              x_return_status            => x_return_status,
                              x_contract_currency        => l_contract_currency,
                              x_currency_conversion_type => l_currency_conversion_type,
                              x_currency_conversion_rate => l_currency_conversion_rate,
                              x_currency_conversion_date => l_currency_conversion_date,
                              x_converted_amount         => l_converted_amount);

          IF(x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
              Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                                  p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
          l_expected_cost := l_converted_Amount;
      END IF;
      END IF;
      x_expected_cost := l_expected_cost;

      --Call end Activity
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR Then
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS
    (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
    );
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS
    (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_UNEXP_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
    );
  WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS
    (
      l_api_name,
      G_PKG_NAME,
      'OTHERS',
      x_msg_count,
      x_msg_data,
      '_PVT'
    );
  END Calculate_expected_cost;
   -----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Adjust_Asset_Lines
-- Description          : Adjust Asset lines on the Re-lease contract
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE adjust_asset_lines(p_api_version   IN  NUMBER,
                               p_init_msg_list IN  VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_chr_id        IN  NUMBER,
                               p_release_date  IN  DATE) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'ADJUST_ASSET_LINES';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR contract_fin_asset_csr
           (p_chr_id       IN NUMBER) IS
    SELECT cle.id,
           cle.start_date,
           sts.ste_code,
           cle.orig_system_id1
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse,
         okc_statuses_b sts
    WHERE cle.dnz_chr_id = p_chr_id
    AND  cle.chr_id =  p_chr_id
    AND  cle.lse_id = lse.id
    AND  lse.lty_code = 'FREE_FORM1'
    AND  cle.sts_code = sts.code;

    CURSOR orig_cle_sts_csr(p_cle_id IN NUMBER)
    IS
    SELECT sts.ste_code,
           --Bug# 4670760
           cle.dnz_chr_id
    FROM   okc_k_lines_b cle,
           okc_statuses_b sts
    WHERE  cle.id = p_cle_id
    AND    cle.sts_code = sts.code;

    orig_cle_sts_rec orig_cle_sts_csr%ROWTYPE;

    CURSOR cle_csr(p_cle_id IN NUMBER) IS
    SELECT id,
           dnz_chr_id,
           chr_id,
           cle_id,
           lse_id,
           start_date
    FROM okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_cle_id;

    CURSOR lse_csr(p_lse_id IN NUMBER) IS
    SELECT lty_code
    FROM okc_line_styles_b
    WHERE id = p_lse_id;

    lse_rec            lse_csr%ROWTYPE;

    CURSOR asset_number_csr(p_cle_id IN NUMBER) IS
    SELECT name  asset_number
    FROM okc_k_lines_v
    WHERE id = p_cle_id;

    asset_number_rec asset_number_csr%ROWTYPE;

    CURSOR fa_asset_csr(p_asset_number   IN VARCHAR2)
    IS
    SELECT fab.asset_id,
           fab.book_type_code
    FROM   fa_additions fad,
           fa_book_controls fbc,
           fa_books fab
    WHERE  fad.asset_number = p_asset_number
    AND    fab.asset_id = fad.asset_id
    AND    fab.book_type_code = fbc.book_type_code
    AND    fab.transaction_header_id_out IS NULL
    AND    fbc.book_class = 'CORPORATE';

    fa_asset_rec       fa_asset_csr%ROWTYPE;

    CURSOR txl_asset_csr (p_chr_id IN NUMBER,
                          p_cle_id IN NUMBER) IS
    SELECT txlb.depreciation_cost,
           txlb.current_units,
           txlb.salvage_value,
           txlb.percent_salvage_value,
           txlb.id
    FROM   okl_txl_assets_b  txlb,
           okl_trx_assets    trx,
           okc_k_lines_b     fa_cleb,
           okc_line_styles_b fa_lseb
    WHERE  txlb.kle_id        = fa_cleb.id
    AND    txlb.tal_type      = 'CRL'
    AND    trx.id             = txlb.tas_id
    AND    trx.tsu_code       <> 'PROCESSED'
    AND    trx.tas_type       = 'CRL'
    AND    fa_cleb.cle_id     = p_cle_id
    AND    fa_cleb.dnz_chr_id = p_chr_id
    AND    fa_cleb.lse_id     = fa_lseb.id
    AND    fa_lseb.lty_code   = 'FIXED_ASSET';

    txl_asset_rec      txl_asset_csr%ROWTYPE;

    CURSOR modelline_csr(p_chr_id       IN NUMBER,
                         p_model_cle_id IN NUMBER) IS
    SELECT model_cim.id      model_cim_id
    FROM   okc_k_items       model_cim
    WHERE  model_cim.cle_id       = p_model_cle_id
    AND    model_cim.dnz_chr_id   = p_chr_id;

    modelline_rec      modelline_csr%ROWTYPE;

    CURSOR txd_asset_csr(p_tal_id in number) is
    SELECT txdb.tax_book,
           txdb.id
    FROM   okl_txd_assets_b txdb
    WHERE  txdb.tal_id      = p_tal_id;

    l_corp_net_book_value   NUMBER;
    l_tax_net_book_value    NUMBER;

    l_talv_rec         okl_txl_assets_pub.tlpv_rec_type;
    lx_talv_rec        okl_txl_assets_pub.tlpv_rec_type;
    l_txdv_rec         okl_txd_assets_pub.adpv_rec_type;
    lx_txdv_rec        okl_txd_assets_pub.adpv_rec_type;

    lp_cimv_rec        okl_okc_migration_pvt.cimv_rec_type;
    lx_cimv_rec        okl_okc_migration_pvt.cimv_rec_type;

    lp_klev_rec        okl_kle_pvt.klev_rec_type;
    lp_clev_rec        okl_okc_migration_pvt.clev_rec_type;

    lx_klev_rec        okl_kle_pvt.klev_rec_type;
    lx_clev_rec        okl_okc_migration_pvt.clev_rec_type;

    lp_cimv_temp_rec   okl_okc_migration_pvt.cimv_rec_type;
    lp_klev_temp_rec   okl_kle_pvt.klev_rec_type;
    lp_clev_temp_rec   okl_okc_migration_pvt.clev_rec_type;

    --Bug# 3950089
    CURSOR curr_hdr_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

    --bug# 4670760
    l_orig_chr_id   NUMBER;
    l_orig_cle_id   NUMBER;
    l_expected_cost NUMBER;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 3950089
    l_currency_code := '?';
    open curr_hdr_csr (p_chr_id);
    fetch curr_hdr_csr into l_currency_code;
    close curr_hdr_csr;

    if (l_currency_code = '?') then

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Currency Code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Fetch Financial Asset Top line
    for contract_fin_asset_rec in contract_fin_asset_csr
                                 (p_chr_id => p_chr_id) loop

      -- Fetch Status of the Line in original contract
      open orig_cle_sts_csr(p_cle_id => contract_fin_asset_rec.orig_system_id1);
      fetch orig_cle_sts_csr into orig_cle_sts_rec;
      close orig_cle_sts_csr;

      if (contract_fin_asset_rec.ste_code IN ('TERMINATED', 'EXPIRED', 'CANCELLED'))
         or ( orig_cle_sts_rec.ste_code IN ('TERMINATED', 'EXPIRED', 'CANCELLED')) then

        -- Delete Lines which are not Active
        OKL_CONTRACT_PUB.delete_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_line_id       => contract_fin_asset_rec.id
         );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      else

        open asset_number_csr(p_cle_id => contract_fin_asset_rec.id);
        fetch asset_number_csr into asset_number_rec;
        close asset_number_csr;

        open fa_asset_csr(p_asset_number => asset_number_rec.asset_number);
        fetch fa_asset_csr into fa_asset_rec;
        close fa_asset_csr;

        -- Fetch NBV for Corporate Book
        l_corp_net_book_value := 0;
        get_nbv(p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
	        x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_asset_id        => fa_asset_rec.asset_id,
                p_book_type_code  => fa_asset_rec.book_type_code,
                p_chr_id          => p_chr_id,
                p_release_date    => p_release_date,
                x_nbv             => l_corp_net_book_value);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 4670760
        --Get expected asset Cost
        l_orig_chr_id := orig_cle_sts_rec.dnz_chr_id;
        l_orig_cle_id := contract_fin_Asset_rec.orig_system_id1;

        -- Calculate  Expected asset cost (cost of the asset expected after re-lease)
        Calculate_Expected_Cost(p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_new_chr_id     => p_chr_id,
                                p_orig_chr_id    => l_orig_chr_id,
                                p_orig_cle_id    => l_orig_cle_id,
                                p_asset_id       => fa_asset_rec.asset_id,
                                p_book_type_code => fa_asset_rec.book_type_code,
                                p_release_date   => p_release_date,
                                p_nbv            => l_corp_net_book_value,
                                x_expected_cost  => l_expected_cost);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        --End Bug# 4670760

        open txl_asset_csr(p_chr_id => p_chr_id
                          ,p_cle_id => contract_fin_asset_rec.id);
        fetch txl_asset_csr into txl_asset_rec;
        close txl_asset_csr;

        if l_corp_net_book_value IS NOT NULL then

          --Update Okl_Txl_Assets for Depreciation cost and
          --Original cost
          l_talv_rec.id                    := txl_asset_rec.id;
          l_talv_rec.depreciation_cost     := l_corp_net_book_value;
          l_talv_rec.original_cost         := l_corp_net_book_value;

          OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => l_talv_rec,
                       x_tlpv_rec       => lx_talv_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        end if;

        for txd_asset_rec in txd_asset_csr(p_tal_id => txl_asset_rec.id) loop

          -- Fetch NBV for Tax Book
          l_tax_net_book_value := 0;
          get_nbv(p_api_version     => p_api_version,
                  p_init_msg_list   => p_init_msg_list,
	            x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_asset_id        => fa_asset_rec.asset_id,
                  p_book_type_code  => txd_asset_rec.tax_book,
                  p_chr_id          => p_chr_id,
                  p_release_date    => p_release_date,
                  x_nbv             => l_tax_net_book_value);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          if l_tax_net_book_value IS NOT NULL then

            --Update Okl_Txd_Assets for Cost
            l_txdv_rec.id       := txd_asset_rec.id;
            l_txdv_rec.cost     := l_tax_net_book_value;

            OKL_TXD_ASSETS_PUB.UPDATE_TXD_ASSET_DEF
              (p_api_version    =>  p_api_version,
               p_init_msg_list  =>  p_init_msg_list,
               x_return_status  =>  x_return_status,
               x_msg_count      =>  x_msg_count,
               x_msg_data       =>  x_msg_data,
               p_adpv_rec       =>  l_txdv_rec,
               x_adpv_rec       =>  lx_txdv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          end if;
        end loop;

        -- Loop through Financial asset line and all its children
        -- for making updates
        for cle_rec in cle_csr(p_cle_id => contract_fin_asset_rec.id) loop

          lp_clev_rec := lp_clev_temp_rec;
          lp_klev_rec := lp_klev_temp_rec;
          lp_cimv_rec := lp_cimv_temp_rec;

          open lse_csr(p_lse_id => cle_rec.lse_id);
          fetch lse_csr into lse_rec;
          close lse_csr;

          -- Subsidy Line
          if lse_rec.lty_code = 'SUBSIDY' then

            -- Delete Subsidy Lines
            OKL_CONTRACT_PUB.delete_contract_line(
              p_api_version   => p_api_version,
              p_init_msg_list => p_init_msg_list,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_line_id       => cle_rec.id
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          -- Financial Asset line
          elsif lse_rec.lty_code = 'FREE_FORM1' then

            --Update Financial asset line for OEC and Residual value
            lp_clev_rec.id                  := cle_rec.id;

            if cle_rec.start_date < p_release_date then
              lp_clev_rec.start_date        := p_release_date;
            end if;

            lp_klev_rec.id                  := cle_rec.id;
            -- l_clev_rec.price_unit          := OKL_API.G_MISS_NUM;
            --Bug# 4631549: Take residual percent and residual value from the previous contract
            --lp_klev_rec.residual_percentage := txl_asset_rec.percent_salvage_value;
            --lp_klev_rec.residual_value      := txl_asset_rec.salvage_value;
            lp_klev_rec.oec                 := NVL(l_corp_net_book_value,0);

            --Bug# 4631549: Not required to sync residual value and percent as they
            --              are now getting copied from previous contract
            /*
            --Bug# 3950089: Sync Residual value and percent
            if (lp_klev_rec.residual_value IS NOT NULL) then

              if (lp_klev_rec.residual_value = 0 or lp_klev_rec.oec = 0) then
                lp_klev_rec.residual_percentage := 0;
              else
                lp_klev_rec.residual_percentage := ROUND(lp_klev_rec.residual_value * 100/lp_klev_rec.oec,2);
              end if;

            elsif (lp_klev_rec.residual_percentage IS NOT NULL) then
              lp_klev_rec.residual_value :=  (lp_klev_rec.residual_percentage/100 * lp_klev_rec.oec);

              lp_klev_rec.residual_value :=
                        OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                          (p_amount        => lp_klev_rec.residual_value,
                           p_currency_code => l_currency_code);
            end if;
            */

            --Bug# 4631549 : Update Expected asset cost (cost of the asset expected after re-lease)
            lp_klev_rec.expected_asset_cost := l_expected_cost;

            --Added by bkatraga for bug 9369915
            --Remove trade-in and Downpayment info at asset level
            lp_klev_rec.tradein_amount := null;
            lp_klev_rec.capital_reduction := null;
            lp_klev_rec.capital_reduction_percent := null;
            lp_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN := null;
            lp_klev_rec.DOWN_PAYMENT_RECEIVER_CODE := null;
            --end bkatraga

            OKL_CONTRACT_PUB.update_contract_line
              (p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_clev_rec       => lp_clev_rec,
               p_klev_rec       => lp_klev_rec,
               x_clev_rec       => lx_clev_rec,
               x_klev_rec       => lx_klev_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
            --End Bug# 4631549

          -- Model line
          elsif lse_rec.lty_code = 'ITEM' then

            --Update Model line for Unit Price and No. of items
            lp_clev_rec.id                 := cle_rec.id;

            if cle_rec.start_date < p_release_date then
              lp_clev_rec.start_date       := p_release_date;
            end if;

            lp_klev_rec.id                 := cle_rec.id;

            if l_corp_net_book_value IS NULL then
              lp_clev_rec.price_unit  :=
                (txl_asset_rec.depreciation_cost/txl_asset_rec.current_units);
            elsif l_corp_net_book_value IS NOT NULL then
              lp_clev_rec.price_unit  := (l_corp_net_book_value/txl_asset_rec.current_units);
            end if;

            open modelline_csr(p_chr_id => p_chr_id
                              ,p_model_cle_id => cle_rec.id);
            fetch modelline_csr into modelline_rec;
            close modelline_csr;

            lp_cimv_rec.id                 := modelline_rec.model_cim_id;
            lp_cimv_rec.number_of_items    := txl_asset_rec.current_units;

            OKL_CONTRACT_PUB.update_contract_line
              (p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_clev_rec       => lp_clev_rec,
               p_klev_rec       => lp_klev_rec,
               x_clev_rec       => lx_clev_rec,
               x_klev_rec       => lx_klev_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

            OKL_OKC_MIGRATION_PVT.update_contract_item
              (p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_cimv_rec       => lp_cimv_rec,
               x_cimv_rec       => lx_cimv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

          -- For all other lines update Start Date to Re-lease date
          else

            lp_clev_rec.id         := cle_rec.id;

            if cle_rec.start_date < p_release_date then
              lp_clev_rec.start_date := p_release_date;
            end if;

            -- Set Line Start Date equal to Release Date
            OKL_CONTRACT_PUB.update_contract_line(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_clev_rec            => lp_clev_rec,
              p_klev_rec            => lp_klev_rec,
              x_clev_rec            => lx_clev_rec,
              x_klev_rec            => lx_klev_rec
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          end if;
        end loop;

      end if;
    end loop;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END adjust_asset_lines;

-----------------------------------------------------------------------------------------------
-- Start of Comments
-- Rekha Pillay
-- Procedure Name       : Update_Taa_Request_Info
-- Description          : Update the Re-lease contract with contract related
--                        information entered in the Transfer and Assumption
--                        Request
-- Business Rules       :
--
--
--
--
--
--
--
-- Parameters           :
-- Version              : 1.0
-- End of Commments
  PROCEDURE update_taa_request_info(p_api_version   IN  NUMBER,
                                    p_init_msg_list IN  VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_chr_id        IN  NUMBER,
                                    p_taa_trx_id    IN  NUMBER,
                                    p_org_id        IN  NUMBER) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_TAA_REQUEST_INFO';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    CURSOR taa_party_info_csr(p_taa_trx_id IN NUMBER) IS
    SELECT party_rel_id2_new
    FROM okl_trx_contracts
    WHERE id = p_taa_trx_id;

    taa_party_info_rec taa_party_info_csr%ROWTYPE;

    CURSOR taa_chr_hdr_dtl_csr(p_taa_trx_id IN NUMBER) IS
    SELECT bill_to_site_id,
           cust_acct_id,
           bank_acct_id,
           invoice_format_id,
           payment_mthd_id,
           mla_id,
           credit_line_id,
           --Bug# 4191851
           insurance_yn,
           lease_policy_yn,
           ipy_type,
           policy_number,
           covered_amt,
           deductible_amt,
           effective_to_date,
           effective_from_date,
           proof_provided_date,
           proof_required_date,
           lessor_insured_yn,
           lessor_payee_yn,
           int_id,
           isu_id,
           agency_site_id,
           agent_site_id,
           territory_code
    FROM okl_taa_request_details_b
    WHERE tcn_id = p_taa_trx_id;

    taa_chr_hdr_dtl_rec taa_chr_hdr_dtl_csr%ROWTYPE;

    CURSOR party_role_csr(p_chr_id IN NUMBER) IS
    SELECT id
    FROM okc_k_party_roles_b
    WHERE chr_id = p_chr_id
    AND rle_code = 'LESSEE';

    party_role_rec     party_role_csr%ROWTYPE;
    lp_cplv_rec        okl_okc_migration_pvt.cplv_rec_type;
    lx_cplv_rec        okl_okc_migration_pvt.cplv_rec_type;

    l_chrv_rec         okl_okc_migration_pvt.chrv_rec_type;
    lx_chrv_rec        okl_okc_migration_pvt.chrv_rec_type;

    CURSOR hdr_rules_csr(p_chr_id   IN NUMBER,
                         p_rgd_code IN VARCHAR2,
                         p_rul_cat  IN VARCHAR2) IS
    select rul.id rul_id,
           rgp.id rgp_id
    from okc_rule_groups_b rgp,
         okc_rules_b rul
    where rgp.id = rul.rgp_id
    and rgp.rgd_code = p_rgd_code
    and rul.rule_information_category = p_rul_cat
    and rgp.dnz_chr_id = p_chr_id
    and rgp.chr_id = p_chr_id
    and rul.dnz_chr_id = p_chr_id;

    hdr_rules_rec    hdr_rules_csr%ROWTYPE;
    lp_rulv_rec      Okl_Rule_Pub.rulv_rec_type;
    lx_rulv_rec      Okl_Rule_Pub.rulv_rec_type;
    lp_rulv_temp_rec Okl_Rule_Pub.rulv_rec_type;

    --sechawla 26-may-09 6826580
   /* CURSOR invoice_format_csr(p_invoice_format_id IN NUMBER) IS
    SELECT name
    FROM okl_invoice_formats_v
    WHERE ID = p_invoice_format_id;

    invoice_format_rec invoice_format_csr%ROWTYPE;
*/

    CURSOR governance_csr(p_chr_id   IN NUMBER,
                          p_scs_code IN VARCHAR2) IS
    SELECT id
    FROM okc_governances gve
    WHERE chr_id = p_chr_id
    AND dnz_chr_id = p_chr_id
    AND EXISTS (SELECT 1
                FROM okc_k_headers_b chr
                WHERE chr.id = gve.chr_id_referred
                AND   chr.scs_code = p_scs_code);

   governance_rec     governance_csr%ROWTYPE;
   lp_gvev_rec        okl_okc_migration_pvt.gvev_rec_type;
   lx_gvev_rec        okl_okc_migration_pvt.gvev_rec_type;
   lp_gvev_temp_rec   okl_okc_migration_pvt.gvev_rec_type;

   CURSOR taa_lines_csr(p_chr_id     IN NUMBER,
                        p_taa_trx_id IN NUMBER) IS
   SELECT cle.id,
          tcl.source_column_1,
          tcl.source_value_1,
          tcl.source_column_2,
          tcl.source_value_2,
          tcl.source_column_3,
          tcl.source_value_3
   FROM okc_k_lines_b cle,
        okc_line_styles_b lse,
        okl_txl_cntrct_lns tcl
   WHERE cle.chr_id = p_chr_id
   AND cle.dnz_chr_id = p_chr_id
   AND lse.lty_code = 'FREE_FORM1'
   AND cle.lse_id = lse.id
   AND tcl.tcn_id = p_taa_trx_id
   AND tcl.kle_id = cle.orig_system_id1
   AND tcl.before_transfer_yn = 'N';

   lp_klev_rec  okl_kle_pvt.klev_rec_type;
   lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;

   lx_klev_rec  okl_kle_pvt.klev_rec_type;
   lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

   CURSOR txl_asset_csr(p_chr_id IN NUMBER,
                        p_cle_id IN NUMBER) IS
   SELECT txlb.id
   FROM   okl_txl_assets_b  txlb,
          okl_trx_assets    trx,
          okc_k_lines_b     fa_cleb,
          okc_line_styles_b fa_lseb
   WHERE  txlb.kle_id        = fa_cleb.id
   AND    txlb.tal_type      = 'CRL'
   AND    trx.id             = txlb.tas_id
   AND    trx.tsu_code       <> 'PROCESSED'
   AND    trx.tas_type       = 'CRL'
   AND    fa_cleb.cle_id     = p_cle_id
   AND    fa_cleb.dnz_chr_id = p_chr_id
   AND    fa_cleb.lse_id     = fa_lseb.id
   AND    fa_lseb.lty_code   = 'FIXED_ASSET';

   txl_asset_rec txl_asset_csr%ROWTYPE;

   l_talv_rec         okl_txl_assets_pub.tlpv_rec_type;
   lx_talv_rec        okl_txl_assets_pub.tlpv_rec_type;

   CURSOR txl_ib_csr (p_chr_id IN NUMBER,
                      p_cle_id IN NUMBER) is
   SELECT iti.id,
          iti.object_id1_new,
          iti.object_id2_new,
          iti.jtot_object_code_new
   FROM   okl_trx_assets    trx,
          okl_txl_itm_insts iti,
          okc_k_lines_b     cleb_ib,
          okc_line_styles_b lseb_ib,
          okc_k_lines_b     cleb_inst,
          okc_line_styles_b lseb_inst
   WHERE  trx.id               = iti.tas_id
   AND    trx.tsu_code         <> 'PROCESSED'
   AND    trx.tas_type         = 'CRL'
   AND    iti.kle_id           = cleb_ib.id
   AND    iti.tal_type         = 'CRL'
   AND    cleb_ib.cle_id       = cleb_inst.id
   AND    cleb_ib.dnz_chr_id   = cleb_inst.dnz_chr_id
   AND    cleb_ib.lse_id       = lseb_ib.id
   AND    lseb_ib.lty_code     = 'INST_ITEM'
   AND    cleb_inst.cle_id     = p_cle_id
   AND    cleb_inst.dnz_chr_id = p_chr_id
   AND    cleb_inst.lse_id     = lseb_inst.id
   AND    lseb_inst.lty_code   = 'FREE_FORM2';

   l_itiv_ib_tbl  OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
   lx_itiv_ib_tbl OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
   i NUMBER;

   --Bug# 4191851
   l_ipyv_rec     OKL_IPY_PVT.ipyv_rec_type;
   lx_ipyv_rec    OKL_IPY_PVT.ipyv_rec_type;

   --Bug# 4558486
   lp_kplv_rec      OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
   lx_kplv_rec      OKL_K_PARTY_ROLES_PVT.kplv_rec_type;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => '_PVT',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN taa_party_info_csr(p_taa_trx_id => p_taa_trx_id);
    FETCH taa_party_info_csr INTO taa_party_info_rec;
    CLOSE taa_party_info_csr;

    OPEN taa_chr_hdr_dtl_csr(p_taa_trx_id => p_taa_trx_id);
    FETCH taa_chr_hdr_dtl_csr INTO taa_chr_hdr_dtl_rec;
    CLOSE taa_chr_hdr_dtl_csr;

    -- Update Lessee
    IF (taa_party_info_rec.party_rel_id2_new IS NOT NULL) THEN

      party_role_rec.id := NULL;
      OPEN party_role_csr(p_chr_id => p_chr_id);
      FETCH party_role_csr INTO party_role_rec;
      CLOSE party_role_csr;

      IF (party_role_rec.id IS NOT NULL) THEN

        lp_cplv_rec.id := party_role_rec.id;
        lp_cplv_rec.object1_id1 := taa_party_info_rec.party_rel_id2_new;
        lp_cplv_rec.object1_id2 := '#';

        --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
        --              to update records in tables
        --              okc_k_party_roles_b and okl_k_party_roles
        /*
        OKL_OKC_MIGRATION_PVT.update_k_party_role
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_cplv_rec       => lp_cplv_rec,
           x_cplv_rec       => lx_cplv_rec);
        */

        lp_kplv_rec.id := lp_cplv_rec.id;
        OKL_K_PARTY_ROLES_PVT.update_k_party_role
          (p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_cplv_rec      => lp_cplv_rec,
           x_cplv_rec      => lx_cplv_rec,
           p_kplv_rec      => lp_kplv_rec,
           x_kplv_rec      => lx_kplv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;

    -- Update Customer Account and Header level Bill-To-Site
    IF (taa_chr_hdr_dtl_rec.cust_acct_id IS NOT NULL) THEN

      l_chrv_rec.id := p_chr_id;
      l_chrv_rec.cust_acct_id := taa_chr_hdr_dtl_rec.cust_acct_id;

      IF (taa_chr_hdr_dtl_rec.bill_to_site_id IS NOT NULL) THEN
        l_chrv_rec.bill_to_site_use_id := taa_chr_hdr_dtl_rec.bill_to_site_id;
      END IF;

      OKL_OKC_MIGRATION_PVT.update_contract_header(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_restricted_update  => OKL_API.G_FALSE,
        p_chrv_rec           => l_chrv_rec,
        x_chrv_rec           => lx_chrv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Update Header level Bank Account
    lp_rulv_rec := lp_rulv_temp_rec;
    IF (taa_chr_hdr_dtl_rec.bank_acct_id IS NOT NULL) THEN

      hdr_rules_rec.rul_id := NULL;
      hdr_rules_rec.rgp_id := NULL;
      OPEN hdr_rules_csr(p_chr_id   => p_chr_id,
                         p_rgd_code => 'LABILL',
                         p_rul_cat  => 'LABACC');
      FETCH hdr_rules_csr INTO hdr_rules_rec;
      CLOSE hdr_rules_csr;

      IF (hdr_rules_rec.rul_id IS NOT NULL) THEN
        lp_rulv_rec.id := hdr_rules_rec.rul_id;
        lp_rulv_rec.rgp_id := hdr_rules_rec.rgp_id;
        lp_rulv_rec.rule_information_category := 'LABACC';
        lp_rulv_rec.dnz_chr_id := p_chr_id;
        lp_rulv_rec.object1_id1 := taa_chr_hdr_dtl_rec.bank_acct_id;
        lp_rulv_rec.object1_id2 := '#';
        lp_rulv_rec.jtot_object1_code := 'OKX_CUSTBKAC';
        lp_rulv_rec.warn_yn := 'N';
        lp_rulv_rec.std_template_yn := 'N';

        OKL_RULE_PUB.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;

    -- Update Header level Payment Method
    lp_rulv_rec := lp_rulv_temp_rec;
    IF (taa_chr_hdr_dtl_rec.payment_mthd_id IS NOT NULL) THEN

      hdr_rules_rec.rul_id := NULL;
      hdr_rules_rec.rgp_id := NULL;
      OPEN hdr_rules_csr(p_chr_id   => p_chr_id,
                         p_rgd_code => 'LABILL',
                         p_rul_cat  => 'LAPMTH');
      FETCH hdr_rules_csr INTO hdr_rules_rec;
      CLOSE hdr_rules_csr;

      IF (hdr_rules_rec.rul_id IS NOT NULL) THEN
        lp_rulv_rec.id := hdr_rules_rec.rul_id;
        lp_rulv_rec.rgp_id := hdr_rules_rec.rgp_id;
        lp_rulv_rec.rule_information_category := 'LAPMTH';
        lp_rulv_rec.dnz_chr_id := p_chr_id;
        lp_rulv_rec.object1_id1 := taa_chr_hdr_dtl_rec.payment_mthd_id;
        lp_rulv_rec.object1_id2 := '#';
        lp_rulv_rec.jtot_object1_code := 'OKX_RCPTMTH';
        lp_rulv_rec.warn_yn := 'N';
        lp_rulv_rec.std_template_yn := 'N';

        OKL_RULE_PUB.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;

    -- Update Header level Invoice Format
    lp_rulv_rec := lp_rulv_temp_rec;
    IF (taa_chr_hdr_dtl_rec.invoice_format_id IS NOT NULL) THEN

      hdr_rules_rec.rul_id := NULL;
      hdr_rules_rec.rgp_id := NULL;
      OPEN hdr_rules_csr(p_chr_id   => p_chr_id,
                         p_rgd_code => 'LABILL',
                         p_rul_cat  => 'LAINVD');
      FETCH hdr_rules_csr INTO hdr_rules_rec;
      CLOSE hdr_rules_csr;

      IF (hdr_rules_rec.rul_id IS NOT NULL) THEN

        --sechawla 26-may-09 6826580
        /*OPEN invoice_format_csr
               (p_invoice_format_id => taa_chr_hdr_dtl_rec.invoice_format_id);
        FETCH invoice_format_csr INTO invoice_format_rec;
        CLOSE invoice_format_csr;
       */
        lp_rulv_rec.id := hdr_rules_rec.rul_id;
        lp_rulv_rec.rgp_id := hdr_rules_rec.rgp_id;
        lp_rulv_rec.rule_information_category := 'LAINVD';
        lp_rulv_rec.dnz_chr_id := p_chr_id;

		--sechawla 26-may-09 6826580 ; store ID instead of name
        lp_rulv_rec.rule_information1 := to_char(taa_chr_hdr_dtl_rec.invoice_format_id); -- invoice_format_rec.name;

        lp_rulv_rec.warn_yn := 'N';
        lp_rulv_rec.std_template_yn := 'N';

        OKL_RULE_PUB.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;

    -- Update Master Lease Agreement
    lp_gvev_rec := lp_gvev_temp_rec;
    IF (taa_chr_hdr_dtl_rec.mla_id IS NOT NULL) THEN

      governance_rec.id := NULL;
      OPEN governance_csr(p_chr_id   => p_chr_id,
                          p_scs_code => 'MASTER_LEASE');
      FETCH governance_csr INTO governance_rec;
      CLOSE governance_csr;

      lp_gvev_rec.chr_id := p_chr_id;
      lp_gvev_rec.dnz_chr_id := p_chr_id;
      lp_gvev_rec.chr_id_referred := taa_chr_hdr_dtl_rec.mla_id;
      lp_gvev_rec.copied_only_yn := 'N';

      IF (governance_rec.id IS NULL) THEN
        lp_gvev_rec.id := NULL;

        OKL_OKC_MIGRATION_PVT.create_governance
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_gvev_rec       => lp_gvev_rec,
           x_gvev_rec       => lx_gvev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

      ELSE

        lp_gvev_rec.id := governance_rec.id;

        OKL_OKC_MIGRATION_PVT.update_governance
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_gvev_rec       => lp_gvev_rec,
           x_gvev_rec       => lx_gvev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

      END IF;
    END IF;

    -- Update Credit Line
    lp_gvev_rec := lp_gvev_temp_rec;
    IF (taa_chr_hdr_dtl_rec.credit_line_id IS NOT NULL) THEN

      governance_rec.id := NULL;
      OPEN governance_csr(p_chr_id   => p_chr_id,
                          p_scs_code => 'CREDITLINE_CONTRACT');
      FETCH governance_csr INTO governance_rec;
      CLOSE governance_csr;

      lp_gvev_rec.chr_id := p_chr_id;
      lp_gvev_rec.dnz_chr_id := p_chr_id;
      lp_gvev_rec.chr_id_referred := taa_chr_hdr_dtl_rec.credit_line_id;
      lp_gvev_rec.copied_only_yn := 'N';

      IF (governance_rec.id IS NULL) THEN
        lp_gvev_rec.id := NULL;

        OKL_OKC_MIGRATION_PVT.create_governance
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_gvev_rec       => lp_gvev_rec,
           x_gvev_rec       => lx_gvev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

      ELSE

        lp_gvev_rec.id := governance_rec.id;

        OKL_OKC_MIGRATION_PVT.update_governance
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_gvev_rec       => lp_gvev_rec,
           x_gvev_rec       => lx_gvev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

      END IF;
    END IF;

    -- Update Asset Line Details
    FOR taa_lines_rec IN taa_lines_csr(p_chr_id     => p_chr_id,
                                       p_taa_trx_id => p_taa_trx_id)
    LOOP

      -- Asset Line level Install At Location
      IF (taa_lines_rec.source_column_1 = 'INSTALL_SITE_ID'
         AND taa_lines_rec.source_value_1 IS NOT NULL) THEN

        i := 0;
        l_itiv_ib_tbl.DELETE;
        FOR txl_ib_rec IN txl_ib_csr(p_chr_id => p_chr_id,
                                     p_cle_id => taa_lines_rec.id)
        LOOP

          i := i + 1;
          l_itiv_ib_tbl(i).id                   := txl_ib_rec.id;
          l_itiv_ib_tbl(i).object_id1_old       := txl_ib_rec.object_id1_new;
          l_itiv_ib_tbl(i).object_id2_old       := txl_ib_rec.object_id2_new;
          l_itiv_ib_tbl(i).jtot_object_code_old := txl_ib_rec.jtot_object_code_new;

          l_itiv_ib_tbl(i).object_id1_new  := taa_lines_rec.source_value_1;
          l_itiv_ib_tbl(i).object_id2_new  := '#';

        END LOOP;

        IF (i > 0) THEN

          OKL_TXL_ITM_INSTS_PUB.update_txl_itm_insts
            (p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_iipv_tbl       => l_itiv_ib_tbl,
             x_iipv_tbl       => lx_itiv_ib_tbl);

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

      -- Asset Line level Fixed asset location
      IF (taa_lines_rec.source_column_2 = 'FA_LOC_ID'
         AND taa_lines_rec.source_value_2 IS NOT NULL) THEN

        OPEN txl_asset_csr(p_chr_id => p_chr_id,
                           p_cle_id => taa_lines_rec.id);
        FETCH txl_asset_csr INTO txl_asset_rec;
        CLOSE txl_asset_csr;

        l_talv_rec.id              := txl_asset_rec.id;
        l_talv_rec.fa_location_id  := taa_lines_rec.source_value_2;

        OKL_TXL_ASSETS_PUB.update_txl_asset_def(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_tlpv_rec       => l_talv_rec,
          x_tlpv_rec       => lx_talv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- Asset Line level Bill-To-Site
      IF (taa_lines_rec.source_column_3 = 'BILL_TO_SITE_ID'
         AND taa_lines_rec.source_value_3 IS NOT NULL) THEN

        lp_clev_rec.id := taa_lines_rec.id;
        lp_clev_rec.bill_to_site_use_id := taa_lines_rec.source_value_3;

        lp_klev_rec.id := taa_lines_rec.id;

        OKL_CONTRACT_PUB.update_contract_line(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_clev_rec            => lp_clev_rec,
          p_klev_rec            => lp_klev_rec,
          x_clev_rec            => lx_clev_rec,
          x_klev_rec            => lx_klev_rec
        );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END LOOP;

    --Bug# 4191851
    -- Create Third Party Insurance
    IF (taa_chr_hdr_dtl_rec.insurance_yn = 'Y' AND
        taa_chr_hdr_dtl_rec.lease_policy_yn = 'N' AND
        taa_chr_hdr_dtl_rec.policy_number IS NOT NULL) THEN

      l_ipyv_rec.ipy_type              := taa_chr_hdr_dtl_rec.ipy_type;
      l_ipyv_rec.sfwt_flag             := 'T';
      l_ipyv_rec.policy_number         := taa_chr_hdr_dtl_rec.policy_number;
      l_ipyv_rec.covered_amount        := taa_chr_hdr_dtl_rec.covered_amt;
      l_ipyv_rec.deductible            := taa_chr_hdr_dtl_rec.deductible_amt;
      l_ipyv_rec.date_to               := taa_chr_hdr_dtl_rec.effective_to_date;
      l_ipyv_rec.date_from             := taa_chr_hdr_dtl_rec.effective_from_date;
      l_ipyv_rec.date_proof_provided   := taa_chr_hdr_dtl_rec.proof_provided_date;
      l_ipyv_rec.date_proof_required   := taa_chr_hdr_dtl_rec.proof_required_date;
      l_ipyv_rec.quote_yn              := 'N';
      l_ipyv_rec.lessor_insured_yn     := taa_chr_hdr_dtl_rec.lessor_insured_yn;
      l_ipyv_rec.lessor_payee_yn       := taa_chr_hdr_dtl_rec.lessor_payee_yn;
      l_ipyv_rec.khr_id                := p_chr_id;
      l_ipyv_rec.int_id                := taa_chr_hdr_dtl_rec.int_id;
      l_ipyv_rec.isu_id                := taa_chr_hdr_dtl_rec.isu_id;
      l_ipyv_rec.agency_site_id        := taa_chr_hdr_dtl_rec.agency_site_id;
      l_ipyv_rec.agent_site_id         := taa_chr_hdr_dtl_rec.agent_site_id;
      l_ipyv_rec.territory_code        := taa_chr_hdr_dtl_rec.territory_code;
      l_ipyv_rec.org_id                := p_org_id;

      OKL_INS_QUOTE_PUB.create_third_prt_ins(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_ipyv_rec        => l_ipyv_rec,
        x_ipyv_rec        => lx_ipyv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END update_taa_request_info;

-----------------------------------------------------------------------------------------------
-------------------------- Main Process for Re-Lease of Contract ------------------------------
-----------------------------------------------------------------------------------------------
  Procedure create_release_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  OKC_K_HEADERS_B.ID%TYPE,
            p_release_reason_code  IN  VARCHAR2,
            p_release_description  IN  VARCHAR2,
            p_trx_date             IN  DATE,
            p_source_trx_id        IN  NUMBER,
            p_source_trx_type      IN  VARCHAR2,
            x_tcnv_rec             OUT NOCOPY tcnv_rec_type,
            x_release_chr_id       OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_RELEASE_CONTRACT';
    l_chrv_rec               chrv_rec_type;
    l_khrv_rec               khrv_rec_type;
    ln_old_chr_id            OKC_K_HEADERS_V.ID%TYPE;
    ln_new_chr_id            OKC_K_HEADERS_V.ID%TYPE;
    lv_old_sts_code          OKC_K_HEADERS_V.STS_CODE%TYPE;
    lv_old_contract_number   OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    ld_old_end_date          OKC_K_HEADERS_V.END_DATE%TYPE;
    ln_old_authoring_org_id  OKC_K_HEADERS_V.AUTHORING_ORG_ID%TYPE;
    lt_top_line_tbl          g_top_line_tbl;
    lt_asset_num_tbl         g_asset_num_tbl;
    l_return_status          VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR c_fetch_header_line_id(p_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT chr.id,
           chr.contract_number,
           chr.end_date,
           st.ste_code sts_code,
           chr.authoring_org_id
    FROM OKC_K_HEADERS_B chr,
         okc_statuses_b st
    WHERE chr.id = p_chr_id
    and st.code = chr.sts_code;

    l_new_contract_number okc_k_headers_b.contract_number%TYPE;
    x_new_chrv_rec        chrv_rec_type;
    x_new_khrv_rec        khrv_rec_type;

    CURSOR taa_request_dtl_csr(p_source_trx_id IN NUMBER)
    IS
    SELECT new_contract_number
    FROM okl_taa_request_details_b
    WHERE tcn_id = p_source_trx_id;

    taa_request_dtl_rec taa_request_dtl_csr%ROWTYPE;


    CURSOR taa_lines_csr(p_new_chr_id    IN NUMBER,
                         p_source_trx_id IN NUMBER)
    IS
    SELECT cle.id
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.chr_id = p_new_chr_id
    AND cle.dnz_chr_id = p_new_chr_id
    AND lse.lty_code = 'FREE_FORM1'
    AND cle.lse_id = lse.id
    AND NOT EXISTS (SELECT 1
                    FROM okl_txl_cntrct_lns tcl
                    WHERE tcl.tcn_id = p_source_trx_id
                    AND tcl.kle_id = cle.orig_system_id1
                    AND tcl.before_transfer_yn = 'N');

    CURSOR taa_fee_serv_csr(p_new_chr_id    IN NUMBER)
    IS
    SELECT cle.id
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.chr_id = p_new_chr_id
    AND cle.dnz_chr_id = p_new_chr_id
    AND lse.lty_code IN ('FEE','SOLD_SERVICE')
    AND cle.lse_id = lse.id
    AND NOT EXISTS (SELECT 1
                    FROM okc_k_lines_b sub_cle
                    WHERE sub_cle.cle_id = cle.id);

    CURSOR taa_request_csr(p_source_trx_id IN NUMBER)
    IS
    SELECT tsu_code,
           complete_transfer_yn,
           --Bug# 4198413
           date_transaction_occurred
    FROM okl_trx_contracts
    where id = p_source_trx_id;

    taa_request_rec        taa_request_csr%ROWTYPE;

    l_seq_no               NUMBER;
    l_term_duration        NUMBER;

    l_release_date         DATE;

    --Bug# 4631549
    --cursor to get all finasset lines
    cursor l_finast_csr (p_chr_id in number) is
    select cleb.id
    from   okc_k_lines_b cleb
    where  cleb.chr_id = p_chr_id
    and    cleb.dnz_chr_id = p_chr_id
    and    cleb.lse_id = 33; --financial asset line id

    l_finast_rec    l_finast_csr%ROWTYPE;
    l_fin_clev_rec  okl_okc_migration_pvt.clev_rec_type;
    l_fin_klev_rec  okl_contract_pub.klev_rec_type;
    lx_fin_clev_rec okl_okc_migration_pvt.clev_rec_type;
    lx_fin_klev_rec okl_contract_pub.klev_rec_type;
    --End Bug# 4631549

  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,l_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_release_date := TRUNC(p_trx_date);

    --Bug# 4198413: Set Revision Date equal to TNA Transfer Effective
    --              Date, if the user does not enter Revision date.
    if (l_release_date IS NULL and p_source_trx_id IS NOT NULL) then
      open taa_request_csr(p_source_trx_id => p_source_trx_id);
      fetch taa_request_csr into taa_request_rec;
      close taa_request_csr;

      l_release_date := TRUNC(taa_request_rec.date_transaction_occurred);
    end if;

    -- Validate Re-lease contract
    validate_release_contract(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_chr_id        => p_chr_id,
                              p_release_date  => l_release_date,
                              p_source_trx_id => p_source_trx_id,
			       p_release_reason_code=>p_release_reason_code);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Fetch the old contract header id and sts_code
    OPEN  c_fetch_header_line_id(p_chr_id);
    IF c_fetch_header_line_id%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_V.ID');

       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH  c_fetch_header_line_id INTO ln_old_chr_id,
                                       lv_old_contract_number,
                                       ld_old_end_date,
                                       lv_old_sts_code,
                                       ln_old_authoring_org_id;
    CLOSE  c_fetch_header_line_id;

    -- T and A Request
    IF p_source_trx_id IS NOT NULL THEN

      OPEN taa_request_dtl_csr(p_source_trx_id);
      FETCH taa_request_dtl_csr INTO taa_request_dtl_rec;
      CLOSE taa_request_dtl_csr;

      l_new_contract_number := taa_request_dtl_rec.new_contract_number;
    END IF;

    IF l_new_contract_number IS NULL THEN

      -- Get Sequence Number to generate Contract Number
      SELECT okl_rbk_seq.NEXTVAL
      INTO   l_seq_no
      FROM   DUAL;

      l_new_contract_number :=  lv_old_contract_number||'-REL'||l_seq_no;
    END IF;

    l_term_duration := TRUNC(MONTHS_BETWEEN(ld_old_end_date + 1,l_release_date));

    -- Depending on the status of the contract we have to copy the contract
    -- or else validate the assets of the contract
    IF (lv_old_sts_code IS NOT NULL OR
       lv_old_sts_code <> OKL_API.G_MISS_CHAR) AND
       lv_old_sts_code IN ('ACTIVE','HOLD') THEN
       l_copy_contract(p_api_version         => p_api_version,
                       p_init_msg_list       => p_init_msg_list,
                       x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data,
                       p_commit              => OKL_API.G_FALSE,
                       p_old_chr_id          => ln_old_chr_id,
                       p_new_contract_number => l_new_contract_number,
                       p_release_date        => l_release_date,
                       p_term_duration       => l_term_duration,
                       x_new_chrv_rec        => x_new_chrv_rec,
                       x_new_khrv_rec        => x_new_khrv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSIF (lv_old_sts_code IS NOT NULL OR
       lv_old_sts_code <> OKL_API.G_MISS_CHAR) AND
       lv_old_sts_code = 'TERMINATED' THEN
       -- Since we got the new contract in form of x_chr_id
       x_return_status := validate_assets_offlease(p_dnz_chr_id    => ln_old_chr_id);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LLA_CHR_ID');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LLA_CHR_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_copy_contract(p_api_version         => p_api_version,
                       p_init_msg_list       => p_init_msg_list,
                       x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data,
                       p_commit              => OKL_API.G_FALSE,
                       p_old_chr_id          => ln_old_chr_id,
                       p_new_contract_number => l_new_contract_number,
                       p_release_date        => l_release_date,
                       p_term_duration       => l_term_duration,
                       x_new_chrv_rec        => x_new_chrv_rec,
                       x_new_khrv_rec        => x_new_khrv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_CHR_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Create Re-lease contract transaction
    create_release_transaction
       (p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_chr_id             => p_chr_id,
        p_new_chr_id         => x_new_chrv_rec.id,
        p_reason_code        => p_release_reason_code,
        p_description        => p_release_description,
        p_trx_date           => l_release_date,
        p_source_trx_id      => p_source_trx_id,
        p_source_trx_type    => p_source_trx_type,
        x_tcnv_rec           => x_tcnv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Delete contract lines which are not transferred
    -- if the source transaction is Partial T and A
    if (p_source_trx_id IS NOT NULL ) then

      open taa_request_csr(p_source_trx_id => p_source_trx_id);
      fetch taa_request_csr into taa_request_rec;
      close taa_request_csr;

      if (taa_request_rec.complete_transfer_yn = 'N') then

        -- Delete Financial Asset lines not transferred
        for taa_lines_rec in taa_lines_csr
                         (p_new_chr_id    => x_new_chrv_rec.id,
                          p_source_trx_id => p_source_trx_id)
        loop
          OKL_CONTRACT_PUB.delete_contract_line(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_line_id       => taa_lines_rec.id
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        end loop;

        -- Delete Fee and Service lines not having Covered Assets
        for taa_fee_serv_rec in taa_fee_serv_csr
                         (p_new_chr_id    => x_new_chrv_rec.id)
        loop
          OKL_CONTRACT_PUB.delete_contract_line(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_line_id       => taa_fee_serv_rec.id
            );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        end loop;

        -- Adjust Top line payments for Service and Rollover Fees
        -- where Covered assets are defined and not all Covered
        -- assets move over
        adjust_partial_taa_pymt
                        (p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_chr_id        => x_new_chrv_rec.id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      end if;
    end if;

    --Bug# 4155405
    -- Update Re-lease contract with information from the
    -- Transfer and Assumption request
    if (p_source_trx_id IS NOT NULL) then

      update_taa_request_info
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_chr_id        => x_new_chrv_rec.id,
         p_taa_trx_id    => p_source_trx_id,
         p_org_id        => ln_old_authoring_org_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    end if;

    adjust_asset_lines(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_chr_id        => x_new_chrv_rec.id,
                       p_release_date  => l_release_date);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    adjust_payment_lines(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_chr_id        => x_new_chrv_rec.id,
                         p_release_date  => l_release_date);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    adjust_fee_lines(p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_chr_id        => x_new_chrv_rec.id,
                     p_orig_chr_id   => p_chr_id,
                     p_release_date  => l_release_date);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    adjust_service_lines(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_chr_id        => x_new_chrv_rec.id,
                         p_orig_chr_id   => p_chr_id,
                         p_release_date  => l_release_date);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	   --Added by rajnisku Bug 6657564
 	    adjust_usage_lines(p_api_version   => p_api_version,
 	                        p_init_msg_list => p_init_msg_list,
 	                        x_return_status => x_return_status,
 	                        x_msg_count     => x_msg_count,
 	                        x_msg_data      => x_msg_data,
 	                        p_chr_id        => x_new_chrv_rec.id,
 	                        p_release_date  => l_release_date);

 	     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
 	       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
 	       RAISE OKL_API.G_EXCEPTION_ERROR;
 	     END IF;
 	    --Added by rajnisku Bug 6657564 : End
    --Bug# 4631549 : Update line Capital Amounts
    open l_finast_csr (p_chr_id => x_new_chrv_rec.id);
    Loop
            Fetch l_finast_csr into l_finast_rec;
            Exit when l_finast_csr%NOTFOUND;
            OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_formula_name  => 'LINE_CAP_AMNT',
                                            p_contract_id   => x_new_chrv_rec.id,
                                            p_line_id       => l_finast_rec.id,
                                            x_value         => l_fin_klev_rec.capital_amount);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

            l_fin_clev_rec.id := l_finast_rec.id;
            l_fin_klev_rec.id := l_finast_rec.id;

            OKL_CONTRACT_PUB.update_contract_line
              (p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_clev_rec       => l_fin_clev_rec,
               p_klev_rec       => l_fin_klev_rec,
               x_clev_rec       => lx_fin_clev_rec,
               x_klev_rec       => lx_fin_klev_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
      End Loop;
      Close l_finast_csr;
      --End Bug# 4631549

    -- R12B Authoring OA Migration
    x_release_chr_id := x_new_chrv_rec.id;

    OKL_API.END_ACTIVITY (x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_fetch_header_line_id%ISOPEN THEN
         CLOSE c_fetch_header_line_id;
      END IF;
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
      x_return_status := l_return_status;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      IF c_fetch_header_line_id%ISOPEN THEN
         CLOSE c_fetch_header_line_id;
      END IF;
      l_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      x_return_status := l_return_status;
  END create_release_contract;
-----------------------------------------------------------------------------------------------
--------------------------------- Activate Release Contract ----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE activate_release_contract(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  OKC_K_HEADERS_B.ID%TYPE) IS
    l_api_name                    VARCHAR2(35)    := 'ACTIVATE_RELEASE_CONTRACT';
    l_proc_name                   VARCHAR2(35)    := 'ACTIVATE_RELEASE_CONTRACT';
    ln_orig_system_source_code    OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE;
    ln_orig_system_id1            OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE;
    ln_orig_contract_number       OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_cimv_rec                    cimv_rec_type;
    lx_cimv_rec                   cimv_rec_type;
    l_trxv_rec                    trxv_rec_type;
    lx_trxv_rec                   trxv_rec_type;
    --Bug# 4072796
    ln_new_contract_number       OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

    -- To get the orig system id for p_chr_id
    CURSOR get_orig_sys_code(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT chr_new.orig_system_source_code,
           chr_new.orig_system_id1,
           chr_old.contract_number,
           --Bug# 4072796
           chr_new.contract_number
    FROM okc_k_headers_b chr_new,
         okc_k_headers_b chr_old
    WHERE chr_new.id = p_chr_id
    AND   chr_old.id = chr_new.orig_system_id1;

    -- To get the orig system id for Fixed Asset lines of p_chr_id
    CURSOR get_orig_fa(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT cle.orig_system_id1 orig_cle_fa,
           cle.id id
    FROM OKC_K_LINES_B cle,
         OKC_LINE_STYLES_B lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'FIXED_ASSET';

    -- To get the orig system id for Install Base lines of p_chr_id
    CURSOR get_orig_ib(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT cle.orig_system_id1 orig_cle_ib,
           cle.id id
    FROM OKC_K_LINES_B cle,
         OKC_LINE_STYLES_B lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'INST_ITEM';

    -- To get the item information from original line id and original contract id
    CURSOR get_item_info(p_orig_chr_id OKC_K_HEADERS_B.ID%TYPE,
                         p_orig_cle_id OKC_K_LINES_B.ID%TYPE) IS
    SELECT object1_id1,
           object1_id2
    FROM  okc_k_items
    WHERE cle_id = p_orig_cle_id
    AND dnz_chr_Id = p_orig_chr_id;

    Cursor l_asr_csr(p_rel_chr_id IN NUMBER) IS
    SELECT cle.cle_id        finasst_id,
           cim.object1_id1   asset_id,
           cle_orig.cle_id   orig_finasst_id,
           asr.id            asset_return_id
    FROM   OKL_ASSET_RETURNS_B asr,
           OKC_K_LINES_B     cle_orig,
           OKC_LINE_STYLES_B lse_orig,
           OKC_K_ITEMS       cim_orig,
           OKC_K_ITEMS       cim,
           OKC_K_LINES_B     cle,
           OKC_LINE_STYLES_B lse,
           OKC_STATUSES_B    sts,
           OKL_TXL_ASSETS_B  txl
    WHERE  asr.kle_id            = cle_orig.cle_id
    AND    asr.ars_code          = 'RELEASE_IN_PROCESS'
    AND    cim.object1_id1       = cim_orig.object1_id1
    AND    cim.object1_id2       = cim_orig.object1_id2
    AND    cim.jtot_object1_code = cim_orig.jtot_object1_code
    AND    cim.id                <> cim_orig.id
    AND    cle_orig.id           = cim_orig.cle_id
    AND    cle_orig.dnz_chr_id   = cim_orig.dnz_chr_id
    AND    cle_orig.lse_id       = lse_orig.id
    AND    lse_orig.lty_code     = 'FIXED_ASSET'
    AND    cim.cle_id            = cle.id
    AND    cim.dnz_chr_id        = cle.dnz_chr_id
    AND    cle.id                = txl.kle_id
    AND    cle.dnz_chr_id        = p_rel_chr_id
    AND    cle.lse_id            = lse.id
    AND    lse.lty_code          = 'FIXED_ASSET'
    AND    cle.sts_code          = sts.code
    AND    sts.ste_code not in ('EXPIRED','TERMINATED','CANCELLED')
    AND    txl.tal_type = 'CRL';

   l_asr_rec l_asr_csr%ROWTYPE;

   l_artv_rec    okl_asset_returns_pub.artv_rec_type;
   lx_artv_rec   okl_asset_returns_pub.artv_rec_type;

   CURSOR taa_trx_csr(p_orig_chr_id    IN NUMBER
                     ,p_new_chr_id     IN NUMBER)
   IS
   SELECT tcn.id,
          tcn.source_trx_id ,
	    --Bug 6657564- Added
 	           RBR_CODE
 	           --Bug 6657564 - End
   FROM   okl_trx_contracts tcn,
          okl_trx_types_tl try
   WHERE  tcn.khr_id_old = p_orig_chr_id
   AND    tcn.khr_id_new = p_new_chr_id
   AND    tcn_type = 'MAE'
   AND    tcn.tsu_code <> 'PROCESSED'
   AND    tcn.try_id = try.id
--rkuttiya added for 12.1.1 Multi GAAP
   AND    tcn.representation_type = 'PRIMARY'
--
   AND    try.name = 'Release'
   AND    try.language= 'US';

   taa_trx_rec taa_trx_csr%ROWTYPE;

   l_tcnv_rec      tcnv_rec_type;
   l_out_tcnv_rec  tcnv_rec_type;

   --Bug# 4072796
   CURSOR taa_request_dtl_csr(p_source_trx_id IN NUMBER)
   IS
   SELECT id,
          tcn_id
   FROM okl_taa_request_details_b
   WHERE tcn_id = p_source_trx_id;

   taa_request_dtl_rec taa_request_dtl_csr%ROWTYPE;

   l_taav_rec      okl_taa_pvt.taav_rec_type;
   l_out_taav_rec  okl_taa_pvt.taav_rec_type;

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
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

    -- To get the orig system id for
    OPEN  get_orig_sys_code(p_chr_id => p_chr_id);
    FETCH get_orig_sys_code INTO ln_orig_system_source_code,
                                 ln_orig_system_id1,
                                 ln_orig_contract_number,
                                 ln_new_contract_number; --Bug# 4072796
    IF get_orig_sys_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_HEADERS_V.ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_orig_sys_code;
    IF ln_orig_system_source_code = 'OKL_RELEASE' THEN

      -- To get all the assets for the p_chr_id
      FOR r_get_orig_fa IN get_orig_fa(p_chr_id => p_chr_id) LOOP

        -- to get all the new line item information
        x_return_status := get_rec_cimv(r_get_orig_fa.id,
                                        p_chr_id,
                                        l_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V record');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V record');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- To get the old information of the old asset
        OPEN get_item_info(p_orig_chr_id => ln_orig_system_id1,
                           p_orig_cle_id => r_get_orig_fa.orig_cle_fa);
        FETCH get_item_info INTO l_cimv_rec.object1_id1,
                                 l_cimv_rec.object1_id2;
        IF get_item_info%NOTFOUND THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        CLOSE get_item_info;
        OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_cimv_rec      => l_cimv_rec,
                                                   x_cimv_rec      => lx_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- To get the Install Base information for the p_chr_id
      FOR r_get_orig_ib IN get_orig_ib(p_chr_id => p_chr_id) LOOP
        -- to get all the new line item information
        x_return_status := get_rec_cimv(r_get_orig_ib.id,
                                        p_chr_id,
                                        l_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V record');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'OKC_K_ITEMS_V record');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        -- To get the old information of the old asset
        OPEN get_item_info(p_orig_chr_id => ln_orig_system_id1,
                           p_orig_cle_id => r_get_orig_ib.orig_cle_ib);
        FETCH get_item_info INTO l_cimv_rec.object1_id1,
                                 l_cimv_rec.object1_id2;
        IF get_item_info%NOTFOUND THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        CLOSE get_item_info;
        OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_cimv_rec      => l_cimv_rec,
                                                   x_cimv_rec      => lx_cimv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- call the asset release api
      okl_activate_asset_pub.RELEASE_ASSET
          (p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_rel_chr_id    => p_chr_id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      --call the install base instance re_lease API
      okl_activate_ib_pvt.RELEASE_IB_INSTANCE
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_rel_chr_id    => p_chr_id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      --code added to update status in OKL_ASSET_RETURNS_B
      --after the release asset transaction has been processed
      OPEN l_asr_csr(p_chr_id);
      LOOP
        FETCH l_asr_csr into l_asr_rec;
        EXIT When l_asr_csr%NOTFOUND;
        l_artv_rec.id := l_asr_rec.asset_return_id;
        l_artv_rec.ars_code := 'CANCELLED';
        l_artv_rec.like_kind_yn := 'N';
        --call to change the release asset status to 'CANCELLED' in asset return
        okl_asset_returns_pub.update_asset_returns(
           p_api_version    => p_api_version
          ,p_init_msg_list  => p_init_msg_list
          ,x_return_status  => x_return_status
          ,x_msg_count      => x_msg_count
          ,x_msg_data       => x_msg_data
          ,p_artv_rec       => l_artv_rec
          ,x_artv_rec       => lx_artv_rec);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
      CLOSE l_asr_csr;

      -- Update Credit line
      OKL_TRANSFER_ASSUMPTION_PVT.update_full_tna_creditline(
          p_api_version    => p_api_version
         ,p_init_msg_list  => p_init_msg_list
         ,x_return_status  => x_return_status
         ,x_msg_count      => x_msg_count
         ,x_msg_data       => x_msg_data
         ,p_chr_id         => p_chr_id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      -- We need to change the status of the contract
      OKL_CONTRACT_STATUS_PUB.update_contract_status(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_khr_status    => 'BOOKED',
                              p_chr_id        => p_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- We need to change the status of the Lines for the contract
      OKL_CONTRACT_STATUS_PUB.cascade_lease_status(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_chr_id        => p_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Set Re-lease Transaction status to 'PROCESSED'
      open taa_trx_csr(p_orig_chr_id => ln_orig_system_id1
                      ,p_new_chr_id  => p_chr_id);
      fetch taa_trx_csr into taa_trx_rec;
      close taa_trx_csr;

      if (taa_trx_rec.id IS NOT NULL) then
        l_tcnv_rec.id       := taa_trx_rec.id;
        l_tcnv_rec.tsu_code := 'PROCESSED';

        OKL_TRX_CONTRACTS_PUB.update_trx_contracts
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_tcnv_rec       => l_tcnv_rec,
           x_tcnv_rec       => l_out_tcnv_rec
          );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      end if;

      --Bug# 4072796
      -- Update new contract number on Transfer and Assumption request
      -- Set status of Transfer and Assumption request to Processed
      if (taa_trx_rec.source_trx_id IS NOT NULL) then

        OPEN taa_request_dtl_csr(p_source_trx_id => taa_trx_rec.source_trx_id);
        FETCH taa_request_dtl_csr INTO taa_request_dtl_rec;
        CLOSE taa_request_dtl_csr;

        if (taa_request_dtl_rec.id is not null) then
          l_taav_rec.id := taa_request_dtl_rec.id;
          l_taav_rec.tcn_id := taa_request_dtl_rec.tcn_id;
          l_taav_rec.new_contract_number := ln_new_contract_number;

          OKL_TAA_PVT.update_row
           (p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_taav_rec      => l_taav_rec,
            x_taav_rec      => l_out_taav_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        end if;

        l_tcnv_rec.id       := taa_trx_rec.source_trx_id;
        l_tcnv_rec.tsu_code := 'PROCESSED';
        l_tcnv_rec.khr_id_new := p_chr_id;

        OKL_TRX_CONTRACTS_PUB.update_trx_contracts
          (p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_tcnv_rec       => l_tcnv_rec,
           x_tcnv_rec       => l_out_tcnv_rec
          );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      end if;
       	 --rajnisku Bug 6657564  : Added a call to create usage line

 	       IF NVL(taa_trx_rec.RBR_CODE,'X')='CUSTOMER_CHANGE' THEN
 	            create_ubb_contract(p_api_version   =>p_api_version,
 	                                p_init_msg_list =>p_init_msg_list,
 	                                x_return_status =>x_return_status,
 	                                x_msg_count     =>x_msg_count,
 	                                x_msg_data      =>x_msg_data,
 	                                p_chr_id        =>p_chr_id,
 	                                p_source_trx_id => taa_trx_rec.source_trx_id
 	                         ) ;


 	        END IF;
 	       --rajnisku:End

    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'This Contract is not a Re-Lease Contract');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
        IF get_orig_sys_code%ISOPEN THEN
          close get_orig_sys_code;
        END IF;
        IF get_orig_fa%ISOPEN THEN
          close get_orig_fa;
        END IF;
        IF get_orig_ib%ISOPEN THEN
          close get_orig_ib;
        END IF;
        IF get_item_info%ISOPEN THEN
          close get_item_info;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
        IF get_orig_sys_code%ISOPEN THEN
          close get_orig_sys_code;
        END IF;
        IF get_orig_fa%ISOPEN THEN
          close get_orig_fa;
        END IF;
        IF get_orig_ib%ISOPEN THEN
          close get_orig_ib;
        END IF;
        IF get_item_info%ISOPEN THEN
          close get_item_info;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
        IF get_orig_sys_code%ISOPEN THEN
          close get_orig_sys_code;
        END IF;
        IF get_orig_fa%ISOPEN THEN
          close get_orig_fa;
        END IF;
        IF get_orig_ib%ISOPEN THEN
          close get_orig_ib;
        END IF;
        IF get_item_info%ISOPEN THEN
          close get_item_info;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END activate_release_contract;

End okl_release_pvt;

/
