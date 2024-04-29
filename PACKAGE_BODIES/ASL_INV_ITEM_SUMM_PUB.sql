--------------------------------------------------------
--  DDL for Package Body ASL_INV_ITEM_SUMM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASL_INV_ITEM_SUMM_PUB" AS
/* $Header: aslconb.pls 120.2 2005/10/25 03:46:43 appldev ship $ */

-- Global variables for WHO variables and Concurrent program
G_load_table       VARCHAR2(30) := 'ASL_INV_SUMM_PKG' ;
G_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
G_appl_id          NUMBER := FND_GLOBAL.PROG_APPL_ID();
G_program_id       NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
G_user_id          NUMBER := FND_GLOBAL.USER_ID();
G_login_id         NUMBER := FND_GLOBAL.CONC_LOGIN_ID();
G_DEBUG            VARCHAR2(1) := NVL(fnd_profile.value('APPS_DEBUG'), 'N');
-- 07-APR-2004 vqnguyen disabled pricing summarization.
--                  replace the following G_PRICING declaration with the
--                  commented one below it to re-enable
G_PRICING          VARCHAR2(1) := 'Y';
-- G_PRICING          VARCHAR2(1) := NVL(fnd_profile.value('ASL_ALL_ITEM_PRICE_LINE'),'N');


PROCEDURE Table_Load_Main(
            ERRBUF            OUT NOCOPY VARCHAR2
         , RETCODE            OUT NOCOPY VARCHAR2
         , p_run_mode         IN  VARCHAR2 DEFAULT 'I'
         , p_category_set_id  IN  NUMBER
         , p_organization_id  IN  NUMBER
         , p_category_id      IN  NUMBER
       ) IS

  l_run_mode              VARCHAR2(1) := p_run_mode;
  l_err_code               VARCHAR2(1);
  l_err_msg                VARCHAR2(200); -- Error message for parameter input errors
  l_category_set_id       NUMBER := p_category_set_id;
  l_organization_id       NUMBER := p_organization_id;
  l_category_id           NUMBER := p_category_id;


  -- Package Exceptions

  FAILED_EDIT  EXCEPTION;

  FAILED_LOAD  EXCEPTION;

BEGIN
  --  Begin Actual Load Process



    IF l_run_mode = 'C' THEN

            asl_summ_load_glbl_pkg.Delete_Rows (
                 p_table_name        => 'ASL_INVENTORY_ITEM_DENORM'
               , p_category_set_id   =>  l_category_set_id
                , p_organization_id   =>  l_organization_id
                , p_category_id       =>  l_category_id
                , x_err_msg           =>  l_err_msg
                , x_err_code          =>  l_err_code
            );


            Complete_Inv_Item_Refresh(
                 x_err_msg          => l_err_msg
                , x_err_code         => l_err_code
                , p_category_set_id  => l_category_set_id
                , p_organization_id  => l_organization_id
                , p_category_id      => l_category_id
             );
            -- Based on flag setting inventory pricing data is collected
            IF G_PRICING = 'N' THEN

               asl_summ_load_glbl_pkg.Delete_Rows (
                     p_table_name        => 'ASL_INVENTORY_PRICING'
                   , p_category_set_id   =>  l_category_set_id
                    , p_organization_id   =>  l_organization_id
                    , p_category_id       =>  l_category_id
                    , x_err_msg           =>  l_err_msg
                    , x_err_code          =>  l_err_code
               );


               Complete_Inv_Pricing_Refresh(
                     x_err_msg          => l_err_msg
                    , x_err_code         => l_err_code
                    , p_category_set_id  => l_category_set_id
                    , p_organization_id  => l_organization_id
                    , p_category_id      => l_category_id
                );
            END IF;


     ELSE
          IF l_category_id IS NULL THEN
             Increm_Cat_Inv_Item_Refresh(
                 x_err_msg          => l_err_msg
                , x_err_code         => l_err_code
                , p_category_set_id  => l_category_set_id
                , p_organization_id  => l_organization_id
             );
          ELSE
             Increm_Inv_Item_Refresh(
                x_err_msg          => l_err_msg
               , x_err_code         => l_err_code
               , p_category_set_id  => l_category_set_id
               , p_organization_id  => l_organization_id
               , p_category_id      => l_category_id
             );
          END IF;
          IF G_PRICING = 'N' THEN
              IF l_category_id IS NULL THEN
                 Increm_Cat_Inv_Price_Refresh(
                     x_err_msg          => l_err_msg
                    , x_err_code         => l_err_code
                    , p_category_set_id  => l_category_set_id
                    , p_organization_id  => l_organization_id
                 ) ;
              ELSE
                 Increm_Inv_Pricing_Refresh(
                    x_err_msg          => l_err_msg
                   , x_err_code         => l_err_code
                   , p_category_set_id  => l_category_set_id
                   , p_organization_id  => l_organization_id
                   , p_category_id      => l_category_id
                 );

              END IF;
          END IF;

   END IF;

     IF l_err_code = '2'  THEN    -- Load Failure - Halt processing
        RAISE FAILED_LOAD;
     ELSE
    Category_summary_Info_Refresh(
           x_err_msg          => l_err_msg
           , x_err_code       => l_err_code);
     END IF;



 EXCEPTION
  WHEN FAILED_LOAD THEN
    ERRBUF  :=  l_err_msg;
    RETCODE :=  l_err_code;


 WHEN OTHERS THEN
     l_err_msg    := SUBSTR(SQLERRM,1,150);
      l_err_code := '2' ;
      ERRBUF     :=  l_err_msg;
      RETCODE    :=  l_err_code;

 END Table_Load_Main;

 /***************      Begin Sub Procedures                 ***************/

 PROCEDURE Category_summary_Info_Refresh (
          x_err_msg           OUT NOCOPY VARCHAR2
             , x_err_code          OUT NOCOPY VARCHAR2
 ) IS
   l_rows_inserted        NUMBER := 0;
 BEGIN
 DELETE asl_category_summary_info;
 INSERT INTO asl_category_summary_info (CATEGORY_ID, CATEGORY_SET_ID , ORGANIZATION_ID,
                        CREATION_DATE, LANGUAGE_CODE )
 SELECT DISTINCT category_id, category_set_id , organization_id, SYSDATE, language_code
 FROM asl_inventory_item_denorm ;

    IF SQL%NOTFOUND THEN
        x_err_msg := 'Category_summary_Info_Refresh' || SUBSTR(SQLERRM,1,150);
        x_err_code := '0';
    ELSE
        COMMIT;
        l_rows_inserted := SQL%ROWCOUNT;
        x_err_code := '0';
    END IF;
    IF G_DEBUG = 'Y' THEN
         asl_summ_load_glbl_pkg.Write_Log(
                        p_table     => 'ASL_CATEGORY_SUMMARY_INFO'
            , p_action    => 'I'
            , p_procedure => 'Category_summary_Info_Refresh'
            , p_num_rows  => l_rows_inserted
                  );
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      x_err_msg  :=  'Category_summary_Info_Refresh:  ' || SUBSTR(SQLERRM,1,150);
      x_err_code :=  '2';

    IF G_DEBUG = 'Y' THEN
      asl_summ_load_glbl_pkg.Write_Log(
            p_table     => 'ASL_CATEGORY_SUMMARY_INFO'
                    , p_action    => 'E'
                    , p_procedure => 'Category_summary_Info_Refresh'
                    , p_load_mode => 'I'
                    , p_message   => x_err_msg
      );
    END IF;

 END Category_summary_Info_Refresh;

 PROCEDURE Complete_Inv_Item_Refresh(
          x_err_msg           OUT NOCOPY VARCHAR2
         , x_err_code          OUT NOCOPY VARCHAR2
         , p_category_set_id   IN  NUMBER
         , p_organization_id   IN  NUMBER
         , p_category_id       IN  NUMBER
        )IS

   l_rows_inserted    NUMBER := 0;

   l_category_id       NUMBER := p_category_id;
   l_category_set_id   NUMBER := p_category_set_id;
   l_inv_org_id        NUMBER := p_organization_id;

