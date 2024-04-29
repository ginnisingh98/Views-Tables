--------------------------------------------------------
--  DDL for Package AR_LL_RCV_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_LL_RCV_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRWSLTS.pls 120.3.12000000.3 2008/08/26 14:02:34 dgaurab ship $ */

/*Bug 7311231, Added parameter p_attribute_rec in procedure Insert_Row, Insert_lintax_Rows,
  Insert_frt_Rows and Insert_chg_Rows */
PROCEDURE Insert_Row (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_lin                 in        number,
    x_tax             in number                ,
    X_frt                 in        number,
    x_chg             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    X_frt_dsc                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency /* Bug 5189370 */
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 := arpcurr.FunctionalCurrency
    ,x_attribute_category IN VARCHAR2 DEFAULT NULL
    ,x_attribute1 IN VARCHAR2 DEFAULT NULL
    ,x_attribute2 IN VARCHAR2 DEFAULT NULL
    ,x_attribute3 IN VARCHAR2 DEFAULT NULL
    ,x_attribute4 IN VARCHAR2 DEFAULT NULL
    ,x_attribute5 IN VARCHAR2 DEFAULT NULL
    ,x_attribute6 IN VARCHAR2 DEFAULT NULL
    ,x_attribute7 IN VARCHAR2 DEFAULT NULL
    ,x_attribute8 IN VARCHAR2 DEFAULT NULL
    ,x_attribute9 IN VARCHAR2 DEFAULT NULL
    ,x_attribute10 IN VARCHAR2 DEFAULT NULL
    ,x_attribute11 IN VARCHAR2 DEFAULT NULL
    ,x_attribute12 IN VARCHAR2 DEFAULT NULL
    ,x_attribute13 IN VARCHAR2 DEFAULT NULL
    ,x_attribute14 IN VARCHAR2 DEFAULT NULL
    ,x_attribute15 IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE Insert_lintax_Rows (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_lin                 in        number,
    x_tax             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency /* Bug 5189370 */
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 := arpcurr.FunctionalCurrency
    ,p_attribute_category IN VARCHAR2 DEFAULT NULL
    ,p_attribute1 IN VARCHAR2 DEFAULT NULL
    ,p_attribute2 IN VARCHAR2 DEFAULT NULL
    ,p_attribute3 IN VARCHAR2 DEFAULT NULL
    ,p_attribute4 IN VARCHAR2 DEFAULT NULL
    ,p_attribute5 IN VARCHAR2 DEFAULT NULL
    ,p_attribute6 IN VARCHAR2 DEFAULT NULL
    ,p_attribute7 IN VARCHAR2 DEFAULT NULL
    ,p_attribute8 IN VARCHAR2 DEFAULT NULL
    ,p_attribute9 IN VARCHAR2 DEFAULT NULL
    ,p_attribute10 IN VARCHAR2 DEFAULT NULL
    ,p_attribute11 IN VARCHAR2 DEFAULT NULL
    ,p_attribute12 IN VARCHAR2 DEFAULT NULL
    ,p_attribute13 IN VARCHAR2 DEFAULT NULL
    ,p_attribute14 IN VARCHAR2 DEFAULT NULL
    ,p_attribute15 IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE Insert_frt_Rows (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_frt                 in        number,
    X_frt_dsc                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency /* Bug 5189370 */
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 := arpcurr.FunctionalCurrency
    ,x_comments      in varchar2 default NULL  /* Bug 5453663 */
    ,p_attribute_category IN VARCHAR2 DEFAULT NULL
    ,p_attribute1 IN VARCHAR2 DEFAULT NULL
    ,p_attribute2 IN VARCHAR2 DEFAULT NULL
    ,p_attribute3 IN VARCHAR2 DEFAULT NULL
    ,p_attribute4 IN VARCHAR2 DEFAULT NULL
    ,p_attribute5 IN VARCHAR2 DEFAULT NULL
    ,p_attribute6 IN VARCHAR2 DEFAULT NULL
    ,p_attribute7 IN VARCHAR2 DEFAULT NULL
    ,p_attribute8 IN VARCHAR2 DEFAULT NULL
    ,p_attribute9 IN VARCHAR2 DEFAULT NULL
    ,p_attribute10 IN VARCHAR2 DEFAULT NULL
    ,p_attribute11 IN VARCHAR2 DEFAULT NULL
    ,p_attribute12 IN VARCHAR2 DEFAULT NULL
    ,p_attribute13 IN VARCHAR2 DEFAULT NULL
    ,p_attribute14 IN VARCHAR2 DEFAULT NULL
    ,p_attribute15 IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE Insert_chg_Rows (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_chg                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency /* Bug 5189370 */
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 := arpcurr.FunctionalCurrency
    ,p_attribute_category IN VARCHAR2 DEFAULT NULL
    ,p_attribute1 IN VARCHAR2 DEFAULT NULL
    ,p_attribute2 IN VARCHAR2 DEFAULT NULL
    ,p_attribute3 IN VARCHAR2 DEFAULT NULL
    ,p_attribute4 IN VARCHAR2 DEFAULT NULL
    ,p_attribute5 IN VARCHAR2 DEFAULT NULL
    ,p_attribute6 IN VARCHAR2 DEFAULT NULL
    ,p_attribute7 IN VARCHAR2 DEFAULT NULL
    ,p_attribute8 IN VARCHAR2 DEFAULT NULL
    ,p_attribute9 IN VARCHAR2 DEFAULT NULL
    ,p_attribute10 IN VARCHAR2 DEFAULT NULL
    ,p_attribute11 IN VARCHAR2 DEFAULT NULL
    ,p_attribute12 IN VARCHAR2 DEFAULT NULL
    ,p_attribute13 IN VARCHAR2 DEFAULT NULL
    ,p_attribute14 IN VARCHAR2 DEFAULT NULL
    ,p_attribute15 IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Update_Row (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_lin                 in        number,
    x_tax             in number                ,
    X_frt                 in        number,
    x_chg             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    X_frt_dsc                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency /* Bug 5189370 */
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 := arpcurr.FunctionalCurrency
);

PROCEDURE Lock_Row (
    X_CUSTOMER_TRX_ID				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    x_object_Version_number in number
) ;

PROCEDURE Delete_Row (
    X_CUSTOMER_TRX_ID  				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
);


END AR_LL_RCV_SUMMARY_PKG ;


 

/
