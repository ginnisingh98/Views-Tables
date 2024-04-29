--------------------------------------------------------
--  DDL for Package GMA_EDITEXT_ATTACH_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_EDITEXT_ATTACH_MIG" AUTHID CURRENT_USER AS
/* $Header: GMAEATHS.pls 120.2 2006/11/02 20:44:44 txdaniel noship $ */

PROCEDURE Attachment_Main(
    p_text_code              in   VARCHAR2  default null,
    p_text_table_tl          in   VARCHAR2  default null,
    p_sy_para_cds_table_name in   VARCHAR2  default null,
    p_attach_form_short_name in   VARCHAR2  default null,
    p_attach_table_name      in   VARCHAR2  default null,
    p_attach_pk1_value       in   VARCHAR2  default null,
    p_attach_pk2_value       in   VARCHAR2  default null,
    p_attach_pk3_value       in   VARCHAR2  default null,
    p_attach_pk4_value       in   VARCHAR2  default null,
    p_attach_pk5_value       in   VARCHAR2  default null
    );

PROCEDURE Check_Fnd_Attachment_Defined(
    p_text_code              in   VARCHAR2  default null,
    p_sy_para_cds_table_name in   VARCHAR2  default null,
    p_form_short_name        in   VARCHAR2  default null,
    p_table_name             in   VARCHAR2  default null,
    p_attachment_function_id OUT NOCOPY NUMBER
    );

PROCEDURE Check_Fnd_Document_Exists(
               p_text_tl_table          in VARCHAR2  default null,
               p_sy_para_cds_table_name in VARCHAR2  default null,
               p_text_code              in VARCHAR2,
               p_paragraph_code         in VARCHAR2,
               p_sub_paracode           in NUMBER,
               p_pk1_value              in VARCHAR2 Default null,
               p_pk2_value              in VARCHAR2 Default null,
               p_pk3_value              in VARCHAR2 Default null,
               p_pk4_value              in VARCHAR2 Default null,
               p_pk5_value              in VARCHAR2 Default null,
               p_paragraph_count        in NUMBER Default null,
               p_document_exist         OUT NOCOPY VARCHAR2,
               p_file_name OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Fnd_Attachment_Blk_PK(
               p_text_code              in   VARCHAR2  default null,
               p_sy_para_cds_table_name in   VARCHAR2  default null,
               p_form_short_name        in   VARCHAR2  default null,
               p_table_name             in   VARCHAR2  default null,
               p_attachment_function_id in NUMBER,
               p_pk1_value     OUT NOCOPY VARCHAR2,
               p_pk2_value     OUT NOCOPY VARCHAR2 ,
               p_pk3_value     OUT NOCOPY VARCHAR2 ,
               p_pk4_value     OUT NOCOPY VARCHAR2 ,
               p_pk5_value     OUT NOCOPY VARCHAR2
    );

PROCEDURE Fnd_Document_set_languages(
               p_text_code              in NUMBER Default null,
               p_sy_para_cds_table_name in VARCHAR2  default null,
               p_text_tl_table   in VARCHAR2 Default null,
               p_paragraph_code  in VARCHAR2 Default null,
               p_sub_paracode    in Number Default null
  );

PROCEDURE Create_Fnd_Document(
              p_text_code              in VARCHAR2  default null,
              p_sy_para_cds_table_name in VARCHAR2  default null,
              p_entity_name   in VARCHAR2 Default 'GMA Migration',
              p_pk1_value     in VARCHAR2 Default null,
              p_pk2_value     in VARCHAR2 Default null,
              p_pk3_value     in VARCHAR2 Default null,
              p_pk4_value     in VARCHAR2 Default null,
              p_pk5_value     in VARCHAR2 Default null,
              x_description   in VARCHAR2 Default null,
              p_file_name     IN VARCHAR2 DEFAULT NULL,
              x_attached_document_id   in OUT NOCOPY NUMBER,
              x_document_id            in OUT NOCOPY NUMBER,
              x_media_id               in OUT NOCOPY NUMBER,
              p_attachment_function_id in NUMBER,
              p_sequence_num   IN NUMBER
            );

PROCEDURE Get_Fnd_Attachment_Category(
              p_text_code              in VARCHAR2 default null,
              p_sy_para_cds_table_name in VARCHAR2 default null,
              p_category_name          in VARCHAR2 default 'OPM_MIGRATED_TEXT',
              p_user_name              in VARCHAR2  default 'GMA Migration Text',
              p_category_exists        OUT NOCOPY NUMBER,
              p_category_id            OUT NOCOPY NUMBER
           );

PROCEDURE Get_Fnd_Category_Usage(
              p_text_code               in VARCHAR2  default null,
              p_sy_para_cds_table_name  in VARCHAR2  default null,
              p_category_id             in NUMBER,
              p_attachment_function_id  in NUMBER,
              p_category_usage_exists   OUT NOCOPY NUMBER
            );

PROCEDURE Create_Fnd_Short_Text(
              p_text_tl_table          in VARCHAR2  default null,
              p_sy_para_cds_table_name in VARCHAR2  default null,
              p_text_code            in VARCHAR2,
              p_paragraph_code       in VARCHAR2,
              p_sub_paracode         in NUMBER,
              p_language             in VARCHAR2,
              p_attached_document_id in OUT NOCOPY NUMBER,
              p_document_id          in OUT NOCOPY NUMBER,
              p_media_id             in OUT NOCOPY NUMBER,
              p_pk1_value            in VARCHAR2 Default null,
              p_pk2_value            in VARCHAR2 Default null,
              p_pk3_value            in VARCHAR2 Default null,
              p_pk4_value            in VARCHAR2 Default null,
              p_pk5_value            in VARCHAR2 Default null,
              p_paragraph_count      in NUMBER Default null
             );

PROCEDURE Check_Text_Paragraph_Match
                              (
                                p_text_code        IN NUMBER,
                                p_text_tl_table    IN VARCHAR2,
                                p_paragraph_code   IN VARCHAR2,
                                p_sub_paracode     IN NUMBER,
                                x_paragraph_exists OUT NOCOPY BOOLEAN
                               );

END GMA_EDITEXT_ATTACH_MIG;

 

/
