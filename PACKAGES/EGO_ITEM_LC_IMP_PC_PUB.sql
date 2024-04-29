--------------------------------------------------------
--  DDL for Package EGO_ITEM_LC_IMP_PC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_LC_IMP_PC_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOCIPSS.pls 120.0 2005/05/26 22:11:23 appldev noship $ */

FUNCTION get_master_controlled_status
RETURN VARCHAR2;

FUNCTION get_master_org_status (p_organization_id  IN  NUMBER)
RETURN VARCHAR2;

FUNCTION get_revision_id (p_inventory_item_id  IN  NUMBER
                         ,p_organization_id    IN  NUMBER
                         ,p_revision           IN  VARCHAR2)
RETURN NUMBER;

-- commented for 3637854
/***
PROCEDURE Check_Pending_Change_Orders
(
   p_inventory_item_id   IN  NUMBER
  ,p_organization_id     IN  NUMBER
  ,p_revision_id         IN  NUMBER
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_msg_data            OUT  NOCOPY VARCHAR2
);
***/

-- 4052565 added parameter perform_security_check
PROCEDURE Create_Pending_Phase_Change
(
  p_api_version                     IN   NUMBER
 ,p_commit                          IN   VARCHAR2
 ,p_inventory_item_id               IN   NUMBER
 ,p_item_number                     IN   VARCHAR2  DEFAULT NULL
 ,p_organization_id                 IN   NUMBER
 ,p_effective_date                  IN   DATE
 ,p_pending_flag                    IN   VARCHAR2
 ,p_revision                        IN   VARCHAR2
 ,p_revision_id                     IN   NUMBER    DEFAULT NULL
 ,p_lifecycle_id                    IN   NUMBER
 ,p_phase_id                        IN   NUMBER
 ,p_status_code                     IN   VARCHAR2  DEFAULT NULL
 ,p_change_id                       IN   NUMBER
 ,p_change_line_id                  IN   NUMBER
 ,p_perform_security_check          IN   VARCHAR2  DEFAULT 'F'
 ,x_return_status                   OUT  NOCOPY VARCHAR2
 ,x_errorcode                       OUT  NOCOPY NUMBER
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 );

-- 4052565 added parameter perform_security_check
PROCEDURE Modify_Pending_Phase_Change
  (p_api_version                    IN   NUMBER
  ,p_commit                         IN   VARCHAR2
  ,p_transaction_type               IN   VARCHAR2
  ,p_inventory_item_id              IN   NUMBER
  ,p_organization_id                IN   NUMBER
  ,p_revision_id                    IN   NUMBER
  ,p_lifecycle_id                   IN   NUMBER
  ,p_phase_id                       IN   NUMBER
  ,p_status_code                    IN   VARCHAR2
  ,p_change_id                      IN   NUMBER
  ,p_change_line_id                 IN   NUMBER
  ,p_effective_date                 IN   DATE
  ,p_new_effective_date             IN   DATE
  ,p_perform_security_check         IN   VARCHAR2
  ,x_return_status                  OUT  NOCOPY VARCHAR2
  ,x_errorcode                      OUT  NOCOPY NUMBER
  ,x_msg_count                      OUT  NOCOPY NUMBER
  ,x_msg_data                       OUT  NOCOPY VARCHAR2
  );

/***
PROCEDURE Delete_Pending_Phase_Change
(
  p_api_version                     IN   NUMBER
 ,p_commit                          IN   VARCHAR2
 ,p_inventory_item_id               IN   NUMBER
 ,p_organization_id                 IN   NUMBER
 ,p_change_id                       IN   NUMBER
 ,p_change_line_id                  IN   NUMBER
 ,x_return_status                   OUT  NOCOPY VARCHAR2
 ,x_errorcode                       OUT  NOCOPY NUMBER
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 );
***/

PROCEDURE Implement_Pending_Changes_CP
(
     ERRBUF                        OUT  NOCOPY VARCHAR2
   , RETCODE                       OUT  NOCOPY NUMBER
   , p_organization_id             IN   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE
   , p_inventory_item_id           IN   MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE
   , p_revision_code               IN   MTL_ITEM_REVISIONS_B.REVISION%TYPE
);

--
-- Created as a part of fix for 3371749
--
-- 4052565 added parameter perform_security_check
PROCEDURE Implement_Pending_Changes
(
     p_api_version                 IN   NUMBER
   , p_commit                      IN   VARCHAR2
   , p_change_id                   IN   NUMBER
   , p_change_line_id              IN   NUMBER
   , p_perform_security_check      IN   VARCHAR2  DEFAULT 'F'
   , x_return_status               OUT  NOCOPY VARCHAR2
   , x_errorcode                   OUT  NOCOPY NUMBER
   , x_msg_count                   OUT  NOCOPY NUMBER
   , x_msg_data                    OUT  NOCOPY VARCHAR2
);

-- 4052565 added parameter perform_security_check
PROCEDURE Implement_Pending_Changes
(
     p_api_version                 IN   NUMBER
   , p_inventory_item_id           IN   NUMBER
   , p_organization_id             IN   NUMBER
   , p_revision_id                 IN   NUMBER
   , p_revision_master_controlled  IN   VARCHAR2
   , p_status_master_controlled    IN   VARCHAR2
   , p_is_master_org               IN   VARCHAR2
   , p_perform_security_check      IN   VARCHAR2  DEFAULT 'F'
   , x_return_status               OUT  NOCOPY VARCHAR2
   , x_errorcode                   OUT  NOCOPY NUMBER
   , x_msg_count                   OUT  NOCOPY NUMBER
   , x_msg_data                    OUT  NOCOPY VARCHAR2
);

END EGO_ITEM_LC_IMP_PC_PUB;

 

/
