--------------------------------------------------------
--  DDL for Package AMW_LOAD_SOD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_SOD_DATA" AUTHID CURRENT_USER AS
/* $Header: amwsodws.pls 120.1.12000000.1 2007/01/16 20:41:20 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_LOAD_SOD_DATA
-- Purpose
--          To upload data from SOD interface table to our data after validation
-- History
-- This is to enable to user to insert huge data *3.1 million records.
-- Records will be inserted into the interface table thru SQL Loader.
-- NOTE
-- Ref bug # 5167649
-- End of Comments
-- ===============================================================
PROCEDURE insert_data(
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
   );


PROCEDURE update_interface_with_error (
        p_err_msg        IN   VARCHAR2
        ,p_interface_id   IN   NUMBER
);

-- ===============================================================
-- Procedure name
--          create_constraint_waivers
-- Purpose
-- 		  	import constraint waivers
--          from interface table to AMW_CONSTRAINT_WAIVERS_B and
--          AMW_CONSTRAINT_WAIVERS_TL
-- Notes
--          this procedure is called in Concurrent Executable
-- ===============================================================
PROCEDURE create_constraint_waivers (
    ERRBUF      OUT NOCOPY   VARCHAR2,
    RETCODE     OUT NOCOPY   VARCHAR2,
    p_batch_id         IN  NUMBER := NULL,
    p_del_after_import IN  VARCHAR2 := 'Y'
);


-- ===============================================================
-- Procedure name
--          update_waiver_intf_with_error
-- Purpose
-- 		  	Updates error flag and interface status of
--          amw_cst_waiver_interface interface table
-- ===============================================================
PROCEDURE update_waiver_intf_with_error (
         p_err_msg        IN   VARCHAR2
        ,p_interface_id   IN   NUMBER
);

-- ===============================================================
-- Procedure name
--          cst_table_update_report
-- Purpose
--      Report the issues identified during updating of the following
--      columsn the application_id
--      1. AMW_VIOLAT_USER_ENTRIES.APPLICATION_ID
--      2. AMW_CONSTRAINT_ENTRIES.APPLICATION_ID
--      3. AMW_VIOLAT_RESP_ENTRIES.APPLICATION_ID
--      4. AMW_VIOLAT_USER_ENTRIES.PROGRAM_APPLICATION_ID
--      5. AMW_CONSTRAINT_WAIVERS_B.PK2
-- Notes
--          this procedure is called in Concurrent Executable
-- ===============================================================
PROCEDURE cst_table_update_report  (
    ERRBUF      OUT NOCOPY   VARCHAR2,
    RETCODE     OUT NOCOPY   VARCHAR2
);

END AMW_LOAD_SOD_DATA;

 

/
