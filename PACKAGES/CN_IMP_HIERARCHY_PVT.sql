--------------------------------------------------------
--  DDL for Package CN_IMP_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_HIERARCHY_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimhis.pls 120.1 2005/08/07 23:03:26 vensrini noship $

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

TYPE IMP_HIER_REC_TYPE IS RECORD
  (IMP_HEADER_ID	NUMBER	:= FND_API.G_MISS_NUM,
   IMP_LINE_ID	        NUMBER	:= FND_API.G_MISS_NUM,
   IMPORT_TYPE_CODE	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   STATUS_CODE	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   ERROR_CODE	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   RECORD_NUM   NUMBER := FND_API.G_MISS_NUM,
   HIERARCHY_TYPE VARCHAR2(80)	:= FND_API.G_MISS_CHAR,
   BASE_TABLE_NAME VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   PRIMARY_KEY VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   HIERARCHY_VALUE VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   HIERARCHY_NAME VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   -- set START_DATE END_DATE to VARCHAR on purpose, do not change to DATE type
   START_DATE     VARCHAR2(30)  := FND_API.G_MISS_CHAR,
   END_DATE       VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   DEFAULT_NODE_FLAG  VARCHAR2(1)	:= FND_API.G_MISS_CHAR,
   PARENT_NODE_NAME  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   NODE_NAME  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   LEVEL_NUM  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
   CREATION_DATE	DATE	:= FND_API.G_MISS_DATE,
   CREATED_BY	NUMBER	:= FND_API.G_MISS_NUM,
   LAST_UPDATE_DATE	DATE	:= FND_API.G_MISS_DATE,
   LAST_UPDATED_BY	NUMBER	:= FND_API.G_MISS_NUM,
  LAST_UPDATE_LOGIN	NUMBER	:= FND_API.G_MISS_NUM
  );

G_MISS_IMP_HIER_REC IMP_HIER_REC_TYPE;

-- Start of comments
--    API name        : Hierarchy_Import
--    Type            : Private.
--    Function        : programtransfer data from staging table into
--                      cn_dimension_vl,cn_head_hierarchies,cn_dim_hierarchies
--                      cn_hierarchy_nodes, cn_hierarchy_edges
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_imp_header_id           IN    NUMBER,
--    OUT             : errbuf         OUT VARCHAR2       Required
--                      retcode        OUTVARCHAR2     Optional
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Hierarchy_Import
 ( errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id		IN	NUMBER
   );

END CN_IMP_HIERARCHY_PVT;

 

/
