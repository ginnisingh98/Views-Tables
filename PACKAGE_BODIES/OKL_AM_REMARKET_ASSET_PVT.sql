--------------------------------------------------------
--  DDL for Package Body OKL_AM_REMARKET_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_REMARKET_ASSET_PVT" AS
/* $Header: OKLRRMKB.pls 120.10 2007/06/07 11:39:28 asawanka noship $ */



-- Start of comments
--
-- Procedure Name  : create_inv_item
-- Description     : This procedure is called from the main procedure - create_rmk_item.
--                   create_inv_item creates an inventory item
-- Business Rules  :
-- Parameters      :  Input parameters : p_Organization_Id  - Item's Orga
--                                       p_Item_Description - Item description (from asset return)
--                                       p_subinventory     - Item's subinventory
--                                       p_sysdate - system date
--
--                    Output Parameters : x_New_Item_Number - Item number of the newly created item
--                                        x_New_Item_Id - item Id of the newly created item
--
-- Version         : 1.0
-- History         : SECHAWLA 05-DEC-02 Bug# 2620853
--                     Commented out the code that references Distribution Account ID, as it is optional
--                   SECHAWLA 16-JAN-03 Bug # 2754280
--                     Changed the app name from OKL to OKC for g_unexpected_error
--                   SECHAWLA 14-MAR-03
--                     Prefixed the sequence generated item number with 'OKL' to prevent duplicate item numbers
--                     within the same org
--                   SECHAWLA 19-MAY-04 Bug # 3633627
--                     start_date_active should not have the time portion
--                   SECHAWLA 19-MAY-04 Bug # 3634514
--                     added p_assign_subinv parameter to conditionally populate subinventory fields
--                   SECHAWLA 08-DEC-04 4047159 : added p_organization_name parameter and a message
-- End of comments


PROCEDURE create_inv_item
(
   p_Organization_Id      IN  NUMBER
 , p_organization_name    IN  VARCHAR2 -- SECHAWLA 08-DEC-04 4047159 added
 , p_Item_Description     IN  VARCHAR2
 , p_subinventory         IN  VARCHAR2
 -- SECHAWLA Bug# 2620853 : distribution account id not required
 --, p_distribution_acct_id IN  NUMBER
 , p_sysdate              IN  DATE
 -- SECHAWLA 05-OCT-04 3924244 : p_item_number may be populated for the master org (if user entered item no.)
 , p_item_number          IN  VARCHAR2   --SECHAWLA Bug# 2679812 : Added new parameter
 , p_item_id              IN  NUMBER     --SECHAWLA Bug# 2679812 : Added new parameter
 , p_assign_subinv        IN  VARCHAR2   --SECHAWLA 19-MAY-04 3634514: Added new parameter
 , x_New_Item_Number      OUT NOCOPY VARCHAR2
 , x_New_Item_Id          OUT NOCOPY NUMBER
 , x_Return_Status        OUT NOCOPY VARCHAR2
)
IS

    SUBTYPE   item_rec_type    IS  inv_item_grp.item_rec_type;
    SUBTYPE   error_tbl_type   IS  inv_item_grp.error_tbl_type;

    -- sequence for item_number
    CURSOR l_seqnextval_csr IS
    SELECT OKL_IMR_SEQ.NEXTVAL
    FROM   DUAL;

    l_Item_rec            item_rec_type;
    x_Item_rec            item_rec_type;
    l_commit              VARCHAR2(1);
    l_validation_level    NUMBER;
    l_return_status       VARCHAR2(1);
    x_Error_tbl           error_tbl_type;
    l_description         VARCHAR2(240);
    l_long_description    VARCHAR2(4000);
    l_Item_Number         VARCHAR2(2000);
    l_Organization_Id     NUMBER;

BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item','Begin(+)');
   END IF;

   --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_Organization_Id :'||p_Organization_Id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_Item_Description :'||p_Item_Description);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_subinventory :'||p_subinventory);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_sysdate :'||p_sysdate);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_item_number :'||p_item_number);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_item_id :'||p_item_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
              'p_assign_subinv :'||p_assign_subinv);
   END IF;

   l_validation_level :=  FND_API.G_VALID_LEVEL_FULL;

   l_Organization_Id := p_Organization_Id;

   IF p_item_number IS NULL THEN   --SECHAWLA Bug# 2679812 : Item number is null when the item has not been created
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
        l_Item_rec.ITEM_NUMBER := p_item_number; --SECHAWLA Bug# 2679812 : If Item has alreday been created in the
                                                 -- master org, then use the same item number for the child org assignment
   END IF;

   --SECHAWLA Bug# 2679812 : Item id is not null when the item has already been created in the master org. use the
   --same item id for child org assignment
   IF p_item_id IS NOT NULL THEN
      l_Item_rec.INVENTORY_ITEM_ID := p_item_id;
   END IF;


   IF (p_Item_Description IS NULL) THEN
       l_description := l_Item_Number;
       l_long_description := l_Item_Number;
   ELSE
       l_description := p_Item_Description;
       l_long_description := p_Item_Description;
   END IF;

   l_Item_rec.ORGANIZATION_ID := l_Organization_Id;

   l_Item_rec.ENABLED_FLAG := 'Y';
   -- SECHAWLA 15-MAY-04 3633627 : start_date_active should not have the time portion
   l_Item_rec.START_DATE_ACTIVE := trunc(p_sysdate);
   l_Item_rec.DESCRIPTION := l_description;
   l_Item_rec.LONG_DESCRIPTION := l_long_description;
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


   -- subinventory and distribution account ID are retrieved from profiles at the time of item creation. Since profiles
   -- may change between the time item is created and time when Order is booked against the item, we store these values
   -- in the following fields. Later when we reduce the quantitiy of an item, after the order is booked, we can
   -- query mtl_system_items with inventory_item_id and org_id and get source_subinventory and distribution account.

   --SECHAWLA 19-MAY-04 3634514: Populate subinventory only if p_assign_subinv = 'Y'
   IF p_assign_subinv = 'Y' THEN
      l_item_rec.SOURCE_TYPE := 1;
      l_Item_rec.SOURCE_SUBINVENTORY := p_subinventory;
      l_Item_rec.SOURCE_ORGANIZATION_ID := l_Organization_Id;
   END IF;
  -- SECHAWLA Bug# 2620853 : Distribution accout id is not stored, as it is optional
  -- l_Item_rec.ENCUMBRANCE_ACCOUNT := p_distribution_acct_id;

   l_commit := okl_api.g_FALSE;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
                      'before INV_Item_GRP.create_item  call sts'||x_return_status);
   END IF;

   INV_Item_GRP.create_item
   (
         p_commit              => l_commit
     ,   p_validation_level    => l_validation_level
     ,   p_Item_rec            => l_Item_rec
     ,   x_Item_rec            => x_item_rec
     ,   x_return_status       => x_return_status
     ,   x_Error_tbl           => x_Error_tbl
   );

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
                      'after INV_Item_GRP.create_item  call sts'||x_return_status);
   END IF;

  IF ( x_return_status = okl_api.G_RET_STS_SUCCESS ) THEN
     x_New_Item_Number := x_item_rec.ITEM_NUMBER;
     x_New_Item_Id := x_item_rec.INVENTORY_ITEM_ID;
  ELSE
      -- SECHAWLA 08-DEC-04 4047159 : added the following message
      -- Error creating inventory item ITEM_NUMBER in organization ORG_NAME.
      OKL_API.set_message(  p_app_name      => 'OKL',
                            p_msg_name      => 'OKL_AM_RMK_ITEM_FAILED',
                            p_token1        => 'ITEM_NUMBER',
                            p_token1_value  => l_Item_rec.ITEM_NUMBER,
                            p_token2        => 'ORG_NAME',
                            p_token2_value  => p_organization_name);


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
   END IF;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
                      'x_New_Item_Number..'||x_New_Item_Number);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
                      'x_New_Item_Id..'||x_New_Item_Id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item.',
                      'ret status at the end.. '||x_return_status);

   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item ','End(-)');
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_REMARKET_ASSET_PVT.create_inv_item  ',
                  'EXCEPTION :'||sqlerrm);
          END IF;

          IF l_seqnextval_csr%ISOPEN THEN
             CLOSE l_seqnextval_csr;
          END IF;
          -- unexpected error
          -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
          OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END create_inv_item;



