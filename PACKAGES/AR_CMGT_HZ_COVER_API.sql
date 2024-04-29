--------------------------------------------------------
--  DDL for Package AR_CMGT_HZ_COVER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_HZ_COVER_API" AUTHID CURRENT_USER AS
/* $Header: ARCMHZCS.pls 120.2.12010000.2 2009/06/11 14:20:36 mraymond ship $  */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/


/*========================================================================
 | PUBLIC PROCEDURE
 |      update_organization()
 | DESCRIPTION
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_party_id          IN      resource_id
 |      p_year_established  IN
 |      p_url               IN
 |      p_sic_code_type     IN
 |      p_sic_code          IN
 |      p_tax_reference     IN
 |      p_duns_number_c     IN
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 |
 *=======================================================================*/
PROCEDURE update_organization(p_party_id           NUMBER,  --15
                              p_year_established   NUMBER := NULL,
                              p_employees_total    NUMBER := NULL,
                              p_url                VARCHAR2 := NULL,
                              p_sic_code_type      VARCHAR2 := NULL,
                              p_sic_code           VARCHAR2 := NULL ,
                              p_tax_reference      VARCHAR2  := NULL,
                              p_duns_number_c      VARCHAR2  := NULL
                             );

PROCEDURE create_party_profile(p_party_id IN   NUMBER,
                               p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE dump_api_output_data(p_return_status   VARCHAR2,
                            p_msg_count       NUMBER,
                            p_msg_data        VARCHAR2);
END AR_CMGT_HZ_COVER_API;

/
