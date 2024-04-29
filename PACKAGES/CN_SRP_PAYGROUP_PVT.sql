--------------------------------------------------------
--  DDL for Package CN_SRP_PAYGROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYGROUP_PVT" AUTHID CURRENT_USER as
-- $Header: cnvsdpgs.pls 120.1 2005/08/25 02:16:40 sjustina noship $

TYPE PayGroup_assign_rec IS RECORD
  (  srp_pay_group_id      cn_srp_pay_groups.srp_pay_group_id%TYPE := cn_api.g_miss_id,
     pay_group_id          cn_srp_pay_groups.pay_group_id%TYPE     := cn_api.g_miss_id,
     salesrep_id           cn_srp_pay_groups.salesrep_id%TYPE      := cn_api.g_miss_id,
     assignment_start_date cn_srp_pay_groups.start_date%TYPE       := cn_api.g_miss_date,
     assignment_end_date   cn_srp_pay_groups.end_date%TYPE         := cn_api.g_miss_date,
     lock_flag             cn_srp_pay_groups.lock_flag%TYPE        := cn_api.g_miss_char,
     role_pay_group_id     cn_srp_pay_groups.role_pay_group_id%TYPE:= cn_api.g_miss_id,
     org_id                cn_srp_pay_groups.org_id%TYPE           := cn_api.g_miss_id,
     object_version_number cn_srp_pay_groups.object_version_number%TYPE,
     attribute_category    cn_srp_pay_groups.attribute_category%TYPE
                             := cn_api.g_miss_char,
     attribute1            cn_srp_pay_groups.attribute1%TYPE
                             := cn_api.g_miss_char,
     attribute2            cn_srp_pay_groups.attribute2%TYPE
                             := cn_api.g_miss_char,
     attribute3            cn_srp_pay_groups.attribute3%TYPE
                             := cn_api.g_miss_char,
     attribute4            cn_srp_pay_groups.attribute4%TYPE
                             := cn_api.g_miss_char,
     attribute5            cn_srp_pay_groups.attribute5%TYPE
                             := cn_api.g_miss_char,
     attribute6            cn_srp_pay_groups.attribute6%TYPE
                             := cn_api.g_miss_char,
     attribute7            cn_srp_pay_groups.attribute7%TYPE
                             := cn_api.g_miss_char,
     attribute8            cn_srp_pay_groups.attribute8%TYPE
                             := cn_api.g_miss_char,
     attribute9            cn_srp_pay_groups.attribute9%TYPE
                             := cn_api.g_miss_char,
     attribute10           cn_srp_pay_groups.attribute10%TYPE
                             := cn_api.g_miss_char,
     attribute11           cn_srp_pay_groups.attribute11%TYPE
                             := cn_api.g_miss_char,
     attribute12           cn_srp_pay_groups.attribute12%TYPE
                             := cn_api.g_miss_char,
     attribute13           cn_srp_pay_groups.attribute13%TYPE
                             := cn_api.g_miss_char,
     attribute14           cn_srp_pay_groups.attribute14%TYPE
                             := cn_api.g_miss_char,
     attribute15           cn_srp_pay_groups.attribute15%TYPE
                             := cn_api.g_miss_char);
PROCEDURE Create_Srp_Pay_Group
  (  	p_api_version              IN	NUMBER				      ,
     	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
  	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
  	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  	x_return_status		   OUT NOCOPY	VARCHAR2	      	      ,
  	x_loading_status           OUT NOCOPY  VARCHAR2       	              ,
  	x_msg_count		   OUT NOCOPY	NUMBER		     	      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2              	      ,
  	p_paygroup_assign_rec      IN OUT NOCOPY  PayGroup_assign_rec
  	);


PROCEDURE Update_Srp_Pay_Group
  (  	p_api_version              IN	NUMBER				      ,
     	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
  	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
  	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_loading_status           OUT NOCOPY  VARCHAR2                       ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
	p_paygroup_assign_rec      IN OUT NOCOPY  PayGroup_assign_rec
  	);

PROCEDURE Delete_Srp_Pay_Group
  (  	p_api_version              IN	NUMBER				      ,
     	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
  	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
  	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_loading_status           OUT NOCOPY  VARCHAR2                       ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
  	p_paygroup_assign_rec      IN PayGroup_assign_rec
  	);

PROCEDURE valid_delete_srp_pay_group
  (  	p_paygroup_assign_rec      IN paygroup_assign_rec                     ,
     	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
  	x_loading_status	   OUT NOCOPY	VARCHAR2	     	      ,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2
	);

  -- Start of comments
  -- API name 	: Delete_Mass_Asgn_Srp_Pay_Groups
  -- Type		: Private
  -- Pre-reqs	: None.
  -- Usage	: Used to delete a payment plan assignment to an salesrep
  -- Desc 	: Procedure to delete a payment plan assignment to salesrep
  -- Parameters	:
  -- IN		:  p_api_version       IN NUMBER      Require
  -- 		   p_init_msg_list     IN VARCHAR2    Optional
  -- 		   	Default = CN_API.G_FALSE
  -- 		   p_commit	       IN VARCHAR2    Optional
  -- 		       	Default = CN_API.G_FALSE
  -- 		   p_validation_level  IN NUMBER      Optional
  -- 		       	Default = CN_API.G_VALID_LEVEL_FULL
  --  	           p_srp_role_id       IN NUMBER
  --                 p_role_pmt_plan_id  IN NUMBER
  -- OUT		:  x_return_status     OUT	      VARCHAR2(1)
  -- 		   x_msg_count	       OUT	      NUMBER
  -- 		   x_msg_data	       OUT	      VARCHAR2(2000)
  --                 x_loading_status    OUT	      VARCHAR2(30)
  -- Version	: Current version	1.0
  --		  Initial version 	1.0

  PROCEDURE Delete_Mass_Asgn_Srp_Pay
    (p_api_version        IN    NUMBER,
     p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
     p_commit	          IN    VARCHAR2 := FND_API.G_FALSE,
     p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     x_return_status      OUT NOCOPY  VARCHAR2,
     x_msg_count	  OUT NOCOPY  NUMBER,
     x_msg_data	          OUT NOCOPY  VARCHAR2,
     p_srp_role_id        IN    NUMBER,
     p_role_pay_group_id  IN    NUMBER,
     x_loading_status     OUT NOCOPY  VARCHAR2
     );


END CN_Srp_PayGroup_PVT ;

 

/
