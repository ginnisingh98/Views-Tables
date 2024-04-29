--------------------------------------------------------
--  DDL for Package Body ARP_RTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RTE_PKG" as
/* $Header: ARXIRTEB.pls 120.2 2005/07/26 15:30:15 naneja noship $ */
/* Purpose : This package has the server side table handlers for the
    	     table RA_TAX_EXEMPTIONS. This file holds the package body.  */

--
-- PRIVATE Procedures/Functions
--


--
-- PUBLIC Procedures/Functions
--

  --
  -- p_org_id is added for MOAC compliance for 11iX
  --
  PROCEDURE Insert_Row(p_Rowid                   IN OUT NOCOPY VARCHAR2,
			p_Tax_exemption_id	 IN OUT	NOCOPY NUMBER,
			p_Last_updated_by		NUMBER,
			p_Last_update_date		DATE,
			p_Created_by			NUMBER,
			p_Creation_date			DATE,
			p_Status			VARCHAR2,
			p_Inventory_item_id		NUMBER,
			p_Customer_id			NUMBER,
			p_Site_use_id			NUMBER,
			p_Exemption_type		VARCHAR2,
			p_Tax_code			VARCHAR2,
			p_Percent_exempt		NUMBER,
			p_Customer_exemption_number	VARCHAR2,
			p_Start_date			DATE,
			p_End_date			DATE,
			p_Location_context		VARCHAR2,
			p_Location_id_segment_1		NUMBER,
			p_Location_id_segment_2		NUMBER,
			p_Location_id_segment_3		NUMBER,
			p_Location_id_segment_4		NUMBER,
			p_Location_id_segment_5		NUMBER,
			p_Location_id_segment_6		NUMBER,
			p_Location_id_segment_7		NUMBER,
			p_Location_id_segment_8		NUMBER,
			p_Location_id_segment_9		NUMBER,
			p_Location_id_segment_10	NUMBER,
			p_Attribute_category		VARCHAR2,
			p_Attribute1			VARCHAR2,
			p_Attribute2			VARCHAR2,
			p_Attribute3			VARCHAR2,
			p_Attribute4			VARCHAR2,
			p_Attribute5			VARCHAR2,
			p_Attribute6			VARCHAR2,
			p_Attribute7			VARCHAR2,
			p_Attribute8			VARCHAR2,
			p_Attribute9			VARCHAR2,
			p_Attribute10			VARCHAR2,
			p_Attribute11			VARCHAR2,
			p_Attribute12			VARCHAR2,
			p_Attribute13			VARCHAR2,
			p_Attribute14			VARCHAR2,
			p_Attribute15			VARCHAR2,
			p_In_use_flag			VARCHAR2,
			p_Program_id			NUMBER,
			p_Program_update_date		DATE,
			p_Request_id			NUMBER,
			p_Program_application_id	NUMBER,
			p_Reason_code			VARCHAR2,
                        p_Exempt_Context                VARCHAR2,
                        p_Exempt_percent1               NUMBER,
                        p_Exempt_percent2               NUMBER,
                        p_Exempt_percent3               NUMBER,
                        p_Exempt_percent4               NUMBER,
                        p_Exempt_percent5               NUMBER,
                        p_Exempt_percent6               NUMBER,
                        p_Exempt_percent7               NUMBER,
                        p_Exempt_percent8               NUMBER,
                        p_Exempt_percent9               NUMBER,
                        p_Exempt_percent10              NUMBER,
                        p_org_id                        NUMBER
                      )
    IS
    CURSOR C IS SELECT rowid FROM RA_TAX_EXEMPTIONS
                 WHERE tax_exemption_id = p_Tax_exemption_id;

      CURSOR C2 IS SELECT ra_tax_exemptions_s.nextval FROM dual;
   BEGIN


      if (p_Tax_Exemption_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO p_Tax_Exemption_id;
        CLOSE C2;
      end if;

       INSERT INTO RA_TAX_EXEMPTIONS(
		Tax_exemption_id,
		Last_updated_by,
		Last_update_date,
		Created_by,
		Creation_date,
		Status,
		Inventory_item_id,
		Customer_id,
		Site_use_id,
		Exemption_type,
		Tax_code,
		Percent_exempt,
		Customer_exemption_number,
		Start_date,
		End_date,
		Location_context,
		Location_id_segment_1,
		Location_id_segment_2,
		Location_id_segment_3,
		Location_id_segment_4,
		Location_id_segment_5,
		Location_id_segment_6,
		Location_id_segment_7,
		Location_id_segment_8,
		Location_id_segment_9,
		Location_id_segment_10,
		Attribute_category,
		Attribute1,
		Attribute2,
		Attribute3,
		Attribute4,
		Attribute5,
		Attribute6,
		Attribute7,
		Attribute8,
		Attribute9,
		Attribute10,
		Attribute11,
		Attribute12,
		Attribute13,
		Attribute14,
		Attribute15,
		In_use_flag,
		Program_id,
		Program_update_date,
		Request_id,
		Program_application_id,
		Reason_code,
                Exempt_Context,
                Exempt_percent1,
                Exempt_percent2,
                Exempt_percent3,
                Exempt_percent4,
                Exempt_percent5,
                Exempt_percent6,
                Exempt_percent7,
                Exempt_percent8,
                Exempt_percent9,
                Exempt_percent10,
                org_id
             )
               VALUES (
		p_Tax_exemption_id,
		p_Last_updated_by,
		p_Last_update_date,
		p_Created_by,
		p_Creation_date,
		p_Status,
		p_Inventory_item_id,
		p_Customer_id,
		p_Site_use_id,
		p_Exemption_type,
		p_Tax_code,
		p_Percent_exempt,
		p_Customer_exemption_number,
		p_Start_date,
		p_End_date,
		p_Location_context,
		p_Location_id_segment_1,
		p_Location_id_segment_2,
		p_Location_id_segment_3,
		p_Location_id_segment_4,
		p_Location_id_segment_5,
		p_Location_id_segment_6,
		p_Location_id_segment_7,
		p_Location_id_segment_8,
		p_Location_id_segment_9,
		p_Location_id_segment_10,
		p_Attribute_category,
		p_Attribute1,
		p_Attribute2,
		p_Attribute3,
		p_Attribute4,
		p_Attribute5,
		p_Attribute6,
		p_Attribute7,
		p_Attribute8,
		p_Attribute9,
		p_Attribute10,
		p_Attribute11,
		p_Attribute12,
		p_Attribute13,
		p_Attribute14,
		p_Attribute15,
		p_In_use_flag,
		p_Program_id,
		p_Program_update_date,
		p_Request_id,
		p_Program_application_id,
		p_Reason_code,
                p_Exempt_Context,
                p_Exempt_percent1,
                p_Exempt_percent2,
                p_Exempt_percent3,
                p_Exempt_percent4,
                p_Exempt_percent5,
                p_Exempt_percent6,
                p_Exempt_percent7,
                p_Exempt_percent8,
                p_Exempt_percent9,
                p_Exempt_percent10,
                p_org_id
             );

    OPEN C;
    FETCH C INTO p_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  END Insert_Row;


  PROCEDURE Lock_Row(p_Rowid                            VARCHAR2,
			p_Tax_exemption_id	       	NUMBER,
			p_Last_updated_by		NUMBER,
			p_Last_update_date		DATE,
			p_Created_by			NUMBER,
			p_Creation_date			DATE,
			p_Status			VARCHAR2,
			p_Inventory_item_id		NUMBER,
			p_Customer_id			NUMBER,
			p_Site_use_id			NUMBER,
			p_Exemption_type		VARCHAR2,
			p_Tax_code			VARCHAR2,
			p_Percent_exempt		NUMBER,
			p_Customer_exemption_number	VARCHAR2,
			p_Start_date			DATE,
			p_End_date			DATE,
			p_Location_context		VARCHAR2,
			p_Location_id_segment_1		NUMBER,
			p_Location_id_segment_2		NUMBER,
			p_Location_id_segment_3		NUMBER,
			p_Location_id_segment_4		NUMBER,
			p_Location_id_segment_5		NUMBER,
			p_Location_id_segment_6		NUMBER,
			p_Location_id_segment_7		NUMBER,
			p_Location_id_segment_8		NUMBER,
			p_Location_id_segment_9		NUMBER,
			p_Location_id_segment_10	NUMBER,
			p_Attribute_category		VARCHAR2,
			p_Attribute1			VARCHAR2,
			p_Attribute2			VARCHAR2,
			p_Attribute3			VARCHAR2,
			p_Attribute4			VARCHAR2,
			p_Attribute5			VARCHAR2,
			p_Attribute6			VARCHAR2,
			p_Attribute7			VARCHAR2,
			p_Attribute8			VARCHAR2,
			p_Attribute9			VARCHAR2,
			p_Attribute10			VARCHAR2,
			p_Attribute11			VARCHAR2,
			p_Attribute12			VARCHAR2,
			p_Attribute13			VARCHAR2,
			p_Attribute14			VARCHAR2,
			p_Attribute15			VARCHAR2,
			p_In_use_flag			VARCHAR2,
			p_Program_id			NUMBER,
			p_Program_update_date		DATE,
			p_Request_id			NUMBER,
			p_Program_application_id	NUMBER,
			p_Reason_code			VARCHAR2,
                        p_Exempt_Context                VARCHAR2,
                        p_Exempt_percent1               NUMBER,
                        p_Exempt_percent2               NUMBER,
                        p_Exempt_percent3               NUMBER,
                        p_Exempt_percent4               NUMBER,
                        p_Exempt_percent5               NUMBER,
                        p_Exempt_percent6               NUMBER,
                        p_Exempt_percent7               NUMBER,
                        p_Exempt_percent8               NUMBER,
                        p_Exempt_percent9               NUMBER,
                        p_Exempt_percent10              NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   RA_TAX_EXEMPTIONS
        WHERE  rowid = p_Rowid
        FOR UPDATE of Tax_Exemption_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if ( (Recinfo.tax_exemption_id =  p_Tax_Exemption_id)
           AND (Recinfo.status =  p_Status)
           AND (   (Recinfo.inventory_item_id =  p_Inventory_item_id)
                OR (    (Recinfo.inventory_item_id IS NULL)
                    AND (p_inventory_item_id IS NULL)))
           AND (   (Recinfo.customer_id =  p_customer_id)
                OR (    (Recinfo.customer_id IS NULL)
                    AND (p_customer_id IS NULL)))
           AND (   (Recinfo.site_use_id =  p_site_use_id)
                OR (    (Recinfo.site_use_id IS NULL)
                    AND (p_site_use_id IS NULL)))
           AND (Recinfo.exemption_type =  p_Exemption_type)
           AND (Recinfo.tax_code =  p_Tax_code)
           AND (Recinfo.percent_exempt =  p_Percent_exempt)
           AND (   (Recinfo.customer_exemption_number =
						p_customer_exemption_number)
                OR (    (Recinfo.customer_exemption_number IS NULL)
                    AND (p_customer_exemption_number IS NULL)))
           AND (Recinfo.start_date =  p_Start_date)
           AND (   (Recinfo.end_date =  p_end_date)
                OR (    (Recinfo.end_date IS NULL)
                    AND (p_end_date IS NULL)))
           AND (   (Recinfo.location_context =  p_location_context)
                OR (    (Recinfo.location_context IS NULL)
                    AND (p_location_context IS NULL)))
           AND (   (Recinfo.location_id_segment_1 =  p_Location_Id_Segment_1)
                OR (    (Recinfo.location_id_segment_1 IS NULL)
                    AND (p_Location_Id_Segment_1 IS NULL)))
           AND (   (Recinfo.location_id_segment_2 =  p_Location_Id_Segment_2)
                OR (    (Recinfo.location_id_segment_2 IS NULL)
                    AND (p_Location_Id_Segment_2 IS NULL)))
           AND (   (Recinfo.location_id_segment_3 =  p_Location_Id_Segment_3)
                OR (    (Recinfo.location_id_segment_3 IS NULL)
                    AND (p_Location_Id_Segment_3 IS NULL)))
           AND (   (Recinfo.location_id_segment_4 =  p_Location_Id_Segment_4)
                OR (    (Recinfo.location_id_segment_4 IS NULL)
                    AND (p_Location_Id_Segment_4 IS NULL)))
           AND (   (Recinfo.location_id_segment_5 =  p_Location_Id_Segment_5)
                OR (    (Recinfo.location_id_segment_5 IS NULL)
                    AND (p_Location_Id_Segment_5 IS NULL)))
           AND (   (Recinfo.location_id_segment_6 =  p_Location_Id_Segment_6)
                OR (    (Recinfo.location_id_segment_6 IS NULL)
                    AND (p_Location_Id_Segment_6 IS NULL)))
           AND (   (Recinfo.location_id_segment_7 =  p_Location_Id_Segment_7)
                OR (    (Recinfo.location_id_segment_7 IS NULL)
                    AND (p_Location_Id_Segment_7 IS NULL)))
           AND (   (Recinfo.location_id_segment_8 =  p_Location_Id_Segment_8)
                OR (    (Recinfo.location_id_segment_8 IS NULL)
                    AND (p_Location_Id_Segment_8 IS NULL)))
           AND (   (Recinfo.location_id_segment_9 =  p_Location_Id_Segment_9)
                OR (    (Recinfo.location_id_segment_9 IS NULL)
                    AND (p_Location_Id_Segment_9 IS NULL)))
           AND (   (Recinfo.location_id_segment_10 =  p_Location_Id_Segment_10)
                OR (    (Recinfo.location_id_segment_10 IS NULL)
                    AND (p_Location_Id_Segment_10 IS NULL)))
           AND (   (Recinfo.attribute_category =  p_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (p_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  p_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (p_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  p_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (p_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  p_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (p_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  p_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (p_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  p_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (p_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  p_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (p_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  p_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (p_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  p_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (p_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  p_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (p_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  p_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (p_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  p_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (p_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  p_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (p_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  p_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (p_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  p_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (p_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  p_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (p_Attribute15 IS NULL)))
           AND (Recinfo.in_use_flag =  p_In_use_flag)
           AND (   (Recinfo.program_id =  p_program_id)
                OR (    (Recinfo.program_id IS NULL)
                    AND (p_program_id IS NULL)))
           AND (   (Recinfo.program_update_date =  p_program_update_date)
                OR (    (Recinfo.program_update_date IS NULL)
                    AND (p_program_update_date IS NULL)))
           AND (   (Recinfo.request_id =  p_request_id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (p_request_id IS NULL)))
           AND (   (Recinfo.program_application_id =  p_program_application_id)
                OR (    (Recinfo.program_application_id IS NULL)
                    AND (p_program_application_id IS NULL)))
           AND (   (Recinfo.reason_code =  p_reason_code)
                OR (    (Recinfo.reason_code IS NULL)
                    AND (p_reason_code IS NULL)))
           AND (   (Recinfo.Exempt_Context =  p_Exempt_Context)
                OR (    (Recinfo.Exempt_Context IS NULL)
                    AND (p_Exempt_context IS NULL)))
          AND (   (Recinfo.Exempt_Percent1 =  p_Exempt_Percent1)
                OR (    (Recinfo.Exempt_Percent1 IS NULL)
                    AND (p_Exempt_Percent1 IS NULL)))
          AND (   (Recinfo.Exempt_Percent2 =  p_Exempt_Percent2)
                OR (    (Recinfo.Exempt_Percent2 IS NULL)
                    AND (p_Exempt_Percent2 IS NULL)))
          AND (   (Recinfo.Exempt_Percent3 =  p_Exempt_Percent3)
                OR (    (Recinfo.Exempt_Percent3 IS NULL)
                    AND (p_Exempt_Percent3 IS NULL)))
          AND (   (Recinfo.Exempt_Percent4 =  p_Exempt_Percent4)
                OR (    (Recinfo.Exempt_Percent4 IS NULL)
                    AND (p_Exempt_Percent4 IS NULL)))
          AND (   (Recinfo.Exempt_Percent5 =  p_Exempt_Percent5)
                OR (    (Recinfo.Exempt_Percent5 IS NULL)
                    AND (p_Exempt_Percent5 IS NULL)))
          AND (   (Recinfo.Exempt_Percent6 =  p_Exempt_Percent6)
                OR (    (Recinfo.Exempt_Percent6 IS NULL)
                    AND (p_Exempt_Percent6 IS NULL)))
          AND (   (Recinfo.Exempt_Percent7 =  p_Exempt_Percent7)
                OR (    (Recinfo.Exempt_Percent7 IS NULL)
                    AND (p_Exempt_Percent7 IS NULL)))
          AND (   (Recinfo.Exempt_Percent8 =  p_Exempt_Percent8)
                OR (    (Recinfo.Exempt_Percent8 IS NULL)
                    AND (p_Exempt_Percent8 IS NULL)))
          AND (   (Recinfo.Exempt_Percent9 =  p_Exempt_Percent9)
                OR (    (Recinfo.Exempt_Percent9 IS NULL)
                    AND (p_Exempt_Percent9 IS NULL)))
          AND (   (Recinfo.Exempt_Percent10 =  p_Exempt_Percent10)
                OR (    (Recinfo.Exempt_Percent10 IS NULL)
                    AND (p_Exempt_Percent10 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  END Lock_Row;



  PROCEDURE Update_Row(p_Rowid                          VARCHAR2,
			p_Tax_exemption_id	        NUMBER,
			p_Last_updated_by		NUMBER,
			p_Last_update_date		DATE,
			p_Created_by			NUMBER,
			p_Creation_date			DATE,
			p_Status			VARCHAR2,
			p_Inventory_item_id		NUMBER,
			p_Customer_id			NUMBER,
			p_Site_use_id			NUMBER,
			p_Exemption_type		VARCHAR2,
			p_Tax_code			VARCHAR2,
			p_Percent_exempt		NUMBER,
			p_Customer_exemption_number	VARCHAR2,
			p_Start_date			DATE,
			p_End_date			DATE,
			p_Location_context		VARCHAR2,
			p_Location_id_segment_1		NUMBER,
			p_Location_id_segment_2		NUMBER,
			p_Location_id_segment_3		NUMBER,
			p_Location_id_segment_4		NUMBER,
			p_Location_id_segment_5		NUMBER,
			p_Location_id_segment_6		NUMBER,
			p_Location_id_segment_7		NUMBER,
			p_Location_id_segment_8		NUMBER,
			p_Location_id_segment_9		NUMBER,
			p_Location_id_segment_10	NUMBER,
			p_Attribute_category		VARCHAR2,
			p_Attribute1			VARCHAR2,
			p_Attribute2			VARCHAR2,
			p_Attribute3			VARCHAR2,
			p_Attribute4			VARCHAR2,
			p_Attribute5			VARCHAR2,
			p_Attribute6			VARCHAR2,
			p_Attribute7			VARCHAR2,
			p_Attribute8			VARCHAR2,
			p_Attribute9			VARCHAR2,
			p_Attribute10			VARCHAR2,
			p_Attribute11			VARCHAR2,
			p_Attribute12			VARCHAR2,
			p_Attribute13			VARCHAR2,
			p_Attribute14			VARCHAR2,
			p_Attribute15			VARCHAR2,
			p_In_use_flag			VARCHAR2,
			p_Program_id			NUMBER,
			p_Program_update_date		DATE,
			p_Request_id			NUMBER,
			p_Program_application_id	NUMBER,
			p_Reason_code			VARCHAR2,
                        p_Exempt_Context                VARCHAR2,
                        p_Exempt_percent1               NUMBER,
                        p_Exempt_percent2               NUMBER,
                        p_Exempt_percent3               NUMBER,
                        p_Exempt_percent4               NUMBER,
                        p_Exempt_percent5               NUMBER,
                        p_Exempt_percent6               NUMBER,
                        p_Exempt_percent7               NUMBER,
                        p_Exempt_percent8               NUMBER,
                        p_Exempt_percent9               NUMBER,
                        p_Exempt_percent10              NUMBER
  ) IS
  BEGIN


    UPDATE RA_TAX_EXEMPTIONS
    SET
	Tax_exemption_id		=	p_Tax_exemption_id,
	Last_updated_by			=	p_Last_updated_by,
	Last_update_date		=	p_Last_update_date,
	Created_by			=	p_Created_by,
	Creation_date			=	p_Creation_date,
	Status				=	p_Status,
	Inventory_item_id		=	p_Inventory_item_id,
	Customer_id			=	p_Customer_id,
	Site_use_id			=	p_Site_use_id,
	Exemption_type			=	p_Exemption_type,
	Tax_code			=	p_Tax_code,
	Percent_exempt			=	p_Percent_exempt,
	Customer_exemption_number	=	p_Customer_exemption_number,
	Start_date			=	p_Start_date,
	End_date			=	p_End_date,
	Location_context		=	p_Location_context,
	Location_id_segment_1		=	p_Location_id_segment_1,
	Location_id_segment_2		=	p_Location_id_segment_2,
	Location_id_segment_3		=	p_Location_id_segment_3,
	Location_id_segment_4		=	p_Location_id_segment_4,
	Location_id_segment_5		=	p_Location_id_segment_5,
	Location_id_segment_6		=	p_Location_id_segment_6,
	Location_id_segment_7		=	p_Location_id_segment_7,
	Location_id_segment_8		=	p_Location_id_segment_8,
	Location_id_segment_9		=	p_Location_id_segment_9,
	Location_id_segment_10		=	p_Location_id_segment_10,
	Attribute_category		=	p_Attribute_category,
	Attribute1			=	p_Attribute1,
	Attribute2			=	p_Attribute2,
	Attribute3			=	p_Attribute3,
	Attribute4			=	p_Attribute4,
	Attribute5			=	p_Attribute5,
	Attribute6			=	p_Attribute6,
	Attribute7			=	p_Attribute7,
	Attribute8			=	p_Attribute8,
	Attribute9			=	p_Attribute9,
	Attribute10			=	p_Attribute10,
	Attribute11			=	p_Attribute11,
	Attribute12			=	p_Attribute12,
	Attribute13			=	p_Attribute13,
	Attribute14			=	p_Attribute14,
	Attribute15			=	p_Attribute15,
	In_use_flag			=	p_In_use_flag,
	Program_id			=	p_Program_id,
	Program_update_date		=	p_Program_update_date,
	Request_id			=	p_Request_id,
	Program_application_id		=	p_Program_application_id,
	Reason_code			=	p_Reason_code,
        Exempt_Context                  =       p_Exempt_Context,
        Exempt_Percent1                 =       p_Exempt_percent1,
        Exempt_Percent2                 =       p_Exempt_percent2,
        Exempt_Percent3                 =       p_Exempt_percent3,
        Exempt_Percent4                 =       p_Exempt_percent4,
        Exempt_Percent5                 =       p_Exempt_percent5,
        Exempt_Percent6                 =       p_Exempt_percent6,
        Exempt_Percent7                 =       p_Exempt_percent7,
        Exempt_Percent8                 =       p_Exempt_percent8,
        Exempt_Percent9                 =       p_Exempt_percent9,
        Exempt_Percent10                =       p_Exempt_percent10

    WHERE rowid = p_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;


  PROCEDURE Delete_Row(p_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM RA_TAX_EXEMPTIONS
    WHERE rowid = p_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Delete_Row;


END ARP_RTE_PKG;

/
