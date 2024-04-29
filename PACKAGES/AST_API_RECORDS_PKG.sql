--------------------------------------------------------
--  DDL for Package AST_API_RECORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_API_RECORDS_PKG" AUTHID CURRENT_USER AS
 /* $Header: astutirs.pls 120.4 2005/11/07 07:54:09 rkumares ship $ */

  -- Start of comments
  -- API name   : Init_JTF_Perz_Query_Raw_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by JTF_PERZ_QUERY_PUB
  -- Parameters : None
  -- Returns    : JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_JTF_Perz_Query_Raw_Rec RETURN JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE;
  -- Start of comments
  -- API name   : Init_JTF_Perz_Query_Param_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new query parameter record type
  --              as required by JTF_PERZ_QUERY_PUB
  -- Parameters : None
  -- Returns    : JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_JTF_Perz_Query_Param_Rec RETURN JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE;
  -- Start of comments
  -- API name   : Init_JTF_Perz_Query_Order_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new query order-by record type
  --              as required by JTF_PERZ_QUERY_PUB
  -- Parameters : None
  -- Returns    : JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_JTF_Perz_Query_Order_Rec RETURN JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE;
  -- Start of comments
  -- API name   : Init_JTF_Perz_Prof_Attr_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new personal profile attributes record type
  --              as required by JTF_PERZ_PROFILE_PUB
  -- Parameters : None
  -- Returns    : JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_JTF_Perz_Prof_Attr_Rec RETURN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE;
  -- Start of comments
  -- API name   : Init_Record
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by JTF_PERZ_QUERY_PUB
  -- Parameters :
  --              x_query_raw_rec IN OUT  JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE
  --
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  PROCEDURE Init_Record ( x_query_raw_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE);
  -- Start of comments
  -- API name   : Init_Record
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes a query parameter record type
  --              as required by JTF_PERZ_QUERY_PUB
  -- Parameters :
  --              x_query_param_rec IN OUT  JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE Required
  --
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  PROCEDURE Init_Record ( x_query_param_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE);
  -- Start of comments
  -- API name   : Init_Record
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes a query order-by record type
  --              as required by JTF_PERZ_QUERY_PUB
  -- Parameters :
  --              x_query_order_rec IN OUT  JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE Required
  --
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  PROCEDURE Init_Record ( x_query_order_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE);
  -- Start of comments
  -- API name   : Init_Record
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes a personal profile attributes record type
  --              as required by JTF_PERZ_PROFILE_PUB
  -- Parameters :
  --               x_profile_attr_rec IN OUT  JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE Required
  --
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  PROCEDURE Init_Record ( x_profile_attr_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE);
  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in sales Center and response center
  -- API name   : INIT_HZ_INTEREST_REC
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_INTEREST_REC
  -- Parameters : None
  -- Returns    : HZ_PERSON_INFO_PUB.PER_INTEREST_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION INIT_AS_INTEREST_REC RETURN AS_INTEREST_PUB.INTEREST_REC_TYPE;
  -- Start of comments
  -- Start of initialization functions to initialize JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE
  -- Used by the customer, contact modules in sales Center and response center
  -- API name   : INIT_AS_INTEREST_REC
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE
  -- Parameters : None
  -- Returns    : AS_INTEREST_PUB.INTEREST_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION INIT_JTF_NOTES_PUB_CONTEXT_TBL RETURN JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE;

   -- Start of comments
  -- Start of initialization functions to initialize HZ_CUSTOMER_ACCOUNTS_PUB.account_rec_type
  -- Used by the customer, contact modules in sales Center and response center
  -- API name   :
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for  AS_INTEREST_PUB.INTEREST_REC_TYPE
  -- Parameters : None
  -- Returns    : AS_INTEREST_PUB.INTEREST_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
-- swkhanna 6/22/00 added the following record types for Accounts tab and Accounts Details





-- nprasad 3/28/02 added the following record type for Partner tab in Lead Center

FUNCTION  Get_PV_Entity_Rec_Type  RETURN  PV_ENTY_ATTR_VALUE_PVT.enty_attr_val_rec_type;

-- end modification by swkhanna 06/21/00

-- Start of comments
-- API name   : Get_OE_Order_Header_Rec
-- Type       : Private
-- Pre-reqs   : None.
-- Function   : Initializes and returns the record type for ASO_ORDER_INT.Order_Header_rec_type
-- Parameters : None
-- Returns    : ASO_ORDER_INT.Order_Header_rec_type
-- Version    : Current version 1.0
--              Initial version 1.0
-- End of comments
FUNCTION Get_OE_Order_Header_Rec RETURN ASO_ORDER_INT.Order_Header_rec_type;



  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_ORG_REC
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_ORG_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_PUB.ORGANIZATION_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
END AST_API_RECORDS_PKG;

 

/
