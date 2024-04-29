--------------------------------------------------------
--  DDL for Package Body CSE_ASSET_ADJUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_ASSET_ADJUST_PKG" AS
-- $Header: CSEFADJB.pls 120.1 2005/06/13 11:28:25 appldev  $

PROCEDURE process_adjustment_trans(
 x_return_code            OUT NOCOPY VARCHAR2
,x_err_buffer             OUT NOCOPY VARCHAR2
,p_inv_org_id               IN NUMBER
,p_inventory_item_id        IN NUMBER
, p_conc_request_id         IN NUMBER )
IS
BEGIN
 NULL ;
END process_adjustment_trans ;


PROCEDURE retire_asset (
 p_ret_asset_rec             IN   cse_datastructures_pub.asset_query_rec
,p_ret_dist_tbl              IN   cse_datastructures_pub.distribution_tbl
,p_transaction_id            IN   NUMBER
,x_return_status             OUT NOCOPY  VARCHAR2
,x_error_msg                 OUT NOCOPY  VARCHAR2)
IS

BEGIN
 NULL ;
END retire_asset ;



PROCEDURE insert_retirement (
  p_ext_ret_rec           IN OUT NOCOPY fa_mass_ext_retirements%ROWTYPE
, x_return_status         OUT NOCOPY    VARCHAR2
, x_error_msg             OUT NOCOPY    VARCHAR2)
IS
l_api_name    VARCHAR2(100) := 'CSE_ASSET_ADJUST_PKG.insert_retirement' ;

BEGIN
  cse_util_pkg.write_log('Begin --Insert Retirements ');
INSERT INTO fa_mass_ext_retirements (
 BATCH_NAME ,
 MASS_EXTERNAL_RETIRE_ID ,
 RETIREMENT_ID          ,
 BOOK_TYPE_CODE        ,
 REVIEW_STATUS        ,
 ASSET_ID            ,
 DISTRIBUTION_ID     ,
 TRANSACTION_NAME   ,
 DATE_RETIRED      ,
 DATE_EFFECTIVE   ,
 COST_RETIRED    ,
 RETIREMENT_PRORATE_CONVENTION ,
 UNITS ,
 PERCENTAGE  ,
 COST_OF_REMOVAL  ,
 PROCEEDS_OF_SALE  ,
 RETIREMENT_TYPE_CODE  ,
 REFERENCE_NUM  ,
 SOLD_TO        ,
 TRADE_IN_ASSET_ID  ,
 CALC_GAIN_LOSS_FLAG,
 STL_METHOD_CODE     ,
 STL_LIFE_IN_MONTHS  ,
 STL_DEPRN_AMOUNT   ,
 CREATED_BY        ,
 CREATION_DATE    ,
 LAST_UPDATED_BY ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN )
VALUES
(p_ext_ret_rec.BATCH_NAME ,
p_ext_ret_rec.MASS_EXTERNAL_RETIRE_ID ,
p_ext_ret_rec.RETIREMENT_ID          ,
p_ext_ret_rec.BOOK_TYPE_CODE        ,
p_ext_ret_rec.REVIEW_STATUS        ,
p_ext_ret_rec.ASSET_ID            ,
p_ext_ret_rec.DISTRIBUTION_ID    ,
p_ext_ret_rec.TRANSACTION_NAME   ,
p_ext_ret_rec.DATE_RETIRED      ,
p_ext_ret_rec.DATE_EFFECTIVE   ,
p_ext_ret_rec.COST_RETIRED    ,
p_ext_ret_rec.RETIREMENT_PRORATE_CONVENTION ,
p_ext_ret_rec.UNITS ,
p_ext_ret_rec.PERCENTAGE  ,
p_ext_ret_rec.COST_OF_REMOVAL  ,
p_ext_ret_rec.PROCEEDS_OF_SALE  ,
p_ext_ret_rec.RETIREMENT_TYPE_CODE  ,
p_ext_ret_rec.REFERENCE_NUM  ,
p_ext_ret_rec.SOLD_TO        ,
p_ext_ret_rec.TRADE_IN_ASSET_ID  ,
p_ext_ret_rec.CALC_GAIN_LOSS_FLAG,
p_ext_ret_rec.STL_METHOD_CODE     ,
p_ext_ret_rec.STL_LIFE_IN_MONTHS  ,
p_ext_ret_rec.STL_DEPRN_AMOUNT   ,
p_ext_ret_rec.CREATED_BY        ,
p_ext_ret_rec.CREATION_DATE    ,
p_ext_ret_rec.LAST_UPDATED_BY ,
p_ext_ret_rec.LAST_UPDATE_DATE ,
p_ext_ret_rec.LAST_UPDATE_LOGIN ) ;

