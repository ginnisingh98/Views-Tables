--------------------------------------------------------
--  DDL for Package Body OKL_ASSET_SUBSIDY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASSET_SUBSIDY_PVT" AS
/* $Header: OKLRASBB.pls 120.30.12010000.2 2008/09/09 22:14:18 rkuttiya ship $ */

  ---------------------------------------------------------------------------
  --GLOBAL Message Constants
  ---------------------------------------------------------------------------
  G_SUBSIDY_NOT_APPLICABLE      CONSTANT Varchar2(200) := 'OKL_SUBSIDY_NOT_APPLICABLE';
  G_SUBSIDY_TOKEN               CONSTANT Varchar2(200) := 'SUBSIDY';
  G_SUBSIDY_NAME_TOKEN          CONSTANT Varchar2(200) := 'SUBSIDY_NAME'; -- cklee
  G_ASSET_NUMBER_TOKEN          CONSTANT Varchar2(200) := 'ASSET_NUMBER';

  G_SUBSIDY_GREATER_THAN_COST   CONSTANT Varchar2(200) := 'OKL_SUBSIDY_LIMIT_ERROR';
  G_SUBSIDY_ALREADY_EXISTS      CONSTANT Varchar2(200) := 'OKL_SUBSIDY_ALREADY_EXISTS';
  G_SUBSIDY_EXCLUSIVE           CONSTANT Varchar2(200) := 'OKL_SUBSIDY_EXCLUSIVE';
  G_PARTY_UPDATE_INVALID        CONSTANT Varchar2(200) := 'OKL_SUB_RBK_PARTY_UPDATE';
 ----------------------------------------------------------------------------
  --Global Constants
 ----------------------------------------------------------------------------
  G_FORMULA_OEC             CONSTANT OKL_FORMULAE_V.NAME%TYPE := 'LINE_OEC';
  G_FORMULA_CAP             CONSTANT OKL_FORMULAE_V.NAME%TYPE := 'LINE_CAP_AMNT';

  G_TRX_AMT_GT_TOT_BUDGET CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_TRX_AMT_MORE_THAN_TOT';
  G_NO_CONVERSION_BASIS CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_NO_CONV_BASIS';

-- cklee, added global message constants as part of subsidy pools enhancement. START
G_SUB_POOL_NOT_ACTIVE CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_NOT_ACTIVE';
G_SUB_POOL_BALANCE_INVALID CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_INVALID_BAL';
G_SUB_POOL_ASSET_DATES_GAP CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_ASSET_DATES';
-- cklee, added global message constants as part of subsidy pools enhancement. END

  /*
   * sjalasut: aug 25, 04 added constants used in raising business event. BEGIN
   */
  G_WF_EVT_ASSET_SUBSIDY_CRTD CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.asset_subsidy_created';
  G_WF_EVT_ASSET_SUBSIDY_RMVD CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.remove_asset_subsidy';
  G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)          := 'CONTRACT_ID';
  G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30)             := 'ASSET_ID';
  G_WF_ITM_SUBSIDY_ID CONSTANT VARCHAR2(30)           := 'SUBSIDY_ID';
  G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)     := 'CONTRACT_PROCESS';
  /*
   * sjalasut: aug 25, 04 added constants used in raising business event. END
   */


  /*
   * sjalasut: aug 18, 04 added procedure to call private wrapper that raises the business event. BEGIN
   *
   */
  -------------------------------------------------------------------------------
  -- PROCEDURE raise_business_event
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_business_event
  -- Description     : This procedure is a wrapper that raises a business event
  --                 : when ever asset subsidy is created or deleted.
  -- Business Rules  :
  -- Parameters      : p_chr_id,p_asset_id,p_subsidy_id,p_event_name along with other api params
  -- Version         : 1.0
  -- History         : 30-AUG-2004 SJALASUT created
  -- End of comments

  PROCEDURE raise_business_event(p_api_version IN NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 p_chr_id IN okc_k_headers_b.id%TYPE,
                                 p_asset_id IN okc_k_lines_b.id%TYPE,
                                 p_subsidy_id IN okl_subsidies_b.id%TYPE,
                                 p_event_name IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2
                                 ) IS
    l_parameter_list wf_parameter_list_t;
    l_contract_process VARCHAR2(20);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- wrapper API to get contract process. this API determines in which status the
    -- contract in question is.
    l_contract_process := okl_lla_util_pvt.get_contract_process(p_chr_id => p_chr_id);
    wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, p_chr_id, l_parameter_list);
    wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, p_asset_id, l_parameter_list);
    wf_event.AddParameterToList(G_WF_ITM_SUBSIDY_ID, p_subsidy_id, l_parameter_list);
    wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS, l_contract_process, l_parameter_list);
    OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_event_name     => p_event_name,
                           p_parameters     => l_parameter_list);
  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END raise_business_event;

  /*
   * sjalasut: aug 18, 04 added procedure to call private wrapper that raises the business event. END
   */


 ---------------------------------------------------------------------------
 -- FUNCTION get_rec for: OKL_ASSET_SUBSIDIES_UV
 ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_asb_rec          IN asb_rec_type,
    x_no_data_found    OUT NOCOPY BOOLEAN
  ) RETURN asb_rec_type IS
    CURSOR asb_csr (p_id                 IN NUMBER) IS
    SELECT
             SUBSIDY_ID
            ,SUBSIDY_CLE_ID
            ,NAME
            ,DESCRIPTION
            ,AMOUNT
            ,SUBSIDY_OVERRIDE_AMOUNT
            ,DNZ_CHR_ID
            ,ASSET_CLE_ID
            ,CPL_ID
            ,VENDOR_ID
            ,VENDOR_NAME
     FROM   okl_asset_subsidy_uv asb
     WHERE asb.subsidy_cle_id     = p_id;
    l_asb_rec                      asb_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN asb_csr (p_asb_rec.subsidy_cle_id);
    FETCH asb_csr INTO
            l_asb_rec.SUBSIDY_ID
            ,l_asb_rec.SUBSIDY_CLE_ID
            ,l_asb_rec.NAME
            ,l_asb_rec.DESCRIPTION
            ,l_asb_rec.AMOUNT
            ,l_asb_rec.SUBSIDY_OVERRIDE_AMOUNT
            ,l_asb_rec.DNZ_CHR_ID
            ,l_asb_rec.ASSET_CLE_ID
            ,l_asb_rec.CPL_ID
            ,l_asb_rec.VENDOR_ID
            ,l_asb_rec.VENDOR_NAME;
    x_no_data_found := asb_csr%NOTFOUND;
    CLOSE asb_csr;

    RETURN(l_asb_rec);

  END get_rec;

  FUNCTION get_rec (
    p_asb_rec                     IN asb_rec_type
  ) RETURN asb_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_asb_rec, l_row_notfound));

END get_rec;
--------------------------------------------------------------------------------
--Start of comments
-- Procedure     : Is_Rebook_Copy (Local)
-- Description   : Return 'Y' if contract is a rebook copy contract, 'N' if it
--                 is not
--Notes         :
--Prameters     : IN
--                p_chr_id          - contract id
--                Return            - 'Y' if rebook copy
--                                    'N' if not rebook copy
--end of comments
--------------------------------------------------------------------------------
FUNCTION Is_Rebook_Copy (p_chr_id IN NUMBER) return varchar2 IS
   --Cursor to check if the contract is a rebook copy
   Cursor Rbk_Cpy_Csr(p_chr_id IN Number) is
   Select 'Y'
   From   okc_k_headers_b chr
   where  chr.orig_system_source_code = 'OKL_REBOOK'
   and    chr.id = p_chr_id;

   l_rbk_cpy  Varchar2(1) default 'N';
Begin
   l_rbk_cpy := 'N';
   Open Rbk_Cpy_Csr(p_chr_id => p_chr_id);
   Fetch Rbk_Cpy_Csr into l_rbk_cpy;
   If Rbk_Cpy_Csr%NOTFOUND Then
       Null;
   End If;
   Close Rbk_Cpy_Csr;
   Return (l_rbk_cpy);
End Is_Rebook_Copy;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Local procedure to fill up defaultvalues for lines and partyroles for insertion
--Name       : Fill_up_defaults
--Creation   : 20-Aug-2003
--Purpose    : To fill up defaults in line and party record structures for
--             update of asset subsidy line
--------------------------------------------------------------------------------
PROCEDURE Fill_up_defaults(x_return_status OUT NOCOPY VARCHAR2,
                          p_asb_rec       IN  asb_rec_type,
                          p_db_asb_rec    IN  asb_rec_type,
                          x_clev_rec      OUT NOCOPY OKL_OKC_MIGRATION_PVT.clev_rec_type,
                          x_klev_rec      OUT NOCOPY OKL_CONTRACT_PUB.klev_rec_type,
                          x_cplv_rec      OUT NOCOPY OKL_OKC_MIGRATION_PVT.cplv_rec_type) is

l_asb_rec     asb_rec_type;
l_db_asb_rec  asb_rec_type;

--cursor to get effectivity dates and stream type
cursor l_sub_csr (p_sub_id in number) is
select subb.stream_type_id,
       subb.effective_from_date,
       subb.effective_to_date,
       subb.expire_after_days,
       subb.maximum_term,
       subb.name,
       subt.short_description
from
       okl_subsidies_tl  subt,
       okl_subsidies_b   subb
where  subt.id       = subb.id
and    subt.language = userenv('LANG')
and    subb.id       = p_sub_id;

l_sub_rec l_sub_csr%ROWTYPE;

--cursor to get defaults from asset line (top line)
cursor l_cleb_csr (p_asset_cle_id in number) is
select cleb.start_date,
       cleb.end_date,
       cleb.sts_code,
       cleb.currency_code
from   okc_k_lines_b cleb
where  cleb.id = p_asset_cle_id;

l_cleb_rec l_cleb_csr%ROWTYPE;

--cursor to get vendor id if vendor name is given
cursor l_vendor_csr (p_vend_name in varchar2) is
select vendor_id
from   po_vendors pov
where  vendor_name = ltrim(rtrim(p_vend_name,' '),' ');

l_vendor_id number;

l_clev_rec okl_okc_migration_pvt.clev_rec_type;
l_klev_rec okl_contract_pub.klev_rec_type;
l_cplv_rec okl_okc_migration_pvt.cplv_rec_type;

l_temp_sub_id Number;

--cursor to get subsidy id from subsidy name
cursor l_subname_csr (p_subsidy_name in varchar2) is
select id
from   okl_subsidies_b subb
where  name = ltrim(rtrim(p_subsidy_name,' '),' ');

l_subsidy_id  Number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_asb_rec    := p_asb_rec;
    l_db_asb_rec := p_db_asb_rec;

    --l_clev_rec.id := l_db_asb_rec.subsidy_cle_id;
    --l_klev_rec.id := l_db_asb_rec.subsidy_cle_id;
    --l_cplv_rec.id := l_db_asb_rec.cpl_id;

    If l_clev_rec.id = OKL_API.G_MISS_NUM then
        l_clev_rec.id := l_db_asb_rec.subsidy_cle_id;
        l_klev_rec.id := l_db_asb_rec.subsidy_cle_id;
    End If;

    --get subsidy id from name if id has not been specified
    If (l_asb_rec.subsidy_id is NULL) OR (l_asb_rec.subsidy_id = OKL_API.G_MISS_NUM) then
        If (l_asb_rec.name is not NULL) AND (l_asb_rec.name <> OKL_API.G_MISS_CHAR) then
            Open l_subname_csr(p_subsidy_name => l_asb_rec.name);
            Fetch l_subname_csr into l_subsidy_id;
            If l_subname_csr%NOTFOUND then
                null;
            else
               l_asb_rec.subsidy_id := l_subsidy_id;
            end if;
            Close l_subname_csr;
        End If;
    End If;


    --check if subsidy has changed
    If l_asb_rec.subsidy_id <> OKL_API.G_MISS_NUM Then
        l_klev_rec.subsidy_id := l_asb_rec.subsidy_id;
        l_temp_sub_id         := l_asb_rec.subsidy_id;
    Else
        l_klev_rec.subsidy_id := l_db_asb_rec.subsidy_id;
        l_temp_sub_id          := l_db_asb_rec.subsidy_id;
    End If;

    --fill start end dates and stream type
    open l_sub_csr(p_sub_id => l_temp_sub_id);
    fetch l_sub_csr into l_sub_rec;
    If l_sub_csr%NOTFOUND then
        null;
    Else
        l_klev_rec.sty_id           := l_sub_rec.stream_type_id;
        l_clev_rec.name             := l_sub_rec.name;
        l_clev_rec.item_description := l_sub_rec.short_description;
    End If;
    close l_sub_csr;

    open l_cleb_csr(p_asset_cle_id => l_db_asb_rec.asset_cle_id);
    fetch l_cleb_csr into l_cleb_rec;
    If l_cleb_csr%NOTFOUND then
        null;
    Else
        l_clev_rec.start_date     := l_cleb_rec.start_date;
        l_clev_rec.sts_code       := l_cleb_rec.sts_code;
        l_clev_rec.currency_code  := l_cleb_rec.currency_code;
        If l_sub_rec.maximum_term is not null then
            If (add_months(l_cleb_rec.start_date ,l_sub_rec.maximum_term) - 1) < (l_cleb_rec.end_date) then
                l_clev_rec.end_date := add_months(l_cleb_rec.start_date ,l_sub_rec.maximum_term) - 1;
            Else
                l_clev_rec.end_date := l_cleb_rec.end_date;
            End If;
        Else
            l_clev_rec.end_date := l_cleb_rec.end_date;
        End If;
    End If;
    close l_cleb_csr;

    --amount
    If nvl(l_asb_rec.amount,-1) <> OKL_API.G_MISS_NUM then
        l_klev_rec.amount := l_asb_rec.amount;
    Else
        l_klev_rec.amount := l_db_asb_rec.amount;
    End If;

    --override amount
    If nvl(l_asb_rec.subsidy_override_amount,-1) <> OKL_API.G_MISS_NUM then
        l_klev_rec.subsidy_override_amount := l_asb_rec.subsidy_override_amount;
    Else
        l_klev_rec.subsidy_override_amount := l_db_asb_rec.subsidy_override_amount;
    End If;

    --subsidy vendor
    If (l_asb_rec.vendor_id is NULL) OR (l_asb_rec.vendor_id = OKL_API.G_MISS_NUM) then
        If (l_asb_rec.vendor_name is NOT NULL) and (l_asb_rec.vendor_name <> OKL_API.G_MISS_CHAR) then
            open l_vendor_csr(p_vend_name => l_asb_rec.vendor_name);
            fetch l_vendor_csr into l_vendor_id;
            If l_vendor_csr%NOTFOUND then
                null;
            Else
                l_asb_rec.vendor_id := l_vendor_id;
            End If;
            close l_vendor_csr;
        End If;
    End If;

    If nvl(l_asb_rec.vendor_id,-1) <> OKL_API.G_MISS_NUM then
         --If l_cplv_rec.id = OKL_API.G_MISS_NUM then
        l_cplv_rec.id := l_db_asb_rec.cpl_id;
         --End If;
        If l_cplv_rec.id is Null then
            l_cplv_rec.dnz_chr_id         := l_db_asb_rec.dnz_chr_id;
            l_cplv_rec.rle_code           := 'OKL_VENDOR';
            l_cplv_rec.object1_id1        := to_char(l_asb_rec.vendor_id);
            l_cplv_rec.object1_id2        := '#';
            l_cplv_rec.jtot_object1_code  := 'OKX_VENDOR';
        ElsIf l_cplv_rec.id is not null then
            l_cplv_rec.object1_id1        := to_char(l_asb_rec.vendor_id);
        End If;
    Else
        l_cplv_rec.id := l_db_asb_rec.cpl_id;
        --End If;
        If l_cplv_rec.id is Null then
            l_cplv_rec.dnz_chr_id         := l_db_asb_rec.dnz_chr_id;
            l_cplv_rec.rle_code           := 'OKL_VENDOR';
            l_cplv_rec.object1_id1        := to_char(l_db_asb_rec.vendor_id);
            l_cplv_rec.object1_id2        := '#';
            l_cplv_rec.jtot_object1_code  := 'OKX_VENDOR';
        ElsIf l_cplv_rec.id is not null then
             l_cplv_rec.object1_id1        := to_char(l_db_asb_rec.vendor_id);
        End If;
    End If;

    x_clev_rec   := l_clev_rec;
    x_klev_rec   := l_klev_rec;
    x_cplv_rec   := l_cplv_rec;

    Exception
    When Others then
        If l_sub_csr%ISOPEN then
            close l_sub_csr;
        End If;
        If l_cleb_csr%ISOPEN then
            close l_cleb_csr;
        End If;
         If l_vendor_csr%ISOPEN then
            close l_vendor_csr;
        End If;
        If l_subname_csr%ISOPEN then
            close l_subname_csr;
        End If;
        x_return_status := OKL_API.G_RET_STS_ERROR;