BEGIN


 IF  l_category_id IS  NULL THEN

   INSERT INTO ASL_INVENTORY_ITEM_DENORM
    (CATEGORY_SET_ID
    ,CATEGORY_ID
    ,INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,LAST_UPDATE_DATE
    ,CREATION_DATE
    ,INVENTORY_ITEM_NUMBER
    ,ITEM_DESCRIPTION
    ,LANGUAGE_CODE
    ,UOM_CODE
    ,UOM_DESCRIPTION
    ,INTEREST_TYPE_ID
    ,INTEREST_TYPE
    ,PRIMARY_INTEREST_CODE_ID
    ,PRIMARY_INTEREST_CODE
    ,SECONDARY_INTEREST_CODE_ID
    ,SECONDARY_INTEREST_CODE
    ,SHIPPLE_FLAG
    ,SERVICE_ITEM_FLAG
    ,TAXABLE_FLAG
    ,RETURNABLE_FLAG
    ,SERVICEABLE_FLAG
    ,ACTIVE_FLAG
    ,BOM_ENABLED_FLAG
    ,VENDOR_WARRANTY_FLAG
    ,PRIMARY_UOM_CODE
    ) SELECT /*+ FIRST_ROWS  */
           MIC.CATEGORY_SET_ID,
           MIC.CATEGORY_ID,
           ITEM.INVENTORY_ITEM_ID,
           ITEM.ORGANIZATION_ID,
           SYSDATE, -- For bootstrap, using sysdate temporary.
           SYSDATE,
           B.CONCATENATED_SEGMENTS,
           ITEM.DESCRIPTION,
           USERENV ( 'LANG' ),
           UOM.UOM_CODE,
           UOM.UNIT_OF_MEASURE,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           B.SHIPPABLE_ITEM_FLAG ,
           B.SERVICE_ITEM_FLAG ,
           B.TAXABLE_FLAG ,
           B.returnable_flag ,
           B.SERVICEABLE_PRODUCT_FLAG ,
           'Y', -- Active Flag to be 'Y'
           DECODE(B.BOM_ITEM_TYPE,1,'MDL',4,DECODE(B.SERVICE_ITEM_FLAG ,'Y','SRV', DECODE(B.SERVICEABLE_PRODUCT_FLAG,'Y','SVA','STD')),'OPP') ,
            B.VENDOR_WARRANTY_FLAG,
	    B.PRIMARY_UOM_CODE
    FROM    MTL_SYSTEM_ITEMS_B_KFV B,
            MTL_SYSTEM_ITEMS_TL ITEM,
            MTL_ITEM_CATEGORIES MIC,
            MTL_UNITS_OF_MEASURE_TL UOM
     WHERE  MIC.ORGANIZATION_ID   = l_inv_org_id
     AND    MIC.CATEGORY_SET_ID   = l_category_set_id
     AND    MIC.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
     AND    MIC.ORGANIZATION_ID   = B.ORGANIZATION_ID
     AND    B.PRIMARY_UOM_CODE    = UOM.UOM_CODE
     AND    UOM.LANGUAGE          = userenv('LANG')
     AND    B.INVENTORY_ITEM_ID   = ITEM.INVENTORY_ITEM_ID
     AND    B.ORGANIZATION_ID     = ITEM.ORGANIZATION_ID
     AND    ITEM.LANGUAGE         = userenv('LANG');

  ELSE
     INSERT INTO ASL_INVENTORY_ITEM_DENORM
    (CATEGORY_SET_ID
    ,CATEGORY_ID
    ,INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,LAST_UPDATE_DATE
    ,CREATION_DATE
    ,INVENTORY_ITEM_NUMBER
    ,ITEM_DESCRIPTION
    ,LANGUAGE_CODE
    ,UOM_CODE
    ,UOM_DESCRIPTION
    ,INTEREST_TYPE_ID
    ,INTEREST_TYPE
    ,PRIMARY_INTEREST_CODE_ID
    ,PRIMARY_INTEREST_CODE
    ,SECONDARY_INTEREST_CODE_ID
    ,SECONDARY_INTEREST_CODE
    ,SHIPPLE_FLAG
    ,SERVICE_ITEM_FLAG
    ,TAXABLE_FLAG
    ,RETURNABLE_FLAG
    ,SERVICEABLE_FLAG
    ,ACTIVE_FLAG
    ,BOM_ENABLED_FLAG
    ,VENDOR_WARRANTY_FLAG
    ,PRIMARY_UOM_CODE
    ) SELECT /*+ FIRST_ROWS  */
           MIC.CATEGORY_SET_ID,
           MIC.CATEGORY_ID,
           ITEM.INVENTORY_ITEM_ID,
           ITEM.ORGANIZATION_ID,
           SYSDATE, -- For bootstrap, using sysdate temporary.
           SYSDATE,
           B.CONCATENATED_SEGMENTS,
           ITEM.DESCRIPTION,
           USERENV ( 'LANG' ),
           UOM.UOM_CODE,
           UOM.UNIT_OF_MEASURE,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           B.SHIPPABLE_ITEM_FLAG ,
           B.SERVICE_ITEM_FLAG ,
           B.TAXABLE_FLAG ,
           B.returnable_flag ,
           B.SERVICEABLE_PRODUCT_FLAG ,
           'Y', -- Active Flag to be 'Y'
           DECODE(B.BOM_ITEM_TYPE,1,'MDL',4,DECODE(B.SERVICE_ITEM_FLAG ,'Y','SRV', DECODE(B.SERVICEABLE_PRODUCT_FLAG,'Y','SVA','STD')),'OPP') ,
            B.VENDOR_WARRANTY_FLAG,
	    B.PRIMARY_UOM_CODE
    FROM    MTL_SYSTEM_ITEMS_B_KFV B,
            MTL_SYSTEM_ITEMS_TL ITEM,
            MTL_ITEM_CATEGORIES MIC,
            MTL_UNITS_OF_MEASURE_TL UOM
     WHERE  MIC.ORGANIZATION_ID   = l_inv_org_id
     AND    MIC.CATEGORY_SET_ID   = l_category_set_id
     AND    MIC.CATEGORY_ID       = l_category_id
     AND    MIC.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
     AND    MIC.ORGANIZATION_ID   = B.ORGANIZATION_ID
     AND    B.PRIMARY_UOM_CODE    = UOM.UOM_CODE
     AND    UOM.LANGUAGE          = userenv('LANG')
     AND    B.INVENTORY_ITEM_ID   = ITEM.INVENTORY_ITEM_ID
     AND    B.ORGANIZATION_ID     = ITEM.ORGANIZATION_ID
     AND    ITEM.LANGUAGE         = userenv('LANG');

  END IF;




    IF SQL%NOTFOUND THEN
        x_err_msg := 'Complete_Inv_Item_Refresh' || SUBSTR(SQLERRM,1,150);
        x_err_code := '0';
    ELSE
        COMMIT;
        l_rows_inserted := SQL%ROWCOUNT;
        x_err_code := '0';
    END IF;
    IF G_DEBUG = 'Y' THEN
         asl_summ_load_glbl_pkg.Write_Log(
                p_table     => 'ASL_INVENTORY_ITEM_DENORM'
            , p_action    => 'I'
            , p_procedure => 'Insert_Inv_Item_Denorm'
            , p_num_rows  => l_rows_inserted
          );
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      x_err_msg  :=  'Complete_Inv_Item_Refresh:  ' || SUBSTR(SQLERRM,1,150);
      x_err_code :=  '2';

    IF G_DEBUG = 'Y' THEN
      asl_summ_load_glbl_pkg.Write_Log(
            p_table     => 'ASL_INVENTORY_ITEM_DENORM'
            , p_action    => 'E'
            , p_procedure => 'Complete_Inv_Item_Refresh'
            , p_load_mode => 'I'
            , p_message   => x_err_msg
      );
    END IF;

 END Complete_Inv_Item_Refresh;

 PROCEDURE Increm_Inv_Item_Refresh(
        x_err_msg          OUT NOCOPY VARCHAR2
       , x_err_code         OUT NOCOPY VARCHAR2
       , p_category_set_id  IN  NUMBER
       , p_organization_id  IN  NUMBER
       , p_category_id      IN  NUMBER
       ) IS

   l_rows_updated      NUMBER := 0;
   l_upd_date           DATE   := TRUNC(sysdate);
   l_category_id        NUMBER := p_category_id;
   l_category_set_id    NUMBER := p_category_set_id;
   l_inv_org_id         NUMBER := p_organization_id;
   l_inv_item_id        NUMBER;
   l_count              NUMBER := 1;



   CURSOR inv_item_id(pl_category_set_id  NUMBER,
                      pl_inv_org_id       NUMBER,
                      pl_category_id      NUMBER) IS
         SELECT  INVENTORY_ITEM_ID
            FROM  MTL_ITEM_CATEGORIES
            WHERE  CATEGORY_SET_ID    =  pl_category_set_id
              AND  ORGANIZATION_ID    =  pl_inv_org_id
              AND  CATEGORY_ID        =  pl_category_id;


 BEGIN



    OPEN  inv_item_id  (l_category_set_id,
                        l_inv_org_id,
                        l_category_id);

     WHILE  l_count  = 1  LOOP

       FETCH  inv_item_id  INTO  l_inv_item_id;

       IF inv_item_id%FOUND THEN


        -- update record if it already exists
        UPDATE ASL_INVENTORY_ITEM_DENORM   aiid
        SET
           ( LAST_UPDATE_DATE
            ,INVENTORY_ITEM_NUMBER
            ,ITEM_DESCRIPTION
            ,LANGUAGE_CODE
            ,UOM_CODE
            ,UOM_DESCRIPTION
           -- ,INTEREST_TYPE_ID   -- is this required
           -- ,INTEREST_TYPE
           -- ,PRIMARY_INTEREST_CODE_ID
           -- ,PRIMARY_INTEREST_CODE
           -- ,SECONDARY_INTEREST_CODE_ID
           -- ,SECONDARY_INTEREST_CODE   -- is this required
            ,SHIPPLE_FLAG
            ,SERVICE_ITEM_FLAG
            ,TAXABLE_FLAG
            ,RETURNABLE_FLAG
            ,SERVICEABLE_FLAG
            ,ACTIVE_FLAG )  =
        (SELECT
           SYSDATE,
           B.CONCATENATED_SEGMENTS,
           ITEM.DESCRIPTION,
           USERENV ( 'LANG' ),
           UOM.UOM_CODE,
           UOM.UNIT_OF_MEASURE,
         --  NULL,
         --  NULL,
         --  NULL,
         --  NULL,
         --  NULL,
         --  NULL,
           B.SHIPPABLE_ITEM_FLAG ,
           B.SERVICE_ITEM_FLAG ,
           B.TAXABLE_FLAG ,
           B.returnable_flag ,
           B.SERVICEABLE_PRODUCT_FLAG ,
           'Y' -- Active Flag to be 'Y'
            FROM    MTL_SYSTEM_ITEMS_B_KFV B,
                    MTL_SYSTEM_ITEMS_TL ITEM,
                    MTL_ITEM_CATEGORIES MIC,
                    MTL_UNITS_OF_MEASURE_TL UOM
            WHERE   MIC.ORGANIZATION_ID   = l_inv_org_id
              AND   MIC.CATEGORY_SET_ID   = l_category_set_id
              AND   MIC.CATEGORY_ID       =  l_category_id
              AND   B.INVENTORY_ITEM_ID   =  l_inv_item_id
              AND   MIC.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
              AND   MIC.ORGANIZATION_ID   = B.ORGANIZATION_ID
              AND   B.PRIMARY_UOM_CODE    = UOM.UOM_CODE
              AND   UOM.LANGUAGE          = userenv('LANG')
              AND   B.INVENTORY_ITEM_ID   = ITEM.INVENTORY_ITEM_ID
              AND   B.ORGANIZATION_ID     = ITEM.ORGANIZATION_ID
              AND   ITEM.LANGUAGE         = userenv('LANG')    )

        WHERE   aiid.ORGANIZATION_ID   = l_inv_org_id
         AND    aiid.CATEGORY_SET_ID   = l_category_set_id
         AND    aiid.CATEGORY_ID       = l_category_id
         AND    aiid.INVENTORY_ITEM_ID = l_inv_item_id
         AND    aiid.LANGUAGE_CODE     = userenv('LANG')
      -- if we do not put this part of code and if select does not get records update will raise ora error
         AND EXISTS (SELECT 1  FROM
            MTL_SYSTEM_ITEMS_B_KFV B,
            MTL_SYSTEM_ITEMS_TL ITEM,
            MTL_ITEM_CATEGORIES MIC,
            MTL_UNITS_OF_MEASURE_TL UOM
          WHERE   MIC.ORGANIZATION_ID   = l_inv_org_id
            AND   MIC.CATEGORY_SET_ID   = l_category_set_id
            AND   MIC.CATEGORY_ID       = l_category_id
            AND   B.INVENTORY_ITEM_ID   = l_inv_item_id
            AND   MIC.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
            AND   MIC.ORGANIZATION_ID   = B.ORGANIZATION_ID
            AND   B.PRIMARY_UOM_CODE    = UOM.UOM_CODE
            AND   UOM.LANGUAGE          = userenv('LANG')
            AND   B.INVENTORY_ITEM_ID   = ITEM.INVENTORY_ITEM_ID
            AND   B.ORGANIZATION_ID     = ITEM.ORGANIZATION_ID
            AND   ITEM.LANGUAGE         = userenv('LANG') );

     -- Insert if inv item id and which does not exist
        INSERT INTO ASL_INVENTORY_ITEM_DENORM
            (CATEGORY_SET_ID
            ,CATEGORY_ID
            ,INVENTORY_ITEM_ID
            ,ORGANIZATION_ID
            ,LAST_UPDATE_DATE
            ,CREATION_DATE
            ,INVENTORY_ITEM_NUMBER
            ,ITEM_DESCRIPTION
            ,LANGUAGE_CODE
            ,UOM_CODE
            ,UOM_DESCRIPTION
            ,INTEREST_TYPE_ID
            ,INTEREST_TYPE
            ,PRIMARY_INTEREST_CODE_ID
            ,PRIMARY_INTEREST_CODE
            ,SECONDARY_INTEREST_CODE_ID
            ,SECONDARY_INTEREST_CODE
            ,SHIPPLE_FLAG
            ,SERVICE_ITEM_FLAG
            ,TAXABLE_FLAG
            ,RETURNABLE_FLAG
            ,SERVICEABLE_FLAG
            ,ACTIVE_FLAG
    ,BOM_ENABLED_FLAG
    ,VENDOR_WARRANTY_FLAG
    ,PRIMARY_UOM_CODE
               ) SELECT /*+ FIRST_ROWS  */
                     MIC.CATEGORY_SET_ID,
                     MIC.CATEGORY_ID,
                     ITEM.INVENTORY_ITEM_ID,
                     ITEM.ORGANIZATION_ID,
                     SYSDATE, -- For bootstrap, using sysdate temporary.
                     SYSDATE,
                     B.CONCATENATED_SEGMENTS,
                     ITEM.DESCRIPTION,
                     USERENV ( 'LANG' ),
                     UOM.UOM_CODE,
                     UOM.UNIT_OF_MEASURE,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     B.SHIPPABLE_ITEM_FLAG ,
                     B.SERVICE_ITEM_FLAG ,
                     B.TAXABLE_FLAG ,
                     B.returnable_flag ,
                     B.SERVICEABLE_PRODUCT_FLAG ,
                     'Y', -- Active Flag to be 'Y'
           DECODE(B.BOM_ITEM_TYPE,1,'MDL',4,DECODE(B.SERVICE_ITEM_FLAG ,'Y','SRV', DECODE(B.SERVICEABLE_PRODUCT_FLAG,'Y','SVA','STD')),'OPP') ,
            B.VENDOR_WARRANTY_FLAG,
	    B.PRIMARY_UOM_CODE
               FROM    MTL_SYSTEM_ITEMS_B_KFV B,
                       MTL_SYSTEM_ITEMS_TL ITEM,
                       MTL_ITEM_CATEGORIES MIC,
                       MTL_UNITS_OF_MEASURE_TL UOM
               WHERE  MIC.ORGANIZATION_ID    = l_inv_org_id
               AND    MIC.CATEGORY_SET_ID    = l_category_set_id
               AND    MIC.CATEGORY_ID        = l_category_id
               AND    ITEM.INVENTORY_ITEM_ID = l_inv_item_id
               AND    MIC.INVENTORY_ITEM_ID  = B.INVENTORY_ITEM_ID
               AND    MIC.ORGANIZATION_ID    = B.ORGANIZATION_ID
               AND    B.PRIMARY_UOM_CODE     = UOM.UOM_CODE
               AND    UOM.LANGUAGE           = userenv('LANG')
               AND    B.INVENTORY_ITEM_ID    = ITEM.INVENTORY_ITEM_ID
               AND    B.ORGANIZATION_ID      = ITEM.ORGANIZATION_ID
               AND    ITEM.LANGUAGE          = userenv('LANG')
               AND NOT EXISTS
                   (  SELECT 1
                          FROM  ASL_INVENTORY_ITEM_DENORM aiid
                          WHERE  aiid.CATEGORY_SET_ID    =  l_category_set_id
                          AND    aiid.ORGANIZATION_ID    =  l_inv_org_id
                          AND    aiid.CATEGORY_ID        =  l_category_id
                          AND    aiid.INVENTORY_ITEM_ID  =  l_inv_item_id
                          AND    aiid.LANGUAGE_CODE      =  userenv('LANG') );

      ELSE
         l_count  := 0;  -- loop stops at this stage.

      END IF;
    END LOOP;

    CLOSE inv_item_id;

      IF SQL%NOTFOUND THEN
         l_rows_updated :=  0 ;
         x_err_code     := '0';
      ELSE
         COMMIT;
         l_rows_updated := SQL%ROWCOUNT;
         x_err_code     := '0';
      END IF;


     IF G_DEBUG = 'Y' THEN
      asl_summ_load_glbl_pkg.Write_Log(
                p_table       => 'ASL_INVENTORY_ITEM_DENORM'
            , p_action      => 'U'
            , p_procedure   => 'Increm_Inv_Item_Refresh'
            , p_num_rows    => l_rows_updated
          ) ;
     END IF;


  EXCEPTION
   WHEN OTHERS THEN
      x_err_msg  :=  'Increm_Inv_Item_Refresh:  ' || SUBSTR(SQLERRM,1,150);
      x_err_code :=  '2';

    IF G_DEBUG = 'Y' THEN
     asl_summ_load_glbl_pkg.Write_Log(
                p_table     => 'ASL_INVENTORY_ITEM_DENORM'
                , p_action    => 'E'
                , p_procedure => 'Increm_Inv_Item_Refresh'
                , p_load_mode => 'U'
                , p_message   => x_err_msg
      );
    END IF;



 END  Increm_Inv_Item_Refresh;


 PROCEDURE Increm_Cat_Inv_Item_Refresh(
        x_err_msg          OUT NOCOPY VARCHAR2
       , x_err_code         OUT NOCOPY VARCHAR2
       , p_category_set_id  IN  NUMBER
       , p_organization_id  IN  NUMBER
       ) IS

      l_rows_updated       NUMBER := 0;
      l_upd_date           DATE   := TRUNC(sysdate);
      l_category_id        NUMBER ;
      l_category_set_id    NUMBER := p_category_set_id;
      l_inv_org_id         NUMBER := p_organization_id;
      l_inv_item_id        NUMBER;
      l_count1             NUMBER := 1;
      l_err_code             VARCHAR2(1);
      l_err_msg           VARCHAR2(200); -- Error message for parameter input errors


      CURSOR cat_id(pl_category_set_id  NUMBER,
                    pl_inv_org_id       NUMBER) IS
         SELECT  CATEGORY_ID
           FROM  MTL_ITEM_CATEGORIES
          WHERE  CATEGORY_SET_ID    =  pl_category_set_id
            AND  ORGANIZATION_ID    =  pl_inv_org_id;

   BEGIN

    OPEN   cat_id(l_category_set_id,
                  l_inv_org_id);

      WHILE  l_count1  = 1  LOOP  -- loop for cat id
         FETCH  cat_id  INTO  l_category_id;
         IF   cat_id%FOUND THEN

            Increm_Inv_Item_Refresh(
               x_err_msg          => l_err_msg
              , x_err_code         => l_err_code
              , p_category_set_id  => l_category_set_id
              , p_organization_id  => l_inv_org_id
              , p_category_id      => l_category_id
              );


         ELSE  -- else for cat id if
            l_count1  := 0;  -- first loop stops at this stage.
         END IF;
      END LOOP; -- end loop for cat id
    CLOSE cat_id;


    IF SQL%NOTFOUND THEN
         l_rows_updated :=  0 ;
         x_err_code     := '0';
    ELSE
         COMMIT;
         l_rows_updated := SQL%ROWCOUNT;
         x_err_code     := '0';
    END IF;


     IF G_DEBUG = 'Y' THEN
      asl_summ_load_glbl_pkg.Write_Log(
                p_table       => 'ASL_INVENTORY_ITEM_DENORM'
            , p_action      => 'U'
            , p_procedure   => 'Increm_Cat_Inv_Item_Refresh'
            , p_num_rows    => l_rows_updated
          ) ;
     END IF;


   EXCEPTION
     WHEN OTHERS THEN
      x_err_msg  :=  'Increm_Cat_Inv_Item_Refresh:  ' || SUBSTR(SQLERRM,1,150);
      x_err_code :=  '2';

    IF G_DEBUG = 'Y' THEN
     asl_summ_load_glbl_pkg.Write_Log(
                p_table     => 'ASL_INVENTORY_ITEM_DENORM'
                , p_action    => 'E'
                , p_procedure => 'Increm_Cat_Inv_Item_Refresh'
                , p_load_mode => 'U'
                , p_message   => x_err_msg
      );
    END IF;



 END  Increm_Cat_Inv_Item_Refresh;

 PROCEDURE Complete_Inv_Pricing_Refresh(
          x_err_msg          OUT NOCOPY VARCHAR2
         , x_err_code         OUT NOCOPY VARCHAR2
         , p_category_set_id  IN  NUMBER
         , p_organization_id  IN  NUMBER
         , p_category_id      IN  NUMBER
        ) IS



  l_inv_org_id         NUMBER  := p_organization_id;
  l_category_set_id    NUMBER  := p_category_set_id;
  l_category_id        NUMBER  := p_category_id;
  l_rows_inserted        NUMBER  := 0;

  l_currency_code      VARCHAR2(4);
  l_list_header_id     NUMBER;
  l_inventory_item_id  NUMBER;



  CURSOR list_hdr_id(p_currency_code VARCHAR2) IS
    SELECT QH.LIST_HEADER_ID
    FROM QP_LIST_HEADERS_B QH
    WHERE QH.LIST_TYPE_CODE =  'PRL'
    AND   nvl(QH.start_date_active, SYSDATE) <=   SYSDATE
    AND   nvl(QH.end_date_active, SYSDATE) >= SYSDATE
    AND   QH.mobile_download = 'Y'
    AND   QH.ACTIVE_FLAG = 'Y'
    AND   QH.currency_code = p_currency_code;

  CURSOR invt_item_id(p_inv_org_id NUMBER, p_category_set_id NUMBER, p_category_id NUMBER) IS
    SELECT INVENTORY_ITEM_ID
    FROM ASL_INVENTORY_ITEM_DENORM ITEM
    WHERE  ITEM.CATEGORY_SET_ID = p_category_set_id
    AND   ITEM.CATEGORY_ID = p_category_id
    AND   ITEM.ORGANIZATION_ID = p_inv_org_id
    AND   ITEM.LANGUAGE_CODE = USERENV ( 'LANG' );


