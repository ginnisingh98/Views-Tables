--------------------------------------------------------
--  DDL for Package AK_FLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_FLOW_PUB" AUTHID CURRENT_USER as
/* $Header: akdpflos.pls 115.7 2002/09/27 17:56:33 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_FLOW_PUB';

-- Type definitions

-- Flow Record

TYPE Flow_Rec_Type IS RECORD (
flow_application_id     NUMBER                    := NULL,
flow_code               VARCHAR2(30)              := NULL,
primary_page_appl_id    NUMBER                    := NULL,
primary_page_code       VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
name                    VARCHAR2(30)              := NULL,
description             VARCHAR2(2000)            := NULL,
created_by		  NUMBER		    := NULL,
creation_date		  DATE			    := NULL,
last_updated_by	  NUMBER                    := NULL,
lasT_update_date	  DATE                      := NULL,
last_update_login	  NUMBER                    := NULL
);

-- Flow Page Record

TYPE Page_Rec_Type IS RECORD (
flow_application_id     NUMBER                    := NULL,
flow_code               VARCHAR2(30)              := NULL,
page_application_id     NUMBER                    := NULL,
page_code               VARCHAR2(30)              := NULL,
primary_region_appl_id  NUMBER                    := NULL,
primary_region_code     VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
name                    VARCHAR2(80)              := NULL,
description             VARCHAR2(2000)            := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
lasT_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Flow Page Region Record
-- (plus foreign_key_name for creating a flow_region_relation record)

TYPE Page_Region_Rec_Type IS RECORD (
flow_application_id     NUMBER                    := NULL,
flow_code               VARCHAR2(30)              := NULL,
page_application_id     NUMBER                    := NULL,
page_code               VARCHAR2(30)              := NULL,
region_application_id   NUMBER                    := NULL,
region_code             VARCHAR2(30)              := NULL,
display_sequence        NUMBER                    := NULL,
region_style            VARCHAR2(30)              := NULL,
num_columns             NUMBER                    := NULL,
icx_custom_call         VARCHAR2(240)             := NULL,
parent_region_appl_id   NUMBER                    := NULL,
parent_region_code      VARCHAR2(30)              := NULL,
foreign_key_name        VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
lasT_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Flow Page Region Item Record

TYPE Page_Region_Item_Rec_Type IS RECORD (
flow_application_id     NUMBER                    := NULL,
flow_code               VARCHAR2(30)              := NULL,
page_application_id     NUMBER                    := NULL,
page_code               VARCHAR2(30)              := NULL,
region_application_id   NUMBER                    := NULL,
region_code             VARCHAR2(30)              := NULL,
attribute_application_id NUMBER                   := NULL,
attribute_code          VARCHAR2(30)              := NULL,
to_page_appl_id         NUMBER                    := NULL,
to_page_code            VARCHAR2(30)              := NULL,
to_url_attribute_appl_id NUMBER                   := NULL,
to_url_attribute_code   VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
lasT_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Flow Region Relation Record

TYPE Region_Relation_Rec_Type IS RECORD (
flow_application_id     NUMBER                    := NULL,
flow_code               VARCHAR2(30)              := NULL,
foreign_key_name        VARCHAR2(30)              := NULL,
from_page_appl_id       NUMBER                    := NULL,
from_page_code          VARCHAR2(30)              := NULL,
from_region_appl_id     NUMBER                    := NULL,
from_region_code        VARCHAR2(30)              := NULL,
to_page_appl_id         NUMBER                    := NULL,
to_page_code            VARCHAR2(30)              := NULL,
to_region_appl_id       NUMBER                    := NULL,
to_region_code          VARCHAR2(30)              := NULL,
application_id          NUMBER                    := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
lasT_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Flow key record

TYPE Flow_PK_Rec_Type IS RECORD (
flow_appl_id       NUMBER := NULL,
flow_code          VARCHAR2(30) := NULL
);

-- Tables

TYPE Flow_Tbl_Type IS TABLE OF Flow_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Flow_PK_Tbl_Type IS TABLE OF Flow_PK_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Page_Tbl_Type IS TABLE OF Page_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Page_Region_Tbl_Type IS TABLE OF Page_Region_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Page_Region_Item_Tbl_Type IS TABLE OF Page_Region_Item_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Region_Relation_Tbl_Type IS TABLE OF Region_Relation_Rec_Type
INDEX BY BINARY_INTEGER;


/* Constants for missing data types */
G_MISS_FLOW_REC              Flow_Rec_Type;
G_MISS_FLOW_TBL              Flow_Tbl_Type;
G_MISS_FLOW_PK_REC           Flow_PK_Rec_Type;
G_MISS_FLOW_PK_TBL           Flow_PK_Tbl_Type;
G_MISS_PAGE_REC              Page_Rec_Type;
G_MISS_PAGE_TBL              Page_Tbl_Type;
G_MISS_PAGE_REGION_REC       Page_Region_Rec_Type;
G_MISS_PAGE_REGION_TBL       Page_Region_Tbl_Type;
G_MISS_PAGE_REGION_ITEM_REC  Page_Region_Item_Rec_Type;
G_MISS_PAGE_REGION_ITEM_TBL  Page_Region_Item_Tbl_Type;
G_MISS_REGION_RELATION_REC   Region_Relation_Rec_Type;
G_MISS_REGION_RELATION_TBL   Region_Relation_Tbl_Type;

end AK_FLOW_PUB;

 

/