End Fill_up_defaults;
--------------------------------------------------------------------------------
--Local procedure to initialize values for lines and partyroles for insertion
--Name       : Initialize_records
--Creation   : 20-Aug-2003
--Purpose    : To initialize defaults in line and party record structures for
--             creation of asset subsidy line
--------------------------------------------------------------------------------
PROCEDURE Initialize_records(x_return_status OUT NOCOPY VARCHAR2,
                            p_asb_rec       IN  asb_rec_type,
                            x_clev_rec      OUT NOCOPY OKL_OKC_MIGRATION_PVT.clev_rec_type,
                            x_klev_rec      OUT NOCOPY OKL_CONTRACT_PUB.klev_rec_type,
                            x_cplv_rec      OUT NOCOPY OKL_OKC_MIGRATION_PVT.cplv_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'INITIALIZE_RECORDS';
l_api_version          CONSTANT NUMBER := 1.0;

l_asb_rec   asb_rec_type;
l_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;
l_klev_rec  OKL_CONTRACT_PUB.klev_rec_type;
l_cplv_rec  OKL_OKC_MIGRATION_PVT.cplv_rec_type;

--cursor to get effectivity dates and stream type
cursor l_sub_csr (p_sub_id in number) is
select subb.stream_type_id,
       subb.effective_from_date,
       subb.effective_to_date,
       subb.expire_after_days,
       subb.maximum_term,
       subb.name,
       subt.short_description
from
       okl_subsidies_tl  subt,
       okl_subsidies_b   subb
where  subt.id       = subb.id
and    subt.language = userenv('LANG')
and    subb.id       = p_sub_id;

l_sub_rec l_sub_csr%ROWTYPE;

--cursor to get defaults from asset line (top line)
cursor l_cleb_csr (p_asset_cle_id in number) is
select cleb.start_date,
       cleb.end_date,
       cleb.sts_code,
       cleb.currency_code
from   okc_k_lines_b cleb
where  cleb.id = p_asset_cle_id;

l_cleb_rec l_cleb_csr%ROWTYPE;

--cursor to get lse_id
cursor l_lseb_csr(p_chr_id in number) is
Select lseb.id
from   okc_line_styles_b      lseb,
       okc_line_styles_b      top_lseb,
       okc_subclass_top_line  scs_lse,
       okc_k_headers_b        chrb
where  lseb.lty_code       = G_SUBLINE_LTY_CODE
and    lseb.lse_parent_id  = top_lseb.id
and    top_lseb.lty_code   = 'FREE_FORM1'
and    lseb.lse_parent_id  = scs_lse.lse_id
and    scs_lse.scs_code    = chrb.scs_code
and    chrb.id             = p_chr_id;

l_lse_id Number;

--cursor to get display sequence
cursor l_dispseq_csr(p_asset_cle_id in number, p_lse_id in number, p_chr_id in number) is
select nvl(max(cleb.display_sequence),0)+5
from   okc_k_lines_b cleb
where  cleb.cle_id     = p_asset_cle_id
and    cleb.dnz_chr_id = p_chr_id
and    cleb.lse_id     = p_lse_id;

l_display_sequence Number;

--cursor to get vendor id if vendor name is given
cursor l_vendor_csr (p_vend_name in varchar2) is
select vendor_id
from   po_vendors pov
where  vendor_name = ltrim(rtrim(p_vend_name,' '),' ');

l_vendor_id number;

--cursor to get subsidy id from subsidy name
cursor l_subname_csr (p_subsidy_name in varchar2) is
select id
from   okl_subsidies_b subb
where  name = ltrim(rtrim(p_subsidy_name,' '),' ');

l_subsidy_id Number;

--Cursor to find out Rebook date
Cursor l_rbk_date_csr (rbk_chr_id IN NUMBER) is
SELECT DATE_TRANSACTION_OCCURRED
FROM   okl_trx_contracts ktrx
WHERE  ktrx.KHR_ID_NEW = rbk_chr_id
AND    ktrx.tsu_code   = 'ENTERED'
AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP Project
AND    ktrx.representation_type = 'PRIMARY';
--

l_rbk_date okl_trx_contracts.DATE_TRANSACTION_OCCURRED%TYPE;

l_rbk_cpy  varchar2(1) default 'N';


Begin
    --dbms_output.put_line(to_char(p_asb_rec.amount));
    x_return_status := l_return_Status;
    l_asb_rec       := p_asb_rec;

    --get subsidy id from name if id has not been specified
    If (l_asb_rec.subsidy_id is NULL) OR (l_asb_rec.subsidy_id = OKL_API.G_MISS_NUM) then
        If (l_asb_rec.name is not NULL) AND (l_asb_rec.name <> OKL_API.G_MISS_CHAR) then
            Open l_subname_csr(p_subsidy_name => l_asb_rec.name);
            Fetch l_subname_csr into l_subsidy_id;
            If l_subname_csr%NOTFOUND then
                null;
            else
               l_asb_rec.subsidy_id := l_subsidy_id;
            end if;
            Close l_subname_csr;
        End If;
    End If;

    --dbms_output.put_line(to_char(l_asb_rec.amount));
    --fill up the defaults
    l_klev_rec.subsidy_id              := l_asb_rec.subsidy_id;
    l_klev_rec.amount                  := l_asb_rec.amount;
    l_klev_rec.subsidy_override_amount := l_asb_rec.subsidy_override_amount;
    l_clev_rec.cle_id                  := l_asb_rec.asset_cle_id;
    l_clev_rec.dnz_chr_id              := l_asb_rec.dnz_chr_id;
    l_clev_rec.exception_yn            := 'N';

    --dbms_output.put_line(to_char(l_klev_rec.amount));

    --fill lse id
    open l_lseb_csr(p_chr_id => l_asb_rec.dnz_chr_id);
	fetch l_lseb_csr into l_lse_id;
	If l_lseb_csr%NOTFOUND then
	    Null;
	Else
	    l_clev_rec.lse_id           := l_lse_id;
	End If;
	close l_lseb_csr;

	--fill display sequence
	open l_dispseq_csr(p_asset_cle_id => l_asb_rec.asset_cle_id,
	                   p_lse_id       => l_lse_id,
					   p_chr_id       => l_asb_rec.dnz_chr_id);
    fetch l_dispseq_csr into l_display_sequence;
	If 	l_dispseq_csr%NOTFOUND then
	    null;
    Else
	    l_clev_rec.display_sequence := l_display_sequence;
    End If;
    --l_clev_rec.lse_id               := 10021;
    --l_clev_rec.display_sequence     := 1;

    --fill start end dates and stream type
    open l_sub_csr(p_sub_id => l_asb_rec.subsidy_id);
    fetch l_sub_csr into l_sub_rec;
    If l_sub_csr%NOTFOUND then
        null;
    Else
        l_klev_rec.sty_id           := l_sub_rec.stream_type_id;
        l_clev_rec.name             := l_sub_rec.name;
        l_clev_rec.item_description := l_sub_rec.short_description;
    End If;
    close l_sub_csr;

    open l_cleb_csr(p_asset_cle_id => l_asb_rec.asset_cle_id);
    fetch l_cleb_csr into l_cleb_rec;
    If l_cleb_csr%NOTFOUND then
        null;
    Else
        l_clev_rec.start_date     := l_cleb_rec.start_date;
        l_clev_rec.sts_code       := l_cleb_rec.sts_code;
        l_clev_rec.currency_code  := l_cleb_rec.currency_code;
        ----------------------------------------
        --check if it is a rebook copy contract
        --if yes then get the rebook transaction
        --date and make it as start date of subsidy
        -------------------------------------------
        l_rbk_cpy := is_rebook_copy(p_chr_id => l_asb_rec.dnz_chr_id);
        If l_rbk_cpy = 'Y' then

            open l_rbk_date_csr(rbk_chr_id => l_asb_rec.dnz_chr_id);
            fetch l_rbk_date_csr into l_rbk_date;
            if l_rbk_date_csr%NOTFOUND then
                NULL;
            end If;
            close l_rbk_date_csr;

            If l_rbk_date is NULL OR l_rbk_date = OKL_API.G_MISS_DATE then
                NULL;
            Else
                l_clev_rec.start_date := l_rbk_date;
            End If;
        End If;
        -----------------------------------------
        --End of rebook check
        -----------------------------------------
        If l_sub_rec.maximum_term is not null then
            If (add_months(l_clev_rec.start_date , l_sub_rec.maximum_term) - 1) < (l_cleb_rec.end_date) then
                l_clev_rec.end_date := add_months(l_clev_rec.start_date , l_sub_rec.maximum_term) - 1;
            Else
                l_clev_rec.end_date := l_cleb_rec.end_date;
            End If;
         Else
             l_clev_rec.end_date := l_cleb_rec.end_date;
         End If;
    End If;
    close l_cleb_csr;

    --fill party role record
    --in case someone has passed id make it default for record creation
    If l_cplv_rec.id <> OKL_API.G_MISS_NUM then
        l_cplv_rec.id                 := OKL_API.G_MISS_NUM;
    End If;
    l_cplv_rec.dnz_chr_id         := l_asb_rec.dnz_chr_id;
    l_cplv_rec.rle_code           := 'OKL_VENDOR';
    --vendor id
    If (l_asb_rec.vendor_id is NULL) OR (l_asb_rec.vendor_id = OKL_API.G_MISS_NUM) then
        If (l_asb_rec.vendor_name is NOT NULL) and (l_asb_rec.vendor_name <> OKL_API.G_MISS_CHAR) then
            --get vendor id
            open l_vendor_csr(p_vend_name => l_asb_rec.vendor_name);
            fetch l_vendor_csr into l_vendor_id;
            If l_vendor_csr%NOTFOUND then
                l_cplv_rec.object1_id1        := to_char(l_asb_rec.vendor_id);
            End If;
            Close l_vendor_csr;
        End If;
     Else
         l_cplv_rec.object1_id1        := to_char(l_asb_rec.vendor_id);
     End If;

    l_cplv_rec.object1_id2        := '#';
    l_cplv_rec.jtot_object1_code  := 'OKX_VENDOR';

    x_clev_rec   := l_clev_rec;
    x_klev_rec   := l_klev_rec;
    x_cplv_rec   := l_cplv_rec;

    Exception
    When Others then
        If l_sub_csr%ISOPEN then
            close l_sub_csr;
        End If;
        If l_cleb_csr%ISOPEN then
            close l_cleb_csr;
        End If;
		If l_lseb_csr%ISOPEN then
            close l_lseb_csr;
        End If;
		If l_dispseq_csr%ISOPEN then
            close l_dispseq_csr;
        End If;
        If l_vendor_csr%ISOPEN then
            close l_dispseq_csr;
        End If;
        If l_subname_csr%ISOPEN then
            close l_subname_csr;
        End If;
        If l_rbk_date_csr%ISOPEN then
            close l_rbk_date_csr;
        End If;
        x_return_status := OKL_API.G_RET_STS_ERROR;
End Initialize_records;
--------------------------------------------------------------------------------
--Name       : recalculate_costs
--Creation   : 29-Aug-2003
--Purpose    : Local procedure to update subsidized costs
--------------------------------------------------------------------------------
PROCEDURE recalculate_costs(
          p_api_version     IN NUMBER,
          p_init_msg_list   IN VARCHAR2,
          x_return_status   OUT NOCOPY VARCHAR2,
          x_msg_count       OUT NOCOPY NUMBER,
          x_msg_data        OUT NOCOPY VARCHAR2,
          p_chr_id          IN  NUMBER,
          p_asset_cle_id    IN  NUMBER
          ) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'RECALCULATE_COSTS';
l_api_version          CONSTANT NUMBER := 1.0;

l_oec               number;
l_cap_amount        number;
l_total_subsidy     number;

l_sub_oec           number;
l_sub_cap_amount    number;

l_clev_rec             okl_okc_migration_pvt.clev_rec_type;
l_klev_rec             okl_contract_pub.klev_rec_type;
lx_clev_rec            okl_okc_migration_pvt.clev_rec_type;
lx_klev_rec            okl_contract_pub.klev_rec_type;

--cursor to fetch asset number for exception
cursor l_clet_csr (p_cle_id in number) is
select clet.name
from   okc_k_lines_tl clet
where  clet.id = p_cle_id
and    clet.language = userenv('LANG');

l_asset_number okc_k_lines_tl.name%TYPE;

begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --calculate and update subsidised OEC and Capital Amount
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_OEC,
                                    p_contract_id   => p_chr_id,
                                    p_line_id       => p_asset_cle_id,
                                    x_value         => l_oec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_CAP,
                                    p_contract_id   => p_chr_id,
                                    p_line_id       => p_asset_cle_id,
                                    x_value         => l_cap_amount);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --get total subsidy
    OKL_SUBSIDY_PROCESS_PVT.get_asset_subsidy_amount(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_asset_cle_id      => p_asset_cle_id,
        --p_accounting_method => 'NET',
        x_subsidy_amount    => l_total_subsidy);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_sub_oec         := (l_oec - l_total_subsidy);
    l_sub_cap_amount  := (l_cap_amount - l_total_subsidy);

    If (l_sub_oec < 0) then
        open l_clet_csr(p_cle_id => p_asset_cle_id);
        Fetch l_clet_csr into l_asset_number;
        if l_clet_csr%NOTFOUND then
            null;
        end if;
        close l_clet_csr;
        --raise error : total subsidy can not be greater than asset cost
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_SUBSIDY_GREATER_THAN_COST,
                              p_token1       => G_ASSET_NUMBER_TOKEN,
                              p_token1_value => l_asset_number);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    ----------------------------------------------------------------------
    --call api to update costs on asset line
    ----------------------------------------------------------------------
    l_clev_rec.id                    := p_asset_cle_id;
    l_klev_rec.id                    := p_asset_cle_id;
    l_klev_rec.oec                   := l_oec;
    l_klev_rec.capital_amount        := l_cap_amount;

    --we do not intend to maintain subsidized costs as discount is built in line_cap_amount
    --l_klev_rec.subsidized_oec        := l_sub_oec;
    --l_klev_rec.subsidized_cap_amount := l_sub_cap_amount;

    okl_contract_pub.update_contract_line
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_clev_rec      => l_clev_rec,
         p_klev_rec      => l_klev_rec,
         x_clev_rec      => lx_clev_rec,
         x_klev_rec      => lx_klev_rec
         );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 4899328
    -- Recalculate Asset depreciation cost when there
    -- is a change to Subsidy
    okl_activate_asset_pvt.recalculate_asset_cost
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_chr_id        => p_chr_id,
         p_cle_id        => p_asset_cle_id
         );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4899328

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
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
End recalculate_costs;

--------------------------------------------------------------------------------
--Name       : calculate_asset_subsidy
--Creation   : 20-Aug-2003
--Purpose    : To calculate asset subsidy amount will call the calculation API
--------------------------------------------------------------------------------
PROCEDURE calculate_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_rec                      IN  asb_rec_type,
    x_asb_rec                      OUT NOCOPY  asb_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CALCULATE_ASSET_SUBSIDY';
l_api_version          CONSTANT NUMBER := 1.0;

l_asb_rec              asb_rec_type;
l_subsidy_amount       number;


l_sub_clev_rec         okl_okc_migration_pvt.clev_rec_type;
l_sub_klev_rec         okl_contract_pub.klev_rec_type;
lx_sub_clev_rec        okl_okc_migration_pvt.clev_rec_type;
lx_sub_klev_rec        okl_contract_pub.klev_rec_type;

lv_subsidy_amount NUMBER;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_asb_rec := p_asb_rec;
    -----------------------------------------------
    --call subsidy calculation API
    -----------------------------------------------
    okl_subsidy_process_pvt.calculate_subsidy_amount
            (
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_subsidy_cle_id => l_asb_rec.subsidy_cle_id,
            x_subsidy_amount => l_subsidy_amount);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_asb_rec.amount := l_subsidy_amount;

--START: cklee 09/29/2005
    -----------------------------------------------------------------------
    -- verify pool balance if this subsidy is reduced from the pool balance
    -- check added for subsidy pools enhancement
    -----------------------------------------------------------------------
--           28-Sep-2005  cklee - Fixed bug#4634871 and bug#4634792  v3       |
/*    lv_subsidy_amount := NVL(l_asb_rec.subsidy_override_amount,NVL(l_asb_rec.amount,0));
    is_balance_valid_after_add (p_subsidy_id => l_asb_rec.subsidy_id
                                ,p_asset_id => l_asb_rec.asset_cle_id
                                ,p_subsidy_amount => lv_subsidy_amount
                                ,p_subsidy_name => l_asb_rec.name
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
--END: cklee 09/29/2005

    ----------------------------------------------------------------------
    --call api to update subsidy amount on subsidy line
    ----------------------------------------------------------------------

    l_sub_clev_rec.id                   := l_asb_rec.subsidy_cle_id;
    l_sub_klev_rec.id                   := l_asb_rec.subsidy_cle_id;
    l_sub_klev_rec.amount               := l_subsidy_amount;

    okl_contract_pub.update_contract_line
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_clev_rec      => l_sub_clev_rec,
         p_klev_rec      => l_sub_klev_rec,
         x_clev_rec      => lx_sub_clev_rec,
         x_klev_rec      => lx_sub_klev_rec
         );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     ---------------------------------------------------------
     --Call API to recalculate asset oec and cap amounts
     ----------------------------------------------------------
     recalculate_costs(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_chr_id         => lx_sub_clev_rec.dnz_chr_id,
            p_asset_cle_id   => lx_sub_clev_rec.cle_id);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

--START: cklee 09/29/2005
    -----------------------------------------------------------------------
    -- verify pool balance if this subsidy is reduced from the pool balance
    -- check added for subsidy pools enhancement
    -----------------------------------------------------------------------
--           28-Sep-2005  cklee - Fixed bug#4634871 and bug#4634792  v3       |
-- move to here after the subsidy amount on subsidy line has been in this DB transaction
-- so that the function can get the total amount up to now for a specific subsidy pool
    lv_subsidy_amount := NVL(l_asb_rec.subsidy_override_amount,NVL(l_asb_rec.amount,0));
    is_balance_valid_after_add (p_subsidy_id => l_asb_rec.subsidy_id
                                ,p_asset_id => l_asb_rec.asset_cle_id
                                ,p_subsidy_amount => lv_subsidy_amount
                                ,p_subsidy_name => l_asb_rec.name
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--END: cklee 09/29/2005


    x_asb_rec := l_asb_rec;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
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
End calculate_asset_subsidy;
--------------------------------------------------------------------------------
--Function to validate whether subsdy is applicable on an asset
--------------------------------------------------------------------------------
  FUNCTION validate_subsidy_applicability(p_subsidy_id    IN  NUMBER
                                          ,p_asset_cle_id  IN  NUMBER
                                          ,p_qa_checker_call IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 IS
    --cursor : to check applicability at contract header ORG_ID
    cursor l_chr_csr (p_subsidy_id in number,
                      p_asset_cle_id in number) is
    Select 'Y'
    from   okl_subsidies_b sub,
           okc_k_headers_b chrb,
           okc_k_lines_b   cleb
    where  sub.id                = p_subsidy_id
    and    chrb.id               = cleb.chr_id
    and    chrb.id               = cleb.dnz_chr_id
    and    cleb.id               = p_asset_cle_id
    --check for authoring org id
    and    chrb.authoring_org_id = sub.org_id
    --check for currency code
    and    chrb.currency_code = sub.currency_code;


    --cursor : to check whether contract is release Kand subsidy is applicable
    -- on release
    cursor l_relk_csr (p_subsidy_id in number,
                       p_asset_cle_id in number) is
    Select 'Y'
    from  okl_subsidies_b sub,
          okc_k_headers_b chrb,
          okc_k_lines_b   cleb
    where sub.id                               = p_subsidy_id
    and   chrb.id                              = cleb.chr_id
    and   chrb.id                              = cleb.dnz_chr_id
    and   cleb.id                              = p_asset_cle_id
    and   decode(chrb.orig_system_source_code,
                 'OKL_RELEASE','Y',
                 sub.APPLICABLE_TO_RELEASE_YN) = sub.APPLICABLE_TO_RELEASE_YN;

    --cursor : to check whether contract is release Asset and subsidy is applicable
    -- on release
    cursor l_rela_csr (p_subsidy_id in number,
                       p_asset_cle_id in number) is
    Select 'Y'
    from  okl_subsidies_b sub,
          okc_rules_b     rulb,
          okc_k_lines_b   cleb
    where sub.id                               = p_subsidy_id
    and   rulb.dnz_chr_id                      = cleb.chr_id
    and   rulb.rule_information_category       = 'LARLES'
    and   cleb.id                              = p_asset_cle_id
    and   decode(ltrim(rtrim(rulb.RULE_INFORMATION1,' '),' '),
                 'Y','Y',
                 sub.APPLICABLE_TO_RELEASE_YN) = sub.APPLICABLE_TO_RELEASE_YN
    union
    -- to take care of S and O where release yes-no flag is not applicable
    Select 'Y'
    from   okl_subsidies_b sub,
           okc_k_lines_b   cleb
    where  sub.id  = p_subsidy_id
    and    cleb.id = p_asset_cle_id
    and    not exists (select 1
                       from   okc_rules_b rulb
                       where  rulb.dnz_chr_id = cleb.chr_id
                       and    rulb.rule_information_category = 'LARLES');



    --cursor : to check applicability at  line dates
    cursor l_cle_csr (p_subsidy_id in number,
                      p_asset_cle_id in number) is
    Select 'Y'
    from   okl_subsidies_b sub,
           okc_k_lines_b   cleb
    where  sub.id                = p_subsidy_id
    and    cleb.id               = p_asset_cle_id
-- start: okl.h cklee
--    and    cleb.start_date between sub.effective_from_date
--                           and nvl(sub.effective_to_date,cleb.start_date);
    and    TRUNC(cleb.start_date) between TRUNC(sub.effective_from_date)
                           and TRUNC(nvl(sub.effective_to_date,cleb.start_date));
-- end: okl.h cklee

    --cursor : to check existence of criteria
    cursor  l_suc_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    where  sub.id = p_subsidy_id
    and exists (select 1
                from   okl_subsidy_criteria suc
                where  suc.subsidy_id = sub.id);

    --cursor : to check that inv check is required
    cursor l_invreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and  exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.organization_id is not null
                   and    suc.subsidy_id = sub.id);

    --cursor : check for inv item
    cursor l_invitm_csr (p_subsidy_id in number,
                         p_asset_cle_id in number) is
    Select 'Y'
    From
           --inv item and org
           okc_k_lines_b        cleb,
           okc_k_lines_b        cle_model,
           okc_line_styles_b    lse_model,
           okc_k_items          cim_model,
           okl_subsidy_criteria suc
    where  cim_model.cle_id     = cle_model.id
    And    cim_model.dnz_chr_id = cleb.dnz_chr_id
    And    cle_model.cle_id     = cleb.id
    And    cle_model.dnz_chr_id = cleb.dnz_chr_id
    And    cle_model.lse_id     = lse_model.id
    And    lse_model.lty_code   = 'ITEM'
    And    cleb.id              = p_asset_cle_id
    And    (to_char(suc.organization_id) = cim_model.object1_id2
             And    to_char(nvl(suc.inventory_item_id,cim_model.object1_id1)) = cim_model.object1_id1
            )
    And    suc.subsidy_id    = p_subsidy_id
    And    suc.organization_id is not null;

    --cursor : to check that credit class check is required
    cursor l_clsreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.credit_classification_code is not null
-- start: okl.h cklee
--                   And    suc.id = sub.id);
                   And    suc.subsidy_id = sub.id);
-- end: okl.h cklee

    --cursor to check cutomer credit class
    cursor l_cclass_csr (p_subsidy_id in number,
                         p_asset_cle_id in number) is
    select 'Y'
    from   okc_k_headers_b       chrb,
           hz_cust_accounts      cust,
           okc_k_lines_b         cleb,
           okl_subsidy_criteria  suc
    where  chrb.id                        = cleb.chr_id
    And    cleb.dnz_chr_id                = chrb.id
    And    cleb.id                        = p_asset_cle_id
-- start: okl.h cklee
--    And    chrb.cust_acct_id              = to_char(cust.cust_account_id)
    And    chrb.cust_acct_id              = cust.cust_account_id
-- end: okl.h cklee
    And    suc.subsidy_id                 = p_subsidy_id
    And    SUC.CREDIT_CLASSIFICATION_CODE = cust.CREDIT_CLASSIFICATION_CODE
    And    SUC.CREDIT_CLASSIFICATION_CODE is not null;


    --cursor : to check that territory check is required
    cursor l_terrreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
--cklee 03/16/2004
--                   where  suc.SALES_TERRITORY_CODE is not null
                   where  suc.SALES_TERRITORY_ID is not null
                   And    suc.subsidy_id = sub.id);

    --Bug# : 3320760
    --cursor to check territory
/*
    cursor l_terr_csr (p_subsidy_id in number,
                         p_asset_cle_id in number) is
    select 'Y'
    from   hz_locations        loc,
           hz_party_sites      hzps,
           hz_party_site_uses  hzpsu,
           okl_txl_itm_insts   iti,
           --csi_item_instances  csii,
           --okc_k_items         cim_ib,
           okc_k_lines_b       cle_ib,
           okc_line_styles_b   lse_ib,
           okc_k_lines_b       cle_inst,
           okc_line_styles_b   lse_inst,
           OKC_K_LINES_B       cleb,
           okl_subsidy_criteria suc
    Where  cle_inst.cle_id      = cleb.id
    And    cle_inst.dnz_chr_id  = cleb.dnz_chr_id
    And    cle_inst.lse_id      = lse_inst.id
    And    lse_inst.lty_code    = 'FREE_FORM2'--'FREE_FORM1' cklee 21-Jan-04 bug#3375789
    And    cle_ib.cle_id        = cle_inst.id
    And    cle_ib.dnz_chr_id    = cle_inst.dnz_chr_id
    And    lse_ib.id            = cle_ib.lse_id
    And    lse_ib.lty_code      = 'INST_ITEM'
    And    iti.kle_id           = cle_ib.id
    And    hzpsu.party_site_use_id = to_number(iti.object_id1_new)
    And    hzps.party_site_id   = hzpsu.party_site_id
    And    loc.location_id      = hzps.location_id
    --And    cim_ib.cle_id        = cle_ib.id
    --And    cim_ib.dnz_chr_id    = cle_ib.dnz_chr_id
    --And    cim_ib.object1_id1   = csii.instance_id
    --And    loc.location_id      = csii.location_id
    And    SUC.SUBSIDY_ID       = p_subsidy_id
    And    SUC.SALES_TERRITORY_CODE = loc.country
    And    SUC.SALES_TERRITORY_CODE is not null
    And    cleb.id              = p_asset_cle_id; -- 'FREE_FORM1'
*/
-- Bug#3508166
   cursor l_terr_csr (p_subsidy_id in number,
                         p_asset_cle_id in number) is
    select 'Y'
    from   RA_SALESREP_TERRITORIES rst,
           OKC_CONTACTS        cro,
           OKC_K_PARTY_ROLES_B cplb,
           OKC_K_LINES_B       cleb,
           okl_subsidy_criteria suc
    Where
           rst.salesrep_id         =  cro.object1_id1
    And    cro.object1_id2         = '#'
    And    cro.jtot_object1_code   = 'OKX_SALEPERS'
    And    cro.cro_code            =  'SALESPERSON'
    And    cro.cpl_id              = cplb.id
    And    cro.dnz_chr_id          = cplb.dnz_chr_id
    And    cplb.chr_id             = cleb.dnz_chr_id
    And    cplb.dnz_chr_id         = cleb.dnz_chr_id
    And    cplb.rle_code           = 'LESSOR'
    And    SUC.SUBSIDY_ID          = p_subsidy_id
    And    SUC.SALES_TERRITORY_ID  = rst.territory_id
