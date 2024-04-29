--------------------------------------------------------
--  DDL for Package WIP_OPERATION_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OPERATION_RESOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: wiporess.pls 120.0 2005/05/24 18:39:13 appldev noship $ */

/*=====================================================================+
 | PROCEDURE
 |   ADD_RESOURCE
 |
 | PURPOSE
 |   Add a resource to the resource sequences of a given operation
 |
 | ARGUMENTS
 |   IN
 |     p_org_id              Organization ID
 |     p_wip_entity_id       WIP entity ID
 |     p_first_schedule_id   ID of the first open schedule
 |     p_operation_seq_num   Sequence of operation of the new resource
 |     p_resource_seq_num    Sequence of resource to be added
 |     p_resource_id         ID of the new resource
 |     p_uom_code            Primary UOM of the new resource
 |     p_basis_type          The resource's basis type; e.g. item or lot
 |     p_activity_id         ID of the resource's default activity
 |     p_standard_rate_flag  Flag whether to charge at standard rate or not
 |     p_start_date          The resource's scheduled start date
 |     p_completion_date     The resource's scheduled completion date
 |
 | EXCEPTIONS
 |  Calls FND_MESSAGE.RAISE_ERROR after setting an error message if
 |  an identical resource is detected
 |
 | NOTES
 |
 +=====================================================================*/
  procedure add_resource(
    p_org_id             in  number,
    p_wip_entity_id      in  number,
    p_first_schedule_id  in  number,
    p_operation_seq_num  in  number,
    p_resource_seq_num   in  number,
    p_resource_id        in  number,
    p_uom_code           in  varchar2,
    p_basis_type         in  number,
    p_activity_id        in  number,
    p_standard_rate_flag in  number,
    p_start_date         in  date,
    p_completion_date    in  date);

/*=====================================================================+
 | PROCEDURE
 |   CHECK_DUP_RESOURCE
 |
 | PURPOSE
 |   Checks if newly added resources are duplicated
 |
 | ARGUMENTS
 |   IN
 |     p_group_id            Group ID
 |
 |   OUT
 |     p_operation_seq_num   Operation seq num where resource is duplicated
 |     p_resource_seq_num    Resource seq num where resource is duplicated
 |     p_dup_exists          Flag indicating a duplicate exists
 |
 | EXCEPTIONS
 |
 | NOTES
 |   This procedure checks whether a duplicate added resource exists.
 |   This procedure checks WIP_COST_TXN_INTERFACE given a group ID and
 |   check if there are any two records with that group ID that are adding
 |   a resource on the fly for the same job/schedule, operation sequence,
 |   resource sequence, but different resource ID.  Since you cannot add
 |   multiple resources on the fly to the same operation sequence and
 |   resource sequence, this procedure indicates a duplicate exists by
 |   setting p_dup_exists to TRUE.
 |   The column SOURCE_CODE is used to indicate that a new resource has
 |   been added by indicating 'NEW_RES'.
 |
 +=====================================================================*/
  procedure check_dup_resources(
    p_group_id          in  number,
    p_operation_seq_num out nocopy number,
    p_resource_seq_num  out nocopy number,
    p_dup_exists        out nocopy boolean);

/*=====================================================================+
 | PROCEDURE
 |   ADD_RESOURCES
 |
 | PURPOSE
 |   Adds new resources on the fly to a job/schedule
 |
 | ARGUMENTS
 |   IN
 |     p_group_id            Group ID
 |
 | EXCEPTIONS
 |
 | NOTES
 |   This procedure takes records in WIP_COST_TXN_INTERFACE that indicate
 |   adding a resource on the fly ('NEW_RES' in column SOURCE_CODE), and
 |   inserts new resources into WIP_OEPRATION_RESOURCES for the given
 |   job/schedule, org, operation seq, resource seq, and resource.
 |   After adding resources, the procedure deletes all records of the
 |   group ID that has transaction quantity = 0.  Then it updates all
 |   records of that group ID by setting the SOURCE_CODE column to NULL
 |   If adding an operation on the fly, be sure you've added the operation
 |   to WIP_OPERATIONS before calling this procedure.
 |
 +=====================================================================*/
  procedure add_resources(p_group_id in number);

