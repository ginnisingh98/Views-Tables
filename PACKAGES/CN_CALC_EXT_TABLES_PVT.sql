--------------------------------------------------------
--  DDL for Package CN_CALC_EXT_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_EXT_TABLES_PVT" AUTHID CURRENT_USER AS
--$Header: cnvextts.pls 115.6 2003/01/31 08:41:33 hithanki ship $

TYPE calc_ext_table_rec_type IS RECORD
  (calc_ext_table_id     cn_calc_ext_tables.calc_ext_table_id%TYPE,
   name			 cn_calc_ext_tables.name%TYPE,
   Internal_table_id     cn_calc_ext_tables.internal_table_id%TYPE,
   external_table_id     cn_calc_ext_tables.external_table_id%TYPE,
   used_flag             cn_calc_ext_tables.used_flag%TYPE,
   description           cn_calc_ext_tables.description%TYPE,
   schema                cn_calc_ext_tables.schema%TYPE,
   external_table_name   cn_calc_ext_tables.external_table_name%TYPE,
   alias                 cn_calc_ext_tables.alias%TYPE,
   object_version_number NUMBER
   );

-- Start of comments
--	API name 	: Create_Calc_Ext_Tables
--	Type		: Private
--	Function	: This Private API can be used to create a
--			  External Table Mapping
--
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL

--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

PROCEDURE create_calc_ext_table
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  x_calc_ext_table_id 	 OUT NOCOPY     NUMBER,
  p_calc_ext_table_rec		IN      CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type
);

-- Start of comments
--	API name 	: Update_calc_ext_table
--	Type		: Public
--	Function	: This Private API can be used to update a external,
--			  table Mapping  in Oracle Sales
--			  Compensation.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_calc_ext_table_rec_type      IN
--						  CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--	Notes		: Note text
--
-- End of comments


PROCEDURE Update_calc_ext_table
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_calc_ext_table_rec	IN OUT NOCOPY  CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type,
  p_calc_ext_table_rec		IN OUT NOCOPY  CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type
);

-- Start of comments
--	API name 	: Delete_calc_ext_table
--	Type		: Public
--	Function	: This Private API can be used to delete a External table Mapping
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

PROCEDURE Delete_calc_ext_table
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_calc_ext_table_id    	IN	NUMBER
);

END CN_CALC_EXT_TABLES_PVT;

 

/
