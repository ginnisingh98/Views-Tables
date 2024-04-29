--------------------------------------------------------
--  DDL for Package IEC_AORECDNU_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_AORECDNU_PUB" AUTHID CURRENT_USER AS
/* $Header: IECRDPBS.pls 115.2 2004/05/18 19:56:40 minwang noship $ */

-- Start of comments
-- Procedure : SetAORecDNU
-- Type : Public API
-- Usage : Makes Record mark as do_not_use with specified do not use reason
--
-- Standard IN Parameters:
-- p_api_version IN NUMBER Required
-- p_init_msg_list IN VARCHAR2(1) Required
-- pass in FND_API.G_FALSE  or FND_API.G_TRUE
-- p_commit IN VARCHAR2(1) Required
-- pass in FND_API.G_FALSE  or FND_API.G_TRUE
--
-- Standard OUT Parameters:
-- x_return_status OUT VARCHAR2(1)
-- x_msg_count OUT NUMBER
-- x_msg_data OUT VARCHAR2(2000)
--
-- Other IN Parameters:
-- p_user_id IN NUMBER Required
-- Corresponds to the column USER_ID in the table
-- FND_USER, and identifies the Oracle
-- Applications user

-- p_login_id IN NUMBER Optional
-- Corresponds to the column LOGIN_ID in the
-- table FND_LOGINS, and identifies the login session
-- Default = FND_GLOBAL.LOGIN_ID or NULL

-- p_list_entry_id IN NUMBER Required
-- p_list_header_id IN NUMBER Required

-- p_dnu_reason_code IN NUMBER DEFAULT null
-- dnu_reason_code is seeded in fnd_lookups with lookup_type='IEC_DNU_REASON'
--
-- Version : Initial version 1.0
--
-- End of comments

PROCEDURE SetAORecDNU
(
	p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
	p_commit IN VARCHAR2,
	p_user_id IN NUMBER,
	p_login_id IN NUMBER DEFAULT NULL,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	p_list_entry_id IN NUMBER,
	p_list_header_id IN NUMBER,
	p_dnu_reason_code IN NUMBER DEFAULT NULL
);

END IEC_AORECDNU_PUB;

 

/
