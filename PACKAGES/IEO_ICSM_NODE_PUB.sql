--------------------------------------------------------
--  DDL for Package IEO_ICSM_NODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_ICSM_NODE_PUB" AUTHID CURRENT_USER AS
/* $Header: ieonodes.pls 115.0 2003/02/14 21:15:29 ktlaw noship $ */

    -- DELETE ALL NODES
    -- delete all nodes after cloning
    PROCEDURE DELETE_ALL_NODES;

END IEO_ICSM_NODE_PUB;

 

/
