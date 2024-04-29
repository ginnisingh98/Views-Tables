--------------------------------------------------------
--  DDL for Package CS_KNOWLEDGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KNOWLEDGE_PVT" AUTHID CURRENT_USER AS
/* $Header: csvkbs.pls 120.0 2005/06/01 10:12:31 appldev noship $ */

--
-- CONSTANTS
--

  G_PKG_NAME  	     CONSTANT VARCHAR2(50) := 'CS_Knowledge_PVT';

  --  G_YES     CONSTANT VARCHAR2(1)  :='Y';
  --  G_NO      CONSTANT VARCHAR2(1)  :='N';

  G_PF      CONSTANT VARCHAR2(2)  :='PF';  -- triggered when user clicked "Yes", it solved my problem
  G_NF      CONSTANT VARCHAR2(2)  :='NF';  -- triggered when user clicked "No", didn't solve my problem
  G_VS      CONSTANT VARCHAR2(2)  :='VS';  -- triggered when solution is viewed

  -- for return status
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

  G_TRUE    CONSTANT VARCHAR2(1)  := FND_API.G_TRUE;
  G_FALSE   CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;
  G_VALID_LEVEL_TYPESOK CONSTANT NUMBER := 50;

--
-- TYPES AND MISSING CONSTANTS
--
  G_MISS_NUM15          CONSTANT NUMBER(15)  := -9E14;

--
-- Procedures and Functions
--

--
-- Utility functions
--

FUNCTION Build_Solution_Text_Query
  (
    p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type
  )
  return varchar2;

FUNCTION Build_Solution_Text_Query
  (
    p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number
  )
  return varchar2;

FUNCTION Build_Solution_Text_Query
  (
    p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number
  )
  return varchar2;

FUNCTION Build_Solution_Text_Query
  (
    p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_category_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number
  )
  return varchar2;

FUNCTION Build_Solution_Text_Query
  (
    p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_category_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_statement_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number
  )
  return varchar2;

FUNCTION Build_Simple_Text_Query
  (
    p_qry_string in varchar2,
    p_search_option in number
  )
  return varchar2;


FUNCTION Build_Statement_Text_Query
  (
    p_raw_text in varchar2,
    p_statement_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type
  )
  return varchar2;

-- 3468629
FUNCTION Build_Statement_Text_Query
  (
    p_raw_text in varchar2,
    p_statement_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number
  )
  return varchar2;

-- Build_Keyword_Query is for KM internal use only
FUNCTION Build_Keyword_Query
  (
    p_string        IN VARCHAR2,
    p_search_option IN NUMBER
  )
  RETURN VARCHAR2;

FUNCTION Bind_Var_String(
   p_start_num   in number,
   p_size        in number
 )return varchar2;


FUNCTION Concat_Ids(
  p_id_tbl in cs_kb_number_tbl_type,
  p_separator in varchar2
) return varchar2;

FUNCTION Concat_Ids(
  p_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
  p_separator in varchar2
) return varchar2;

FUNCTION Is_Set_Ele_Type_Valid(
  p_set_id in number := null,
  p_set_type_id in number :=null,
  p_ele_id in number :=null,
  p_ele_type_id in number :=null
) return varchar2;

FUNCTION Does_Set_Type_Exist(
  p_set_type_id in number
) return varchar2;

FUNCTION Does_Element_Type_Exist(
  p_ele_type_id in number
) return varchar2;



PROCEDURE Get_Who(
  x_sysdate  OUT NOCOPY date,
  x_user_id  OUT NOCOPY number,
  x_login_id OUT NOCOPY number
);


FUNCTION Do_Elements_Exist_In_Set (
  p_ele_id_tbl  in cs_kb_number_tbl_type
) return varchar2;

FUNCTION Get_External_Obj_Names(
  p_obj_code_tbl in jtf_varchar2_table_100,
  p_sel_id_tbl   in jtf_varchar2_table_100,
  p_sel_name_tbl OUT NOCOPY jtf_varchar2_table_1000
) return number;

--FUNCTION Move_Element_Order(
--  p_set_id in number,
--  p_ele_id in number,
--  p_mode   in varchar2
--) return number;

--FUNCTION Change_Element_Assoc(
--  p_set_id in number,
--  p_ele_id_tbl in cs_kb_number_tbl_type,
--  p_assoc_tbl  in cs_kb_varchar100_tbl_type --N = neg, P=positive
--) return number;

FUNCTION Del_Element_From_Set(
  p_ele_id in number,
  p_set_id in number,
  p_update_sets_b in varchar2 default 'T'
) return number;

