--------------------------------------------------------
--  DDL for Package Body OKS_CONTRACT_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CONTRACT_LINE_PUB" AS
/* $Header: OKSPKLNB.pls 120.1 2005/07/15 09:23:17 parkumar noship $ */
  PROCEDURE add_language IS
  BEGIN
    -- Translate OKS_K_LINES_TLH table (not included in Private TAPI)
    --   (To translate OKS_K_LINES_TL table call the procedure included
    --    in the TAPI: OKS_KLN_PVT.add_language )
    DELETE FROM OKS_K_LINES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKS_K_LINES_BH B
         WHERE B.ID =T.ID
           AND B.MAJOR_VERSION =T.MAJOR_VERSION
        );

    UPDATE OKS_K_LINES_TLH T SET(
        INVOICE_TEXT,
        IB_TRX_DETAILS,
        STATUS_TEXT,
        REACT_TIME_NAME) = (SELECT
                                  B.INVOICE_TEXT,
                                  B.IB_TRX_DETAILS,
                                  B.STATUS_TEXT,
                                  B.REACT_TIME_NAME
                                FROM OKS_K_LINES_TLH B
                               WHERE B.ID = T.ID
                                 AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKS_K_LINES_TLH SUBB, OKS_K_LINES_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.INVOICE_TEXT <> SUBT.INVOICE_TEXT
                      OR SUBB.IB_TRX_DETAILS <> SUBT.IB_TRX_DETAILS
                      OR SUBB.STATUS_TEXT <> SUBT.STATUS_TEXT
                      OR SUBB.REACT_TIME_NAME <> SUBT.REACT_TIME_NAME
                      OR (SUBB.INVOICE_TEXT IS NULL AND SUBT.INVOICE_TEXT IS NOT NULL)
                      OR (SUBB.IB_TRX_DETAILS IS NULL AND SUBT.IB_TRX_DETAILS IS NOT NULL)
                      OR (SUBB.STATUS_TEXT IS NULL AND SUBT.STATUS_TEXT IS NOT NULL)
                      OR (SUBB.REACT_TIME_NAME IS NULL AND SUBT.REACT_TIME_NAME IS NOT NULL)
              ));

    INSERT INTO OKS_K_LINES_TLH (
        ID,
        MAJOR_VERSION,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        INVOICE_TEXT,
        IB_TRX_DETAILS,
        STATUS_TEXT,
        REACT_TIME_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            B.MAJOR_VERSION,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.INVOICE_TEXT,
            B.IB_TRX_DETAILS,
            B.STATUS_TEXT,
            B.REACT_TIME_NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKS_K_LINES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKS_K_LINES_TLH T
                     WHERE T.ID = B.ID
                       AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  PROCEDURE create_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type,
    p_validate_yn                  IN VARCHAR2) IS

    l_init_msg_list   VARCHAR2(10);
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_line
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => l_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_rec       => p_klnv_rec
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_kln_pvt.insert_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_rec       => p_klnv_rec,
             x_klnv_rec       => x_klnv_rec
           );
    END IF;
  END create_line;

  PROCEDURE create_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_line
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_kln_pvt.insert_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             x_klnv_tbl       => x_klnv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
  END create_line;

  PROCEDURE create_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_line
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_kln_pvt.insert_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             x_klnv_tbl       => x_klnv_tbl
           );
    END IF;
  END create_line;

  PROCEDURE update_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_line
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_rec       => p_klnv_rec
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_kln_pvt.update_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_rec       => p_klnv_rec,
             x_klnv_rec       => x_klnv_rec
           );
    END IF;
  END update_line;

  PROCEDURE update_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_line
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_kln_pvt.update_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             x_klnv_tbl       => x_klnv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
  END update_line;

  PROCEDURE update_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_line
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_kln_pvt.update_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             x_klnv_tbl       => x_klnv_tbl
           );
    END IF;
  END update_line;

  PROCEDURE lock_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type) IS
  BEGIN
    oks_kln_pvt.lock_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_rec       => p_klnv_rec
           );
  END lock_line;

  PROCEDURE lock_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
  BEGIN
    oks_kln_pvt.lock_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             px_error_tbl     => px_error_tbl
           );
  END lock_line;

  PROCEDURE lock_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type) IS
  BEGIN
    oks_kln_pvt.lock_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl
           );
  END lock_line;

  PROCEDURE delete_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type) IS
  BEGIN
    oks_kln_pvt.delete_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_rec       => p_klnv_rec
           );
  END delete_line;

  PROCEDURE delete_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
  BEGIN
    oks_kln_pvt.delete_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl,
             px_error_tbl     => px_error_tbl
           );
  END delete_line;

  PROCEDURE delete_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type) IS
  BEGIN
    oks_kln_pvt.delete_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_klnv_tbl       => p_klnv_tbl
           );
  END delete_line;

  PROCEDURE validate_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  END validate_line;

  PROCEDURE validate_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  END validate_line;

  PROCEDURE validate_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  END validate_line;

