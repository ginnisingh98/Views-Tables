--------------------------------------------------------
--  DDL for Package AHL_FMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVFMPS.pls 120.3.12010000.3 2009/04/30 20:52:00 sikumar ship $ */

-- Define Record Type for Affected Item Instance Record --
TYPE MR_ITEM_INSTANCE_REC_TYPE IS RECORD (
  ITEM_NUMBER             VARCHAR2(40),
  SERIAL_NUMBER           VARCHAR2(30),
  LOCATION                VARCHAR2(4000),
  STATUS                  VARCHAR2(80),
  OWNER                   VARCHAR2(360),
  CONDITION               VARCHAR2(240),
  UNIT_NAME               VARCHAR2(80),
  ITEM_INSTANCE_ID        NUMBER,
  INVENTORY_ITEM_ID       NUMBER,
  MR_EFFECTIVITY_ID       NUMBER,
  UC_HEADER_ID            NUMBER
);

-- Define Table Type for Affected Item Instances --
TYPE MR_ITEM_INSTANCE_TBL_TYPE IS TABLE OF MR_ITEM_INSTANCE_REC_TYPE INDEX BY BINARY_INTEGER;

-- Define Record Type for Applicable MR Record --
TYPE APPLICABLE_MR_REC_TYPE IS RECORD (
  MR_HEADER_ID            NUMBER,
  MR_EFFECTIVITY_ID       NUMBER,
  ITEM_INSTANCE_ID        NUMBER,
--  PARENT_ITEM_INSTANCE_ID NUMBER,  --may be deleted
  REPETITIVE_FLAG         VARCHAR2(1),
  SHOW_REPETITIVE_CODE    VARCHAR2(4),
  PRECEDING_MR_HEADER_ID  NUMBER,
  COPY_ACCOMPLISHMENT_FLAG VARCHAR2(1),
  IMPLEMENT_STATUS_CODE   VARCHAR2(30),
  DESCENDENT_COUNT        NUMBER
);

-- Define Table Type for Applicable MRs --
TYPE APPLICABLE_MR_TBL_TYPE IS TABLE OF APPLICABLE_MR_REC_TYPE INDEX BY BINARY_INTEGER;

-- Define Record Type for Applicable Activities for PM --
TYPE APPLICABLE_ACTIVITIES_REC_TYPE IS RECORD
(
  MR_HEADER_ID                  NUMBER,
  PROGRAM_MR_HEADER_ID          NUMBER,
  SERVICE_LINE_ID               NUMBER,
  MR_EFFECTIVITY_ID             NUMBER,
  ITEM_INSTANCE_ID              NUMBER,
  REPETITIVE_FLAG               VARCHAR2(1),
  WHICHEVER_FIRST_CODE          VARCHAR2(30),
  SHOW_REPETITIVE_CODE          VARCHAR2(4),
  IMPLEMENT_STATUS_CODE         VARCHAR2(30),
  ACT_SCHEDULE_EXISTS           VARCHAR2(1)
);

-- Define Table Type for Applicable Activities for PM --
TYPE APPLICABLE_ACTIVITIES_TBL_TYPE IS TABLE OF APPLICABLE_ACTIVITIES_REC_TYPE
  INDEX BY BINARY_INTEGER;

