--------------------------------------------------------
--  DDL for Package FEM_MV_REFRESH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_MV_REFRESH_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVMVREFRESHS.pls 120.1 2008/02/20 06:51:38 jcliving noship $ */

PROCEDURE Register_MV
(
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  --
  p_mv_name                 IN         VARCHAR2,
  p_base_table_name         IN         VARCHAR2,
  p_refresh_group_sequence  IN         NUMBER   := NULL
);

PROCEDURE Unregister_MV
(
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  --
  p_mv_name                 IN         VARCHAR2
);

PROCEDURE Refresh_MV_CP
(
  errbuf                    OUT NOCOPY VARCHAR2  ,
  retcode                   OUT NOCOPY VARCHAR2  ,
  --
  p_base_table_name         IN         VARCHAR2
);

PROCEDURE Refresh_MV
(
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  --
  p_base_table_name         IN         VARCHAR2
);

END FEM_MV_Refresh_Pvt ;

/
