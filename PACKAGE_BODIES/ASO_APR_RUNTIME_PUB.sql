--------------------------------------------------------
--  DDL for Package Body ASO_APR_RUNTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_RUNTIME_PUB" AS
/* $Header: asopappb.pls 120.1 2005/06/29 12:36:17 appldev noship $ */
-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ASO_APR_RUNTIME_PUB';
G_USER CONSTANT VARCHAR2(30)     := FND_GLOBAL.USER_ID;


-- ---------------------------------------------------------
-- Define Procedures
-- ---------------------------------------------------------

--------------------------------------------------------------------------
PROCEDURE SUBMIT_APPROVALS
(
 p_api_version            IN        NUMBER,
 p_init_msg_list          IN   VARCHAR2       DEFAULT FND_API.G_FALSE,
 p_commit                 IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
 x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_msg_count              OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 p_approval_object        IN   VARCHAR2,
 p_key_value1             IN   VARCHAR2,
 p_key_value2             IN   VARCHAR2,
 p_key_value3             IN   VARCHAR2,
 p_key_value4             IN   VARCHAR2,
 p_key_value5             IN   VARCHAR2,
 p_key_value6             IN   VARCHAR2,
 p_key_value7             IN   VARCHAR2,
 p_key_value8             IN   VARCHAR2,
 p_key_value9             IN   VARCHAR2,
 p_key_value10            IN   VARCHAR2,
 p_timeout                  IN   NUMBER
)
IS
l_api_name      CONSTANT  VARCHAR2(30)    := 'SUBMIT_APPROVALS';
l_api_version   CONSTANT                NUMBER                  := 1.0;
l_approval_id   number;
l_requestor     varchar2(30);
l_count         number;
l_aso_apr_approval_det_id number;
l_row_id        varchar2(30);
BEGIN
NULL;
END SUBMIT_APPROVALS;

END ASO_APR_RUNTIME_PUB;

/
