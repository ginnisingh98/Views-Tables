--------------------------------------------------------
--  DDL for Package CS_SR_FUL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_FUL_PKG" AUTHID CURRENT_USER AS
/* $Header: csvsrfls.pls 120.2 2006/01/02 05:43:16 prayadur noship $ */

-- Procedure for testing a single SR request
PROCEDURE SR_SINGLE_REQUEST(P_API_VERSION in NUMBER,
					P_INCIDENT_ID in NUMBER,
					P_INCIDENT_NUMBER in VARCHAR2,
					P_USER_ID in NUMBER,
					P_EMAIL in VARCHAR2,
					P_SUBJECT in VARCHAR2,		--bug 4527968 prayadur
				     P_FAX in VARCHAR2,
					X_RETURN_STATUS out NOCOPY VARCHAR2,
					X_MSG_COUNT out NOCOPY number,
					X_MSG_DATA out NOCOPY varchar2
					);

PROCEDURE SR_RESUBMIT_REQUEST(P_API_VERSION  in NUMBER,
					P_REQUEST_ID in NUMBER,
					X_RETURN_STATUS out NOCOPY VARCHAR2,
					X_MSG_COUNT out NOCOPY number,
					X_MSG_DATA  out NOCOPY varchar2);

END CS_SR_FUL_PKG;
 

/
