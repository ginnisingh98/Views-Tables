--------------------------------------------------------
--  DDL for Package CSI_EXT_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_EXT_CONTACTS_PKG" AUTHID CURRENT_USER AS
/*$Header: CSIEXCTS.pls 115.4 2003/02/07 23:46:53 rmamidip noship $*/
TYPE CP_Contact_Rec_Type IS RECORD(
        Customer_Product_Id NUMBER :=FND_API.G_Miss_Num,
        Cs_Contact_Id         NUMBER :=FND_API.G_Miss_NUM,
        Contact_Category    VARCHAR2(30) :=FND_API.G_Miss_Num,
        Contact_Type        NUMBER := FND_API.G_Miss_Num,
        Contact_Id          NUMBER := FND_API.G_Miss_Num,
	primary_flag	      VARCHAR2(1):= FND_API.G_Miss_CHAR,
	preferred_flag      VARCHAR2(1):= FND_API.G_Miss_Char,
	svc_provider_flag   VARCHAR2(1):= FND_API.G_Miss_Char,
	start_date_active   DATE:= FND_API.G_Miss_Date,
	end_date_active     DATE:= FND_API.G_Miss_Date,
	context	      VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute1	      VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute2	      VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute3 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute4 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute5 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute6 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute7 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute8 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute9 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute10 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute11 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute12 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute13 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute14 VARCHAR2(150):= FND_API.G_Miss_CHAR,
	attribute15 VARCHAR2(150):= FND_API.G_Miss_CHAR);

PROCEDURE Insert_Row(
	p_customer_Product_id		IN NUMBER,
	p_contact_category              IN VARCHAR2,
	p_contact_type			IN VARCHAR2,
	p_contact_id			IN NUMBER,
	p_primary_flag			IN VARCHAR2,
	p_preferred_flag		IN VARCHAR2,
	p_svc_provider_flag		IN VARCHAR2,
	p_start_date_active		IN DATE,
	p_end_date_active		IN DATE,
	p_context				IN VARCHAR2,
	p_attribute1			IN VARCHAR2,
	p_attribute2			IN VARCHAR2,
	p_attribute3			IN VARCHAR2,
	p_attribute4			IN VARCHAR2,
	p_attribute5			IN VARCHAR2,
	p_attribute6			IN VARCHAR2,
	p_attribute7			IN VARCHAR2,
	p_attribute8			IN VARCHAR2,
	p_attribute9			IN VARCHAR2,
	p_attribute10			IN VARCHAR2,
	p_attribute11			IN VARCHAR2,
	p_attribute12			IN VARCHAR2,
	p_attribute13			IN VARCHAR2,
	p_attribute14			IN VARCHAR2,
	p_attribute15			IN VARCHAR2,
	x_cs_contact_id	 OUT NOCOPY NUMBER,
	x_return_status	 OUT NOCOPY VARCHAR,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR,
	x_object_version_number OUT NOCOPY NUMBER
	);


PROCEDURE Lock_Row(
--	p_rowid				IN OUT VARCHAR2,
	p_cs_contact_id		        IN NUMBER,
	p_Customer_Product_id		IN NUMBER,
	p_Customer_Id	                IN NUMBER,
	p_contact_category              IN VARCHAR2,
	p_contact_type			IN VARCHAR2,
	p_contact_id			IN NUMBER,
	p_primary_flag			IN VARCHAR2,
	p_preferred_flag		IN VARCHAR2,
	p_svc_provider_flag		IN VARCHAR2,
	p_start_date_active		IN DATE,
	p_end_date_active		IN DATE,
	p_context			IN VARCHAR2,
	p_attribute1			IN VARCHAR2,
	p_attribute2			IN VARCHAR2,
	p_attribute3			IN VARCHAR2,
	p_attribute4			IN VARCHAR2,
	p_attribute5			IN VARCHAR2,
	p_attribute6			IN VARCHAR2,
	p_attribute7			IN VARCHAR2,
	p_attribute8			IN VARCHAR2,
	p_attribute9			IN VARCHAR2,
	p_attribute10			IN VARCHAR2,
	p_attribute11			IN VARCHAR2,
	p_attribute12			IN VARCHAR2,
	p_attribute13			IN VARCHAR2,
	p_attribute14			IN VARCHAR2,
	p_attribute15			IN VARCHAR2,
	p_object_version_number	IN NUMBER
	);

PROCEDURE Update_Row(
	p_cs_contact_id		        IN NUMBER,
	p_customer_Product_id		IN NUMBER,
	p_contact_category              IN VARCHAR2,
	p_contact_type			IN VARCHAR2,
	p_contact_id			IN NUMBER,
	p_primary_flag			IN VARCHAR2,
	p_preferred_flag		IN VARCHAR2,
	p_svc_provider_flag		IN VARCHAR2,
	p_start_date_active		IN DATE,
	p_end_date_active		IN DATE,
	p_context			IN VARCHAR2,
	p_attribute1			IN VARCHAR2,
	p_attribute2			IN VARCHAR2,
	p_attribute3			IN VARCHAR2,
	p_attribute4			IN VARCHAR2,
	p_attribute5			IN VARCHAR2,
	p_attribute6			IN VARCHAR2,
	p_attribute7			IN VARCHAR2,
	p_attribute8			IN VARCHAR2,
	p_attribute9			IN VARCHAR2,
	p_attribute10			IN VARCHAR2,
	p_attribute11			IN VARCHAR2,
	p_attribute12			IN VARCHAR2,
	p_attribute13			IN VARCHAR2,
	p_attribute14			IN VARCHAR2,
	p_attribute15			IN VARCHAR2,
	p_object_version_number	        IN NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR,
	x_object_version_number         OUT NOCOPY NUMBER
	);

PROCEDURE Delete_Row(
	x_return_status	 OUT NOCOPY VARCHAR,
	x_msg_count	 OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR,
	p_cs_contact_id		IN NUMBER,
        P_Object_Version_Number IN NUMBER
	);
end csi_ext_contacts_pkg;

 

/
