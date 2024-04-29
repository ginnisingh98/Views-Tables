--------------------------------------------------------
--  DDL for Package EGO_ITEM_AML_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_AML_GRP" AUTHID CURRENT_USER AS
/* $Header: EGOGAMLS.pls 120.0 2005/06/28 01:57:34 srajapar noship $ */

---------------------------------------------------------------------------
-- Start of comments
-- API name  : Populate_Intf_With_Proddata
-- Type      : Public
-- Pre-reqs  : None
-- FUNCTION  : To populate the interface with the production data
--
-- Parameters:
--     IN    :
--        p_api_version           IN   NUMBER
--              The version of the API being called
--
--        p_commit                IN   VARCHAR2
--              Determines whether to commit the data or not
--              FND_API.G_TRUE allows you to commit data
--              on all other values, the data is not committed.
--
--        p_data_set_id           IN   NUMBER --  mandatory parameter
--              The job number
--
--        p_pf_to_process         IN   NUMBER --  mandatory parameter
--              Determines which lines need to populated with production data
--
--        p_pf_after_population   IN  NUMBER
--              Determines the process flag of the lines that were modified
--
--     OUT    :
--             x_return_status          OUT NOCOPY VARCHAR2
--             x_msg_count              OUT NOCOPY NUMBER
--             x_msg_data               OUT NOCOPY VARCHAR2
--
--  Version:		Current version 1.0
-- ----------------------------------------------------------------------

Procedure Populate_Intf_With_Proddata (
    p_api_version            IN  NUMBER
   ,p_commit                 IN  VARCHAR2
   ,p_data_set_id            IN  NUMBER
   ,p_pf_to_process          IN  NUMBER
   ,p_pf_after_population    IN  NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   );

END EGO_ITEM_AML_GRP;


 

/
