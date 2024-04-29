--------------------------------------------------------
--  DDL for Package Body DPP_EXECUTIONPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_EXECUTIONPROCESS_PUB" AS
/* $Header: dpppexcb.pls 120.19.12010000.7 2010/04/21 11:31:59 anbbalas ship $ */

-- Package name     : DPP_EXECUTIONPROCESS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'DPP_EXECUTIONPROCESS_PUB';
  G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
  G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dpppexcb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_ExecutionProcess
--
-- PURPOSE
--    Initiate Execution Process
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE Initiate_ExecutionProcess(errbuff        OUT NOCOPY VARCHAR2,
                                    retcode        OUT NOCOPY VARCHAR2,
                                    p_in_org_id          IN   NUMBER,
                                    p_in_txn_number  IN VARCHAR2
                                   )
IS
L_API_NAME          CONSTANT VARCHAR2(30) := 'Initiate_ExecutionProcess';
l_module            CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_EXECUTIONPROCESS_PUB.Initiate_ExecutionProcess';
  BEGIN

  -- Debug Message
  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'start');

 DPP_EXECUTIONPROCESS_PVT.Initiate_ExecutionProcess(
                                       errbuff,
                                       retcode,
                                       p_in_org_id,
                                       p_in_txn_number
                                       );
  -- Debug Message
  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'end');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       ROLLBACK;
       retcode := '1';
       errbuff := 'No Data Found.....';
         FND_FILE.PUT_LINE(FND_FILE.LOG,'No Data Found.....');
         FND_FILE.NEW_LINE(FND_FILE.LOG);

    WHEN OTHERS THEN
       ROLLBACK;
       retcode := '1';
       errbuff := 'When Others Exception'||SQLERRM;
         FND_FILE.PUT_LINE(FND_FILE.LOG,'When Others Exception'||SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
  END Initiate_ExecutionProcess;

END DPP_EXECUTIONPROCESS_PUB;

/
