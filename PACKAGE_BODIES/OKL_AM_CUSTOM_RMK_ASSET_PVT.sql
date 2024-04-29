--------------------------------------------------------
--  DDL for Package Body OKL_AM_CUSTOM_RMK_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CUSTOM_RMK_ASSET_PVT" AS
/* $Header: OKLRCREB.pls 120.5 2006/07/18 10:59:00 cdubey noship $ */


-- Start of comments
--
-- Procedure Name  : validate_item_info
-- Description     : Validate Item Information
-- Business Rules  :
-- Parameters      :  Input parameters : p_asset_return_id     -- Asset Return ID
--     									 p_item_number         -- Item #
--     									 p_Item_Description    -- Item Description
--     									 p_Item_Price          -- Item Price
--     									 p_quantity            -- Item Quantity
--
--                    Output Parameters : x_inv_org_id         -- Inventory Org ID
--     									  x_inv_org_name       -- Inventory Org Name
--     									  x_subinv_code        -- Subinventory Code
--     									  x_sys_date           -- System Date
--     									  x_price_list_id	   -- price List ID
--     									  x_item_templ_id      -- Item Template ID
--
-- Version         : 1.0
-- History         : 25-OCT-04 SECHAWLA - Created
-- End of comments
PROCEDURE validate_item_info(
     p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_asset_return_id       IN     NUMBER,
     p_item_number           IN     VARCHAR2,
     p_Item_Description      IN     VARCHAR2,
     p_Item_Price            IN     NUMBER DEFAULT OKL_API.G_MISS_NUM,
     p_quantity              IN     NUMBER DEFAULT 1,
     x_inv_org_id            OUT    NOCOPY NUMBER,
     x_inv_org_name          OUT    NOCOPY VARCHAR2,
     x_subinv_code           OUT    NOCOPY VARCHAR2,
     x_sys_date              OUT    NOCOPY DATE,
     x_price_list_id		 OUT    NOCOPY NUMBER,
     x_item_templ_id         OUT    NOCOPY NUMBER,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2)
IS

-- validate asset return id
CURSOR l_assetreturn_csr(cp_asset_return_id IN NUMBER) IS
SELECT 'x'
FROM   okl_asset_returns_b
WHERE  id = cp_asset_return_id;

-- This cursor is used to validate an organization Id against mtl_organization
CURSOR l_mtlorgcsr(cp_org_id NUMBER) IS
SELECT organization_name
FROM   ORG_ORGANIZATION_DEFINITIONS
WHERE  organization_id = cp_org_id;



-- This cursor is used to validate the list_header_id
CURSOR  l_qplisthdr_csr(cp_list_header_id NUMBER) IS
SELECT  'x'
--FROM    QP_LIST_HEADERS_B -- SECHAWLA 08-DEC-04 4047159
FROM    QP_LIST_HEADERS -- SECHAWLA 08-DEC-04 4047159
WHERE   LIST_HEADER_ID = cp_list_header_id;


-- This cursor is used to get the warehouse for the Order and Line Transaction types
CURSOR l_oetranstypesall_csr(cp_trans_id NUMBER) IS
SELECT warehouse_id, default_outbound_line_type_id, name
FROM   oe_transaction_types_all a, oe_transaction_types_tl b
WHERE  a.transaction_type_id = b.transaction_type_id
AND    a.transaction_type_id = cp_trans_id;

  -- check the Remarketing flow options from the setup
 CURSOR l_systemparamsall_csr IS
 SELECT REMK_ORGANIZATION_ID, REMK_SUBINVENTORY, REMK_PRICE_LIST_ID, REMK_ITEM_TEMPLATE_ID
 FROM   OKL_SYSTEM_PARAMS ;

 -- check if item already exists in inventory
 CURSOR l_mtlsystemitems_csr(cp_inv_item_number  IN VARCHAR2) IS
 SELECT count(*)
 FROM   MTL_SYSTEM_ITEMS_B
 WHERE  segment1 = cp_inv_item_number;

 -- validate item template
 CURSOR l_mtltemplates_csr(cp_item_templ_id IN NUMBER, cp_org_id IN NUMBER) IS
 SELECT TEMPLATE_NAME
       --  DESCRIPTION ,
 FROM  MTL_ITEM_TEMPLATES
 WHERE TEMPLATE_ID = cp_item_templ_id
 AND   ( (CONTEXT_ORGANIZATION_ID IS NULL ) OR (CONTEXT_ORGANIZATION_ID = cp_org_id));

 l_item_cnt  NUMBER;

 l_order_warehouse_id            NUMBER;
 l_line_warehouse_id             NUMBER;
 l_def_outbound_line_type_id     NUMBER;
 l_order_name                    VARCHAR2(30);
 l_line_name                     VARCHAR2(30);
 l_inv_org_id                    NUMBER;
 l_subinv_code                   VARCHAR2(10);
 l_price_list_id                 NUMBER;
 l_item_template_id              NUMBER;
 l_template_name 				 VARCHAR2(30);

 l_return_status                 VARCHAR2(1);
 l_pricelist_exists              VARCHAR2(1);
 l_temp_org_name                 VARCHAR2(240);
 l_default_order_type_id         NUMBER;


 l_sysdate                       DATE;

 l_user_profile_name             VARCHAR2(240);

  -- SECHAWLA 08-MAR-04 3492490 : new declarations


 l_api_name                      CONSTANT VARCHAR2(30) := 'validate_item_info';
 l_api_version                   CONSTANT NUMBER := 1;

 l_dummy                         VARCHAR2(1);
BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info','Begin(+)');
   END IF;

   --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_api_version :'||p_api_version);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_init_msg_list :'||p_init_msg_list);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_asset_return_id :'||p_asset_return_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_item_number :'||p_item_number);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_Item_Description :'||p_Item_Description);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_Item_Price :'||p_Item_Price);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
              'p_quantity :'||p_quantity);

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

     SELECT SYSDATE INTO l_sysdate FROM DUAL;

     x_sys_date := l_sysdate;

     IF p_item_number IS NOT NULL THEN
     	OPEN  l_mtlsystemitems_csr(p_item_number);
     	FETCH l_mtlsystemitems_csr INTO l_item_cnt;
     	CLOSE l_mtlsystemitems_csr;

         IF l_item_cnt > 0 THEN
            --Item number ITEM_NUMBER already exists in Inventory. Please enter another item number.
          	OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_ITEM_ALREADY_EXISTS',
                               p_token1        => 'ITEM_NUMBER',
                               p_token1_value  => p_item_number);
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;


     IF p_item_price IS NULL OR p_item_price = OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        --Item Price is required
        OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ITEM_PRICE');

        RAISE okl_api.G_EXCEPTION_ERROR;
     END IF;

     IF p_quantity IS NULL OR p_quantity = OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        --Item Quantity is required
        OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ITEM_QUANTITY');

        RAISE okl_api.G_EXCEPTION_ERROR;
     END IF;

     -- SECHAWLA 05-OCT-04 3924244 : Migrated profiles to setups
     -- Check the remarketing flow setup
     OPEN   l_systemparamsall_csr;
     FETCH  l_systemparamsall_csr INTO l_inv_org_id, l_subinv_code, l_price_list_id, l_item_template_id;
     IF  l_systemparamsall_csr%NOTFOUND THEN
         -- Remarketing options are not setup for this operating unit.
         OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_SETUP');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
	 CLOSE  l_systemparamsall_csr;


	 IF l_inv_org_id IS NULL THEN
		-- Remarketing Inventory Organization is not setup for this operating unit.
		OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_ORG');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSE
        x_inv_org_id := l_inv_org_id;
     END IF;
     -- SECHAWLA 05-OCT-04 3924244 : Migrated profiles to setups



     OPEN  l_mtlorgcsr(l_inv_org_id);
     FETCH l_mtlorgcsr INTO l_temp_org_name;
     IF    l_mtlorgcsr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;

        OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Remarketing Inventory Organization');

        RAISE okl_api.G_EXCEPTION_ERROR;
     END IF;
     CLOSE l_mtlorgcsr;


     x_inv_org_name := l_temp_org_name;


     -- validate subinventory
     IF l_subinv_code IS NULL THEN

        -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        -- Remarketing Subinventory is not setup for this operating unit.
		OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_SUBINV');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSE
	    x_subinv_code   := l_subinv_code;
     END IF;



     IF l_price_list_id IS NULL THEN

        -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups

        -- Remarketing Price List is not setup for this operating unit.
        OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_PRICE_LIST');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     OPEN  l_qplisthdr_csr(l_price_list_id);
     FETCH l_qplisthdr_csr INTO l_pricelist_exists;
     IF l_qplisthdr_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
		OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Remarketing Price List');
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     CLOSE l_qplisthdr_csr;

     x_price_list_id := l_price_list_id ;


     IF l_item_template_id IS NOT NULL THEN
        OPEN  l_mtltemplates_csr(l_item_template_id, l_inv_org_id);
        FETCH l_mtltemplates_csr INTO l_template_name;
        IF l_mtltemplates_csr%NOTFOUND THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
		   OKC_API.set_message(      p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Item Template');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE l_mtltemplates_csr;
     END IF;

     x_item_templ_id := l_item_template_id;

     -- ASO_ORDER_TYPE_ID is an Oracle Order Capture profile to set the default Order type.
     -- iStore uses this profile to get the default Order type and then assigns this Order type to the Orders

     --l_default_order_type_id := fnd_profile.value('ASO_ORDER_TYPE_ID');
      l_default_order_type_id := aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.G_DEFAULT_ORDER_TYPE,l_inv_org_id); -- CDUBEY - For MOAC Bug 4421236



     IF l_default_order_type_id IS NULL THEN

        --SECHAWLA Bug# 2679812 : Added the following code to display user profile option name in messages
        --                        instead of profile option name
        l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                     p_profile_option_name  => 'ASO_ORDER_TYPE_ID',
                                     x_return_status        => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           --Remarketing Order Type profile is missing.
            OKL_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_ORDER_TYPE_PROFILE'
                                );
            RAISE okl_api.G_EXCEPTION_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        -- SECHAWLA  Bug# 2679812 -- end new code

        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Profile value not defined
        OKL_API.set_message(         p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_PROFILE_VALUE',
                                     p_token1        => 'PROFILE',
                                     p_token1_value  => l_user_profile_name -- modified to display user profile option
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- get the warehouse and the Line Type for the Default Order Type
     OPEN  l_oetranstypesall_csr(l_default_order_type_id);
     FETCH l_oetranstypesall_csr INTO l_order_warehouse_id, l_def_outbound_line_type_id, l_order_name;
     -- This fetch will definitely find the record in oe_transaction_types_all
     CLOSE l_oetranstypesall_csr;


     IF  l_order_warehouse_id IS NULL THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Warehouse not defined for this Order Type
         OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_WAREHOUSE',
                                     p_token1        => 'TYPE',
                                     p_token1_value  => 'ORDER',
                                     p_token2        => 'NAME',
                                     p_token2_value  => l_order_name
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF l_def_outbound_line_type_id IS NULL THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Line Type not defined for this Order Type
         OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_LINE_TYPE',
                                     p_token1        => 'ORDER_TYPE',
                                     p_token1_value  => l_order_name
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- get the warehouse for the Line type corresponding to the Default Order Type
     OPEN  l_oetranstypesall_csr(l_def_outbound_line_type_id);
     FETCH l_oetranstypesall_csr INTO l_line_warehouse_id, l_def_outbound_line_type_id, l_line_name;
     -- This fetch will definitely find the record in oe_transaction_types_all
     CLOSE l_oetranstypesall_csr;

     IF  l_line_warehouse_id IS NULL THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Warehouse not defined for this Line Type
         OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_WAREHOUSE',
                                     p_token1        => 'TYPE',
                                     p_token1_value  => 'LINE',
                                     p_token2        => 'NAME',
                                     p_token2_value  => l_line_name
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF l_order_warehouse_id <> l_line_warehouse_id THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Warehouses for the Order Type ORDER_TYPE and Line Type LINE_TYPE do not match.
         OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_WHS_MISMATCH',
                                     p_token1        => 'ORDER_TYPE',
                                     p_token1_value  => l_order_name,
                                     p_token2        => 'LINE_TYPE',
                                     p_token2_value  => l_line_name
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF l_inv_org_id <> l_order_warehouse_id THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Shipping organization should be the same as the inventory item organization.
         OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_INVALID_WHS'
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.','End(-)');
     END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
        END IF;

        IF l_mtlsystemitems_csr%ISOPEN THEN
		   CLOSE l_mtlsystemitems_csr;
		END IF;

        IF l_mtlorgcsr%ISOPEN THEN
           CLOSE l_mtlorgcsr;
        END IF;


        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_qplisthdr_csr%ISOPEN THEN
           CLOSE l_qplisthdr_csr;
        END IF;

        IF l_oetranstypesall_csr%ISOPEN THEN
            CLOSE l_oetranstypesall_csr;
        END IF;


        -- SECHAWLA 05-OCT-04 3924244 : close new cursor
        IF l_systemparamsall_csr%ISOPEN THEN
            CLOSE l_systemparamsall_csr;
    	END IF;

        IF l_assetreturn_csr%ISOPEN THEN
            CLOSE l_assetreturn_csr;
    	END IF;

    	IF l_mtltemplates_csr%ISOPEN THEN
    	    CLOSE l_mtltemplates_csr;
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

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info.',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

        IF l_mtlsystemitems_csr%ISOPEN THEN
		   CLOSE l_mtlsystemitems_csr;
		END IF;

        IF l_mtlorgcsr%ISOPEN THEN
           CLOSE l_mtlorgcsr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_qplisthdr_csr%ISOPEN THEN
           CLOSE l_qplisthdr_csr;
        END IF;

        IF l_oetranstypesall_csr%ISOPEN THEN
            CLOSE l_oetranstypesall_csr;
        END IF;

        -- SECHAWLA 05-OCT-04 3924244 : close new cursor
        IF l_systemparamsall_csr%ISOPEN THEN
            CLOSE l_systemparamsall_csr;
    	END IF;

    	IF l_assetreturn_csr%ISOPEN THEN
            CLOSE l_assetreturn_csr;
    	END IF;

    	IF l_mtltemplates_csr%ISOPEN THEN
    	    CLOSE l_mtltemplates_csr;
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

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info. ',
                  'EXCEPTION :'||sqlerrm);
        END IF;

        IF l_mtlsystemitems_csr%ISOPEN THEN
		   CLOSE l_mtlsystemitems_csr;
		END IF;

	    IF l_mtlorgcsr%ISOPEN THEN
           CLOSE l_mtlorgcsr;
        END IF;
               -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_qplisthdr_csr%ISOPEN THEN
           CLOSE l_qplisthdr_csr;
        END IF;

        IF l_oetranstypesall_csr%ISOPEN THEN
            CLOSE l_oetranstypesall_csr;
        END IF;

        -- SECHAWLA 05-OCT-04 3924244 : close new cursor
        IF l_systemparamsall_csr%ISOPEN THEN
            CLOSE l_systemparamsall_csr;
    	END IF;

    	IF l_assetreturn_csr%ISOPEN THEN
            CLOSE l_assetreturn_csr;
    	END IF;

    	IF l_mtltemplates_csr%ISOPEN THEN
    	    CLOSE l_mtltemplates_csr;
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


