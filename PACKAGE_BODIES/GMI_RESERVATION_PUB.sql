--------------------------------------------------------
--  DDL for Package Body GMI_RESERVATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RESERVATION_PUB" AS
/*  $Header: GMIPRSVB.pls 120.0 2005/05/25 16:00:01 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPRSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to OPM             |
 |     reservation.                                                        |
 |                                                                         |
 | - Query_Reservation                                                     |
 | - Create_Reservation                                                    |
 | - Update_Reservation                                                    |
 | - Delete_Reservation                                                    |
 | - Transfer_Reservation                                                  |
 |                                                                         |
 | HISTORY                                                                 |
 |     21-FEB-2000  odaboval        Created                                |
 |   	                                                                   |
 | B1479751 odaboval 15-Nov-2000 : Removed all variable x_msg_data from    |
 |   	     any GMI_Reservation_Util.PrintLn.                             |
 |   	     And removed all FND_MSG_PUB.Get calls (at public level)       |
 | 03-OCT-2001  odaboval, local fix for bug 2025611                        |
 |                        Call procedure Check_Shipping_Details            |
 |  As a local fix, this is now removed.                                   |
 |   	                                                                   |
 |   	                                                                   |
 |   	                                                                   |
 |   	                                                                   |
 |   	                                                                   |
 +=========================================================================+
  API Name  : GMI_Reservation_PUB
  Type      : Global - Package Body
  Function  : This package contains Global procedures used to
              OPM reservation process.
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

/*  Global variables   */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='GMI_Reservation_PUB';


/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Query_Reservation                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Query reservations included in table IC_TRAN_PND.                      |
 |   If found, fetch data into a table of rec_type.                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Query reservations included in table IC_TRAN_PND.                      |
 |   If found, fetch data into a table of rec_type.                         |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version_number        IN  NUMBER       - API version            |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT NOCOPY VARCHAR2     - Return Status   |
 |    x_msg_count                 OUT NOCOPY NUMBER       -                 |
 |    x_msg_data                  OUT NOCOPY VARCHAR2     -                 |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_query_input               IN  rec_type     -                        |
 |    p_lock_records              IN  VARCHAR2     -                        |
 |    x_mtl_reservation_tbl       OUT NOCOPY rec_type     -                 |
 |    x_mtl_reservation_tbl_count OUT NOCOPY NUMBER       -                 |
 |    x_error_code                OUT NOCOPY NUMBER       -                 |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Query_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date              IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode             IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Query_Reservation';

BEGIN

/*  Initialize API return status to success   */
x_return_status := FND_API.G_RET_STS_SUCCESS;

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc GMI_Reservation_PUB.query_reservation ');

GMI_Reservation_Util.PrintLn('(opm_dbg) in QueryPub org_id='||p_query_input.organization_id);
GMI_Reservation_Util.PrintLn('(opm_dbg) in QueryPub header='||p_query_input.demand_source_header_id);
GMI_Reservation_Util.PrintLn('(opm_dbg) in QueryPub line_id='||p_query_input.demand_source_line_id);
/* =====================================================================
  Check the validation flag :
  If validation flag is G_TRUE, then check
                          ( used if another process calls the procedure)
  If validation flag is NONE, then no check.
                          ( used if the call comes from another GMI_reservation)
 =======================================================================  */

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB q : before Check_Missing : flag='||p_validation_flag||', G_TRUE='||FND_API.G_TRUE);
IF (p_validation_flag = FND_API.G_TRUE)
THEN
   /* ==========================================================================
     Call Data Validation
     =========================================================================*/
   GMI_Reservation_Util.Check_Missing(
        p_event                     => 'QUERY'
      , p_rec_to_check              => p_query_input
      , x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      );

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB q : after Check_Missing : return='||x_return_status||', Succes='||FND_API.G_RET_STS_SUCCESS);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Check_Missing');
      FND_MESSAGE.Set_Token('WHERE', 'Query_Reservation');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

END IF;

/* ==========================================================================
  Call The private query_reservation
============================================================================= */
GMI_Reservation_Util.PrintLn('(opm_dbg) in GMI_Reservation_PUB.query_reservation before calling PVT');

