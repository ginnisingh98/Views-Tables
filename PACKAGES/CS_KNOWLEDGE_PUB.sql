--------------------------------------------------------
--  DDL for Package CS_KNOWLEDGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KNOWLEDGE_PUB" AUTHID CURRENT_USER AS
/* $Header: cspkbs.pls 120.1 2005/08/16 10:55:45 speng noship $ */



--
-- CONSTANTS
--

  G_PKG_NAME  	     CONSTANT VARCHAR2(50) := 'CS_Knowledge_PUB';


 -- G_ERROR_STATUS     CONSTANT NUMBER(5)   := -1;
 -- G_OKAY_STATUS      CONSTANT NUMBER(5)   := 0;

  /* for cs_kb_set_eles.assoc_degree  */
  G_POSITIVE_ASSOC   CONSTANT NUMBER(5)   := 1;
  G_NEGATIVE_ASSOC   CONSTANT NUMBER(5)   := -1;

  /* default increment for count */
  G_COUNT_INCR       CONSTANT NUMBER(5)   := 1;
  G_COUNT_INIT       CONSTANT NUMBER(5)   := 1;

  /* for different Search options as in metalink */

  MATCH_ALL          CONSTANT NUMBER(5)   := 0;
  MATCH_ANY          CONSTANT NUMBER(5)   := 1;
  FUZZY              CONSTANT NUMBER(5)   := 2;
  INTERMEDIA_SYNTAX  CONSTANT NUMBER(5)   := 3;
  THEME_BASED        CONSTANT NUMBER(5)   := 4;
  MATCH_ACCUM        CONSTANT NUMBER(5)   := 5;
  -- "6" is reserved for match by id at java level
  MATCH_PHRASE       CONSTANT NUMBER(5)   := 7;

--
-- TYPES AND MISSING CONSTANTS
-- (All types are defined in PUB package)
--

  /* for input query strings */
  TYPE varchar21990_tbl_type IS TABLE OF varchar2(1990);

  /* for input ids */
  TYPE number15_tbl_type IS TABLE OF number(15);

  /* weakly typed cursor for dynamic sql */
  TYPE general_csr_type IS REF CURSOR;

  /* element results */
  TYPE ele_res_rec_type IS RECORD (
      id                 number(15),
      score              number(15),
      type_id            number(15),
      description        clob      ,
      creation_date      date      ,
      created_by         number(15),
      last_update_date   date      ,
      last_updated_by    number(15),
      last_update_login  number(15),
      type_name          varchar2(100),
      short_description  varchar2(2000)
  );
  TYPE ele_res_tbl_type IS TABLE OF ele_res_rec_type;


  /* set results */
  TYPE set_res_rec_type IS RECORD (
      id                 number(15)    ,
      score              number(15)    ,
      type_id            number(15)    ,
      name               varchar2(1000) ,
      description        varchar2(1000),
      creation_date      date          ,
      created_by         number(15)    ,
      last_update_date   date          ,
      last_updated_by    number(15)    ,
      last_update_login  number(15)    ,
      type_name          varchar2(100) ,
      solution_number    varchar2(30)
  );
  TYPE set_res_tbl_type IS TABLE OF set_res_rec_type;


  /* record type for element definition */
  TYPE ele_def_rec_type IS RECORD (
    element_id             number(15) ,
    element_type_id        number(15) ,
    name               varchar2(2000) ,
    description        varchar2(2000) ,
    attribute_category varchar2(30) ,
    attribute1         varchar2(150),
    attribute2         varchar2(150),
    attribute3         varchar2(150),
    attribute4         varchar2(150),
    attribute5         varchar2(150),
    attribute6         varchar2(150),
    attribute7         varchar2(150),
    attribute8         varchar2(150),
    attribute9         varchar2(150),
    attribute10        varchar2(150),
    attribute11        varchar2(150),
    attribute12        varchar2(150),
    attribute13        varchar2(150),
    attribute14        varchar2(150),
    attribute15        varchar2(150)
   );
  TYPE ele_def_tbl_type IS TABLE OF ele_def_rec_type;
/*
  TYPE attrval_def_rec_type IS RECORD(
    attribute_val_id number(15),
    attribute_id number(15),
    num_val number,
    date_val date,
    string_val varchar2(1000),
    description varchar2(1000),
    attribute_category varchar2(30) ,
    attribute1         varchar2(150),
    attribute2         varchar2(150),
    attribute3         varchar2(150),
    attribute4         varchar2(150),
    attribute5         varchar2(150),
    attribute6         varchar2(150),
    attribute7         varchar2(150),
    attribute8         varchar2(150),
    attribute9         varchar2(150),
    attribute10        varchar2(150),
    attribute11        varchar2(150),
    attribute12        varchar2(150),
    attribute13        varchar2(150),
    attribute14        varchar2(150),
    attribute15        varchar2(150)
  );

  TYPE attrval_def_tbl_type IS TABLE OF attrval_def_rec_type;
*/
  /* record type for set definition */
  TYPE set_def_rec_type IS RECORD (
    set_id             number(15) ,
    set_type_id        number(15) ,
    name               varchar2(500)  ,
    description        varchar2(100) ,
    status             varchar2(30),
    attribute_category varchar2(30) ,
    attribute1         varchar2(150),
    attribute2         varchar2(150),
    attribute3         varchar2(150),
    attribute4         varchar2(150),
    attribute5         varchar2(150),
    attribute6         varchar2(150),
    attribute7         varchar2(150),
    attribute8         varchar2(150),
    attribute9         varchar2(150),
    attribute10        varchar2(150),
    attribute11        varchar2(150),
    attribute12        varchar2(150),
    attribute13        varchar2(150),
    attribute14        varchar2(150),
    attribute15        varchar2(150)
   );


  G_MISS_ELE_DEF_REC ele_def_rec_type ;
  G_MISS_ELE_DEF_TBL ele_def_tbl_type ;

  --
  -- Public
  --
-- Start of comments
--  API Name    : Construct_Text_Query
--  Type        : Public
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_qry_string  			IN
--		String of keywords
--  	p_search_option  			IN
--		Search option such as and, or, not, theme
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_qry_string           		OUT	VARCHAR2(30000)
--
--
--  Version     : Initial Version     1.0
--
--  Notes       : (Post 8/10/01) x_qry_string return result of the construct
--
--
-- End of comments

PROCEDURE Construct_Text_Query(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_qry_string          in  varchar2,
  p_search_option       in number,
  x_qry_string          OUT NOCOPY varchar2
);


-- Start of comments
--  API Name    : Create_Set_And_Elements
--  Type        : Public
--  Function    : Create a set using given elements
--  Pre-reqs    : Must have valid set/element types
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_set_def_rec  			IN
--		CS_Knowledge_PUB.set_def_rec_type		Required
--		Definition of the set. Must have set type, status, name.
--  	p_ele_def_tbl  			IN
--  		CS_Knowledge_PUB.ele_def_tbl_type		Required
--		Each record defines an element. If element id is given,
--		it is used, otherwise the api uses other fields to
--		create the element.
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_set_id              		OUT	NUMBER
--		The created set id.
--	x_element_id_tbl		OUT	CS_Knowledge_PUB.number15_tbl_type
--		Table of element ids associated with the statements contributed
--
--
--  Version     : Initial Version     1.0
--
--  Notes       : (Post 8/03/00) Contributed element ids passed back
--
--
-- End of comments

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
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY CS_Knowledge_PUB.number15_tbl_type
);




end CS_Knowledge_PUB;

 

/
