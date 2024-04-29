--------------------------------------------------------
--  DDL for Package Body OKL_TRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRY_PVT" as
/* $Header: OKLSTRYB.pls 120.8 2007/04/16 10:01:28 dpsingh noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  function get_seq_id return number is
  begin
    return(Okc_P_Util.raw_to_number(sys_guid()));
  end get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  procedure qc is
  begin
    null;
  end qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  procedure change_version is
  begin
    null;
  end change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  procedure api_copy is
  begin
    null;
  end api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  procedure add_language is
  begin
    delete from OKL_TRX_TYPES_TL T
     where not exists (
        select null
          from OKL_TRX_TYPES_B B    --fixed bug 3321017 by kmotepal
         where B.ID = T.ID
        );

    update OKL_TRX_TYPES_TL T set (
        name,
        DESCRIPTION,
        CONTRACT_HEADER_LINE_FLAG,
        TRANSACTION_HEADER_LINE_DETAIL) = (select
                                  B.name,
                                  B.DESCRIPTION,
                                  B.CONTRACT_HEADER_LINE_FLAG,
                                  B.TRANSACTION_HEADER_LINE_DETAIL
                                from OKL_TRX_TYPES_TL B
                               where B.ID = T.ID
                                 and B.language = T.SOURCE_LANG)
      where (
              T.ID,
              T.language)
          in (select
                  SUBT.ID,
                  SUBT.language
                from OKL_TRX_TYPES_TL SUBB, OKL_TRX_TYPES_TL SUBT
               where SUBB.ID = SUBT.ID
                 and SUBB.language = SUBT.SOURCE_LANG
                 and (SUBB.name <> SUBT.name
                      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      or SUBB.CONTRACT_HEADER_LINE_FLAG <> SUBT.CONTRACT_HEADER_LINE_FLAG
                      or SUBB.TRANSACTION_HEADER_LINE_DETAIL <> SUBT.TRANSACTION_HEADER_LINE_DETAIL
                      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
                      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
              ));

    insert into OKL_TRX_TYPES_TL (
        ID,
        language,
        SOURCE_LANG,
        SFWT_FLAG,
        name,
        DESCRIPTION,
        CONTRACT_HEADER_LINE_FLAG,
        TRANSACTION_HEADER_LINE_DETAIL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      select
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.name,
            B.DESCRIPTION,
            B.CONTRACT_HEADER_LINE_FLAG,
            B.TRANSACTION_HEADER_LINE_DETAIL,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        from OKL_TRX_TYPES_TL B, FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
         and B.language = USERENV('LANG')
         and not exists(
                    select null
                      from OKL_TRX_TYPES_TL T
                     where T.ID = B.ID
                       and T.language = L.LANGUAGE_CODE
                    );

  end add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_TYPES_B
  ---------------------------------------------------------------------------
  function get_rec (
    p_try_rec                      in try_rec_type,
    x_no_data_found                out NOCOPY boolean
  ) return try_rec_type is
    cursor okl_trx_types_b_pk_csr (p_id                 in number) is
    select
            ID,
            TRY_ID,
            TRY_ID_FOR,
            ILC_ID,
            AEP_CODE,
            TRY_TYPE,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TRX_TYPE_CLASS,
            --Added by kthiruva on 04-May-2005 for Tax Enhancements
            --Bug 4386433 - Start of Changes
            TAX_UPFRONT_YN,
            TAX_INVOICE_YN,
            TAX_SCHEDULE_YN,
            --Bug 4386433 - End of Changes
	    --Bug 5707866 dpsingh
	    FORMULA_YN,
	    ACCOUNTING_EVENT_CLASS_CODE
      from Okl_Trx_Types_B
     where okl_trx_types_b.id   = p_id;
    l_okl_trx_types_b_pk           okl_trx_types_b_pk_csr%rowtype;
    l_try_rec                      try_rec_type;
  begin
    x_no_data_found := true;
    -- Get current database values
    open okl_trx_types_b_pk_csr (p_try_rec.id);
    fetch okl_trx_types_b_pk_csr into
              l_try_rec.ID,
              l_try_rec.TRY_ID,
              l_try_rec.TRY_ID_FOR,
              l_try_rec.ILC_ID,
              l_try_rec.AEP_CODE,
              l_try_rec.TRY_TYPE,
              l_try_rec.OBJECT_VERSION_NUMBER,
              l_try_rec.ORG_ID,
              l_try_rec.CREATED_BY,
              l_try_rec.CREATION_DATE,
              l_try_rec.LAST_UPDATED_BY,
              l_try_rec.LAST_UPDATE_DATE,
              l_try_rec.LAST_UPDATE_LOGIN,
              l_try_rec.TRX_TYPE_CLASS,
              --Added by kthiruva on 04-May-2005 for Tax Enhancements
              --Bug 4386433 - Start of Changes
              l_try_rec.TAX_UPFRONT_YN,
              l_try_rec.TAX_INVOICE_YN,
              l_try_rec.TAX_SCHEDULE_YN,
              --Bug 4386433 - End of Changes
	      --Bug 5707866 dpsingh
	      l_try_rec.FORMULA_YN,
	      l_try_rec.ACCOUNTING_EVENT_CLASS_CODE;
    x_no_data_found := okl_trx_types_b_pk_csr%notfound;
    close okl_trx_types_b_pk_csr;
    return(l_try_rec);
  end get_rec;

  function get_rec (
    p_try_rec                      in try_rec_type
  ) return try_rec_type is
    l_row_notfound                 boolean := true;
  begin
    return(get_rec(p_try_rec, l_row_notfound));
  end get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_TYPES_TL
  ---------------------------------------------------------------------------
  function get_rec (
    p_okl_trx_types_tl_rec         in okl_trx_types_tl_rec_type,
    x_no_data_found                out NOCOPY boolean
  ) return okl_trx_types_tl_rec_type is
    cursor okl_trx_types_tl_pk_csr (p_id                 in number,
                                    p_language           in varchar2) is
    select
            ID,
            language,
            SOURCE_LANG,
            SFWT_FLAG,
            name,
            DESCRIPTION,
            CONTRACT_HEADER_LINE_FLAG,
            TRANSACTION_HEADER_LINE_DETAIL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      from Okl_Trx_Types_Tl
     where okl_trx_types_tl.id  = p_id
       and okl_trx_types_tl.language = p_language;
    l_okl_trx_types_tl_pk          okl_trx_types_tl_pk_csr%rowtype;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
  begin
    x_no_data_found := true;
    -- Get current database values
    open okl_trx_types_tl_pk_csr (p_okl_trx_types_tl_rec.id,
                                  p_okl_trx_types_tl_rec.language);
    fetch okl_trx_types_tl_pk_csr into
              l_okl_trx_types_tl_rec.ID,
              l_okl_trx_types_tl_rec.language,
              l_okl_trx_types_tl_rec.SOURCE_LANG,
              l_okl_trx_types_tl_rec.SFWT_FLAG,
              l_okl_trx_types_tl_rec.name,
              l_okl_trx_types_tl_rec.DESCRIPTION,
              l_okl_trx_types_tl_rec.CONTRACT_HEADER_LINE_FLAG,
              l_okl_trx_types_tl_rec.TRANSACTION_HEADER_LINE_DETAIL,
              l_okl_trx_types_tl_rec.CREATED_BY,
              l_okl_trx_types_tl_rec.CREATION_DATE,
              l_okl_trx_types_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_types_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_types_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_types_tl_pk_csr%notfound;
    close okl_trx_types_tl_pk_csr;
    return(l_okl_trx_types_tl_rec);
  end get_rec;

  function get_rec (
    p_okl_trx_types_tl_rec         in okl_trx_types_tl_rec_type
  ) return okl_trx_types_tl_rec_type is
    l_row_notfound                 boolean := true;
  begin
    return(get_rec(p_okl_trx_types_tl_rec, l_row_notfound));
  end get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_TYPES_V
  ---------------------------------------------------------------------------
  function get_rec (
    p_tryv_rec                     in tryv_rec_type,
    x_no_data_found                out NOCOPY boolean
  ) return tryv_rec_type is
    cursor okl_tryv_pk_csr (p_id                 in number) is
    select
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            AEP_CODE,
            ILC_ID,
            TRY_ID,
            TRY_ID_FOR,
            TRY_TYPE,
            name,
            DESCRIPTION,
            CONTRACT_HEADER_LINE_FLAG,
            TRANSACTION_HEADER_LINE_DETAIL,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TRX_TYPE_CLASS,
            --Added by kthiruva on 04-May-2005 for Tax Enhancements
            --Bug 4386433 - Start of Changes
            TAX_UPFRONT_YN,
            TAX_INVOICE_YN,
            TAX_SCHEDULE_YN,
            --Bug 4386433 - End of Changes
	    --Bug 5707866 dpsingh
            FORMULA_YN,
            ACCOUNTING_EVENT_CLASS_CODE
      from Okl_Trx_Types_V
     where okl_trx_types_v.id   = p_id;
    l_okl_tryv_pk                  okl_tryv_pk_csr%rowtype;
    l_tryv_rec                     tryv_rec_type;
  begin
    x_no_data_found := true;
    -- Get current database values
    open okl_tryv_pk_csr (p_tryv_rec.id);
    fetch okl_tryv_pk_csr into
              l_tryv_rec.ID,
              l_tryv_rec.OBJECT_VERSION_NUMBER,
              l_tryv_rec.SFWT_FLAG,
              l_tryv_rec.AEP_CODE,
              l_tryv_rec.ILC_ID,
              l_tryv_rec.TRY_ID,
              l_tryv_rec.TRY_ID_FOR,
              l_tryv_rec.TRY_TYPE,
              l_tryv_rec.name,
              l_tryv_rec.DESCRIPTION,
              l_tryv_rec.CONTRACT_HEADER_LINE_FLAG,
              l_tryv_rec.TRANSACTION_HEADER_LINE_DETAIL,
              l_tryv_rec.ORG_ID,
              l_tryv_rec.CREATED_BY,
              l_tryv_rec.CREATION_DATE,
              l_tryv_rec.LAST_UPDATED_BY,
              l_tryv_rec.LAST_UPDATE_DATE,
              l_tryv_rec.LAST_UPDATE_LOGIN,
              l_tryv_rec.TRX_TYPE_CLASS,
              --Added by kthiruva on 04-May-2005 for Tax Enhancements
              --Bug 4386433 - Start of Changes
              l_tryv_rec.TAX_UPFRONT_YN,
              l_tryv_rec.TAX_INVOICE_YN,
              l_tryv_rec.TAX_SCHEDULE_YN,
              --Bug 4386433 - End of Changes
	      --Bug 5707866 dpsingh
	       l_tryv_rec.FORMULA_YN,
	       l_tryv_rec.ACCOUNTING_EVENT_CLASS_CODE;
    x_no_data_found := okl_tryv_pk_csr%notfound;
    close okl_tryv_pk_csr;
    return(l_tryv_rec);
  end get_rec;

  function get_rec (
    p_tryv_rec                     in tryv_rec_type
  ) return tryv_rec_type is
    l_row_notfound                 boolean := true;
  begin
    return(get_rec(p_tryv_rec, l_row_notfound));
  end get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_TYPES_V --
  -----------------------------------------------------
  function null_out_defaults (
    p_tryv_rec	in tryv_rec_type
  ) return tryv_rec_type is
    l_tryv_rec	tryv_rec_type := p_tryv_rec;
  begin
    if (l_tryv_rec.object_version_number = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.object_version_number := null;
    end if;
    if (l_tryv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.sfwt_flag := null;
    end if;
    if (l_tryv_rec.aep_code = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.aep_code := null;
    end if;
    if (l_tryv_rec.ilc_id = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.ilc_id := null;
    end if;
    if (l_tryv_rec.try_id = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.try_id := null;
    end if;
    if (l_tryv_rec.try_id_for = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.try_id_for := null;
    end if;
    if (l_tryv_rec.try_type = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.try_type := null;
    end if;
    if (l_tryv_rec.name = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.name := null;
    end if;
    if (l_tryv_rec.description = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.description := null;
    end if;
    if (l_tryv_rec.contract_header_line_flag = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.contract_header_line_flag := null;
    end if;
    if (l_tryv_rec.transaction_header_line_detail = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.transaction_header_line_detail := null;
    end if;
    if (l_tryv_rec.org_id = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.org_id := null;
    end if;
    if (l_tryv_rec.created_by = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.created_by := null;
    end if;
    if (l_tryv_rec.creation_date = Okc_Api.G_MISS_DATE) then
      l_tryv_rec.creation_date := null;
    end if;
    if (l_tryv_rec.last_updated_by = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.last_updated_by := null;
    end if;
    if (l_tryv_rec.last_update_date = Okc_Api.G_MISS_DATE) then
      l_tryv_rec.last_update_date := null;
    end if;
    if (l_tryv_rec.last_update_login = Okc_Api.G_MISS_NUM) then
      l_tryv_rec.last_update_login := null;
    end if;
    if (l_tryv_rec.trx_type_class = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.trx_type_class := null;
    end if;
    --Added by kthiruva on 04-May-2005 for Tax Enhancements
    --Bug 4386433 - Start of Changes
    if (l_tryv_rec.tax_upfront_yn = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.tax_upfront_yn := null;
    end if;
    if (l_tryv_rec.tax_invoice_yn = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.tax_invoice_yn := null;
    end if;
    if (l_tryv_rec.tax_schedule_yn = Okc_Api.G_MISS_CHAR) then
      l_tryv_rec.tax_schedule_yn := null;
    end if;
    --Bug 4386433 - End of Changes
    --Bug 5707866 dpsingh
if (l_tryv_rec.formula_yn = Okl_Api.G_MISS_CHAR) then
      l_tryv_rec.formula_yn := null;
    end if;
    if (l_tryv_rec.accounting_event_class_code = Okl_Api.G_MISS_CHAR) then
      l_tryv_rec.accounting_event_class_code := null;
    end if;
    return(l_tryv_rec);
  end null_out_defaults;

  /**** Commenting out nocopy generated code in favour of hand written code ********
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_TRX_TYPES_V --
  ---------------------------------------------
  function Validate_Attributes (
    p_tryv_rec in  tryv_rec_type
  ) return varchar2 is
    l_return_status	varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  begin
    if p_tryv_rec.id = OKC_API.G_MISS_NUM or
       p_tryv_rec.id is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.object_version_number = OKC_API.G_MISS_NUM or
          p_tryv_rec.object_version_number is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.aep_code = OKC_API.G_MISS_CHAR or
          p_tryv_rec.aep_code is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'aep_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.ilc_id = OKC_API.G_MISS_NUM or
          p_tryv_rec.ilc_id is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ilc_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.try_type = OKC_API.G_MISS_CHAR or
          p_tryv_rec.try_type is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'try_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.name = OKC_API.G_MISS_CHAR or
          p_tryv_rec.name is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.contract_header_line_flag = OKC_API.G_MISS_CHAR or
          p_tryv_rec.contract_header_line_flag is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_header_line_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    elsif p_tryv_rec.transaction_header_line_detail = OKC_API.G_MISS_CHAR or
          p_tryv_rec.transaction_header_line_detail is null
    then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'transaction_header_line_detail');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    return(l_return_status);
  end Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate_Record for:OKL_TRX_TYPES_V --
  -----------------------------------------
  function Validate_Record (
    p_tryv_rec in tryv_rec_type
  ) return varchar2 is
    l_return_status                varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  begin
    return (l_return_status);
  end Validate_Record;

  **************** end Commenting generated code ***************************/

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
  procedure Validate_Id (x_return_status out NOCOPY  varchar2
  						,p_tryv_rec      in   tryv_rec_type )
  is

  l_return_status         varchar2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    if (p_tryv_rec.id is null) or
       (p_tryv_rec.id = Okc_Api.G_MISS_NUM) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing necessary; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Id;

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
  procedure Validate_Object_Version_Number(x_return_status out NOCOPY  varchar2
  										  ,p_tryv_rec      in   tryv_rec_type )
  is

  l_return_status         varchar2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    if (p_tryv_rec.object_version_number is null) or
       (p_tryv_rec.object_version_number = Okc_Api.G_MISS_NUM) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing necessary; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Object_Version_Number;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sfwt_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sfwt_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  procedure Validate_Sfwt_Flag(x_return_status out NOCOPY  varchar2
  							  ,p_tryv_rec      in   tryv_rec_type)
  is

  l_return_status         varchar2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy			      varchar2(1) := '?';

  begin
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    if (p_tryv_rec.sfwt_flag is null) or
       (p_tryv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'sfwt_flag');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
      -- check if sfwt_flag is in uppercase
      elsif (p_tryv_rec.sfwt_flag) <> UPPER(p_tryv_rec.sfwt_flag) then
         Okc_Api.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'sfwt_flag');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
         raise G_EXCEPTION_HALT_VALIDATION;
      -- check if sfwt_flag is Y or N
      elsif p_tryv_rec.sfwt_flag is not null then
	  --Check if sfwt_flag exists in the fnd_common_lookups or not

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type  => 'YES_NO',
                                                          p_lookup_code => p_tryv_rec.sfwt_flag,
                                                          p_app_id      => 0,
                                                          p_view_app_id => 0);
      if l_dummy = OKC_API.G_FALSE then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'sfwt_flag');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	    end if;
      end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Sfwt_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Aep_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Aep_Code
  -- Description     : Checks if code exists in FND_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Aep_Code(
     	x_return_status  out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKC_API.G_FALSE;

    begin
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing

    if (p_tryv_rec.aep_code is not null) and
       (p_tryv_rec.aep_code <> Okc_Api.G_MISS_CHAR) then
        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                        (p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                         p_lookup_code => p_tryv_rec.aep_code);

	if l_dummy = OKC_API.G_FALSE then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'aep_code');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    end if;

   exception
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => SQLCODE,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    end Validate_Aep_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  procedure Validate_Name(x_return_status out NOCOPY  varchar2
  						 ,p_tryv_rec      in   tryv_rec_type )
  is

  l_return_status         varchar2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  begin
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    if (p_tryv_rec.name is null) or
       (p_tryv_rec.name = Okc_Api.G_MISS_CHAR) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'name');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing necessary; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ilc_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ilc_Id
  -- Description     : Checks if code exists in FND_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Ilc_Id(x_return_status 	out NOCOPY varchar2
     						,p_tryv_rec          in tryv_rec_type ) is
    begin
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing

    if (p_tryv_rec.ilc_id is null) or
       (p_tryv_rec.ilc_id = Okc_Api.G_MISS_NUM) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'ilc_id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
    end if;

   exception
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => SQLCODE,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    end Validate_Ilc_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Try_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Try_Id
  -- Description     : Checks if id exists in okl_trx_types_v
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Try_Id( x_return_status 	out NOCOPY varchar2
     						 ,p_tryv_rec          in tryv_rec_type )
   is

	cursor try_id_csr(p_id in number) is
	select '1'
	from OKL_TRX_TYPES_V
	where id = p_id;
	l_dummy		varchar2(1) := '?';

    begin
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	if (p_tryv_rec.try_id is not null) and
           (p_tryv_rec.try_id <> OKC_API.G_MISS_NUM) then
	  open try_id_csr(p_tryv_rec.try_id);
	  fetch try_id_csr into l_dummy;
	  if (try_id_csr%notfound) then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'try_id');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
                close try_id_csr;
		raise G_EXCEPTION_HALT_VALIDATION;
	  end if;
	  close try_id_csr ;
    end if;

   exception
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => SQLCODE,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    end Validate_Try_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Try_Id_For
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Try_Id_For
  -- Description     : Checks if id exists in okl_trx_types_v
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Try_Id_For(
     	x_return_status  out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	cursor try_id_for_csr(p_id in number) is
	select '1'
	from OKL_TRX_TYPES_V
	where id = p_id;
	l_dummy		varchar2(1) := '?';

    begin
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	if (p_tryv_rec.try_id_for is not null) and
           (p_tryv_rec.try_id_for <> OKC_API.G_MISS_NUM) then

	  open try_id_for_csr(p_tryv_rec.try_id_for);
	  fetch try_id_for_csr into l_dummy;
	  if (try_id_for_csr%notfound) then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'try_id_for');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
	        close try_id_for_csr ;
		raise G_EXCEPTION_HALT_VALIDATION;
	  end if;
	  close try_id_for_csr ;
    end if;

   exception
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => SQLCODE,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    end Validate_Try_Id_For;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Try_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Try_Type
  -- Description     : Checks if code exists in FND_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Try_Type(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKC_API.G_FALSE;

    begin
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing

    if (p_tryv_rec.try_type is null) or
       (p_tryv_rec.try_type = Okc_Api.G_MISS_CHAR) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'try_type');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
    end if;
    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                (p_lookup_type => 'OKL_TRANSACTION_TYPE_CATEGORY',
                 p_lookup_code => p_tryv_rec.try_type);

	   if (l_dummy = OKC_API.G_FALSE) then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'try_type');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	  end if;

   exception
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => SQLCODE,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    end Validate_Try_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Chl_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Chl_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  procedure Validate_Chl_Flag(x_return_status out NOCOPY  varchar2
  							  ,p_tryv_rec      in   tryv_rec_type)
  is

  l_return_status         varchar2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                 varchar2(1)  := OKC_API.G_FALSE;
  l_app_id                number := 0;
  l_view_app_id           number := 0;

  begin
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    if (p_tryv_rec.contract_header_line_flag is null) or
       (p_tryv_rec.contract_header_line_flag = Okc_Api.G_MISS_CHAR) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'contract_header_line_flag');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
      -- check if contract_header_line_flag is in uppercase
    elsif (p_tryv_rec.contract_header_line_flag) <> UPPER(p_tryv_rec.contract_header_line_flag) then
         Okc_Api.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'contract_header_line_flag');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
         raise G_EXCEPTION_HALT_VALIDATION;
      -- check if contract_header_line_flag is Y or N
    else
	  --Check if contract_header_line_flag exists in the fnd_common_lookups or not
	  l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                        (p_lookup_type => 'YES_NO',
                         p_lookup_code => p_tryv_rec.contract_header_line_flag,
                         p_app_id => l_app_id,
                         p_view_app_id => l_view_app_id);
	    if l_dummy = OKC_API.G_FALSE then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'contract_header_line_flag');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	    end if;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Chl_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Thl_Detail
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Thl_Detail
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  procedure Validate_Thl_Detail(x_return_status out NOCOPY  varchar2
  							  ,p_tryv_rec      in   tryv_rec_type)
  is

  l_return_status         varchar2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                  varchar2(1)  := OKC_API.G_FALSE;
  l_app_id                 number := 0;
  l_view_app_id            number := 0;

  begin
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    if (p_tryv_rec.transaction_header_line_detail is null) or
       (p_tryv_rec.transaction_header_line_detail = Okc_Api.G_MISS_CHAR) then
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'transaction_header_line_detail');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       raise G_EXCEPTION_HALT_VALIDATION;
      -- check if transaction_header_line_detail is in uppercase
    elsif (p_tryv_rec.transaction_header_line_detail) <> UPPER(p_tryv_rec.transaction_header_line_detail) then
         Okc_Api.SET_MESSAGE(p_app_name         => g_app_name
                            ,p_msg_name         => g_uppercase_required
                            ,p_token1           => g_col_name_token
                            ,p_token1_value     => 'transaction_header_line_detail');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
         raise G_EXCEPTION_HALT_VALIDATION;
      -- check if transaction_header_line_detail is Y or N
	else
	   l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                        (p_lookup_type => 'YES_NO',
                         p_lookup_code => p_tryv_rec.transaction_header_line_detail,
                         p_app_id      => l_app_id,
                         p_view_app_id => l_view_app_id);
	    if (l_dummy = OKC_API.G_FALSE) then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'transaction_header_line_detail');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	    end if;
    end if;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Thl_Detail;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Trx_type_class
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Trx_type_class
  -- Description     : Checks if code exists in FND_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Trx_Type_Class(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKC_API.G_FALSE;

    begin

  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    if (p_tryv_rec.trx_type_class is not null) and
       (p_tryv_rec.trx_type_class <>  Okc_Api.G_MISS_CHAR) then

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                 (p_lookup_type => 'OKL_TRANSACTION_TYPE_CLASS',
                 p_lookup_code => p_tryv_rec.trx_type_class);

	   if (l_dummy = OKC_API.G_FALSE) then
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'trx_type_class');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	  end if;
     end if;

   exception
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => SQLCODE,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    end Validate_TRX_TYPE_CLASS;

  --Added by kthiruva on 06-May-2005 as part of Tax Enhancements
  --Bug 4386433 - Start of Changes
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tax_Upfont_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tax_Upfront_YN
  -- Description     : Checks if code exists in FND_LOOKUPS for tax_upfront_yn
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Tax_Upfront_YN(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKC_API.G_FALSE;

    begin

     -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_tryv_rec.tax_upfront_yn IS NOT NULL THEN
    --Check if tax_upfront_yn exists in the fnd_common_lookups or not
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type  => 'YES_NO',
                                                          p_lookup_code => p_tryv_rec.tax_upfront_yn,
                                                          p_app_id      => 0,
                                                          p_view_app_id => 0);
      IF l_dummy = OKC_API.G_FALSE THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'tax_upfront_yn');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Tax_Upfront_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tax_Invoice_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tax_Invoice_YN
  -- Description     : Checks if code exists in FND_LOOKUPS for Tax_Invoice_YN
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Tax_Invoice_YN(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKC_API.G_FALSE;

    begin

     -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_tryv_rec.tax_invoice_yn IS NOT NULL THEN
    --Check if tax_upfront_yn exists in the fnd_common_lookups or not
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type  => 'YES_NO',
                                                          p_lookup_code => p_tryv_rec.tax_invoice_yn,
                                                          p_app_id      => 0,
                                                          p_view_app_id => 0);
      IF l_dummy = OKC_API.G_FALSE THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'tax_invoice_yn');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Tax_Invoice_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tax_Schedule_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tax_Schedule_YN
  -- Description     : Checks if code exists in FND_LOOKUPS for tax_schedule_yn
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Tax_Schedule_YN(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKC_API.G_FALSE;

    begin

     -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_tryv_rec.tax_schedule_yn IS NOT NULL THEN
    --Check if tax_upfront_yn exists in the fnd_common_lookups or not
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type  => 'YES_NO',
                                                          p_lookup_code => p_tryv_rec.tax_schedule_yn,
                                                          p_app_id      => 0,
                                                          p_view_app_id => 0);
      IF l_dummy = OKC_API.G_FALSE THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'tax_schedule_yn');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Tax_Schedule_YN;
  -- Bug 4386433 - End of Changes

