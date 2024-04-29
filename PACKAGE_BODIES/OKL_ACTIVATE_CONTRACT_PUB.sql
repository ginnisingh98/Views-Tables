--------------------------------------------------------
--  DDL for Package Body OKL_ACTIVATE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACTIVATE_CONTRACT_PUB" AS
/* $Header: OKLPACOB.pls 120.26.12010000.7 2009/12/16 04:59:47 rpillay ship $ */

PROCEDURE get_stream_id
(
 p_khr_id  		   	IN okl_k_headers_full_v.id%TYPE,
 p_stream_type_purpose          IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_sty_id 		        OUT NOCOPY okl_strm_type_b.ID%TYPE
)
IS

CURSOR pry_sty_csr IS
SELECT ID
FROM   OKL_Strm_type_b
WHERE stream_type_purpose = p_stream_type_purpose;

l_sty_id 			  	NUMBER;

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

    OPEN pry_sty_csr;
    FETCH pry_sty_csr INTO l_sty_id;
    IF  pry_sty_csr%NOTFOUND THEN
            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_PRY_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => p_stream_type_purpose);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;
     CLOSE pry_sty_csr;

  x_sty_id := l_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);

END get_stream_id;

--------------------------------------------------------------------------------
--Bug # 3310972
--Api Name     : Is_Rebook_Supported
--Description  : Local procedure will determine whether there is a change
--               in asset add-ons or adjustments during rebook. These changes
--               are not supported.
--Notes        :
--               IN Parameters -
--      IN Parameters -
--                     p_rbk_chr_id    - contract id of rebook copy contract
--                     p_orig_chr_id   - contract id of original contract
--      OUT Parameter  x_return_status - will return OKL_API.G_RET_STS_SUCCESS or
--                                       OKL_API.G_RET_STS_ERROR
--
--      03-Jul-2009 rpillay   Bug# 8652738: Modified API to only validate
--                            if an add-on has been deleted during rebook.
--                            Addition and Update of Add-on and Update of
--                            Trade-in and Down Payments are now supported by
--                            rebook
--End of Comments
--------------------------------------------------------------------------------
  Procedure Is_Rebook_Supported (p_rbk_chr_id    IN NUMBER,
                                 p_orig_chr_id   IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2) is

  l_return_status   varchar2(1) default OKL_API.G_RET_STS_SUCCESS;

  l_asset_number okc_k_lines_tl.name%TYPE default NULL;

  ------------------------------------------------------
  --Cursor to determine if an addon has been deleted
  --during rebook
  ------------------------------------------------------
  Cursor l_deleted_addon_csr (p_rbk_chr_id in NUMBER,
                              p_orig_chr_id in NUMBER) is
  select clet.name
  from   okc_line_styles_b   addon_lseb,
         okc_k_lines_b       addon_cleb,
         okc_line_styles_b   model_lseb,
         okc_k_lines_b       model_cleb,
         okc_k_lines_tl      clet,
         okc_line_styles_b   lseb,
         okc_k_lines_b       cleb
  where
  addon_cleb.cle_id            = model_cleb.id
  and    addon_cleb.dnz_chr_id = model_cleb.dnz_chr_id
  and    addon_lseb.id         = addon_cleb.lse_id
  and    addon_lseb.lty_code   = 'ADD_ITEM'
  --
  and    model_cleb.cle_id     = cleb.id
  and    model_cleb.dnz_chr_id = cleb.dnz_chr_id
  and    model_lseb.id         = model_cleb.lse_id
  and    model_lseb.lty_code   = 'ITEM'
  --
  and    clet.id               = cleb.id
  and    clet.language         = userenv('LANG')
  and    cleb.chr_id           = p_orig_chr_id --orig contract
  and    cleb.dnz_chr_id       = p_orig_chr_id --orig contract
  and    lseb.id               = cleb.lse_id
  and    lseb.lty_code         = 'FREE_FORM1'
  and    not exists (select '1'
                 from   okc_k_lines_b addon_cleb2,
                        okc_k_lines_b model_cleb2,
                        okc_k_lines_b cleb2
                 where  nvl(addon_cleb2.orig_system_id1,-999)       = addon_cleb.id
                 and    nvl(model_cleb2.orig_system_id1,-999)       = model_cleb.id
                 --and    nvl(cleb2.orig_system_id1,-999)             = cleb2.id
                 and    nvl(cleb2.orig_system_id1,-999)             = cleb.id
                 and    addon_cleb2.cle_id                          = model_cleb2.id
                 and    addon_cleb2.dnz_chr_id                      = model_cleb2.dnz_chr_id
                 and    model_cleb2.cle_id                          = cleb2.id
                 and    model_cleb2.dnz_chr_id                      = cleb2.dnz_chr_id
                 and    cleb2.chr_id                                = p_rbk_chr_id --rebook copy
                 and    cleb2.dnz_chr_id                            = p_rbk_chr_id --rebook copy
                 --to avoid picking up new asset added during rebook
                 and    cleb2.orig_system_id1 is not null);

  l_unsupported_rebook_modfn EXCEPTION;

  begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_asset_number  := NULL;

      --4.0 check if new addon has been deleted
      open l_deleted_Addon_csr(p_rbk_chr_id => p_rbk_chr_id,
                             p_orig_chr_id => p_orig_chr_id);
      Fetch l_deleted_Addon_csr into l_asset_number;
      If l_deleted_addon_csr%NOTFOUND then
          NULL;
      End If;
      Close l_deleted_Addon_csr;

      If nvl(l_asset_number,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR then
         OKL_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_REBOOK_UNSUPPORTED_MODFN'
                          );
         raise l_unsupported_rebook_modfn;
      End If;

      EXCEPTION
      When l_unsupported_rebook_modfn then
         If l_deleted_addon_csr%ISOPEN then
              close l_deleted_addon_csr;
          End If;
          x_return_status := OKL_API.G_RET_STS_ERROR;
      When OTHERS then
         If l_deleted_addon_csr%ISOPEN then
              close l_deleted_addon_csr;
          End If;
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  End Is_Rebook_Supported;
--Bug# 3310972
--------------------------------------------------------------------------------
--Bug # 2953906
--Api Name     : Validate_Bill_To
--Description  : Local procedure to validate bill to addresses on the contract
--               Will be called for normal booking.Will not be called for
--               rebooks and releases
--Notes        :
--               IN Parameters -
--      IN Parameters -
--                     p_chr_id    - contract id
--      OUT Parameter  x_return_status - return status
--End of Comments
--------------------------------------------------------------------------------
Procedure Validate_bill_To(p_chr_id IN Number,
                           x_return_status OUT NOCOPY  VARCHAR2) is
l_return_status varchar2(1) default OKL_API.G_RET_STS_SUCCESS;

--cursor to fetch rule values for customer account and bill to at
--contract level and contract line level

--Bug# 3124577 :new cursors for rule migration
--cursor to fetch contract header level BTO and CAN
cursor l_chrb_csr(chrId IN NUMBER) is
Select chrb.bill_to_site_use_id,
       chrb.cust_acct_id
from   okc_k_headers_b chrb
where  id = ChrId;

--cursor to fetch contract line level BTO and CAN
cursor l_cleb_csr (chrId In Number) is
Select cleb.bill_to_site_use_id
from   okc_k_lines_b cleb
where  cleb.dnz_chr_id = ChrId
and    cleb.sts_code <> 'ABANDONED'
and    cleb.bill_to_site_use_id is not null;

--cursor to fetch vendor billing setup BTO and CAN
cursor l_cplb_csr (ChrId In Number) is
Select cplb.bill_to_site_use_id,
       cplb.cust_acct_id
from   okc_k_party_roles_b cplb
where  cplb.chr_id = ChrId
and    cplb.dnz_chr_id = ChrId
and    (cplb.bill_to_site_use_id is NOT NULL
        OR
        cplb.cust_acct_id is NOT NULL);

l_bto_id      okc_rules_b.object1_id1%TYPE;
l_custacct_id okc_rules_b.object1_id1%TYPE;


--Local function to determine whether BTO is active
Function is_bto_active(p_bto_id      IN Varchar2,
                       p_custacct_id IN Varchar2) return Varchar2 is
l_return_status varchar2(1) default OKL_API.G_RET_STS_SUCCESS;

--cursor to find BTO status
Cursor l_bto_sts_csr(btoid      IN NUMBER,
                     custacctid IN NUMBER) is
select 'A'
from   okx_cust_site_uses_v site_use,
       hz_cust_acct_sites_all site
where  site_use.id1                   = btoid
and    site_use.site_use_code         = 'BILL_TO'
and    site_use.b_status              = 'A'
--and    site_use.cust_acct_site_status = 'A'
and    site.cust_acct_site_id = site_use.cust_acct_site_id
and    site.status = 'A'
and    site_use.cust_account_id       = custacctid;

