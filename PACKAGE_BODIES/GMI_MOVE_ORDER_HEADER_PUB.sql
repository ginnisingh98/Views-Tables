--------------------------------------------------------
--  DDL for Package Body GMI_MOVE_ORDER_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MOVE_ORDER_HEADER_PUB" AS
/*  $Header: GMIPMOHB.pls 115.12 2003/04/22 12:58:48 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPMOHB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Move Order Header.                                                  |
 |                                                                         |
 | - Process_Move_Order_Header                                             |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  Hverddin        Created                                |
 |     02-AUG-2000  J. DiIorio commented out dbms_output                   |
 |     14-SEP-2000  odaboval   removed dummy calls .                       |
 |                                                                         |
 +=========================================================================+
  API Name  : GMI_Move_Order_Header_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

/*  Global variables   */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_MOVE_ORDER_HEADER_PUB';

PROCEDURE Process_Move_Order_Header
 (
   p_api_version_number          IN  NUMBER
 , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_flag             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
 , p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_mo_hdr_rec                  IN  GMI_Move_Order_Global.MO_HDR_REC
 , x_mo_hdr_rec                  OUT NOCOPY GMI_Move_Order_Global.MO_HDR_REC
 , x_return_status               OUT  NOCOPY VARCHAR2
 , x_msg_count                   OUT  NOCOPY NUMBER
 , x_msg_data                    OUT  NOCOPY VARCHAR2
 )
 IS
 l_api_name           CONSTANT VARCHAR2 (30) := 'PROCESS_MOVE_ORDER_HEADER';
 l_api_version_number CONSTANT NUMBER        := 1.0;
 l_msg_count          NUMBER  :=0;
 l_msg_data           VARCHAR2(2000);
 l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_mo_hdr_rec         GMI_MOVE_ORDER_GLOBAL.mo_hdr_rec;
-- HW NOCOPY changes
 ll_mo_hdr_rec         GMI_MOVE_ORDER_GLOBAL.mo_hdr_rec;


 BEGIN

gmi_reservation_util.println('n Process_Move_Order_Header');
gmi_reservation_util.println('value of p_mo_hdr_rec.organization_id: '||p_mo_hdr_rec.organization_id);
gmi_reservation_util.println('Value of p_mo_hdr_rec.request_number is '||p_mo_hdr_rec.request_number);
   /* DBMS_OUTPUT.PUT_LINE('IN MOVE ORDER HDR');
     ************ DO I NEED SAVE POINT FOR PUBLIC DECLARATION *******
     Standard call to check for call compatibility.
    */

   IF NOT FND_API.Compatible_API_CALL ( l_api_version_number
				   , p_api_version_number
           , l_api_name
				   , G_PKG_NAME
				   )
     THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	 /*  Initialize message list if p_int_msg_lst is set TRUE.   */
   IF FND_API.to_boolean(p_init_msg_lst)
     THEN
     FND_MSG_PUB.Initialize;
   END IF;

  /*  Initialize API return status to sucess   */
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  WSH_Util_Core.PrintLn('Entering_GMI_Create_Move_Order_Header with operation='||p_mo_hdr_rec.operation);

  WSH_Util_Core.PrintLn('Batch NAME => ' || p_mo_hdr_rec.request_number);

  WSH_Util_Core.PrintLn('Call Convert Missing To Null');

-- HW commented call as part of bug 2643440
-- Since G_MISS_XXX is removed, no need to call conver_miss_to_null
   l_mo_hdr_rec := GMI_MOVE_ORDER_HEADER_UTIL.Convert_Miss_To_Null
			  ( p_mo_hdr_rec => p_mo_hdr_rec);

gmi_reservation_util.println('Afrer calling GMI_MOVE_ORDER_HEADER_UTIL.Convert_Miss_To_Null');
gmi_reservation_util.println('value of l_mo_hdr_rec.organization_id: '||l_mo_hdr_rec.organization_id);
gmi_reservation_util.println('Value of l_mo_hdr_rec.operation is '||l_mo_hdr_rec.request_number);

  WSH_Util_Core.PrintLn('Batch NAME => ' || l_mo_hdr_rec.request_number);

  WSH_Util_Core.PrintLn('CAlling Move order Header PVT');

gmi_reservation_util.println('Going to call GMI_Move_Order_Header_PVT.Process_Move_Order_Header');
-- HW OPM use ll_mo_hdr_rec
  GMI_Move_Order_Header_PVT.Process_Move_Order_Header
  (
    p_api_version_number  => p_api_version_number,
    p_init_msg_lst        => p_init_msg_lst,
    p_validation_flag     => p_validation_flag,
    p_commit              => p_commit,
    p_mo_hdr_rec          => l_mo_hdr_rec,
    x_mo_hdr_rec          => ll_mo_hdr_rec,
    x_return_status       => l_return_status,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data
   );

  /*  Set up return Variables.   */
  --  HW NOCOPY use ll_mo_hdr_rec
  x_mo_hdr_rec := ll_mo_hdr_rec;


  gmi_reservation_util.println('Value of x_mo_hdr_rec.organization_id is '||x_mo_hdr_rec.organization_id);
  gmi_reservation_util.println('Value of x_mo_hdr_rec.header_id is '||x_mo_hdr_rec.header_id);

/*   GMI_Move_Order_Header_Util.Insert_Row( l_mo_hdr_rec);   */

/*    FND_MESSAGE.Set_Name('GMI','Entering_GMI_Create_Move_Order_Header');
      FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
*/


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      /*   Get message count and data  */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;

	 FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
			      , l_api_name
      				);


      /*   Get message count and data   */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );



END Process_Move_Order_Header;

END GMI_Move_Order_Header_PUB;

/