--    And    SUC.SALES_TERRITORY_CODE is not null
    And    cleb.id                 = p_asset_cle_id;


    --cursor : to check that product check is required
    cursor l_pdtreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.PRODUCT_ID is not null
                   And    suc.subsidy_id = sub.id);

    --cursor to check financial product
    cursor l_pdt_csr (p_subsidy_id in number,
                      p_asset_cle_id in number) is
    select 'Y'
    from   okl_k_headers       khr,
           okc_k_lines_b       cleb,
           okl_subsidy_criteria suc
    Where  khr.id                         = cleb.chr_id
    And    SUC.subsidy_id                 = p_subsidy_id
    And    SUC.product_id                 = khr.pdt_id
    And    SUC.product_id is not null
    And    cleb.id                        = p_asset_cle_id;

    --cursor : to check that sic_code check is required
    cursor l_sicreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.INDUSTRY_CODE is not null
                   And    suc.INDUSTRY_CODE_TYPE is not null
                   And    suc.subsidy_id = sub.id);

    --cursor to check service industry code
    cursor l_sic_csr (p_subsidy_id in number,
                      p_asset_cle_id in number) is
    select 'Y'
    from   hz_parties hp,
           hz_cust_accounts_all hca,
           okc_k_lines_b        cleb,
           okc_k_headers_b      chrb,
           okl_subsidy_criteria suc
    where  hp.party_id            = hca.party_id
    And    hca.CUST_ACCOUNT_ID    = chrb.cust_acct_id
    And    chrb.id                = cleb.chr_id
    And    SUC.subsidy_id         = p_subsidy_id
    And    SUC.industry_code      = hp.sic_code
    And    SUC.industry_code_type = hp.sic_code_type
    And    SUC.industry_code      is not null
    And    SUC.industry_code_type is not null
    And    cleb.id                = p_asset_cle_id;


    --cursor : to check that subsidy expiration
    cursor l_not_expire_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id

     -- Start : Bug 6050165 : prasjain
      -- and    TRUNC(nvl(sub.EFFECTIVE_TO_DATE,sysdate) + nvl(sub.EXPIRE_AFTER_DAYS,0)) >= TRUNC(sysdate);
      and       TRUNC(sysdate) between TRUNC(sub.effective_from_date) and
                TRUNC(nvl(sub.EFFECTIVE_TO_DATE,sysdate) + nvl(sub.EXPIRE_AFTER_DAYS,0));

      -- cursor to check if it is a rebook contract
      cursor l_chr_rebook (p_asset_cle_id in number) is
      Select 'Y'
      from  okc_k_headers_b chrb,
            okc_k_lines_b   cleb,
            okl_trx_contracts ktrx
      where chrb.id                              = cleb.chr_id
      and   chrb.id                              = cleb.dnz_chr_id
      and   chrb.orig_system_source_code         = 'OKL_REBOOK'
      and   cleb.id                              = p_asset_cle_id
      and   ktrx.khr_id_new                      = chrb.id
      AND    ktrx.tsu_code                        = 'ENTERED'
      AND    ktrx.rbr_code                        is NOT NULL
      AND    ktrx.tcn_type                        = 'TRBK'
     --rkuttiya added for 12.1.1. Multi GAAP Project
      AND    ktrx.representation_type             = 'PRIMARY';
     --

      l_chr_rbk        varchar2(1);

      --cursor to check if it is a mass rebook
      cursor l_chr_mass_rebook (p_asset_cle_id in number) is
      Select 'Y'
      from  okc_k_headers_b chrb,
            okc_k_lines_b   cleb,
            okl_trx_contracts ktrx
      where chrb.id                              = cleb.chr_id
      and   chrb.id                              = cleb.dnz_chr_id
      and   cleb.id                              = p_asset_cle_id
      and   ktrx.KHR_ID                          = chrb.id
      AND    ktrx.tsu_code                        = 'ENTERED'
      AND    ktrx.rbr_code                        is NOT NULL
      AND    ktrx.tcn_type                        = 'TRBK'
--rkuttiya added for 12.1.1 MUlti GAAP Project
      AND    ktrx.representation_type            = 'PRIMARY'
--
      AND    EXISTS (SELECT '1'
                FROM   okl_rbk_selected_contract rbk_khr
                WHERE  rbk_khr.KHR_ID = chrb.id
                AND    rbk_khr.STATUS <> 'PROCESSED');

      l_chr_mass_rbk        varchar2(1);

       --cursor to get split asset transactions
      CURSOR get_split_trn_csr (p_asset_cle_id IN NUMBER) IS
        SELECT 'Y'
        FROM  OKL_TXL_ASSETS_B   TXL,
              OKL_TRX_ASSETS     TRX,
              OKC_K_LINES_B      KLE_FIN,
              OKC_K_LINES_B      KLE_FIX,
              OKC_LINE_STYLES_B  LTY_FIN,
              OKC_LINE_STYLES_B  LTY_FIX
        WHERE TXL.TAL_TYPE = 'ALI' -- identifies split transaction
          AND TRX.TSU_CODE = 'ENTERED' -- split transaction in progress
          AND TXL.TAS_ID = TRX.ID
          AND KLE_FIN.LSE_ID = LTY_FIN.ID
          AND LTY_FIN.LTY_CODE = 'FREE_FORM1'
          AND KLE_FIN.ID = KLE_FIX.CLE_ID
          AND KLE_FIX.LSE_ID = LTY_FIX.ID
          AND LTY_FIX.LTY_CODE = 'FIXED_ASSET'
          AND TXL.KLE_ID = KLE_FIX.ID
          AND ( KLE_FIN.ID = p_asset_cle_id -- original asset during split
               OR KLE_FIN.ID = (SELECT ORIG_SYSTEM_ID1
                                  FROM OKC_K_LINES_B CLE_TMP
                                 WHERE CLE_TMP.ID =  p_asset_cle_id) -- new asset generated during split
                );

       l_cle_split        varchar2(1);
      -- End : Bug 6050165 : prasjain

    l_chk_required   varchar2(1);
    l_applicable     varchar2(10);

    halt_validation exception;

Begin
    --Checks on header line and existence of applicability criteria

    ---------------------------------------------------------------------------
    --A.1. check subsidy expiration
    ---------------------------------------------------------------------------
    -- cklee 01/23/04
    l_applicable := 'N';

     --Start : Bug 6050165 : prasjain
      l_chr_rbk := 'N';
      open l_chr_rebook( p_asset_cle_id => p_asset_cle_id );
      fetch l_chr_rebook into l_chr_rbk;
      close l_chr_rebook;

      l_chr_mass_rbk := 'N';
      open l_chr_mass_rebook( p_asset_cle_id => p_asset_cle_id );
      fetch l_chr_mass_rebook into l_chr_mass_rbk;
      close l_chr_mass_rebook;

      l_cle_split := 'N';
      open get_split_trn_csr(p_asset_cle_id => p_asset_cle_id);
      fetch get_split_trn_csr into l_cle_split;
      close get_split_trn_csr;

      if(l_chr_rbk = 'N' AND l_chr_mass_rbk = 'N' AND l_cle_split = 'N') then
      --End : Bug 6050165 : prasjain

    open l_not_expire_csr(p_subsidy_id   => p_subsidy_id);
    Fetch l_not_expire_csr into l_applicable;
    If l_not_expire_csr%NOTFOUND then
       Null;
    End If;
    close l_not_expire_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

     --Start : Bug 6050165 : prasjain
      end if;
      --End : Bug 6050165 : prasjain

    ---------------------------------------------------------------------------
    --A. check whether subsidy can be applied to contract (org id match)
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_chr_csr(p_subsidy_id   => p_subsidy_id,
                   p_asset_cle_id => p_asset_cle_id);
    Fetch l_chr_csr into l_applicable;
    If l_chr_csr%NOTFOUND then
       Null;
    End If;
    close l_chr_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

    ---------------------------------------------------------------------------
    --B. check whether subsidy can be applied to re-lease contract
    --    if contract is a release k
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_relk_csr(p_subsidy_id   => p_subsidy_id,
                    p_asset_cle_id => p_asset_cle_id);
    Fetch l_relk_csr into l_applicable;
    If l_relk_csr%NOTFOUND then
       Null;
    End If;
    close l_relk_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

    ---------------------------------------------------------------------------
    --C. check whether subsidy can be applied to re-lease assets
    --    if contract is a release asset k
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_rela_csr(p_subsidy_id   => p_subsidy_id,
                    p_asset_cle_id => p_asset_cle_id);
    Fetch l_rela_csr into l_applicable;
    If l_rela_csr%NOTFOUND then
       Null;
    End If;
    close l_rela_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;


    ---------------------------------------------------------------------------
    --D. check whether subsidy can be applied to line (dates match)
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_cle_csr(p_subsidy_id   => p_subsidy_id,
                   p_asset_cle_id => p_asset_cle_id);
    Fetch l_cle_csr into l_applicable;
    If l_cle_csr%NOTFOUND then
       Null;
    End If;
    close l_cle_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

    -- sjalasut added code to validate subsidy pool applicability as part of the subsidy pools enhancement. START
    -- for lease authoring the params p_ast_date_sq nad p_trx_curr_code_sq are passed as null always
    -- note that the param p_qa_checker_call is set to Y only when called from QA checker process
    -- for all the cases this param is not passed and defaulted as 'N'
    -- when called from the QA checker, the subsidypool applicability is not checked.
    -- the QA checker explicitly checks for the pool applicability. therefore the code is skipped in such case
    IF(p_qa_checker_call = 'N')THEN
      l_applicable := validate_subsidy_pool_applic(p_subsidy_id => p_subsidy_id
                                                  ,p_asset_cle_id => p_asset_cle_id
                                                  ,p_ast_date_sq => NULL -- always NULL for a Contract
                                                  ,p_trx_curr_code_sq => NULL -- always NULL for a Contract
                                                   );
      IF(l_applicable = 'NA')THEN
       l_applicable := 'Y';
      ELSIF l_applicable = 'N' THEN
        l_applicable := 'N';
        RAISE halt_validation;
      END IF;
    END IF;
    -- sjalasut added code to validate subsidy pool applicability as part of the subsidy pools enhancement. END


    ---------------------------------------------------------------------------
    --E. check whether any applicability criteria defined
    ---------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_suc_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_suc_csr into l_chk_required;
    If l_suc_csr%NOTFOUND then
        Null;
    End If;
    close l_suc_csr;

    If l_chk_required = 'N' then
       l_applicable := 'Y';
       Raise halt_validation;
    End If;

    --check applicability criterias
    l_applicable := 'Y';
    ----------------------------------------------------------------------------
    --1. check for inventory item and ORG
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_invreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_invreq_csr into l_chk_required;
    If l_invreq_csr%NOTFOUND then
        Null;
    End If;
    close l_invreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_invitm_csr(p_subsidy_id   => p_subsidy_id,
                          p_asset_cle_id => p_asset_cle_id);
        --Bug# 3290648:
        fetch l_invitm_csr into l_applicable;
        If l_invitm_csr%NOTFOUND then
           Null;
        End If;
        close l_invitm_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --2. check for credit class
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_clsreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_clsreq_csr into l_chk_required;
    If l_clsreq_csr%NOTFOUND then
        Null;
    End If;
    close l_clsreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_cclass_csr(p_subsidy_id   => p_subsidy_id,
                          p_asset_cle_id => p_asset_cle_id);
        --Bug# 3290648:
        fetch l_cclass_csr into l_applicable;
        If l_cclass_csr%NOTFOUND then
           Null;
        End If;
        close l_cclass_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --3. check for territory
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_terrreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_terrreq_csr into l_chk_required;
    If l_terrreq_csr%NOTFOUND then
        Null;
    End If;
    close l_terrreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_terr_csr(p_subsidy_id   => p_subsidy_id,
                          p_asset_cle_id => p_asset_cle_id);
        --Bug# 3290648:
        fetch l_terr_csr into l_applicable;
        If l_terr_csr%NOTFOUND then
           Null;
        End If;
        close l_terr_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --4. check for product
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_pdtreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_pdtreq_csr into l_chk_required;
    If l_pdtreq_csr%NOTFOUND then
        Null;
    End If;
    close l_pdtreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_pdt_csr(p_subsidy_id   => p_subsidy_id,
                          p_asset_cle_id => p_asset_cle_id);
       --Bug# 3290648:
        fetch l_pdt_csr into l_applicable;
        If l_pdt_csr%NOTFOUND then
           Null;
        End If;
        close l_pdt_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --5. check for SIC code
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_sicreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_sicreq_csr into l_chk_required;
    If l_sicreq_csr%NOTFOUND then
        Null;
    End If;
    close l_sicreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_sic_csr(p_subsidy_id   => p_subsidy_id,
                          p_asset_cle_id => p_asset_cle_id);
       --Bug# 3290648:
        fetch l_sic_csr into l_applicable;
        If l_sic_csr%NOTFOUND then
           Null;
        End If;
        close l_sic_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    Return(l_applicable);
    Exception
    When halt_validation then
        Return(l_applicable);
    When others then
        l_applicable := 'N';
        Return(l_applicable);
End validate_subsidy_applicability;
--Bug# 3320760 :
------------------------------------------------------------------------------
--Function to validate whether subsdy is applicable on an asset overloaded for SO
--------------------------------------------------------------------------------
Function validate_subsidy_applicability(p_subsidy_id          IN  NUMBER,
                                        p_chr_id              IN  NUMBER,
                                        p_start_date          IN  DATE,
                                        p_inv_item_id         IN  NUMBER,
                                        p_inv_org_id          IN  NUMBER,
                                        p_install_site_use_id IN NUMBER
                                        ) Return Varchar2 is

    --cursor : to check applicability at contract header ORG_ID
    cursor l_chr_csr (p_subsidy_id in number,
                      p_chr_id in number) is
    Select 'Y'
    from   okl_subsidies_b sub,
           okc_k_headers_b chrb
    where  sub.id                = p_subsidy_id
    and    chrb.id               = p_chr_id
    --check for authoring org id
    and    chrb.authoring_org_id = sub.org_id
    --check for currency code
    and    chrb.currency_code = sub.currency_code;


    --cursor : to check applicability at  line dates
    cursor l_cle_csr (p_subsidy_id in number,
                      p_start_date in date
                      ) is
    Select 'Y'
    from   okl_subsidies_b sub
    where  sub.id                = p_subsidy_id
    and    p_start_date between sub.effective_from_date
                          and nvl(sub.effective_to_date,p_start_date);

    --cursor : to check existence of criteria
    cursor  l_suc_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    where  sub.id = p_subsidy_id
    and exists (select 1
                from   okl_subsidy_criteria suc
                where  suc.subsidy_id = sub.id);

    --cursor : to check that inv check is required
    cursor l_invreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and  exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.organization_id is not null
                   and    suc.subsidy_id = sub.id);

    --cursor : check for inv item
    cursor l_invitm_csr (p_subsidy_id in number,
                         p_inv_item_id in number,
                         p_inv_org_id  in number) is
    Select 'Y'
    From
           --inv item and org
           okl_subsidy_criteria suc
    where  (suc.organization_id = p_inv_org_id
             And    nvl(suc.inventory_item_id,p_inv_item_id) = p_inv_item_id
            )
    And    suc.subsidy_id    = p_subsidy_id
    And    suc.organization_id is not null;

    --cursor : to check that credit class check is required
    cursor l_clsreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.credit_classification_code is not null
-- start: okl.h cklee
--                   And    suc.id = sub.id);
                   And    suc.subsidy_id = sub.id);
-- end: okl.h cklee

    --cursor to check cutomer credit class
  --     nikshah -- Bug # 5484903 Fixed,
  --     Changed cursor l_cclass_csr (p_subsidy_id in number,  p_chr_id in number) SQL definition
cursor l_cclass_csr (p_subsidy_id in number,
                         p_chr_id in number) is
   select 'Y'
    from   okc_k_headers_all_b       chrb,
           hz_cust_accounts      cust,
           okl_subsidy_criteria  suc
    where  chrb.id                        =  p_chr_id
    And    chrb.cust_acct_id              = cust.cust_account_id
    And    suc.subsidy_id                 = p_subsidy_id
    And    SUC.CREDIT_CLASSIFICATION_CODE = cust.CREDIT_CLASSIFICATION_CODE
    And    SUC.CREDIT_CLASSIFICATION_CODE is not null;


    --cursor : to check that territory check is required
    cursor l_terrreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.SALES_TERRITORY_CODE is not null
                   And    suc.subsidy_id = sub.id);

    --cursor to check territory
   cursor l_terr_csr (p_subsidy_id in number,
                      p_install_site_use_id in number) is
    select 'Y'
    from   hz_locations        loc,
           hz_party_sites      hzps,
           hz_party_site_uses  hzpsu,
           okl_subsidy_criteria suc
    Where  hzpsu.party_site_use_id = p_install_site_use_id
    And    hzps.party_site_id   = hzpsu.party_site_id
    And    loc.location_id      = hzps.location_id
    And    SUC.SUBSIDY_ID       = p_subsidy_id
    And    SUC.SALES_TERRITORY_CODE = loc.country
    And    SUC.SALES_TERRITORY_CODE is not null;

    --cursor : to check that product check is required
    cursor l_pdtreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.PRODUCT_ID is not null
                   And    suc.subsidy_id = sub.id);

    --cursor to check financial product
    cursor l_pdt_csr (p_subsidy_id in number,
                      p_chr_id     in number) is
    select 'Y'
    from   okl_k_headers       khr,
           okl_subsidy_criteria suc
    Where  khr.id                         = p_chr_id
    And    SUC.subsidy_id                 = p_subsidy_id
    And    SUC.product_id                 = khr.pdt_id
    And    SUC.product_id is not null;

    --cursor : to check that sic_code check is required
    cursor l_sicreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.INDUSTRY_CODE is not null
                   And    suc.INDUSTRY_CODE_TYPE is not null
                   And    suc.subsidy_id = sub.id);

    --cursor to check service industry code
    cursor l_sic_csr (p_subsidy_id in number,
                      p_chr_id     in number) is
    select 'Y'
    from   hz_parties hp,
           hz_cust_accounts_all hca,
           okc_k_headers_b      chrb,
           okl_subsidy_criteria suc
    where  hp.party_id            = hca.party_id
    And    hca.CUST_ACCOUNT_ID    = chrb.cust_acct_id
    And    chrb.id                = p_chr_id
    And    SUC.subsidy_id         = p_subsidy_id
    And    SUC.industry_code      = hp.sic_code
    And    SUC.industry_code_type = hp.sic_code_type
    And    SUC.industry_code      is not null
    And    SUC.industry_code_type is not null;

    CURSOR c_get_trx_csr IS
    SELECT currency_code
      FROM okc_k_headers_b
     WHERE id = p_chr_id;
    l_trx_currency_code okc_k_headers_b.currency_code%TYPE;

    l_chk_required   varchar2(1);
    l_applicable     varchar2(10);

    lx_conversion_rate NUMBER;
    lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
    lx_subsidy_pool_status okl_subsidy_pools_b.decision_status_code%TYPE;
    lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
    lx_sub_pool_balance NUMBER;

    halt_validation exception;

Begin
    --Checks on header line and existence of applicability criteria
    ---------------------------------------------------------------------------
    --A. check whether subsidy can be applied to contract (org id match)
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_chr_csr(p_subsidy_id   => p_subsidy_id,
                   p_chr_id       => p_chr_id);
    Fetch l_chr_csr into l_applicable;
    If l_chr_csr%NOTFOUND then
       Null;
    End If;
    close l_chr_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

    ---------------------------------------------------------------------------
    --D. check whether subsidy can be applied to line (dates match)
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_cle_csr(p_subsidy_id   => p_subsidy_id,
                   p_start_date   => p_start_date);
    Fetch l_cle_csr into l_applicable;
    If l_cle_csr%NOTFOUND then
       Null;
    End If;
    close l_cle_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

--START: 24-Oct-2005  cklee - Fixed bug#4865580                           |
    /**
     * sjalasut, added validations as part of subsidy pools enhancement. START
     * for sales quote, the parameter p_asset_cle_id is passed as NULL
     * the asset start date and the contract currency code must be passed in case of sales quote
     */
    OPEN c_get_trx_csr; FETCH c_get_trx_csr INTO l_trx_currency_code;
    CLOSE c_get_trx_csr;
    l_applicable := validate_subsidy_pool_applic(p_subsidy_id => p_subsidy_id
                                                ,p_asset_cle_id => null
                                                ,p_ast_date_sq => p_start_date
                                                ,p_trx_curr_code_sq => l_trx_currency_code
                                                 );
    IF(l_applicable = 'NA')THEN
      l_applicable := 'Y';
    ELSIF l_applicable = 'N' THEN
      Raise halt_validation;
    END IF;
    /**
     * sjalasut, added validations as part of subsidy pools enhancement. END
     */

--END: 24-Oct-2005  cklee - Fixed bug#4865580                           |

    ---------------------------------------------------------------------------
    --E. check whether any applicability criteria defined
    ---------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_suc_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_suc_csr into l_chk_required;
    If l_suc_csr%NOTFOUND then
        Null;
    End If;
    close l_suc_csr;

    If l_chk_required = 'N' then
       l_applicable := 'Y';
       Raise halt_validation;
    End If;

    --check applicability criterias
    l_applicable := 'Y';
    ----------------------------------------------------------------------------
    --1. check for inventory item and ORG
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_invreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_invreq_csr into l_chk_required;
    If l_invreq_csr%NOTFOUND then
        Null;
    End If;
    close l_invreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_invitm_csr(p_subsidy_id   => p_subsidy_id,
                          p_inv_item_id  => p_inv_item_id,
                          p_inv_org_id   => p_inv_org_id);
        --Bug# 3290648:
        fetch l_invitm_csr into l_applicable;
        If l_invitm_csr%NOTFOUND then
           Null;
        End If;
        close l_invitm_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --2. check for credit class
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_clsreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_clsreq_csr into l_chk_required;
    If l_clsreq_csr%NOTFOUND then
        Null;
    End If;
    close l_clsreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_cclass_csr(p_subsidy_id   => p_subsidy_id,
                          p_chr_id       => p_chr_id);
        --Bug# 3290648:
        fetch l_cclass_csr into l_applicable;
        If l_cclass_csr%NOTFOUND then
           Null;
        End If;
        close l_cclass_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --3. check for territory
    ----------------------------------------------------------------------------
