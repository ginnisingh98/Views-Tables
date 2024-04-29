--------------------------------------------------------
--  DDL for Package CS_KNOWLEDGE_AUDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KNOWLEDGE_AUDIT_PVT" AUTHID CURRENT_USER AS
/* $Header: cskbaps.pls 120.1.12010000.2 2009/10/21 12:47:12 amganapa ship $ */

  /* for RETURN status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

  /* for cs_kb_set_eles.assoc_degree  */
  POSITIVE_ASSOC  	CONSTANT NUMBER      := 1;
  NEGATIVE_ASSOC  	CONSTANT NUMBER      := -1;

  /* DEFAULT increment for count */
  COUNT_INCR  	CONSTANT NUMBER      := 1;
  COUNT_INIT  	CONSTANT NUMBER      := 1;

  G_TRUE    CONSTANT VARCHAR2(1)  := FND_API.G_TRUE;
  G_FALSE   CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;

VALIDATION_ERROR		  EXCEPTION;
INVALID_FLOW                      EXCEPTION;
INVALID_SET_NUMBER                EXCEPTION;
INVALID_SET_TYPE_NAME             EXCEPTION;
INVALID_ELEMENT_TYPE_NAME         EXCEPTION;
INVALID_ELEMENT_TYPE              EXCEPTION;
INVALID_SET_ELEMENT_TYPE_MAP      EXCEPTION;
INVALID_VISIBILITY_LEVEL          EXCEPTION;
INVALID_ACCESS_LEVEL              EXCEPTION;
INVALID_PRODUCT_NAME              EXCEPTION;
INVALID_PRODUCT_SEGMENT           EXCEPTION;
INVALID_PLATFORM_NAME             EXCEPTION;
INVALID_PLATFORM_SEGMENT          EXCEPTION;
INVALID_CATEGORY_NAME             EXCEPTION;
INVALID_ELEMENT_CONTENT_TYPE      EXCEPTION;
INVALID_ELEMENT_NUMBER            EXCEPTION;
DUPLICATE_ELEMENT_NAME            EXCEPTION;
DUPLICATE_SET_NAME                EXCEPTION;
PRODUCT_LINK_ERROR                EXCEPTION;
PLATFORM_LINK_ERROR               EXCEPTION;
CATEGORY_LINK_ERROR               EXCEPTION;
SET_ELEMENT_LINK_ERROR            EXCEPTION;
MANDATORY_STATEMENT_MISSING       EXCEPTION;
MANDATORY_CATEGORY_MISSING        EXCEPTION;

--klou (SRCHEFF)
INVALID_USAGE_TIME_SPAN_ERROR     EXCEPTION;
INVALID_COEFFICIENT_FACTOR        EXCEPTION;

