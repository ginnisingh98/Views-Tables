--------------------------------------------------------
--  DDL for Package Body CN_PAYMENT_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYMENT_API_PKG" as
-- $Header: cntpmtab.pls 115.2 2001/10/29 17:15:38 pkm ship    $


  -------------------------------------------------------------------------+
  -- Procedure Name : Insert_Record
  -- Purpose        : Main insert procedure
  -------------------------------------------------------------------------+

  PROCEDURE Insert_Record(
			x_period_id               cn_payment_api.period_id%TYPE
			,x_salesrep_id             cn_payment_api.salesrep_id%TYPE
			,x_pay_date       	   cn_payment_api.pay_date%TYPE
			,x_payment_type            cn_payment_api.payment_type%TYPE
			,x_amount                  cn_payment_api.amount%TYPE
			,x_cost_center_id          cn_payment_api.cost_center_id%TYPE
			,x_payment_api_id          cn_payment_api.payment_api_id%TYPE
			,x_payrun_id               cn_payment_api.payrun_id%TYPE
			,x_from_credit_type_id	  cn_payment_api.from_credit_type_id%TYPE
			,x_to_credit_type_id       cn_payment_api.to_credit_type_id%TYPE
			,x_role_id                 cn_payment_api.role_id%TYPE
			,x_created_by              cn_payment_api.created_by%TYPE
			,x_creation_date           cn_payment_api.creation_date%TYPE
   )
    IS

  BEGIN

     INSERT INTO cn_payment_api(
			period_id
			,salesrep_id
			,pay_date
			,payment_type
			,amount
			,cost_center_id
			,payment_api_id
			,payrun_id
			,from_credit_type_id
			,to_credit_type_id
		        ,role_id
		        ,created_by
			,creation_date	)
       VALUES (
			x_period_id
			,x_salesrep_id
			,x_pay_date
			,x_payment_type
			,x_amount
			,x_cost_center_id
			,Nvl(x_payment_api_id, cn_payment_api_s.NEXTVAL)
			,x_payrun_id
			,x_from_credit_type_id
			,x_to_credit_type_id
	                ,x_role_id
	                ,x_created_by
	                ,x_creation_date
	       );

  END Insert_Record;

END CN_PAYMENT_API_PKG;

/