END validate_item_info;


-- Start of comments
--
-- Procedure Name  : create_inv_item
-- Description     : Create Inventory Item
-- Business Rules  :
-- Parameters      :  Input parameters : p_asset_return_id     -- Asset Return ID
--   									 p_Organization_Id     -- Org ID
--   									 p_organization_name   -- Org Name
-- 										 p_Item_Description    -- Item Description
-- 										 p_subinventory        -- Subinventory
-- 										 p_sysdate             -- System Date
--  									 p_item_number         -- Item #
--  									 p_item_templ_id       -- Item Template ID
--
--                    Output Parameters : x_New_Item_Number    -- Item #
--										  x_New_Item_Id        -- Item ID
--
-- Version         : 1.0
-- History         : 25-OCT-04 SECHAWLA - Created
-- End of comments
PROCEDURE create_inv_item
(  p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
   p_asset_return_id      IN  NUMBER,
   p_Organization_Id      IN  NUMBER,
   p_organization_name    IN  VARCHAR2  -- remk org name
 , p_Item_Description     IN  VARCHAR2
 , p_subinventory         IN  VARCHAR2
 , p_sysdate              IN  DATE
 -- SECHAWLA 05-OCT-04 3924244 : p_item_number may be populated for the master org (if user entered item no.)
 , p_item_number          IN  VARCHAR2   --SECHAWLA Bug# 2679812 : Added new parameter
 , p_item_templ_id        IN  NUMBER
 , x_New_Item_Number      OUT NOCOPY VARCHAR2
 , x_New_Item_Id          OUT NOCOPY NUMBER
 , x_Return_Status        OUT NOCOPY VARCHAR2
 , x_msg_count            OUT NOCOPY NUMBER
 , x_msg_data             OUT NOCOPY VARCHAR2
) IS

