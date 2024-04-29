--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG7" as
/* $Header: POXRIL7B.pls 120.0.12010000.2 2012/08/31 09:06:29 hliao ship $ */
	 c_log_head    CONSTANT VARCHAR2(40) := 'po.plsql.PO_REQUISITION_LINES_PKG7.';
	 g_fnd_debug   CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE Lock2_Row(X_Rowid                           VARCHAR2,
                     X_Research_Agent_Id                NUMBER,
                     X_On_Line_Flag                     VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Wip_Line_Id                      NUMBER,
                     X_Wip_Repetitive_Schedule_Id       NUMBER,
                     X_Wip_Operation_Seq_Num            NUMBER,
                     X_Wip_Resource_Seq_Num             NUMBER,
                     X_Attribute_Category               VARCHAR2,
                     X_Destination_Context              VARCHAR2,
                     X_Inventory_Source_Context         VARCHAR2,
                     X_Vendor_Source_Context            VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2
  ) IS

    CURSOR C IS
        SELECT *
        FROM   PO_REQUISITION_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Requisition_Line_Id NOWAIT;

    Recinfo C%ROWTYPE;
 --For debugging Purposes.
 	     l_api_name CONSTANT VARCHAR2(30) := 'Lock2_Row';
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (

               (   (Recinfo.research_agent_id = X_Research_Agent_Id)
                OR (    (Recinfo.research_agent_id IS NULL)
                    AND (X_Research_Agent_Id IS NULL)))
           AND (   (TRIM(Recinfo.on_line_flag) = TRIM(X_On_Line_Flag))
                OR (    (TRIM(Recinfo.on_line_flag) IS NULL)
                    AND (TRIM(X_On_Line_Flag) IS NULL)))
           AND (   (Recinfo.wip_entity_id = X_Wip_Entity_Id)
                OR (    (Recinfo.wip_entity_id IS NULL)
                    AND (X_Wip_Entity_Id IS NULL)))
           AND (   (Recinfo.wip_line_id = X_Wip_Line_Id)
                OR (    (Recinfo.wip_line_id IS NULL)
                    AND (X_Wip_Line_Id IS NULL)))
           AND (   (Recinfo.wip_repetitive_schedule_id = X_Wip_Repetitive_Schedule_Id)
                OR (    (Recinfo.wip_repetitive_schedule_id IS NULL)
                    AND (X_Wip_Repetitive_Schedule_Id IS NULL)))
           AND (   (Recinfo.wip_operation_seq_num = X_Wip_Operation_Seq_Num)
                OR (    (Recinfo.wip_operation_seq_num IS NULL)
                    AND (X_Wip_Operation_Seq_Num IS NULL)))
           AND (   (Recinfo.wip_resource_seq_num = X_Wip_Resource_Seq_Num)
                OR (    (Recinfo.wip_resource_seq_num IS NULL)
                    AND (X_Wip_Resource_Seq_Num IS NULL)))
           AND (   (TRIM(Recinfo.attribute_category) = TRIM(X_Attribute_Category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.destination_context) = TRIM(X_Destination_Context))
                OR (    (TRIM(Recinfo.destination_context) IS NULL)
                    AND (TRIM(X_Destination_Context) IS NULL)))
           AND (   (TRIM(Recinfo.inventory_source_context) = TRIM(X_Inventory_Source_Context))
                OR (    (TRIM(Recinfo.inventory_source_context) IS NULL)
                    AND (TRIM(X_Inventory_Source_Context) IS NULL)))
           AND (   (TRIM(Recinfo.vendor_source_context) = TRIM(X_Vendor_Source_Context))
                OR (    (TRIM(Recinfo.vendor_source_context) IS NULL)
                    AND (TRIM(X_Vendor_Source_Context) IS NULL)))
           AND (   (TRIM(Recinfo.attribute1) = TRIM(X_Attribute1))
                OR (    (TRIM(Recinfo.attribute1) IS NULL)
                    AND (TRIM(X_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.attribute2) = TRIM(X_Attribute2))
                OR (    (TRIM(Recinfo.attribute2) IS NULL)
                    AND (TRIM(X_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.attribute3) = TRIM(X_Attribute3))
                OR (    (TRIM(Recinfo.attribute3) IS NULL)
                    AND (TRIM(X_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.attribute4) = TRIM(X_Attribute4))
                OR (    (TRIM(Recinfo.attribute4) IS NULL)
                    AND (TRIM(X_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.attribute5) = TRIM(X_Attribute5))
                OR (    (TRIM(Recinfo.attribute5) IS NULL)
                    AND (TRIM(X_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_Attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_Attribute6) IS NULL)))
            ) then
      return;
    else

     -- Logging Infra: Procedure level
     IF (g_fnd_debug = 'Y' ) THEN
if (nvl(X_Research_Agent_Id, -999 ) <> nvl(Recinfo.Research_Agent_Id, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Research_Agent_Id '||X_Research_Agent_Id ||' Database  Research_Agent_Id '||Recinfo.Research_Agent_Id);
 end if;
if (nvl(X_On_Line_Flag,'-999') <> nvl(Recinfo.On_Line_Flag,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_On_Line_Flag '||X_On_Line_Flag ||' Database  On_Line_Flag '||Recinfo.On_Line_Flag);
 end if;
if (nvl(X_Wip_Entity_Id, -999 ) <> nvl(Recinfo.Wip_Entity_Id, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Wip_Entity_Id '||X_Wip_Entity_Id ||' Database  Wip_Entity_Id '||Recinfo.Wip_Entity_Id);
 end if;
if (nvl(X_Wip_Line_Id, -999 ) <> nvl(Recinfo.Wip_Line_Id, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Wip_Line_Id '||X_Wip_Line_Id ||' Database  Wip_Line_Id '||Recinfo.Wip_Line_Id);
 end if;
if (nvl(X_Wip_Repetitive_Schedule_Id, -999 ) <> nvl(Recinfo.Wip_Repetitive_Schedule_Id, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Wip_Repetitive_Schedule_Id '||X_Wip_Repetitive_Schedule_Id ||' Database  Wip_Repetitive_Schedule_Id '||Recinfo.Wip_Repetitive_Schedule_Id);
 end if;
if (nvl(X_Wip_Operation_Seq_Num, -999 ) <> nvl(Recinfo.Wip_Operation_Seq_Num, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Wip_Operation_Seq_Num '||X_Wip_Operation_Seq_Num ||' Database  Wip_Operation_Seq_Num '||Recinfo.Wip_Operation_Seq_Num);
 end if;
if (nvl(X_Wip_Resource_Seq_Num, -999 ) <> nvl(Recinfo.Wip_Resource_Seq_Num, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Wip_Resource_Seq_Num '||X_Wip_Resource_Seq_Num ||' Database  Wip_Resource_Seq_Num '||Recinfo.Wip_Resource_Seq_Num);
 end if;
if (nvl(X_Attribute_Category,'-999') <> nvl(Recinfo.Attribute_Category,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute_Category '||X_Attribute_Category ||' Database  Attribute_Category '||Recinfo.Attribute_Category);
 end if;
if (nvl(X_Destination_Context,'-999') <> nvl(Recinfo.Destination_Context,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Destination_Context '||X_Destination_Context ||' Database  Destination_Context '||Recinfo.Destination_Context);
 end if;
if (nvl(X_Inventory_Source_Context,'-999') <> nvl(Recinfo.Inventory_Source_Context,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Inventory_Source_Context '||X_Inventory_Source_Context ||' Database  Inventory_Source_Context '||Recinfo.Inventory_Source_Context);
 end if;
if (nvl(X_Vendor_Source_Context,'-999') <> nvl(Recinfo.Vendor_Source_Context,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Vendor_Source_Context '||X_Vendor_Source_Context ||' Database  Vendor_Source_Context '||Recinfo.Vendor_Source_Context);
 end if;
if (nvl(X_Attribute1,'-999') <> nvl(Recinfo.Attribute1,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute1 '||X_Attribute1 ||' Database  Attribute1 '||Recinfo.Attribute1);
 end if;
if (nvl(X_Attribute2,'-999') <> nvl(Recinfo.Attribute2,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute2 '||X_Attribute2 ||' Database  Attribute2 '||Recinfo.Attribute2);
 end if;
if (nvl(X_Attribute3,'-999') <> nvl(Recinfo.Attribute3,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute3 '||X_Attribute3 ||' Database  Attribute3 '||Recinfo.Attribute3);
 end if;
if (nvl(X_Attribute4,'-999') <> nvl(Recinfo.Attribute4,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute4 '||X_Attribute4 ||' Database  Attribute4 '||Recinfo.Attribute4);
 end if;
if (nvl(X_Attribute5,'-999') <> nvl(Recinfo.Attribute5,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute5 '||X_Attribute5 ||' Database  Attribute5 '||Recinfo.Attribute5);
 end if;
if (nvl(X_Attribute6,'-999') <> nvl(Recinfo.Attribute6,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute6 '||X_Attribute6 ||' Database  Attribute6 '||Recinfo.Attribute6);
 end if;


     END IF;

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

  END Lock2_Row;

END PO_REQUISITION_LINES_PKG7;

/