EXCEPTION
WHEN OTHERS
THEN
   x_return_status := fnd_api.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
   fnd_message.set_token('API_NAME',l_api_name);
   fnd_message.set_token('SQL_ERROR',SQLERRM);
   x_error_msg := fnd_message.get;

END insert_retirement ;



PROCEDURE create_inv_rets(p_asset_id IN NUMBER,
             p_mass_ext_retire_id    IN NUMBER,
             p_mtl_cost              IN OUT NOCOPY NUMBER,
             p_non_mtl_cost          IN OUT NOCOPY NUMBER,
             x_return_status         OUT NOCOPY VARCHAR2,
             x_error_msg             OUT NOCOPY VARCHAR2)
IS
l_api_name   VARCHAR2(100) := 'CSE_ASSET_ADJUST_PKG.create_inv_rets';
l_cost       NUMBER ;
CURSOR mtl_src_lines_cur IS
SELECT source_line_id
     , fixed_assets_cost cost
FROM   fa_asset_invoices
WHERE  SIGN(fixed_assets_cost) = SIGN(p_mtl_cost)
AND    NVL(attribute15,'N') = 'Y'
AND    date_ineffective IS NULL
AND    asset_id = p_asset_id ;


CURSOR non_mtl_src_lines_cur IS
SELECT source_line_id
     , fixed_assets_cost cost
FROM   fa_asset_invoices
WHERE  SIGN(fixed_assets_cost) = SIGN(p_mtl_cost)
AND    NVL(attribute15,'N') <> 'Y'
AND    date_ineffective IS NULL
AND    asset_id = p_asset_id ;

BEGIN
   FOR mtl_src_lines_rec IN mtl_src_lines_cur
   LOOP
      IF ABS(mtl_src_lines_rec.cost) < ABS(p_mtl_cost)
      THEN
         l_cost := mtl_src_lines_rec.cost ;
      ELSE
         l_cost := p_mtl_cost ;
      END IF ;
      IF l_cost = 0
      THEN
         EXIT ;
      END IF ;
      INSERT INTO fa_ext_inv_retirements (
                mass_external_retire_id
              , source_line_id
              , cost_retired )
      VALUES ( p_mass_ext_retire_id
              , mtl_src_lines_rec.source_line_id
              , l_cost) ;
      p_mtl_cost := p_mtl_cost - l_cost ;
   END LOOP ;
   FOR non_mtl_src_lines_rec IN non_mtl_src_lines_cur
   LOOP
      IF ABS(non_mtl_src_lines_rec.cost) < ABS(p_non_mtl_cost)
      THEN
         l_cost := non_mtl_src_lines_rec.cost ;
      ELSE
         l_cost := p_non_mtl_cost ;
      END IF ;
      IF l_cost = 0
      THEN
         EXIT ;
      END IF ;
      INSERT INTO fa_ext_inv_retirements (
                mass_external_retire_id
              , source_line_id
              , cost_retired )
      VALUES ( p_mass_ext_retire_id
              , non_mtl_src_lines_rec.source_line_id
              , l_cost) ;
   END LOOP ;
EXCEPTION
WHEN OTHERS
THEN
   x_return_status := fnd_api.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
   fnd_message.set_token('API_NAME',l_api_name);
   fnd_message.set_token('SQL_ERROR',SQLERRM);
   x_error_msg := fnd_message.get;

END create_inv_rets ;


END CSE_ASSET_ADJUST_PKG ;

/
