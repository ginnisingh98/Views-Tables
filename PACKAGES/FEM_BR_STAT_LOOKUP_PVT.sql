--------------------------------------------------------
--  DDL for Package FEM_BR_STAT_LOOKUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_STAT_LOOKUP_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVSTATLKPS.pls 120.0 2006/06/29 09:05:57 asadadek noship $ */

PROCEDURE DeleteObjectDefinition(p_obj_def_id NUMBER);

PROCEDURE CopyObjectDefinition(p_source_obj_def_id  IN NUMBER,
                               p_target_obj_def_id  IN NUMBER,
                               p_created_by         IN NUMBER,
                               p_creation_date      IN DATE);

END fem_br_stat_lookup_pvt;

 

/
