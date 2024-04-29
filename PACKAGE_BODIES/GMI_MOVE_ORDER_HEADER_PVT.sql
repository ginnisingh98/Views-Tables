--------------------------------------------------------
--  DDL for Package Body GMI_MOVE_ORDER_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MOVE_ORDER_HEADER_PVT" AS
/*  $Header: GMIVMOHB.pls 115.12 2003/04/22 14:04:38 hwahdani ship $ */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_MOVE_ORDER_HEADER_PVT';
/*  Api start of comments
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVMOHB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Private Routines relating to GMI              |
 |     Move Order Header.                                                  |
 |                                                                         |
 | - Process_Move_Order_Header                                             |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  Hverddin        Created                                |
 |   			   									           |
 +=========================================================================+
  API Name  : GMI_Move_Order_HEADER_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

-- HW OPM changes for NOCOPY
-- add NOCOPY to x_mo_hdr_rec
PROCEDURE Process_Move_Order_Header
 (
   p_api_version_number          IN  NUMBER
 , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_flag             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
 , p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_mo_hdr_rec                  IN  GMI_Move_Order_Global.MO_HDR_REC
 , x_mo_hdr_rec                  OUT NOCOPY GMI_Move_Order_Global.MO_HDR_REC
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 )
 IS
 l_api_name           CONSTANT VARCHAR2 (30) := 'PROCESS_MOVE_ORDER_HEADER';
 l_api_version_number CONSTANT NUMBER        := 1.0;
 l_msg_count          NUMBER  :=0;
 l_msg_data           VARCHAR2(2000);
 l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_mo_hdr_rec         GMI_MOVE_ORDER_GLOBAL.mo_hdr_rec:= p_mo_hdr_rec;


 BEGIN

 gmi_reservation_util.println('In move order pvt');
gmi_reservation_util.println('value of p_mo_hdr_rec.organization_id: '||p_mo_hdr_rec.organization_id);
gmi_reservation_util.println('Value of p_mo_hdr_rec.operation is '||p_mo_hdr_rec.request_number);
 /*  Standard Start OF API savepoint */
    SAVEPOINT move_order_header;

   /*  DBMS_OUTPUT.PUT_LINE('IN MOVE ORDER HDR'); */

   /*  Standard call to check for call compatibility. */

   IF NOT FND_API.Compatible_API_CALL ( l_api_version_number
							   , p_api_version_number
                                      , l_api_name
							   , G_PKG_NAME
							   )
     THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

/* Initialize message list if p_int_msg_lst is set TRUE. */
																   IF FND_API.to_boolean(p_init_msg_lst)
     THEN
     FND_MSG_PUB.Initialize;
   END IF;
/*  Initialize API return status to sucess */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  WSH_Util_Core.PrintLn('Move_Order_Header PVT => '||p_mo_hdr_rec.operation);


  IF check_required( p_mo_hdr_rec => l_mo_hdr_rec) THEN
	FND_MESSAGE.SET_NAME('GMI','Required Values Missing');
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  WSH_Util_Core.PrintLn('Move_Order_Header PVT => '||p_mo_hdr_rec.operation);

  IF l_mo_hdr_rec.operation = INV_GLOBALS.G_OPR_DELETE THEN
	/*  physically delete this row */
	/*   */
  WSH_Util_Core.PrintLn('Calling Delete Row');
     GMI_Move_Order_Header_Util.delete_Row( l_mo_hdr_rec.header_id);

  ELSE

  WSH_Util_Core.PrintLn('Calling Insert / Update Row');

	/*  Set Generic defaults */
     l_mo_hdr_rec.last_update_date   := SYSDATE;
     l_mo_hdr_rec.last_updated_by    := FND_GLOBAL.USER_ID;
     l_mo_hdr_rec.last_update_login  := FND_GLOBAL.USER_ID;

     IF l_mo_hdr_rec.operation = INV_GLOBALS.G_OPR_UPDATE THEN
  WSH_Util_Core.PrintLn('Calling Update Row');
    gmi_reservation_util.PrintLn('Calling Update Row in move_order hdr pvt');
        GMI_Move_Order_Header_Util.update_Row( l_mo_hdr_rec);

	ELSE /*  IF l_mo_hdr_rec.operation = INV_GLOBALS.G_OPR_CREATE THEN */
	   /*  Set create defaults */


        l_mo_hdr_rec.creation_date   := SYSDATE;
        l_mo_hdr_rec.created_by      := FND_GLOBAL.USER_ID;

	   /*  Get New Header Id Via Sequence */
           -- BEGIN Bug 2628244 - Use of sequence MTL_TXN_REQUEST_HEADERS_S
           -- instead of gmi_mo_header_id_s
           -- select gmi_mo_header_id_s.nextval
           select MTL_TXN_REQUEST_HEADERS_S.nextval
           -- END Bug 2628244
	   INTO   l_mo_hdr_rec.header_id
	   FROM   DUAL;


  WSH_Util_Core.PrintLn('Seq Header id => '||l_mo_hdr_rec.header_id);
  WSH_Util_Core.PrintLn('Calling Insert Row');
  WSH_Util_Core.PrintLn('Batch Number => ' || l_mo_hdr_rec.request_number);
