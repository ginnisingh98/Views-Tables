--------------------------------------------------------
--  DDL for Package PA_DRAFT_REVENUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DRAFT_REVENUES_PKG" AUTHID CURRENT_USER as
/* $Header: PAXRVUTS.pls 120.1 2005/08/05 02:12:29 bchandra noship $ */

 /*
 ** INITIALIZE - set up function security for current user
 **/
 procedure INITIALIZE;

 /*
 ** ALLOW_RELEASE - check whether the user is allowd to release
 **                 the draft revenue.  If not, an error message is put
 **                 in the message stack for the client-side to retrieve.
 **/
 function ALLOW_RELEASE(
		X_PROJECT_ID		in NUMBER,
		X_DRAFT_REVENUE_NUM	in NUMBER)
	return BOOLEAN;

 /*
 ** ALLOW_UNRELEASE - check whether the user is allowd to unrelease
 **                   the draft revenue.  If not, an error message is put
 **                   in the message stack for the client-side to retrieve.
 **/
 function ALLOW_UNRELEASE(
		X_PROJECT_ID		in NUMBER,
		X_DRAFT_REVENUE_NUM	in NUMBER)
	return BOOLEAN;

 /*
 ** RELEASE - release the draft revenue
 **/
 procedure RELEASE(
		X_PROJECT_ID		in     NUMBER,
		X_DRAFT_REVENUE_NUM	in     NUMBER,
                X_ERR_CODE		in out NOCOPY  NUMBER);


 /*
 ** UNRELEASE - unrelease the draft revenue
 **/
 procedure UNRELEASE(
		X_PROJECT_ID		in     NUMBER,
		X_DRAFT_REVENUE_NUM	in     NUMBER,
                X_ERR_CODE		in out NOCOPY  NUMBER);

end pa_draft_revenues_pkg;

 

/
