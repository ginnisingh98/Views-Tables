--------------------------------------------------------
--  DDL for Package GR_RISK_SAFETY_PHRASES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_RISK_SAFETY_PHRASES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GRRISAPS.pls 120.0.12010000.2 2009/06/19 16:23:54 plowe noship $*/
/*#
 * This interface is used to create, delete, and validate risk and safety phrases.
 * This package defines and implements the procedures required
 * to create, delete, and validate risk and safety phrases.
 * @rep:scope public
 * @rep:product GR
 * @rep:lifecycle active
 * @rep:displayname GR Risk Safety Phrases Package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GR_RISK_SAFETY_PHRASES
 */



/*   Define Procedures And Functions :   */

 /*#
 * Inserts Risk and Safety Phrases
 * This is a PL/SQL procedure to create,update and delete risk and safety phrases.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_action Actions are I(insert),U(update),D(delete)
 * @param p_object Object types are C(code),L(language)
 * @param p_phrase_type Prhase Types are S(Safety Phrase),R(Risk Phrase)
 * @param p_phrase_code Risk or Safety phrase code
 * @param p_language Language in which Phrase text is inserted/updated
 * @param p_source_language Source language for Phrase text.
 * @param p_phrase_text Description for safety and risk phrases.
 * @param p_attribute1 to attribute30 Flexfield attributes
 * @param p_attribute_category structure of flex field
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Risk and Safety Phrases procedure
 * @rep:compatibility S  */



PROCEDURE RISK_SAFETY_PHRASES
( p_api_version           IN NUMBER
, p_init_msg_list         IN VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                IN VARCHAR2        DEFAULT FND_API.G_FALSE
, p_action                IN VARCHAR2
, p_object                IN VARCHAR2
, p_phrase_type           IN VARCHAR2
, p_phrase_code           IN VARCHAR2
, p_language              IN VARCHAR2
, p_source_language       IN VARCHAR2
, p_phrase_text           IN VARCHAR2
, p_attribute_category    IN VARCHAR2
, p_attribute1            IN VARCHAR2
, p_attribute2            IN VARCHAR2
, p_attribute3            IN VARCHAR2
, p_attribute4            IN VARCHAR2
, p_attribute5            IN VARCHAR2
, p_attribute6            IN VARCHAR2
, p_attribute7            IN VARCHAR2
, p_attribute8            IN VARCHAR2
, p_attribute9            IN VARCHAR2
, p_attribute10           IN VARCHAR2
, p_attribute11           IN VARCHAR2
, p_attribute12           IN VARCHAR2
, p_attribute13           IN VARCHAR2
, p_attribute14           IN VARCHAR2
, p_attribute15           IN VARCHAR2
, p_attribute16           IN VARCHAR2
, p_attribute17           IN VARCHAR2
, p_attribute18           IN VARCHAR2
, p_attribute19           IN VARCHAR2
, p_attribute20           IN VARCHAR2
, p_attribute21           IN VARCHAR2
, p_attribute22           IN VARCHAR2
, p_attribute23           IN VARCHAR2
, p_attribute24           IN VARCHAR2
, p_attribute25           IN VARCHAR2
, p_attribute26           IN VARCHAR2
, p_attribute27           IN VARCHAR2
, p_attribute28           IN VARCHAR2
, p_attribute29           IN VARCHAR2
, p_attribute30           IN VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2);

END GR_RISK_SAFETY_PHRASES_PUB;


/