---------------------------------------------------------------
-- Procedure for mass insert in OKS_K_HEADERS_B table
---------------------------------------------------------------
  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,
                           p_klnv_tbl      IN klnv_tbl_type) IS


      l_tabsize NUMBER := p_klnv_tbl.COUNT;
      l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
      in_id                 OKC_DATATYPES.NumberTabTyp;
      in_cle_id             OKC_DATATYPES.NumberTabTyp;
      in_dnz_chr_id         OKC_DATATYPES.NumberTabTyp;
      in_discount_list      OKC_DATATYPES.NumberTabTyp;
      in_acct_rule_id       OKC_DATATYPES.NumberTabTyp;
      in_payment_type       OKC_DATATYPES.Var30TabTyp;
      in_cc_no              OKC_DATATYPES.Var90TabTyp;
      in_cc_expiry_date     OKC_DATATYPES.DateTabTyp;
      in_cc_bank_acct_id    OKC_DATATYPES.NumberTabTyp;
      in_cc_auth_code       OKC_DATATYPES.Var150TabTyp;
      in_commitment_id      OKC_DATATYPES.NumberTabTyp;
      in_locked_price_list_id       OKC_DATATYPES.NumberTabTyp;
      in_usage_est_yn               OKC_DATATYPES.Var3TabTyp;
      in_usage_est_method           OKC_DATATYPES.Var30TabTyp;
      in_usage_est_start_date       OKC_DATATYPES.DateTabTyp;
      in_termn_method               OKC_DATATYPES.Var30TabTyp;
      in_ubt_amount                 OKC_DATATYPES.NumberTabTyp;
      in_credit_amount              OKC_DATATYPES.NumberTabTyp;
      in_suppressed_credit          OKC_DATATYPES.NumberTabTyp;
      in_override_amount            OKC_DATATYPES.NumberTabTyp;
      in_cust_po_number_req_yn      OKC_DATATYPES.Var3TabTyp;
      in_cust_po_number             OKC_DATATYPES.Var150TabTyp;
      in_grace_duration             OKC_DATATYPES.NumberTabTyp;
      in_grace_period               OKC_DATATYPES.Var30TabTyp;
      in_inv_print_flag             OKC_DATATYPES.Var3TabTyp;
      in_price_uom                  OKC_DATATYPES.Var30TabTyp;
      in_tax_amount                 OKC_DATATYPES.NumberTabTyp;
      in_tax_inclusive_yn           OKC_DATATYPES.Var3TabTyp;
      in_tax_status                 OKC_DATATYPES.Var30TabTyp;
      in_tax_code                   OKC_DATATYPES.NumberTabTyp;
      in_tax_exemption_id           OKC_DATATYPES.NumberTabTyp;
      in_ib_trans_type              OKC_DATATYPES.Var10TabTyp;
      in_ib_trans_date              OKC_DATATYPES.DateTabTyp;
      in_prod_price                 OKC_DATATYPES.NumberTabTyp;
      in_service_price              OKC_DATATYPES.NumberTabTyp;
      in_clvl_list_price            OKC_DATATYPES.NumberTabTyp;
      in_clvl_quantity              OKC_DATATYPES.NumberTabTyp;
      in_clvl_extended_amt          OKC_DATATYPES.NumberTabTyp;
      in_clvl_uom_code              OKC_DATATYPES.Var3TabTyp;
      in_toplvl_operand_code        OKC_DATATYPES.Var30TabTyp;
      in_toplvl_operand_val         OKC_DATATYPES.NumberTabTyp;
      in_toplvl_quantity            OKC_DATATYPES.NumberTabTyp;
      in_toplvl_uom_code            OKC_DATATYPES.Var3TabTyp;
      in_toplvl_adj_price           OKC_DATATYPES.NumberTabTyp;
      in_toplvl_price_qty           OKC_DATATYPES.NumberTabTyp;
      in_averaging_interval         OKC_DATATYPES.NumberTabTyp;
      in_settlement_interval        OKC_DATATYPES.Var30TabTyp;
      in_minimum_quantity           OKC_DATATYPES.NumberTabTyp;
      in_default_quantity           OKC_DATATYPES.NumberTabTyp;
      in_amcv_flag                  OKC_DATATYPES.Var3TabTyp;
      in_fixed_quantity             OKC_DATATYPES.NumberTabTyp;
      in_usage_duration             OKC_DATATYPES.NumberTabTyp;
      in_usage_period               OKC_DATATYPES.Var3TabTyp;
      in_level_yn                   OKC_DATATYPES.Var3TabTyp;
      in_usage_type                 OKC_DATATYPES.Var10TabTyp;
      in_uom_quantified             OKC_DATATYPES.Var3TabTyp;
      in_base_reading               OKC_DATATYPES.NumberTabTyp;
      in_billing_schedule_type      OKC_DATATYPES.Var10TabTyp;
      in_full_credit                OKC_DATATYPES.Var3TabTyp;
      in_coverage_type              OKC_DATATYPES.Var3TabTyp;
      in_exception_cov_id           OKC_DATATYPES.NumberTabTyp;
      in_limit_uom_quantified       OKC_DATATYPES.Var3TabTyp;
      in_discount_amount            OKC_DATATYPES.NumberTabTyp;
      in_discount_percent           OKC_DATATYPES.NumberTabTyp;
      in_offset_duration            OKC_DATATYPES.NumberTabTyp;
      in_offset_period              OKC_DATATYPES.Var3TabTyp;
      in_incident_severity_id       OKC_DATATYPES.NumberTabTyp;
      in_pdf_id                     OKC_DATATYPES.NumberTabTyp;
      in_work_thru_yn               OKC_DATATYPES.Var3TabTyp;
      in_react_active_yn            OKC_DATATYPES.Var3TabTyp;
      in_transfer_option            OKC_DATATYPES.Var30TabTyp;
      in_prod_upgrade_yn            OKC_DATATYPES.Var3TabTyp;
      in_inheritance_type           OKC_DATATYPES.Var30TabTyp;
      in_pm_program_id              OKC_DATATYPES.NumberTabTyp;
      in_pm_conf_req_yn             OKC_DATATYPES.Var3TabTyp;
      in_pm_sch_exists_yn           OKC_DATATYPES.Var3TabTyp;
      in_allow_bt_discount          OKC_DATATYPES.Var3TabTyp;
      in_apply_default_timezone     OKC_DATATYPES.Var3TabTyp;
      in_sync_date_install          OKC_DATATYPES.Var3TabTyp;
      in_object_version_number      OKC_DATATYPES.NumberTabTyp;
      in_request_id                 OKC_DATATYPES.NumberTabTyp;
      in_created_by                 OKC_DATATYPES.Number15TabTyp;
      in_creation_date              OKC_DATATYPES.DateTabTyp;
      in_last_updated_by            OKC_DATATYPES.Number15TabTyp;
      in_last_update_date           OKC_DATATYPES.DateTabTyp;
      in_last_update_login          OKC_DATATYPES.Number15TabTyp;

      in_source_lang                OKC_DATATYPES.Var12TabTyp;
      in_sfwt_flag                  OKC_DATATYPES.Var3TabTyp;
      in_invoice_text               OKC_DATATYPES.Var1995TabTyp;
      in_ib_trx_details             OKC_DATATYPES.Var1995TabTyp;
      in_status_text                OKC_DATATYPES.Var450TabTyp;
      in_react_time_name            OKC_DATATYPES.Var450TabTyp;
      in_security_group_id          OKC_DATATYPES.NumberTabTyp;

    i number;
    j number;


