--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_VRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_VRS_PUB" AS
/*  $Header: GMDPSVRB.pls 120.0 2005/05/25 19:03:59 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | File Name          : GMDPSVRB.pls                                       |
 | Package Name       : GMD_SPEC_VRS_PUB                                   |
 | Type               : PUBLIC                                             |
 |                                                                         |
 | Contents:                                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions for processing             |
 |     SPEC Validity Rules                                                 |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-May-2005  Convergence Changes                                                                    |
 +=========================================================================+
  API Name  : GMD_SPEC_VRS_PUB
  Type      : Public
  Function  : This package contains public procedures used to process
              spec validity rules.
  Pre-reqs  : N/A
  Parameters: Per function


  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
  END of Notes */


/*  Global variables   */

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GMD_SPEC_VRS_PUB';

/*
 +=========================================================================+
 | Name               : CREATE_INVENTORY_SPEC_VRS                          |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of inventory_spec_vrs definitions.  Validates       |
 |     each table entry and where valid, inserts a corresponding row       |
 |     into gmd_inventory_spec_vrs                                         |
 |     In the case of any failure a rollback is instigated.
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE CREATE_INVENTORY_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2
, p_commit                 IN  VARCHAR2
, p_validation_level       IN  VARCHAR2
, p_inventory_spec_vrs_tbl IN  GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_inventory_spec_vrs_tbl OUT NOCOPY GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'CREATE_INVENTORY_SPEC_VRS';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_msg_count              NUMBER  :=0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                   GMD_SPECIFICATIONS%ROWTYPE;
  l_inventory_spec_vrs     GMD_INVENTORY_SPEC_VRS%ROWTYPE;
  l_inventory_spec_vrs_out GMD_INVENTORY_SPEC_VRS%ROWTYPE;
  l_inventory_spec_vrs_tbl GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl;
  l_rowid                  ROWID;
  l_user_id                NUMBER(15);

BEGIN

  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Create_Inventory_Spec_VRS;

  --  Standard call to check for call compatibility
  --  =============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter
  -- ============================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Loop through the inventory spec validity rules validating and creating
  -- ======================================================================
  FOR i in 1..p_inventory_spec_vrs_tbl.COUNT LOOP

    l_inventory_spec_vrs := p_inventory_spec_vrs_tbl(i);

    -- Set Who columns ahead of Validation
    -- ===================================
    l_inventory_spec_vrs.created_by      := l_user_id;
    l_inventory_spec_vrs.last_updated_by := l_user_id;
    l_inventory_spec_vrs.creation_date   := sysdate;
    l_inventory_spec_vrs.last_update_date:= sysdate;

    -- Set spec_vr_id to NULL and delete_mark to zero
    -- ==============================================
    l_inventory_spec_vrs.spec_vr_id := NULL;
    l_inventory_spec_vrs.delete_mark := 0;

    -- Set spec_vr_status to NEW
    -- =========================
    l_inventory_spec_vrs.spec_vr_status  := 100;

    -- Validate Inventory Spec Validity Rule
    -- =====================================
    -- BUG 2691994 - signature change for validation routine
    GMD_SPEC_VRS_GRP.Validate_INV_VR(
                      p_inv_vr            => l_inventory_spec_vrs,
                      p_called_from       => 'API',
                      p_operation         => 'INSERT',
                      x_inv_vr            => l_inventory_spec_vrs_out,
                      x_return_status     => l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_inventory_spec_vrs := l_inventory_spec_vrs_out;

    IF NOT GMD_INVENTORY_SPEC_VRS_PVT.Insert_Row(l_inventory_spec_vrs, l_inventory_spec_vrs_out)
    THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Return Parameter Tbl
    -- ===========================
    l_inventory_spec_vrs_tbl(i) := l_inventory_spec_vrs_out;

 END LOOP;

  -- Standard Check of p_commit.
  -- ==========================
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;
  x_inventory_spec_vrs_tbl     := l_inventory_spec_vrs_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Inventory_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Inventory_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                 );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_Inventory_Spec_VRS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_INVENTORY_SPEC_VRS;

/*
 +=========================================================================+
 | Name               : CREATE_WIP_SPEC_VRS                                |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of wip_spec_vrs definitions.  Validates             |
 |     each table entry and where valid, inserts a corresponding row       |
 |     into gmd_wip_spec_vrs                                               |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE CREATE_WIP_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2
, p_commit                 IN  VARCHAR2
, p_validation_level       IN  VARCHAR2
, p_wip_spec_vrs_tbl       IN  GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_wip_spec_vrs_tbl       OUT NOCOPY GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'CREATE_WIP_SPEC_VRS';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_msg_count              NUMBER  :=0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                   GMD_SPECIFICATIONS%ROWTYPE;
  l_wip_spec_vrs           GMD_WIP_SPEC_VRS%ROWTYPE;
  l_wip_spec_vrs_out       GMD_WIP_SPEC_VRS%ROWTYPE;
  l_wip_spec_vrs_tbl       GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl;
  l_rowid                  ROWID;
  l_user_id                NUMBER(15);

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Create_WIP_Spec_VRS;

  --  Standard call to check for call compatibility
  --  =============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter
  -- ============================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Loop through the WIP spec validity rules validating and creating
  -- ================================================================
  FOR i in 1..p_wip_spec_vrs_tbl.COUNT LOOP

    l_wip_spec_vrs := p_wip_spec_vrs_tbl(i);

    -- Set Who columns ahead of Validation
    -- ===================================
    l_wip_spec_vrs.created_by      := l_user_id;
    l_wip_spec_vrs.last_updated_by := l_user_id;
    l_wip_spec_vrs.creation_date   := sysdate;
    l_wip_spec_vrs.last_update_date:= sysdate;

    -- Set spec_vr_id to NULL and delete_mark to zero
    -- ==============================================
    l_wip_spec_vrs.spec_vr_id := NULL;
    l_wip_spec_vrs.delete_mark := 0;

    -- Set spec_vr_status to NEW
    -- =========================
    l_wip_spec_vrs.spec_vr_status  := 100;

    -- Validate WIP Spec Validity Rule
    -- ===============================
    -- BUG 2691994 - signature change for validation routine
    GMD_SPEC_VRS_GRP.Validate_WIP_VR(
                      p_wip_vr            => l_wip_spec_vrs,
                      p_called_from       => 'API',
                      p_operation         => 'INSERT',
                      x_wip_vr            => l_wip_spec_vrs_out,
                      x_return_status     => l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_wip_spec_vrs := l_wip_spec_vrs_out;

    IF NOT GMD_WIP_SPEC_VRS_PVT.Insert_Row(l_wip_spec_vrs, l_wip_spec_vrs_out)
    THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Return Parameter Tbl
    -- ===========================
    l_wip_spec_vrs_tbl(i) := l_wip_spec_vrs_out;

 END LOOP;

  -- Standard Check of p_commit.
  -- ==========================
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;
  x_wip_spec_vrs_tbl   := l_wip_spec_vrs_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_WIP_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_WIP_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                 );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_WIP_Spec_VRS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_WIP_SPEC_VRS;

/*
 +=========================================================================+
 | Name               : CREATE_CUSTOMER_SPEC_VRS                           |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of customer_spec_vrs definitions.  Validates        |
 |     each table entry and where valid, inserts a corresponding row       |
 |     into gmd_customer_spec_vrs                                          |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE CREATE_CUSTOMER_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2
, p_commit                 IN  VARCHAR2
, p_validation_level       IN  VARCHAR2
, p_customer_spec_vrs_tbl  IN  GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_customer_spec_vrs_tbl  OUT NOCOPY GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'CREATE_CUSTOMER_SPEC_VRS';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_msg_count              NUMBER  :=0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_customer_spec_vrs      GMD_CUSTOMER_SPEC_VRS%ROWTYPE;
  l_customer_spec_vrs_out  GMD_CUSTOMER_SPEC_VRS%ROWTYPE;
  l_customer_spec_vrs_tbl  GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl;
  l_user_id                NUMBER(15);

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Create_Customer_Spec_VRS;

  --  Standard call to check for call compatibility
  --  =============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter
  -- ============================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Loop through the Customer spec validity rules validating and creating
  -- =====================================================================
  FOR i in 1..p_customer_spec_vrs_tbl.COUNT LOOP

    l_customer_spec_vrs := p_customer_spec_vrs_tbl(i);

    -- Set Who columns ahead of Validation
    -- ===================================
    l_customer_spec_vrs.created_by      := l_user_id;
    l_customer_spec_vrs.last_updated_by := l_user_id;
    l_customer_spec_vrs.creation_date   := sysdate;
    l_customer_spec_vrs.last_update_date:= sysdate;

    -- Set spec_vr_id to NULL and delete_mark to zero
    -- ==============================================
    l_customer_spec_vrs.spec_vr_id := NULL;
    l_customer_spec_vrs.delete_mark := 0;

    -- Set spec_vr_status to NEW
    -- =========================
    l_customer_spec_vrs.spec_vr_status  := 100;

    -- Validate Customer Spec Validity Rule
    -- ====================================
    GMD_SPEC_VRS_GRP.Validate_Cust_VR(
                      p_cust_vr           => l_customer_spec_vrs,
                      p_called_from       => 'API',
                      p_operation         => 'INSERT',
                      x_return_status     => l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_CUSTOMER_SPEC_VRS_PVT.Insert_Row(l_customer_spec_vrs, l_customer_spec_vrs_out)
    THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Return Parameter Tbl
    -- ===========================
    l_customer_spec_vrs_tbl(i) := l_customer_spec_vrs_out;

 END LOOP;

  -- Standard Check of p_commit.
  -- ==========================
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status           := l_return_status;
  x_customer_spec_vrs_tbl   := l_customer_spec_vrs_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Customer_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Customer_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                 );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_Customer_Spec_VRS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_CUSTOMER_SPEC_VRS;

/*
 +=========================================================================+
 | Name               : CREATE_SUPPLIER_SPEC_VRS                           |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of supplier_spec_vrs definitions.  Validates        |
 |     each table entry and where valid, inserts a corresponding row       |
 |     into gmd_supplier_spec_vrs                                          |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE CREATE_SUPPLIER_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2
, p_commit                 IN  VARCHAR2
, p_validation_level       IN  VARCHAR2
, p_supplier_spec_vrs_tbl  IN  GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_supplier_spec_vrs_tbl  OUT NOCOPY GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'CREATE_SUPPLIER_SPEC_VRS';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_msg_count              NUMBER  :=0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_supplier_spec_vrs      GMD_SUPPLIER_SPEC_VRS%ROWTYPE;
  l_supplier_spec_vrs_out  GMD_SUPPLIER_SPEC_VRS%ROWTYPE;
  l_supplier_spec_vrs_tbl  GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl;
  l_user_id                NUMBER(15);

BEGIN

  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Create_Supplier_Spec_VRS;

  --  Standard call to check for call compatibility
  --  =============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter
  -- ============================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Loop through the Supplier spec validity rules validating and creating
  -- =====================================================================
  FOR i in 1..p_supplier_spec_vrs_tbl.COUNT LOOP

    l_supplier_spec_vrs := p_supplier_spec_vrs_tbl(i);

    -- Set Who columns ahead of Validation
    -- ===================================
    l_supplier_spec_vrs.created_by      := l_user_id;
    l_supplier_spec_vrs.last_updated_by := l_user_id;
    l_supplier_spec_vrs.creation_date   := sysdate;
    l_supplier_spec_vrs.last_update_date:= sysdate;

    -- Set spec_vr_id to NULL and delete_mark to zero
    -- ==============================================
    l_supplier_spec_vrs.spec_vr_id := NULL;
    l_supplier_spec_vrs.delete_mark := 0;

    -- Set spec_vr_status to NEW
    -- =========================
    l_supplier_spec_vrs.spec_vr_status  := 100;

    -- Validate Supplier Spec Validity Rule
    -- ====================================
    GMD_SPEC_VRS_GRP.Validate_Supp_VR(
                      p_supp_vr           => l_supplier_spec_vrs,
                      p_called_from       => 'API',
                      p_operation         => 'INSERT',
                      x_return_status     => l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_SUPPLIER_SPEC_VRS_PVT.Insert_Row(l_supplier_spec_vrs, l_supplier_spec_vrs_out)
    THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Return Parameter Tbl
    -- ===========================
    l_supplier_spec_vrs_tbl(i) := l_supplier_spec_vrs_out;

 END LOOP;

  -- Standard Check of p_commit.
  -- ==========================
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status           := l_return_status;
  x_supplier_spec_vrs_tbl   := l_supplier_spec_vrs_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Supplier_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Supplier_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                 );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_Supplier_Spec_VRS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_SUPPLIER_SPEC_VRS;





/*
 +=========================================================================+
 | Name               : CREATE_MONITORING_SPEC_VRS                         |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of monitoring_spec_vrs definitions.  Validates      |
 |     each table entry and where valid, inserts a corresponding row       |
 |     into gmd_supplier_spec_vrs                                          |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-Jan-2004	Manish Gupta                                            |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE CREATE_MONITORING_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2
, p_commit                 IN  VARCHAR2
, p_validation_level       IN  VARCHAR2
, p_monitoring_spec_vrs_tbl  IN  GMD_SPEC_VRS_PUB.monitoring_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_monitoring_spec_vrs_tbl  OUT NOCOPY GMD_SPEC_VRS_PUB.monitoring_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'CREATE_MONITORING_SPEC_VRS';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_msg_count              NUMBER  :=0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_monitoring_spec_vrs      GMD_MONITORING_SPEC_VRS%ROWTYPE;
  l_monitoring_spec_vrs_out  GMD_MONITORING_SPEC_VRS%ROWTYPE;
  l_monitoring_spec_vrs_tbl  GMD_SPEC_VRS_PUB.monitoring_spec_vrs_tbl;
  l_user_id                NUMBER(15);

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Create_monitoring_Spec_VRS;

  --  Standard call to check for call compatibility
  --  =============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter
  -- ============================
  GMD_SPEC_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Loop through the Monitoring spec validity rules validating and creating
  -- =====================================================================
  FOR i in 1..p_monitoring_spec_vrs_tbl.COUNT LOOP

    l_monitoring_spec_vrs := p_monitoring_spec_vrs_tbl(i);

    -- Set Who columns ahead of Validation
    -- ===================================
    l_monitoring_spec_vrs.created_by      := l_user_id;
    l_monitoring_spec_vrs.last_updated_by := l_user_id;
    l_monitoring_spec_vrs.creation_date   := sysdate;
    l_monitoring_spec_vrs.last_update_date:= sysdate;

    -- Set spec_vr_id to NULL and delete_mark to zero
    -- ==============================================
    l_monitoring_spec_vrs.spec_vr_id := NULL;
    l_monitoring_spec_vrs.delete_mark := 0;

    -- Set spec_vr_status to NEW
    -- =========================
    l_monitoring_spec_vrs.spec_vr_status  := 100;


    -- Bug 3451798
    -- In case rule type is location, all resource-related info should be nulled
    -- In case rule type is resource, all location-related info should be nulled
    if (l_monitoring_spec_vrs.rule_type = 'R') then
     l_monitoring_spec_vrs.locator_id := NULL;
     l_monitoring_spec_vrs.locator_organization_id := NULL;
     l_monitoring_spec_vrs.subinventory := NULL;
    elsif (l_monitoring_spec_vrs.rule_type = 'L') then
     l_monitoring_spec_vrs.resources := NULL;
     l_monitoring_spec_vrs.resource_organization_id := NULL;
     l_monitoring_spec_vrs.resource_instance_id := NULL;
    end if;

    -- Validate Supplier Spec Validity Rule
    -- ====================================
    GMD_SPEC_VRS_GRP.Validate_Mon_VR(
                      p_mon_vr           => l_monitoring_spec_vrs,
                      p_called_from       => 'API',
                      p_operation         => 'INSERT',
                      x_mon_vr            => l_monitoring_spec_vrs_out,
                      x_return_status     => l_return_status
                      );


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_MONITORING_SPEC_VRS_PVT.Insert_Row(l_monitoring_spec_vrs, l_monitoring_spec_vrs_out)
    THEN
      -- Diagnostic message is already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Return Parameter Tbl
    -- ===========================
    l_monitoring_spec_vrs_tbl(i) := l_monitoring_spec_vrs_out;

 END LOOP;

  -- Standard Check of p_commit.
  -- ==========================
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status           := l_return_status;
  x_monitoring_spec_vrs_tbl   := l_monitoring_spec_vrs_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_monitoring_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_monitoring_Spec_VRS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                 );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_monitoring_Spec_VRS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_MONITORING_SPEC_VRS;
/*
 +=========================================================================+
 | Name               : DELETE_INVENTORY_SPEC_VRS                          |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of inventory_spec_vrs definitions.  Validates       |
 |     each table entry to ensure the corresponding row is not already     |
 |     delete marked.  Where validation is successful, a logical delete    |
 |     is performed setting delete_mark=1                                  |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE DELETE_INVENTORY_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, p_validation_level         IN  VARCHAR2
, p_inventory_spec_vrs_tbl   IN  GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl
, p_user_name                IN  VARCHAR2
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name                 CONSTANT VARCHAR2 (30) := 'DELETE_INVENTORY_SPEC_VRS';
  l_api_version              CONSTANT NUMBER        := 1.0;
  l_msg_count                NUMBER  :=0;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                     GMD_SPECIFICATIONS%ROWTYPE;
  l_inventory_spec_vrs       GMD_INVENTORY_SPEC_VRS%ROWTYPE;
  l_deleted_rows             NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_Inventory_Spec_VRS;

  -- Standard call to check for call compatibility.
  -- ==============================================

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize Local Variables
  -- ==========================
  l_spec.spec_id := 0;

  -- Validate user_name
  -- ==================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_spec.last_updated_by);

  IF NVL(l_spec.last_updated_by, -1) < 0
  THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Process each of the inventory spec validity rules
  -- =================================================
  FOR i in 1..p_inventory_spec_vrs_tbl.COUNT LOOP
    l_inventory_spec_vrs := p_inventory_spec_vrs_tbl(i);
    -- Ensure the owning spec_id is supplied
    -- =====================================
    IF ( l_inventory_spec_vrs.spec_id IS NULL )
    THEN
    -- raise validation error
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Retrieve and validate the owning SPEC if it is not already retrieved/validated
    -- ==============================================================================
    IF l_spec.spec_id <> l_inventory_spec_vrs.spec_id
    THEN
      -- Validate to ensure spec is in a suitable state to delete mark
      -- ==============================================================
      GMD_SPEC_GRP.Validate_Before_Delete( p_spec_id          => l_inventory_spec_vrs.spec_id
                                         , x_return_status    => l_return_status
                                         , x_message_data     => l_msg_data
                                         );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Lock the SPEC ahead of manipulating INVENTORY_SPEC_VRS
      -- ======================================================
      IF  NOT GMD_Specifications_PVT.Lock_Row(l_inventory_spec_vrs.spec_id)
      THEN
        -- Report Failure to obtain locks
        -- ==============================
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                                'l_table_name', 'GMD_SPECIFICATIONS',
                                'l_column_name', 'SPEC_ID',
                                'l_key_value', l_inventory_spec_vrs.spec_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;  -- end of spec validation

    -- Validate to ensure validity_rule exists and is not already delete marked
    -- ========================================================================
    GMD_SPEC_VRS_GRP.VALIDATE_BEFORE_DELETE_INV_VRS
                          (  p_spec_id          => l_inventory_spec_vrs.spec_id
                           , p_spec_vr_id       => l_inventory_spec_vrs.spec_vr_id
                           , x_return_status    => l_return_status
                           , x_message_data     => l_msg_data
                           );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic message already on the stack
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Lock the validity rule ahead of deleting
    -- ========================================
    IF  NOT GMD_INVENTORY_SPEC_VRS_PVT.Lock_Row( l_inventory_spec_vrs.spec_vr_id)
    THEN
      -- Report Failure to obtain locks
      -- ==============================
      GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_INVENTORY_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_inventory_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_INVENTORY_SPEC_VRS_PVT.Delete_Row
                                     ( p_spec_vr_id  => l_inventory_spec_vrs.spec_vr_id
                                     , p_last_update_date => sysdate
                                     , p_last_updated_by  => l_spec.last_updated_by
                                     )
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_INVENTORY_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_inventory_spec_vrs.spec_vr_id);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_deleted_rows       := i;
    END IF;

  END LOOP;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Inventory_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Inventory_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Delete_Inventory_Spec_VRS;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_INVENTORY_SPEC_VRS;

/*
 +=========================================================================+
 | Name               : DELETE_WIP_SPEC_VRS                                |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of wip_spec_vrs definitions.  Validates             |
 |     each table entry to ensure the corresponding row is not already     |
 |     delete marked.  Where validation is successful, a logical delete    |
 |     is performed setting delete_mark=1                                  |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE DELETE_WIP_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, p_validation_level         IN  VARCHAR2
, p_wip_spec_vrs_tbl         IN  GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl
, p_user_name                IN  VARCHAR2
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name                 CONSTANT VARCHAR2 (30) := 'DELETE_WIP_SPEC_VRS';
  l_api_version              CONSTANT NUMBER        := 1.0;
  l_msg_count                NUMBER  :=0;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                     GMD_SPECIFICATIONS%ROWTYPE;
  l_wip_spec_vrs             GMD_WIP_SPEC_VRS%ROWTYPE;
  l_deleted_rows             NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_WIP_Spec_VRS;

  -- Standard call to check for call compatibility.
  -- ==============================================

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize Local Variables
  -- ==========================
  l_spec.spec_id := 0;

  -- Validate user_name
  -- ==================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_spec.last_updated_by);

  IF NVL(l_spec.last_updated_by, -1) < 0
  THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Process each of the WIP spec validity rules
  -- ===========================================
  FOR i in 1..p_wip_spec_vrs_tbl.COUNT LOOP
    l_wip_spec_vrs := p_wip_spec_vrs_tbl(i);
    -- Ensure the owning spec_id is supplied
    -- =====================================
    IF ( l_wip_spec_vrs.spec_id IS NULL )
    THEN
    -- raise validation error
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Retrieve and validate the owning SPEC if it is not already retrieved/validated
    -- ==============================================================================
    IF l_spec.spec_id <> l_wip_spec_vrs.spec_id
    THEN
      -- Validate to ensure spec is in a suitable state to delete mark
      -- ==============================================================
      GMD_SPEC_GRP.Validate_Before_Delete( p_spec_id          => l_wip_spec_vrs.spec_id
                                         , x_return_status    => l_return_status
                                         , x_message_data     => l_msg_data
                                         );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Lock the SPEC ahead of manipulating WIP_SPEC_VRS
      -- ======================================================
      IF  NOT GMD_Specifications_PVT.Lock_Row(l_wip_spec_vrs.spec_id)
      THEN
        -- Report Failure to obtain locks
        -- ==============================
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                                'l_table_name', 'GMD_SPECIFICATIONS',
                                'l_column_name', 'SPEC_ID',
                                'l_key_value', l_wip_spec_vrs.spec_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;  -- end of spec validation

    -- Validate to ensure validity_rule exists and is not already delete marked
    -- ========================================================================
    GMD_SPEC_VRS_GRP.VALIDATE_BEFORE_DELETE_WIP_VRS
                          ( p_spec_id          => l_wip_spec_vrs.spec_id
                          , p_spec_vr_id       => l_wip_spec_vrs.spec_vr_id
                          , x_return_status    => l_return_status
                          , x_message_data     => l_msg_data
                          );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Lock the validity rule ahead of deleting
    -- ========================================
    IF  NOT GMD_WIP_SPEC_VRS_PVT.Lock_Row( l_wip_spec_vrs.spec_vr_id)
    THEN
      -- Report Failure to obtain locks
      -- ==============================
      GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_WIP_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_wip_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_WIP_SPEC_VRS_PVT.Delete_Row ( p_spec_vr_id  => l_wip_spec_vrs.spec_vr_id
                                           , p_last_update_date => sysdate
                                           , p_last_updated_by  => l_spec.last_updated_by
                                           )
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_WIP_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_wip_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_deleted_rows       := i;
    END IF;

  END LOOP;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_WIP_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_WIP_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Delete_WIP_Spec_VRS;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_WIP_SPEC_VRS;

/*
 +=========================================================================+
 | Name               : DELETE_CUSTOMER_SPEC_VRS                           |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of customer_spec_vrs definitions.  Validates        |
 |     each table entry to ensure the corresponding row is not already     |
 |     delete marked.  Where validation is successful, a logical delete    |
 |     is performed setting delete_mark=1                                  |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE DELETE_CUSTOMER_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, p_validation_level         IN  VARCHAR2
, p_customer_spec_vrs_tbl    IN  GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl
, p_user_name                IN  VARCHAR2
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name                 CONSTANT VARCHAR2 (30) := 'DELETE_CUSTOMER_SPEC_VRS';
  l_api_version              CONSTANT NUMBER        := 1.0;
  l_msg_count                NUMBER  :=0;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                     GMD_SPECIFICATIONS%ROWTYPE;
  l_customer_spec_vrs        GMD_CUSTOMER_SPEC_VRS%ROWTYPE;
  l_deleted_rows             NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_Customer_Spec_VRS;

  -- Standard call to check for call compatibility.
  -- ==============================================

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize Local Variables
  -- ==========================
  l_spec.spec_id := 0;

  -- Validate user_name
  -- ==================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_spec.last_updated_by);

  IF NVL(l_spec.last_updated_by, -1) < 0
  THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Process each of the WIP spec validity rules
  -- ===========================================
  FOR i in 1..p_customer_spec_vrs_tbl.COUNT LOOP
    l_customer_spec_vrs := p_customer_spec_vrs_tbl(i);
    -- Ensure the owning spec_id is supplied
    -- =====================================
    IF ( l_customer_spec_vrs.spec_id IS NULL )
    THEN
    -- raise validation error
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Retrieve and validate the owning SPEC if it is not already retrieved/validated
    -- ==============================================================================
    IF l_spec.spec_id <> l_customer_spec_vrs.spec_id
    THEN
      -- Validate to ensure spec is in a suitable state to delete mark
      -- ==============================================================
      GMD_SPEC_GRP.Validate_Before_Delete( p_spec_id          => l_customer_spec_vrs.spec_id
                                         , x_return_status    => l_return_status
                                         , x_message_data     => l_msg_data
                                         );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Lock the SPEC ahead of manipulating CUSTOMER_SPEC_VRS
      -- ======================================================
      IF  NOT GMD_Specifications_PVT.Lock_Row(l_customer_spec_vrs.spec_id)
      THEN
        -- Report Failure to obtain locks
        -- ==============================
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                                'l_table_name', 'GMD_SPECIFICATIONS',
                                'l_column_name', 'SPEC_ID',
                                'l_key_value', l_customer_spec_vrs.spec_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;  -- end of spec validation

    -- Validate to ensure validity_rule exists and is not already delete marked
    -- ========================================================================
    GMD_SPEC_VRS_GRP.VALIDATE_BEFORE_DELETE_CST_VRS
                         ( p_spec_id          => l_customer_spec_vrs.spec_id
                         , p_spec_vr_id       => l_customer_spec_vrs.spec_vr_id
                         , x_return_status    => l_return_status
                         , x_message_data     => l_msg_data
                         );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Lock the validity rule ahead of deleting
    -- ========================================
    IF  NOT GMD_CUSTOMER_SPEC_VRS_PVT.Lock_Row( l_customer_spec_vrs.spec_vr_id)
    THEN
      -- Report Failure to obtain locks
      -- ==============================
      GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_CUSTOMER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_customer_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_CUSTOMER_SPEC_VRS_PVT.Delete_Row
                                    (  p_spec_vr_id  => l_customer_spec_vrs.spec_vr_id
                                     , p_last_update_date => sysdate
                                     , p_last_updated_by  => l_spec.last_updated_by
                                     )
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_CUSTOMER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_customer_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_deleted_rows       := i;
    END IF;

  END LOOP;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Customer_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Customer_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Delete_Customer_Spec_VRS;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_CUSTOMER_SPEC_VRS;

/*
 +=========================================================================+
 | Name               : DELETE_SUPPLIER_SPEC_VRS                           |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of supplier_spec_vrs definitions.  Validates        |
 |     each table entry to ensure the corresponding row is not already     |
 |     delete marked.  Where validation is successful, a logical delete    |
 |     is performed setting delete_mark=1                                  |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/
PROCEDURE DELETE_SUPPLIER_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, p_validation_level         IN  VARCHAR2
, p_supplier_spec_vrs_tbl    IN  GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl
, p_user_name                IN  VARCHAR2
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name                 CONSTANT VARCHAR2 (30) := 'DELETE_SUPPLIER_SPEC_VRS';
  l_api_version              CONSTANT NUMBER        := 1.0;
  l_msg_count                NUMBER  :=0;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                     GMD_SPECIFICATIONS%ROWTYPE;
  l_supplier_spec_vrs        GMD_SUPPLIER_SPEC_VRS%ROWTYPE;
  l_deleted_rows             NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_Supplier_Spec_VRS;

  -- Standard call to check for call compatibility.
  -- ==============================================

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize Local Variables
  -- ==========================
  l_spec.spec_id := 0;

  -- Validate user_name
  -- ==================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_spec.last_updated_by);

  IF NVL(l_spec.last_updated_by, -1) < 0
  THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Process each of the WIP spec validity rules
  -- ===========================================
  FOR i in 1..p_supplier_spec_vrs_tbl.COUNT LOOP
    l_supplier_spec_vrs := p_supplier_spec_vrs_tbl(i);
    -- Ensure the owning spec_id is supplied
    -- =====================================
    IF ( l_supplier_spec_vrs.spec_id IS NULL )
    THEN
    -- raise validation error
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Retrieve and validate the owning SPEC if it is not already retrieved/validated
    -- ==============================================================================
    IF l_spec.spec_id <> l_supplier_spec_vrs.spec_id
    THEN
      -- Validate to ensure spec is in a suitable state to delete mark
      -- ==============================================================
      GMD_SPEC_GRP.Validate_Before_Delete( p_spec_id          => l_supplier_spec_vrs.spec_id
                                         , x_return_status    => l_return_status
                                         , x_message_data     => l_msg_data
                                         );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Lock the SPEC ahead of manipulating SUPPLIER_SPEC_VRS
      -- ======================================================
      IF  NOT GMD_Specifications_PVT.Lock_Row(l_supplier_spec_vrs.spec_id)
      THEN
        -- Report Failure to obtain locks
        -- ==============================
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                                'l_table_name', 'GMD_SPECIFICATIONS',
                                'l_column_name', 'SPEC_ID',
                                'l_key_value', l_supplier_spec_vrs.spec_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;  -- end of spec validation

    -- Validate to ensure validity_rule exists and is not already delete marked
    -- ========================================================================
    GMD_SPEC_VRS_GRP.VALIDATE_BEFORE_DELETE_SUP_VRS
                         ( p_spec_id          => l_supplier_spec_vrs.spec_id
                         , p_spec_vr_id       => l_supplier_spec_vrs.spec_vr_id
                         , x_return_status    => l_return_status
                         , x_message_data     => l_msg_data
                         );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Lock the validity rule ahead of deleting
    -- ========================================
    IF  NOT GMD_SUPPLIER_SPEC_VRS_PVT.Lock_Row( l_supplier_spec_vrs.spec_vr_id)
    THEN
      -- Report Failure to obtain locks
      -- ==============================
      GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_SUPPLIER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_supplier_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_SUPPLIER_SPEC_VRS_PVT.Delete_Row
                                    ( p_spec_vr_id  => l_supplier_spec_vrs.spec_vr_id
                                     , p_last_update_date => sysdate
                                     , p_last_updated_by  => l_spec.last_updated_by
                                     )
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_SUPPLIER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_supplier_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_deleted_rows       := i;
    END IF;

  END LOOP;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Supplier_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Supplier_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Delete_Supplier_Spec_VRS;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_SUPPLIER_SPEC_VRS;


/*
 +=========================================================================+
 | Name               : DELETE_MONITORING_SPEC_VRS                           |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of monitoring_spec_vrs definitions.  Validates        |
 |     each table entry to ensure the corresponding row is not already     |
 |     delete marked.  Where validation is successful, a logical delete    |
 |     is performed setting delete_mark=1                                  |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-Jan-2004  Manish Gupta                                           |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE DELETE_MONITORING_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, p_validation_level         IN  VARCHAR2
, p_monitoring_spec_vrs_tbl    IN  GMD_SPEC_VRS_PUB.MONITORING_spec_vrs_tbl
, p_user_name                IN  VARCHAR2
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name                 CONSTANT VARCHAR2 (30) := 'DELETE_MONITORING_SPEC_VRS';
  l_api_version              CONSTANT NUMBER        := 1.0;
  l_msg_count                NUMBER  :=0;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                     GMD_SPECIFICATIONS%ROWTYPE;
  l_monitoring_spec_vrs        GMD_MONITORING_SPEC_VRS%ROWTYPE;
  l_deleted_rows             NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_Monitoring_Spec_VRS;

  -- Standard call to check for call compatibility.
  -- ==============================================

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize Local Variables
  -- ==========================
  l_spec.spec_id := 0;

  -- Validate user_name
  -- ==================
  GMD_SPEC_GRP.GET_WHO ( p_user_name => p_user_name
                          ,x_user_id   => l_spec.last_updated_by);

  IF NVL(l_spec.last_updated_by, -1) < 0
  THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Process each of the WIP spec validity rules
  -- ===========================================
  FOR i in 1..p_monitoring_spec_vrs_tbl.COUNT LOOP
    l_monitoring_spec_vrs := p_monitoring_spec_vrs_tbl(i);
    -- Ensure the owning spec_id is supplied
    -- =====================================
    IF ( l_monitoring_spec_vrs.spec_id IS NULL )
    THEN
    -- raise validation error
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Retrieve and validate the owning SPEC if it is not already retrieved/validated
    -- ==============================================================================
    IF l_spec.spec_id <> l_monitoring_spec_vrs.spec_id
    THEN
      -- Validate to ensure spec is in a suitable state to delete mark
      -- ==============================================================
      GMD_SPEC_GRP.Validate_Before_Delete( p_spec_id          => l_monitoring_spec_vrs.spec_id
                                         , x_return_status    => l_return_status
                                         , x_message_data     => l_msg_data
                                         );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Lock the SPEC ahead of manipulating MONITORING_SPEC_VRS
      -- ======================================================
      IF  NOT GMD_Specifications_PVT.Lock_Row(l_monitoring_spec_vrs.spec_id)
      THEN
        -- Report Failure to obtain locks
        -- ==============================
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                                'l_table_name', 'GMD_SPECIFICATIONS',
                                'l_column_name', 'SPEC_ID',
                                'l_key_value', l_monitoring_spec_vrs.spec_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;  -- end of spec validation

    -- Validate to ensure validity_rule exists and is not already delete marked
    -- To be added later as the group layer is locked by Sierra.
    -- ========================================================================
    /*GMD_SPEC_VRS_GRP.VALIDATE_BEFORE_DELETE_MON_VRS
                         ( p_spec_id          => l_monitoring_spec_vrs.spec_id
                         , p_spec_vr_id       => l_monitoring_spec_vrs.spec_vr_id
                         , x_return_status    => l_return_status
                         , x_message_data     => l_msg_data
                         );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;*/


    -- Lock the validity rule ahead of deleting
    -- ========================================
    IF  NOT GMD_MONITORING_SPEC_VRS_PVT.Lock_Row( l_monitoring_spec_vrs.spec_vr_id)
    THEN
      -- Report Failure to obtain locks
      -- ==============================
      GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_monitoring_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_monitoring_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_MONITORING_SPEC_VRS_PVT.Delete_Row
                                    (  p_spec_vr_id  => l_monitoring_spec_vrs.spec_vr_id
                                     , p_last_update_date => sysdate
                                     , p_last_updated_by  => l_spec.last_updated_by
                                     )
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_MONITORING_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_monitoring_spec_vrs.spec_vr_id);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_deleted_rows       := i;
    END IF;

  END LOOP;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_monitoring_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_monitoring_Spec_VRS;
      x_deleted_rows  := 0;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Delete_monitoring_Spec_VRS;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_MONITORING_SPEC_VRS;
END GMD_SPEC_VRS_PUB;

/
