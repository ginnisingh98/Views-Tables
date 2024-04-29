--------------------------------------------------------
--  DDL for Package Body GML_OP_CUST_MST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OP_CUST_MST_PKG" AS
/* $Header: GMLUPDB.pls 115.13 2002/10/18 20:55:00 gmangari ship $ */


/*#############################################################################
  #  PROCEDURE
  #
  #     update_customer_balance
  #
  #  DESCRIPTION
  #
  #
  #     To update the  customer balances in op_cust_mst  and op_updt_bal_wk
  #
  #
  #   MODIFICATION HISTORY
  #
  #      02-APR-99      Srinivas Somayajula Created.
  #      02-DEC-99      Rajender Nalla      Getting the user_id from
  #                                         fnd_global.user_id.
  #     29-FEB-00      Rajender Nalla     Changed the parameters to cust_no
  #                                       instead of CUST_ID
  #                                       V_from_cust_id,V_from_cust_no
  #                                       V_to_cust_id,V_to_cust_no
  #      13-Sep-2002  Piyush K. Mishra Bug#2521042
  #                   Modified the UPDATE statement to update the Customer's Open
  #                   Balance correctly.
  #      17-Oct-2002  Piyush K. Mishra Bug#2611290
  #                   Modified the Cursor Cur_get_cust_details, since it was not
  #                   working if V_from_cust_no and V_to_cust_no is being passed as
  #                   NULL. Modified Update statement setting open_balance to 0
  #                   and added condition so this update will be done only once for
  #                   each customer.
  ##########################################################################*/
PROCEDURE update_cust_balance
(
  V_session_id    NUMBER,
  V_co_code 	  VARCHAR2,
  V_from_cust_no  VARCHAR2,
  V_to_cust_no    VARCHAR2
) IS
  X_max_cust_id 	NUMBER;
  X_currency      	VARCHAR2(10);
  X_base_currency    	VARCHAR2(10);
  X_type        	VARCHAR2(4);
  X_user_id             NUMBER;
  X_exch_rate           NUMBER;
  --Begin Bug#2611290 Piyush K. Mishra
  X_prvs_cust_id NUMBER := 0;
  --End Bug#2611290

  CURSOR Cur_max_cust_id IS
    SELECT MAX(cust_id)
    FROM   op_cust_mst;

  /*Begin Bug#2611290 Piyush K. Mishra
  Changed the NVL used in below query, previously it was
  NVL(V_from_cust_no, 'X') and NVL(V_from_cust_no, 'X').
  Also commented the hdr.billcust_id = cus.cust_id as it was twice */
  CURSOR Cur_get_cust_details IS
    SELECT cus.cust_id,
           cus.cust_no,
           cus.cust_name,
           cus.cust_currency,
           hdr.order_id,
           hdr.order_date,
           hdr.billing_currency,
           SUM(hdr.total_open_amount) total_open_amount
    FROM   op_cust_mst cus, op_ordr_hdr hdr
    WHERE  hdr.billcust_id 		= cus.cust_id and
	   hdr.completed_ind 		<> -1 	      and
	   hdr.delete_mark 		= 0 	      and
	   hdr.order_status 		< 20 	      and
           -- hdr.billcust_id 		= cus.cust_id and
           (cus.cust_id IN(SELECT cust_id from op_cust_mst where cust_no >= NVL(V_from_cust_no, cust_no)) and
           (cus.cust_id IN(SELECT cust_id from op_cust_mst where cust_no <= NVL(V_to_cust_no, cust_no)))) and
           cus.co_code 			= V_co_code
           GROUP BY cus.cust_id,
           cus.cust_no,
           cus.cust_name,
           cus.cust_currency,
           hdr.order_id,
           hdr.order_date,
           hdr.billing_currency;
  --End Bug#2611290

    CURSOR Cur_get_base_curr IS
      SELECT  base_currency_code
      FROM    gl_plcy_mst
      WHERE   set_of_books_name IS NOT NULL and
	      co_code 	  = V_co_code and
              delete_mark = 0;
  X_cust_details Cur_get_cust_details%ROWTYPE;


  CURSOR Cur_get_exchange_rate(V_currency VARCHAR2) IS
    SELECT   ex.exchange_rate, ex.mul_div_sign,
             ex.exchange_rate_date
    FROM     gl_xchg_rte ex,
             gl_srce_mst src
    WHERE  ex.to_currency_code    =  X_cust_details.billing_currency and
           ex.from_currency_code  =  V_currency and
           ex.exchange_rate_date  <= X_cust_details.order_date and
           ex.rate_type_code      =  src.rate_type_code     and
           src.trans_source_code  =  'OP'                   and
           ex.delete_mark=0;
  X_exchange_rate_rec Cur_get_exchange_rate%rowtype;