-- Start of comments
--
-- Procedure Name  : Create_Inv_Misc_Receipt_Txn
-- Description     : This procedure is called from the main procedure - create_rmk_item.
--                   Create_Inv_Misc_Receipt_Txn moves the item to inventory
-- Business Rules  :
-- Parameters      :  Input parameters : p_Inventory_Item_id  - Item Id of the newly craeted item,
--                                       p_Subinv_Code - Item subinventory (setup)
--                                       p_Organization_Id - Item's Organization (setup)
--                                       p_Dist_account_id - Distribution Account Id
--                                       p_quantity        - Item's quantity
--                                       p_trans_type_id   - Transaction Type (Receipt/Issue)
--                                       p_sysdate - system date
--
-- Version         : 1.0
-- History         : SECHAWLA 05-DEC-02 Bug# 2620853
--                     Commented out the code that references Distribution account id, as it is optional
--                   SECHAWLA 16-JAN-03 Bug # 2754280
--                     Changed the app name from OKL to OKC for g_unexpected_error
--
-- End of comments

PROCEDURE Create_Inv_Misc_Receipt_Txn
(    p_Inventory_Item_id    IN NUMBER
  ,  p_Subinv_Code          IN VARCHAR2
  ,  p_Organization_Id      IN NUMBER
 -- SECHAWLA Bug# 2620853 : Distribution accout id is not required
 -- ,  p_Dist_account_id      IN NUMBER
  ,  p_quantity             IN NUMBER
  ,  p_trans_type_id        IN NUMBER
  ,  p_sysdate              IN DATE
  ,  x_Return_Status        OUT NOCOPY VARCHAR2
)
IS


BEGIN

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn','Begin(+)');
       END IF;

       --Print Input Variables
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'p_Inventory_Item_id :'||p_Inventory_Item_id);

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'p_Subinv_Code :'||p_Subinv_Code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'p_Organization_Id :'||p_Organization_Id);

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'p_quantity :'||p_quantity);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'p_trans_type_id :'||p_trans_type_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'p_sysdate :'||p_sysdate);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn.',
              'before insert call sts..'||x_return_status);
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
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn ','End(-)');
      END IF;

EXCEPTION
    WHEN OTHERS THEN
         -- unexpected error
         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_REMARKET_ASSET_PVT.Create_Inv_Misc_Receipt_Txn',
                  'EXCEPTION :'||sqlerrm);
         END IF;
         -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END Create_Inv_Misc_Receipt_Txn;


-- Start of comments
--
-- Procedure Name  : Create_Item_In_Price_List
-- Description     : This procedure is called from the main procedure - create_rmk_item.
--                   Create_Item_In_Price_List creates a price list for the newly created item
-- Business Rules  :
-- Parameters      :  Input parameters : p_Price_List_id - price list Id from setup,
--                                       p_Item_Id - Item Id of the newly craeted item
--                                       p_Item_Price - price of the item ( from asset return)
--
-- History         :  SECHAWLA 16-JAN-03 Bug # 2754280
--                       Changed the app name from OKL to OKC for g_unexpected_error
-- Version         : 1.0
-- End of comments

PROCEDURE Create_Item_In_Price_List
(   p_api_version       IN  NUMBER
  , p_Price_List_id     IN  NUMBER
  , p_price_list_name 	IN  VARCHAR2  -- SECHAWLA 08-DEC-04 4047159 : added
  , p_price_list_item   IN  VARCHAR2  -- SECHAWLA 08-DEC-04 4047159 : added
  , p_Item_Id           IN  NUMBER
  , p_Item_Price        IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
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
BEGIN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List','Begin(+)');
     END IF;

     --Print Input Variables
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List.',
                'p_Price_List_id :'||p_Price_List_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List.',
                'p_Item_Id :'||p_Item_Id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List.',
                'p_Item_Price :'||p_Item_Price);

     END IF;

     gpr_price_list_rec.list_header_id := p_Price_List_id;
     gpr_price_list_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
     --asawanka commented out as we need not pass org_id
     --gpr_price_list_rec.org_id := mo_global.get_current_org_id(); --CDUBEY l_authoring_org_id added for MOAC


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
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List.',
                'before QP_PRICE_LIST_PUB.Process_Price_List  sts..'||x_return_status);
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

     -- return status of the above procedure call becomes the return status of the current procedure which is then
     -- handled in the calling procedure - create_rmk_item
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List.',
                'after QP_PRICE_LIST_PUB.Process_Price_List  sts..'||x_return_status);
     END IF;

     -- SECHAWLA 08-DEC-04 4047159 : added the following message
     IF ( x_return_status <> okl_api.G_RET_STS_SUCCESS ) THEN
        -- Error assigning item ITEM_NUMBER to price list PRICE_LIST.
        OKL_API.set_message(  p_app_name      => 'OKL',
                            p_msg_name        => 'OKL_AM_RMK_PL_FAILED',
                            p_token1          => 'ITEM_NUMBER',
                            p_token1_value    => p_price_list_item,
                            p_token2          => 'PRICE_LIST',
                            p_token2_value    => p_price_list_name);
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List ','End(-)');
     END IF;
EXCEPTION
  WHEN OTHERS THEN
         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_REMARKET_ASSET_PVT.Create_Item_In_Price_List ',
                  'EXCEPTION :'||sqlerrm);
         END IF;
         -- unexpected error
         -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END Create_Item_In_Price_List;





