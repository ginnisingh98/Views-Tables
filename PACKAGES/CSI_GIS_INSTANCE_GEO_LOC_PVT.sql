--------------------------------------------------------
--  DDL for Package CSI_GIS_INSTANCE_GEO_LOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GIS_INSTANCE_GEO_LOC_PVT" AUTHID CURRENT_USER AS
/* $Header: csivgils.pls 120.0.12010000.1 2008/11/10 05:56:30 jgootyag noship $ */
PROCEDURE INSERT_ROW
(
    p_instance_id             IN          NUMBER
   ,p_inst_latitude           IN          NUMBER
   ,p_inst_longitude          IN          NUMBER
   , x_return_status           OUT NOCOPY  VARCHAR2
);


PROCEDURE UPDATE_ROW
(
    p_instance_id             IN          NUMBER
   ,p_inst_latitude           IN          NUMBER
   ,p_inst_longitude          IN          NUMBER
   ,p_valid_flag              IN          VARCHAR2
  , x_return_status           OUT NOCOPY  VARCHAR2
);

END CSI_GIS_INSTANCE_GEO_LOC_PVT;

/