BEGIN
  -- Initialize return status
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  i := p_klnv_tbl.FIRST;
  j:=0;
  while i is not null
  LOOP
    j:=j+1;
      in_id(j)  := 	p_klnv_tbl(i).id;
      in_cle_id(j)  := 	      p_klnv_tbl(i).cle_id;
      in_dnz_chr_id(j)  := 	      p_klnv_tbl(i).dnz_chr_id;
      in_discount_list(j)  := 	      p_klnv_tbl(i).discount_list;
      in_acct_rule_id(j)  := 	      p_klnv_tbl(i).acct_rule_id;
      in_payment_type(j)  := 	      p_klnv_tbl(i).payment_type;
      in_cc_no(j)  := 	      p_klnv_tbl(i).cc_no;
      in_cc_expiry_date(j)  := 	      p_klnv_tbl(i).cc_expiry_date;
      in_cc_bank_acct_id(j)  := 	      p_klnv_tbl(i).cc_bank_acct_id;
      in_cc_auth_code(j)  := 	      p_klnv_tbl(i).cc_auth_code;
      in_commitment_id(j)  := 	      p_klnv_tbl(i).commitment_id;
      in_locked_price_list_id(j)  := 	      p_klnv_tbl(i).locked_price_list_id;
      in_usage_est_yn(j)  :=	      p_klnv_tbl(i).usage_est_yn;
      in_usage_est_method(j)  := 	p_klnv_tbl(i).usage_est_method;
      in_usage_est_start_date(j)  := 	      p_klnv_tbl(i).usage_est_start_date;
      in_termn_method(j)  := 	      p_klnv_tbl(i).termn_method;
      in_ubt_amount(j)  := 	      p_klnv_tbl(i).ubt_amount;
      in_credit_amount(j)  := 	      p_klnv_tbl(i).credit_amount;
      in_suppressed_credit(j)  := 	      p_klnv_tbl(i).suppressed_credit;
      in_override_amount(j)  := 	      p_klnv_tbl(i).override_amount;
      in_cust_po_number_req_yn(j)  := 	      p_klnv_tbl(i).cust_po_number_req_yn;
      in_cust_po_number(j)  := 	      p_klnv_tbl(i).cust_po_number;
      in_grace_duration(j)  := 	      p_klnv_tbl(i).grace_duration;
      in_grace_period(j)  := 	      p_klnv_tbl(i).grace_period;
      in_inv_print_flag(j)  := 	      p_klnv_tbl(i).inv_print_flag;
      in_price_uom(j)  := 	      p_klnv_tbl(i).price_uom;
      in_tax_amount(j)  := 	      p_klnv_tbl(i).tax_amount;
      in_tax_inclusive_yn(j)  := 	      p_klnv_tbl(i).tax_inclusive_yn;
      in_tax_status(j)  := 	      p_klnv_tbl(i).tax_status;
      in_tax_code(j)  := 	      p_klnv_tbl(i).tax_code;
      in_tax_exemption_id(j)  := 	      p_klnv_tbl(i).tax_exemption_id;
      in_ib_trans_type(j)  := 	      p_klnv_tbl(i).ib_trans_type;
      in_ib_trans_date(j)  := 	      p_klnv_tbl(i).ib_trans_date;
      in_prod_price(j)  := 	      p_klnv_tbl(i).prod_price;
      in_service_price(j)  := 	      p_klnv_tbl(i).service_price;
      in_clvl_list_price(j)  := 	      p_klnv_tbl(i).clvl_list_price;
      in_clvl_quantity(j)  := 	      p_klnv_tbl(i).clvl_quantity;
      in_clvl_extended_amt(j)  := 	      p_klnv_tbl(i).clvl_extended_amt;
      in_clvl_uom_code(j)  := 	      p_klnv_tbl(i).clvl_uom_code;
      in_toplvl_operand_code(j)  := 	      p_klnv_tbl(i).toplvl_operand_code;
      in_toplvl_operand_val(j)  := 	      p_klnv_tbl(i).toplvl_operand_val;
      in_toplvl_quantity(j)  := 	      p_klnv_tbl(i).toplvl_quantity;
      in_toplvl_uom_code(j)  := 	      p_klnv_tbl(i).toplvl_uom_code;
      in_toplvl_adj_price(j)  := 	      p_klnv_tbl(i).toplvl_adj_price;
      in_toplvl_price_qty(j)  := 	      p_klnv_tbl(i).toplvl_price_qty;
      in_averaging_interval(j)  := 	      p_klnv_tbl(i).averaging_interval;
      in_settlement_interval(j)  := 	      p_klnv_tbl(i).settlement_interval;
      in_minimum_quantity(j)  := 	      p_klnv_tbl(i).minimum_quantity;
      in_default_quantity(j)  := 	      p_klnv_tbl(i).default_quantity;
      in_amcv_flag(j)  := 	      p_klnv_tbl(i).amcv_flag;
      in_fixed_quantity(j)  := 	      p_klnv_tbl(i).fixed_quantity;
      in_usage_duration(j)  := 	      p_klnv_tbl(i).usage_duration;
      in_usage_period(j)  := 	      p_klnv_tbl(i).usage_period;
      in_level_yn(j)  := 	      p_klnv_tbl(i).level_yn;
      in_usage_type(j)  := 	      p_klnv_tbl(i).usage_type;
      in_uom_quantified(j)  := 	      p_klnv_tbl(i).uom_quantified;
      in_base_reading(j)  := 	      p_klnv_tbl(i).base_reading;
      in_billing_schedule_type(j)  := 	      p_klnv_tbl(i).billing_schedule_type;
      in_full_credit(j) :=          p_klnv_tbl(i).full_credit;
      in_coverage_type(j)  := 	      p_klnv_tbl(i).coverage_type;
      in_exception_cov_id(j)  := 	      p_klnv_tbl(i).exception_cov_id;
      in_limit_uom_quantified(j)  := 	      p_klnv_tbl(i).limit_uom_quantified;
      in_discount_amount(j)  := 	      p_klnv_tbl(i).discount_amount;
      in_discount_percent(j)  := 	      p_klnv_tbl(i).discount_percent;
      in_offset_duration(j)  := 	      p_klnv_tbl(i).offset_duration;
      in_offset_period(j)  := 	      p_klnv_tbl(i).offset_period;
      in_incident_severity_id(j)  := 	      p_klnv_tbl(i).incident_severity_id;
      in_pdf_id(j)  := 	      p_klnv_tbl(i).pdf_id;
      in_work_thru_yn(j)  := 	      p_klnv_tbl(i).work_thru_yn;
      in_react_active_yn(j)  := 	      p_klnv_tbl(i).react_active_yn;
      in_transfer_option(j)  := 	      p_klnv_tbl(i).transfer_option;
      in_prod_upgrade_yn(j)  := 	      p_klnv_tbl(i).prod_upgrade_yn;
      in_inheritance_type(j)  := 	      p_klnv_tbl(i).inheritance_type;
      in_pm_program_id(j)  := 	      p_klnv_tbl(i).pm_program_id;
      in_pm_conf_req_yn(j)  := 	      p_klnv_tbl(i).pm_conf_req_yn;
      in_pm_sch_exists_yn(j)  := 	      p_klnv_tbl(i).pm_sch_exists_yn;
      in_allow_bt_discount(j)  := 	      p_klnv_tbl(i).allow_bt_discount;
      in_apply_default_timezone(j)  := 	      p_klnv_tbl(i).apply_default_timezone;
      in_sync_date_install(j)  := 	      p_klnv_tbl(i).sync_date_install;
      in_object_version_number(j)  := 	      p_klnv_tbl(i).object_version_number;
      in_request_id(j)  := 	      p_klnv_tbl(i).request_id;
      in_created_by(j)  := 	      p_klnv_tbl(i).created_by;
      in_creation_date(j)  := 	      p_klnv_tbl(i).creation_date;
      in_last_updated_by(j)  := 	      p_klnv_tbl(i).last_updated_by;
      in_last_update_date(j)  := 	      p_klnv_tbl(i).last_update_date;
      in_last_update_login(j) :=	      p_klnv_tbl(i).last_update_login;
      in_security_group_id(j) :=          p_klnv_tbl(i).security_group_id;

      in_source_lang(j)   :=  l_source_lang; --p_klnv_tbl(i).source_lang;
      in_sfwt_flag(j)  :=  p_klnv_tbl(i).sfwt_flag;
      in_invoice_text(j):=  p_klnv_tbl(i).invoice_text;
      in_ib_trx_details(j):=  p_klnv_tbl(i).ib_trx_details;
      in_status_text(j):=  p_klnv_tbl(i).status_text;
      in_react_time_name(j):=  p_klnv_tbl(i).react_time_name;

      i:=p_klnv_tbl.next(i);
  END LOOP;


  FORALL i in 1..l_tabsize
    INSERT
      INTO OKS_K_LINES_B
      (
      id,
      cle_id,
      dnz_chr_id,
      discount_list,
      acct_rule_id,
      payment_type,
      cc_no,
      cc_expiry_date,
      cc_bank_acct_id,
      cc_auth_code,
      commitment_id,
      locked_price_list_id,
      usage_est_yn,
      usage_est_method,
      usage_est_start_date,
      termn_method,
      ubt_amount,
      credit_amount,
      suppressed_credit,
      override_amount,
      cust_po_number_req_yn,
      cust_po_number,
      grace_duration,
      grace_period,
      inv_print_flag,
      price_uom,
      tax_amount,
      tax_inclusive_yn,
      tax_status,
      tax_code,
      tax_exemption_id,
      ib_trans_type,
      ib_trans_date,
      prod_price,
      service_price,
      clvl_list_price,
      clvl_quantity,
      clvl_extended_amt,
      clvl_uom_code,
      toplvl_operand_code,
      toplvl_operand_val,
      toplvl_quantity,
      toplvl_uom_code,
      toplvl_adj_price,
      toplvl_price_qty,
      averaging_interval,
      settlement_interval,
      minimum_quantity,
      default_quantity,
      amcv_flag,
      fixed_quantity,
      usage_duration,
      usage_period,
      level_yn,
      usage_type,
      uom_quantified,
      base_reading,
      billing_schedule_type,
      full_credit,
      coverage_type,
      exception_cov_id,
      limit_uom_quantified,
      discount_amount,
      discount_percent,
      offset_duration,
      offset_period,
      incident_severity_id,
      pdf_id,
      work_thru_yn,
      react_active_yn,
      transfer_option,
      prod_upgrade_yn,
      inheritance_type,
      pm_program_id,
      pm_conf_req_yn,
      pm_sch_exists_yn,
      allow_bt_discount,
      apply_default_timezone,
      sync_date_install,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
    ) VALUES (
      in_id(i),
      in_cle_id(i),
      in_dnz_chr_id(i),
      in_discount_list(i),
      in_acct_rule_id(i),
      in_payment_type(i),
      in_cc_no(i),
      in_cc_expiry_date(i),
      in_cc_bank_acct_id(i),
      in_cc_auth_code(i),
      in_commitment_id(i),
      in_locked_price_list_id(i),
      in_usage_est_yn(i),
      in_usage_est_method(i),
      in_usage_est_start_date(i),
      in_termn_method(i),
      in_ubt_amount(i),
      in_credit_amount(i),
      in_suppressed_credit(i),
      in_override_amount(i),
      in_cust_po_number_req_yn(i),
      in_cust_po_number(i),
      in_grace_duration(i),
      in_grace_period(i),
      in_inv_print_flag(i),
      in_price_uom(i),
      in_tax_amount(i),
      in_tax_inclusive_yn(i),
      in_tax_status(i),
      in_tax_code(i),
      in_tax_exemption_id(i),
      in_ib_trans_type(i),
      in_ib_trans_date(i),
      in_prod_price(i),
      in_service_price(i),
      in_clvl_list_price(i),
      in_clvl_quantity(i),
      in_clvl_extended_amt(i),
      in_clvl_uom_code(i),
      in_toplvl_operand_code(i),
      in_toplvl_operand_val(i),
      in_toplvl_quantity(i),
      in_toplvl_uom_code(i),
      in_toplvl_adj_price(i),
      in_toplvl_price_qty(i),
      in_averaging_interval(i),
      in_settlement_interval(i),
      in_minimum_quantity(i),
      in_default_quantity(i),
      in_amcv_flag(i),
      in_fixed_quantity(i),
      in_usage_duration(i),
      in_usage_period(i),
      in_level_yn(i),
      in_usage_type(i),
      in_uom_quantified(i),
      in_base_reading(i),
      in_billing_schedule_type(i),
      in_full_credit(i),
      in_coverage_type(i),
      in_exception_cov_id(i),
      in_limit_uom_quantified(i),
      in_discount_amount(i),
      in_discount_percent(i),
      in_offset_duration(i),
      in_offset_period(i),
      in_incident_severity_id(i),
      in_pdf_id(i),
      in_work_thru_yn(i),
      in_react_active_yn(i),
      in_transfer_option(i),
      in_prod_upgrade_yn(i),
      in_inheritance_type(i),
      in_pm_program_id(i),
      in_pm_conf_req_yn(i),
      in_pm_sch_exists_yn(i),
      in_allow_bt_discount(i),
      in_apply_default_timezone(i),
      in_sync_date_install(i),
      in_object_version_number(i),
      in_request_id(i),
      in_created_by(i),
      in_creation_date(i),
      in_last_updated_by(i),
      in_last_update_date(i),
      in_last_update_login(i)
      );

    FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKS_K_LINES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        invoice_text,
        ib_trx_details,
        status_text,
        react_time_name,
        security_group_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        in_source_lang(i),
        in_sfwt_flag(i),
        in_invoice_text(i),
        in_ib_trx_details(i),
        in_status_text(i),
        in_react_time_name(i),
        in_security_group_id(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
        );
   End Loop;


