--------------------------------------------------------
--  DDL for Package AMW_LOAD_AUDIT_PROCEDURE_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_AUDIT_PROCEDURE_DATA" AUTHID CURRENT_USER AS
/* $Header: amwaprs.pls 120.0 2005/05/31 21:40:33 appldev noship $ */
-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             fnd_attachment_rec_type
--   -------------------------------------------------------

--===================================================================
TYPE fnd_attachment_rec_type IS RECORD
(
       rowid                           varchar2(100),
       document_id                     NUMBER,
       datatype_id                     Number,
       category_id                     Number := 1,/* default 1 => Misc */
       security_type                   Number := 4,/* default 4 => None */
       publish_flag                    Varchar(1):= 'Y',/*default Y */
       description                     VARCHAR2(255),
       file_name                       VARCHAR2(2048),
       media_id                        Number,
       file_size                       Varchar2(150),/* doc_attribute2 is used */
       attached_document_id            Number,
       seq_num                         Number,
       entity_name                     Varchar2(40),/* doc_attribute2 is used */
       PK1_VALUE                       Varchar2(100),
       PK2_VALUE                       Varchar2(100),
       PK3_VALUE                       Varchar2(100),
       PK4_VALUE                       Varchar2(100),
       PK5_VALUE                       Varchar2(100),
       automatically_added_flag        Varchar2(1) := 'N',
       short_text                      Varchar2(2000),
       last_update_date                Date,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       attachment_type                 VARCHAR2(30),
       language                        varchar2(30) := 'US',
       usage_type                      varchar2(30) := 'O'
);



PROCEDURE update_apr(
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
     ,p_user_id    IN              NUMBER
   );
   PROCEDURE update_interface_with_error (
      p_err_msg        IN   VARCHAR2
      ,p_interface_id   IN   NUMBER
   );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Fnd_Attachment
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
--       p_Fnd_Attachment_rec      IN   prompt_setup_rec_type  Required
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

PROCEDURE Create_Fnd_Attachment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_fnd_attachment_rec         IN   fnd_attachment_rec_type,
    x_document_id                OUT NOCOPY NUMBER,
    x_attached_document_id       OUT NOCOPY NUMBER
     );
END AMW_LOAD_AUDIT_PROCEDURE_DATA;

 

/