-- This cursor is used to validate Organization and subinventory
CURSOR l_mtlsecinv_csr(p_inv_org_id NUMBER, p_subinv_code VARCHAR2) IS
SELECT 'Validate Org and Subinv'
FROM   mtl_secondary_inventories
WHERE  organization_id = p_inv_org_id
AND    secondary_inventory_name = p_subinv_code;

CURSOR l_mtlparam_csr(p_org_id NUMBER) IS
SELECT a.master_organization_id, b.organization_name master_org_name
FROM   mtl_parameters a , ORG_ORGANIZATION_DEFINITIONS b
WHERE  a.organization_id = p_org_id
AND    a.master_organization_id = b.organization_id ;




--- from create_inv_item------
    SUBTYPE   item_rec_type    IS  inv_item_grp.item_rec_type;
    SUBTYPE   error_tbl_type   IS  inv_item_grp.error_tbl_type;
    SUBTYPE   artv_rec_type    IS  OKL_ASSET_RETURNS_PUB.artv_rec_type;
    -- sequence for item_number
    CURSOR l_seqnextval_csr IS
    SELECT OKL_IMR_SEQ.NEXTVAL
    FROM   DUAL;

    l_Item_rec            item_rec_type;
    x_Item_rec            item_rec_type;
    l_commit              VARCHAR2(1);
    l_validation_level    NUMBER;
    x_Error_tbl           error_tbl_type;
    l_description         VARCHAR2(240);
    l_long_description    VARCHAR2(4000);
    l_Item_Number         VARCHAR2(2000);
   -- l_Organization_Id     NUMBER;
    l_return_status       VARCHAR2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'create_inv_item';
    l_api_version         CONSTANT NUMBER := 1;
---
    l_master_org_id       NUMBER;
    l_master_org_name     ORG_ORGANIZATION_DEFINITIONS.organization_name%TYPE;
    l_iterations          NUMBER;
    l_current_org         NUMBER;
    l_current_org_name    ORG_ORGANIZATION_DEFINITIONS.organization_name%TYPE; -- SECHAWLA 08-DEC-04 4047159
    l_item_id             NUMBER;
    l_New_Item_Number     VARCHAR2(2000);
    l_New_Item_Id         NUMBER;
    l_temp                VARCHAR2(25);
    l_assign_subinv       VARCHAR2(1);

    lp_artv_rec           artv_rec_type;
    lx_artv_rec           artv_rec_type;

BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item','Begin(+)');
   END IF;

   --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_api_version :'||p_api_version);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_init_msg_list :'||p_init_msg_list);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_asset_return_id :'||p_asset_return_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_Organization_Id :'||p_Organization_Id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_organization_name :'||p_organization_name);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_Item_Description :'||p_Item_Description);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_subinventory :'||p_subinventory);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_sysdate :'||p_sysdate);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_item_number :'||p_item_number);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'p_item_templ_id :'||p_item_templ_id);

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

  -- SECHAWLA Bug# 2679812 : Get the Master Org for the Inv Org
     OPEN  l_mtlparam_csr(p_organization_id);

     -- SECAHWLA 08-MAR-04 3492490  : Added master org name
     FETCH l_mtlparam_csr INTO l_master_org_id, l_master_org_name;
     IF l_mtlparam_csr%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Inventory organization is not set up in MTL Parameters.
         OKL_API.set_message(   p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_NO_ORG_PARAM'
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     IF l_master_org_id IS NULL THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Master organization is not defined for inventory organization.
         OKL_API.set_message(   p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_NO_MASTER_ORG'
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     CLOSE l_mtlparam_csr;

     -- SECHAWLA Bug# 2679812 :
     -- If inv org is a master org then create item only in master org. If 2 orgs are different, then first craete
     -- the item in master org and then assign the same item to child org
     IF p_organization_id = l_master_org_id THEN
        l_iterations := 1;
     ELSE
        l_iterations := 2;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'l_iterations '||l_iterations);
     END IF;


     -- SECHAWLA Bug# 2679812 :
     -- This loop is executed once if the inv org is also a master org whereas if the 2 orgs are different,
     -- this loop is executed twice, once for the master org and then for the child org
     FOR i IN 1..l_iterations LOOP

        IF i = 1 THEN
           l_current_org := l_master_org_id;
           l_current_org_name := l_master_org_name;  -- SECHAWLA 08-DEC-04 4047159
           --l_item_number := NULL;  -- SECHAWLA 05-OCT-04 3924244
           l_item_number := p_item_number; -- SECHAWLA 05-OCT-04 3924244 : Use item no. entered by the user. It may be NULL
           l_item_id := NULL;
        ELSIF i = 2 THEN
           l_current_org := p_organization_id; --child org
           l_current_org_name := p_organization_name; -- SECHAWLA 08-DEC-04 4047159
           l_item_number := l_New_Item_Number;
           l_item_id := l_New_Item_Id;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'l_current_org'||l_current_org);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'l_item_number'||l_item_number);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
              'l_item_id'||l_item_id);
        END IF;

        ---------------------
        -- SECHAWLA 08-MAR-04 3492490 : Moved the following validation here from the beginning. So it can be
        -- performed for both Master and Child org

        OPEN   l_mtlsecinv_csr(l_current_org , p_subinventory );
        FETCH  l_mtlsecinv_csr INTO l_temp;
        IF  l_mtlsecinv_csr%NOTFOUND THEN
           -- x_return_status := OKL_API.G_RET_STS_ERROR;

            IF  (p_organization_id <> l_master_org_id  AND  i = 1 )THEN
                /* SECHAWLA 19-MAY-04 3634514 : Commented out
                --Subinventory SUBINVENTORY is not defined for the organization MASTER_ORG, which is the Master organization of the Remarketing Inventory organization CHILD_ORG.
                OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_RMK_MST_ORG_SUBINV',
                          p_token1       => 'SUBINVENTORY',
                          p_token1_value => l_subinv_code,
                          p_token2       => 'MASTER_ORG',
                          p_token2_value => l_master_org_name,
                          p_token3       => 'CHILD_ORG',
                          p_token3_value => l_temp_org_name);
                 */
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  '(l_inv_org_id <> l_master_org_id  AND  i = 1)  sts'||x_return_status);

                 END IF;
                 NULL;
             ELSE
                x_return_status := OKL_API.G_RET_STS_ERROR;
                --Subinventory SUBINVENTORY is invalid for the organization ORGANIZATION.
                OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_RMK_ORG_SUBINV',
                          p_token1       => 'SUBINVENTORY',
                          p_token1_value => p_subinventory,
                          p_token2       => 'ORGANIZATION',
                          p_token2_value => p_organization_name);
                RAISE OKL_API.G_EXCEPTION_ERROR; --SECHAWLA 19-MAY-04 3634514 : Added
             END IF;

             --RAISE OKL_API.G_EXCEPTION_ERROR; --SECHAWLA 19-MAY-04 3634514 : Commented out
        END IF;
        CLOSE l_mtlsecinv_csr;


        --SECHAWLA 19-MAY-04 3634514 : populate subinventory fields in the item master only if the
        --Remarketing org is Master Org OR if the remarketing org is the child org and the item is
        --being assigned to the child org

        IF (l_iterations = 1) OR (i = 2) THEN
           l_assign_subinv := 'Y';
        ELSE
           l_assign_subinv := 'N';
        END IF;
        --SECHAWLA 19-MAY-04 3634514 : end


        ---------------------

        -- Create the Item in Inventory
        l_validation_level :=  FND_API.G_VALID_LEVEL_FULL;



   IF l_item_number IS NULL THEN   --SECHAWLA Bug# 2679812 : Item number is null when the item has not been created
                                   --in the master org yet.
        OPEN  l_seqnextval_csr;
        FETCH l_seqnextval_csr INTO l_Item_Number;
        IF l_seqnextval_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- Failed to create sequence for Item Number
                OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_ITEM_NUM_SEQ'
                           );
                RAISE okl_api.G_EXCEPTION_ERROR;
        END IF;
        CLOSE l_seqnextval_csr;
        --SECHAWLA 14-MAR-03 : Prefixed the sequence generated item number with 'OKL' to prevent duplicate
        -- item numbers within the same org, incase an external application has already created an item with same
        -- item # generated by OKL's sequence.

        l_Item_rec.ITEM_NUMBER := 'OKL'||l_Item_Number;
   ELSE
        l_Item_rec.ITEM_NUMBER := l_item_number; --SECHAWLA Bug# 2679812 : If Item has alreday been created in the
                                                 -- master org, then use the same item number for the child org assignment
   END IF;

   --SECHAWLA Bug# 2679812 : Item id is not null when the item has already been created in the master org. use the
   --same item id for child org assignment
   IF l_item_id IS NOT NULL THEN
      l_Item_rec.INVENTORY_ITEM_ID := l_item_id;
   END IF;


   IF (p_Item_Description IS NULL) THEN
       l_description := l_Item_Number;
       l_long_description := l_Item_Number;
   ELSE
       l_description := p_Item_Description;
       l_long_description := p_Item_Description;
   END IF;

   l_Item_rec.ORGANIZATION_ID := l_current_org;

   l_Item_rec.ENABLED_FLAG := 'Y';
   -- SECHAWLA 15-MAY-04 3633627 : start_date_active should not have the time portion
   l_Item_rec.START_DATE_ACTIVE := trunc(p_sysdate);
   l_Item_rec.DESCRIPTION := l_description;
   l_Item_rec.LONG_DESCRIPTION := l_long_description;

   IF p_item_templ_id IS NULL THEN -- No template is specified
   		l_Item_rec.PRIMARY_UOM_CODE := 'EA';
   		l_Item_rec.INVENTORY_ITEM_STATUS_CODE := 'Active';
   		l_Item_rec.ITEM_TYPE := 'I';
   		l_Item_rec.INVENTORY_ITEM_FLAG := 'Y';
   		l_Item_rec.STOCK_ENABLED_FLAG := 'Y';
   		l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG := 'Y';
   		l_Item_rec.CUSTOMER_ORDER_FLAG := 'Y';
   		l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG := 'Y';
   		l_Item_rec.SHIPPABLE_ITEM_FLAG := 'Y';
   		l_Item_rec.INTERNAL_ORDER_FLAG := 'Y';
   		l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG := 'Y';
   		l_Item_rec.ATP_FLAG := 'Y';
   		l_Item_rec.SO_TRANSACTIONS_FLAG := 'Y';
   		l_Item_rec.ORDERABLE_ON_WEB_FLAG := 'Y';
   		l_Item_rec.WEB_STATUS := 'PUBLISHED';

   	    -- SECHAWLA 08-DEC-04 4047159 : Need to set the following 2 attributes for the billing process
        l_Item_rec.invoiceable_item_flag := 'Y';
        l_Item_rec.invoice_enabled_flag := 'Y';
   END IF;
   -- subinventory and distribution account ID are retrieved from profiles at the time of item creation. Since profiles
   -- may change between the time item is created and time when Order is booked against the item, we store these values
   -- in the following fields. Later when we reduce the quantitiy of an item, after the order is booked, we can
   -- query mtl_system_items with inventory_item_id and org_id and get source_subinventory and distribution account.

   --SECHAWLA 19-MAY-04 3634514: Populate subinventory only if p_assign_subinv = 'Y'
   IF l_assign_subinv = 'Y' THEN
      l_item_rec.SOURCE_TYPE := 1;
      l_Item_rec.SOURCE_SUBINVENTORY := p_subinventory;
	  l_Item_rec.SOURCE_ORGANIZATION_ID := l_current_org;
   END IF;
  -- SECHAWLA Bug# 2620853 : Distribution accout id is not stored, as it is optional
  -- l_Item_rec.ENCUMBRANCE_ACCOUNT := p_distribution_acct_id;

   l_commit := okl_api.g_FALSE;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  'before INV_Item_GRP.create_item'||x_return_status);

   END IF;
   IF p_item_templ_id IS NULL THEN
   		INV_Item_GRP.create_item
   		(  		p_commit              => l_commit
     		,   p_validation_level    => l_validation_level
     		,   p_Item_rec            => l_Item_rec
     		,   x_Item_rec            => x_item_rec
     		,   x_return_status       => x_return_status
     		,   x_Error_tbl           => x_Error_tbl
   		);
	ELSE
	    INV_Item_GRP.create_item
   		(  		p_commit              => l_commit
     		,   p_validation_level    => l_validation_level
     		,   p_Item_rec            => l_Item_rec
     		,   x_Item_rec            => x_item_rec
     		,   x_return_status       => x_return_status
     		,   x_Error_tbl           => x_Error_tbl
     		,   p_Template_Id         => p_item_templ_id
   		);
	END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  'after INV_Item_GRP.create_item'||x_return_status);

   END IF;
  IF ( x_return_status = okl_api.G_RET_STS_SUCCESS ) THEN
     l_New_Item_Number := x_item_rec.ITEM_NUMBER;
     l_New_Item_Id := x_item_rec.INVENTORY_ITEM_ID;
  ELSE

      -- SECHAWLA 08-DEC-04 4047159 : added the following message
      -- Error creating inventory item ITEM_NUMBER in organization ORG_NAME.
      OKL_API.set_message(  p_app_name      => 'OKL',
                            p_msg_name      => 'OKL_AM_RMK_ITEM_FAILED',
                            p_token1        => 'ITEM_NUMBER',
                            p_token1_value  => l_Item_rec.ITEM_NUMBER,
                            p_token2        => 'ORG_NAME',
                            p_token2_value  => l_current_org_name);

      -- display the error messages from the x_error_tbl table
      FOR i IN 1 .. x_Error_tbl.COUNT LOOP
          -- Error: Transaction Id = TRX_ID
          OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_TRANS_ID',
                                p_token1        => 'TRX_ID',
                                p_token1_value  => x_Error_tbl(i).TRANSACTION_ID
                           );
          -- Error : Unique Id = UNIQUE_ID
          OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_UNIQUE_ID',
                                p_token1        => 'UNIQUE_ID',
                                p_token1_value  => x_Error_tbl(i).UNIQUE_ID
                           );
          -- Error : Table Name = TABLE_NAME
          OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_TABLE_NAME',
                                p_token1        => 'TABLE_NAME',
                                p_token1_value  => x_Error_tbl(i).TABLE_NAME
                           );

          --Error : Column Name = COLUMN_NAME
          OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_COLUMN_NAME',
                                p_token1        => 'COLUMN_NAME',
                                p_token1_value  => x_Error_tbl(i).COLUMN_NAME
                           );

          --Error : Message Name = MSG_NAME
          OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_MSG_NAME',
                                p_token1        => 'MSG_NAME',
                                p_token1_value  => x_Error_tbl(i).MESSAGE_NAME
                           );

          -- Error : Message Text = MSG_TEXT
          OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_MSG_TEXT',
                                p_token1        => 'MSG_TEXT',
                                p_token1_value  => x_Error_tbl(i).MESSAGE_TEXT
                           );

      END LOOP;
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -----------



     END LOOP;

     -------
     -- set the item_id and Item_name
     lp_artv_rec.id := p_asset_return_id;
     lp_artv_rec.imr_id :=  l_new_item_id;
     --If item number is automatically generated, then
     -- populate new col new_item_number with item number
     IF p_item_number IS NULL THEN  -- user did not enter item no.
        lp_artv_rec.new_item_number := l_new_item_number;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  'before OKL_ASSET_RETURNS_PUB.update_asset_returns'||x_return_status);

     END IF;

     -- call update of tapi
    OKL_ASSET_RETURNS_PUB.update_asset_returns(
      p_api_version        => p_api_version,
      p_init_msg_list      => OKL_API.G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_artv_rec           => lp_artv_rec,
      x_artv_rec           => lx_artv_rec);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  'after OKL_ASSET_RETURNS_PUB.update_asset_returns'||x_return_status);

    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
     -------

     x_New_Item_Number  := l_new_item_number;
     x_New_Item_Id := l_new_item_id;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  'x_New_Item_Number..'||x_New_Item_Number);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item.',
            			  'x_New_Item_Id..'||x_New_Item_Id);

     END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
        END IF;

        IF l_mtlsecinv_csr%ISOPEN THEN
           CLOSE l_mtlsecinv_csr;
        END IF;

        IF l_mtlparam_csr%ISOPEN THEN
            CLOSE l_mtlparam_csr;
        END IF;

        IF l_seqnextval_csr%ISOPEN THEN
            CLOSE l_seqnextval_csr;
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
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_inv_item',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

        IF l_mtlsecinv_csr%ISOPEN THEN
           CLOSE l_mtlsecinv_csr;
        END IF;

        IF l_mtlparam_csr%ISOPEN THEN
            CLOSE l_mtlparam_csr;
        END IF;

        IF l_seqnextval_csr%ISOPEN THEN
            CLOSE l_seqnextval_csr;
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

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_inv_item',
                  'EXCEPTION :'||sqlerrm);
        END IF;

        IF l_mtlsecinv_csr%ISOPEN THEN
           CLOSE l_mtlsecinv_csr;
        END IF;

        IF l_mtlparam_csr%ISOPEN THEN
            CLOSE l_mtlparam_csr;
        END IF;

        IF l_seqnextval_csr%ISOPEN THEN
            CLOSE l_seqnextval_csr;
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