/*comment out for bug##3508166: cklee 03/16/2004
    l_chk_required := 'N';
    open l_terrreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_terrreq_csr into l_chk_required;
    If l_terrreq_csr%NOTFOUND then
        Null;
    End If;
    close l_terrreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_terr_csr(p_subsidy_id          => p_subsidy_id,
                        p_install_site_use_id => p_install_site_use_id);
        --Bug# 3290648:
        fetch l_terr_csr into l_applicable;
        If l_terr_csr%NOTFOUND then
           Null;
        End If;
        close l_terr_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;
*/
    ----------------------------------------------------------------------------
    --4. check for product
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_pdtreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_pdtreq_csr into l_chk_required;
    If l_pdtreq_csr%NOTFOUND then
        Null;
    End If;
    close l_pdtreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_pdt_csr(p_subsidy_id   => p_subsidy_id,
                       p_chr_id => p_chr_id);
       --Bug# 3290648:
        fetch l_pdt_csr into l_applicable;
        If l_pdt_csr%NOTFOUND then
           Null;
        End If;
        close l_pdt_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --5. check for SIC code
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_sicreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_sicreq_csr into l_chk_required;
    If l_sicreq_csr%NOTFOUND then
        Null;
    End If;
    close l_sicreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_sic_csr(p_subsidy_id   => p_subsidy_id,
                       p_chr_id => p_chr_id);
       --Bug# 3290648:
        fetch l_sic_csr into l_applicable;
        If l_sic_csr%NOTFOUND then
           Null;
        End If;
        close l_sic_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    /**
     * sjalasut, added validations as part of subsidy pools enhancement. START
     * for sales quote, the parameter p_asset_cle_id is passed as NULL
     * the asset start date and the contract currency code must be passed in case of sales quote
     */
--START: 24-Oct-2005  cklee - Fixed bug#4865580
--Commented for the following and move to above check criteria exists                         |
--    OPEN c_get_trx_csr; FETCH c_get_trx_csr INTO l_trx_currency_code;
--    CLOSE c_get_trx_csr;
--    l_applicable := validate_subsidy_pool_applic(p_subsidy_id => p_subsidy_id
--                                                ,p_asset_cle_id => null
--                                                ,p_ast_date_sq => p_start_date
--                                                ,p_trx_curr_code_sq => l_trx_currency_code
--                                                 );
--    IF(l_applicable = 'NA')THEN
--     l_applicable := 'Y';
--    ELSIF l_applicable = 'N' THEN
--      l_applicable := 'N';
--    END IF;
--END: 24-Oct-2005  cklee - Fixed bug#4865580                           |
    /**
     * sjalasut, added validations as part of subsidy pools enhancement. END
     */

    Return(l_applicable);
    Exception
    When halt_validation then
        Return(l_applicable);
    When others then
        l_applicable := 'N';
        Return(l_applicable);
End validate_subsidy_applicability;
--End Bug# 3320760

-- start 29-June-2005 cklee -  okl.h Sales Quote IA Subsidies
  -------------------------------------------------------------------------------
  -- FUNCTION validate_subsidy_applicability
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : validate_subsidy_applicability
  -- Description     : function returns Y if the subsidy is applicable for the
  --                 : passed in Sales Quote/Lease Application asset
  --                 : N otherwise
  --
  -- Parameters      : requires parameters:
  --                   p_subsidy_id         : Subsidy ID
  --                   p_start_date         : Sales Quote/Lease App's asset start date
  --                   p_inv_item_id        : Inventory Item ID
  --obsolete                   p_install_site_use_id: Install Site use ID
  --                   p_currency_code      : Sales Quote/Lease App's currency code
  --                   p_authoring_org_id   : Sales Quote/Lease App's operating unit ID
  --                   p_cust_account_id    : Sales Quote/Lease App's customer account ID
  --                   p_pdt_id             : Financial product ID
  --                   p_sales_rep_id       : Sales Representative ID
  --
  --                   p_tot_subsidy_amount : The total asset subsidy amount for the Quote/Lease
  --                                          application up to the validation point.
  --
  --                                         For example,
  --                                         Quote has 3 assets with subsidy
  --                                         Asset1, sub1, $1,000 : p_tot_subsidy_amount = $1,000
  --                                         Asset2, sub1, $1,000 : p_tot_subsidy_amount = $2,000
  --                                         Asset3, sub1, $1,000 : p_tot_subsidy_amount = $3,000
  --
  --                                         API will check if the accumulated subsidy amount exceed
  --                                         the pool balance.
  --                   p_subsidy_amount     : Calculated subsidy amount based on Quote/Lease
  --                                          application system. API will also check if
  --                                          subsidy amount exceed the balance of the pool
  --                   p_filter_flag        : Y/N to indicate if used for LOV filterring
  --                   p_dnz_asset_number   : Quote/Lease app asset number used for error message
  --
  -- Validation rules:
  --                   System will not have FK check for the passed in parameters.
  --                   Instead, system will check the applicability between the passed
  --                   in parametrs and the details criteria for the passed in
  --                   Subsidy.
  --
  -- Version         : 1.0
  -- History         : 29-June-2005 cklee created
  -- End of comments
  Function validate_subsidy_applicability(p_subsidy_id          IN  NUMBER,
                                          p_start_date          IN  DATE,
                                          p_inv_item_id         IN  NUMBER,
                                          p_inv_org_id          IN  NUMBER,
--obsolete                                          p_install_site_use_id IN  NUMBER,
                                          p_currency_code       IN  VARCHAR2,
                                          p_authoring_org_id    IN  NUMBER,
                                          p_cust_account_id     IN  NUMBER,
                                          p_pdt_id              IN  NUMBER,
                                          p_sales_rep_id        IN  NUMBER,
--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                          p_tot_subsidy_amount  IN  NUMBER,
                                          p_subsidy_amount      IN  NUMBER,
                                          p_filter_flag         IN  VARCHAR2,
                                          p_dnz_asset_number    IN  VARCHAR2
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                          ) Return Varchar2 is

-- start: okl.h cklee
/*    --cursor : to check applicability at contract header ORG_ID
    cursor l_chr_csr (p_subsidy_id in number,
                      p_chr_id in number) is
    Select 'Y'
    from   okl_subsidies_b sub,
           okc_k_headers_b chrb
    where  sub.id                = p_subsidy_id
    and    chrb.id               = p_chr_id
    --check for authoring org id
    and    chrb.authoring_org_id = sub.org_id
    --check for currency code
    and    chrb.currency_code = sub.currency_code;
*/
    --cursor : to check applicability for the Sales Quote/Lease App ORG_ID, currency code
    cursor l_chr_csr (p_subsidy_id       in number,
                      p_authoring_org_id in number,
                      p_currency_code    in varchar2) is
    Select 'Y'
    from   okl_subsidies_b sub
    where  sub.id                = p_subsidy_id
    --check for authoring org id
    and    sub.org_id            = p_authoring_org_id
    --check for currency code
    and    sub.currency_code     = p_currency_code;
-- end: okl.h cklee


    --cursor : to check applicability at line dates
    cursor l_cle_csr (p_subsidy_id in number,
                      p_start_date in date
                      ) is
    Select 'Y'
    from   okl_subsidies_b sub
    where  sub.id                = p_subsidy_id
-- start: okl.h cklee
--    and    p_start_date between sub.effective_from_date
--                          and nvl(sub.effective_to_date,p_start_date);
    and    TRUNC(p_start_date) between TRUNC(sub.effective_from_date)
                          and TRUNC(nvl(sub.effective_to_date,p_start_date));
-- end: okl.h cklee

    --cursor : to check existence of criteria
    cursor  l_suc_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    where  sub.id = p_subsidy_id
    and exists (select 1
                from   okl_subsidy_criteria suc
                where  suc.subsidy_id = sub.id);

    --cursor : to check that inv check is required
    cursor l_invreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and  exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.organization_id is not null
                   and    suc.subsidy_id = sub.id);

    --cursor : check for inv item
    cursor l_invitm_csr (p_subsidy_id in number,
                         p_inv_item_id in number,
                         p_inv_org_id  in number) is
    Select 'Y'
    From
           --inv item and org
           okl_subsidy_criteria suc
    where  (suc.organization_id = p_inv_org_id
             And    nvl(suc.inventory_item_id,p_inv_item_id) = p_inv_item_id
            )
    And    suc.subsidy_id    = p_subsidy_id
    And    suc.organization_id is not null;

    --cursor : to check that credit class check is required
    cursor l_clsreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.credit_classification_code is not null
-- start: okl.h cklee
--                   And    suc.id = sub.id);
                   And    suc.subsidy_id = sub.id);
-- end: okl.h cklee

-- start: okl.h cklee
    --cursor to check cutomer credit class
/*    cursor l_cclass_csr (p_subsidy_id in number,
                         p_chr_id in number) is
    select 'Y'
    from   okc_k_headers_b       chrb,
           hz_cust_accounts      cust,
           okl_subsidy_criteria  suc
    where  chrb.id                        = p_chr_id
    And    chrb.cust_acct_id              = to_char(cust.cust_account_id)
    And    suc.subsidy_id                 = p_subsidy_id
    And    SUC.CREDIT_CLASSIFICATION_CODE = cust.CREDIT_CLASSIFICATION_CODE
    And    SUC.CREDIT_CLASSIFICATION_CODE is not null;
*/
    --cursor to check cutomer credit class
    cursor l_cclass_csr (p_subsidy_id      in number,
                         p_cust_account_id in number) is
    select 'Y'
    from   hz_cust_accounts      cust,
           okl_subsidy_criteria  suc
    where  cust.cust_account_id           = p_cust_account_id
    And    suc.subsidy_id                 = p_subsidy_id
    And    SUC.CREDIT_CLASSIFICATION_CODE = cust.CREDIT_CLASSIFICATION_CODE
    And    SUC.CREDIT_CLASSIFICATION_CODE is not null;
-- end: okl.h cklee


    --cursor : to check that territory check is required
    cursor l_terrreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.SALES_TERRITORY_ID is not null
                   And    suc.subsidy_id = sub.id);

-- start: okl.h cklee
    --cursor to check territory
/*   cursor l_terr_csr (p_subsidy_id in number,
                      p_install_site_use_id in number) is
    select 'Y'
    from   hz_locations        loc,
           hz_party_sites      hzps,
           hz_party_site_uses  hzpsu,
           okl_subsidy_criteria suc
    Where  hzpsu.party_site_use_id = p_install_site_use_id
    And    hzps.party_site_id   = hzpsu.party_site_id
    And    loc.location_id      = hzps.location_id
    And    SUC.SUBSIDY_ID       = p_subsidy_id
    And    SUC.SALES_TERRITORY_CODE = loc.country
    And    SUC.SALES_TERRITORY_CODE is not null;
*/
   cursor l_terr_csr (p_subsidy_id   in number,
                      p_sales_rep_id in number) is
    select 'Y'
    from   RA_SALESREP_TERRITORIES rst,
           okl_subsidy_criteria suc
    Where  rst.salesrep_id         = p_sales_rep_id
    And    SUC.SUBSIDY_ID          = p_subsidy_id
    And    SUC.SALES_TERRITORY_ID  = rst.territory_id;
-- end: okl.h cklee

    --cursor : to check that product check is required
    cursor l_pdtreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.PRODUCT_ID is not null
                   And    suc.subsidy_id = sub.id);

-- start: okl.h cklee
    --cursor to check financial product
/*    cursor l_pdt_csr (p_subsidy_id in number,
                      p_chr_id     in number) is
    select 'Y'
    from   okl_k_headers       khr,
           okl_subsidy_criteria suc
    Where  khr.id                         = p_chr_id
    And    SUC.subsidy_id                 = p_subsidy_id
    And    SUC.product_id                 = khr.pdt_id
    And    SUC.product_id is not null;
*/
    --cursor to check financial product
    cursor l_pdt_csr (p_subsidy_id in number,
                      p_pdt_id     in number) is
    select 'Y'
    from   okl_subsidy_criteria suc
    where  SUC.subsidy_id                 = p_subsidy_id
    And    SUC.product_id                 = p_pdt_id
    And    SUC.product_id is not null;
-- end: okl.h cklee

    --cursor : to check that sic_code check is required
    cursor l_sicreq_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b sub
    Where  sub.id = p_subsidy_id
    and    exists (select 1
                   from   okl_subsidy_criteria suc
                   where  suc.INDUSTRY_CODE is not null
                   And    suc.INDUSTRY_CODE_TYPE is not null
                   And    suc.subsidy_id = sub.id);

-- start: okl.h cklee
    --cursor to check service industry code
/*    cursor l_sic_csr (p_subsidy_id in number,
                      p_chr_id     in number) is
    select 'Y'
    from   ra_customers         rac,
           okc_k_headers_b      chrb,
           okl_subsidy_criteria suc
    where  rac.customer_id        = chrb.cust_acct_id
    And    chrb.id                = p_chr_id
    And    SUC.subsidy_id         = p_subsidy_id
    And    SUC.industry_code      = rac.sic_code
    And    SUC.industry_code_type = rac.sic_code_type
    And    SUC.industry_code      is not null
    And    SUC.industry_code_type is not null;
*/
    --cursor to check service industry code
    cursor l_sic_csr (p_subsidy_id      in number,
                      p_cust_account_id in number) is
    select 'Y'
    from   hz_parties hp,
           hz_cust_accounts_all hca,
           okl_subsidy_criteria suc
    where  hp.party_id            = hca.party_id
    And    hca.CUST_ACCOUNT_ID    = p_cust_account_id
    And    SUC.subsidy_id         = p_subsidy_id
    And    SUC.industry_code      = hp.sic_code
    And    SUC.industry_code_type = hp.sic_code_type
    And    SUC.industry_code      is not null
    And    SUC.industry_code_type is not null;
-- end: okl.h cklee


-- start: okl.h cklee
-- commented for the okl.h Sales Quote/Lease Application IA Subsidies
/*    CURSOR c_get_trx_csr IS
    SELECT currency_code
      FROM okc_k_headers_b
     WHERE id = p_chr_id;

    l_trx_currency_code okc_k_headers_b.currency_code%TYPE;
*/
-- end: okl.h cklee

    l_chk_required   varchar2(1);
    l_applicable     varchar2(10);

    lx_conversion_rate NUMBER;
    lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
    lx_subsidy_pool_status okl_subsidy_pools_b.decision_status_code%TYPE;
    lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
    lx_sub_pool_balance NUMBER;

    halt_validation exception;

Begin
    --Checks on header line and existence of applicability criteria
    ---------------------------------------------------------------------------
    --A. check whether subsidy can be applied to contract (org id match)
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_chr_csr (p_subsidy_id       => p_subsidy_id,
                    p_authoring_org_id => p_authoring_org_id,
                    p_currency_code    => p_currency_code);

    Fetch l_chr_csr into l_applicable;
    If l_chr_csr%NOTFOUND then
       Null;
    End If;
    close l_chr_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

    ---------------------------------------------------------------------------
    --D. check whether subsidy can be applied to line (dates match)
    ---------------------------------------------------------------------------
    l_applicable := 'N';
    open l_cle_csr(p_subsidy_id   => p_subsidy_id,
                   p_start_date   => p_start_date);
    Fetch l_cle_csr into l_applicable;
    If l_cle_csr%NOTFOUND then
       Null;
    End If;
    close l_cle_csr;
    If l_applicable = 'N' then
       Raise halt_validation;
    End If;

--START: 24-Oct-2005  cklee - Fixed bug#4865580                           |
    l_applicable := validate_subsidy_pool_applic(p_subsidy_id         => p_subsidy_id
                                                ,p_asset_cle_id       => null
                                                ,p_ast_date_sq        => p_start_date
                                                ,p_trx_curr_code_sq   => p_currency_code
--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                                ,p_tot_subsidy_amount => p_tot_subsidy_amount
                                                ,p_subsidy_amount     => p_subsidy_amount
                                                ,p_filter_flag        => p_filter_flag
                                                ,p_dnz_asset_number   => p_dnz_asset_number
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                                 );
    IF(l_applicable = 'NA')THEN
      l_applicable := 'Y';
    ELSIF l_applicable = 'N' THEN
      Raise halt_validation;
    END IF;
--END: 24-Oct-2005  cklee - Fixed bug#4865580                           |

    ---------------------------------------------------------------------------
    --E. check whether any applicability criteria defined
    ---------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_suc_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_suc_csr into l_chk_required;
    If l_suc_csr%NOTFOUND then
        Null;
    End If;
    close l_suc_csr;

    If l_chk_required = 'N' then
       l_applicable := 'Y';
       Raise halt_validation;
    End If;

    --check applicability criterias
    l_applicable := 'Y';
    ----------------------------------------------------------------------------
    --1. check for inventory item and ORG
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_invreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_invreq_csr into l_chk_required;
    If l_invreq_csr%NOTFOUND then
        Null;
    End If;
    close l_invreq_csr;

    If l_chk_required = 'Y' then
        --check for inv item and org
        l_applicable := 'N';
        open l_invitm_csr(p_subsidy_id   => p_subsidy_id,
                          p_inv_item_id  => p_inv_item_id,
                          p_inv_org_id   => p_inv_org_id);
        --Bug# 3290648:
        fetch l_invitm_csr into l_applicable;
        If l_invitm_csr%NOTFOUND then
           Null;
        End If;
        close l_invitm_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --2. check for credit class
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_clsreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_clsreq_csr into l_chk_required;
    If l_clsreq_csr%NOTFOUND then
        Null;
    End If;
    close l_clsreq_csr;

    If l_chk_required = 'Y' then
        --check for credit class
        l_applicable := 'N';
        open l_cclass_csr(p_subsidy_id       => p_subsidy_id,
                          p_cust_account_id  => p_cust_account_id);
        --Bug# 3290648:
        fetch l_cclass_csr into l_applicable;
        If l_cclass_csr%NOTFOUND then
           Null;
        End If;
        close l_cclass_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --3. check for territory
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_terrreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_terrreq_csr into l_chk_required;
    If l_terrreq_csr%NOTFOUND then
        Null;
    End If;
    close l_terrreq_csr;

    If l_chk_required = 'Y' then
        --check for territory
        l_applicable := 'N';
        open l_terr_csr(p_subsidy_id   => p_subsidy_id,
                        p_sales_rep_id => p_sales_rep_id);
        --Bug# 3290648:
        fetch l_terr_csr into l_applicable;
        If l_terr_csr%NOTFOUND then
           Null;
        End If;
        close l_terr_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --4. check for product
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_pdtreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_pdtreq_csr into l_chk_required;
    If l_pdtreq_csr%NOTFOUND then
        Null;
    End If;
    close l_pdtreq_csr;

    If l_chk_required = 'Y' then
        --check for product
        l_applicable := 'N';
        open l_pdt_csr(p_subsidy_id   => p_subsidy_id,
                       p_pdt_id       => p_pdt_id);
       --Bug# 3290648:
        fetch l_pdt_csr into l_applicable;
        If l_pdt_csr%NOTFOUND then
           Null;
        End If;
        close l_pdt_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --5. check for SIC code
    ----------------------------------------------------------------------------
    l_chk_required := 'N';
    open l_sicreq_csr(p_subsidy_id => p_subsidy_id);
    Fetch l_sicreq_csr into l_chk_required;
    If l_sicreq_csr%NOTFOUND then
        Null;
    End If;
    close l_sicreq_csr;

    If l_chk_required = 'Y' then
        --check for SIC
        l_applicable := 'N';
        open l_sic_csr(p_subsidy_id      => p_subsidy_id,
                       p_cust_account_id => p_cust_account_id);
       --Bug# 3290648:
        fetch l_sic_csr into l_applicable;
        If l_sic_csr%NOTFOUND then
           Null;
        End If;
        close l_sic_csr;
        If l_applicable = 'N' then
           Raise halt_validation;
        End If;
    End If;

    /**
     * sjalasut, added validations as part of subsidy pools enhancement. START
     * for sales quote, the parameter p_asset_cle_id is passed as NULL
     * the asset start date and the contract currency code must be passed in case of sales quote
     */
-- start: okl.h cklee
-- commented for the okl.h Sales Quote/Lease Application IA Subsidies
/*    OPEN c_get_trx_csr; FETCH c_get_trx_csr INTO l_trx_currency_code;
    CLOSE c_get_trx_csr;
*/
-- end: okl.h cklee
-- cklee: 06/26/05
  -- cklee: 06/29/2005
  -- l_applicable is used for the resturn status of the function. Do not confuse
  -- with the name of the variable. So, if l_applicable = 'NA' means subsidy is
  -- either associated with the subsidy pool and applicable or subsidy is a
  -- stand alone subsidy
  --
--START: 24-Oct-2005  cklee - Fixed bug#4865580                           |
-- commented   l_applicable := validate_subsidy_pool_applic(p_subsidy_id => p_subsidy_id
-- commented                                               ,p_asset_cle_id => null
-- commented                                               ,p_ast_date_sq => p_start_date
--END 24-Oct-2005  cklee - Fixed bug#4865580                           |
-- start: okl.h cklee
-- commented for the okl.h Sales Quote/Lease Application IA Subsidies
--                                                ,p_trx_curr_code_sq => l_trx_currency_code
-- commented                                               ,p_trx_curr_code_sq => p_currency_code
-- start: okl.h cklee
-- commented                                                );
--END 24-Oct-2005  cklee - Fixed bug#4865580                           |

