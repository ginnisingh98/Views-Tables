--------------------------------------------------------
--  DDL for Package IEM_OP_STAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_OP_STAT_PUB" AUTHID CURRENT_USER as
/* $Header: iemopstats.pls 115.0 2003/08/20 13:28:07 gohu noship $*/

PROCEDURE startOPStats(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_jservID               IN   VARCHAR2,
    p_jservPort             IN   VARCHAR2,
    p_apacheHost            IN   VARCHAR2,
    p_apachePort            IN   VARCHAR2,
    p_processed_msg_cnt     IN   NUMBER,
    p_cfailed_reason        IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2,
    x_controller_id         OUT  NOCOPY NUMBER
    );

PROCEDURE recordOPStats(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_jservID               IN   VARCHAR2,
    p_jservPort             IN   VARCHAR2,
    p_apacheHost            IN   VARCHAR2,
    p_apachePort            IN   VARCHAR2,
    p_threadID              IN   VARCHAR2,
    p_threadType            IN   VARCHAR2,
    p_tfailed_reason        IN   VARCHAR2,
    p_processed_msg_cnt     IN   NUMBER,
    p_controller_id         IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

END IEM_OP_STAT_PUB;

 

/