l_bto_id         NUMBER;
l_custacct_id    NUMBER;
l_bto_status     VARCHAR2(1) default 'I';


Begin
----
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_bto_status    := 'I'; -- inactive

    l_bto_id      := to_number(p_bto_id);
    l_custacct_id := to_number(p_custacct_id);

    open l_bto_sts_csr(btoid      => l_bto_id,
                       custacctid => l_custacct_id);
    fetch l_bto_sts_csr into l_bto_status;
    If l_bto_sts_csr%NOTFOUND then
        null;
    End If;
    close l_bto_sts_csr;

    if l_bto_status = 'I' then
       l_return_status := OKL_API.G_RET_STS_ERROR;
    end if;
    Return(l_return_status);

    exception
    when others then
        if l_bto_sts_csr%ISOPEN then
            close l_bto_sts_csr;
        end if;
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
end is_bto_active;

Begin
-----
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    --fetch contract customer account at contract header level
    open l_chrb_csr(ChrId => p_chr_id);
    Fetch l_chrb_csr into l_bto_id,l_custacct_id;
    If l_chrb_csr%NOTFOUND then
        Null;
    End If;
    Close l_chrb_csr;

    --check if bto is active at contract header level
    l_return_status := is_bto_active(p_bto_id => l_bto_id,
                                     p_custacct_id => l_custacct_id);
    If l_return_status = OKL_API.G_RET_STS_ERROR then
       --set error message
        OKL_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QA_INVALID_BILLTO'
                          );
    Elsif l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
        Null;
    End If;


    If l_return_status = OKL_API.G_RET_STS_SUCCESS then
        --fetch bill to at contract line level
        open l_cleb_csr(ChrId => p_chr_id);
        Loop
            Fetch l_cleb_csr into l_bto_id;
            Exit when l_cleb_csr%NOTFOUND;
            --check if bto is active at contract line level
            l_return_status := is_bto_active(p_bto_id => l_bto_id,
                                             p_custacct_id => l_custacct_id);
            If l_return_status = OKL_API.G_RET_STS_ERROR then
                --set error message
                OKL_API.set_message(
                                   p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_QA_INVALID_BILLTO'
                                  );
                Exit;
            Elsif l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
                Exit;
            End If;
         End Loop;
         Close l_cleb_csr;
    End If;


    If l_return_status = OKL_API.G_RET_STS_SUCCESS then
        --fetch bill to  and cust account at vendor billing setup level
        open l_cplb_csr(ChrId => p_chr_id);
        Loop
            Fetch l_cplb_csr into l_bto_id,l_custacct_id;
            Exit when l_cplb_csr%NOTFOUND;
            --check if bto is active at vendor billing setup level
            If l_bto_id is not null and l_custacct_id is not null then
                l_return_status := is_bto_active(p_bto_id => l_bto_id,
                                                 p_custacct_id => l_custacct_id);
                If l_return_status = OKL_API.G_RET_STS_ERROR then
                    --set error message
                    OKL_API.set_message(
                                       p_app_name     => G_APP_NAME,
                                       p_msg_name     => 'OKL_QA_INVALID_BILLTO'
                                       );
                    Exit;
                Elsif l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
                    Exit;
                End If;
             End If;
         End Loop;
         Close l_cplb_csr;
    End If;


    x_return_status := l_return_Status;
    Exception
    When others then
         If l_chrb_csr%ISOPEN then
            close l_chrb_csr;
         End If;
         If l_cleb_csr%ISOPEN then
            close l_cleb_csr;
         End If;
         If l_cplb_csr%ISOPEN then
            close l_cplb_csr;
         End If;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
----
End Validate_Bill_To;
--Bug# 2953906 end

--Bug # 3783518
--Api Name     : Validate_Rebook_Date
--Description  : Local procedure to check that if there is a change
--               in Unit Cost during Rebook, then the Revision Date
--               should be the same as Contract Start Date.
--Notes        :
--
--      IN Parameters -
--                     p_rbk_chr_id    - contract id of rebook copy contract
--                     p_orig_chr_id   - contract id of original contract
--      OUT Parameter  x_return_status - will return OKL_API.G_RET_STS_SUCCESS or
--                                       OKL_API.G_RET_STS_ERROR
--End of Comments
--------------------------------------------------------------------------------
  PROCEDURE  Validate_Rebook_Date
                 (p_api_version   IN  NUMBER,
                  p_init_msg_list IN  VARCHAR2,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_msg_count     OUT NOCOPY NUMBER,
                  x_msg_data      OUT NOCOPY VARCHAR2,
                  p_rbk_chr_id    IN  NUMBER,
                  p_orig_chr_id   IN  NUMBER,
                  p_rebook_date   IN  DATE) IS

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Rebook_Date';
  l_api_version	    CONSTANT NUMBER	:= 1.0;

  CURSOR chr_csr(p_chr_id NUMBER) IS
  select start_date
  from okc_k_headers_b
  where id = p_chr_id;

  CURSOR cle_csr(p_rbk_chr_id    NUMBER,
                 p_orig_chr_id   NUMBER,
                 p_item_lty_code VARCHAR2) IS
  select rbk_cle.price_unit    rbk_price_unit,
         orig_cle.price_unit   orig_price_unit
  from   okc_k_lines_b      rbk_cle,
         okc_line_styles_b  rbk_lse,
         okc_k_lines_b      orig_cle
  where  rbk_cle.dnz_chr_id  = p_rbk_chr_id
  and    rbk_lse.lty_code    = p_item_lty_code
  and    rbk_cle.lse_id      = rbk_lse.id
  and    orig_cle.id         = rbk_cle.orig_system_id1
  and    orig_cle.dnz_chr_id = p_orig_chr_id;

  l_cle_rec               cle_csr%rowtype;
  l_chr_rec               chr_csr%rowtype;
  l_item_lty_code         okc_line_styles_b.lty_code%type := 'ITEM';
BEGIN

   open chr_csr(p_rbk_chr_id);
   fetch chr_csr into l_chr_rec;
   close chr_csr;

   -- Revision Date should be the same as Contract Start Date inorder to make an
   -- Unit Cost change
   if (l_chr_rec.start_date <> p_rebook_date) then

     open cle_csr(p_rbk_chr_id, p_orig_chr_id,l_item_lty_code);
     loop
       fetch cle_csr into l_cle_rec;
       exit when cle_csr%NOTFOUND;

       if l_cle_rec.rbk_price_unit <> l_cle_rec.orig_price_unit then
         close cle_csr;
         OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LLA_VALIDATE_UNIT_COST_CHG'
		   		     );
         RAISE OKL_API.G_EXCEPTION_ERROR;
       end if;
     end loop;
     close cle_csr;
   end if;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END Validate_Rebook_Date;
--Bug# 3783518: end

--------------------------------------------------------------------------------
--Api Name     : Activate Contract
--Description  : Will call the FA Activation and IB Activation public apis
--               Will be called from the activate button on the booking screen
--Notes        :
--               IN Parameters -
--      IN Parameters -
--                     p_chr_id    - contract id to be activated
--                     p_call_mode - 'BOOK' for booking
--                                   'REBOOK' for rebooking
--                                   'RELEASE' for release
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE ACTIVATE_CONTRACT(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_chrv_id       IN  NUMBER,
                            p_call_mode     IN  VARCHAR2) IS

l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'ACTIVATE_CONTRACT';
l_api_version          CONSTANT NUMBER := 1.0;

l_cimv_tbl_fa          Okl_Activate_Asset_Pub.cimv_tbl_type;
l_cimv_tbl_ib          Okl_Activate_Ib_Pub.cimv_tbl_type;
l_tcnv_rec             Okl_Trx_Contracts_Pvt.tcnv_rec_type;
l_service_chr_id        Number;

l_commit             VARCHAR2(1)   := Okl_Api.G_FALSE;
l_transaction_type   VARCHAR2(256) default 'Booking';
l_draft_yn           VARCHAR2(1)   := Okl_Api.G_FALSE;

--Bug#2835070
--cursor to check if the contract is rebooked contract
cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
SELECT '!',chr.orig_system_id1, ktrx.date_transaction_occurred,ktrx.id
FROM   okc_k_headers_b CHR,
       okl_trx_contracts ktrx
WHERE  ktrx.khr_id_new = chr.id
AND    ktrx.tsu_code = 'ENTERED'
AND    ktrx.rbr_code is NOT NULL
AND    ktrx.tcn_type = 'TRBK'
AND    CHR.id = p_chr_id
AND    CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_REBOOK'
AND    ktrx.representation_type = 'PRIMARY'; -- MGAAP 7263041

