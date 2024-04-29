--------------------------------------------------------
--  DDL for Package OKS_RENEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RENEW_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRENWS.pls 120.1 2005/08/29 14:46:47 anjkumar noship $*/

--------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
G_FND_APP					CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
G_RECORD_LOGICALLY_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
G_REQUIRED_VALUE				CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE				CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN				CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN			CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN			CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR          		CONSTANT VARCHAR2(200) := 'OKS_RENEW_UNEXPECTED_ERROR';
G_EXPECTED_ERROR          		CONSTANT VARCHAR2(200) := 'OKS_RENEW_ERROR';
G_SQLCODE_TOKEN              		CONSTANT VARCHAR2(200) := 'SQLcode';
G_SQLERRM_TOKEN              		CONSTANT VARCHAR2(200) := 'SQLerrm';


---------------------------------------------------------------------------
-- GLOBAL EXCEPTIONS
---------------------------------------------------------------------------
G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;
G_EXCEPTION_ROLLBACK EXCEPTION;
G_ERROR	EXCEPTION;

---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_RENEW_PVT';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_NUM_ONE           CONSTANT NUMBER := 1;


PROCEDURE Debug_Log(p_program_name        IN VARCHAR2,
                    p_perf_msg            IN VARCHAR2 DEFAULT NULL,
                    p_error_msg           IN VARCHAR2 DEFAULT NULL,
                    p_path                IN VARCHAR2 DEFAULT NULL);

PROCEDURE Debug_Log(p_program_name        IN VARCHAR2,
                    p_perf_msg            IN VARCHAR2 DEFAULT NULL,
                    p_error_msg           IN VARCHAR2 DEFAULT NULL,
                    p_path                IN VARCHAR2 DEFAULT NULL,
                    x_msg_data            OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_return_status       OUT NOCOPY VARCHAR2);


END OKS_RENEW_PVT;

 

/
