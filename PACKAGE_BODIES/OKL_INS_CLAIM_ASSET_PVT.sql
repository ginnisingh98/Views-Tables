--------------------------------------------------------
--  DDL for Package Body OKL_INS_CLAIM_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_CLAIM_ASSET_PVT" AS
/* $Header: OKLRCLAB.pls 120.4 2005/12/28 09:46:11 dkagrawa noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.INSURANCE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
 PROCEDURE   create_lease_claim(
           	p_api_version                  IN NUMBER,
  	  	    p_init_msg_list                IN VARCHAR2 ,
           	x_return_status                OUT NOCOPY VARCHAR2,
           	x_msg_count                    OUT NOCOPY NUMBER,
           	x_msg_data                     OUT NOCOPY VARCHAR2,
           	px_clmv_tbl                    IN OUT NOCOPY clmv_tbl_type,
           	px_acdv_tbl		               IN OUT NOCOPY acdv_tbl_type,
           	px_acnv_tbl		               IN OUT NOCOPY acnv_tbl_type
     		)
 AS
    l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_iln_id                PLS_INTEGER;
    l_kle_id                NUMBER;
    l_clmv_tbl              clmv_tbl_type := px_clmv_tbl;
    x_clmv_tbl              clmv_tbl_type;
    l_acdv_tbl              acdv_tbl_type := px_acdv_tbl;
    x_acdv_tbl              acdv_tbl_type ;
    l_acnv_tbl              acnv_tbl_type := px_acnv_tbl;
    x_acnv_tbl              acnv_tbl_type ;
    i                       PLS_INTEGER;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_lease_claim';
    l_dummy_var                    VARCHAR2(1) := '?';
    l_api_version			CONSTANT NUMBER := 1;

    CURSOR l_acdv_csr(p_kle_id NUMBER) IS
       SELECT CSI.LOCATION_ID
       FROM OKC_K_LINES_B A,
            OKC_K_LINES_B B,
            OKC_K_LINES_B C,
            OKC_K_ITEMS CIM,
            OKX_INSTALL_ITEMS_V CSI
       WHERE A.ID = p_kle_id
       AND   B.CLE_ID = A.ID
       AND   B.LSE_ID = 43
       AND   C.CLE_ID = B.ID
       AND   C.LSE_ID = 45
       AND CIM.CLE_ID = C.ID
       AND CIM.JTOT_OBJECT1_CODE = 'OKX_IB_ITEM'
       AND CSI.ID1 = CIM.OBJECT1_ID1
       AND CSI.ID2 = CIM.OBJECT1_ID2;

     CURSOR l_fav_csr(p_cle_id NUMBER) IS
       select CLE.ID
       from okc_k_lines_b cle , okc_line_styles_b lse
       where cle.cle_id = p_cle_id  and
             cle.lse_id =  lse.id and
             lse.LTY_CODE = 'FIXED_ASSET';
 BEGIN
   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PROCESS',
                                             x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


    --Populate the Master
-- Start of wraper code generated automatically by Debug code generator for okl_ins_claims_pub.insert_INS_CLAIMS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCLAB.pls call okl_ins_claims_pub.insert_INS_CLAIMS ');
    END;
  END IF;
    okl_ins_claims_pub.insert_INS_CLAIMS(
          p_api_version        =>  p_api_version
         ,p_init_msg_list      =>  p_init_msg_list
         ,x_return_status      =>  x_return_status
         ,x_msg_count          =>  x_msg_count
         ,x_msg_data           =>  x_msg_data
         ,p_clmv_tbl           =>  l_clmv_tbl
    	 ,x_clmv_tbl           =>  x_clmv_tbl );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCLAB.pls call okl_ins_claims_pub.insert_INS_CLAIMS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_ins_claims_pub.insert_INS_CLAIMS

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    	  RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    IF (x_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
         px_clmv_tbl := x_clmv_tbl;
    END IF;
--dkagrawa commnted following code and moved down inside loop
--bug#4878489
/*    OPEN l_acdv_csr(l_acdv_tbl(1).kle_id);
	   FETCH l_acdv_csr INTO l_iln_id;
    CLOSE l_acdv_csr;

    OPEN l_fav_csr(l_acdv_tbl(1).kle_id);
	          FETCH l_fav_csr INTO l_kle_id;
    CLOSE l_fav_csr;

         -- if l_dummy_var is still set to default ,data was not found
         IF (l_iln_id =OKC_API.G_MISS_NUM OR l_iln_id IS NULL) THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'LOCATION ID',
                               p_token2             => g_child_table_token, --3745151
                               p_token2_value       => 'OKX_INSTALL_ITEMS_V',--3745151
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'OKX_ITEM_INSTS_LINES_V');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
*/
    -- Populate the foreign key for the line
    IF (l_acdv_tbl.COUNT > 0) THEN
       i := l_acdv_tbl.FIRST;
       LOOP
         --Bug#4878489 starts
         OPEN l_acdv_csr(l_acdv_tbl(i).kle_id);
         FETCH l_acdv_csr INTO l_iln_id;
         CLOSE l_acdv_csr;

         OPEN l_fav_csr(l_acdv_tbl(i).kle_id);
         FETCH l_fav_csr INTO l_kle_id;
         CLOSE l_fav_csr;
         IF (l_iln_id =OKC_API.G_MISS_NUM OR l_iln_id IS NULL) THEN
           OKC_API.set_message(p_app_name           => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'LOCATION ID',
                               p_token2             => g_child_table_token, --3745151
                               p_token2_value       => 'OKX_INSTALL_ITEMS_V',--3745151
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'OKX_ITEM_INSTS_LINES_V');
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
         END IF;
         --Bug#4878489 end
         l_acdv_tbl(i).clm_id := px_clmv_tbl(1).id;
         l_acdv_tbl(i).isp_id := 1;
         l_acdv_tbl(i).iln_id := l_iln_id;
         l_acdv_tbl(i).kle_id := l_kle_id;

          EXIT WHEN (i = l_acdv_tbl.LAST);
          i := l_acdv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the line
