--------------------------------------------------------
--  DDL for Package AS_SCORECARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SCORECARD_PUB" AUTHID CURRENT_USER AS
/* $Header: asxpscds.pls 115.8 2002/11/18 23:54:19 chchandr ship $ */


/* begin raverma 01312001
    add params for security check
                p_identity_salesforce_id  IN  NUMBER,
                p_admin_flag              IN  Varchar2(1),
                p_admin_group_id          IN  NUMBER,
    always check update access = 'Y'
*/
-- ffang 050901, add parameter p_check_access_flag
-- from UI, this parameter should be past 'Y'
-- from lead import concurr. program, 'N' should be past

-- this will be the main call of the scoreCard scoring engine
Procedure Get_Score (
    p_api_version             IN  NUMBER := 2.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_sales_lead_id           IN  NUMBER,
    p_scorecard_id            IN  NUMBER,
 -- swkhanna Bug 2260459
    p_marketing_score         IN  NUMBER := 0,
    p_identity_salesforce_id  IN  NUMBER,
    p_admin_flag              IN  VARCHAR2,
    p_admin_group_id          IN  NUMBER,
    x_rank_id                 OUT NOCOPY NUMBER,
    X_SCORE                   OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2 );

END AS_SCORECARD_PUB;

 

/
