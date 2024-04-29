--------------------------------------------------------
--  DDL for Package IEX_SCOREAPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCOREAPI_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpsras.pls 120.0 2005/06/15 17:40:16 acaraujo ship $ */

procedure getScore( p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    p_SCORE_ID        IN  NUMBER,
                    p_OBJECT_ID       IN  NUMBER,
                    x_SCORE           OUT NOCOPY NUMBER,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR);
procedure getStatus(p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    p_commit          IN  VARCHAR2,
                    p_SCORE_ID        IN  NUMBER,
                    p_SCORE           IN  NUMBER,
                    x_STATUS          OUT NOCOPY VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR);

procedure getScoreStatus(p_api_version IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2,
                         p_SCORE_ID        IN  NUMBER,
                         p_OBJECT_ID       IN  NUMBER,
                         x_STATUS          OUT NOCOPY VARCHAR2,
                         x_SCORE           OUT NOCOPY NUMBER,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR);
Function checkObject_Compatibility(p_score_id in number) return BOOLEAN;

END;

 

/
