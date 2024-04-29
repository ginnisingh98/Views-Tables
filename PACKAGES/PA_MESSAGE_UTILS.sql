--------------------------------------------------------
--  DDL for Package PA_MESSAGE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MESSAGE_UTILS" AUTHID CURRENT_USER AS
-- $Header: PAMSGUTS.pls 120.1 2005/08/19 16:36:14 mwasowic noship $

--
--  PROCEDURE
--              save_messages
--  PURPOSE
--
PROCEDURE save_messages
	(p_request_id           IN      NUMBER      default -1,
         p_user_id              IN      NUMBER      default null,
         p_source_Type1         IN      VARCHAR2    default null,
         p_source_Type2	        IN      VARCHAR2    default null,
         p_source_identifier1	IN      VARCHAR2    default null,
         p_source_identifier2	IN      VARCHAR2    default null,
         p_context1             IN      VARCHAR2    default null,
         p_context2             IN      VARCHAR2    default null,
         p_context3             IN      VARCHAR2    default null,
         p_context4             IN      VARCHAR2    default null,
         p_context5             IN      VARCHAR2    default null,
         p_context6             IN      VARCHAR2    default null,
         p_context7             IN      VARCHAR2    default null,
         p_context8             IN      VARCHAR2    default null,
         p_context9             IN      VARCHAR2    default null,
         p_context10            IN      VARCHAR2    default null,
         p_date_context1        IN      DATE        default null,
         p_date_context2        IN      DATE        default null,
         p_date_context3        IN      DATE        default null,
         p_use_fnd_msg          IN      VARCHAR2    default 'Y',
         p_commit               IN      VARCHAR2    default FND_API.G_FALSE,
         p_init_msg_list        IN      VARCHAR2    default FND_API.G_TRUE,
         p_encode               IN      VARCHAR2    default FND_API.G_TRUE,
         x_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Get_Decoded_Message(encoded_message_text IN VARCHAR2)
RETURN VARCHAR2;

END PA_MESSAGE_UTILS;
 

/