-- Start of comments
--
-- Procedure Name  : create_rmk_item
-- Description     : The main body of the package. This procedure creats an inventory item, moves the item to
--                   Inventory and creates a price list for the Item. These 3 steps are considered as a part of
--                   single transaction and are all required to complete successfully in order to create an inventory
--                   item.
-- Business Rules  :
-- Parameters      :  Input parameters : p_Item_Description - item desc , p_Item_Price- item price,
--                                       p_quantity - Item's quantity
--                    Output parameters : x_new_item_number - item number of the item created
--                                        x_new_item_id - item Id of the item created
-- Version         : 1.0
-- History         : SECHAWLA  05-DEC-02 - Bug# 2620853
--                     Commented out the code that uses the distribution account id profile, as it is optional
--                   SECHAWLA 05-DEC-02 - Bug# 2679812
--                     Fixed the typos in the CLOSE cursor statement in the exception block
--                     Removed DEFAULT hint from procedure parameters
--                     Modified messages to display user profile option name instead of profile option name
--                     Added/Modified code to first create the item in the master org and then assign it to
--                          child org, if the 2 Orgs are different
--                   SECHAWLA 17-DEC-02 : Bug # 2706328
--                     Fixed the datatype of l_temp_org_name
--                   SECHAWLA 16-JAN-02 Bug # 2754280
--                     Changed the call to fn get_user_profile_option_name to refer it from am util
--                   SECHAWLA 08-MAR-04 Bug # 3492490
--                     Use ORG_ORGANIZATION_DEFINITIONS instead of mtl_organizations to validate the inventory org
--                     Validate subinventory is defined for Master org when the remarketing inv org is a child org
--                   SECHAWLA 19-MAY-04 Bug # 3634514
--                     Populate subinventory fields on the item master only if 1) the remarketing org is a master org OR
--                     2) Remarketing org is a child org and the item is being assigned to the child org
--                   SECHAWLA 04-OCT-04 3924244 : added p_item_number parameter
-- End of comments

PROCEDURE create_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2,
     p_item_number           IN     VARCHAR2, -- 04-OCT-04 SECHAWLA 3924244 : new parameter
     p_Item_Description      IN     VARCHAR2,
     p_Item_Price            IN     NUMBER ,
     p_quantity              IN     NUMBER ,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2,
     x_new_item_number       OUT    NOCOPY VARCHAR2,
     x_new_item_id           OUT    NOCOPY NUMBER

)
IS

-- This cursor is used to validate an organization Id against mtl_organization
CURSOR l_mtlorgcsr(p_org_id NUMBER) IS
SELECT organization_name
-- SECHAWLA 08-MAR-04 3492490 : Validate against ORG_ORGANIZATION_DEFINITIONS, as we use this view to set the LOV for
-- inventory organization.  mtl_organizations may not have all the orgs that ORG_ORGANIZATION_DEFINITIONS has. For
-- our validation purposes, we do not need the restrictions that mtl_organizations uses to filter out certain orgs
--FROM   mtl_organizations
FROM   ORG_ORGANIZATION_DEFINITIONS
WHERE  organization_id = p_org_id;

-- This cursor is used to validate Organization and subinventory
CURSOR l_mtlsecinv_csr(p_inv_org_id NUMBER, p_subinv_code VARCHAR2) IS
SELECT 'Validate Org and Subinv'
FROM   mtl_secondary_inventories
WHERE  organization_id = p_inv_org_id
AND    secondary_inventory_name = p_subinv_code;

-- This cursor is used to validate the list_header_id
CURSOR  l_qplisthdr_csr(p_list_header_id NUMBER) IS
--SELECT  'x'                 --  SECHAWLA 08-DEC-04 4047159
--FROM    QP_LIST_HEADERS_B   --  SECHAWLA 08-DEC-04 4047159
SELECT  name
FROM    QP_LIST_HEADERS
WHERE   LIST_HEADER_ID = p_list_header_id;


-- SECHAWLA Bug# 2620853 : Cursor not required, as we are not going to use distribution account id
/*
-- This cursor is used to validate distribution_account_id
CURSOR  l_glcodecomb_csr(p_ccid  NUMBER) IS
SELECT  'x'
FROM    GL_CODE_COMBINATIONS
WHERE   code_combination_id = p_ccid
AND     enabled_flag = 'Y';
*/


-- This cursor is used to get the warehouse for the Order and Line Transaction types
CURSOR l_oetranstypesall_csr(p_trans_id NUMBER) IS
SELECT warehouse_id, default_outbound_line_type_id, name
FROM   oe_transaction_types_all a, oe_transaction_types_tl b
WHERE  a.transaction_type_id = b.transaction_type_id
AND    a.transaction_type_id = p_trans_id;

--SECHAWLA 05-DEC-02 - Bug# 2679812 : Added a new cursor
-- This cursor is used to find the master org for an organization

-- SECHAWLA 08-MAR-04 3492490 : Added master org name
CURSOR l_mtlparam_csr(p_org_id NUMBER) IS
SELECT a.master_organization_id, b.organization_name master_org_name
FROM   mtl_parameters a , ORG_ORGANIZATION_DEFINITIONS b
WHERE  a.organization_id = p_org_id
AND    a.master_organization_id = b.organization_id ;


 l_order_warehouse_id            NUMBER;
 l_line_warehouse_id             NUMBER;
 l_def_outbound_line_type_id     NUMBER;
 l_order_name                    VARCHAR2(30);
 l_line_name                     VARCHAR2(30);
 l_inv_org_id                    NUMBER;
 l_subinv_code                   VARCHAR2(10);
 --SECHAWLA Bug# 2620853 : Dist Account ID is not required
 -- l_distribution_account_id       NUMBER;
 l_price_list_id                 NUMBER;
 l_New_Item_Number               VARCHAR2(2000);
 l_New_Item_Id                   NUMBER;
 l_return_status                 VARCHAR2(1);
 l_temp                          VARCHAR2(25);
 -- l_pricelist_exists              VARCHAR2(1); --  SECHAWLA 08-DEC-04 4047159
 l_pricelist_name                QP_LIST_HEADERS.name%TYPE; --  SECHAWLA 08-DEC-04 4047159
 --SECHAWLA 2706328 : Fixed the datatype for l_temp_org_name
 l_temp_org_name                 mtl_organizations.organization_name%TYPE;
 l_temp_ccid                     VARCHAR2(1);
 l_count                         NUMBER;
 l_default_order_type_id         NUMBER;

 l_api_name                      CONSTANT VARCHAR2(30) := 'create_rmk_item';
 l_api_version                   CONSTANT NUMBER := 1;
 l_sysdate                       DATE;

 --SECHAWLA Bug# 2679812 : new declarations
 l_master_org_id                 NUMBER;
 l_current_org                   NUMBER;
 l_current_org_name              ORG_ORGANIZATION_DEFINITIONS.organization_name%TYPE; -- SECHAWLA 08-DEC-04 4047159
 l_iterations                    NUMBER;
 l_item_id                       NUMBER;
 l_item_number                   VARCHAR2(2000);
 l_user_profile_name             VARCHAR2(240);

  -- SECHAWLA 08-MAR-04 3492490 : new declarations

 l_master_org_name               ORG_ORGANIZATION_DEFINITIONS.organization_name%TYPE;

 --SECHAWLA 19-MAY-04 3634514 : new declaration
 l_assign_subinv                 VARCHAR2(1);

 -- SECHAWLA 05-OCT-04 3924244 : New declarations
 -- check the Remarketing flow options from the setup
 CURSOR l_systemparamsall_csr IS
 SELECT REMK_ORGANIZATION_ID, REMK_SUBINVENTORY, REMK_PRICE_LIST_ID
 FROM   OKL_SYSTEM_PARAMS ;

 -- SECHAWLA 18-OCT-04 3924244 : new declarations
 -- check if item already exists in inventory
 CURSOR l_mtlsystemitems_csr(cp_inv_item_number  IN VARCHAR2) IS
 SELECT count(*)
 FROM   MTL_SYSTEM_ITEMS_B
 WHERE  segment1 = cp_inv_item_number;

 l_item_cnt  NUMBER;