--Bug 5707866 dpsingh
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Formula_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Formula_YN
  -- Description     : Checks if code exists in FND_LOOKUPS for formula_yn
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Formula_YN(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKL_API.G_FALSE;

    begin

     -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_tryv_rec.formula_yn IS NOT NULL THEN
    --Check if formula_yn exists in the fnd_common_lookups or not
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type  => 'OKL_YES_NO',
                                                          p_lookup_code => p_tryv_rec.formula_yn,
                                                          p_app_id      => 540,
                                                          p_view_app_id => 0);
      IF l_dummy = OKL_API.G_FALSE THEN
		Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'formula_yn');
          	x_return_status := Okl_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Formula_YN;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accnt_Evnt_Class_Cde
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Accnt_Evnt_Class_Cde
  -- Description     : Checks if code exists in FND_LOOKUPS for accounting_event_class_code
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   procedure Validate_Accnt_Evnt_Class_Cde(
     	x_return_status 	out NOCOPY varchar2
	   ,p_tryv_rec          in tryv_rec_type ) is

	l_dummy		varchar2(1) := OKL_API.G_FALSE;

    begin

     -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_tryv_rec.accounting_event_class_code IS NOT NULL THEN
    --Check if accounting_event_class_code exists in the fnd_common_lookups or not
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type  => 'OKL_ACCOUNTING_EVENT_CLASS',
                                                          p_lookup_code => p_tryv_rec.accounting_event_class_code,
                                                          p_app_id      => 540,
                                                          p_view_app_id => 0);
      IF l_dummy = OKL_API.G_FALSE THEN
		Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'accounting_event_class_code');
          	x_return_status := Okl_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing required ; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Accnt_Evnt_Class_Cde;

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

  function Validate_Attributes (
    p_tryv_rec in  tryv_rec_type
  ) return varchar2 is

    x_return_status	varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
  begin

     -- call each column-level validation

    -- Validate_Id
    Validate_Id(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_Name
    Validate_Name(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;


    -- Validate_Sfwt_Flag
       Validate_Sfwt_Flag(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_Aep_Code
       Validate_Aep_Code(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;


    -- Validate_Ilc_Id
       Validate_Ilc_Id(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;


    -- Validate_Try_Id
       Validate_Try_Id(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_Try_Id_For
       Validate_Try_Id_For(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;


    -- Validate_Chl_Flag
       Validate_Chl_Flag(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_Thl_Detail
       Validate_Thl_Detail(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_trx_type_class
       Validate_trx_type_class(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    --Added by kthiruva on 06-May-2005 for the impact of Tax Enhancements
	--Bug 4386433 - Start of Changes
	-- Validate_tax_upfront_yn
       Validate_tax_upfront_yn(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_tax_invoice_yn
       Validate_tax_invoice_yn(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    -- Validate_tax_schedule_yn
       Validate_tax_schedule_yn(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;
	   --Bug 4386433 - End of Changes
   --Bug 5707866 dpsingh
	   -- Validate_Formula_YN
       Validate_Formula_YN(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

       -- Validate_Accnt_Evnt_Class_Cde
       Validate_Accnt_Evnt_Class_Cde(x_return_status, p_tryv_rec);
    -- store the highest degree of error
       if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
          if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
          -- need to leave
          l_return_status := x_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
          else
          -- record that there was an error
          l_return_status := x_return_status;
          end if;
       end if;

    return(l_return_status);
  exception
    when G_EXCEPTION_HALT_VALIDATION then
       -- just come out with return status
       null;
       return (l_return_status);

    when OTHERS then
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       return(l_return_status);

  end Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Try_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Try_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  procedure Validate_Unique_Try_Record(x_return_status out NOCOPY  varchar2
  									  ,p_tryv_rec      in   tryv_rec_type)
  is

  l_dummy                 varchar2(1);
  l_row_found             boolean := false;
  l_language              OKL_TRX_TYPES_TL.language%type := USERENV('LANG');
    cursor unique_try_csr(p_name okl_trx_types_tl.name%type
						 ,p_language OKL_TRX_TYPES_TL.language%type
						 ,p_id OKL_TRX_TYPES_TL.id%type ) is
    select 1
    from okl_trx_types_tl
    where  name = p_name
    and    language = l_language
    and    id <> p_id;

  begin

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    open unique_try_csr(p_tryv_rec.name,
		 l_language, p_tryv_rec.id);
    fetch unique_try_csr into l_dummy;
    l_row_found := unique_try_csr%found;
    close unique_try_csr;
    if l_row_found then
		Okc_Api.set_message('OKL',G_UNQS);
		x_return_status := Okc_Api.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
    end if;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing necessary; validation can continue
    -- with the next column
    null;

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Unique_Try_Record;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  function Validate_Record (
    p_tryv_rec in tryv_rec_type
  ) return varchar2 is
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
  begin

    -- Validate_Unique_Try_Record
      Validate_Unique_Try_Record(x_return_status,p_tryv_rec );
      -- store the highest degree of error
      if (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) then
        if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
            -- need to leave
            l_return_status := x_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
            else
            -- record that there was an error
            l_return_status := x_return_status;
        end if;
      end if;

  return(l_return_status);

  exception
    when G_EXCEPTION_HALT_VALIDATION then
    -- no processing necessary;  validation can continue
    -- with the next column
    null;
    return (l_return_status);

    when OTHERS then
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  end Validate_Record;


/************************ END HAND CODING **********************************/


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  procedure migrate (
    p_from	in tryv_rec_type,
    p_to	in out NOCOPY try_rec_type
  ) is
  begin
    p_to.id := p_from.id;
    p_to.try_id := p_from.try_id;
    p_to.try_id_for := p_from.try_id_for;
    p_to.ilc_id := p_from.ilc_id;
    p_to.aep_code := p_from.aep_code;
    p_to.trx_type_class := p_from.trx_type_class;
    p_to.try_type := p_from.try_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    --Added by kthiruva on 04-May-2005 for Tax Enhancements
    --Bug 4386433 - Start of Changes
    p_to.tax_upfront_yn := p_from.tax_upfront_yn;
    p_to.tax_invoice_yn := p_from.tax_invoice_yn;
    p_to.tax_schedule_yn := p_from.tax_schedule_yn;
    --Bug 4386433 - End of Changes
    --Bug 5707866 dpsingh
    p_to.formula_yn := p_from.formula_yn;
    p_to.accounting_event_class_code := p_from.accounting_event_class_code;
  end migrate;
  procedure migrate (
    p_from	in try_rec_type,
    p_to	in out NOCOPY tryv_rec_type
  ) is
  begin
    p_to.id := p_from.id;
    p_to.try_id := p_from.try_id;
    p_to.try_id_for := p_from.try_id_for;
    p_to.ilc_id := p_from.ilc_id;
    p_to.aep_code := p_from.aep_code;
    p_to.trx_type_Class := p_from.trx_type_Class;
    p_to.try_type := p_from.try_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    --Added by kthiruva on 04-May-2005 for Tax Enhancements
    --Bug 4386433 - Start of Changes
    p_to.tax_upfront_yn := p_from.tax_upfront_yn;
    p_to.tax_invoice_yn := p_from.tax_invoice_yn;
    p_to.tax_schedule_yn := p_from.tax_schedule_yn;
    --Bug 4386433 - End of Changes
    --Bug 5707866 dpsingh
    p_to.formula_yn := p_from.formula_yn;
    p_to.accounting_event_class_code := p_from.accounting_event_class_code;
  end migrate;
  procedure migrate (
    p_from	in tryv_rec_type,
    p_to	in out NOCOPY okl_trx_types_tl_rec_type
  ) is
  begin
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.contract_header_line_flag := p_from.contract_header_line_flag;
    p_to.transaction_header_line_detail := p_from.transaction_header_line_detail;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  end migrate;
  procedure migrate (
    p_from	in okl_trx_types_tl_rec_type,
    p_to	in out NOCOPY tryv_rec_type
  ) is
  begin
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.contract_header_line_flag := p_from.contract_header_line_flag;
    p_to.transaction_header_line_detail := p_from.transaction_header_line_detail;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  end migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_TRX_TYPES_V --
  --------------------------------------
  procedure validate_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_rec                     in tryv_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_validate_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tryv_rec                     tryv_rec_type := p_tryv_rec;
    l_try_rec                      try_rec_type;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_tryv_rec);
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_return_status := Validate_Record(l_tryv_rec);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:TRYV_TBL --
  ------------------------------------------
  procedure validate_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_tbl                     in tryv_tbl_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_tbl_validate_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              number := 0;
  begin
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    if (p_tryv_tbl.COUNT > 0) then
      i := p_tryv_tbl.FIRST;
      loop
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tryv_rec                     => p_tryv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	if x_return_status <> Okc_Api.G_RET_STS_SUCCESS then
      if l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR then
         l_overall_status := x_return_status;
      end if;
	end if;
/* End Post Generation Change */
        exit when (i = p_tryv_tbl.LAST);
        i := p_tryv_tbl.next(i);
      end loop;
    end if;
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- insert_row for:OKL_TRX_TYPES_B --
  ------------------------------------
  procedure insert_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_try_rec                      in try_rec_type,
    x_try_rec                      out NOCOPY try_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'B_insert_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_try_rec                      try_rec_type := p_try_rec;
    l_def_try_rec                  try_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_B --
    ----------------------------------------
    function Set_Attributes (
      p_try_rec in  try_rec_type,
      x_try_rec out NOCOPY try_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_try_rec := p_try_rec;
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_try_rec,                         -- IN
      l_try_rec);                        -- OUT
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    insert into OKL_TRX_TYPES_B(
        id,
        try_id,
        try_id_for,
        ilc_id,
        aep_code,
        try_type,
        trx_type_class,
        object_version_number,
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        --Added by kthiruva on 04-May-2005 for Tax Enhancements
        --Bug 4386433 - Start of Changes
        tax_upfront_yn,
        tax_invoice_yn,
        tax_schedule_yn,
        --Bug 4386433 - End of Changes,
	--Bug 5707866 dpsingh
       formula_yn,
       accounting_event_class_code
        )
      values (
        l_try_rec.id,
        l_try_rec.try_id,
        l_try_rec.try_id_for,
        l_try_rec.ilc_id,
        l_try_rec.aep_code,
        l_try_rec.try_type,
        l_try_rec.trx_type_class,
        l_try_rec.object_version_number,
        l_try_rec.org_id,
        l_try_rec.created_by,
        l_try_rec.creation_date,
        l_try_rec.last_updated_by,
        l_try_rec.last_update_date,
        l_try_rec.last_update_login,
        --Added by kthiruva on 04-May-2005 for Tax Enhancements
        --Bug 4386433 - Start of Changes
        l_try_rec.tax_upfront_yn,
        l_try_rec.tax_invoice_yn,
        l_try_rec.tax_schedule_yn,
        --Bug 4386433 - End of Changes
	--Bug 5707866 dpsingh
       l_try_rec.formula_yn,
       l_try_rec.accounting_event_class_code
		);
    -- Set OUT values
    x_try_rec := l_try_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end insert_row;
  -------------------------------------
  -- insert_row for:OKL_TRX_TYPES_TL --
  -------------------------------------
  procedure insert_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_okl_trx_types_tl_rec         in okl_trx_types_tl_rec_type,
    x_okl_trx_types_tl_rec         out NOCOPY okl_trx_types_tl_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'TL_insert_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type := p_okl_trx_types_tl_rec;
    l_def_okl_trx_types_tl_rec     okl_trx_types_tl_rec_type;
    cursor get_languages is
      select *
        from FND_LANGUAGES
       where INSTALLED_FLAG in ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_TL --
    -----------------------------------------
    function Set_Attributes (
      p_okl_trx_types_tl_rec in  okl_trx_types_tl_rec_type,
      x_okl_trx_types_tl_rec out NOCOPY okl_trx_types_tl_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_okl_trx_types_tl_rec := p_okl_trx_types_tl_rec;
      x_okl_trx_types_tl_rec.language := USERENV('LANG');
      x_okl_trx_types_tl_rec.SOURCE_LANG := USERENV('LANG');
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_types_tl_rec,            -- IN
      l_okl_trx_types_tl_rec);           -- OUT

    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    for l_lang_rec in get_languages loop
      l_okl_trx_types_tl_rec.language := l_lang_rec.language_code;
      insert into OKL_TRX_TYPES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          description,
          contract_header_line_flag,
          transaction_header_line_detail,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        values (
          l_okl_trx_types_tl_rec.id,
          l_okl_trx_types_tl_rec.language,
          l_okl_trx_types_tl_rec.source_lang,
          l_okl_trx_types_tl_rec.sfwt_flag,
          l_okl_trx_types_tl_rec.name,
          l_okl_trx_types_tl_rec.description,
          l_okl_trx_types_tl_rec.contract_header_line_flag,
          l_okl_trx_types_tl_rec.transaction_header_line_detail,
          l_okl_trx_types_tl_rec.created_by,
          l_okl_trx_types_tl_rec.creation_date,
          l_okl_trx_types_tl_rec.last_updated_by,
          l_okl_trx_types_tl_rec.last_update_date,
          l_okl_trx_types_tl_rec.last_update_login);
    end loop;
    -- Set OUT values
    x_okl_trx_types_tl_rec := l_okl_trx_types_tl_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end insert_row;
  ------------------------------------
  -- insert_row for:OKL_TRX_TYPES_V --
  ------------------------------------
  procedure insert_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_rec                     in tryv_rec_type,
    x_tryv_rec                     out NOCOPY tryv_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_insert_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tryv_rec                     tryv_rec_type;
    l_def_tryv_rec                 tryv_rec_type;
    l_try_rec                      try_rec_type;
    lx_try_rec                     try_rec_type;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
    lx_okl_trx_types_tl_rec        okl_trx_types_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    function fill_who_columns (
      p_tryv_rec	in tryv_rec_type
    ) return tryv_rec_type is
      l_tryv_rec	tryv_rec_type := p_tryv_rec;
    begin
      l_tryv_rec.CREATION_DATE := SYSDATE;
      l_tryv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_tryv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tryv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tryv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      return(l_tryv_rec);
    end fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_V --
    ----------------------------------------
    function Set_Attributes (
      p_tryv_rec in  tryv_rec_type,
      x_tryv_rec out NOCOPY tryv_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_tryv_rec := p_tryv_rec;
      x_tryv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tryv_rec.SFWT_FLAG := 'N';

-- Fixed bug 3070446 by santonyr on 24/07/03

--    x_tryv_rec.ORG_ID := NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99);
      x_tryv_rec.ORG_ID := null;

      x_tryv_rec.CONTRACT_HEADER_LINE_FLAG := 'Y';
      x_tryv_rec.TRANSACTION_HEADER_LINE_DETAIL := 'Y';
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
	if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_tryv_rec := null_out_defaults(p_tryv_rec);
    -- Set primary key value
    l_tryv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tryv_rec,                        -- IN
      l_def_tryv_rec);                   -- OUT
    --- If any errors happen abort API
	if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_def_tryv_rec := fill_who_columns(l_def_tryv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tryv_rec);
		--- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_return_status := Validate_Record(l_def_tryv_rec);
		if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tryv_rec, l_try_rec);
    migrate(l_def_tryv_rec, l_okl_trx_types_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_try_rec,
      lx_try_rec
    );
		if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    migrate(lx_try_rec, l_def_tryv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_types_tl_rec,
      lx_okl_trx_types_tl_rec
    );
		if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    migrate(lx_okl_trx_types_tl_rec, l_def_tryv_rec);
    -- Set OUT values
    x_tryv_rec := l_def_tryv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:TRYV_TBL --
  ----------------------------------------
  procedure insert_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_tbl                     in tryv_tbl_type,
    x_tryv_tbl                     out NOCOPY tryv_tbl_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_tbl_insert_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              number := 0;
  begin
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    if (p_tryv_tbl.COUNT > 0) then
      i := p_tryv_tbl.FIRST;
      loop
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tryv_rec                     => p_tryv_tbl(i),
          x_tryv_rec                     => x_tryv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	if x_return_status <> Okc_Api.G_RET_STS_SUCCESS then
      if l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR then
         l_overall_status := x_return_status;
      end if;
	end if;
/* End Post Generation Change */
        exit when (i = p_tryv_tbl.LAST);
        i := p_tryv_tbl.next(i);
      end loop;
    end if;
    x_return_status := l_overall_status;
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- lock_row for:OKL_TRX_TYPES_B --
  ----------------------------------
  procedure lock_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_try_rec                      in try_rec_type) is

    E_Resource_Busy               exception;
    pragma exception_init(E_Resource_Busy, -00054);
    cursor lock_csr (p_try_rec in try_rec_type) is
    select OBJECT_VERSION_NUMBER
      from OKL_TRX_TYPES_B
     where ID = p_try_rec.id
       and OBJECT_VERSION_NUMBER = p_try_rec.object_version_number
    for update of OBJECT_VERSION_NUMBER nowait;

    cursor  lchk_csr (p_try_rec in try_rec_type) is
    select OBJECT_VERSION_NUMBER
      from OKL_TRX_TYPES_B
    where ID = p_try_rec.id;
    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'B_lock_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_TYPES_B.OBJECT_VERSION_NUMBER%type;
    lc_object_version_number      OKL_TRX_TYPES_B.OBJECT_VERSION_NUMBER%type;
    l_row_notfound                boolean := false;
    lc_row_notfound               boolean := false;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    begin
      open lock_csr(p_try_rec);
      fetch lock_csr into l_object_version_number;
      l_row_notfound := lock_csr%notfound;
      close lock_csr;
    exception
      when E_Resource_Busy then
        if (lock_csr%isopen) then
          close lock_csr;
        end if;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        raise App_Exceptions.RECORD_LOCK_EXCEPTION;
    end;

    if ( l_row_notfound ) then
      open lchk_csr(p_try_rec);
      fetch lchk_csr into lc_object_version_number;
      lc_row_notfound := lchk_csr%notfound;
      close lchk_csr;
    end if;
    if (lc_row_notfound) then
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      raise Okc_Api.G_EXCEPTION_ERROR;
    elsif lc_object_version_number > p_try_rec.object_version_number then
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      raise Okc_Api.G_EXCEPTION_ERROR;
    elsif lc_object_version_number <> p_try_rec.object_version_number then
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      raise Okc_Api.G_EXCEPTION_ERROR;
    elsif lc_object_version_number = -1 then
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end lock_row;
  -----------------------------------
  -- lock_row for:OKL_TRX_TYPES_TL --
  -----------------------------------
  procedure lock_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_okl_trx_types_tl_rec         in okl_trx_types_tl_rec_type) is

    E_Resource_Busy               exception;
    pragma exception_init(E_Resource_Busy, -00054);
    cursor lock_csr (p_okl_trx_types_tl_rec in okl_trx_types_tl_rec_type) is
    select *
      from OKL_TRX_TYPES_TL
     where ID = p_okl_trx_types_tl_rec.id
    for update nowait;

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'TL_lock_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%rowtype;
    l_row_notfound                boolean := false;
    lc_row_notfound               boolean := false;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    begin
      open lock_csr(p_okl_trx_types_tl_rec);
      fetch lock_csr into l_lock_var;
      l_row_notfound := lock_csr%notfound;
      close lock_csr;
    exception
      when E_Resource_Busy then
        if (lock_csr%isopen) then
          close lock_csr;
        end if;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        raise App_Exceptions.RECORD_LOCK_EXCEPTION;
    end;

    if ( l_row_notfound ) then
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end lock_row;
  ----------------------------------
  -- lock_row for:OKL_TRX_TYPES_V --
  ----------------------------------
  procedure lock_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_rec                     in tryv_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_lock_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_try_rec                      try_rec_type;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_tryv_rec, l_try_rec);
    migrate(p_tryv_rec, l_okl_trx_types_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_try_rec
    );
    if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_types_tl_rec
    );
    if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:TRYV_TBL --
  --------------------------------------
  procedure lock_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_tbl                     in tryv_tbl_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_tbl_lock_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              number := 0;
  begin
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    if (p_tryv_tbl.COUNT > 0) then
      i := p_tryv_tbl.FIRST;
      loop
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tryv_rec                     => p_tryv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	if x_return_status <> Okc_Api.G_RET_STS_SUCCESS then
      if l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR then
         l_overall_status := x_return_status;
      end if;
	end if;
/* End Post Generation Change */
        exit when (i = p_tryv_tbl.LAST);
        i := p_tryv_tbl.next(i);
      end loop;
    end if;
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- update_row for:OKL_TRX_TYPES_B --
  ------------------------------------
  procedure update_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_try_rec                      in try_rec_type,
    x_try_rec                      out NOCOPY try_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'B_update_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_try_rec                      try_rec_type := p_try_rec;
    l_def_try_rec                  try_rec_type;
    l_row_notfound                 boolean := true;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    function populate_new_record (
      p_try_rec	in try_rec_type,
      x_try_rec	out NOCOPY try_rec_type
    ) return varchar2 is
      l_try_rec                      try_rec_type;
      l_row_notfound                 boolean := true;
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_try_rec := p_try_rec;
      -- Get current database values
      l_try_rec := get_rec(p_try_rec, l_row_notfound);
      if (l_row_notfound) then
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      end if;
      if (x_try_rec.id = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.id := l_try_rec.id;
      end if;
      if (x_try_rec.try_id = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.try_id := l_try_rec.try_id;
      end if;
      if (x_try_rec.try_id_for = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.try_id_for := l_try_rec.try_id_for;
      end if;
      if (x_try_rec.ilc_id = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.ilc_id := l_try_rec.ilc_id;
      end if;
      if (x_try_rec.aep_code = Okc_Api.G_MISS_CHAR)
      then
        x_try_rec.aep_code := l_try_rec.aep_code;
      end if;
      if (x_try_rec.trx_type_class = Okc_Api.G_MISS_CHAR)
      then
        x_try_rec.trx_type_class := l_try_rec.trx_type_class;
      end if;
      if (x_try_rec.try_type = Okc_Api.G_MISS_CHAR)
      then
        x_try_rec.try_type := l_try_rec.try_type;
      end if;
      if (x_try_rec.object_version_number = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.object_version_number := l_try_rec.object_version_number;
      end if;
      if (x_try_rec.org_id = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.org_id := l_try_rec.org_id;
      end if;
      if (x_try_rec.created_by = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.created_by := l_try_rec.created_by;
      end if;
      if (x_try_rec.creation_date = Okc_Api.G_MISS_DATE)
      then
        x_try_rec.creation_date := l_try_rec.creation_date;
      end if;
      if (x_try_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.last_updated_by := l_try_rec.last_updated_by;
      end if;
      if (x_try_rec.last_update_date = Okc_Api.G_MISS_DATE)
      then
        x_try_rec.last_update_date := l_try_rec.last_update_date;
      end if;
      if (x_try_rec.last_update_login = Okc_Api.G_MISS_NUM)
      then
        x_try_rec.last_update_login := l_try_rec.last_update_login;
      end if;
      --Added by kthiruva on 04-May-2005 for Tax Enhancements
      --Bug 4386433 - Start of Changes
      if (x_try_rec.tax_upfront_yn = Okc_Api.G_MISS_CHAR)
      then
        x_try_rec.tax_upfront_yn := l_try_rec.tax_upfront_yn;
      end if;
	  if (x_try_rec.tax_invoice_yn = Okc_Api.G_MISS_CHAR)
      then
        x_try_rec.tax_invoice_yn := l_try_rec.tax_invoice_yn;
      end if;
	  if (x_try_rec.tax_schedule_yn = Okc_Api.G_MISS_CHAR)
      then
        x_try_rec.tax_schedule_yn := l_try_rec.tax_schedule_yn;
      end if;
      --Bug 4386433 - End of Changes
      --Bug 5707866 dpsingh
       if (x_try_rec.formula_yn = Okl_Api.G_MISS_CHAR)
      then
        x_try_rec.formula_yn := l_try_rec.formula_yn;
      end if;
       if (x_try_rec.accounting_event_class_code = Okl_Api.G_MISS_CHAR)
      then
        x_try_rec.accounting_event_class_code := l_try_rec.accounting_event_class_code;
      end if;
      return(l_return_status);
    end populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_B --
    ----------------------------------------
    function Set_Attributes (
      p_try_rec in  try_rec_type,
      x_try_rec out NOCOPY try_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_try_rec := p_try_rec;
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_try_rec,                         -- IN
      l_try_rec);                        -- OUT
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_return_status := populate_new_record(l_try_rec, l_def_try_rec);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    update  OKL_TRX_TYPES_B
    set TRY_ID = l_def_try_rec.try_id,
        TRY_ID_FOR = l_def_try_rec.try_id_for,
        ILC_ID = l_def_try_rec.ilc_id,
        AEP_CODE = l_def_try_rec.aep_code,
        TRX_TYPE_CLASS = l_def_try_rec.trx_type_Class,
        TRY_TYPE = l_def_try_rec.try_type,
        OBJECT_VERSION_NUMBER = l_def_try_rec.object_version_number,
        ORG_ID = l_def_try_rec.org_id,
        CREATED_BY = l_def_try_rec.created_by,
        CREATION_DATE = l_def_try_rec.creation_date,
        LAST_UPDATED_BY = l_def_try_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_try_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_try_rec.last_update_login,
        --Added by kthiruva on 04-May-2005 for Tax Enhancements
        --Bug 4386433 - Start of Changes
        TAX_UPFRONT_YN = l_def_try_rec.tax_upfront_yn,
        TAX_INVOICE_YN = l_def_try_rec.tax_invoice_yn,
        TAX_SCHEDULE_YN = l_def_try_rec.tax_schedule_yn,
        --Bug 4386433 - End of Changes
	 --Bug 5707866 dpsingh
	FORMULA_YN = l_def_try_rec.formula_yn,
	ACCOUNTING_EVENT_CLASS_CODE = l_def_try_rec.accounting_event_class_code
    where ID = l_def_try_rec.id;

    x_try_rec := l_def_try_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end update_row;
  -------------------------------------
  -- update_row for:OKL_TRX_TYPES_TL --
  -------------------------------------
  procedure update_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_okl_trx_types_tl_rec         in okl_trx_types_tl_rec_type,
    x_okl_trx_types_tl_rec         out NOCOPY okl_trx_types_tl_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'TL_update_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type := p_okl_trx_types_tl_rec;
    l_def_okl_trx_types_tl_rec     okl_trx_types_tl_rec_type;
    l_row_notfound                 boolean := true;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    function populate_new_record (
      p_okl_trx_types_tl_rec	in okl_trx_types_tl_rec_type,
      x_okl_trx_types_tl_rec	out NOCOPY okl_trx_types_tl_rec_type
    ) return varchar2 is
      l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
      l_row_notfound                 boolean := true;
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_okl_trx_types_tl_rec := p_okl_trx_types_tl_rec;
      -- Get current database values
      l_okl_trx_types_tl_rec := get_rec(p_okl_trx_types_tl_rec, l_row_notfound);
      if (l_row_notfound) then
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      end if;
      if (x_okl_trx_types_tl_rec.id = Okc_Api.G_MISS_NUM)
      then
        x_okl_trx_types_tl_rec.id := l_okl_trx_types_tl_rec.id;
      end if;
      if (x_okl_trx_types_tl_rec.language = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.language := l_okl_trx_types_tl_rec.language;
      end if;
      if (x_okl_trx_types_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.source_lang := l_okl_trx_types_tl_rec.source_lang;
      end if;
      if (x_okl_trx_types_tl_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.sfwt_flag := l_okl_trx_types_tl_rec.sfwt_flag;
      end if;
      if (x_okl_trx_types_tl_rec.name = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.name := l_okl_trx_types_tl_rec.name;
      end if;
      if (x_okl_trx_types_tl_rec.description = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.description := l_okl_trx_types_tl_rec.description;
      end if;
      if (x_okl_trx_types_tl_rec.contract_header_line_flag = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.contract_header_line_flag := l_okl_trx_types_tl_rec.contract_header_line_flag;
      end if;
      if (x_okl_trx_types_tl_rec.transaction_header_line_detail = Okc_Api.G_MISS_CHAR)
      then
        x_okl_trx_types_tl_rec.transaction_header_line_detail := l_okl_trx_types_tl_rec.transaction_header_line_detail;
      end if;
      if (x_okl_trx_types_tl_rec.created_by = Okc_Api.G_MISS_NUM)
      then
        x_okl_trx_types_tl_rec.created_by := l_okl_trx_types_tl_rec.created_by;
      end if;
      if (x_okl_trx_types_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
      then
        x_okl_trx_types_tl_rec.creation_date := l_okl_trx_types_tl_rec.creation_date;
      end if;
      if (x_okl_trx_types_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      then
        x_okl_trx_types_tl_rec.last_updated_by := l_okl_trx_types_tl_rec.last_updated_by;
      end if;
      if (x_okl_trx_types_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
      then
        x_okl_trx_types_tl_rec.last_update_date := l_okl_trx_types_tl_rec.last_update_date;
      end if;
      if (x_okl_trx_types_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
      then
        x_okl_trx_types_tl_rec.last_update_login := l_okl_trx_types_tl_rec.last_update_login;
      end if;
      return(l_return_status);
    end populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_TL --
    -----------------------------------------
    function Set_Attributes (
      p_okl_trx_types_tl_rec in  okl_trx_types_tl_rec_type,
      x_okl_trx_types_tl_rec out NOCOPY okl_trx_types_tl_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_okl_trx_types_tl_rec := p_okl_trx_types_tl_rec;
      x_okl_trx_types_tl_rec.language := USERENV('LANG');
      x_okl_trx_types_tl_rec.SOURCE_LANG := USERENV('LANG');
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_types_tl_rec,            -- IN
      l_okl_trx_types_tl_rec);           -- OUT
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_return_status := populate_new_record(l_okl_trx_types_tl_rec, l_def_okl_trx_types_tl_rec);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    update  OKL_TRX_TYPES_TL
    set name = l_def_okl_trx_types_tl_rec.name,
        DESCRIPTION = l_def_okl_trx_types_tl_rec.description,
        CONTRACT_HEADER_LINE_FLAG = l_def_okl_trx_types_tl_rec.contract_header_line_flag,
        TRANSACTION_HEADER_LINE_DETAIL = l_def_okl_trx_types_tl_rec.transaction_header_line_detail,
        CREATED_BY = l_def_okl_trx_types_tl_rec.created_by,
        SOURCE_LANG = l_def_okl_trx_types_tl_rec.source_lang,
        CREATION_DATE = l_def_okl_trx_types_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_trx_types_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_trx_types_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_trx_types_tl_rec.last_update_login
    where ID = l_def_okl_trx_types_tl_rec.id
    and USERENV('LANG') in (SOURCE_LANG, language);
    --  AND SOURCE_LANG = USERENV('LANG');

    update  OKL_TRX_TYPES_TL
    set SFWT_FLAG = 'Y'
    where ID = l_def_okl_trx_types_tl_rec.id
      and SOURCE_LANG <> USERENV('LANG');

    x_okl_trx_types_tl_rec := l_def_okl_trx_types_tl_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end update_row;
  ------------------------------------
  -- update_row for:OKL_TRX_TYPES_V --
  ------------------------------------
  procedure update_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_rec                     in tryv_rec_type,
    x_tryv_rec                     out NOCOPY tryv_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_update_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tryv_rec                     tryv_rec_type := p_tryv_rec;
    l_def_tryv_rec                 tryv_rec_type;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
    lx_okl_trx_types_tl_rec        okl_trx_types_tl_rec_type;
    l_try_rec                      try_rec_type;
    lx_try_rec                     try_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    function fill_who_columns (
      p_tryv_rec	in tryv_rec_type
    ) return tryv_rec_type is
      l_tryv_rec	tryv_rec_type := p_tryv_rec;
    begin
      l_tryv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tryv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tryv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      return(l_tryv_rec);
    end fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    function populate_new_record (
      p_tryv_rec	in tryv_rec_type,
      x_tryv_rec	out NOCOPY tryv_rec_type
    ) return varchar2 is
      l_tryv_rec                     tryv_rec_type;
      l_row_notfound                 boolean := true;
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_tryv_rec := p_tryv_rec;
      -- Get current database values
      l_tryv_rec := get_rec(p_tryv_rec, l_row_notfound);
      if (l_row_notfound) then
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      end if;
      if (x_tryv_rec.id = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.id := l_tryv_rec.id;
      end if;
      if (x_tryv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.object_version_number := l_tryv_rec.object_version_number;
      end if;
      if (x_tryv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.sfwt_flag := l_tryv_rec.sfwt_flag;
      end if;
      if (x_tryv_rec.aep_code = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.aep_code := l_tryv_rec.aep_code;
      end if;
      if (x_tryv_rec.trx_type_class = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.trx_type_class := l_tryv_rec.trx_type_class;
      end if;
      if (x_tryv_rec.ilc_id = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.ilc_id := l_tryv_rec.ilc_id;
      end if;
      if (x_tryv_rec.try_id = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.try_id := l_tryv_rec.try_id;
      end if;
      if (x_tryv_rec.try_id_for = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.try_id_for := l_tryv_rec.try_id_for;
      end if;
      if (x_tryv_rec.try_type = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.try_type := l_tryv_rec.try_type;
      end if;
      if (x_tryv_rec.name = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.name := l_tryv_rec.name;
      end if;
      if (x_tryv_rec.description = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.description := l_tryv_rec.description;
      end if;
      if (x_tryv_rec.contract_header_line_flag = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.contract_header_line_flag := l_tryv_rec.contract_header_line_flag;
      end if;
      if (x_tryv_rec.transaction_header_line_detail = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.transaction_header_line_detail := l_tryv_rec.transaction_header_line_detail;
      end if;
      if (x_tryv_rec.org_id = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.org_id := l_tryv_rec.org_id;
      end if;
      if (x_tryv_rec.created_by = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.created_by := l_tryv_rec.created_by;
      end if;
      if (x_tryv_rec.creation_date = Okc_Api.G_MISS_DATE)
      then
        x_tryv_rec.creation_date := l_tryv_rec.creation_date;
      end if;
      if (x_tryv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.last_updated_by := l_tryv_rec.last_updated_by;
      end if;
      if (x_tryv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      then
        x_tryv_rec.last_update_date := l_tryv_rec.last_update_date;
      end if;
      if (x_tryv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      then
        x_tryv_rec.last_update_login := l_tryv_rec.last_update_login;
      end if;
      --Added by kthiruva on 04-May-2005 for Tax Enhancements
      --Bug 4386433 - Start of Changes
      if (x_tryv_rec.tax_upfront_yn = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.tax_upfront_yn := l_tryv_rec.tax_upfront_yn;
      end if;
      if (x_tryv_rec.tax_invoice_yn = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.tax_invoice_yn := l_tryv_rec.tax_invoice_yn;
      end if;
      if (x_tryv_rec.tax_schedule_yn = Okc_Api.G_MISS_CHAR)
      then
        x_tryv_rec.tax_schedule_yn := l_tryv_rec.tax_schedule_yn;
      end if;
      --Bug 4386433 - End of Changes
      --Bug 5707866 dpsingh
      if (x_tryv_rec.formula_yn = Okl_Api.G_MISS_CHAR)
      then
        x_tryv_rec.formula_yn := l_tryv_rec.formula_yn;
      end if;
      if (x_tryv_rec.accounting_event_class_code = Okl_Api.G_MISS_CHAR)
      then
        x_tryv_rec.accounting_event_class_code := l_tryv_rec.accounting_event_class_code;
      end if;
      return(l_return_status);
    end populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_V --
    ----------------------------------------
    function Set_Attributes (
      p_tryv_rec in  tryv_rec_type,
      x_tryv_rec out NOCOPY tryv_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_tryv_rec := p_tryv_rec;
      x_tryv_rec.OBJECT_VERSION_NUMBER := NVL(x_tryv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tryv_rec,                        -- IN
      l_tryv_rec);                       -- OUT
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_return_status := populate_new_record(l_tryv_rec, l_def_tryv_rec);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_def_tryv_rec := fill_who_columns(l_def_tryv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tryv_rec);
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    l_return_status := Validate_Record(l_def_tryv_rec);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tryv_rec, l_okl_trx_types_tl_rec);
    migrate(l_def_tryv_rec, l_try_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_types_tl_rec,
      lx_okl_trx_types_tl_rec
    );
    if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    migrate(lx_okl_trx_types_tl_rec, l_def_tryv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_try_rec,
      lx_try_rec
    );
    if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    migrate(lx_try_rec, l_def_tryv_rec);
    x_tryv_rec := l_def_tryv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:TRYV_TBL --
  ----------------------------------------
  procedure update_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_tbl                     in tryv_tbl_type,
    x_tryv_tbl                     out NOCOPY tryv_tbl_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_tbl_update_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              number := 0;
  begin
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    if (p_tryv_tbl.COUNT > 0) then
      i := p_tryv_tbl.FIRST;
      loop
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tryv_rec                     => p_tryv_tbl(i),
          x_tryv_rec                     => x_tryv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	if x_return_status <> Okc_Api.G_RET_STS_SUCCESS then
      if l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR then
         l_overall_status := x_return_status;
      end if;
	end if;
/* End Post Generation Change */
        exit when (i = p_tryv_tbl.LAST);
        i := p_tryv_tbl.next(i);
      end loop;
    end if;
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- delete_row for:OKL_TRX_TYPES_B --
  ------------------------------------
  procedure delete_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_try_rec                      in try_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'B_delete_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_try_rec                      try_rec_type:= p_try_rec;
    l_row_notfound                 boolean := true;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    delete from OKL_TRX_TYPES_B
     where ID = l_try_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end delete_row;
  -------------------------------------
  -- delete_row for:OKL_TRX_TYPES_TL --
  -------------------------------------
  procedure delete_row(
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_okl_trx_types_tl_rec         in okl_trx_types_tl_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'TL_delete_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type:= p_okl_trx_types_tl_rec;
    l_row_notfound                 boolean := true;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_TYPES_TL --
    -----------------------------------------
    function Set_Attributes (
      p_okl_trx_types_tl_rec in  okl_trx_types_tl_rec_type,
      x_okl_trx_types_tl_rec out NOCOPY okl_trx_types_tl_rec_type
    ) return varchar2 is
      l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    begin
      x_okl_trx_types_tl_rec := p_okl_trx_types_tl_rec;
      x_okl_trx_types_tl_rec.language := USERENV('LANG');
      return(l_return_status);
    end Set_Attributes;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_types_tl_rec,            -- IN
      l_okl_trx_types_tl_rec);           -- OUT
    --- If any errors happen abort API
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    delete from OKL_TRX_TYPES_TL
     where ID = l_okl_trx_types_tl_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end delete_row;
  ------------------------------------
  -- delete_row for:OKL_TRX_TYPES_V --
  ------------------------------------
  procedure delete_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_rec                     in tryv_rec_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_delete_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tryv_rec                     tryv_rec_type := p_tryv_rec;
    l_okl_trx_types_tl_rec         okl_trx_types_tl_rec_type;
    l_try_rec                      try_rec_type;
  begin
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    if (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_tryv_rec, l_okl_trx_types_tl_rec);
    migrate(l_tryv_rec, l_try_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_types_tl_rec
    );
    if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_try_rec
    );
    if (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = Okc_Api.G_RET_STS_ERROR) then
      raise Okc_Api.G_EXCEPTION_ERROR;
    end if;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:TRYV_TBL --
  ----------------------------------------
  procedure delete_row(
    p_api_version                  in number,
    p_init_msg_list                in varchar2,
    x_return_status                out NOCOPY varchar2,
    x_msg_count                    out NOCOPY number,
    x_msg_data                     out NOCOPY varchar2,
    p_tryv_tbl                     in tryv_tbl_type) is

    l_api_version                 constant number := 1;
    l_api_name                     constant varchar2(30) := 'V_tbl_delete_row';
    l_return_status                varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               varchar2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              number := 0;
  begin
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    if (p_tryv_tbl.COUNT > 0) then
      i := p_tryv_tbl.FIRST;
      loop
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tryv_rec                     => p_tryv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	if x_return_status <> Okc_Api.G_RET_STS_SUCCESS then
      if l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR then
         l_overall_status := x_return_status;
      end if;
	end if;
/* End Post Generation Change */
        exit when (i = p_tryv_tbl.LAST);
        i := p_tryv_tbl.next(i);
      end loop;
    end if;
  exception
    when Okc_Api.G_EXCEPTION_ERROR then
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when OTHERS then
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end delete_row;


 -------------------------------------------------------------------------------
  -- Procedure TRANSLATE_ROW
 -------------------------------------------------------------------------------

 PROCEDURE TRANSLATE_ROW(p_tryv_rec IN tryv_rec_type,
                          p_owner IN VARCHAR2,
                          p_last_update_date IN VARCHAR2,
                          x_return_status IN OUT NOCOPY VARCHAR2) IS
   f_luby    NUMBER;  -- entity owner in file
   f_ludate  DATE;    -- entity update date in file
   db_luby     NUMBER;  -- entity owner in db
   db_ludate   DATE;    -- entity update date in db

   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

     SELECT  LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO  db_luby, db_ludate
      FROM OKL_TRX_TYPES_TL
      where ID = to_number(p_tryv_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
	UPDATE OKL_TRX_TYPES_TL
	SET
	     NAME              = p_tryv_rec.name,
	     DESCRIPTION       = p_tryv_rec.description,
	     LAST_UPDATE_DATE  = f_ludate,
	     LAST_UPDATED_BY   = f_luby,
	     LAST_UPDATE_LOGIN = 0,
	     SOURCE_LANG       = USERENV('LANG')
	WHERE ID  = to_number(p_tryv_rec.ID)
	 AND USERENV('LANG') IN (language,source_lang);
     END IF;
 END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

 PROCEDURE LOAD_ROW(p_tryv_rec IN tryv_rec_type,
                     p_owner    IN VARCHAR2,
                     p_last_update_date IN VARCHAR2,
                     x_return_status IN OUT NOCOPY VARCHAR2) IS
    id        NUMBER;
    f_luby    NUMBER;  -- entity owner in file
    f_ludate  DATE;    -- entity update date in file
    db_luby   NUMBER;  -- entity owner in db
    db_ludate DATE;    -- entity update date in db

   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT ID , LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO id, db_luby, db_ludate
      FROM OKL_TRX_TYPES_B
      where ID = p_tryv_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
        UPDATE OKL_TRX_TYPES_B
		 SET
		     OBJECT_VERSION_NUMBER = p_tryv_rec.object_version_number,
		     TRY_ID                = p_tryv_rec.try_id,
		     TRY_ID_FOR            = p_tryv_rec.try_id_for,
		     ILC_ID                = p_tryv_rec.ilc_id,
		     AEP_CODE              = p_tryv_rec.aep_code,
		     TRY_TYPE              = p_tryv_rec.try_type,
		     TRX_TYPE_CLASS        = p_tryv_rec.trx_type_class,
		     LAST_UPDATE_DATE      = f_ludate,
		     LAST_UPDATED_BY       = f_luby,
		     LAST_UPDATE_LOGIN     = 0,
		     TAX_UPFRONT_YN  = p_tryv_rec.tax_upfront_yn,
		     TAX_INVOICE_YN  = p_tryv_rec.tax_invoice_yn,
		     TAX_SCHEDULE_YN = p_tryv_rec.tax_schedule_yn,
		     --Bug 5707866 dpsingh
		     FORMULA_YN = p_tryv_rec.formula_yn,
		     ACCOUNTING_EVENT_CLASS_CODE = p_tryv_rec.accounting_event_class_code
	      WHERE ID = to_number(p_tryv_rec.id);

        --Update _TL
	    UPDATE OKL_TRX_TYPES_TL
	    SET
		  DESCRIPTION       = p_tryv_rec.DESCRIPTION,
		  NAME              = p_tryv_rec.NAME,
		  LAST_UPDATE_DATE  = f_ludate,
		  LAST_UPDATED_BY   = f_luby,
		  LAST_UPDATE_LOGIN = 0,
		  SOURCE_LANG       = USERENV('LANG')
	    WHERE ID = TO_NUMBER(p_tryv_rec.id)
		AND USERENV('LANG') IN (language,source_lang);

        IF(sql%notfound) THEN

		  INSERT INTO OKL_TRX_TYPES_TL
		  (ID,
		   LANGUAGE,
		   SOURCE_LANG,
		   SFWT_FLAG,
		   NAME,
		   DESCRIPTION,
		   CONTRACT_HEADER_LINE_FLAG,
		   TRANSACTION_HEADER_LINE_DETAIL,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_DATE,
		   LAST_UPDATE_LOGIN
		  ) select
		   TO_NUMBER(p_tryv_rec.id),
		   L.LANGUAGE_CODE,
		   USERENV('LANG'),
		   'N',
		   p_tryv_rec.NAME,
		   p_tryv_rec.DESCRIPTION,
		   'Y',
		   'Y',
		   f_luby,
		   f_ludate,
		   f_luby,
		   f_ludate,
		   0
		 from FND_LANGUAGES L
		 where L.INSTALLED_FLAG IN ('I','B')
		 and not exists
		      ( SELECT NULL
		       from OKL_TRX_TYPES_TL TL
			   where TL.ID = TO_NUMBER(p_tryv_rec.id)
			   and   TL.LANGUAGE = L.LANGUAGE_CODE);

	  END IF;

     END IF;

    END;
    EXCEPTION
     when no_data_found then
     --Insert Into b
       INSERT INTO OKL_TRX_TYPES_B
		(
		ID,
		TRY_ID,
		TRY_ID_FOR,
		ILC_ID,
		AEP_CODE,
		TRY_TYPE,
		TRX_TYPE_CLASS,
		OBJECT_VERSION_NUMBER,
		ORG_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		TAX_UPFRONT_YN ,
		TAX_INVOICE_YN ,
		TAX_SCHEDULE_YN,
		--Bug 5707866 dpsingh
                 FORMULA_YN,
                 ACCOUNTING_EVENT_CLASS_CODE
		)
	VALUES(
	  TO_NUMBER(p_tryv_rec.ID),
	  p_tryv_rec.TRY_ID,
	  p_tryv_rec.TRY_ID_FOR,
	  p_tryv_rec.ILC_ID,
	  p_tryv_rec.AEP_CODE,
	  p_tryv_rec.TRY_TYPE,
	  p_tryv_rec.TRX_TYPE_CLASS,
	  p_tryv_rec.OBJECT_VERSION_NUMBER,
	  p_tryv_rec.ORG_ID,
	  f_luby,
	  f_ludate,
	  f_luby,
	  f_ludate,
	  0,
	  p_tryv_rec.TAX_UPFRONT_YN,
	  p_tryv_rec.TAX_INVOICE_YN,
	  p_tryv_rec.TAX_SCHEDULE_YN,
	  --Bug 5707866 dpsingh
          p_tryv_rec.FORMULA_YN,
          p_tryv_rec.ACCOUNTING_EVENT_CLASS_CODE);

	INSERT INTO OKL_TRX_TYPES_TL
	 (
	   ID,
	   LANGUAGE,
	   SOURCE_LANG,
	   SFWT_FLAG,
	   NAME,
	   DESCRIPTION,
	   CONTRACT_HEADER_LINE_FLAG,
	   TRANSACTION_HEADER_LINE_DETAIL,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATE_LOGIN)
	  SELECT
		TO_NUMBER(p_tryv_rec.ID),
		L.LANGUAGE_CODE,
		userenv('LANG'),
		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
		p_tryv_rec.NAME,
		p_tryv_rec.DESCRIPTION,
		'Y',
		'Y',
		f_luby,
		f_ludate,
		f_luby,
		f_ludate,
		0
		FROM FND_LANGUAGES L
		WHERE L.INSTALLED_FLAG IN ('I','B')
		AND NOT EXISTS
		  (SELECT NULL
		   FROM  OKL_TRX_TYPES_TL TL
		   WHERE TL.ID = TO_NUMBER(p_tryv_rec.ID)
		   AND   TL.LANGUAGE = L.LANGUAGE_CODE);

 END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------
 PROCEDURE LOAD_SEED_ROW(
    p_upload_mode      IN VARCHAR2,
    p_id               IN VARCHAR2,
    p_trx_type_class   IN VARCHAR2,
    p_try_id           IN VARCHAR2,
    p_try_id_for       IN VARCHAR2,
    p_ilc_id           IN VARCHAR2,
    p_aep_code         IN VARCHAR2,
    p_try_type         IN VARCHAR2,
    p_object_version_number IN VARCHAR2,
    p_org_id           IN VARCHAR2,
    p_name             IN VARCHAR2,
    p_description      IN VARCHAR2,
    p_owner            IN VARCHAR2,
    p_last_update_date IN VARCHAR2,
    p_tax_upfront_yn   IN VARCHAR2,
    p_tax_invoice_yn   IN VARCHAR2,
    p_tax_schedule_yn  IN VARCHAR2,
    --Added by dpsingh for Bug 5707866
    p_formula_yn              IN VARCHAR2,
    p_accounting_event_class_code    IN VARCHAR2) IS

  l_api_version   CONSTANT number := 1;
  l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
  l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
  l_msg_count              number;
  l_msg_data               varchar2(4000);
  l_init_msg_list          VARCHAR2(1):= 'T';
  l_tryv_rec               tryv_rec_type;
  BEGIN

  --Prepare Record Structure for Insert/Update
    l_tryv_rec.id := p_id;
    l_tryv_rec.object_version_number := p_object_version_number;
    l_tryv_rec.aep_code := p_aep_code;
    l_tryv_rec.ilc_id := p_ilc_id;
    l_tryv_rec.try_id := p_try_id;
    l_tryv_rec.try_id_for := p_try_id_for;
    l_tryv_rec.try_type := p_try_type;
    l_tryv_rec.name := p_name;
    l_tryv_rec.description := p_description;
    l_tryv_rec.org_id := p_org_id;
    l_tryv_rec.trx_type_class := p_trx_type_class;
    l_tryv_rec.tax_upfront_yn := p_tax_upfront_yn;
    l_tryv_rec.tax_invoice_yn := p_tax_invoice_yn;
    l_tryv_rec.tax_schedule_yn := p_tax_schedule_yn;
    --Bug 5707866 dpsingh
    l_tryv_rec.FORMULA_YN := p_formula_yn;
    l_tryv_rec.ACCOUNTING_EVENT_CLASS_CODE := p_accounting_event_class_code;
    l_tryv_rec.last_update_login := 0;
   IF(p_upload_mode = 'NLS') then
	 OKL_TRY_PVT.TRANSLATE_ROW(p_tryv_rec => l_tryv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);

   ELSE
	 OKL_TRY_PVT.LOAD_ROW(p_tryv_rec => l_tryv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);

   END IF;
 END LOAD_SEED_ROW;

end Okl_Try_Pvt;

/
