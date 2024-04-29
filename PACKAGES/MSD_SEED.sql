--------------------------------------------------------
--  DDL for Package MSD_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SEED" AUTHID CURRENT_USER AS
/* $Header: msdseeds.pls 115.0 2000/02/14 17:11:47 pkm ship        $ */


/* Public Functions */

procedure insert_levels;
procedure insert_hierarchies;
procedure insert_hierarchy_levels;
procedure insert_all;

END MSD_SEED;

 

/
