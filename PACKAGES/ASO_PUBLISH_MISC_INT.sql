--------------------------------------------------------
--  DDL for Package ASO_PUBLISH_MISC_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PUBLISH_MISC_INT" AUTHID CURRENT_USER as
/* $Header: asoipmss.pls 120.3.12010000.2 2008/09/08 05:22:05 ajosephg ship $ */

--   API Name:  NotifyUserForRegistration
--   Type    :  Public
--   Pre-Req :  Workflow template for the notification should be there in the DB

PROCEDURE NotifyUserForRegistration(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_quote_id          IN   NUMBER,
     p_Send_Name         IN   Varchar2,
     p_Store_Name        IN   Varchar2,
     p_Store_Website     IN   Varchar2,
     p_FND_Password      IN   Varchar2,
     p_email_address     IN   varchar2 := null,
     p_email_language    IN   varchar2 := null,
     x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
     );

--   API Name:  NotifyForQuotePublish
--   Type    :  Public
--   Pre-Req :  Workflow template for the notification should be there in the DB

PROCEDURE NotifyForQuotePublish(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_quote_id          IN   NUMBER,
     p_Send_Name         IN   Varchar2,
     p_Comments          IN   Varchar2,
     p_Store_Name        IN   Varchar2,
     p_Store_Website     IN   Varchar2,
     p_url               IN   Varchar2,
     x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
     );


--   API Name:  getUserType
--   Type    :  Public
--   Pre-Req :  No

Procedure getUserType(
    pPartyId    IN Varchar2,
    pUserType   OUT NOCOPY /* file.sql.39 change */   Varchar2
    );

--   API Name:  GetFirstName
--   Type    :  Public
--   Pre-Req :  No

PROCEDURE GetFirstName(
	document_id	    IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	document_type IN OUT NOCOPY /* file.sql.39 change */  	VARCHAR2
    );


--   API Name:  GetLastName
--   Type    :  Public
--   Pre-Req :  No

PROCEDURE GetLastName(
	document_id    IN        VARCHAR2,
	display_type   IN        VARCHAR2,
	document       IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type  IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );


--   API Name:  getUserType
--   Type    :  Public
--   Pre-Req :  No

PROCEDURE GetTitle(
    document_id    IN        VARCHAR2,
    display_type   IN        VARCHAR2,
    document       IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    document_type  IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );

--   API Name:  GetStoreName
--   Type    :  Public
--   Pre-Req :  No

PROCEDURE GetStoreName(
    document_id    IN        VARCHAR2,
    display_type   IN        VARCHAR2,
    document       IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    document_type  IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );


/*
PROCEDURE PublishQuoteLocal(
    p_quote_header_id   IN  NUMBER,
    p_publish_flag      IN  VARCHAR2,
    p_last_update_date  IN  DATE
    );
*/

procedure createStoreUser
(
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_user_name                 IN       VARCHAR2,
    p_user_password             IN       VARCHAR2,
    p_email_address             IN       VARCHAR2 DEFAULT  NULL, /*  Add for Bug 7334453  */
    p_email_language            IN       VARCHAR2,
    p_party_id                  IN       NUMBER,
    p_party_type                IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);



--sunder -- added wrapper for sso changes 7/21
--
PROCEDURE TestUserName(
        p_user_name IN VARCHAR2,
        x_test_user_status OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
        );

END aso_publish_misc_int;

/
