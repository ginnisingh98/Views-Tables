--------------------------------------------------------
--  DDL for Package Body OKL_LA_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_ASSET_PVT" as
/* $Header: OKLRLAAB.pls 120.19 2007/07/19 18:28:07 asahoo noship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_INVALID_CRITERIA            CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
  G_COPY_HEADER                 CONSTANT VARCHAR2(200) := 'OKL_LLA_COPY_HEADER';
  G_COPY_LINE                   CONSTANT VARCHAR2(200) := 'OKL_LLA_COPY_LINE';
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE               CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
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
  G_PKG_NAME                  CONSTANT  VARCHAR2(200) := 'OKL_LA_ASSET_PVT';
  G_APP_NAME            CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_LEASE_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LEASE';
  G_LOAN_SCS_CODE                         OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LOAN';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';
-------------------------------------------------------------------------------------------------
-- cklee
  G_BULK_BATCH_SIZE                 CONSTANT  NUMBER := 10000;
-------------------------------------------------------------------------------------------------
-- cklee
  TYPE r_las_rec_type IS RECORD (asset_number          FA_ADDITIONS_B.ASSET_NUMBER%TYPE,
                                 year_manufactured     NUMBER := OKL_API.G_MISS_NUM,
                                 manufacturer_name     FA_ADDITIONS_B.MANUFACTURER_NAME%TYPE,
                                 description           FA_ADDITIONS_TL.DESCRIPTION%TYPE,
                                 current_units         NUMBER := OKL_API.G_MISS_NUM,
                                 oec                   NUMBER := OKL_API.G_MISS_NUM,
                                 vendor_name           PO_VENDORS.VENDOR_NAME%TYPE,
                                 residual_value        NUMBER := OKL_API.G_MISS_NUM,
                                 start_date            OKC_K_LINES_B.START_DATE%TYPE,
                                 date_terminated       OKC_K_LINES_B.DATE_TERMINATED%TYPE,
                                 end_date              OKC_K_LINES_B.END_DATE%TYPE,
                                 sts_code              OKC_K_LINES_B.STS_CODE%TYPE,
                                 location_id           VARCHAR(1995),
                                 parent_line_id        NUMBER := OKL_API.G_MISS_NUM,
                                 dnz_chr_id            NUMBER := OKL_API.G_MISS_NUM);

  TYPE las_loc_rec_type IS RECORD (location_id           VARCHAR(1995),
                                   parent_line_id        NUMBER := OKL_API.G_MISS_NUM,
                                   dnz_chr_id            NUMBER := OKL_API.G_MISS_NUM);

  TYPE las_loc_tbl_type IS TABLE OF las_loc_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE fin_line_tab_type IS TABLE OF NUMBER;
  TYPE loc_id_tab_type IS TABLE OF VARCHAR(1995);

  l_pre_asset_name okc_k_lines_tl.name%type;
  l_cur_asset_name okc_k_lines_tl.name%type;
  l_unique_asset_flag boolean := false;

-- cklee

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : search_loc
-- Description     : Search financial asset location using binary search
-- Business Rules  : 1. p_fin_line_tbl must be ascending order
--                   2. p_fin_line_tbl must be continue without
--                      null node
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

FUNCTION search_loc(
           fin_line_id    in number,
           p_fin_line_tbl in fin_line_tab_type,
           tot_count      in number) return number
is

 low number;
 high number;
 mid number;

begin

  -- stop search if total count = 0
  if (tot_count = 0) then
    return null;
  end if;

  low := p_fin_line_tbl.FIRST;
  high := tot_count;
  while (low <= high) loop
--START:|           08-Sept-2004  cklee  Fixed bug#4705572                           |
--    mid := (low+high) / 2;
    mid := ROUND((low+high) / 2);
--END  :|           08-Sept-2004  cklee  Fixed bug#4705572                           |
    if (fin_line_id < p_fin_line_tbl(mid)) then
      high := mid - 1;
    elsif (fin_line_id > p_fin_line_tbl(mid)) then
      low := mid + 1;
    else
      exit;
    end if;
  end loop;

  return mid;

exception
  when others then
    return null;
end search_loc;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_asset_rec
-- Description     : copy asset record and remove duplicated asset number
--                   copy location if it's an active contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE copy_asset_rec(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_las_rec                      IN r_las_rec_type
   ,p_idx                          IN NUMBER
   ,p_active_contract              IN BOOLEAN default false
   ,p_fin_line_ids                 IN fin_line_tab_type default null
   ,p_loc_ids                      IN loc_id_tab_type default null
   ,p_fin_line_2_ids               IN fin_line_tab_type default null
   ,p_loc_2_ids                    IN loc_id_tab_type default null
   ,x_las_rec                      OUT NOCOPY las_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'copy_asset_rec';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_location_id      VARCHAR2(1995) := NULL;
  l_loc_idx          NUMBER := NULL;

--START:|           01-Mar-2006  cklee  Fixed bug#4728228                            |
  l_sub_tot          NUMBER;

    cursor l_sub_tot_csr(p_asset_cle_id in number) is
    select nvl(sum(nvl(sub_kle.subsidy_override_amount,nvl(sub_kle.amount,0))),0)
    from   okl_subsidies_b    subb,
           okl_k_lines        sub_kle,
           okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    where  subb.id                     = sub_kle.subsidy_id
    and    subb.accounting_method_code = 'NET'
    and    sub_kle.id                  = sub_cle.id
    and    sub_cle.cle_id              = p_asset_cle_id
    and    sub_cle.lse_id              = sub_lse.id
    and    sub_lse.lty_code            = 'SUBSIDY';
--END:|           01-Mar-2006  cklee  Fixed bug#4728228                            |

begin
  -- Set API savepoint
  SAVEPOINT copy_asset_rec;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


--*** Begin API body ****************************************************

-- cklee: remove duplicated rows for asset
  -- initialization

  if (p_idx = 0) then
    l_cur_asset_name := p_las_rec.asset_number;
    l_unique_asset_flag := true;
  -- Compare if duplicated asset number found
  else
    l_pre_asset_name := l_cur_asset_name;
    l_cur_asset_name := p_las_rec.asset_number;
    if (l_pre_asset_name = l_cur_asset_name) then
      l_unique_asset_flag := false;
    else
      l_unique_asset_flag := true;
    end if;
  end if;

  if (l_unique_asset_flag = true) then

    x_las_rec.asset_number         := p_las_rec.asset_number;
    x_las_rec.year_manufactured    := p_las_rec.year_manufactured;
    x_las_rec.manufacturer_name    := p_las_rec.manufacturer_name;
    x_las_rec.description          := p_las_rec.description;
    x_las_rec.current_units        := p_las_rec.current_units;
    x_las_rec.from_oec             := p_las_rec.oec;
--START:|           01-Mar-2006  cklee  Fixed bug#4728228                            |
--    x_las_rec.to_oec               := NVL((p_las_rec.oec -
--                                         OKL_SEEDED_FUNCTIONS_PVT.line_discount(p_las_rec.dnz_chr_id, p_las_rec.parent_line_id)),
--                                                          p_las_rec.oec);
    open l_sub_tot_csr(p_las_rec.parent_line_id);
    fetch l_sub_tot_csr into l_sub_tot;
    close l_sub_tot_csr;
    x_las_rec.to_oec               := NVL((p_las_rec.oec - l_sub_tot), p_las_rec.oec);

--END:|           01-Mar-2006  cklee  Fixed bug#4728228                            |
    x_las_rec.vendor_name          := p_las_rec.vendor_name;
    x_las_rec.from_residual_value  := p_las_rec.residual_value;
    x_las_rec.from_start_date      := p_las_rec.start_date;
    x_las_rec.from_end_date        := p_las_rec.end_date;
    x_las_rec.from_date_terminated := p_las_rec.date_terminated;
    x_las_rec.sts_code             := p_las_rec.sts_code;
    x_las_rec.location_id          := p_las_rec.location_id;
    x_las_rec.parent_line_id       := p_las_rec.parent_line_id;
    x_las_rec.dnz_chr_id           := p_las_rec.dnz_chr_id;

  end if;

  -- get location from FA if it's an active contract
  IF p_active_contract THEN

    -- search the 1st location set
    l_loc_idx :=  search_loc(fin_line_id     => p_las_rec.parent_line_id,
                             p_fin_line_tbl  => p_fin_line_ids,
                             tot_count       => p_fin_line_ids.COUNT);
    IF l_loc_idx IS NULL THEN
      -- search the 2nd location set
      l_loc_idx :=  search_loc(fin_line_id     => p_las_rec.parent_line_id,
                               p_fin_line_tbl  => p_fin_line_2_ids,
                               tot_count       => p_fin_line_2_ids.COUNT);
      IF l_loc_idx IS NOT NULL THEN
        l_location_id := p_loc_2_ids(l_loc_idx);
      END IF;
    ELSE
        l_location_id := p_loc_ids(l_loc_idx);
    END IF;

   ELSE -- non active contract

    -- search the location set
    l_loc_idx :=  search_loc(fin_line_id     => p_las_rec.parent_line_id,
                             p_fin_line_tbl  => p_fin_line_ids,
                             tot_count       => p_fin_line_ids.COUNT);
    IF l_loc_idx IS NOT NULL THEN
      l_location_id := p_loc_ids(l_loc_idx);
    END IF;

   END IF;

   x_las_rec.location_id := l_location_id;


--*** End API body ******************************************************

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO copy_asset_rec;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_asset_rec;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO copy_asset_rect;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end copy_asset_rec;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_asset_rec
-- Description     : validate asset search criteria
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE validate_asset_rec(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_las_rec                      IN las_rec_type
   ,x_las_rec                      OUT NOCOPY las_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'validate_asset_rec';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_las_rec          las_rec_type := p_las_rec;

begin
  -- Set API savepoint
  SAVEPOINT validate_asset_rec;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


--*** Begin API body ****************************************************

    -- initial copy record
    x_las_rec := l_las_rec;

    IF l_las_rec.dnz_chr_id IS NULL OR
       l_las_rec.dnz_chr_id = OKL_API.G_MISS_NUM THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (l_las_rec.year_manufactured = OKL_API.G_MISS_NUM OR
       l_las_rec.year_manufactured IS NULL) THEN
       x_las_rec.year_manufactured := null;
    END IF;
    IF (l_las_rec.current_units = OKL_API.G_MISS_NUM OR
       l_las_rec.current_units IS NULL) THEN
       x_las_rec.current_units := null;
    END IF;
    IF (l_las_rec.from_oec = OKL_API.G_MISS_NUM OR
       l_las_rec.from_oec IS NULL) THEN
       x_las_rec.from_oec := null;
    END IF;
    IF (l_las_rec.to_oec = OKL_API.G_MISS_NUM OR
       l_las_rec.to_oec IS NULL) THEN
       x_las_rec.to_oec := null;
    END IF;
    IF (l_las_rec.from_residual_value = OKL_API.G_MISS_NUM OR
       l_las_rec.from_residual_value IS NULL) THEN
       x_las_rec.from_residual_value := null;
    END IF;
    IF (l_las_rec.to_residual_value = OKL_API.G_MISS_NUM OR
       l_las_rec.to_residual_value IS NULL) THEN
       x_las_rec.to_residual_value := null;
    END IF;
    IF (l_las_rec.parent_line_id = OKL_API.G_MISS_NUM OR
       l_las_rec.parent_line_id IS NULL) THEN
       x_las_rec.parent_line_id := null;
    END IF;
    IF (l_las_rec.from_start_date = OKL_API.G_MISS_DATE  OR
       l_las_rec.from_start_date IS NULL)  THEN
       x_las_rec.from_start_date := null;
    END IF;
    IF (l_las_rec.to_start_date = OKL_API.G_MISS_DATE  OR
       l_las_rec.to_start_date IS NULL)  THEN
       x_las_rec.to_start_date := null;
    END IF;
    IF (l_las_rec.from_end_date = OKL_API.G_MISS_DATE  OR
       l_las_rec.from_end_date IS NULL)  THEN
       x_las_rec.from_end_date := null;
    END IF;
    IF (l_las_rec.to_end_date = OKL_API.G_MISS_DATE  OR
       l_las_rec.to_end_date IS NULL)  THEN
       x_las_rec.to_end_date := null;
    END IF;
    IF (l_las_rec.from_date_terminated = OKL_API.G_MISS_DATE OR
       l_las_rec.from_date_terminated IS NULL) THEN
       x_las_rec.from_date_terminated := null;
    END IF;
    IF (l_las_rec.to_date_terminated = OKL_API.G_MISS_DATE OR
       l_las_rec.to_date_terminated IS NULL) THEN
       x_las_rec.to_date_terminated := null;
    END IF;
    IF (l_las_rec.asset_number = OKL_API.G_MISS_CHAR OR
       l_las_rec.asset_number IS NULL) THEN
       x_las_rec.asset_number := null;
    END IF;
    IF (l_las_rec.manufacturer_name = OKL_API.G_MISS_CHAR  OR
       l_las_rec.manufacturer_name IS NULL) THEN
       x_las_rec.manufacturer_name := null;
    END IF;
    IF (l_las_rec.description = OKL_API.G_MISS_CHAR OR
       l_las_rec.description IS NULL) THEN
       x_las_rec.description := null;
    END IF;
    IF (l_las_rec.sts_code = OKL_API.G_MISS_CHAR OR
       l_las_rec.sts_code IS NULL) THEN
       x_las_rec.sts_code := null;
    END IF;
    IF (l_las_rec.vendor_name = OKL_API.G_MISS_CHAR OR
       l_las_rec.vendor_name IS NULL) THEN
       x_las_rec.vendor_name := null;
    END IF;
    IF (l_las_rec.location_id = OKL_API.G_MISS_CHAR OR
       l_las_rec.location_id IS NULL) THEN
       x_las_rec.location_id := null;
    END IF;

--*** End API body ******************************************************

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO validate_asset_rec;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO validate_asset_rec;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO validate_asset_rec;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end validate_asset_rec;

-----------------------------------------------------------------------------------------------------------

  FUNCTION isReleaseAssetContract(p_dnz_chr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE DEFAULT OKL_API.G_MISS_NUM)
  RETURN BOOLEAN IS
    l_status_active     BOOLEAN := FALSE;
    l_return_value      VARCHAR2(1) := '';
    --cursor to check if contract has re-lease assets
    CURSOR l_chk_rel_ast_csr (p_chr_id IN Number) IS
    SELECT 'x'
    FROM    okc_k_headers_b CHR
    WHERE   nvl(chr.orig_system_source_code,'XXXX') <> 'OKL_RELEASE'
    AND     chr.ID = p_chr_id
    AND     exists (SELECT '1'
               FROM   OKC_RULES_B rul
               WHERE  rul.dnz_chr_id = chr.id
               AND    rul.rule_information_category = 'LARLES'
               AND    nvl(rule_information1,'N') = 'Y');

  BEGIN

    -- Check the deal type of the contract
    -- If it is not LOAN or LOAN_REVOLVING, check the cursors c_check_assets_in_fa
    -- and c_check_assets_in_txl
    OPEN l_chk_rel_ast_csr(p_dnz_chr_id);
    FETCH l_chk_rel_ast_csr INTO l_return_value;
    l_status_active := l_chk_rel_ast_csr%FOUND;
    CLOSE l_chk_rel_ast_csr;

    IF (l_status_active) THEN
      return TRUE;
    ELSE
      return FALSE;
    END IF;
  END isReleaseAssetContract;

-------------------------------------------------------------------------------------------------

/*
   This check is made for the following.
   If the Contract has gone through processes (ex: Mass Rebook) after booking,
   and failed. Say, the contract status remained as 'APPROVED', when it failed.
   Now, the asset screens display information from TXL, as the contract status
   is 'APPROVED'. As the above mentioned transaction failed, the line level
   transaction invoked doesn't complete. Asset summary picks up the duplicate
   assets. To avoid this, we are checking for object1_id1, object1_id2 values in
   OKC_K_ITEMS. If they are populated, we treat is as a active contract else an
   inactive one.

   This function checks whether the asset information of the contract exists in
   FA, IB and TXL. If the information exists in FA, IB, then it is treated as a
   active contract and the information will be picked up from FA, else if it
   exists in TXL, the information should be retrieved from there. If it exists at
   both places, it is error.
*/

  FUNCTION isContractActive(p_dnz_chr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                            p_deal_type  IN OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE,
                            p_sts_code   IN OKL_K_HEADERS_FULL_V.STS_CODE%TYPE)
  RETURN BOOLEAN IS
    l_active_status     BOOLEAN := FALSE;
    l_inactive_status   BOOLEAN := FALSE;
    l_release_asset_contract   BOOLEAN := FALSE;
    l_status_active     BOOLEAN := FALSE;
    l_return_value      VARCHAR2(1) := '';
    CURSOR c_check_assets_in_fa(p_dnz_chr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT 'x'
/*    FROM dual
    WHERE exists
        (SELECT (1) */
         FROM OKC_K_LINES_B cle,
              OKC_K_ITEMS itm,
              OKC_LINE_STYLES_B lse,
              OKC_STATUSES_B sts
         WHERE cle.dnz_chr_id = p_dnz_chr_id
         AND itm.dnz_chr_id = cle.dnz_chr_id
         AND itm.cle_id = cle.id
         AND lse.id = cle.lse_id
         AND lse.lty_code = 'FIXED_ASSET'
         AND itm.object1_id1 is not null
         AND itm.object1_id2 is not null
         AND sts.code = cle.sts_code;
--START:|           14-Mar-2006  cklee  Fixed bug#4905107                            |
--         AND sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');--);
--END:|           14-Mar-2006  cklee  Fixed bug#4905107                            |

    CURSOR c_check_info_in_ib(p_dnz_chr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT 'x'
/*    FROM dual
    WHERE exists
        (SELECT (1) */
         FROM OKC_K_LINES_B cle,
              OKC_K_ITEMS itm,
              OKC_LINE_STYLES_B lse,
              OKC_STATUSES_B sts
         WHERE cle.dnz_chr_id = p_dnz_chr_id
         AND itm.dnz_chr_id = cle.dnz_chr_id
         AND itm.cle_id = cle.id
         AND lse.id = cle.lse_id
         AND lse.lty_code = 'INST_ITEM'
         AND itm.object1_id1 is not null
         AND itm.object1_id2 is not null
         AND sts.code = cle.sts_code;
--START:|           14-Mar-2006  cklee  Fixed bug#4905107                            |
--         AND sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');--);
--END:|           14-Mar-2006  cklee  Fixed bug#4905107                            |

    CURSOR c_check_assets_in_txl(p_dnz_chr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT 'x'
/*    FROM dual
    WHERE exists
        (SELECT (1) */
         FROM OKC_K_LINES_B cle,
              OKC_K_ITEMS itm,
              OKC_LINE_STYLES_B lse,
              OKC_STATUSES_B sts
         WHERE cle.dnz_chr_id = p_dnz_chr_id
         AND itm.dnz_chr_id = cle.dnz_chr_id
         AND itm.cle_id = cle.id
         AND lse.id = cle.lse_id
         AND lse.lty_code = 'FIXED_ASSET'
         AND itm.object1_id1 is null
         AND itm.object1_id2 is null
         AND sts.code = cle.sts_code;
--START:|           14-Mar-2006  cklee  Fixed bug#4905107                            |
--         AND sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');--);
--END:|           14-Mar-2006  cklee  Fixed bug#4905107                            |

  BEGIN

    -- Check for Re-Lease Asset contract
    l_release_asset_contract := isReleaseAssetContract(p_dnz_chr_id);

    IF (p_sts_code IS NOT NULL AND (p_sts_code = 'BOOKED' OR
                                    p_sts_code = 'TERMINATED' OR
                                    p_sts_code = 'AMENDED' OR
                                    p_sts_code = 'EXPIRED' OR
                                    p_sts_code = 'ACTIVE')) THEN
      l_status_active := TRUE;
    END IF;

    IF (l_release_asset_contract AND l_status_active) THEN
      RETURN TRUE;
    ELSIF (l_release_asset_contract AND NOT l_status_active) THEN
      RETURN FALSE;
    END IF;
    --End

    -- Check the deal type of the contract
    -- If it is not LOAN or LOAN_REVOLVING, check the cursors c_check_assets_in_fa
    -- and c_check_assets_in_txl
    IF (p_deal_type IS NOT NULL AND (p_deal_type <> 'LOAN' AND
                                     p_deal_type <> 'LOAN-REVOLVING')) THEN
        OPEN c_check_assets_in_fa(p_dnz_chr_id);
        FETCH c_check_assets_in_fa INTO l_return_value;
        l_active_status := c_check_assets_in_fa%FOUND;
        CLOSE c_check_assets_in_fa;

        OPEN c_check_assets_in_txl(p_dnz_chr_id);
        FETCH c_check_assets_in_txl INTO l_return_value;
        l_inactive_status := c_check_assets_in_txl%FOUND;
        CLOSE c_check_assets_in_txl;

        IF (l_active_status AND NOT l_inactive_status) THEN
            return TRUE;
        ELSIF (NOT l_active_status AND l_inactive_status) THEN
            return FALSE;
        -- Following case is handled at the Asset Summary screen UI itself,
        -- thus allowing the user not to access the screen, by displaying
        --  the respective message.
/*        ELSIF (l_active_status AND l_inactive_status) THEN
            return FALSE;
          OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
           RAISE G_EXCEPTION_STOP_VALIDATION;*/
        END IF;
    ELSE    -- Contract is either 'LOAN' or 'LOAN-REVOLVING'
        OPEN c_check_assets_in_fa(p_dnz_chr_id);
        FETCH c_check_assets_in_fa INTO l_return_value;
        l_active_status := c_check_assets_in_fa%FOUND;
        CLOSE c_check_assets_in_fa;

        IF (l_active_status) THEN
          return TRUE;  -- Info exists in FA
        ELSE
          IF (l_status_active) THEN
            return TRUE;  -- Deduced basing on contract status
          ELSE
            OPEN c_check_info_in_ib(p_dnz_chr_id);
            FETCH c_check_info_in_ib INTO l_return_value;
            l_active_status := c_check_info_in_ib%FOUND;
            CLOSE c_check_info_in_ib;

            IF (l_active_status) THEN
              return TRUE;  -- Info exists in IB
            ELSE
              return FALSE;
            END IF;
          END IF;
        END IF;
    END IF;
    return FALSE;
  END isContractActive;
-------------------------------------------------------------------------------------------------

--  Procedure generate_asset_summary(
-------------------------------------------------------------------------------------------------

  Procedure generate_asset_summary(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_las_rec              IN  las_rec_type,
            x_las_tbl              OUT NOCOPY las_tbl_type)
  AS
  l_api_version    CONSTANT NUMBER := 1;
  l_api_name       CONSTANT VARCHAR2(30) := 'VERSION_CONTRACT';
  lv_sts_code               OKC_K_HEADERS_V.STS_CODE%TYPE;
  lv_deal_type              OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE;
  i                         NUMBER := 0;
  l_las_rec                 las_rec_type := p_las_rec;
  l_active_contract         BOOLEAN := FALSE;
  l_info_exists             BOOLEAN := FALSE;
  l_return_value            VARCHAR2(1) := '';

-- cklee
  l_fin_line_ids            fin_line_tab_type;
  l_loc_ids                 loc_id_tab_type;
  l_fin_line_2_ids          fin_line_tab_type;
  l_loc_2_ids               loc_id_tab_type;
  lx_las_rec                las_rec_type;


 CURSOR c_get_old_asset_loc(p_dnz_chr_id number)
  IS
    -- start abhaxen modiyied for SQL Performance

  select cle_fin.id fin_line_id,
         substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,null, null,null,null,null,null,null,'n','n',80,1,1),1,80) location_id
  from hz_locations hl,
       csi_item_instances csi,
       okc_k_items cim_ib,
       okc_line_styles_b lse_ib,
       okc_k_lines_b cle_ib,
       okc_line_styles_b lse_inst,
       okc_k_lines_b cle_inst,
       okc_line_styles_b lse_fin,
       okc_k_lines_b cle_fin
 where cle_fin.cle_id is null
   and cle_fin.chr_id = cle_fin.dnz_chr_id
   and lse_fin.id = cle_fin.lse_id
   and lse_fin.lty_code = 'FREE_FORM1'
   and cle_inst.cle_id = cle_fin.id
   and cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
   and cle_inst.lse_id = lse_inst.id
   and lse_inst.lty_code = 'FREE_FORM2'
   and cle_ib.cle_id = cle_inst.id
   and cle_ib.dnz_chr_id = cle_inst.dnz_chr_id
   and cle_ib.lse_id = lse_ib.id
   and lse_ib.lty_code = 'INST_ITEM'
   and cim_ib.cle_id = cle_ib.id
   and cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
   and cim_ib.object1_id1 = csi.instance_id
   and cim_ib.object1_id2 = '#'
   and cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
--   and   csi.location_type_code = 'HZ_LOCATIONS'
--   and csi.location_id = hl.location_id
   and   csi.install_location_type_code = 'HZ_LOCATIONS' -- cklee
   and csi.install_location_id = hl.location_id -- cklee
   and   cle_fin.dnz_chr_id = p_dnz_chr_id
  order by cle_fin.id asc;
  -- end abhaxen modiyied for SQL Performance

 CURSOR c_get_old_asset_party_loc(p_dnz_chr_id number)
  IS
    -- start abhaxen modiyied for SQL Performance

  select  cle_fin.id fin_line_id,
          substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,null, null,null,null,null,null,null,'n','n',80,1,1),1,80) location_id
  from hz_locations hl,
       hz_party_sites hps,
       --Bug# 3569441 :
       --hz_party_site_uses hpsu,
       csi_item_instances csi,
       okc_k_items cim_ib,
       okc_line_styles_b lse_ib,
       okc_k_lines_b cle_ib,
       okc_line_styles_b lse_inst,
       okc_k_lines_b cle_inst,
       okc_line_styles_b lse_fin,
       okc_k_lines_b cle_fin
 where cle_fin.cle_id is null
   and cle_fin.chr_id = cle_fin.dnz_chr_id
   and lse_fin.id = cle_fin.lse_id
   and lse_fin.lty_code = 'FREE_FORM1'
   and cle_inst.cle_id = cle_fin.id
   and cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
   and cle_inst.lse_id = lse_inst.id
   and lse_inst.lty_code = 'FREE_FORM2'
   and cle_ib.cle_id = cle_inst.id
   and cle_ib.dnz_chr_id = cle_inst.dnz_chr_id
   and cle_ib.lse_id = lse_ib.id
   and lse_ib.lty_code = 'INST_ITEM'
   and cim_ib.cle_id = cle_ib.id
   and cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
   and cim_ib.object1_id1 = csi.instance_id
   and cim_ib.object1_id2 = '#'
   and cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
   --Bug# 3569441 :
   --and csi.install_location_id = hpsu.party_site_use_id
   and csi.install_location_id = hps.party_site_id
   and csi.install_location_type_code = 'HZ_PARTY_SITES'
   --and hpsu.site_use_type = 'INSTALL_AT'
   --and hpsu.party_site_id = hps.party_site_id
   and hps.location_id = hl.location_id
   and   cle_fin.dnz_chr_id = p_dnz_chr_id
  order by cle_fin.id asc;
  -- end abhaxen modiyied for SQL Performance