BEGIN

  /* Bug Id 1080909 fixed. */
  X_user_id := FND_GLOBAL.USER_ID;
  /* End of bug 1080909. */
  OPEN  Cur_max_cust_id;
  FETCH Cur_max_cust_id INTO X_max_cust_id;
  CLOSE Cur_max_cust_id;
  OPEN  Cur_get_base_curr;
  FETCH Cur_get_base_curr INTO X_base_currency;
  CLOSE Cur_get_base_curr;
  OPEN  Cur_get_cust_detailS;
  LOOP
    FETCH Cur_get_cust_details INTO X_cust_details;
    IF(Cur_get_cust_details%NOTFOUND) THEN
      EXIT;
    END IF;
    IF(X_cust_details.cust_currency IS NOT NULL ) THEN
      X_currency := X_cust_details.cust_currency;
    ELSE
      X_currency := X_base_currency;
    END IF;
    IF(X_currency IS NULL) THEN
      INSERT INTO op_updt_bal_wk (session_id, cust_no, cust_name, error_message,
					    created_by, creation_date, last_update_date, last_updated_by,
					    last_update_login) VALUES
             (
               V_session_id,
               X_cust_details.cust_no,
               X_cust_details.cust_name,
        'Base currency not available',
	         X_user_id,
               sysdate,
               sysdate,
               X_user_id,
  	          -1
		      );
    ELSE
      IF (X_currency = X_cust_details.billing_currency) THEN
        X_exch_rate := 1;
      ELSE
        OPEN  Cur_get_exchange_rate(X_currency);
        FETCH Cur_get_exchange_rate INTO X_exchange_rate_rec;
        CLOSE Cur_get_exchange_rate;
        X_exch_rate := X_exchange_rate_rec.exchange_rate;
      END IF;
      IF(X_exch_rate IS NULL) THEN
        INSERT INTO op_updt_bal_wk (session_id, cust_no, cust_name, error_message,
				    created_by, creation_date, last_update_date, last_updated_by,
				    last_update_login) VALUES
               (
                 V_session_id,
                 X_cust_details.cust_no,
                 X_cust_details.cust_name,
                 'Exchange rate does not exist for this customer',
                 X_user_id,
                 sysdate,
                 sysdate,
                 X_user_id,
  	          -1
        );
      ELSE
        IF(X_exchange_rate_rec.mul_div_sign = '1') THEN
          X_cust_details.total_open_amount :=
          X_cust_details.total_open_amount/X_exch_rate;
        ELSE
          X_cust_details.total_open_amount :=  X_cust_details.total_open_amount*
                                               X_exch_rate;
        END IF;
      END IF;

      /*Begin Bug#2611290 Piyush K. Mishra
      Added IF condition and modified the where condition, it was wrong.
      This update statement updates the open balance of the customers (fetched
      in the loop for whom the open balances exist) to zero. This is required
      as the balances should be calculated and updated every time the program
      is executed. This should be executed only once per customer before updating
      the open balance with the open amounts from sales orders */

      IF X_prvs_cust_id <> X_cust_details.cust_id THEN
        UPDATE op_cust_mst
        SET    open_balance = 0
        WHERE  bill_ind = 1
               AND co_code = V_co_code
               AND cust_id = X_cust_details.cust_id;
      /*Commented following conditions
               AND cust_id NOT IN
                  (SELECT cust_id
                   FROM  op_cust_mst cus,op_ordr_hdr hdr
                   WHERE hdr.billcust_id = cus.cust_id
           	   AND   hdr.completed_ind <> -1
                   AND   hdr.delete_mark = 0
	           AND   hdr.order_status < 20
                   AND   hdr.billcust_id = cus.cust_id
                   AND   (cus.cust_id IN(SELECT cust_id from op_cust_mst where cust_no >= NVL(V_from_cust_no,'X'))
                   AND   (cus.cust_id IN(SELECT cust_id from op_cust_mst where cust_no <= NVL(V_to_cust_no,'X')))));*/
        X_prvs_cust_id := X_cust_details.cust_id;
      END IF;
      /*End Bug#2611290*/

      --Begin Bug#2521042 Piyush K. Mishra
      --Open_balance should be updated with open_balance + X_cust_details.total_open_amount
      UPDATE op_cust_mst
      SET    open_balance = Open_balance + X_cust_details.total_open_amount
      WHERE  cust_id = X_cust_details.cust_id
      AND    co_code = V_co_code;
      --End Bug#2521042

    END IF;
  END LOOP;
  CLOSE Cur_get_cust_details;
  /* Begin Bug#2611290 Piyush K. Mishra */
  /* This update statement updates the open balances to zero, for the customers for whom no
     open amounts exist and are within the range criteria. The customers fetched in the above
     loop are excluded in this update. */
  UPDATE op_cust_mst
     SET    open_balance = 0
   WHERE  bill_ind = 1
     AND co_code = V_co_code
     AND cust_id NOT IN
     (SELECT cust_id
        FROM  op_cust_mst cus,op_ordr_hdr hdr
        WHERE hdr.billcust_id = cus.cust_id
   	AND   hdr.completed_ind <> -1
        AND   hdr.delete_mark = 0
	AND   hdr.order_status < 20
        AND   (cus.cust_id IN(SELECT cust_id from op_cust_mst where cust_no >= NVL(V_from_cust_no,cust_no))
        AND   (cus.cust_id IN(SELECT cust_id from op_cust_mst where cust_no <= NVL(V_to_cust_no,cust_no)))))
     AND (cust_id IN(SELECT cust_id from op_cust_mst where cust_no >= NVL(V_from_cust_no, cust_no))
     AND (cust_id IN(SELECT cust_id from op_cust_mst where cust_no <= NVL(V_to_cust_no, cust_no))));
  /* End Bug#2611290 */

END UPDATE_CUST_BALANCE;

END  GML_OP_CUST_MST_PKG;

/
