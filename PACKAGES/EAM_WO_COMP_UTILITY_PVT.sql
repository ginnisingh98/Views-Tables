--------------------------------------------------------
--  DDL for Package EAM_WO_COMP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_COMP_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWCUS.pls 120.1 2005/10/21 16:51:16 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWCUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_COMP_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Perform_Writes (
	p_eam_wo_comp_rec	IN  EAM_PROCESS_WO_PUB. eam_wo_comp_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  );

PROCEDURE insert_row (
	p_eam_wo_comp_rec     IN  EAM_PROCESS_WO_PUB. eam_wo_comp_rec_type
	, x_return_status     OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl    OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 );

PROCEDURE update_row (
	  p_eam_wo_comp_rec     IN  EAM_PROCESS_WO_PUB. eam_wo_comp_rec_type
        , x_return_status       OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

INVENTORY_ITEM_NULL EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;

TYPE Lot_Serial_Rec_Type is RECORD
(
	lot_number		VARCHAR2(80),
	serial_number		VARCHAR2(30),
	quantity		NUMBER
);

TYPE Lot_Serial_Tbl_Type is TABLE OF Lot_Serial_Rec_Type INDEX BY BINARY_INTEGER;

END EAM_WO_COMP_UTILITY_PVT;

 

/
