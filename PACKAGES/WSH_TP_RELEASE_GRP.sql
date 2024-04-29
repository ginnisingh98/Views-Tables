--------------------------------------------------------
--  DDL for Package WSH_TP_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TP_RELEASE_GRP" AUTHID CURRENT_USER as
/* $Header: WSHTPGPS.pls 115.0 2003/09/05 19:11:38 wrudge noship $ */


-- TP interface records are identified by their INTERFACE_ACTION_CODE
-- having this constant value:
G_TP_RELEASE_CODE CONSTANT VARCHAR2(30) := 'TP_RELEASE';


TYPE id_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE input_rec_type IS RECORD (
        action_code VARCHAR2(30),
        commit_flag VARCHAR2(1)
      );

TYPE output_rec_type IS RECORD (
        text        VARCHAR2(32767)
     );


-- action codes:
G_ACTION_RELEASE CONSTANT VARCHAR2(30) := 'RELEASE';
G_ACTION_PURGE   CONSTANT VARCHAR2(30) := 'PURGE';



--
--  Procedure:   action
--  Parameters:
--               p_id_tab          list of ids to process, depending on action.
--                                   For actions implemented, list of group_id
--                                   identifies the trips in WSH_TRIPS_INTERFACE
--                                   with INTERFACE_ACTION_CODE = 'TP_RELEASE'
--                                   and their related records in other interface tables.
--               p_input_rec       input parameters:
--                                   action_code:
--                                     G_ACTION_RELEASE - release the plan
--                                       if some groups fail, returns warning
--                                       if all fail, returns error
--                                     G_ACTION_PURGE   - purge interface tables
--                                   commit_flag:
--                                     FND_API.G_TRUE  - commit each group
--                                     FND_API.G_FALSE - do not commit
--               p_output_rec_type output parameters:
--                                   placeholder for future
--               x_return_status   return status
--                                   FND_API.G_RET_STS_SUCCESS - success
--                                   'W' - warning (WSH_UTIL_CORE.G_RET_STS_WARNING)
--                                   FND_API.G_RET_STS_ERROR
--                                   FND_API.G_RET_STS_UNEXP_ERROR
--
--  Description:
--    Perform an action relating to TP integration, based on p_input_rec.action_code:
--                  Release Plan
--                  Purge Interface Tables
--
--
PROCEDURE action(
  p_id_tab                 IN            id_tab_type,
  p_input_rec              IN            input_rec_type,
  x_ouput_rec_type         OUT NOCOPY    output_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2);


END WSH_TP_RELEASE_GRP;

 

/
