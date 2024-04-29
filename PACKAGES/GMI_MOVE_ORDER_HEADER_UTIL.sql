--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_HEADER_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMIUMOHS.pls 120.0 2005/05/26 00:17:29 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUMOHS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Move Order Header Utilities                                         |
 |                                                                         |
 | - Process_Move_Order_Header                                             |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     27-Apr-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Move_Order_Header_Util
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/
/*
   Attributes global constants
*/
G_ATTRIBUTE1                  CONSTANT NUMBER := 1;
G_ATTRIBUTE10                 CONSTANT NUMBER := 2;
G_ATTRIBUTE11                 CONSTANT NUMBER := 3;
G_ATTRIBUTE12                 CONSTANT NUMBER := 4;
G_ATTRIBUTE13                 CONSTANT NUMBER := 5;
G_ATTRIBUTE14                 CONSTANT NUMBER := 6;
G_ATTRIBUTE15                 CONSTANT NUMBER := 7;
G_ATTRIBUTE2                  CONSTANT NUMBER := 8;
G_ATTRIBUTE3                  CONSTANT NUMBER := 9;
G_ATTRIBUTE4                  CONSTANT NUMBER := 10;
G_ATTRIBUTE5                  CONSTANT NUMBER := 11;
G_ATTRIBUTE6                  CONSTANT NUMBER := 12;
G_ATTRIBUTE7                  CONSTANT NUMBER := 13;
G_ATTRIBUTE8                  CONSTANT NUMBER := 14;
G_ATTRIBUTE9                  CONSTANT NUMBER := 15;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 16;
G_CREATED_BY                  CONSTANT NUMBER := 17;
G_CREATION_DATE               CONSTANT NUMBER := 18;
G_DATE_REQUIRED               CONSTANT NUMBER := 19;
G_DESCRIPTION                 CONSTANT NUMBER := 20;
G_FROM_SUBINVENTORY           CONSTANT NUMBER := 21;
G_HEADER                      CONSTANT NUMBER := 22;
G_HEADER_STATUS               CONSTANT NUMBER := 23;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 24;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 25;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 26;
G_ORGANIZATION                CONSTANT NUMBER := 27;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 28;
G_PROGRAM                     CONSTANT NUMBER := 29;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 30;
G_REQUEST                     CONSTANT NUMBER := 31;
G_REQUEST_NUMBER              CONSTANT NUMBER := 32;
G_STATUS_DATE                 CONSTANT NUMBER := 33;
G_TO_ACCOUNT                  CONSTANT NUMBER := 34;
G_TO_SUBINVENTORY             CONSTANT NUMBER := 35;
G_MOVE_ORDER_TYPE             CONSTANT NUMBER := 36;
G_TRANSACTION_TYPE	      CONSTANT NUMBER := 37;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 38;
G_SHIP_TO_LOCATION_ID         CONSTANT NUMBER := 39;

/*   Procedure Clear_Dependent_Attr
   Procedure Apply_Attribute_Changes
   Function Get_Values
   Function Get_Ids
*/

FUNCTION Complete_Record
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
,   p_old_mo_hdr_rec                IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
) RETURN GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC;


FUNCTION Convert_Miss_To_Null
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
) RETURN GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC;


PROCEDURE Update_Row
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
);


PROCEDURE Update_Row_Status
(   p_header_id                         IN      Number,
    p_status                            IN      Number
);


PROCEDURE Insert_Row
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
);


PROCEDURE Delete_Row
(   p_header_id                     IN  NUMBER
);


FUNCTION Query_Row
(   p_header_id                     IN  NUMBER
) RETURN GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC;


PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
,   x_mo_hdr_rec                    OUT NOCOPY GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
);


END GMI_Move_Order_Header_Util;

 

/