l_rbk_khr      VARCHAR2(1) DEFAULT '?';
l_orig_khr_id  okc_k_headers_b.orig_system_id1%Type;
l_rebook_date  OKL_TRX_CONTRACTS.date_transaction_occurred%TYPE;
l_transaction_id okl_trx_contracts.id%TYPE;
--4542290 start
l_trx_date  OKL_TRX_CONTRACTS.date_transaction_occurred%TYPE;
l_pdt_parameter_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
l_max_bill_date DATE;
l_sty_id NUMBER;
l_accrual_date  OKL_TRX_CONTRACTS.date_transaction_occurred%TYPE;
l_stream_name VARCHAR2(30);
--4542290 end

--Bug#3156924 : Cursor modified to fetch transaction date
--cursor to check if the contract is selected for Mass Rebook
CURSOR  l_chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
SELECT '!', ktrx.date_transaction_occurred,
       --Bug# 4212626
       ktrx.id,
       source_trx_id -- 4542290
FROM   okc_k_headers_b CHR,
       okl_trx_contracts ktrx
where  CHR.ID          = p_chr_id
AND    ktrx.KHR_ID     =  chr.id
AND    ktrx.tsu_code   = 'ENTERED'
AND    ktrx.rbr_code   IS NOT NULL
AND    ktrx.tcn_type   = 'TRBK'
AND    ktrx.representation_type = 'PRIMARY'  -- MGAAP 7263041
/*------------------------------------------------
--AND    EXISTS (SELECT '1'
--               FROM   okl_trx_contracts ktrx
--               WHERE  ktrx.KHR_ID     = chr.id
--               AND    ktrx.tsu_code   = 'ENTERED'
--               AND    ktrx.rbr_code IS NOT NULL
--               AND    ktrx.tcn_type = 'TRBK')
------------------------------------------------*/
AND   EXISTS (SELECT '1'
              FROM   okl_rbk_selected_contract rbk_khr
              WHERE  rbk_khr.KHR_ID = chr.id
              AND    rbk_khr.STATUS <> 'PROCESSED'); --check with debdip

l_mass_rbk_khr  VARCHAR2(1) DEFAULT '?';
--Bug# 3156924
l_mass_rbk_date OKL_TRX_CONTRACTS.date_transaction_occurred%TYPE;
--Bug# 4212626
l_mass_rbk_trx_id OKL_TRX_CONTRACTS.id%TYPE;
--4542290
l_source_trx_id   OKL_TRX_CONTRACTS.ID%TYPE;

CURSOR l_source_trx_type_csr(p_trx_id NUMBER) IS
SELECT TCN_TYPE
FROM   OKL_TRX_CONTRACTS
WHERE  ID = p_trx_id;

l_source_trx_type OKL_TRX_CONTRACTS.TCN_TYPE%TYPE;
--4542290
--cursor to check if usage line exists on the contract
CURSOR l_chk_usage_csr (p_chr_id IN Number) IS
SELECT '!'
FROM   okc_k_headers_b CHR
WHERE  chr.ID = p_chr_id
AND    exists (SELECT '1'
              FROM
                     OKC_LINE_STYLES_B lse,
                     OKC_K_LINES_B     cle
              WHERE  cle.sts_code = 'APPROVED'
              AND    lse.id = cle.lse_id
              AND    lse.lty_code = 'USAGE'
              AND    cle.dnz_chr_id = chr.id);

l_usage_khr   VARCHAR2(1) DEFAULT '?';

--cursor to check if contract is a re-lease contract
CURSOR l_chk_rel_khr_csr (p_chr_id IN Number) IS
SELECT '!'
FROM   okc_k_headers_b CHR
where  chr.ID = p_chr_id
AND    nvl(chr.orig_system_source_code,'XXXX') = 'OKL_RELEASE';

l_rel_khr    VARCHAR2(1) DEFAULT '?';

--cursor to check if contract has re-lease assets
CURSOR l_chk_rel_ast_csr (p_chr_id IN Number) IS
SELECT '!'
FROM   okc_k_headers_b CHR
WHERE   nvl(chr.orig_system_source_code,'XXXX') <> 'OKL_RELEASE'
and     chr.ID = p_chr_id
AND     exists (SELECT '1'
               FROM   OKC_RULES_B rul
               WHERE  rul.dnz_chr_id = chr.id
               AND    rul.rule_information_category = 'LARLES'
               AND    nvl(rule_information1,'N') = 'Y');

l_rel_ast     VARCHAR2(1) DEFAULT '?';

--Bug#2522439 Start
--Cursorr to find out asset return record for re-lease
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
AND    asr.ars_code          = 'RE_LEASE'
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
AND    sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');
/*
-- smereddy,04/13/2006,Bug#4291242
-- Commented as part of bug fix
AND    exists
                  (select  trx.tas_type,
                           ttyp.name
                  from    OKL_TRX_ASSETS    trx,
                          OKL_TRX_TYPES_TL  ttyp
                  where   trx.id        = txl.tas_id
                  and     trx.try_id    = ttyp.id
                  and     ttyp.name     = 'Internal Asset Creation'
                  and     ttyp.language = 'US'
                  and     trx.tsu_code  <>  'PROCESSED'
                  --Bug# 3533936
                  and     trx.tas_type   = 'CRL')
AND    txl.tal_type = 'CRL';
-- end,smereddy,04/13/2006,Bug#4291242
*/
l_asr_rec l_asr_csr%ROWTYPE;


l_artv_rec    okl_asset_returns_pub.artv_rec_type;
lx_artv_rec   okl_asset_returns_pub.artv_rec_type;
--Bug#2522439 End

--Bug#3143522 : Subsidies enhancement

l_subsidy_exists varchar2(1) default OKL_API.G_FALSE;

-- cursor to find subsidies which have expired (if any)
-- sjalasut. modified cursor to remove " and    nvl(subb.effective_to_date,sysdate)+nvl(subb.expire_after_days,0) < sysdate "
-- from the cursor to make the cursor re-usable for subsidy pools enhancement, also added subsidy_id column
-- the check for expiried subsidy would be done in the code, the else part will fork to the common pool transaction api
-- also changed the name of the cursor from l_expired_subsidy_csr as now it retrieves all subsidies

cursor l_subsidy_csr(p_chr_id in number) is
select nvl(subb.effective_to_date,sysdate) effective_to_date,
       nvl(subb.expire_after_days,0)       expire_after_days,
       clet_sub.name                       subsidy_name,
       clet_asst.name                      asset_number,
       subb.id                             subsidy_id,               -- added for subsidy pools enhancement
       kle_sub.amount                      subsidy_amount,           -- added for subsidy pools enhancement
       kle_sub.subsidy_override_amount     subsidy_override_amount,  -- added for subsidy pools enhancement
       cleb_asst.start_date                asset_start_date,         -- added for subsidy pools enhancement
       cleb_asst.id                        asset_id                  -- added for subsidy pools enhancement
       ,subb.effective_from_date           effective_from_date       -- added : Bug 6050165 : prasjain
from   okl_subsidies_b   subb,
       okl_k_lines       kle_sub,
       okc_k_lines_tl    clet_sub,
       okc_k_lines_b     cleb_sub,
       okc_line_styles_b lseb_sub,
       okc_k_lines_tl    clet_asst,
       okc_k_lines_b     cleb_asst,
       okc_line_styles_b lseb_asst
where  subb.id              = kle_sub.subsidy_id
--and    nvl(subb.effective_to_date,sysdate)+nvl(subb.expire_after_days,0) < sysdate
and    kle_sub.id           = cleb_sub.id
and    clet_sub.id          = cleb_sub.id
and    clet_sub.language    = userenv('LANG')
and    cleb_sub.cle_id      = cleb_asst.id
and    cleb_sub.dnz_chr_id  = cleb_asst.dnz_chr_id
and    cleb_sub.sts_code   <> 'ABANDONED'
and    lseb_sub.id          = cleb_sub.lse_id
and    lseb_sub.lty_code    = 'SUBSIDY'
and    clet_asst.id         = cleb_asst.id
and    clet_asst.language   = userenv('LANG')
and    cleb_asst.chr_id     = p_chr_id
and    cleb_asst.dnz_chr_id = p_chr_id
and    lseb_asst.id         = cleb_asst.lse_id
and    lseb_asst.lty_code   = 'FREE_FORM1'
and    cleb_asst.sts_code   <> 'ABANDONED';

l_subsidy_rec    l_subsidy_csr%ROWTYPE;
l_subsidy_valid_status   varchar2(1) default OKL_API.G_RET_STS_SUCCESS;

    -- Start : Bug 6050165 : prasjain
    --cursor to check subsidy applicability at line dates
      cursor l_cle_csr (p_subsidy_id in number,
                        p_asset_cle_id in number) is
      Select 'Y'
      from   okl_subsidies_b sub,
             okc_k_lines_b   cleb
      where  sub.id                = p_subsidy_id
      and    cleb.id               = p_asset_cle_id
      and    TRUNC(cleb.start_date) between TRUNC(sub.effective_from_date)
                             and TRUNC(nvl(sub.effective_to_date,cleb.start_date));
      l_applicable     varchar2(1);
    -- End : Bug 6050165 : prasjain

