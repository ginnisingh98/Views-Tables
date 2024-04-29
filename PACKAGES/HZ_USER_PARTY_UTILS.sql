--------------------------------------------------------
--  DDL for Package HZ_USER_PARTY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_USER_PARTY_UTILS" AUTHID CURRENT_USER AS
/* $Header: ARHUSRPS.pls 120.1 2005/06/16 21:16:16 jhuang noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC procedure get_user_party_id
 |
 | DESCRIPTION
 |      Tries to find a party based on email-address. If party is found
 |      the party id is returned. If the party is NOT found a new party
 |      is created and party id returned.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   pv_user_name          User Name
 |   pv_first_name         First Name
 |   pv_last_name          Last Name
 |   pv_party_email        Email address
 |
 | RETURNS
 |   pn_party_id      Party Identifier
 |   pv_return_status Return status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2001           J Rautiainen      Created
 *=======================================================================*/
PROCEDURE get_user_party_id(pv_user_name         IN  VARCHAR2,
                            pv_first_name        IN  VARCHAR2,
                            pv_last_name         IN  VARCHAR2,
                            pv_email_address     IN  VARCHAR2,
                            pn_party_id          OUT NOCOPY NUMBER,
                            pv_return_status     OUT NOCOPY VARCHAR2);

END HZ_USER_PARTY_UTILS;

 

/
