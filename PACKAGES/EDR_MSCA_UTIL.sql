--------------------------------------------------------
--  DDL for Package EDR_MSCA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_MSCA_UTIL" AUTHID CURRENT_USER AS
/* $Header: EDRVMTLS.pls 120.1.12000000.1 2007/01/18 05:56:34 appldev ship $ */


--Reference cursor which is used in LOV queries.
TYPE l_genref IS REF CURSOR;


--This proecdeure would obtain the e-record text for the specified e-record ID.

-- Start of comments
-- API name   : GET_ERECORD_TEXT
-- Type       : Private Utility.
-- Function   : Obtains the e-record text for s given e-record ID.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_erecord_id IN NUMBER - The e-record ID value

-- OUT        : x_text_erecord OUT NOCOPY VARCHAR2 - The e-record text.
--            : x_error_msg    OUT NOCOPY VARCHAR2 - The return message indicating success/error.

  PROCEDURE GET_ERECORD_TEXT(p_erecord_id   IN NUMBER,
                             x_text_erecord OUT NOCOPY VARCHAR2,
                             x_error_msg    OUT NOCOPY VARCHAR2);

--This procedeure would obtain all the lookup codes and corresponding meanings for
--the specified lookup type.

-- Start of comments
-- API name   : GET_LOOKUP
-- Type       : Private Utility.
-- Function   : Obtains the lookup details
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_lookup_type IN VARCHAR2 - The lookup type
--            : p_meaning     IN VARCHAR2 - The Entered meaning in lov

-- OUT        : x_lookup OUT NOCOPY L_GENREF - The lookup details

  PROCEDURE GET_LOOKUP(x_lookup      OUT NOCOPY L_GENREF,
                       p_lookup_type IN  VARCHAR2,
                       p_meaning     IN VARCHAR2);


--This procedeure would obtain all the lookup codes and corresponding meanings for
--the specified lookup type except that of the excluded lookup code

-- Start of comments
-- API name   : GET_LOOKUP
-- Type       : Private Utility.
-- Function   : Obtains the lookup details except of the excluded lookup code.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_lookup_type          IN VARCHAR2 - The lookup type
--            : p_excluded_lookup_code IN VARCHAR2 - The lookup code to be excluded
--            : p_meaning     IN VARCHAR2 - The Entered meaning in lov

-- OUT        : x_lookup OUT NOCOPY L_GENREF - The lookup details

  PROCEDURE GET_LOOKUP(x_lookup              OUT NOCOPY l_genref,
                       p_lookup_type         IN  VARCHAR2,
                       p_exclude_lookup_code IN VARCHAR2,
                       p_meaning             IN VARCHAR2);


--This procedure would obtain all the approvers for the specified transaction
--based on the event key.

-- Start of comments
-- API name   : GET_LOOKUP
-- Type       : Private Utility.
-- Function   : Obtains the lookup details
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_eventkey IN NUMBER - The event key value
--            : p_approverName IN VARCHAR2 : Approver Name from lov

-- OUT        : x_approvers OUT NOCOPY L_GENREF - The approver list.

  PROCEDURE GET_APPROVERS(x_approvers OUT NOCOPY l_genref,
                          p_eventkey  IN  NUMBER,
                          p_approverName   IN VARCHAR2);


--This procedeure would obtain all the forms based test scenario details.

-- Start of comments
-- API name   : GET_TEST_SCENARIO_DETAILS
-- Type       : Private Utility.
-- Function   : Obtains the FORMS based test scenario details.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : NONE

-- OUT        : x_test_scenario_details OUT NOCOPY L_GENREF - The test scenario details

  PROCEDURE GET_TEST_SCENARIO_DETAILS( x_test_scenario_details OUT NOCOPY l_genref);

END EDR_MSCA_UTIL;

 

/
