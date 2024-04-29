--------------------------------------------------------
--  DDL for Package JTM_ITEM_INSTANCE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_ITEM_INSTANCE_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtmhkins.pls 120.1 2005/08/24 02:13:05 saradhak noship $*/
PROCEDURE create_item_instance_post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_id           IN     NUMBER
    ,x_return_status         OUT NOCOPY   VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );

PROCEDURE update_item_instance_pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_id           IN     NUMBER
    ,x_return_status         OUT NOCOPY  VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );

PROCEDURE update_item_instance_post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_id           IN     NUMBER
    ,x_return_status         OUT NOCOPY   VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );



end JTM_ITEM_INSTANCE_VUHK;

 

/
