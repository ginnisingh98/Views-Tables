--------------------------------------------------------
--  DDL for Package QA_PERFORMANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PERFORMANCE_PUB" AUTHID CURRENT_USER AS
/* $Header: qapinds.pls 120.0 2005/05/24 17:54:25 appldev noship $ */


-- Start of Comments
--
-- API name        : get_predicate
-- Type            : Public
-- Pre-reqs        : None
-- Function        : API to fetch the predicate for a Function based index on a
--                   Softcoded Collection Element in Oracle Quality.
--
-- Parameters      :
-- IN              : p_api_version                                           NUMBER
--                      Should be 1.0
--
--                   p_init_msg_list                                         VARCHAR2
--                      Standard api parameter.  Indicates whether to
--                      re-initialize the message list.
--                      Default is fnd_api.g_false.
--
--                   p_char_id                                               NUMBER
--                      qa_char.char_id of the element for which the predicate
--                      neds to be fetched.
--                      Default is NULL.
--
--                   p_alias                                                 DATE
--     	                If p_alias is not NULL, then each CHARACTERxx in text
--                      should be prefixed by <p_alias>.CHARACTERxx.
--                      Default is NULL.
--
-- OUT             : x_predicate                                             VARCHAR2
--                      The Predicate to be returned
--
--                   x_msg_count                                             NUMBER
--                      Standard api parameter.  Indicates no. of messages
--                      put into the message stack. Currently, there are no
--                      supported messages. The framework is provided similar
--                      to any Public API.
--
--                   x_msg_data                                              VARCHAR2
--                      Standard api parameter.  Messages returned.
--                      Currently, there are no supported messages. The
--                      framework is provided similar to any Public API.
--
--                   x_return_status                                         VARCHAR2
--                      Standard api return status parameter.
--                      Values: fnd_api.g_ret_sts_success,
--                              fnd_api.g_ret_sts_error,
--                              fnd_api.g_ret_sts_unexp_error.
--
--
-- Version         : 1.0
--
-- Initial Version : 1.0
--
-- End of Comments.
--

    PROCEDURE get_predicate(
        p_api_version               IN  NUMBER,
        p_init_msg_list             IN  VARCHAR2,
        p_char_id                   IN  NUMBER,
        p_alias                     IN  VARCHAR2,
        x_predicate                 OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        x_return_status             OUT NOCOPY VARCHAR2);



END qa_performance_pub;

 

/
