--------------------------------------------------------
--  DDL for Package Body GMI_MOVE_ORDER_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MOVE_ORDER_LINES_PUB" AS
/*  $Header: GMIPMOLB.pls 120.2 2008/01/10 17:35:49 plowe ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPMOLB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Move Order line .                                                  |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  hverddin        Created                                |
 |     02-AUG-2000  jdiiorio        Commented out dbms_output              |
 |     14-Sep-2000  odaboval  Removed dummy calls.                         |
 |     29-Apr-2005  methomas  B4276612 Added Code for 3rd Party Integration|
 |                            to initiate Sales Order XML Outbound.        |
 |     25-Aug-2005  nchekuri  Bug#4500071. Added NOCOPY for OUT Variables  |
 |     10-Jan-2007  plowe     Bug 6733409. New parameter added to call to  |
 |                            GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER	to
 |                            ensure that this package is not invalid
 |                            PLEASE NOTE  - THIS CODE IS NOT EXECUTED IN
 |                            R12  as call is now in INV code
 |                            INV_Move_Order_PUB after Inventory Convergence
 +=========================================================================+
  API Name  : GMI_Move_Order_lines_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/
/*
  Global variables
*/
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_MOVE_ORDER_LINES_PUB';

PROCEDURE Process_Move_Order_lines
  (
     p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag       IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_LINE_tbl           IN  GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_mo_LINE_tbl           OUT NOCOPY GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
  )
 IS
 l_api_name           CONSTANT VARCHAR2 (30) := 'PROCESS_MOVE_ORDER_LINES';
 l_api_version_number CONSTANT NUMBER        := 1.0;
 l_msg_count          NUMBER  :=0;
 l_msg_data           VARCHAR2(2000);
 l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_mo_line_rec       GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
 l_mo_line_tbl       GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;

 CURSOR get_sales_order (V_line_id NUMBER) IS
 select h.order_number
 from oe_order_headers_all h
     ,oe_order_lines_all l
 where l.header_id = h.header_id
 and l.line_id = V_line_id;
 l_source_line_id     NUMBER;
 l_error_code         NUMBER;


 BEGIN
/*  DBMS_OUTPUT.PUT_line('IN MOVE ORDER line');
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

/*    Initialize message list if p_int_msg_lst is set TRUE.   */
   IF FND_API.to_boolean(p_init_msg_lst)
     THEN
     FND_MSG_PUB.Initialize;
   END IF;

/*    Initialize API return status to sucess   */
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  WSH_Util_Core.PrintLn('Call Convert Missing To Null');

  FOR I in 1..p_mo_line_tbl.COUNT LOOP

    l_mo_line_rec := p_mo_line_tbl(I);

    WSH_Util_Core.PrintLn('_Move_Order_line => '||l_mo_line_rec.operation);

-- HW BUG#:2643440 No need to call Convert_Miss_To_Null since
-- the record is set to NULL already
    l_mo_line_rec := GMI_MOVE_ORDER_line_UTIL.Convert_Miss_To_Null
	     		 ( p_mo_line_rec => l_mo_line_rec);

    l_mo_line_tbl(I) := l_mo_line_rec;

  END LOOP;

  WSH_Util_Core.PrintLn('CAlling Move order Lines PVT');

  GMI_Move_Order_lines_PVT.Process_Move_Order_lines
  (
     p_api_version_number  => l_api_version_number
   , p_init_msg_lst        => p_init_msg_lst
   , p_validation_flag     => p_validation_flag
   , p_commit              => p_commit
   , p_mo_LINE_tbl         => l_mo_line_tbl
   , x_mo_LINE_tbl         => l_mo_line_tbl
   , x_return_status       => l_return_status
   , x_msg_count           => l_msg_count
   , x_msg_data            => l_msg_data
  );

/*    Return Output Variables   */

  x_mo_line_tbl := l_mo_line_tbl;
  WSH_Util_Core.PrintLn('Count MOL table => ' || x_mo_line_tbl.count);

  /* Bug 4276612 Added the following to initate the Outbound for Third Party Integration */
  OPEN get_sales_order(l_mo_line_rec.txn_source_line_id);
  FETCH get_sales_order INTO l_source_line_id;
  CLOSE get_sales_order;

-- new parameter added to call to GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER	to
-- ensure that this package is not invalid
-- PLEASE NOTE  - THIS CODE IS NOT EXECUTED IN R12  as call is now in INV code  INV_Move_Order_PUB after Inventory Convergence
  GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER
	(p_api_version         => l_api_version_number,
	 p_init_msg_list       => p_init_msg_lst,
	 p_commit              => p_commit,
	 p_sales_order_org_id  => 0,   -- dummy value to ensure compilation 6733409
	 p_orgn_id             => l_mo_line_rec.organization_id,
	 p_item_id             => l_mo_line_rec.inventory_item_id,
	 p_sales_order_no      => l_source_line_id,
	 x_return_status       => l_return_status,
	 x_error_code          => l_error_code,
	 x_msg_data            => l_msg_data);

  IF l_return_status <> 'S' THEN
  WSH_Util_Core.PrintLn('Error occured on initiate the Outbound to Third Party with the following error message ' || l_msg_data);
  ELSE
  WSH_Util_Core.PrintLn('Successfully initiated the Outbound to Third Party => ' || l_mo_line_rec.inventory_item_id);
  END IF;
  /* End of the changes for GR Third Party Integration */

/*   GMI_Move_Order_Header_Util.Insert_Row( l_mo_hdr_rec);    */

/*    FND_MESSAGE.Set_Name('GMI','Entering_GMI_Create_Move_Order_Header');  */
/*    FND_MSG_PUB.Add;  */
/*    RAISE FND_API.G_EXC_ERROR;  */

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

/*         Get message count and data  */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;

	 FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
					      , l_api_name
	      				);


/*         Get message count and data   */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );




END Process_Move_Order_lines;

END GMI_Move_Order_lines_PUB;

/
