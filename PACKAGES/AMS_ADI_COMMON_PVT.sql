--------------------------------------------------------
--  DDL for Package AMS_ADI_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADI_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvadcs.pls 120.0 2005/07/01 03:58:19 appldev noship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_ADI_COMMON_PVT';
g_log_level  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

g_batch_size CONSTANT NUMBER := FND_PROFILE.VALUE('AMS_ADI_BATCH_SIZE');
g_max_error_messages CONSTANT NUMBER := 5;

TYPE ams_adi_error_rec IS RECORD
(error_code VARCHAR2(30),
 error_message VARCHAR2(4000),
 object_id NUMBER,
 object_name VARCHAR2(240),
 parent_object_id NUMBER
);

TYPE ams_adi_error_rec_t IS TABLE OF ams_adi_error_rec;

--========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
--========================================================================
PROCEDURE handle_success_row(
p_commit IN VARCHAR2 := FND_API.G_TRUE
);


--========================================================================
-- PROCEDURE
--    handles ERROR in API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
--========================================================================
PROCEDURE handle_error_row(
p_write_conc_log IN VARCHAR2 := FND_API.G_TRUE,
p_rollback IN VARCHAR2 := FND_API.G_TRUE,
p_error_code IN VARCHAR2 := NULL,
p_error_message IN VARCHAR2 := NULL,
p_object_id IN NUMBER,
p_object_name IN VARCHAR2,
p_parent_object_id IN NUMBER,
p_error_records IN OUT NOCOPY ams_adi_error_rec_t
);


--========================================================================
-- PROCEDURE
--    handles FATAL ERROR in API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    ROLLBACK, log messages to conc log
-- HISTORY
--
--========================================================================
PROCEDURE handle_fatal_error(
p_write_conc_log IN VARCHAR2 := FND_API.G_TRUE,
p_rollback IN VARCHAR2 := FND_API.G_TRUE
);


--========================================================================
-- PROCEDURE
--    initializes for all operations
-- Purpose
--
-- HISTORY
--
--========================================================================
PROCEDURE init;


--========================================================================
-- PROCEDURE
--    initializes for batch operations
-- Purpose
--    initializes error structure table
-- HISTORY
--
--========================================================================
PROCEDURE init_for_batch(
p_error_records IN OUT  NOCOPY ams_adi_error_rec_t
);


--========================================================================
-- PROCEDURE
--    needs to be called after processing a batch of batch_size
-- Purpose
--    updates all staging table rows that errored out and commits(by default)
-- HISTORY
--
--========================================================================
PROCEDURE complete_batch(
p_update_table_name IN VARCHAR2,
p_upload_batch_id IN NUMBER,
p_use_object_id_as_pk IN VARCHAR2 := FND_API.G_TRUE,
p_commit IN VARCHAR2 := FND_API.G_TRUE,
p_error_records IN OUT  NOCOPY ams_adi_error_rec_t
);


--========================================================================
-- PROCEDURE
--    needs to be called at the end of all rows processing
-- Purpose
--    updates all staging table rows that errored out and commits
-- HISTORY
--
--========================================================================
PROCEDURE complete_all(
p_write_conc_out IN VARCHAR2 := FND_API.G_TRUE,
p_commit IN VARCHAR2 := FND_API.G_TRUE,
p_upload_batch_id IN NUMBER := 0
);



END AMS_ADI_COMMON_PVT;

 

/
