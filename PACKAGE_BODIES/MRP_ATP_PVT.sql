--------------------------------------------------------
--  DDL for Package Body MRP_ATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ATP_PVT" AS
/* $Header: MRPGATPB.pls 115.253 2002/12/02 20:46:48 dsting ship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MRP_ATP_PVT';


PROCEDURE Extend_Atp (
  p_atp_tab             IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
) IS
Begin
	MSC_SATP_FUNC.Extend_Atp(p_atp_tab, x_return_status);
END Extend_Atp;


PROCEDURE Assign_Atp_Input_Rec (
  p_atp_table          	IN       MRP_ATP_PUB.ATP_Rec_Typ,
  p_index         	IN       NUMBER,
  x_atp_table           IN OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status	OUT	 NoCopy VARCHAR2
) IS
Begin
	MSC_SATP_FUNC.Assign_Atp_Input_Rec (
  		p_atp_table,
  		p_index,
  		x_atp_table,
  		x_return_status);
END Assign_Atp_Input_Rec;


PROCEDURE Assign_Atp_Output_Rec (
  p_atp_table          	IN       MRP_ATP_PUB.ATP_Rec_Typ,
  x_atp_table           IN OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status	OUT	 NoCopy VARCHAR2
) IS
Begin
	MSC_SATP_FUNC.Assign_Atp_Output_Rec (
  		p_atp_table,
  		x_atp_table,
  		x_return_status);
END Assign_Atp_Output_Rec;


END MRP_ATP_PVT;

/
