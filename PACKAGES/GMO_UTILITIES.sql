--------------------------------------------------------
--  DDL for Package GMO_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: GMOUTILS.pls 120.1 2005/11/09 02:33 bchopra noship $ */

PROCEDURE GET_WHO_COLUMNS
(
         x_creation_date     out nocopy date,
         x_created_by        out nocopy number,
         x_last_update_date  out nocopy date,
         x_last_updated_by   out nocopy number,
         x_last_update_login out nocopy number
);

function GET_USER_DISPLAY_NAME (P_USER_NAME IN VARCHAR2) RETURN VARCHAR2;

function GET_USER_DISPLAY_NAME (P_USER_ID IN NUMBER) RETURN VARCHAR2;

PROCEDURE GET_USER_DISPLAY_NAME (P_USER_ID IN NUMBER, P_USER_DISPLAY_NAME OUT nocopy VARCHAR2);

PROCEDURE GET_MFG_LOOKUP
(
	P_LOOKUP_TYPE IN VARCHAR2,
        P_LOOKUP_CODE IN VARCHAR2,
        P_MEANING     OUT NOCOPY VARCHAR2
);

function GET_LOOKUP_MEANING (P_LOOKUP_TYPE IN VARCHAR2, P_LOOKUP_CODE IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE GET_LOOKUP
(
        P_LOOKUP_TYPE IN VARCHAR2,
        P_LOOKUP_CODE IN VARCHAR2,
        X_MEANING     OUT NOCOPY VARCHAR2
);

procedure get_organization (P_BATCH_ID IN NUMBER,
                            X_ORG_ID OUT NOCOPY NUMBER,
                            X_ORG_CODE OUT NOCOPY VARCHAR2,
                            X_ORG_NAME OUT NOCOPY VARCHAR2);

procedure get_organization (P_ORG_ID IN NUMBER,
                            X_ORG_CODE OUT NOCOPY VARCHAR2,
                            X_ORG_NAME OUT NOCOPY VARCHAR2);

END GMO_UTILITIES;

 

/
