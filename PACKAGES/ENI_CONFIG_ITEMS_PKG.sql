--------------------------------------------------------
--  DDL for Package ENI_CONFIG_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_CONFIG_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: ENICTOIS.pls 115.1 2003/09/12 19:13:39 sbag noship $  */

-- API used to insert config. items into the STAR table

PROCEDURE Create_config_items( p_api_version NUMBER,
                               p_init_msg_list VARCHAR2 := 'F',
                               p_star_record CTO_ENI_WRAPPER.star_rec_type,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2);

End ENI_CONFIG_ITEMS_PKG;


 

/
