--------------------------------------------------------
--  DDL for Package Body OKE_FORM_DD250_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FORM_DD250_EXT" AS
/* $Header: OKEMIRXB.pls 115.0 2003/11/20 20:27:49 alaw noship $ */

--
-- Global Declarations
--
G_PKG_NAME     VARCHAR2(30) := 'OKE_FORM_DD250_EXT';

--
-- Private Procedures and Functions
--

FUNCTION Override_Shipment_Prefix
( P_K_Header_ID          IN           NUMBER
, P_Delivery_ID          IN           NUMBER
, P_Inv_Org_ID           IN           NUMBER
, P_Ship_From_Loc_ID     IN           NUMBER
) RETURN VARCHAR2 IS

BEGIN

  RETURN ( NULL );

END Override_Shipment_Prefix;


PROCEDURE Override_Form_Data
( P_K_Header_ID          IN           NUMBER
, P_Delivery_ID          IN           NUMBER
, P_Hdr_Rec              IN           OKE_FORM_DD250.Hdr_Rec_Type
, P_Line_Tbl             IN           OKE_FORM_DD250.Line_Tbl_Type
, X_Hdr_Rec              OUT NOCOPY   OKE_FORM_DD250.Hdr_Rec_Type
, X_Line_Tbl             OUT NOCOPY   OKE_FORM_DD250.Line_Tbl_Type
) IS

BEGIN

  X_Hdr_Rec := P_Hdr_Rec;
  X_Line_Tbl := P_Line_Tbl;

END Override_Form_Data;

END OKE_FORM_DD250_EXT;

/