--Bug#3143522 : 11.5.10 Subsidy enhancement

--BUG# 3397688 : get valid GL date for Accrual reversals during rebooks
l_gl_date    date;

-- Bug# 3541098
-- cursor to get capitalize interest flag
Cursor cap_interest_rul_csr (pchrid number) is
Select rul.rule_information1 capitalize_interest_flag
From   okc_rules_b rul
where  rul.dnz_chr_id = pchrid
and    rul.rule_information_category = 'LACPLN';

Cursor chr_csr (pchrid number) is
Select contract_number
      ,start_date
From   okc_k_headers_b chr
where  chr.id = pchrid;

--4542290
CURSOR max_bill_date_csr(p_stm_id IN NUMBER) IS
SELECT MAX(sel.stream_element_date) stream_element_date
FROM okl_strm_elements sel
WHERE sel.stm_id = p_stm_id
AND   sel.date_billed IS NOT NULL;

l_capitalize_interest_flag  okc_rules_b.rule_information1%TYPE;
l_amount          number;
l_source_id       number;
l_contract_number okc_k_headers_b.contract_number%type;
l_start_date      okc_k_headers_b.start_date%type;
-- Bug# 3541098 end

l_ignore_flag     VARCHAR2(1);

-- sjalasut: added local variables for subsidy pools enhancement. START
lx_sub_pool_id okl_subsidy_pools_b.id%TYPE;
lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
l_sub_pool_applicable VARCHAR2(10);
lv_subsidy_amount okl_k_lines.amount%TYPE;
l_debug_enabled VARCHAR2(10);
l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_ACTIVATE_CONTRACT_PUB.ACTIVATE_CONTRACT';
is_debug_statement_on BOOLEAN;
-- sjalasut: added local variables for subsidy pools enhancement. END

  -- dedey, Bug#4264314
  lx_trx_number OKL_TRX_CONTRACTS.trx_number%TYPE := null; -- MGAAP 7263041
  l_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
  -- dedey, Bug#4264314

  -- racheruv: added update of okl_stream_trx_date.last_trx_state flag.
  l_contract_id     number;

  --Bug# 9191475
  lx_trxnum_tbl OKL_GENERATE_ACCRUALS_PVT.trxnum_tbl_type;

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
			p_api_type      => '_PUB',
			x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    okl_debug_pub.logmessage('In Activate_contract: p_chrv_id =' || p_chrv_id);
    okl_debug_pub.logmessage('p_call_mode =' || p_call_mode);
    -- check if debug is enabled
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    --check for mass rebook contract
    l_mass_rbk_khr := '?';
    OPEN l_chk_mass_rbk_csr (p_chr_id => p_chrv_id);
    --bug# 3156924
    --FETCH l_chk_mass_rbk_csr INTO l_mass_rbk_khr;
    --Bug# 4212626
    FETCH l_chk_mass_rbk_csr INTO
          l_mass_rbk_khr, l_mass_rbk_date, l_mass_rbk_trx_id, l_source_trx_id;
          -- 4542290
    IF l_chk_mass_rbk_csr%NOTFOUND THEN
       NULL;
    END IF;
    CLOSE l_chk_mass_rbk_csr;

    --check for rebook contract
    l_rbk_khr := '?';
    l_orig_khr_id := null;
    l_transaction_id := null;
    OPEN l_chk_rbk_csr (p_chr_id => p_chrv_id);
    FETCH l_chk_rbk_csr INTO l_rbk_khr,l_orig_khr_id,l_rebook_date,l_transaction_id;
    IF l_chk_rbk_csr%NOTFOUND THEN
       NULL;
    END IF;
    CLOSE l_chk_rbk_csr;

    l_rel_khr := '?';
    --check for relese contract
    OPEN l_chk_rel_khr_csr (p_chr_id => p_chrv_id);
    FETCH l_chk_rel_khr_csr INTO l_rel_khr;
    IF l_chk_rel_khr_csr%NOTFOUND THEN
       NULL;
    END IF;
    CLOSE l_chk_rel_khr_csr;

    l_rel_ast := '?';
    --check for relese assets in a contract
    OPEN l_chk_rel_ast_csr (p_chr_id => p_chrv_id);
    FETCH l_chk_rel_ast_csr INTO l_rel_ast;
    IF l_chk_rel_ast_csr%NOTFOUND THEN
       NULL;
    END IF;
    CLOSE l_chk_rel_ast_csr;

    IF l_mass_rbk_khr = '!' THEN
        --do mass rebook processing
        --bug# 3156924 :
        IF nvl(l_mass_rbk_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
            l_mass_rbk_date := sysdate;
        End IF;
        --Bug# 3156924

         -- Start : Bug 6050165 : prasjain
          l_subsidy_exists := OKL_API.G_FALSE;
          okl_subsidy_process_pvt.is_contract_subsidized
                            (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chr_id        => p_chrv_id,
                            x_subsidized    => l_subsidy_exists);
          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

         IF l_subsidy_exists = OKL_API.G_TRUE THEN
            l_subsidy_valid_status  := OKL_API.G_RET_STS_SUCCESS;
            OPEN l_subsidy_csr (p_chr_id => p_chrv_id);
            LOOP
                FETCH l_subsidy_csr INTO l_subsidy_rec;
                EXIT WHEN l_subsidy_csr%NOTFOUND;
                l_applicable := 'N';
                  open l_cle_csr(p_subsidy_id   => l_subsidy_rec.subsidy_id,
                               p_asset_cle_id => l_subsidy_rec.asset_id);
                  Fetch l_cle_csr into l_applicable;
                  If l_cle_csr%NOTFOUND then
                      Null;
                  End If;
                  close l_cle_csr;

                  If (l_applicable = 'N') then
                      Okl_Api.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_SUBSIDY_CRITERIA_MATCH',
                              p_token1       => 'SUBSIDY_NAME',
                              p_token1_value => l_subsidy_rec.subsidy_name,
                              p_token2       => 'ASSET_NUMBER',
                              p_token2_value => l_subsidy_rec.asset_number);
                      l_subsidy_valid_status := OKL_API.G_RET_STS_ERROR;
                 end if;
               end loop;
               IF (l_subsidy_valid_status = Okl_Api.G_RET_STS_ERROR) THEN
                 RAISE Okl_Api.G_EXCEPTION_ERROR;
               end if;
           end if;
     -- End : Bug 6050165 : prasjain

        -- 4542290
        OPEN l_source_trx_type_csr(l_source_trx_id);
        FETCH l_source_trx_type_csr
        INTO  l_source_trx_type;
        CLOSE l_source_trx_type_csr;

        --dbms_output.put_line('Gone in for rebook.');
        Okl_Activate_Asset_Pvt.MASS_REBOOK_ASSET(p_api_version      => p_api_version,
                                                 p_init_msg_list    => p_init_msg_list,
                                                 x_return_status    => x_return_status,
                                                 x_msg_count        => x_msg_count,
                                                 x_msg_data         => x_msg_data,
                                                 p_rbk_chr_id       => p_chrv_id);
                --dbms_output.put_line('Gone in for rebook. '||x_return_status);
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

	 -- dedey, Bug#4264314
	 OKL_CONTRACT_REBOOK_PVT.create_billing_adjustment(
	   p_api_version     => p_api_version,
	   p_init_msg_list   => p_init_msg_list,
	   x_return_status   => x_return_status,
	   x_msg_count       => x_msg_count,
	   x_msg_data        => x_msg_data,
	   p_rbk_khr_id      => p_chrv_id,
	   p_orig_khr_id     => p_chrv_id,
	   p_trx_id          => l_mass_rbk_trx_id,
	   p_trx_date        => sysdate); -- 4583578 passing sysdate instead of rebook date

	 IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	 ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
	 -- dedey, Bug#4264314

        -- 4542290
        -- 4752350 (added NVL as l_source_trx_type is NULL)
        IF (nvl(l_source_trx_type,'X') NOT IN ('ALT', 'PPD')) THEN
          --generate final booking JE for rebooked contract
          --bug# 28355070
          okl_la_je_pvt.generate_journal_entries(
                        p_api_version      => p_api_version,
                        p_init_msg_list    => p_init_msg_list,
                        p_commit           => l_commit,
                        p_contract_id      => p_chrv_id,
                        p_transaction_type => l_transaction_type,
                        --Bug# 3156924
                        --p_transaction_date => sysdate,
                        p_transaction_date => l_mass_rbk_date,
                        p_draft_yn         => l_draft_yn,
                        p_memo_yn          => okl_api.g_true,
                        x_return_status    => x_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data);

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        END IF;

         --bug# 2842342
         --call reverse accruals API

         --Bug# 3156924
         l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_mass_rbk_date);

        -- Sales Tax Project changes Bug: 4622963 - START

        -- Important Note: 'Mass-Rebook' is not a seeded trx type
        -- it is a placeholder to distinguish regular 'Rebook'
        -- from 'Mass Rebook' process for sales tax, because tax processing
        -- is different between the processes. Inside the sales tax process
        -- it will be replaced by trx type 'Rebook' before calling tax engine,
        -- as both the processes use 'Rebook' as the trx type
