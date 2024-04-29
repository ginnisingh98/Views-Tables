--------------------------------------------------------
--  DDL for Package PV_CONTEXT_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_CONTEXT_VALUES" 
/* $Header: pvxvcons.pls 120.3 2005/12/27 13:17:33 amaram noship $*/
AUTHID CURRENT_USER
AS

-- ----------------------------------------------------------------------------
-- Global Variables
-- ----------------------------------------------------------------------------
g_full_refresh       CONSTANT VARCHAR2(30) := 'FULL';
g_incr_refresh       CONSTANT VARCHAR2(30) := 'INCR';
g_incr_full_refresh  CONSTANT VARCHAR2(30) := 'INCR-FULL';


-- ----------------------------------------------------------------------------
-- Public Procedures
-- ----------------------------------------------------------------------------
procedure Exec_Create_context_Val ( ERRBUF              OUT  NOCOPY VARCHAR2,
                                    RETCODE             OUT  NOCOPY VARCHAR2,
                                    p_new_partners_only IN VARCHAR2 := 'N',
                                    p_log_to_file       IN VARCHAR2 := 'Y');


PROCEDURE Pre_Processing (
   p_refresh_type          IN  VARCHAR2 := g_full_refresh,
   p_synonym_name          IN  VARCHAR2,
   p_mirror_synonym_name   IN  VARCHAR2,
   p_temp_synonym_name     IN  VARCHAR2,
   p_partner_id_temp_table IN  VARCHAR2 := null,
   p_temp_table_processed  IN  BOOLEAN  := FALSE,
   p_last_incr_refresh_str IN  VARCHAR2 := null,
   p_log_to_file           IN  VARCHAR2 := 'Y',
   p_module_name           IN  VARCHAR2,
   p_pv_schema_name        IN  OUT NOCOPY VARCHAR2,
   p_search_table          OUT NOCOPY VARCHAR2,
   p_mirror_table          OUT NOCOPY VARCHAR2,
   p_end_refresh_flag      OUT NOCOPY BOOLEAN,
   p_out_refresh_type      OUT NOCOPY VARCHAR2
);

PROCEDURE Post_Processing (
   p_refresh_type          IN  VARCHAR2 := g_full_refresh,
   p_synonym_name          IN  VARCHAR2,
   p_mirror_synonym_name   IN  VARCHAR2,
   p_temp_synonym_name     IN  VARCHAR2,
   p_pv_schema_name        IN  VARCHAR2,
   p_search_table          IN  VARCHAR2,
   p_mirror_table          IN  VARCHAR2,
   p_incr_timestamp        IN  VARCHAR2,
   p_api_package_name      IN  VARCHAR2,
   p_module_name           IN  VARCHAR2,
   p_log_to_file           IN  VARCHAR2 := 'Y'
) ;


PROCEDURE Disable_Drop_Indexes(
   p_mirror_table    IN VARCHAR2,
   p_pv_schema_owner IN VARCHAR2
);

PROCEDURE Enable_Create_Indexes(
   p_search_table    IN VARCHAR2,
   p_mirror_table    IN VARCHAR2,
   p_pv_schema_owner IN VARCHAR2
);

PROCEDURE Create_Indexes(
   p_table1          IN VARCHAR2,
   p_table2          IN VARCHAR2,
   p_pv_schema_owner IN VARCHAR2
);


end PV_CONTEXT_VALUES;

 

/
