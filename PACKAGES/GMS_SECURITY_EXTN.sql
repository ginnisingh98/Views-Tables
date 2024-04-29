--------------------------------------------------------
--  DDL for Package GMS_SECURITY_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_SECURITY_EXTN" AUTHID CURRENT_USER AS
/* $Header: gmsseexs.pls 120.3 2006/08/24 13:05:35 smaroju ship $ */
/*#
 * This extension enables users to override the default award security or to add additional award security
 * criteria by implementing customized award security business rules.
 * @rep:scope public
 * @rep:product GMS
 * @rep:lifecycle active
 * @rep:displayname Award Security Client Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMS_AWARD
 * @rep:doccd 120gmsug.pdf See the Oracle Oracle Grants Accounting User's Guide
*/
/*#
 * This procedure implements the award security extension.
 * @param X_award_id Identifier of the award or identifier of the award template
 * @rep:paraminfo  {@rep:required}
 * @param X_person_id Identifier of the person
 * @rep:paraminfo {@rep:required}
 * @param X_calling_module Module in which the award security extension is called.Grants
 * Accounting sets this value for each module in which it calls the security extension
 * @rep:paraminfo  {@rep:required}
 * @param X_event Identifier of the type of query level to check.It can take following
 * specific rules: ALLOW_QUERY, ALLOW_UPDATE
 * @rep:paraminfo  {@rep:required}
 * @param X_value Specifies the result of the event: Y indicates event is
 * allowed in the calling module for this person for the specific award. N indicates event
 * is disallowed in the calling module for this person for the specific award
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Award Access
 * @rep:compatibility S
*/

  PROCEDURE check_award_access ( X_award_id		IN NUMBER
                                 , X_person_id          IN NUMBER
                                 , X_calling_module	IN VARCHAR2
	                         , X_event              IN VARCHAR2
                                 , X_value              OUT NOCOPY VARCHAR2 );
  pragma RESTRICT_REFERENCES ( check_award_access, WNDS, WNPS );

END gms_security_extn;

 

/
