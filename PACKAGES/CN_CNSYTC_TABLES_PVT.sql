--------------------------------------------------------
--  DDL for Package CN_CNSYTC_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CNSYTC_TABLES_PVT" AUTHID CURRENT_USER AS
/* $Header: cnsytbls.pls 120.1 2005/08/08 04:44:56 rramakri noship $ */

--=============================================================================
-- Work around for Forms Bug w.r.t using *_MISS_* type of
-- Initializations
--
--
TYPE table_rec_type IS RECORD (
		  object_id          cn_objects.object_id%TYPE
		, name               cn_objects.name%TYPE
		, description        cn_objects.description%TYPE
		, status             cn_objects.object_status%TYPE
		, repository_id      cn_objects.repository_id%TYPE
		, alias              cn_objects.alias%TYPE
		, table_level        cn_objects.table_level%TYPE
		, table_type         cn_objects.table_level%TYPE
		, object_type        cn_objects.object_type%TYPE
		, schema             cn_objects.schema%TYPE
		, calc_eligible_flag cn_objects.calc_eligible_flag%TYPE
		, user_name          cn_objects.user_name%TYPE
		, object_version_number  cn_objects.object_version_number%TYPE
		, org_id             cn_objects.org_id%TYPE
  		       );
--
--
--

PROCEDURE create_tables(
			      x_return_status      OUT NOCOPY VARCHAR2
			    , x_msg_count          OUT NOCOPY NUMBER
			    , x_msg_data           OUT NOCOPY VARCHAR2
			    , x_loading_status     OUT NOCOPY VARCHAR2
			    , p_api_version        IN  NUMBER
			    , p_init_msg_list      IN  VARCHAR2
			    , p_commit             IN  VARCHAR2
			    , p_validation_level   IN  VARCHAR2
			    , p_table_rec          IN  OUT NOCOPY table_rec_type
			    );

END  cn_cnsytc_tables_pvt;
 

/
