--------------------------------------------------------
--  DDL for Package FUN_RULE_MSG_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_MSG_HANDLER_PKG" AUTHID CURRENT_USER AS
/* $Header: FUNXTMRULMSGHNS.pls 120.0 2005/06/20 04:29:55 ammishra noship $ */

PROCEDURE DoesMessageExist(p_applicationid      IN         FND_NEW_MESSAGES.APPLICATION_ID%TYPE,
                           p_messagetext        IN         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
                           p_languagecode       IN         FND_NEW_MESSAGES.LANGUAGE_CODE%TYPE,
                           p_messagename        OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_NAME%TYPE);


PROCEDURE CreateNewMessage(p_applicationid      IN         FND_NEW_MESSAGES.APPLICATION_ID%TYPE,
                           p_ruledetailid       IN         FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
                           p_messagetext        IN         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
                           p_languagecode       IN         FND_NEW_MESSAGES.LANGUAGE_CODE%TYPE,
                           p_messagename        OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_NAME%TYPE);

PROCEDURE GetMessageFromRuleDetail(p_ruledetailid       IN         FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
                                   p_messagename        OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_NAME%TYPE);


PROCEDURE DoUpdateRuleTables(p_ruleobjectid       IN         FUN_RULE_OBJECTS_B.RULE_OBJECT_ID%TYPE,
                             p_ruledetailid       IN         FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
                             p_applicationid      IN         FND_NEW_MESSAGES.APPLICATION_ID%TYPE,
                             p_messagename        IN         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE);

PROCEDURE updateExistingMessage(p_ruledetailid       IN         FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
                                p_languagecode       IN         FND_NEW_MESSAGES.LANGUAGE_CODE%TYPE,
                                p_messagetext        IN         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE);




END FUN_RULE_MSG_HANDLER_PKG;

 

/
