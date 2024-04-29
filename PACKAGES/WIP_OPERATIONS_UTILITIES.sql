--------------------------------------------------------
--  DDL for Package WIP_OPERATIONS_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OPERATIONS_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wipoputs.pls 115.8 2004/03/09 23:49:15 kboonyap ship $ */

  PROCEDURE Check_Unique(X_Wip_Entity_Id                 NUMBER,
                         X_Organization_Id               NUMBER,
                         X_Operation_Seq_Num             NUMBER,
                         X_Repetitive_Schedule_Id        NUMBER);

  FUNCTION Pending_Op_Txns(X_Wip_Entity_Id              NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_Line_Id                       NUMBER)
                return BOOLEAN;

  FUNCTION Get_Previous_Op(X_Wip_Entity_Id                 NUMBER,
                           X_Organization_Id               NUMBER,
                           X_Operation_Seq_Num             NUMBER,
                           X_Repetitive_Schedule_Id        NUMBER)
                return NUMBER;

  PROCEDURE Get_Prev_Next_Op(X_Wip_Entity_Id                 NUMBER,
                             X_Organization_Id               NUMBER,
                             X_Operation_Seq_Num             NUMBER,
                             X_Repetitive_Schedule_Id        NUMBER,
                             X_Insert_Flag                   BOOLEAN,
                             X_Prev_Op_Seq                   IN OUT NOCOPY NUMBER,
                             X_Next_Op_Seq                   IN OUT NOCOPY NUMBER);

  PROCEDURE Set_Previous_Op(X_Wip_Entity_Id             NUMBER,
                            X_Organization_Id           NUMBER,
                            X_Operation_Seq_Num         NUMBER,
                            X_Prev_Op_Seq               NUMBER,
                            X_Repetitive_Schedule_Id    NUMBER);

  PROCEDURE Set_Next_Op(X_Wip_Entity_Id                 NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Next_Op_Seq                   NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER);

  PROCEDURE Delete_Resources(X_Wip_Entity_Id                     NUMBER,
                             X_Organization_Id                   NUMBER,
                             X_Operation_Seq_Num                 NUMBER,
                             X_Repetitive_Schedule_Id            NUMBER,
                             x_return_status          OUT NOCOPY VARCHAR2);

  PROCEDURE Insert_Resources(X_Wip_Entity_Id            NUMBER,
                             X_Organization_Id          NUMBER,
                             X_Operation_Seq_Num        NUMBER,
                             X_Standard_Operation_Id    NUMBER,
                             X_Repetitive_Schedule_Id   NUMBER,
                             X_Last_Updated_By          NUMBER,
                             X_Created_By               NUMBER,
                             X_Last_Update_Login        NUMBER,
                             X_Start_Date               DATE,
                             X_Completion_Date          DATE);

  FUNCTION Num_Standard_Resources(X_Organization_Id             NUMBER,
                                  X_Standard_Operation_Id       NUMBER)
                RETURN NUMBER;

  PROCEDURE Check_Requirements(X_Wip_Entity_Id          NUMBER,
                               X_Organization_Id        NUMBER,
                               X_Operation_Seq_Num      NUMBER,
                               X_Repetitive_Schedule_Id NUMBER,
                               X_Entity_Start_Date      DATE);

  FUNCTION Num_Assembly_Pull(X_Wip_Entity_Id            NUMBER,
                         X_Organization_Id              NUMBER,
                         X_Operation_Seq_Num            NUMBER,
                         X_Repetitive_Schedule_Id       NUMBER)
                return NUMBER;

  FUNCTION Num_Resources(X_Wip_Entity_Id                NUMBER,
                             X_Organization_Id          NUMBER,
                             X_Operation_Seq_Num        NUMBER,
                             X_Repetitive_Schedule_Id   NUMBER)
                return NUMBER;

  PROCEDURE Set_Operation_Dates(X_Wip_Entity_Id         NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_First_Unit_Start_Date         DATE,
                        X_Last_Unit_Completion_Date     DATE,
                        X_Resource_Start_Date           DATE,
                        X_Resource_Completion_Date      DATE);

  PROCEDURE Set_Entity_Dates(X_Wip_Entity_Id            NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_First_Unit_Start_Date         DATE,
                        X_Last_Unit_Completion_Date     DATE);

  PROCEDURE Update_Operationless_Reqs(X_Wip_Entity_Id           NUMBER,
                                      X_Organization_Id         NUMBER,
                                      X_Operation_Seq_Num       NUMBER,
                                      X_Repetitive_Schedule_Id  NUMBER,
                                      X_Department_Id           NUMBER,
                                      X_First_Unit_Start_Date   DATE);

  PROCEDURE Update_Reqs(X_Wip_Entity_Id                 NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_Department_Id                 NUMBER,
                        X_Start_Date                    DATE);

  PROCEDURE Get_Prev_Op_Dates(X_Wip_Entity_Id                   NUMBER,
                              X_Organization_Id                 NUMBER,
                              X_Prev_Operation_Seq_Num          NUMBER,
                              X_Repetitive_Schedule_Id          NUMBER,
                              X_First_Unit_Start_Date    OUT NOCOPY DATE,
                              X_Last_Unit_Start_Date      OUT NOCOPY DATE,
                              X_First_Unit_Completion_Date OUT NOCOPY DATE,
                              X_Last_Unit_Completion_Date OUT NOCOPY DATE);

  PROCEDURE Update_Res_Op_Seq(X_Wip_Entity_Id           NUMBER,
                              X_Organization_Id         NUMBER,
                              X_Old_Operation_Seq_Num   NUMBER,
                              X_New_Operation_Seq_Num   NUMBER,
                              X_Repetitive_Schedule_Id  NUMBER);

  FUNCTION Other_Active_Schedules(X_Wip_Entity_Id  NUMBER,
                                  X_Org_Id         NUMBER,
                                  X_Line_Id        NUMBER) RETURN VARCHAR;

  PROCEDURE rollback_database;


END WIP_OPERATIONS_UTILITIES;

 

/