-- Start of wraper code generated automatically by Debug code generator for okl_asset_cndtns_pub.insert_asset_cndtns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCLAB.pls call okl_asset_cndtns_pub.insert_asset_cndtns ');
    END;
  END IF;
    okl_asset_cndtns_pub.insert_asset_cndtns(
    	        p_api_version    => p_api_version
    	       ,p_init_msg_list  =>  p_init_msg_list
    	       ,x_return_status  =>  x_return_status
    	       ,x_msg_count      =>  x_msg_count
    	       ,x_msg_data       =>  x_msg_data
    	       ,p_acdv_tbl       =>  l_acdv_tbl
    	       ,x_acdv_tbl       =>  px_acdv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCLAB.pls call okl_asset_cndtns_pub.insert_asset_cndtns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_asset_cndtns_pub.insert_asset_cndtns

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
     	  RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    IF (x_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
         null;
         --px_acdv_tbl := x_acdv_tbl;
    END IF;


    IF (px_acnv_tbl.COUNT > 0) THEN
      i := l_acnv_tbl.FIRST;
      LOOP
       l_acnv_tbl(i).acd_id := px_acdv_tbl(i).id;
       EXIT WHEN (i = l_acnv_tbl.LAST);
        i := l_acnv_tbl.NEXT(i);
      END LOOP;
    END IF;
-- Start of wraper code generated automatically by Debug code generator for okl_asset_cndtn_lns_pub.insert_asset_cndtn_lns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCLAB.pls call okl_asset_cndtn_lns_pub.insert_asset_cndtn_lns ');
    END;
  END IF;
    okl_asset_cndtn_lns_pub.insert_asset_cndtn_lns(
    	          p_api_version    =>  p_api_version
    	         ,p_init_msg_list  =>  p_init_msg_list
    	         ,x_return_status  =>  x_return_status
    	         ,x_msg_count      =>  x_msg_count
    	         ,x_msg_data       =>  x_msg_data
    	         ,p_acnv_tbl       =>  l_acnv_tbl
    		 ,x_acnv_tbl       =>  px_acnv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCLAB.pls call okl_asset_cndtn_lns_pub.insert_asset_cndtn_lns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_asset_cndtn_lns_pub.insert_asset_cndtn_lns

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      	  RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
   IF (x_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
         px_acnv_tbl := x_acnv_tbl;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
       	  				  	 	 p_pkg_name	=> G_PKG_NAME,
       							 p_exc_name   => 'OKC_API.G_RET_STS_ERROR',
       							 x_msg_count	=> x_msg_count,
       							 x_msg_data	=> x_msg_data,
       						         p_api_type	=> '_PROCESS');

           WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
             x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
       	  				  	 	  p_pkg_name	=> G_PKG_NAME,
       							  p_exc_name   => 'OKC_API.G_RET_STS_UNEXP_ERROR',
       							  x_msg_count	=> x_msg_count,
       							  x_msg_data	=> x_msg_data,
       							  p_api_type	=> '_PROCESS');

           WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
       	  				  	 	  p_pkg_name	=> G_PKG_NAME,
       							  p_exc_name   => 'OTHERS',
       							  x_msg_count	=> x_msg_count,
       							  x_msg_data	=> x_msg_data,
					                  p_api_type	=> '_PROCESS');
            IF l_acdv_csr%ISOPEN THEN
              CLOSE l_acdv_csr;
            END IF;

  END create_lease_claim;

  PROCEDURE  hold_streams(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsm_id                       IN stmid_rec_type_tbl_type
) IS
l_stmv_tbl Okl_Streams_Pvt.stmv_tbl_type;
x_stmv_tbl Okl_Streams_Pvt.stmv_tbl_type;
l_api_version  NUMBER :=  1 ;
BEGIN

  				-- SET values to retrieve record

    IF p_lsm_id IS NOT NULL THEN
     IF p_lsm_id.COUNT > 0 THEN
         FOR i IN p_lsm_id.first..p_lsm_id.last LOOP
         IF p_lsm_id.EXISTS(i) THEN
	        l_stmv_tbl(i).ID := p_lsm_id(i).ID ;
          l_stmv_tbl(i).SAY_CODE := p_lsm_id(i).STATUS ;
    	  END IF;
        END LOOP;

-- Start of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.update_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCLAB.pls call Okl_Streams_Pub.update_streams   ');
    END;
  END IF;
        		  Okl_Streams_Pub.update_streams  (
	   p_api_version                   => l_api_version,
       p_init_msg_list                => Okc_Api.G_FALSE  ,
       x_return_status                => X_return_status  ,
       x_msg_count                    => x_msg_count,
       x_msg_data                     => x_msg_data ,
       p_stmv_tbl                     =>  l_stmv_tbl,
       x_stmv_tbl                       => x_stmv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCLAB.pls call Okl_Streams_Pub.update_streams   ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.update_streams

	        IF (X_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (X_return_status = OKC_API.G_RET_STS_ERROR) THEN

              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

    END IF ;
    END IF ;
      END hold_streams ;


END OKL_INS_CLAIM_ASSET_PVT;

/
