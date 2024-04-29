--------------------------------------------------------
--  DDL for Package ZX_API_PRVDR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_API_PRVDR_PUB" AUTHID CURRENT_USER AS
/* $Header: zxifprvdrsrvpubs.pls 120.0 2005/02/11 23:11:57 vsidhart ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

 TYPE ERROR_MESSAGES_TBL is TABLE OF VARCHAR2(1000)
  INDEX BY BINARY_INTEGER;
/* ==============================================*
 |           Procedure definition                |
 * ==============================================*/

PROCEDURE create_srvc_registration (
p_api_version	  IN  NUMBER,
x_error_msg_tbl   OUT NOCOPY error_messages_tbl,
x_return_status   OUT NOCOPY VARCHAR2,
p_srvc_prvdr_name IN  VARCHAR2,
p_srvc_type_code  IN  VARCHAR2,
p_country_code    IN  VARCHAR2,
p_business_flow   IN  VARCHAR2,
p_package_name    IN  VARCHAR2,
p_procedure_name  IN  VARCHAR2
 ) ;

PROCEDURE delete_srvc_registration (
p_api_version	  IN  NUMBER,
x_error_msg_tbl   OUT NOCOPY error_messages_tbl,
x_return_status   OUT NOCOPY VARCHAR2,
p_srvc_prvdr_name IN  VARCHAR2,
p_srvc_type_code  IN  VARCHAR2,
p_country_code    IN  VARCHAR2,
p_business_flow   IN  VARCHAR2
);

PROCEDURE execute_srvc_plugin  (
p_api_version	  IN  NUMBER,
x_error_msg_tbl   OUT NOCOPY error_messages_tbl,
x_return_status   OUT NOCOPY VARCHAR2,
p_srvc_prvdr_name IN  VARCHAR2
);

END ZX_API_PRVDR_PUB;


 

/
