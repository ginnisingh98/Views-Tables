--------------------------------------------------------
--  DDL for Package QASLSP_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QASLSP_TABLE_HANDLER_PKG" AUTHID CURRENT_USER as
/* $Header: qaslsps.pls 115.2 2002/11/27 19:19:25 jezheng ship $ */

PROCEDURE insert_sl_sp_rcv_criteria_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          IN OUT NOCOPY NUMBER,
      X_Organization_id      NUMBER,
      X_Vendor_id            NUMBER       DEFAULT -1,
      X_Vendor_Site_id       NUMBER       DEFAULT -1,
      X_Item_id              NUMBER       DEFAULT -1,
      X_Item_Revision        VARCHAR2     DEFAULT '-1',
      X_Category_id          NUMBER       DEFAULT -1,
      X_Manufacturer_id      NUMBER       DEFAULT -1,
      X_Project_id           NUMBER       DEFAULT -1,
      X_Task_id              NUMBER       DEFAULT -1,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE insert_sp_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Collection_Plan_id   NUMBER       DEFAULT -1,
      X_SP_WF_Role_Name      VARCHAR2,
      X_SP_Effective_From    DATE,
      X_SP_Effective_To      DATE,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE insert_sl_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Process_id           NUMBER,
      X_SL_WF_Role_Name      VARCHAR2,
      X_SL_Effective_From    DATE,
      X_SL_Effective_To      DATE,
      X_Lotsize_From         NUMBER,
      X_Lotsize_To           NUMBER,
      X_Insp_Stage           VARCHAR2,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE update_sl_sp_rcv_criteria_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Organization_id      NUMBER,
      X_Vendor_id            NUMBER       DEFAULT -1,
      X_Vendor_Site_id       NUMBER       DEFAULT -1,
      X_Item_id              NUMBER       DEFAULT -1,
      X_Item_Revision        VARCHAR2     DEFAULT '-1',
      X_Category_id          NUMBER       DEFAULT -1,
      X_Manufacturer_id      NUMBER       DEFAULT -1,
      X_Project_id           NUMBER       DEFAULT -1,
      X_Task_id              NUMBER       DEFAULT -1,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE update_sp_association_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Collection_Plan_id   NUMBER       DEFAULT -1,
      X_SP_WF_Role_Name      VARCHAR2,
      X_SP_Effective_From    DATE,
      X_SP_Effective_To      DATE,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE update_sl_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Process_id           NUMBER,
      X_SL_WF_Role_Name      VARCHAR2,
      X_SL_Effective_From    DATE,
      X_SL_Effective_To      DATE,
      X_Lotsize_From         NUMBER,
      X_Lotsize_To           NUMBER,
      X_Insp_Stage           VARCHAR2,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE lock_sl_sp_rcv_criteria_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Organization_id      NUMBER,
      X_Vendor_id            NUMBER       DEFAULT -1,
      X_Vendor_Site_id       NUMBER       DEFAULT -1,
      X_Item_id              NUMBER       DEFAULT -1,
      X_Item_Revision        VARCHAR2     DEFAULT '-1',
      X_Category_id          NUMBER       DEFAULT -1,
      X_Manufacturer_id      NUMBER       DEFAULT -1,
      X_Project_id           NUMBER       DEFAULT -1,
      X_Task_id              NUMBER       DEFAULT -1,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE lock_sp_association_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Collection_Plan_id   NUMBER       DEFAULT -1,
      X_SP_WF_Role_Name      VARCHAR2,
      X_SP_Effective_From    DATE,
      X_SP_Effective_To      DATE,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE lock_sl_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Process_id           NUMBER,
      X_SL_WF_Role_Name      VARCHAR2,
      X_SL_Effective_From    DATE,
      X_SL_Effective_To      DATE,
      X_Lotsize_From         NUMBER,
      X_Lotsize_To           NUMBER,
      X_Insp_Stage           VARCHAR2,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
);


PROCEDURE delete_sl_sp_rcv_criteria_row(X_Rowid VARCHAR2);

PROCEDURE delete_sp_association_row(X_Rowid VARCHAR2);

PROCEDURE delete_sl_association_row(X_Rowid VARCHAR2);


END QASLSP_TABLE_HANDLER_PKG;

 

/
