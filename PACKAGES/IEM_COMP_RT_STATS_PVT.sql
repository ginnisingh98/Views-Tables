--------------------------------------------------------
--  DDL for Package IEM_COMP_RT_STATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_COMP_RT_STATS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvcrss.pls 115.3 2002/12/04 02:40:44 chtang noship $ */
-- Start of Comments
--  API name    : create_item
--  Type        :       Private
--  Function    : This procedure create a record in the table IEM_COMP_RT_STATS
--  Pre-reqs    :       None.
--  Parameters  :
--      IN
--  p_api_version_number        IN NUMBER       Required
--  p_init_msg_list     	IN VARCHAR2
--  p_commit    		IN VARCHAR2
--  p_type 			IN   VARCHAR2,
--  p_param   			IN   VARCHAR2,
--  p_value       		IN   VARCHAR2,
--
--      OUT
--  x_return_status    		OUT     VARCHAR2
--  x_msg_count     		OUT     NUMBER
--  x_msg_data      		OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
                       p_init_msg_list  IN   VARCHAR2,
                       p_commit      IN   VARCHAR2,
                       p_type IN   VARCHAR2,
                       p_param   IN   VARCHAR2,
                       p_value       IN   VARCHAR2,
                       x_return_status     OUT NOCOPY VARCHAR2,
                       x_msg_count       OUT NOCOPY NUMBER,
                       x_msg_data  OUT NOCOPY     VARCHAR2
                         );

PROCEDURE update_item (p_api_version_number    IN   NUMBER,
                       p_init_msg_list  IN   VARCHAR2,
                       p_commit     IN   VARCHAR2,
                       p_comp_rt_stats_id IN NUMBER,
                       p_type IN   VARCHAR2,
                       p_param   IN   VARCHAR2,
                       p_value       IN   VARCHAR2,
                       x_return_status   OUT NOCOPY     VARCHAR2,
                       x_msg_count             OUT NOCOPY          NUMBER,
                       x_msg_data        OUT NOCOPY     VARCHAR2
                         );

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
                              p_init_msg_list  IN   VARCHAR2,
                              p_commit      IN   VARCHAR2,
                              p_comp_rt_stats_id     in number,
                              x_return_status   OUT NOCOPY     VARCHAR2,
                              x_msg_count             OUT NOCOPY          NUMBER,
                              x_msg_data        OUT NOCOPY     VARCHAR2
                         );

PROCEDURE delete_item_for_cache (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

END IEM_COMP_RT_STATS_PVT;

 

/
