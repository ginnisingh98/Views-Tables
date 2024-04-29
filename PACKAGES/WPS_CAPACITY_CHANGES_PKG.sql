--------------------------------------------------------
--  DDL for Package WPS_CAPACITY_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WPS_CAPACITY_CHANGES_PKG" AUTHID CURRENT_USER AS
/* $Header: WPSCAPCS.pls 115.2 2002/11/01 01:19:08 jenchang ship $ */


  /**
   * This procedure is used to delete a resource exception
   */
  PROCEDURE Delete_Resource_Exception(X_Rowid VARCHAR2);

  /**
   * This procedure is used to delete a resource instance exception
   */
  PROCEDURE Delete_Resinst_Exception(X_Rowid VARCHAR2);

  /**
   * This procedure is used to update a resource exception
   */
  PROCEDURE Update_Resource_Exception(X_Rowid     VARCHAR2,
                                      X_Shift     NUMBER,
                                      X_Action    NUMBER,
                                      X_Units     NUMBER,
                                      X_From_Date DATE,
                                      X_To_Date   DATE,
                                      X_From_Time NUMBER,
                                      X_To_Time   NUMBER,
                                      X_User_Id   NUMBER,
				      X_REASON_CODE VARCHAR2 DEFAULT NULL);
  /**
   * This procedure is used to insert a resource exception
   */
  PROCEDURE Insert_Resource_Exception(X_Resource_Id   NUMBER,
                                      X_Department_Id NUMBER,
                                      X_Shift         NUMBER,
                                      X_Action        NUMBER,
                                      X_Units         NUMBER,
                                      X_From_Date     DATE,
                                      X_To_Date       DATE,
                                      X_From_Time     NUMBER,
                                      X_To_Time       NUMBER,
                                      X_Sim_Set       VARCHAR2,
                                      X_User_Id       NUMBER,
				      X_REASON_CODE   VARCHAR2 DEFAULT NULL);
  /**
   * This procedure is used to insert a resource instance exception
   */
  PROCEDURE Insert_ResInst_Exception (X_Resource_Id   NUMBER,
                                      X_Department_Id NUMBER,
                                      X_Shift         NUMBER,
                                      X_Action        NUMBER,
                                      X_Units         NUMBER,
                                      X_From_Date     DATE,
                                      X_To_Date       DATE,
                                      X_From_Time     NUMBER,
                                      X_To_Time       NUMBER,
                                      X_Instance_Id   NUMBER,
                                      X_Serial_Num    VARCHAR2,
                                      X_Sim_Set       VARCHAR2,
                                      X_User_Id       NUMBER,
				      X_REASON_CODE   VARCHAR2 DEFAULT NULL);
  /**
   * This procedure is used to update a resource instance exception
   */
  PROCEDURE Update_ResInst_Exception (X_Rowid       VARCHAR2,
                                      X_Shift       NUMBER,
                                      X_Action      NUMBER,
                                      X_Units       NUMBER,
                                      X_From_Date   DATE,
                                      X_To_Date     DATE,
                                      X_From_Time   NUMBER,
                                      X_To_Time     NUMBER,
                                      X_Instance_Id NUMBER,
                                      X_Serial_Num  VARCHAR2,
                                      X_User_Id     NUMBER,
				      X_REASON_CODE VARCHAR2 DEFAULT NULL);

  /**
   * This is a utility procedure to check whether the instance exception will
   * max out the resource assigned units
   */
  PROCEDURE CheckResInstForInsert(X_Resource_Id    NUMBER,
                                  X_Department_Id  NUMBER,
                                  X_Sim_Set        VARCHAR2,
                                  X_Shift          NUMBER,
                                  X_Action         NUMBER,
                                  X_Units          NUMBER,
                                  X_From_Date      DATE,
                                  X_To_Date        DATE,
                                  X_From_Time      NUMBER,
                                  X_To_Time        NUMBER,
                                  X_Return_Id OUT NOCOPY Number);


END WPS_CAPACITY_CHANGES_PKG;

 

/
