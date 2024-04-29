--------------------------------------------------------
--  DDL for Package HZ_CONTACT_PREFERENCE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_PREFERENCE_V2PUB" AUTHID CURRENT_USER AS
/* $Header: ARH2CTSS.pls 120.7 2006/08/17 10:16:10 idali noship $ */
/*#
 * This package contains the public APIs for contact preference.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Contact Preference
 * @rep:category BUSINESS_ENTITY HZ_CONTACT_PREFERENCE
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Contact Preference APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

TYPE contact_preference_rec_type IS RECORD (

contact_preference_id	    NUMBER,
contact_level_table	    VARCHAR2(30),
contact_level_table_id	    NUMBER,
contact_type		    VARCHAR2(30),
preference_code		    VARCHAR2(30),
preference_topic_type	    VARCHAR2(30),
preference_topic_type_id    NUMBER,
preference_topic_type_code  VARCHAR2(30),
preference_start_date	    DATE,
preference_end_date	    DATE,
preference_start_time_hr    NUMBER,
preference_end_time_hr	    NUMBER,
preference_start_time_mi    NUMBER,
preference_end_time_mi      NUMBER,
max_no_of_interactions	    NUMBER,
max_no_of_interact_uom_code VARCHAR2(30),
requested_by		    VARCHAR2(30),
reason_code		    VARCHAR2(30),
status		            VARCHAR2(1),
created_by_module           VARCHAR2(150),
application_id              NUMBER

);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_contact_preference
 *
 * DESCRIPTION
 *     Creates contact preference
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_contact_preference_rec       Contact preference record.
 *   IN/OUT:
 *   OUT:
 *     x_contact_preference_id        contact preference ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JUL-2001    Kate Shan         o Created.
 *
 */

/*#
 * Use this routine to create a contact preference. This API creates records in the
 * HZ_CONTACT_PREFERENCES table. You can create contact preferences for a party, party
 * site, or contact point.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Contact Preference
 * @rep:businessevent oracle.apps.ar.hz.ContactPreference.create
 * @rep:doccd 120hztig.pdf Contact Preference APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_contact_preference (
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_contact_preference_rec    IN      CONTACT_PREFERENCE_REC_TYPE,
    x_contact_preference_id     OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_contact_preference
 *
 * DESCRIPTION
 *     Updates contact preference
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_contact_preference_rec       Contact Preference record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Kate Shan        o Created.
 *
 */

/*#
 * Use this routine to update a contact preference. This API updates records in the
 * HZ_CONTACT_PREFERENCES table for a party, party site or contact point.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Contact Preference
 * @rep:businessevent oracle.apps.ar.hz.ContactPreference.update
 * @rep:doccd 120hztig.pdf Contact Preference APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE  update_contact_preference (
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_contact_preference_rec                IN      CONTACT_PREFERENCE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_contact_preference_rec
 *
 * DESCRIPTION
 *      Gets contact preference record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_contact_preference_id        Contact preference id.
 *   IN/OUT:
 *   OUT:
 *     x_contact_preference_rec       Returned contact preference record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Kate Shan         o Created.
 *
 */

PROCEDURE get_contact_preference_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_contact_preference_id                 IN     NUMBER,
    x_contact_preference_rec                OUT    NOCOPY CONTACT_PREFERENCE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);


END HZ_CONTACT_PREFERENCE_V2PUB;

 

/
