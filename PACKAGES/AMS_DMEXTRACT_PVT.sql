--------------------------------------------------------
--  DDL for Package AMS_DMEXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMEXTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdxts.pls 115.9 2002/12/09 11:28:46 choang noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'AMS_DMExtract_PVT';


--
-- PROCEDURE ExtractMain
-- This is the main driving procedure for the extraction process. It calls all
-- the other procedures as required.
-- Input Params:
-- p_job : May be used if this is scheduled with DBMS_JOBS or Concurrent Mgr
-- p_mode: Parameter specifying whether this is an Insert or an Update process
--         Values: 'I' --> Insert Process
--                 'U' --> Update Process
-- (the following are valid only if p_mode is 'I')
-- p_model_id: Model ID for the data mining model to be built or scored
-- p_model_type: Whether this extraction process is for model building ('MODL')
--               or scoring the model ('SCOR')
--
PROCEDURE ExtractMain (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_job IN VARCHAR2 DEFAULT 'NULL',
   p_mode IN VARCHAR2,
   p_model_id IN NUMBER DEFAULT NULL,
   p_model_type IN VARCHAR2 DEFAULT 'NULL'
);


--
-- Purpose
--    Concurrent program to call extractmain with update
--    as the mode.
--
-- Parameters
--    errbuf - standard concurrent program output
--    retcode - standard concurrent program output
PROCEDURE schedule_update_parties (
   errbuf   OUT NOCOPY VARCHAR2,
   retcode  OUT NOCOPY VARCHAR2
);


END ams_DMExtract_pvt; -- END OF PACKAGE SPEC.

 

/
