--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_HEADERS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_HEADERS_PKG1" as
/* $Header: POXRIH2B.pls 120.1.12010000.3 2012/08/31 08:55:35 hliao ship $ */

/**************************************************************************/
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
c_log_head    CONSTANT VARCHAR2(40) := 'po.plsql.PO_REQUISITION_HEADERS_PKG1.';

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Requisition_Header_Id            NUMBER,
                     X_Preparer_Id                      NUMBER,
                     X_Segment1                         VARCHAR2,
                     X_Summary_Flag                     VARCHAR2,
                     X_Enabled_Flag                     VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE,
                     X_Description                      VARCHAR2,
                     X_Authorization_Status             VARCHAR2,
                     X_Note_To_Authorizer               VARCHAR2,
                     X_Type_Lookup_Code                 VARCHAR2,
                     X_Transferred_To_Oe_Flag           VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_On_Line_Flag                     VARCHAR2,
                     X_Preliminary_Research_Flag        VARCHAR2,
                     X_Research_Complete_Flag           VARCHAR2,
                     X_Preparer_Finished_Flag           VARCHAR2,
                     X_Preparer_Finished_Date           DATE,
                     X_Agent_Return_Flag                VARCHAR2,
                     X_Agent_Return_Note                VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
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
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Interface_Source_Code            VARCHAR2,
                     X_Interface_Source_Line_Id         NUMBER,
                     X_Closed_Code                      VARCHAR2

  ) IS

    CURSOR C IS
        SELECT *
        FROM   PO_REQUISITION_HEADERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Requisition_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;
	l_api_name CONSTANT VARCHAR2(30) := 'Lock_Row';
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

               (Recinfo.requisition_header_id = X_Requisition_Header_Id)
           AND (Recinfo.preparer_id = X_Preparer_Id)
           AND (TRIM(Recinfo.segment1) = TRIM(X_Segment1))
           AND (TRIM(Recinfo.summary_flag) = TRIM(X_Summary_Flag))
           AND (TRIM(Recinfo.enabled_flag) = TRIM(X_Enabled_Flag))
           AND (   (TRIM(Recinfo.segment2) = TRIM(X_Segment2))
                OR (    (TRIM(Recinfo.segment2) IS NULL)
                    AND (TRIM(X_Segment2) IS NULL)))
           AND (   (TRIM(Recinfo.segment3) = TRIM(X_Segment3))
                OR (    (TRIM(Recinfo.segment3) IS NULL)
                    AND (TRIM(X_Segment3) IS NULL)))
           AND (   (TRIM(Recinfo.segment4) = TRIM(X_Segment4))
                OR (    (TRIM(Recinfo.segment4) IS NULL)
                    AND (TRIM(X_Segment4) IS NULL)))
           AND (   (TRIM(Recinfo.segment5) = TRIM(X_Segment5))
                OR (    (TRIM(Recinfo.segment5) IS NULL)
                    AND (TRIM(X_Segment5) IS NULL)))
           AND (   (Recinfo.start_date_active = X_Start_Date_Active)
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
           AND (   (Recinfo.end_date_active = X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
           AND (   (TRIM(Recinfo.description) = TRIM(X_Description))
                OR (    (TRIM(Recinfo.description) IS NULL)
                    AND (TRIM(X_Description) IS NULL)))
           AND (   (TRIM(Recinfo.authorization_status) = TRIM(X_Authorization_Status))
                OR (    (TRIM(Recinfo.authorization_status) IS NULL)
                    AND (TRIM(X_Authorization_Status) IS NULL)))
           AND (   (TRIM(Recinfo.note_to_authorizer) = TRIM(X_Note_To_Authorizer))
                OR (    (TRIM(Recinfo.note_to_authorizer) IS NULL)
                    AND (TRIM(X_Note_To_Authorizer) IS NULL)))
           AND (   (TRIM(Recinfo.type_lookup_code) = TRIM(X_Type_Lookup_Code))
                OR (    (TRIM(Recinfo.type_lookup_code) IS NULL)
                    AND (TRIM(X_Type_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.transferred_to_oe_flag) = TRIM(X_Transferred_To_Oe_Flag))
                OR (    (TRIM(Recinfo.transferred_to_oe_flag) IS NULL)
                    AND (TRIM(X_Transferred_To_Oe_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.attribute_category) = TRIM(X_Attribute_Category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_Attribute_Category) IS NULL)))
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
           AND (   (TRIM(Recinfo.on_line_flag) = TRIM(X_On_Line_Flag))
                OR (    (TRIM(Recinfo.on_line_flag) IS NULL)
                    AND (TRIM(X_On_Line_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.preliminary_research_flag) = TRIM(X_Preliminary_Research_Flag))
                OR (    (TRIM(Recinfo.preliminary_research_flag) IS NULL)
                    AND (TRIM(X_Preliminary_Research_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.research_complete_flag) = TRIM(X_Research_Complete_Flag))
                OR (    (TRIM(Recinfo.research_complete_flag) IS NULL)
                    AND (TRIM(X_Research_Complete_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.preparer_finished_flag) = TRIM(X_Preparer_Finished_Flag))
                OR (    (TRIM(Recinfo.preparer_finished_flag) IS NULL)
                    AND (TRIM(X_Preparer_Finished_Flag) IS NULL)))
           AND (   (Recinfo.preparer_finished_date = X_Preparer_Finished_Date)
                OR (    (Recinfo.preparer_finished_date IS NULL)
                    AND (X_Preparer_Finished_Date IS NULL)))
           AND (   (TRIM(Recinfo.agent_return_flag) = TRIM(X_Agent_Return_Flag))
                OR (    (TRIM(Recinfo.agent_return_flag) IS NULL)
                    AND (TRIM(X_Agent_Return_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.agent_return_note) = TRIM(X_Agent_Return_Note))
                OR (    (TRIM(Recinfo.agent_return_note) IS NULL)
                    AND (TRIM(X_Agent_Return_Note) IS NULL)))
           AND (   (TRIM(Recinfo.cancel_flag) = TRIM(X_Cancel_Flag))
                OR (    (TRIM(Recinfo.cancel_flag) IS NULL)
                    AND (TRIM(X_Cancel_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_Attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.attribute7) = TRIM(X_Attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_Attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_Attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_Attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_Attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_Attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_Attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_Attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_Attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_Attribute15) IS NULL)))
           AND (   (TRIM(Recinfo.government_context) = TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (TRIM(Recinfo.interface_source_code) = TRIM(X_Interface_Source_Code))
                OR (    (TRIM(Recinfo.interface_source_code) IS NULL)
                    AND (TRIM(X_Interface_Source_Code) IS NULL)))
           AND (   (Recinfo.interface_source_line_id = X_Interface_Source_Line_Id)
                OR (    (Recinfo.interface_source_line_id IS NULL)
                    AND (X_Interface_Source_Line_Id IS NULL)))
           AND (   (TRIM(Recinfo.closed_code) = TRIM(X_Closed_Code))
                OR (    (TRIM(Recinfo.closed_code) IS NULL)
                    AND (TRIM(X_Closed_Code) IS NULL)))

            ) then
      return;
    else

	    IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Requisition_Header_Id,-999) <> NVL(Recinfo.requisition_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form requisition_header_id'||X_Requisition_Header_Id ||' Database  requisition_header_id '|| Recinfo.requisition_header_id);
        END IF;
        IF (NVL(X_Preparer_Id,-999) <> NVL(Recinfo.preparer_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preparer_id'||X_Preparer_Id ||' Database  preparer_id '|| Recinfo.preparer_id);
        END IF;
        IF (NVL(TRIM(X_Segment1),'-999') <> NVL( TRIM(Recinfo.segment1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form segment1 '||X_Segment1 ||' Database  segment1 '||Recinfo.segment1);
        END IF;
        IF (NVL(TRIM(X_Summary_Flag),'-999') <> NVL( TRIM(Recinfo.summary_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form summary_flag '||X_Summary_Flag ||' Database  summary_flag '||Recinfo.summary_flag);
        END IF;
        IF (NVL(TRIM(X_Enabled_Flag),'-999') <> NVL( TRIM(Recinfo.enabled_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form enabled_flag '||X_Enabled_Flag ||' Database  enabled_flag '||Recinfo.enabled_flag);
        END IF;
        IF (NVL(TRIM(X_Segment2),'-999') <> NVL( TRIM(Recinfo.segment2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form segment2 '||X_Segment2 ||' Database  segment2 '||Recinfo.segment2);
        END IF;
        IF (NVL(TRIM(X_Segment3),'-999') <> NVL( TRIM(Recinfo.segment3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form segment3 '||X_Segment3 ||' Database  segment3 '||Recinfo.segment3);
        END IF;
        IF (NVL(TRIM(X_Segment4),'-999') <> NVL( TRIM(Recinfo.segment4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form segment4 '||X_Segment4 ||' Database  segment4 '||Recinfo.segment4);
        END IF;
        IF (NVL(TRIM(X_Segment5),'-999') <> NVL( TRIM(Recinfo.segment5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form segment5 '||X_Segment5 ||' Database  segment5 '||Recinfo.segment5);
        END IF;
        IF (X_Start_Date_Active <> Recinfo.start_date_active ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form start_date_active '||X_Start_Date_Active ||' Database  start_date_active '||Recinfo.start_date_active);
        END IF;
        IF (X_End_Date_Active <> Recinfo.end_date_active ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form end_date_active '||X_End_Date_Active ||' Database  end_date_active '||Recinfo.end_date_active);
        END IF;
        IF (NVL(TRIM(X_Description),'-999') <> NVL( TRIM(Recinfo.description),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form description '||X_Description ||' Database  description '||Recinfo.description);
        END IF;
        IF (NVL(TRIM(X_Authorization_Status),'-999') <> NVL( TRIM(Recinfo.authorization_status),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form authorization_status '||X_Authorization_Status ||' Database  authorization_status '||Recinfo.authorization_status);
        END IF;
        IF (NVL(TRIM(X_Note_To_Authorizer),'-999') <> NVL( TRIM(Recinfo.note_to_authorizer),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form note_to_authorizer '||X_Note_To_Authorizer ||' Database  note_to_authorizer '||Recinfo.note_to_authorizer);
        END IF;
        IF (NVL(TRIM(X_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form type_lookup_code '||X_Type_Lookup_Code ||' Database  type_lookup_code '||Recinfo.type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Transferred_To_Oe_Flag),'-999') <> NVL( TRIM(Recinfo.transferred_to_oe_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form transferred_to_oe_flag '||X_Transferred_To_Oe_Flag ||' Database  transferred_to_oe_flag '||Recinfo.transferred_to_oe_flag);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_On_Line_Flag),'-999') <> NVL( TRIM(Recinfo.on_line_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form on_line_flag '||X_On_Line_Flag ||' Database  on_line_flag '||Recinfo.on_line_flag);
        END IF;
        IF (NVL(TRIM(X_Preliminary_Research_Flag),'-999') <> NVL( TRIM(Recinfo.preliminary_research_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preliminary_research_flag '||X_Preliminary_Research_Flag ||' Database  preliminary_research_flag '||Recinfo.preliminary_research_flag);
        END IF;
        IF (NVL(TRIM(X_Research_Complete_Flag),'-999') <> NVL( TRIM(Recinfo.research_complete_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form research_complete_flag '||X_Research_Complete_Flag ||' Database  research_complete_flag '||Recinfo.research_complete_flag);
        END IF;
        IF (NVL(TRIM(X_Preparer_Finished_Flag),'-999') <> NVL( TRIM(Recinfo.preparer_finished_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preparer_finished_flag '||X_Preparer_Finished_Flag ||' Database  preparer_finished_flag '||Recinfo.preparer_finished_flag);
        END IF;
        IF (X_Preparer_Finished_Date <> Recinfo.preparer_finished_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preparer_finished_date '||X_Preparer_Finished_Date ||' Database  preparer_finished_date '||Recinfo.preparer_finished_date);
        END IF;
        IF (NVL(TRIM(X_Agent_Return_Flag),'-999') <> NVL( TRIM(Recinfo.agent_return_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form agent_return_flag '||X_Agent_Return_Flag ||' Database  agent_return_flag '||Recinfo.agent_return_flag);
        END IF;
        IF (NVL(TRIM(X_Agent_Return_Note),'-999') <> NVL( TRIM(Recinfo.agent_return_note),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form agent_return_note '||X_Agent_Return_Note ||' Database  agent_return_note '||Recinfo.agent_return_note);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (NVL(TRIM(X_Interface_Source_Code),'-999') <> NVL( TRIM(Recinfo.interface_source_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form interface_source_code '||X_Interface_Source_Code ||' Database  interface_source_code '||Recinfo.interface_source_code);
        END IF;
        IF (NVL(X_Interface_Source_Line_Id,-999) <> NVL(Recinfo.interface_source_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form interface_source_line_id'||X_Interface_Source_Line_Id ||' Database  interface_source_line_id '|| Recinfo.interface_source_line_id);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
    END IF;

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

 EXCEPTION   --Bug 12373682
      WHEN app_exception.record_lock_exception THEN
          po_message_s.app_error ('PO_ALL_CANNOT_RESERVE_RECORD');

  END Lock_Row;

END PO_REQUISITION_HEADERS_PKG1;

/
