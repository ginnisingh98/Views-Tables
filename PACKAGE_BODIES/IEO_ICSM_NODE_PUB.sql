--------------------------------------------------------
--  DDL for Package Body IEO_ICSM_NODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_ICSM_NODE_PUB" AS
/* $Header: ieonodeb.pls 115.0 2003/02/14 21:15:34 ktlaw noship $ */

    PROCEDURE DELETE_ALL_NODES IS
    BEGIN
		delete from ieo_svr_node_rt_info;
		delete from ieo_svr_node_assignments;
		delete from ieo_node_addrs;
		delete from ieo_nodes;
    END DELETE_ALL_NODES;

END IEO_ICSM_NODE_PUB;

/
