--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG3" as
/* $Header: POXRIL4B.pls 120.0.12010000.2 2012/08/31 08:59:10 hliao ship $ */
-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_REQUISITION_LINES_PKG3.';

  PROCEDURE Lock3_Row(X_Rowid                            VARCHAR2,
                     X_Rate_Type                        VARCHAR2,
                     X_Rate_Date                        DATE,
                     X_Rate                             NUMBER,
                     X_Currency_Unit_Price              NUMBER,
                     X_Currency_Amount                NUMBER, -- <SERVICES FPJ>
                     X_Suggested_Vendor_Name            VARCHAR2,
                     X_Suggested_Vendor_Location        VARCHAR2,
                     X_Suggested_Vendor_Contact         VARCHAR2,
                     X_Suggested_Vendor_Phone           VARCHAR2,
                     X_Sugg_Vendor_Product_Code    VARCHAR2,
                     X_Un_Number_Id                     NUMBER,
                     X_Hazard_Class_Id                  NUMBER,
                     X_Must_Use_Sugg_Vendor_Flag        VARCHAR2,
                     X_Reference_Num                    VARCHAR2,
                     X_On_Rfq_Flag                      VARCHAR2,
                     X_Urgent_Flag                      VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
                     X_Source_Organization_Id           NUMBER,
                     X_Source_Subinventory              VARCHAR2,
                     X_Destination_Type_Code            VARCHAR2,
                     X_Destination_Organization_Id      NUMBER,
                     X_Destination_Subinventory         VARCHAR2,
                     X_Quantity_Cancelled               NUMBER,
                     X_Cancel_Date                      DATE,
                     X_Cancel_Reason                    VARCHAR2,
                     X_Closed_Code                      VARCHAR2,
                     X_Agent_Return_Note                VARCHAR2,
                     X_Changed_After_Research_Flag      VARCHAR2,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Vendor_Contact_Id                NUMBER
  ) IS

    CURSOR C IS
        SELECT *
        FROM   PO_REQUISITION_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Requisition_Line_Id NOWAIT;

    Recinfo C%ROWTYPE;
	-- For debug purposes
    l_api_name CONSTANT VARCHAR2(30) := 'Lock3_Row';
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    /* Bug 2679432 - Added the trunc function for the rate_date column
    as the date coming from REQIMPORT could have
    time component and the lock_row would fail   */
    if (
               (   (TRIM(Recinfo.rate_type) = TRIM(X_Rate_Type))
                OR (    (TRIM(Recinfo.rate_type) IS NULL)
                    AND (TRIM(X_Rate_Type) IS NULL)))
           AND (   (trunc(Recinfo.rate_date) = trunc(X_Rate_Date))
                OR (    (Recinfo.rate_date IS NULL)
                    AND (X_Rate_Date IS NULL)))
           AND (   (Recinfo.rate = X_Rate)
                OR (    (Recinfo.rate IS NULL)
                    AND (X_Rate IS NULL)))
           AND (   (Recinfo.currency_unit_price = X_Currency_Unit_Price)
                OR (    (Recinfo.currency_unit_price IS NULL)
                    AND (X_Currency_Unit_Price IS NULL)))
-- <SERVICES FPJ START>
           AND (   (Recinfo.currency_amount = X_Currency_Amount)
                OR (    (Recinfo.currency_amount IS NULL)
                    AND (X_Currency_Amount IS NULL)))
-- <SERVICES FPJ END>
           AND (   (TRIM(Recinfo.suggested_vendor_name) = TRIM(X_Suggested_Vendor_Name))
                OR (    (TRIM(Recinfo.suggested_vendor_name) IS NULL)
                    AND (TRIM(X_Suggested_Vendor_Name) IS NULL)))
           AND (   (TRIM(Recinfo.suggested_vendor_location) = TRIM(X_Suggested_Vendor_Location))
                OR (    (TRIM(Recinfo.suggested_vendor_location) IS NULL)
                    AND (TRIM(X_Suggested_Vendor_Location) IS NULL)))
           AND (   (TRIM(Recinfo.suggested_vendor_contact) = TRIM(X_Suggested_Vendor_Contact))
                OR (    (TRIM(Recinfo.suggested_vendor_contact) IS NULL)
                    AND (TRIM(X_Suggested_Vendor_Contact) IS NULL)))
           AND (   (TRIM(Recinfo.suggested_vendor_phone) = TRIM(X_Suggested_Vendor_Phone))
                OR (    (TRIM(Recinfo.suggested_vendor_phone) IS NULL)
                    AND (TRIM(X_Suggested_Vendor_Phone) IS NULL)))
           AND (   (TRIM(Recinfo.suggested_vendor_product_code) = TRIM(X_Sugg_Vendor_Product_Code))
                OR (    (TRIM(Recinfo.suggested_vendor_product_code) IS NULL)
                    AND (TRIM(X_Sugg_Vendor_Product_Code) IS NULL)))
           AND (   (Recinfo.un_number_id = X_Un_Number_Id)
                OR (    (Recinfo.un_number_id IS NULL)
                    AND (X_Un_Number_Id IS NULL)))
           AND (   (Recinfo.hazard_class_id = X_Hazard_Class_Id)
                OR (    (Recinfo.hazard_class_id IS NULL)
                    AND (X_Hazard_Class_Id IS NULL)))
           AND (   (TRIM(Recinfo.must_use_sugg_vendor_flag) = TRIM(X_Must_Use_Sugg_Vendor_Flag))
                OR (    (TRIM(Recinfo.must_use_sugg_vendor_flag) IS NULL)
                    AND (TRIM(X_Must_Use_Sugg_Vendor_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.reference_num) = TRIM(X_Reference_Num))
                OR (    (TRIM(Recinfo.reference_num) IS NULL)
                    AND (TRIM(X_Reference_Num) IS NULL)))
           AND (   (TRIM(Recinfo.on_rfq_flag) = TRIM(X_On_Rfq_Flag))
                OR (    (TRIM(Recinfo.on_rfq_flag) IS NULL)
                    AND (TRIM(X_On_Rfq_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.urgent_flag) = TRIM(X_Urgent_Flag))
                OR (    (TRIM(Recinfo.urgent_flag) IS NULL)
                    AND (TRIM(X_Urgent_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.cancel_flag) = TRIM(X_Cancel_Flag))
                OR (    (TRIM(Recinfo.cancel_flag) IS NULL)
                    AND (TRIM(X_Cancel_Flag) IS NULL)))
           AND (   (Recinfo.source_organization_id = X_Source_Organization_Id)
                OR (    (Recinfo.source_organization_id IS NULL)
                    AND (X_Source_Organization_Id IS NULL)))
           AND (   (TRIM(Recinfo.source_subinventory) = TRIM(X_Source_Subinventory))
                OR (    (TRIM(Recinfo.source_subinventory) IS NULL)
                    AND (TRIM(X_Source_Subinventory) IS NULL)))
           AND (   (TRIM(Recinfo.destination_type_code) = TRIM(X_Destination_Type_Code))
                OR (    (TRIM(Recinfo.destination_type_code) IS NULL)
                    AND (TRIM(X_Destination_Type_Code) IS NULL)))
           AND (   (Recinfo.destination_organization_id = X_Destination_Organization_Id)
                OR (    (Recinfo.destination_organization_id IS NULL)
                    AND (X_Destination_Organization_Id IS NULL)))
           AND (   (TRIM(Recinfo.destination_subinventory) = TRIM(X_Destination_Subinventory))
                OR (    (TRIM(Recinfo.destination_subinventory) IS NULL)
                    AND (TRIM(X_Destination_Subinventory) IS NULL)))
           AND (   (Recinfo.quantity_cancelled = X_Quantity_Cancelled)
                OR (    (Recinfo.quantity_cancelled IS NULL)
                    AND (X_Quantity_Cancelled IS NULL)))
           AND (   (Recinfo.cancel_date = X_Cancel_Date)
                OR (    (Recinfo.cancel_date IS NULL)
                    AND (X_Cancel_Date IS NULL)))
           AND (   (TRIM(Recinfo.cancel_reason) = TRIM(X_Cancel_Reason))
                OR (    (TRIM(Recinfo.cancel_reason) IS NULL)
                    AND (TRIM(X_Cancel_Reason) IS NULL)))
           AND (   (TRIM(Recinfo.closed_code) = TRIM(X_Closed_Code))
                OR (    (TRIM(Recinfo.closed_code) IS NULL)
                    AND (TRIM(X_Closed_Code) IS NULL)))
           AND (   (TRIM(Recinfo.agent_return_note) = TRIM(X_Agent_Return_Note))
                OR (    (TRIM(Recinfo.agent_return_note) IS NULL)
                    AND (TRIM(X_Agent_Return_Note) IS NULL)))
           AND (   (TRIM(Recinfo.changed_after_research_flag) = TRIM(X_Changed_After_Research_Flag))
                OR (    (TRIM(Recinfo.changed_after_research_flag) IS NULL)
                    AND (TRIM(X_Changed_After_Research_Flag) IS NULL)))
           AND (   (Recinfo.vendor_id = X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id = X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.vendor_contact_id = X_Vendor_Contact_Id)
                OR (    (Recinfo.vendor_contact_id IS NULL)
                    AND (X_Vendor_Contact_Id IS NULL)))
            ) then
      return;
    else

	    IF (g_fnd_debug = 'Y') THEN
        IF (NVL(TRIM(X_Rate_Type),'-999') <> NVL( TRIM(Recinfo.rate_type),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form rate_type '||X_Rate_Type ||' Database  rate_type '||Recinfo.rate_type);
        END IF;
        IF (X_Rate_Date <> Recinfo.rate_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form rate_date '||X_Rate_Date ||' Database  rate_date '||Recinfo.rate_date);
        END IF;
        IF (NVL(X_Rate,-999) <> NVL(Recinfo.rate,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form rate'||X_Rate ||' Database  rate '|| Recinfo.rate);
        END IF;
        IF (NVL(X_Currency_Unit_Price,-999) <> NVL(Recinfo.currency_unit_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form currency_unit_price'||X_Currency_Unit_Price ||' Database  currency_unit_price '|| Recinfo.currency_unit_price);
        END IF;
        IF (NVL(X_Currency_Amount,-999) <> NVL(Recinfo.currency_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form currency_amount'||X_Currency_Amount ||' Database  currency_amount '|| Recinfo.currency_amount);
        END IF;
        IF (NVL(TRIM(X_Suggested_Vendor_Name),'-999') <> NVL( TRIM(Recinfo.suggested_vendor_name),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_name '||X_Suggested_Vendor_Name ||' Database  suggested_vendor_name '||Recinfo.suggested_vendor_name);
        END IF;
        IF (NVL(TRIM(X_Suggested_Vendor_Location),'-999') <> NVL( TRIM(Recinfo.suggested_vendor_location),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_location '||X_Suggested_Vendor_Location ||' Database  suggested_vendor_location '||Recinfo.suggested_vendor_location);
        END IF;
        IF (NVL(TRIM(X_Suggested_Vendor_Contact),'-999') <> NVL( TRIM(Recinfo.suggested_vendor_contact),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_contact '||X_Suggested_Vendor_Contact ||' Database  suggested_vendor_contact '||Recinfo.suggested_vendor_contact);
        END IF;
        IF (NVL(TRIM(X_Suggested_Vendor_Phone),'-999') <> NVL( TRIM(Recinfo.suggested_vendor_phone),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_phone '||X_Suggested_Vendor_Phone ||' Database  suggested_vendor_phone '||Recinfo.suggested_vendor_phone);
        END IF;
        IF (NVL(TRIM(X_Sugg_Vendor_Product_Code),'-999') <> NVL( TRIM(Recinfo.suggested_vendor_product_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form sugg_vendor_product_code '||X_Sugg_Vendor_Product_Code ||' Database  sugg_vendor_product_code '||Recinfo.suggested_vendor_product_code);
        END IF;
        IF (NVL(X_Un_Number_Id,-999) <> NVL(Recinfo.un_number_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form un_number_id'||X_Un_Number_Id ||' Database  un_number_id '|| Recinfo.un_number_id);
        END IF;
        IF (NVL(X_Hazard_Class_Id,-999) <> NVL(Recinfo.hazard_class_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form hazard_class_id'||X_Hazard_Class_Id ||' Database  hazard_class_id '|| Recinfo.hazard_class_id);
        END IF;
        IF (NVL(TRIM(X_Must_Use_Sugg_Vendor_Flag),'-999') <> NVL( TRIM(Recinfo.must_use_sugg_vendor_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form must_use_sugg_vendor_flag '||X_Must_Use_Sugg_Vendor_Flag ||' Database  must_use_sugg_vendor_flag '||Recinfo.must_use_sugg_vendor_flag);
        END IF;
        IF (NVL(TRIM(X_Reference_Num),'-999') <> NVL( TRIM(Recinfo.reference_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form reference_num '||X_Reference_Num ||' Database  reference_num '||Recinfo.reference_num);
        END IF;
        IF (NVL(TRIM(X_On_Rfq_Flag),'-999') <> NVL( TRIM(Recinfo.on_rfq_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form on_rfq_flag '||X_On_Rfq_Flag ||' Database  on_rfq_flag '||Recinfo.on_rfq_flag);
        END IF;
        IF (NVL(TRIM(X_Urgent_Flag),'-999') <> NVL( TRIM(Recinfo.urgent_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form urgent_flag '||X_Urgent_Flag ||' Database  urgent_flag '||Recinfo.urgent_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(X_Source_Organization_Id,-999) <> NVL(Recinfo.source_organization_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_organization_id'||X_Source_Organization_Id ||' Database  source_organization_id '|| Recinfo.source_organization_id);
        END IF;
        IF (NVL(TRIM(X_Source_Subinventory),'-999') <> NVL( TRIM(Recinfo.source_subinventory),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_subinventory '||X_Source_Subinventory ||' Database  source_subinventory '||Recinfo.source_subinventory);
        END IF;
        IF (NVL(TRIM(X_Destination_Type_Code),'-999') <> NVL( TRIM(Recinfo.destination_type_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form destination_type_code '||X_Destination_Type_Code ||' Database  destination_type_code '||Recinfo.destination_type_code);
        END IF;
        IF (NVL(X_Destination_Organization_Id,-999) <> NVL(Recinfo.destination_organization_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form destination_organization_id'||X_Destination_Organization_Id ||' Database  destination_organization_id '|| Recinfo.destination_organization_id);
        END IF;
        IF (NVL(TRIM(X_Destination_Subinventory),'-999') <> NVL( TRIM(Recinfo.destination_subinventory),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form destination_subinventory '||X_Destination_Subinventory ||' Database  destination_subinventory '||Recinfo.destination_subinventory);
        END IF;
        IF (NVL(X_Quantity_Cancelled,-999) <> NVL(Recinfo.quantity_cancelled,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_cancelled'||X_Quantity_Cancelled ||' Database  quantity_cancelled '|| Recinfo.quantity_cancelled);
        END IF;
        IF (X_Cancel_Date <> Recinfo.cancel_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_date '||X_Cancel_Date ||' Database  cancel_date '||Recinfo.cancel_date);
        END IF;
        IF (NVL(TRIM(X_Cancel_Reason),'-999') <> NVL( TRIM(Recinfo.cancel_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_reason '||X_Cancel_Reason ||' Database  cancel_reason '||Recinfo.cancel_reason);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Agent_Return_Note),'-999') <> NVL( TRIM(Recinfo.agent_return_note),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form agent_return_note '||X_Agent_Return_Note ||' Database  agent_return_note '||Recinfo.agent_return_note);
        END IF;
        IF (NVL(TRIM(X_Changed_After_Research_Flag),'-999') <> NVL( TRIM(Recinfo.changed_after_research_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form changed_after_research_flag '||X_Changed_After_Research_Flag ||' Database  changed_after_research_flag '||Recinfo.changed_after_research_flag);
        END IF;
        IF (NVL(X_Vendor_Id,-999) <> NVL(Recinfo.vendor_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form vendor_id'||X_Vendor_Id ||' Database  vendor_id '|| Recinfo.vendor_id);
        END IF;
        IF (NVL(X_Vendor_Site_Id,-999) <> NVL(Recinfo.vendor_site_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form vendor_site_id'||X_Vendor_Site_Id ||' Database  vendor_site_id '|| Recinfo.vendor_site_id);
        END IF;
        IF (NVL(X_Vendor_Contact_Id,-999) <> NVL(Recinfo.vendor_contact_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form vendor_contact_id'||X_Vendor_Contact_Id ||' Database  vendor_contact_id '|| Recinfo.vendor_contact_id);
        END IF;
    END IF;


      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock3_Row;

END PO_REQUISITION_LINES_PKG3;

/