BEGIN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item','Begin(+)');
      END IF;

   --Print Input Variables
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'p_init_msg_list :'||p_init_msg_list);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'p_item_number :'||p_item_number);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'p_Item_Description :'||p_Item_Description);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'p_Item_Price :'||p_Item_Price);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
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

     -- SECHAWLA 18-OCT-04 3924244 : Added  the following validation
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
     -- SECHAWLA 18-OCT-04 3924244 : end

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
     FETCH  l_systemparamsall_csr INTO l_inv_org_id, l_subinv_code, l_price_list_id;
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
     END IF;
     -- SECHAWLA 05-OCT-04 3924244 : Migrated profiles to setups



   /* -- -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups

     l_inv_org_id := fnd_profile.value('OKL_REMARKET_ITEMS_INV_ORG');
     l_subinv_code := fnd_profile.value('OKL_REMARKET_SUBINVENTORY');

     -- distribution account ID in mtl_transactions_interface is optional.

     -- SECHAWLA Bug # 2620853 - following profile is not required
     --l_distribution_account_id := fnd_profile.value('OKL_REMARKET_DISTRIBUTION_ACCOUNT');

     l_price_list_id := fnd_profile.value('OKL_REMARKET_PRICE_LIST');
   */

     -- ASO_ORDER_TYPE_ID is an Oracle Order Capture profile to set the default Order type.
     -- iStore uses this profile to get the default Order type and then assigns this Order type to the Orders
     -- l_default_order_type_id := fnd_profile.value('ASO_ORDER_TYPE_ID');
        l_default_order_type_id := aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.G_DEFAULT_ORDER_TYPE,l_inv_org_id); -- CDUBEY - For MOAC Bug 4421236

     /*  -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
     -- validate organization
     IF l_inv_org_id IS NULL THEN

        --SECHAWLA Bug# 2679812 : Added the following code to display user profile option name in messages
        --                        instead of profile option name

        -- SECHAWLA 16-JAN-02 Bug # 2754280 : Changed the following fn call to call this function from am util
        l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                     p_profile_option_name  => 'OKL_REMARKET_ITEMS_INV_ORG',
                                     x_return_status        => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           --Remarketing Inventory Organization profile is missing.
            OKL_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_INV_ORG_PROFILE'
                                );
            RAISE okl_api.G_EXCEPTION_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        -- SECHAWLA  Bug# 2679812 -- end new code

        x_return_status := OKL_API.G_RET_STS_ERROR;
        --Profile value not defined
        OKL_API.set_message(         p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_PROFILE_VALUE',
                                     p_token1        => 'PROFILE',
                                     p_token1_value  => l_user_profile_name  -- modified to display user profile option name
                           );
        RAISE okl_api.G_EXCEPTION_ERROR;
     END IF;
     */  -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups


     OPEN  l_mtlorgcsr(l_inv_org_id);
     FETCH l_mtlorgcsr INTO l_temp_org_name;
     IF    l_mtlorgcsr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        /*  -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        --Profile is invalid.
        OKL_API.set_message(         p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_INVALID_PROFILE',
                                     p_token1        => 'PROFILE',
                                     p_token1_value  => 'OKL_REMARKET_ITEMS_INV_ORG'
                           );
        */

        -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Remarketing Inventory Organization');

        RAISE okl_api.G_EXCEPTION_ERROR;
     END IF;
     CLOSE l_mtlorgcsr;


     -- validate subinventory
     IF l_subinv_code IS NULL THEN

        /*  -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        --SECHAWLA Bug# 2679812 : Added the following code to display user profile option name in messages
        --                        instead of profile option name
        l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                     p_profile_option_name  => 'OKL_REMARKET_SUBINVENTORY',
                                     x_return_status        => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           --Remarketing Subinventory profile is missing.
            OKL_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_SUBINV_PROFILE'
                                );
            RAISE okl_api.G_EXCEPTION_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        -- SECHAWLA  Bug# 2679812 -- end new code

        x_return_status := OKL_API.G_RET_STS_ERROR;
        --Profile value not defined
        OKL_API.set_message(         p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_NO_PROFILE_VALUE',
                                     p_token1        => 'PROFILE',
                                     p_token1_value  => l_user_profile_name -- modified to display user profile option
                           );
        RAISE okl_api.G_EXCEPTION_ERROR;
        */

        -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        -- Remarketing Subinventory is not setup for this operating unit.
		OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_SUBINV');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;



     -- This profile will generally be set to NULL. We are still keeping the profile to provide flexibility
     -- to the user, if they want to store distribution account ID in mtl_transactionjs_interface

     -- SECHAWLA Bug # 2620853  - no need to validate distribution_account_id, as we are not using the corresponding profile.

    /* IF l_distribution_account_id IS NOT NULL THEN
        OPEN   l_glcodecomb_csr(l_distribution_account_id);
        FETCH  l_glcodecomb_csr INTO l_temp_ccid;
        IF     l_glcodecomb_csr%NOTFOUND THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- Profile is invalid.
             OKL_API.set_message(       p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_INVALID_PROFILE',
                                     p_token1        => 'PROFILE',
                                     p_token1_value  => 'OKL_REMARKET_DISTRIBUTION_ACCOUNT'
                           );
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE l_glcodecomb_csr;
     END IF;
     */


     IF l_price_list_id IS NULL THEN

         /* -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        --SECHAWLA Bug# 2679812 : Added the following code to display user profile option name in messages
        --                        instead of profile option name
        l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                     p_profile_option_name  => 'OKL_REMARKET_PRICE_LIST',
                                     x_return_status        => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           --Remarketing Price List profile is missing.
            OKL_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_PL_PROFILE'
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
        */
        -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups

        -- Remarketing Price List is not setup for this operating unit.
        OKL_API.set_message(
					           p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_REMK_PRICE_LIST');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     OPEN  l_qplisthdr_csr(l_price_list_id);
     FETCH l_qplisthdr_csr INTO l_pricelist_name;  -- SECHAWLA 08-DEC-04 4047159
     IF l_qplisthdr_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;

        /*  -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
        -- Profile is invalid.
        OKL_API.set_message(         p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_INVALID_PROFILE',
                                     p_token1        => 'PROFILE',
                                     p_token1_value  => 'OKL_REMARKET_PRICE_LIST'
         */

		 -- SECHAWLA 05-OCT-04 3924244  : Migrated remarketing profiles to setups
		 OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Remarketing Price List');
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     CLOSE l_qplisthdr_csr;

     IF l_default_order_type_id IS NULL THEN

        --SECHAWLA Bug# 2679812 : Added the following code to display user profile option name in messages
        --                        instead of profile option name
        l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                     p_profile_option_name  => 'ASO_ORDER_TYPE_ID',
                                     x_return_status        => x_return_status);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_user_profile_name status'||x_return_status);
        END IF;

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
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'fetched l_oetranstypesall_csr..');
     END IF;

     CLOSE l_oetranstypesall_csr;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_order_warehouse_id..'||l_order_warehouse_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_def_outbound_line_type_id..'||l_def_outbound_line_type_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_order_name..'||l_order_name);
     END IF;


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
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'fetched l_oetranstypesall_csr again');
     END IF;

     CLOSE l_oetranstypesall_csr;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_line_warehouse_id'||l_line_warehouse_id);
     END IF;

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


     --SECHAWLA Bug# 2679812 : Added/modified the following code to first create the item in the master org and then
     -- assign the same item to the child org


     -- SECHAWLA Bug# 2679812 : Get the Master Org for the Inv Org
     OPEN  l_mtlparam_csr(l_inv_org_id);

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
     IF l_inv_org_id = l_master_org_id THEN
        l_iterations := 1;
     ELSE
        l_iterations := 2;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
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
           l_current_org := l_inv_org_id; --child org
           l_current_org_name := l_temp_org_name; -- SECHAWLA 08-DEC-04 4047159
           l_item_number := l_New_Item_Number;
           l_item_id := l_New_Item_Id;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_current_org'||l_current_org);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_item_number'||l_item_number);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
              'l_item_id'||l_item_id);
        END IF;
        ---------------------
        -- SECHAWLA 08-MAR-04 3492490 : Moved the following validation here from the beginning. So it can be
        -- performed for both Master and Child org

        OPEN   l_mtlsecinv_csr(l_current_org , l_subinv_code );
        FETCH  l_mtlsecinv_csr INTO l_temp;
        IF  l_mtlsecinv_csr%NOTFOUND THEN
            --x_return_status := OKL_API.G_RET_STS_ERROR;

            IF  (l_inv_org_id <> l_master_org_id  AND  i = 1 )THEN
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
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  '(l_inv_org_id <> l_master_org_id  AND  i = 1)  sts'||x_return_status);

                 END IF;

                 NULL;
             ELSE
                x_return_status := OKL_API.G_RET_STS_ERROR;
                --Subinventory SUBINVENTORY is invalid for the organization ORGANIZATION.
                OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_RMK_ORG_SUBINV',
                          p_token1       => 'SUBINVENTORY',
                          p_token1_value => l_subinv_code,
                          p_token2       => 'ORGANIZATION',
                          p_token2_value => l_temp_org_name);
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
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'before create_inv_item  call'||x_return_status);

        END IF;
        create_inv_item
	           (--p_Organization_Id      =>	l_inv_org_id,  --SECHAWLA Bug# 2679812 : use current org
                p_Organization_Id      =>  l_current_org,
                p_organization_name    =>  l_current_org_name, -- SECHAWLA 08-DEC-04 4047159 : added
                p_Item_Description     =>  p_Item_Description,
                p_subinventory         =>  l_subinv_code,
                --  p_distribution_acct_id =>  l_distribution_account_id, -- SECHAWLA Bug # 2620853 : Removed
                p_sysdate              =>  l_sysdate,
                -- SECHAWLA 05-OCT-04 3924244 : l_item_number may have a value for the master org (if user enters item no.)
                p_item_number          =>  l_item_number,  --SECHAWLA Bug# 2679812 :added
                p_item_id              =>  l_item_id,      --SECHAWLA Bug# 2679812 :added
                p_assign_subinv        =>  l_assign_subinv, --SECHAWLA 19-MAY-04 3634514: Added
	            x_New_Item_Number      =>  l_New_Item_Number,
                x_New_Item_Id          =>  l_New_Item_Id,
	            x_return_Status        =>  x_return_status);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'after create_inv_item  call'||x_return_status);

        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;




        IF (l_iterations = 1) OR (i = 2) THEN  --SECHAWLA Bug# 2679812 : Create Misc transaction if inv org is the
                                               --master org OR for the child org

            -- Creating Inventory Receipt Transaction for the Item
            -- SECHAWLA Bug # 2620853  : No need to pass distribution account id, as it is optional
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'before Create_Inv_Misc_Receipt_Txn call'||x_return_status);

             END IF;
            Create_Inv_Misc_Receipt_Txn
                (   p_Inventory_Item_id => l_New_Item_Id,
                    p_Subinv_Code       => l_subinv_code,
                    --p_Organization_Id   => l_inv_org_id, --SECHAWLA Bug# 2679812 : use current org
                    p_Organization_Id   => l_current_org,
                    --p_Dist_account_id   => l_distribution_account_id,  -- This can be NULL
                    p_quantity          => p_quantity,
                    p_trans_type_id     => 42,         --- transaction type ID for Receipt Transactions
                    p_sysdate           => l_sysdate,
                    x_Return_Status     => x_return_status);

             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'after Create_Inv_Misc_Receipt_Txn call'||x_return_status);

             END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        END IF;

        IF i = 1 THEN -- SECHAWLA Bug# 2679812 :Create price list only for the master item
             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'before Create_Item_In_Price_List'||x_return_status);

             END IF;
            -- Create the Item in the Price List
            Create_Item_In_Price_List
            (
                p_api_version   	=> l_api_version,
                p_Price_List_id 	=> l_price_list_id,
                p_price_list_name 	=> l_pricelist_name,  -- SECHAWLA 08-DEC-04 4047159 : added
                p_price_list_item   => l_New_Item_Number, -- SECHAWLA 08-DEC-04 4047159 : added
                p_Item_Id       	=> l_New_Item_Id,
                p_Item_Price    	=> p_Item_Price,
                x_return_status 	=> x_return_status);
             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'after Create_Item_In_Price_List'||x_return_status);

             END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;

     END LOOP;

     x_New_Item_Number  := l_new_item_number;
     x_New_Item_Id := l_new_item_id;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'x_New_Item_Number '||x_New_Item_Number);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item.',
            			  'x_New_Item_Id '||x_New_Item_Id);

     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item ','End(-)');
     END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
        END IF;

        IF l_mtlsystemitems_csr%ISOPEN THEN
		   CLOSE l_mtlsystemitems_csr;
		END IF;

        IF l_mtlorgcsr%ISOPEN THEN
           CLOSE l_mtlorgcsr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_mtlsecinv_csr%ISOPEN THEN
           CLOSE l_mtlsecinv_csr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_qplisthdr_csr%ISOPEN THEN
           CLOSE l_qplisthdr_csr;
        END IF;

     -- SECHAWLA Bug# 2620853 : This cursor is not used
     /*   IF l_glcodecomb_csr%ISOPEN THEN
           CLOSE l_glcodecomb_csr;
        END IF;
     */

        IF l_oetranstypesall_csr%ISOPEN THEN
            CLOSE l_oetranstypesall_csr;
        END IF;

        -- SECHAWLA Bug# 2679812 : close the new cursor
        IF l_mtlparam_csr%ISOPEN THEN
            CLOSE l_mtlparam_csr;
        END IF;

        -- SECHAWLA 05-OCT-04 3924244 : close new cursor
        IF l_systemparamsall_csr%ISOPEN THEN
            CLOSE l_systemparamsall_csr;
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

        IF l_mtlsystemitems_csr%ISOPEN THEN
		   CLOSE l_mtlsystemitems_csr;
		END IF;

        IF l_mtlorgcsr%ISOPEN THEN
           CLOSE l_mtlorgcsr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_mtlsecinv_csr%ISOPEN THEN
           CLOSE l_mtlsecinv_csr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_qplisthdr_csr%ISOPEN THEN
           CLOSE l_qplisthdr_csr;
        END IF;

        -- SECHAWLA Bug# 2620853 : This cursor is not used
       /* IF l_glcodecomb_csr%ISOPEN THEN
           CLOSE l_glcodecomb_csr;
        END IF;
       */

        IF l_oetranstypesall_csr%ISOPEN THEN
            CLOSE l_oetranstypesall_csr;
        END IF;

        -- SECHAWLA Bug# 2679812 : close the new cursor
        IF l_mtlparam_csr%ISOPEN THEN
            CLOSE l_mtlparam_csr;
        END IF;

        -- SECHAWLA 05-OCT-04 3924244 : close new cursor
        IF l_systemparamsall_csr%ISOPEN THEN
            CLOSE l_systemparamsall_csr;
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_AM_REMARKET_ASSET_PVT.create_rmk_item',
                  'EXCEPTION :'||sqlerrm);
        END IF;

        IF l_mtlsystemitems_csr%ISOPEN THEN
		   CLOSE l_mtlsystemitems_csr;
		END IF;

        IF l_mtlorgcsr%ISOPEN THEN
           CLOSE l_mtlorgcsr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_mtlsecinv_csr%ISOPEN THEN
           CLOSE l_mtlsecinv_csr;
        END IF;

        -- SECHAWLA Bug# 2679812 : Fixed the typo in the CLOSE cursor statement
        IF l_qplisthdr_csr%ISOPEN THEN
           CLOSE l_qplisthdr_csr;
        END IF;

        -- SECHAWLA Bug# 2620853 : This cursor is not used
       /* IF l_glcodecomb_csr%ISOPEN THEN
           CLOSE l_glcodecomb_csr;
         END IF;
       */

        IF l_oetranstypesall_csr%ISOPEN THEN
            CLOSE l_oetranstypesall_csr;
        END IF;

        -- SECHAWLA Bug# 2679812 : close the new cursor
        IF l_mtlparam_csr%ISOPEN THEN
            CLOSE l_mtlparam_csr;
        END IF;

        -- SECHAWLA 05-OCT-04 3924244 : close new cursor
        IF l_systemparamsall_csr%ISOPEN THEN
            CLOSE l_systemparamsall_csr;
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


