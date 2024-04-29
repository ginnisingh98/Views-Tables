--------------------------------------------------------
--  DDL for Package CSF_REMOTE_VIEWS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_REMOTE_VIEWS_PUB" AUTHID CURRENT_USER AS
/* $Header: CSFPRVWS.pls 115.4.11510.1 2004/06/24 13:35:29 appldev ship $ */

-- Start of comments
-- API name 	: Parse_Query
-- Type		: Public
-- Function	: Parse a SQL-Query to check if it is correctly executable.
-- Pre-reqs	: None
-- Parameters	:
--   p_api_version      IN   NUMBER                              Required
--   p_init_msg_list    IN   VARCHAR2  DEFAULT  FND_API.G_FALSE  Optional
--   x_return_status    OUT  NOCOPY VARCHAR2
--   x_msg_count        OUT  NOCOPY  NUMBER
--   x_msg_data         OUT  NOCOPY VARCHAR2
--   p_sql_query        IN   VARCHAR2                            Required
--      Standard SQL-query, ready to be executed when correct.
--   x_query_correct    OUT NOCOPY VARCHAR2
--      x_query_correct will be FND_API.G_TRUE or FND_API.G_FALSE.
-- Version		: 1.0
-- Notes		: -
--
-- End of comments

procedure Parse_Query
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY  NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_sql_query        IN  VARCHAR2
, x_query_correct    OUT NOCOPY VARCHAR2
);

-- Start of comments
-- API name 	: Execute_Remote_Views
-- Type		: Public
-- Function	: Execute predefined remote views. A succesful execution will be sent
--                to the requester by use of notifications and a record will be added
--                to table csf_l_queryrequests.
-- Pre-reqs	: Query to execute is defined in csf_l_queries.
-- Parameters	:
--   p_api_version      IN   NUMBER                                 Required
--   p_init_msg_list    IN   VARCHAR2  DEFAULT  FND_API.G_FALSE     Optional
--   p_commit           IN   VARCHAR2  DEFAULT  FND_API.G_FALSE     Optional
--   x_return_status    OUT NOCOPY  VARCHAR2
--   x_msg_count        OUT NOCOPY  NUMBER
--   x_msg_data         OUT NOCOPY  VARCHAR2
--   p_sqlstring        IN   VARCHAR2                               Required
--      The SQL-string to be executed is either the standard parameterless format or
--      has the following special syntax for parameters in the where-clause(s):
--      For text  : [$Question]
--      For number: [&Question]
--      For date  : [#Question]
--      Example: select distinct msi.description
--               from mtl_system_items msi
--               where description like [$Please enter the pattern of the name:]
--   p_parameter_string IN   VARCHAR2                               Required
--      Parameters for p_sqlstring have the following format:
--      <String>, followed by Chr(2).
--      For a text parameter quotes around the parameter are not allowed and
--      the '*'-char is allowed with the meaning of the '%'-char.
--      The [...] patterns in t p_sqlstring are replaced with the supplied
--      parameters starting with the first [...] (by textual search) and
--      the first supplied parameter, followed by the second etc.
--      Example: A% || Chr(2) || B* || Chr(2) || 1 || Chr(2)
--   p_sqltitle         IN   VARCHAR2                               Required
--   p_role             IN   VARCHAR2                               Required
--   p_requestdate      IN   DATE                                   Required
--   p_query_id         IN   NUMBER                                 Required
--      corresponds to existing csf_queries.queries_id.
--   p_queryrequest_id  IN   NUMBER    DEFAULT  FND_API.G_MISS_NUM  Optional
--      Primary Key for insertered record. If a primary key is given it
--      is used, otherwise one is generated automatically.
--   x_notification_id  OUT  NUMBER
--      corresponds to new wf_notifications.notification_id.
-- Version		: 1.0
-- Notes		: If execution fails the results of the execution will not
--                        be send to the requester.
--
-- End of comments

procedure Execute_Remote_View
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_sqlstring        IN  VARCHAR2
, p_parameter_string IN  VARCHAR2
, p_sqltitle         IN  VARCHAR2
, p_role             IN  VARCHAR2
, p_requestdate      IN  DATE
, p_query_id         IN  NUMBER
, p_queryrequest_id  IN  NUMBER   := FND_API.G_MISS_NUM
, x_queryrequest_id  OUT NOCOPY  NUMBER
, x_notification_id  OUT NOCOPY NUMBER
);

end CSF_REMOTE_VIEWS_PUB;

 

/
