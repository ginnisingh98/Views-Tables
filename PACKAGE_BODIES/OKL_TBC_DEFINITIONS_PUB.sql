--------------------------------------------------------
--  DDL for Package Body OKL_TBC_DEFINITIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TBC_DEFINITIONS_PUB" AS
/* $Header: OKLPTBCB.pls 120.4 2007/03/20 11:24:12 asawanka noship $ */


FUNCTION Validate_Record (
    p_tbcv_rec IN tbcv_rec_type,
    p_rec_number  IN NUMBER


  ) RETURN VARCHAR2 IS

    CURSOR l_checkduplicate_tbc_csr(cp_tax_attribute_def_id IN VARCHAR2) IS
    SELECT result_code
    FROM   OKL_TAX_ATTR_DEFINITIONS
    WHERE  result_type_code = 'TBC_CODE'
        AND    nvl(TRY_ID, -99999) = nvl(p_tbcv_rec.TRY_ID,-99999)
        AND    nvl(STY_ID, -99999) = nvl(p_tbcv_rec.STY_ID,-99999)
        AND       nvl(BOOK_CLASS_CODE,'XXXXX') = nvl(p_tbcv_rec.BOOK_CLASS_CODE,'XXXXX')
        AND    nvl(TAX_COUNTRY_CODE,'XXXXX') = nvl(p_tbcv_rec.TAX_COUNTRY_CODE,'XXXXX')
        AND   nvl(TAX_ATTRIBUTE_DEF_ID, -99999) <> nvl(cp_tax_attribute_def_id,-99999)
        AND       nvl(EXPIRE_FLAG,'N')<> 'Y' ;

        CURSOR l_checkduplicate_pc_csr(cp_tax_attribute_def_id IN VARCHAR2) IS
            SELECT result_code
            FROM   OKL_TAX_ATTR_DEFINITIONS
            WHERE  result_type_code = 'PC_CODE'
        AND    nvl(PURCHASE_OPTION_CODE,'XXXXX') = nvl(p_tbcv_rec.PURCHASE_OPTION_CODE,'XXXXX')
                AND    nvl(STY_ID, -99999) = nvl(p_tbcv_rec.STY_ID,-99999)
                AND    nvl(INT_DISCLOSED_CODE,'N') = nvl(p_tbcv_rec.INT_DISCLOSED_CODE,'N')
                AND    nvl(TITLE_TRNSFR_CODE,'N') = nvl(p_tbcv_rec.TITLE_TRNSFR_CODE,'N')
                AND    nvl(SALE_LEASE_BACK_CODE,'N') = nvl(p_tbcv_rec.SALE_LEASE_BACK_CODE,'N')
                AND    nvl(LEASE_PURCHASED_CODE,'N') = nvl(p_tbcv_rec.LEASE_PURCHASED_CODE,'N')
                AND    nvl(TAX_COUNTRY_CODE,'XXXXX') = nvl(p_tbcv_rec.TAX_COUNTRY_CODE,'XXXXX')
                AND   nvl(TAX_ATTRIBUTE_DEF_ID, -99999) <> nvl(cp_tax_attribute_def_id,-99999)
                AND       nvl(EXPIRE_FLAG,'N')<> 'Y' ;

        CURSOR l_checkduplicate_ufc_csr(cp_tax_attribute_def_id IN VARCHAR2) IS
            SELECT result_code
            FROM   OKL_TAX_ATTR_DEFINITIONS
            WHERE  result_type_code = 'UFC_CODE'
                AND     nvl(PURCHASE_OPTION_CODE,'XXXXX') = nvl(p_tbcv_rec.PURCHASE_OPTION_CODE,'XXXXX')
                AND    nvl(PDT_ID, -99999) = nvl(p_tbcv_rec.PDT_ID,-99999)
                AND    nvl(STY_ID, -99999) = nvl(p_tbcv_rec.STY_ID,-99999)
                AND    nvl(TRY_ID, -99999) = nvl(p_tbcv_rec.TRY_ID,-99999)
                AND    nvl(LEASE_PURCHASED_CODE,'N') = nvl(p_tbcv_rec.LEASE_PURCHASED_CODE,'N')
                AND    nvl(EQUIP_USAGE_CODE,'XXXXX') = nvl(p_tbcv_rec.EQUIP_USAGE_CODE,'XXXXX')
                AND    nvl(VENDOR_SITE_ID,-99999) = nvl(p_tbcv_rec.VENDOR_SITE_ID,-99999)
                AND    nvl(INT_DISCLOSED_CODE,'N') = nvl(p_tbcv_rec.INT_DISCLOSED_CODE,'N')
                AND    nvl(TITLE_TRNSFR_CODE,'N') = nvl(p_tbcv_rec.TITLE_TRNSFR_CODE,'N')
                AND    nvl(SALE_LEASE_BACK_CODE,'N') = nvl(p_tbcv_rec.SALE_LEASE_BACK_CODE,'N')
                AND    nvl(TAX_COUNTRY_CODE,'XXXXX') = nvl(p_tbcv_rec.TAX_COUNTRY_CODE,'XXXXX')
                AND    nvl(TERM_QUOTE_TYPE_CODE,'XXXXX') = nvl(p_tbcv_rec.TERM_QUOTE_TYPE_CODE,'XXXXX')
                AND    nvl(TERM_QUOTE_REASON_CODE,'XXXXX') = nvl(p_tbcv_rec.TERM_QUOTE_REASON_CODE,'XXXXX')
                AND       nvl(EXPIRE_FLAG,'N')<> 'Y'
                AND   nvl(TAX_ATTRIBUTE_DEF_ID, -99999) <> nvl(cp_tax_attribute_def_id,-99999)

                AND (  (   -- This condition will allow cases where DB FROm and To are NULL and also Screen FROM and TO are null
                   --(AGE_OF_EQUIP_FROM IS NOT NULL OR AGE_OF_EQUIP_TO IS NOT NULL OR p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL OR p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL )
                  -- AND
                    -- this condition will prevent exact matches (including cases where some values are null)
                   (nvl(AGE_OF_EQUIP_FROM,-99999) = nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,-99999) AND
                    nvl(AGE_OF_EQUIP_TO, -99999) = nvl(p_tbcv_rec.AGE_OF_EQUIP_TO,-99999)
                    )
                )
               OR -- age of equipment from can not be null for comparison purposes (when TO is not null),
                      -- as we can assume it is 0, if null
                  -- so this condition takes care of scenarios where both Froms and both Tos have a value
                  -- OR any of the FROMs are null and both Tos have a value
               (--nvl(AGE_OF_EQUIP_FROM,0) IS NOT NULL AND nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) IS NOT NULL AND
                AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND
                  (  (nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) < nvl(AGE_OF_EQUIP_FROM,0) AND p_tbcv_rec.AGE_OF_EQUIP_TO >= nvl(AGE_OF_EQUIP_FROM,0))
                     OR
                     (nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) >= nvl(AGE_OF_EQUIP_FROM,0) AND nvl(p_tbcv_rec.AGE_OF_EQUIP_FROM,0) <= AGE_OF_EQUIP_TO) --AND p_tbcv_rec.AGE_OF_EQUIP_TO > AGE_OF_EQUIP_TO)
                  )

               )
               OR
               ( AGE_OF_EQUIP_TO IS NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL AND
                 -- In this case Both the FROMs can not be null together or have the same value, as it will get captured in condition 1
                 -- here, either DB FROM is Null and Screen FROM is not null --> This combination is ok
                 -- OR DB FROM is not null and Screen FROM is null --> this combinatio is ok
                 -- OR both FROMs have a value(differenr value) --> restrict this combination
                 AGE_OF_EQUIP_FROM IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL -- The 2 FROMs can not have same value at this point
               )
               OR
                   ( AGE_OF_EQUIP_TO IS NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND -- TO in DB is Null,TO on screen is not null
                     -- In this case following scenarios are possible
                     -- DB FROM is Null (DB To is also NUll) FROM on the screen can be considered to be be >=0 (0 if null), since TO on screen is not null - OK
                         -- DB FROM >=0, SCREEN TO < DB FROM - ok
                         -- DB FROM >=0, SCREEN TO >= DB FROM - restrict this condition
                         AGE_OF_EQUIP_FROM >= 0 AND p_tbcv_rec.AGE_OF_EQUIP_TO >= AGE_OF_EQUIP_FROM
                   )
                   OR
                   ( AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO IS NULL AND
                     -- In this case following scenarios are possible
                     -- DB FROM can be considered to be >=0 (0 if null), since DB TO is not null, so there is a fixed age range defined in DB
                     -- SCREEN FROM is null (TO is always NULL) - OK
                     -- screen from >=0, SCREEN FROM > DB TO - ok
                     -- screen from >=0, screen from <= db to - RESTRICT THIS CONDITION
                     p_tbcv_rec.AGE_OF_EQUIP_FROM >=0 AND p_tbcv_rec.AGE_OF_EQUIP_FROM <= AGE_OF_EQUIP_TO
                   )
            ) ;

    CURSOR okl_tbc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT classification_name
      FROM zx_fc_business_categories_v
      WHERE classification_code = p_lookup_code;

    CURSOR okl_pc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT classification_name
      FROM zx_fc_product_categories_v
      WHERE classification_code = p_lookup_code;

    CURSOR okl_ufc_res_code_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT classification_name
      FROM zx_fc_user_defined_v
      WHERE classification_code = p_lookup_code;

        l_result_code                                      VARCHAR2(300) := 'XXXXX';
        x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_meaning                                          VARCHAR2(80);

        l_msg_name VARCHAR2(80);
        l_token1        VARCHAR2(10);

    BEGIN

      IF ((p_tbcv_rec.RESULT_CODE = OKL_API.G_MISS_CHAR OR p_tbcv_rec.RESULT_CODE IS NULL) ) THEN

                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  --Unable to create Category definition as mandatory attributes are provided.
                  OKL_API.set_message(p_app_name    => 'OKL',
                                      p_msg_name    => 'OKL_TX_NO_TBC_ATTR');
                  RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;
      IF (p_tbcv_rec.AGE_OF_EQUIP_FROM IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_FROM <> OKL_API.G_MISS_NUM) AND
         (p_tbcv_rec.AGE_OF_EQUIP_TO IS NOT NULL AND p_tbcv_rec.AGE_OF_EQUIP_TO <> OKL_API.G_MISS_NUM) THEN
          IF p_tbcv_rec.AGE_OF_EQUIP_TO < p_tbcv_rec.AGE_OF_EQUIP_FROM THEN
              x_return_status := OKC_API.G_RET_STS_ERROR;
                  --Unable to create Transcation Business Category definition as none of the attributes are provided.
                  OKL_API.set_message(p_app_name    => 'OKL',
                                  p_msg_name    => 'OKL_TX_INVALID_AGE_RANGE');
                  RAISE G_EXCEPTION_HALT_VALIDATION;

          END IF;
      END IF;


      IF (p_tbcv_rec.result_type_code = 'TBC_CODE') THEN
              OPEN  l_checkduplicate_tbc_csr(p_tbcv_rec.tax_attribute_def_id);
              FETCH l_checkduplicate_tbc_csr INTO l_result_code;
              CLOSE l_checkduplicate_tbc_csr;
              IF l_result_code <> 'XXXXX' THEN
                OPEN  okl_tbc_res_code_fk_csr(l_result_code);
                FETCH okl_tbc_res_code_fk_csr INTO l_meaning;
                CLOSE okl_tbc_res_code_fk_csr;
              END IF;

              l_msg_name := 'OKL_TX_DUP_TBC_UI_ERR';
              l_token1 := 'TBC';

      ELSIF (p_tbcv_rec.result_type_code = 'PC_CODE') THEN
              OPEN  l_checkduplicate_pc_csr(p_tbcv_rec.tax_attribute_def_id);
              FETCH l_checkduplicate_pc_csr INTO l_result_code;
              CLOSE l_checkduplicate_pc_csr;
              IF l_result_code <> 'XXXXX' THEN
                OPEN  okl_pc_res_code_fk_csr(l_result_code);
                FETCH okl_pc_res_code_fk_csr INTO l_meaning;
                CLOSE okl_pc_res_code_fk_csr;
              END IF;

              l_msg_name := 'OKL_TX_DUP_PC_UI_ERR';
              l_token1 := 'PC_CODE';

      ELSIF (p_tbcv_rec.result_type_code = 'UFC_CODE') THEN
              OPEN  l_checkduplicate_ufc_csr(p_tbcv_rec.tax_attribute_def_id);
              FETCH l_checkduplicate_ufc_csr INTO l_result_code;
              CLOSE l_checkduplicate_ufc_csr;
              IF l_result_code <> 'XXXXX' THEN
                OPEN  okl_ufc_res_code_fk_csr(l_result_code);
                FETCH okl_ufc_res_code_fk_csr INTO l_meaning;
                CLOSE okl_ufc_res_code_fk_csr;
              END IF;

              l_msg_name := 'OKL_TX_DUP_UFC_ERR';
              l_token1 := 'UFC_CODE';

      END IF;

      -- There can be at the most one duplicate record.
      IF l_result_code <> 'XXXXX' THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
             -- Another Category already exists for this combination of tax determinants.
             -- modified by dcshanmu for eBTax project - modification start
             -- modified default values passed to p_msg_name and p_token1
         IF l_token1 = 'UFC_CODE' THEN
                     OKL_API.set_message(p_app_name                 => 'OKL',
                                        p_msg_name      => l_msg_name,
                                        p_token1        => l_token1,
                                        p_token1_value  => l_meaning);

         ELSE

            OKL_API.set_message(p_app_name                 => 'OKL',
                                        p_msg_name      => l_msg_name,
                                        p_token1        => l_token1,
                                        p_token1_value  => l_meaning,
                                        p_token2        => 'REC_NO',
                                        p_token2_value  => p_rec_number);
         END IF;
         RAISE G_EXCEPTION_HALT_VALIDATION;

     END IF;

      RETURN (x_return_status);
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        RETURN(x_return_status);
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RETURN(x_return_status);
    END Validate_Record;

