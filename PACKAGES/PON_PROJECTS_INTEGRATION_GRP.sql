--------------------------------------------------------
--  DDL for Package PON_PROJECTS_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_PROJECTS_INTEGRATION_GRP" AUTHID CURRENT_USER AS
--$Header: PONGPRJS.pls 120.0 2005/11/08 14:49:42 smhanda noship $


-- Start of comments
--      API name  : CHECK_DELETE_PROJECT_OK
--
--      Type      : Group
--
--
--      Function  : Checks if the passed in project id is refrenced in any
--                  auction header, line or payment.This API is called by
--                  Oracle Projects before deleting any project in Oracle Projects
--
--     Parameters:
--     IN   :      p_api_version       NUMBER   Required
--     IN   :      p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_TRUE Optional
--     IN   :      p_project_id        NUMBER Required, project id which needs to be checked
--
--     OUT  :      x_return_status          VARCHAR2, flag to indicate if the copy procedure
--                                                       was successful or not; It can have
--                                                      following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR  (Success with warning)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR (Failed due to error)
--
--     OUT  :      x_msg_count              NUMBER,   the number of warning of error messages due
--                                                       to this procedure call. It will have following
--                                                       values  -
--                                                       0 (for Success without warning)
--                                                       1 (for failure with error, check the
--                                                       x_return_status if it is error or waring)
--                                                       1 or more (for Success with warning, check the x_return_status)
--
--     OUT  :      x_msg_data               VARCHAR2,  the standard message data output parameter
--                                                       used to return the first message of the stack
--
--    Version    : Current version    1.0
--                 Previous version   1.0
--                 Initial version    1.0
--
-- End of comments
PROCEDURE CHECK_DELETE_PROJECT_OK(
                    p_api_version                 IN          NUMBER,
                    p_init_msg_list               IN          VARCHAR2,
                    p_project_id                  IN         NUMBER,
                    x_return_status               OUT NOCOPY  VARCHAR2,
                    x_msg_count                   OUT NOCOPY  NUMBER,
                    x_msg_data                    OUT NOCOPY  VARCHAR2
                    );


END PON_PROJECTS_INTEGRATION_GRP;

 

/
