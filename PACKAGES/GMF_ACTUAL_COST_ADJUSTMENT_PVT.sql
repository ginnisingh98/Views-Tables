--------------------------------------------------------
--  DDL for Package GMF_ACTUAL_COST_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ACTUAL_COST_ADJUSTMENT_PVT" AUTHID CURRENT_USER AS
 /* $Header: GMFVACAS.pls 120.2.12000000.1 2007/01/17 16:53:24 appldev ship $ */
  PROCEDURE CREATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                         IN              NUMBER,
  p_init_msg_list                       IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status                       OUT     NOCOPY  VARCHAR2,
  x_msg_count                           OUT     NOCOPY  NUMBER,
  x_msg_data                            OUT     NOCOPY  VARCHAR2,
  p_adjustment_rec                      IN  OUT NOCOPY  GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );

  PROCEDURE UPDATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                         IN              NUMBER,
  p_init_msg_list                       IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_adjustment_rec                      IN  OUT NOCOPY  GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );

  PROCEDURE DELETE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                         IN              NUMBER,
  p_init_msg_list                       IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_adjustment_rec                      IN  OUT NOCOPY  GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );

  PROCEDURE GET_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                         IN              NUMBER,
  p_init_msg_list                       IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_adjustment_rec                      IN  OUT NOCOPY  GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );

END GMF_ACTUAL_COST_ADJUSTMENT_PVT;

 

/