-- cklee
--
 CURSOR c_get_new_asset_loc(p_dnz_chr_id number)
  IS
  -- start abhaxen modiyied for SQL Performance
        select cle_fin.id fin_line_id,
               substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,null, null,null,null,null,null,null,'n','n',80,1,1),1,80) location_id
        from hz_locations hl,
             hz_party_sites hps,
             hz_party_site_uses hpsu,
             okl_txl_itm_insts iti,
             okc_line_styles_b lse_ib,
             okc_k_lines_b cle_ib,
             okc_line_styles_b lse_inst,
             okc_k_lines_b cle_inst,
             okc_line_styles_b lse_fin,
             okc_k_lines_b cle_fin
        where cle_fin.cle_id is null
        and cle_fin.chr_id = cle_fin.dnz_chr_id
        and lse_fin.id = cle_fin.lse_id
        and lse_fin.lty_code = 'FREE_FORM1'
        and cle_inst.cle_id = cle_fin.id
        and cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
        and cle_inst.lse_id = lse_inst.id
        and lse_inst.lty_code = 'FREE_FORM2'
        and cle_ib.cle_id = cle_inst.id
        and cle_ib.dnz_chr_id = cle_inst.dnz_chr_id
        and cle_ib.lse_id = lse_ib.id
        and lse_ib.lty_code = 'INST_ITEM'
        and iti.kle_id = cle_ib.id
        and iti.object_id1_new = hpsu.party_site_use_id
        and iti.object_id2_new = '#'
        and hpsu.party_site_id = hps.party_site_id
        and hps.location_id = hl.location_id
   and   cle_fin.dnz_chr_id = p_dnz_chr_id
  order by cle_fin.id asc;
  -- end abhaxen modiyied for SQL Performance
