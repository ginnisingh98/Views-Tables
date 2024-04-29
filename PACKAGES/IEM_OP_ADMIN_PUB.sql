--------------------------------------------------------
--  DDL for Package IEM_OP_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_OP_ADMIN_PUB" AUTHID CURRENT_USER as
/* $Header: iemoadms.pls 115.0 2003/08/22 21:20:36 txliu noship $*/

procedure getItemError(p_api_version_number    IN   NUMBER,
                       p_init_msg_list         IN   VARCHAR2,
                       p_commit                IN   VARCHAR2,
                       p_page_no               IN   NUMBER,
                       p_disp_size             IN   NUMBER,
                       p_sort_by               IN   VARCHAR2,
                       p_sort_dir              IN   NUMBER, --0 asc, 1 dsc
                       x_return_status         OUT NOCOPY  VARCHAR2,
                       x_msg_count             OUT NOCOPY  NUMBER,
                       x_msg_data              OUT NOCOPY  VARCHAR2,
                       x_total                 OUT NOCOPY  NUMBER,
                       x_item_err              OUT NOCOPY  SYSTEM.IEM_OP_ERR_OBJ_ARRAY);
procedure clearOutboxErrors(p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_rt_media_item_id_array IN  SYSTEM.IEM_RT_MSG_KEY_ARRAY,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2);

procedure purgeOutboxItems(p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_rt_media_item_id_array IN  SYSTEM.IEM_RT_MSG_KEY_ARRAY,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2);

procedure getOpItem(p_api_version_number   IN  NUMBER,
                   p_init_msg_list         IN  VARCHAR2,
                   p_commit                IN  VARCHAR2,
                   p_rt_media_item_id      IN  NUMBER,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_item_obj              OUT NOCOPY  SYSTEM.IEM_OP_ITEM
                   );

procedure pushbackToRework(p_api_version_number   IN  NUMBER,
                   p_init_msg_list         IN  VARCHAR2,
                   p_commit                IN  VARCHAR2,
                   p_rt_media_item_ids     IN  SYSTEM.IEM_RT_MSG_KEY_ARRAY,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2
                   );
/*
procedure getThreadStatus(p_api_version_number   IN  NUMBER,
                   p_init_msg_list         IN  VARCHAR2,
                   p_commit                IN  VARCHAR2,
                   p_thread_type           IN  NUMBER, -- 0 for Failed, 1 for Normal
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_thread_array          OUT NOCOPY  IEM_OP_THREAD_ARRAY
                   );
*/
end IEM_OP_ADMIN_PUB;

 

/
