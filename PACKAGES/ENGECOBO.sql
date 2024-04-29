--------------------------------------------------------
--  DDL for Package ENGECOBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENGECOBO" AUTHID CURRENT_USER AS
/* $Header: ENGECOBS.pls 120.2 2005/10/24 05:44:48 lkasturi noship $ */

---------------------------------------------------------------
--  Global constants                                         --
---------------------------------------------------------------
GLOBAL_CHANGE_ID NUMBER := -1;
GLOBAL_ORG_ID NUMBER := -1;

---------------------------------------------------------------
--  Public Procedures                                        --
---------------------------------------------------------------


-- ****************************************************************** --
--  API name    : Propagate_ECO                                       --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_change_notice            VARCHAR2   Required      --
--                p_org_hierarchy_name       varchar2                 --
--                p_org_hierarchy_level      VARCHAR2                 --
--                p_local_organization_id    NUMBER := NULL           --
--                p_calling_api              NUMBER := NULL           --
--       OUT    : retcode                    VARCHAR2(1)              --
--                error_buf                  VARCHAR2(30)             --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                     --
--                if org hierarchy id is -1 then the list of orgs     --
--                associated to the change are picked for propagation --
--                if p_org_hierarchy_id is null, check that the value --
--                local_organization_id has been specified            --
--                Validate that the local organization id either      --
--                belongs to the hierarchy or to the list of local    --
--                 orgs of thesource change order                     --
--                 p_calling API is TTM then the change header        --
--                 relation is checked first 'TRANSFERRED_TO'         --
-- ****************************************************************** --
PROCEDURE PROPAGATE_ECO
(
  errbuf                 OUT  NOCOPY  VARCHAR2,
  retcode                OUT  NOCOPY  VARCHAR2,
  p_change_notice        IN     VARCHAR2,
  p_org_hierarchy_name   IN     VARCHAR2,
  p_org_hierarchy_level  IN     VARCHAR2,
  p_local_organization_id IN    NUMBER := NULL   -- R12
, p_calling_API           IN    VARCHAR2 := NULL --R12
);

-- ****************************************************************** --
--  API name    : Propagate_ECO                                       --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_inventory_item_id       NUMBER      Required      --
--                p_local_organization_id    NUMBER                   --
--       OUT    : x_return_status            VARCHAR2(1)              --
--                                                                    --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                     --
-- ****************************************************************** --

PROCEDURE Auto_Enable_Item (
    p_api_version           IN NUMBER
  , p_init_msg_list         IN VARCHAR2
  , p_commit                IN VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
  , p_inventory_item_id     IN NUMBER
  , p_local_organization_id IN NUMBER
);
-- ****************************************************************** --
--  API name    : PreProcess_Propagate_Request                        --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Procedure   : Adds a row into the Propagation maps table          --
--  Parameters  :                                                     --
--       IN     :  p_api_version               IN   NUMBER            --
--                   p_init_msg_list             IN   VARCHAR2        --
--                   p_commit                    IN   VARCHAR2        --
--                   p_request_id                IN   NUMBER          --
--                   p_change_id                 IN   VARCHAR2        --
--                   p_org_hierarchy_name        IN   VARCHAR2        --
--                   p_local_organization_id     IN   NUMBER          --
--                   p_calling_API               IN   VARCHAR2        --
--                                                                    --
--       OUT    : x_msg_count                 OUT NOCOPY  NUMBER      --
--                x_msg_data                  OUT NOCOPY  VARCHAR2    --
--                x_return_status                    VARCHAR2(1)      --
--                                                                    --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                     --
-- ****************************************************************** --
PROCEDURE PreProcess_Propagate_Request (
   p_api_version               IN   NUMBER                             --
 , p_init_msg_list             IN   VARCHAR2                           --
 , p_commit                    IN   VARCHAR2                           --
 , p_request_id                IN   NUMBER
 , p_change_id                 IN   VARCHAR2
 , p_org_hierarchy_name        IN   VARCHAR2
 , p_local_organization_id     IN   NUMBER
 , p_calling_API               IN   VARCHAR2
 , x_return_status             OUT NOCOPY  VARCHAR2                    --
 , x_msg_count                 OUT NOCOPY  NUMBER                      --
 , x_msg_data                  OUT NOCOPY  VARCHAR2                    --
);

END ENGECOBO;


 

/