--ebtax rebook impacts akrangan start
--remove upfront tax call for rebook
/*
        okl_la_sales_tax_pvt.process_sales_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => Okl_Api.G_FALSE,
                      p_commit           => Okl_Api.G_FALSE,
                      p_contract_id      => l_orig_khr_id,
                      p_transaction_type => 'Mass-Rebook',
                      p_transaction_id   => l_mass_rbk_trx_id,
                      p_transaction_date => l_mass_rbk_date,
                      p_rbk_contract_id  => l_orig_khr_id,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        -- Sales Tax Project changes Bug: 4622963 - END
*/
--akrangan end
 	       -- dedey,Bug#4264314
         -- This call moved up before JE call
	 /*

         --Bug# 4212626
         OKL_CONTRACT_REBOOK_PVT.create_billing_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chrv_id,
           p_orig_khr_id     => p_chrv_id,
           p_trx_id          => l_mass_rbk_trx_id,
           p_trx_date        => sysdate); -- 4583578 passing sysdate instead of rebook date

         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
	 */
	 -- dedey,Bug#4264314

         --Bug# 4212626
         -- This call is moved to Okl_Mass_Rebook_Pvt(OKLRMRPB.pls)
         -- as the accrual adjustment api requires the Contract
         -- status to be 'BOOKED' before accrual adjustments can be
         -- generated.
         /*
         OKL_CONTRACT_REBOOK_PVT.create_accrual_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chrv_id,
           p_orig_khr_id     => p_chrv_id,
           p_trx_id          => l_mass_rbk_trx_id,
           p_trx_date        => l_mass_rbk_date);

         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
         */

        --Bug# 4212626
        /*
        okl_generate_accruals_pub.REVERSE_ALL_ACCRUALS (
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            p_khr_id        => p_chrv_id,
            --Bug# 3156924
            --p_reverse_date  => SYSDATE,
            p_reverse_date  => l_gl_date,
            p_description   => 'Call from Rebook API',
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        */

    ELSIF l_rbk_khr = '!' THEN

        --Bug# : check if rebook changes are supported
        --       check that no changes to add-ons and adjustments
        Is_Rebook_Supported(p_rbk_chr_id    => p_chrv_id,
                            p_orig_chr_id   => l_orig_khr_id,
                            x_return_status => x_return_status);

         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
         --Bug#:  End.

        -- 02-Mar-09  sechawla  bug 8370324 : removed the following validation
        /*
        --Bug# 3783518 : Allow update of unit cost only if the
        --               revision date is the same as contract start date
         Validate_Rebook_Date
                 (p_api_version     => p_api_version,
                  p_init_msg_list   => p_init_msg_list,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_rbk_chr_id      => p_chrv_id,
                  p_orig_chr_id     => l_orig_khr_id,
                  p_rebook_date     => l_rebook_date);
          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        --Bug# 3783518: End
         */

        --Bug# 8756653
        -- Check if contract has been upgraded for effective dated rebook
        OKL_LLA_UTIL_PVT.check_rebook_upgrade
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_chr_id          => l_orig_khr_id,
           p_rbk_chr_id      => p_chrv_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      --Start : Bug 6050165 : prasjain
          l_subsidy_exists := OKL_API.G_FALSE;
          okl_subsidy_process_pvt.is_contract_subsidized
                            (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chr_id        => p_chrv_id,
                            x_subsidized    => l_subsidy_exists);
          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

         IF l_subsidy_exists = OKL_API.G_TRUE THEN
            l_subsidy_valid_status  := OKL_API.G_RET_STS_SUCCESS;
            OPEN l_subsidy_csr (p_chr_id => p_chrv_id);
            LOOP
                FETCH l_subsidy_csr INTO l_subsidy_rec;
                EXIT WHEN l_subsidy_csr%NOTFOUND;
                l_applicable := 'N';
                  open l_cle_csr(p_subsidy_id   => l_subsidy_rec.subsidy_id,
                               p_asset_cle_id => l_subsidy_rec.asset_id);
                  Fetch l_cle_csr into l_applicable;
                  If l_cle_csr%NOTFOUND then
                      Null;
                  End If;
                  close l_cle_csr;

                  If (l_applicable = 'N') then
                      Okl_Api.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_SUBSIDY_CRITERIA_MATCH',
                              p_token1       => 'SUBSIDY_NAME',
                              p_token1_value => l_subsidy_rec.subsidy_name,
                              p_token2       => 'ASSET_NUMBER',
                              p_token2_value => l_subsidy_rec.asset_number);
                      l_subsidy_valid_status := OKL_API.G_RET_STS_ERROR;
                 end if;
               end loop;
               IF (l_subsidy_valid_status = Okl_Api.G_RET_STS_ERROR) THEN
                 RAISE Okl_Api.G_EXCEPTION_ERROR;
               end if;
           end if;
     --End : Bug 6050165 : prasjain

        --4542290
        l_trx_date := l_rebook_date;
        l_accrual_date := l_rebook_date;

        okl_k_rate_params_pvt.get_product(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => p_chrv_id,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

        IF (l_pdt_parameter_rec.interest_calculation_basis = 'REAMORT' AND
            l_pdt_parameter_rec.revenue_recognition_method = 'STREAMS' ) THEN
          -- Change l_trx_date accordingly
          get_stream_id
          (
            p_khr_id => p_chrv_id,
            p_stream_type_purpose => 'RENT',
            x_return_status => x_return_status,
            x_sty_id => l_sty_id
          );
	  IF x_return_status <> 'S' THEN
            okl_api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                p_token1       => 'STREAM_NAME',
                                p_token1_value => 'RENT');
            RAISE okl_api.g_exception_error;
	  END IF;

          l_max_bill_date := NULL;
          OPEN max_bill_date_csr(p_stm_id => l_sty_id );
          FETCH max_bill_date_csr INTO l_max_bill_date;
          CLOSE max_bill_date_csr;
          IF (l_max_bill_date IS NOT NULL) THEN
            l_trx_date := l_max_bill_date;
          END IF;

          IF (l_pdt_parameter_rec.deal_type = 'LEASEOP') THEN
            l_stream_name := 'RENT_ACCRUAL';
          ELSIF (l_pdt_parameter_rec.deal_type IN ('LEASEDF','LEASEST')) THEN
            l_stream_name := 'LEASE_INCOME'; -- AKP: Check 'LEASE_INCOME'?
          ELSIF (l_pdt_parameter_rec.deal_type = 'LOAN') THEN
            l_stream_name := 'INTEREST_INCOME'; -- AKP: Check
          END IF;
          get_stream_id
            (
              p_khr_id => p_chrv_id,
              p_stream_type_purpose => l_stream_name,
              x_return_status => x_return_status,
              x_sty_id => l_sty_id
            );
	  IF x_return_status <> 'S' THEN
            okl_api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                p_token1       => 'STREAM_NAME',
                                p_token1_value => l_stream_name);
            RAISE okl_api.g_exception_error;
	  END IF;

          l_max_bill_date := NULL;
          OPEN max_bill_date_csr(p_stm_id => l_sty_id );
          FETCH max_bill_date_csr INTO l_max_bill_date;
          CLOSE max_bill_date_csr;
          IF (l_max_bill_date IS NOT NULL) THEN
            l_accrual_date := l_max_bill_date;
          END IF;

        END IF;
        --4542290

        --Bug# 4212626
        OKL_CONTRACT_REBOOK_PVT.create_billing_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chrv_id,
           p_orig_khr_id     => l_orig_khr_id,
           p_trx_id          => l_transaction_id,
           p_trx_date        => sysdate); -- 4583578 passing sysdate instead of rebook date
           --4542290 p_trx_date        => l_rebook_date);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

	-- dedey,Bug#4264314
        /*
        --Bug# 4212626
        OKL_CONTRACT_REBOOK_PVT.create_accrual_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chrv_id,
           p_orig_khr_id     => l_orig_khr_id,
           p_trx_id          => l_transaction_id,
           p_trx_date        => l_rebook_date);

	*/
      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041
      OKL_CONTRACT_REBOOK_PVT.calc_accrual_adjustment(
       p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_rbk_khr_id      => p_chrv_id,
       p_orig_khr_id     => l_orig_khr_id,
       p_trx_id          => l_transaction_id,
       --4542290 p_trx_date        => l_rebook_date,
       p_trx_date        => sysdate,    -- 4583578 passing sysdate instead of rebook_date
       x_accrual_rec     => l_accrual_rec,
       x_stream_tbl      => l_stream_tbl);

     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     IF (l_stream_tbl.COUNT > 0) THEN -- Call adjustment when required, dedey
        OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          --Bug# 9191475
          --x_trx_number     => lx_trx_number,
          x_trx_tbl        => lx_trxnum_tbl,
          p_accrual_rec    => l_accrual_rec,
          p_stream_tbl     => l_stream_tbl);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

      END IF; -- l_stream_tbl.COUNT > 0

      -- Start MGAAP 7263041
      OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
      OKL_CONTRACT_REBOOK_PVT.calc_accrual_adjustment(
       p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_rbk_khr_id      => p_chrv_id,
       p_orig_khr_id     => l_orig_khr_id,
       p_trx_id          => l_transaction_id,
       --4542290 p_trx_date        => l_rebook_date,
       p_trx_date        => sysdate,    -- 4583578 passing sysdate instead of rebook_date
       x_accrual_rec     => l_accrual_rec,
       x_stream_tbl      => l_stream_tbl);

     OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     IF (l_stream_tbl.COUNT > 0) THEN -- Call adjustment when required, dedey
        --l_accrual_rec.trx_number := lx_trx_number;
        OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          --Bug# 9191475
          --x_trx_number     => lx_trx_number,
          x_trx_tbl        => lx_trxnum_tbl,
          p_accrual_rec    => l_accrual_rec,
          p_stream_tbl     => l_stream_tbl,
          p_representation_type     => 'SECONDARY');

        OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

      END IF; -- l_stream_tbl.COUNT > 0
      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
      -- End MGAAP 7263041

	-- dedey,Bug#4264314

        -- call synchronize
        --dbms_output.put_line('Into processing for rebooking.');
		Okl_Contract_Rebook_Pvt.sync_rebook_orig_contract(
                                      p_api_version        => p_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rebook_chr_id      => p_chrv_id
                                     );
         --dbms_output.put_line('Hey 1 first call: '||x_return_status);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;


        --dbms_output.put_line('Status1 BEFORE call: '||x_return_status);
         -- call synchronize Streams

         Okl_Contract_Rebook_Pvt.sync_rebook_stream (
                               p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               p_chr_id             => p_chrv_id,
                               p_stream_status      =>  NULL
                              );
        --dbms_output.put_line('Status1: '||x_return_status);

        IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        --dbms_output.put_line('Status2: '||x_return_status);
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
        --dbms_output.put_line('Status3: '||x_return_status);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
        --dbms_output.put_line('Status4: '||x_return_status);

        --call rebook api

        Okl_Activate_Asset_Pub.REBOOK_ASSET(p_api_version      => p_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
                                            p_rbk_chr_id       => p_chrv_id);
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        ---------------------------------------------------------------------------------------
        --Bug# 3143522: Subsidies enhancement : Create billing transaction for 'BILL' subsidies
        ---------------------------------------------------------------------------------------
        l_subsidy_exists := OKL_API.G_FALSE;
        okl_subsidy_process_pvt.is_contract_subsidized
                          (p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chrv_id,
                          x_subsidized    => l_subsidy_exists);
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        If l_subsidy_exists = OKL_API.G_FALSE Then
            okl_subsidy_process_pvt.is_contract_subsidized
                          (p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => l_orig_khr_id,
                          x_subsidized    => l_subsidy_exists);
            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
        Elsif l_subsidy_exists = OKL_API.G_TRUE then
            Null;
        End If;

        If l_subsidy_exists = OKL_API.G_TRUE then
            -- varangan - Bug#5474059 - Modified - Start
            -- Subsidy billing during rebook done before actual
            -- synchronization with main contract. This is to ensure that
            -- the subsidy amount differences can be used to generate invoices/
            -- credit memo as is the case
            --call process API to create Billing transactions for Subsidies ;
           --call process API to create Billing transactions for Subsidies ;
            OKL_SUBSIDY_PROCESS_PVT.CREATE_BILLING_TRX(
                          p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chrv_id);

            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
            -- varangan - Bug#5474059 - Modified - End

            --do rebook synchronize for subsidies
            OKL_SUBSIDY_PROCESS_PVT.rebook_synchronize
                          (p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_rbk_chr_id    => p_chrv_id,
                          p_orig_chr_id   => l_orig_khr_id);

            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;


        End If;
        -------------------------------------------------------------------------------------------
        --Bug# 3143522: End Subsidies enhancement : Create billing transaction for 'BILL' subsidies
        --------------------------------------------------------------------------------------------

        --bug# 28355070
        --generate final booking JE for synced original contract
        okl_la_je_pvt.generate_journal_entries(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_commit           => l_commit,
                      p_contract_id      => l_orig_khr_id,
                      p_transaction_type => l_transaction_type,
                      p_transaction_date => l_rebook_date,
                      p_draft_yn         => l_draft_yn,
                      p_memo_yn          => okl_api.g_true,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 3397688 : Call function to get valid open period date
        l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_rebook_date);

        -- Sales Tax Project changes Bug: 4622963 - START
        okl_la_sales_tax_pvt.process_sales_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => Okl_Api.G_FALSE,
                      p_commit           => Okl_Api.G_FALSE,
                      p_contract_id      => l_orig_khr_id,
                      p_transaction_type => 'Rebook',
                      p_transaction_id   => l_transaction_id,
                      p_transaction_date => l_rebook_date,
                      p_rbk_contract_id  => p_chrv_id,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        -- Sales Tax Project changes Bug: 4622963 - END

        --Bug# 4212626
        /*
         --bug# 2842342
         --call reverse accruals API
        okl_generate_accruals_pub.REVERSE_ALL_ACCRUALS (
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            p_khr_id        => l_orig_khr_id,
            --Bug# 3397688 :
            p_reverse_date  => l_gl_date,
            --p_reverse_date  => l_rebook_date,
            p_description   => 'Call from Rebook API',
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        */