FUNCTION Is_Element_Updatable
(
  p_element_number IN  VARCHAR2,
  p_set_number     IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Missing_Ele_Type
(
  p_set_id                 IN  NUMBER--,
)
RETURN VARCHAR2;

FUNCTION Decrypt
(
  KEY       IN VARCHAR2,
  VALUE     IN VARCHAR2
)
RETURN VARCHAR2;


PROCEDURE Get_Who
(
  x_sysdate  OUT NOCOPY DATE,
  x_user_id  OUT NOCOPY NUMBER,
  x_login_id OUT NOCOPY NUMBER
);

FUNCTION Is_Set_Ele_Type_Valid
(
  p_set_number IN VARCHAR2 := NULL,
  p_set_type_id IN NUMBER :=NULL,
  p_element_number IN VARCHAR2 := NULL,
  p_ele_type_id IN NUMBER :=NULL
) RETURN VARCHAR2;

FUNCTION Del_Element_From_Set
(
  p_element_id IN NUMBER,
  p_set_id IN NUMBER
) RETURN NUMBER;

FUNCTION Add_Element_To_Set
(
  p_element_number IN VARCHAR2,
  p_set_id IN NUMBER,
  p_assoc_degree IN NUMBER := CS_KNOWLEDGE_PUB.G_POSITIVE_ASSOC
) RETURN NUMBER;

FUNCTION Create_Element_And_Link_To_Set
(
  p_element_type_id  IN NUMBER,
  p_desc IN VARCHAR2,
  p_name IN VARCHAR2,
  p_status IN VARCHAR2 DEFAULT NULL,
  p_access_level IN NUMBER DEFAULT NULL,
  p_attribute_category IN VARCHAR2 DEFAULT NULL,
  p_attribute1 IN VARCHAR2 DEFAULT NULL,
  p_attribute2 IN VARCHAR2 DEFAULT NULL,
  p_attribute3 IN VARCHAR2 DEFAULT NULL,
  p_attribute4 IN VARCHAR2 DEFAULT NULL,
  p_attribute5 IN VARCHAR2 DEFAULT NULL,
  p_attribute6 IN VARCHAR2 DEFAULT NULL,
  p_attribute7 IN VARCHAR2 DEFAULT NULL,
  p_attribute8 IN VARCHAR2 DEFAULT NULL,
  p_attribute9 IN VARCHAR2 DEFAULT NULL,
  p_attribute10 IN VARCHAR2 DEFAULT NULL,
  p_attribute11 IN VARCHAR2 DEFAULT NULL,
  p_attribute12 IN VARCHAR2 DEFAULT NULL,
  p_attribute13 IN VARCHAR2 DEFAULT NULL,
  p_attribute14 IN VARCHAR2 DEFAULT NULL,
  p_attribute15 IN VARCHAR2 DEFAULT NULL,
  p_set_id IN NUMBER,
  p_assoc_degree IN NUMBER := CS_Knowledge_PUB.G_POSITIVE_ASSOC,
  p_locked_by IN NUMBER DEFAULT NULL,
  p_start_active_date IN DATE DEFAULT NULL,
  p_end_active_date IN DATE DEFAULT NULL,
  p_content_type IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

-- Sort elements IN a solution
-- based on the element_type_order defined IN cs.cs_kb_set_ele_types
FUNCTION Sort_Element_Order(p_set_number IN VARCHAR2)
RETURN NUMBER;

PROCEDURE Auto_Obsolete_Draft_Stmts(p_set_number  IN VARCHAR2,
                                    p_max_set_id  IN NUMBER);

PROCEDURE Auto_Obsolete_For_Solution_Pub(p_set_number  IN VARCHAR2,
                                             p_max_set_id  IN NUMBER);

PROCEDURE Auto_Obsolete_For_Solution_Obs(p_set_number  IN VARCHAR2,
                                              p_max_set_id  IN NUMBER);

FUNCTION Is_Pub_Element_Obsoletable(p_element_id IN NUMBER) RETURN NUMBER;

PROCEDURE Obs_Elmt_Status_With_Check(p_element_id IN NUMBER);

PROCEDURE Transfer_Note_To_Element(p_note_id IN NUMBER, p_element_id IN NUMBER);

FUNCTION Get_Concatenated_Elmt_Details(p_set_id IN NUMBER) RETURN CLOB;

FUNCTION Create_Set_With_Validation
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_flow_name	 in VARCHAR2 DEFAULT NULL,
  p_set_flow_stepcode	 in VARCHAR2 DEFAULT NULL,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl              in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_number           OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION Update_Set_With_Validation
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_number           in  varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl          in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_id               OUT NOCOPY number) RETURN NUMBER;

FUNCTION Validate_Set_Type_Name_Create
(
  p_set_type_name IN  VARCHAR2,
  x_set_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Validate_Set_Type_Name_Update
(
  p_set_id        IN  NUMBER,
  p_set_type_name IN  VARCHAR2,
  x_set_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Validate_Flow
(
  p_flow_name 	IN  VARCHAR2,
  p_flow_step	IN  VARCHAR2,
  x_flow_details_id OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Validate_Set_Number
(
  p_set_number IN varchar2,
  x_set_id OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Validate_Element_Type_Name
(
  p_Element_type_name IN  VARCHAR2,
  x_element_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Resolve_Element_Type_ID
(
  p_Element_number    IN  VARCHAR2,
  x_element_type_id   OUT NOCOPY NUMBER
  ) RETURN NUMBER;

FUNCTION Validate_Set_Element_Type_Ids
(
  p_set_type_id       IN  NUMBER,
  p_element_type_ids  IN JTF_NUMBER_TABLE

) RETURN NUMBER;

FUNCTION VALIDATE_VISIBILITY_LEVEL
(
  p_visibility_name   IN  VARCHAR2,
  x_visibility_id     OUT NOCOPY NUMBER
) RETURN VARCHAR2;

FUNCTION VALIDATE_ACCESS_LEVEL
(
  p_access_level_name   IN  VARCHAR2,
  x_access_level_value  OUT NOCOPY VARCHAR2
) RETURN NUMBER;

FUNCTION VALIDATE_ELEMENT_NO
(
  p_ele_no    IN  VARCHAR2,
  x_latest_id OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION VALIDATE_ELEMENT_CONTENT_TYPE
(
  p_ele_content_type    IN  VARCHAR2,
  p_ele_content_type_code OUT NOCOPY VARCHAR2
) RETURN NUMBER;

FUNCTION VALIDATE_PRODUCT_NAME
(
  p_name   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION VALIDATE_PRODUCT_SEGMENT
(
  p_segment   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION VALIDATE_PLATFORM_NAME
(
  p_name   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION VALIDATE_PLATFORM_SEGMENT
(
  p_segment   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION VALIDATE_CATEGORY_NAME
(
  p_name   IN  VARCHAR2,
  p_last_name IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION VALIDATE_SOLN_ATTRIBUTES
(
  p_set_type_id       IN  NUMBER,
  p_visibility_name IN  VARCHAR2,
  p_product_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_last_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_nums          IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_nums	IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_dist_names     IN JTF_VARCHAR2_TABLE_2000,
  p_element_type_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_names  IN JTF_VARCHAR2_TABLE_2000,
  x_visibility_id      OUT NOCOPY NUMBER,
  x_product_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_platform_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_category_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids		  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_ids	 OUT NOCOPY JTF_NUMBER_TABLE,
  x_element_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2
) RETURN NUMBER;

FUNCTION Link_Soln_Attributes
(
  p_validate_type     IN VARCHAR2,
  p_set_id		IN NUMBER,
  p_given_element_ids	IN JTF_NUMBER_TABLE,
  p_given_ele_nums	in  JTF_VARCHAR2_TABLE_2000,
  p_given_ele_type_ids  in  JTF_NUMBER_TABLE,
  p_given_ele_dist_ids	in  JTF_VARCHAR2_TABLE_2000,
  p_given_ele_content_types in  JTF_VARCHAR2_TABLE_2000,
  p_given_ele_summaryies in  JTF_VARCHAR2_TABLE_2000,
  p_element_ids   IN JTF_NUMBER_TABLE,
  p_element_type_ids	IN JTF_NUMBER_TABLE,
  p_element_dist_ids	IN JTF_VARCHAR2_TABLE_2000,
  p_element_content_types IN JTF_VARCHAR2_TABLE_2000,
  p_element_summaries	IN JTF_VARCHAR2_TABLE_2000,
  p_element_dummy_detail IN CLOB,
  p_set_product_ids     IN JTF_NUMBER_TABLE,
  p_set_platform_ids	IN JTF_NUMBER_TABLE,
  p_set_category_ids	IN JTF_NUMBER_TABLE,
  x_created_element_ids OUT NOCOPY JTF_NUMBER_TABLE,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2
) RETURN NUMBER;


FUNCTION Get_Category_Name
(
  p_category_name  IN  varchar2
) RETURN VARCHAR2;

FUNCTION Encode_Text(p_text IN VARCHAR2) RETURN VARCHAR2 ;

PROCEDURE WRITE_CLOB_TO_FILE
(
  p_clob  IN CLOB,
  p_file  IN NUMBER
);

PROCEDURE EXPORT_SOLUTIONS
(
  errbuf           OUT NOCOPY VARCHAR2,
  retcode          OUT NOCOPY NUMBER,
  p_category_name  IN  VARCHAR2,
  p_sol_status     IN  VARCHAR2
);

PROCEDURE GET_USER_ACCESS_LEVEL(
                                p_user_name      IN VARCHAR2,
                                x_access_level   OUT NOCOPY NUMBER);

FUNCTION GET_USER_NAME (V_USER_ID NUMBER)
RETURN VARCHAR2;

-- (SRCHEFF)
PROCEDURE Update_Solution_Usage_Score(
    p_commit              IN   VARCHAR2     := FND_API.G_FALSE);

FUNCTION VALIDATE_SOLN_ATTRIBUTES_2
(
  p_set_type_id       IN  NUMBER,
  p_visibility_name IN  VARCHAR2,
  p_product_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_last_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_nums          IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_nums        IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_dist_names     IN JTF_VARCHAR2_TABLE_2000,
  p_element_type_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_names  IN JTF_VARCHAR2_TABLE_2000,
  x_visibility_id      OUT NOCOPY NUMBER,
  x_product_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_platform_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_category_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids           OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_element_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2,
  p_delim                  IN VARCHAR2

) RETURN NUMBER;

FUNCTION VALIDATE_SOLN_ATTRIBUTES_3
(
  p_set_type_id       IN  NUMBER,
  p_visibility_name IN  VARCHAR2,
  p_product_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_product_segments   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_segments   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_last_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_nums          IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_nums        IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_dist_names     IN JTF_VARCHAR2_TABLE_2000,
  p_element_type_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_names  IN JTF_VARCHAR2_TABLE_2000,
  x_visibility_id      OUT NOCOPY NUMBER,
  x_product_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_platform_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_category_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids           OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_element_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2,
  p_delim                  IN VARCHAR2

) RETURN NUMBER;

FUNCTION Create_Set_With_Validation_2
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_flow_name        in VARCHAR2,
  p_set_flow_stepcode    in VARCHAR2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl              in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl	 in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_number           OUT NOCOPY VARCHAR2,
  p_delim                  IN VARCHAR2
  ) RETURN NUMBER;

FUNCTION Create_Set_With_Validation_3
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_flow_name        in VARCHAR2,
  p_set_flow_stepcode    in VARCHAR2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_product_segments    in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_platform_segments   in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl              in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl	 in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_number           OUT NOCOPY VARCHAR2,
  p_delim                  IN VARCHAR2
  ) RETURN NUMBER;


PROCEDURE EXPORT_SOLUTIONS_2
(
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY NUMBER,
  p_category_name  IN  VARCHAR2,
  p_sol_status     IN  VARCHAR2,
  p_delim IN VARCHAR2
);

FUNCTION Get_Category_Full_Name
(
  p_catid  IN  NUMBER,
  p_delim IN VARCHAR2,
  p_verify IN BOOLEAN DEFAULT FALSE
--  full_cat_name OUT VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Category_Name_2
(
  p_category_name  IN  varchar2,
  p_delim IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Update_Set_With_Validation_2
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_number           in  varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl          in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_id               OUT NOCOPY number,
  p_delim                  IN VARCHAR2
) RETURN NUMBER;

FUNCTION Update_Set_With_Validation_3
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_number           in  varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_product_segments         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_platform_segments        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl          in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_id               OUT NOCOPY number,
  p_delim                  IN VARCHAR2
) RETURN NUMBER;

FUNCTION VALIDATE_CATEGORY_NAME_2
(
  p_name      IN  VARCHAR2,
  p_last_name IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER,
  p_delim IN VARCHAR2
) RETURN NUMBER;

PROCEDURE Clone_Soln_After_Import
    (
    x_return_status        OUT NOCOPY varchar2,
    x_msg_count            OUT NOCOPY number,
    x_msg_data             OUT NOCOPY varchar2,
    p_set_flow_name        IN  VARCHAR2,
    p_set_flow_stepcode    IN  VARCHAR2,
    p_set_number           IN  VARCHAR2
    ) ;

END CS_KNOWLEDGE_AUDIT_PVT;

/