EXCEPTION
  WHEN OTHERS THEN

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
END INSERT_ROW_UPG;

-------------------------------------------------------------------
-- Procedure for mass insert in OKS_K_LINES_BH and OKS_K_LINES_TLH
-------------------------------------------------------------------
PROCEDURE CREATE_LINE_VERSION_UPG(x_return_status OUT NOCOPY VARCHAR2,
                                  p_klnhv_tbl IN klnhv_tbl_type) IS

      l_tabsize NUMBER := p_klnhv_tbl.COUNT;
      l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
      in_id                         OKC_DATATYPES.NumberTabTyp;
      in_cle_id                     OKC_DATATYPES.NumberTabTyp;
      in_dnz_chr_id                 OKC_DATATYPES.NumberTabTyp;
      in_discount_list              OKC_DATATYPES.NumberTabTyp;
      in_acct_rule_id               OKC_DATATYPES.NumberTabTyp;
      in_payment_type               OKC_DATATYPES.Var30TabTyp;
      in_cc_no                      OKC_DATATYPES.Var90TabTyp;
      in_cc_expiry_date             OKC_DATATYPES.DateTabTyp;
      in_cc_bank_acct_id            OKC_DATATYPES.NumberTabTyp;
      in_cc_auth_code               OKC_DATATYPES.Var150TabTyp;
      in_commitment_id              OKC_DATATYPES.NumberTabTyp;
      in_locked_price_list_id       OKC_DATATYPES.NumberTabTyp;
      in_usage_est_yn               OKC_DATATYPES.Var3TabTyp;
      in_usage_est_method           OKC_DATATYPES.Var30TabTyp;
      in_usage_est_start_date       OKC_DATATYPES.DateTabTyp;
      in_termn_method               OKC_DATATYPES.Var30TabTyp;
      in_ubt_amount                 OKC_DATATYPES.NumberTabTyp;
      in_credit_amount              OKC_DATATYPES.NumberTabTyp;
      in_suppressed_credit          OKC_DATATYPES.NumberTabTyp;
      in_override_amount            OKC_DATATYPES.NumberTabTyp;
      in_cust_po_number_req_yn      OKC_DATATYPES.Var3TabTyp;
      in_cust_po_number             OKC_DATATYPES.Var150TabTyp;
      in_grace_duration             OKC_DATATYPES.NumberTabTyp;
      in_grace_period               OKC_DATATYPES.Var30TabTyp;
      in_inv_print_flag             OKC_DATATYPES.Var3TabTyp;
      in_price_uom                  OKC_DATATYPES.Var30TabTyp;
      in_tax_amount                 OKC_DATATYPES.NumberTabTyp;
      in_tax_inclusive_yn           OKC_DATATYPES.Var3TabTyp;
      in_tax_status                 OKC_DATATYPES.Var30TabTyp;
      in_tax_code                   OKC_DATATYPES.NumberTabTyp;
      in_tax_exemption_id           OKC_DATATYPES.NumberTabTyp;
      in_ib_trans_type              OKC_DATATYPES.Var10TabTyp;
      in_ib_trans_date              OKC_DATATYPES.DateTabTyp;
      in_prod_price                 OKC_DATATYPES.NumberTabTyp;
      in_service_price              OKC_DATATYPES.NumberTabTyp;
      in_clvl_list_price            OKC_DATATYPES.NumberTabTyp;
      in_clvl_quantity              OKC_DATATYPES.NumberTabTyp;
      in_clvl_extended_amt          OKC_DATATYPES.NumberTabTyp;
      in_clvl_uom_code              OKC_DATATYPES.Var3TabTyp;
      in_toplvl_operand_code        OKC_DATATYPES.Var30TabTyp;
      in_toplvl_operand_val         OKC_DATATYPES.NumberTabTyp;
      in_toplvl_quantity            OKC_DATATYPES.NumberTabTyp;
      in_toplvl_uom_code            OKC_DATATYPES.Var3TabTyp;
      in_toplvl_adj_price           OKC_DATATYPES.NumberTabTyp;
      in_toplvl_price_qty           OKC_DATATYPES.NumberTabTyp;
      in_averaging_interval         OKC_DATATYPES.NumberTabTyp;
      in_settlement_interval        OKC_DATATYPES.Var30TabTyp;
      in_minimum_quantity           OKC_DATATYPES.NumberTabTyp;
      in_default_quantity           OKC_DATATYPES.NumberTabTyp;
      in_amcv_flag                  OKC_DATATYPES.Var3TabTyp;
      in_fixed_quantity             OKC_DATATYPES.NumberTabTyp;
      in_usage_duration             OKC_DATATYPES.NumberTabTyp;
      in_usage_period               OKC_DATATYPES.Var3TabTyp;
      in_level_yn                   OKC_DATATYPES.Var3TabTyp;
      in_usage_type                 OKC_DATATYPES.Var10TabTyp;
      in_uom_quantified             OKC_DATATYPES.Var3TabTyp;
      in_base_reading               OKC_DATATYPES.NumberTabTyp;
      in_billing_schedule_type      OKC_DATATYPES.Var10TabTyp;
      in_full_credit                OKC_DATATYPES.Var3TabTyp;
      in_coverage_type              OKC_DATATYPES.Var3TabTyp;
      in_exception_cov_id           OKC_DATATYPES.NumberTabTyp;
      in_limit_uom_quantified       OKC_DATATYPES.Var3TabTyp;
      in_discount_amount            OKC_DATATYPES.NumberTabTyp;
      in_discount_percent           OKC_DATATYPES.NumberTabTyp;
      in_offset_duration            OKC_DATATYPES.NumberTabTyp;
      in_offset_period              OKC_DATATYPES.Var3TabTyp;
      in_incident_severity_id       OKC_DATATYPES.NumberTabTyp;
      in_pdf_id                     OKC_DATATYPES.NumberTabTyp;
      in_work_thru_yn               OKC_DATATYPES.Var3TabTyp;
      in_react_active_yn            OKC_DATATYPES.Var3TabTyp;
      in_transfer_option            OKC_DATATYPES.Var30TabTyp;
      in_prod_upgrade_yn            OKC_DATATYPES.Var3TabTyp;
      in_inheritance_type           OKC_DATATYPES.Var30TabTyp;
      in_pm_program_id              OKC_DATATYPES.NumberTabTyp;
      in_pm_conf_req_yn             OKC_DATATYPES.Var3TabTyp;
      in_pm_sch_exists_yn           OKC_DATATYPES.Var3TabTyp;
      in_allow_bt_discount          OKC_DATATYPES.Var3TabTyp;
      in_apply_default_timezone     OKC_DATATYPES.Var3TabTyp;
      in_sync_date_install          OKC_DATATYPES.Var3TabTyp;
      in_object_version_number      OKC_DATATYPES.NumberTabTyp;
      in_security_group_id          OKC_DATATYPES.NumberTabTyp;
      in_request_id                 OKC_DATATYPES.NumberTabTyp;
      in_created_by                 OKC_DATATYPES.Number15TabTyp;
      in_creation_date              OKC_DATATYPES.DateTabTyp;
      in_last_updated_by            OKC_DATATYPES.Number15TabTyp;
      in_last_update_date           OKC_DATATYPES.DateTabTyp;
      in_last_update_login          OKC_DATATYPES.Number15TabTyp;
      in_major_version                   OKC_DATATYPES.NumberTabTyp;

      in_source_lang           OKC_DATATYPES.Var12TabTyp;
      in_sfwt_flag             OKC_DATATYPES.Var3TabTyp;
      in_invoice_text          OKC_DATATYPES.Var1995TabTyp;
      in_ib_trx_details        OKC_DATATYPES.Var1995TabTyp;
      in_status_text           OKC_DATATYPES.Var450TabTyp;
      in_react_time_name       OKC_DATATYPES.Var450TabTyp;

      i number;
      j number;


