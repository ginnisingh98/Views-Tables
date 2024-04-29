--------------------------------------------------------
--  DDL for Package Body AST_API_RECORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_API_RECORDS_PKG" AS
 /* $Header: astutirb.pls 120.4 2005/11/07 07:54:12 rkumares ship $ */

  -- *****************************************************
  FUNCTION Init_JTF_Perz_Query_Raw_Rec RETURN JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE IS
    l_return_rec JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE;
  BEGIN
    l_return_rec := JTF_PERZ_QUERY_PUB.G_MISS_QUERY_RAW_SQL_REC;
    RETURN l_return_rec ;
  END;
  -- *****************************************************
  FUNCTION Init_JTF_Perz_Query_Param_Rec RETURN JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE IS
    l_return_rec JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;
  -- *****************************************************
  FUNCTION Init_JTF_Perz_Query_Order_Rec RETURN JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE IS
    l_return_rec JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;
  -- *****************************************************
  FUNCTION Init_JTF_Perz_Prof_Attr_Rec RETURN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE IS
    l_return_rec JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;
  -- *****************************************************
  PROCEDURE Init_Record ( x_query_raw_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE) IS
  BEGIN
    x_query_raw_rec := Init_JTF_Perz_Query_Raw_Rec;
  END;
  -- *****************************************************
  PROCEDURE Init_Record ( x_query_param_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_REC_TYPE) IS
  BEGIN
    x_query_param_rec := Init_JTF_Perz_Query_Param_Rec;
  END;
  -- *****************************************************
  PROCEDURE Init_Record ( x_query_order_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_REC_TYPE) IS
  BEGIN
    x_query_order_rec := Init_JTF_Perz_Query_Order_Rec;
  END;
  -- *****************************************************
  PROCEDURE Init_Record ( x_profile_attr_rec IN OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_REC_TYPE) IS
  BEGIN
    x_profile_attr_rec := Init_JTF_Perz_Prof_Attr_Rec;
  END;
  -- *****************************************************
  FUNCTION INIT_AS_INTEREST_REC RETURN AS_INTEREST_PUB.INTEREST_REC_TYPE IS
    l_return_rec AS_INTEREST_PUB.INTEREST_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;
    -- *****************************************************
  FUNCTION INIT_JTF_NOTES_PUB_CONTEXT_TBL RETURN JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE IS
    l_return_tbl JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE ;
  BEGIN
    l_return_tbl := JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TAB_DFLT;
    RETURN l_return_tbl ;
  END;

FUNCTION Get_OE_Order_Header_Rec RETURN ASO_ORDER_INT.Order_Header_rec_type
IS
  l_rec ASO_ORDER_INT.Order_Header_rec_type;
BEGIN
  l_rec := ASO_ORDER_INT.G_MISS_Order_Header_Rec;
  RETURN l_rec;
END ;

 ----------------------------------------------------------
FUNCTION  Get_PV_Entity_Rec_Type  RETURN  PV_ENTY_ATTR_VALUE_PVT.enty_attr_val_rec_type
 IS
 TMP_REC  PV_ENTY_ATTR_VALUE_PVT.enty_attr_val_rec_type;
BEGIN
  RETURN   TMP_REC;
END Get_PV_Entity_Rec_Type;

    -- *****************************************************
		--------------------------------------------------------


END AST_API_RECORDS_PKG;

/
