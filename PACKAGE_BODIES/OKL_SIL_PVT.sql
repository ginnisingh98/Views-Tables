--------------------------------------------------------
--  DDL for Package Body OKL_SIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIL_PVT" AS
/* $Header: OKLSSILB.pls 120.3.12010000.4 2009/07/21 00:23:07 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sil_rec                      IN sil_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sil_rec_type IS
    CURSOR sil_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STATE_DEPRE_DMNSHING_VALUE_RT,
            BOOK_DEPRE_DMNSHING_VALUE_RT,
            RESIDUAL_GUARANTEE_METHOD,
            FED_DEPRE_TERM,
            FED_DEPRE_DMNSHING_VALUE_RATE,
            FED_DEPRE_ADR_CONVE,
            STATE_DEPRE_BASIS_PERCENT,
            STATE_DEPRE_METHOD,
            PURCHASE_OPTION,
            PURCHASE_OPTION_AMOUNT,
            ASSET_COST,
            STATE_DEPRE_TERM,
            STATE_DEPRE_ADR_CONVENT,
            FED_DEPRE_METHOD,
            RESIDUAL_AMOUNT,
            FED_DEPRE_SALVAGE,
            DATE_FED_DEPRE,
            BOOK_SALVAGE,
            BOOK_ADR_CONVENTION,
            STATE_DEPRE_SALVAGE,
            FED_DEPRE_BASIS_PERCENT,
            BOOK_BASIS_PERCENT,
            DATE_DELIVERY,
            BOOK_TERM,
            RESIDUAL_GUARANTEE_AMOUNT,
            DATE_FUNDING,
            DATE_BOOK,
            DATE_STATE_DEPRE,
            BOOK_METHOD,
            STREAM_INTERFACE_ATTRIBUTE08,
            STREAM_INTERFACE_ATTRIBUTE03,
            STREAM_INTERFACE_ATTRIBUTE01,
            INDEX_NUMBER,
            STREAM_INTERFACE_ATTRIBUTE05,
            DESCRIPTION,
            STREAM_INTERFACE_ATTRIBUTE10,
            STREAM_INTERFACE_ATTRIBUTE06,
            STREAM_INTERFACE_ATTRIBUTE09,
            STREAM_INTERFACE_ATTRIBUTE07,
            STREAM_INTERFACE_ATTRIBUTE14,
            STREAM_INTERFACE_ATTRIBUTE12,
            STREAM_INTERFACE_ATTRIBUTE15,
            STREAM_INTERFACE_ATTRIBUTE02,
            STREAM_INTERFACE_ATTRIBUTE11,
            STREAM_INTERFACE_ATTRIBUTE04,
            STREAM_INTERFACE_ATTRIBUTE13,
            DATE_START,
            DATE_LENDING,
            SIF_ID,
            OBJECT_VERSION_NUMBER,
            KLE_ID,
            SIL_TYPE,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            -- mvasudev , 05/13/2002
            RESIDUAL_GUARANTEE_TYPE,
            RESIDUAL_DATE,
            DOWN_PAYMENT_AMOUNT,
            CAPITALIZE_DOWN_PAYMENT_YN,
            orig_contract_line_id
      FROM Okl_Sif_Lines
     WHERE okl_sif_lines.id     = p_id;
    l_sil_pk                       sil_pk_csr%ROWTYPE;
    l_sil_rec                      sil_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sil_pk_csr (p_sil_rec.id);
    FETCH sil_pk_csr INTO
              l_sil_rec.ID,
              l_sil_rec.STATE_DEPRE_DMNSHING_VALUE_RT,
              l_sil_rec.BOOK_DEPRE_DMNSHING_VALUE_RT,
              l_sil_rec.RESIDUAL_GUARANTEE_METHOD,
              l_sil_rec.FED_DEPRE_TERM,
              l_sil_rec.FED_DEPRE_DMNSHING_VALUE_RATE,
              l_sil_rec.FED_DEPRE_ADR_CONVE,
              l_sil_rec.STATE_DEPRE_BASIS_PERCENT,
              l_sil_rec.STATE_DEPRE_METHOD,
              l_sil_rec.PURCHASE_OPTION,
              l_sil_rec.PURCHASE_OPTION_AMOUNT,
              l_sil_rec.ASSET_COST,
              l_sil_rec.STATE_DEPRE_TERM,
              l_sil_rec.STATE_DEPRE_ADR_CONVENT,
              l_sil_rec.FED_DEPRE_METHOD,
              l_sil_rec.RESIDUAL_AMOUNT,
              l_sil_rec.FED_DEPRE_SALVAGE,
              l_sil_rec.DATE_FED_DEPRE,
              l_sil_rec.BOOK_SALVAGE,
              l_sil_rec.BOOK_ADR_CONVENTION,
              l_sil_rec.STATE_DEPRE_SALVAGE,
              l_sil_rec.FED_DEPRE_BASIS_PERCENT,
              l_sil_rec.BOOK_BASIS_PERCENT,
              l_sil_rec.DATE_DELIVERY,
              l_sil_rec.BOOK_TERM,
              l_sil_rec.RESIDUAL_GUARANTEE_AMOUNT,
              l_sil_rec.DATE_FUNDING,
              l_sil_rec.DATE_BOOK,
              l_sil_rec.DATE_STATE_DEPRE,
              l_sil_rec.BOOK_METHOD,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE08,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE03,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE01,
              l_sil_rec.INDEX_NUMBER,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE05,
              l_sil_rec.DESCRIPTION,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE10,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE06,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE09,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE07,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE14,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE12,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE02,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE11,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE04,
              l_sil_rec.STREAM_INTERFACE_ATTRIBUTE13,
              l_sil_rec.DATE_START,
              l_sil_rec.DATE_LENDING,
              l_sil_rec.SIF_ID,
              l_sil_rec.OBJECT_VERSION_NUMBER,
              l_sil_rec.KLE_ID,
              l_sil_rec.SIL_TYPE,
              l_sil_rec.CREATED_BY,
              l_sil_rec.LAST_UPDATED_BY,
              l_sil_rec.CREATION_DATE,
              l_sil_rec.LAST_UPDATE_DATE,
              l_sil_rec.LAST_UPDATE_LOGIN,
              -- mvasudev , 05/13/2002
              l_sil_rec.RESIDUAL_GUARANTEE_TYPE,
              l_sil_rec.RESIDUAL_DATE,
              l_sil_rec.DOWN_PAYMENT_AMOUNT,
              l_sil_rec.CAPITALIZE_DOWN_PAYMENT_YN,
			  l_sil_rec.orig_contract_line_id;
    x_no_data_found := sil_pk_csr%NOTFOUND;
    CLOSE sil_pk_csr;
    RETURN(l_sil_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sil_rec                      IN sil_rec_type
  ) RETURN sil_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sil_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_silv_rec                     IN silv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN silv_rec_type IS
    CURSOR silv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STATE_DEPRE_DMNSHING_VALUE_RT,
            BOOK_DEPRE_DMNSHING_VALUE_RT,
            RESIDUAL_GUARANTEE_METHOD,
            FED_DEPRE_TERM,
            FED_DEPRE_DMNSHING_VALUE_RATE,
            FED_DEPRE_ADR_CONVE,
            STATE_DEPRE_BASIS_PERCENT,
            STATE_DEPRE_METHOD,
            PURCHASE_OPTION,
            PURCHASE_OPTION_AMOUNT,
            ASSET_COST,
            STATE_DEPRE_TERM,
            STATE_DEPRE_ADR_CONVENT,
            FED_DEPRE_METHOD,
            RESIDUAL_AMOUNT,
            FED_DEPRE_SALVAGE,
            DATE_FED_DEPRE,
            BOOK_SALVAGE,
            BOOK_ADR_CONVENTION,
            STATE_DEPRE_SALVAGE,
            FED_DEPRE_BASIS_PERCENT,
            BOOK_BASIS_PERCENT,
            DATE_DELIVERY,
            BOOK_TERM,
            RESIDUAL_GUARANTEE_AMOUNT,
            DATE_FUNDING,
            DATE_BOOK,
            DATE_STATE_DEPRE,
            BOOK_METHOD,
            STREAM_INTERFACE_ATTRIBUTE01,
            STREAM_INTERFACE_ATTRIBUTE02,
            STREAM_INTERFACE_ATTRIBUTE03,
            STREAM_INTERFACE_ATTRIBUTE04,
            STREAM_INTERFACE_ATTRIBUTE05,
            STREAM_INTERFACE_ATTRIBUTE06,
            STREAM_INTERFACE_ATTRIBUTE07,
            STREAM_INTERFACE_ATTRIBUTE08,
            STREAM_INTERFACE_ATTRIBUTE09,
            STREAM_INTERFACE_ATTRIBUTE10,
            STREAM_INTERFACE_ATTRIBUTE11,
            STREAM_INTERFACE_ATTRIBUTE12,
            STREAM_INTERFACE_ATTRIBUTE13,
            STREAM_INTERFACE_ATTRIBUTE14,
            STREAM_INTERFACE_ATTRIBUTE15,
            DATE_START,
            DATE_LENDING,
            INDEX_NUMBER,
            SIF_ID,
            OBJECT_VERSION_NUMBER,
            KLE_ID,
            SIL_TYPE,
            DESCRIPTION,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            -- mvasudev , 05/13/2002
            RESIDUAL_GUARANTEE_TYPE,
            RESIDUAL_DATE,
            DOWN_PAYMENT_AMOUNT,
            CAPITALIZE_DOWN_PAYMENT_YN,
            orig_contract_line_id
      FROM Okl_Sif_Lines_V
     WHERE okl_sif_lines_v.id   = p_id;
    l_silv_pk                      silv_pk_csr%ROWTYPE;
    l_silv_rec                     silv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN silv_pk_csr (p_silv_rec.id);
    FETCH silv_pk_csr INTO
              l_silv_rec.ID,
              l_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT,
              l_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT,
              l_silv_rec.RESIDUAL_GUARANTEE_METHOD,
              l_silv_rec.FED_DEPRE_TERM,
              l_silv_rec.FED_DEPRE_DMNSHING_VALUE_RATE,
              l_silv_rec.FED_DEPRE_ADR_CONVE,
              l_silv_rec.STATE_DEPRE_BASIS_PERCENT,
              l_silv_rec.STATE_DEPRE_METHOD,
              l_silv_rec.PURCHASE_OPTION,
              l_silv_rec.PURCHASE_OPTION_AMOUNT,
              l_silv_rec.ASSET_COST,
              l_silv_rec.STATE_DEPRE_TERM,
              l_silv_rec.STATE_DEPRE_ADR_CONVENT,
              l_silv_rec.FED_DEPRE_METHOD,
              l_silv_rec.RESIDUAL_AMOUNT,
              l_silv_rec.FED_DEPRE_SALVAGE,
              l_silv_rec.DATE_FED_DEPRE,
              l_silv_rec.BOOK_SALVAGE,
              l_silv_rec.BOOK_ADR_CONVENTION,
              l_silv_rec.STATE_DEPRE_SALVAGE,
              l_silv_rec.FED_DEPRE_BASIS_PERCENT,
              l_silv_rec.BOOK_BASIS_PERCENT,
              l_silv_rec.DATE_DELIVERY,
              l_silv_rec.BOOK_TERM,
              l_silv_rec.RESIDUAL_GUARANTEE_AMOUNT,
              l_silv_rec.DATE_FUNDING,
              l_silv_rec.DATE_BOOK,
              l_silv_rec.DATE_STATE_DEPRE,
              l_silv_rec.BOOK_METHOD,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE01,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE02,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE03,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE04,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE05,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE06,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE07,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE08,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE09,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE10,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE11,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE12,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE13,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE14,
              l_silv_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_silv_rec.DATE_START,
              l_silv_rec.DATE_LENDING,
              l_silv_rec.INDEX_NUMBER,
              l_silv_rec.SIF_ID,
              l_silv_rec.OBJECT_VERSION_NUMBER,
              l_silv_rec.KLE_ID,
              l_silv_rec.SIL_TYPE,
              l_silv_rec.DESCRIPTION,
              l_silv_rec.CREATED_BY,
              l_silv_rec.LAST_UPDATED_BY,
              l_silv_rec.CREATION_DATE,
              l_silv_rec.LAST_UPDATE_DATE,
              l_silv_rec.LAST_UPDATE_LOGIN,
              -- mvasudev , 05/13/2002
              l_silv_rec.RESIDUAL_GUARANTEE_TYPE,
              l_silv_rec.RESIDUAL_DATE,
              l_silv_rec.DOWN_PAYMENT_AMOUNT,
              l_silv_rec.CAPITALIZE_DOWN_PAYMENT_YN,
			  l_silv_rec.orig_contract_line_id;
    x_no_data_found := silv_pk_csr%NOTFOUND;
    CLOSE silv_pk_csr;
    RETURN(l_silv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_silv_rec                     IN silv_rec_type
  ) RETURN silv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_silv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_LINES_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_silv_rec	IN silv_rec_type
  ) RETURN silv_rec_type IS
    l_silv_rec	silv_rec_type := p_silv_rec;
  BEGIN
    IF (l_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT := NULL;
    END IF;
    IF (l_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT := NULL;
    END IF;
    IF (l_silv_rec.residual_guarantee_method = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.residual_guarantee_method := NULL;
    END IF;
    -- mvasudev , 05/13/2002
    IF (l_silv_rec.residual_guarantee_type = OKC_API.G_MISS_CHAR) THEN
          l_silv_rec.residual_guarantee_type := NULL;
    END IF;
    IF (l_silv_rec.residual_date = OKC_API.G_MISS_DATE) THEN
          l_silv_rec.residual_date := NULL;
    END IF;
    IF (l_silv_rec.fed_depre_term = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.fed_depre_term := NULL;
    END IF;
    IF (l_silv_rec.fed_depre_dmnshing_value_rate = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.fed_depre_dmnshing_value_rate := NULL;
    END IF;
    IF (l_silv_rec.fed_depre_adr_conve = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.fed_depre_adr_conve := NULL;
    END IF;
    IF (l_silv_rec.state_depre_basis_percent = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.state_depre_basis_percent := NULL;
    END IF;
    IF (l_silv_rec.state_depre_method = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.state_depre_method := NULL;
    END IF;
    IF (l_silv_rec.purchase_option = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.purchase_option := NULL;
    END IF;
    IF (l_silv_rec.purchase_option_amount = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.purchase_option_amount := NULL;
    END IF;
    IF (l_silv_rec.asset_cost = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.asset_cost := NULL;
    END IF;
    IF (l_silv_rec.state_depre_term = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.state_depre_term := NULL;
    END IF;
    IF (l_silv_rec.state_depre_adr_convent = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.state_depre_adr_convent := NULL;
    END IF;
    IF (l_silv_rec.fed_depre_method = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.fed_depre_method := NULL;
    END IF;
    IF (l_silv_rec.residual_amount = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.residual_amount := NULL;
    END IF;
    IF (l_silv_rec.fed_depre_salvage = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.fed_depre_salvage := NULL;
    END IF;
    IF (l_silv_rec.date_fed_depre = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_fed_depre := NULL;
    END IF;
    IF (l_silv_rec.book_salvage = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.book_salvage := NULL;
    END IF;
    IF (l_silv_rec.book_adr_convention = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.book_adr_convention := NULL;
    END IF;
    IF (l_silv_rec.state_depre_salvage = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.state_depre_salvage := NULL;
    END IF;
    IF (l_silv_rec.fed_depre_basis_percent = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.fed_depre_basis_percent := NULL;
    END IF;
    IF (l_silv_rec.book_basis_percent = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.book_basis_percent := NULL;
    END IF;
    IF (l_silv_rec.date_delivery = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_delivery := NULL;
    END IF;
    IF (l_silv_rec.book_term = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.book_term := NULL;
    END IF;
    IF (l_silv_rec.residual_guarantee_amount = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.residual_guarantee_amount := NULL;
    END IF;
    IF (l_silv_rec.date_funding = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_funding := NULL;
    END IF;
    IF (l_silv_rec.date_book = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_book := NULL;
    END IF;
    IF (l_silv_rec.date_state_depre = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_state_depre := NULL;
    END IF;
    IF (l_silv_rec.book_method = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.book_method := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_silv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.stream_interface_attribute15 := NULL;
    END IF;
    IF (l_silv_rec.date_start = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_start := NULL;
    END IF;
    IF (l_silv_rec.date_lending = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.date_lending := NULL;
    END IF;
    IF (l_silv_rec.index_number = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.index_number := NULL;
    END IF;
    IF (l_silv_rec.sif_id = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.sif_id := NULL;
    END IF;
    IF (l_silv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.object_version_number := NULL;
    END IF;
    IF (l_silv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.kle_id := NULL;
    END IF;
    IF (l_silv_rec.sil_type = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.sil_type := NULL;
    END IF;
    IF (l_silv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.description := NULL;
    END IF;
    IF (l_silv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.created_by := NULL;
    END IF;
    IF (l_silv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.last_updated_by := NULL;
    END IF;
    IF (l_silv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.creation_date := NULL;
    END IF;
    IF (l_silv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_silv_rec.last_update_date := NULL;
    END IF;
    IF (l_silv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.last_update_login := NULL;
    END IF;
    IF (l_silv_rec.down_payment_amount = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.down_payment_amount := NULL;
    END IF;
    IF (l_silv_rec.capitalize_down_payment_yn = OKC_API.G_MISS_CHAR) THEN
      l_silv_rec.capitalize_down_payment_yn := NULL;
    END IF;

    IF (l_silv_rec.orig_contract_line_id = OKC_API.G_MISS_NUM) THEN
      l_silv_rec.orig_contract_line_id := NULL;
    END IF;

    RETURN(l_silv_rec);

  END null_out_defaults;

  -- START change : mvasudev , 08/15/2001
  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_SIF_LINES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_silv_rec IN  silv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_silv_rec.id = OKC_API.G_MISS_NUM OR
       p_silv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_silv_rec.index_number = OKC_API.G_MISS_NUM OR
          p_silv_rec.index_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'index_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_silv_rec.sif_id = OKC_API.G_MISS_NUM OR
          p_silv_rec.sif_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sif_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_silv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_silv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_silv_rec.kle_id = OKC_API.G_MISS_NUM OR
          p_silv_rec.kle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'kle_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_silv_rec.sil_type = OKC_API.G_MISS_CHAR OR
          p_silv_rec.sil_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sil_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/

/**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.id = Okc_Api.G_MISS_NUM OR
      p_silv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_silv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Index_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Index_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Index_Number(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.index_number = Okc_Api.G_MISS_NUM OR
      p_silv_rec.index_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'index_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Index_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sil_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sil_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sil_Type(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
    l_found VARCHAR2(1);
  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Sil_type = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.Sil_type IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sil_type');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
	--Check if sil_type exists in the fnd_common_lookups or not
	l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_SIL_TYPE',
						    p_lookup_code => p_silv_rec.sil_type);


	IF (l_found <> OKL_API.G_TRUE ) THEN
     OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SIL_TYPE');
	     x_return_status := Okc_Api.G_RET_STS_ERROR;
		 -- raise the exception as there's no matching foreign key value
		 RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;


    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sil_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sif_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sif_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sif_Id(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIL_SIF_FK;
  CURSOR okl_sifv_pk_csr (p_id IN OKL_SIF_STREAM_TYPES_V.sif_id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAM_INTERFACES_V
   WHERE OKL_STREAM_INTERFACES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.sif_id = Okc_Api.G_MISS_NUM OR
       p_silv_rec.sif_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sif_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sifv_pk_csr(p_silv_rec.Sif_id);
    FETCH okl_sifv_pk_csr INTO l_dummy;
    l_row_not_found := okl_sifv_pk_csr%NOTFOUND;
    CLOSE okl_sifv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sif_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_sifv_pk_csr%ISOPEN THEN
        CLOSE okl_sifv_pk_csr;
      END IF;

  END Validate_Sif_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Kle_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Kle_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Kle_Id(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIL_KLE_FK;
  CURSOR okl_klev_pk_csr (p_id IN OKL_SIF_LINES_V.kle_id%TYPE) IS
  SELECT '1'
    FROM OKL_K_LINES_V
   WHERE OKL_K_LINES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.kle_id = Okc_Api.G_MISS_NUM OR
       p_silv_rec.kle_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Kle_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_klev_pk_csr(p_silv_rec.kle_id);
    FETCH okl_klev_pk_csr INTO l_dummy;
    l_row_not_found := okl_klev_pk_csr%NOTFOUND;
    CLOSE okl_klev_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Kle_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_klev_pk_csr%ISOPEN THEN
        CLOSE okl_klev_pk_csr;
      END IF;

  END Validate_Kle_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_State_Depr_Dim_Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_State_Depr_Dim_Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_State_Depr_Dim_Value(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT = Okc_Api.G_MISS_NUM OR
       p_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'STATE_DEPRE_DMNSHING_VALUE_RT');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_State_Depr_Dim_Value;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Book_Depr_Dim_Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Book_Depr_Dim_Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Book_Depr_Dim_Value(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT = Okc_Api.G_MISS_NUM OR
       p_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'BOOK_DEPRE_DMNSHING_VALUE_RT');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Book_Depr_Dim_Value;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Residual_Guarantee
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Residual_Guarantee
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Residual_Guarantee(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Residual_Guarantee_Method = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.Residual_Guarantee_Method IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Residual_Guarantee_Method');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Residual_Guarantee;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fed_Depre_Term
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fed_Depre_Term
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fed_Depre_Term(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Fed_Depre_Term = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Fed_Depre_Term IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fed_Depre_Term');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fed_Depre_Term;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fed_Depre_Dim_Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fed_Depre_Dim_Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fed_Depre_Dim_Value(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Fed_Depre_DmnShing_Value_Rate = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Fed_Depre_DmnShing_Value_Rate IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fed_Depre_DmnShing_Value_Rate');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fed_Depre_Dim_Value;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fed_Depre_Adr
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fed_Depre_Adr
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fed_Depre_Adr(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Fed_Depre_Adr_Conve = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.Fed_Depre_Adr_Conve IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fed_Depre_Adr_Conve');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fed_Depre_Adr;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_State_Depre_Basis
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_State_Depre_Basis
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_State_Depre_Basis(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.State_Depre_Basis_Percent = Okc_Api.G_MISS_NUM OR
       p_silv_rec.State_Depre_Basis_Percent IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'State_Depre_Basis_Percent');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_State_Depre_Basis;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_State_Depre_Method
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_State_Depre_Method
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_State_Depre_Method(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.State_Depre_Method = Okc_Api.G_MISS_CHAR  OR
       p_silv_rec.State_Depre_Method IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'State_Depre_Method');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_State_Depre_Method;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Purchase_Option
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Purchase_Option
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Purchase_Option(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Purchase_Option = Okc_Api.G_MISS_CHAR  OR
       p_silv_rec.Purchase_Option IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Purchase_Option');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Purchase_Option;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Asset_Cost
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Asset_Cost
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Asset_Cost(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Asset_Cost = Okc_Api.G_MISS_NUM  OR
       p_silv_rec.Asset_Cost IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Asset_Cost');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Asset_Cost;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_State_Depre_Term
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_State_Depre_Term
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_State_Depre_Term(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.State_Depre_Term = Okc_Api.G_MISS_NUM OR
       p_silv_rec.State_Depre_Term IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'State_Depre_Term');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_State_Depre_Term;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_State_Depre_Adr
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_State_Depre_Adr
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_State_Depre_Adr(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.State_Depre_Adr_Convent = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.State_Depre_Adr_Convent IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'State_Depre_Adr_Convent');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_State_Depre_Adr;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fed_Depre_Method
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fed_Depre_Method
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fed_Depre_Method(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Fed_Depre_Method = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.Fed_Depre_Method IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fed_Depre_Method');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fed_Depre_Method;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Residual_Amount
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Residual_Amount
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Residual_Amount(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Residual_Amount = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Residual_Amount IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Residual_Amount');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Residual_Amount;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fed_Depre_Salvage
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fed_Depre_Salvage
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fed_Depre_Salvage(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Fed_Depre_Salvage = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Fed_Depre_Salvage IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fed_Depre_Salvage');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fed_Depre_Salvage;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Fed_Depre
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Fed_Depre
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Fed_Depre(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Date_Fed_Depre = Okc_Api.G_MISS_DATE OR
       p_silv_rec.Date_Fed_Depre IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Fed_Depre');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Fed_Depre;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Book_Salvage
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Book_Salvage
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Book_Salvage(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Book_Salvage = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Book_Salvage IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Book_Salvage');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Book_Salvage;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Book_Adr_Convention
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Book_Adr_Convention
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Book_Adr_Convention(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Book_Adr_Convention = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.Book_Adr_Convention IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Book_Adr_Convention');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Book_Adr_Convention;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_State_Depre_Salvage
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_State_Depre_Salvage
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_State_Depre_Salvage(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.State_Depre_Salvage = Okc_Api.G_MISS_NUM OR
       p_silv_rec.State_Depre_Salvage IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'State_Depre_Salvage');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_State_Depre_Salvage;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fed_Depr_Basis
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fed_Depr_Basis
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fed_Depr_Basis(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Fed_Depre_Basis_Percent = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Fed_Depre_Basis_Percent IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fed_Depre_Basis_Percent');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fed_Depr_Basis;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Book_Basis_Percent
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Book_Basis_Percent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Book_Basis_Percent(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Book_Basis_Percent = Okc_Api.G_MISS_NUM OR
       p_silv_rec.Book_Basis_Percent IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Book_Basis_Percent');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Book_Basis_Percent;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Delivery
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Delivery
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Delivery(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Date_Delivery = Okc_Api.G_MISS_DATE OR
       p_silv_rec.Date_Delivery IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Delivery');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Delivery;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Funding
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Funding
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Funding(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Date_Funding = Okc_Api.G_MISS_DATE OR
       p_silv_rec.Date_Funding IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Funding');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Funding;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Book
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Book
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Book(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Date_Book = Okc_Api.G_MISS_DATE OR
       p_silv_rec.Date_Book IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Book');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Book;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_State_Depre
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_State_Depre
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_State_Depre(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Date_State_Depre = Okc_Api.G_MISS_DATE OR
       p_silv_rec.Date_State_Depre IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_State_Depre');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_State_Depre;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Book_Method
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Book_Method
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Book_Method(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_silv_rec.Book_Method = Okc_Api.G_MISS_CHAR OR
       p_silv_rec.Book_Method IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Book_Method');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Book_Method;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Lending
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Lending
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Lending(
    p_silv_rec      IN   silv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- 04/23/2002, mvasudev
    /*
    IF p_silv_rec.Date_Lending = Okc_Api.G_MISS_DATE OR
       p_silv_rec.Date_Lending IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Lending');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */
    -- end, 04/23/2002, mvasudev
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Lending;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_silv_rec IN  silv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_silv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_silv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Index_Number
    Validate_Index_Number(p_silv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sif_id
    Validate_Sif_id(p_silv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Kle_Id
    Validate_Kle_Id(p_silv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sil_Type
    Validate_Sil_Type(p_silv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    IF (p_silv_rec.Sil_Type = G_SIL_TYPE_LEASE)
    THEN

	    -- Validate_Residual_Guarantee
	    Validate_Residual_Guarantee(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Purchase_Option
	    Validate_Purchase_Option(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Asset_Cost
	    Validate_Asset_Cost(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Residual_Amount
	    Validate_Residual_Amount(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;


	    -- Validate_Date_Delivery
	    Validate_Date_Delivery(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Date_Funding
	    Validate_Date_Funding(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    /*
	    -- mvasudev, 07/16/2002
	    --  Commented out to make "Depreciation Details" optional

	    -- Validate_State_Depr_Dim_Value
	    Validate_State_Depr_Dim_Value(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Book_Depr_Dim_Value
	    Validate_Book_Depr_Dim_Value(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;



	    -- Validate_Fed_Depre_Term
	    Validate_Fed_Depre_Term(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Fed_Depre_Dim_Value
	    Validate_Fed_Depre_Dim_Value(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Fed_Depre_Adr
	    Validate_Fed_Depre_Adr(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_State_Depre_Basis
	    Validate_State_Depre_Basis(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_State_Depre_Method
	    Validate_State_Depre_Method(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Book_Depr_Dim_Value
	    Validate_Book_Depr_Dim_Value(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_State_Depre_Term
	    Validate_State_Depre_Term(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_State_Depre_Adr
	    Validate_State_Depre_Adr(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Fed_Depre_Method
	    Validate_Fed_Depre_Method(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Fed_Depre_Salvage
	    Validate_Fed_Depre_Salvage(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Date_Fed_Depre
	    Validate_Date_Fed_Depre(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Book_Salvage
	    Validate_Book_Salvage(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Book_Adr_Convention
	    Validate_Book_Adr_Convention(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_State_Depre_Salvage
	    Validate_State_Depre_Salvage(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Fed_Depr_Basis
	    Validate_Fed_Depr_Basis(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Book_Basis_Percent
	    Validate_Book_Basis_Percent(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Date_Book
	    Validate_Date_Book(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Date_State_Depre
	    Validate_Date_State_Depre(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Book_Method
	    Validate_Book_Method(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;
	    */

    ELSIF (p_silv_rec.Sil_Type = G_SIL_TYPE_LOAN)
    THEN
	    -- Validate_Date_Lending
	    Validate_Date_Lending(p_silv_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;
    END IF;

  RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                           p_token1           => G_OKL_SQLCODE_TOKEN,
                           p_token1_value     => SQLCODE,
                           p_token2           => G_OKL_SQLERRM_TOKEN,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate_Record for:OKL_SIF_LINES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_silv_rec IN silv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN silv_rec_type,
    -- p_to	OUT NOCOPY sil_rec_type
    p_to	IN OUT NOCOPY sil_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.STATE_DEPRE_DMNSHING_VALUE_RT := p_from.STATE_DEPRE_DMNSHING_VALUE_RT;
    p_to.BOOK_DEPRE_DMNSHING_VALUE_RT := p_from.BOOK_DEPRE_DMNSHING_VALUE_RT;
    p_to.residual_guarantee_method := p_from.residual_guarantee_method;
    p_to.fed_depre_term := p_from.fed_depre_term;
    p_to.fed_depre_dmnshing_value_rate := p_from.fed_depre_dmnshing_value_rate;
    p_to.fed_depre_adr_conve := p_from.fed_depre_adr_conve;
    p_to.state_depre_basis_percent := p_from.state_depre_basis_percent;
    p_to.state_depre_method := p_from.state_depre_method;
    p_to.purchase_option := p_from.purchase_option;
    p_to.purchase_option_amount := p_from.purchase_option_amount;
    p_to.asset_cost := p_from.asset_cost;
    p_to.state_depre_term := p_from.state_depre_term;
    p_to.state_depre_adr_convent := p_from.state_depre_adr_convent;
    p_to.fed_depre_method := p_from.fed_depre_method;
    p_to.residual_amount := p_from.residual_amount;
    p_to.fed_depre_salvage := p_from.fed_depre_salvage;
    p_to.date_fed_depre := p_from.date_fed_depre;
    p_to.book_salvage := p_from.book_salvage;
    p_to.book_adr_convention := p_from.book_adr_convention;
    p_to.state_depre_salvage := p_from.state_depre_salvage;
    p_to.fed_depre_basis_percent := p_from.Fed_Depre_Basis_Percent;
    p_to.book_basis_percent := p_from.book_basis_percent;
    p_to.date_delivery := p_from.date_delivery;
    p_to.book_term := p_from.book_term;
    p_to.residual_guarantee_amount := p_from.residual_guarantee_amount;
    p_to.date_funding := p_from.date_funding;
    p_to.date_book := p_from.date_book;
    p_to.date_state_depre := p_from.date_state_depre;
    p_to.book_method := p_from.book_method;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.index_number := p_from.index_number;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.description := p_from.description;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.date_start := p_from.date_start;
    p_to.date_lending := p_from.date_lending;
    p_to.sif_id := p_from.sif_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.kle_id := p_from.kle_id;
    p_to.sil_type := p_from.sil_type;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    -- mvasudev , 05/13/2002
    p_to.residual_guarantee_type := p_from.residual_guarantee_type;
    p_to.residual_date := p_from.residual_date;
    p_to.down_payment_amount := p_from.down_payment_amount;
    p_to.capitalize_down_payment_yn	:= p_from.capitalize_down_payment_yn;
    p_to.orig_contract_line_id := p_from.orig_contract_line_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sil_rec_type,
    --p_to	OUT NOCOPY silv_rec_type
    p_to	IN OUT NOCOPY silv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.STATE_DEPRE_DMNSHING_VALUE_RT := p_from.STATE_DEPRE_DMNSHING_VALUE_RT;
    p_to.BOOK_DEPRE_DMNSHING_VALUE_RT := p_from.BOOK_DEPRE_DMNSHING_VALUE_RT;
    p_to.residual_guarantee_method := p_from.residual_guarantee_method;
    p_to.fed_depre_term := p_from.fed_depre_term;
    p_to.fed_depre_dmnshing_value_rate := p_from.fed_depre_dmnshing_value_rate;
    p_to.fed_depre_adr_conve := p_from.fed_depre_adr_conve;
    p_to.state_depre_basis_percent := p_from.state_depre_basis_percent;
    p_to.state_depre_method := p_from.state_depre_method;
    p_to.purchase_option := p_from.purchase_option;
    p_to.purchase_option_amount := p_from.purchase_option_amount;
    p_to.asset_cost := p_from.asset_cost;
    p_to.state_depre_term := p_from.state_depre_term;
    p_to.state_depre_adr_convent := p_from.state_depre_adr_convent;
    p_to.fed_depre_method := p_from.fed_depre_method;
    p_to.residual_amount := p_from.residual_amount;
    p_to.fed_depre_salvage := p_from.fed_depre_salvage;
    p_to.date_fed_depre := p_from.date_fed_depre;
    p_to.book_salvage := p_from.book_salvage;
    p_to.book_adr_convention := p_from.book_adr_convention;
    p_to.state_depre_salvage := p_from.state_depre_salvage;
    p_to.fed_depre_basis_percent := p_from.Fed_Depre_Basis_Percent;
    p_to.book_basis_percent := p_from.book_basis_percent;
    p_to.date_delivery := p_from.date_delivery;
    p_to.book_term := p_from.book_term;
    p_to.residual_guarantee_amount := p_from.residual_guarantee_amount;
    p_to.date_funding := p_from.date_funding;
    p_to.date_book := p_from.date_book;
    p_to.date_state_depre := p_from.date_state_depre;
    p_to.book_method := p_from.book_method;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.index_number := p_from.index_number;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.description := p_from.description;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.date_start := p_from.date_start;
    p_to.date_lending := p_from.date_lending;
    p_to.sif_id := p_from.sif_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.kle_id := p_from.kle_id;
    p_to.sil_type := p_from.sil_type;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    -- mvasudev , 05/13/2002
    p_to.residual_date := p_from.residual_date;
    p_to.down_payment_amount := p_from.down_payment_amount;
    p_to.capitalize_down_payment_yn	:= p_from.capitalize_down_payment_yn;
    p_to.orig_contract_line_id	:= p_from.orig_contract_line_id;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_SIF_LINES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_silv_rec                     silv_rec_type := p_silv_rec;
    l_sil_rec                      sil_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_silv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_silv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:SILV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_silv_tbl.COUNT > 0) THEN
      i := p_silv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_silv_rec                     => p_silv_tbl(i));
    	-- START change : mvasudev, 08/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_silv_tbl.LAST);
        i := p_silv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- insert_row for:OKL_SIF_LINES --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sil_rec                      IN sil_rec_type,
    x_sil_rec                      OUT NOCOPY sil_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sil_rec                      sil_rec_type := p_sil_rec;
    l_def_sil_rec                  sil_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKL_SIF_LINES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_sil_rec IN  sil_rec_type,
      x_sil_rec OUT NOCOPY sil_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sil_rec := p_sil_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sil_rec,                         -- IN
      l_sil_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_LINES(
        id,
        STATE_DEPRE_DMNSHING_VALUE_RT,
        BOOK_DEPRE_DMNSHING_VALUE_RT,
        residual_guarantee_method,
        fed_depre_term,
        fed_depre_dmnshing_value_rate,
        fed_depre_adr_conve,
        state_depre_basis_percent,
        state_depre_method,
        purchase_option,
        purchase_option_amount,
        asset_cost,
        state_depre_term,
        state_depre_adr_convent,
        fed_depre_method,
        residual_amount,
        fed_depre_salvage,
        date_fed_depre,
        book_salvage,
        book_adr_convention,
        state_depre_salvage,
        fed_depre_basis_percent,
        book_basis_percent,
        date_delivery,
        book_term,
        residual_guarantee_amount,
        date_funding,
        date_book,
        date_state_depre,
        book_method,
        stream_interface_attribute08,
        stream_interface_attribute03,
        stream_interface_attribute01,
        index_number,
        stream_interface_attribute05,
        description,
        stream_interface_attribute10,
        stream_interface_attribute06,
        stream_interface_attribute09,
        stream_interface_attribute07,
        stream_interface_attribute14,
        stream_interface_attribute12,
        stream_interface_attribute15,
        stream_interface_attribute02,
        stream_interface_attribute11,
        stream_interface_attribute04,
        stream_interface_attribute13,
        date_start,
        date_lending,
        sif_id,
        object_version_number,
        kle_id,
        sil_type,
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login,
        -- mvasudev , 05/13/2002
        residual_guarantee_type,
        residual_date,
        down_payment_amount,
        capitalize_down_payment_yn,
		orig_contract_line_id)
      VALUES (
        l_sil_rec.id,
        l_sil_rec.STATE_DEPRE_DMNSHING_VALUE_RT,
        l_sil_rec.BOOK_DEPRE_DMNSHING_VALUE_RT,
        l_sil_rec.residual_guarantee_method,
        l_sil_rec.fed_depre_term,
        l_sil_rec.fed_depre_dmnshing_value_rate,
        l_sil_rec.fed_depre_adr_conve,
        l_sil_rec.state_depre_basis_percent,
        l_sil_rec.state_depre_method,
        l_sil_rec.purchase_option,
        l_sil_rec.purchase_option_amount,
        l_sil_rec.asset_cost,
        l_sil_rec.state_depre_term,
        l_sil_rec.state_depre_adr_convent,
        l_sil_rec.fed_depre_method,
        l_sil_rec.residual_amount,
        l_sil_rec.fed_depre_salvage,
        l_sil_rec.date_fed_depre,
        l_sil_rec.book_salvage,
        l_sil_rec.book_adr_convention,
        l_sil_rec.state_depre_salvage,
        l_sil_rec.fed_depre_basis_percent,
        l_sil_rec.book_basis_percent,
        l_sil_rec.date_delivery,
        l_sil_rec.book_term,
        l_sil_rec.residual_guarantee_amount,
        l_sil_rec.date_funding,
        l_sil_rec.date_book,
        l_sil_rec.date_state_depre,
        l_sil_rec.book_method,
        l_sil_rec.stream_interface_attribute08,
        l_sil_rec.stream_interface_attribute03,
        l_sil_rec.stream_interface_attribute01,
        l_sil_rec.index_number,
        l_sil_rec.stream_interface_attribute05,
        l_sil_rec.description,
        l_sil_rec.stream_interface_attribute10,
        l_sil_rec.stream_interface_attribute06,
        l_sil_rec.stream_interface_attribute09,
        l_sil_rec.stream_interface_attribute07,
        l_sil_rec.stream_interface_attribute14,
        l_sil_rec.stream_interface_attribute12,
        l_sil_rec.stream_interface_attribute15,
        l_sil_rec.stream_interface_attribute02,
        l_sil_rec.stream_interface_attribute11,
        l_sil_rec.stream_interface_attribute04,
        l_sil_rec.stream_interface_attribute13,
        l_sil_rec.date_start,
        l_sil_rec.date_lending,
        l_sil_rec.sif_id,
        l_sil_rec.object_version_number,
        l_sil_rec.kle_id,
        l_sil_rec.sil_type,
        l_sil_rec.created_by,
        l_sil_rec.last_updated_by,
        l_sil_rec.creation_date,
        l_sil_rec.last_update_date,
        l_sil_rec.last_update_login,
        -- mvasudev , 05/13/2002
        l_sil_rec.residual_guarantee_type,
        l_sil_rec.residual_date,
        l_sil_rec.down_payment_amount,
        l_sil_rec.capitalize_down_payment_yn,
		l_sil_rec.orig_contract_line_id);
    -- Set OUT values
    x_sil_rec := l_sil_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------
  -- insert_row for:OKL_SIF_LINES_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_silv_rec                     silv_rec_type;
    l_def_silv_rec                 silv_rec_type;
    l_sil_rec                      sil_rec_type;
    lx_sil_rec                     sil_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_silv_rec	IN silv_rec_type
    ) RETURN silv_rec_type IS
      l_silv_rec	silv_rec_type := p_silv_rec;
    BEGIN
      l_silv_rec.CREATION_DATE := SYSDATE;
      l_silv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_silv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_silv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_silv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_silv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_SIF_LINES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_silv_rec IN  silv_rec_type,
      x_silv_rec OUT NOCOPY silv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_silv_rec := p_silv_rec;
      x_silv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_silv_rec := null_out_defaults(p_silv_rec);
    -- Set primary key value
    l_silv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_silv_rec,                        -- IN
      l_def_silv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_silv_rec := fill_who_columns(l_def_silv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_silv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_silv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_silv_rec, l_sil_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sil_rec,
      lx_sil_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sil_rec, l_def_silv_rec);
    -- Set OUT values
    x_silv_rec := l_def_silv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:SILV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_silv_tbl.COUNT > 0) THEN
      i := p_silv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_silv_rec                     => p_silv_tbl(i),
          x_silv_rec                     => x_silv_tbl(i));
    	-- START change : mvasudev, 08/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev

        EXIT WHEN (i = p_silv_tbl.LAST);
        i := p_silv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------
  -- lock_row for:OKL_SIF_LINES --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sil_rec                      IN sil_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sil_rec IN sil_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_LINES
     WHERE ID = p_sil_rec.id
       AND OBJECT_VERSION_NUMBER = p_sil_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sil_rec IN sil_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_LINES
    WHERE ID = p_sil_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_LINES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_sil_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_sil_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sil_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sil_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_OKC_APP,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------
  -- lock_row for:OKL_SIF_LINES_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sil_rec                      sil_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_silv_rec, l_sil_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sil_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:SILV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_silv_tbl.COUNT > 0) THEN
      i := p_silv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_silv_rec                     => p_silv_tbl(i));
    	-- START change : mvasudev, 08/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_silv_tbl.LAST);
        i := p_silv_tbl.NEXT(i);
      -- START change : mvasudev, 08/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- update_row for:OKL_SIF_LINES --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sil_rec                      IN sil_rec_type,
    x_sil_rec                      OUT NOCOPY sil_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sil_rec                      sil_rec_type := p_sil_rec;
    l_def_sil_rec                  sil_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sil_rec	IN sil_rec_type,
      x_sil_rec	OUT NOCOPY sil_rec_type
    ) RETURN VARCHAR2 IS
      l_sil_rec                      sil_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sil_rec := p_sil_rec;
      -- Get current database values
      l_sil_rec := get_rec(p_sil_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sil_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.id := l_sil_rec.id;
      END IF;
      IF (x_sil_rec.STATE_DEPRE_DMNSHING_VALUE_RT = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.STATE_DEPRE_DMNSHING_VALUE_RT := l_sil_rec.STATE_DEPRE_DMNSHING_VALUE_RT;
      END IF;
      IF (x_sil_rec.BOOK_DEPRE_DMNSHING_VALUE_RT = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.BOOK_DEPRE_DMNSHING_VALUE_RT := l_sil_rec.BOOK_DEPRE_DMNSHING_VALUE_RT;
      END IF;
      IF (x_sil_rec.residual_guarantee_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.residual_guarantee_method := l_sil_rec.residual_guarantee_method;
      END IF;
      -- mvasudev , 05/13/2002
      IF (x_sil_rec.residual_guarantee_type = OKC_API.G_MISS_CHAR)
            THEN
              x_sil_rec.residual_guarantee_type := l_sil_rec.residual_guarantee_type;
      END IF;
      IF (x_sil_rec.residual_date = OKC_API.G_MISS_DATE)
            THEN
              x_sil_rec.residual_date := l_sil_rec.residual_date;
      END IF;
      IF (x_sil_rec.fed_depre_term = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.fed_depre_term := l_sil_rec.fed_depre_term;
      END IF;
      IF (x_sil_rec.fed_depre_dmnshing_value_rate = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.fed_depre_dmnshing_value_rate := l_sil_rec.fed_depre_dmnshing_value_rate;
      END IF;
      IF (x_sil_rec.fed_depre_adr_conve = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.fed_depre_adr_conve := l_sil_rec.fed_depre_adr_conve;
      END IF;
      IF (x_sil_rec.state_depre_basis_percent = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.state_depre_basis_percent := l_sil_rec.state_depre_basis_percent;
      END IF;
      IF (x_sil_rec.state_depre_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.state_depre_method := l_sil_rec.state_depre_method;
      END IF;
      IF (x_sil_rec.purchase_option = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.purchase_option := l_sil_rec.purchase_option;
      END IF;
      IF (x_sil_rec.purchase_option_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.purchase_option_amount := l_sil_rec.purchase_option_amount;
      END IF;
      IF (x_sil_rec.asset_cost = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.asset_cost := l_sil_rec.asset_cost;
      END IF;
      IF (x_sil_rec.state_depre_term = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.state_depre_term := l_sil_rec.state_depre_term;
      END IF;
      IF (x_sil_rec.state_depre_adr_convent = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.state_depre_adr_convent := l_sil_rec.state_depre_adr_convent;
      END IF;
      IF (x_sil_rec.fed_depre_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.fed_depre_method := l_sil_rec.fed_depre_method;
      END IF;
      IF (x_sil_rec.residual_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.residual_amount := l_sil_rec.residual_amount;
      END IF;
      IF (x_sil_rec.fed_depre_salvage = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.fed_depre_salvage := l_sil_rec.fed_depre_salvage;
      END IF;
      IF (x_sil_rec.date_fed_depre = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_fed_depre := l_sil_rec.date_fed_depre;
      END IF;
      IF (x_sil_rec.book_salvage = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.book_salvage := l_sil_rec.book_salvage;
      END IF;
      IF (x_sil_rec.book_adr_convention = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.book_adr_convention := l_sil_rec.book_adr_convention;
      END IF;
      IF (x_sil_rec.state_depre_salvage = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.state_depre_salvage := l_sil_rec.state_depre_salvage;
      END IF;
      IF (x_sil_rec.fed_depre_basis_percent = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.fed_depre_basis_percent := l_sil_rec.fed_depre_basis_percent;
      END IF;
      IF (x_sil_rec.book_basis_percent = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.book_basis_percent := l_sil_rec.book_basis_percent;
      END IF;
      IF (x_sil_rec.date_delivery = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_delivery := l_sil_rec.date_delivery;
      END IF;
      IF (x_sil_rec.book_term = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.book_term := l_sil_rec.book_term;
      END IF;
      IF (x_sil_rec.residual_guarantee_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.residual_guarantee_amount := l_sil_rec.residual_guarantee_amount;
      END IF;
      IF (x_sil_rec.date_funding = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_funding := l_sil_rec.date_funding;
      END IF;
      IF (x_sil_rec.date_book = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_book := l_sil_rec.date_book;
      END IF;
      IF (x_sil_rec.date_state_depre = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_state_depre := l_sil_rec.date_state_depre;
      END IF;
      IF (x_sil_rec.book_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.book_method := l_sil_rec.book_method;
      END IF;
      IF (x_sil_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute08 := l_sil_rec.stream_interface_attribute08;
      END IF;
      IF (x_sil_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute03 := l_sil_rec.stream_interface_attribute03;
      END IF;
      IF (x_sil_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute01 := l_sil_rec.stream_interface_attribute01;
      END IF;
      IF (x_sil_rec.index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.index_number := l_sil_rec.index_number;
      END IF;
      IF (x_sil_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute05 := l_sil_rec.stream_interface_attribute05;
      END IF;
      IF (x_sil_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.description := l_sil_rec.description;
      END IF;
      IF (x_sil_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute10 := l_sil_rec.stream_interface_attribute10;
      END IF;
      IF (x_sil_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute06 := l_sil_rec.stream_interface_attribute06;
      END IF;
      IF (x_sil_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute09 := l_sil_rec.stream_interface_attribute09;
      END IF;
      IF (x_sil_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute07 := l_sil_rec.stream_interface_attribute07;
      END IF;
      IF (x_sil_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute14 := l_sil_rec.stream_interface_attribute14;
      END IF;
      IF (x_sil_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute12 := l_sil_rec.stream_interface_attribute12;
      END IF;
      IF (x_sil_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute15 := l_sil_rec.stream_interface_attribute15;
      END IF;
      IF (x_sil_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute02 := l_sil_rec.stream_interface_attribute02;
      END IF;
      IF (x_sil_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute11 := l_sil_rec.stream_interface_attribute11;
      END IF;
      IF (x_sil_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute04 := l_sil_rec.stream_interface_attribute04;
      END IF;
      IF (x_sil_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.stream_interface_attribute13 := l_sil_rec.stream_interface_attribute13;
      END IF;
      IF (x_sil_rec.date_start = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_start := l_sil_rec.date_start;
      END IF;
      IF (x_sil_rec.date_lending = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.date_lending := l_sil_rec.date_lending;
      END IF;
      IF (x_sil_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.sif_id := l_sil_rec.sif_id;
      END IF;
      IF (x_sil_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.object_version_number := l_sil_rec.object_version_number;
      END IF;
      IF (x_sil_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.kle_id := l_sil_rec.kle_id;
      END IF;
      IF (x_sil_rec.sil_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.sil_type := l_sil_rec.sil_type;
      END IF;
      IF (x_sil_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.created_by := l_sil_rec.created_by;
      END IF;
      IF (x_sil_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.last_updated_by := l_sil_rec.last_updated_by;
      END IF;
      IF (x_sil_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.creation_date := l_sil_rec.creation_date;
      END IF;
      IF (x_sil_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sil_rec.last_update_date := l_sil_rec.last_update_date;
      END IF;
      IF (x_sil_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.last_update_login := l_sil_rec.last_update_login;
      END IF;
      IF (x_sil_rec.down_payment_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.down_payment_amount := l_sil_rec.down_payment_amount;
      END IF;
      IF (x_sil_rec.capitalize_down_payment_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sil_rec.capitalize_down_payment_yn := l_sil_rec.capitalize_down_payment_yn;
      END IF;

       IF (x_sil_rec.orig_contract_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_sil_rec.orig_contract_line_id := l_sil_rec.orig_contract_line_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_SIF_LINES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_sil_rec IN  sil_rec_type,
      x_sil_rec OUT NOCOPY sil_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sil_rec := p_sil_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sil_rec,                         -- IN
      l_sil_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sil_rec, l_def_sil_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_LINES
    SET STATE_DEPRE_DMNSHING_VALUE_RT = l_def_sil_rec.STATE_DEPRE_DMNSHING_VALUE_RT,
        BOOK_DEPRE_DMNSHING_VALUE_RT = l_def_sil_rec.BOOK_DEPRE_DMNSHING_VALUE_RT,
        RESIDUAL_GUARANTEE_METHOD = l_def_sil_rec.residual_guarantee_method,
        -- mvasudev , 05/13/2002
        RESIDUAL_GUARANTEE_TYPE = l_def_sil_rec.residual_guarantee_type,
        RESIDUAL_DATE = l_def_sil_rec.residual_date,
        FED_DEPRE_TERM = l_def_sil_rec.fed_depre_term,
        FED_DEPRE_DMNSHING_VALUE_RATE = l_def_sil_rec.fed_depre_dmnshing_value_rate,
        FED_DEPRE_ADR_CONVE = l_def_sil_rec.fed_depre_adr_conve,
        STATE_DEPRE_BASIS_PERCENT = l_def_sil_rec.state_depre_basis_percent,
        STATE_DEPRE_METHOD = l_def_sil_rec.state_depre_method,
        PURCHASE_OPTION = l_def_sil_rec.purchase_option,
        PURCHASE_OPTION_AMOUNT = l_def_sil_rec.purchase_option_amount,
        ASSET_COST = l_def_sil_rec.asset_cost,
        STATE_DEPRE_TERM = l_def_sil_rec.state_depre_term,
        STATE_DEPRE_ADR_CONVENT = l_def_sil_rec.state_depre_adr_convent,
        FED_DEPRE_METHOD = l_def_sil_rec.fed_depre_method,
        RESIDUAL_AMOUNT = l_def_sil_rec.residual_amount,
        FED_DEPRE_SALVAGE = l_def_sil_rec.fed_depre_salvage,
        DATE_FED_DEPRE = l_def_sil_rec.date_fed_depre,
        BOOK_SALVAGE = l_def_sil_rec.book_salvage,
        BOOK_ADR_CONVENTION = l_def_sil_rec.book_adr_convention,
        STATE_DEPRE_SALVAGE = l_def_sil_rec.state_depre_salvage,
        FED_DEPRE_BASIS_PERCENT = l_def_sil_rec.fed_depre_basis_percent,
        BOOK_BASIS_PERCENT = l_def_sil_rec.book_basis_percent,
        DATE_DELIVERY = l_def_sil_rec.date_delivery,
        BOOK_TERM = l_def_sil_rec.book_term,
        RESIDUAL_GUARANTEE_AMOUNT = l_def_sil_rec.residual_guarantee_amount,
        DATE_FUNDING = l_def_sil_rec.date_funding,
        DATE_BOOK = l_def_sil_rec.date_book,
        DATE_STATE_DEPRE = l_def_sil_rec.date_state_depre,
        BOOK_METHOD = l_def_sil_rec.book_method,
        STREAM_INTERFACE_ATTRIBUTE08 = l_def_sil_rec.stream_interface_attribute08,
        STREAM_INTERFACE_ATTRIBUTE03 = l_def_sil_rec.stream_interface_attribute03,
        STREAM_INTERFACE_ATTRIBUTE01 = l_def_sil_rec.stream_interface_attribute01,
        INDEX_NUMBER = l_def_sil_rec.index_number,
        STREAM_INTERFACE_ATTRIBUTE05 = l_def_sil_rec.stream_interface_attribute05,
        DESCRIPTION = l_def_sil_rec.description,
        STREAM_INTERFACE_ATTRIBUTE10 = l_def_sil_rec.stream_interface_attribute10,
        STREAM_INTERFACE_ATTRIBUTE06 = l_def_sil_rec.stream_interface_attribute06,
        STREAM_INTERFACE_ATTRIBUTE09 = l_def_sil_rec.stream_interface_attribute09,
        STREAM_INTERFACE_ATTRIBUTE07 = l_def_sil_rec.stream_interface_attribute07,
        STREAM_INTERFACE_ATTRIBUTE14 = l_def_sil_rec.stream_interface_attribute14,
        STREAM_INTERFACE_ATTRIBUTE12 = l_def_sil_rec.stream_interface_attribute12,
        STREAM_INTERFACE_ATTRIBUTE15 = l_def_sil_rec.stream_interface_attribute15,
        STREAM_INTERFACE_ATTRIBUTE02 = l_def_sil_rec.stream_interface_attribute02,
        STREAM_INTERFACE_ATTRIBUTE11 = l_def_sil_rec.stream_interface_attribute11,
        STREAM_INTERFACE_ATTRIBUTE04 = l_def_sil_rec.stream_interface_attribute04,
        STREAM_INTERFACE_ATTRIBUTE13 = l_def_sil_rec.stream_interface_attribute13,
        DATE_START = l_def_sil_rec.date_start,
        DATE_LENDING = l_def_sil_rec.date_lending,
        SIF_ID = l_def_sil_rec.sif_id,
        OBJECT_VERSION_NUMBER = l_def_sil_rec.object_version_number,
        KLE_ID = l_def_sil_rec.kle_id,
        SIL_TYPE = l_def_sil_rec.sil_type,
        CREATED_BY = l_def_sil_rec.created_by,
        LAST_UPDATED_BY = l_def_sil_rec.last_updated_by,
        CREATION_DATE = l_def_sil_rec.creation_date,
        LAST_UPDATE_DATE = l_def_sil_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sil_rec.last_update_login,
        DOWN_PAYMENT_AMOUNT = l_def_sil_rec.down_payment_amount,
        CAPITALIZE_DOWN_PAYMENT_YN	= l_def_sil_rec.capitalize_down_payment_yn,
        orig_contract_line_id	= l_def_sil_rec.orig_contract_line_id
    WHERE ID = l_def_sil_rec.id;

    x_sil_rec := l_def_sil_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------
  -- update_row for:OKL_SIF_LINES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_silv_rec                     silv_rec_type := p_silv_rec;
    l_def_silv_rec                 silv_rec_type;
    l_sil_rec                      sil_rec_type;
    lx_sil_rec                     sil_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_silv_rec	IN silv_rec_type
    ) RETURN silv_rec_type IS
      l_silv_rec	silv_rec_type := p_silv_rec;
    BEGIN
      l_silv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_silv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_silv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_silv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_silv_rec	IN silv_rec_type,
      x_silv_rec	OUT NOCOPY silv_rec_type
    ) RETURN VARCHAR2 IS
      l_silv_rec                     silv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_silv_rec := p_silv_rec;
      -- Get current database values
      l_silv_rec := get_rec(p_silv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_silv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.id := l_silv_rec.id;
      END IF;
      IF (x_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT := l_silv_rec.STATE_DEPRE_DMNSHING_VALUE_RT;
      END IF;
      IF (x_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT := l_silv_rec.BOOK_DEPRE_DMNSHING_VALUE_RT;
      END IF;
      IF (x_silv_rec.residual_guarantee_method = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.residual_guarantee_method := l_silv_rec.residual_guarantee_method;
      END IF;
      -- mvasudev , 05/13/2002
      IF (x_silv_rec.residual_guarantee_type = OKC_API.G_MISS_CHAR)
            THEN
              x_silv_rec.residual_guarantee_type := l_silv_rec.residual_guarantee_type;
      END IF;
      IF (x_silv_rec.residual_date = OKC_API.G_MISS_DATE)
            THEN
              x_silv_rec.residual_date := l_silv_rec.residual_date;
      END IF;
      IF (x_silv_rec.fed_depre_term = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.fed_depre_term := l_silv_rec.fed_depre_term;
      END IF;
      IF (x_silv_rec.fed_depre_dmnshing_value_rate = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.fed_depre_dmnshing_value_rate := l_silv_rec.fed_depre_dmnshing_value_rate;
      END IF;
      IF (x_silv_rec.fed_depre_adr_conve = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.fed_depre_adr_conve := l_silv_rec.fed_depre_adr_conve;
      END IF;
      IF (x_silv_rec.state_depre_basis_percent = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.state_depre_basis_percent := l_silv_rec.state_depre_basis_percent;
      END IF;
      IF (x_silv_rec.state_depre_method = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.state_depre_method := l_silv_rec.state_depre_method;
      END IF;
      IF (x_silv_rec.purchase_option = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.purchase_option := l_silv_rec.purchase_option;
      END IF;
      IF (x_silv_rec.purchase_option_amount = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.purchase_option_amount := l_silv_rec.purchase_option_amount;
      END IF;
      IF (x_silv_rec.asset_cost = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.asset_cost := l_silv_rec.asset_cost;
      END IF;
      IF (x_silv_rec.state_depre_term = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.state_depre_term := l_silv_rec.state_depre_term;
      END IF;
      IF (x_silv_rec.state_depre_adr_convent = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.state_depre_adr_convent := l_silv_rec.state_depre_adr_convent;
      END IF;
      IF (x_silv_rec.fed_depre_method = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.fed_depre_method := l_silv_rec.fed_depre_method;
      END IF;
      IF (x_silv_rec.residual_amount = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.residual_amount := l_silv_rec.residual_amount;
      END IF;
      IF (x_silv_rec.fed_depre_salvage = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.fed_depre_salvage := l_silv_rec.fed_depre_salvage;
      END IF;
      IF (x_silv_rec.date_fed_depre = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_fed_depre := l_silv_rec.date_fed_depre;
      END IF;
      IF (x_silv_rec.book_salvage = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.book_salvage := l_silv_rec.book_salvage;
      END IF;
      IF (x_silv_rec.book_adr_convention = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.book_adr_convention := l_silv_rec.book_adr_convention;
      END IF;
      IF (x_silv_rec.state_depre_salvage = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.state_depre_salvage := l_silv_rec.state_depre_salvage;
      END IF;
      IF (x_silv_rec.Fed_Depre_Basis_Percent = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.Fed_Depre_Basis_Percent := l_silv_rec.Fed_Depre_Basis_Percent;
      END IF;
      IF (x_silv_rec.book_basis_percent = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.book_basis_percent := l_silv_rec.book_basis_percent;
      END IF;
      IF (x_silv_rec.date_delivery = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_delivery := l_silv_rec.date_delivery;
      END IF;
      IF (x_silv_rec.book_term = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.book_term := l_silv_rec.book_term;
      END IF;
      IF (x_silv_rec.residual_guarantee_amount = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.residual_guarantee_amount := l_silv_rec.residual_guarantee_amount;
      END IF;
      IF (x_silv_rec.date_funding = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_funding := l_silv_rec.date_funding;
      END IF;
      IF (x_silv_rec.date_book = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_book := l_silv_rec.date_book;
      END IF;
      IF (x_silv_rec.date_state_depre = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_state_depre := l_silv_rec.date_state_depre;
      END IF;
      IF (x_silv_rec.book_method = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.book_method := l_silv_rec.book_method;
      END IF;
      IF (x_silv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute01 := l_silv_rec.stream_interface_attribute01;
      END IF;
      IF (x_silv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute02 := l_silv_rec.stream_interface_attribute02;
      END IF;
      IF (x_silv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute03 := l_silv_rec.stream_interface_attribute03;
      END IF;
      IF (x_silv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute04 := l_silv_rec.stream_interface_attribute04;
      END IF;
      IF (x_silv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute05 := l_silv_rec.stream_interface_attribute05;
      END IF;
      IF (x_silv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute06 := l_silv_rec.stream_interface_attribute06;
      END IF;
      IF (x_silv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute07 := l_silv_rec.stream_interface_attribute07;
      END IF;
      IF (x_silv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute08 := l_silv_rec.stream_interface_attribute08;
      END IF;
      IF (x_silv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute09 := l_silv_rec.stream_interface_attribute09;
      END IF;
      IF (x_silv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute10 := l_silv_rec.stream_interface_attribute10;
      END IF;
      IF (x_silv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute11 := l_silv_rec.stream_interface_attribute11;
      END IF;
      IF (x_silv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute12 := l_silv_rec.stream_interface_attribute12;
      END IF;
      IF (x_silv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute13 := l_silv_rec.stream_interface_attribute13;
      END IF;
      IF (x_silv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute14 := l_silv_rec.stream_interface_attribute14;
      END IF;
      IF (x_silv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.stream_interface_attribute15 := l_silv_rec.stream_interface_attribute15;
      END IF;
      IF (x_silv_rec.date_start = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_start := l_silv_rec.date_start;
      END IF;
      IF (x_silv_rec.date_lending = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.date_lending := l_silv_rec.date_lending;
      END IF;
      IF (x_silv_rec.index_number = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.index_number := l_silv_rec.index_number;
      END IF;
      IF (x_silv_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.sif_id := l_silv_rec.sif_id;
      END IF;
      IF (x_silv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.object_version_number := l_silv_rec.object_version_number;
      END IF;
      IF (x_silv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.kle_id := l_silv_rec.kle_id;
      END IF;
      IF (x_silv_rec.sil_type = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.sil_type := l_silv_rec.sil_type;
      END IF;
      IF (x_silv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.description := l_silv_rec.description;
      END IF;
      IF (x_silv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.created_by := l_silv_rec.created_by;
      END IF;
      IF (x_silv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.last_updated_by := l_silv_rec.last_updated_by;
      END IF;
      IF (x_silv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.creation_date := l_silv_rec.creation_date;
      END IF;
      IF (x_silv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_silv_rec.last_update_date := l_silv_rec.last_update_date;
      END IF;
      IF (x_silv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.last_update_login := l_silv_rec.last_update_login;
      END IF;
      IF (x_silv_rec.down_payment_amount = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.down_payment_amount := l_silv_rec.down_payment_amount;
      END IF;
      IF (x_silv_rec.capitalize_down_payment_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_silv_rec.capitalize_down_payment_yn := l_silv_rec.capitalize_down_payment_yn;
      END IF;

      IF (x_silv_rec.orig_contract_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_silv_rec.orig_contract_line_id := l_silv_rec.orig_contract_line_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_SIF_LINES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_silv_rec IN  silv_rec_type,
      x_silv_rec OUT NOCOPY silv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_silv_rec := p_silv_rec;
      x_silv_rec.OBJECT_VERSION_NUMBER := NVL(x_silv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_silv_rec,                        -- IN
      l_silv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_silv_rec, l_def_silv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_silv_rec := fill_who_columns(l_def_silv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_silv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_silv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_silv_rec, l_sil_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sil_rec,
      lx_sil_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sil_rec, l_def_silv_rec);
    x_silv_rec := l_def_silv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:SILV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_silv_tbl.COUNT > 0) THEN
      i := p_silv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_silv_rec                     => p_silv_tbl(i),
          x_silv_rec                     => x_silv_tbl(i));
        EXIT WHEN (i = p_silv_tbl.LAST);
        i := p_silv_tbl.NEXT(i);
    	-- START change : mvasudev, 08/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
      END LOOP;
      -- START change : mvasudev, 08/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- delete_row for:OKL_SIF_LINES --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sil_rec                      IN sil_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sil_rec                      sil_rec_type:= p_sil_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_SIF_LINES
     WHERE ID = l_sil_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------
  -- delete_row for:OKL_SIF_LINES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_silv_rec                     silv_rec_type := p_silv_rec;
    l_sil_rec                      sil_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_silv_rec, l_sil_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sil_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:SILV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_silv_tbl.COUNT > 0) THEN
      i := p_silv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_silv_rec                     => p_silv_tbl(i));
        EXIT WHEN (i = p_silv_tbl.LAST);
        i := p_silv_tbl.NEXT(i);
    	-- START change : mvasudev, 08/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
      END LOOP;
      -- START change : mvasudev, 08/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_SIL_PVT;

/
