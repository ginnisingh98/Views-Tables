--------------------------------------------------------
--  DDL for Package OKC_XPRT_CUSTOM_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_CUSTOM_PACKAGE" AUTHID CURRENT_USER AS
/* $Header: okcxprtudvtestprocs.pls 120.0 2007/03/23 16:17:33 jkodiyan noship $ */

    PROCEDURE GET_OE_HEADER_VALUES (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE		IN VARCHAR2,
	    X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

    PROCEDURE GET_PRICE_UPDATE_TOLERANCE (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE		IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

	PROCEDURE GET_QUOTE_SALES_SUPPLEMENT (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE		IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

	        PROCEDURE GET_SHIP_WAREHOUSE (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

        PROCEDURE GET_SOURCING_UOM (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

	       PROCEDURE GET_PO_UOM (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

       PROCEDURE GET_RELEASE_RATIO (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

	           PROCEDURE GET_BLANKET_AMOUNT_RANGE (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

           PROCEDURE GET_DFF_PO (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);

           PROCEDURE GET_DFF_SA (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	);



END OKC_XPRT_CUSTOM_PACKAGE;

/