--


  CURSOR c_get_new_asset_desc(p_las_rec IN las_rec_type)
  IS
  select nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
--         sts.meaning sts_code,
--         nalc.location_id location_id,
--         nast.fin_line_id parent_line_id,
         nast.parent_line_id,
         nast.dnz_chr_id
from okl_new_assets_uv nast
  where nast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(nast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(nast.asset_number))
  and nvl(upper(nast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(nast.vendor_name),'x'))
  and nast.oec between nvl(p_las_rec.from_oec,nast.oec) and nvl(p_las_rec.to_oec,nast.oec)
  and nvl(nast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(nast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(nast.residual_value,0))
  and upper(nast.description) like nvl(upper(p_las_rec.description),upper(nast.description))
  and nast.sts_code like nvl(p_las_rec.sts_code,nast.sts_code)
  and nvl(nast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(nast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(nast.start_date,to_date('1111','yyyy')))
  and nvl(nast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(nast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(nast.end_date,to_date('1111','yyyy')))
  and nvl(nast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy')))
--  and nvl(upper(nalc.location_id),'x') like nvl(upper(p_las_rec.location_id),nvl(upper(nalc.location_id),'x'))
--  and nast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and nast.sts_code <> 'ABANDONED'
--  and nast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
 --bug# 4202325 : added following condition
 and nast.ASSET_STATUS_CODE <> 'ABANDONED'

  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) desc;

 CURSOR c_get_old_asset_desc(p_las_rec IN las_rec_type)
      IS
  select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
--         sts.meaning sts_code,
--         oalc.location_id location_id,
--         oast.fin_line_id parent_line_id,
         oast.parent_line_id,
         oast.dnz_chr_id
from okl_old_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
--  and nvl(upper(oalc.location_id),'x') like nvl(upper(p_las_rec.location_id),nvl(upper(oalc.location_id),'x'))
--  and oast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and oast.sts_code <> 'ABANDONED'
--  and oast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
  and oast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) desc;

  CURSOR c_get_new_asset_asc(p_las_rec IN las_rec_type)
  IS
  select nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
--         sts.meaning sts_code,
--         nalc.location_id location_id,
--         nast.fin_line_id parent_line_id,
         nast.parent_line_id,
         nast.dnz_chr_id
from okl_new_assets_uv nast
  where nast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(nast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(nast.asset_number))
  and nvl(upper(nast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(nast.vendor_name),'x'))
  and nast.oec between nvl(p_las_rec.from_oec,nast.oec) and nvl(p_las_rec.to_oec,nast.oec)
  and nvl(nast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(nast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(nast.residual_value,0))
  and upper(nast.description) like nvl(upper(p_las_rec.description),upper(nast.description))
  and nast.sts_code like nvl(p_las_rec.sts_code,nast.sts_code)
  and nvl(nast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(nast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(nast.start_date,to_date('1111','yyyy')))
  and nvl(nast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(nast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(nast.end_date,to_date('1111','yyyy')))
  and nvl(nast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy')))
--  and nvl(upper(nalc.location_id),'x') like nvl(upper(p_las_rec.location_id),nvl(upper(nalc.location_id),'x'))
--  and nast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and nast.sts_code <> 'ABANDONED'
--  and nast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
 --bug# 4202325 : added following condition
 and nast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) asc;

 CURSOR c_get_old_asset_asc(p_las_rec IN las_rec_type)
  IS
  select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
--         sts.meaning sts_code,
--         oalc.location_id location_id,
--         oast.fin_line_id parent_line_id,
         oast.parent_line_id,
         oast.dnz_chr_id
from okl_old_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
--  and nvl(upper(oalc.location_id),'x') like nvl(upper(p_las_rec.location_id),nvl(upper(oalc.location_id),'x'))
--  and oast.dnz_chr_id = p_las_rec.dnz_chr_id
-- and oast.sts_code <> 'ABANDONED'
--  and oast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
  and oast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) asc;
  CURSOR c_get_sts_code(p_chr_id OKC_K_HEADERS_V.ID%TYPE)
  IS
  SELECT st.ste_code,
         khr.deal_type
--  FROM OKL_K_HEADERS_FULL_V chr,
  FROM okc_k_headers_b chr,
       okl_k_headers khr,
       okc_statuses_b st
  WHERE khr.id = chr.id
  and   chr.id = p_chr_id
  and   st.code = chr.sts_code;

  CURSOR c_check_assets_in_fa(p_dnz_chr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT 'x'
    /*FROM dual
    WHERE exists
        (SELECT (1)*/
         FROM OKC_K_LINES_B cle,
              OKC_K_ITEMS itm,
              OKC_LINE_STYLES_B lse,
              OKC_STATUSES_B sts
         WHERE cle.dnz_chr_id = p_dnz_chr_id
         AND itm.dnz_chr_id = cle.dnz_chr_id
         AND itm.cle_id = cle.id
         AND lse.id = cle.lse_id
         AND lse.lty_code = 'FIXED_ASSET'
         AND itm.object1_id1 is not null
         AND itm.object1_id2 is not null
         AND sts.code = cle.sts_code
         AND sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');--);

-- Start --> Cursors for Loan Contracts
 CURSOR c_get_old_loan_asset_desc(p_las_rec IN las_rec_type)
  IS
  select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
--         sts.meaning sts_code,
--         oalc.location_id location_id,
--         oast.fin_line_id parent_line_id,
         oast.parent_line_id,
         oast.dnz_chr_id
from okl_old_loan_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
--  and oast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and oast.sts_code <> 'ABANDONED'
--  and oast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
  and oast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) desc;

 CURSOR c_get_old_loan_asset_asc(p_las_rec IN las_rec_type)
  IS
  select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
--         sts.meaning sts_code,
--         oalc.location_id location_id,
--         oast.fin_line_id parent_line_id,
         oast.parent_line_id,
         oast.dnz_chr_id
from okl_old_loan_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
--  and oast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and oast.sts_code <> 'ABANDONED'
--  and oast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
  and oast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) asc;

 CURSOR c_get_new_loan_asset_desc(p_las_rec IN las_rec_type)
  IS
  select nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
--         sts.meaning sts_code,
--         nalc.location_id location_id,
--         nast.fin_line_id parent_line_id,
         nast.parent_line_id,
         nast.dnz_chr_id
from okl_new_loan_assets_uv nast
  where nast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(nast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(nast.asset_number))
  and nvl(upper(nast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(nast.vendor_name),'x'))
  and nast.oec between nvl(p_las_rec.from_oec,nast.oec) and nvl(p_las_rec.to_oec,nast.oec)
  and nvl(nast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(nast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(nast.residual_value,0))
  and upper(nast.description) like nvl(upper(p_las_rec.description),upper(nast.description))
  and nast.sts_code like nvl(p_las_rec.sts_code,nast.sts_code)
  and nvl(nast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(nast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(nast.start_date,to_date('1111','yyyy')))
  and nvl(nast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(nast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(nast.end_date,to_date('1111','yyyy')))
  and nvl(nast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy')))
--  and nast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and nast.sts_code <> 'ABANDONED'
--  and nast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
--bug#4202325 Added following condition
  and nast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) desc;

 CURSOR c_get_new_loan_asset_asc(p_las_rec IN las_rec_type)
  IS
  select nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
--         sts.meaning sts_code,
--         nalc.location_id location_id,
--         nast.fin_line_id parent_line_id,
         nast.parent_line_id,
         nast.dnz_chr_id
from okl_new_loan_assets_uv nast
  where nast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(nast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(nast.asset_number))
  and nvl(upper(nast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(nast.vendor_name),'x'))
  and nast.oec between nvl(p_las_rec.from_oec,nast.oec) and nvl(p_las_rec.to_oec,nast.oec)
  and nvl(nast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(nast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(nast.residual_value,0))
  and upper(nast.description) like nvl(upper(p_las_rec.description),upper(nast.description))
  and nast.sts_code like nvl(p_las_rec.sts_code,nast.sts_code)
  and nvl(nast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(nast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(nast.start_date,to_date('1111','yyyy')))
  and nvl(nast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(nast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(nast.end_date,to_date('1111','yyyy')))
  and nvl(nast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(nast.date_terminated,to_date('1111','yyyy')))
--  and nast.dnz_chr_id = p_las_rec.dnz_chr_id
--  and nast.sts_code <> 'ABANDONED'
--  and nast.sts_code = sts.code
--  and sts.LANGUAGE = userenv('LANG')
--bug#4202325 Added following condition
  and nast.ASSET_STATUS_CODE <> 'ABANDONED'
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) asc;

-- End   --> Cursors for Loan Contracts
--Bug# 4202325: Added cursor for split asset -start

CURSOR c_get_old_splt_asset_desc(p_las_rec IN las_rec_type)
IS
 select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
         oast.parent_line_id,
         oast.dnz_chr_id
 from okl_old_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
  and (	oast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	oast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = oast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  oast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
  )
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) desc;

 CURSOR c_get_old_splt_asset_asc(p_las_rec IN las_rec_type)
 IS
 select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
--         sts.meaning sts_code,
--         oalc.location_id location_id,
--         oast.fin_line_id parent_line_id,
         oast.parent_line_id,
         oast.dnz_chr_id
 from okl_old_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
  and (	oast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	oast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = oast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  oast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
  )
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) asc;



CURSOR c_get_old_splt_loan_asset_desc(p_las_rec IN las_rec_type)
  IS
  select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
         oast.parent_line_id,
         oast.dnz_chr_id
from okl_old_loan_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
  and (	oast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	oast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = oast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  oast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
  )
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) desc;

 CURSOR c_get_old_splt_loan_asset_asc(p_las_rec IN las_rec_type)
  IS
  select oast.asset_number,
         oast.year_manufactured,
         oast.manufacturer_name,
         oast.description,
         oast.current_units,
         oast.oec,
         oast.vendor_name,
         oast.residual_value,
         oast.start_date,
         oast.end_date,
         oast.date_terminated,
         oast.sts_code,
         oast.location_id,
         oast.parent_line_id,
         oast.dnz_chr_id
from okl_old_loan_assets_uv oast
  where oast.dnz_chr_id = p_las_rec.dnz_chr_id
  and upper(oast.asset_number) like nvl(upper(p_las_rec.asset_number),upper(oast.asset_number))
  and nvl(upper(oast.vendor_name),'x') like nvl(upper(p_las_rec.vendor_name),nvl(upper(oast.vendor_name),'x'))
  and oast.oec between nvl(p_las_rec.from_oec,oast.oec) and nvl(p_las_rec.to_oec,oast.oec)
  and nvl(oast.residual_value,0) between nvl(p_las_rec.from_residual_value,nvl(oast.residual_value,0)) and nvl(p_las_rec.to_residual_value,nvl(oast.residual_value,0))
  and upper(oast.description) like nvl(upper(p_las_rec.description),upper(oast.description))
  and oast.sts_code like nvl(p_las_rec.sts_code,oast.sts_code)
  and nvl(oast.start_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_start_date,nvl(oast.start_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_start_date,nvl(oast.start_date,to_date('1111','yyyy')))
  and nvl(oast.end_date,to_date('1111','yyyy')) between nvl(p_las_rec.from_end_date,nvl(oast.end_date,to_date('1111','yyyy'))) and nvl(p_las_rec.to_end_date,nvl(oast.end_date,to_date('1111','yyyy')))
  and nvl(oast.date_terminated,to_date('1111','yyyy')) between nvl(p_las_rec.from_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy'))) and nvl(p_las_rec.to_date_terminated,nvl(oast.date_terminated,to_date('1111','yyyy')))
  and (	oast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	oast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = oast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  oast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
  )
  order by decode(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',to_char(start_date,'dd-mon-yyyy')
                       ,'ETDT',to_char(end_date,'dd-mon-yyyy')
                       ,'TRDT',to_char(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) asc;


  CURSOR c_get_new_splt_asset_asc(p_las_rec IN las_rec_type)
  IS
  SELECT nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
         nast.parent_line_id,
         nast.dnz_chr_id
FROM okl_new_assets_uv nast
  WHERE nast.dnz_chr_id = p_las_rec.dnz_chr_id
  AND UPPER(nast.asset_number) LIKE NVL(UPPER(p_las_rec.asset_number),UPPER(nast.asset_number))
  AND NVL(UPPER(nast.vendor_name),'x') LIKE NVL(UPPER(p_las_rec.vendor_name),NVL(UPPER(nast.vendor_name),'x'))
  AND nast.oec BETWEEN NVL(p_las_rec.from_oec,nast.oec) AND NVL(p_las_rec.to_oec,nast.oec)
  AND NVL(nast.residual_value,0) BETWEEN NVL(p_las_rec.from_residual_value,NVL(nast.residual_value,0)) AND NVL(p_las_rec.to_residual_value,NVL(nast.residual_value,0))
  AND UPPER(nast.description) LIKE NVL(UPPER(p_las_rec.description),UPPER(nast.description))
  AND nast.sts_code LIKE NVL(p_las_rec.sts_code,nast.sts_code)
  AND NVL(nast.start_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.end_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.date_terminated,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy')))
 --bug# 4202325 : added following condition
  AND (	nast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	nast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = nast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  nast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
  )
  ORDER BY DECODE(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       --Bug# 2747693
                       --,'DESC',description
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',TO_CHAR(start_date,'dd-mon-yyyy')
                       ,'ETDT',TO_CHAR(end_date,'dd-mon-yyyy')
                       ,'TRDT',TO_CHAR(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) ASC;

  CURSOR c_get_new_splt_asset_desc(p_las_rec IN las_rec_type)
  IS
  SELECT nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
         nast.parent_line_id,
         nast.dnz_chr_id
FROM okl_new_assets_uv nast
  WHERE nast.dnz_chr_id = p_las_rec.dnz_chr_id
  AND UPPER(nast.asset_number) LIKE NVL(UPPER(p_las_rec.asset_number),UPPER(nast.asset_number))
  AND NVL(UPPER(nast.vendor_name),'x') LIKE NVL(UPPER(p_las_rec.vendor_name),NVL(UPPER(nast.vendor_name),'x'))
  AND nast.oec BETWEEN NVL(p_las_rec.from_oec,nast.oec) AND NVL(p_las_rec.to_oec,nast.oec)
  AND NVL(nast.residual_value,0) BETWEEN NVL(p_las_rec.from_residual_value,NVL(nast.residual_value,0)) AND NVL(p_las_rec.to_residual_value,NVL(nast.residual_value,0))
  AND UPPER(nast.description) LIKE NVL(UPPER(p_las_rec.description),UPPER(nast.description))
  AND nast.sts_code LIKE NVL(p_las_rec.sts_code,nast.sts_code)
  AND NVL(nast.start_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.end_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.date_terminated,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy')))
 --bug# 4202325 : added following condition
  AND (	nast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	nast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = nast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  nast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
)
 ORDER BY DECODE(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',TO_CHAR(start_date,'dd-mon-yyyy')
                       ,'ETDT',TO_CHAR(end_date,'dd-mon-yyyy')
                       ,'TRDT',TO_CHAR(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) DESC;

 CURSOR c_get_new_splt_loan_asset_asc(p_las_rec IN las_rec_type)
  IS
  SELECT nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
         nast.parent_line_id,
         nast.dnz_chr_id
FROM okl_new_loan_assets_uv nast
  WHERE nast.dnz_chr_id = p_las_rec.dnz_chr_id
  AND UPPER(nast.asset_number) LIKE NVL(UPPER(p_las_rec.asset_number),UPPER(nast.asset_number))
  AND NVL(UPPER(nast.vendor_name),'x') LIKE NVL(UPPER(p_las_rec.vendor_name),NVL(UPPER(nast.vendor_name),'x'))
  AND nast.oec BETWEEN NVL(p_las_rec.from_oec,nast.oec) AND NVL(p_las_rec.to_oec,nast.oec)
  AND NVL(nast.residual_value,0) BETWEEN NVL(p_las_rec.from_residual_value,NVL(nast.residual_value,0)) AND NVL(p_las_rec.to_residual_value,NVL(nast.residual_value,0))
  AND UPPER(nast.description) LIKE NVL(UPPER(p_las_rec.description),UPPER(nast.description))
  AND nast.sts_code LIKE NVL(p_las_rec.sts_code,nast.sts_code)
  AND NVL(nast.start_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.end_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.date_terminated,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy')))
  AND (	nast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	nast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = nast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  nast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
 )
  ORDER BY DECODE(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',TO_CHAR(start_date,'dd-mon-yyyy')
                       ,'ETDT',TO_CHAR(end_date,'dd-mon-yyyy')
                       ,'TRDT',TO_CHAR(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) ASC;


 CURSOR c_get_new_splt_loan_asset_desc(p_las_rec IN las_rec_type)
  IS
  SELECT nast.asset_number,
         nast.year_manufactured,
         nast.manufacturer_name,
         nast.description,
         nast.current_units,
         nast.oec,
         nast.vendor_name,
         nast.residual_value,
         nast.start_date,
         nast.end_date,
         nast.date_terminated,
         nast.sts_code,
         nast.location_id,
         nast.parent_line_id,
         nast.dnz_chr_id
FROM okl_new_loan_assets_uv nast
  WHERE nast.dnz_chr_id = p_las_rec.dnz_chr_id
  AND UPPER(nast.asset_number) LIKE NVL(UPPER(p_las_rec.asset_number),UPPER(nast.asset_number))
  AND NVL(UPPER(nast.vendor_name),'x') LIKE NVL(UPPER(p_las_rec.vendor_name),NVL(UPPER(nast.vendor_name),'x'))
  AND nast.oec BETWEEN NVL(p_las_rec.from_oec,nast.oec) AND NVL(p_las_rec.to_oec,nast.oec)
  AND NVL(nast.residual_value,0) BETWEEN NVL(p_las_rec.from_residual_value,NVL(nast.residual_value,0)) AND NVL(p_las_rec.to_residual_value,NVL(nast.residual_value,0))
  AND UPPER(nast.description) LIKE NVL(UPPER(p_las_rec.description),UPPER(nast.description))
  AND nast.sts_code LIKE NVL(p_las_rec.sts_code,nast.sts_code)
  AND NVL(nast.start_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_start_date,NVL(nast.start_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.end_date,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_end_date,NVL(nast.end_date,TO_DATE('1111','yyyy')))
  AND NVL(nast.date_terminated,TO_DATE('1111','yyyy')) BETWEEN NVL(p_las_rec.from_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy'))) AND NVL(p_las_rec.to_date_terminated,NVL(nast.date_terminated,TO_DATE('1111','yyyy')))
  AND (	nast.ASSET_STATUS_CODE <> 'ABANDONED'
	OR (
	nast.ASSET_STATUS_CODE = 'ABANDONED'
	 and exists (
			select 1
			FROM okl_txl_assets_b a, okl_trx_assets b, okl_txd_assets_b c,okl_trx_types_tl d
			where a.tas_id = b.id
			and     b.tsu_code = 'PROCESSED'
			and     c.tal_id = a.id
			and     c.split_percent is not null
			and a.kle_id =(
					 SELECT cle.id
					 FROM OKC_K_LINES_B cle,
					 OKC_LINE_STYLES_B lse
					 WHERE cle.dnz_chr_id = nast.dnz_chr_id
					 AND lse.id = cle.lse_id
					 AND lse.lty_code = 'FIXED_ASSET'
					 and cle_id=  nast.parent_line_id
					)
			AND     b.try_id = D.ID
		    AND D.LANGUAGE = 'US'
		    AND D.NAME = 'Split Asset'
		  )
	  )
 )
 ORDER BY DECODE(p_las_rec.p_order_by
                       ,'AST',asset_number
                       ,'YRMF',year_manufactured
                       ,'MFNM',manufacturer_name
                       ,'DESC',4
                       ,'QTY',current_units
                       ,'OEC',oec
                       ,'VEDN',vendor_name
                       ,'RESV',residual_value
                       ,'STDT',TO_CHAR(start_date,'dd-mon-yyyy')
                       ,'ETDT',TO_CHAR(end_date,'dd-mon-yyyy')
                       ,'TRDT',TO_CHAR(date_terminated,'dd-mon-yyyy')
                       ,'STS',sts_code
                       ,'LOC',location_id
                       ,asset_number) DESC;


--Bug# 4202325: Added cursor for split asset - end



  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- cklee
    validate_asset_rec(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_las_rec       => l_las_rec,
                       x_las_rec       => lx_las_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- copy record back
    l_las_rec := lx_las_rec;
-- cklee

    -- Get the sts code since we can version only active contract
    OPEN  c_get_sts_code(l_las_rec.dnz_chr_id);
    IF c_get_sts_code%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_HEADERS_V.STS_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_get_sts_code INTO lv_sts_code, lv_deal_type;
    CLOSE c_get_sts_code;

--cklee
    -- Check if the info to be extracted from FA or Transaction tables.
    l_active_contract := isContractActive(l_las_rec.dnz_chr_id,
                                          lv_deal_type,
                                          lv_sts_code);

    IF (l_active_contract) THEN

      --cklee: get entire old asset locations for a contract
      OPEN c_get_old_asset_loc(l_las_rec.dnz_chr_id);
      FETCH c_get_old_asset_loc BULK COLLECT INTO l_fin_line_ids, l_loc_ids LIMIT G_BULK_BATCH_SIZE;
      CLOSE c_get_old_asset_loc;

      OPEN c_get_old_asset_party_loc(l_las_rec.dnz_chr_id);
      FETCH c_get_old_asset_party_loc BULK COLLECT INTO l_fin_line_2_ids, l_loc_2_ids LIMIT G_BULK_BATCH_SIZE;
      CLOSE c_get_old_asset_party_loc;

    ELSE

      --cklee: get entire new asset locations for a contract
      OPEN c_get_new_asset_loc(l_las_rec.dnz_chr_id);
      FETCH c_get_new_asset_loc BULK COLLECT INTO l_fin_line_ids, l_loc_ids LIMIT G_BULK_BATCH_SIZE;
      CLOSE c_get_new_asset_loc;

    END IF;
--cklee

    -- Check for Loan and Loan Revolving contracts.
    IF (lv_deal_type IN ('LOAN', 'LOAN-REVOLVING')) THEN

      IF (l_active_contract) THEN
        OPEN c_check_assets_in_fa(l_las_rec.dnz_chr_id);
        FETCH c_check_assets_in_fa INTO l_return_value;
        l_info_exists := c_check_assets_in_fa%FOUND;
        CLOSE c_check_assets_in_fa;

        IF (l_info_exists) THEN
          IF l_las_rec.p_sort_by = 'DESC' THEN
--            FOR r_get_old_asset_desc IN c_get_old_asset_desc(l_las_rec) LOOP
	   IF l_las_rec.include_split_yn='Y' THEN
              FOR r_las_rec IN c_get_old_splt_asset_desc(l_las_rec) LOOP
               IF c_get_old_splt_asset_desc%NOTFOUND THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
             END LOOP;
            ELSE
            FOR r_las_rec IN c_get_old_asset_desc(l_las_rec) LOOP
              IF c_get_old_asset_desc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
            END LOOP;
	   END IF;
          ELSE
--            FOR r_get_old_asset_asc IN c_get_old_asset_asc(l_las_rec) LOOP

            IF l_las_rec.include_split_yn='Y' THEN

               FOR r_las_rec IN c_get_old_splt_asset_asc(l_las_rec) LOOP
              IF c_get_old_splt_asset_asc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
             END LOOP;

           ELSE
            FOR r_las_rec IN c_get_old_asset_asc(l_las_rec) LOOP
              IF c_get_old_asset_asc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
            END LOOP;
	   END IF;
          END IF;
        ELSE -- Active New Query
          IF l_las_rec.p_sort_by = 'DESC' THEN
--            FOR r_get_old_asset_desc IN c_get_old_loan_asset_desc(l_las_rec) LOOP
	IF l_las_rec.include_split_yn='Y' THEN
	  FOR r_las_rec IN c_get_old_splt_loan_asset_desc(l_las_rec) LOOP
              IF c_get_old_splt_loan_asset_desc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
            END LOOP;

	ELSE
           FOR r_las_rec IN c_get_old_loan_asset_desc(l_las_rec) LOOP
              IF c_get_old_loan_asset_desc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
            END LOOP;
	END IF; --split asset end if
          ELSE
--            FOR r_get_old_asset_asc IN c_get_old_loan_asset_asc(l_las_rec) LOOP
           IF l_las_rec.include_split_yn='Y' THEN
            FOR r_las_rec IN c_get_old_splt_loan_asset_asc(l_las_rec) LOOP
              IF c_get_old_splt_loan_asset_asc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
            END LOOP;

	    ELSE
             FOR r_las_rec IN c_get_old_loan_asset_asc(l_las_rec) LOOP
              IF c_get_old_loan_asset_asc%NOTFOUND THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              copy_asset_rec(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_las_rec         => r_las_rec,
                             p_idx             => i,
                             p_active_contract => l_active_contract,
                             p_fin_line_ids    => l_fin_line_ids,
                             p_loc_ids         => l_loc_ids,
                             p_fin_line_2_ids  => l_fin_line_2_ids,
                             p_loc_2_ids       => l_loc_2_ids,
                             x_las_rec         => x_las_tbl(i));

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              i := i + 1;
            END LOOP;

	    END IF; -- split end if

          END IF;
        END IF;
      ELSE -- Contract is not active.
        IF l_las_rec.p_sort_by = 'DESC' THEN
--          FOR r_get_new_asset_desc IN c_get_new_loan_asset_desc(l_las_rec) LOOP
          IF l_las_rec.include_split_yn='Y' THEN
           FOR r_las_rec IN c_get_new_splt_loan_asset_desc(l_las_rec) LOOP
            IF c_get_new_splt_loan_asset_desc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            i := i + 1;
           END LOOP;

          ELSE --split else
          FOR r_las_rec IN c_get_new_loan_asset_desc(l_las_rec) LOOP
            IF c_get_new_loan_asset_desc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;
          END IF; --split end if
        ELSE
--          FOR r_get_new_asset_asc IN c_get_new_loan_asset_asc(l_las_rec) LOOP
          IF l_las_rec.include_split_yn='Y' THEN
            FOR r_las_rec IN c_get_new_splt_loan_asset_asc(l_las_rec) LOOP
            IF c_get_new_splt_loan_asset_asc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;

          ELSE --split Else
          FOR r_las_rec IN c_get_new_loan_asset_asc(l_las_rec) LOOP
            IF c_get_new_loan_asset_asc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;

          END IF; --split END IF

        END IF;
      END IF;
    ELSE  -- Contract is neither 'LOAN' nor 'LOAN-REVOLVING'

      IF (l_active_contract) THEN
        IF l_las_rec.p_sort_by = 'DESC' THEN
--          FOR r_get_old_asset_desc IN c_get_old_asset_desc(l_las_rec) LOOP
	 IF l_las_rec.include_split_yn='Y' THEN
	  FOR r_las_rec IN c_get_old_splt_asset_desc(l_las_rec) LOOP
            IF c_get_old_splt_asset_desc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
            END LOOP;
	 ELSE
	    FOR r_las_rec IN c_get_old_asset_desc(l_las_rec) LOOP
            IF c_get_old_asset_desc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
            END LOOP;
	 END IF;

        ELSE
--       FOR r_get_old_asset_asc IN c_get_old_asset_asc(l_las_rec) LOOP

	 IF l_las_rec.include_split_yn='Y' THEN
          FOR r_las_rec IN c_get_old_splt_asset_asc(l_las_rec) LOOP
            IF c_get_old_splt_asset_asc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;

	 ELSE

           FOR r_las_rec IN c_get_old_asset_asc(l_las_rec) LOOP
            IF c_get_old_asset_asc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;


	 END IF;

        END IF;
      ELSE
        IF l_las_rec.p_sort_by = 'DESC' THEN
--          FOR r_get_new_asset_desc IN c_get_new_asset_desc(l_las_rec) LOOP
          IF l_las_rec.include_split_yn='Y' THEN
            FOR r_las_rec IN c_get_new_splt_asset_desc(l_las_rec) LOOP
            IF c_get_new_splt_asset_desc%NOTFOUND THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;

          ELSE --split else
          FOR r_las_rec IN c_get_new_asset_desc(l_las_rec) LOOP
            IF c_get_new_asset_desc%NOTFOUND THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;

          END IF; --split end if

        ELSE
--          FOR r_get_new_asset_asc IN c_get_new_asset_asc(l_las_rec) LOOP
        IF l_las_rec.include_split_yn='Y' THEN
          FOR r_las_rec IN c_get_new_splt_asset_asc(l_las_rec) LOOP
            IF c_get_new_splt_asset_asc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;

        ELSE --split else
          FOR r_las_rec IN c_get_new_asset_asc(l_las_rec) LOOP
            IF c_get_new_asset_asc%NOTFOUND THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            copy_asset_rec(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_las_rec         => r_las_rec,
                           p_idx             => i,
                           p_active_contract => l_active_contract,
                           p_fin_line_ids    => l_fin_line_ids,
                           p_loc_ids         => l_loc_ids,
                           p_fin_line_2_ids  => l_fin_line_2_ids,
                           p_loc_2_ids       => l_loc_2_ids,
                           x_las_rec         => x_las_tbl(i));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            i := i + 1;
          END LOOP;
        END IF; --split end

        END IF;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_get_new_asset_desc%ISOPEN THEN
         CLOSE c_get_new_asset_desc;
      END IF;
      IF c_get_old_asset_desc%ISOPEN THEN
         CLOSE c_get_old_asset_desc;
      END IF;
      IF c_get_new_asset_asc%ISOPEN THEN
         CLOSE c_get_new_asset_asc;
      END IF;
      IF c_get_old_asset_asc%ISOPEN THEN
         CLOSE c_get_old_asset_asc;
      END IF;
      IF c_get_sts_code%ISOPEN THEN
         CLOSE c_get_sts_code;
      END IF;
--cklee
      IF c_get_old_asset_loc%ISOPEN THEN
         CLOSE c_get_old_asset_loc;
      END IF;
      IF c_get_new_asset_loc%ISOPEN THEN
         CLOSE c_get_new_asset_loc;
      END IF;
      IF c_get_old_asset_party_loc%ISOPEN THEN
         CLOSE c_get_old_asset_party_loc;
      END IF;
--cklee
--Bug#4402325 start
       IF c_get_old_splt_asset_desc%ISOPEN THEN
         CLOSE c_get_old_splt_asset_desc;
      END IF;
      IF c_get_old_splt_asset_asc%ISOPEN THEN
         CLOSE c_get_old_splt_asset_asc;
      END IF;

--Bug#4402325 end


      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_get_new_asset_desc%ISOPEN THEN
         CLOSE c_get_new_asset_desc;
      END IF;
      IF c_get_old_asset_desc%ISOPEN THEN
         CLOSE c_get_old_asset_desc;
      END IF;
      IF c_get_new_asset_asc%ISOPEN THEN
         CLOSE c_get_new_asset_asc;
      END IF;
      IF c_get_old_asset_asc%ISOPEN THEN
         CLOSE c_get_old_asset_asc;
      END IF;
      IF c_get_sts_code%ISOPEN THEN
         CLOSE c_get_sts_code;
      END IF;
--cklee
      IF c_get_old_asset_loc%ISOPEN THEN
         CLOSE c_get_old_asset_loc;
      END IF;
      IF c_get_new_asset_loc%ISOPEN THEN
         CLOSE c_get_new_asset_loc;
      END IF;
      IF c_get_old_asset_party_loc%ISOPEN THEN
         CLOSE c_get_old_asset_party_loc;
      END IF;
--cklee
--Bug#4402325 start
       IF c_get_old_splt_asset_desc%ISOPEN THEN
         CLOSE c_get_old_splt_asset_desc;
      END IF;
      IF c_get_old_splt_asset_asc%ISOPEN THEN
         CLOSE c_get_old_splt_asset_asc;
      END IF;

--Bug#4402325 end


      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF c_get_new_asset_desc%ISOPEN THEN
         CLOSE c_get_new_asset_desc;
      END IF;
      IF c_get_old_asset_desc%ISOPEN THEN
         CLOSE c_get_old_asset_desc;
      END IF;
      IF c_get_new_asset_asc%ISOPEN THEN
         CLOSE c_get_new_asset_asc;
      END IF;
      IF c_get_old_asset_asc%ISOPEN THEN
         CLOSE c_get_old_asset_asc;
      END IF;
      IF c_get_sts_code%ISOPEN THEN
         CLOSE c_get_sts_code;
      END IF;
--cklee
      IF c_get_old_asset_loc%ISOPEN THEN
         CLOSE c_get_old_asset_loc;
      END IF;
      IF c_get_new_asset_loc%ISOPEN THEN
         CLOSE c_get_new_asset_loc;
      END IF;
      IF c_get_old_asset_party_loc%ISOPEN THEN
         CLOSE c_get_old_asset_party_loc;
      END IF;
--cklee
--Bug#4402325 start
       IF c_get_old_splt_asset_desc%ISOPEN THEN
         CLOSE c_get_old_splt_asset_desc;
      END IF;
      IF c_get_old_splt_asset_asc%ISOPEN THEN
         CLOSE c_get_old_splt_asset_asc;
      END IF;

--Bug#4402325 end


      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END generate_asset_summary;


-- Start of comments
--
-- Procedure Name  : update_contract_line
-- Description     : updates contract line
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                           IN  NUMBER,
    p_date_delivery_expected       IN  DATE,
    p_date_funding_expected        IN  DATE,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER
   ) AS

    l_api_name	VARCHAR2(30) := 'update_contract_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    lp_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    lp_klev_rec    OKL_CONTRACT_PUB.klev_rec_type;
    lx_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec    OKL_CONTRACT_PUB.klev_rec_type;

    l_template_yn OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
  BEGIN
/*
    OKL_CONTEXT.SET_OKL_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);
*/
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_clev_rec.id := p_id;
    lp_klev_rec.id := p_id;
    lp_klev_rec.date_delivery_expected := p_date_delivery_expected;
    lp_klev_rec.date_funding_expected  := p_date_funding_expected;

    OKL_CONTRACT_PUB.update_contract_line(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
	    p_clev_rec       => lp_clev_rec,
	    p_klev_rec       => lp_klev_rec,
	    p_edit_mode      => 'N',
	    x_clev_rec       => lx_clev_rec,
	    x_klev_rec       => lx_klev_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : update_contract_line
-- Description     : updates contract line
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                           IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_manufacturer_name            IN  VARCHAR2,
    p_model_number                 IN  VARCHAR2,
    p_year_of_manufacture          IN  VARCHAR2,
    p_vendor_name                  IN  VARCHAR2,
    p_vendor_id                    IN  VARCHAR2,
    p_cpl_id                       IN  NUMBER,
    p_notes                        IN  VARCHAR2
   ) AS

    l_api_name	VARCHAR2(30) := 'update_contract_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    lp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    lp_klev_rec OKL_CONTRACT_PUB.klev_rec_type;
    lx_clev_rec okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec OKL_CONTRACT_PUB.klev_rec_type;

    lp_vndr_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_vndr_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    l_template_yn OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type    OKC_K_HEADERS_B.CHR_TYPE%TYPE;

    l_vendor_id NUMBER:= null;
    --start modifying abhsaxen cursor is no longer used
    --    CURSOR okx_vendor_id1_csr IS
    --end  modifying abhsaxen cursor is no longer used

  BEGIN
/*
    OKL_CONTEXT.SET_OKL_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);
*/
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_clev_rec.id := p_id;
    lp_klev_rec.id := p_id;
    lp_klev_rec.manufacturer_name := p_manufacturer_name;
    lp_klev_rec.model_number  := p_model_number;
    lp_klev_rec.year_of_manufacture  := p_year_of_manufacture;
    lp_clev_rec.comments  := p_notes;

    OKL_CONTRACT_PUB.update_contract_line(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_clev_rec       => lp_clev_rec,
      p_klev_rec       => lp_klev_rec,
      p_edit_mode      => 'N',
      x_clev_rec       => lx_clev_rec,
      x_klev_rec       => lx_klev_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


   OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : update_fin_cap_cost
-- Description     : updates fin cap cost
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_fin_cap_cost(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    P_new_yn                       IN  VARCHAR2,
    p_asset_number                 IN  VARCHAR2,
    p_top_line_id                  IN  NUMBER,
    p_dnz_chr_id                   IN  NUMBER,
    p_capital_reduction            IN  NUMBER,
    p_capital_reduction_percent    IN  NUMBER,
    p_oec                          IN  NUMBER,
    p_cap_down_pay_yn              IN  VARCHAR2,
    p_down_payment_receiver        IN  VARCHAR2
   ) AS

    l_api_name	VARCHAR2(30) := 'update_fin_cap_cost';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    lp_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lp_klev_rec OKL_CONTRACT_PUB.klev_rec_type;
    lx_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lx_klev_rec OKL_CONTRACT_PUB.klev_rec_type;

    --Bug#5495504
    CURSOR c_get_tradein_amt
    IS
    SELECT kle.tradein_amount
    FROM okl_k_lines kle
    WHERE kle.id = p_top_line_id;

  BEGIN
/*
    OKL_CONTEXT.SET_OKL_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);
*/
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_clev_rec.id := p_top_line_id;
    lp_clev_rec.line_number := '1';
    lp_clev_rec.dnz_chr_id := p_dnz_chr_id;
    lp_clev_rec.display_sequence := 1;
    lp_clev_rec.exception_yn := 'N';

    lp_klev_rec.id := p_top_line_id;
    lp_klev_rec.capital_reduction := p_capital_reduction;
    lp_klev_rec.capital_reduction_percent := p_capital_reduction_percent;
    lp_klev_rec.oec := p_oec;
    lp_klev_rec.tradein_amount := null;
    lp_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN := p_cap_down_pay_yn;
    lp_klev_rec.DOWN_PAYMENT_RECEIVER_CODE := p_down_payment_receiver;

    --Bug#5495504
    open c_get_tradein_amt;
    fetch c_get_tradein_amt into lp_klev_rec.tradein_amount;
    close c_get_tradein_amt;

    IF((p_down_payment_receiver IS NOT NULL) AND
    	(p_down_payment_receiver = 'VENDOR' OR p_down_payment_receiver = 'LESSOR')) THEN
     IF(p_cap_down_pay_yn IS NOT NULL AND p_cap_down_pay_yn = 'N' AND p_down_payment_receiver = 'VENDOR') THEN
       OKC_API.SET_MESSAGE(p_app_name => g_app_name,
       			  p_msg_name => 'OKL_INVALID_COMBINATION');
       x_return_status := OKC_API.g_ret_sts_error;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
    END IF;

    OKL_CREATE_KLE_PUB.update_fin_cap_cost(
    	  p_api_version    => p_api_version,
    	  p_init_msg_list  => p_init_msg_list,
    	  x_return_status  => x_return_status,
    	  x_msg_count      => x_msg_count,
    	  x_msg_data       => x_msg_data,
    	  p_new_yn         => p_new_yn,
    	  p_asset_number   => p_asset_number,
    	  p_clev_rec       => lp_clev_rec,
    	  p_klev_rec       => lp_klev_rec,
    	  x_clev_rec       => lx_clev_rec,
    	  x_klev_rec       => lx_klev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    	   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    	   RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

   OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

  PROCEDURE update_fin_cap_cost(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fin_adj_tbl		   IN  fin_adj_tbl_type
   ) AS

   l_api_name	VARCHAR2(30) := 'update_fin_cap_cost_tbl';
   l_api_version	CONSTANT NUMBER	  := 1.0;
   l_fin_adj_rec    fin_adj_rec_type;
   lp_asset_number VARCHAR2(50);
   lp_new_yn VARCHAR2(10);

 BEGIN
     x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

 FOR l_fin_adj_rec_index IN p_fin_adj_tbl.FIRST .. p_fin_adj_tbl.LAST
 LOOP
    lp_asset_number := NULL;
    lp_new_yn       := NULL;
    l_fin_adj_rec   := NULL;
    l_fin_adj_rec :=  p_fin_adj_tbl(l_fin_adj_rec_index);
    lp_asset_number := l_fin_adj_rec.p_asset_number;
    lp_new_yn       := l_fin_adj_rec.p_new_yn;

    IF((l_fin_adj_rec.p_down_payment_receiver IS NOT NULL) AND
    	(l_fin_adj_rec.p_down_payment_receiver = 'VENDOR' OR l_fin_adj_rec.p_down_payment_receiver = 'LESSOR')) THEN
     IF(l_fin_adj_rec.p_cap_down_pay_yn IS NOT NULL AND l_fin_adj_rec.p_cap_down_pay_yn = 'N' AND l_fin_adj_rec.p_down_payment_receiver = 'VENDOR') THEN
       OKC_API.SET_MESSAGE(p_app_name => g_app_name,
       			  p_msg_name => 'OKL_INVALID_COMBINATION');
       x_return_status := OKC_API.g_ret_sts_error;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
    END IF;

    update_fin_cap_cost(
    p_api_version                  =>p_api_version,
    p_init_msg_list                => p_init_msg_list,
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    P_new_yn                       => lp_new_yn,
    p_asset_number                 => lp_asset_number,
    p_top_line_id                  => l_fin_adj_rec.p_top_line_id,
    p_dnz_chr_id                   => l_fin_adj_rec.p_dnz_chr_id,
    p_capital_reduction            => l_fin_adj_rec.p_capital_reduction,
    p_capital_reduction_percent    => l_fin_adj_rec.p_capital_reduction_percent,
    p_oec                          => l_fin_adj_rec.p_oec,
    p_cap_down_pay_yn              => l_fin_adj_rec.p_cap_down_pay_yn,
    p_down_payment_receiver        => l_fin_adj_rec.p_down_payment_receiver);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    	   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    	   RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

 END LOOP;
 OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);
 EXCEPTION
 WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
 END;

End OKL_LA_ASSET_PVT;

/
