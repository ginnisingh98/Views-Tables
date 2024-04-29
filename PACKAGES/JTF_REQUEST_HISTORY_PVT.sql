--------------------------------------------------------
--  DDL for Package JTF_REQUEST_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_REQUEST_HISTORY_PVT" AUTHID CURRENT_USER AS
 /* $Header: jtfgrqhs.pls 115.3 2003/09/05 19:41:14 sxkrishn ship $ */

 G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
 --===================================================================
 --    Start of Comments
 --   -------------------------------------------------------
 --    Record name
 --             request_history_rec_type
 --   -------------------------------------------------------
 --   Parameters:
 --       outcome_code
 --       source_code_id
 --       source_code
 --       object_type
 --       object_id
 --       order_id
 --       resubmit_count
 --       outcome_desc
 --       request
 --       submit_dt_tm
 --       server_id
 --       template_id
 --       app_info
 --       group_id
 --       hist_req_id
 --       user_id
 --       priority
 --       processed_dt_tm
 --       message_id
 --       last_update_date
 --       last_updated_by
 --       creation_date
 --       created_by
 --       last_update_login
 --       org_id
 --       f_deletedflag
 --       object_version_number
 --       security_group_id
 --
 --    Required
 --
 --    Defaults
 --
 --    Note: This is automatic generated record definition, it includes all columns
 --          defined in the table, developer must manually add or delete some of the attributes.
 --
 --   End of Comments

 --===================================================================
 TYPE request_history_rec_type IS RECORD
 (
        outcome_code                    VARCHAR2(50) ,
        source_code_id                  NUMBER,
        source_code                     VARCHAR2(30),
        object_type                     VARCHAR2(30),
        object_id                       NUMBER ,
        order_id                        NUMBER,
        resubmit_count                  NUMBER ,
        outcome_desc                    VARCHAR2(2000),
        request                         CLOB,
        submit_dt_tm                    DATE,
        server_id                       NUMBER,
        template_id                     NUMBER,
        app_info                        VARCHAR2(30),
        group_id                        NUMBER,
        hist_req_id                     NUMBER,
        user_id                         NUMBER,
        priority                        NUMBER,
        processed_dt_tm                 DATE,
        message_id                      RAW(16),
        last_update_date                DATE,
        last_updated_by                 NUMBER,
        creation_date                   DATE,
        created_by                      NUMBER,
        last_update_login               NUMBER,
        org_id                          NUMBER,
        f_deletedflag                   VARCHAR2(1),
        object_version_number           NUMBER,
        security_group_id               NUMBER
 );

 g_miss_request_history_rec          request_history_rec_type;
 TYPE  request_history_tbl_type      IS TABLE OF request_history_rec_type INDEX BY BINARY_INTEGER;
 g_miss_request_history_tbl          request_history_tbl_type;

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Request_History
 --   Type
 --           Private
 --   Pre-Req
 --
 --   Parameters
 --
 --   IN
 --       p_api_version_number      IN   NUMBER     Required
 --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
 --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
 --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
 --       p_request_history_rec            IN   request_history_rec_type  Required
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
 --         and basic operation, developer must manually add parameters and business logic as necessary.
 --
 --   End of Comments
 --   ==============================================================================
 --

 PROCEDURE Create_Request_History(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2 ,
     p_commit                     IN   VARCHAR2,
     p_validation_level           IN   NUMBER ,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_request_history_rec        IN   request_history_rec_type,
     x_request_history_id         OUT NOCOPY  NUMBER
      );


 END JTF_Request_History_PVT;


 

/
