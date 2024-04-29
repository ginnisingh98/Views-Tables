--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG1" as
/* $Header: POXRIL2B.pls 120.1.12010000.5 2014/06/12 09:40:06 yyoliu ship $ */

g_fnd_debug CONSTANT VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_REQUISITION_LINES_PKG1.';
  PROCEDURE Lock1_Row(X_Rowid                         VARCHAR2,
                     X_Requisition_Line_Id            NUMBER,
                     X_Requisition_Header_Id          NUMBER,
                     X_Line_Num                       NUMBER,
                     X_Line_Type_Id                   NUMBER,
                     X_Category_Id                    NUMBER,
                     X_Item_Description               VARCHAR2,
                     X_Unit_Meas_Lookup_Code          VARCHAR2,
                     X_Unit_Price                     NUMBER,
                     X_Quantity                       NUMBER,
                     X_Amount                         NUMBER, -- <SERVICES FPJ>
                     X_Deliver_To_Location_Id         NUMBER,
                     X_To_Person_Id                   NUMBER,
                     X_Source_Type_Code               VARCHAR2,
                     X_Item_Id                        NUMBER,
         X_Tax_Code_Id      NUMBER,
         X_Tax_User_Override_Flag   VARCHAR2,
-- MC bug# 1548597.. Add 3 process related columns.unit_of_measure,quantity and grade.
-- start of 1548597
                       X_Secondary_Unit_Of_Measure      VARCHAR2 default null,
                       X_Secondary_Quantity             NUMBER default null,
                       X_Preferred_Grade                VARCHAR2 default null
-- end of 1548597
  ) IS

    CURSOR C IS
        SELECT *
        FROM   PO_REQUISITION_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Requisition_Line_Id NOWAIT;

    Recinfo C%ROWTYPE;
     l_api_name CONSTANT VARCHAR2(30) := 'Lock1_Row';
    -- Bug 9579029
    l_item_desc po_lines.item_description%type;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
      -- raise app_exception.record_lock_exception;
    end if;
    CLOSE C;
    	     -- bug 9579029 <start>
 	               if X_Item_Id is not null then
 	                           begin
 	                              select decode(msi.allow_item_desc_update_flag,'Y',Recinfo.item_description,msit.description)
 	                                into l_item_desc
 	                                from mtl_system_items msi,
 	                                     mtl_system_items_tl msit,
 	                                     FINANCIALS_SYSTEM_PARAMETERS FSP
 	                               where msi.INVENTORY_ITEM_ID  = X_Item_Id
 	                                 AND msi.inventory_item_id = msit.inventory_item_id
 	                                 AND msi.organization_id = msit.organization_id
 	                                 AND NVL(MSI.ORGANIZATION_ID,FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
 	                                 AND userenv('LANG') = msit.LANGUAGE ;

 	                           exception
 	                              when others then
 	                                l_item_desc := '';
 	                           end;
			else Begin
			    l_item_desc := X_Item_Description ;
			    End ;
 	               end if;
 	      -- bug 9579029 <end>
 	      -- bug 9579029 modified the condition Recinfo.item_description with l_item_desc in the following if clause condition.
    if (

               (Recinfo.requisition_line_id = X_Requisition_Line_Id)
           AND (Recinfo.requisition_header_id = X_Requisition_Header_Id)
           AND (Recinfo.line_num = X_Line_Num)
           AND (Recinfo.line_type_id = X_Line_Type_Id)
           AND (Recinfo.category_id = X_Category_Id)
	   AND (TRIM(Recinfo.item_description) = TRIM(X_Item_Description))
           --bug 18490803
           -- <SERVICES FPJ START>
           AND (   ( TRIM(recinfo.unit_meas_lookup_code) = TRIM(x_unit_meas_lookup_code ))
               OR  (   (TRIM( recinfo.unit_meas_lookup_code) IS NULL )
                   AND ( TRIM(x_unit_meas_lookup_code) IS NULL ) ) )

           AND (   ( recinfo.unit_price = x_unit_price )
               OR  (   ( recinfo.unit_price IS NULL )
                   AND ( x_unit_price IS NULL ) ) )

           AND (   ( recinfo.quantity = x_quantity )
               OR  (   ( recinfo.quantity IS NULL )
                   AND ( x_quantity IS NULL ) ) )

           AND (   ( recinfo.amount = x_amount )
               OR  (   ( recinfo.amount IS NULL )
                   AND ( x_amount IS NULL ) ) )
           -- <SERVICES FPJ END>

           AND (Recinfo.deliver_to_location_id = X_Deliver_To_Location_Id)
           AND (Recinfo.to_person_id = X_To_Person_Id)
           AND (TRIM(Recinfo.source_type_code) = TRIM(X_Source_Type_Code))
           AND (   (Recinfo.item_id = X_Item_Id)
                OR (    (Recinfo.item_id IS NULL)
                    AND (X_Item_Id IS NULL)))
-- start of 1548597
           AND ((TRIM(Recinfo.secondary_unit_of_measure) = TRIM(X_Secondary_Unit_Of_Measure))
                OR (    (Recinfo.secondary_unit_of_measure IS NULL)
                    AND (TRIM(X_Secondary_Unit_Of_Measure) IS NULL)))
           AND ((Recinfo.secondary_quantity = X_Secondary_Quantity)
                OR (    (Recinfo.secondary_quantity IS NULL)
                    AND (X_Secondary_quantity IS NULL)))
           AND ((TRIM(Recinfo.preferred_grade)= TRIM(X_Preferred_Grade))
                OR (    (Recinfo.preferred_grade IS NULL)
                    AND (TRIM(X_Preferred_Grade) IS NULL)))
-- end of 1548597
            ) then
      return;
    else

     IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Requisition_Line_Id,-999) <> NVL(Recinfo.requisition_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form requisition_line_id'||X_Requisition_Line_Id ||' Database  requisition_line_id '|| Recinfo.requisition_line_id);
        END IF;
        IF (NVL(X_Requisition_Header_Id,-999) <> NVL(Recinfo.requisition_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form requisition_header_id'||X_Requisition_Header_Id ||' Database  requisition_header_id '|| Recinfo.requisition_header_id);
        END IF;
        IF (NVL(X_Line_Num,-999) <> NVL(Recinfo.line_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_num'||X_Line_Num ||' Database  line_num '|| Recinfo.line_num);
        END IF;
        IF (NVL(X_Line_Type_Id,-999) <> NVL(Recinfo.line_type_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_type_id'||X_Line_Type_Id ||' Database  line_type_id '|| Recinfo.line_type_id);
        END IF;
        IF (NVL(X_Category_Id,-999) <> NVL(Recinfo.category_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form category_id'||X_Category_Id ||' Database  category_id '|| Recinfo.category_id);
        END IF;
        IF (NVL(TRIM(X_Item_Description),'-999') <> NVL( TRIM(Recinfo.item_description),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_description '||X_Item_Description ||' Database  item_description '||Recinfo.item_description);
        END IF;
        IF (NVL(TRIM(X_Unit_Meas_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.unit_meas_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_meas_lookup_code '||X_Unit_Meas_Lookup_Code ||' Database  unit_meas_lookup_code '||Recinfo.unit_meas_lookup_code);
        END IF;
        IF (NVL(X_Unit_Price,-999) <> NVL(Recinfo.unit_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_price'||X_Unit_Price ||' Database  unit_price '|| Recinfo.unit_price);
        END IF;
        IF (NVL(X_Quantity,-999) <> NVL(Recinfo.quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity'||X_Quantity ||' Database  quantity '|| Recinfo.quantity);
        END IF;
        IF (NVL(X_Amount,-999) <> NVL(Recinfo.amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form amount'||X_Amount ||' Database  amount '|| Recinfo.amount);
        END IF;
        IF (NVL(X_Deliver_To_Location_Id,-999) <> NVL(Recinfo.deliver_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form deliver_to_location_id'||X_Deliver_To_Location_Id ||' Database  deliver_to_location_id '|| Recinfo.deliver_to_location_id);
        END IF;
        IF (NVL(X_To_Person_Id,-999) <> NVL(Recinfo.to_person_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form to_person_id'||X_To_Person_Id ||' Database  to_person_id '|| Recinfo.to_person_id);
        END IF;
        IF (NVL(TRIM(X_Source_Type_Code),'-999') <> NVL( TRIM(Recinfo.source_type_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_type_code '||X_Source_Type_Code ||' Database  source_type_code '||Recinfo.source_type_code);
        END IF;
        IF (NVL(X_Item_Id,-999) <> NVL(Recinfo.item_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_id'||X_Item_Id ||' Database  item_id '|| Recinfo.item_id);
        END IF;

		IF (NVL(TRIM(X_Secondary_Unit_Of_Measure),'-999') <> NVL( TRIM(Recinfo.secondary_unit_of_measure),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_unit_of_measure '||X_Secondary_Unit_Of_Measure ||' Database  secondary_unit_of_measure '||Recinfo.secondary_unit_of_measure);
        END IF;
        IF (NVL(X_Secondary_Quantity,-999) <> NVL(Recinfo.secondary_quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_quantity'||X_Secondary_Quantity ||' Database  secondary_quantity '|| Recinfo.secondary_quantity);
        END IF;
        IF (NVL(TRIM(X_Preferred_Grade),'-999') <> NVL( TRIM(Recinfo.preferred_grade),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preferred_grade '||X_Preferred_Grade ||' Database  preferred_grade '||Recinfo.preferred_grade);
        END IF;

    END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
      --raise app_exception.record_lock_exception;
    end if;
  END Lock1_Row;



  PROCEDURE Delete_Row(X_Rowid        VARCHAR2,
           X_transferred_to_oe_flag     OUT NOCOPY VARCHAR2) IS
  x_progress VARCHAR2(3) := NULL;
  x_requisition_header_id NUMBER;

  BEGIN

    x_progress := '010';

    SELECT requisition_header_id
    INTO   x_requisition_header_id
    FROM   po_requisition_lines
    WHERE  rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    x_progress := '020';

    DELETE FROM PO_REQUISITION_LINES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;


    x_progress := '030';
    --dbms_output.put_line ('Before call to update_transferred...');

    po_req_lines_sv.update_transferred_to_oe_flag (X_requisition_header_id,
             X_transferred_to_oe_flag);


   EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('DELETE_ROW',x_progress,sqlcode);

  END Delete_Row;


END PO_REQUISITION_LINES_PKG1;

/
