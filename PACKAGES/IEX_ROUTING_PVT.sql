--------------------------------------------------------
--  DDL for Package IEX_ROUTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_ROUTING_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvrous.pls 120.0 2004/01/24 03:28:37 appldev noship $ */

--TYPE iex_collectors_rec_type IS RECORD
--(
--         collector_id	     jtf_customer_profiles_v.collector_id%type
--);

--TYPE iex_collectors_tbl_type IS TABLE  OF  iex_collectors_rec_type
--      INDEX BY BINARY_INTEGER;

TYPE iex_collectors_tbl_type IS TABLE  OF
   jtf_customer_profiles_v.collector_id%type
   INDEX BY BINARY_INTEGER;


PROCEDURE isCustomerOverdue ( p_api_version               in  number,
                              p_init_msg_list             in  varchar2 default fnd_api.g_false,
                              p_commit                    in  varchar2 default fnd_api.g_false,
                              p_validation_level          in  number   default fnd_api.g_valid_level_full,
                              x_return_status             out NOCOPY varchar2,
                              x_msg_count                 out NOCOPY number,
                              x_msg_data                  out NOCOPY varchar2,
                              p_customer_id               in  number,
                              p_customer_overdue          out NOCOPY boolean);

PROCEDURE getCollectors     ( p_api_version               in  number,
                              p_init_msg_list             in  varchar2 default fnd_api.g_false,
                              p_commit                    in  varchar2 default fnd_api.g_false,
                              p_validation_level          in  number   default fnd_api.g_valid_level_full,
                              x_return_status             out NOCOPY varchar2,
                              x_msg_count                 out NOCOPY number,
                              x_msg_data                  out NOCOPY varchar2,
                              p_customer_id               in  number,
                              p_collectors                out NOCOPY iex_collectors_tbl_type);

END IEX_ROUTING_PVT;

 

/
