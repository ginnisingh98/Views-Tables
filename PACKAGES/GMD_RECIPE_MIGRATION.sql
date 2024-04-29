--------------------------------------------------------
--  DDL for Package GMD_RECIPE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMDRMIGS.pls 115.6 2003/04/10 14:06:32 gmangari noship $ */

  PROCEDURE MIGRATE_RECIPE
   (	p_api_version		IN		NUMBER				,
	p_init_msg_list		IN 		VARCHAR2 := FND_API.G_FALSE	,
	p_commit		IN		VARCHAR2 := FND_API.G_FALSE	,
	x_return_status		OUT NOCOPY 	VARCHAR2			,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,
	p_recipe_no_choice 	IN  		VARCHAR2
   );

   PROCEDURE insert_message (
      p_source_table       IN   VARCHAR2,
      p_target_table       IN   VARCHAR2,
      p_source_id          IN   VARCHAR2,
      p_target_id	   IN	VARCHAR2,
      p_message            IN   VARCHAR2,
      p_error_type         IN   VARCHAR2 DEFAULT 'E'
   );

   PROCEDURE qty_update_fxd_scaling;
END GMD_RECIPE_MIGRATION;

 

/
