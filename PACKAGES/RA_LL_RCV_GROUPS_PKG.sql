--------------------------------------------------------
--  DDL for Package RA_LL_RCV_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RA_LL_RCV_GROUPS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRWGLTS.pls 120.2 2006/01/19 00:10:37 ramenon noship $ */

PROCEDURE Insert_Row (
    X_ROWID				 IN OUT NOCOPY				 ROWID,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_GROUP_ID     				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_line_only               in        number,
    x_tax_only             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    x_CREATED_BY_MODULE in varchar2
    -- Oct 04 added two param below
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 := arpcurr.FunctionalCurrency
);



PROCEDURE Update_Row (
    X_ROWID	         IN OUT NOCOPY  ROWID,
    X_CASH_RECEIPT_ID   IN NUMBER,
    X_GROUP_ID          IN NUMBER,
    X_CUSTOMER_TRX_ID   IN NUMBER,
    X_line_only         in number,
    x_tax_only          in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    x_CREATED_BY_MODULE in varchar2
    -- Oct 04 added two param below
    ,x_inv_to_rct_rate  in number default 1
    ,x_rct_curr_code    in varchar2 := arpcurr.FunctionalCurrency
) ;

PROCEDURE Lock_Row (
    X_CUSTOMER_TRX_ID				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    x_object_Version_number in number
) ;




PROCEDURE Select_Row (
    X_APPLY_TO     				 IN OUT NOCOPY				 VARCHAR2,
    X_TAX_BALANCE  				 IN OUT NOCOPY				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID				 IN OUT NOCOPY				 NUMBER,
    X_COMMENTS     				 IN OUT NOCOPY				 VARCHAR2,
    X_TAX          				 IN OUT NOCOPY				 NUMBER,
    X_CASH_RECEIPT_ID				 IN OUT NOCOPY				 NUMBER,
    X_ATTRIBUTE_CATEGORY				 IN OUT NOCOPY				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT				 IN OUT NOCOPY				 NUMBER,
    X_GROUP_ID     				 IN OUT NOCOPY				 NUMBER,
    X_TAX_DISCOUNT 				 IN OUT NOCOPY				 NUMBER,
    X_AMOUNT       				 IN OUT NOCOPY				 NUMBER,
    X_LINE_DISCOUNT				 IN OUT NOCOPY				 NUMBER,
    X_ATTRIBUTE9   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE8   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE7   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE6   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE5   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE4   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE3   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE2   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE1   				 IN OUT NOCOPY				 VARCHAR2,
    X_LINE_BALANCE 				 IN OUT NOCOPY				 NUMBER,
    X_ATTRIBUTE15  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE14  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE13  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE12  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE11  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE10  				 IN OUT NOCOPY				 VARCHAR2
) ;

PROCEDURE Delete_Row (
    X_GROUP_ID  				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID  				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
) ;


END RA_LL_RCV_GROUPS_PKG;


 

/