BEGIN
  /*
  04-April-2005 SEBHAT. Refer Bug: 4266517
  Disabling the population of ASL_INVENTORY_PRICING table as this is currently
  not being used for downloading summarised information to Sales Offline(ASL)
  */

  NULL;

  /*
   SELECT FND_PROFILE.value('JTF_PROFILE_DEFAULT_CURRENCY')
        INTO l_currency_code
        FROM DUAL;

   IF  l_category_id IS  NULL THEN

      -- We should add the logic for only downloading the mobile flag. and list_type_code = PRL.
            INSERT INTO ASL_INVENTORY_PRICING
             (LIST_HEADER_ID
             ,LIST_LINE_ID
             ,LIST_LINE_TYPE_CODE
             ,INVENTORY_ITEM_ID
             ,ORGANIZATION_ID
             ,AUTOMATIC_FLAG
             ,LIST_PRICE
             ,LIST_PRICE_UOM_CODE
             ,PRIMARY_UOM_FLAG
             ,LIST_LINE_NO
             ,LAST_UPDATE_DATE
             ,CREATION_DATE
             ,LANGUAGE_CODE
             ,CURRENCY_CODE
             )
             SELECT *//*+ ORDERED use_nl(QPA QL)
                          index(QPA QP_PRICING_ATTRIBUTES_N5)
                          index(QL QP_LIST_LINES_PK)
                          index(ITEM ASL_INVENTORY_ITEM_DENORM_N1)*/
                      /*distinct QH.LIST_HEADER_ID,
                      QL.list_line_id,
                      QL.list_line_type_code,
                      ITEM.inventory_item_id,
                      l_inv_org_id,
                      QL.AUTOMATIC_FLAG  ,
                      DECODE(QL.OPERAND, NULL, QL.LIST_PRICE,  QL.OPERAND),
                      QL.LIST_PRICE_UOM_CODE  ,
                      QL.PRIMARY_UOM_FLAG  ,
                      QL.LIST_LINE_NO  ,
                      SYSDATE,
                      SYSDATE,
                      USERENV ( 'LANG' ),
                      l_currency_code
                FROM  QP_PRICING_ATTRIBUTES QPA,
                      QP_LIST_LINES QL,
                      ASL_INVENTORY_ITEM_DENORM ITEM ,
                      QP_LIST_HEADERS_B QH
                WHERE QPA.LIST_HEADER_ID = QH.LIST_HEADER_ID
                AND  QH.LIST_TYPE_CODE =  'PRL'
                AND   nvl(QH.start_date_active, SYSDATE) <=   SYSDATE
                AND   nvl(QH.end_date_active, SYSDATE) >= SYSDATE
        AND   QH.mobile_download = 'Y'
                AND   QH.ACTIVE_FLAG = 'Y'
                AND   QH.currency_code = l_currency_code
             --   AND   QPA.PRICING_PHASE_ID = 1
                AND   QPA.product_attribute_context =   'ITEM'
                AND   QPA.product_attribute = 'PRICING_ATTRIBUTE1'
                AND   to_char(ITEM.inventory_item_id) = QPA.PRODUCT_ATTR_VALUE
             --   AND   QPA.QUALIFICATION_IND IN (4, 6)
                AND   QPA.excluder_flag = 'N'
                AND   QPA.LIST_LINE_ID = QL.LIST_LINE_ID
                AND   QL.LIST_LINE_TYPE_CODE = 'PLL'
                AND   QL.ARITHMETIC_OPERATOR = 'UNIT_PRICE'
                AND   ITEM.CATEGORY_SET_ID = l_category_set_id
                AND   ITEM.ORGANIZATION_ID = l_inv_org_id
                AND   ITEM.LANGUAGE_CODE = USERENV ( 'LANG' );

   ELSE   -- when l_category_id is passed by user

      -- Get all the list_header_ids and loop
      FOR r_list_hdr_id IN list_hdr_id(l_currency_code) LOOP

          l_list_header_id := r_list_hdr_id.LIST_HEADER_ID;
          -- DBMS_OUTPUT.PUT_LINE( ' HEADER ID ' || l_list_header_id );

          FOR r_invt_item_id IN invt_item_id(l_inv_org_id, l_category_set_id, l_category_id) LOOP
                l_inventory_item_id := r_invt_item_id.INVENTORY_ITEM_ID;


             INSERT INTO ASL_INVENTORY_PRICING
             (LIST_HEADER_ID
             ,LIST_LINE_ID
             ,LIST_LINE_TYPE_CODE
             ,INVENTORY_ITEM_ID
             ,ORGANIZATION_ID
             ,AUTOMATIC_FLAG
             ,LIST_PRICE
             ,LIST_PRICE_UOM_CODE
             ,PRIMARY_UOM_FLAG
             ,LIST_LINE_NO
             ,LAST_UPDATE_DATE
             ,CREATION_DATE
             ,LANGUAGE_CODE
             ,CURRENCY_CODE
             ) SELECT*/ /*+ ORDERED use_nl(QPA QL)
                          index(QPA QP_PRICING_ATTRIBUTES_N5)
                          index(QL QP_LIST_LINES_PK)*/
                      /*l_list_header_id,
                      QL.list_line_id,
                      QL.list_line_type_code,
                      l_inventory_item_id,
                      l_inv_org_id,
                      QL.AUTOMATIC_FLAG  ,
                      DECODE(QL.OPERAND, NULL, QL.LIST_PRICE,  QL.OPERAND),
                      QL.LIST_PRICE_UOM_CODE  ,
                      QL.PRIMARY_UOM_FLAG  ,
                      QL.LIST_LINE_NO  ,
                      SYSDATE,
                      SYSDATE,
                      USERENV ( 'LANG' ),
                      l_currency_code
                FROM  QP_PRICING_ATTRIBUTES QPA,
                      QP_LIST_LINES QL
                WHERE QPA.LIST_HEADER_ID = l_list_header_id
              --  AND   QPA.PRICING_PHASE_ID = 1
                AND   QPA.product_attribute_context =   'ITEM'
                AND   QPA.product_attribute = 'PRICING_ATTRIBUTE1'
                AND   QPA.PRODUCT_ATTR_VALUE = to_char(l_inventory_item_id)
              --  AND   QPA.QUALIFICATION_IND IN (4, 6)
                AND   QPA.excluder_flag = 'N'
                AND   QPA.LIST_LINE_ID = QL.LIST_LINE_ID
                AND   QL.LIST_LINE_TYPE_CODE = 'PLL'
                AND   QL.ARITHMETIC_OPERATOR = 'UNIT_PRICE' ;

          END LOOP;  -- inv item id loop ends
      END LOOP;  -- header id loop ends



   END IF;


     IF SQL%NOTFOUND THEN
        x_err_msg := 'Complete_Inv_Pricing_Refresh' || SUBSTR(SQLERRM,1,150);
        x_err_code := '0';
    ELSE
        COMMIT;
        l_rows_inserted := SQL%ROWCOUNT;
        x_err_code := '0';
    END IF;
    IF G_DEBUG = 'Y' THEN
         asl_summ_load_glbl_pkg.Write_Log(
                p_table     => 'ASL_INVENTORY_PRICING'
            , p_action    => 'I'
            , p_procedure => 'Complete_Inv_Pricing_Refresh'
            , p_num_rows  => l_rows_inserted
          );
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      x_err_msg  :=  'Complete_Inv_Pricing_Refresh:  ' || SUBSTR(SQLERRM,1,150);
      x_err_code :=  '2';

    IF G_DEBUG = 'Y' THEN
      asl_summ_load_glbl_pkg.Write_Log(
            p_table     => 'ASL_INVENTORY_PRICING'
            , p_action    => 'E'
            , p_procedure => 'Complete_Inv_Pricing_Refresh'
            , p_load_mode => 'I'
            , p_message   => x_err_msg
      );
    END IF;
    04-April-2005 SEBHAT. Refer Bug: 4266517
   */
  END Complete_Inv_Pricing_Refresh;

  PROCEDURE Increm_Inv_Pricing_Refresh(
          x_err_msg          OUT NOCOPY VARCHAR2
         , x_err_code         OUT NOCOPY VARCHAR2
         , p_category_set_id  IN  NUMBER
         , p_organization_id  IN  NUMBER
         , p_category_id      IN  NUMBER
        ) IS

  l_inv_org_id         NUMBER  := p_organization_id;
  l_category_set_id    NUMBER  := p_category_set_id;
  l_category_id        NUMBER  := p_category_id;
  l_rows_updated         NUMBER  := 0;

  l_currency_code      VARCHAR2(4);
  l_list_header_id     NUMBER;
  l_inventory_item_id  NUMBER;



  CURSOR list_hdr_id(p_currency_code VARCHAR2) IS
    SELECT QH.LIST_HEADER_ID
    FROM QP_LIST_HEADERS_B QH
    WHERE QH.LIST_TYPE_CODE =  'PRL'
    AND   nvl(QH.start_date_active, SYSDATE) <=   SYSDATE
    AND   nvl(QH.end_date_active, SYSDATE) >= SYSDATE
    AND   QH.mobile_download = 'Y'
    AND   QH.ACTIVE_FLAG = 'Y'
    AND   QH.currency_code = p_currency_code;

  CURSOR invt_item_id(p_inv_org_id NUMBER, p_category_set_id NUMBER, p_category_id NUMBER) IS
    SELECT INVENTORY_ITEM_ID
    FROM ASL_INVENTORY_ITEM_DENORM ITEM
    WHERE  ITEM.CATEGORY_SET_ID = p_category_set_id
    AND   ITEM.CATEGORY_ID = p_category_id
    AND   ITEM.ORGANIZATION_ID = p_inv_org_id
    AND   ITEM.LANGUAGE_CODE = USERENV ( 'LANG' );

 BEGIN
     /* 11-AUG-2005 SEBHAT. Refer Bug: 4282256
        Disabling the population of ASL_INVENTORY_PRICING table in the
        Incremental Refresh as done for Complete Refresh for Bug: 4266517
     */

    NULL;

    /*
      SELECT FND_PROFILE.value('JTF_PROFILE_DEFAULT_CURRENCY')
         INTO l_currency_code
         FROM DUAL;


      -- Get all the list_header_ids and loop
      FOR r_list_hdr_id IN list_hdr_id(l_currency_code) LOOP

          l_list_header_id := r_list_hdr_id.LIST_HEADER_ID;


          FOR r_invt_item_id IN invt_item_id(l_inv_org_id, l_category_set_id, l_category_id) LOOP
              l_inventory_item_id := r_invt_item_id.INVENTORY_ITEM_ID;




              -- update records if they exist already

              UPDATE ASL_INVENTORY_PRICING  aip
                  SET (LIST_LINE_ID
                      ,LIST_LINE_TYPE_CODE
                      ,AUTOMATIC_FLAG
                      ,LIST_PRICE
                      ,LIST_PRICE_UOM_CODE
                      ,PRIMARY_UOM_FLAG
                      ,LIST_LINE_NO
                      ,LAST_UPDATE_DATE
                      ,LANGUAGE_CODE  ) =
                  ( SELECT + ORDERED use_nl(QPA QL)
                          index(QPA QP_PRICING_ATTRIBUTES_N5)
                          index(QL QP_LIST_LINES_PK)
                        QL.list_line_id,
                        QL.list_line_type_code,
                        QL.AUTOMATIC_FLAG  ,
                        DECODE(QL.OPERAND, NULL, QL.LIST_PRICE,  QL.OPERAND),
                        QL.LIST_PRICE_UOM_CODE  ,
                        QL.PRIMARY_UOM_FLAG  ,
                        QL.LIST_LINE_NO  ,
                        SYSDATE,
                        USERENV ( 'LANG' )
                     FROM  QP_PRICING_ATTRIBUTES QPA,
                           QP_LIST_LINES QL
                     WHERE QPA.LIST_HEADER_ID = l_list_header_id
                    -- AND   QPA.PRICING_PHASE_ID = 1
                     AND   QPA.product_attribute_context =   'ITEM'
                     AND   QPA.product_attribute = 'PRICING_ATTRIBUTE1'
                     AND   QPA.PRODUCT_ATTR_VALUE = to_char(l_inventory_item_id)
                    -- AND   QPA.QUALIFICATION_IND IN (4, 6)
                     AND   QPA.excluder_flag = 'N'
                     AND   QPA.LIST_LINE_ID = QL.LIST_LINE_ID
                     AND   QL.LIST_LINE_TYPE_CODE = 'PLL'
                     AND   QL.ARITHMETIC_OPERATOR = 'UNIT_PRICE' )
               WHERE aip.LIST_HEADER_ID    = l_list_header_id
                 AND aip.INVENTORY_ITEM_ID = l_inventory_item_id
                 AND aip.ORGANIZATION_ID   = l_inv_org_id
                 AND aip.CURRENCY_CODE     = l_currency_code
                 AND EXISTS (SELECT 1
                              FROM  QP_PRICING_ATTRIBUTES QPA,
                                    QP_LIST_LINES QL
                              WHERE QPA.LIST_HEADER_ID = l_list_header_id
                            --  AND   QPA.PRICING_PHASE_ID = 1
                              AND   QPA.product_attribute_context =   'ITEM'
                              AND   QPA.product_attribute = 'PRICING_ATTRIBUTE1'
                              AND   QPA.PRODUCT_ATTR_VALUE = to_char(l_inventory_item_id)
                            --  AND   QPA.QUALIFICATION_IND IN (4, 6)
                              AND   QPA.excluder_flag = 'N'
                              AND   QPA.LIST_LINE_ID = QL.LIST_LINE_ID
                              AND   QL.LIST_LINE_TYPE_CODE = 'PLL'
                              AND   QL.ARITHMETIC_OPERATOR = 'UNIT_PRICE' );

              -- If records do not exist Insert the same
               INSERT INTO ASL_INVENTORY_PRICING
                  (LIST_HEADER_ID
                  ,LIST_LINE_ID
                  ,LIST_LINE_TYPE_CODE
                  ,INVENTORY_ITEM_ID
                  ,ORGANIZATION_ID
                  ,AUTOMATIC_FLAG
                  ,LIST_PRICE
                  ,LIST_PRICE_UOM_CODE
                  ,PRIMARY_UOM_FLAG
                  ,LIST_LINE_NO
                  ,LAST_UPDATE_DATE
                  ,CREATION_DATE
                  ,LANGUAGE_CODE
                  ,CURRENCY_CODE
                  ) SELECT + ORDERED use_nl(QPA QL)
                          index(QPA QP_PRICING_ATTRIBUTES_N5)
                          index(QL QP_LIST_LINES_PK)
                        l_list_header_id,
                        QL.list_line_id,
                        QL.list_line_type_code,
                        l_inventory_item_id,
                        l_inv_org_id,
                        QL.AUTOMATIC_FLAG  ,
                        DECODE(QL.OPERAND, NULL, QL.LIST_PRICE,  QL.OPERAND),
                        QL.LIST_PRICE_UOM_CODE  ,
                        QL.PRIMARY_UOM_FLAG  ,
                        QL.LIST_LINE_NO  ,
                        SYSDATE,
                        SYSDATE,
                        USERENV ( 'LANG' ),
                        l_currency_code
                     FROM  QP_PRICING_ATTRIBUTES QPA,
                           QP_LIST_LINES QL
                     WHERE QPA.LIST_HEADER_ID = l_list_header_id
                    -- AND   QPA.PRICING_PHASE_ID = 1
                     AND   QPA.product_attribute_context =   'ITEM'
                     AND   QPA.product_attribute = 'PRICING_ATTRIBUTE1'
                     AND   QPA.PRODUCT_ATTR_VALUE = to_char(l_inventory_item_id)
                    -- AND   QPA.QUALIFICATION_IND IN (4, 6)
                     AND   QPA.excluder_flag = 'N'
                     AND   QPA.LIST_LINE_ID = QL.LIST_LINE_ID
                     AND   QL.LIST_LINE_TYPE_CODE = 'PLL'
                     AND   QL.ARITHMETIC_OPERATOR = 'UNIT_PRICE'
                     AND NOT EXISTS
                     (  SELECT 1
                           FROM ASL_INVENTORY_PRICING aip
                           WHERE aip.LIST_HEADER_ID = l_list_header_id
                              AND aip.INVENTORY_ITEM_ID = l_inventory_item_id
                              AND aip.ORGANIZATION_ID = l_inv_org_id
                              AND aip.CURRENCY_CODE  = l_currency_code);


          END LOOP;  -- inv item id loop ends
      END LOOP;  -- header id loop ends

      IF SQL%NOTFOUND THEN
         l_rows_updated :=  0 ;
         x_err_code     := '0';
      ELSE
         COMMIT;
         l_rows_updated := SQL%ROWCOUNT;
         x_err_code     := '0';
      END IF;


      IF G_DEBUG = 'Y' THEN
         asl_summ_load_glbl_pkg.Write_Log(
                p_table       => 'ASL_INVENTORY_PRICING'
            , p_action      => 'U'
            , p_procedure   => 'Increm_Inv_Pricing_Refresh'
            , p_num_rows    => l_rows_updated
           ) ;
      END IF;


      EXCEPTION
         WHEN OTHERS THEN
            x_err_msg  :=  'Increm_Inv_Pricing_Refresh:  ' || SUBSTR(SQLERRM,1,150);
            x_err_code :=  '2';

      IF G_DEBUG = 'Y' THEN
          asl_summ_load_glbl_pkg.Write_Log(
                p_table     => 'ASL_INVENTORY_PRICING'
                , p_action    => 'E'
                , p_procedure => 'Increm_Inv_Pricing_Refresh'
                , p_load_mode => 'U'
                , p_message   => x_err_msg
         );
      END IF;
      */
  END  Increm_Inv_Pricing_Refresh;

  PROCEDURE Increm_Cat_Inv_Price_Refresh(
        x_err_msg          OUT NOCOPY VARCHAR2
       , x_err_code         OUT NOCOPY VARCHAR2
       , p_category_set_id  IN  NUMBER
       , p_organization_id  IN  NUMBER
       ) IS

      l_rows_updated       NUMBER := 0;
      l_upd_date           DATE   := TRUNC(sysdate);
      l_category_id        NUMBER ;
      l_category_set_id    NUMBER := p_category_set_id;
      l_inv_org_id         NUMBER := p_organization_id;
      l_inv_item_id        NUMBER;
      l_err_code             VARCHAR2(1);
      l_err_msg           VARCHAR2(200); -- Error message for parameter input errors


      CURSOR cat_id(pl_category_set_id  NUMBER,
                    pl_inv_org_id       NUMBER) IS
         SELECT distinct CATEGORY_ID
           FROM  ASL_INVENTORY_ITEM_DENORM ITEM
          WHERE  ITEM.CATEGORY_SET_ID = pl_category_set_id
           AND   ITEM.ORGANIZATION_ID = pl_inv_org_id
           AND   ITEM.LANGUAGE_CODE   = USERENV ( 'LANG' );



   BEGIN

     FOR r_cat_id IN cat_id( l_category_set_id, l_inv_org_id) LOOP
                l_category_id := r_cat_id.CATEGORY_ID;



            Increm_Inv_Pricing_Refresh(
               x_err_msg          => l_err_msg
              , x_err_code         => l_err_code
              , p_category_set_id  => l_category_set_id
              , p_organization_id  => l_inv_org_id
              , p_category_id      => l_category_id
              );

      END LOOP; -- end loop for cat id



      IF SQL%NOTFOUND THEN
         l_rows_updated :=  0 ;
         x_err_code     := '0';
      ELSE
         COMMIT;
         l_rows_updated := SQL%ROWCOUNT;
         x_err_code     := '0';
      END IF;


      IF G_DEBUG = 'Y' THEN
        asl_summ_load_glbl_pkg.Write_Log(
                p_table       => 'ASL_INVENTORY_PRICING'
            , p_action      => 'U'
            , p_procedure   => 'Increm_Cat_Inv_Price_Refresh'
            , p_num_rows    => l_rows_updated
          ) ;
      END IF;


      EXCEPTION
         WHEN OTHERS THEN
         x_err_msg  :=  'Increm_Cat_Inv_Price_Refresh:  ' || SUBSTR(SQLERRM,1,150);
         x_err_code :=  '2';

      IF G_DEBUG = 'Y' THEN
          asl_summ_load_glbl_pkg.Write_Log(
                p_table     => 'ASL_INVENTORY_PRICING'
                , p_action    => 'E'
                , p_procedure => 'Increm_Cat_Inv_Price_Refresh'
                , p_load_mode => 'U'
                , p_message   => x_err_msg
         );
      END IF;



 END  Increm_Cat_Inv_Price_Refresh;



END ASL_INV_ITEM_SUMM_PUB;

/