Begin
x_return_status := OKC_API.G_RET_STS_SUCCESS;

  i := p_klnhv_tbl.FIRST;
  j:=0;

  while i is not null
  LOOP
      j := j + 1;
      in_id(j)                       :=   p_klnhv_tbl(i).id;
      in_cle_id(j)                   :=   p_klnhv_tbl(i).cle_id;
      in_dnz_chr_id(j)               :=   p_klnhv_tbl(i).dnz_chr_id;
      in_discount_list(j)              :=   p_klnhv_tbl(i).discount_list;
      in_acct_rule_id(j)             :=   p_klnhv_tbl(i).acct_rule_id;
      in_payment_type(j)               :=   p_klnhv_tbl(i).payment_type ;
      in_cc_no(j)                      :=  p_klnhv_tbl(i).cc_no;
      in_cc_expiry_date(j)             :=  p_klnhv_tbl(i).cc_expiry_date;
      in_cc_bank_acct_id(j)            :=  p_klnhv_tbl(i).cc_bank_acct_id;
      in_cc_auth_code(j)               :=  p_klnhv_tbl(i).cc_auth_code;
      in_commitment_id(j)              :=   p_klnhv_tbl(i).commitment_id;
      in_locked_price_list_id(j)     :=   p_klnhv_tbl(i).locked_price_list_id;
      in_usage_est_yn(j)               :=   p_klnhv_tbl(i).usage_est_yn;
      in_usage_est_method(j)           :=   p_klnhv_tbl(i).usage_est_method;
      in_usage_est_start_date(j)       :=   p_klnhv_tbl(i).usage_est_start_date;
      in_termn_method(j)               :=   p_klnhv_tbl(i).termn_method;
      in_ubt_amount(j)                 :=   p_klnhv_tbl(i).ubt_amount;
      in_credit_amount(j)              :=   p_klnhv_tbl(i).credit_amount;
      in_suppressed_credit(j)          :=   p_klnhv_tbl(i).suppressed_credit;
      in_override_amount(j)            :=   p_klnhv_tbl(i).override_amount;
      in_cust_po_number_req_yn(j)      :=   p_klnhv_tbl(i).cust_po_number_req_yn;
      in_cust_po_number(j)             :=   p_klnhv_tbl(i).cust_po_number;
      in_grace_duration(j)             :=   p_klnhv_tbl(i).grace_duration;
      in_grace_period(j)               :=   p_klnhv_tbl(i).grace_period;
      in_inv_print_flag(j)             :=   p_klnhv_tbl(i).inv_print_flag;
      in_price_uom(j)                  :=   p_klnhv_tbl(i).price_uom;
      in_tax_amount(j)                 :=  p_klnhv_tbl(i).tax_amount;
      in_tax_inclusive_yn(j)           :=   p_klnhv_tbl(i).tax_inclusive_yn;
      in_tax_status(j)                 :=  p_klnhv_tbl(i).tax_status;
      in_tax_code(j)                   :=  p_klnhv_tbl(i).tax_code;
      in_tax_exemption_id(j)           :=  p_klnhv_tbl(i).tax_exemption_id;
      in_ib_trans_type(j)              :=   p_klnhv_tbl(i).ib_trans_type;
      in_ib_trans_date(j)              :=   p_klnhv_tbl(i).ib_trans_date;
      in_prod_price(j)                 :=   p_klnhv_tbl(i).prod_price;
      in_service_price(j)              :=   p_klnhv_tbl(i).service_price;
      in_clvl_list_price(j)            :=   p_klnhv_tbl(i).clvl_list_price;
      in_clvl_quantity(j)             :=   p_klnhv_tbl(i).clvl_quantity;
      in_clvl_extended_amt(j)          :=   p_klnhv_tbl(i).clvl_extended_amt;
      in_clvl_uom_code(j)              :=   p_klnhv_tbl(i).clvl_uom_code;
      in_toplvl_operand_code(j)        :=   p_klnhv_tbl(i).toplvl_operand_code;
      in_toplvl_operand_val(j)         :=   p_klnhv_tbl(i).toplvl_operand_val;
      in_toplvl_quantity(j)            :=   p_klnhv_tbl(i).toplvl_quantity;
      in_toplvl_uom_code(j)            :=   p_klnhv_tbl(i).toplvl_uom_code;
      in_toplvl_adj_price(j)           :=   p_klnhv_tbl(i).toplvl_adj_price;
      in_toplvl_price_qty(j)           :=   p_klnhv_tbl(i).toplvl_price_qty;
      in_averaging_interval(j)         :=   p_klnhv_tbl(i).averaging_interval;
      in_settlement_interval(j)        :=   p_klnhv_tbl(i).settlement_interval;
      in_minimum_quantity(j)           :=   p_klnhv_tbl(i).minimum_quantity;
      in_default_quantity(j)           :=   p_klnhv_tbl(i).default_quantity;
      in_amcv_flag(j)                  :=   p_klnhv_tbl(i).amcv_flag;
      in_fixed_quantity(j)             :=   p_klnhv_tbl(i).fixed_quantity;
      in_usage_duration(j)             :=   p_klnhv_tbl(i).usage_duration;
      in_usage_period(j)               :=   p_klnhv_tbl(i).usage_period;
      in_level_yn(j)                   :=   p_klnhv_tbl(i).level_yn;
      in_usage_type(j)                 :=   p_klnhv_tbl(i).usage_type;
      in_uom_quantified(j)             :=   p_klnhv_tbl(i).uom_quantified;
      in_base_reading(j)               :=   p_klnhv_tbl(i).base_reading;
      in_billing_schedule_type(j)      :=   p_klnhv_tbl(i).billing_schedule_type;
      in_full_credit(j)                :=   p_klnhv_tbl(i).full_credit;
      in_coverage_type(j)              :=   p_klnhv_tbl(i).coverage_type;
      in_exception_cov_id(j)         :=   p_klnhv_tbl(i).exception_cov_id;
      in_limit_uom_quantified(j)       :=   p_klnhv_tbl(i).limit_uom_quantified;
      in_discount_amount(j)            :=   p_klnhv_tbl(i).discount_amount;
      in_discount_percent(j)           :=   p_klnhv_tbl(i).discount_percent;
      in_offset_duration(j)            :=   p_klnhv_tbl(i).offset_duration;
      in_offset_period(j)              :=   p_klnhv_tbl(i).offset_period;
      in_incident_severity_id(j)     :=   p_klnhv_tbl(i).incident_severity_id;
      in_pdf_id(j)                   :=   p_klnhv_tbl(i).pdf_id;
      in_work_thru_yn(j)               :=   p_klnhv_tbl(i).work_thru_yn;
      in_react_active_yn(j)            :=   p_klnhv_tbl(i).react_active_yn;
      in_transfer_option(j)            :=   p_klnhv_tbl(i).transfer_option;
      in_prod_upgrade_yn(j)            :=   p_klnhv_tbl(i).prod_upgrade_yn;
      in_inheritance_type(j)           :=   p_klnhv_tbl(i).inheritance_type;
      in_pm_program_id(j)            :=   p_klnhv_tbl(i).pm_program_id;
      in_pm_conf_req_yn(j)             :=   p_klnhv_tbl(i).pm_conf_req_yn;
      in_pm_sch_exists_yn(j)           :=   p_klnhv_tbl(i).pm_sch_exists_yn;
      in_allow_bt_discount(j)          :=   p_klnhv_tbl(i).allow_bt_discount;
      in_apply_default_timezone(j)     :=   p_klnhv_tbl(i).apply_default_timezone;
      in_sync_date_install(j)          :=   p_klnhv_tbl(i).sync_date_install;
      in_object_version_number(j)                   :=  p_klnhv_tbl(i).object_version_number;
      in_security_group_id(j)       :=  p_klnhv_tbl(i).security_group_id;
      in_request_id(j)                              :=  p_klnhv_tbl(i).request_id;
      in_created_by(j)                              :=  p_klnhv_tbl(i).created_by;
      in_creation_date(j)                           :=  p_klnhv_tbl(i).creation_date;
      in_last_updated_by(j)                         :=  p_klnhv_tbl(i).last_updated_by;
      in_last_update_date(j)                        :=  p_klnhv_tbl(i).last_update_date;
      in_last_update_login(j)                       :=  p_klnhv_tbl(i).last_update_login;
      in_major_version(j)                           :=  p_klnhv_tbl(i).major_version;
      in_source_lang(j)      :=   l_source_lang;
      in_sfwt_flag(j)      :=   p_klnhv_tbl(i).sfwt_flag;
      in_invoice_text(j)      :=   p_klnhv_tbl(i).invoice_text;
      in_ib_trx_details(j)      :=   p_klnhv_tbl(i).ib_trx_details;
      in_status_text(j)      :=   p_klnhv_tbl(i).status_text;
      in_react_time_name(j)      :=   p_klnhv_tbl(i).react_time_name;
    i:= p_klnhv_tbl.next(i);
