--------------------------------------------------------
--  DDL for Package Body GME_TEXT_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_TEXT_DBL" AS
/* $Header: GMEVTXTB.pls 120.1 2005/06/03 11:01:38 appldev  $ */
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'gme_text_dbl';

   FUNCTION insert_header_row (
      p_header   IN              gme_text_header%ROWTYPE
     ,x_header   IN OUT NOCOPY   gme_text_header%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'GET_ITEM_NO';
   BEGIN
      INSERT INTO gme_text_header
                  (text_code, created_by
                  ,creation_date, last_updated_by
                  ,last_update_date)
           VALUES (gem5_text_code_s.NEXTVAL, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp)
        RETURNING text_code
             INTO x_header.text_code;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         --Bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END insert_header_row;

   FUNCTION insert_text_row (
      p_text_row   IN              gme_text_table%ROWTYPE
     ,x_text_row   IN OUT NOCOPY   gme_text_table%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_rowid               VARCHAR2 (40);
      l_api_name   CONSTANT VARCHAR2 (30) := 'insert_text_row';
   BEGIN
      gma_gme_text_tbl_pkg.insert_row
                           (x_rowid                  => l_rowid
                           ,x_text_code              => p_text_row.text_code
                           ,x_lang_code              => p_text_row.lang_code
                           ,x_paragraph_code         => p_text_row.paragraph_code
                           ,x_sub_paracode           => p_text_row.sub_paracode
                           ,x_line_no                => p_text_row.line_no
                           ,x_text                   => p_text_row.text
                           ,x_creation_date          => gme_common_pvt.g_timestamp
                           ,x_created_by             => gme_common_pvt.g_user_ident
                           ,x_last_updated_by        => gme_common_pvt.g_user_ident
                           ,x_last_update_date       => gme_common_pvt.g_timestamp
                           ,x_last_update_login      => gme_common_pvt.g_login_id);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         --Bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         --End Bug2804440
         RETURN FALSE;
   END insert_text_row;
END gme_text_dbl;

/