--FUNCTION Add_Element_To_Set_Ord(
--  p_set_id in number,
--  p_ele_id in number,
--  p_ele_order in number,
--  p_assoc_degree in number := CS_Knowledge_PUB.G_POSITIVE_ASSOC
--) return number;


FUNCTION Add_Element_To_Set(
  p_ele_id in number,
  p_set_id in number,
  p_assoc_degree in number := CS_Knowledge_PUB.G_POSITIVE_ASSOC,
  p_update_sets_b in varchar2 default 'T'
) return number;

PROCEDURE Add_External_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_usage_code          in  varchar2,
  p_id                  in  number,
  p_object_code         in  varchar2,
  p_other_id_tbl            in  cs_kb_number_tbl_type,
  p_other_code_tbl          in  cs_kb_varchar100_tbl_type
);

--
-- Update or delete link
--
--PROCEDURE Change_Set_Type_Links(
--  p_api_version         in  number,
--  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
--  p_commit              in  varchar2 := FND_API.G_FALSE,
--  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
--  x_return_status       OUT NOCOPY varchar2,
--  x_msg_count           OUT NOCOPY number,
--  x_msg_data            OUT NOCOPY varchar2,
--  p_link_id_tbl         in  cs_kb_number_tbl_type,
--  p_set_type_id_tbl      in  cs_kb_number_tbl_type
--);

PROCEDURE Change_Ele_Type_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_link_id_tbl         in  cs_kb_number_tbl_type,
  p_ele_type_id_tbl      in  cs_kb_number_tbl_type
);
--
-- Update or Delete setlinks
-- (used when del set)
--
PROCEDURE Change_Set_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_link_id_tbl         in  cs_kb_number_tbl_type,
  p_set_id_tbl          in  cs_kb_number_tbl_type
);

PROCEDURE Change_Element_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_link_id_tbl         in  cs_kb_number_tbl_type,
  p_element_id_tbl          in  cs_kb_number_tbl_type
);

PROCEDURE Change_Element_To_Sets(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_element_id          in  number,
  p_set_id_tbl          in  cs_kb_number_tbl_type,
  p_new_ele_id_tbl      in  cs_kb_number_tbl_type
);
--
-- Creation APIs using records
--

-- Original (Pre 8/03/00) Contributed element ids not passed back
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type,
--  p_attrval_def_tbl     in  CS_Knowledge_PUB.attrval_def_tbl_type,
  x_set_id              OUT NOCOPY number
);

-- New (Post 8/03/00) Contributed element ids passed back
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type,
--  p_attrval_def_tbl     in  CS_Knowledge_PUB.attrval_def_tbl_type,
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY CS_Knowledge_PUB.number15_tbl_type
);

PROCEDURE Create_Set(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_id_tbl          in  CS_Knowledge_PUB.number15_tbl_type,
--  p_attrval_def_tbl     in  CS_Knowledge_PUB.attrval_def_tbl_type,
  x_set_id              OUT NOCOPY number
);

PROCEDURE Create_Element(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_ele_def_rec         in  CS_Knowledge_PUB.ele_def_rec_type,
  x_element_id          OUT NOCOPY number
);


--
-- Creation APIs using objects
--

-- Original (Pre 8/03/00) Contributed element ids not passed back
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_obj         in  cs_kb_set_def_obj_type,
  p_ele_def_tbl         in  cs_kb_ele_def_tbl_type,
--  p_attrval_def_tbl     in  cs_kb_attrval_def_tbl_type :=null,
  p_ele_assoc_tbl       in  cs_kb_number_tbl_type :=null,
  x_set_id              OUT NOCOPY number
);

-- New (Post 8/03/00) Contributed element ids passed back
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_obj         in  cs_kb_set_def_obj_type,
  p_ele_def_tbl         in  cs_kb_ele_def_tbl_type,
--  p_attrval_def_tbl     in  cs_kb_attrval_def_tbl_type :=null,
  p_ele_assoc_tbl       in  cs_kb_number_tbl_type :=null,
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY cs_kb_number_tbl_type
);

PROCEDURE Create_Set(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_def_obj         in  cs_kb_set_def_obj_type,
  p_ele_id_tbl          in  cs_kb_number_tbl_type,
--  p_attrval_def_tbl     in  cs_kb_attrval_def_tbl_type :=null,
  p_ele_assoc_tbl       in  cs_kb_number_tbl_type :=null,
  x_set_id              OUT NOCOPY number
);

PROCEDURE Create_Element(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_ele_def_obj         in  cs_kb_ele_def_obj_type,
  x_element_id          OUT NOCOPY number
);

