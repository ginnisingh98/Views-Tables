--------------------------------------------------------
--  DDL for Package OE_UPG_INSTALL_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UPG_INSTALL_DETAILS" AUTHID CURRENT_USER as
/* $Header: OEXIUIDS.pls 120.0 2005/05/31 23:29:10 appldev noship $ */

PROCEDURE Upgrade_Install_Details
  (
   p_slab IN NUMBER DEFAULT NULL
   );


PROCEDURE Get_Line_Inst_Details
(   p_line_inst_details_id          IN  NUMBER
, x_line_inst_dtl_rec OUT NOCOPY CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type

, x_line_inst_dtl_desc_flex OUT NOCOPY CS_InstalledBase_PUB.DFF_Rec_Type

);


END oe_upg_install_details;


 

/
