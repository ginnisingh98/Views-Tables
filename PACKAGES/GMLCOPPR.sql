--------------------------------------------------------
--  DDL for Package GMLCOPPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMLCOPPR" AUTHID CURRENT_USER AS
/* $Header: GMLCPPRS.pls 115.1 2002/12/04 19:00:48 gmangari ship $ */
  PROCEDURE copy_list (   p_old_pricelist_id    IN OP_PRCE_MST.PRICELIST_ID%TYPE  ,
                          p_pricelist_code    IN OP_PRCE_MST.PRICELIST_CODE%TYPE,
                          p_pricelist_desc1   IN OP_PRCE_MST.PRICELIST_DESC1%TYPE,
                          p_pricesort_name    IN OP_PRCE_MST.PRICESORT_NAME%TYPE,
  		                    p_currency_code     IN OP_PRCE_MST.CURRENCY_CODE%TYPE ,
  					              p_comments          IN OP_PRCE_MST.COMMENTS%TYPE       ,
  					              p_price_change_type IN NUMBER                         ,
  					              p_price_change      IN NUMBER                         ,
  					              p_decimal           IN NUMBER                         ,
  					              p_copy_text         IN VARCHAR2 					            ,
  					              p_user_id           IN OP_PRCE_MST.CREATED_BY%TYPE    ,
  					              p_err_num           OUT NOCOPY NUMBER                        ,
                          p_err_msg           OUT NOCOPY VARCHAR2
                        ) ;

  PROCEDURE copy_contract(   p_old_contract_id   IN OP_CNTR_HDR.CONTRACT_ID%TYPE   ,
                              p_contract_no       IN OP_CNTR_HDR.CONTRACT_NO%TYPE   ,
                              p_contract_desc1    IN OP_CNTR_HDR.CONTRACT_DESC1%TYPE,
                              p_contract_desc2    IN OP_CNTR_HDR.CONTRACT_DESC2%TYPE,
  					                  p_comments          IN OP_CNTR_HDR.COMMENTS%TYPE      ,
  		                        p_contract_currency IN OP_CNTR_HDR.CONTRACT_CURRENCY%TYPE ,
  		                        p_exchange_rate     IN OP_CNTR_HDR.EXCHANGE_RATE%TYPE ,
  		                        p_mul_div_sign      IN OP_CNTR_HDR.MUL_DIV_SIGN%TYPE ,
  		                        p_presales_ord_id   IN OP_CNTR_HDR.PRESALES_ORD_ID%TYPE ,
  					                  p_price_change_type IN NUMBER                         ,
  					                  p_price_change      IN NUMBER                         ,
  					                  p_decimal           IN NUMBER                         ,
  					                  p_copy_text         IN VARCHAR2                       ,
        					            p_user_id           IN OP_CNTR_HDR.CREATED_BY%TYPE    ,
        					            p_err_num           OUT NOCOPY NUMBER                        ,
                              p_err_msg           OUT NOCOPY VARCHAR2
                           );

  PROCEDURE copy_charge(    p_old_charge_id     IN OP_CHRG_MST.CHARGE_ID%TYPE     ,
                            p_charge_code       IN OP_CHRG_MST.CHARGE_CODE%TYPE   ,
                            p_charge_desc       IN OP_CHRG_MST.CHARGE_DESC%TYPE   ,
                            p_charge_type       IN OP_CHRG_MST.CHARGE_TYPE%TYPE   ,
                            p_chgtax_class      IN OP_CHRG_MST.CHGTAX_CLASS%TYPE  ,
                            p_billable_ind      IN OP_CHRG_MST.BILLABLE_IND%TYPE  ,
                            p_currency_code     IN OP_CHRG_MST.CURRENCY_CODE%TYPE ,
					                  p_price_change_type IN NUMBER                         ,
					                  p_price_change      IN NUMBER                         ,
					                  p_decimal           IN NUMBER                         ,
					                  p_copy_text         IN VARCHAR2                       ,
      					            p_user_id           IN OP_CHRG_MST.CREATED_BY%TYPE    ,
      					            p_err_num           OUT NOCOPY NUMBER                        ,
                            p_err_msg           OUT NOCOPY VARCHAR2
                       ) ;

  PROCEDURE copy_effectivity( p_old_priceff_id    IN OP_PRCE_EFF.PRICEFF_ID%TYPE      ,
                              p_list_id           IN OP_PRCE_EFF.PRICELIST_ID%TYPE    ,
                              p_new_start_date    IN OP_PRCE_EFF.START_DATE%TYPE      ,
                              p_new_end_date      IN OP_PRCE_EFF.END_DATE%TYPE        ,
  		                        p_new_preference    IN OP_PRCE_EFF.PREFERENCE%TYPE      ,
         					            p_copy_text         IN VARCHAR2                         ,
        					            p_user_id           IN OP_PRCE_EFF.CREATED_BY%TYPE      ,
        					            p_err_num           OUT NOCOPY NUMBER                          ,
                              p_err_msg           OUT NOCOPY VARCHAR2
  					                  );

  PROCEDURE copy_charge_asc ( p_old_chargeitem_id IN OP_CHRG_ITM.CHARGEITEM_ID%TYPE ,
                              p_charge_id         IN OP_CHRG_ITM.CHARGE_ID%TYPE     ,
    					                p_copy_text         IN VARCHAR2                       ,
          					          p_user_id           IN OP_CHRG_MST.CREATED_BY%TYPE    ,
      	    				          p_err_num           OUT NOCOPY NUMBER                        ,
                              p_err_msg           OUT NOCOPY VARCHAR2
                            ) ;

  PROCEDURE copy_text_record(  p_old_text_code  IN OP_TEXT_HDR.TEXT_CODE%TYPE   ,
                               p_new_text_code  IN OP_TEXT_HDR.TEXT_CODE%TYPE   ,
                               p_user_id        IN OP_TEXT_HDR.CREATED_BY%TYPE
                             );

  FUNCTION create_pricelist_id RETURN NUMBER;

  FUNCTION create_price_id RETURN NUMBER;

  FUNCTION create_breaktype_id RETURN NUMBER;

  FUNCTION create_priceff_id RETURN NUMBER;

  FUNCTION create_contract_id RETURN NUMBER;

  FUNCTION create_charge_id RETURN NUMBER;

  FUNCTION create_chargeitem_id RETURN NUMBER;

  FUNCTION create_chargebreak_id RETURN NUMBER;

  FUNCTION create_text_code   RETURN NUMBER;

END;

 

/
