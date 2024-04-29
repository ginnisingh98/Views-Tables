--------------------------------------------------------
--  DDL for Package IEX_CASE_OWNER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASE_OWNER_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpcals.pls 120.0 2004/01/24 03:19:09 appldev noship $ */


/* this will be the outside wrapper for the concurrent program to call the "creation" in batch
 */
PROCEDURE IEX_CASE_OWNER_CONCUR(ERRBUF      OUT NOCOPY     VARCHAR2,
                                 RETCODE     OUT NOCOPY     VARCHAR2,
                                 p_list_name IN VARCHAR2 DEFAULT NULL);

/*

 */
PROCEDURE Run_Load_Balance(p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2);

END IEX_CASE_OWNER_PUB ;

 

/
