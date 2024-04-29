--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_LEVEL_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_LEVEL_TYPES" AUTHID CURRENT_USER AS
/* $Header: msddemclts.pls 120.1.12000000.2 2007/09/25 06:30:38 syenamar noship $ */

procedure collect_levels(errbuf              OUT NOCOPY VARCHAR2,
                           retcode             OUT NOCOPY NUMBER,
                           p_instance_id       IN  NUMBER,
                           p_collect_level_type  IN NUMBER,
                           p_plan_id             IN NUMBER DEFAULT -1)  ;

END MSD_DEM_COLLECT_LEVEL_TYPES;

 

/
