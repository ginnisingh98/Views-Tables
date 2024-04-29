--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_WF_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpstws.pls 120.0 2004/01/24 03:20:09 appldev noship $ */

-- PROCEDURE start workflow
-- DESCRIPTION	This procedure is called to start standard collections strategy workflow*/

PROCEDURE start_workflow
           (p_api_version             IN NUMBER := 2.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
	    	p_strategy_rec            IN IEX_STRATEGY_PVT.STRATEGY_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            bConcProg                 IN  VARCHAR2 := 'YES')
;

PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2);

setMsgLevel  NUMBER;


END IEX_STRATEGY_WF_PUB;

 

/
