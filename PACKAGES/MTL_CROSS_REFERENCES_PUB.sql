--------------------------------------------------------
--  DDL for Package MTL_CROSS_REFERENCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CROSS_REFERENCES_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPXRFS.pls 120.0.12010000.2 2010/01/13 00:30:16 akbharga noship $ */

/* This API can insert,update and delete cross references associated with
particular Items. This is not supporting Cross References having type as 'GTIN'
and Source System(SS_ITEM_XREF).

 p_api_version: A decimal number indicating major and minor revisions to
the API (where major revisions change the portion of the number before the
decimal and minor revisions change the portion of the number after the decimal).
Pass 1.0 unless otherwise indicated in the API parameter list.

 p_init_msg_list: A one-character flag indicating whether to initialize the
FND_MSG_PUB package's message stack at the beginning of API processing(which
removes any messages that may exist on the stack from prior processing in the
same session). Valid values are FND_API.G_TRUE and  FND_API.G_FALSE.

 p_commit: A one-character flag indicating whether to commit work at the end
of API processing.  Valid values are FND_API.G_TRUE and FND_API.G_FALSE.

 x_return_status: A one-character code indicating whether any errors occurred
during processing (in which case error messages will be present on the
FND_MSG_PUB package's message stack).Valid values are FND_API.G_RET_STS_SUCCESS,
FND_API.G_RET_STS_ERROR, and FND_API.G_RET_STS_UNEXP_ERROR.

 x_msg_count: An integer indicating the number of messages on the FND_MSG_PUB
package's message stack at the end of API processing.  For information about
how to retrieve messages from the message stack, refer to FND_MSG_PUB
documentation.

 x_msg_data: A character string containing message text; will be nonempty only
when x_msg_count is exactly 1. This is a convenience feature so that callers
need not interact with the message stack when it contains only one message
(as is commonly the case).
*/


G_BO_Identifier                         CONSTANT             VARCHAR2(30) :=  'XRef';

TYPE XRef_Rec_Type IS RECORD
  (
  Transaction_Type                        VARCHAR2(30)         DEFAULT      FND_API.G_MISS_CHAR
  ,X_Return_Status                        VARCHAR2(1)          DEFAULT      FND_API.G_MISS_CHAR
  -- Primary Key Columns
  ,Inventory_Item_Id                      NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Organization_Id                        NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Cross_Reference_Type                   VARCHAR2(25)         DEFAULT      FND_API.G_MISS_CHAR
  ,Cross_Reference                        VARCHAR2(25)         DEFAULT      FND_API.G_MISS_CHAR
  -- As cross_reference_id is present,for uniquely identifying
  -- the row we have to use this.(Must be populated for Update and Delete)
  ,Cross_Reference_Id                     NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Description                            VARCHAR2(240)        DEFAULT      FND_API.G_MISS_CHAR
  ,Org_Independent_Flag                   VARCHAR2(1)          DEFAULT      FND_API.G_MISS_CHAR
  --Who Columns
  ,Last_Update_Date                       DATE                 DEFAULT      FND_API.G_MISS_DATE
  ,Last_Updated_By                        NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Creation_Date                          DATE                 DEFAULT      FND_API.G_MISS_DATE
  ,Created_By                             NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Last_Update_Login                      NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Request_id                             NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Program_Application_Id                 NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Program_Id                             NUMBER               DEFAULT      FND_API.G_MISS_NUM
  ,Program_Update_Date                    DATE                 DEFAULT      FND_API.G_MISS_DATE
  -- DFF
  ,Attribute1                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute2                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute3                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute4                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute5                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute6                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute7                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute8                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute9                             VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute10                            VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute11                            VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute12                            VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute13                            VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute14                            VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute15                            VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Attribute_category                     VARCHAR2(150)        DEFAULT      FND_API.G_MISS_CHAR
  ,Uom_Code                               VARCHAR2(3)          DEFAULT      FND_API.G_MISS_CHAR
  ,Revision_Id                            NUMBER               DEFAULT      FND_API.G_MISS_NUM );

TYPE XRef_Tbl_Type  IS TABLE OF XRef_Rec_Type INDEX BY BINARY_INTEGER;

-- -----------------------------------------------------------------------------
-- API Name: Process_XRef
--
-- Description :
--    Public API used to call the Private API for (CREATE/UPDATE/DELETE) a set of
--    Cross References based on data in the pl/sql table.
-- -----------------------------------------------------------------------------

PROCEDURE Process_XRef(
   p_api_version        IN                NUMBER
  ,p_init_msg_list      IN                VARCHAR2             DEFAULT      FND_API.G_FALSE
  ,p_commit             IN                VARCHAR2             DEFAULT      FND_API.G_FALSE
  ,p_XRef_Tbl           IN OUT NOCOPY     MTL_CROSS_REFERENCES_PUB.XRef_Tbl_Type
  ,x_return_status      OUT    NOCOPY     VARCHAR2
  ,x_msg_count          OUT    NOCOPY     NUMBER
  ,x_message_list       OUT    NOCOPY           Error_Handler.Error_Tbl_Type);

END MTL_CROSS_REFERENCES_PUB;

/
