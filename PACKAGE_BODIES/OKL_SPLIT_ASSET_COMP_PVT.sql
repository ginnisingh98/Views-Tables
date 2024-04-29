--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_ASSET_COMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_ASSET_COMP_PVT" AS
/* $Header: OKLRSACB.pls 120.6 2006/06/07 00:02:26 fmiao noship $ */

   /*
   -- mvasudev, 08/23/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_SPLIT_ASSET_REQ  CONSTANT VARCHAR2(69) := 'oracle.apps.okl.la.lease_contract.split_asset_by_components_requested';
   G_WF_EVT_KHR_SPLIT_ASSET_COMP CONSTANT VARCHAR2(69) := 'oracle.apps.okl.la.lease_contract.split_asset_by_components_completed';

   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(20)  := 'CONTRACT_ID';
   G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(10)  := 'ASSET_ID';
   --Bug 4047504: increased size
   G_WF_ITM_TRANS_DATE CONSTANT VARCHAR2(20)    := 'TRANSACTION_DATE';

  --------------------------------------------------------------------------
  ----- Calculates Unit and Cost based on current image
  --------------------------------------------------------------------------
  PROCEDURE calculate_unit_cost(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_tal_id         IN  NUMBER)
  IS

    l_api_version     CONSTANT NUMBER       := 1.0;
    l_api_name   CONSTANT VARCHAR2(30) := 'calculate_unit_cost';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_id              okl_txd_assets_B.ID%TYPE;
    l_split_percent   okl_txd_assets_B.SPLIT_PERCENT%TYPE;
    l_oec             okl_txl_assets_B.ORIGINAL_COST%TYPE;
    l_units           okl_txl_assets_B.CURRENT_UNITS%TYPE;
    l_asdv_rec        Okl_Asd_Pvt.asdv_rec_type;
    x_asdv_rec        Okl_Asd_Pvt.asdv_rec_type;

--
-- need to get unit, cost to calcuate the new unit and cost!!
--
  CURSOR c(p_tal_id NUMBER)
  IS
  SELECT a.id,
         a.SPLIT_PERCENT
  FROM okl_txd_assets_v a
  WHERE TAL_ID = p_tal_id
  ;

  CURSOR c_org(p_tal_id NUMBER)
  IS
  SELECT ORIGINAL_COST,
         CURRENT_UNITS
  FROM okl_txl_assets_b
  WHERE id = p_tal_id
  ;

BEGIN
  -- Set API savepoint
  SAVEPOINT calculate_unit_cost_pvt;

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


/*** Begin API body ****************************************************/

    --
    -- get the original units and cost
    --
    OPEN c_org (p_tal_id);
    FETCH c_org INTO l_oec,
                     l_units;
    CLOSE c_org;

    --
    -- update all
    --
    OPEN c (p_tal_id);
    LOOP

      FETCH c INTO l_id,
                   l_split_percent;

      EXIT WHEN c%NOTFOUND;

      l_asdv_rec.id := l_id;
      l_asdv_rec.cost := l_oec * (l_split_percent/100);
      l_asdv_rec.quantity := l_units;

      Okl_Asd_Pvt.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_asdv_rec,
                            x_asdv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;
    CLOSE c;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO calculate_unit_cost_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO calculate_unit_cost_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO calculate_unit_cost_pvt;
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
  END calculate_unit_cost;

  --------------------------------------------------------------------------
  ----- Validate Asset Number
  --------------------------------------------------------------------------
  FUNCTION validate_asset_number(
    p_asdv_rec                     IN advv_rec_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
  BEGIN

    -- is required
    IF (p_asdv_rec.ASSET_NUMBER IS NULL) OR
       (p_asdv_rec.ASSET_NUMBER = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Asset Number');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --
    -- must be unique within ?:
    -- can be check at process_split_asset_comp()
    --

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Asset Description
  --------------------------------------------------------------------------
  FUNCTION validate_asset_description(
    p_asdv_rec                     IN advv_rec_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
  BEGIN

    -- is required
    IF (p_asdv_rec.DESCRIPTION IS NULL) OR
       (p_asdv_rec.DESCRIPTION = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Asset Description');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Split Percent
  --------------------------------------------------------------------------
  FUNCTION validate_split_percent(
    p_asdv_rec                     IN advv_rec_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_percent         NUMBER;

  BEGIN

    -- is required
    IF (p_asdv_rec.SPLIT_PERCENT IS NULL) OR
       (p_asdv_rec.SPLIT_PERCENT = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Split Percent');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_asdv_rec.SPLIT_PERCENT < 0) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_POSITIVE_AMOUNT_ONLY',
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Split Percent');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_asdv_rec.SPLIT_PERCENT > 100) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_PERCENT');
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Item
  --------------------------------------------------------------------------
  FUNCTION validate_Item(
    p_asdv_rec                     IN advv_rec_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy       VARCHAR2(1) := '?';

  BEGIN

    -- is required
    IF (p_asdv_rec.INVENTORY_ITEM_ID IS NULL) OR
       (p_asdv_rec.INVENTORY_ITEM_ID = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- FK check take care by TAPI: OKL_ASD_PVT

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

--------------------------------------------------------------------------
  FUNCTION validate_attributes(
    p_asdv_rec                     IN advv_rec_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_asset_number(p_asdv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Do formal attribute validation:
    l_return_status := validate_asset_description(p_asdv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Do formal attribute validation:
    l_return_status := validate_split_percent(p_asdv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Do formal attribute validation:
    l_return_status := validate_item(p_asdv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_attributes;
--------------------------------------------------------------------------
  --------------------------------------------------------------------------
  ----- Validate Split Percent
  --------------------------------------------------------------------------
  FUNCTION validate_split_percent(
    p_asdv_tbl                     IN advv_tbl_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_percent         NUMBER;

  CURSOR c(p_tal_id NUMBER)
  IS
  SELECT NVL(SUM(SPLIT_PERCENT),0)
  FROM okl_txd_assets_v
  WHERE TAL_ID = p_tal_id
  ;

  BEGIN

    --
    -- the total can not exceeds 100
    --
    OPEN c (p_asdv_tbl(p_asdv_tbl.FIRST).tal_id);
    FETCH c INTO l_percent;
    CLOSE c;

    IF (l_percent > 100) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_PERCENT');
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Asset Number
  --------------------------------------------------------------------------
  FUNCTION validate_asset_number(
    p_asdv_tbl                     IN advv_tbl_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_asset_number    okl_txd_assets_B.ASSET_NUMBER%TYPE;

  --cursor to check duplicate within same transaction
  CURSOR c(p_tal_id NUMBER)
  IS
  SELECT asset_number
  FROM okl_txd_assets_v
  WHERE TAL_ID = p_tal_id
  GROUP BY asset_number
  HAVING COUNT(1) > 1
  ;
  --bug #2465479 begin
  --cursor to fetch asset number
  CURSOR asset_cur(p_asd_id IN NUMBER) IS
  SELECT asset_number
  FROM   okl_txd_assets_v
  WHERE  id = p_asd_id;

  --cursor to check duplicate in FA
  CURSOR asset_chk_curs1 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okx_assets_v okx
    WHERE  okx.asset_number = p_asset_number;

    --chk for asset on asset line
    CURSOR asset_chk_curs2 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okl_k_lines_full_v kle,
           okc_line_styles_b  lse
    WHERE  kle.name = p_asset_number
    AND    kle.lse_id = lse.id
    AND    lse.lty_code = 'FIXED_ASSET';



   --check for asset on create asset or rebook transaction
   CURSOR asset_chk_curs3 (p_asset_number IN VARCHAR2) IS
   SELECT 'Y'
   FROM   okl_txl_assets_b txl
   WHERE  txl.asset_number = p_asset_number
   AND    txl.tal_type IN ('ALI','CRB'); --only transactions apart from split which create a new line

   l_asset_exists  VARCHAR2(1) DEFAULT 'N';
   i NUMBER;
     --bug #2465479 end

  BEGIN

    --
    -- catch the 1st invalid asset_number only
    --
    OPEN c (p_asdv_tbl(p_asdv_tbl.FIRST).tal_id);
    FETCH c INTO l_asset_number;
    IF c%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE c;

    IF (l_asset_number IS NOT NULL) THEN

     OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NOT_UNIQUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'Asset Number '|| l_asset_number);
      RAISE G_EXCEPTION_HALT_VALIDATION;
  --bug #2465479 begin
    ELSIF (l_asset_number IS NULL) THEN
        IF p_asdv_tbl.COUNT > 0 THEN
            i := p_asdv_tbl.FIRST;
            LOOP

                l_asset_number := NULL;
                OPEN asset_cur(p_asd_id => p_asdv_tbl(i).id);
                FETCH asset_cur INTO l_asset_number;
                   IF asset_cur%NOTFOUND THEN
                       NULL;
                   END IF;
                CLOSE asset_cur;

                IF l_asset_number IS NOT NULL THEN
                    l_asset_exists := 'N';
                    OPEN asset_chk_curs1(p_asdv_tbl(i).asset_number);
                        FETCH asset_chk_curs1 INTO l_asset_exists;
                        IF asset_chk_curs1%NOTFOUND THEN
                            OPEN asset_chk_curs2(p_asdv_tbl(i).asset_number);
                            FETCH asset_chk_curs2 INTO l_asset_exists;
                            IF asset_chk_curs2%NOTFOUND THEN
                                OPEN asset_chk_curs3(p_asdv_tbl(i).asset_number);
                                FETCH asset_chk_curs3 INTO l_asset_exists;
                                IF asset_chk_curs3%NOTFOUND THEN
                                    NULL;
                                END IF;
                               CLOSE asset_chk_curs3;
                            END IF;
                            CLOSE asset_chk_curs2;
                        END IF;
                    CLOSE asset_chk_curs1;
                END IF;
                IF l_asset_exists = 'Y' THEN
                    -- store SQL error message on message stack
                    OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                        p_msg_name     => G_NOT_UNIQUE,
                                        p_token1       => G_COL_NAME_TOKEN,
                                        p_token1_value => 'Asset Number '|| p_asdv_tbl(i).asset_number);

                    -- halt validation as it is a required field
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                IF i = p_asdv_tbl.LAST THEN
                    EXIT;
                ELSE
                    i:= i+1;
                END IF;
            END LOOP;
        END IF;
    END IF;
      --bug #2465479 end
    RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN

      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

        --bug #2465479 begin
       --close the cursor
       IF asset_chk_curs1%ISOPEN THEN
          CLOSE asset_chk_curs1;
       END IF;
       IF asset_chk_curs2%ISOPEN THEN
          CLOSE asset_chk_curs2;
       END IF;
       IF asset_chk_curs3%ISOPEN THEN
          CLOSE asset_chk_curs3;
       END IF;
       IF asset_cur%ISOPEN THEN
          CLOSE asset_cur;
       END IF;
       IF c%ISOPEN THEN
          CLOSE asset_cur;
       END IF;
         --bug #2465479 end


      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Inventory Item id
  --------------------------------------------------------------------------
  FUNCTION validate_inventory_item_id(
    p_asdv_tbl                     IN advv_tbl_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_inventory_item_id      okl_txd_assets_B.INVENTORY_ITEM_ID%TYPE;
    l_inventory_item_name    okx_system_items_v.NAME%TYPE;

  CURSOR c(p_tal_id NUMBER)
  IS
  SELECT inventory_item_id
  FROM okl_txd_assets_v
  WHERE TAL_ID = p_tal_id
  GROUP BY inventory_item_id
  HAVING COUNT(1) > 1
  ;

  -- don't care the org_id
  CURSOR c_name(p_inventory_item_id NUMBER)
  IS
  SELECT i.name
  FROM okx_system_items_v i
  WHERE i.ID1 = p_inventory_item_id
  --group by i.name
  ;

  BEGIN

    --
    -- catch the 1st invalid asset_number only
    --
    OPEN c (p_asdv_tbl(p_asdv_tbl.FIRST).tal_id);
    FETCH c INTO l_inventory_item_id;
    CLOSE c;

    IF (l_inventory_item_id IS NOT NULL) THEN

      OPEN c_name (l_inventory_item_id);
      FETCH c_name INTO l_inventory_item_name;
      CLOSE c_name;

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NOT_UNIQUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Inventory Item Name ' || l_inventory_item_name);
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

------------------------------------------------------------------------
  FUNCTION validate_rows(
    p_asdv_tbl                     IN advv_tbl_type
   ,p_mode                         IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_split_percent(p_asdv_tbl, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_asset_number(p_asdv_tbl, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

   -- fmiao - Bug#5230268  - Commented - Start
   -- Split Asset by Component. This is to handle the following scenario where while booking
   -- contracts lessor is unaware of the number units of the item and hence creates the
   -- asset with 1 unit and later needs to split the asset by repeating the item.
   /*

    l_return_status := validate_inventory_item_id(p_asdv_tbl, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
   */
   -- fmiao - Bug#5230268 - Commented - End

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_rows;
-----------------------------------------------------------------------------------
    PROCEDURE create_split_asset_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN advv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY advv_tbl_type)
    IS

    l_api_version     CONSTANT NUMBER       := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'create_split_asset_comp';
    l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_mode                       VARCHAR2(1)  := 'C';
    i                 NUMBER;
    --Bug# 4126331
    l_asdv_rec advv_rec_type;

    /*
    -- mvasudev, 08/23/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
	   x_return_status OUT NOCOPY VARCHAR2
    )
	IS

		CURSOR l_cle_trx_csr(p_tal_id IN NUMBER)
		IS
		SELECT cleb.dnz_chr_id
		      ,cleb.id cle_id
              ,trxa.date_trans_occurred
		FROM okl_trx_assets trxa
		    ,okl_txl_assets_b txla
		    ,okc_k_lines_b cleb
			,okc_line_styles_b lseb
		WHERE txla.kle_id = cleb.id
		AND cleb.lse_id = lseb.id
		AND lseb.lty_code = 'FIXED_ASSET'
		AND txla.tal_type = 'ALI'
		AND txla.tas_id = trxa.id
		AND trxa.tsu_code = 'ENTERED'
		AND txla.id = p_tal_id;

      l_parameter_list           wf_parameter_list_t;
	BEGIN

	  IF (p_asdv_tbl.COUNT > 0) THEN
       FOR l_cle_trx_rec IN l_cle_trx_csr(p_asdv_tbl(1).tal_id)
	   LOOP

  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_cle_trx_rec.dnz_chr_id,l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,l_cle_trx_rec.cle_id,l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_TRANS_DATE,fnd_date.date_to_canonical(l_cle_trx_rec.date_trans_occurred),l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_SPLIT_ASSET_REQ,
								 p_parameters     => l_parameter_list);

	    END LOOP;
	  END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;

    /*
    -- mvasudev, 08/23/2004
    -- END, PROCEDURE to enable Business Event
    */

    BEGIN
  -- Set API savepoint
  SAVEPOINT create_split_asset_comp_pvt;

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


/*** Begin API body ****************************************************/

    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;

      LOOP

        l_return_status := validate_attributes(p_asdv_tbl(i), l_mode);
        --- Store the highest degree of error
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        --Bug# 4126331: Only upper case aset numbers are alowed in FA
        l_asdv_rec := NULL;
        l_asdv_rec := p_asdv_tbl(i);
        l_asdv_rec.asset_number := upper(p_asdv_tbl(i).asset_number);
        Okl_Asd_Pvt.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           l_asdv_rec,
                           --p_asdv_tbl(i),
                           x_asdv_tbl(i));

        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
      END LOOP;

      -- validate all based on current image
      l_return_status := validate_rows(p_asdv_tbl, l_mode);
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      -- update all based on current image
      calculate_unit_cost(p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_tal_id        => p_asdv_tbl(p_asdv_tbl.FIRST).tal_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

   /*
   -- mvasudev, 08/23/2004
   -- Code change to enable Business Event
   */
	raise_business_event(x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/23/2004
   -- END, Code change to enable Business Event
   */

    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_split_asset_comp_pvt;
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

    END create_split_asset_comp;

-----------------------------------------------------------------------------------

   PROCEDURE update_split_asset_comp(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type,
     x_asdv_tbl                     OUT NOCOPY advv_tbl_type)
     IS

     l_api_version     CONSTANT NUMBER       := 1.0;
     l_api_name          CONSTANT VARCHAR2(30) := 'update_split_asset_comp';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_mode                       VARCHAR2(1)  := 'U';
     i                 NUMBER;
     --Bug# 4126331
     l_asdv_rec advv_rec_type;

   BEGIN
  -- Set API savepoint
  SAVEPOINT update_split_asset_comp_pvt;

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


/*** Begin API body ****************************************************/


    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;
      LOOP

        l_return_status := validate_attributes(p_asdv_tbl(i), l_mode);
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        --Bug# 4126331: Only upper case aset numbers are alowed in FA
        l_asdv_rec := NULL;
        l_asdv_rec := p_asdv_tbl(i);
        l_asdv_rec.asset_number := upper(p_asdv_tbl(i).asset_number);
        Okl_Asd_Pvt.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_asdv_rec,
                            --p_asdv_tbl(i),
                            x_asdv_tbl(i));

        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
      END LOOP;

      -- validate all based on current image
      l_return_status := validate_rows(p_asdv_tbl, l_mode);
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      -- update all based on current image
      calculate_unit_cost(p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_tal_id        => p_asdv_tbl(p_asdv_tbl.FIRST).tal_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_split_asset_comp_pvt;
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

   END update_split_asset_comp;

--------------------------------------------------------------------------------

   PROCEDURE delete_split_asset_comp(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type)
     IS

     l_api_version     CONSTANT NUMBER       := 1.0;
     l_api_name          CONSTANT VARCHAR2(30) := 'delete_split_asset_comp';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
  -- Set API savepoint
  SAVEPOINT delete_split_asset_comp_pvt;

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


/*** Begin API body ****************************************************/
     Okl_Asd_Pvt.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_split_asset_comp_pvt;
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

   END delete_split_asset_comp;
-----------------------------------------------------------------------------------
  --------------------------------------------------------------------------
  ----- Validate Split Percent
  --------------------------------------------------------------------------
  FUNCTION validate_split_percent(
    p_tal_id                     IN NUMBER
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_percent         NUMBER;

  CURSOR c(p_tal_id NUMBER)
  IS
  SELECT NVL(SUM(SPLIT_PERCENT),0)
  FROM okl_txd_assets_v
  WHERE TAL_ID = p_tal_id
  ;

  BEGIN

    --
    -- the total can not exceeds 100
    --
    OPEN c (p_tal_id);
    FETCH c INTO l_percent;
    CLOSE c;

    IF (l_percent <> 100) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_TOTAL_PERCENT',
                          p_token1       => 'TITLE',
                          p_token1_value => 'Split Percent');
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
-----------------------------------------------------------------------------------

   PROCEDURE process_split_asset_comp(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tal_id                       IN NUMBER)
     IS

     l_api_version     CONSTANT NUMBER       := 1.0;
     l_api_name          CONSTANT VARCHAR2(30) := 'process_split_asset_comp';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     CURSOR fin_ast_csr (p_tal_id IN NUMBER) IS
     SELECT cle.cle_id
     FROM   okc_k_lines_b cle,
            okl_txl_assets_b tal
     WHERE  cle.id = tal.kle_id
     AND    tal.id = p_tal_id;

     l_cle_id    okc_k_lines_b.id%TYPE;
     l_cle_tbl   okl_split_asset_pub.cle_tbl_type;

    /*
    -- mvasudev, 08/24/2004
    -- Added PROCEDURE to enable Business Event
    */

      --Bug 4047504:
      CURSOR l_cle_trx_csr(p_tal_id IN NUMBER)
      IS
      SELECT cleb.dnz_chr_id
            ,cleb.cle_id cle_id
            ,trxa.date_trans_occurred
      FROM okl_trx_assets trxa
          ,okl_txl_assets_b txla
          ,okc_k_lines_b cleb
          ,okc_line_styles_b lseb
      WHERE txla.kle_id = cleb.id
      AND cleb.lse_id = lseb.id
      AND lseb.lty_code = 'FIXED_ASSET'
      AND txla.tal_type = 'ALI'
      AND txla.tas_id = trxa.id
      AND trxa.tsu_code = 'ENTERED'
      AND txla.id = p_tal_id;

      l_dnz_chr_id NUMBER;
      l_trx_date DATE;
      l_cleb_id NUMBER;

	PROCEDURE raise_business_event(
         p_dnz_chr_id    IN NUMBER,
         p_trx_date      IN DATE,
         p_cle_id        IN NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
      )
	IS

      l_parameter_list           wf_parameter_list_t;
	BEGIN

         x_return_status := OKL_API.G_RET_STS_SUCCESS;

	 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_dnz_chr_id,l_parameter_list);
	 wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,p_cle_id,l_parameter_list);
	 wf_event.AddParameterToList(G_WF_ITM_TRANS_DATE,fnd_date.date_to_canonical(p_trx_date),l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_SPLIT_ASSET_COMP,
								 p_parameters     => l_parameter_list);

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;

    /*
    -- mvasudev, 08/24/2004
    -- END, PROCEDURE to enable Business Event
    */


   BEGIN
  -- Set API savepoint
  SAVEPOINT process_split_asset_comp_pvt;

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


/*** Begin API body ****************************************************/
--
-- process split asset comp code here ->
------------------------------------------------------------------------
-- get the top line id from p_tal_id
    OPEN fin_ast_csr(p_tal_id => p_tal_id);
         FETCH fin_ast_csr INTO l_cle_id;
         IF fin_ast_csr%NOTFOUND THEN
            NULL;
            --no fin asset line found for tal_id!!!!
         ELSE

           --Bug 4047504:
           /*
           -- mvasudev, 10/28/2004
           -- Fetch parameters for Business Event enabling
           */
           FOR l_cle_trx_rec IN l_cle_trx_csr(p_tal_id => p_tal_id)
           LOOP
            l_dnz_chr_id := l_cle_trx_rec.dnz_chr_id;
            l_trx_date := l_cle_trx_rec.date_trans_occurred;
            l_cleb_id := l_cle_trx_rec.cle_id;
           END LOOP;
          /*
          -- mvasudev, 10/28/2004
          -- END, Fetch parameters for Business Event enabling
          */

-- 1) unique asset number within ?
-- 2) total split percent must = 100
-- 3) same item has been apply to differnt asset number?
             -- validation:
            l_return_status := validate_split_percent(p_tal_id);
            IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

            OKL_SPLIT_ASSET_PUB.Split_Fixed_Asset
                                 (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_cle_id         => l_cle_id,
                                  x_cle_tbl        => l_cle_tbl);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
    CLOSE fin_ast_csr;

   --Bug 4047504:
   /*
   -- mvasudev, 08/24/2004
   -- Code change to enable Business Event
   */
        raise_business_event(p_dnz_chr_id => l_dnz_chr_id,
                             p_trx_date => l_trx_date,
                             p_cle_id => l_cleb_id,
                             x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/24/2004
   -- END, Code change to enable Business Event
   */

--
-- end of process split asset comp code
--
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO process_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_split_asset_comp_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO process_split_asset_comp_pvt;
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

   END process_split_asset_comp;


END OKL_SPLIT_ASSET_COMP_PVT;

/
