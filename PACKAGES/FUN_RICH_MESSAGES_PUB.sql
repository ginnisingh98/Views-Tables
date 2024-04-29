--------------------------------------------------------
--  DDL for Package FUN_RICH_MESSAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RICH_MESSAGES_PUB" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULRTMPUS.pls 120.2.12010000.2 2008/08/06 07:45:15 makansal ship $ */
/*
 * This package contains the public APIs for Rich Text Messages.
 * @rep:scope internal
 * @rep:product FUN
 * @rep:displayname Fun:Rich Text Message
 * @rep:category BUSINESS_ENTITY FUN_RICH_MESSAGES
 * @rep:lifecycle active
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE rich_messages_rec_type IS RECORD (
   application_id   		NUMBER,
   message_name                 VARCHAR2(30),
   created_by_module            VARCHAR2(150)
);


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------


/**
 * Use this routine to create a Rich Text Message its related information.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Rich Text Messages
 * @rep:businessevent
 * @rep:doccd
 * @param p_rich_messages_rec      PLSQL record of the Rich Text Message
 * @param p_message_text           Text of the Rich Text Message
 * @param x_message_name           Name of the Rich Text Message
 * @param x_rich_messages_rec PLSQL Record of the Message
 */

PROCEDURE create_rich_messages(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rich_messages_rec     		 IN      RICH_MESSAGES_REC_TYPE,
    p_message_text                       IN      CLOB,
    x_message_name                       OUT NOCOPY    VARCHAR2,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);


/**
 * Use this routine to update a Rich text Message. The API updates records in the
 * FUN_RICH_MESSAGES table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Rich Text Messages
 * @rep:businessevent
 * @rep:doccd
 * @rep:displayname Update Rich message
 * @param p_rich_messages_rec      PLSQL record of the Rich Message
 * @param p_message_text           Text of the Message
 * @param p_object_version_number  Object Version Number
 * @param x_rich_messages_rec PLSQL Record of the Message
 */
PROCEDURE update_rich_messages(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rich_messages_rec    		 IN      RICH_MESSAGES_REC_TYPE,
    p_message_text                       IN      CLOB,
    p_object_version_number  		 IN OUT NOCOPY  NUMBER,
    x_return_status       		 OUT NOCOPY     VARCHAR2,
    x_msg_count           		 OUT NOCOPY     NUMBER,
    x_msg_data         			 OUT NOCOPY     VARCHAR2
);

/**
 * Use this routine to Select a Rich Text Message. The API Select records From the
 * FUN_RICH_MESSAGES table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Display Rich Text Message
 * @rep:businessevent
 * @rep:doccd
 * @param p_message_name      Name of the Message
 * @param x_message_text      Text of the Message
 * @param p_application_id    Application id of the Message
 * @param x_rich_messages_rec PLSQL Record of the Message
 * @rep:displayname Get Rich message
 */

PROCEDURE get_rich_messages_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_message_name                          IN     VARCHAR2,
    p_application_id                        IN     NUMBER,
    x_message_text                          OUT    NOCOPY CLOB,
    x_rich_messages_rec        		    OUT    NOCOPY RICH_MESSAGES_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * Use this routine to delete a Rich Text Message. The API deletes records in the
 * FUN_RICH_MESSAGES table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Rich Text Message
 * @rep:businessevent
 * @rep:doccd
 * @param p_message_name      Name of the Message
 * @param p_language_code     Language code of the Message
 * @param p_application_id    Application id of the Message
 * @rep:displayname Delete Rich message
 */

PROCEDURE delete_rich_messages(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_message_name            IN        VARCHAR2,
    p_language_code           IN        VARCHAR2,
    p_application_id	      IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
);

END FUN_RICH_MESSAGES_PUB;

/