GMI_Reservation_PVT.Query_Reservation(
        x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_validation_flag           => p_validation_flag
      , p_query_input	            => p_query_input
      , p_lock_records	            => p_lock_records
      , x_mtl_reservation_tbl	    => x_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count => x_mtl_reservation_tbl_count
      , x_error_code                => x_error_code
   );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_PVT.Query_Reservation');
   FND_MESSAGE.Set_Token('WHERE', 'Query_Reservation');
   FND_MSG_PUB.Add;
   GMI_Reservation_Util.PrintLn('(opm_dbg) in end of PUB q ERROR:Returned by PVT q.');
   RAISE FND_API.G_EXC_ERROR;
END IF;



/* ============================================================================
  Set the return values
   =========================================================================  */
GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.query_reservation NO Error');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data   */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

/*       IF (x_msg_count > 1)
       THEN
         FND_MSG_PUB.Get(
          p_data           => x_msg_data
        , p_msg_index_out  => x_msg_count
        );
       END IF;
*/
      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.Query_Reservation Exp_Error count='||x_msg_count);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data   */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

/*       IF (x_msg_count > 1)
       THEN
         FND_MSG_PUB.Get(
          p_data           => x_msg_data
        , p_msg_index_out  => x_msg_count
        );
       END IF;
*/
      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_Pub.Query_Reservation OTHERS count='||x_msg_count);

END Query_Reservation;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Reservation                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Create reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Create reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version_number        IN  NUMBER       - API version            |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT NOCOPY VARCHAR2     - Return Status   |
 |    x_msg_count                 OUT NOCOPY NUMBER       -                 |
 |    x_msg_data                  OUT NOCOPY VARCHAR2     -                 |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_rsv_rec                   IN  rec_type     -                        |
 |    p_serial_number             IN  rec_type     -                        |
 |    x_serial_number             OUT NOCOPY rec_type     -                 |
 |    x_quantity_reserved         OUT NOCOPY rec_type     -                 |
 |    x_reservation_id            OUT NOCOPY NUMBER       -                 |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Create_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_rsv_rec                       IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number                 IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number                 OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag      IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_quantity_reserved             OUT NOCOPY NUMBER
   , x_reservation_id                OUT NOCOPY NUMBER
  ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Reservation';

BEGIN

/*  Initialize API return status to success   */
x_return_status := FND_API.G_RET_STS_SUCCESS;
SAVEPOINT GMI_Create_Reservation_PUB;

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc GMI_Reservation_PUB.create_reservation ');

