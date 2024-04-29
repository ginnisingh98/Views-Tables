--------------------------------------------------------
--  DDL for Package AP_CUSTOM_INT_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CUSTOM_INT_INV_PKG" AUTHID CURRENT_USER AS
/*$Header: apcstiis.pls 120.7 2006/06/02 12:25:47 mahkumar noship $*/

  -- bug 4995343.To add a code hook to call Federal
  -- package for interest calculation included parameters in
  -- the below call

PROCEDURE ap_custom_calculate_interest(
     P_invoice_id                     IN   NUMBER,
     P_sys_auto_calc_int_flag         IN   VARCHAR2, --bug 4995343
     P_auto_calculate_interest_flag   IN   VARCHAR2, --bug 4995343
     P_check_date                     IN   DATE,
     P_payment_num                    IN   NUMBER,
     P_amount_remaining               IN   NUMBER, --bug 4995343
     P_discount_taken                 IN   NUMBER, --bug 4995343
     P_discount_available             IN   NUMBER, --bug 4995343
     P_currency_code                  IN   VARCHAR2,
     P_payment_amount                 IN   NUMBER,
     P_interest_amount                OUT  NOCOPY   NUMBER,
     P_invoice_due_date		    IN	 DATE );

END AP_CUSTOM_INT_INV_PKG;

 

/