END create_rmk_item;



/*

-- This code is commented in anticipation of the possibility of including it again at some point in future.


-- Start of comments
--
-- Procedure Name  : remove_inv_item
-- Description     : This procedure is called from the main procedure - remove_rmk_item.
--                   remove_inv_item inactivates an inventory item by setting the end_date_active to sysdate
-- Business Rules  :
-- Parameters      :  Input parameters : p_Item_Id - Item Id of item to be removed
--                                       p_org_id - Items' organization Id
--                                       p_sysdate - system date
--
--
-- Version         : 1.0
-- End of comments

PROCEDURE remove_inv_item(  p_item_id       IN  NUMBER,
                            p_org_id        IN  NUMBER,
                            p_sysdate       IN  DATE,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
    l_Item_rec                      INV_Item_GRP.Item_rec_type;
    x_Item_rec                      INV_Item_GRP.Item_rec_type;
    l_commit                        VARCHAR2(1);
    l_validation_level              NUMBER;
    l_return_status                 VARCHAR2(1);
    x_Error_tbl                     INV_Item_GRP.Error_tbl_type;

    l_lock_rows                     VARCHAR2(20) := fnd_api.g_TRUE;

BEGIN

   l_validation_level :=  FND_API.G_VALID_LEVEL_FULL;

   l_item_rec.end_date_active := p_sysdate;
   l_item_rec.inventory_item_id := p_Item_Id;
   l_Item_rec.organization_id := p_org_id;


   l_commit := OKC_API.g_FALSE;

   INV_Item_GRP.update_item
   (
         p_commit              => l_commit,
         p_lock_rows           => l_lock_rows
     ,   p_validation_level    => l_validation_level
     ,   p_Item_rec            => l_Item_rec
     ,   x_Item_rec            => x_item_rec
     ,   x_return_status       => x_return_status
     ,   x_Error_tbl           => x_Error_tbl
   );


     IF ( x_return_status <>  okl_api.G_RET_STS_SUCCESS ) THEN
         -- Display the error messages from the x_error_tbl table
         FOR i IN 1 .. x_Error_tbl.COUNT LOOP
            -- Error :  Transaction Id = TRX_ID
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
            -- Error : Column Name = COLUMN_NAME
            OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RMK_COLUMN_NAME',
                                p_token1        => 'COLUMN_NAME',
                                p_token1_value  => x_Error_tbl(i).COLUMN_NAME
                           );
            -- Error : Message Name = MSG_NAME
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
      END IF;
EXCEPTION
  WHEN OTHERS THEN
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END remove_inv_item;


-- Start of comments
--
-- Procedure Name  : remove_item_from_price_list
-- Description     : This procedure is called from the main procedure - remove_rmk_item.
--                   remove_item_from_price_list inactivates the price list of an item by setting the end_date_active
--                   to sysdate
-- Business Rules  :
-- Parameters      :  Input parameters : p_Item_Id - Item Id of the item
--                                       p_sysdate - system date
--
--
-- Version         : 1.0
-- End of comments

PROCEDURE remove_item_from_price_list(p_item_id         IN  NUMBER,
                                      p_sysdate         IN  DATE,
                                      x_return_status   OUT NOCOPY VARCHAR2)


IS
 l_msg_count                    NUMBER:= 0;
 l_msg_data                     VARCHAR2(2000);
 l_return_status                VARCHAR2(1) := NULL;
 gpr_price_list_rec             QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_line_tbl        QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 gpr_pricing_attr_tbl           QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_price_list_rec             QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec         QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl        QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl    QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 ppr_qualifiers_tbl             QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl         QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl           QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl       QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 k                              NUMBER;
 l_list_header_id               NUMBER;
 l_list_line_id                 NUMBER;

 -- This cursor is used to get the price lists for an inventory item
CURSOR l_prodattrval_csr IS
SELECT list_header_id, list_line_id
FROM   qp_pricing_attributes
WHERE  product_attr_value = to_char(p_item_id);



BEGIN

     -- disable all the price lists for the inventory item
     FOR l_prodattrval_rec IN l_prodattrval_csr LOOP

         gpr_price_list_rec.list_header_id := l_prodattrval_rec.list_header_id;
         gpr_price_list_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
         gpr_price_list_rec.end_date_active := p_sysdate;


         gpr_price_list_line_tbl(1).end_date_active := p_sysdate;
         gpr_price_list_line_tbl(1).list_line_type_code := 'PLL';
         gpr_price_list_line_tbl(1).list_line_id := l_prodattrval_rec.list_line_id;

         gpr_price_list_line_tbl(1).operation := QP_GLOBALS.G_OPR_UPDATE;


         QP_PRICE_LIST_PUB.Process_Price_List
            (   p_api_version_number            => 1
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
     END LOOP;
EXCEPTION
  WHEN OTHERS THEN
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END remove_item_from_price_list;
*/



