--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RETURN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RETURN_PVT" AS
/* $Header: OKLRARRB.pls 120.22 2007/12/14 22:26:25 rmunjulu noship $ */


-- GLOBAL VARIABLES

  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_asset_return_pvt.';


    -- To Do
    -- 1. Need to update the floor amount in the contract Header
    -- 2. Set the inventory item id


  -- Start of comments
  --
  -- Procedure Name	: set_defaults
  -- Description	  :
  -- Default the values of parameters if the values are not passed to this API
  -- This assumption is necessary because this API can either be called from
  -- a screen or from some other process api and not all parameters are passed
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE set_defaults(
    px_artv_rec              IN OUT NOCOPY artv_rec_type,
    x_return_status          OUT NOCOPY VARCHAR2)  IS
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_defaults';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In out param, px_artv_rec.relocate_asset_yn: '||px_artv_rec.relocate_asset_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In out param, px_artv_rec.asset_relocated_yn: '||px_artv_rec.asset_relocated_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In out param, px_artv_rec.commmercially_reas_sale_yn: '||px_artv_rec.commmercially_reas_sale_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In out param, px_artv_rec.voluntary_yn: '||px_artv_rec.voluntary_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In out param, px_artv_rec.repurchase_agmt_yn: '||px_artv_rec.repurchase_agmt_yn);
   END IF;

    -- Set the relocate_asset_yn if null
    IF ((px_artv_rec.relocate_asset_yn IS NULL) OR
        (px_artv_rec.relocate_asset_yn = OKL_API.G_MISS_CHAR)) THEN
      px_artv_rec.relocate_asset_yn      :=  'N';
    END IF;

    -- Set the asset_relocated_yn if null
    IF ((px_artv_rec.asset_relocated_yn IS NULL) OR
        (px_artv_rec.asset_relocated_yn = OKL_API.G_MISS_CHAR)) THEN
      px_artv_rec.asset_relocated_yn      :=  'N';
    END IF;

    -- Set the commmercially_reas_sale_yn if null
    IF ((px_artv_rec.commmercially_reas_sale_yn IS NULL) OR
        (px_artv_rec.commmercially_reas_sale_yn = OKL_API.G_MISS_CHAR)) THEN
      px_artv_rec.commmercially_reas_sale_yn      :=  'N';
    END IF;

    -- Set the voluntary_yn if null
    IF ((px_artv_rec.voluntary_yn IS NULL) OR
        (px_artv_rec.voluntary_yn = OKL_API.G_MISS_CHAR)) THEN
      px_artv_rec.voluntary_yn      :=  'N';
    END IF;

    -- Set the repurchase_agmt_yn if null
    IF ((px_artv_rec.repurchase_agmt_yn IS NULL) OR
        (px_artv_rec.repurchase_agmt_yn = OKL_API.G_MISS_CHAR)) THEN
      px_artv_rec.repurchase_agmt_yn      :=  'N';
    END IF;

    x_return_status                   :=   OKL_API.G_RET_STS_SUCCESS;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

   EXCEPTION
    WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       -- Unexpected error
       OKL_API.set_message(p_app_name    => 'OKL',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

  END set_defaults;




  -- Start of comments
  --
  -- Procedure Name	  : calculate_floor_price
  -- Description	  : This procedure calculates the floor price.
  -- Business Rules   :
  -- Parameters		  : p_chr_id - Contract header ID, p_kle_id - Contract Line ID
  -- Version		  : 1.0
  --
  -- End of comments

  FUNCTION  get_floor_price(      p_chr_id          IN   NUMBER,
                                  p_kle_id          IN   NUMBER,
                                  x_msg_count      	OUT  NOCOPY NUMBER,
                                  x_msg_data       	OUT  NOCOPY VARCHAR2,
                                  x_return_status   OUT  NOCOPY VARCHAR2  ) RETURN NUMBER AS

    l_floor_price                NUMBER ;
    l_rulv_rec                   okl_rule_pub.rulv_rec_type;
    floor_price_error            EXCEPTION;
    l_formula_name               VARCHAR2(150) := 'DEFAULT ASSET FLOOR PRICE';
    l_module_name                VARCHAR2(500) := G_MODULE_NAME || 'get_floor_price';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_kle_id: '||p_kle_id);
   END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
   END IF;

     okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMLARL'
                                     ,p_rdf_code         => 'AMCFPR'
                                     ,p_chr_id           => p_chr_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => FALSE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called okl_am_util_pvt.get_rule_record, return status :'||x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_rulv_rec.rule_information1 :'||l_rulv_rec.rule_information1);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found and formula is found
          IF (l_rulv_rec.rule_information1 IS NOT NULL) AND
             (l_rulv_rec.rule_information1 <> OKL_API.G_MISS_CHAR) THEN

              l_formula_name  :=  l_rulv_rec.rule_information1;
          END IF;
    END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_formula_value');
   END IF;

    okl_am_util_pvt.get_formula_value(
                  p_formula_name	=> l_formula_name,
                  p_chr_id	        => p_chr_id,
                  p_cle_id	        => p_kle_id,
		          x_formula_value	=> l_floor_price,
		          x_return_status	=> x_return_status);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called okl_am_util_pvt.get_formula_value, return status :'||x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_floor_price :'||l_floor_price);
   END IF;

    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
     -- Unable to create Asset Return because of the missing floor price formula.
        OKL_API.set_message(  p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_MISSING_FORMULA');
        RAISE floor_price_error;
    END IF;
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_floor_price: '||l_floor_price);
   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;


    RETURN l_floor_price;

  EXCEPTION
    WHEN  floor_price_error THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'floor_price_error');
        END IF;

       RETURN NULL;

    WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       -- Unexpected error
       OKL_API.set_message(p_app_name      => 'OKL',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

       RETURN NULL;

  END get_floor_price;

  -- Start of comments
  --
  -- Procedure Name	  : get_item_price
  -- Description	  : This procedure is used to calculate the Item Price.
  -- Business Rules	  :
  -- Parameters		  : p_chr_id - Contract Header ID, p_kle_id - Contract Line ID
  -- Version		  : 1.0
  -- History          : SECHAWLA 07-FEB-03 Bug # 2758114
  --                    Default item price to 0 if rule instance or formula is not found
  -- End of comments

  FUNCTION  get_item_price (p_chr_id          IN   NUMBER,
                            p_kle_id          IN   NUMBER,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data     	  OUT NOCOPY VARCHAR2,
                            x_return_status   OUT  NOCOPY VARCHAR2  ) RETURN NUMBER AS

     l_item_price                NUMBER ;
     l_rulv_rec                  okl_rule_pub.rulv_rec_type;
     l_module_name               VARCHAR2(500) := G_MODULE_NAME || 'get_item_price';
     is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
     is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
     is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_kle_id: '||p_kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
   END IF;
     okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMLARL'
                                     ,p_rdf_code         => 'AMCFPR'
                                     ,p_chr_id           => p_chr_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => FALSE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record, return status: ' || x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information2: ' || l_rulv_rec.rule_information2);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but formula not found
          IF l_rulv_rec.rule_information2 IS NULL OR l_rulv_rec.rule_information2 = OKL_API.G_MISS_CHAR THEN
               --SECHAWLA 07-FEB-03 Bug # 2758114 : Default item price to 0 if no formula found
               RETURN NULL;
          END IF;
    ELSE
          --SECHAWLA 07-FEB-03 Bug # 2758114 : Default item price to 0 if rule instance is not found
          x_return_status := OKL_API.G_RET_STS_SUCCESS;
          RETURN NULL;
    END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_formula_value');
   END IF;
    okl_am_util_pvt.get_formula_value(
                  p_formula_name	=> l_rulv_rec.rule_information2,
                  p_chr_id	        => p_chr_id,
                  p_cle_id	        => p_kle_id,
		          x_formula_value	=> l_item_price,
		          x_return_status	=> x_return_status);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_formula_value, return status: ' || x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_item_price: ' || l_item_price);
   END IF;
    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RETURN NULL;
    END IF;
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_item_price: '||l_item_price);
   END IF;
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

    RETURN l_item_price;

  EXCEPTION

    WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       -- Unexpected Error
       OKL_API.set_message(p_app_name      => 'OKL',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

       RETURN NULL;

  END get_item_price;


-- Start of comments
  --
  -- Procedure Name	  : get_repurchase_agreement
  -- Description	  : This procedure is used to get the repurchase agreement Y/N flag
  -- Business Rules   :
  -- Parameters		  : p_chr_id - Contract Header ID, p_kle_id - Contract Line ID
  -- Version		  : 1.0
  --
  -- End of comments

  FUNCTION  get_repurchase_agreement(p_chr_id          IN   NUMBER,
                                     p_kle_id          IN   NUMBER,
                                     x_msg_count       OUT NOCOPY NUMBER,
                                     x_msg_data        OUT NOCOPY VARCHAR2,
                                     x_return_status   OUT  NOCOPY VARCHAR2  ) RETURN VARCHAR2 AS

    --Check if Vendor program is attached to the Lease contract
    CURSOR  l_khr_csr(p_id NUMBER) IS
      SELECT  khr.khr_id
      FROM    okl_k_headers khr
      WHERE   khr.id = p_id;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_repurchase_agreement';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    l_repuchase_agreement_yn        VARCHAR2(1);
    l_program_khr_id                NUMBER := NULL;
    l_rulv_rec                      okl_rule_pub.rulv_rec_type;
    repurchase_agreement_error      EXCEPTION;
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_kle_id: '||p_kle_id);
   END IF;

    --Check if Vendor program is attached to the Lease contract
    OPEN  l_khr_csr(p_chr_id);
    FETCH l_khr_csr INTO l_program_khr_id;
    CLOSE l_khr_csr;

    --Is a Vendor program attached to the Lease contract
    IF l_program_khr_id IS NULL THEN
      RAISE repurchase_agreement_error;
    END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
   END IF;
    okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMREPQ'
                                     ,p_rdf_code         => 'AMARQC'
                                     ,p_chr_id           => p_chr_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => FALSE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record, x_return_status: ' || x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record, l_rulv_rec.rule_information1: ' || l_rulv_rec.rule_information1);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but formula not found
          IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN
                RAISE repurchase_agreement_error;
          END IF;
    ELSE
          RAISE repurchase_agreement_error;
    END IF;

    l_repuchase_agreement_yn := l_rulv_rec.rule_information1;
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_repuchase_agreement_yn: '||l_repuchase_agreement_yn);
   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

    RETURN l_repuchase_agreement_yn;

  EXCEPTION
    WHEN  repurchase_agreement_error THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       IF l_khr_csr%ISOPEN THEN
          CLOSE l_khr_csr;
       END IF;
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'repurchase_agreement_error');
        END IF;

       RETURN 'N';

    WHEN OTHERS THEN
       IF l_khr_csr%ISOPEN THEN
          CLOSE l_khr_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       -- Unexpected Error
       OKL_API.set_message(p_app_name      => 'OKL',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

       RETURN 'N';

  END get_repurchase_agreement;



  -- Start of comments
  --
  -- Procedure Name	: assign_remarketer
  -- Description	  : assign default remarketer if a default remarketer is found
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE assign_remarketer(
           p_kle_id                 IN  NUMBER,
           x_rmr_id                 OUT NOCOPY NUMBER,
           x_return_status          OUT NOCOPY VARCHAR2)  IS

    -- This cursor is used to get the item catalog
    CURSOR  l_catgrp_csr(p_id NUMBER) IS
    SELECT  st.item_catalog_group_id
    FROM    MTL_SYSTEM_ITEMS_VL st, OKX_MODEL_LINES_V ml
    WHERE   ml.inventory_item_id = st.inventory_item_id
    AND     ml.parent_line_id = p_id;

    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    p_catalog_group_id            NUMBER;
    p_rmr_id                      NUMBER;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'assign_remarketer';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

    -- This cursor is used to get the remarketer
    CURSOR  l_remarketcombo_csr(p_id NUMBER) IS
    SELECT  RC.rmr_id
    FROM    OKL_DF_CTGY_RMK_TMS  RC, OKL_AM_REMARKET_TEAMS_UV T
    WHERE   RC.rmr_id = T.ORIG_SYSTEM_ID
    AND     RC.ico_id = p_id
    AND     RC.date_effective_from <= SYSDATE
    AND     NVL(RC.date_effective_to, SYSDATE+1) >= SYSDATE;



  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_kle_id: '||p_kle_id);
   END IF;

    OPEN  l_catgrp_csr(p_kle_id);
    FETCH l_catgrp_csr into p_catalog_group_id;
    CLOSE l_catgrp_csr;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_catalog_group_id: '||p_catalog_group_id);
   END IF;

    IF p_catalog_group_id IS NOT NULL AND p_catalog_group_id <> OKL_API.G_MISS_NUM THEN

      OPEN  l_remarketcombo_csr(p_catalog_group_id);
      FETCH l_remarketcombo_csr INTO p_rmr_id;
      CLOSE l_remarketcombo_csr;

      IF p_rmr_id IS NOT NULL AND p_rmr_id <> OKL_API.G_MISS_NUM THEN

        x_rmr_id := p_rmr_id;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;

      ELSE

        p_rmr_id := TO_NUMBER(fnd_profile.value('OKL_DEFAULT_REMARKETER'));

        -- validate default remarketer
        IF  p_rmr_id IS NULL OR p_rmr_id = OKL_API.G_MISS_NUM THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
        ELSE
            x_rmr_id := p_rmr_id;
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
        END IF;

      END IF;

    ELSE

      p_rmr_id := TO_NUMBER(fnd_profile.value('OKL_DEFAULT_REMARKETER'));

      -- validate default remarketer
      IF p_rmr_id IS NULL OR p_rmr_id = OKL_API.G_MISS_NUM THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
      ELSE
            x_rmr_id := p_rmr_id;
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;

    END IF;
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'x_rmr_id: '||x_rmr_id);
   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

    EXCEPTION
    WHEN OTHERS THEN
         IF l_catgrp_csr%ISOPEN THEN
            CLOSE l_catgrp_csr;
         END IF;
         IF l_remarketcombo_csr%ISOPEN THEN
            CLOSE l_remarketcombo_csr;
         END IF;
          -- unexpected error
          OKL_API.set_message(p_app_name      => 'OKL',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

  END assign_remarketer;




  -- Start of comments
  --
  -- Procedure Name	  : create_asset_return
  -- Description	  : This procedure creates an Asset Return record
  -- Business Rules	  :
  -- Parameters		  : p_artv_rec - Asset Return record.
  -- Version		  : 1.0
  -- History          : SECHAWLA - 19-DEC-2002 :  Bug # 2667636
  --                      Added logic to convert floor price an item price from contract currency to functional currency
  --                    SECHAWLA - 16-JAN-03 Bug # 2754280
  --                      Modified code to display user profile option name in messages instead of profile option name
  --                      Removed DEFAULT hint from procedure parameters
  --                    SECHAWLA - 07-FEB-03 Bug # 2758114
  --                      Remove defaulting logic for Item Price and default to 0 if no formula found.
  --                      Propogate error if a formula is found and execution returns error.
  --                    SECHAWLA 07-FEB-03 Bug # 2789656 : Added x_return_status parameter to okl_accounting_util call
  --                    RMUNJULU 3061751 SERVICE CONTRACT INTEGRATION STEPS
  --                  : 29 Oct 2004 PAGARG Bug# 3925453
  --                  :             Additional Input parameter quote id that will
  --                  :             be used to obtain quote type and validate
  --                  :             ARS_CODE
  --                  : DJANASWA Changes for 'Asset repossession for a loan' project
  --                    13-Nov-2007 Added validation for ASSET_FMV_AMOUNT column
  --
  --                 : RKUTTIYA  14-NOV-07  Sprint 2 of Loans Repossession
  --                             Added validations for Repossession Indicator
  -- End of comments

  PROCEDURE create_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_rec					   	IN artv_rec_type,
    x_artv_rec					   	OUT NOCOPY artv_rec_type,
    p_quote_id                      IN NUMBER DEFAULT NULL) AS

    SUBTYPE rasv_rec_type IS OKL_AM_SHIPPING_INSTR_PUB.rasv_rec_type;

    lp_artv_rec                  artv_rec_type := p_artv_rec;
    lx_artv_rec                  artv_rec_type;

    lp_rasv_rec                  rasv_rec_type;
    lx_rasv_rec                  rasv_rec_type;

    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                   CONSTANT VARCHAR2(30) := 'create_asset_return';
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_asset_return';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    l_floor_price                NUMBER := OKL_API.G_MISS_NUM;
    l_inventory_item_id          NUMBER := OKL_API.G_MISS_NUM;
    l_Item_Price                 NUMBER := OKL_API.G_MISS_NUM;
    l_New_Item_Number            VARCHAR2(25);
    l_New_Item_Id                NUMBER := OKL_API.G_MISS_NUM;
    l_rmr_id                     NUMBER := OKL_API.G_MISS_NUM;
    l_api_version                CONSTANT NUMBER := 1;
    l_repurchase_yn              VARCHAR2(1);
    l_chr_id                     NUMBER;
    l_name                       VARCHAR2(150);
    l_item_description           VARCHAR2(1995);
    l_rulv_rec                   okl_rule_pub.rulv_rec_type;
    floor_price_error            EXCEPTION;

    l_contract_status            VARCHAR2(30);

    --SECHAWLA  Bug # 2667636 : new declarations
    l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_contract_curr_code         okc_k_headers_b.currency_code%TYPE;
    lx_contract_currency         okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount          NUMBER;
    l_sysdate                    DATE;

    -- This cursor is used to get contract ID for a given financial asset line
    CURSOR l_okcklinesv_csr(p_id NUMBER) IS
    SELECT chr_id, name, item_description
    FROM   okc_k_lines_v
    WHERE  id = p_id;
    --SECHAWLA 16-JAN-03 Bug # 2754280 : new declarations
    l_user_profile_name          VARCHAR2(240);

    -- SECHAWLA 07-FEB-03 Bug # 2758114 : New declarations
    item_price_error             EXCEPTION;

    -- RMUNJULU 3061751
    l_service_int_needed VARCHAR2(1) := 'N';

    --Bug# 3925453: pagarg +++ T and A +++++++ Start ++++++++++
    CURSOR l_qte_type_csr(p_quote_id NUMBER) IS
    SELECT qtb.qtp_code
    FROM okl_trx_quotes_b qtb
    WHERE qtb.id = p_quote_id;

    l_qtp_code okl_trx_quotes_b.qtp_code%TYPE;
    --Bug# 3925453: pagarg +++ T and A +++++++ End ++++++++++

    -- RRAVIKIR Legal Entity Changes
    CURSOR fetch_legal_entity(p_khr_id NUMBER) IS
    SELECT legal_entity_id
    FROM   okl_k_headers
    WHERE  id = p_khr_id;

    l_legal_entity_id   NUMBER;
    -- Legal Entity Changes

   --rkuttiya added for Loans Repossession
    l_repo_yn     VARCHAR2(1);
    lx_return_Status  VARCHAR2(1);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.id:' || lp_artv_rec.id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.kle_id:' || lp_artv_rec.kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.legal_entity_id:' || lp_artv_rec.legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.new_item_description:' || lp_artv_rec.new_item_description);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.ARS_CODE:' || lp_artv_rec.ARS_CODE);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.art1_code:' || lp_artv_rec.art1_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.rna_id:' || lp_artv_rec.rna_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.date_repossession_required:' || lp_artv_rec.date_repossession_required);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.date_repossession_actual:' || lp_artv_rec.date_repossession_actual);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.date_hold_until:' || lp_artv_rec.date_hold_until);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.floor_price:' || lp_artv_rec.floor_price);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.new_item_price:' || lp_artv_rec.new_item_price);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.currency_code:' || lp_artv_rec.currency_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.currency_conversion_code:' || lp_artv_rec.currency_conversion_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.repurchase_agmt_yn:' || lp_artv_rec.repurchase_agmt_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.rmr_id:' || lp_artv_rec.rmr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.ASSET_FMV_AMOUNT:' || lp_artv_rec.ASSET_FMV_AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.legal_entity_id:' || lp_artv_rec.legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.imr_id:' || lp_artv_rec.imr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.attribute14:' || lp_artv_rec.attribute14);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.new_item_number:' || lp_artv_rec.new_item_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, p_quote_id:' || p_quote_id);
   END IF;

    l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- SECHAWLA  Bug # 2667636 : using sysdate as transaction date for currency conversion routines
    SELECT SYSDATE INTO l_sysdate FROM DUAL;

    IF lp_artv_rec.kle_id IS NULL OR lp_artv_rec.kle_id = OKL_API.G_MISS_NUM THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- Asset Number is required
       OKL_API.set_message(          p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Asset Number');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN   l_okcklinesv_csr(lp_artv_rec.kle_id);
    FETCH  l_okcklinesv_csr INTO l_chr_id, l_name, l_item_description;
    IF l_okcklinesv_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Invalid Asset Number
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Asset Number');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_chr_id :'||l_chr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_name :'||l_name);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_item_description :'||l_item_description);
   END IF;

    IF l_chr_id IS NULL OR l_chr_id = OKL_API.G_MISS_NUM THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- Contract ID is required
       OKL_API.set_message(          p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Contract Id');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE l_okcklinesv_csr;

    -- RRAVIKIR Legal Entity Changes
    OPEN fetch_legal_entity(p_khr_id  =>  l_chr_id);
    FETCH fetch_legal_entity INTO l_legal_entity_id;
    CLOSE fetch_legal_entity;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_legal_entity_id :'||l_legal_entity_id);
   END IF;

    IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_required_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'legal_entity_id');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_artv_rec.legal_entity_id := l_legal_entity_id;
    -- Legal Entity Changes

    IF l_item_description IS NULL OR l_item_description = OKL_API.G_MISS_CHAR THEN
       lp_artv_rec.new_item_description := l_name ;
    ELSE
       lp_artv_rec.new_item_description := l_name||', '||l_item_description;
    END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.validate_contract');
   END IF;

    OKL_AM_LEASE_LOAN_TRMNT_PVT.validate_contract(
                p_api_version               => p_api_version,
                p_init_msg_list             => OKL_API.G_FALSE,
                x_return_status             => x_return_status,
                x_msg_count                 => x_msg_count,
                x_msg_data                  => x_msg_data,
                p_contract_id               => l_chr_id,
                p_control_flag              => 'ASSET_RETURN_CREATE',
                x_contract_status           => l_contract_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_LEASE_LOAN_TRMNT_PVT.validate_contract, x_return_status: ' || x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_contract_status: ' || l_contract_status);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 3925453: pagarg +++ T and A +++++++ Start ++++++++++
    IF p_quote_id <> NULL AND p_quote_id <> OKL_API.G_MISS_NUM
    THEN
       OPEN l_qte_type_csr(p_quote_id => p_quote_id);
       FETCH l_qte_type_csr INTO l_qtp_code;
       CLOSE l_qte_type_csr;
    END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_qtp_code: ' || l_qtp_code);
   END IF;

    --Bug# 3925453: pagarg +++ T and A +++++++ End ++++++++++

    --Bug# 3925453: pagarg +++ T and A ++++
    -- Validating for ARS_CODE
    -- Valid values for ARS_CODE are SCHEDULED, RETURNED, RELEASE_IN_PROCESS
    -- If quote type is TER_RELEASE_WO_PURCHASE then ARS_CODE must be RELEASE_IN_PROCESS
    IF     lp_artv_rec.ARS_CODE IS NULL OR lp_artv_rec.ARS_CODE = OKL_API.G_MISS_CHAR THEN
           lp_artv_rec.ARS_CODE := 'SCHEDULED';
    ELSIF  lp_artv_rec.ARS_CODE NOT IN ('SCHEDULED','RETURNED', 'RELEASE_IN_PROCESS')
    OR     (l_qtp_code = 'TER_RELEASE_WO_PURCHASE' AND lp_artv_rec.ARS_CODE <> 'RELEASE_IN_PROCESS')
    THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- Asset Return status should be set to Scheduled or Returned.
           OKL_API.set_message(      p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_INVALID_CREATE_STATUS');
           RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --rkuttiya added for Loans Repossession
    -- validate that it is not a Loans Repossession
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_CREATE_QUOTE_PVT.check_repo_quote');
   END IF;

    l_repo_yn := OKL_AM_CREATE_QUOTE_PVT.check_repo_quote(p_quote_id,
                                                          lx_return_status);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_CREATE_QUOTE_PVT.check_repo_quote, lx_return_status: ' || lx_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_repo_yn: ' || l_repo_yn);
   END IF;

    IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF  lp_artv_rec.art1_code = 'REPOS_REQUEST' AND l_repo_yn = 'N' THEN

        IF     lp_artv_rec.rna_id IS NULL OR lp_artv_rec.rna_id = OKL_API.G_MISS_NUM THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Agent Name is required
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_REQ_FIELD_ERR',
                                     p_token1        => 'PROMPT',
                                     p_token1_value  => 'rna_id');
               RAISE OKL_API.G_EXCEPTION_ERROR;

        ELSIF  lp_artv_rec.date_repossession_required IS NULL OR lp_artv_rec.date_repossession_required = OKL_API.G_MISS_DATE THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Date Required is required
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_REQ_FIELD_ERR',
                                     p_token1        => 'PROMPT',
                                     p_token1_value  => 'date_repossession_required');
               RAISE OKL_API.G_EXCEPTION_ERROR;

        ELSIF  lp_artv_rec.date_repossession_actual IS NULL OR lp_artv_rec.date_repossession_actual = OKL_API.G_MISS_DATE THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Date Actual is required
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_REQ_FIELD_ERR',
                                     p_token1        => 'PROMPT',
                                     p_token1_value  => 'date_repossession_actual');
               RAISE OKL_API.G_EXCEPTION_ERROR;

        ELSIF  lp_artv_rec.date_hold_until IS NULL OR lp_artv_rec.date_hold_until = OKL_API.G_MISS_DATE THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Date Hold Until is required
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_REQ_FIELD_ERR',
                                     p_token1        => 'PROMPT',
                                     p_token1_value  => 'date_hold_until');
               RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

    END IF;

    -- SECHAWLA  Bug # 2667636 : get the functional and contract currency

    -- get the functional currency
    l_func_curr_code := okl_am_util_pvt.get_functional_currency;
    -- get the contract currency
    l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => l_chr_id);


    -- get the floor price

    l_floor_price  :=   get_floor_price(p_chr_id          => l_chr_id,
                                        p_kle_id          => lp_artv_rec.kle_id,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        x_return_status   => x_return_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'x_return_status of get_floor_price: ' || x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_func_curr_code: ' || l_func_curr_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_contract_curr_code: ' || l_contract_curr_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_floor_price: ' || l_floor_price);
   END IF;


    IF  x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE floor_price_error;
    ELSE
        -- SECHAWLA  Bug # 2667636 : added the following logic to convert floor price to functional currency

        -- Formula amounts are in contract currency. For Asset Return transaction, the amounts should be stored in
        -- functional currency. If the contract currency is different than the functional currency, then convert
        -- the floor price to functional currency amount



        IF l_contract_curr_code <> l_func_curr_code  THEN
           -- convert amount to functional currency
           --SECHAWLA 07-FEB-03 Bug # 2789656 : Added x_return_status parameter to the following procedure call
		   IF (is_debug_statement_on) THEN
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling okl_accounting_util.convert_to_functional_currency');
		   END IF;
           okl_accounting_util.convert_to_functional_currency(
   	            p_khr_id  		  	       => l_chr_id,
   	            p_to_currency   		   => l_func_curr_code,
   	            p_transaction_date 	       => l_sysdate,
   	            p_amount 			       => l_floor_price,
                x_return_status		       => x_return_status,
   	            x_contract_currency	       => lx_contract_currency,
   		        x_currency_conversion_type => lx_currency_conversion_type,
   		        x_currency_conversion_rate => lx_currency_conversion_rate,
   		        x_currency_conversion_date => lx_currency_conversion_date,
   		        x_converted_amount 	       => lx_converted_amount );
		   IF (is_debug_statement_on) THEN
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called okl_accounting_util.convert_to_functional_currency, x_return_status: ' || x_return_status);
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_contract_currency: ' || lx_contract_currency);
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_type: ' || lx_currency_conversion_type);
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_rate: ' || lx_currency_conversion_rate);
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_date: ' || lx_currency_conversion_date);
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_converted_amount: ' || lx_converted_amount);
		   END IF;

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

          lp_artv_rec.floor_price := lx_converted_amount ;

       ELSE
          lp_artv_rec.floor_price := l_floor_price;
       END IF;

    END IF;



    -- get item price

    l_item_price  :=   get_item_price(p_chr_id          => l_chr_id,
                                      p_kle_id          => lp_artv_rec.kle_id,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data,
                                      x_return_status   => x_return_status);

   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'x_return_status of get_item_price: ' || x_return_status);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_item_price: ' || l_item_price);
   END IF;

    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       -- SECHAWLA 07-FEB-03 Bug # 2758114 : Do not default item price to floor price. Propogate error if a formula
       -- is found and execution returns error.
       --lp_artv_rec.new_item_price := l_floor_price;
        RAISE item_price_error;
    ELSE

       -- SECHAWLA 07-FEB-03 Bug # 2758114 : Perform currency conversion if the item price formula executed successfully
       -- If the formula was not found, then item price gets defaulted to 0. Bypass currency conversionin this case.
       IF l_item_price IS NOT NULL THEN

            -- SECHAWLA  Bug # 2667636 : added the following logic to convert item price to functional currency
            IF l_contract_curr_code <> l_func_curr_code  THEN
                -- convert amount to functional currency

                 --SECHAWLA 07-FEB-03 Bug # 2789656 : Added x_return_status parameter to the following procedure call
                okl_accounting_util.convert_to_functional_currency(
   	             p_khr_id  		  	        => l_chr_id,
   	             p_to_currency   		    => l_func_curr_code,
   	             p_transaction_date 	    => l_sysdate ,
   	             p_amount 			        => l_item_price,
                 x_return_status		    => x_return_status,
   	             x_contract_currency	    => lx_contract_currency,
   		         x_currency_conversion_type => lx_currency_conversion_type,
   		         x_currency_conversion_rate => lx_currency_conversion_rate,
   		         x_currency_conversion_date => lx_currency_conversion_date,
   		         x_converted_amount 	    => lx_converted_amount );

			   IF (is_debug_statement_on) THEN
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called okl_accounting_util.convert_to_functional_currency, x_return_status: ' || x_return_status);
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_contract_currency: ' || lx_contract_currency);
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_type: ' || lx_currency_conversion_type);
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_rate: ' || lx_currency_conversion_rate);
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_currency_conversion_date: ' || lx_currency_conversion_date);
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lx_converted_amount: ' || lx_converted_amount);
			   END IF;

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

                lp_artv_rec.new_item_price := lx_converted_amount ;

           ELSE
                lp_artv_rec.new_item_price := l_item_price;
           END IF;
       ELSE
           -- SECHAWLA 07-FEB-03 Bug # 2758114 : Defalut item price to 0 if item price formula not found. In this
           -- case funtional currency amount is also assumed to be 0.
           lp_artv_rec.new_item_price := 0;
       END IF;

    END IF;

    -- SECHAWLA  Bug # 2667636 : populate currency code and currency conversion code
    lp_artv_rec.currency_code := l_func_curr_code;
    lp_artv_rec.currency_conversion_code := l_func_curr_code;


    -- get repurchase agreement

    l_repurchase_yn  :=   get_repurchase_agreement(  p_chr_id          => l_chr_id,
                                                      p_kle_id          => lp_artv_rec.kle_id,
                                                      x_msg_count       => x_msg_count,
                                                      x_msg_data        => x_msg_data,
                                                      x_return_status   =>  x_return_status);

   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'x_return_status of get_repurchase_agreement: ' || x_return_status);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_repurchase_yn: ' || l_repurchase_yn);
   END IF;
    lp_artv_rec.repurchase_agmt_yn := l_repurchase_yn;

    -- Call AssignRemarker procedure to assign the default remarketer
    IF (lp_artv_rec.rmr_id = OKL_API.G_MISS_NUM)
    OR (lp_artv_rec.rmr_id IS NULL)  THEN

        assign_remarketer(
           p_kle_id               => lp_artv_rec.kle_id,
           x_rmr_id               => l_rmr_id,
           x_return_status        => x_return_status);

   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'x_return_status of assign_remarketer: ' || x_return_status);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_rmr_id: ' || l_rmr_id);
   END IF;

      -- Set the message if no default remarketer found
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

          --SECHAWLA 16-JAN-03 Bug# 2754280: Added the following code to display user profile option name in messages
          --                        instead of profile option name
          l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                     p_profile_option_name  => 'OKL_DEFAULT_REMARKETER',
                                     x_return_status        => x_return_status);
		   IF (is_debug_statement_on) THEN
		     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'x_return_status of okl_am_util_pvt.get_user_profile_option_name: ' || x_return_status);
		     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_user_profile_name: ' || l_user_profile_name);
		   END IF;

          IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              --Default Remarketer profile is missing.
              OKL_API.set_message(   p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_DEF_RMK_PROFILE'
                                );
              RAISE okl_api.G_EXCEPTION_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          -- SECHAWLA  16-JAN-03 Bug# 2754280 -- end new code


          OKL_API.set_message(     p_app_name      => 'OKL',
                                   p_msg_name      => 'OKL_AM_RMK_NO_PROFILE_VALUE',
                                   p_token1        => 'PROFILE',
                                   p_token1_value  => l_user_profile_name  -- SECHAWLA 16-JAN-03 Bug# 2754280 : Modified to display user profile option name
                             );
          RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      -- Set the default remarketer
      lp_artv_rec.rmr_id := l_rmr_id;
    END IF;

    --  DJANASWA  Changes for 'Asset repossession for a loan' project BEGIN
    IF (lp_artv_rec.ASSET_FMV_AMOUNT IS NOT NULL
           AND lp_artv_rec.ASSET_FMV_AMOUNT <> OKL_API.G_MISS_NUM) THEN
              IF lp_artv_rec.ASSET_FMV_AMOUNT < 0  THEN
                   x_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset FMV Amount cannot be less than zero.

                  OKL_API.set_message(  p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_AM_ASSET_FMV_AMT_ERR');

                  RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
    END IF;
    --  DJANASWA  Changes for 'Asset repossession for a loan' project END


    -- set the defaults if not passed
    set_defaults(
      px_artv_rec                => lp_artv_rec,
      x_return_status            => x_return_status);

	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'x_return_status of set_defaults: ' || x_return_status);
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_ASSET_RETURNS_PUB.insert_asset_returns');
	END IF;

    -- call insert of tapi
    OKL_ASSET_RETURNS_PUB.insert_asset_returns(
      p_api_version              => p_api_version,
      p_init_msg_list            => OKL_API.G_FALSE,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_artv_rec                 => lp_artv_rec,
      x_artv_rec                 => lx_artv_rec);

	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_ASSET_RETURNS_PUB.insert_asset_returns, x_return_status: ' || x_return_status);
	END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    x_artv_rec      := lx_artv_rec;


    -- Notify Repossession Agent
    --rkuttiya added validation to check that it is not Loans Repossession

    IF  lp_artv_rec.art1_code = 'REPOS_REQUEST' AND l_repo_yn = 'N' THEN
        -- call notify repossession agent wf
	    IF (is_debug_statement_on) THEN
	      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'Raising workflow OKL_AM_WF.raise_business_event,oracle.apps.okl.am.notifyrepoagent, lx_artv_rec.id:' || lx_artv_rec.id);
	    END IF;
        OKL_AM_WF.raise_business_event(lx_artv_rec.id,'oracle.apps.okl.am.notifyrepoagent');
    END IF;

    -- create shipping instructions

    lp_rasv_rec.art_id := lx_artv_rec.id;
    lp_rasv_rec.trans_option_accepted_yn := 'N';

	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_SHIPPING_INSTR_PUB.create_shipping_instr');
	END IF;
    OKL_AM_SHIPPING_INSTR_PUB.create_shipping_instr(p_api_version           => p_api_version
                                                   ,p_init_msg_list         => OKL_API.G_FALSE
                                                   ,x_return_status         => x_return_status
                                                   ,x_msg_count             => x_msg_count
                                                   ,x_msg_data              => x_msg_data
                                                   ,p_rasv_rec              => lp_rasv_rec
                                                   ,x_rasv_rec              => lx_rasv_rec);
	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_SHIPPING_INSTR_PUB.create_shipping_instr, x_return_status: ' || x_return_status);
	END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'Raising workflow OKL_AM_WF.raise_business_event,oracle.apps.okl.am.notifyremarketer, lx_artv_rec.id:' || lx_artv_rec.id);
	END IF;
    -- notify remarketer
    OKL_AM_WF.raise_business_event(lx_artv_rec.id,'oracle.apps.okl.am.notifyremarketer');


	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling okl_am_util_pvt.get_rule_record');
	END IF;
    -- First get the party id from the rule if the custodian is a 3rd party
  	okl_am_util_pvt.get_rule_record (
										p_rgd_code => 'LAAFLG',
										p_rdf_code => 'LAFLTL',
										p_chr_id   => l_chr_id,
										p_cle_id   => lp_artv_rec.kle_id,
										x_rulv_rec => l_rulv_rec,
									    x_return_status => l_return_status,
										p_message_yn => FALSE); -- put error message on stack if there is no rule

	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called okl_am_util_pvt.get_rule_record, l_return_status: ' || l_return_status);
	END IF;

    IF  l_return_status = OKL_API.G_RET_STS_SUCCESS AND l_rulv_rec.object2_id1 IS NOT NULL AND l_rulv_rec.object2_id1 <> OKL_API.G_MISS_NUM THEN
	    IF (is_debug_statement_on) THEN
	      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'Raising workflow OKL_AM_WF.raise_business_event,oracle.apps.okl.am.notifytitleholder, lx_artv_rec.id:' || lx_artv_rec.id);
	    END IF;
        OKL_AM_WF.raise_business_event(lx_artv_rec.id,'oracle.apps.okl.am.notifytitleholder');

    END IF;

  -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++

  -- RMUNJULU 3061751 27-AUG-2003
  -- Check if linked service contract exists for the asset which is returned
	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.check_service_k_int_needed');
	END IF;
  l_service_int_needed := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_service_k_int_needed(
                                            p_asset_id  => lp_artv_rec.kle_id,
                                            p_source    => 'RETURN');
	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_LEASE_LOAN_TRMNT_PVT.check_service_k_int_needed');
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_service_int_needed: ' || l_service_int_needed);
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.service_k_integration');
	END IF;

  -- Do the Service Contract Integration Notification for RETURN
  OKL_AM_LEASE_LOAN_TRMNT_PVT.service_k_integration(
                          p_transaction_id             => lp_artv_rec.kle_id,
                          p_transaction_date           => SYSDATE,
                          p_source                     => 'RETURN',
                          p_service_integration_needed => l_service_int_needed);
	IF (is_debug_statement_on) THEN
	  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_LEASE_LOAN_TRMNT_PVT.service_k_integration');
	END IF;

  -- ++++++++++++++++++++  service contract integration end   ++++++++++++++++++


    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

  EXCEPTION

    WHEN floor_price_error THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'floor_price_error');
        END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');

    -- SECHAWLA 07-FEB-03 Bug # 2758114 : Added a new exception
    WHEN item_price_error THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'item_price_error');
        END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');

    WHEN G_EXCEPTION_INSURANCE_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_INSURANCE_ERROR');
        END IF;

      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF l_okcklinesv_csr%ISOPEN THEN
       CLOSE l_okcklinesv_csr;
    END IF;

    -- RRAVIKIR Legal Entity Changes
    IF fetch_legal_entity%ISOPEN THEN
      CLOSE fetch_legal_entity;
    END IF;
    -- Legal Entity Changes End
    IF (is_debug_exception_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
    END IF;

    x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF l_okcklinesv_csr%ISOPEN THEN
       CLOSE l_okcklinesv_csr;
    END IF;

    -- RRAVIKIR Legal Entity Changes
    IF fetch_legal_entity%ISOPEN THEN
      CLOSE fetch_legal_entity;
    END IF;
    -- Legal Entity Changes End
    IF (is_debug_exception_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
    END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN
    IF l_okcklinesv_csr%ISOPEN THEN
       CLOSE l_okcklinesv_csr;
    END IF;

    -- RRAVIKIR Legal Entity Changes
    IF fetch_legal_entity%ISOPEN THEN
      CLOSE fetch_legal_entity;
    END IF;
    -- Legal Entity Changes End
    IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
    END IF;

     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
  END create_asset_return;





  -- Start of comments
  --
  -- Procedure Name	: perform_cancellation
  -- Description	  : perform_cancellation
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE perform_cancellation IS
  BEGIN
    NULL;
  END ;

  -- Start of comments
  --
  -- Procedure Name	  : check_asset_status
  -- Description	  : This procedure is used to check the status of the asset line
  -- Business Rules	  :
  -- Parameters		  : p_kle_id - financial asset id
  --                    p_asset_numbner - asset number
  -- Version		  : 1.0
  -- History          : SECHAWLA 22-JAN-03 Bug # 2762419  : Created
  -- End of comments

  PROCEDURE check_asset_status(
    p_kle_id         IN NUMBER,
    p_asset_number   IN VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2) AS

    -- This cursor to used to check the status of the asset line
    CURSOR l_okclines_csr IS
    SELECT sts_code
    FROM   okc_k_lines_b
    WHERE  id = p_kle_id;

    l_sts_code   okc_k_lines_b.sts_code%TYPE;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_asset_status';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, p_kle_id:' || p_kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, p_asset_number:' || p_asset_number);
   END IF;

      OPEN  l_okclines_csr;
      FETCH l_okclines_csr INTO l_sts_code;
      IF l_okclines_csr%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Kle ID is invalid
         OKL_API.set_message(
                        p_app_name      => 'OKC',
                        p_msg_name      => G_INVALID_VALUE,
                        p_token1        => G_COL_NAME_TOKEN,
                        p_token1_value  => 'KLE_ID');

       END IF;
       CLOSE l_okclines_csr;

       IF l_sts_code NOT IN ( 'TERMINATED','EXPIRED') THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- Asset ASSET_NUMBER is still STATUS. Asset should be terminated or expired.
          OKL_API.set_message(
                     p_app_name      => 'OKL',
                     p_msg_name      => 'OKL_AM_ASSET_NOT_TERMINATED',
                     p_token1        => 'ASSET_NUMBER',
                     p_token1_value  => p_asset_number,
                     p_token2        => 'STATUS',
                     p_token2_value  => l_sts_code);

       END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

    EXCEPTION
       WHEN OTHERS THEN

           IF l_okclines_csr%ISOPEN THEN
              CLOSE l_okclines_csr;
           END IF;
           IF (is_debug_exception_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
           END IF;

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message(p_app_name      => 'OKC',
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
    END check_asset_status;

  -- Start of comments
  --
  -- Procedure Name	  : update_asset_return
  -- Description	  : This procedure is used to update an Asset Return record
  -- Business Rules	  :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA 16-JAN-03 Bug # 2754280 : Removed DEFAULT hint from procedure parameters
  --                    SECHAWLA 22-JAN-03 Bug # 2762419 : Modified certain validations that were checking for a
  --                    Terminated/Expired contracts, to instead check for Terminated/Expired asset line.
  --                    PAGARG   28-SEP-04 Bug 3918852: Pass meaning as tokens
  --                             to error message instead of lookup code
  --                    SECHAWLA 04-OCT-04 3924244 : Validate the new item number entered by the user. Call the
  --                             Remarketing API or WF depending upon the Remarketing setup
  --                    SECHAWLA 29-OCT-04 3924244 : preserve the new_item_number and imr_id updated by the custom
  --                             remk WF during update
  --       			    SECHAWLA 10-NOV-04 4000128 : Added a message
  --                    SECHAWLA 18-JAN-04 4125635 : Added an additional check before updating the new item number
  --                             during the custom flow
  --                    SECHAWLA 23-MAR-05 4241558 : Removed the item price > 0 validation
  --                    SECHAWLA 24-MAR-05 4241558 : Added validation to check -ve item price
  --                    nikshah -- Bug # 5484903 Fixed,
  --                                         Changed CURSOR l_repurchasetasset_csr(p_art_id NUMBER) SQL definition
  --                    DJANASWA 13-Nov-2007 Changes for 'Asset repossession for a loan' project
  --                                            Added validation for ASSET_FMV_AMOUNT column

  -- End of comments
  PROCEDURE update_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_rec				IN artv_rec_type,
    x_artv_rec				OUT NOCOPY artv_rec_type) AS

    lp_artv_rec                     artv_rec_type := p_artv_rec;
    lx_artv_rec                     artv_rec_type;
    l_floor_amt                     NUMBER := OKL_API.G_MISS_NUM;
    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                      CONSTANT VARCHAR2(30) := 'update_asset_return';
    l_inventory_item_id             NUMBER := OKL_API.G_MISS_NUM;
    l_Item_Price                    NUMBER := OKL_API.G_MISS_NUM;
    l_New_Item_Number               VARCHAR2(25);
    l_New_Item_Id                   NUMBER := OKL_API.G_MISS_NUM;
    l_quantity                      NUMBER;
    l_api_version                   CONSTANT NUMBER := 1;
    l_current_db_status             VARCHAR2(30);
    l_kle_id                        NUMBER;
    l_chr_id                        NUMBER;
    l_contract_status               VARCHAR2(30);
    l_quote_id                      NUMBER;
    l_accepted_yn                   VARCHAR2(1);
    i                               NUMBER;
    l_total_quantity                NUMBER;
    l_item_number                   VARCHAR2(40);
    l_meaning	                    fnd_lookups.meaning%TYPE := NULL;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_asset_return';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);



    -- This cursor is used to get the quantity for the inventory Item
    --SECHAWLA 22-JAN-03 Bug # 2762419 : Added asset_number for displaying in new messages
--start changed by abhsaxen for Bug#6174484
    CURSOR l_assetreturnuv_csr(p_id NUMBER) IS
	SELECT kle.name asset_number,
	  cim.number_of_items quantity,
	  oar.ars_code ars_code,
	  kle.id kle_id,
	  kle.chr_id chr_id,
	  msi.segment1 inventory_item_number
	FROM okl_k_lines_full_v kle,
	  okl_asset_returns_all_b oar,
	  mtl_system_items_b msi,
	  okc_k_lines_b kle2,
	  okc_line_styles_b lse,
	  okc_k_items cim
	WHERE oar.kle_id = kle.id
	 AND oar.imr_id = msi.inventory_item_id(+)
	 AND kle.id = kle2.cle_id
	 AND kle2.lse_id = lse.id
	 AND lse.lty_code = 'ITEM'
	 AND kle2.id = cim.cle_id
	 AND oar.id = p_id;
--end changed by abhsaxen for Bug#6174484

    -- This cursor is used to validate that a BOOKED order exists when asset retun status changes to 'REMARKETED'. It also
    -- validates ordered_quantity with asset return quantity
    CURSOR l_assetsaleuv_csr(p_art_id NUMBER) IS
    SELECT art_id, ordered_quantity
    FROM   okl_am_asset_sale_uv
    WHERE  art_id = p_art_id
    AND    order_status = 'BOOKED';

    -- This cursor is used to get an accepted repurchase quote for an asset
    CURSOR l_repurchasetasset_csr(p_art_id NUMBER) IS
   SELECT OTQB.ID QUOTE_ID , OTQB.ACCEPTED_YN ACCEPTED_YN
   FROM OKL_TRX_QUOTES_B OTQB ,
             OKL_ASSET_RETURNS_B OAR
   WHERE OTQB.ART_ID  = OAR.ID
        AND OTQB.ART_ID = p_art_id;

    --SECHAWLA 22-JAN-03 Bug # 2762419 : new declarations
    l_asset_number   okl_am_asset_returns_uv.asset_number%TYPE;

    --Bug 3918852 fix starts
    --define the cursor to obtain meaning for a given lookup type and code
    CURSOR l_lookup_meaning_csr(p_lookup_type VARCHAR2, p_lookup_code VARCHAR2)
    IS
    SELECT meaning
    FROM fnd_lookups
    WHERE lookup_type = p_lookup_type
      AND lookup_code = p_lookup_code;

    l_asset_return_type fnd_lookups.meaning%TYPE;
    l_asset_return_status fnd_lookups.meaning%TYPE;
    --Bug 3918852 fix ends

    -- SECHAWLA 30-SEP-04 3924244 : New declarations begin

    -- check if item already exists in inventory

    CURSOR l_mtlsystemitems_csr(cp_inv_item_number  IN VARCHAR2) IS
    SELECT 'x'
    FROM   MTL_SYSTEM_ITEMS_B
    WHERE  segment1 = cp_inv_item_number;

    -- check the Remarketing flow option from the setup
    CURSOR l_systemparamsall_csr IS
    SELECT REMK_PROCESS_CODE
    FROM   OKL_SYSTEM_PARAMS ;

    -- get the wf display name
    CURSOR   l_get_wf_details_csr (c_event_name VARCHAR2) IS
    SELECT   IT.display_name
    ,        RP.display_name
    FROM     WF_EVENTS             WFEV,
             WF_EVENT_SUBSCRIPTIONS   WFES,
             wf_runnable_processes_v  RP,
             wf_item_types_vl         IT
    WHERE WFEV.guid = WFES.event_filter_guid
    AND   WFES.WF_PROCESS_TYPE = RP.ITEM_TYPE
    AND   WFES.WF_PROCESS_NAME = RP.PROCESS_NAME
    AND   RP.ITEM_TYPE = IT.NAME
    AND   WFEV.NAME  = c_event_name;

    l_wf_desc       VARCHAR2(100);
    l_process_desc  VARCHAR2(100);
    l_item_cnt      NUMBER := 0;
    l_remk_process  VARCHAR2(15);
    -- SECHAWLA 30-SEP-04 3924244 : New declarations end

    -- SECHAWLA 29-OCT-04 3924244 : new declaraions
    CURSOR l_assetreturn_csr(cp_id IN NUMBER) IS
    SELECT imr_id, new_item_number
    FROM   okl_asset_returns_b
    WHERE  id = cp_id;

    l_wf_imr_id  			NUMBER;
    l_wf_new_item_number 	VARCHAR2(40);

    l_custom_rmk_wf 		VARCHAR2(1) := 'N';
    -- SECHAWLA 29-OCT-04 3924244 : new declaraions end

    l_dummy                 VARCHAR2(1);

    -- RRAVIKIR Legal Entity Changes
    CURSOR fetch_legal_entity(p_khr_id NUMBER) IS
    SELECT legal_entity_id, deal_type --6674730
    FROM   okl_k_headers
    WHERE  id = p_khr_id;

    l_legal_entity_id   NUMBER;
    -- Legal Entity Changes
    -- Bug 6674730 start
    CURSOR l_okclines_csr(p_kle_id NUMBER) IS
    SELECT sts_code
    FROM   okc_k_lines_b
    WHERE  id = p_kle_id;

    l_sts_code   okc_k_lines_b.sts_code%TYPE;
    l_deal_type VARCHAR2(150);
    -- Bug 6674730 end

    -- rmunjulu 6674730
    CURSOR l_mtl_instance_csr (p_kle_id NUMBER) IS
    SELECT cle.id                    ID,
           mtlb.description          item_description,
           mtlb.asset_category_id    asset_category_id,
           hrou.name                 organization_name
    FROM OKC_K_LINES_B CLE,
	     OKC_K_ITEMS CIM,
		 OKC_LINE_STYLES_B LSE,
         MTL_SYSTEM_ITEMS_B MTLB ,
		 OKC_K_LINES_B KLE,
		 HR_OPERATING_UNITS HROU
    WHERE kle.id = p_kle_id
	AND cle.cle_id = kle.id
	AND cle.id = cim.cle_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'ITEM'
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND cim.object1_id1 = mtlb.inventory_item_id
    AND cim.object1_id2 = to_char(mtlb.organization_id)
    AND mtlb.organization_id = hrou.organization_id;

    l_mtl_instance_rec l_mtl_instance_csr%ROWTYPE;

    -- bug 6674730 get the operational options setup
    CURSOR l_operational_csr IS
    SELECT syp.asst_add_book_type_code  corp_book,
           syp.tax_book_1               tax_book_1,
           syp.fa_location_id           fa_location_id
    FROM  OKL_SYSTEM_PARAMS SYP;

    l_operational_rec l_operational_csr%ROWTYPE;
    l_error VARCHAR2(3) := 'N';


  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.id:' || lp_artv_rec.id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.kle_id:' || lp_artv_rec.kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.legal_entity_id:' || lp_artv_rec.legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.new_item_description:' || lp_artv_rec.new_item_description);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.ARS_CODE:' || lp_artv_rec.ARS_CODE);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.art1_code:' || lp_artv_rec.art1_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.rna_id:' || lp_artv_rec.rna_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.date_repossession_required:' || lp_artv_rec.date_repossession_required);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.date_repossession_actual:' || lp_artv_rec.date_repossession_actual);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.date_hold_until:' || lp_artv_rec.date_hold_until);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.floor_price:' || lp_artv_rec.floor_price);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.new_item_price:' || lp_artv_rec.new_item_price);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.currency_code:' || lp_artv_rec.currency_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.currency_conversion_code:' || lp_artv_rec.currency_conversion_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.repurchase_agmt_yn:' || lp_artv_rec.repurchase_agmt_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.rmr_id:' || lp_artv_rec.rmr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.ASSET_FMV_AMOUNT:' || lp_artv_rec.ASSET_FMV_AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.legal_entity_id:' || lp_artv_rec.legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.imr_id:' || lp_artv_rec.imr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.attribute14:' || lp_artv_rec.attribute14);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'In param, lp_artv_rec.new_item_number:' || lp_artv_rec.new_item_number);
   END IF;

    l_return_status :=  OKL_API.START_ACTIVITY(  l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF lp_artv_rec.id IS NULL OR lp_artv_rec.id = OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Asset Return ID is required
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_RETURN_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  l_assetreturnuv_csr(lp_artv_rec.id);
    FETCH l_assetreturnuv_csr INTO l_asset_number, l_quantity, l_current_db_status, l_kle_id, l_chr_id, l_item_number;
    IF  l_assetreturnuv_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Invalid Asset Return ID
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_RETURN_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE l_assetreturnuv_csr;

    -- RRAVIKIR Legal Entity Changes
    OPEN fetch_legal_entity(p_khr_id  =>  l_chr_id);
    FETCH fetch_legal_entity INTO l_legal_entity_id, l_deal_type; --6674730
    CLOSE fetch_legal_entity;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_asset_number :'||l_asset_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_quantity :'||l_quantity);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_current_db_status :'||l_current_db_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_kle_id :'||l_kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_chr_id :'||l_chr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_item_number :'||l_item_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_legal_entity_id :'||l_legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_deal_type :'||l_deal_type);
   END IF;

    IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_required_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'legal_entity_id');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_artv_rec.legal_entity_id := l_legal_entity_id;
    -- Legal Entity Changes

    -- If db status is "available for sale" it can only change to "REMARKETED" or remain "AVAILABLE_FOR_SALE"
    IF l_current_db_status = 'AVAILABLE_FOR_SALE' THEN
       IF lp_artv_rec.ARS_CODE NOT IN ('AVAILABLE_FOR_SALE', 'REMARKETED') THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;

          l_meaning := okl_am_util_pvt.get_lookup_meaning(
                                             p_lookup_type => 'OKL_ASSET_RETURN_STATUS',
                                             p_lookup_code => l_current_db_status);

          --Can not change the asset status when it is already Available For Sale.
          OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_STATUS_CHANGE',
                               p_token1        => 'DB_STATUS',
                               p_token1_value  => l_meaning);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- If db status is scrapped
    IF l_current_db_status = 'SCRAPPED' THEN
       IF lp_artv_rec.ARS_CODE <> 'SCRAPPED' THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;

          l_meaning := okl_am_util_pvt.get_lookup_meaning(
                                             p_lookup_type => 'OKL_ASSET_RETURN_STATUS',
                                             p_lookup_code => l_current_db_status);

          --Can not change the asset status when it is SCRAPPED.
          OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_STATUS_CHANGE',
                               p_token1        => 'DB_STATUS',
                               p_token1_value  => l_meaning);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- If db status is CANCELLED
    IF l_current_db_status = 'CANCELLED' THEN
       IF lp_artv_rec.ARS_CODE <> 'CANCELLED' THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;

          l_meaning := okl_am_util_pvt.get_lookup_meaning(
                                             p_lookup_type => 'OKL_ASSET_RETURN_STATUS',
                                             p_lookup_code => l_current_db_status);


          --Can not change the asset status when it is 'CANCELLED'
          OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_STATUS_CHANGE',
                               p_token1        => 'DB_STATUS',
                               p_token1_value  => l_meaning);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- if db status is REMARKETED
    IF l_current_db_status = 'REMARKETED' THEN
       IF lp_artv_rec.ARS_CODE <> 'REMARKETED' THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;

          l_meaning := okl_am_util_pvt.get_lookup_meaning(
                                             p_lookup_type => 'OKL_ASSET_RETURN_STATUS',
                                             p_lookup_code => l_current_db_status);


          --Can not change the asset status when it is 'REMARKETED'
          OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_STATUS_CHANGE',
                               p_token1        => 'DB_STATUS',
                               p_token1_value  => l_meaning);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- if db status is REPURCHASE
    IF l_current_db_status = 'REPURCHASE' THEN
       IF lp_artv_rec.ARS_CODE <> 'REPURCHASE' THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;

          l_meaning := okl_am_util_pvt.get_lookup_meaning(
                                             p_lookup_type => 'OKL_ASSET_RETURN_STATUS',
                                             p_lookup_code => l_current_db_status);

          --Can not change the asset status when it is 'REPURCHASE'
          OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_STATUS_CHANGE',
                               p_token1        => 'DB_STATUS',
                               p_token1_value  => l_meaning);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    IF l_quantity IS NULL OR l_quantity = OKL_API.G_MISS_NUM THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- Quantity is required
       OKL_API.set_message(          p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'QUANTITY');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- l_kle_id and l_current_db_status can not be null


    -- If status is changing to 'AVAILABLE FOR SALE'
    IF l_current_db_status <> 'AVAILABLE_FOR_SALE' THEN

        IF ((lp_artv_rec.imr_id IS NULL OR  lp_artv_rec.imr_id = OKL_API.G_MISS_NUM)
             AND (lp_artv_rec.ARS_CODE = 'AVAILABLE_FOR_SALE') ) THEN

                -- when the status first changes to Av for sale, make sure that the asset is terminated or expired.

                -- SECHAWLA 22-JAN-03 Bug # 2762419 : call the new procedure to check that the asset line is terminated/expired
                check_asset_status(p_kle_id        => l_kle_id,
                                   p_asset_number  => l_asset_number,
                                   x_return_status => x_return_status);

			   IF (is_debug_statement_on) THEN
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called check_asset_status, x_return_status: '||x_return_status);
			   END IF;
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                -- SECHAWLA 22-JAN-03 Bug # 2762419 : end modification

                -- SECHAWLA 30-SEP-04 3924244 : begin
                -- If the user enters an item number, then validate to ensure that item does not already exist
                -- in inventory
                -- 03-DEC-04 SECHAWLA 4047159 : Added validation for duplicate item number
			     IF p_artv_rec.new_item_number IS NOT NULL THEN
                   OPEN  l_mtlsystemitems_csr(p_artv_rec.new_item_number);
                   FETCH l_mtlsystemitems_csr INTO l_dummy;
                   IF l_mtlsystemitems_csr%FOUND THEN
                       --Item number ITEM_NUMBER already exists in Inventory. Please enter another item number.
          			   OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_ITEM_ALREADY_EXISTS',
                               p_token1        => 'ITEM_NUMBER',
                               p_token1_value  => p_artv_rec.new_item_number);
                       x_return_status := OKL_API.G_RET_STS_ERROR;
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
                   CLOSE l_mtlsystemitems_csr;


                END IF;

                -- Check the remarketing flow setup
                OPEN   l_systemparamsall_csr;
                FETCH  l_systemparamsall_csr INTO l_remk_process;
                IF  l_systemparamsall_csr%NOTFOUND THEN
                    -- Remarketing options are not setup for this operating unit.
                    OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_SETUP');
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
				CLOSE  l_systemparamsall_csr;

			   IF (is_debug_statement_on) THEN
			       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_remk_process: '||l_remk_process);
			   END IF;

				IF l_remk_process IS NULL THEN
		    		-- Remarketing process is not setup for this operating unit.
				    OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_PROCESS');
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    RAISE OKL_API.G_EXCEPTION_ERROR;
            	END IF;

				-- SECHAWLA 30-SEP-04 3924244 : end

                IF p_artv_rec.new_item_description IS NULL OR p_artv_rec.new_item_description = OKL_API.G_MISS_CHAR THEN
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Item Description is required
                    OKL_API.set_message(
                                     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Item Description');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                IF p_artv_rec.new_Item_Price IS NULL OR p_artv_rec.new_Item_Price = OKL_API.G_MISS_NUM THEN
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Item Price is required
                    OKL_API.set_message(
                                     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Item Price');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;


                -- SECHAWLA 29-OCT-04 3924244 : item price should not be zero
                -- IF p_artv_rec.new_Item_Price = 0 THEN -- SECHAWLA 23-MAR-05 4241558 : Removed the item price validation
                IF p_artv_rec.new_Item_Price < 0 THEN -- SECHAWLA 24-MAR-05 4241558 : do not allow -ve item price
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Item Price is invalid
                    OKL_API.set_message(
                                     p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Item Price');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;


                -- SECHAWLA 04-OCT-04 3924244 : Call the following API if the Remarketing process is setup as "Standard"
                -- Pass the item number entered by the user. Item number may be NULL (if user does not enter)
                IF l_remk_process = 'STANDARD' THEN
				   IF (is_debug_statement_on) THEN
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_REMARKET_ASSET_PUB.create_rmk_item');
				   END IF;

               		OKL_AM_REMARKET_ASSET_PUB.create_rmk_item(
               			p_api_version      => p_api_version,
               			p_init_msg_list    => OKL_API.G_FALSE,
               			p_item_number      => p_artv_rec.new_item_number, -- SECHAWLA 04-OCT-04 3924244 : added this parameter
               			p_Item_Description => p_artv_rec.new_item_description,
               			p_Item_Price       => p_artv_rec.new_Item_Price,
               			p_quantity         => l_quantity,
               			x_return_status    => x_return_status,
               			x_msg_count        => x_msg_count,
               			x_msg_data         => x_msg_data,
               			x_New_Item_Number  => l_New_Item_Number,
               			x_New_Item_Id      => l_New_Item_id);
				   IF (is_debug_statement_on) THEN
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_REMARKET_ASSET_PUB.create_rmk_item, x_return_status: '|| x_return_status);
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_New_Item_Number: '|| l_New_Item_Number);
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_New_Item_id: '|| l_New_Item_id);
				   END IF;

              			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              			ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  			RAISE OKL_API.G_EXCEPTION_ERROR;
              			END IF;

             			-- Message Name: OKL_AM_RETURN_INVENTORY_ERROR
             			-- Message Text: Error Processing Inventory Return
             			IF  l_New_Item_id = OKL_API.G_MISS_NUM THEN
                			x_return_status := OKL_API.G_RET_STS_ERROR;
                			--Error creating Inventory item for remarketing.
                			OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      =>'OKL_AM_NO_INVENTORY_ITEM');
                			RAISE OKL_API.G_EXCEPTION_ERROR;
             			END IF;

             			-- set the item_id and Item_name
             			lp_artv_rec.imr_id      :=  l_new_item_id;
             			lp_artv_rec.attribute14 :=  l_New_Item_Number;  -- not being used, setting in base table


             			-- SECHAWLA 04-OCT-04 3924244 : If item number is automatically generated, then
             			-- populate new col new_item_number with item number
             			IF p_artv_rec.new_item_number IS NULL THEN  -- user did not enter item no.
             			   lp_artv_rec.new_item_number := l_New_Item_Number;
             			END IF;

             			-- SECHAWLA 10-NOV-04 4000128 : added the following message
             			OKL_API.set_message(p_app_name     => 'OKL',
                          					p_msg_name     => 'OKL_CONFIRM_UPDATE');

             	-- SECHAWLA 04-OCT-04 3924244 :	For Custom Remarketing Process, launch a WF
             	ELSIF l_remk_process = 'CUSTOM' THEN
             	      -- Raise event to launch the service k integration workflow
				   IF (is_debug_statement_on) THEN
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling  OKL_AM_REMARKET_ASSET_WF.RAISE_RMK_CUSTOM_PROCESS_EVENT');
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'lp_artv_rec.id: '|| lp_artv_rec.id);
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'p_artv_rec.new_item_number: '|| p_artv_rec.new_item_number);
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'p_artv_rec.new_item_description: '|| p_artv_rec.new_item_description);
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'p_artv_rec.new_Item_Price: '|| p_artv_rec.new_Item_Price);
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'l_quantity: '|| l_quantity);
				   END IF;

                      OKL_AM_REMARKET_ASSET_WF.RAISE_RMK_CUSTOM_PROCESS_EVENT(
					                     p_asset_return_id  => lp_artv_rec.id,
                                         p_item_number      => p_artv_rec.new_item_number,
										 p_Item_Description => p_artv_rec.new_item_description,
										 p_Item_Price       => p_artv_rec.new_Item_Price,
										 p_quantity         => l_quantity);
				   IF (is_debug_statement_on) THEN
				       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_REMARKET_ASSET_WF.RAISE_RMK_CUSTOM_PROCESS_EVENT');
				   END IF;

					  l_custom_rmk_wf := 'Y';  -- SECHAWLA 29-OCT-04 3924244 added

					  OPEN  l_get_wf_details_csr('oracle.apps.okl.am.remkcustomflow');
  					  FETCH l_get_wf_details_csr INTO l_wf_desc, l_process_desc;
  					  IF l_get_wf_details_csr%found THEN

      						OKL_API.set_message(p_app_name     => 'OKL',
                          		p_msg_name     => 'OKL_AM_REMK_WF_RAISED',
                          		p_token1       => 'ITEM_DESC',
                          		p_token1_value => l_wf_desc);
  					  END IF;
  					  CLOSE l_get_wf_details_csr;

             	END IF;
       END IF;
    END IF;

    --------------Repossession------------------------
    IF (lp_artv_rec.ARS_CODE = 'REPOSSESSED' AND l_current_db_status <> 'REPOSSESSED') OR
       (lp_artv_rec.ARS_CODE = 'UNSUCCESS_REPO' AND l_current_db_status <> 'UNSUCCESS_REPO') THEN

       -- MDOKAL Bug 2883292,  changed = to <>
       IF lp_artv_rec.art1_code <> 'REPOS_REQUEST'  THEN

          -- rmunjulu Bug 6674730  check if loan and MANUAL then allow
          IF l_deal_type = 'LOAN' AND lp_artv_rec.art1_code = 'NOTIFY_OF_INTENT_TO_RETURN' THEN

              null;
          ELSE

           -- send notification to the user who created the notification request

           -- MDOKAL Bug 2883292, No longer called here
           -- okl_am_wf.raise_business_event(lp_artv_rec.id,'oracle.apps.okl.am.notifycollections');

       -- MDOKAL Bug 2883292, Changed condition
       -- ELSE
           x_return_status := OKL_API.G_RET_STS_ERROR;
           --Repossession status ARS_CODE is invalid for asset return type ART1_CODE.

           --Bug 3918852 fix starts
           --Obtain the meaning for given lookup type and code and pass that as
           --token to display error message.
           OPEN l_lookup_meaning_csr ('OKL_ASSET_RETURN_TYPE', lp_artv_rec.art1_code);
           FETCH l_lookup_meaning_csr INTO l_asset_return_type;
           CLOSE l_lookup_meaning_csr;

           OPEN l_lookup_meaning_csr ('OKL_ASSET_RETURN_STATUS', lp_artv_rec.ARS_CODE);
           FETCH l_lookup_meaning_csr INTO l_asset_return_status;
           CLOSE l_lookup_meaning_csr;

           OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_INVALID_STATUS_TYPE',
                                p_token1        => 'ARS_CODE',
                                p_token1_value  => l_asset_return_status,
                                p_token2        => 'ART1_CODE',
                                p_token2_value  => l_asset_return_type);
           --Bug 3918852 fix ends

           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
    END IF;
    ----------------------------------------------------

    IF lp_artv_rec.ARS_CODE = 'AVAILABLE_FOR_REPAIR' AND l_current_db_status <> 'AVAILABLE_FOR_REPAIR' THEN
       -- permits the creation of asset condition lines
       NULL;
    END IF;

    ---------------Re-Lease-----------------------------
    IF lp_artv_rec.ARS_CODE = 'RE_LEASE' AND l_current_db_status <> 'RE_LEASE' THEN



       -- make sure that the asset is terminated or expired

       -- SECHAWLA 22-JAN-03 Bug # 2762419 : call the new procedure to check that the asset line is terminated/expired
       check_asset_status(p_kle_id        => l_kle_id,
                          p_asset_number  => l_asset_number,
                          x_return_status => x_return_status);
	   IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called check_asset_status, x_return_status: ' || x_return_status);
	   END IF;

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- SECHAWLA 22-JAN-03 Bug # 2762419 : end modification


    END IF;
    ------------------------------------------------------

    IF lp_artv_rec.ARS_CODE = 'SCRAPPED' AND l_current_db_status <> 'SCRAPPED' THEN
       -- make sure that the asset is terminated or expired

       -- SECHAWLA 22-JAN-03 Bug # 2762419 : call the new procedure to check that the asset line is terminated/expired
       check_asset_status(p_kle_id        => l_kle_id,
                          p_asset_number  => l_asset_number,
                          x_return_status => x_return_status);
	   IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called check_asset_status, x_return_status: ' || x_return_status);
	   END IF;

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- SECHAWLA 22-JAN-03 Bug # 2762419 : end modification

	   IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_AM_ASSET_DISPOSE_PVT.dispose_asset');
	   END IF;

        -- call asset disposition for full retirement of the asset
        OKL_AM_ASSET_DISPOSE_PVT.dispose_asset (
                                    p_api_version           => p_api_version,
           			    p_init_msg_list         => OKC_API.G_FALSE,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
           			    x_msg_data              => x_msg_data,
				    p_financial_asset_id    => l_kle_id,
                                    p_quantity              => l_quantity,
                                    p_proceeds_of_sale      => 0,
                                    p_legal_entity_id       => lp_artv_rec.legal_entity_id);
	   IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_AM_ASSET_DISPOSE_PVT.dispose_asset, x_return_status: ' || x_return_status);
	   END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    IF lp_artv_rec.ARS_CODE = 'CANCELLED' AND l_current_db_status <> 'CANCELLED' THEN
       perform_cancellation();
    END IF;

    -- status can change to "Remarketing" only from "Available for Sale"
    IF lp_artv_rec.ARS_CODE = 'REMARKETED' AND l_current_db_status <> 'REMARKETED' THEN
       IF l_current_db_status = 'AVAILABLE_FOR_SALE' THEN
            i := 0;
            l_total_quantity := 0;
            -- Loop thru all of the order lines and calculate the sum total of order quantities for all order lines
            FOR l_assetsaleuv_rec IN  l_assetsaleuv_csr(lp_artv_rec.id) LOOP
                l_total_quantity := l_total_quantity +  l_assetsaleuv_rec.ordered_quantity;
                i := i +1;
            END LOOP;

            IF i = 0 THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                --Can not change the Asset Return status to REMARKETING , as there is no order booked for theis asset

                OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_NO_ORDER_EXISTS');


                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            IF l_total_quantity <> l_quantity THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- Ordered quantity does not match the original Asset Return quantity for this asset.
                OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_QUANTITY_MISMATCH');
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
       ELSE
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Asset can be Remarketed only if it is Available for Sale
            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_NO_REMARKET');
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

    IF lp_artv_rec.ARS_CODE = 'REPURCHASE' AND l_current_db_status <> 'REPURCHASE' THEN
       OPEN  l_repurchasetasset_csr(lp_artv_rec.id);
       FETCH l_repurchasetasset_csr INTO l_quote_id, l_accepted_yn;
       IF l_repurchasetasset_csr%NOTFOUND OR l_quote_id IS NULL OR l_quote_id = OKL_API.G_MISS_NUM OR
          l_accepted_yn IS NULL OR l_accepted_yn = OKL_API.G_MISS_CHAR OR l_accepted_yn <> 'Y' THEN

           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- Can not change Asset Return status to REPURCHASE, as there is no accepted repurchase quote existing for this asset.
           OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_NO_REPURCHASE_QUOTE');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
       CLOSE l_repurchasetasset_csr;
    END IF;

    -- SECHAWLA 29-OCT-04 3924244 : check if the item has ben created by the WF
    -- need to assign the item id and item number in lp_artv_rec before updation
    -- If user entered item number on the screen, lp_artv_rec.new_item_number will have
    -- the item number at this point, lp_artv_rec.imr_id wil be null. If user did not enter item number,
    -- both lp_artv_rec.imr_id and lp_artv_rec.new_item_number would be null at this point
    IF  l_custom_rmk_wf = 'Y' THEN
    	OPEN   l_assetreturn_csr(lp_artv_rec.id);
    	FETCH  l_assetreturn_csr INTO l_wf_imr_id, l_wf_new_item_number;
    	CLOSE  l_assetreturn_csr;


    	IF l_wf_imr_id IS NOT NULL THEN  -- wf has created the item
       	   lp_artv_rec.imr_id := l_wf_imr_id;
       	   -- SECHAWLA 18-JAN-04 4125635 : added the following IF statement
       	   IF lp_artv_rec.new_item_number IS NULL -- user did not enter item no.
       	      AND l_wf_new_item_number IS NOT NULL THEN -- custom wf API updated item no.
            	  lp_artv_rec.new_item_number := l_wf_new_item_number; -- SECHAWLA 03-DEC-04 4047159 : Moved here
           END IF;
        END IF;

        -- -- SECHAWLA 03-DEC-04 4047159
    	/*IF l_wf_new_item_number IS NOT NULL THEN -- wf has creaed the item
      	   lp_artv_rec.new_item_number := l_wf_new_item_number;
    	END IF;
    	*/
    END IF;
    -- SECHAWLA 29-OCT-04 3924244 : added the following piece of code - END

    --  DJANASWA  Changes for 'Asset repossession for a loan' project BEGIN
    IF (lp_artv_rec.ASSET_FMV_AMOUNT IS NOT NULL
           AND lp_artv_rec.ASSET_FMV_AMOUNT <> OKL_API.G_MISS_NUM) THEN
              IF lp_artv_rec.ASSET_FMV_AMOUNT < 0  THEN
                   x_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset FMV Amount cannot be less than zero.

                  OKL_API.set_message(  p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_AM_ASSET_FMV_AMT_ERR');

                  RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
    END IF;
    --  DJANASWA  Changes for 'Asset repossession for a loan' project  END

    -- rmunjulu Bug 6674730 start
    -- Only for Loans - Do some checks
    IF (l_deal_type = 'LOAN') THEN

      -- If date returned is stamped as greater thnn sysdate then throw error
      IF (p_artv_rec.DATE_RETURNED IS NOT NULL AND
          p_artv_rec.DATE_RETURNED <> OKL_API.G_MISS_DATE) THEN
        IF (TRUNC(p_artv_rec.DATE_RETURNED) > TRUNC(SYSDATE)) THEN
          -- You cannot enter a future date as the Date Returned.
          OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_ASSET_DT_RET');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      OPEN  l_okclines_csr(l_kle_id);
      FETCH l_okclines_csr INTO l_sts_code;
      CLOSE l_okclines_csr;

      -- If the asset return is being set to Repossessed (only for Loans) do some checks
      IF  p_artv_rec.ars_code IS NOT NULL
	  AND p_artv_rec.ars_code <> OKL_API.G_MISS_CHAR
	  AND p_artv_rec.ars_code = 'REPOSSESSED' THEN

        -- Asset cannot be in terminated status when changing status to repossessed
        IF (l_sts_code = 'TERMINATED' ) THEN

             -- The asset has been terminated on the contract. You cannot update the return status to Repossessed for a terminated asset.
             OKL_API.set_message( p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_ASSET_LN_TERM');
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Date returned cannot be null when changing status to repossessed
        IF (p_artv_rec.DATE_RETURNED IS NULL OR
            p_artv_rec.DATE_RETURNED = OKL_API.G_MISS_DATE) THEN

		   --You cannot update the return status to Repossessed. Please enter the Date Returned.
		   OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_ASSET_DATE_RET_REQ');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

        -- Asset return value cannot be null when changing status to repossessed
        IF (p_artv_rec.ASSET_FMV_AMOUNT IS NULL OR
            p_artv_rec.ASSET_FMV_AMOUNT = OKL_API.G_MISS_NUM) THEN

           --You cannot update the return status to Repossessed. Please enter the Return Value.
  	       OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_ASSET_RET_VAL_REQ');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

         -- Check for Asset category existence in Inventory (MTL_SYSTEM_ITEMS)
         OPEN l_mtl_instance_csr(l_kle_id);
         FETCH l_mtl_instance_csr INTO l_mtl_instance_rec;
         CLOSE l_mtl_instance_csr;

         IF l_mtl_instance_rec.asset_category_id IS NULL THEN

			  OKL_API.set_message( p_app_name      => 'OKL',
                                   p_msg_name      => 'OKL_AM_ASSET_CAT_DOESNOT_EXIST',
                                   p_token1        => 'ITEM_DESCRIPTION',
                                   p_token1_value  => l_mtl_instance_rec.item_description,
                                   p_token2        => 'ORGANIZATION_NAME',
                                   p_token2_value  => l_mtl_instance_rec.organization_name);
              RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- Check for setup in operational options
         OPEN l_operational_csr;
         FETCH l_operational_csr INTO l_operational_rec;
         IF l_operational_csr%NOTFOUND THEN
           l_error := 'Y';
         END IF;
         CLOSE l_operational_csr;

         IF l_error = 'Y'
		 OR l_operational_rec.corp_book IS NULL
		 OR l_operational_rec.tax_book_1 IS NULL
		 OR l_operational_rec.fa_location_id IS NULL THEN

              -- You cannot update the return status to Repossessed as the System Options
			  -- for Asset Return has not been defined for this Operating Unit.
			  OKL_API.set_message( p_app_name      => 'OKL',
                                   p_msg_name      => 'OKL_AM_ASSET_REPO_OPTIONS');

           RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;

       END IF; -- ars_code NOT NULL

       -- If current status is Repossessed and cancelling or unsuccessful repo or returned or scheduled then error
       IF (l_current_db_status = 'REPOSSESSED') AND
          (p_artv_rec.ars_code IN ('CANCELLED', 'UNSUCCESS_REPO', 'RETURNED', 'SCHEDULED')) THEN

            -- You have selected an invalid return status.
            -- Assets in Repossessed return status cannot be updated to Canceled, Unsuccessful Repossession, Returned or Scheduled for a loan. Please select a valid return status.
		    OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_ASSET_REPO_STATUS');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF; -- for LOAN
    -- rmunjulu Bug 6674730 end

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling OKL_ASSET_RETURNS_PUB.update_asset_returns');
   END IF;
    -- call update of tapi
    OKL_ASSET_RETURNS_PUB.update_asset_returns(
      p_api_version        => p_api_version,
      p_init_msg_list      =>  OKL_API.G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_artv_rec           => lp_artv_rec,
      x_artv_rec           => lx_artv_rec);
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called OKL_ASSET_RETURNS_PUB.update_asset_returns, x_return_status: ' || x_return_status);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- MDOKAL Bug 2883292, Logic moved to call WF
    --------------Collections WF Request------------------------
    IF (lp_artv_rec.ARS_CODE = 'REPOSSESSED' AND l_current_db_status <> 'REPOSSESSED') OR
       (lp_artv_rec.ARS_CODE = 'UNSUCCESS_REPO' AND l_current_db_status <> 'UNSUCCESS_REPO') THEN

       IF lp_artv_rec.art1_code = 'REPOS_REQUEST' THEN

		   IF (is_debug_statement_on) THEN
		       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling okl_am_wf.raise_business_event,oracle.apps.okl.am.notifycollections, lp_artv_rec.id: ' || lp_artv_rec.id);
		   END IF;
           -- send notification to the user who created the notification request
            okl_am_wf.raise_business_event(lp_artv_rec.id,'oracle.apps.okl.am.notifycollections');
       END IF;
    END IF;
    ----------------------------------------------------


    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

      IF l_assetreturnuv_csr%ISOPEN THEN
        CLOSE l_assetreturnuv_csr;
      END IF;

      IF l_assetsaleuv_csr%ISOPEN THEN
         CLOSE l_assetsaleuv_csr;
      END IF;

      IF l_repurchasetasset_csr%ISOPEN THEN
         CLOSE  l_repurchasetasset_csr;
      END IF;

      -- SECHAWLA 04-OCT-04 3924244 : close new cursors
      IF l_get_wf_details_csr%ISOPEN THEN
         CLOSE l_get_wf_details_csr;
      END IF;
      --IF l_mtlsystemitems_csr%ISOPEN THEN
     --    CLOSE l_mtlsystemitems_csr;
	 -- END IF;

      IF l_systemparamsall_csr%ISOPEN THEN
         CLOSE l_systemparamsall_csr;
	  END IF;

      -- SECHAWLA 29-OCT-04 3924244
      IF l_assetreturn_csr%ISOPEN THEN
         CLOSE l_assetreturn_csr;
      END IF;

      -- RRAVIKIR Legal Entity Changes
      IF fetch_legal_entity%ISOPEN THEN
        CLOSE fetch_legal_entity;
      END IF;
      -- Legal Entity Changes End

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

      IF l_assetreturnuv_csr%ISOPEN THEN
         CLOSE l_assetreturnuv_csr;
      END IF;

      IF l_assetsaleuv_csr%ISOPEN THEN
         CLOSE l_assetsaleuv_csr;
      END IF;

      IF l_repurchasetasset_csr%ISOPEN THEN
         CLOSE  l_repurchasetasset_csr;
      END IF;

      -- SECHAWLA 04-OCT-04 3924244 : close new cursors

      IF l_get_wf_details_csr%ISOPEN THEN
         CLOSE l_get_wf_details_csr;
      END IF;
     -- IF l_mtlsystemitems_csr%ISOPEN THEN
      --   CLOSE l_mtlsystemitems_csr;
	 -- END IF;

      IF l_systemparamsall_csr%ISOPEN THEN
         CLOSE l_systemparamsall_csr;
	  END IF;

	  -- SECHAWLA 29-OCT-04 3924244
      IF l_assetreturn_csr%ISOPEN THEN
         CLOSE l_assetreturn_csr;
      END IF;

      -- RRAVIKIR Legal Entity Changes
      IF fetch_legal_entity%ISOPEN THEN
        CLOSE fetch_legal_entity;
      END IF;
      -- Legal Entity Changes End

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     IF l_assetreturnuv_csr%ISOPEN THEN
         CLOSE l_assetreturnuv_csr;
     END IF;

     IF l_assetsaleuv_csr%ISOPEN THEN
         CLOSE l_assetsaleuv_csr;
     END IF;

     IF l_repurchasetasset_csr%ISOPEN THEN
         CLOSE  l_repurchasetasset_csr;
     END IF;

     -- SECHAWLA 04-OCT-04 3924244 : close new cursors
     IF l_get_wf_details_csr%ISOPEN THEN
         CLOSE l_get_wf_details_csr;
      END IF;

     -- IF l_mtlsystemitems_csr%ISOPEN THEN
     --    CLOSE l_mtlsystemitems_csr;
	 -- END IF;

      IF l_systemparamsall_csr%ISOPEN THEN
         CLOSE l_systemparamsall_csr;
	  END IF;

	  -- SECHAWLA 29-OCT-04 3924244
      IF l_assetreturn_csr%ISOPEN THEN
         CLOSE l_assetreturn_csr;
      END IF;

      -- RRAVIKIR Legal Entity Changes
      IF fetch_legal_entity%ISOPEN THEN
        CLOSE fetch_legal_entity;
      END IF;
      -- Legal Entity Changes End

     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
  END update_asset_return;


  -- Start of comments
  --
  -- Procedure Name   : create_asset_return
  -- Description	  : Create multiple asset returns
  -- Business Rules	  :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA 16-JAN-03 Bug # 2754280 : Removed DEFAULT hint from procedure parameters
  --                  : 29 Oct 2004 PAGARG Bug# 3925453
  --                  :             Additional Input parameter quote id
  -- End of comments
  PROCEDURE create_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_tbl					   	IN artv_tbl_type,
    x_artv_tbl					   	OUT NOCOPY artv_tbl_type,
    p_quote_id                      IN NUMBER DEFAULT NULL) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_asset_return';
    l_api_version                  CONSTANT NUMBER := 1;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_asset_return';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'p_artv_tbl.COUNT:'||p_artv_tbl.COUNT);
   END IF;

    l_return_status :=  OKL_API.START_ACTIVITY(  l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      -- loop thru the table of records and create asset return for each record
      LOOP
       IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling create_asset_return');
	   END IF;
        create_asset_return (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i),
          x_artv_rec                     => x_artv_tbl(i),
          p_quote_id                     => p_quote_id); -- 29 Oct 2004 PAGARG Bug# 3925453
       IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called create_asset_return, l_return_status: ' || l_return_status);
	   END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

    x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;


     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

  END create_asset_return;


  -- Start of comments
  --
  -- Procedure Name	: update_asset_return
  -- Description	: Update multiple asset returns
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- History        : SECHAWLA 16-JAN-03 Bug # 2754280 : Removed DEFAULT hint from procedure parameters
  -- End of comments
  PROCEDURE update_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_tbl					   	IN artv_tbl_type,
    x_artv_tbl					   	OUT NOCOPY artv_tbl_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_asset_return';
    l_api_version                  CONSTANT NUMBER := 1;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_asset_return';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'p_artv_tbl.COUNT:'||p_artv_tbl.COUNT);
   END IF;

    l_return_status :=  OKL_API.START_ACTIVITY(  l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_artv_tbl.COUNT > 0) THEN
      i := p_artv_tbl.FIRST;
      -- update asset return for each table record
      LOOP
       IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'calling update_asset_return');
	   END IF;

        update_asset_return (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_artv_rec                     => p_artv_tbl(i),
          x_artv_rec                     => x_artv_tbl(i));
       IF (is_debug_statement_on) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name, 'called update_asset_return, l_return_status: ' || l_return_status);
	   END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
           END IF;
        END IF;

        EXIT WHEN (i = p_artv_tbl.LAST);
        i := p_artv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

    x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

  END update_asset_return;

END OKL_AM_ASSET_RETURN_PVT;

/