--START: 24-Oct-2005  cklee - Fixed bug#4865580                           |
-- commented    IF(l_applicable = 'NA')THEN
-- commented    l_applicable := 'Y';
-- commented   ELSIF l_applicable = 'N' THEN
-- commented     l_applicable := 'N';
-- commented END IF;
--END: 24-Oct-2005  cklee - Fixed bug#4865580                           |
    /**
     * sjalasut, added validations as part of subsidy pools enhancement. END
     */

    Return(l_applicable);
    Exception
    When halt_validation then
        Return(l_applicable);
    When others then
        l_applicable := 'N';
        Return(l_applicable);
End validate_subsidy_applicability;

-- end:  29-June-2005 cklee -  okl.h Sales Quote IA Subsidies


-- sjalasut added new function for subsidy pools enhancement. START
-- this functions returns
-- Y if there exists a pool and is applicable,
-- N if there exists a pool but not applicable,
-- NA if the pool is not associated with the subsidy (standalone subsidy)
-- the rules for applicability are
-- 1. A subsidy is associated with a pool
-- 2. the subsidy pool has decision_status_code = 'ACTIVE' and sysdate between effective dates of the subsidy pool
-- 3. the subsidy pool is logically active as on the start date of the asset
-- 4. there exists a valid currency conversion basis between the pool and the asset/contract
-- 5. the pool balance is valid before addition of the subsidy amount
FUNCTION validate_subsidy_pool_applic(p_subsidy_id          IN okl_subsidies_b.id%TYPE,
                                      p_asset_cle_id        IN okc_k_lines_b.id%TYPE,
                                      p_ast_date_sq         IN okc_k_lines_b.start_date%TYPE,
                                      p_trx_curr_code_sq    IN okc_k_lines_b.currency_code%TYPE,
--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                      p_tot_subsidy_amount  IN  NUMBER,
                                      p_subsidy_amount      IN  NUMBER,
                                      p_filter_flag         IN  VARCHAR2,
                                      p_dnz_asset_number    IN  VARCHAR2
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                      ) RETURN VARCHAR2 IS

  CURSOR c_get_asset_dtls_csr IS
  SELECT line.start_date, hdr.currency_code
    FROM okc_k_headers_b hdr,
         okc_k_lines_b line
   WHERE line.id = p_asset_cle_id
     AND line.dnz_chr_id = hdr.id;

--START: 09/29/2005 bug#4634871
  CURSOR c_get_asset_number_csr(p_asset_cle_id number) IS
  SELECT line.name
    FROM okc_k_lines_v line
   WHERE line.id = p_asset_cle_id;

  CURSOR c_get_subsidy_name_csr(p_subsidy_id number) IS
  SELECT sub.name
    FROM okl_subsidies_b sub
   WHERE sub.id = p_subsidy_id;

  CURSOR c_get_subsidy_pool_name_csr(p_subsidy_pool_id number) IS
  SELECT sub.subsidy_pool_name
    FROM okl_subsidy_pools_v sub
   WHERE sub.id = p_subsidy_pool_id;
--END: 09/29/2005 bug#4634871


  l_applicable     VARCHAR2(10);
  lx_conversion_rate NUMBER;
  lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
  lx_subsidy_pool_status okl_subsidy_pools_b.decision_status_code%TYPE;
  lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
  lx_sub_pool_balance NUMBER;
  -- local variables for sales quote usage. when called from LA, the p_asset_cle_id is passed and
  -- p_ast_date_sq is p_trx_curr_code are null, for SQ, the case is converse
  lv_asset_curr_code okc_k_lines_b.currency_code%TYPE;
  lv_start_date okc_k_lines_b.start_date%TYPE;
--START: 09/29/2005 bug#4634871
  lv_asset_number okc_k_lines_v.name%TYPE;
  lv_subsidy_name okl_subsidies_b.name%TYPE;
  lv_subsidy_pool_name okl_subsidy_pools_v.subsidy_pool_name%TYPE;
--END: 09/29/2005 bug#4634871

  l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_ASSET_SUBSIDY_PVT.VALIDATE_SUBSIDY_POOL_APPLIC';
  l_debug_enabled VARCHAR2(10);
  is_debug_statement_on BOOLEAN;

--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
  lx_return_status    VARCHAR2(1);
  lx_msg_count        NUMBER;
  lx_msg_data         VARCHAR2(2000);
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |

BEGIN
  l_applicable := 'NA';

  -- check if debug is enabled
  l_debug_enabled := okl_debug_pub.check_log_enabled;
  -- check for logging on STATEMENT level
  is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

  -- cklee: 06/29/2005
  -- l_applicable is used for the resturn status of the function. Do not confuse
  -- with the name of the variable. So, if l_applicable = 'Y' means subsidy is
  -- associated with subsidy pool
  --
  l_applicable := is_sub_assoc_with_pool(p_subsidy_id => p_subsidy_id
                                        ,x_subsidy_pool_id => lx_subsidy_pool_id
                                        ,x_sub_pool_curr_code => lx_sub_pool_curr_code);

  IF(l_applicable = 'Y' AND lx_subsidy_pool_id IS NOT NULL)THEN
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'subsidy '||p_subsidy_id||' is attached to subsidy pool '||lx_subsidy_pool_id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    -- the code check here is as good as the effective date check, but the code check is more
    -- economical in case the pool has already expired. date comparision is more costlier than
    -- reading a value from a column.
    l_applicable := is_sub_pool_active(p_subsidy_pool_id => lx_subsidy_pool_id
                                      ,x_pool_status => lx_subsidy_pool_status
                                       );
    IF(l_applicable = 'N')THEN
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'subsidy pool '||lx_subsidy_pool_id||' is not active'
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

--START: 09/29/2005 bug#4634871
      OPEN c_get_asset_number_csr(p_asset_cle_id); FETCH c_get_asset_number_csr INTO lv_asset_number;
      CLOSE c_get_asset_number_csr;

--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
      -- Override asset number for Sales Quote to display proper error message
      IF p_filter_flag = 'N' THEN
        lv_asset_number := p_dnz_asset_number;
      END IF;
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |

      OPEN c_get_subsidy_name_csr(p_subsidy_id); FETCH c_get_subsidy_name_csr INTO lv_subsidy_name;
      CLOSE c_get_subsidy_name_csr;
      OKL_API.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_NOT_ACTIVE,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => lv_subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => lv_asset_number);
      RAISE G_EXCEPTION_HALT_VALIDATION;
--      return l_applicable;
--END: 09/29/2005 bug#4634871
    END IF;
    -- this determines whether the function is called from contracts or from sales quote
    -- for contracts, the asset_id is used to derive the transaction currency and start date
    -- for quotes, these values are passed as parameters and asset_id in case of quotes will be null
    IF(p_ast_date_sq IS NULL AND p_trx_curr_code_sq IS NULL)THEN
      OPEN c_get_asset_dtls_csr; FETCH c_get_asset_dtls_csr INTO lv_start_date, lv_asset_curr_code;
      CLOSE c_get_asset_dtls_csr;
    ELSE
      lv_start_date:= p_ast_date_sq;
      lv_asset_curr_code := p_trx_curr_code_sq;
    END IF;
    l_applicable := is_sub_pool_active_by_date(p_subsidy_pool_id => lx_subsidy_pool_id
                                              ,p_asset_date => lv_start_date
                                              );
    IF(l_applicable = 'N')THEN
--START: 09/29/2005 bug#4634871
      OPEN c_get_asset_number_csr(p_asset_cle_id); FETCH c_get_asset_number_csr INTO lv_asset_number;
      CLOSE c_get_asset_number_csr;

--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
      -- Override asset number for Sales Quote to display proper error message
      IF p_filter_flag = 'N' THEN
        lv_asset_number := p_dnz_asset_number;
      END IF;
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |

      OPEN c_get_subsidy_name_csr(p_subsidy_id); FETCH c_get_subsidy_name_csr INTO lv_subsidy_name;
      CLOSE c_get_subsidy_name_csr;
      OKL_API.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_ASSET_DATES_GAP,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => lv_subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => lv_asset_number);
      RAISE G_EXCEPTION_HALT_VALIDATION;
--      return l_applicable;
--END: 09/29/2005 bug#4634871
    END IF;
    -- check for conversion basis only if the currency codes are different
    IF(lx_sub_pool_curr_code <> lv_asset_curr_code)THEN
      l_applicable := is_sub_pool_conv_rate_valid(p_subsidy_pool_id => lx_subsidy_pool_id
                                                 ,p_asset_date => TRUNC(SYSDATE) -- lv_start_date, changed the date to sysdate as conversion should happen on sysdate
                                                 ,p_trx_currency_code => lv_asset_curr_code
                                                 ,x_conversion_rate => lx_conversion_rate
                                                  );
      IF(l_applicable = 'N')THEN
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'conversion basis does not exist for subsidy pool '||lx_subsidy_pool_id||' on '||trunc(sysdate)||
                                  ' between trx currency code '||lv_asset_curr_code||' and pool currency '||lx_sub_pool_curr_code
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

--START: 09/29/2005 bug#4634871
        OPEN c_get_subsidy_name_csr(p_subsidy_id); FETCH c_get_subsidy_name_csr INTO lv_subsidy_name;
        CLOSE c_get_subsidy_name_csr;
        OPEN c_get_subsidy_pool_name_csr(lx_subsidy_pool_id); FETCH c_get_subsidy_pool_name_csr INTO lv_subsidy_pool_name;
        CLOSE c_get_subsidy_pool_name_csr;
        OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
                          ,'SUBSIDY', lv_subsidy_name
                          ,'POOL_NAME',lv_subsidy_pool_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
--        return l_applicable;
--END: 09/29/2005 bug#4634871
      END IF;
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                  'conversion rate '|| lx_conversion_rate||' for pool '||lx_subsidy_pool_id||' on '||trunc(sysdate)||
                                  ' between trx currency code '||lv_asset_curr_code||' and pool currency '||lx_sub_pool_curr_code
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
    END IF;

    l_applicable := is_balance_valid_before_add(p_subsidy_pool_id => lx_subsidy_pool_id
                                              ,x_pool_balance => lx_sub_pool_balance);
    IF(l_applicable = 'N')THEN
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                  'subsidy pool balance is not valid before add '||lx_sub_pool_balance
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

--START: 09/29/2005 bug#4634871
      OPEN c_get_asset_number_csr(p_asset_cle_id); FETCH c_get_asset_number_csr INTO lv_asset_number;
      CLOSE c_get_asset_number_csr;

--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
      -- Override asset number for Sales Quote to display proper error message
      IF p_filter_flag = 'N' THEN
        lv_asset_number := p_dnz_asset_number;
      END IF;
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |

      OPEN c_get_subsidy_name_csr(p_subsidy_id); FETCH c_get_subsidy_name_csr INTO lv_subsidy_name;
      CLOSE c_get_subsidy_name_csr;
      OKL_API.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_BALANCE_INVALID,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => lv_subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => lv_asset_number);
      RAISE G_EXCEPTION_HALT_VALIDATION;
--      return l_applicable;
--END: 09/29/2005 bug#4634871
    END IF;

