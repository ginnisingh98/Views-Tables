--------------------------------------------------------
--  DDL for Package IBY_EMAIL_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EMAIL_REPORT" AUTHID CURRENT_USER AS
/*$Header: ibyvmals.pls 115.1 2002/11/18 22:22:03 jleybovi noship $*/

------------------------------------------------------------------------
-- Constants Declaration
------------------------------------------------------------------------
     C_USERTYPE_ADHOC  CONSTANT  VARCHAR2(10) := 'ADHOC_USER';
     C_USERTYPE_REGISTERED  CONSTANT  VARCHAR2(10) := 'REGD_USER';

-------------------------------------------------------------------------
        --**Defining all DataStructures required by the APIs**--
--  The following input and output PL/SQL record/table types are defined
-- to store the User Information
-------------------------------------------------------------------------

--INPUT and OUTPUT DataStructures

  --1. Record Types

TYPE UserInfo_rec_type IS RECORD (
        username          VARCHAR2(100),
        emailaddr         VARCHAR2(200),
        usertype          VARCHAR2(10)
        );

   --2. Table Types

TYPE UserInfo_tbl_type IS TABLE OF UserInfo_rec_type;

-- 1. populate_userinfo
PROCEDURE populate_userinfo( email_users_str VARCHAR2);

--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
        -- 1. Send_Mail
        -- Start of comments
        --   API name        : Send_Mail
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Sends an email report.
        --   Parameters      :
        --   IN              : p_item_key          IN    VARCHAR2
        --                     p_user_name         IN    VARCHAR2
        --
        --   OUT             : x_return_status     OUT NOCOPY VARCHAR2
        --                     x_msg_count         OUT NOCOPY VARCHAR2
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
--------------------------------------------------------------------------------------
-- 1. Send_Mail
PROCEDURE Send_Mail (p_item_key      IN  VARCHAR2,
                     p_user_name     IN  VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER
	               );

--------------------------------------------------------------------------------------
        -- 2. Send_Report
        -- Start of comments
        --   API name        : Send_Report
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Implements Concurrent Program.
        --   Parameters      :
        --   IN              : p_email_users       IN    VARCHAR2
        --
        --   OUT             : ERRBUF              OUT NOCOPY VARCHAR2
        --                     RETCODE             OUT NOCOPY NUMBER
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
--------------------------------------------------------------------------------------
-- 2. Send_Report

Procedure Send_Report(ERRBUF                 OUT NOCOPY VARCHAR2,
                      RETCODE                OUT NOCOPY NUMBER,
                      p_email_users          IN    VARCHAR2
                     );

END IBY_EMAIL_REPORT;

 

/