-- Define Record Type for Applicable Programs for PM --
-- R12: replaced okc_k_headers_b with okc_k_headers_all_b for MOAC (ref bug# 4337173).
TYPE applicable_programs_rec_type IS RECORD
(
  contract_id               NUMBER,
  contract_number           OKC_K_HEADERS_ALL_B.contract_number%TYPE,
  contract_number_modifier  OKC_K_HEADERS_ALL_B.contract_number_modifier%TYPE,
  sts_code                  OKC_K_HEADERS_ALL_B.sts_code%TYPE,
  service_line_id           NUMBER,
  service_name              VARCHAR2(300),  --OKX_SYSTEM_ITEMS_V.NAME%TYPE
  service_description       VARCHAR2(300),  --OKX_SYSTEM_ITEMS_V.DESCRIPTION%TYPE
  coverage_term_line_id     NUMBER,
  coverage_term_name        OKC_K_LINES_V.name%TYPE,
  coverage_term_description OKC_K_LINES_V.item_description%TYPE,
  coverage_type_code        Oks_Cov_Types_B.code%TYPE,
  coverage_type_meaning     Oks_Cov_Types_TL.meaning%TYPE,
  coverage_type_imp_level   Oks_Cov_Types_B.importance_level%TYPE,
  service_start_date        DATE,
  service_end_date          DATE,
  warranty_flag             VARCHAR2(1),
  eligible_for_entitlement  VARCHAR2(1),
  exp_reaction_time         DATE,
  exp_resolution_time       DATE,
  status_code               VARCHAR2(1),
  status_text               VARCHAR2(1995),
  date_terminated           DATE,
  pm_program_id             VARCHAR2(40),
  pm_schedule_exists        VARCHAR2(450),
  mr_effectivity_id         NUMBER
);

TYPE applicable_programs_tbl_type IS TABLE OF applicable_programs_rec_type
  INDEX BY BINARY_INTEGER;

-- Define Procedure GET_MR_AFFECTED_ITEMS --
PROCEDURE GET_MR_AFFECTED_ITEMS (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_mr_header_id          IN  NUMBER,
  p_mr_effectivity_id     IN  NUMBER    := NULL,
  p_top_node_flag         IN  VARCHAR2  := 'N',
  p_unique_inst_flag      IN  VARCHAR2  := 'N',
  p_sort_flag             IN  VARCHAR2  := 'N',
  x_mr_item_inst_tbl      OUT NOCOPY MR_ITEM_INSTANCE_TBL_TYPE
);
--  Start of Comments  --
--
--  Procedure name  : GET_MR_AFFECTED_ITEMS
--  Type        	: Public
--  Function    	: Get all of the affected item instances for a given MR_id.
--  Pre-reqs    	:
--
--  GET_MR_AFFECTED_ITEMS Parameters :
--  p_mr_id                 IN  NUMBER     Required
--                          Primary key of table AHL_MR_HEADERS_B
--  p_mr_effectivity_id     IN  NUMBER     Required
--                          Primary key of table AHL_MR_EFFECTIVITIES
--  p_top_node_flag         IN  VARCHAR2   Required
--                          If 'Y' only return top node item instances, else
--                          return all matching ones
--  p_unique_inst_flag      IN  VARCHAR2   Required
--                          If 'Y' only return unique item instances, else
--                          return all matching ones
--  x_mr_item_inst_tbl      OUT NOCOPY MR_ITEM_INSTANCE_TBL_TYPE   Required
--                          Stores the returned item instance ID and its other
--                          attributes
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

-- Declare Procedures GET_APPLICABLE_MRS --
PROCEDURE GET_APPLICABLE_MRS (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_item_instance_id      IN  NUMBER,
  p_mr_header_id          IN  NUMBER    := NULL,
  p_components_flag       IN  VARCHAR2  := 'Y',
  p_include_doNotImplmt   IN  VARCHAR2  := 'Y',
  p_visit_type_code       IN VARCHAR2   := NULL,
  x_applicable_mr_tbl     OUT NOCOPY APPLICABLE_MR_TBL_TYPE
);
--  Start of Comments  --
--
--  Procedure name  : GET_APPLICABLE_MRS
--  Type        	: Public
--  Function    	: Get all of its applicable Maintenance Requirements for
--                    a given item_instance_id.
--  Pre-reqs    	:
--
--  GET_APPLICABLE_MRS Parameters :
--  p_item_instance_id      IN  NUMBER   Required
--                          Item Instance ID
--  p_components_flag       IN  VARCHAR2   Required
--                          If 'Y' also return the applicable MRs of all its
--                          child item instances as well
--  x_applicable_mr_tbl     OUT NOCOPY APPLICABLE_MR_TBL_TYPE   Required
--                          Stores the returned MR ID and its other
--                          attributes
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

-- Declare FUNCTION COUNT_MR_DESCENDENTS --
FUNCTION count_mr_descendents(
  p_mr_header_id               NUMBER
) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (count_mr_descendents, WNDS);
--  Start of Comments  --
--
--  Function name   : COUNT_MR_DESCENDENTS
--  Type        	: Public
--  Function    	: Get the number of all the given MR's descendents. This
--                    function is used in the column list of a select statement.
--                    and that is why it appears in this specification.
--  Pre-reqs    	:
--  Parameters      :
--  p_mr_header_id      IN  NUMBER   Required
--                      MR Header ID
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --

FUNCTION Instance_Matches_Path_Pos(
p_instance_id      IN NUMBER,
p_path_position_id IN NUMBER
) RETURN VARCHAR2;

-- Declare Procedures GET_PM_APPLICABLE_MRS --
PROCEDURE GET_PM_APPLICABLE_MRS (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_item_instance_id      IN  NUMBER,
  x_applicable_activities_tbl   OUT NOCOPY applicable_activities_tbl_type,
  x_applicable_programs_tbl     OUT NOCOPY applicable_programs_tbl_type
);
--  Start of Comments  --
--
--  Procedure name  : GET_PM_APPLICABLE_MRS
--  Type        	: Public
--  Function    	: Get all of its applicable Maintenance Requirements for
--                    a given item_instance_id.
--  Pre-reqs    	:
--
--  GET_APPLICABLE_MRS Parameters :
--  p_item_instance_id      IN  NUMBER   Required
--                          Item Instance ID
--  p_components_flag       IN  VARCHAR2   Required
--                          If 'Y' also return the applicable MRs of all its
--                          child item instances as well
--  x_applicable_programs_tbl     OUT NOCOPY APPLICABLE_MR_TBL_TYPE   Required
--                          Stores the returned MR ID (programs) and its other
--                          attributes
--  x_applicable_activities_tbl   OUT NOCOPY APPLICABLE_MR_TBL_TYPE   Required
--                          Stores the returned MR ID (activities)and its other
--                          attributes
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --


-- Declare Procedures GET_VISIT_APPLICABLE_MRS --
PROCEDURE get_visit_applicable_mrs (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_item_instance_id      IN  NUMBER,
  p_visit_type_code       IN  VARCHAR2
);
--  Start of Comments  --
--
--  Procedure name  : GET_VISIT_APPLICABLE_MRS
--  Type        	: Public
--  Function    	: Get all of its applicable Maintenance Requirements for
--                    a given item_instance_id.
--   returns all the op mr's satisfying p_visit_type_code in temp table AHL_APPLICABLE_RELNS
--  Pre-reqs    	:
--
--  GET_APPLICABLE_MRS Parameters :
--  p_item_instance_id      IN  NUMBER   Required
--                          Item Instance ID
--  x_applicable_mr_tbl     OUT NOCOPY APPLICABLE_MR_TBL_TYPE   Required
--                          Stores the returned MR ID and its other
--                          attributes
--  Version :
--  	Initial Version   1.0
--
--  End of Comments  --
--
-- Declare Procedures GET_VISIT+APPLICABLE_MRS --

FUNCTION is_pc_assoc_valid(p_item_instance_id  IN  NUMBER,p_pc_node_id IN NUMBER) RETURN VARCHAR2;

END AHL_FMP_PVT; -- Package spec

/
