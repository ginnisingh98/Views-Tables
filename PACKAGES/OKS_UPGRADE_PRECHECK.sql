--------------------------------------------------------
--  DDL for Package OKS_UPGRADE_PRECHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_UPGRADE_PRECHECK" AUTHID CURRENT_USER AS
/* $Header: OKS22PCS.pls 115.1 2003/12/09 21:44:01 hmedheka noship $ */

PROCEDURE Create_Bus_Process(x_Return_status IN OUT NOCOPY Varchar2,
                             x_Return_Msg IN OUT NOCOPY Varchar2);

PROCEDURE create_bltype(p_billing_type IN varchar2,
                        p_txntype_id   IN number,
                        x_Return_status OUT NOCOPY Varchar2,
                        x_Return_Msg OUT NOCOPY Varchar2);

PROCEDURE Create_Txn_bltypes(x_Return_status OUT NOCOPY Varchar2,
                             x_Return_Msg OUT NOCOPY Varchar2);

PROCEDURE Create_Bus_process_Txn(p_txn_type_id IN Number,
                                 x_Return_status OUT NOCOPY Varchar2,
                                 x_Return_Msg OUT NOCOPY Varchar2);
PROCEDURE Insert_Time_code_units;

PROCEDURE Log_Errors(P_Original_system_Reference IN VARCHAR2,
				 P_Original_System_Reference_Id IN NUMBER,
				 P_Original_System_Ref_Id_Upper IN NUMBER,
				 P_DateTime IN DATE,
				 P_Error_Message IN VARCHAR2);

PROCEDURE Drive_Upg_Check;

PROCEDURE Update_status;

PROCEDURE Update_time_zone;

PROCEDURE Create_Index;

END OKS_UPGRADE_PRECHECK;

 

/
