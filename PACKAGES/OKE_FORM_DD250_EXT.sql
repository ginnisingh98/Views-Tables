--------------------------------------------------------
--  DDL for Package OKE_FORM_DD250_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FORM_DD250_EXT" AUTHID CURRENT_USER AS
/* $Header: OKEMIRXS.pls 115.0 2003/11/20 20:27:42 alaw noship $ */

--
-- This function allows you to override the prefix of the shipment
-- number.  If no value is returned, the prefix will be defaulted
-- using the organization code of the shipping organization, right-
-- padded with "X" up to 3 characters.
--
FUNCTION Override_Shipment_Prefix
( P_K_Header_ID          IN           NUMBER
, P_Delivery_ID          IN           NUMBER
, P_Inv_Org_ID           IN           NUMBER
, P_Ship_From_Loc_ID     IN           NUMBER
) RETURN VARCHAR2;


--
-- This function allows you to override data in any block of
-- DD250.  For address information, please refer to the package
-- OKE_FORM_DD250 on how it is stored.
--
PROCEDURE Override_Form_Data
( P_K_Header_ID          IN           NUMBER
, P_Delivery_ID          IN           NUMBER
, P_Hdr_Rec              IN           OKE_FORM_DD250.Hdr_Rec_Type
, P_Line_Tbl             IN           OKE_FORM_DD250.Line_Tbl_Type
, X_Hdr_Rec              OUT NOCOPY   OKE_FORM_DD250.Hdr_Rec_Type
, X_Line_Tbl             OUT NOCOPY   OKE_FORM_DD250.Line_Tbl_Type
);


END OKE_FORM_DD250_EXT;

 

/