-- Start of comments
--
-- Procedure Name  : remove_item
-- Description     : This procedure is used to reduce the quantity of inventory items after an Order has been
--                   booked, by creating an issue transaction . This procedure is called from remove_rmk_item
--
-- Business Rules  :
-- Parameters      :  Input parameters :
--                                       p_inventory_item_id    - item id
--                                       p_Subinv_Code          - Subinventory Code
--                                       p_org_id               - organization that the item belongs to
--                                       p_dist_account_id      - Distribution Account
--                                       p_quantity             - Ordered Quantity
--                                       p_sysdate              - system date
--                    Innentory Item Id and Organization Id form the PK for mtl_system_items
-- Version         : 1.0
-- History         : SECHAWLA 05-DEC-02 Bug# 2620853
--                     Commented out the codethat references disribution account id, as it is optional
--                   SECHAWLA 16-JAN-03 Bug # 2754280
--                     Changed the app name from OKL to OKC for g_unexpected_error
-- End of comments

PROCEDURE remove_item
(
     p_inventory_item_id     IN     NUMBER,
     p_Subinv_Code           IN     VARCHAR2,
     p_org_id                IN     NUMBER,
    -- SECHAWLA Bug# 2620853 : dist_account_id is not required
    -- p_dist_account_id       IN     NUMBER,
     p_quantity              IN     NUMBER,
     p_sysdate               IN     DATE,
     x_return_status         OUT 	NOCOPY VARCHAR2

)
IS

