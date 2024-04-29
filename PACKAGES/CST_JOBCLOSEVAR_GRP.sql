--------------------------------------------------------
--  DDL for Package CST_JOBCLOSEVAR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_JOBCLOSEVAR_GRP" AUTHID CURRENT_USER AS
/* $Header: CSTGWJVS.pls 120.0 2005/06/24 12:41:09 appldev noship $ */

/*----------------------------------------------------------------------------+
| Start of comments                                                           |
|      API name        : Calculate_Job_Variance                               |
|      Type            : Group                                                |
|      Function        : Discrete job close variance calculation.             |
|      Pre-reqs        : None.                                                |
|      Parameters      :                                                      |
|      IN              :                                                      |
|        p_api_version      IN NUMBER       Required                          |
|        p_init_msg_list    IN VARCHAR2     Required                          |
|        p_commit           IN VARCHAR2     Required                          |
|        p_validation_level IN NUMBER       Required                          |
|        p_user_id          IN NUMBER       Required                          |
|        p_login_id         IN NUMBER       Required                          |
|        p_prg_appl_id      IN NUMBER       Required                          |
|        p_prg_id           IN NUMBER       Required                          |
|        p_req_id           IN NUMBER       Required                          |
|        p_wcti_group_id    IN NUMBER       Required                          |
|        p_org_id           IN NUMBER       Required                          |
|                                                                             |
|      OUT             :                                                      |
|        x_return_status    OUT VARCHAR2(1)                                   |
|        x_msg_count        OUT NUMBER                                        |
|        x_msg_data         OUT VARCHAR2(2000)                                |
|                                                                             |
|      Version : Current version       1.0                                    |
|                                                                             |
| End of comments                                                             |
+----------------------------------------------------------------------------*/
PROCEDURE Calculate_Job_Variance
(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2,
        p_commit                IN      VARCHAR2,
        p_validation_level      IN      NUMBER,

        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,

        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_prg_appl_id           IN      NUMBER,
        p_prg_id                IN      NUMBER,
        p_req_id                IN      NUMBER,
        p_wcti_group_id         IN      NUMBER,
        p_org_id                IN      NUMBER
);

END CST_JobCloseVar_GRP;

 

/
