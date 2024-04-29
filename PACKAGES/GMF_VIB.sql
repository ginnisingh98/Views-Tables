--------------------------------------------------------
--  DDL for Package GMF_VIB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_VIB" AUTHID CURRENT_USER AS
/*  $Header: GMFVIBS.pls 120.1.12010000.1 2008/07/30 05:35:41 appldev ship $

 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMFVIB.pls                                                            |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMF_VIB                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 | CONTENTS                                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 +==========================================================================+
*/
PROCEDURE Create_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Update_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Delete_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Create_Temp_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Create_VIB_Details
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_tran_rec      IN          GMF_LAYERS.trans_rec_type,
  p_layer_rec     IN          gmf_incoming_material_layers%ROWTYPE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Finalize_VIB_Details
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Revert_Finalization
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

/*
PROCEDURE allocate_ingredients
(
  p_ac_proc_id    IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2
);
*/

END GMF_VIB;

/