/*======================================================================
  Check the validation flag :
  If validation flag is <>0, then check
                        ( used if another process calls the procedure)
  If validation flag is 0, then no check.
                        ( used if the call comes from another OPM_reservation)
========================================================================= */

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB q : before Check_Missing : flag='||p_validation_flag||', G_TRUE='||FND_API.G_TRUE);
IF (p_validation_flag = FND_API.G_TRUE)
THEN
   /*========================================================================
     Call Data Validation
   ========================================================================*/
   GMI_Reservation_Util.Check_Missing(
        p_event                     => 'CREATE'
      , p_rec_to_check              => p_rsv_rec
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Check_Missing');
      FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
      FND_MSG_PUB.Add;
      GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB c : after Check_Missing : Error='||x_return_status);
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END IF;


/* =====================================================================
  Call The private create_reservation
======================================================================= */
GMI_Reservation_Util.PrintLn('(opm_dbg) in GMI_Reservation_PUB.create_reservation before calling PVT');

GMI_Reservation_PVT.Create_Reservation(
        x_return_status		       => x_return_status
      , x_msg_count		       => x_msg_count
      , x_msg_data		       => x_msg_data
      , p_validation_flag              => p_validation_flag
      , p_rsv_rec                      => p_rsv_rec
      , p_serial_number                => p_serial_number
      , x_serial_number                => x_serial_number
      , p_partial_reservation_flag     =>  p_partial_reservation_flag
      , p_force_reservation_flag       =>  p_force_reservation_flag
      , x_quantity_reserved            => x_quantity_reserved
      , x_reservation_id               => x_reservation_id
   );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_PVT.Create_Reservation');
   FND_MESSAGE.Set_Token('WHERE', 'Create_Reservation');
   FND_MSG_PUB.Add;
   GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB c : after create(PVT) : Error='||x_return_status);
   RAISE FND_API.G_EXC_ERROR;
END IF;

/* ========================================================================
  Set the return values
========================================================================= */
GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.create_reservation : NO Error');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      GMI_Reservation_Util.PrintLn('in end of GMI_Reservation_PUB.create_reservation : Error');
      ROLLBACK TO SAVEPOINT GMI_Create_Reservation_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_Pub.Create_Reservation Exp_Error count='||x_msg_count);


   WHEN OTHERS THEN
      GMI_Reservation_Util.PrintLn('in end of GMI_Reservation_PUB.create_reservation : ErrorOther');
      ROLLBACK TO SAVEPOINT GMI_Create_Reservation_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data   */
      FND_MSG_PUB.count_and_get
       (  p_count => x_msg_count
        , p_data  => x_msg_data
       );

      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_Pub.Create_Reservation OTHERS count='||x_msg_count);

END Create_Reservation;

/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Update_Reservation                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Update reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Update reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version_number        IN  NUMBER       - API version            |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT NOCOPY VARCHAR2     - Return Status   |
 |    x_msg_count                 OUT NOCOPY NUMBER       -                 |
 |    x_msg_data                  OUT NOCOPY VARCHAR2     -                 |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_original_rsv_rec          IN  rec_type     -                        |
 |    p_to_rsv_rec                IN  rec_type     -                        |
 |    p_serial_number             IN  rec_type     -                        |
 |    x_serial_number             OUT NOCOPY rec_type     -                 |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Update_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Reservation';

BEGIN

/*  Initialize API return status to success   */
x_return_status := FND_API.G_RET_STS_SUCCESS;
SAVEPOINT GMI_Update_Reservation_PUB;

/* ==============================================================
  Check the validation flag :
  If validation flag is G_TRUE, then check
                          ( used if another process calls the procedure)
  If validation flag is NONE, then no check.
                          ( used if the call comes from another GMI_reservation)
================================================================ */

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB q : before Check_Missing : flag='||p_validation_flag||', G_TRUE='||FND_API.G_TRUE);
IF (p_validation_flag = FND_API.G_TRUE)
THEN
   /* =================================================================
     Call Data Validation
   ==================================================================== */
   GMI_Reservation_Util.Check_Missing(
        p_event                     => 'UPDATE'
      , p_rec_to_check              => p_to_rsv_rec
      , x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Check_Missing');
      FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

END IF;

/* =====================================================================
  Call The private update_reservation_reservation
====================================================================== */
GMI_Reservation_Util.PrintLn('(opm_dbg) in GMI_Reservation_PUB.update_reservation before calling PVT');

GMI_Reservation_PVT.Update_Reservation(
        x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_validation_flag           => p_validation_flag
      , p_original_rsv_rec          => p_original_rsv_rec
      , p_to_rsv_rec 	            => p_to_rsv_rec
      , p_original_serial_number    => p_original_serial_number
      , p_to_serial_number          => p_to_serial_number
   );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_PVT.Update_Reservation');
   FND_MESSAGE.Set_Token('WHERE', 'Update_Reservation');
   FND_MSG_PUB.Add;
   GMI_Reservation_Util.PrintLn('(opm_dbg) in end of PUB u: ERROR:Returned by PVT u.');
   RAISE FND_API.G_EXC_ERROR;
END IF;



/* =============================================================================
  Set the return values
============================================================================= */
GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.update_reservation NO Error');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT GMI_Update_Reservation_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

     GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.update_reservation Exp_Error count='||x_msg_count);


   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT GMI_Update_Reservation_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*    Get message count and data   */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

     GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.update_reservation OTHERS count='||x_msg_count);



END Update_Reservation;



/*  Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Delete_Reservation                                                    |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Delete reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Delete reservation by calling OPM_Allocation manager.                  |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version_number        IN  NUMBER       - API version            |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT NOCOPY VARCHAR2     - Return Status   |
 |    x_msg_count                 OUT NOCOPY NUMBER       -                 |
 |    x_msg_data                  OUT NOCOPY VARCHAR2     -                 |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    p_rsv_rec                   IN  rec_type     -                        |
 |    p_serial_number             IN  rec_type     -                        |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Delete_Reservation
  (
     p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_validation_flag          IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_rsv_rec                  IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number            IN  inv_reservation_global.serial_number_tbl_type
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Reservation';

-- odaboval, Oct-2001, standalone fix for Tropicana.
CURSOR c_get_wsh_released_status( l_so_line_id IN NUMBER) IS
SELECT released_status
FROM wsh_delivery_details
WHERE released_status IN ('Y', 'C')
AND source_line_id = l_so_line_id;

BEGIN

/*  Initialize API return status to success   */
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* =========================================================================
  Check the validation flag :
  If validation flag is G_TRUE, then check
                          ( used if another process calls the procedure)
  If validation flag is NONE, then no check.
                       ( used if the call comes from another GMI_reservation)
============================================================================ */

GMI_Reservation_Util.PrintLn('(opm_dbg) in proc PUB q : before Check_Missing : flag='||p_validation_flag||', G_TRUE='||FND_API.G_TRUE);
IF (p_validation_flag = FND_API.G_TRUE)
THEN
/* =======================================================================
    Call Data Validation
  ====================================================================== */
   GMI_Reservation_Util.Check_Missing(
        p_event                     => 'DELETE'
      , p_rec_to_check              => p_rsv_rec
      , x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
      FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_Util.Check_Missing');
      FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

END IF;

-- Bug 2025611, odaboval, Oct-2001, added a check for not calling
--     delete_reservation when the released_status of the shipping details
--     is Y or C :
/* This local fix is now removed (odaboval, for Tropicana only)
GMI_Reservation_PVT.Check_Shipping_Details(
        p_rsv_rec    	            => p_rsv_rec
      , x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data);

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FND_MESSAGE.Set_Name('GMI','GMI_NOT_ALLOWED_TO_DELETE_RSV');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_PVT.Check_Shipping_Details');
   FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
   FND_MSG_PUB.Add;
   GMI_Reservation_Util.PrintLn('(opm_dbg) in end of PUB d: WARNING: Cannot call Delete_Reservation because of shipping status.');
   RAISE FND_API.G_EXC_ERROR;
END IF;
(odaboval) */

/* ==========================================================================
  Call The private delete_reservation_reservation
   ======================================================================= */
GMI_Reservation_Util.PrintLn('(opm_dbg) in GMI_Reservation_PUB.delete_reservation before calling PVT');

GMI_Reservation_PVT.Delete_Reservation(
        x_return_status	            => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_validation_flag           => p_validation_flag
      , p_rsv_rec    	            => p_rsv_rec
      , p_serial_number             => p_serial_number
   );

IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FND_MESSAGE.Set_Name('GMI','GMI_ERROR');
   FND_MESSAGE.Set_Token('BY_PROC', 'GMI_Reservation_PVT.Delete_Reservation');
   FND_MESSAGE.Set_Token('WHERE', 'Delete_Reservation');
   FND_MSG_PUB.Add;
   GMI_Reservation_Util.PrintLn('(opm_dbg) in end of PUB d: ERROR:Returned by PVT d.');
   RAISE FND_API.G_EXC_ERROR;
END IF;



/* ===========================================================================
  Set the return values
=========================================================================== */
GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.delete_reservation NO Error');



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data   */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.delete_reservation Exp_Error count='||x_msg_count);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*    Get message count and data */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.delete_reservation OTHERS count='||x_msg_count);


END Delete_Reservation;

/*   Api start of comments
 +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Transfer_Reservation                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Global                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   Transfer reservation - Not Used, just a message                        |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   Transfer reservation - Not Used, just a message                        |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version_number        IN  NUMBER       - API version            |
 |    p_init_msg_lst              IN  VARCHAR2     - Msg init               |
 |    x_return_status             OUT NOCOPY VARCHAR2     - Return Status   |
 |    x_msg_count                 OUT NOCOPY NUMBER       -                 |
 |    x_msg_data                  OUT NOCOPY VARCHAR2     -                 |
 |    p_is_transfer_supply        IN  VARCHAR2     -                        |
 |    p_original_rsv_rec          IN  rec_type     -                        |
 |    p_to_rsv_rec                IN  rec_type     -                        |
 |    p_original_serial_number    IN  rec_type     -                        |
 |    p_to_serial_number          IN  rec_type     -                        |
 |    p_validation_flag           IN  VARCHAR2     -                        |
 |    x_to_reservation_id         OUT NOCOPY NUMBER       -                 |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     21-FEB-2000  odaboval        Created                                 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
PROCEDURE Transfer_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_is_transfer_supply            IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , x_to_reservation_id             OUT NOCOPY NUMBER
   ) IS

l_api_name           CONSTANT VARCHAR2 (30) := 'Transfer_Reservation';

BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_RSV_UNAVAILABLE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*   Get message count and data  */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.transfer_reservation Exp_Error count='||x_msg_count);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      /*   Get message count and data  */
      FND_MSG_Pub.Count_and_Get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );

      GMI_Reservation_Util.PrintLn('(opm_dbg) in end of GMI_Reservation_PUB.transfer_reservation OTHERS count='||x_msg_count);

END Transfer_Reservation;

END GMI_Reservation_PUB;

/