END create_inv_item;

-- Start of comments
--
-- Procedure Name  : create_inv_misc_receipt
-- Description     : Create Inventory Misc Receipt
-- Business Rules  :
-- Parameters      :  Input parameters : p_Inventory_Item_id   -- Inventory Item ID
--  									 p_Subinv_Code         -- Subinventory Code
--  									 p_Organization_Id     -- Org ID
--  									 p_quantity            -- Item quantity
--  									 p_trans_type_id       -- Transaction Type ID
--  									 p_sysdate             -- System Date
--
--
-- Version         : 1.0
-- History         : 25-OCT-04 SECHAWLA - Created
-- End of comments

PROCEDURE create_inv_misc_receipt(
     p_api_version          IN  NUMBER,
     p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_Inventory_Item_id    IN NUMBER
  ,  p_Subinv_Code          IN VARCHAR2
  ,  p_Organization_Id      IN NUMBER
 -- SECHAWLA Bug# 2620853 : Distribution accout id is not required
 -- ,  p_Dist_account_id      IN NUMBER
  ,  p_quantity             IN NUMBER
  ,  p_trans_type_id        IN NUMBER
  ,  p_sysdate              IN DATE
  ,  x_Return_Status        OUT NOCOPY VARCHAR2
  ,  x_msg_count            OUT NOCOPY NUMBER
  ,  x_msg_data             OUT NOCOPY VARCHAR2
)
IS
     l_return_status                 VARCHAR2(1);
     l_api_name                      CONSTANT VARCHAR2(30) := 'create_inv_misc_receipt';
     l_api_version                   CONSTANT NUMBER := 1;

BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt','Begin(+)');
   END IF;

   --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_api_version :'||p_api_version);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_init_msg_list :'||p_init_msg_list);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_Inventory_Item_id :'||p_Inventory_Item_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_Subinv_Code :'||p_Subinv_Code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_Organization_Id :'||p_Organization_Id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_quantity :'||p_quantity);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_trans_type_id :'||p_trans_type_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt.',
              'p_sysdate :'||p_sysdate);

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

      -- There is a direct insert into the table here as there is no TAPI with insert procedure to insert into
      -- mtl_transactions_interface

      INSERT INTO mtl_transactions_interface
                  (source_code,
                   source_header_id,
                   lock_Flag,
                   Source_line_id,
                   process_flag,
                   transaction_mode,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   transaction_header_id,
                   validation_required,
                   inventory_item_id,
                   organization_id,
                   subinventory_code,
                   transaction_quantity,
                   transaction_uom,
                   transaction_date,
                   transaction_type_id,
                   transaction_reference,
                 --SECHAWLA Bug # 2620853 : No need to store distribution account id
                 --  distribution_account_id,
                   transaction_source_id,
                   transaction_source_name,
                   expenditure_type)
      VALUES
                  ('LEASE',              /* source_code */
                   0,                    /* source_header_id */
--                   '',                   /* lock_Flag */
                   2,                   /* lock_Flag */
                   0,                    /* Source_line_id */
                   1,                    /* process_flag */
                   3,                    /* transaction_mode */
                   p_sysdate,              /* last_update_date */
                   FND_GLOBAL.USER_ID,   /* last_updated_by */
                   p_sysdate,              /* creation_date */
                   FND_GLOBAL.USER_ID,   /* created_by */
                   112,                  /* transaction_header_id */
                   1,                    /* validation_required */
                   p_Inventory_Item_id,  /* inventory_item_id */
                   p_Organization_Id,    /* organization_id */
                   p_Subinv_Code,        /* subinventory_code */
                   p_quantity,            /* transaction_quantity */
                   'EA',                 /* transaction_uom */
                   p_sysdate,              /* transaction_date */
                   p_trans_type_id,      /* transaction_type_id */
                   'LEASE' ,             /* transaction_reference */
                -- SECHAWLA Bug# 2620853 : No need to store distribution account id
                --   p_Dist_account_id,    /* distribution_account_id */
                   0,                    /* transaction_source_id */
                   'LEASE',              /* transaction_source_name */
                   ''                    /* expenditure_type */
                   );
      x_return_status := okl_api.g_RET_STS_SUCCESS;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt ','End(-)');
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
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
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
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
         -- unexpected error
         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_misc_receipt ',
                  'EXCEPTION :'||sqlerrm);
         END IF;
         -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

         x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );


END Create_Inv_Misc_Receipt;

-- Procedure Name  : Create_Item_Price_List
-- Description     : Create Item in price List
-- Business Rules  :
-- Parameters      :  Input parameters : p_Price_List_id - price list Id from setup,
--                                       p_Item_Id - Item Id of the newly craeted item
--                                       p_Item_Price - price of the item ( from asset return)
--
-- History         : 25-OCT-04 SECHAWLA - Created
-- Version         : 1.0
-- End of comments