--
-- API for recording a set is useful
--

PROCEDURE Incr_Set_Useful(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit	        in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_id              in  number,
  p_user_id             in  number,
  p_used_type           in varchar2, -- := CS_KNOWLEDGE_PVT.G_PF,
  p_session_id          in  number  DEFAULT NULL
);

--
-- Search APIs
--
--PROCEDURE Find_Eles_Matching (
--  p_api_version	        in  number,
--  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
--  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
--  x_return_status       OUT NOCOPY varchar2,
--  x_msg_count	        OUT NOCOPY number,
--  x_msg_data	        OUT NOCOPY varchar2,
--  p_query_str     	in  varchar2,
--  p_type_id_tbl     	in  CS_Knowledge_PUB.number15_tbl_type,
--  p_other_criteria  	in  varchar2 := NULL,
--  p_rows                in  number,
--  p_start_score         in  number := null,
--  p_start_id            in  number := null,
--  p_start_row           in  number, -- := 1,
--  x_ele_tbl      	in OUT NOCOPY CS_Knowledge_PUB.ele_res_tbl_type,
--  p_search_option       in number := null
--);

--PROCEDURE Find_Eles_Related (
--  p_api_version	        in  number,
--  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
--  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
--  x_return_status       OUT NOCOPY varchar2,
--  x_msg_count	        OUT NOCOPY number,
--  x_msg_data	        OUT NOCOPY varchar2,
--  p_ele_id_tbl          in  CS_Knowledge_PUB.number15_tbl_type,
--  p_type_id_tbl     	in  CS_Knowledge_PUB.number15_tbl_type,
--  p_other_criteria  	in  varchar2 := NULL,
--  p_rows                in  number,
--  p_start_score         in  number := null,
--  p_start_id            in  number := null,
--  p_start_row           in  number, -- := 1,
--  x_ele_tbl      	in OUT NOCOPY CS_Knowledge_PUB.ele_res_tbl_type
--);

PROCEDURE Find_Sets_Matching (
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_pos_query_str       in  varchar2,
  p_neg_query_str       in  varchar2 := null,
  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
  p_other_criteria      in  varchar2 := NULL,
  p_rows                in  number,
  p_start_score         in  number := null,
  p_start_id            in  number := null,
  p_start_row           in  number, -- := 1,
  p_get_total_flag      in  varchar2, -- := FND_API.G_FALSE,
  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type,
  x_total_rows          OUT NOCOPY number,
  p_search_option       in number := null
);

PROCEDURE Find_Sets_Matching2 (
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_pos_query_str       in  varchar2,
--  p_neg_query_str       in  varchar2 := null,
  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
  p_other_criteria      in  varchar2,
  p_other_value         in  Number,
  p_rows                in  number,
  p_start_score         in  number := null,
  p_start_id            in  number := null,
  p_start_row           in  number, -- := 1,
  p_get_total_flag      in  varchar2, -- := FND_API.G_FALSE,
  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type,
  x_total_rows          OUT NOCOPY number,
  p_search_option       in number := null
);

--PROCEDURE Find_Sets_Related (
--  p_api_version	        in  number,
--  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
--  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
--  x_return_status       OUT NOCOPY varchar2,
--  x_msg_count	        OUT NOCOPY number,
--  x_msg_data	        OUT NOCOPY varchar2,
--  p_pos_ele_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
--  p_neg_ele_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
--  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
--  p_other_criteria      in  varchar2 := NULL,
--  p_rows                in  number,
--  p_start_score         in  number := null,
--  p_start_id            in  number := null,
--  p_start_row           in  number, -- := 1,
--  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type
--);


PROCEDURE Process_Frequency_Keyword (
     p_query_str       in  out nocopy varchar2,
     p_search_option   in Number);


FUNCTION Build_Smart_Score_Query
  (
    p_current_query  in varchar2,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_category_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_statement_id_tbl in CS_Knowledge_PUB.number15_tbl_type
  )
  return varchar2;

FUNCTION Build_Related_Stmt_Text_Query
( p_statement_id_tbl in CS_Knowledge_PUB.number15_tbl_type )
 Return VARCHAR2;

FUNCTION Build_SR_Text_Query
  (
    p_string in varchar2,
    p_search_option in number
  )
return varchar2;

-- Add item_id
FUNCTION Build_SR_Text_Query
  (
    p_string        in VARCHAR2,
    p_item_id       in NUMBER,
    p_search_option in NUMBER
  )
return varchar2;

end CS_Knowledge_Pvt;

 

/