--START: bug#4874385 cklee 12/09/2005
    BEGIN
      okl_asset_subsidy_pvt.is_balance_valid_after_add (
                                 p_subsidy_id         => p_subsidy_id
                                ,p_currency_code      => p_trx_curr_code_sq
                                ,p_subsidy_amount     => p_subsidy_amount
                                ,p_tot_subsidy_amount => p_tot_subsidy_amount
                                ,p_dnz_asset_number   => p_dnz_asset_number
                                ,x_return_status      => lx_return_status
                                ,x_msg_count          => lx_msg_count
                                ,x_msg_data           => lx_msg_data);

      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_asset_subsidy_pvt.is_balance_valid_after_add returned with '|| lx_return_status||' x_msg_data '||lx_msg_data
                                    );
      END IF;

      IF (lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END;
--END: bug#4874385 cklee 12/09/2005

  ELSE
    return 'NA';
  END IF;
  RETURN l_applicable;
EXCEPTION
  WHEN OTHERS THEN
    l_applicable := 'N';
    RETURN(l_applicable);
END validate_subsidy_pool_applic;


FUNCTION is_sub_assoc_with_pool(p_subsidy_id IN okl_subsidies_b.id%TYPE
                                ,x_subsidy_pool_id OUT NOCOPY okl_subsidy_pools_b.id%TYPE
                                ,x_sub_pool_curr_code OUT NOCOPY okl_subsidy_pools_b.currency_code%TYPE) RETURN VARCHAR2 IS
  CURSOR c_subsidy_csr IS
  SELECT sub.subsidy_pool_id,pool.currency_code
    FROM okl_subsidies_b sub
        ,okl_subsidy_pools_b pool
   WHERE sub.id = p_subsidy_id
     AND sub.subsidy_pool_id = pool.id;
  cv_subsidy c_subsidy_csr%ROWTYPE;
  lv_return_status VARCHAR2(1);
BEGIN
  lv_return_status := 'N';
  OPEN c_subsidy_csr; FETCH c_subsidy_csr INTO cv_subsidy; CLOSE c_subsidy_csr;
  IF(cv_subsidy.subsidy_pool_id IS NOT NULL AND cv_subsidy.subsidy_pool_id <> OKL_API.G_MISS_NUM)THEN
    x_subsidy_pool_id := cv_subsidy.subsidy_pool_id; -- this is the subsidy pool id
    x_sub_pool_curr_code := cv_subsidy.currency_code; -- this is the subsidy pool currency code
    lv_return_status := 'Y';
  END IF;
  return lv_return_status;
END is_sub_assoc_with_pool;

FUNCTION is_sub_pool_active(p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                    ,x_pool_status OUT NOCOPY okl_subsidy_pools_b.decision_status_code%TYPE) RETURN VARCHAR2 IS
  CURSOR c_sub_pool_csr IS
  SELECT decision_status_code
        ,effective_from_date
        ,effective_to_date
    FROM okl_subsidy_pools_b
   WHERE id = p_subsidy_pool_id;
  cv_sub_pool c_sub_pool_csr%ROWTYPE;
  lv_return_status VARCHAR2(1);
BEGIN
  lv_return_status := 'N';
  OPEN c_sub_pool_csr; FETCH c_sub_pool_csr INTO cv_sub_pool; CLOSE c_sub_pool_csr;
  x_pool_status := cv_sub_pool.decision_status_code;
  IF((cv_sub_pool.decision_status_code  = 'ACTIVE') AND
     (TRUNC(SYSDATE) BETWEEN cv_sub_pool.effective_from_date AND NVL(cv_sub_pool.effective_to_date,okl_accounting_util.g_final_date)))THEN
    lv_return_status := 'Y';
  END IF;
  return lv_return_status;
END is_sub_pool_active;

FUNCTION is_sub_pool_active_by_date(p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                    ,p_asset_date IN okc_k_lines_b.start_date%TYPE
                                    ) RETURN VARCHAR2 IS
  CURSOR c_sub_pool_csr IS
  SELECT effective_from_date
        ,effective_to_date
    FROM okl_subsidy_pools_b
   WHERE id = p_subsidy_pool_id;
  cv_sub_pool c_sub_pool_csr%ROWTYPE;
  lv_return_status VARCHAR2(1);
  x_return_status VARCHAR2(1);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(1000);
BEGIN
  lv_return_status := 'N';
  OPEN c_sub_pool_csr; FETCH c_sub_pool_csr INTO cv_sub_pool; CLOSE c_sub_pool_csr;
  IF(TRUNC(p_asset_date) BETWEEN TRUNC(cv_sub_pool.effective_from_date)
     AND NVL(cv_sub_pool.effective_to_date,OKL_ACCOUNTING_UTIL.g_final_date))THEN
    lv_return_status := 'Y';
  END IF;
  return lv_return_status;
END is_sub_pool_active_by_date;

FUNCTION is_sub_pool_conv_rate_valid(p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                     ,p_asset_date IN okc_k_lines_b.start_date%TYPE
                                     ,p_trx_currency_code IN okc_k_headers_b.currency_code%TYPE
                                     ,x_conversion_rate OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
  CURSOR c_sub_pool_csr IS
  SELECT currency_code
         ,currency_conversion_type
    FROM okl_subsidy_pools_b
   WHERE id = p_subsidy_pool_id;
  cv_sub_pool c_sub_pool_csr%ROWTYPE;
  lv_return_status VARCHAR2(1);
  x_return_status VARCHAR2(1);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(1000);
  lv_conversion_rate NUMBER;
  l_api_version CONSTANT NUMBER DEFAULT 1.0;
BEGIN
  lv_return_status := 'N';
  OPEN c_sub_pool_csr; FETCH c_sub_pool_csr INTO cv_sub_pool; CLOSE c_sub_pool_csr;
  lv_conversion_rate := 0;
  okl_accounting_util.get_curr_con_rate(p_api_version    => l_api_version
                                ,p_init_msg_list  => OKL_API.G_TRUE
                                ,x_return_status  => x_return_status
                                ,x_msg_count      => x_msg_count
                                ,x_msg_data       => x_msg_data
                                ,p_from_curr_code => p_trx_currency_code
                                ,p_to_curr_code   => cv_sub_pool.currency_code
                                ,p_con_date       => NVL(p_asset_date,TRUNC(SYSDATE)) -- since no trx is done, conv date is sysdate per PM
                                ,p_con_type       => cv_sub_pool.currency_conversion_type
                                ,x_conv_rate      => lv_conversion_rate
                               );
  IF(x_return_status = OKL_API.G_RET_STS_SUCCESS OR lv_conversion_rate > 0)THEN
    lv_return_status := 'Y';
  END IF;
  x_conversion_rate := lv_conversion_rate;
  return lv_return_status;
END is_sub_pool_conv_rate_valid;

FUNCTION is_balance_valid_before_add (p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                    , x_pool_balance OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
  CURSOR c_sub_pool_csr IS
  SELECT NVL(total_budgets,0) total_budget_amount
        ,NVL(total_subsidy_amount,0) total_subsidy_amount
    FROM okl_subsidy_pools_b
   WHERE id = p_subsidy_pool_id;
  cv_sub_pool c_sub_pool_csr%ROWTYPE;
  lv_return_status VARCHAR2(1);
BEGIN
  lv_return_status := 'N';
  OPEN c_sub_pool_csr; FETCH c_sub_pool_csr INTO cv_sub_pool; CLOSE c_sub_pool_csr;
  x_pool_balance := (cv_sub_pool.total_budget_amount - cv_sub_pool.total_subsidy_amount);
  IF(x_pool_balance > 0)THEN
    lv_return_status := 'Y';
  END IF;
  return lv_return_status;
END is_balance_valid_before_add;

PROCEDURE is_balance_valid_after_add (p_subsidy_id okl_subsidies_b.id%TYPE,
                                      p_asset_id okc_k_lines_b.id%TYPE,
                                      p_subsidy_amount NUMBER,
                                      p_subsidy_name okl_subsidies_b.name%TYPE
                                     ,x_return_status OUT NOCOPY VARCHAR2
                                     ,x_msg_count OUT NOCOPY NUMBER
                                     ,x_msg_data OUT NOCOPY VARCHAR2
                                    ) IS

-- START: cklee 09/27/2005: 4634792
-- This cursor will accumulated the total amount of the subsidy up to now
-- for the current transaction
  CURSOR c_get_tot_sub_amt_csr(p_asset_id number, p_subsidy_pool_id number) IS
  select SUM(decode(kle_sub.SUBSIDY_OVERRIDE_AMOUNT,
                null, nvl(kle_sub.AMOUNT,0),
                kle_sub.SUBSIDY_OVERRIDE_AMOUNT))
    from okc_k_lines_b cleb_sub,
         okc_line_styles_b lseb_sub,
         okl_k_lines kle_sub,
         okl_subsidies_b sub
  where kle_sub.id = cleb_sub.id And
  cleb_sub.lse_id = lseb_sub.id And
  sub.id = kle_sub.subsidy_id And
  sub.subsidy_pool_id = p_subsidy_pool_id And
  lseb_sub.lty_code = 'SUBSIDY' And
  cleb_sub.sts_code <> 'ABANDONED' And
  cleb_sub.dnz_chr_id = (select dnz_chr_id
                           from okc_k_lines_b cleb_sub1
                         where  cleb_sub1.id = p_asset_id);
-- END: cklee 09/27/2005: 4634792

  CURSOR c_get_asset_csr IS
  SELECT start_date, currency_code
    FROM okc_k_lines_b
   WHERE id = p_asset_id;
   cv_get_asset c_get_asset_csr%ROWTYPE;

  CURSOR c_get_pool_amount_csr (p_subsidy_pool_id okl_subsidy_pools_b.id%TYPE)IS
  SELECT nvl(total_budgets,0) total_budgets
        ,nvl(total_subsidy_amount,0) total_subsidy_amount
        , subsidy_pool_name
    FROM okl_subsidy_pools_b
   WHERE id = p_subsidy_pool_id;

--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
  CURSOR c_subsidy_name_csr(p_subsidy_id number) IS
  select sub.name
    from okl_subsidies_b sub
  where sub.id = p_subsidy_id;

   l_subsidy_name okl_subsidies_b.name%TYPE;
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |

   cv_pool_amount c_get_pool_amount_csr%ROWTYPE;

   lv_return_status VARCHAR2(1);
   lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
   lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
   lx_conversion_rate NUMBER;
   lx_conversion_round_amt NUMBER;
   l_amount_in_pool_curr NUMBER;
   l_api_version CONSTANT NUMBER DEFAULT 1.0;

-- START: cklee 09/27/2005: 4634792
   lx_conversion_rate_tot NUMBER;
   lx_conversion_round_amt_tot NUMBER;
   l_amount_in_pool_curr_tot NUMBER;
   l_subsidy_amount_tot NUMBER;
-- END: cklee 09/27/2005: 4634792

BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  -- first determine if subsidy pool is applicable
  lv_return_status := is_sub_assoc_with_pool(p_subsidy_id => p_subsidy_id
                                            ,x_subsidy_pool_id => lx_subsidy_pool_id
                                            ,x_sub_pool_curr_code => lx_sub_pool_curr_code
                                            );
  IF(lv_return_status = 'Y' AND lx_subsidy_pool_id IS NOT NULL)THEN
    -- now that the subsidy is associated with the pool, check if the pool balance is valid after adding the
    -- total subsidy amount to the pool
    OPEN c_get_asset_csr; FETCH c_get_asset_csr INTO cv_get_asset;
    CLOSE c_get_asset_csr;

--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
    open c_subsidy_name_csr(p_subsidy_id);
    fetch c_subsidy_name_csr into l_subsidy_name;
    close c_subsidy_name_csr;
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |

-- START: cklee 09/27/2005: 4634792
    open c_get_tot_sub_amt_csr(p_asset_id, lx_subsidy_pool_id);
    fetch c_get_tot_sub_amt_csr into l_subsidy_amount_tot;
    close c_get_tot_sub_amt_csr;
-- END: cklee 09/27/2005: 4634792

    IF(cv_get_asset.currency_code <> lx_sub_pool_curr_code)THEN
      lx_conversion_rate := 0;
      -- obtain the conversion rate for the pool, as on the asset start date
      lv_return_status := is_sub_pool_conv_rate_valid(p_subsidy_pool_id => lx_subsidy_pool_id
                                                     ,p_asset_date => TRUNC(SYSDATE) -- since no trx is done, conv date is sysdate per PM
                                                     ,p_trx_currency_code => cv_get_asset.currency_code
                                                     ,x_conversion_rate => lx_conversion_rate
                                                     );
      IF(lv_return_status = 'Y' AND lx_conversion_rate > 0)THEN

        lx_conversion_round_amt := 0;
        l_amount_in_pool_curr := lx_conversion_rate * p_subsidy_amount;
        -- this converted amount should be rounded
        lx_conversion_round_amt := okl_accounting_util.cross_currency_round_amount(p_amount => l_amount_in_pool_curr
                                                                                  ,p_currency_code => lx_sub_pool_curr_code);
        IF(lx_conversion_round_amt <= 0)THEN
          OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                          ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
           x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          -- the amount of subsidy in pool currency should not be more than the total budget as we reduce this from the pool balance
          OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
          FETCH c_get_pool_amount_csr INTO cv_pool_amount;
          CLOSE c_get_pool_amount_csr;
          IF(cv_pool_amount.total_budgets < lx_conversion_round_amt + cv_pool_amount.total_subsidy_amount)THEN
            OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_subsidy_amount
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
             x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

-- START: cklee 09/27/2005: 4634792
-- Check accumulated subsidy amount up to now for a specific pool
        lx_conversion_round_amt_tot := 0;
        l_amount_in_pool_curr_tot := lx_conversion_rate * l_subsidy_amount_tot;
        -- this converted amount should be rounded
        lx_conversion_round_amt_tot := okl_accounting_util.cross_currency_round_amount(p_amount => l_amount_in_pool_curr_tot
                                                                                  ,p_currency_code => lx_sub_pool_curr_code);
        IF(lx_conversion_round_amt_tot <= 0)THEN
          OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                          ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
           x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          -- the amount of subsidy in pool currency should not be more than the total budget as we reduce this from the pool balance
          OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
          FETCH c_get_pool_amount_csr INTO cv_pool_amount;
          CLOSE c_get_pool_amount_csr;
          IF(cv_pool_amount.total_budgets < lx_conversion_round_amt_tot + cv_pool_amount.total_subsidy_amount)THEN
            OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_subsidy_amount
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
             x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
-- END: cklee 09/27/2005: 4634792

      ELSE
        OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                        ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
         x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; -- end of lv_return_status = 'Y' AND lx_conversion_rate > 0
--START: cklee 09/12/2005
    ELSE
      -- the amount of subsidy in pool currency should not be more than the total budget as we reduce this from the pool balance
      OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
      FETCH c_get_pool_amount_csr INTO cv_pool_amount;
      CLOSE c_get_pool_amount_csr;
      IF(cv_pool_amount.total_budgets < p_subsidy_amount + cv_pool_amount.total_subsidy_amount)THEN
        OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_subsidy_amount
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
--END: cklee 09/12/2005

-- START: cklee 09/27/2005: 4634792
-- Check accumulated subsidy amount up to now for a specific pool
      OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
      FETCH c_get_pool_amount_csr INTO cv_pool_amount;
      CLOSE c_get_pool_amount_csr;
      IF(cv_pool_amount.total_budgets < l_subsidy_amount_tot + cv_pool_amount.total_subsidy_amount)THEN
        OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_subsidy_amount
--START: 24-Oct-2005  cklee - Fixed bug#4687505                           |
--                          ,'SUBSIDY', p_subsidy_name
                          ,'SUBSIDY', l_subsidy_name
--END: 24-Oct-2005  cklee - Fixed bug#4687505                           |
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
-- END: cklee 09/27/2005: 4634792

    END IF; -- end of cv_get_asset.currency_code <> lx_sub_pool_curr_code
  END IF; -- end for lv_return_status = 'Y' AND lx_subsidy_pool_id IS NOT NULL
END is_balance_valid_after_add;

-- sjalasut added new function for subsidy pools enhancement. END


--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
  -------------------------------------------------------------------------------
  -- PROCEDURE is_balance_valid_after_add : for Sales Quote and Lease application
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_balance_valid_after_add
  -- Description     : for the context subsidy pool, this function returns Y if there exists a valid
  --                   pool balance after adding the subsidy amount to the pool in pool currency, N otherwise
  -- Parameters      : IN p_asb_rec asb_rec_type
  -- Version         : 1.0
  -- History         : 07-Dec-2005 cklee created
  -- End of comments

  PROCEDURE is_balance_valid_after_add (p_subsidy_id          IN okl_subsidies_b.id%TYPE
                                        ,p_currency_code      IN  VARCHAR2
                                        ,p_subsidy_amount     IN NUMBER
                                        ,p_tot_subsidy_amount IN  NUMBER
                                        ,p_dnz_asset_number   IN  VARCHAR2
                                        ,x_return_status      OUT NOCOPY VARCHAR2
                                        ,x_msg_count          OUT NOCOPY NUMBER
                                        ,x_msg_data           OUT NOCOPY VARCHAR2
                                      ) IS


  CURSOR c_get_pool_amount_csr (p_subsidy_pool_id okl_subsidy_pools_b.id%TYPE)IS
  SELECT nvl(total_budgets,0) total_budgets
        ,nvl(total_subsidy_amount,0) total_subsidy_amount
        , subsidy_pool_name
    FROM okl_subsidy_pools_b
   WHERE id = p_subsidy_pool_id;

  CURSOR c_subsidy_name_csr(p_subsidy_id number) IS
  select sub.name
    from okl_subsidies_b sub
  where sub.id = p_subsidy_id;

   l_subsidy_name okl_subsidies_b.name%TYPE;

   cv_pool_amount c_get_pool_amount_csr%ROWTYPE;

   lv_return_status VARCHAR2(1);
   lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
   lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
   lx_conversion_rate NUMBER;
   lx_conversion_round_amt NUMBER;
   l_amount_in_pool_curr NUMBER;
   l_api_version CONSTANT NUMBER DEFAULT 1.0;

   lx_conversion_rate_tot NUMBER;
   lx_conversion_round_amt_tot NUMBER;
   l_amount_in_pool_curr_tot NUMBER;

BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  -- first determine if subsidy pool is applicable
  lv_return_status := is_sub_assoc_with_pool(p_subsidy_id => p_subsidy_id
                                            ,x_subsidy_pool_id => lx_subsidy_pool_id
                                            ,x_sub_pool_curr_code => lx_sub_pool_curr_code
                                            );
  IF(lv_return_status = 'Y' AND lx_subsidy_pool_id IS NOT NULL)THEN
    -- now that the subsidy is associated with the pool, check if the pool balance is valid after adding the
    -- total subsidy amount to the pool

    open c_subsidy_name_csr(p_subsidy_id);
    fetch c_subsidy_name_csr into l_subsidy_name;
    close c_subsidy_name_csr;

    IF(p_currency_code <> lx_sub_pool_curr_code)THEN
      lx_conversion_rate := 0;
      -- obtain the conversion rate for the pool, as on the asset start date
      lv_return_status := is_sub_pool_conv_rate_valid(p_subsidy_pool_id => lx_subsidy_pool_id
                                                     ,p_asset_date => TRUNC(SYSDATE) -- since no trx is done, conv date is sysdate per PM
                                                     ,p_trx_currency_code => p_currency_code
                                                     ,x_conversion_rate => lx_conversion_rate
                                                     );
      IF(lv_return_status = 'Y' AND lx_conversion_rate > 0)THEN

        lx_conversion_round_amt := 0;
        l_amount_in_pool_curr := lx_conversion_rate * p_subsidy_amount;
        -- this converted amount should be rounded
        lx_conversion_round_amt := okl_accounting_util.cross_currency_round_amount(p_amount => l_amount_in_pool_curr
                                                                                  ,p_currency_code => lx_sub_pool_curr_code);
        IF(lx_conversion_round_amt <= 0)THEN
          OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
                          ,'SUBSIDY', l_subsidy_name
                          ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
           x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          -- the amount of subsidy in pool currency should not be more than the total budget as we reduce this from the pool balance
          OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
          FETCH c_get_pool_amount_csr INTO cv_pool_amount;
          CLOSE c_get_pool_amount_csr;
          IF(cv_pool_amount.total_budgets < lx_conversion_round_amt + cv_pool_amount.total_subsidy_amount)THEN
            OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_subsidy_amount
                          ,'SUBSIDY', l_subsidy_name
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
             x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

-- Check accumulated subsidy amount up to now for a specific pool
        lx_conversion_round_amt_tot := 0;
        l_amount_in_pool_curr_tot := lx_conversion_rate * p_tot_subsidy_amount;
        -- this converted amount should be rounded
        lx_conversion_round_amt_tot := okl_accounting_util.cross_currency_round_amount(p_amount => l_amount_in_pool_curr_tot
                                                                                  ,p_currency_code => lx_sub_pool_curr_code);
        IF(lx_conversion_round_amt_tot <= 0)THEN
          OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
                          ,'SUBSIDY', l_subsidy_name
                          ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
           x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          -- the amount of subsidy in pool currency should not be more than the total budget as we reduce this from the pool balance
          OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
          FETCH c_get_pool_amount_csr INTO cv_pool_amount;
          CLOSE c_get_pool_amount_csr;
          IF(cv_pool_amount.total_budgets < lx_conversion_round_amt_tot + cv_pool_amount.total_subsidy_amount)THEN
            OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_tot_subsidy_amount
                          ,'SUBSIDY', l_subsidy_name
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
             x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

      ELSE
        OKC_API.set_message(G_APP_NAME, G_NO_CONVERSION_BASIS
                          ,'SUBSIDY', l_subsidy_name
                        ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
         x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; -- end of lv_return_status = 'Y' AND lx_conversion_rate > 0

    ELSE
      -- the amount of subsidy in pool currency should not be more than the total budget as we reduce this from the pool balance
      OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
      FETCH c_get_pool_amount_csr INTO cv_pool_amount;
      CLOSE c_get_pool_amount_csr;
      IF(cv_pool_amount.total_budgets < p_subsidy_amount + cv_pool_amount.total_subsidy_amount)THEN
        OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_subsidy_amount
                          ,'SUBSIDY', l_subsidy_name
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

-- Check accumulated subsidy amount up to now for a specific pool
      OPEN c_get_pool_amount_csr (p_subsidy_pool_id =>lx_subsidy_pool_id);
      FETCH c_get_pool_amount_csr INTO cv_pool_amount;
      CLOSE c_get_pool_amount_csr;
      IF(cv_pool_amount.total_budgets < p_tot_subsidy_amount + cv_pool_amount.total_subsidy_amount)THEN
        OKC_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET,
                            'TRX_AMOUNT', p_tot_subsidy_amount
                          ,'SUBSIDY', l_subsidy_name
                            ,'POOL_NAME',cv_pool_amount.subsidy_pool_name);
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF; -- end of cv_get_asset.currency_code <> lx_sub_pool_curr_code
  END IF; -- end for lv_return_status = 'Y' AND lx_subsidy_pool_id IS NOT NULL

EXCEPTION WHEN OTHERS THEN
  x_return_status := OKL_API.G_RET_STS_ERROR;

END is_balance_valid_after_add;
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |

-----------------------------------
--1.validate subsidy id
-----------------------------------
PROCEDURE validate_subsidy_id(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_subsidy_id               IN NUMBER) IS
    cursor l_sub_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b subb
    where  subb.id = p_subsidy_id;

    l_exists varchar2(1) default 'N';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_subsidy_id = OKL_API.G_MISS_NUM OR
        p_subsidy_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy Name');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        --check foreign key validation
        l_exists := 'N';
        open l_sub_csr(p_subsidy_id => p_subsidy_id);
        fetch l_sub_csr into l_exists;
        If l_sub_csr%NOTFOUND then
            null;
        End If;
        Close l_sub_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Name');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_subsidy_id;
-----------------------------------
--2.validate subsidy_cle_id
-----------------------------------
PROCEDURE validate_subsidy_cle_id(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN NUMBER) IS
    cursor l_subcle_csr (p_subsidy_cle_id in number) is
    select 'Y'
    from   okc_k_lines_b     cleb,
           okc_line_styles_b lseb
    where  cleb.id  =  p_subsidy_cle_id
    and    lseb.id  = cleb.lse_id
    and    lseb.lty_code = 'SUBSIDY'
    and    cleb.sts_code <> 'ABANDONED';

    l_exists varchar2(1) default 'N';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_subsidy_cle_id <> OKL_API.G_MISS_NUM AND
        p_subsidy_cle_id IS NOT NULL)
    THEN
        --check foreign key validation
        l_exists := 'N';
        open l_subcle_csr(p_subsidy_cle_id => p_subsidy_cle_id);
        fetch l_subcle_csr into l_exists;
        If l_subcle_csr%NOTFOUND then
            null;
        End If;
        Close l_subcle_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy line identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_subsidy_cle_id;
-----------------------------------
--3.validate dnz_chr_id
-----------------------------------
PROCEDURE validate_dnz_chr_id(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_dnz_chr_id       IN NUMBER) IS

    cursor l_chr_csr (p_dnz_chr_id in number) is
    select 'Y'
    from   okc_k_headers_b chrb
    where  chrb.id  =  p_dnz_chr_id;
    --as per clarification by srawlings
    --and    chrb.sts_code in ('NEW','COMPLETE','PASSED','INCOMPLETE','TERMINATED','APPROVED');

    l_exists varchar2(1) default 'N';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_dnz_chr_id = OKL_API.G_MISS_NUM OR
        p_dnz_chr_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract Identifier');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        --check foreign key validation
        l_exists := 'N';
        open l_chr_csr(p_dnz_chr_id => p_dnz_chr_id);
        fetch l_chr_csr into l_exists;
        If l_chr_csr%NOTFOUND then
            null;
        End If;
        Close l_chr_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Contract Identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_dnz_chr_id;
-----------------------------------
--4.validate asset_Cle_id
-----------------------------------
PROCEDURE validate_asset_cle_id(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_asset_cle_id       IN NUMBER) IS

    cursor l_cle_csr (p_asset_cle_id in number) is
    select 'Y'
    from   okc_k_lines_b cleb
    where  cleb.id  =  p_asset_cle_id;
    --as per clarification by srawlings
    --and    cleb.sts_code in ('NEW','COMPLETE','PASSED','INCOMPLETE','TERMINATED','APPROVED');

    l_exists varchar2(1) default 'N';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_asset_cle_id = OKL_API.G_MISS_NUM OR
        p_asset_cle_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Asset line identifier');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        --check foreign key validation
        l_exists := 'N';
        open l_cle_csr(p_asset_cle_id => p_asset_cle_id);
        fetch l_cle_csr into l_exists;
        If l_cle_csr%NOTFOUND then
            null;
        End If;
        Close l_cle_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Asset line identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_asset_cle_id;
-----------------------------------
--5.validate vendor_id
-----------------------------------
PROCEDURE validate_vendor_id(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_vendor_id        IN NUMBER) IS

    cursor l_vendor_csr (p_vendor_id in number) is
    select 'Y'
    from   po_vendors pov
    where  pov.vendor_id  =  p_vendor_id;

    l_exists varchar2(1) default 'N';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_vendor_id = OKL_API.G_MISS_NUM OR
        p_vendor_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy provider party');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        --check foreign key validation
        l_exists := 'N';
        open l_vendor_csr(p_vendor_id => p_vendor_id);
        fetch l_vendor_csr into l_exists;
        If l_vendor_csr%NOTFOUND then
            null;
        End If;
        Close l_vendor_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy provider party');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_vendor_id;
-----------------------------------
--6.validate record
-----------------------------------
PROCEDURE validate_record(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_asb_rec          IN asb_rec_type) IS

    --to check fin asset line id and chr id combo is valid
    cursor l_chrcle_csr (p_chr_id         in number,
                         p_asset_cle_id   in number
                         ) is
    select 'Y'
    from   okc_k_lines_b cleb
    where  cleb.id         =  p_asset_cle_id
    and    cleb.dnz_chr_id =  p_chr_id;

/* cklee check from validate_record_after()
    --to check subsidy line id is valid for fin asset line
    cursor l_subcle_csr (p_subsidy_cle_id in number,
                         p_asset_cle_id   in number
                         ) is
    select 'Y'
    from   okc_k_lines_b cleb
    where  cleb.id         =  p_subsidy_cle_id
    and    cleb.cle_id     =  p_asset_cle_id;

    --tro check cpl_id is valid for subsidy line
    cursor l_cplb_csr (p_subsidy_cle_id in number,
                       p_cpl_id         in number
                         ) is
    select 'Y'
    from   okc_k_party_roles_b cplb
    where  cplb.id         =  p_cpl_id
    and    cplb.cle_id     =  p_subsidy_cle_id
    and    cplb.rle_code   =  'OKL_VENDOR';


    --to check that vendor is vendor on contract header
    --required only for lease.not for quote
    cursor l_vendor_csr (p_chr_id    in number,
                         p_vendor_id in number) is
    select 'Y'
    from   okc_k_party_roles_b cplb
    where  cplb.chr_id            = p_chr_id
    and    cplb.dnz_chr_id        = p_chr_id
    and    cplb.rle_code          =  'OKL_VENDOR'
    and    cplb.object1_id1       = to_char(p_vendor_id)
    and    cplb.object1_id2       = '#'
    and    cplb.jtot_object1_code = 'OKC_VENDOR';

    --to check if same subsidy is already attached to the asset
    cursor l_subsidy_exists_csr(p_asset_cle_id   in number,
                                p_subsidy_id     in number,
                                p_subsidy_cle_id in number) is
    select 'Y',
           clet.name          subsidy_name,
           clet_asst.name     asset_number
    from   okl_k_lines        kle,
           okc_k_lines_tl     clet,
           okc_k_lines_b      cleb,
           okc_line_styles_b  lseb,
           okc_k_lines_tl     clet_asst
    where  kle.id             = cleb.id
    and    kle.subsidy_id     = p_subsidy_id
    and    clet.id            = cleb.id
    and    clet.language      = userenv('LANG')
    and    cleb.cle_id        = clet_asst.id
    and    clet_asst.id       = p_Asset_cle_id
    and    clet_asst.language = userenv('LANG')
    and    lseb.id            = cleb.lse_id
    and    lseb.lty_code      = 'SUBSIDY'
    and    cleb.sts_code      <> 'ABANDOANED'
    and    cleb.id            <> nvl(p_subsidy_cle_id,-999);

    --cursor to check if subsidy being attached is exclusive
    --and there are other subsidies attached to the contract
    cursor l_exclusive_csr(p_asset_cle_id   in number,
                           p_subsidy_id     in number,
                           p_subsidy_cle_id in number) is
    Select 'Y',
           subb.name
    from   okl_subsidies_b  subb
    where  subb.id                    = p_subsidy_id
    and    nvl(subb.exclusive_yn,'N') = 'Y'
    and    exists (select '1'
                   from   okc_k_lines_b       sub_cleb,
                          okc_line_styles_b   sub_lseb
                   where  sub_cleb.cle_id     = p_asset_cle_id
                   and    sub_cleb.sts_code   <> 'ABANDONED'
                   and    sub_cleb.id         <>  nvl(p_subsidy_cle_id,-999)
                   and    sub_lseb.id         = sub_cleb.lse_id
                   and    sub_lseb.lty_code   = 'SUBSIDY'
                   );
*/

    l_exists         varchar2(1) default 'N';

--    l_subsidy_name   okc_k_lines_tl.name%TYPE;
--    l_asset_number   okc_k_lines_tl.name%TYPE;


BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --check foreign key validation
    l_exists := 'N';
    open l_chrcle_csr(p_chr_id       => p_asb_rec.dnz_chr_id,
                       p_asset_cle_id => p_asb_rec.asset_cle_id);
    fetch l_chrcle_csr into l_exists;
    If l_chrcle_csr%NOTFOUND then
        null;
    End If;
    Close l_chrcle_csr;
    If l_exists = 'N' then
       OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Contract identifier');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

/* cklee check from validate_record_after()
    If p_asb_rec.subsidy_cle_id is not null and p_asb_rec.subsidy_cle_id <> OKL_API.G_MISS_NUM then
        l_exists := 'N';
        open l_subcle_csr(p_subsidy_cle_id => p_asb_rec.subsidy_cle_id,
                          p_asset_cle_id   => p_asb_rec.asset_cle_id);
        fetch l_subcle_csr into l_exists;
        If l_subcle_csr%NOTFOUND then
            null;
        End If;
        Close l_subcle_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy line identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    End If;

    If p_asb_rec.cpl_id is not null and p_asb_rec.cpl_id <> OKL_API.G_MISS_NUM then
        l_exists := 'N';
        open l_cplb_csr(p_subsidy_cle_id => p_asb_rec.subsidy_cle_id,
                        p_cpl_id         => p_asb_rec.cpl_id);
        fetch l_cplb_csr into l_exists;
        If l_cplb_csr%NOTFOUND then
            null;
        End If;
        Close l_cplb_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy party identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    End If;

    --check if subsidy has not been already deined for this asset
    l_exists := 'N';
    Open l_subsidy_exists_csr (p_asset_cle_id   => p_asb_rec.asset_cle_id,
                           p_subsidy_id     => p_asb_rec.subsidy_id,
                           p_subsidy_cle_id => p_asb_rec.subsidy_cle_id);
    Fetch l_subsidy_exists_csr into l_exists, l_subsidy_name, l_asset_number;
    If    l_subsidy_exists_csr%NOTFOUND then
        Null;
    End If;
    Close l_subsidy_exists_csr;

    If l_exists = 'Y' then
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SUBSIDY_ALREADY_EXISTS,
                            p_token1       => G_SUBSIDY_NAME_TOKEN,
                            p_token1_value => l_subsidy_name,
                            p_token2       => G_ASSET_NUMBER_TOKEN,
                            p_token2_value  => l_asset_number);
        x_return_status := OKL_API.G_RET_STS_ERROR; -- cklee
        RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

    --cursor to check if exclusive subsidy has any other subsidy atched to the
    -- asset
    l_exists := 'N';
    Open l_exclusive_csr (p_asset_cle_id   => p_asb_rec.asset_cle_id,
                               p_subsidy_id     => p_asb_rec.subsidy_id,
                               p_subsidy_cle_id => p_asb_rec.subsidy_cle_id);
    Fetch  l_exclusive_csr into l_exists, l_subsidy_name;
    If   l_exclusive_csr%NOTFOUND then
        Null;
    End If;
    Close l_exclusive_csr;

    If l_exists = 'Y' then
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SUBSIDY_EXCLUSIVE,
                            p_token1       => G_SUBSIDY_NAME_TOKEN,
                            p_token1_value => l_subsidy_name
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;
*/

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_record;

-- start cklee
-----------------------------------
--6.1 validate record_after
-----------------------------------
PROCEDURE validate_record_after(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_asb_rec          IN asb_rec_type) IS

    --to check subsidy line id is valid for fin asset line
    cursor l_subcle_csr (p_subsidy_cle_id in number,
                         p_asset_cle_id   in number
                         ) is
    select 'Y'
    from   okc_k_lines_b cleb
    where  cleb.id         =  p_subsidy_cle_id
    and    cleb.cle_id     =  p_asset_cle_id;

    --to check cpl_id is valid for subsidy line
    cursor l_cplb_csr (p_subsidy_cle_id in number,
                       p_cpl_id         in number
                         ) is
    select 'Y'
    from   okc_k_party_roles_b cplb
    where  cplb.id         =  p_cpl_id
    and    cplb.cle_id     =  p_subsidy_cle_id
    and    cplb.rle_code   =  'OKL_VENDOR';

    --to check if same subsidy is already attached to the asset
    cursor l_subsidy_exists_csr(p_asset_cle_id   in number,
                                p_subsidy_id     in number,
                                p_subsidy_cle_id in number) is
    select 'Y',
           clet.name          subsidy_name,
           clet_asst.name     asset_number
    from   okl_k_lines        kle,
           okc_k_lines_tl     clet,
           okc_k_lines_b      cleb,
           okc_line_styles_b  lseb,
           okc_k_lines_tl     clet_asst
    where  kle.id             = cleb.id
    and    kle.subsidy_id     = p_subsidy_id
    and    clet.id            = cleb.id
    and    clet.language      = userenv('LANG')
    and    cleb.cle_id        = clet_asst.id
    and    clet_asst.id       = p_Asset_cle_id
    and    clet_asst.language = userenv('LANG')
    and    lseb.id            = cleb.lse_id
    and    lseb.lty_code      = 'SUBSIDY'
    and    cleb.sts_code      <> 'ABANDOANED'
    and    cleb.id            <> nvl(p_subsidy_cle_id,-999)
-- cklee 03/15/2004
    group by clet.name, clet_asst.name
    having count(1) > 1;
-- cklee 03/15/2004

    --cursor to check if subsidy being attached is exclusive
    --and there are other subsidies attached to the contract
/* cklee
    cursor l_exclusive_csr(p_asset_cle_id   in number,
                           p_subsidy_id     in number,
                           p_subsidy_cle_id in number) is
    Select 'Y',
           subb.name
    from   okl_subsidies_b  subb
    where  subb.id                    = p_subsidy_id
    and    nvl(subb.exclusive_yn,'N') = 'Y'
    and    exists (select '1'
                   from   okc_k_lines_b       sub_cleb,
                          okc_line_styles_b   sub_lseb
                   where  sub_cleb.cle_id     = p_asset_cle_id
                   and    sub_cleb.sts_code   <> 'ABANDONED'
                   and    sub_cleb.id         <>  nvl(p_subsidy_cle_id,-999)
                   and    sub_lseb.id         = sub_cleb.lse_id
                   and    sub_lseb.lty_code   = 'SUBSIDY'
                   );
*/
    --cursor to check if subsidy attached is exclusive
    cursor l_exclusive_csr(p_asset_cle_id   in number) is
    Select 'Y',
           subb.name
    from   okl_subsidies_b     subb,
           okc_k_lines_b       sub_cleb,
           okc_line_styles_b   sub_lseb,
           okl_k_lines         sub_kleb
    where  sub_cleb.cle_id     = p_asset_cle_id
    and    sub_cleb.sts_code   <> 'ABANDONED'
    and    sub_lseb.id         = sub_cleb.lse_id
    and    sub_lseb.lty_code   = 'SUBSIDY'
    and    sub_kleb.id         = sub_cleb.id
    and    subb.id             = sub_kleb.subsidy_id
    and    subb.exclusive_yn   = 'Y';

    -- cursor to check if multiple rows exist for
    -- a p_asset_cle_id ('FREE_FORM1')
    cursor l_exclusive_csr2(p_asset_cle_id   in number) is
    select count(1)
    from   okl_subsidies_b     subb,
           okc_k_lines_b       sub_cleb,
           okc_line_styles_b   sub_lseb,
           okl_k_lines         sub_kleb
    where  sub_cleb.cle_id     = p_asset_cle_id
    and    sub_cleb.sts_code   <> 'ABANDONED'
    and    sub_lseb.id         = sub_cleb.lse_id
    and    sub_lseb.lty_code   = 'SUBSIDY'
    and    sub_kleb.id         = sub_cleb.id
    and    subb.id             = sub_kleb.subsidy_id;

    l_exists          varchar2(1) default 'N';
    l_count           number := 0;

    l_subsidy_name   okc_k_lines_tl.name%TYPE;
    l_asset_number   okc_k_lines_tl.name%TYPE;


BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    If p_asb_rec.subsidy_cle_id is not null and p_asb_rec.subsidy_cle_id <> OKL_API.G_MISS_NUM then
        l_exists := 'N';
        open l_subcle_csr(p_subsidy_cle_id => p_asb_rec.subsidy_cle_id,
                          p_asset_cle_id   => p_asb_rec.asset_cle_id);
        fetch l_subcle_csr into l_exists;
        If l_subcle_csr%NOTFOUND then
            null;
        End If;
        Close l_subcle_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy line identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    End If;

    If p_asb_rec.cpl_id is not null and p_asb_rec.cpl_id <> OKL_API.G_MISS_NUM then
        l_exists := 'N';
        open l_cplb_csr(p_subsidy_cle_id => p_asb_rec.subsidy_cle_id,
                        p_cpl_id         => p_asb_rec.cpl_id);
        fetch l_cplb_csr into l_exists;
        If l_cplb_csr%NOTFOUND then
            null;
        End If;
        Close l_cplb_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy party identifier');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    End If;

    --check if subsidy has not been already deined for this asset
    l_exists := 'N';
    Open l_subsidy_exists_csr (p_asset_cle_id   => p_asb_rec.asset_cle_id,
                           p_subsidy_id     => p_asb_rec.subsidy_id,
                           p_subsidy_cle_id => p_asb_rec.subsidy_cle_id);
    Fetch l_subsidy_exists_csr into l_exists, l_subsidy_name, l_asset_number;

    If    l_subsidy_exists_csr%NOTFOUND then
        Null;
    End If;
    Close l_subsidy_exists_csr;

    If l_exists = 'Y' then
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SUBSIDY_ALREADY_EXISTS,
                            p_token1       => G_SUBSIDY_NAME_TOKEN,
                            p_token1_value => l_subsidy_name,
                            p_token2       => G_ASSET_NUMBER_TOKEN,
                            p_token2_value  => l_asset_number);
         x_return_status := OKL_API.G_RET_STS_ERROR; -- cklee
         RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

    --cursor to check if exclusive subsidy has any other subsidy atched to the
    -- asset
    l_exists := 'N';
/* cklee
    Open l_exclusive_csr (p_asset_cle_id   => p_asb_rec.asset_cle_id,
                               p_subsidy_id     => p_asb_rec.subsidy_id,
                               p_subsidy_cle_id => p_asb_rec.subsidy_cle_id);
*/
    Open l_exclusive_csr (p_asset_cle_id   => p_asb_rec.asset_cle_id);
    Fetch  l_exclusive_csr into l_exists, l_subsidy_name;

    If l_exclusive_csr%NOTFOUND then
        Null;
    End If;
    Close l_exclusive_csr;

    Open l_exclusive_csr2 (p_asset_cle_id   => p_asb_rec.asset_cle_id);
    Fetch  l_exclusive_csr2 into l_count;

    If l_exclusive_csr2%NOTFOUND then
        Null;
    End If;
    Close l_exclusive_csr2;

    If (l_exists = 'Y' and l_count > 1) then
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SUBSIDY_EXCLUSIVE,
                            p_token1       => G_SUBSIDY_NAME_TOKEN,
                            p_token1_value => l_subsidy_name
                            );
        x_return_status := OKL_API.G_RET_STS_ERROR; -- cklee
        RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END validate_record_after;