--Bug#5955320
        --call insurance API
        OKL_INSURANCE_POLICIES_PUB.cancel_create_policies(
              p_api_version       => p_api_version,
              p_init_msg_list     => OKL_API.G_FALSE,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_khr_id            => l_orig_khr_id,
              p_cancellation_date => l_rebook_date,
              p_transaction_id    => l_transaction_id,
              x_ignore_flag       => l_ignore_flag);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            If (l_ignore_flag = OKL_API.G_FALSE) then
                RAISE Okl_Api.G_EXCEPTION_ERROR;
            End If;
        END IF;

        --Bug#3278666 : 11.5.10 call Asset management API to invalidate all valid quotes
        OKL_AM_INTEGRATION_PVT.cancel_termination_quotes(
                              p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_khr_id             => l_orig_khr_id,
                              p_source_trx_id      => NULL
                              );
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        --Bug# 3278666 : 11.5.10 call Asset management API to invalidate all valid quotes

        -- PPD
        -- Cancel un-accepted PPD transaction during rebook of a contract
        --
        OKL_CS_PRINCIPAL_PAYDOWN_PUB.CANCEL_PPD(
                p_api_version           => p_api_version
                ,p_init_msg_list        => p_init_msg_list
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,p_khr_id               => l_orig_khr_id
               );

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        -- End PPD Cancel

        --update transaction status
        Okl_Transaction_Pub.update_trx_status(
                              p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_chr_id             => p_chrv_id,
                              p_status             => 'PROCESSED',
                              x_tcnv_rec           => l_tcnv_rec
                             );
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        --change the rebook copy contract status to 'ABANDONED'
        okl_contract_status_pub.update_contract_status(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_khr_status       => 'ABANDONED',
                                p_chr_id           => p_chrv_id);
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        --cascade status to lines
        okl_contract_status_pub.cascade_lease_status(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_chr_id           => p_chrv_id);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        -- Bug# 6071566 - Added Start
        -- Re-assess the earliest stream bill date on contract after rebook to
        -- take into account any changes in payment structure.
        OKL_BILLING_CONTROLLER_PVT.track_next_bill_date(l_orig_khr_id);
        -- Bug# 6071566 - Added End


    ELSIF l_rel_khr = '!' Then
        -- call contract release api
        okl_release_pub.activate_release_contract(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_chr_id             => p_chrv_id);

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

    ELSIF l_rel_ast = '!' Then
   /*
          dcshanmu 21-Jan-2008 start bug#6688570
          Subsidy enhancement added as part of the bug#6688570. As per the update
          given by the PM *** SRAWLING  11/20/07 10:16 am ***, the subsidy needs
          to be billed even if the contract is for re-leased assets and the amount
          needs to be tracked to a subsidy pool.
       */
    ---------------------------------------------------------------------------------------
    --Bug# 3143522: Subsidies enhancement : Check for expired subsidies and stop activation
    --                               Create billing transaction for 'BILL' subsidies
    ---------------------------------------------------------------------------------------

           l_subsidy_exists := OKL_API.G_FALSE;
           okl_subsidy_process_pvt.is_contract_subsidized
                             (p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_chr_id        => p_chrv_id,
                             x_subsidized    => l_subsidy_exists);
           IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                   RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;

           IF l_subsidy_exists = OKL_API.G_TRUE THEN
             ---------------------------------------------------
             --check if expired subsidies exist for the contract
             ---------------------------------------------------
             l_subsidy_valid_status  := OKL_API.G_RET_STS_SUCCESS;
             OPEN l_subsidy_csr (p_chr_id => p_chrv_id);
             LOOP
                 FETCH l_subsidy_csr INTO l_subsidy_rec;
                 EXIT WHEN l_subsidy_csr%NOTFOUND;
                 --shagarg bug 6032336 start
                 l_applicable := 'N';
                   open l_cle_csr(p_subsidy_id   => l_subsidy_rec.subsidy_id,
                                p_asset_cle_id => l_subsidy_rec.asset_id);
                   Fetch l_cle_csr into l_applicable;
                   If l_cle_csr%NOTFOUND then
                       Null;
                   End If;
                   close l_cle_csr;

                   If (l_applicable = 'N') then
                       Okl_Api.set_message(
                               p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_SUBSIDY_CRITERIA_MATCH',
                               p_token1       => 'SUBSIDY_NAME',
                               p_token1_value => l_subsidy_rec.subsidy_name,
                               p_token2       => 'ASSET_NUMBER',
                               p_token2_value => l_subsidy_rec.asset_number);
                       l_subsidy_valid_status := OKL_API.G_RET_STS_ERROR;
                   end if;

                 --IF((l_subsidy_rec.effective_to_date + l_subsidy_rec.expire_after_days) < TRUNC(SYSDATE))THEN
                  if( TRUNC(sysdate) not between TRUNC(l_subsidy_rec.effective_from_date) and
                     TRUNC(nvl(l_subsidy_rec.EFFECTIVE_TO_DATE,sysdate) + nvl(l_subsidy_rec.EXPIRE_AFTER_DAYS,0)))then
                --shagarg bug 6032336 end
                     OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                       p_msg_name     => 'OKL_SUBSIDY_EXPIRED',
                                       p_token1       => 'SUBSIDY',
                                       p_token1_value => l_subsidy_rec.subsidy_name,
                                       p_token2       => 'ASSET_NUMBER',
                                       p_token2_value => l_subsidy_rec.asset_number);
                   l_subsidy_valid_status := OKL_API.G_RET_STS_ERROR;



                 ELSE
                   /*
                    * sjalasut added code for subsidy pools enhancement, the subsidy is checked for association
                    * with the subsidy pool, if associated, the authoring transaction api is invoked for
                    * validation and then create transaction. code logic being merged with subsidy expiration
                    * because only when subsidy is not expired and is associated with a pool, will the pool transaction occur.
                    * Further, it is not correct to indicate a validation failure on a subsidy pool transaction while the
                    * subsidy is actually exipred. START
                    */
                   IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
                     okl_debug_pub.log_debug( FND_LOG.LEVEL_STATEMENT, l_module, 'verifying subsidy applicability over pool subsidy id '||l_subsidy_rec.subsidy_id);
                   END IF;

                   l_sub_pool_applicable := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => l_subsidy_rec.subsidy_id
                                                                                        ,x_subsidy_pool_id => lx_sub_pool_id
                                                                                        ,x_sub_pool_curr_code => lx_sub_pool_curr_code
                                                                                        );

                   IF(l_sub_pool_applicable = 'Y')THEN
                     -- initialize for every iteration of the loop
                     lv_subsidy_amount := 0;
                     -- the amount for transaction is either the override amount if present or the calculated subsidy amount
                     lv_subsidy_amount := NVL(l_subsidy_rec.subsidy_override_amount,NVL(l_subsidy_rec.subsidy_amount,0));
                     -- write to debug log
                     IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
                       okl_debug_pub.log_debug( FND_LOG.LEVEL_STATEMENT, l_module, 'pool applicable sub_pool_id '||lx_sub_pool_id||' amount '||lv_subsidy_amount);
                     END IF;
                     okl_subsidy_pool_auth_trx_pvt.create_pool_trx_khr_book(p_api_version   => p_api_version
                                                                           ,p_init_msg_list => p_init_msg_list
                                                                           ,x_return_status => x_return_status
                                                                           ,x_msg_count     => x_msg_count
                                                                           ,x_msg_data      => x_msg_data
                                                                           ,p_chr_id        => p_chrv_id
                                                                           ,p_asset_id      => l_subsidy_rec.asset_id
                                                                           ,p_subsidy_id    => l_subsidy_rec.subsidy_id
                                                                           ,p_subsidy_pool_id => lx_sub_pool_id
                                                                           ,p_trx_amount    => lv_subsidy_amount
                                                                           );
                     l_subsidy_valid_status := x_return_status;
                     IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
                       okl_debug_pub.log_debug( FND_LOG.LEVEL_STATEMENT, l_module, 'x_return_status being copied into l_subsidy_valid_status '||l_subsidy_valid_status
                                                ||' x_msg_data '||x_msg_data
                                               );
                     END IF; -- end of write to debug log
                   END IF; -- end of l_sub_pool_applicable = 'Y'
                 END IF; -- end of (l_subsidy_rec.effective_to_date + l_subsidy_rec.expire_after_days) < TRUNC(SYSDATE)
                   /*
                    * sjalasut added code for subsidy pools enhancement, the subsidy is checked for association
                    * with the subsidy pool, if associated, the authoring transaction api is invoked for
                    * validation and then create transaction. END
                    */
             END LOOP;
             CLOSE l_subsidy_csr;

             x_return_status := l_subsidy_valid_status;

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                       RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;


               --call process API to create Billing transactions for Subsidies ;
               OKL_SUBSIDY_PROCESS_PVT.CREATE_BILLING_TRX(
                             p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_chr_id        => p_chrv_id);

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                       RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;
           End If;
           -------------------------------------------------------------------------
           --Bug#i 3143522 : End Subsidies enhancement
           -------------------------------------------------------------------------

       /* dcshanmu 21-Jan-2008 end bug#6688570 */

        -- call the asset release api
        okl_activate_asset_pub.RELEASE_ASSET
                        (p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_rel_chr_id    => p_chrv_id);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 3533936 :
        --call the install base instance re_lease API
        okl_activate_ib_pvt.RELEASE_IB_INSTANCE
                        (p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_rel_chr_id    => p_chrv_id);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        --Bug#2522439 Start
        --code added to update status in OKL_ASSET_RETURNS_B
        --after the release asset transaction has been processed
        OPEN l_asr_csr(p_chrv_id);
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
        --Bug#2522439 End

    ELSE
        --bug# 2953906 :
         --check for billto status
        Validate_bill_To(p_chr_id        => p_chrv_id,
                         x_return_status => x_return_status);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        --bug # 2953906 end.

       -------------------------------------------------------------------------
        --Bug# 3541098: If Capitalize interest flag is set to 'NO', then
        --              calculate interest on pre-funding amount upto the
        --              booking date of the contract and create
        --              Billing transaction for the interest amount.
        ------------------------------------------------------------------------
       open cap_interest_rul_csr (p_chrv_id);
       fetch cap_interest_rul_csr  into l_capitalize_interest_flag;
       if cap_interest_rul_csr%NOTFOUND then
         l_capitalize_interest_flag := 'N';
       end if;
       close cap_interest_rul_csr;

       if NVL(l_capitalize_interest_flag,'N') = 'N' then

         open chr_csr(p_chrv_id);
         fetch chr_csr into l_contract_number,l_start_date;
         close chr_csr;

         okl_interest_calc_pub.calc_interest_activate
             (p_api_version        => p_api_version,
              p_init_msg_list      => p_init_msg_list,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,
              p_contract_number    => l_contract_number,
              p_Activation_date    => l_start_date,
              x_amount             => l_amount,
              x_source_id          => l_source_id);

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
       end if;
       -- Bug# 3541098 end.

        ---------------------------------------------------------------------------------------
        --Bug# 3143522: Subsidies enhancement : Check for expired subsidies and stop activation
        --                               Create billing transaction for 'BILL' subsidies
        ---------------------------------------------------------------------------------------
        l_subsidy_exists := OKL_API.G_FALSE;
        okl_subsidy_process_pvt.is_contract_subsidized
                          (p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chrv_id,
                          x_subsidized    => l_subsidy_exists);
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF l_subsidy_exists = OKL_API.G_TRUE THEN
          ---------------------------------------------------
          --check if expired subsidies exist for the contract
          ---------------------------------------------------
          l_subsidy_valid_status  := OKL_API.G_RET_STS_SUCCESS;
          OPEN l_subsidy_csr (p_chr_id => p_chrv_id);
          LOOP
              FETCH l_subsidy_csr INTO l_subsidy_rec;
              EXIT WHEN l_subsidy_csr%NOTFOUND;
              --Start : Bug 6050165 : prasjain
                l_applicable := 'N';
                  open l_cle_csr(p_subsidy_id   => l_subsidy_rec.subsidy_id,
                               p_asset_cle_id => l_subsidy_rec.asset_id);
                  Fetch l_cle_csr into l_applicable;
                  If l_cle_csr%NOTFOUND then
                      Null;
                  End If;
                  close l_cle_csr;

                  If (l_applicable = 'N') then
                      Okl_Api.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_SUBSIDY_CRITERIA_MATCH',
                              p_token1       => 'SUBSIDY_NAME',
                              p_token1_value => l_subsidy_rec.subsidy_name,
                              p_token2       => 'ASSET_NUMBER',
                              p_token2_value => l_subsidy_rec.asset_number);
                      l_subsidy_valid_status := OKL_API.G_RET_STS_ERROR;
                  end if;

                --IF((l_subsidy_rec.effective_to_date + l_subsidy_rec.expire_after_days) < TRUNC(SYSDATE))THEN
                 if( TRUNC(sysdate) not between TRUNC(l_subsidy_rec.effective_from_date) and
                    TRUNC(nvl(l_subsidy_rec.EFFECTIVE_TO_DATE,sysdate) + nvl(l_subsidy_rec.EXPIRE_AFTER_DAYS,0)))then
               --End : Bug 6050165 : prasjain
                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_SUBSIDY_EXPIRED',
                                    p_token1       => 'SUBSIDY',
                                    p_token1_value => l_subsidy_rec.subsidy_name,
                                    p_token2       => 'ASSET_NUMBER',
                                    p_token2_value => l_subsidy_rec.asset_number);
                l_subsidy_valid_status := OKL_API.G_RET_STS_ERROR;
              ELSE
                /*
                 * sjalasut added code for subsidy pools enhancement, the subsidy is checked for association
                 * with the subsidy pool, if associated, the authoring transaction api is invoked for
                 * validation and then create transaction. code logic being merged with subsidy expiration
                 * because only when subsidy is not expired and is associated with a pool, will the pool transaction occur.
                 * Further, it is not correct to indicate a validation failure on a subsidy pool transaction while the
                 * subsidy is actually exipred. START
                 */
                IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
                  okl_debug_pub.log_debug( FND_LOG.LEVEL_STATEMENT, l_module, 'verifying subsidy applicability over pool subsidy id '||l_subsidy_rec.subsidy_id);
                END IF;

                l_sub_pool_applicable := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => l_subsidy_rec.subsidy_id
                                                                                     ,x_subsidy_pool_id => lx_sub_pool_id
                                                                                     ,x_sub_pool_curr_code => lx_sub_pool_curr_code
                                                                                     );

                IF(l_sub_pool_applicable = 'Y')THEN
                  -- initialize for every iteration of the loop
                  lv_subsidy_amount := 0;
                  -- the amount for transaction is either the override amount if present or the calculated subsidy amount
                  lv_subsidy_amount := NVL(l_subsidy_rec.subsidy_override_amount,NVL(l_subsidy_rec.subsidy_amount,0));
                  -- write to debug log
                  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
                    okl_debug_pub.log_debug( FND_LOG.LEVEL_STATEMENT, l_module, 'pool applicable sub_pool_id '||lx_sub_pool_id||' amount '||lv_subsidy_amount);
                  END IF;
                  okl_subsidy_pool_auth_trx_pvt.create_pool_trx_khr_book(p_api_version   => p_api_version
                                                                        ,p_init_msg_list => p_init_msg_list
                                                                        ,x_return_status => x_return_status
                                                                        ,x_msg_count     => x_msg_count
                                                                        ,x_msg_data      => x_msg_data
                                                                        ,p_chr_id        => p_chrv_id
                                                                        ,p_asset_id      => l_subsidy_rec.asset_id
                                                                        ,p_subsidy_id    => l_subsidy_rec.subsidy_id
                                                                        ,p_subsidy_pool_id => lx_sub_pool_id
                                                                        ,p_trx_amount    => lv_subsidy_amount
                                                                        );
                  l_subsidy_valid_status := x_return_status;
                  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
                    okl_debug_pub.log_debug( FND_LOG.LEVEL_STATEMENT, l_module, 'x_return_status being copied into l_subsidy_valid_status '||l_subsidy_valid_status
                                             ||' x_msg_data '||x_msg_data
                                            );
                  END IF; -- end of write to debug log
                END IF; -- end of l_sub_pool_applicable = 'Y'
              END IF; -- end of (l_subsidy_rec.effective_to_date + l_subsidy_rec.expire_after_days) < TRUNC(SYSDATE)
                /*
                 * sjalasut added code for subsidy pools enhancement, the subsidy is checked for association
                 * with the subsidy pool, if associated, the authoring transaction api is invoked for
                 * validation and then create transaction. END
                 */
          END LOOP;
          CLOSE l_subsidy_csr;

          x_return_status := l_subsidy_valid_status;

            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;




            --call process API to create Billing transactions for Subsidies ;
            OKL_SUBSIDY_PROCESS_PVT.CREATE_BILLING_TRX(
                          p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chrv_id);

            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
        End If;
        -------------------------------------------------------------------------
        --Bug#i 3143522 : End Subsidies enhancement
        -------------------------------------------------------------------------

         --call fa activation API
        Okl_Activate_Asset_Pub.ACTIVATE_ASSET(p_api_version   => p_api_version,
                                              p_init_msg_list => p_init_msg_list,
        	                                  x_return_status => x_return_status,
         	                                  x_msg_count     => x_msg_count,
          	 	                              x_msg_data      => x_msg_data,
           	                                  p_chrv_id       => p_chrv_id,
                                              p_call_mode     => p_call_mode,
                                              x_cimv_tbl      => l_cimv_tbl_fa);

    	IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       		RAISE Okl_Api.G_EXCEPTION_ERROR;
    	END IF;

        --Bug# 2726870 : 11.5.9 enhancment Service contracts integration
        --call service integration api :
        okl_service_integration_pub.initiate_service_booking(
                                    p_api_version    => p_api_version,
                                    p_init_msg_list  => p_init_msg_list,
                                    x_return_status  => x_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_okl_chr_id     => p_chrv_id);

    	IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       		RAISE Okl_Api.G_EXCEPTION_ERROR;
    	END IF;

    	--call ib activation API
    	Okl_Activate_Ib_Pub.ACTIVATE_IB_INSTANCE(p_api_version   => p_api_version,
     	                                         p_init_msg_list => p_init_msg_list,
      	                                         x_return_status => x_return_status,
       	                                         x_msg_count     => x_msg_count,
        	                                     x_msg_data      => x_msg_data,
                                                 p_chrv_id       => p_chrv_id,
                                                 p_call_mode     => p_call_mode,
                                                 x_cimv_tbl      => l_cimv_tbl_ib);

	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       		RAISE Okl_Api.G_EXCEPTION_ERROR;
    	END IF;

        --check if usage line is there on the contract
        l_usage_khr := '?';
        OPEN l_chk_usage_csr (p_chr_id => p_chrv_id);
        FETCH l_chk_usage_csr INTO l_usage_khr;
        IF l_chk_usage_csr%NOTFOUND THEN
           NULL;
        END IF;
        CLOSE l_chk_usage_csr;

        IF l_usage_khr = '!' THEN
            --call ubb api for service contracts creation
            okl_ubb_integration_pub.create_ubb_contract(
                          p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chrv_id,
                          x_chr_id        => l_service_chr_id
                         );

            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       		    RAISE Okl_Api.G_EXCEPTION_ERROR;
    	    END IF;
        End If;

    END IF;

	  -- added update of okl_stream_trx_data.last_trx_state value
	  -- racheruv

      if l_rbk_khr = '!' then
	    l_contract_id := l_orig_khr_id;
      else
	    l_contract_id := p_chrv_id;
	  end if;

	  okl_streams_util.update_trx_state(l_contract_id, 'BOTH');

	  -- end update of okl_stream_trx_data.last_trx_state value

	    Okl_Api.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
	--dbms_output.put_line('Unexpected Error Routine');
    x_return_status :=Okl_Api.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'Okl_Api.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
	--dbms_output.put_line('2 Unexpected Error Routine');
    WHEN OTHERS THEN
    x_return_status :=Okl_Api.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
END ACTIVATE_CONTRACT;
END OKL_ACTIVATE_CONTRACT_PUB;

/