/*=====================================================================+
 | PROCEDURE
 |   CHECK_PO_AND_REQ
 |
 | PURPOSE
 |   Check any PO or REQ linked to the resource before deleting resource
 |
 | ARGUMENTS
 |   IN
 |     p_org_id              Organization ID
 |     p_wip_entity_id       WIP entity ID
 |     p_operation_seq_num   Sequence of operation of the new resource
 |     p_resource_seq_num    Sequence of resource to be added
 |     p_rep_sched_id        Repetitive Schedule ID
 |
 |
 | EXCEPTIONS
 |  Calls FND_MESSAGE.RAISE_ERROR after setting an error message if
 |  a PO or REQ is found
 |
 | NOTES
 |
   +=====================================================================*/
  FUNCTION CHECK_PO_AND_REQ(
        p_org_id                IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_operation_seq_num     IN  NUMBER,
        p_resource_seq_num      IN  NUMBER,
        p_rep_sched_id          IN  NUMBER) RETURN BOOLEAN;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Resource_Seq_Num               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Uom_Code                       VARCHAR2,
                       X_Basis_Type                     NUMBER,
                       X_Usage_Rate_Or_Amount           NUMBER,
                       X_Activity_Id                    NUMBER,
                       X_Scheduled_Flag                 NUMBER,
                       X_Assigned_Units                 NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Applied_Resource_Units         NUMBER,
                       X_Applied_Resource_Value         NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Completion_Date                DATE,
                       X_Start_Date                     DATE,
                       X_Schedule_Seq_Num               NUMBER,
                       X_Substitute_Group_Num           NUMBER,
                       X_Replacement_Group_Num          NUMBER,
                       X_Parent_Resource_Seq            NUMBER,
                       X_SetUp_Id                       NUMBER DEFAULT NULL
                      );


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Operation_Seq_Num                NUMBER,
                     X_Resource_Seq_Num                 NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Repetitive_Schedule_Id           NUMBER,
                     X_Resource_Id                      NUMBER,
                     X_Uom_Code                         VARCHAR2,
                     X_Basis_Type                       NUMBER,
                     X_Usage_Rate_Or_Amount             NUMBER,
                     X_Activity_Id                      NUMBER,
                     X_Scheduled_Flag                   NUMBER,
                     X_Assigned_Units                   NUMBER,
                     X_Autocharge_Type                  NUMBER,
                     X_Standard_Rate_Flag               NUMBER,
                     X_Applied_Resource_Units           NUMBER,
                     X_Applied_Resource_Value           NUMBER,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Completion_Date                  DATE,
                     X_Start_Date                       DATE,
                     X_Schedule_Seq_Num                 NUMBER,
                     X_Substitute_Group_Num             NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Resource_Seq_Num               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Uom_Code                       VARCHAR2,
                       X_Basis_Type                     NUMBER,
                       X_Usage_Rate_Or_Amount           NUMBER,
                       X_Activity_Id                    NUMBER,
                       X_Scheduled_Flag                 NUMBER,
                       X_Assigned_Units                 NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Applied_Resource_Units         NUMBER,
                       X_Applied_Resource_Value         NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Completion_Date                DATE,
                       X_Start_Date                     DATE,
                       X_Schedule_Seq_Num               NUMBER,
                       X_Substitute_Group_Num           NUMBER,
                       X_Replacement_Group_Num          NUMBER,
                       X_Parent_Resource_Seq            NUMBER,
                       X_SetUp_Id                       NUMBER DEFAULT NULL
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END WIP_OPERATION_RESOURCES_PKG;

 

/