-- end cklee
--------------------------------------------------------------------------------
--Name       : validate_asset_subsidy
--Creation   : 20-Aug-2003
--Purpose    : To validate asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE validate_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_rec                      IN  asb_rec_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'VALIDATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;

    l_asb_rec                asb_rec_type;
    l_highest_return_status  VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;

    l_applicable             VARCHAR2(1);

    cursor l_clet_csr(p_cle_id in number) is
    select clet.name
    from   okc_k_lines_tl clet
    where  clet.id = p_cle_id
    and    clet.language = userenv('LANG');

    l_asset_number okc_k_lines_tl.name%TYPE;

    cursor l_sub_csr(p_subsidy_id in number) is
    select subb.name
    from   okl_subsidies_b subb
    where  id = p_subsidy_id;

    l_subsidy_name okl_subsidies_b.name%TYPE;

begin
-----
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_asb_rec := p_asb_rec;
    -----------------------------------------------
    --call validation routines
    -----------------------------------------------

    l_highest_return_status := x_return_status;
    ---------------------------------------
    --1.validate subsidy_id
    ---------------------------------------
/* cklee 1/21/04 call from validate_asset_subsidy_after()
    validate_subsidy_id(x_return_status,l_asb_rec.subsidy_id);
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS then
        l_highest_return_status := x_return_status;
    End If;
*/
    ---------------------------------------
    --2.validate subsidy_cle_id
    ---------------------------------------
    validate_subsidy_cle_id(x_return_status,l_asb_rec.subsidy_cle_id);
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS then
        l_highest_return_status := x_return_status;
    End If;
    ---------------------------------------
    --3.validate dnz_chr_id
    ---------------------------------------
    validate_dnz_chr_id(x_return_status,l_asb_rec.dnz_chr_id);
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS then
        l_highest_return_status := x_return_status;
    End If;
    ---------------------------------------
    --4.validate asset_cle_id
    ---------------------------------------
    validate_asset_cle_id(x_return_status,l_asb_rec.asset_cle_id);
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS then
        l_highest_return_status := x_return_status;
    End If;
    ---------------------------------------
    --5.validate vendor_id
    ---------------------------------------
    validate_vendor_id(x_return_status,l_asb_rec.vendor_id);
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS then
        l_highest_return_status := x_return_status;
    End If;

    x_return_status := l_highest_return_status;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------
    --5.validate record
    ---------------------------------------
    validate_record(x_return_status,l_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   ---------------------------------------
   --6.validate subsidy applicability
   ---------------------------------------
   l_applicable := validate_subsidy_applicability(p_subsidy_id   => l_asb_rec.subsidy_id,
                                                  p_asset_cle_id => l_asb_rec.asset_cle_id);
   If l_applicable = 'N' then

       open l_clet_csr(p_cle_id => l_asb_rec.asset_cle_id);
       fetch l_clet_csr into l_asset_number;
       if l_clet_csr%NOTFOUND then
           null;
       end if;
       close l_clet_csr;

       open l_sub_csr(p_subsidy_id => l_asb_rec.subsidy_id);
       fetch l_sub_csr into l_subsidy_name;
       if l_sub_csr%NOTFOUND then
           null;
       end if;
       close l_sub_csr;

       --raise error
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_SUBSIDY_NOT_APPLICABLE,
                           p_token1       => G_SUBSIDY_TOKEN,
                           p_token1_value => l_subsidy_name,
                           p_token2       => G_ASSET_NUMBER_TOKEN,
                           p_token2_value => l_asset_number
                          );
       x_return_status := OKL_API.G_RET_STS_ERROR;

       RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
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
End validate_asset_subsidy;
-- start : cklee
--------------------------------------------------------------------------------
--Name       : validate_asset_subsidy_after
--Creation   : 22-Jan-2004
--Purpose    : To validate asset subsidy record after record has been created
--             in this transaction
--------------------------------------------------------------------------------
PROCEDURE validate_asset_subsidy_after(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_rec                      IN  asb_rec_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'VALIDATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;

    l_asb_rec                asb_rec_type;
    l_highest_return_status  VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;

begin
-----
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_asb_rec := p_asb_rec;
    -----------------------------------------------
    --call validation routines
    -----------------------------------------------

    l_highest_return_status := x_return_status;
/*comment out by cklee 03/15/2004
    ---------------------------------------
    --2.validate subsidy_cle_id
    ---------------------------------------
    validate_subsidy_cle_id(x_return_status,l_asb_rec.subsidy_cle_id);
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS then
        l_highest_return_status := x_return_status;
    End If;

    x_return_status := l_highest_return_status;
*/
    ---------------------------------------
    --5.validate record
    ---------------------------------------
    validate_record_after(x_return_status,l_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

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
End validate_asset_subsidy_after;

-- end : cklee
--------------------------------------------------------------------------------
--Name       : create_asset_subsidy
--Creation   : 20-Aug-2003
--Purpose    : To create asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE create_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_rec                      IN  asb_rec_type,
    x_asb_rec                      OUT NOCOPY  asb_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CREATE_ASSET_SUBSIDY';
l_api_version          CONSTANT NUMBER := 1.0;

l_asb_rec       asb_rec_type;
lx_calc_asb_rec asb_rec_type;

l_clev_rec      okl_okc_migration_pvt.clev_rec_type;
l_klev_rec      okl_contract_pub.klev_rec_type;
l_cplv_rec      okl_okc_migration_pvt.cplv_rec_type;

lx_clev_rec      okl_okc_migration_pvt.clev_rec_type;
lx_klev_rec      okl_contract_pub.klev_rec_type;
lx_cplv_rec      okl_okc_migration_pvt.cplv_rec_type;

lx_def_clev_rec      okl_okc_migration_pvt.clev_rec_type;
lx_def_klev_rec      okl_contract_pub.klev_rec_type;
lx_def_cplv_rec      okl_okc_migration_pvt.cplv_rec_type;

--cursor to get vendor name
cursor l_vendor_csr(p_vendor_id in number) is
select pov.vendor_name
from   po_vendors pov
where  vendor_id = p_vendor_id;

l_vendor_name po_vendors.vendor_name%TYPE;

--Bug# 4558486
l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
lx_kplv_rec     okl_k_party_roles_pvt.kplv_rec_type;

Begin
----
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_asb_rec := p_asb_rec;

    ---------------------------------------------------------
    --call local procedure to fill up the defaults
    ----------------------------------------------------------
    Initialize_records(x_return_status => x_return_status,
                      p_asb_rec       => l_asb_rec,
                      x_clev_rec      => lx_def_clev_rec,
                      x_klev_rec      => lx_def_klev_rec,
                      x_cplv_rec      => lx_def_cplv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_clev_rec := lx_def_clev_rec;
    l_klev_rec := lx_def_klev_rec;
    l_cplv_rec := lx_def_cplv_rec;

    ----------------------------------------------------------------------
    --fill up the defaults for validation
    ----------------------------------------------------------------------
    l_asb_rec.subsidy_id              :=  l_klev_rec.subsidy_id;
    l_asb_rec.name                    :=  l_clev_rec.name;
    l_asb_rec.description             :=  l_clev_rec.item_description;
    l_asb_rec.amount                  :=  l_klev_rec.amount;
    l_asb_rec.subsidy_override_amount :=  l_klev_rec.subsidy_override_amount;
    l_asb_rec.dnz_chr_id              :=  l_clev_rec.dnz_chr_id;
    l_asb_rec.asset_cle_id            :=  l_clev_rec.cle_id;
    If (l_cplv_rec.object1_id1 is not null) and (l_cplv_rec.object1_id1 <> OKL_API.G_MISS_CHAR) then
        l_asb_rec.vendor_id               :=  to_number(l_cplv_rec.object1_id1);
    End If;

    --Bug# 4959361
    OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => l_asb_rec.asset_cle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4959361

    ----------------------------------------------------
    --validate the subsidy asset record
    ----------------------------------------------------
    validate_asset_subsidy(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------------------------
    --call complex API to create line instance
    ----------------------------------------------------------
    --dbms_output.put_line(to_char(l_klev_rec.amount));

    OKL_CONTRACT_PUB.create_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => lx_clev_rec,
      x_klev_rec      => lx_klev_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/* comment out by cklee 03/15/2004: move to l_asb_tbl level
-- start cklee 1/22/04
    ----------------------------------------------------
    --validate the subsidy asset record after record has
    -- been created in this transaction
    ----------------------------------------------------
    -- subsidy line ID
    l_asb_rec.subsidy_cle_id := lx_clev_rec.id;

    validate_asset_subsidy_after(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- end cklee 1/22/04
*/

    ---------------------------------------------------------
    --call complex API to create party role instance
    ----------------------------------------------------------
    If (l_cplv_rec.object1_id1 is not null) and
       (l_cplv_rec.object1_id1 <> OKL_API.G_MISS_CHAR) then
        l_cplv_rec.cle_id := lx_clev_rec.id;

      --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
      --              to create records in tables
      --              okc_k_party_roles_b and okl_k_party_roles
      /*
         okl_okc_migration_pvt.create_k_party_role(
	         p_api_version	    => p_api_version,
	         p_init_msg_list	=> p_init_msg_list,
	         x_return_status 	=> x_return_status,
	         x_msg_count     	=> x_msg_count,
	         x_msg_data      	=> x_msg_data,
	         p_cplv_rec		    => l_cplv_rec,
	         x_cplv_rec		    => lx_cplv_rec);
      */
         okl_k_party_roles_pvt.create_k_party_role(
	         p_api_version	    => p_api_version,
	         p_init_msg_list    => p_init_msg_list,
	         x_return_status    => x_return_status,
	         x_msg_count        => x_msg_count,
	         x_msg_data         => x_msg_data,
	         p_cplv_rec         => l_cplv_rec,
	         x_cplv_rec         => lx_cplv_rec,
               p_kplv_rec         => l_kplv_rec,
	         x_kplv_rec         => lx_kplv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
     End If;

     --reinitialize asset subsidy record with final values for output
     l_asb_rec.subsidy_id              :=  lx_klev_rec.subsidy_id;
     l_asb_rec.subsidy_cle_id          :=  lx_clev_rec.id;
     l_asb_rec.name                    :=  lx_clev_rec.name;
     l_asb_rec.description             :=  lx_clev_rec.item_description;
     l_asb_rec.amount                  :=  lx_klev_rec.amount;
     l_asb_rec.subsidy_override_amount :=  lx_klev_rec.subsidy_override_amount;
     l_asb_rec.dnz_chr_id              :=  lx_clev_rec.dnz_chr_id;
     l_asb_rec.asset_cle_id            :=  lx_clev_rec.cle_id;

     IF lx_cplv_rec.object1_id1 is not NULL AND lx_cplv_rec.object1_id1 <> OKL_API.G_MISS_NUM then
         l_asb_rec.cpl_id              :=  lx_cplv_rec.id;
         l_asb_rec.vendor_id := to_number(lx_cplv_rec.object1_id1);
         --get vendor name
         open l_vendor_csr(p_vendor_id => l_asb_rec.vendor_id);
         fetch l_vendor_csr into l_vendor_name;
         If l_vendor_csr%NOTFOUND then
             null;
         else
             l_asb_rec.vendor_name := l_vendor_name;
         end if;
         close l_vendor_csr;
     End If;


     ---------------------------------------------------------
     --Call API to calculate asset subsidy amounts
     ----------------------------------------------------------
     calculate_asset_subsidy(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_rec,
            x_asb_rec        => lx_calc_asb_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --dbms_output.put_line(to_char(lx_calc_asb_rec.amount));
     l_asb_rec := lx_calc_asb_rec;
     --dbms_output.put_line(to_char(l_asb_rec.amount));

     ---------------------------------------------------------
     --Call API to recalculate asset oec and cap amounts
     ----------------------------------------------------------
     --included in calculate asset subsidy
     ------------------------------------------------------------
     --assign values to out record
     ------------------------------------------------------------
     x_asb_rec                :=  l_asb_rec;

     /*
      * sjalasut: aug 25, 04 added code to enable business event. BEGIN
      */
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(lx_clev_rec.dnz_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => lx_clev_rec.dnz_chr_id,
                            p_asset_id            => lx_clev_rec.cle_id,
                            p_subsidy_id          => x_asb_rec.subsidy_id,
                            p_event_name          => G_WF_EVT_ASSET_SUBSIDY_CRTD,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data
                           );
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     /*
      * sjalasut: aug 25, 04 added code to enable business event. END
      */


    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_vendor_csr%ISOPEN then
        close l_vendor_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_vendor_csr%ISOPEN then
        close l_vendor_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_vendor_csr%ISOPEN then
        close l_vendor_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End Create_asset_subsidy;
--------------------------------------------------------------------------------
--Name       : create_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To create asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE create_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_tbl                      IN  asb_tbl_type,
    x_asb_tbl                      OUT NOCOPY  asb_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'CREATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_overall_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                      NUMBER := 0;

    l_asb_tbl  asb_tbl_type;
Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_asb_tbl := p_asb_tbl;
    If l_asb_tbl.COUNT > 0 then
        i := l_asb_tbl.FIRST;
        LOOP
            create_asset_subsidy(
                 p_api_version        => p_api_version,
                 p_init_msg_list      => p_init_msg_list,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_asb_rec            => l_asb_tbl(i),
                 x_asb_rec            => x_asb_tbl(i));
/***-- start cklee 11/15/04
	             -- store the highest degree of error
		         If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			             l_overall_status := x_return_status;
		             End If;
		         End If;
-- end cklee 11/15/04
*/
-- start cklee 11/15/04
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
-- end cklee 11/15/04

            EXIT WHEN (i = l_asb_tbl.LAST);
            i := l_asb_tbl.NEXT(i);
        END LOOP;
        -- return overall status
-- start cklee 11/15/04
--cklee	    x_return_status := l_overall_status;
-- end cklee 11/15/04

-- start cklee 03/15/04
        ----------------------------------------------------
        --validate the subsidy asset record after records have
        -- been created in this transaction
        ----------------------------------------------------
        validate_asset_subsidy_after(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_tbl(l_asb_tbl.FIRST));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
-- end cklee 03/15/04

    End If;
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
End Create_asset_subsidy;
--------------------------------------------------------------------------------
--Name       : update_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To update asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE update_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_rec                      IN  asb_rec_type,
    x_asb_rec                      OUT NOCOPY  asb_rec_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'UPDATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;

    l_asb_rec     asb_rec_type;
    l_db_asb_rec  asb_rec_type;
    lx_calc_asb_rec  asb_rec_type;


    l_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec    okl_contract_pub.klev_rec_type;
    l_cplv_rec    okl_okc_migration_pvt.cplv_rec_type;

    lx_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec    okl_contract_pub.klev_rec_type;
    lx_cplv_rec    okl_okc_migration_pvt.cplv_rec_type;

    lx_def_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    lx_def_klev_rec    okl_contract_pub.klev_rec_type;
    lx_def_cplv_rec    okl_okc_migration_pvt.cplv_rec_type;

    l_row_notfound     BOOLEAN := TRUE;

    --cursor to get vendor name
    cursor l_vendor_csr(p_vendor_id in number) is
    select pov.vendor_name
    from   po_vendors pov
    where  vendor_id = p_vendor_id;

    l_vendor_name po_vendors.vendor_name%TYPE;

    --cursor to fetch party refund details record
    cursor l_ppyd_csr (p_cpl_id in number) is
    select ppyd.id
    from   okl_party_payment_dtls ppyd
    where  ppyd.cpl_id = p_cpl_id;

    l_ppyd_id number default null;

    l_ppydv_rec      OKL_PYD_PVT.ppydv_rec_type;

    l_rbk_cpy       varchar2(1) default 'N';

    --Bug# 4558486
    l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec     okl_k_party_roles_pvt.kplv_rec_type;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --Bug# 4959361
    OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => p_asb_rec.subsidy_cle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4959361

    l_asb_rec    := p_asb_rec;
    l_db_asb_rec := get_rec(l_asb_rec,l_row_notfound);

    IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -------------------------------------------------------------------
    --Begin delete the party payment details if vendor changes
    -------------------------------------------------------------------
    If nvl(l_asb_rec.vendor_id,-1) <> OKL_API.G_MISS_NUM and
       nvl(l_asb_rec.vendor_id,-1) <> nvl(l_db_asb_rec.vendor_id,-1) Then

        ----------------------------------------
        --check if it is a rebook copy contract
        --if yes then do not allow change in vendor
        -------------------------------------------
        l_rbk_cpy := is_rebook_copy(p_chr_id => l_db_asb_rec.dnz_chr_id);
        If l_rbk_cpy = 'Y' then
            If l_asb_rec.vendor_id <> l_db_asb_rec.vendor_id then
                okl_api.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_PARTY_UPDATE_INVALID,
                                    p_token1       => G_SUBSIDY_TOKEN,
                                    p_token1_value => l_db_asb_rec.name
                                   );
                x_return_status := OKL_API.G_RET_STS_ERROR;
                Raise OKL_API.G_EXCEPTION_ERROR;
            End If;
        End If;
        -----------------------------------------
        --End of rebook check
        -----------------------------------------

        If l_db_asb_rec.cpl_id is not Null and
           l_db_asb_rec.cpl_id <> OKL_API.G_MISS_NUM Then
            --fetch if any party refund details record
            open l_ppyd_csr(p_cpl_id => l_db_asb_rec.cpl_id);
            fetch l_ppyd_csr into l_ppyd_id;
            If l_ppyd_csr%NOTFOUND then
                null;
            End If;
            Close l_ppyd_csr;

            If l_ppyd_id is not null Then

                l_ppydv_rec.id := l_ppyd_id;

                OKL_PYD_PVT.delete_row(
                  p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_ppydv_rec      => l_ppydv_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            End If;
        End If;
    End If;
    -------------------------------------------------------------------
    --End delete the party payment details if vendor changes
    -------------------------------------------------------------------


    --dbms_output.put_line(to_char(l_asb_rec.amount));
    ---------------------------------------------------------
    --call local procedure to fill up the defaults
    ----------------------------------------------------------
    fill_up_defaults (x_return_status => x_return_status,
                      p_asb_rec       => l_asb_rec,
                      p_db_asb_rec    => l_db_asb_rec,
                      x_clev_rec      => lx_def_clev_rec,
                      x_klev_rec      => lx_def_klev_rec,
                      x_cplv_rec      => lx_def_cplv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_clev_rec := lx_def_clev_rec;
    l_klev_rec := lx_def_klev_rec;
    l_cplv_rec := lx_def_cplv_rec;

    ------------------------------------------------------------
    --fill up l_asb_rec for validation
    ------------------------------------------------------------
    If l_klev_rec.subsidy_id <> OKL_API.G_MISS_NUM then
        l_asb_rec.subsidy_id              := l_klev_rec.subsidy_id;
    Else
        l_asb_rec.subsidy_id              := l_db_asb_rec.subsidy_id;
    End If;
    l_asb_rec.subsidy_cle_id          := l_db_asb_rec.subsidy_cle_id;
    l_asb_rec.name                    := l_clev_rec.name;
    l_asb_rec.description             := l_clev_rec.item_description;
    l_asb_rec.amount                  := l_klev_rec.amount;
    l_asb_rec.subsidy_override_amount := l_klev_rec.subsidy_override_amount;
    l_asb_rec.dnz_chr_id              := l_db_asb_rec.dnz_chr_id;
    l_asb_rec.asset_cle_id            := l_db_asb_rec.asset_cle_id;
    If l_cplv_rec.id <> OKL_API.G_MISS_NUM then
        l_asb_rec.cpl_id              := l_cplv_rec.id;
    Else
        l_asb_rec.cpl_id             := l_db_asb_rec.cpl_id;
    End If;
    If (l_cplv_rec.object1_id1 is not null) and (l_cplv_rec.object1_id1 <> OKL_API.G_MISS_CHAR) then
        l_asb_rec.vendor_id           := to_number(l_cplv_rec.object1_id1);
        --get vendor name
        open l_vendor_csr(p_vendor_id => l_asb_rec.vendor_id);
        fetch l_vendor_csr into l_vendor_name;
        If l_vendor_csr%NOTFOUND then
            null;
        else
            l_asb_rec.vendor_name := l_vendor_name;
        end if;
        close l_vendor_csr;
    Else
        l_asb_rec.vendor_id    := l_db_asb_rec.vendor_id;
        l_asb_rec.vendor_name  := l_db_asb_rec.vendor_name;
    End If;

    ----------------------------------------------------
    --validate the subsidy asset record
    ----------------------------------------------------
    validate_asset_subsidy(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------------------------
    --call complex API to update line instance
    ----------------------------------------------------------
    --dbms_output.put_line(to_char(l_klev_rec.amount));
    --dbms_output.put_line('before update ' ||to_char(l_klev_rec.subsidy_override_amount));
    If l_clev_rec.id <> OKL_API.G_MISS_NUM then

        OKL_CONTRACT_PUB.update_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => l_clev_rec,
          p_klev_rec      => l_klev_rec,
          x_clev_rec      => lx_clev_rec,
          x_klev_rec      => lx_klev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    End If;
   --dbms_output.put_line('After update :'||to_char(l_klev_rec.subsidy_override_amount));

/* comment out by cklee 03/15/2004: move to l_asb_tbl level
-- start cklee 01/22/04
    ----------------------------------------------------
    --validate the subsidy asset record
    ----------------------------------------------------
    validate_asset_subsidy_after(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- end cklee 01/22/04
*/
    ---------------------------------------------------------
    -- call complex API to create or update party role instance
    -- depending on existence
    ----------------------------------------------------------
    If l_cplv_rec.id  <> OKL_API.G_MISS_NUM then
        If l_cplv_rec.id is null then
            --no record exists create
            If (l_cplv_rec.object1_id1 is not null) and
               (l_cplv_rec.object1_id1 <> OKL_API.G_MISS_CHAR) then
                l_cplv_rec.cle_id := l_clev_rec.id;
                l_cplv_rec.id := OKL_API.G_MISS_NUM;

                --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
                --              to create records in tables
                --              okc_k_party_roles_b and okl_k_party_roles

                /*
                 okl_okc_migration_pvt.create_k_party_role(
	                 p_api_version	    => p_api_version,
	                 p_init_msg_list	=> p_init_msg_list,
	                 x_return_status 	=> x_return_status,
	                 x_msg_count     	=> x_msg_count,
	                 x_msg_data      	=> x_msg_data,
	                 p_cplv_rec		    => l_cplv_rec,
	                 x_cplv_rec		    => lx_cplv_rec);
                 */

                 okl_k_party_roles_pvt.create_k_party_role(
	                 p_api_version      => p_api_version,
	                 p_init_msg_list    => p_init_msg_list,
	                 x_return_status    => x_return_status,
	                 x_msg_count        => x_msg_count,
	                 x_msg_data         => x_msg_data,
	                 p_cplv_rec         => l_cplv_rec,
	                 x_cplv_rec         => lx_cplv_rec,
                       p_kplv_rec         => l_kplv_rec,
	                 x_kplv_rec         => lx_kplv_rec);

                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
             End If;
         Elsif l_cplv_rec.id is not null  then
             --update
             --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
             --              to update records in tables
             --              okc_k_party_roles_b and okl_k_party_roles
             /*
             okl_okc_migration_pvt.update_k_party_role(
	                 p_api_version	    => p_api_version,
	                 p_init_msg_list	=> p_init_msg_list,
	                 x_return_status 	=> x_return_status,
	                 x_msg_count     	=> x_msg_count,
	                 x_msg_data      	=> x_msg_data,
	                 p_cplv_rec		    => l_cplv_rec,
	                 x_cplv_rec		    => lx_cplv_rec);
             */

             l_kplv_rec.id := l_cplv_rec.id;
             okl_k_party_roles_pvt.update_k_party_role(
	                 p_api_version      => p_api_version,
	                 p_init_msg_list    => p_init_msg_list,
	                 x_return_status    => x_return_status,
	                 x_msg_count        => x_msg_count,
	                 x_msg_data         => x_msg_data,
	                 p_cplv_rec         => l_cplv_rec,
	                 x_cplv_rec         => lx_cplv_rec,
                       p_kplv_rec         => l_kplv_rec,
	                 x_kplv_rec         => lx_kplv_rec
                       );

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         End If;
     End If;

    ---------------------------------------------------------
    --Call API to calculate asset subsidy amounts
    ----------------------------------------------------------
    calculate_asset_subsidy(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_rec,
            x_asb_rec        => lx_calc_asb_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_asb_rec := lx_calc_asb_rec;

     ---------------------------------------------------------
     --Call API to recalculate asset oec and cap amounts
     ----------------------------------------------------------
     --included in calculate_asset_subsidy
    ----------------------------------------------------------------------------
    --assign values to out record
    ----------------------------------------------------------------------------
    x_asb_rec := l_asb_rec;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_vendor_csr%ISOPEN then
        close l_vendor_csr;
    End If;
    If l_ppyd_csr%ISOPEN then
        close l_ppyd_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_vendor_csr%ISOPEN then
        close l_vendor_csr;
    End If;
    If l_ppyd_csr%ISOPEN then
        close l_ppyd_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_vendor_csr%ISOPEN then
        close l_vendor_csr;
    End If;
    If l_ppyd_csr%ISOPEN then
        close l_ppyd_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End update_asset_subsidy;
--------------------------------------------------------------------------------
--Name       : update_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To update asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE update_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_tbl                      IN  asb_tbl_type,
    x_asb_tbl                      OUT NOCOPY  asb_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'UPDATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_overall_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                      NUMBER := 0;

    l_asb_tbl  asb_tbl_type;
Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_asb_tbl := p_asb_tbl;
    If l_asb_tbl.COUNT > 0 then
        i := l_asb_tbl.FIRST;
        LOOP
            update_asset_subsidy(
                 p_api_version        => p_api_version,
                 p_init_msg_list      => p_init_msg_list,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_asb_rec            => l_asb_tbl(i),
                 x_asb_rec            => x_asb_tbl(i));

/*-- start cklee 11/15/04

	             -- store the highest degree of error
		         If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			             l_overall_status := x_return_status;
		             End If;
		         End If;
-- end cklee 11/15/04
*/
-- start cklee 11/15/04
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
-- end cklee 11/15/04

            EXIT WHEN (i = l_asb_tbl.LAST);
            i := l_asb_tbl.NEXT(i);
        END LOOP;
        -- return overall status
-- start cklee 11/15/04
--	    x_return_status := l_overall_status;
-- end cklee 11/15/04

-- start cklee 03/15/04
        ----------------------------------------------------
        --validate the subsidy asset record after record has
        -- been created in this transaction
        ----------------------------------------------------
        validate_asset_subsidy_after(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asb_rec        => l_asb_tbl(l_asb_tbl.FIRST));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
-- end cklee 03/15/04

    End If;
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
End update_asset_subsidy;
--------------------------------------------------------------------------------
--Name       : delete_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To delete asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE delete_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_rec                      IN  asb_rec_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'DELETE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;

    l_asb_rec          asb_rec_type;
    l_db_asb_rec       asb_rec_type;
    l_row_notfound     BOOLEAN := TRUE;

    l_clev_rec         okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec         okl_contract_pub.klev_rec_type;
    l_cplv_rec         okl_okc_migration_pvt.cplv_rec_type;

    --cursor to fetch party refund details record
    cursor l_ppyd_csr (p_cpl_id in number) is
    select ppyd.id
    from   okl_party_payment_dtls ppyd
    where  ppyd.cpl_id = p_cpl_id;

    l_ppyd_id number default null;

    l_ppydv_rec      OKL_PYD_PVT.ppydv_rec_type;

    --Bug# 4558486
    l_kplv_rec       OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_asb_rec    := p_asb_rec;
    l_db_asb_rec := get_rec(l_asb_rec,l_row_notfound);

    IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    --Bug# 4959361
    OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => l_db_asb_rec.subsidy_cle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4959361

    ----------------------------------------------------------------------------
    --Begin : Delete party refund details if they exist
    ----------------------------------------------------------------------------
    If l_db_asb_rec.cpl_id is not Null and
       l_db_asb_rec.cpl_id <> OKL_API.G_MISS_NUM Then
        --fetch if any party refund details record
        open l_ppyd_csr(p_cpl_id => l_db_asb_rec.cpl_id);
        fetch l_ppyd_csr into l_ppyd_id;
        If l_ppyd_csr%NOTFOUND then
            null;
        End If;
        Close l_ppyd_csr;

        If l_ppyd_id is not null Then

            l_ppydv_rec.id := l_ppyd_id;

            OKL_PYD_PVT.delete_row(
              p_api_version    => p_api_version,
              p_init_msg_list  => p_init_msg_list,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_ppydv_rec      => l_ppydv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        End If;
    End If;

    ----------------------------------------------------------------------------
    --End : Delete party refund details if they exist
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------
    --call line api to delete line
    ----------------------------------------------------------------
    If (l_db_asb_rec.subsidy_cle_id is not null) and
       (l_db_asb_rec.subsidy_cle_id <> OKL_API.G_MISS_NUM) then

        l_clev_rec.id := l_db_asb_rec.subsidy_cle_id;
        l_klev_rec.id := l_db_asb_rec.subsidy_cle_id;

        OKL_CONTRACT_PUB.delete_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => l_clev_rec,
          p_klev_rec      => l_klev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    End If;

    ----------------------------------------------------------------
    --call party api to delete party_role
    ----------------------------------------------------------------
    If (l_db_asb_rec.cpl_id is not null) and
       (l_db_asb_rec.cpl_id <> OKL_API.G_MISS_NUM) then

        l_cplv_rec.id := l_db_asb_rec.cpl_id;

        --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
        --              to delete records in tables
        --              okc_k_party_roles_b and okl_k_party_roles
        /*
        OKL_OKC_MIGRATION_PVT.delete_k_party_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_cplv_rec      => l_cplv_rec);
        */

        l_kplv_rec.id := l_cplv_rec.id;
        OKL_K_PARTY_ROLES_PVT.delete_k_party_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_cplv_rec      => l_cplv_rec,
          p_kplv_rec      => l_kplv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --also will delete the party payment details once they are in place
    End If;
     ---------------------------------------------------------
     --Call API to recalculate asset oec and cap amounts
     ----------------------------------------------------------
     recalculate_costs(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_chr_id         => l_db_asb_rec.dnz_chr_id,
            p_asset_cle_id   => l_db_asb_rec.asset_cle_id);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     /*
      * sjalasut: aug 25, 04 added code to enable business event. BEGIN
      */
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_db_asb_rec.dnz_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => l_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_db_asb_rec.dnz_chr_id,
                            p_asset_id            => l_db_asb_rec.asset_cle_id,
                            p_subsidy_id          => l_db_asb_rec.subsidy_id,
                            p_event_name          => G_WF_EVT_ASSET_SUBSIDY_RMVD,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data
                           );
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     /*
      * sjalasut: aug 25, 04 added code to enable business event. END
      */

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_ppyd_csr%isopen then
        close l_ppyd_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_ppyd_csr%isopen then
        close l_ppyd_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_ppyd_csr%isopen then
        close l_ppyd_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End delete_asset_subsidy;
--------------------------------------------------------------------------------
--Name       : delete_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To delete asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE delete_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_tbl                      IN  asb_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'DELETE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_overall_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                      NUMBER := 0;

    l_asb_tbl  asb_tbl_type;
Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_asb_tbl := p_asb_tbl;
    If l_asb_tbl.COUNT > 0 then
        i := l_asb_tbl.FIRST;
        LOOP
            delete_asset_subsidy(
                 p_api_version        => p_api_version,
                 p_init_msg_list      => p_init_msg_list,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_asb_rec            => l_asb_tbl(i));
/*-- start cklee 11/15/04

	             -- store the highest degree of error
		         If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			             l_overall_status := x_return_status;
		             End If;
		         End If;
-- end cklee 11/15/04
*/
-- start cklee 11/15/04
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
-- end cklee 11/15/04

            EXIT WHEN (i = l_asb_tbl.LAST);
            i := l_asb_tbl.NEXT(i);
        END LOOP;
        -- return overall status
-- start cklee 11/15/04
--	    x_return_status := l_overall_status;
-- end cklee 11/15/04

    End If;
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
End delete_asset_subsidy;

--------------------------------------------------------------------------------
--Name       : validate_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To validate asset subsidy record along with associted party role
--------------------------------------------------------------------------------
PROCEDURE validate_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_tbl                      IN  asb_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'VALIDATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_overall_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                      NUMBER := 0;

    l_asb_tbl  asb_tbl_type;
Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_asb_tbl := p_asb_tbl;
    If l_asb_tbl.COUNT > 0 then
        i := l_asb_tbl.FIRST;
        LOOP
            validate_asset_subsidy(
                 p_api_version        => p_api_version,
                 p_init_msg_list      => p_init_msg_list,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_asb_rec            => l_asb_tbl(i));

/*-- start cklee 11/15/04
	             -- store the highest degree of error
		         If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			             l_overall_status := x_return_status;
		             End If;
		         End If;
-- end cklee 11/15/04
*/
-- start cklee 11/15/04
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
-- end cklee 11/15/04

            EXIT WHEN (i = l_asb_tbl.LAST);
            i := l_asb_tbl.NEXT(i);
        END LOOP;
        -- return overall status
-- start cklee 11/15/04
--	    x_return_status := l_overall_status;
-- end cklee 11/15/04

    End If;
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
End validate_asset_subsidy;
--------------------------------------------------------------------------------
--Name       : calculate_asset_subsidy
--Creation   : 21-Aug-2003
--Purpose    : To calculate asset subsidy for table of subsidy records
--------------------------------------------------------------------------------
PROCEDURE calculate_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asb_tbl                      IN  asb_tbl_type,
    x_asb_tbl                      OUT NOCOPY  asb_tbl_type) is


    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'CALCULATE_ASSET_SUBSIDY';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_overall_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                      NUMBER := 0;

    l_asb_tbl  asb_tbl_type;
Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_asb_tbl := p_asb_tbl;
    If l_asb_tbl.COUNT > 0 then
        i := l_asb_tbl.FIRST;
        LOOP
            calculate_asset_subsidy(
                 p_api_version        => p_api_version,
                 p_init_msg_list      => p_init_msg_list,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_asb_rec            => l_asb_tbl(i),
                 x_asb_rec            => x_asb_tbl(i));

/*-- start cklee 11/15/04
	             -- store the highest degree of error
		         If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			             l_overall_status := x_return_status;
		             End If;
		         End If;
-- end cklee 11/15/04
*/

-- start cklee 11/15/04
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
-- end cklee 11/15/04


            EXIT WHEN (i = l_asb_tbl.LAST);
            i := l_asb_tbl.NEXT(i);
        END LOOP;
        -- return overall status
-- start cklee 11/15/04
--	    x_return_status := l_overall_status;
-- end cklee 11/15/04

    End If;

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
End calculate_asset_subsidy;
END OKL_ASSET_SUBSIDY_PVT;

/