/*
-- This code is commented in anticipation of the possibility of including it again at some point in future.


-- This cursor is used to make sure that the item exists in active state, before removing the item
CURSOR l_mtlsysitems_csr(p_inventory_item_id NUMBER,p_organization_id NUMBER)  IS
SELECT 'x'
FROM   mtl_system_items_b
WHERE  inventory_item_id = p_inventory_item_id
AND    organization_id = p_organization_id
AND    end_date_active IS NULL;
*/


BEGIN


   -- Creating Inventory Issue Transaction for the Item

    Create_Inv_Misc_Receipt_Txn
         (p_inventory_item_id => p_inventory_item_id,
          p_subinv_code       => p_subinv_code,
          p_organization_id   => p_org_id,
        --SECHAWLA Bug# 2620853 : dist_account_id is not required
        --  p_dist_account_id   => p_dist_account_id,
          p_quantity          => p_quantity,
          p_trans_type_id     => 32,         --- trnasction type ID for Issue Transactions
          p_sysdate           => p_sysdate,
          x_return_status     => x_return_status);

    -- return status of the above procedure call becomes the return status of the current procedure
    -- which is then handled in the calling procedure - remove_rmk_item


/*
   -- This code is commented in anticipation of the possibility of including it again at some point in future.
   -- If this code needs to be uncommented, we must get the org id as a direct input parameter. We can not
   -- use the Org from the profile to delete (disable) an inventory item, as the pofile may change between the time of
   -- creation and deletion of inventory item. An item may belong to more than one org So Org Id is required to
   -- disable an inventory item.

   IF p_item_id IS NULL OR p_item_id =  OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Item Id is required
        OKC_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ITEM_ID');
        RAISE okc_api.G_EXCEPTION_ERROR;
   END IF;

   IF p_org_id IS NULL OR p_org_id = OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Organization Id is required
        OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORGANIZATION');
        RAISE okc_api.G_EXCEPTION_ERROR;
   END IF;

   OPEN   l_mtlsysitems_csr(p_item_id,p_org_id);
   FETCH  l_mtlsysitems_csr INTO l_temp;
   IF  l_mtlsysitems_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- No active Item exists for this combination of Item and Organization
        OKL_API.set_message(         p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RMK_INVALID_ITEM_ORG'

                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_mtlsysitems_csr;

   -- Disable the Inventory Item
   remove_inv_item(p_item_id       => p_item_id,
                   p_org_id        => p_org_id,
                   p_sysdate       => l_sysdate,
                   x_return_status => x_return_status);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   -- Disable the Price Lists corresponding to the Inventory Item
   remove_item_from_price_list(p_item_id       => p_item_id,
                               p_sysdate       => l_sysdate,
                               x_return_status => x_return_status);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
*/

  EXCEPTION
       WHEN OTHERS THEN
          -- unexpected error

          -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
          OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END remove_item;



-- Start of comments
--
-- Procedure Name  : remove_rmk_item
-- Description     : This procedure is used to reduce the quantity of of all the inventory items belonging to an
--                   order, after the order has been booked
-- Business Rules  :
-- Parameters      :  Input parameters : p_order_header_id - header ID for the Order
-- Version         : 1.0
-- History         : SECHAWLA 05-DEC-02 : Bug # 2620853
--                     Commented out the code that uses distribution account id
--                     Removed DEFAULT hint from procedure parameters
--                   SECHAWLA 17-DEC-02 : Bug # 2706328
--                     Fixed the datatype of l_temp_org_name
--                   SECHAWLA 21-OCT-04 3924244
--                     changed p_order_header_id to p_order_line_Id and modified the code to work on order line id
--                     instead of order header id
--
-- End of comments

