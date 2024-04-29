--------------------------------------------------------
--  DDL for Package IBE_PROD_RELATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PROD_RELATION_GRP" AUTHID CURRENT_USER AS
/* $Header: IBEGCRLS.pls 120.0 2005/05/30 02:28:21 appldev noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBE_Prod_Relation_GRP';

-- Start of comments
--    API name   : Get_Related_Items
--    Type       : Public or Group or Private.
--    Function   :
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_item_id            IN  NUMBER
--                 p_rel_type_code      IN  VARCHAR2
--                 p_max_ret_num        IN  NUMBER
--                     Default = NULL  (Return all)
--                 p_order_by_col       IN  VARCHAR2
--                     Default = NULL  (No order)
--                 p_order_by_order     IN  VARCHAR2
--                     Default = G_ASCEND_ORDER  (Ascending order)
--                 p_include_self_ref   IN  VARCHAR2
--                     Default = FND_API.G_FALSE (Don't include self-referrals)
--                 p_bind_varN          IN  VARCHAR2
--                     Default = NULL  (Bind variables for relationship rule defined by manual SQL)
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--                 x_items_tbl          OUT JTF_Number_Table
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
PROCEDURE Get_Related_Items
(
   p_api_version      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := NULL           ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2                    ,
   p_item_id          IN         NUMBER                      ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   p_include_self_ref IN         VARCHAR2  := NULL           ,
   p_rule_type        IN         VARCHAR2  := NULL           ,
   p_bind_arg1        IN         VARCHAR2  := NULL           ,
   p_bind_arg2        IN         VARCHAR2  := NULL           ,
   p_bind_arg3        IN         VARCHAR2  := NULL           ,
   p_bind_arg4        IN         VARCHAR2  := NULL           ,
   p_bind_arg5        IN         VARCHAR2  := NULL           ,
   p_bind_arg6        IN         VARCHAR2  := NULL           ,
   p_bind_arg7        IN         VARCHAR2  := NULL           ,
   p_bind_arg8        IN         VARCHAR2  := NULL           ,
   p_bind_arg9        IN         VARCHAR2  := NULL           ,
   p_bind_arg10       IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table
);

-- Start of comments
--    API name   : Get_Related_Items
--    Type       : Public or Group or Private.
--    Function   : If p_preview_flag = 'T' returns items whose
--                 web_status is 'PUBLISHED' or 'UNPUBLISHED'.
--                 Otherwise, only returns items whose web_status
--                 is 'PUBLISHED'.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_msite_id           IN  NUMBER
--                 p_preview_flag       IN  VARCHAR2
--                 p_item_id            IN  NUMBER
--                 p_rel_type_code      IN  VARCHAR2
--                 p_max_ret_num        IN  NUMBER
--                     Default = NULL  (Return all)
--                 p_order_by_col       IN  VARCHAR2
--                     Default = NULL  (No order)
--                 p_order_by_order     IN  VARCHAR2
--                     Default = G_ASCEND_ORDER  (Ascending order)
--                 p_include_self_ref   IN  VARCHAR2
--                     Default = FND_API.G_FALSE (Don't include self-referrals)
--                 p_bind_varN          IN  VARCHAR2
--                     Default = NULL  (Bind variables for relationship rule defined by manual SQL)
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--                 x_items_tbl          OUT JTF_Number_Table
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
PROCEDURE Get_Related_Items
(
   p_api_version      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := NULL           ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2                    ,
   p_msite_id         IN         NUMBER                      ,
   p_preview_flag     IN         VARCHAR2  := NULL           ,
   p_item_id          IN         NUMBER                      ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   p_include_self_ref IN         VARCHAR2  := NULL           ,
   p_rule_type        IN         VARCHAR2  := NULL           ,
   p_bind_arg1        IN         VARCHAR2  := NULL           ,
   p_bind_arg2        IN         VARCHAR2  := NULL           ,
   p_bind_arg3        IN         VARCHAR2  := NULL           ,
   p_bind_arg4        IN         VARCHAR2  := NULL           ,
   p_bind_arg5        IN         VARCHAR2  := NULL           ,
   p_bind_arg6        IN         VARCHAR2  := NULL           ,
   p_bind_arg7        IN         VARCHAR2  := NULL           ,
   p_bind_arg8        IN         VARCHAR2  := NULL           ,
   p_bind_arg9        IN         VARCHAR2  := NULL           ,
   p_bind_arg10       IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table
);


-- Start of comments
--    API name   : Get_Related_Items
--    Type       : Public or Group or Private.
--    Function   : If p_preview_flag = 'T' returns items whose
--                 web_status is 'PUBLISHED' or 'UNPUBLISHED'.
--                 Otherwise, only returns items whose web_status
--                 is 'PUBLISHED'.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_msite_id           IN  NUMBER
--                 p_preview_flag       IN  VARCHAR2
--                 p_item_id            IN  NUMBER
--                 p_rel_type_code      IN  VARCHAR2
--                 p_max_ret_num        IN  NUMBER
--                     Default = NULL  (Return all)
--                 p_order_by_col       IN  VARCHAR2
--                     Default = NULL  (No order)
--                 p_order_by_order     IN  VARCHAR2
--                     Default = G_ASCEND_ORDER  (Ascending order)
--                 p_include_self_ref   IN  VARCHAR2
--                     Default = FND_API.G_FALSE (Don't include self-referrals)
--                 p_bind_varN          IN  VARCHAR2
--                     Default = NULL  (Bind variables for relationship rule defined by manual SQL)
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--                 x_items_tbl          OUT JTF_Number_Table
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
PROCEDURE Get_Related_Items
(
   p_api_version      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := NULL           ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2                    ,
   p_msite_id         IN         NUMBER                      ,
   p_preview_flag     IN         VARCHAR2  := NULL           ,
   p_item_ids         IN         JTF_Number_Table            ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   p_include_self_ref IN         VARCHAR2  := NULL           ,
   p_rule_type        IN         VARCHAR2  := NULL           ,
   p_bind_arg1        IN         VARCHAR2  := NULL           ,
   p_bind_arg2        IN         VARCHAR2  := NULL           ,
   p_bind_arg3        IN         VARCHAR2  := NULL           ,
   p_bind_arg4        IN         VARCHAR2  := NULL           ,
   p_bind_arg5        IN         VARCHAR2  := NULL           ,
   p_bind_arg6        IN         VARCHAR2  := NULL           ,
   p_bind_arg7        IN         VARCHAR2  := NULL           ,
   p_bind_arg8        IN         VARCHAR2  := NULL           ,
   p_bind_arg9        IN         VARCHAR2  := NULL           ,
   p_bind_arg10       IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table
);


END IBE_Prod_Relation_GRP;

 

/
