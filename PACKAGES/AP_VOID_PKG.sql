--------------------------------------------------------
--  DDL for Package AP_VOID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_VOID_PKG" AUTHID CURRENT_USER AS
/* $Header: apvoidps.pls 120.4 2005/08/22 23:53:22 bghose noship $ */

  PROCEDURE Ap_Reverse_Check
                 (P_Check_Id                    IN     number
                 ,P_Replace_Flag                IN     varchar2
                 ,P_Reversal_Date		IN     date
		 ,P_Reversal_Period_Name	IN     varchar2
		 ,P_Checkrun_Name		IN     varchar2
		 ,P_Invoice_Action		IN     varchar2
		 ,P_Hold_Code			IN     varchar2
		 ,P_Hold_Reason			IN     varchar2
                 ,P_Sys_Auto_Calc_Int_Flag      IN     varchar2
                 ,P_Vendor_Auto_Calc_Int_Flag   IN     varchar2
		 ,P_Last_Updated_By             IN     number
		 ,P_Last_Update_Login		IN     number
		 ,P_Num_Cancelled		OUT NOCOPY  number
		 ,P_Num_Not_Cancelled		OUT NOCOPY  number
                 ,P_Calling_Module              IN     varchar2 default 'SQLAP'
                 ,P_Calling_Sequence            IN     varchar2
                 ,X_return_status               OUT NOCOPY varchar2
                 ,X_msg_count                   OUT NOCOPY number
                 ,X_msg_data                    OUT NOCOPY varchar2
		 );

 /* New procedure to be used by Oracle Payments
    during voiding of payments from their UI */

  PROCEDURE Iby_Void_Check
                 (p_api_version                 IN  NUMBER,
                  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
                  p_payment_id                  IN  NUMBER,
                  p_void_date                   IN  DATE,
                  x_return_status               OUT NOCOPY VARCHAR2,
                  x_msg_count                   OUT NOCOPY VARCHAR2,
                  x_msg_data                    OUT NOCOPY VARCHAR2
                 );

END AP_VOID_PKG;

 

/
