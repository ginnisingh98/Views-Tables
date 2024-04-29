--------------------------------------------------------
--  DDL for Package ASO_APR_RUNTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_RUNTIME_PUB" AUTHID CURRENT_USER AS
/* $Header: asopapps.pls 120.1 2005/06/29 12:36:20 appldev noship $ */
-- ---------------------------------------------------------
-- Declare Procedures
------------------------------------------------------------

--------------------------------------------------------------------------
PROCEDURE SUBMIT_APPROVALS
(
 p_api_version                     IN        NUMBER,
 p_init_msg_list                   IN   VARCHAR2       DEFAULT FND_API.G_FALSE,
 p_commit                          IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
 x_return_status                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_msg_count                       OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
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
);

END ASO_APR_RUNTIME_PUB;

 

/