End Loop;


  FORALL i in 1..l_tabsize
    Insert Into oks_k_lines_bh
      (
        id ,
        major_version,
        cle_id ,
        dnz_chr_id ,
        discount_list ,
        acct_rule_id ,
        payment_type ,
        cc_no ,
        cc_expiry_date ,
        cc_bank_acct_id ,
        cc_auth_code ,
        commitment_id ,
        locked_price_list_id ,
        usage_est_yn ,
        usage_est_method ,
        usage_est_start_date ,
        termn_method ,
        ubt_amount ,
        credit_amount ,
        suppressed_credit ,
        override_amount ,
        cust_po_number_req_yn,
        cust_po_number,
        grace_duration ,
        grace_period ,
        inv_print_flag ,
        price_uom ,
        tax_amount ,
        tax_inclusive_yn ,
        tax_status ,
        tax_code ,
        tax_exemption_id ,
        ib_trans_type ,
        ib_trans_date ,
        prod_price ,
        service_price ,
        clvl_list_price ,
        clvl_quantity ,
        clvl_extended_amt ,
        clvl_uom_code ,
        toplvl_operand_code ,
        toplvl_operand_val ,
        toplvl_quantity ,
        toplvl_uom_code ,
        toplvl_adj_price ,
        toplvl_price_qty ,
        averaging_interval ,
        settlement_interval ,
        minimum_quantity ,
        default_quantity ,
        amcv_flag ,
        fixed_quantity ,
        usage_duration ,
        usage_period ,
        level_yn ,
        usage_type ,
        uom_quantified ,
        base_reading ,
        billing_schedule_type ,
        full_credit ,
        coverage_type ,
        exception_cov_id ,
        limit_uom_quantified ,
        discount_amount ,
        discount_percent ,
        offset_duration ,
        offset_period ,
        incident_severity_id ,
        pdf_id ,
        work_thru_yn ,
        react_active_yn ,
        transfer_option ,
        prod_upgrade_yn ,
        inheritance_type ,
        pm_program_id ,
        pm_conf_req_yn ,
        pm_sch_exists_yn ,
        allow_bt_discount ,
        apply_default_timezone ,
        sync_date_install,
        object_version_number ,
        security_group_id ,
        request_id ,
        created_by ,
        creation_date ,
        last_updated_by ,
        last_update_date ,
        last_update_login
      )
       Values (
      in_id(i),
      in_major_version(i),
      in_cle_id(i),
      in_dnz_chr_id(i),
      in_discount_list(i),
      in_acct_rule_id(i),
      in_payment_type(i),
      in_cc_no(i),
      in_cc_expiry_date(i),
      in_cc_bank_acct_id(i),
      in_cc_auth_code(i),
      in_commitment_id(i),
      in_locked_price_list_id(i),
      in_usage_est_yn(i),
      in_usage_est_method(i),
      in_usage_est_start_date(i),
      in_termn_method(i),
      in_ubt_amount(i),
      in_credit_amount(i),
      in_suppressed_credit(i),
      in_override_amount(i),
      in_cust_po_number_req_yn(i),
      in_cust_po_number(i),
      in_grace_duration(i),
      in_grace_period(i),
      in_inv_print_flag(i),
      in_price_uom(i),
      in_tax_amount(i),
      in_tax_inclusive_yn(i),
      in_tax_status(i),
      in_tax_code(i),
      in_tax_exemption_id(i),
      in_ib_trans_type(i),
      in_ib_trans_date(i),
      in_prod_price(i),
      in_service_price(i),
      in_clvl_list_price(i),
      in_clvl_quantity(i),
      in_clvl_extended_amt(i),
      in_clvl_uom_code(i),
      in_toplvl_operand_code(i),
      in_toplvl_operand_val(i),
      in_toplvl_quantity(i),
      in_toplvl_uom_code(i),
      in_toplvl_adj_price(i),
      in_toplvl_price_qty(i),
      in_averaging_interval(i),
      in_settlement_interval(i),
      in_minimum_quantity(i),
      in_default_quantity(i),
      in_amcv_flag(i),
      in_fixed_quantity(i),
      in_usage_duration(i),
      in_usage_period(i),
      in_level_yn(i),
      in_usage_type(i),
      in_uom_quantified(i),
      in_base_reading(i),
      in_billing_schedule_type(i),
      in_full_credit(i),
      in_coverage_type(i),
      in_exception_cov_id(i),
      in_limit_uom_quantified(i),
      in_discount_amount(i),
      in_discount_percent(i),
      in_offset_duration(i),
      in_offset_period(i),
      in_incident_severity_id(i),
      in_pdf_id(i),
      in_work_thru_yn(i),
      in_react_active_yn(i),
      in_transfer_option(i),
      in_prod_upgrade_yn(i),
      in_inheritance_type(i),
      in_pm_program_id(i),
      in_pm_conf_req_yn(i),
      in_pm_sch_exists_yn(i),
      in_allow_bt_discount(i),
      in_apply_default_timezone(i),
      in_sync_date_install(i),
      in_object_version_number(i),
      in_security_group_id(i),
      in_request_id(i),
      in_created_by(i),
      in_creation_date(i),
      in_last_updated_by(i),
      in_last_update_date(i),
      in_last_update_login(i)
      );

 FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
 FORALL i in 1..l_tabsize
    Insert Into oks_k_lines_tlh
    (
        id ,
        major_version,
        language ,
        source_lang ,
        sfwt_flag ,
        invoice_text ,
        ib_trx_details ,
        status_text ,
        react_time_name ,
        security_group_id ,
        created_by ,
        creation_date ,
        last_updated_by ,
        last_update_date ,
        last_update_login
      ) Values (
        in_id (i),
        in_major_version(i),
        OKC_UTIL.g_language_code(lang_i),
        in_source_lang (i),
        in_sfwt_flag (i),
        in_invoice_text (i),
        in_ib_trx_details (i),
        in_status_text (i),
        in_react_time_name (i),
        in_security_group_id (i),
        in_created_by (i),
        in_creation_date (i),
        in_last_updated_by (i),
        in_last_update_date (i),
        in_last_update_login(i)
     );
End Loop;

EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End CREATE_LINE_VERSION_UPG;


END oks_contract_line_pub;


/
