--------------------------------------------------------
--  DDL for Package WMS_CROSSDOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CROSSDOCK_GRP" AUTHID CURRENT_USER AS
  /* $Header: WMSXDGRS.pls 120.3 2005/07/06 13:47:28 stdavid noship $ */

  g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header: WMSXDGRS.pls 120.3 2005/07/06 13:47:28 stdavid noship $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'WMS_CROSSDOCK_GRP';


  --
  --
  -- VALIDATE_PLANXDOCK_CRT_ID:
  --
  -- Returns fnd_api.g_ret_sts_success if p_criterion_id is a valid
  -- crossdock criterion of type 'Planned'
  --
  -- Returns fnd_api.g_ret_sts_error   if p_criterion_id is not valid
  -- or if criterion type is not 'Planned'
  --
  -- Returns fnd_api.g_ret_sts_unexp_error for unexpected errors
  --
  --

  PROCEDURE validate_planxdock_crt_id
  ( x_return_status  OUT NOCOPY  VARCHAR2
  , p_criterion_id   IN          NUMBER
  );


  --
  --
  -- CHK_PLANXD_CRT_ID_NAME:
  --
  -- If a valid ID is passed in, it returns criterion name
  -- Or else if a valid criterion name is passed in, the ID is returned
  --
  -- Returns fnd_api.g_ret_sts_success for success
  --
  -- Returns fnd_api.g_ret_sts_error if ID/name is not valid
  -- or if criterion type is not 'Planned'
  --
  -- Returns fnd_api.g_ret_sts_unexp_error for unexpected errors
  --
  --

  PROCEDURE chk_planxd_crt_id_name
  ( x_return_status    OUT    NOCOPY   VARCHAR2
  , p_criterion_id     IN OUT NOCOPY   NUMBER
  , p_criterion_name   IN OUT NOCOPY   VARCHAR2
  );


  --
  --
  -- CHK_MO_TYPE:
  --
  -- Takes in a move order line and returns move order header ID,
  -- move order type, and whether or not it is a putaway move order
  --
  -- Returns fnd_api.g_ret_sts_success for success
  --
  -- Returns fnd_api.g_ret_sts_error if ID/name is not valid
  -- or if criterion type is not 'Planned'
  --
  -- Returns fnd_api.g_ret_sts_unexp_error for unexpected errors
  --
  --

  PROCEDURE chk_mo_type
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , x_mo_header_id    OUT NOCOPY   NUMBER
  , x_mo_type         OUT NOCOPY   NUMBER
  , x_is_putaway_mo   OUT NOCOPY   VARCHAR2
  , p_mo_line_id      IN           NUMBER
  );

END wms_crossdock_grp;

 

/
