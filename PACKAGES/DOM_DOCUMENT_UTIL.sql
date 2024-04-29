--------------------------------------------------------
--  DDL for Package DOM_DOCUMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_DOCUMENT_UTIL" AUTHID CURRENT_USER as
/*$Header: DOMPDUTS.pls 120.6 2006/07/14 22:22:43 mkimizuk noship $ */

G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR         CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'


--
-- Fnd Lookup Type: DOM_PHASE_TYPES
-- Used for Document Lifecycle Phase Type
--
G_PHASE_TYPE_CREATE    CONSTANT NUMBER := 1 ; -- Create
G_PHASE_TYPE_RELEASE   CONSTANT NUMBER := 7 ; -- Release
G_PHASE_TYPE_APPROVAL  CONSTANT NUMBER := 8 ; -- Approval
G_PHASE_TYPE_REVIEW    CONSTANT NUMBER := 12 ; -- Review
G_PHASE_TYPE_ARCHIVE   CONSTANT NUMBER := 40 ; -- Archive


Procedure Change_Doc_LC_Phase
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,p_change_id          IN  NUMBER
  ,p_lc_phase_code      IN  NUMBER
  ,p_action_type        IN  VARCHAR2-- 'PROMOTE' or 'DEMOTE'
  ,p_api_caller         IN  VARCHAR2
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
 );

Procedure Update_Approval_Status
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,p_change_id          IN  NUMBER
  ,p_approval_status    IN  NUMBER
  ,p_wf_route_status    IN  VARCHAR2
  ,p_api_caller         IN  VARCHAR2
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
);


Procedure Start_Doc_LC_Phase_WF
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
  ,p_change_id          IN  NUMBER
  ,p_route_id           IN  NUMBER
  ,p_lc_phase_code      IN  NUMBER := NULL
  ,p_api_caller         IN  VARCHAR2
 );


Procedure Abort_Doc_LC_Phase_WF
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
  ,p_change_id          IN  NUMBER
  ,p_route_id           IN  NUMBER
  ,p_lc_phase_code      IN  NUMBER := NULL
  ,p_api_caller         IN  VARCHAR2
 );



-- -----------------------------------------------------------------------------
--  API Name:       Generate_Seq_For_Doc_Catalog
--  Nisar
--  Description:
--    Generates the Item Sequence For Number Generation or Revision Generation.
-- -----------------------------------------------------------------------------
PROCEDURE Generate_Seq_For_Doc_Category
(
  p_doc_category_id        IN  NUMBER
 ,p_seq_start_num          IN  NUMBER
 ,p_seq_increment_by       IN  NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_errorcode              OUT NOCOPY NUMBER
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
 ,p_num_rev_type           IN VARCHAR2
);

----------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--  API Name:       Drop_Sequence_For_Doc_Category
--  Nisar
--  Description:
--    Generates the Item Sequence For Number Generation
-- -----------------------------------------------------------------------------
PROCEDURE Drop_Sequence_For_Category (
  p_doc_category_seq_name         IN  VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_errorcode                    OUT NOCOPY NUMBER
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------------

FUNCTION GET_DOC_NUM_SCHEME
(   P_CATEGORY_ID            IN  NUMBER
) RETURN VARCHAR2 ;

-- -----------------------------------------------------------------------------
--  API Name:       rowtocol
--  Srinivas Chintamani
--  Description:
--    Generic function to convert rows returned by arbitrary SQL into
--    a list using the passed in seperator character.
-- -----------------------------------------------------------------------------
FUNCTION rowtocol

  ( p_slct  IN VARCHAR2,
    p_dlmtr IN VARCHAR2 DEFAULT ','

  ) RETURN VARCHAR2;

-- -----------------------------------------------------------------------------

END DOM_DOCUMENT_UTIL;

 

/