PROCEDURE remove_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 ,
     p_order_line_Id         IN     NUMBER,  -- SECHAWLA 21-OCT-04 3924244
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2

) IS

-- This cursor is used to validate Header ID
CURSOR l_orderheaders_csr(cp_header_id NUMBER) IS
SELECT order_number
FROM   oe_order_headers_all
WHERE  header_id = cp_header_id;

/* -- SECHAWLA 21-OCT-04 3924244
-- This cursor is used to get the information about all the line items corresponding to an Order
CURSOR l_orderlines_csr(p_header_id  NUMBER) IS
SELECT line_id, inventory_item_id, ordered_quantity, ship_from_org_id
FROM   oe_order_lines_all
WHERE  header_id = p_header_id;
*/

-- SECHAWLA 21-OCT-04 3924244 : added this cursor
-- This cursor is used to get the information about an order line
CURSOR l_orderlines_csr(cp_line_id  NUMBER) IS
SELECT header_id, inventory_item_id, ordered_quantity, ship_from_org_id
FROM   oe_order_lines_all
WHERE  line_id = cp_line_id;


-- This cursor is used to get the source subinventory and distribution account for an inventory item
CURSOR l_mtlsystemitems_csr(p_item_id NUMBER, p_org_id NUMBER) IS
-- SECHAWLA Bug# 2620853 : ENCUMBRANCE_ACCOUNT (which stores the distribution accout id) is not required
--SELECT SOURCE_SUBINVENTORY, ENCUMBRANCE_ACCOUNT
SELECT SOURCE_SUBINVENTORY
FROM   mtl_system_items
WHERE  inventory_item_id = p_item_id
AND    organization_id = p_org_id;

    l_order_number                  NUMBER;
    l_return_status                 VARCHAR2(1);
    l_sysdate                       DATE;
    l_api_name                      CONSTANT VARCHAR2(30) := 'remove_rmk_item';
    l_api_version                   CONSTANT NUMBER := 1;

    l_inv_org_id                    NUMBER;
    l_subinv_code                   VARCHAR2(10);
    -- SECHAWLA Bug # 2620853 : Distribution account id is not required
   -- l_distribution_account_id       NUMBER;
    --SECHAWLA 2706328 : Fixed the datatype for l_temp_org_name
    l_temp_org_name                 mtl_organizations.organization_name%TYPE;

    l_header_id						NUMBER;
	l_inventory_item_id				NUMBER;
	l_ordered_quantity				NUMBER;
	l_ship_from_org_id				NUMBER;

BEGIN

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

   SELECT SYSDATE INTO l_sysdate FROM dual;

   -- SECHAWLA 21-OCT-04 3924244 : changed header id to line id
   IF p_order_line_Id IS NULL OR  p_order_line_Id =  OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Order Line ID is required
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDER_LINE_ID');
        RAISE okl_api.G_EXCEPTION_ERROR;
   END IF;

   /*-- SECHAWLA 21-OCT-04 3924244
   OPEN  l_orderheaders_csr(p_order_header_Id);
   FETCH l_orderheaders_csr INTO l_order_number;
   IF l_orderheaders_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Order Header ID is invalid
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDER_HEADER_ID');
        RAISE okl_api.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_orderheaders_csr;
   */

   -- SECHAWLA 21-OCT-04 3924244 : added
   OPEN  l_orderlines_csr(p_order_line_Id);
   FETCH l_orderlines_csr INTO l_header_id, l_inventory_item_id, l_ordered_quantity, l_ship_from_org_id;
   IF  l_orderlines_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Order Line ID is invalid
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDER_LINE_ID');
        RAISE okl_api.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_orderlines_csr;

   OPEN  l_orderheaders_csr(l_header_id);
   FETCH l_orderheaders_csr INTO l_order_number;
   CLOSE l_orderheaders_csr;

   -- loop thru all the line items for a given order, validate the data and then reduce the quantity of each line item

   -- SECHAWLA 21-OCT-04 3924244 : commented out the loop
   --FOR l_orderlines_rec IN l_orderlines_csr(p_order_header_id) LOOP

       IF l_ship_from_org_id IS NULL THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Ship From Org ID is required
            OKL_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'SHIP_FROM_ORG_ID');
            RAISE okl_api.G_EXCEPTION_ERROR;
       END IF;


       OPEN   l_mtlsystemitems_csr(l_inventory_item_id, l_ship_from_org_id);
       -- SECHAWLA Bug# 2620853 : Distribution accout id is not required
       --FETCH  l_mtlsystemitems_csr INTO l_subinv_code, l_distribution_account_id;
       FETCH  l_mtlsystemitems_csr INTO l_subinv_code;
       IF l_mtlsystemitems_csr%NOTFOUND THEN
          -- shipping org for the order does not match the Item's organization
          x_return_status := OKL_API.G_RET_STS_ERROR;
           --Order ORDER_NUMBER has invalid combination of inventory item and organization
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_INVALID_ITEM_ORG',
                              p_token1       => 'ORDER_NUMBER',
                              p_token1_value => l_order_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF l_subinv_code IS NULL THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- source subinventory is required
          OKL_API.set_message(       p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'SOURCE_SUBINVENTORY');
          RAISE okl_api.G_EXCEPTION_ERROR;
       END IF;
       CLOSE  l_mtlsystemitems_csr;

       -- Distribution Account ID can be NULL

       --SECHAWLA Bug# 2620853 : Distribution Account ID is not required
       remove_item(    p_inventory_item_id      => l_inventory_item_id,
                       p_subinv_code            => l_subinv_code,
                       p_org_id                 => l_ship_from_org_id,
                       p_quantity               => -(l_ordered_quantity),
                       p_sysdate                => l_sysdate,
                       x_return_status          => x_return_status);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

 --  END LOOP;  -- SECHAWLA 21-OCT-04 3924244

  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        IF l_orderheaders_csr%ISOPEN THEN
           CLOSE l_orderheaders_csr;
        END IF;
        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;
        IF l_mtlsystemitems_csr%ISOPEN THEN
           CLOSE l_mtlsystemitems_csr;
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
        IF l_orderheaders_csr%ISOPEN THEN
           CLOSE l_orderheaders_csr;
        END IF;
        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;
        IF l_mtlsystemitems_csr%ISOPEN THEN
           CLOSE l_mtlsystemitems_csr;
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
       IF l_orderheaders_csr%ISOPEN THEN
           CLOSE l_orderheaders_csr;
       END IF;
       IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
       END IF;
       IF l_mtlsystemitems_csr%ISOPEN THEN
           CLOSE l_mtlsystemitems_csr;
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


END remove_rmk_item;




END OKL_AM_REMARKET_ASSET_PVT;

/
