--------------------------------------------------------
--  DDL for Package ASO_QUOTE_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_MISC_PVT" AUTHID CURRENT_USER AS
/* $Header: asovqmis.pls 115.1 2002/05/21 17:02:38 pkm ship    $ */
-- Start of Comments
-- Package name     : ASO_TAX_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--   Record Type:
--   Charge_Control_Rec_Type


PROCEDURE Debug_Tax_Info_Notification (
   p_qte_header_rec      IN ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE
  ,p_Hd_Shipment_Rec     IN ASO_QUOTE_PUB.SHIPMENT_REC_TYPE
  ,p_reason              IN VARCHAR2
  );

End ASO_Quote_Misc_PVT;

 

/
