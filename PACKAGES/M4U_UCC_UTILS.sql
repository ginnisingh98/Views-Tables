--------------------------------------------------------
--  DDL for Package M4U_UCC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_UCC_UTILS" AUTHID CURRENT_USER AS
/* $Header: m4uutils.pls 120.1 2006/01/05 04:18:00 rkrishan noship $ */
       /*#
         * This package contains utility routines which are invoked from the
         * M4U XML Gateway Message maps.
         * @rep:scope private
         * @rep:product CLN
         * @rep:displayname M4U utility APIs invoked from XMLGateway message-maps.
         * @rep:category BUSINESS_ENTITY EGO_ITEM
         */

        c_resp_appl_id          CONSTANT NUMBER       := 431;
        c_party_type            CONSTANT VARCHAR2(1)  := 'I';
        c_party_site_name       CONSTANT VARCHAR2(30) := 'UCCNET';
        c_document_type         CONSTANT VARCHAR2(30) := 'M4U';
        c_coll_point            CONSTANT VARCHAR2(10) := 'APPS';

        g_org_id                VARCHAR2(50);
        g_party_id              VARCHAR2(40);
        g_party_site_id         VARCHAR2(40);
        g_host_gln              VARCHAR2(50);
        g_supp_gln              VARCHAR2(50);
        g_local_system          wf_systems.name%TYPE;



        /*#
         * Converts Oracle date to UCCnet date format.
         * @param p_ora_date Input date in Oracle format
         * @param x_ucc_date Output date string in UCCnet format
         * @rep:displayname Convert Oracle date value to UCCnet date string
         */
        PROCEDURE convert_to_uccnet_date (p_ora_date    IN      DATE,
                                  x_ucc_date    OUT     NOCOPY VARCHAR2
                                              );
        /*#
         * Converts Oracle date-time to UCCnet date-time format.
         * @param p_ora_date Input date-time in Oracle format
         * @param x_ucc_date Output date-time string in UCCnet format
         * @rep:displayname Convert Oracle date-time value to UCCnet date string
         */
        PROCEDURE convert_to_uccnet_datetime (p_ora_date        IN      DATE,
                                      x_ucc_date        OUT     NOCOPY VARCHAR2
                                      );

        /*#
         * Returns FND lookup meaning corresponding to input lookup type, code combination.
         * @param p_lookup_type FND lookup type, to wghich the lookup code belongs
         * @param p_lookup_code FND lookup code, whose meaning is to be queried
         * @return The FND lookup meaning
         * @rep:displayname Get FND lookup meaning.
         */
        FUNCTION get_lookup_meaning( p_lookup_type VARCHAR2, p_lookup_code VARCHAR)
          RETURN VARCHAR2;

        /*#
         * Returns the server date in UCCnet date format.
         * @return The server date in UCCnet date format
         * @rep:displayname Get sysdate.
         */
        FUNCTION get_sys_date   RETURN VARCHAR2;

        /*#
         * Returns the server time-zone indicator.
         * @return The server time zone.
         * @rep:displayname Get time-zone.
         */
        FUNCTION get_time_zone  RETURN VARCHAR2;

        /*#
         * Returns the current system time in UCCnet time format
         * @return The current system time in UCCnet time format
         * @rep:displayname Get system time.
         */
        FUNCTION get_time       RETURN VARCHAR2;

        /*#
         * Wrapper around sys_guid function call, returns Oracle generated GUID.
         * @return The GUID
         * @rep:displayname Get system generated GUID.
         */
        FUNCTION get_guid       RETURN VARCHAR2;


        /*#
         * Calculate the status type of an item
         * @param p_cancel_date Input date-time in Oracle format
         * @param p_discontinue_date Input date-time in Oracle format
         * @param x_catalogue_item_status Output varchar string
         * @rep:displayname Process Catalogue Item Status
         */
        PROCEDURE process_catalogue_item_status(
                p_cancel_date                   IN  DATE,
                p_discontinue_date              IN  DATE,
                x_catalogue_item_status         OUT NOCOPY VARCHAR2
        );

        /*#
         * converts the date from string to date format
         * @param p_string API input string format of date
         * @return The date format of the input string.
         * @rep:scope private
         * @rep:displayname Get date format of the string.
         */
        FUNCTION CONVERT_TO_DATE(
              p_string                 VARCHAR2
        ) RETURN DATE;


        /*#
         * Form a string representing the industry extensions supported
         * from the input value for XSLT processing.
         * @param p_industry_column Input Varchar String
         * @param x_mutiple_industry_ext Output Varchar String
         * @rep:displayname Format Industry Extension String
         */
        PROCEDURE format_industry_ext_string(
                p_industry_column               IN         VARCHAR2,
                x_mutiple_industry_ext          OUT NOCOPY VARCHAR2
        );



        -- Name
        --      validate_uccnet_attr
        -- Purpose
        --      This procedure is used for validating the GTIN/GLN at the moment
        -- Arguments
        -- Notes
        --
        /*#
         * Validates the given UCCnet attribute(GLN or GTIN). Returns 'true' if validation succeeds
         * else returns 'false'.
         * @param x_return_status API return status
         * @param x_msg_data Error/Success message
         * @param p_attr_type UCCnet attribute type being validated.(GLN/GTIN)
         * @param p_attr_value UCCnet atttribute value being validated.
         * @return Validation true/false.
         * @rep:scope private
         * @rep:displayname Validate UCCnet attributes.
        */
        FUNCTION validate_uccnet_attr(
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_attr_type             IN  VARCHAR2,
                p_attr_value            IN  VARCHAR2
          )RETURN BOOLEAN;

END m4u_ucc_utils;

 

/
