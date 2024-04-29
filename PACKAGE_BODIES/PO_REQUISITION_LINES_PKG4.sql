--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG4" as
/* $Header: POXRIL5B.pls 120.0.12010000.2 2012/08/31 09:01:28 hliao ship $ */
-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_REQUISITION_LINES_PKG4.';

  PROCEDURE Lock4_Row(X_Rowid                            VARCHAR2,
                     X_Item_Revision                    VARCHAR2,
                     X_Quantity_Delivered               NUMBER,
                     X_Suggested_Buyer_Id               NUMBER,
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Rfq_Required_Flag                VARCHAR2,
                     X_Need_By_Date                     DATE,
                     X_Line_Location_Id                 NUMBER,
                     X_Modified_By_Agent_Flag           VARCHAR2,
                     X_Parent_Req_Line_Id               NUMBER,
                     X_Justification                    VARCHAR2,
                     X_Note_To_Agent                    VARCHAR2,
                     X_Note_To_Receiver                 VARCHAR2,
                     X_Purchasing_Agent_Id              NUMBER,
                     X_Document_Type_Code               VARCHAR2,
                     X_Blanket_Po_Header_Id             NUMBER,
                     X_Blanket_Po_Line_Num              NUMBER,
                     X_Currency_Code                    VARCHAR2
  ) IS

    CURSOR C IS
        SELECT *
        FROM   PO_REQUISITION_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Requisition_Line_Id NOWAIT;

    Recinfo C%ROWTYPE;
	 -- For debug purposes
    l_api_name CONSTANT VARCHAR2(30) := 'Lock4_Row';
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
               (   (TRIM(Recinfo.item_revision) = TRIM(X_Item_Revision))
                OR (    (TRIM(Recinfo.item_revision) IS NULL)
                    AND (TRIM(X_Item_Revision) IS NULL)))
           AND (   (Recinfo.quantity_delivered = X_Quantity_Delivered)
                OR (    (Recinfo.quantity_delivered IS NULL)
                    AND (X_Quantity_Delivered IS NULL)))
           AND (   (Recinfo.suggested_buyer_id = X_Suggested_Buyer_Id)
                OR (    (Recinfo.suggested_buyer_id IS NULL)
                    AND (X_Suggested_Buyer_Id IS NULL)))
           AND (   (TRIM(Recinfo.encumbered_flag) = TRIM(X_Encumbered_Flag))
                OR (    (TRIM(Recinfo.encumbered_flag) IS NULL)
                    AND (TRIM(X_Encumbered_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.rfq_required_flag) = TRIM(X_Rfq_Required_Flag))
                OR (    (TRIM(Recinfo.rfq_required_flag) IS NULL)
                    AND (TRIM(X_Rfq_Required_Flag) IS NULL)))
           AND (   (Recinfo.need_by_date = X_Need_By_Date)
                OR (    (Recinfo.need_by_date IS NULL)
                    AND (X_Need_By_Date IS NULL)))
           AND (   (Recinfo.line_location_id = X_Line_Location_Id)
                OR (    (Recinfo.line_location_id IS NULL)
                    AND (X_Line_Location_Id IS NULL)))
           AND (   (TRIM(Recinfo.modified_by_agent_flag) = TRIM(X_Modified_By_Agent_Flag))
                OR (    (TRIM(Recinfo.modified_by_agent_flag) IS NULL)
                    AND (TRIM(X_Modified_By_Agent_Flag) IS NULL)))
           AND (   (Recinfo.parent_req_line_id = X_Parent_Req_Line_Id)
                OR (    (Recinfo.parent_req_line_id IS NULL)
                    AND (X_Parent_Req_Line_Id IS NULL)))
           AND (   (TRIM(Recinfo.justification) = TRIM(X_Justification))
                OR (    (TRIM(Recinfo.justification) IS NULL)
                    AND (TRIM(X_Justification) IS NULL)))
           AND (   (TRIM(Recinfo.note_to_agent) = TRIM(X_Note_To_Agent))
                OR (    (TRIM(Recinfo.note_to_agent) IS NULL)
                    AND (TRIM(X_Note_To_Agent) IS NULL)))
           AND (   (TRIM(Recinfo.note_to_receiver) = TRIM(X_Note_To_Receiver))
                OR (    (TRIM(Recinfo.note_to_receiver) IS NULL)
                    AND (TRIM(X_Note_To_Receiver) IS NULL)))
           AND (   (Recinfo.purchasing_agent_id = X_Purchasing_Agent_Id)
                OR (    (Recinfo.purchasing_agent_id IS NULL)
                    AND (X_Purchasing_Agent_Id IS NULL)))
           AND (   (TRIM(Recinfo.document_type_code) = TRIM(X_Document_Type_Code))
                OR (    (TRIM(Recinfo.document_type_code) IS NULL)
                    AND (TRIM(X_Document_Type_Code) IS NULL)))
           AND (   (Recinfo.blanket_po_header_id = X_Blanket_Po_Header_Id)
                OR (    (Recinfo.blanket_po_header_id IS NULL)
                    AND (X_Blanket_Po_Header_Id IS NULL)))
           AND (   (Recinfo.blanket_po_line_num = X_Blanket_Po_Line_Num)
                OR (    (Recinfo.blanket_po_line_num IS NULL)
                    AND (X_Blanket_Po_Line_Num IS NULL)))
           AND (   (TRIM(Recinfo.currency_code) = TRIM(X_Currency_Code))
                OR (    (TRIM(Recinfo.currency_code) IS NULL)
                    AND (TRIM(X_Currency_Code) IS NULL)))
            ) then
      return;
    else

	    IF (g_fnd_debug = 'Y') THEN
        IF (NVL(TRIM(X_Item_Revision),'-999') <> NVL( TRIM(Recinfo.item_revision),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_revision '||X_Item_Revision ||' Database  item_revision '||Recinfo.item_revision);
        END IF;
        IF (NVL(X_Quantity_Delivered,-999) <> NVL(Recinfo.quantity_delivered,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_delivered'||X_Quantity_Delivered ||' Database  quantity_delivered '|| Recinfo.quantity_delivered);
        END IF;
        IF (NVL(X_Suggested_Buyer_Id,-999) <> NVL(Recinfo.suggested_buyer_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_buyer_id'||X_Suggested_Buyer_Id ||' Database  suggested_buyer_id '|| Recinfo.suggested_buyer_id);
        END IF;
        IF (NVL(TRIM(X_Encumbered_Flag),'-999') <> NVL( TRIM(Recinfo.encumbered_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form encumbered_flag '||X_Encumbered_Flag ||' Database  encumbered_flag '||Recinfo.encumbered_flag);
        END IF;
        IF (NVL(TRIM(X_Rfq_Required_Flag),'-999') <> NVL( TRIM(Recinfo.rfq_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form rfq_required_flag '||X_Rfq_Required_Flag ||' Database  rfq_required_flag '||Recinfo.rfq_required_flag);
        END IF;
        IF (X_Need_By_Date <> Recinfo.need_by_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form need_by_date '||X_Need_By_Date ||' Database  need_by_date '||Recinfo.need_by_date);
        END IF;
        IF (NVL(X_Line_Location_Id,-999) <> NVL(Recinfo.line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_location_id'||X_Line_Location_Id ||' Database  line_location_id '|| Recinfo.line_location_id);
        END IF;
        IF (NVL(TRIM(X_Modified_By_Agent_Flag),'-999') <> NVL( TRIM(Recinfo.modified_by_agent_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form modified_by_agent_flag '||X_Modified_By_Agent_Flag ||' Database  modified_by_agent_flag '||Recinfo.modified_by_agent_flag);
        END IF;
        IF (NVL(X_Parent_Req_Line_Id,-999) <> NVL(Recinfo.parent_req_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form parent_req_line_id'||X_Parent_Req_Line_Id ||' Database  parent_req_line_id '|| Recinfo.parent_req_line_id);
        END IF;
        IF (NVL(TRIM(X_Justification),'-999') <> NVL( TRIM(Recinfo.justification),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form justification '||X_Justification ||' Database  justification '||Recinfo.justification);
        END IF;
        IF (NVL(TRIM(X_Note_To_Agent),'-999') <> NVL( TRIM(Recinfo.note_to_agent),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form note_to_agent '||X_Note_To_Agent ||' Database  note_to_agent '||Recinfo.note_to_agent);
        END IF;
        IF (NVL(TRIM(X_Note_To_Receiver),'-999') <> NVL( TRIM(Recinfo.note_to_receiver),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form note_to_receiver '||X_Note_To_Receiver ||' Database  note_to_receiver '||Recinfo.note_to_receiver);
        END IF;
        IF (NVL(X_Purchasing_Agent_Id,-999) <> NVL(Recinfo.purchasing_agent_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form purchasing_agent_id'||X_Purchasing_Agent_Id ||' Database  purchasing_agent_id '|| Recinfo.purchasing_agent_id);
        END IF;
        IF (NVL(TRIM(X_Document_Type_Code),'-999') <> NVL( TRIM(Recinfo.document_type_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form document_type_code '||X_Document_Type_Code ||' Database  document_type_code '||Recinfo.document_type_code);
        END IF;
        IF (NVL(X_Blanket_Po_Header_Id,-999) <> NVL(Recinfo.blanket_po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form blanket_po_header_id'||X_Blanket_Po_Header_Id ||' Database  blanket_po_header_id '|| Recinfo.blanket_po_header_id);
        END IF;
        IF (NVL(X_Blanket_Po_Line_Num,-999) <> NVL(Recinfo.blanket_po_line_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form blanket_po_line_num'||X_Blanket_Po_Line_Num ||' Database  blanket_po_line_num '|| Recinfo.blanket_po_line_num);
        END IF;
        IF (NVL(TRIM(X_Currency_Code),'-999') <> NVL( TRIM(Recinfo.currency_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form currency_code '||X_Currency_Code ||' Database  currency_code '||Recinfo.currency_code);
        END IF;
    END IF;

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock4_Row;

END PO_REQUISITION_LINES_PKG4;

/