gmi_reservation_util.println('Going to insert row in move_order_hdr_pvt');
gmi_reservation_util.println('value of l_mo_hdr_rec.organization_id: '||l_mo_hdr_rec.organization_id);
gmi_reservation_util.println('Value of l_mo_hdr_rec.operation is '||l_mo_hdr_rec.request_number);
        GMI_Move_Order_Header_Util.Insert_Row( l_mo_hdr_rec);

     END IF;
  END IF;

  WSH_Util_Core.PrintLn('Ham Out Of Here No Action');
  gmi_reservation_util.PrintLn('Ham Out Of Here No Action');

     x_mo_hdr_rec := l_mo_hdr_rec;
  WSH_Util_Core.PrintLn('Seq Header id => '||x_mo_hdr_rec.header_id);

/*    FND_MESSAGE.Set_Name('GMI','Entering_GMI_Create_Move_Order_Header'); */
/*    FND_MSG_PUB.Add; */
   /* RAISE FND_API.G_EXC_ERROR; */

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;

	 FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
					      , l_api_name
	      				);


      /*   Get message count and data */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );



END Process_Move_Order_Header;

FUNCTION check_required
 (
  p_mo_hdr_rec        IN  GMI_MOVE_ORDER_GLOBAL.mo_hdr_rec
 )
 RETURN BOOLEAN
 IS
BEGIN

 IF ( p_mo_hdr_rec.operation = INV_GLOBALS.G_OPR_CREATE)  THEN

    IF  p_mo_hdr_rec.REQUEST_NUMBER    is NULL OR
        p_mo_hdr_rec.organization_id   is NULL THEN

	   RETURN TRUE;

	ELSE
	   RETURN FALSE;

     END IF;


 ELSIF ( p_mo_hdr_rec.operation = INV_GLOBALS.G_OPR_UPDATE)  THEN

    IF  p_mo_hdr_rec.header_id          is NULL OR
        p_mo_hdr_rec.REQUEST_NUMBER     is NULL OR
        p_mo_hdr_rec.organization_id    is NULL THEN

	   RETURN TRUE;

	ELSE
	   RETURN FALSE;

     END IF;

  /*  This should Catch DELETE, LOCK_ROW and QUERY */
  /*  Which all need a HEADER ID. */
  ELSE

    IF  p_mo_hdr_rec.header_id        is NULL THEN
	   RETURN TRUE;
    ELSE
	   RETURN FALSE;
    END IF;

 END IF;

 RETURN TRUE;


 EXCEPTION
																 WHEN OTHERS THEN
	 FND_MESSAGE.SET_NAME('GMI','UNEXPECTED ERROR CHECK MISSING');
      RETURN TRUE;

END CHECK_REQUIRED;


END GMI_Move_Order_HEADER_PVT;

/
