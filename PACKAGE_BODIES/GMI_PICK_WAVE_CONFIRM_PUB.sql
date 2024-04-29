--------------------------------------------------------
--  DDL for Package Body GMI_PICK_WAVE_CONFIRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PICK_WAVE_CONFIRM_PUB" AS
/*  $Header: GMIPPWCB.pls 115.15 2003/04/22 13:14:30 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPPWCB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick Wave Confirmation.                                            |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  hverddin        Created                                |
 |     02-AUG-2000  jdiiorio        Commented out dbms_output.             |
 |     14-Sep-2000  odaboval        Removed dummy calls.                   |
 |                                                                         |
 |     HW BUG#:2296620 Added a new parameter to PICK_CONFIRM called        |
 |                     p_manual_pick for ship sets functionality           |
 |                                                                         |
 |                                                                         |
 +=========================================================================+
  API Name  : GMI_PICK_WAVE_CONFIRM_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/
/* Global variables  */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_PICK_WAVE_CONFIRM_PUB';
-- HW OPM changes for NOCOPY
-- Added NOCOPY to x_mo_line_tbl
PROCEDURE PICK_CONFIRM
  (
     p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag       IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_LINE_tbl           IN  GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_mo_LINE_tbl           OUT  NOCOPY GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_return_status         OUT  NOCOPY VARCHAR2
   , x_msg_count             OUT  NOCOPY NUMBER
   , x_msg_data              OUT  NOCOPY VARCHAR2
   , p_manual_pick           IN VARCHAR2 DEFAULT NULL
  )
 IS
 l_api_name           CONSTANT VARCHAR2 (30) := 'PICK_CONFIRM';
 l_api_version_number CONSTANT NUMBER        := 1.0;

 l_msg_count          NUMBER  :=0;
 l_msg_data           VARCHAR2(2000);
 l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_mo_line_rec       GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
 l_mo_line_tbl       GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;
-- HW OPM changes for NOCOPY
 ll_mo_line_tbl       GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;

-- HW BUG#:2296620
l_manual_pick VARCHAR2(1);
l_warning EXCEPTION;


 BEGIN
   GMI_Reservation_Util.PrintLn('IN MOVE ORDER line');
/* ************ DO I NEED SAVE POINT FOR PUBLIC DECLARATION *******   */
/*  Standard call to check for call compatibility.   */

   IF NOT FND_API.Compatible_API_CALL ( l_api_version_number
        				 , p_api_version_number
                                         , l_api_name
				         , G_PKG_NAME
				       )
     THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  GMI_Reservation_Util.PrintLn('After Check Version');
/* Initialize message list if p_int_msg_lst is set TRUE.   */
   IF FND_API.to_boolean(p_init_msg_lst)
     THEN
     FND_MSG_PUB.Initialize;
   END IF;

  GMI_Reservation_Util.PrintLn('After Init Messages');

/*  Initialize API return status to sucess    */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*  Check That we have at least one Move Order Line Rec   */
  GMI_Reservation_Util.PrintLn('mo_line_tbl.COUNT='||p_mo_line_tbl.count);

  IF ( p_mo_line_tbl.count = 0 )  THEN
     FND_MESSAGE.SET_NAME('INV', 'INV_NO_LINES_TO_PICK_CONFIRM');
     FND_MSG_PUB.add;
	raise FND_API.G_EXC_ERROR;
  END IF;

/*  Convert Missing To NULL;   */
  GMI_Reservation_Util.PrintLn('Call Convert Missing To Null');

  FOR I in 1..p_mo_line_tbl.COUNT LOOP

    l_mo_line_rec := p_mo_line_tbl(I);

    GMI_Reservation_Util.PrintLn('_Move_Order_line => '||l_mo_line_rec.operation);
-- HW BUG#:2643440 No need to call Convert_Miss_To_Null since the
-- records is set to NULL already
    l_mo_line_rec := GMI_MOVE_ORDER_line_UTIL.Convert_Miss_To_Null
	     		 ( p_mo_line_rec => l_mo_line_rec);


    l_mo_line_tbl(I) := l_mo_line_rec;

-- HW BUG#:2296620
   l_manual_pick := p_manual_pick;
  END LOOP;

  GMI_Reservation_Util.PrintLn('CAlling Move order Lines PVT');
  GMI_RESERVATION_UTIL.println('Value of p_manual_pick is '|| l_manual_pick);
 -- HW BUG#:2296620 add p_manual_pick parameter
 -- HW OPM changes for NOCOPY
 -- Use ll_mo_line_tbl for x_mo_LINE_tbl
  GMI_PICK_WAVE_CONFIRM_PVT.PICK_CONFIRM
  (
     p_api_version_number  => l_api_version_number
   , p_init_msg_lst        => p_init_msg_lst
   , p_validation_flag     => p_validation_flag
   , p_commit              => p_commit
   , p_mo_LINE_tbl         => l_mo_line_tbl
   , x_mo_LINE_tbl         => ll_mo_line_tbl
   , x_return_status       => l_return_status
   , x_msg_count           => l_msg_count
   , x_msg_data            => l_msg_data
   , p_manual_pick         => l_manual_pick
  );

/*  Return Output Variables   */
 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS AND
     l_return_status <> 'X')  THEN
   IF ( l_return_status = 'W' )THEN  -- HW BUG#:2296620
    RAISE l_warning;
   ElSE
     FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
     FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_PICK_WAVE_CONFIRM_PVT.PICK_CONFIRM');
     FND_MESSAGE.SET_TOKEN('WHERE',G_PKG_NAME||'.'||l_api_name);

     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;

-- HW OPM changes for NOCOPY
-- Use ll_mo_line_tbl for x_mo_LINE_tbl

  x_mo_line_tbl := ll_mo_line_tbl;
  GMI_Reservation_Util.PrintLn('Count MOL table => ' || x_mo_line_tbl.count);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

/*   Get message count and data   */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
-- HW BUG#:2296620 added a new exception
   WHEN l_warning THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );


/*   Get message count and data    */
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );


END PICK_CONFIRM;

END GMI_PICK_WAVE_CONFIRM_PUB;

/
