--------------------------------------------------------
--  DDL for Package AST_WRAPUP_ADM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_WRAPUP_ADM_PVT" AUTHID CURRENT_USER AS
/* $Header: astvwuas.pls 115.3 2002/02/06 11:21:42 pkm ship      $ */

	PROCEDURE INSERT_OUTCOME(
		P_API_VERSION		            IN  NUMBER,
		P_INIT_MSG_LIST		            IN  VARCHAR2 := FND_API.G_FALSE,
		P_COMMIT		                IN  VARCHAR2 := FND_API.G_FALSE,
		P_VALIDATION_LEVEL	            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		X_RETURN_STATUS		            OUT VARCHAR2,
		X_MSG_COUNT		                OUT NUMBER,
		X_MSG_DATA		                OUT VARCHAR2,
        P_RESULT_REQUIRED               IN  VARCHAR2,
        P_VERSATILITY_CODE              IN  NUMBER,
        P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
        P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
        P_SCORE                         IN  NUMBER,
        P_POSITIVE_OUTCOME_FLAG         IN  VARCHAR2,
        P_LANGUAGE                      IN  VARCHAR2,
        P_LONG_DESCRIPTION              IN  VARCHAR2,
        P_SHORT_DESCRIPTION             IN  VARCHAR2,
        P_OUTCOME_CODE                  IN  VARCHAR2,
        P_MEDIA_TYPE                    IN  VARCHAR2,
        X_OUTCOME_ID                    OUT NUMBER
	);

    PROCEDURE UPDATE_OUTCOME(
	    P_API_VERSION			        IN  NUMBER,
	    P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	    X_RETURN_STATUS			        OUT VARCHAR2,
	    X_MSG_COUNT				        OUT NUMBER,
	    X_MSG_DATA				        OUT VARCHAR2,
        P_OUTCOME_ID                    IN  NUMBER,
        P_RESULT_REQUIRED               IN  VARCHAR2,
        P_VERSATILITY_CODE              IN  NUMBER,
        P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
        P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
        P_SCORE                         IN  NUMBER,
        P_POSITIVE_OUTCOME_FLAG         IN  VARCHAR2,
        P_LANGUAGE                      IN  VARCHAR2,
        P_LONG_DESCRIPTION              IN  VARCHAR2,
        P_SHORT_DESCRIPTION             IN  VARCHAR2,
        P_OUTCOME_CODE                  IN  VARCHAR2,
        P_MEDIA_TYPE                    IN  VARCHAR2
    );

	PROCEDURE INSERT_RESULT(
		P_API_VERSION		            IN  NUMBER,
		P_INIT_MSG_LIST		            IN  VARCHAR2 := FND_API.G_FALSE,
		P_COMMIT		                IN  VARCHAR2 := FND_API.G_FALSE,
		P_VALIDATION_LEVEL	            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		X_RETURN_STATUS		            OUT VARCHAR2,
		X_MSG_COUNT		                OUT NUMBER,
		X_MSG_DATA		                OUT VARCHAR2,
        P_REASON_REQUIRED               IN  VARCHAR2,
        P_VERSATILITY_CODE              IN  NUMBER,
        P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
        P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
        P_POSITIVE_RESULT_FLAG         IN  VARCHAR2,
        P_LANGUAGE                      IN  VARCHAR2,
        P_LONG_DESCRIPTION              IN  VARCHAR2,
        P_SHORT_DESCRIPTION             IN  VARCHAR2,
        P_RESULT_CODE                  IN  VARCHAR2,
        P_MEDIA_TYPE                    IN  VARCHAR2,
        X_RESULT_ID                    OUT NUMBER
	);

    PROCEDURE UPDATE_RESULT(
	    P_API_VERSION			        IN  NUMBER,
	    P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	    X_RETURN_STATUS			        OUT VARCHAR2,
	    X_MSG_COUNT				        OUT NUMBER,
	    X_MSG_DATA				        OUT VARCHAR2,
        P_RESULT_ID                    IN  NUMBER,
        P_REASON_REQUIRED               IN  VARCHAR2,
        P_VERSATILITY_CODE              IN  NUMBER,
        P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
        P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
        P_POSITIVE_RESULT_FLAG         IN  VARCHAR2,
        P_LANGUAGE                      IN  VARCHAR2,
        P_LONG_DESCRIPTION              IN  VARCHAR2,
        P_SHORT_DESCRIPTION             IN  VARCHAR2,
        P_RESULT_CODE                  IN  VARCHAR2,
        P_MEDIA_TYPE                    IN  VARCHAR2
    );

    PROCEDURE INSERT_REASON(
	    P_API_VERSION			        IN  NUMBER,
	    P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	    X_RETURN_STATUS			        OUT VARCHAR2,
	    X_MSG_COUNT				        OUT NUMBER,
	    X_MSG_DATA				        OUT VARCHAR2,
        P_VERSATILITY_CODE              IN  NUMBER,
        P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
        P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
        P_LANGUAGE                      IN  VARCHAR2,
        P_LONG_DESCRIPTION              IN  VARCHAR2,
        P_SHORT_DESCRIPTION             IN  VARCHAR2,
        P_REASON_CODE                   IN  VARCHAR2,
        P_MEDIA_TYPE                    IN  VARCHAR2,
        X_REASON_ID                     OUT NUMBER
    );

    PROCEDURE UPDATE_REASON(
	    P_API_VERSION			        IN  NUMBER,
	    P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	    X_RETURN_STATUS			        OUT VARCHAR2,
	    X_MSG_COUNT				        OUT NUMBER,
	    X_MSG_DATA				        OUT VARCHAR2,
        P_REASON_ID                    IN  NUMBER,
        P_VERSATILITY_CODE              IN  NUMBER,
        P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
        P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
        P_LANGUAGE                      IN  VARCHAR2,
        P_LONG_DESCRIPTION              IN  VARCHAR2,
        P_SHORT_DESCRIPTION             IN  VARCHAR2,
        P_REASON_CODE                  IN  VARCHAR2,
        P_MEDIA_TYPE                    IN  VARCHAR2
    );

    PROCEDURE ALTER_OUTCOME_RESULT_LINK(
	    P_API_VERSION			        IN  NUMBER,
	    P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	    X_RETURN_STATUS			        OUT VARCHAR2,
	    X_MSG_COUNT				        OUT NUMBER,
	    X_MSG_DATA				        OUT VARCHAR2,
        P_ACTION                        IN  VARCHAR2,
        P_OUTCOME_ID                    IN  NUMBER,
        P_RESULT_ID                     IN  NUMBER
    );

    PROCEDURE ALTER_RESULT_REASON_LINK(
	    P_API_VERSION			        IN  NUMBER,
	    P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	    P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	    X_RETURN_STATUS			        OUT VARCHAR2,
	    X_MSG_COUNT				        OUT NUMBER,
	    X_MSG_DATA				        OUT VARCHAR2,
        P_ACTION                        IN  VARCHAR2,
        P_RESULT_ID                     IN  NUMBER,
        P_REASON_ID                     IN  NUMBER
    );

END;

 

/
