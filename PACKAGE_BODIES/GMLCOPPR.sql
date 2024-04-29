--------------------------------------------------------
--  DDL for Package Body GMLCOPPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMLCOPPR" AS
/* $Header: GMLCPPRB.pls 115.6 2002/12/04 18:57:36 gmangari ship $ */
/* Exceptions */
  e_orig_record_not_found  EXCEPTION ;
  e_invalid_decimal        EXCEPTION ;
  e_null_price_change      EXCEPTION ;

  /* Error Numbers and Messages */
  v_orig_record_not_found_eno  NUMBER        DEFAULT -30001;

  v_invalid_decimal_emsg        VARCHAR2(100) ;
  v_invalid_decimal_eno         NUMBER        DEFAULT -30002;

  v_null_price_change_eno       NUMBER        DEFAULT -30003;

 /*========================================================================+
 | NAME                                                                    |
 |    copy_list                                                            |
 | SYNOPSIS                                                                |
 |   Creates a copy of an existing pricelist.                              |
 | PARAMETERS                                                              |
 |   p_old_pricelist_id  IN Surrogate for Pricelist to be copied from.     |
 |   p_pricelist_code    IN New pricelist code. Null not allowed.          |
 |   p_pricelist_desc1   IN New pricelist desc.                            |
 |                          If null uses value from existing pricelist.    |
 |   p_pricesort_name    IN New pricesort name.                            |
 |                          If null uses value from existing pricelist.    |
 |   p_currency_code     IN New pricelist currency.                        |
 |                          If null uses value from existing pricelist.    |
 |   p_comments          IN New comments.                                  |
 |   p_price_change_type IN Price change type                              |
 |                         ( 1= percent change, 2= absolute change).       |
 |   p_price_change      IN Value for price change.                        |
 |                          Can not be null if type above is 1 or 2.       |
 |   p_decimal           IN Decimal for rounding changed price ( 0 to 6).  |
 |                          Can not be null if type above is 1 or 2.       |
 |   p_copy_text         IN Flag to include text in the copy ( Y/N)        |
 |   p_user_id           IN Applications user id.                          |
 |   p_err_num           OUT If positive, ID of new list;                  |
 |                           else error as described below.                |
 |   p_err_msg           OUT Error message.                                |
 | DESCRIPTION                                                             |
 |                                                                         |
 | ERROR Codes and messages                                                |
 |   Positive Number : ID of newly created record, no errors.              |
 |   Database errors                    : -1     to -30000                 |
 |   User defined :common to the package: -30001 to -30009                 |
 |   user defined: Procedure specific   : -30010 to -30019                 |
 +========================================================================*/
   PROCEDURE copy_list ( p_old_pricelist_id  IN OP_PRCE_MST.PRICELIST_ID%TYPE  ,
                         p_pricelist_code    IN OP_PRCE_MST.PRICELIST_CODE%TYPE,
                         p_pricelist_desc1   IN OP_PRCE_MST.PRICELIST_DESC1%TYPE,
                         p_pricesort_name    IN OP_PRCE_MST.PRICESORT_NAME%TYPE,
 		                     p_currency_code     IN OP_PRCE_MST.CURRENCY_CODE%TYPE ,
 				                 p_comments          IN OP_PRCE_MST.COMMENTS%TYPE      ,
 					               p_price_change_type IN NUMBER                         ,
 					               p_price_change      IN NUMBER                         ,
 					               p_decimal           IN NUMBER                         ,
 					               p_copy_text         IN VARCHAR2                       ,
 					               p_user_id           IN OP_PRCE_MST.CREATED_BY%TYPE    ,
					               p_err_num           OUT NOCOPY NUMBER                        ,
                         p_err_msg           OUT NOCOPY VARCHAR2
                      ) IS

	  /*Cursors */
    CURSOR Cur_prce_mst IS
      SELECT  *
      FROM    op_prce_mst
      WHERE   pricelist_id  = p_old_pricelist_id;

    CURSOR Cur_prce_itm IS
      SELECT  *
      FROM    op_prce_itm
      WHERE   pricelist_id  = p_old_pricelist_id;

    CURSOR Cur_prce_brk ( V_old_price_id  GML.OP_PRCE_BRK.PRICE_ID%TYPE) IS
      SELECT  *
      FROM    op_prce_brk
      WHERE   price_id  = V_old_price_id;

    /* Composites */
	  V_prce_mst           Cur_prce_mst%ROWTYPE         ;

    /* Scalars */
    X_pricelist_id       OP_PRCE_MST.PRICELIST_ID%TYPE;
    X_price_id           OP_PRCE_ITM.PRICE_ID%TYPE    ;
    X_breaktype_id       OP_PRCE_BRK.BREAKTYPE_ID%TYPE;
    X_prce_mst_text_code OP_PRCE_MST.TEXT_CODE%TYPE   ;
    X_prce_itm_text_code OP_PRCE_ITM.TEXT_CODE%TYPE   ;
    X_breakpoint_price   OP_PRCE_BRK.BREAKPOINT_PRICE%TYPE;
    X_base_price         OP_PRCE_ITM.BASE_PRICE%TYPE;
    BEGIN

      /* Initialize error number to zero */
      p_err_num := 0;

      IF P_price_change_type IN ( 1, 2) THEN
        IF( P_decimal < 0 ) THEN
           FND_MESSAGE.SET_NAME('GML', 'SO_E_DEC_PLACES');
           v_invalid_decimal_emsg := FND_MESSAGE.GET;
          RAISE e_invalid_decimal;
        END IF;
        IF( P_price_change IS NULL ) THEN
          RAISE e_null_price_change ;
        END IF;
      END IF;

      /* Fetch the price master record. */
      OPEN Cur_prce_mst;
	    FETCH Cur_prce_mst INTO v_prce_mst;

      /* If no rows found, then raise exception */
      IF ( Cur_prce_mst%NOTFOUND ) THEN
  	    CLOSE Cur_prce_mst ;
        RAISE e_orig_record_not_found;
      END IF;

	    CLOSE Cur_prce_mst ;

      /* Create a new pricelist id. */
      X_pricelist_id := create_pricelist_id;

      /* If text is to be copied, and the existing pricelist has text associated with it, */
	    /* then get a new text id for the text and copy the text. */
	    IF ( ( p_copy_text = 'Y') AND ( v_prce_mst.text_code IS NOT NULL)) THEN
	      X_prce_mst_text_code := create_text_code ;

	      /* Create the text record */
	      Copy_text_record( v_prce_mst.text_code, X_prce_mst_text_code, P_user_id );
      ELSE
	      X_prce_mst_text_code := NULL;
      END IF;


     /* Now write the OP_PRCE_MST record to the table. */
     /* When creating a new record, use the original reocrd's currency code  */
     /* if the currency code passed is null. */
     INSERT INTO OP_PRCE_MST
                    ( pricelist_id                     ,
                      pricelist_desc1                  ,
                      pricesort_name                   ,
                      comments                         ,
                      currency_code                    ,
                      creation_date                    ,
                      pricelist_code                   ,
                      last_update_date                 , last_updated_by  ,
                      created_by                       , last_update_login,
                      delete_mark                      , in_use           ,
                      text_code                        ,
                      attribute1                       , attribute2       ,
                      attribute3                       , attribute4       ,
                      attribute5                       , attribute6       ,
                      attribute7                       , attribute8       ,
                      attribute9                       , attribute10      ,
                      attribute11                      , attribute12      ,
                      attribute13                      , attribute14      ,
                      attribute15                      , attribute16      ,
                      attribute17                      , attribute18      ,
                      attribute19                      , attribute20      ,
                      attribute21                      , attribute22      ,
                      attribute23                      , attribute24      ,
                      attribute25                      , attribute26      ,
                      attribute27                      , attribute28      ,
                      attribute29                      , attribute30      ,
                      attribute_category
                    )
                    SELECT
                      X_pricelist_id                                           ,
                      NVL(P_pricelist_desc1, v_prce_mst.pricelist_desc1)       ,
                      NVL(P_pricesort_name , v_prce_mst.pricesort_name )       ,
                      P_comments                                               ,
                      NVL( P_currency_code, v_prce_mst.currency_code )         ,
                      sysdate                          , P_pricelist_code      ,
                      sysdate                          , P_user_id             ,
                      P_user_id                        , NULL                  ,
                      v_prce_mst.delete_mark           , 0                     ,
                      X_prce_mst_text_code             ,
                      v_prce_mst.attribute1            , v_prce_mst.attribute2 ,
                      v_prce_mst.attribute3            , v_prce_mst.attribute4 ,
                      v_prce_mst.attribute5            , v_prce_mst.attribute6 ,
                      v_prce_mst.attribute7            , v_prce_mst.attribute8 ,
                      v_prce_mst.attribute9            , v_prce_mst.attribute10,
                      v_prce_mst.attribute11           , v_prce_mst.attribute12,
                      v_prce_mst.attribute13           , v_prce_mst.attribute14,
                      v_prce_mst.attribute15           , v_prce_mst.attribute16,
                      v_prce_mst.attribute17           , v_prce_mst.attribute18,
                      v_prce_mst.attribute19           , v_prce_mst.attribute20,
                      v_prce_mst.attribute21           , v_prce_mst.attribute22,
                      v_prce_mst.attribute23           , v_prce_mst.attribute24,
                      v_prce_mst.attribute25           , v_prce_mst.attribute26,
                      v_prce_mst.attribute27           , v_prce_mst.attribute28,
                      v_prce_mst.attribute29           , v_prce_mst.attribute30,
                      v_prce_mst.attribute_category
                    FROM DUAL;

      /* Retrieve and Copy rows from op_prce_itm */
      FOR v_prce_itm IN cur_prce_itm LOOP

        /*Get a new surrogate id */
        X_price_id := create_price_id;

        /* If text is to be copied, and the existing pricelist has text associated with it, */
    	  /* then get a new text id for the text and copy the text. */
	      IF ( ( p_copy_text = 'Y') AND ( v_prce_itm.text_code IS NOT NULL)) THEN
	        X_prce_itm_text_code := create_text_code ;

  	      /* Create the text record */
	        Copy_text_record( v_prce_itm.text_code, X_prce_itm_text_code, P_user_id );
		    ELSE
		      X_prce_itm_text_code := NULL;
        END IF;

        /*  Calculate new base price based on the price change type and change. */
        IF p_price_change_type = 1 THEN
          X_base_price := ROUND( ( v_prce_itm.base_price * ( 1 + p_price_change/100)), P_decimal  ) ;
        ELSIF p_price_change_type = 2 THEN
          X_base_price := ROUND( (v_prce_itm.base_price + p_price_change), P_decimal )  ;
        ELSE
          X_base_price := v_prce_itm.base_price ;
        END IF ;

        /*  Base price can not be negative */
        IF X_base_price < 0 THEN
          X_base_price := 0;
        END IF;

        /*  Now insert a new row in OP_PRCE_ITM */
        INSERT INTO OP_PRCE_ITM
                    ( base_price                       , pricelist_id     ,
                      price_id                         , price_type       ,
                      break_type                       , creation_date    ,
                      last_update_date                 , last_updated_by  ,
                      created_by                       , last_update_login,
                      price_class                      ,
                      delete_mark                      , trans_cnt        ,
                      text_code                        , item_id          ,
                      whse_code                        , qc_grade         ,
                      price_um                         , frtbill_mthd     ,
                      line_no                          ,
                      attribute1                       , attribute2       ,
                      attribute3                       , attribute4       ,
                      attribute5                       , attribute6       ,
                      attribute7                       , attribute8       ,
                      attribute9                       , attribute10      ,
                      attribute11                      , attribute12      ,
                      attribute13                      , attribute14      ,
                      attribute15                      , attribute16      ,
                      attribute17                      , attribute18      ,
                      attribute19                      , attribute20      ,
                      attribute21                      , attribute22      ,
                      attribute23                      , attribute24      ,
                      attribute25                      , attribute26      ,
                      attribute27                      , attribute28      ,
                      attribute29                      , attribute30      ,
                      attribute_category
                    )
                    SELECT
                      X_base_price                     , X_pricelist_id        ,
                      X_price_id                       , v_prce_itm.price_type ,
                      v_prce_itm.break_type            , SYSDATE               ,
                      SYSDATE                          , P_user_id             ,
                      P_user_id                        , NULL   ,
                      v_prce_itm.price_class           ,
                      v_prce_itm.delete_mark           , 0 ,
                      X_prce_itm_text_code             , v_prce_itm.item_id     ,
                      v_prce_itm.whse_code             , v_prce_itm.qc_grade    ,
                      v_prce_itm.price_um              , v_prce_itm.frtbill_mthd,
                      v_prce_itm.line_no               ,
                      v_prce_itm.attribute1            , v_prce_itm.attribute2  ,
                      v_prce_itm.attribute3            , v_prce_itm.attribute4  ,
                      v_prce_itm.attribute5            , v_prce_itm.attribute6  ,
                      v_prce_itm.attribute7            , v_prce_itm.attribute8  ,
                      v_prce_itm.attribute9            , v_prce_itm.attribute10 ,
                      v_prce_itm.attribute11           , v_prce_itm.attribute12 ,
                      v_prce_itm.attribute13           , v_prce_itm.attribute14 ,
                      v_prce_itm.attribute15           , v_prce_itm.attribute16 ,
                      v_prce_itm.attribute17           , v_prce_itm.attribute18 ,
                      v_prce_itm.attribute19           , v_prce_itm.attribute20 ,
                      v_prce_itm.attribute21           , v_prce_itm.attribute22 ,
                      v_prce_itm.attribute23           , v_prce_itm.attribute24 ,
                      v_prce_itm.attribute25           , v_prce_itm.attribute26 ,
                      v_prce_itm.attribute27           , v_prce_itm.attribute28 ,
                      v_prce_itm.attribute29           , v_prce_itm.attribute30 ,
                      v_prce_itm.attribute_category
                     FROM DUAL ;

          /*  Now insert corresponding break rows into OP_PRCE_BRK */
          FOR v_prce_brk IN cur_prce_brk(v_prce_itm.price_id) LOOP
            X_breaktype_id := create_breaktype_id;

          /*  Calculate new break price based on the price change type and change. */
          IF p_price_change_type = 1 THEN
            X_breakpoint_price := ROUND ( ( v_prce_brk.breakpoint_price * ( 1 + p_price_change/100 )), P_decimal ) ;
          ELSIF p_price_change_type = 2 THEN
            X_breakpoint_price := ROUND( (v_prce_brk.breakpoint_price + p_price_change), P_decimal )  ;
          ELSE
            X_breakpoint_price := v_prce_brk.breakpoint_price ;
          END IF ;

          /*  Break price can not be negative */
          IF X_breakpoint_price < 0 THEN
            X_breakpoint_price := 0;
          END IF;

          INSERT INTO OP_PRCE_BRK
                  ( price_id                         , breakpoint_factor,
                    breakpoint_price                 , creation_date    ,
                    last_update_date                 , last_updated_by  ,
                    created_by                       , last_update_login,
                    delete_mark                      , trans_cnt        ,
                    breaktype_id                     , line_no          ,
                    qty_breakpoint                   , value_breakpoint
                  )
                  SELECT
                    X_price_id                       , v_prce_brk.breakpoint_factor,
                    X_breakpoint_price               , sysdate                     ,
                    sysdate                          , P_user_id                   ,
                    P_user_id                        , NULL         ,
                    v_prce_brk.delete_mark           , 0                           ,
                    X_breaktype_id                   , v_prce_brk.line_no          ,
                    v_prce_brk.qty_breakpoint        , v_prce_brk.value_breakpoint
                  FROM DUAL ;

        END LOOP;  /*  cur_price_brk */

      END LOOP; /*  cur_prce_itm */
      /*  Set err number to pricelist id if success */
      P_err_num := X_pricelist_id;

      EXCEPTION
        WHEN e_orig_record_not_found THEN
          p_err_num := v_orig_record_not_found_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_COPY_ORIG_NOT_FOUND');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_invalid_decimal THEN
          p_err_num := v_invalid_decimal_eno;
          p_err_msg := v_invalid_decimal_emsg ;
        WHEN e_null_price_change THEN
          p_err_num := v_null_price_change_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_NULL_PRICE_CHANGE');
          p_err_msg := FND_MESSAGE.GET;
        WHEN OTHERS THEN
          p_err_num := SQLCODE;
          p_err_msg := SUBSTR(SQLERRM, 1, 100);

    END copy_list;


 /*========================================================================+
 |  NAME                                                                   |
 |     copy_contract                                                       |
 |  SYNOPSIS                                                               |
 |    create a new contract by copying an existing one.                    |
 |                                                                         |
 |  PARAMETERS                                                             |
 |    p_old_contract_id   IN Surrogate for Contract to be copied from.     |
 |    p_contract_no       IN New contract no. Null not allowed.            |
 |    p_contract_desc1    IN New contract long desc.                       |
 |                           If null uses value from existing contract.    |
 |    p_contract_desc2    IN New contract short desc.                      |
 |                            If null uses value from existing contract.   |
 |    p_comments          IN New contract comments.                        |
 |    p_currency_code     IN New contract currency.                        |
 |                           If null uses value from existing contract.    |
 |    p_exchange_rate     IN New contract exchange rate.                   |
 |                           If null uses value from existing contract.    |
 |    p_mul_div_sign      IN New contract mul-div-sign ( 0 or 1 ).         |
 |                           If null uses value from existing contract.    |
 |    p_presales_ord_id   IN New contract assoicated BSO. .                |
 |    p_price_change_type IN Price change type                             |
 |                           ( 1= percent change, 2= absolute change).     |
 |    p_price_change      IN Value for price change.                       |
 |                           Can not be null if type above is 1 or 2.      |
 |    p_decimal           IN Decimal for rounding changed price ( 0 to 6). |
 |                           Can not be null if type above is 1 or 2.      |
 |    p_copy_text         IN Flag to include text in the copy ( Y/N)       |
 |    p_user_id           IN Applications user id.                         |
 |    p_err_num           OUT If positive, ID of new list;                 |
 |                            else error as described below.               |
 |    p_err_msg           OUT Error message.                               |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |  ERROR Codes and messages                                               |
 |     Positive Number : ID of newly created record, no errors.            |
 |     Database errors                    : -1     to -30000               |
 |     User defined :common to the package: -30001 to -30009               |
 |     user defined: Procedure specific   : -30020 to -30029               |
 +========================================================================*/
  PROCEDURE copy_contract(  p_old_contract_id   IN OP_CNTR_HDR.CONTRACT_ID%TYPE   ,
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
                      ) IS
	  /* Cursors */
    CURSOR Cur_cntr_hdr IS
      SELECT  *
      FROM    op_cntr_hdr
      WHERE   contract_id  = p_old_contract_id;

    CURSOR Cur_cntr_dtl IS
      SELECT  *
      FROM    op_cntr_dtl
      WHERE   contract_id  = p_old_contract_id;

    CURSOR Cur_cntr_brk ( V_old_price_id  GML.OP_CNTR_BRK.PRICE_ID%TYPE) IS
      SELECT  *
      FROM    op_cntr_brk
      WHERE   price_id  = V_old_price_id;

    /*  Composites */
	  V_cntr_hdr           Cur_cntr_hdr%ROWTYPE         ;

    /* Scalars */
    X_contract_id        OP_CNTR_HDR.CONTRACT_ID%TYPE;
    X_price_id           OP_CNTR_DTL.PRICE_ID%TYPE    ;
    X_breaktype_id       OP_CNTR_BRK.BREAKTYPE_ID%TYPE;
    X_cntr_hdr_text_code OP_CNTR_HDR.TEXT_CODE%TYPE   ;
    X_cntr_dtl_text_code OP_CNTR_DTL.TEXT_CODE%TYPE   ;
    X_base_price         OP_CNTR_DTL.BASE_PRICE%TYPE  ;
    X_breakpoint_price   OP_CNTR_BRK.BREAKPOINT_PRICE%TYPE  ;

    BEGIN

      IF P_price_change_type IN ( 1, 2) THEN
        IF( P_decimal < 0 ) THEN
          FND_MESSAGE.SET_NAME('GML', 'SO_E_DEC_PLACES');
          v_invalid_decimal_emsg := FND_MESSAGE.GET;
          RAISE e_invalid_decimal;
        END IF;
        IF( P_price_change IS NULL ) THEN
          RAISE e_null_price_change ;
        END IF;
      END IF;

      /*  Fetch the price master record. */
      OPEN Cur_cntr_hdr;
	    FETCH Cur_cntr_hdr INTO v_cntr_hdr;

      /*  If no rows found, then raise exception */
      IF ( Cur_cntr_hdr%NOTFOUND ) THEN
  	    CLOSE Cur_cntr_hdr ;
        RAISE e_orig_record_not_found;
      END IF;

     CLOSE Cur_cntr_hdr ;

      /*  Create a new pricelist id. */
      X_contract_id := create_contract_id;

      /*  If text is to be copied, and the existing pricelist has text associated with it, */
	    /*  then get a new text id for the text and copy the text. */
	    IF ( ( p_copy_text = 'Y') AND ( v_cntr_hdr.text_code IS NOT NULL)) THEN
	      X_cntr_hdr_text_code := create_text_code ;

	      /*  Create the text record */
	      Copy_text_record( v_cntr_hdr.text_code, X_cntr_hdr_text_code, P_user_id );
      ELSE
	      X_cntr_hdr_text_code := NULL;
      END IF;


     /*  Now write the OP_CNTR_HDR record to the table. */
     /*  When creating a new record, if the following parameters are passed in as NULLs, replace them with  */
     /*  the corresponding values form the old contract: */
     /*  Contract_desc1, Contract_desc2, contract_currency, Exchange_rate, Mul_div_sign */
     INSERT INTO OP_CNTR_HDR
                    ( contract_id                      , presales_ord_id  ,
                      contract_desc1                   ,
                      contract_desc2                   ,
                      comments                         ,
                      contract_currency                ,
                      exchange_rate                    ,
                      mul_div_sign                     ,
                      contract_no                      , order_discount   ,
                      value_ordered                    , creation_date    ,
                      created_by                       , last_update_date ,
                      last_updated_by                  , last_update_login,
                      text_code                        , delete_mark      ,
                      in_use                           , base_currency    ,
                      attribute1                       , attribute2       ,
                      attribute3                       , attribute4       ,
                      attribute5                       , attribute6       ,
                      attribute7                       , attribute8       ,
                      attribute9                       , attribute10      ,
                      attribute11                      , attribute12      ,
                      attribute13                      , attribute14      ,
                      attribute15                      , attribute16      ,
                      attribute17                      , attribute18      ,
                      attribute19                      , attribute20      ,
                      attribute21                      , attribute22      ,
                      attribute23                      , attribute24      ,
                      attribute25                      , attribute26      ,
                      attribute27                      , attribute28      ,
                      attribute29                      , attribute30      ,
                      attribute_category
                    )
                    SELECT
                      X_contract_id                    , P_presales_ord_id        ,
                      NVL( P_contract_desc1,    v_cntr_hdr.contract_desc1)        ,
                      NVL( P_contract_desc2,    v_cntr_hdr.contract_desc2)        ,
                      P_comments                       ,
                      NVL( P_contract_currency, v_cntr_hdr.contract_currency)     ,
                      NVL( P_exchange_rate,     v_cntr_hdr.exchange_rate)         ,
                      NVL( P_mul_div_sign,      v_cntr_hdr.mul_div_sign)          ,
                      P_contract_no                    , v_cntr_hdr.order_discount,
                      0                                , SYSDATE                  ,
                      P_user_id                        , sysdate                  ,
                      P_user_id                        , NULL      ,
                      X_cntr_hdr_text_code             , v_cntr_hdr.delete_mark   ,
                      0                                , v_cntr_hdr.base_currency ,
                      v_cntr_hdr.attribute1            , v_cntr_hdr.attribute2    ,
                      v_cntr_hdr.attribute3            , v_cntr_hdr.attribute4    ,
                      v_cntr_hdr.attribute5            , v_cntr_hdr.attribute6    ,
                      v_cntr_hdr.attribute7            , v_cntr_hdr.attribute8    ,
                      v_cntr_hdr.attribute9            , v_cntr_hdr.attribute10   ,
                      v_cntr_hdr.attribute11           , v_cntr_hdr.attribute12   ,
                      v_cntr_hdr.attribute13           , v_cntr_hdr.attribute14   ,
                      v_cntr_hdr.attribute15           , v_cntr_hdr.attribute16   ,
                      v_cntr_hdr.attribute17           , v_cntr_hdr.attribute18   ,
                      v_cntr_hdr.attribute19           , v_cntr_hdr.attribute20   ,
                      v_cntr_hdr.attribute21           , v_cntr_hdr.attribute22   ,
                      v_cntr_hdr.attribute23           , v_cntr_hdr.attribute24   ,
                      v_cntr_hdr.attribute25           , v_cntr_hdr.attribute26   ,
                      v_cntr_hdr.attribute27           , v_cntr_hdr.attribute28   ,
                      v_cntr_hdr.attribute29           , v_cntr_hdr.attribute30   ,
                      v_cntr_hdr.attribute_category
                    FROM DUAL ;

      /*  Retrieve and Copy rows from op_cntr_dtl */
      FOR v_cntr_dtl IN cur_cntr_dtl LOOP

        /* Get a new surrogate id */
        X_price_id := create_price_id;

        /*  If text is to be copied, and the existing pricelist has text associated with it, */
    	  /*  then get a new text id for the text and copy the text. */
	      IF ( ( p_copy_text = 'Y') AND ( v_cntr_dtl.text_code IS NOT NULL)) THEN
	        X_cntr_dtl_text_code := create_text_code ;

  	      /*  Create the text record */
	        Copy_text_record( v_cntr_dtl.text_code, X_cntr_dtl_text_code, P_user_id );
		    ELSE
		      X_cntr_dtl_text_code := NULL;
        END IF;

        /*  Calculate new base price based on the price change type and change. */
        IF p_price_change_type = 1 THEN
          X_base_price := ROUND( (v_cntr_dtl.base_price *( 1 + p_price_change/100 )), P_decimal) ;
        ELSIF p_price_change_type = 2 THEN
          X_base_price := ROUND((v_cntr_dtl.base_price + p_price_change), P_decimal )  ;
        ELSE
          X_base_price := v_cntr_dtl.base_price ;
        END IF ;

        /*  Base price can not be negative */
        IF X_base_price < 0 THEN
          X_base_price := 0;
        END IF;

        /*  Now insert a new row in OP_CNTR_DTL */
        INSERT INTO OP_CNTR_DTL
                    ( price_id                         , contract_id      ,
                      base_price                       , price_type       ,
                      break_type                       , creation_date    ,
                      last_update_date                 , last_updated_by  ,
                      created_by                       , last_update_login,
                      price_class                      ,
                      delete_mark                      , trans_cnt        ,
                      text_code                        , item_id          ,
                      whse_code                        , qc_grade         ,
                      price_um                         , frtbill_mthd     ,
                      line_no                          ,
                      attribute1                       , attribute2       ,
                      attribute3                       , attribute4       ,
                      attribute5                       , attribute6       ,
                      attribute7                       , attribute8       ,
                      attribute9                       , attribute10      ,
                      attribute11                      , attribute12      ,
                      attribute13                      , attribute14      ,
                      attribute15                      , attribute16      ,
                      attribute17                      , attribute18      ,
                      attribute19                      , attribute20      ,
                      attribute21                      , attribute22      ,
                      attribute23                      , attribute24      ,
                      attribute25                      , attribute26      ,
                      attribute27                      , attribute28      ,
                      attribute29                      , attribute30      ,
                      attribute_category
                    )
                    VALUES
                    ( X_price_id                       , X_contract_id         ,
                      X_base_price                     , v_cntr_dtl.price_type ,
                      v_cntr_dtl.break_type            , SYSDATE               ,
                      SYSDATE                          , P_user_id             ,
                      P_user_id                        , NULL   ,
                      v_cntr_dtl.price_class           ,
                      v_cntr_dtl.delete_mark           , 0                     ,
                      X_cntr_dtl_text_code             , v_cntr_dtl.item_id    ,
                      v_cntr_dtl.whse_code             , v_cntr_dtl.qc_grade   ,
                      v_cntr_dtl.price_um              , v_cntr_dtl.frtbill_mthd,
                      v_cntr_dtl.line_no               ,
                      v_cntr_dtl.attribute1            , v_cntr_dtl.attribute2  ,
                      v_cntr_dtl.attribute3            , v_cntr_dtl.attribute4  ,
                      v_cntr_dtl.attribute5            , v_cntr_dtl.attribute6  ,
                      v_cntr_dtl.attribute7            , v_cntr_dtl.attribute8  ,
                      v_cntr_dtl.attribute9            , v_cntr_dtl.attribute10 ,
                      v_cntr_dtl.attribute11           , v_cntr_dtl.attribute12 ,
                      v_cntr_dtl.attribute13           , v_cntr_dtl.attribute14 ,
                      v_cntr_dtl.attribute15           , v_cntr_dtl.attribute16 ,
                      v_cntr_dtl.attribute17           , v_cntr_dtl.attribute18 ,
                      v_cntr_dtl.attribute19           , v_cntr_dtl.attribute20 ,
                      v_cntr_dtl.attribute21           , v_cntr_dtl.attribute22 ,
                      v_cntr_dtl.attribute23           , v_cntr_dtl.attribute24 ,
                      v_cntr_dtl.attribute25           , v_cntr_dtl.attribute26 ,
                      v_cntr_dtl.attribute27           , v_cntr_dtl.attribute28 ,
                      v_cntr_dtl.attribute29           , v_cntr_dtl.attribute30 ,
                      v_cntr_dtl.attribute_category
                     ) ;

          /*  Now insert corresponding break rows into OP_CNTR_BRK */
          FOR v_cntr_brk IN cur_cntr_brk(v_cntr_dtl.price_id) LOOP
            X_breaktype_id := create_breaktype_id;

          /*  Calculate new break price based on the price change type and change. */
          IF p_price_change_type = 1 THEN
            X_breakpoint_price := ROUND( (v_cntr_brk.breakpoint_price * ( 1 + p_price_change/100 )), P_decimal) ;
          ELSIF p_price_change_type = 2 THEN
            X_breakpoint_price := ROUND( (v_cntr_brk.breakpoint_price + p_price_change), P_decimal )  ;
          ELSE
            X_breakpoint_price := v_cntr_brk.breakpoint_price ;
          END IF ;

          /*  Break price can not be negative */
          IF X_breakpoint_price < 0 THEN
            X_breakpoint_price := 0;
          END IF;

          INSERT INTO OP_CNTR_BRK
                  ( breakpoint_factor                , breakpoint_price ,
                    creation_date                    , last_updated_by  ,
                    last_update_date                 , created_by       ,
                    price_id                         , last_update_login,
                    delete_mark                      , trans_cnt        ,
                    breaktype_id                     , line_no          ,
                    qty_breakpoint                   , value_breakpoint
                  )
                  VALUES
                  ( v_cntr_brk.breakpoint_factor     , X_breakpoint_price          ,
                    SYSDATE                          , P_user_id                   ,
                    sysdate                          , P_user_id                   ,
                    X_price_id                       , NULL                        ,
                    v_cntr_brk.delete_mark           , 0                           ,
                    X_breaktype_id                   , v_cntr_brk.line_no          ,
                    v_cntr_brk.qty_breakpoint        , v_cntr_brk.value_breakpoint
                   ) ;

        END LOOP;  /*  cur_price_brk */

      END LOOP; /*  cur_cntr_dtl */

      /*  Set err number to pricelist id if success */
      P_err_num := X_contract_id;

      EXCEPTION
        WHEN e_orig_record_not_found THEN
          p_err_num := v_orig_record_not_found_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_COPY_ORIG_NOT_FOUND');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_invalid_decimal THEN
          p_err_num := v_invalid_decimal_eno;
          p_err_msg := v_invalid_decimal_emsg ;
        WHEN e_null_price_change THEN
          p_err_num := v_null_price_change_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_NULL_PRICE_CHANGE');
          p_err_msg := FND_MESSAGE.GET;
        WHEN OTHERS THEN
          p_err_num := SQLCODE;
          p_err_msg := SUBSTR(SQLERRM, 1, 100);

    END copy_contract;

 /*========================================================================+
 |  NAME                                                                   |
 |     copy_charge                                                         |
 |  SYNOPSIS                                                               |
 |    Create a new charge from an existing one.                            |
 |                                                                         |
 |  PARMS                                                                  |
 |    p_old_charge_id     IN Surrogate for Charge to be copied from.       |
 |    p_charge_code       IN New charge code. Null not allowed.            |
 |    p_charge_desc       IN New charge desc.                              |
 |                           If null uses value from existing charge.      |
 |    p_charge_type       IN New charge type.                              |
 |                           If null uses value from existing charge.      |
 |    p_chgtax_class      IN New charge tax class.                         |
 |                           If null uses value from existing charge.      |
 |    p_billable_ind      IN New contract biallable ind (0 or 1 ).         |
 |                           If null uses value from existing charge.      |
 |    p_currency_code     IN New contract currency.                        |
 |                           If null uses value from existing charge.      |
 |    p_price_change_type IN Price change type                             |
 |                           ( 1= percent change, 2= absolute change).     |
 |    p_price_change      IN Value for price change.                       |
 |                            Can not be null if type above is 1 or 2.     |
 |    p_decimal           IN Decimal for rounding changed price ( 0 to 6). |
 |                           Can not be null if type above is 1 or 2.      |
 |    p_copy_text         IN Flag to include text in the copy ( Y/N)       |
 |    p_user_id           IN Applications user id.                         |
 |    p_err_num           OUT If positive, ID of new list;                 |
 |                            else error as described below.               |
 |    p_err_msg           OUT Error message.                               |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |                                                                         |
 |  ERROR Codes and messages                                               |
 |     Positive Number : ID of newly created record, no errors.            |
 |     Database errors                    : -1     to -30000               |
 |     User defined :common to the package: -30001 to -30009               |
 |     user defined: Procedure specific   : -30030 to -30039               |
 +========================================================================*/

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
                      ) IS
	  /* Cursors */
    CURSOR Cur_chrg_mst IS
      SELECT  *
      FROM    op_chrg_mst
      WHERE   charge_id  = p_old_charge_id;

    CURSOR Cur_chrg_brk ( V_old_charge_id OP_CHRG_BRK.CHARGE_ID%TYPE) IS
      SELECT  *
      FROM    op_chrg_brk
      WHERE   charge_id  = V_old_charge_id;

    /*  Composites */
	  V_chrg_mst           Cur_chrg_mst%ROWTYPE         ;

    /* Scalars */
    X_charge_id          OP_CHRG_MST.CHARGE_ID%TYPE;
    X_base_rate          OP_CHRG_MST.BASE_RATE%TYPE;
    X_base_amount        OP_CHRG_MST.BASE_AMOUNT%TYPE;
    X_base_per_unit      OP_CHRG_MST.BASE_PER_UNIT%TYPE;
    X_chrgbreak_id       OP_CHRG_BRK.CHRGBREAK_ID%TYPE;
    X_chrg_mst_text_code OP_CHRG_MST.TEXT_CODE%TYPE   ;
    X_breakpoint_price   OP_CHRG_BRK.BREAKPOINT_PRICE%TYPE;

    /* Variable that decides if sign of the charge amounts/rates needs to be changed because of  */
    /* change in type of charge. */
    X_change_sign        VARCHAR(1)             DEFAULT 'N';


    /* Exceptions and meesages */
    e_invalid_billable_ind        EXCEPTION;
    v_invalid_billable_ind_eno    NUMBER        DEFAULT -30030;

    e_invalid_base_rate          EXCEPTION;
    v_invalid_base_rate_eno      NUMBER         DEFAULT -30031;


    BEGIN

      IF P_price_change_type IN ( 1, 2) THEN
        IF( P_decimal < 0 ) THEN
          FND_MESSAGE.SET_NAME('GML', 'SO_E_DEC_PLACES');
          v_invalid_decimal_emsg := FND_MESSAGE.GET;
          RAISE e_invalid_decimal;
        END IF;
        IF( P_price_change IS NULL ) THEN
          RAISE e_null_price_change ;
        END IF;
      END IF;

      IF p_billable_ind IS NOT NULL THEN
        IF p_billable_ind NOT IN ( 0, 1 )THEN
         RAISE e_invalid_billable_ind;
        END IF;
      END IF;

      /*  Fetch the price master record. */
      OPEN Cur_chrg_mst;
	    FETCH Cur_chrg_mst INTO v_chrg_mst;

      /*  If no rows found, then raise exception */
      IF ( Cur_chrg_mst%NOTFOUND ) THEN
  	    CLOSE Cur_chrg_mst ;
        RAISE e_orig_record_not_found;
      END IF;

	    CLOSE Cur_chrg_mst ;

      /*  Create a new charge id. */
      X_charge_id := create_charge_id;

      /*  If text is to be copied, and the existing pricelist has text associated with it, */
	    /*  then get a new text id for the text and copy the text. */
	    IF ( ( p_copy_text = 'Y') AND ( v_chrg_mst.text_code IS NOT NULL)) THEN
	      X_chrg_mst_text_code := create_text_code ;

	      /*  Create the text record */
	      Copy_text_record( v_chrg_mst.text_code, X_chrg_mst_text_code, P_user_id );
      ELSE
	      X_chrg_mst_text_code := NULL;
      END IF;

      /*  Calculate new charge amounts/percentages based on the price change type and change. */
      /*  Base rate. */
      /*  Note that the base_rate is stored as a percentage, so calculate accordingly. */
      IF ( (v_chrg_mst.base_rate IS NOT NULL) AND ( p_price_change_type IN (1,2 ))  ) THEN
        IF p_price_change_type = 1 THEN
          X_base_rate := ROUND( (v_chrg_mst.base_rate * ( 1 + p_price_change/100 )), P_decimal) ;
        ELSIF p_price_change_type = 2 THEN
          X_base_rate := ROUND( (v_chrg_mst.base_rate + p_price_change/100), P_decimal)  ;
        END IF;
        /*  If change has changed the base_rate to more than 1 or less than -1, then error. */
        IF ( ( X_base_rate > 1) OR (X_base_rate < -1 ) ) THEN
          RAISE e_invalid_base_rate;
        END IF;
      ELSE
        X_base_rate := v_chrg_mst.base_rate;
      END IF;

      /*  Base amount */
      IF ( (v_chrg_mst.base_amount IS NOT NULL) AND ( p_price_change_type IN (1,2 ))  ) THEN
        IF p_price_change_type = 1 THEN
          X_base_amount := ROUND( (v_chrg_mst.base_amount * ( 1 + p_price_change/100 )), P_decimal) ;
        ELSIF p_price_change_type = 2 THEN
          X_base_amount := ROUND( (v_chrg_mst.base_amount + p_price_change), P_decimal)  ;
        END IF;
      ELSE
        X_base_amount := v_chrg_mst.base_amount;
      END IF;

      /* Base per unit */
      IF ( (v_chrg_mst.base_per_unit IS NOT NULL) AND ( p_price_change_type IN (1,2 ))  ) THEN
        IF p_price_change_type = 1 THEN
          X_base_per_unit := ROUND( (v_chrg_mst.base_per_unit * ( 1 + p_price_change/100 )), P_decimal) ;
        ELSIF p_price_change_type = 2 THEN
          X_base_per_unit := ROUND( (v_chrg_mst.base_per_unit + p_price_change), P_decimal)  ;
        END IF;
      ELSE
        X_base_per_unit := v_chrg_mst.base_per_unit;
      END IF;

     /*  If the charge type is being changed then we might need to change the sign for the charge. */
     /*  Type 0, 1 and 10 store charges as positive; types 20 amd 30 as negative. */
     IF (    (  p_charge_type < 20         AND  v_chrg_mst.charge_type IN ( 20, 30) )
          OR (  p_charge_type IN (20, 30 ) AND  v_chrg_mst.charge_type < 20          )
         ) THEN
       /* Set type changed variable and change the sign for amounts. */
       X_change_sign := 'Y';

       IF ( X_base_rate IS NOT NULL AND X_base_rate <> 0 ) THEN
         X_base_rate := X_base_rate * (-1);
       END IF;
       IF ( X_base_amount IS NOT NULL AND X_base_amount <> 0 ) THEN
         X_base_amount := X_base_amount * (-1);
       END IF;
       IF ( X_base_per_unit IS NOT NULL AND X_base_per_unit <> 0 ) THEN
         X_base_per_unit := X_base_per_unit * (-1);
       END IF;
     END IF;

     /*  Now write the OP_CHRG_MST record to the table. */
     /*  When creating a new record, if the following parameters are passed in as NULLs, replace them with  */
     /*  the corresponding values form the old charge: */
     /*  Charge_desc, Charge_type, currency_code, chgtax_class, billable_ind. */
     INSERT INTO OP_CHRG_MST
                    ( charge_id                        , charge_code      ,
                      charge_desc                      ,
                      charge_type                      ,
                      currency_code                    ,
                      chgtax_class                     ,
                      base_rate                        , base_amount      ,
                      creation_date                    , last_update_date ,
                      created_by                       , last_updated_by  ,
                      last_update_login                , trans_cnt        ,
                      text_code                        , delete_mark      ,
                      base_per_unit                    , charge_uom       ,
                      breakprice_type                  , break_type       ,
                      allocation_method                , calculation_type ,
                      linecharge_ind                   ,
                      billable_ind                     ,
                      attribute1                       , attribute2       ,
                      attribute3                       , attribute4       ,
                      attribute5                       , attribute6       ,
                      attribute7                       , attribute8       ,
                      attribute9                       , attribute10      ,
                      attribute11                      , attribute12      ,
                      attribute13                      , attribute14      ,
                      attribute15                      , attribute16      ,
                      attribute17                      , attribute18      ,
                      attribute19                      , attribute20      ,
                      attribute21                      , attribute22      ,
                      attribute23                      , attribute24      ,
                      attribute25                      , attribute26      ,
                      attribute27                      , attribute28      ,
                      attribute29                      , attribute30      ,
                      attribute_category
                    )
                    SELECT
                      X_charge_id                      , P_charge_code           ,
                      NVL( P_charge_desc,   v_chrg_mst.charge_desc )  ,
                      NVL( P_charge_type,   v_chrg_mst.charge_type )  ,
                      NVL( P_currency_code, v_chrg_mst.currency_code) ,
                      NVL( P_chgtax_class,  v_chrg_mst.chgtax_class)  ,
                      X_base_rate                      , X_base_amount            ,
                      SYSDATE                          , SYSDATE                  ,
                      P_user_id                        , P_user_id                ,
                      NULL                             , 0                        ,
                      X_chrg_mst_text_code             , v_chrg_mst.delete_mark   ,
                      X_base_per_unit                  , v_chrg_mst.charge_uom    ,
                      v_chrg_mst.breakprice_type       , v_chrg_mst.break_type    ,
                      v_chrg_mst.allocation_method     , v_chrg_mst.calculation_type ,
                      v_chrg_mst.linecharge_ind        ,
                      NVL( P_billable_ind, v_chrg_mst.billable_ind )  ,
                      v_chrg_mst.attribute1            , v_chrg_mst.attribute2    ,
                      v_chrg_mst.attribute3            , v_chrg_mst.attribute4    ,
                      v_chrg_mst.attribute5            , v_chrg_mst.attribute6    ,
                      v_chrg_mst.attribute7            , v_chrg_mst.attribute8    ,
                      v_chrg_mst.attribute9            , v_chrg_mst.attribute10   ,
                      v_chrg_mst.attribute11           , v_chrg_mst.attribute12   ,
                      v_chrg_mst.attribute13           , v_chrg_mst.attribute14   ,
                      v_chrg_mst.attribute15           , v_chrg_mst.attribute16   ,
                      v_chrg_mst.attribute17           , v_chrg_mst.attribute18   ,
                      v_chrg_mst.attribute19           , v_chrg_mst.attribute20   ,
                      v_chrg_mst.attribute21           , v_chrg_mst.attribute22   ,
                      v_chrg_mst.attribute23           , v_chrg_mst.attribute24   ,
                      v_chrg_mst.attribute25           , v_chrg_mst.attribute26   ,
                      v_chrg_mst.attribute27           , v_chrg_mst.attribute28   ,
                      v_chrg_mst.attribute29           , v_chrg_mst.attribute30   ,
                      v_chrg_mst.attribute_category
                    FROM DUAL ;

       /*  Now insert corresponding break rows into OP_CHRG_BRK */
       FOR v_chrg_brk IN cur_chrg_brk(P_old_charge_id ) LOOP
         X_chrgbreak_id := create_chargebreak_id;

         /*  Calculate new break price based on the price change type and change. */
        IF ( (v_chrg_brk.breakpoint_price IS NOT NULL) AND ( p_price_change_type IN (1,2 ))  ) THEN
         IF p_price_change_type = 1 THEN
           X_breakpoint_price := ROUND( (v_chrg_brk.breakpoint_price * ( 1 + p_price_change/100 )), P_decimal) ;
         ELSIF p_price_change_type = 2 THEN
           X_breakpoint_price := ROUND( (v_chrg_brk.breakpoint_price + p_price_change), P_decimal)  ;
         END IF;
       ELSE
         X_breakpoint_price := v_chrg_brk.breakpoint_price ;
       END IF ;

       /* If sign change is required */
       IF ( X_change_sign = 'Y' )  AND  (X_breakpoint_price IS NOT NULL) AND (X_breakpoint_price <> 0 ) THEN
          X_breakpoint_price := X_breakpoint_price * (-1);
      END IF;

         INSERT INTO OP_CHRG_BRK
                 ( chrgbreak_id                     , charge_id        ,
                   qty_breakpoint                   , value_breakpoint ,
                   breakpoint_factor                , breakpoint_price ,
                   created_by                       , last_update_date ,
                   creation_date                    , last_updated_by  ,
                   last_update_login                , delete_mark      ,
                   trans_cnt                        , line_no
                 )
                 SELECT
                   X_chrgbreak_id                   , X_charge_id                 ,
                   v_chrg_brk.qty_breakpoint        , v_chrg_brk.value_breakpoint ,
                   v_chrg_brk.breakpoint_factor     , X_breakpoint_price ,
                   P_user_id                        , SYSDATE                     ,
                   sysdate                          , P_user_id                   ,
                   NULL                             , v_chrg_brk.delete_mark      ,
                   0                                , v_chrg_brk.line_no
                  FROM DUAL ;

       END LOOP; /*  cur_chrg_itm */

      /*  Set err number to pricelist id if success */
      P_err_num := X_charge_id;

      EXCEPTION
        WHEN e_orig_record_not_found THEN
          p_err_num := v_orig_record_not_found_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_COPY_ORIG_NOT_FOUND');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_invalid_decimal THEN
          p_err_num := v_invalid_decimal_eno;
          p_err_msg := v_invalid_decimal_emsg ;
        WHEN e_null_price_change THEN
          p_err_num := v_null_price_change_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_NULL_PRICE_CHANGE');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_invalid_billable_ind THEN
          p_err_num := v_invalid_billable_ind_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_CHARGE_INVALID_BILLABLE_IND');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_invalid_base_rate THEN
          p_err_num := v_invalid_base_rate_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_INVALID_PRICE_CHANGE');
          p_err_msg := FND_MESSAGE.GET;
        WHEN OTHERS THEN
          p_err_num := SQLCODE;
          p_err_msg := SUBSTR(SQLERRM, 1, 100);

    END copy_charge;

 /*========================================================================+
 |  NAME                                                                   |
 |     copy_effectivity                                                    |
 |  SYNOPSIS                                                               |
 |    Creates a new effectivity record for a pricelist, contract,          |
 |    or header charge, based on existing effectivity of the same type     |
 |                                                                         |
 |  PARMS                                                                  |
 |    p_old_priceff_id    IN Surrogate for effectivity to be copied from.  |
 |    p_list_id           IN pricelist/Contract/Charge surrogate           |
 |                           for which new effectivity will be created.    |
 |    p_new_start_date    IN Start date for new record.                    |
 |    p_new_end_date      IN End date for new record.                      |
 |    p_new_preference    IN Preference for new record.                    |
 |    p_copy_text         IN Flag to include text in the copy ( Y/N)       |
 |    p_user_id           IN Applications user id.                         |
 |    p_err_num           OUT If positive, ID of new list;                 |
 |                            else error as described below.               |
 |    p_err_msg           OUT Error message.                               |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |  ERROR Codes and messages                                               |
 |     Positive Number : ID of newly created record, no errors.            |
 |     Database errors                    : -1     to -30000               |
 |     User defined :common to the package: -30001 to -30009               |
 |     user defined: Procedure specific   : -30040 to -30049               |
 |                                                                         |
 +========================================================================*/

  PROCEDURE copy_effectivity( p_old_priceff_id    IN OP_PRCE_EFF.PRICEFF_ID%TYPE      ,
                              p_list_id           IN OP_PRCE_EFF.PRICELIST_ID%TYPE    ,
                              p_new_start_date    IN OP_PRCE_EFF.START_DATE%TYPE      ,
                              p_new_end_date      IN OP_PRCE_EFF.END_DATE%TYPE        ,
		                          p_new_preference    IN OP_PRCE_EFF.PREFERENCE%TYPE      ,
      					              p_copy_text         IN VARCHAR2                         ,
      					              p_user_id           IN OP_PRCE_EFF.CREATED_BY%TYPE      ,
      					              p_err_num           OUT NOCOPY NUMBER                          ,
                              p_err_msg           OUT NOCOPY VARCHAR2
					                  ) IS

	  /* Cursors */
	  /* Effectivity record. */
    CURSOR Cur_prce_eff IS
      SELECT  *
      FROM    op_prce_eff
      WHERE   priceff_id  = p_old_priceff_id ;

    /* Charge type */
    CURSOR Cur_linecharge_ind IS
      SELECT  linecharge_ind
      FROM    op_chrg_mst
      WHERE   charge_id  = p_list_id ;

    /*  Composites */
	  V_prce_eff           Cur_prce_eff%ROWTYPE         ;


	  /* Overlapping dates with duplicate effectivity -Pricelist. */
    CURSOR Cur_check_dup_eff IS
      SELECT  COUNT(1)
      FROM    op_prce_eff
      WHERE   (   ( orgn_code = v_prce_eff.orgn_code)
               OR ( orgn_code IS NULL AND v_prce_eff.orgn_code IS NULL ) )
      AND     (   ( custprice_class = v_prce_eff.custprice_class )
               OR ( custprice_class IS NULL AND v_prce_eff.custprice_class IS NULL ) )
      AND     (   ( cust_id = v_prce_eff.cust_id )
               OR ( cust_id IS NULL AND v_prce_eff.cust_id IS NULL ) )
      AND     effectivity_type = v_prce_eff.effectivity_type
      AND     preference       = p_new_preference
      AND    (    p_new_start_date BETWEEN start_date AND end_date
               OR p_new_end_date   BETWEEN start_date AND end_date
               OR start_date       BETWEEN p_new_start_date AND p_new_end_date
               OR end_date         BETWEEN p_new_start_date AND p_new_end_date
             );


    /* Scalars */
    X_priceff_id         OP_PRCE_EFF.PRICEFF_ID%TYPE ;
    X_prce_eff_text_code OP_PRCE_EFF.TEXT_CODE%TYPE  ;
    X_linecharge_ind     OP_CHRG_MST.LINECHARGE_IND%TYPE  ;
    X_check_dup_eff      NUMBER DEFAULT 0 ;

     /*  Exceptions */
    e_charge_type_mismatch   EXCEPTION ;
    e_start_before_end       EXCEPTION ;
    e_preference_overlap     EXCEPTION ;

    /*  Error Numbers and Messages */
    v_charge_type_mismatch_eno  NUMBER        DEFAULT -30041;

    v_start_before_end_eno      NUMBER        DEFAULT -30042;

    v_preference_overlap_eno    NUMBER        DEFAULT -30043;

    BEGIN

      /*  Make sure that start_date is before end_date */
      IF ( p_new_start_date > p_new_end_date ) THEN
        RAISE e_start_before_end;
      END IF;

      /*  Fetch the price master record. */
      OPEN Cur_prce_eff;
	    FETCH Cur_prce_eff into v_prce_eff;

      /*  If no rows found, then raise exception */
      IF ( Cur_prce_eff%NOTFOUND ) THEN
  	    CLOSE Cur_prce_eff ;
        RAISE e_orig_record_not_found;
      END IF;

	    CLOSE Cur_prce_eff ;

      /*  If effectivity is for a charge, then check to see if the charge is total order type. */
      /*  For contract or pricelist, check that there is no date overlap with duplicate preference. */
      IF ( v_prce_eff.effectivity_type = 3) THEN
        OPEN Cur_linecharge_ind;
	      FETCH Cur_linecharge_ind INTO X_linecharge_ind;
	      CLOSE Cur_linecharge_ind;
	      IF ( X_linecharge_ind <> 0 ) THEN
          RAISE e_charge_type_mismatch;
        END IF;
      ELSIF ( v_prce_eff.effectivity_type IN ( 0, 1)  ) THEN
        OPEN Cur_check_dup_eff;
	      FETCH Cur_check_dup_eff INTO X_check_dup_eff;
	      CLOSE Cur_check_dup_eff;
	      IF ( X_check_dup_eff > 0 ) THEN
          RAISE e_preference_overlap;
        END IF;
       END IF;

      /*  Create a new price effectivity id. */
      X_priceff_id := create_priceff_id;


      /*  If text is to be copied, and the existing effectivity has text associated with it, */
	    /*  then get a new text id for the text and copy the text. */
	    IF ( ( p_copy_text = 'Y') AND ( v_prce_eff.text_code IS NOT NULL)) THEN
	      X_prce_eff_text_code := create_text_code ;

	      /*  Create the text record */
	      Copy_text_record( v_prce_eff.text_code, X_prce_eff_text_code, P_user_id );
      ELSE
	      X_prce_eff_text_code := NULL;
      END IF;

      /*  Now write the OP_PRCE_EFF record to the table. */
      INSERT INTO OP_PRCE_EFF(PRICEFF_ID                                       ,
                              ORGN_CODE                                        ,
                              PROMOTION_ID                                     ,
                              CUST_ID                                          ,
                              INACTIVE_IND                                     ,
                              LISTPRICE_IND                                    ,
                              CUSTPRICE_CLASS                                  ,
                              DELETE_MARK                                      ,
                              TEXT_CODE                                        ,
                              TRANS_CNT                                        ,
                              CREATION_DATE                                    ,
                              CREATED_BY                                       ,
                              LAST_UPDATE_DATE                                 ,
                              LAST_UPDATED_BY                                  ,
                              LAST_UPDATE_LOGIN                                ,
                              TERRITORY                                        ,
                              START_DATE                                       ,
                              END_DATE                                         ,
                              PREFERENCE                                       ,
                              EFFECTIVITY_TYPE                                 ,
                              PRICELIST_ID                                     ,
                              CONTRACT_ID                                      ,
                              CHARGE_ID
                             )
                    SELECT    X_priceff_id                                     ,
                              v_prce_eff.orgn_code                             ,
                              NULL                                             ,
                              v_prce_eff.cust_id                               ,
                              v_prce_eff.inactive_ind                          ,
                              v_prce_eff.listprice_ind                         ,
                              v_prce_eff.custprice_class                       ,
                              v_prce_eff.delete_mark                           ,
                              X_prce_eff_text_code                             ,
                              0                                                ,
                              SYSDATE                                          ,
                              P_user_id                                        ,
                              SYSDATE                                          ,
                              P_user_id                                        ,
                              NULL                              ,
                              v_prce_eff.territory                             ,
                              p_new_start_date                                 ,
                              p_new_end_date                                   ,
                              p_new_preference                                 ,
                              v_prce_eff.effectivity_type                      ,
                              DECODE (v_prce_eff.effectivity_type, 0, p_list_id,
                                                              NULL      )  ,
                              DECODE (v_prce_eff.effectivity_type, 1, p_list_id,
                                                              NULL      )  ,
                              DECODE (v_prce_eff.effectivity_type, 3, p_list_id,
                                                                  NULL  )
                    FROM DUAL;

      /*  Set err number to pricelist id if success */
      P_err_num := X_priceff_id;

      EXCEPTION
        WHEN e_orig_record_not_found THEN
          p_err_num := v_orig_record_not_found_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_COPY_ORIG_NOT_FOUND');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_charge_type_mismatch THEN
          p_err_num := v_charge_type_mismatch_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_LINE_CHARGE_EFF_NOT_ALLOWED');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_start_before_end THEN
          p_err_num := v_start_before_end_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_TOLESS_THAN_FROM');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_preference_overlap THEN
          p_err_num := v_preference_overlap_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_RECORD_EXISTS');
          p_err_msg := FND_MESSAGE.GET;
        WHEN OTHERS THEN
          p_err_num := SQLCODE;
          p_err_msg := SUBSTR(SQLERRM, 1, 100);

  END copy_effectivity;

 /*========================================================================+
 |  NAME                                                                   |
 |     copy_charge_asc                                                     |
 |  SYNOPSIS                                                               |
 |    Creates a new customer-item charge association record for            |
 |    line level charges based on existing association.                    |
 |                                                                         |
 |  PARMS                                                                  |
 |    p_old_chargeitem_id IN Surrogate for association to be copied from.  |
 |    p_charge_id         IN Charge surrogate for which                    |
 |                           new association will be created.              |
 |    p_copy_text         IN Flag to include text in the copy ( Y/N)       |
 |    p_user_id           IN Applications user id.                         |
 |    p_err_num           OUT If positive, ID of new list;                 |
 |                            else error as described below.               |
 |    p_err_msg           OUT Error message.                               |
 |                                                                         |
 |  ERROR Codes and messages                                               |
 |     Positive Number : ID of newly created record, no errors.            |
 |     Database errors                    : -1     to -30000               |
 |     User defined :common to the package: -30001 to -30009               |
 |     user defined: Procedure specific   : -30050 to -30059               |
 |                                                                         |
 +========================================================================*/

  PROCEDURE copy_charge_asc ( p_old_chargeitem_id IN OP_CHRG_ITM.CHARGEITEM_ID%TYPE     ,
                              p_charge_id         IN OP_CHRG_ITM.CHARGE_ID%TYPE     ,
    					                p_copy_text         IN VARCHAR2                       ,
          					          p_user_id           IN OP_CHRG_MST.CREATED_BY%TYPE    ,
      	    				          p_err_num           OUT NOCOPY NUMBER                        ,
                              p_err_msg           OUT NOCOPY VARCHAR2
                            ) IS
	  /* Cursors */

    CURSOR Cur_chrg_itm IS
      SELECT  *
      FROM    op_chrg_itm
      WHERE   chargeitem_id  = p_old_chargeitem_id;

    /* Charge type */
    CURSOR Cur_linecharge_ind IS
      SELECT  linecharge_ind
      FROM    op_chrg_mst
      WHERE   charge_id  = p_charge_id ;

    /*  Composites */
	  V_chrg_itm           Cur_chrg_itm%ROWTYPE         ;

    /* Scalars */
    X_chargeitem_id      OP_CHRG_ITM.CHARGEITEM_ID%TYPE;
    X_chrg_itm_text_code OP_CHRG_ITM.TEXT_CODE%TYPE   ;
    X_linecharge_ind     OP_CHRG_MST.LINECHARGE_IND%TYPE   ;

     /*  Exceptions */
    e_charge_type_mismatch   EXCEPTION ;

    /*  Error Numbers and Messages */
    v_charge_type_mismatch_eno  NUMBER        DEFAULT -30050;

    BEGIN

      /*  Fetch the charge item record. */
      OPEN Cur_chrg_itm;
	    FETCH Cur_chrg_itm INTO v_chrg_itm;
      /*  If no rows found, then raise exception */
      IF ( Cur_chrg_itm%NOTFOUND ) THEN
  	    CLOSE Cur_chrg_itm ;
        RAISE e_orig_record_not_found;
      END IF;

	    CLOSE Cur_chrg_itm ;

      /*  Check that the charge is not for the order header. */
      OPEN Cur_linecharge_ind;
      FETCH Cur_linecharge_ind INTO X_linecharge_ind;
      CLOSE Cur_linecharge_ind;
      IF ( X_linecharge_ind <> 1 ) THEN
        RAISE e_charge_type_mismatch;
      END IF;

      /*  Create a new charge id. */
      X_chargeitem_id := create_chargeitem_id;

      /*  If text is to be copied, and the existing pricelist has text associated with it, */
	    /*  then get a new text id for the text and copy the text. */
	    IF ( ( p_copy_text = 'Y') AND ( v_chrg_itm.text_code IS NOT NULL)) THEN
	      X_chrg_itm_text_code := create_text_code ;

	      /*  Create the text record */
	      Copy_text_record( v_chrg_itm.text_code, X_chrg_itm_text_code, P_user_id );
      ELSE
	      X_chrg_itm_text_code := NULL;
      END IF;

        INSERT INTO OP_CHRG_ITM
                    ( chargeitem_id                    , charge_id        ,
                      created_by                       , last_updated_by  ,
                      creation_date                    , last_update_date ,
                      last_update_login                , delete_mark      ,
                      trans_cnt                        , text_code        ,
                      cust_id                          , item_id          ,
                      icprice_class                    ,
                      attribute1                       , attribute2       ,
                      attribute3                       , attribute4       ,
                      attribute5                       , attribute6       ,
                      attribute7                       , attribute8       ,
                      attribute9                       , attribute10      ,
                      attribute11                      , attribute12      ,
                      attribute13                      , attribute14      ,
                      attribute15                      , attribute16      ,
                      attribute17                      , attribute18      ,
                      attribute19                      , attribute20      ,
                      attribute21                      , attribute22      ,
                      attribute23                      , attribute24      ,
                      attribute25                      , attribute26      ,
                      attribute27                      , attribute28      ,
                      attribute29                      , attribute30      ,
                      attribute_category
                    )
                    SELECT
                      X_chargeitem_id                  , P_charge_id           ,
                      P_user_id                        , P_user_id             ,
                      SYSDATE                          , SYSDATE               ,
                      NULL                             , v_chrg_itm.delete_mark,
                      0                                , X_chrg_itm_text_code  ,
                      v_chrg_itm.cust_id               , v_chrg_itm.item_id    ,
                      v_chrg_itm.icprice_class         ,
                      v_chrg_itm.attribute1            , v_chrg_itm.attribute2  ,
                      v_chrg_itm.attribute3            , v_chrg_itm.attribute4  ,
                      v_chrg_itm.attribute5            , v_chrg_itm.attribute6  ,
                      v_chrg_itm.attribute7            , v_chrg_itm.attribute8  ,
                      v_chrg_itm.attribute9            , v_chrg_itm.attribute10 ,
                      v_chrg_itm.attribute11           , v_chrg_itm.attribute12 ,
                      v_chrg_itm.attribute13           , v_chrg_itm.attribute14 ,
                      v_chrg_itm.attribute15           , v_chrg_itm.attribute16 ,
                      v_chrg_itm.attribute17           , v_chrg_itm.attribute18 ,
                      v_chrg_itm.attribute19           , v_chrg_itm.attribute20 ,
                      v_chrg_itm.attribute21           , v_chrg_itm.attribute22 ,
                      v_chrg_itm.attribute23           , v_chrg_itm.attribute24 ,
                      v_chrg_itm.attribute25           , v_chrg_itm.attribute26 ,
                      v_chrg_itm.attribute27           , v_chrg_itm.attribute28 ,
                      v_chrg_itm.attribute29           , v_chrg_itm.attribute30 ,
                      v_chrg_itm.attribute_category
                     FROM DUAL  ;

      /*  Set err number to pricelist id if success */
      P_err_num := X_chargeitem_id;

      EXCEPTION
        WHEN e_orig_record_not_found THEN
          p_err_num := v_orig_record_not_found_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_COPY_ORIG_NOT_FOUND');
          p_err_msg := FND_MESSAGE.GET;
        WHEN e_charge_type_mismatch THEN
          p_err_num := v_charge_type_mismatch_eno;
          FND_MESSAGE.SET_NAME( 'GML', 'OP_TOTAL_CHARGE_NO_ASC');
          p_err_msg := FND_MESSAGE.GET;
        WHEN OTHERS THEN
          p_err_num := SQLCODE;
          p_err_msg := SUBSTR(SQLERRM, 1, 100);

    END copy_charge_asc;

 /*========================================================================+
 |  NAME                                                                   |
 |     copy_text_record                                                    |
 |  SYNOPSIS                                                               |
 |    Proc  copy_text_record                                               |
 |  PARMS                                                                  |
 |    P_old_text_code IN Old text code to be copied from.                  |
 |    P_new_text_code IN text code for the new record.                     |
 |    P_user_id       IN Application ser id.                               |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |                                                                         |
 +========================================================================*/

  PROCEDURE copy_text_record(  p_old_text_code  IN OP_TEXT_HDR.TEXT_CODE%TYPE   ,
                               p_new_text_code  IN OP_TEXT_HDR.TEXT_CODE%TYPE   ,
                               p_user_id        IN OP_TEXT_HDR.CREATED_BY%TYPE
                            ) IS
	  /* Cursors */
    CURSOR Cur_text_tbl_tl IS
      SELECT  *
      FROM    op_text_tbl_tl
      WHERE   text_code   = p_old_text_code;

    BEGIN

     /*  Now create the text header record. */
     INSERT INTO OP_TEXT_HDR
                    ( text_code                        , creation_date    ,
                      created_by                       , last_update_date ,
                      last_updated_by                  , last_update_login
                     )
                    SELECT
                      P_new_text_code                  , SYSDATE                  ,
                      P_user_id                        , sysdate                  ,
                      P_user_id                        , NULL
                    FROM DUAL ;

      /*  Retrieve and Copy rows from op_text_tbl */
      FOR v_text_tbl_tl IN  cur_text_tbl_tl LOOP

        /*  Now insert a new row in OP_TEXT_TBL_TL */
        INSERT INTO OP_TEXT_TBL_TL
                      ( text_code         ,
                        lang_code         ,
                        paragraph_code    ,
                        sub_paracode      ,
                        line_no           ,
                        text              ,
                        language          ,
                        source_lang       ,
                        last_updated_by   ,
                        created_by        ,
                        last_update_date  ,
                        creation_date     ,
                        last_update_login
                      )
               SELECT p_new_text_code             ,
                      v_text_tbl_tl.lang_code     ,
                      v_text_tbl_tl.paragraph_code,
                      v_text_tbl_tl.sub_paracode  ,
                      v_text_tbl_tl.line_no       ,
                      v_text_tbl_tl.text          ,
                      v_text_tbl_tl.language      ,
                      v_text_tbl_tl.source_lang   ,
                      P_user_id                   ,
                      P_user_id                   ,
                      SYSDATE                     ,
                      SYSDATE                     ,
                      NULL
                 FROM DUAL   ;

      END LOOP; /*  cur_text_tbl_tl */
    END copy_text_record;

 /*========================================================================+
 | NAME                                                                    |
 |     create_pricelist_id                                                 |
 | SYNOPSIS                                                                |
 |     function create_pricelist_id                                        |
 | DESCRIPTION                                                             |
 |     Generates and returns new pricelist_id from the sequence.           |
 +========================================================================*/

  FUNCTION create_pricelist_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_new_pricelist_id IS
      SELECT GMO_PRICELIST_ID_S.NEXTVAL
      FROM SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      OPEN  Cur_new_pricelist_id;
      FETCH Cur_new_pricelist_id INTO X_ret;
      CLOSE Cur_new_pricelist_id;

      return X_ret;

    END create_pricelist_id;
 /*========================================================================+
 | NAME                                                                    |
 |	  create_price_id                                                      |
 | SYNOPSIS                                                                |
 |	                                                                       |
 | DESCRIPTION                                                             |
 |     Generates and returns price id from sequence.                       |
 +========================================================================*/
  FUNCTION create_price_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_get_id IS
      SELECT gmo_price_id_s.NEXTVAL
      FROM   SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      /* Generates price id from sequence for each record. */
      OPEN  Cur_get_id;
      FETCH Cur_get_id INTO X_ret;
      CLOSE Cur_get_id;

      return X_ret;

    END create_price_id;

 /*========================================================================+
 | NAME                                                                    |
 |	create_breaktype_id                                                    |
 | SYNOPSIS                                                                |
 |	                                                                       |
 | DESCRIPTION                                                             |
 |     Generates and returns breaktype_id.                                 |
 +========================================================================*/
  FUNCTION create_breaktype_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_get_id IS
      SELECT gmo_breaktype_id_s.NEXTVAL
      FROM   SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      /* Generates price id from sequence for each record. */
      OPEN  Cur_get_id;
      FETCH Cur_get_id INTO X_ret;
      CLOSE Cur_get_id;

      return X_ret;

    END create_breaktype_id;
 /*========================================================================+
 | NAME                                                                    |
 |	 create_priceff_id                                                     |
 | SYNOPSIS                                                                |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Generates and returns effectivity id from sequence.                   |
 +========================================================================*/
  FUNCTION create_priceff_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_get_id IS
      SELECT gmo_priceff_id_s.NEXTVAL
      FROM   SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      /* Generates price id from sequence for each record. */
      OPEN  Cur_get_id;
      FETCH Cur_get_id INTO X_ret;
      CLOSE Cur_get_id;

      return X_ret;
    END create_priceff_id;
 /*========================================================================+
 | NAME                                                                    |
 |     create_charge_id                                                    |
 | SYNOPSIS                                                                |
 |     proc create_charge_id                                               |
 | DESCRIPTION                                                             |
 |     generates and returns a new charge_id from the sequence.            |
 +========================================================================*/

  FUNCTION create_charge_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_new_charge_id IS
      SELECT GMO_CHARGE_ID_S.NEXTVAL
      FROM SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      OPEN  Cur_new_charge_id;
      FETCH Cur_new_charge_id INTO X_ret;
      CLOSE Cur_new_charge_id;

      return X_ret;

    END create_charge_id;
 /*========================================================================+
 | NAME                                                                    |
 |	create_chargitem_id                                                    |
 | SYNOPSIS                                                                |
 |	                                                                       |
 | DESCRIPTION                                                             |
 |     Generates returns a new chargeitem_id from sequence.                |
 +========================================================================*/
  FUNCTION create_chargeitem_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_get_id IS
      SELECT gem5_chargeitem_id_s.NEXTVAL
      FROM   SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      /* Generates chargeitem id from sequence for each record. */
      OPEN  Cur_get_id;
      FETCH Cur_get_id INTO X_ret;
      CLOSE Cur_get_id;

      return X_ret;
    END create_chargeitem_id;

 /*========================================================================+
 | NAME                                                                    |
 |	create_chargebreak_id                                                  |
 | SYNOPSIS                                                                |
 |	                                                                       |
 | DESCRIPTION                                                             |
 |     Generates chargebreak_id.                                           |
 +========================================================================*/

  FUNCTION create_chargebreak_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_get_id IS
      SELECT gmo_chrgbreak_id_s.NEXTVAL
      FROM   SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      /* Generates price id from sequence for each record. */
      OPEN  Cur_get_id;
      FETCH Cur_get_id INTO X_ret;
      CLOSE Cur_get_id;

      return X_ret;

    END create_chargebreak_id;
 /*========================================================================+
 | NAME                                                                    |
 |     create_contract_id                                                  |
 | SYNOPSIS                                                                |
 |     proc create_contract_id                                             |
 | DESCRIPTION                                                             |
 |     This procedure creates a new contract_id from the sequence.         |
 +========================================================================*/

  FUNCTION create_contract_id RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_new_contract_id IS
      SELECT GMO_CHARGE_ID_S.NEXTVAL
      FROM SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      OPEN  Cur_new_contract_id;
      FETCH Cur_new_contract_id INTO X_ret;
      CLOSE Cur_new_contract_id;

      return X_ret;

    END create_contract_id;
 /*========================================================================+
 | NAME                                                                    |
 |     create_text_code                                                    |
 | SYNOPSIS                                                                |
 |     proc create_text_code                                               |
 | DESCRIPTION                                                             |
 |     This procedure creates a new text_code from the sequence.           |
 +========================================================================*/

  FUNCTION create_text_code RETURN NUMBER IS
    /* Cursors */
    CURSOR Cur_text_code IS
      SELECT GEM5_TEXT_CODE_S.NEXTVAL
      FROM SYS.DUAL;

    /* Scalars */
    X_ret NUMBER;

    BEGIN
      OPEN  Cur_text_code;
      FETCH Cur_text_code INTO X_ret;
      CLOSE Cur_text_code;

      return X_ret;

    END create_text_code;

END;

/
