--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_PRICING_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_PRICING_PARAMS_PVT" AS
/* $Header: OKLRSPMB.pls 120.5 2006/07/11 10:02:09 dkagrawa noship $*/

PROCEDURE create_trans_pricing_params(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_tpp_rec                 IN  tpp_rec_type
                    ,p_chr_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_gts_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_sif_id                  IN  NUMBER )
       IS
BEGIN
NULL;
END create_trans_pricing_params;


PROCEDURE create_trans_pricing_params(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_tpp_tbl                 IN  tpp_tbl_type
                    ,p_chr_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_gts_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_sif_id                  IN  NUMBER )
         IS
         l_tpp_tbl                             tpp_tbl_type;
         l_spmv_tbl                            spmv_tbl_type;
         l_sif_id                              okl_sif_pricing_params.sif_id%TYPE := p_sif_id;
         l_gts_id                              okl_st_gen_tmpt_sets.id%TYPE := p_gts_id;
         l_chr_id                              okc_k_headers_b.id%TYPE := p_chr_id;
         i                                     NUMBER := 0;
         j                                     NUMBER := 0;
         l_found                               VARCHAR2(1) := 'N';
         l_api_version                         CONSTANT NUMBER := 1;
         l_row_notfound                        BOOLEAN :=TRUE;

         l_id                                 okl_st_gen_prc_params.id%TYPE;
         l_name                               okl_st_gen_prc_params.name%TYPE;
         l_display_yn                         okl_st_gen_prc_params.display_yn%TYPE;
         l_update_yn                          okl_st_gen_prc_params.update_yn%TYPE;
         l_default_value                      okl_st_gen_prc_params.default_value%TYPE;
         l_prc_eng_ident                      okl_st_gen_prc_params.prc_eng_ident%TYPE;
         l_description                        okl_st_gen_prc_params.description%TYPE;

         CURSOR st_gen_prc_params(p_gts_id NUMBER) IS
         SELECT pp.id, pp.name, pp.display_yn,pp.update_yn,
         pp.default_value, pp.prc_eng_ident, pp.description
         FROM okl_st_gen_tmpt_sets temp_set,
         okl_st_gen_templates template,
         okl_st_gen_prc_params pp
         WHERE temp_set.id = template.gts_id
         AND   template.id = pp.gtt_id
         AND   temp_set.id = p_gts_id;

         CURSOR get_gts_id(p_chr_id NUMBER) IS
         SELECT TST.ID  GTS_ID
         FROM OKL_ST_GEN_TMPT_SETS TST,
         OKL_AE_TMPT_SETS_V AES,
         OKL_PRODUCTS_V PDT,
         OKL_K_HEADERS KHR
         WHERE TST.ID = AES.GTS_ID AND
         AES.ID = PDT.AES_ID AND
         PDT.ID = KHR.PDT_ID AND
         KHR.ID =p_chr_id;

BEGIN
  x_return_status :=OKC_API.G_RET_STS_SUCCESS;
  l_tpp_tbl := p_tpp_tbl;

  delete_pricing_params(l_chr_id,x_return_status);

  IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  IF ( (l_gts_id IS NULL OR l_gts_id = OKC_API.G_MISS_NUM) AND
       (l_chr_id IS NULL OR l_chr_id = OKC_API.G_MISS_NUM) )
  THEN
    x_return_status := Okc_Api.G_RET_STS_ERROR;
    OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Contract Number');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  ELSIF ( (l_gts_id IS NULL OR l_gts_id = OKC_API.G_MISS_NUM) AND
          (l_chr_id IS NOT  NULL OR l_chr_id <>  OKC_API.G_MISS_NUM) )
  THEN
    OPEN get_gts_id(l_chr_id);
    FETCH get_gts_id INTO l_gts_id;
      l_row_notfound := get_gts_id%NOTFOUND;
    CLOSE get_gts_id;

    IF l_row_notfound  THEN
      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                          p_msg_name => 'OKL_INVALID_CONTRACT_ID',
                          p_token1   => 'CONT_ID',
                          p_token1_value => to_char(l_chr_id));
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  IF (l_gts_id IS NOT NULL OR l_gts_id <> OKC_API.G_MISS_NUM) THEN
    OPEN st_gen_prc_params(l_gts_id);
    LOOP
      FETCH st_gen_prc_params INTO l_id, l_name,l_display_yn,l_update_yn,
                                   l_default_value,l_prc_eng_ident,l_description;
      EXIT WHEN st_gen_prc_params%NOTFOUND;
      l_spmv_tbl(j).parameter_value := l_default_value;
      IF (l_display_yn = 'Y' AND l_update_yn = 'Y')
      THEN
        l_found := 'N';
        IF (l_tpp_tbl.COUNT > 0)

        THEN
          i := l_tpp_tbl.FIRST;
          LOOP
            IF l_tpp_tbl(i).gtp_id = l_id
            THEN
              --Modified by kthiruva for on 06-Jan-2005.
              -- A String was being compared against G_MISS_NUM instead of G_MISS_CHAR
              --Bug 4062792 - Start of Changes
              IF l_tpp_tbl(i).parameter_value IS NOT NULL AND
                 l_tpp_tbl(i).parameter_value <> OKC_API.G_MISS_CHAR
              --Bug 4062792 - End of Changes
              THEN
                l_spmv_tbl(j).parameter_value := l_tpp_tbl(i).parameter_value;
              END IF;
              l_found := 'Y';
            END IF;
            EXIT WHEN (i = l_tpp_tbl.LAST OR l_found = 'Y');
            i := l_tpp_tbl.NEXT(i);
          END LOOP;
        END IF;
      END IF;
      l_spmv_tbl(j).object_version_number := 1;
      /*commented by suresh gorantla 04/03/05*/
      --l_spmv_tbl(j).sif_id := l_sif_id;
      l_spmv_tbl(j).khr_id := l_chr_id;
      l_spmv_tbl(j).name := l_name;
      l_spmv_tbl(j).display_yn := l_display_yn;
      l_spmv_tbl(j).update_yn := l_update_yn;
      l_spmv_tbl(j).default_value := l_default_value;
      l_spmv_tbl(j).prc_eng_ident := l_prc_eng_ident;
      l_spmv_tbl(j).description := l_description;
      j := j + 1;
    END LOOP;

    CLOSE st_gen_prc_params;

    OKL_SPM_PVT.insert_row(p_api_version      => l_api_version,
                           p_init_msg_list    => p_init_msg_list,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data,
                           p_spmv_tbl         =>l_spmv_tbl);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
END create_trans_pricing_params;

--User navigates to the same screen second time before Generate the Streams we need to remove the records
--whatever inserted in the first time

PROCEDURE delete_pricing_params(
                   p_chr_id                  IN NUMBER
                  ,x_return_status           OUT NOCOPY VARCHAR2)
IS
BEGIN
  DELETE FROM OKL_SIF_PRICING_PARAMS
  WHERE khr_ID = p_chr_id
  AND sif_id IS NULL;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  WHEN OTHERS THEN
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
END delete_pricing_params;

END; --OKL_TRANS_PRICING_PARAMS_PVT

/
