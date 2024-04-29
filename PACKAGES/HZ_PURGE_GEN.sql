--------------------------------------------------------
--  DDL for Package HZ_PURGE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PURGE_GEN" AUTHID CURRENT_USER AS
/* $Header: ARHPGENS.pls 120.2 2005/05/25 23:52:51 achung noship $ */
PROCEDURE identify_candidates(p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2,
 check_flag boolean, con_prg boolean, regid_proc boolean);
END;

 

/
