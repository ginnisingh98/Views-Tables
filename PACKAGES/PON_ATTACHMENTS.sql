--------------------------------------------------------
--  DDL for Package PON_ATTACHMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_ATTACHMENTS" AUTHID CURRENT_USER AS
/* $Header: PONATCHS.pls 120.1 2007/06/28 20:23:59 sssahai ship $ */

SHORT_TEXT     constant number := 1;
LONG_TEXT      constant number := 2;
WEB_PAGE       constant number := 5;
EXTERNAL_FILE  constant number := 6;


FUNCTION check_attachment_exists(p_entity_name IN VARCHAR2,
                                 p_pk1_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk2_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk3_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk4_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk5_value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE add_attachment_blob(
p_file_name in VARCHAR2,
p_file_content_type in VARCHAR2,
p_file_format in VARCHAR2,
p_file_id out nocopy NUMBER
);

PROCEDURE add_attachment(
        p_seq_num                 in NUMBER,     --  1
        p_category_id             in NUMBER,     --  2
        p_document_description    in VARCHAR2,   --  3
        p_datatype_id             in NUMBER,     --  4
        p_short_text              in VARCHAR2,   --  5
        p_file_name               in VARCHAR2,   --  6
        p_url                     in VARCHAR2,   --  7
        p_entity_name             in VARCHAR2,   --  8
        p_pk1_value               in VARCHAR2,   --  9
        p_pk2_value               in VARCHAR2,   -- 10
        p_pk3_value               in VARCHAR2,   -- 11
        p_pk4_value               in VARCHAR2,   -- 12
        p_pk5_value               in VARCHAR2,   -- 13
        p_media_id                in NUMBER,     -- 14
	p_user_id                 in NUMBER,     -- 15
	p_column1                 IN VARCHAR2,   -- 16
        x_attached_document_id    out nocopy NUMBER,    -- 17
        x_file_id                 out nocopy NUMBER     -- 18
);

PROCEDURE add_attachment(
        p_seq_num                 in NUMBER,     --  1
        p_category_id             in NUMBER,     --  2
        p_document_description    in VARCHAR2,   --  3
        p_datatype_id             in NUMBER,     --  4
        p_short_text              in VARCHAR2,   --  5
        p_file_name               in VARCHAR2,   --  6
        p_url                     in VARCHAR2,   --  7
        p_entity_name             in VARCHAR2,   --  8
        p_pk1_value               in VARCHAR2,   --  9
        p_pk2_value               in VARCHAR2,   -- 10
        p_pk3_value               in VARCHAR2,   -- 11
        p_pk4_value               in VARCHAR2,   -- 12
        p_pk5_value               in VARCHAR2,   -- 13
        p_media_id                in NUMBER,     -- 14
        p_user_id                 in NUMBER,     -- 15
        x_attached_document_id    out nocopy NUMBER,    -- 16
        x_file_id                 out nocopy NUMBER     -- 17
);

PROCEDURE add_long_text_attachment (
        p_seq_num                in NUMBER,          --  1
        p_category_id            in NUMBER,          --  2
        p_document_description   in VARCHAR2,        --  3
        p_long_text              in LONG,            --  4
        p_file_name              in VARCHAR2,        --  5
        p_url                    in VARCHAR2,        --  6
        p_entity_name            in VARCHAR2,        --  7
        p_pk1_value              in VARCHAR2,        --  8
        p_pk2_value              in VARCHAR2,        --  9
        p_pk3_value              in VARCHAR2,        -- 10
        p_pk4_value              in VARCHAR2,        -- 11
        p_pk5_value              in VARCHAR2,        -- 12
        p_media_id               in NUMBER,          -- 13
        p_user_id                in NUMBER,          -- 14
	p_column1                IN VARCHAR2,        -- 15
	x_attached_document_id   out nocopy NUMBER,  -- 16
        x_file_id                out nocopy NUMBER   -- 17
);

PROCEDURE add_attachment_frm_doc_catalog(
       p_seq_num                in  NUMBER,        --  1
       p_entity_name            in  VARCHAR2,      --  2
       p_pk1_value              in  VARCHAR2,      --  3
       p_pk2_value              in  VARCHAR2,      --  4
       p_pk3_value              in  VARCHAR2,      --  5
       p_pk4_value              in  VARCHAR2,      --  6
       p_pk5_value              in  VARCHAR2,      --  7
       p_document_id            in  NUMBER,        --  8
       p_column1                IN VARCHAR2,       --  9
       x_attached_document_id   out nocopy  NUMBER --  10
);

--  A wrapper for creating attachment from the regular User Interface (e.g.,
--  'add_attachment.jsp'. Internally, it'll make use of the 'add' procedures
--  available above. Please see the package body for implementation details.
--  - Sarath.
PROCEDURE add_attachment_frm_ui(
        p_seq_num                 in NUMBER,     --  1
        p_category_id             in NUMBER,     --  2
        p_document_description    in VARCHAR2,   --  3
        p_datatype_id             in NUMBER,     --  4
        p_short_text              in VARCHAR2,   --  5
        p_long_text               in LONG,       --  6
        p_file_name               in VARCHAR2,   --  7
        p_url                     in VARCHAR2,   --  8
        p_entity_name             in VARCHAR2,   --  9
        p_pk1_value               in VARCHAR2,   -- 10
        p_pk2_value               in VARCHAR2,   -- 11
        p_pk3_value               in VARCHAR2,   -- 12
        p_pk4_value               in VARCHAR2,   -- 13
        p_pk5_value               in VARCHAR2,   -- 14
        p_media_id                in NUMBER,     -- 15
        p_user_id                 in NUMBER,     -- 16
        p_document_id             in NUMBER,     -- 17
        x_attached_document_id    out nocopy NUMBER,    -- 18
        x_file_id                 out nocopy NUMBER     -- 19
);

PROCEDURE add_attachment_frm_ui(
        p_seq_num                 in NUMBER,     --  1
        p_category_id             in NUMBER,     --  2
        p_document_description    in VARCHAR2,   --  3
        p_datatype_id             in NUMBER,     --  4
        p_short_text              in VARCHAR2,   --  5
        p_long_text               in LONG,       --  6
        p_file_name               in VARCHAR2,   --  7
        p_url                     in VARCHAR2,   --  8
        p_entity_name             in VARCHAR2,   --  9
        p_pk1_value               in VARCHAR2,   -- 10
        p_pk2_value               in VARCHAR2,   -- 11
        p_pk3_value               in VARCHAR2,   -- 12
        p_pk4_value               in VARCHAR2,   -- 13
        p_pk5_value               in VARCHAR2,   -- 14
        p_media_id                in NUMBER,     -- 15
        p_user_id                 in NUMBER,     -- 16
        p_document_id             in NUMBER,     -- 17
        p_column1                 IN VARCHAR2,   -- 18
	x_attached_document_id    out nocopy NUMBER,    -- 19
        x_file_id                 out nocopy NUMBER     -- 20
);

PROCEDURE delete_attachment(
        p_attached_document_id    in NUMBER,     --  1
        p_datatype_id             in NUMBER      --  2
);

END PON_ATTACHMENTS;

/
