--------------------------------------------------------
--  DDL for Package CN_REVENUE_CLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REVENUE_CLASS_PVT" AUTHID CURRENT_USER AS
--$Header: cnvrclss.pls 120.2 2005/08/07 23:04:53 vensrini noship $

TYPE revenue_class_rec_type IS RECORD
  (revenue_class_id      cn_revenue_classes.revenue_class_id%TYPE,
   name			 cn_revenue_classes.name%TYPE,
   description		 cn_revenue_classes.description%TYPE,
   liability_account_id  cn_revenue_classes.liability_account_id%TYPE,
   expense_account_id    cn_revenue_classes.expense_account_id%TYPE,
   object_version_number NUMBER
   );

-- Start of comments
--	API name 	: Create_revenue_class
--	Type		: Private
--	Function	: This Private API can be used to create a
--			  Revenue Class
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

PROCEDURE create_revenue_class
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  x_revenue_class_id 	 OUT NOCOPY     NUMBER,
  p_revenue_class_rec		IN      CN_REVENUE_CLASS_PVT.revenue_class_rec_type,
  p_org_id			IN 	NUMBER
);

-- Start of comments
--	API name 	: Update_revenue_class
--	Type		: Public
--	Function	: This Private API can be used to update a Revenue Class
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
--						  CN_REVENUE_CLASS_PVT.calc_ext_table_rec_type
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


PROCEDURE Update_revenue_class
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  pold_revenue_class_rec	IN OUT NOCOPY  CN_REVENUE_CLASS_PVT.revenue_class_rec_type,
  p_revenue_class_rec           IN OUT NOCOPY  CN_REVENUE_CLASS_PVT.revenue_class_rec_type
);

-- Start of comments
--	API name 	: Delete_revenue_class
--	Type		: Public
--	Function	: This Private API can be used to delete a Revenue Class
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

PROCEDURE Delete_revenue_class
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_revenue_class_id     	IN	NUMBER
);

END CN_REVENUE_CLASS_PVT;

 

/
