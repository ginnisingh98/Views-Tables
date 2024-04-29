--------------------------------------------------------
--  DDL for Package AMS_RUNTIME_SCRIPTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_RUNTIME_SCRIPTING_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvsces.pls 115.1 2002/12/11 14:13:43 sanshuma noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_RUNTIME_SCRIPTING_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- ===============================================================


-----------------------------------------------------------------------
-- PROCEDURE
--    notifyForgetLogin
--
-- PURPOSE
--    Sends email to user with given email address
--
-- NOTES
--
-----------------------------------------------------------------------
PROCEDURE notifyForgetLogin(
      p_api_version           IN      NUMBER,
      p_init_msg_list         IN      VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                IN      VARCHAR2 DEFAULT fnd_api.g_false,
      p_user_name             IN      VARCHAR2,
      p_password              IN      VARCHAR2,
      p_email_address         IN      VARCHAR2,
      p_subject               IN      VARCHAR2,
      p_uname_label           IN      VARCHAR2,
      p_pwd_label             IN      VARCHAR2,
      x_return_status         OUT     NOCOPY VARCHAR2,
      x_msg_count             OUT     NOCOPY NUMBER,
      x_msg_data              OUT     NOCOPY VARCHAR2
);


END AMS_RUNTIME_SCRIPTING_PVT;

 

/