PROCEDURE Create_Item_Price_List
(   p_api_version       IN  NUMBER
  , p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
  , p_Price_List_id     IN  NUMBER
  , p_Item_Id           IN  NUMBER
  , p_Item_Price        IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
)
IS
 l_msg_count                    NUMBER:= 0;
 l_msg_data                     VARCHAR2(2000);
 l_return_status                VARCHAR2(1) := NULL;
 gpr_price_list_rec             QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_val_rec         QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 gpr_price_list_line_tbl        QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 gpr_price_list_line_val_tbl    QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 gpr_qualifiers_tbl             QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 gpr_qualifiers_val_tbl         QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 gpr_pricing_attr_tbl           QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_attr_val_tbl       QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 ppr_price_list_rec             QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec         QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl        QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl    QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 ppr_qualifiers_tbl             QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl         QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl           QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl       QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 k                              NUMBER;

 l_api_name                      CONSTANT VARCHAR2(30) := 'Create_Item_Price_List';
 l_api_version                   CONSTANT NUMBER := 1;


 -- SECHAWLA 08-DEC-04 4047159 : added
 -- This cursor is used to get the price list name
CURSOR  l_qplisthdr_csr(cp_list_header_id NUMBER) IS
SELECT  name
FROM    QP_LIST_HEADERS
WHERE   LIST_HEADER_ID = cp_list_header_id;

-- SECHAWLA 08-DEC-04 4047159 : Added
CURSOR l_mtlsystemitems_b(cp_item_id IN NUMBER) IS
SELECT segment1
FROM   mtl_system_items_b
WHERE  inventory_item_id = cp_item_id;

l_pricelist_name  		QP_LIST_HEADERS.name%TYPE;
l_item_number  			VARCHAR2(40);
BEGIN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List','Begin(+)');
     END IF;

     --Print Input Variables
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'p_api_version :'||p_api_version);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'p_init_msg_list :'||p_init_msg_list);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'p_Price_List_id :'||p_Price_List_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'p_Item_Id :'||p_Item_Id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'p_Item_Price :'||p_Item_Price);

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

     gpr_price_list_rec.list_header_id := p_Price_List_id;
     gpr_price_list_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
     gpr_price_list_rec.org_id := mo_global.get_current_org_id(); --CDUBEY l_authoring_org_id added for MOAC

     gpr_price_list_line_tbl(1).list_line_id := okl_api.G_MISS_NUM;
     gpr_price_list_line_tbl(1).list_line_type_code := 'PLL';
     gpr_price_list_line_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;
     gpr_price_list_line_tbl(1).operand := p_Item_Price;
     gpr_price_list_line_tbl(1).arithmetic_operator := 'UNIT_PRICE';


     gpr_pricing_attr_tbl(1).pricing_attribute_id := okl_api.G_MISS_NUM;
     gpr_pricing_attr_tbl(1).list_line_id := okl_api.G_MISS_NUM;
     gpr_pricing_attr_tbl(1).PRODUCT_ATTRIBUTE_CONTEXT := 'ITEM';
     gpr_pricing_attr_tbl(1).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE1';
     gpr_pricing_attr_tbl(1).PRODUCT_ATTR_VALUE := to_char(p_Item_Id);
     gpr_pricing_attr_tbl(1).PRODUCT_UOM_CODE := 'EA';
     gpr_pricing_attr_tbl(1).EXCLUDER_FLAG := 'N';
     gpr_pricing_attr_tbl(1).ATTRIBUTE_GROUPING_NO := 1;
     gpr_pricing_attr_tbl(1).PRICE_LIST_LINE_INDEX := 1;
     gpr_pricing_attr_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'before QP_PRICE_LIST_PUB.Process_Price_List call status'||x_return_status);
     END IF;

     QP_PRICE_LIST_PUB.Process_Price_List
     (   p_api_version_number            => p_api_version
     ,   p_init_msg_list                 => okl_api.G_FALSE
     ,   p_return_values                 => okl_api.G_FALSE
     ,   p_commit                        => okl_api.G_FALSE
     ,   x_return_status                 => x_return_status
     ,   x_msg_count                     => l_msg_count
     ,   x_msg_data                      => l_msg_data
     ,   p_PRICE_LIST_rec                => gpr_price_list_rec
     ,   p_PRICE_LIST_LINE_tbl           => gpr_price_list_line_tbl
     ,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
     ,   x_PRICE_LIST_rec                => ppr_price_list_rec
     ,   x_PRICE_LIST_val_rec            => ppr_price_list_val_rec
     ,   x_PRICE_LIST_LINE_tbl           => ppr_price_list_line_tbl
     ,   x_PRICE_LIST_LINE_val_tbl       => ppr_price_list_line_val_tbl
     ,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
     ,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
     ,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
     ,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
     );

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List.',
              'after QP_PRICE_LIST_PUB.Process_Price_List call status'||x_return_status);
     END IF;

     -- SECHAWLA 08-DEC-04 4047159 : added the following message
     IF ( x_return_status <> okl_api.G_RET_STS_SUCCESS ) THEN
        OPEN  l_qplisthdr_csr(p_Price_List_id) ;
        FETCH l_qplisthdr_csr INTO l_pricelist_name;
        CLOSE l_qplisthdr_csr;

        OPEN  l_mtlsystemitems_b(p_Item_Id) ;
        FETCH l_mtlsystemitems_b  INTO l_item_number;
        CLOSE l_mtlsystemitems_b;

        -- Error assigning item ITEM_NUMBER to price list PRICE_LIST.
        OKL_API.set_message(  p_app_name      => 'OKL',
                            p_msg_name        => 'OKL_AM_RMK_PL_FAILED',
                            p_token1          => 'ITEM_NUMBER',
                            p_token1_value    => l_item_number,
                            p_token2          => 'PRICE_LIST',
                            p_token2_value    => l_pricelist_name);
     END IF;


     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List ','End(-)');
     END IF;

     -- return status of the above procedure call becomes the return status of the current procedure which is then
     -- handled in the calling procedure
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN

       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
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

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
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
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List ',
                  'EXCEPTION :'||sqlerrm);
          END IF;
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
         -- unexpected error
         x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

END Create_Item_Price_List;

END OKL_AM_CUSTOM_RMK_ASSET_PVT;

/