PROCEDURE insert_tbc_definition(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN  tbcv_rec_type,
    x_tbcv_rec                     OUT NOCOPY tbcv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_tbcv_rec  tbcv_rec_type;
lx_tbcv_rec  tbcv_rec_type;

BEGIN
OKL_API.init_msg_list(p_init_msg_list);
SAVEPOINT tbc_insert ;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_tbcv_rec :=  p_tbcv_rec;
lx_tbcv_rec :=  x_tbcv_rec;






okl_tbc_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_tbcv_rec
                         ,lx_tbcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_tbcv_rec := lx_tbcv_rec;





--Assign value to OUT variables
x_tbcv_rec  := lx_tbcv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','insert_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_tbc_definition;

PROCEDURE insert_tbc_definition(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN  tbcv_tbl_type,
    x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_tbcv_tbl  tbcv_tbl_type;
lx_tbcv_tbl  tbcv_tbl_type;
lx_tbcv_rec  tbcv_rec_type;

BEGIN
OKL_API.init_msg_list(p_init_msg_list);
SAVEPOINT tbc_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_tbcv_tbl :=  p_tbcv_tbl;
lx_tbcv_tbl :=  x_tbcv_tbl;
FOR i IN lp_tbcv_tbl.FIRST..lp_tbcv_tbl.LAST LOOP
  IF lp_tbcv_tbl.EXISTS(i) THEN
        l_return_status := validate_record (lp_tbcv_tbl(i), i);

        IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        okl_tbc_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_tbcv_tbl(i)
                         ,lx_tbcv_rec);
        lx_tbcv_tbl(i) :=  lx_tbcv_rec;

        IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   END IF;

  END LOOP;

--Assign value to OUT variables
x_tbcv_tbl  := lx_tbcv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','insert_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_tbc_definition;

 PROCEDURE lock_tbc_definition(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN  tbcv_rec_type) IS

BEGIN
    okl_tbc_pvt.lock_row(
                    p_api_version,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_tbcv_rec);

IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','lock_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_tbc_definition;


PROCEDURE lock_tbc_definition(
     p_api_version                  IN   NUMBER
    ,p_init_msg_list                IN   VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tbcv_tbl                     IN   tbcv_tbl_type) IS

BEGIN
    okl_tbc_pvt.lock_row(
                    p_api_version,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_tbcv_tbl);

IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','lock_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_tbc_definition;


PROCEDURE update_tbc_definition(
     p_api_version                  IN   NUMBER
    ,p_init_msg_list                IN   VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tbcv_rec                     IN   tbcv_rec_type
    ,x_tbcv_rec                     OUT  NOCOPY tbcv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_tbcv_rec  tbcv_rec_type;
lx_tbcv_rec  tbcv_rec_type;

BEGIN

SAVEPOINT tbc_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_tbcv_rec :=  p_tbcv_rec;
lx_tbcv_rec :=  x_tbcv_rec;





    okl_tbc_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_tbcv_rec
                             ,lx_tbcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_tbcv_rec := lx_tbcv_rec;




--Assign value to OUT variables
x_tbcv_rec  := lx_tbcv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','update_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_tbc_definition;

PROCEDURE update_tbc_definition(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN  tbcv_tbl_type,
    x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_tbcv_tbl  tbcv_tbl_type;
lx_tbcv_tbl  tbcv_tbl_type;

BEGIN

SAVEPOINT tbc_update;


lp_tbcv_tbl :=  p_tbcv_tbl;
lx_tbcv_tbl :=  x_tbcv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;





    okl_tbc_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_tbcv_tbl
                             ,lx_tbcv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_tbcv_tbl := lx_tbcv_tbl;



--Assign value to OUT variables
x_tbcv_tbl  := lx_tbcv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','update_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_tbc_definition;

--Put custom code for cascade delete by developer
PROCEDURE delete_tbc_definition(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN  tbcv_rec_type)  IS

i                           NUMBER :=0;
l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_tbcv_rec  tbcv_rec_type;
--lx_tbcv_rec  tbcv_rec_type;

BEGIN

SAVEPOINT tbc_delete;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_tbcv_rec :=  p_tbcv_rec;
--lx_tbcv_rec :=  p_tbcv_rec;




--Delete the Master
okl_tbc_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_tbcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_delete;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_delete;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_delete;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','delete_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_tbc_definition;


PROCEDURE delete_tbc_definition(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN  tbcv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_tbcv_tbl  tbcv_tbl_type;
--lx_tbcv_tbl  tbcv_tbl_type;

BEGIN

SAVEPOINT tbc_delete;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_tbcv_tbl :=  p_tbcv_tbl;
--lx_tbcv_tbl :=  p_tbcv_tbl;




--Delete the Master
okl_tbc_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_tbcv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_delete;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_delete;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_delete;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','delete_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_tbc_definition;



PROCEDURE validate_tbc_definition(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_tbcv_rec  tbcv_rec_type;
lx_tbcv_rec  tbcv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT tbc_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_tbcv_rec :=  p_tbcv_rec;
lx_tbcv_rec :=  p_tbcv_rec;




okl_tbc_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tbcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_tbcv_rec := lx_tbcv_rec;








--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','validate_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_tbc_definition;

PROCEDURE validate_tbc_definition(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN  tbcv_tbl_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_tbcv_tbl  tbcv_tbl_type;
lx_tbcv_tbl  tbcv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT tbc_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_tbcv_tbl :=  p_tbcv_tbl;
lx_tbcv_tbl :=  p_tbcv_tbl;



okl_tbc_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_tbcv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_tbcv_tbl := lx_tbcv_tbl;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO tbc_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO tbc_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO tbc_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TBC_DEFINITIONS_PUB','validate_tbc_definition');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_tbc_definition;

END OKL_TBC_DEFINITIONS_PUB;

/
