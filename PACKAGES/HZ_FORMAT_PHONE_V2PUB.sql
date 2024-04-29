--------------------------------------------------------
--  DDL for Package HZ_FORMAT_PHONE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FORMAT_PHONE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPHFMS.pls 120.8 2006/08/17 10:18:21 idali noship $ */
/*#
 * This package contains the public APIs used to parse the phone number into country_code,
 * area_code, and phone_number and to format a phone number for display, based on the
 * appropriate phone formats.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Format Phone
 * @rep:category BUSINESS_ENTITY HZ_CONTACT_POINT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Phone Parsing and Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */


TYPE user_phone_preferences_rec IS RECORD (
    USER_TERRITORY_CODE             VARCHAR2(2),
    DEFAULT_AREA_CODE               VARCHAR2(10),
    DISPLAY_AREA_CODE               VARCHAR2(1),
    DISPLAY_ALL_PREFIXES            VARCHAR2(1),
    PABX_PREFIX                     VARCHAR2(1)
  );

/*#
 * Use this routine to parse a raw phone number into the country code, area code
 * and subscriber number, based on the setup of country and user phone
 * preferences. Raw phone numbers are an entered string of digits that must
 * include the subscriber number, and may include the international prefix,
 * trunk prefix, country code, and area code. Depending on the country, users can enter
 * phone numbers using different formats. This API is called from the
 * Contact Point API. The Contact Point API calls this API when creating or updating a
 * contact point of PHONE type and when the raw phone number is passed to the Contact Point
 * API. The Parse Phone Number API returns the parsed country code, area code, and
 * subscriber number to the Contact Point API, which then populates these columns in the
 * HZ_CONTACT_POINTS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Parse Phone Number
 * @rep:doccd 120hztig.pdf Phone Parsing and Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE phone_parse (
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_raw_phone_number        IN  VARCHAR2 := fnd_api.g_miss_char,
    p_territory_code          IN  VARCHAR2 := fnd_api.g_miss_char,
    x_phone_country_code      OUT NOCOPY VARCHAR2,
    x_phone_area_code         OUT NOCOPY VARCHAR2,
    x_phone_number            OUT NOCOPY VARCHAR2,
    x_mobile_flag             OUT NOCOPY VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2 );

PROCEDURE phone_display(
    p_init_msg_list          IN VARCHAR2 := fnd_api.g_false,
    p_contact_point_id       IN NUMBER,
    x_formatted_phone_number OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2 );

/*#
 * Use this routine to format a phone number for display, based on the
 * appropriate country phone format and the user's preferences. The format considers
 * which number segments to display as well as the inclusion of prefixes.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Format Phone Number
 * @rep:doccd 120hztig.pdf Phone Parsing and Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE phone_display(
    p_init_msg_list          IN VARCHAR2 := fnd_api.g_false,
    p_territory_code         IN VARCHAR2 := fnd_api.g_miss_char,
    p_phone_country_code     IN VARCHAR2 := fnd_api.g_miss_char,
    p_phone_area_code        IN VARCHAR2 := fnd_api.g_miss_char,
    p_phone_number           IN VARCHAR2 := fnd_api.g_miss_char,
    x_formatted_phone_number OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2 );


PROCEDURE check_mobile_phone (
     p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
     p_phone_country_code      IN  VARCHAR2 := fnd_api.g_miss_char,
     p_phone_area_code         IN  VARCHAR2 := fnd_api.g_miss_char,
     p_phone_number            IN  VARCHAR2 := fnd_api.g_miss_char,
     x_mobile_flag             OUT NOCOPY VARCHAR2,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2);

FUNCTION get_formatted_phone(
    p_contact_point_id       IN NUMBER,
    p_display_purpose        IN VARCHAR2 := fnd_api.g_true
) RETURN VARCHAR2;


/**
 * FUNCTION get_formatted_phone
 *
 * DESCRIPTION
 *    Overloaded function to return a formatted phone number.
 *
 * ARGUMENTS
 *   IN:
 *     p_phone_country_code     phone country code
 *     p_phone_area_code        phone area code
 *     p_phone_number           phone number
 *     p_phone_extension        phone extension
 *     p_phone_line_type        phone line type
 *     p_display_purpose        If the return is for display purpose.
 *                              When the value is FND_API.G_TRUE, return
 *                              formatted phone number (phone line type)
 *
 *   RETURNS    : VARCHAR2
 *
 */
FUNCTION get_formatted_phone (
    p_phone_country_code          IN     VARCHAR2,
    p_phone_area_code             IN     VARCHAR2,
    p_phone_number                IN     VARCHAR2,
    p_phone_extension             IN     VARCHAR2,
    p_phone_line_type             IN     VARCHAR2,
    p_display_purpose             IN     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;


end HZ_FORMAT_PHONE_V2PUB;

 

/
