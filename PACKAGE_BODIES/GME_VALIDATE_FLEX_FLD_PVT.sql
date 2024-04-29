--------------------------------------------------------
--  DDL for Package Body GME_VALIDATE_FLEX_FLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_VALIDATE_FLEX_FLD_PVT" AS
   /* $Header: GMEVVFFB.pls 120.4 2006/03/09 05:41:51 svgonugu noship $ */
   g_debug                VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'GME_API_VALIDATE_FLEX_FIELD';

   /* FPBug#4395561  commented out following line
   g_flex_validate_prof   NUMBER
                := NVL (fnd_profile.VALUE ('GME_VALIDATE_FLEX_ON_SERVER'), 0); */

    /*======================================================================
   -- NAME
   -- validate_flex_batch_header
   --
   -- DESCRIPTION
   --    This procedure will validate the BATCH_FLEX, descriptive flex field on the
   --    batch header using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- SYNOPSIS:

        validate_flex_batch_header(p_batch_header => a_batch_header,
                                   x_batch_header => b_batch_header,
                                   x_return_status =>l_return_status);
   -- HISTORY
   -- A.Sriram    19-FEB-2004     Created --BUG#3406639

   -- G. Muratore 05-MAY-2004     Bug 3575735
   --  New profile added to control whether or not this procedure should be
   --  executed. A problem occurs when there is a flexfield of value set type,
   --  that has a where clause using a block field on the form.
   ======================================================================= */
   PROCEDURE validate_flex_batch_header (
      p_batch_header    IN              gme_batch_header%ROWTYPE
     ,x_batch_header    IN OUT NOCOPY   gme_batch_header%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category   VARCHAR2 (240);
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'BATCH_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'I';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      validation_error       EXCEPTION;
      header_fetch_error     EXCEPTION;
      l_field_value          VARCHAR2 (240);
      l_field_name           VARCHAR2 (100);
      n                      NUMBER                     := 0;
      l_batch_header_row     gme_batch_header%ROWTYPE;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      /* Bug 3575735 - Do not run this validation if it is set to N. */
      /* It should only be set to N if it is a value set flexfield   */
      /* with a where clause using block fields from the form.       */
      IF gme_common_pvt.g_flex_validate_prof = 0 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      IF NOT gme_batch_header_dbl.fetch_row (p_batch_header
                                            ,l_batch_header_row) THEN
         RAISE header_fetch_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      l_attribute_category := p_batch_header.attribute_category;

      IF p_batch_header.attribute_category IS NULL THEN
         l_attribute_category :=
                              NVL (l_batch_header_row.attribute_category, '');
      ELSIF p_batch_header.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);

      IF p_batch_header.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE1'
                                        ,NVL (l_batch_header_row.attribute1
                                             ,'') );
      ELSIF p_batch_header.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_batch_header.attribute1);
      END IF;

      IF p_batch_header.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE2'
                                        ,NVL (l_batch_header_row.attribute2
                                             ,'') );
      ELSIF p_batch_header.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_batch_header.attribute2);
      END IF;

      IF p_batch_header.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE3'
                                        ,NVL (l_batch_header_row.attribute3
                                             ,'') );
      ELSIF p_batch_header.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_batch_header.attribute3);
      END IF;

      IF p_batch_header.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE4'
                                        ,NVL (l_batch_header_row.attribute4
                                             ,'') );
      ELSIF p_batch_header.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_batch_header.attribute4);
      END IF;

      IF p_batch_header.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE5'
                                        ,NVL (l_batch_header_row.attribute5
                                             ,'') );
      ELSIF p_batch_header.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_batch_header.attribute5);
      END IF;

      IF p_batch_header.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE6'
                                        ,NVL (l_batch_header_row.attribute6
                                             ,'') );
      ELSIF p_batch_header.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_batch_header.attribute6);
      END IF;

      IF p_batch_header.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE7'
                                        ,NVL (l_batch_header_row.attribute7
                                             ,'') );
      ELSIF p_batch_header.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_batch_header.attribute7);
      END IF;

      IF p_batch_header.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE8'
                                        ,NVL (l_batch_header_row.attribute8
                                             ,'') );
      ELSIF p_batch_header.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_batch_header.attribute8);
      END IF;

      IF p_batch_header.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value
                                        ('ATTRIBUTE9'
                                        ,NVL (l_batch_header_row.attribute9
                                             ,'') );
      ELSIF p_batch_header.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_batch_header.attribute9);
      END IF;

      IF p_batch_header.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE10'
                                       ,NVL (l_batch_header_row.attribute10
                                            ,'') );
      ELSIF p_batch_header.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_batch_header.attribute10);
      END IF;

      IF p_batch_header.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE11'
                                       ,NVL (l_batch_header_row.attribute11
                                            ,'') );
      ELSIF p_batch_header.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_batch_header.attribute11);
      END IF;

      IF p_batch_header.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE12'
                                       ,NVL (l_batch_header_row.attribute12
                                            ,'') );
      ELSIF p_batch_header.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_batch_header.attribute12);
      END IF;

      IF p_batch_header.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE13'
                                       ,NVL (l_batch_header_row.attribute13
                                            ,'') );
      ELSIF p_batch_header.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_batch_header.attribute13);
      END IF;

      IF p_batch_header.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE14'
                                       ,NVL (l_batch_header_row.attribute14
                                            ,'') );
      ELSIF p_batch_header.attribute14 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_batch_header.attribute14);
      END IF;

      IF p_batch_header.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE15'
                                       ,NVL (l_batch_header_row.attribute15
                                            ,'') );
      ELSIF p_batch_header.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_batch_header.attribute15);
      END IF;

      IF p_batch_header.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE16'
                                       ,NVL (l_batch_header_row.attribute16
                                            ,'') );
      ELSIF p_batch_header.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_batch_header.attribute16);
      END IF;

      IF p_batch_header.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE17'
                                       ,NVL (l_batch_header_row.attribute17
                                            ,'') );
      ELSIF p_batch_header.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_batch_header.attribute17);
      END IF;

      IF p_batch_header.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE18'
                                       ,NVL (l_batch_header_row.attribute18
                                            ,'') );
      ELSIF p_batch_header.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_batch_header.attribute18);
      END IF;

      IF p_batch_header.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE19'
                                       ,NVL (l_batch_header_row.attribute19
                                            ,'') );
      ELSIF p_batch_header.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_batch_header.attribute19);
      END IF;

      IF p_batch_header.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE20'
                                       ,NVL (l_batch_header_row.attribute20
                                            ,'') );
      ELSIF p_batch_header.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_batch_header.attribute20);
      END IF;

      IF p_batch_header.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE21'
                                       ,NVL (l_batch_header_row.attribute21
                                            ,'') );
      ELSIF p_batch_header.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_batch_header.attribute21);
      END IF;

      IF p_batch_header.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE22'
                                       ,NVL (l_batch_header_row.attribute22
                                            ,'') );
      ELSIF p_batch_header.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_batch_header.attribute22);
      END IF;

      IF p_batch_header.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE23'
                                       ,NVL (l_batch_header_row.attribute23
                                            ,'') );
      ELSIF p_batch_header.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_batch_header.attribute23);
      END IF;

      IF p_batch_header.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE24'
                                       ,NVL (l_batch_header_row.attribute24
                                            ,'') );
      ELSIF p_batch_header.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_batch_header.attribute24);
      END IF;

      IF p_batch_header.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE25'
                                       ,NVL (l_batch_header_row.attribute25
                                            ,'') );
      ELSIF p_batch_header.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_batch_header.attribute25);
      END IF;

      IF p_batch_header.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE26'
                                       ,NVL (l_batch_header_row.attribute26
                                            ,'') );
      ELSIF p_batch_header.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_batch_header.attribute26);
      END IF;

      IF p_batch_header.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE27'
                                       ,NVL (l_batch_header_row.attribute27
                                            ,'') );
      ELSIF p_batch_header.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_batch_header.attribute27);
      END IF;

      IF p_batch_header.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE28'
                                       ,NVL (l_batch_header_row.attribute28
                                            ,'') );
      ELSIF p_batch_header.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_batch_header.attribute28);
      END IF;

      IF p_batch_header.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE29'
                                       ,NVL (l_batch_header_row.attribute29
                                            ,'') );
      ELSIF p_batch_header.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_batch_header.attribute29);
      END IF;

      IF p_batch_header.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE30'
                                       ,NVL (l_batch_header_row.attribute30
                                            ,'') );
      ELSIF p_batch_header.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_batch_header.attribute30);
      END IF;

      IF p_batch_header.attribute31 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE31'
                                       ,NVL (l_batch_header_row.attribute31
                                            ,'') );
      ELSIF p_batch_header.attribute31 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE31', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE31'
                                           ,p_batch_header.attribute31);
      END IF;

      IF p_batch_header.attribute32 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE32'
                                       ,NVL (l_batch_header_row.attribute32
                                            ,'') );
      ELSIF p_batch_header.attribute32 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE32', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE32'
                                           ,p_batch_header.attribute32);
      END IF;

      IF p_batch_header.attribute33 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE33'
                                       ,NVL (l_batch_header_row.attribute33
                                            ,'') );
      ELSIF p_batch_header.attribute33 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE33', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE33'
                                           ,p_batch_header.attribute33);
      END IF;

      IF p_batch_header.attribute34 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE34'
                                       ,NVL (l_batch_header_row.attribute34
                                            ,'') );
      ELSIF p_batch_header.attribute34 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE34', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE34'
                                           ,p_batch_header.attribute34);
      END IF;

      IF p_batch_header.attribute35 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE35'
                                       ,NVL (l_batch_header_row.attribute35
                                            ,'') );
      ELSIF p_batch_header.attribute35 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE35', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE35'
                                           ,p_batch_header.attribute35);
      END IF;

      IF p_batch_header.attribute36 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE36'
                                       ,NVL (l_batch_header_row.attribute36
                                            ,'') );
      ELSIF p_batch_header.attribute36 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE36', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE36'
                                           ,p_batch_header.attribute36);
      END IF;

      IF p_batch_header.attribute37 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE37'
                                       ,NVL (l_batch_header_row.attribute37
                                            ,'') );
      ELSIF p_batch_header.attribute37 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE37', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE37'
                                           ,p_batch_header.attribute37);
      END IF;

      IF p_batch_header.attribute38 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE38'
                                       ,NVL (l_batch_header_row.attribute38
                                            ,'') );
      ELSIF p_batch_header.attribute38 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE38', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE38'
                                           ,p_batch_header.attribute38);
      END IF;

      IF p_batch_header.attribute39 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE39'
                                       ,NVL (l_batch_header_row.attribute39
                                            ,'') );
      ELSIF p_batch_header.attribute39 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE39', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE39'
                                           ,p_batch_header.attribute39);
      END IF;

      IF p_batch_header.attribute40 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE40'
                                       ,NVL (l_batch_header_row.attribute40
                                            ,'') );
      ELSIF p_batch_header.attribute40 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE40', '');
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE40'
                                           ,p_batch_header.attribute40);
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success. ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_batch_header.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_batch_header.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_batch_header.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_batch_header.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_batch_header.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_batch_header.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_batch_header.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_batch_header.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_batch_header.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_batch_header.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_batch_header.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_batch_header.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_batch_header.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_batch_header.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_batch_header.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_batch_header.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_batch_header.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_batch_header.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_batch_header.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_batch_header.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_batch_header.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_batch_header.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_batch_header.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_batch_header.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_batch_header.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_batch_header.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_batch_header.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_batch_header.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_batch_header.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_batch_header.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_batch_header.attribute30 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE31' THEN
               x_batch_header.attribute31 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE32' THEN
               x_batch_header.attribute32 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE33' THEN
               x_batch_header.attribute33 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE34' THEN
               x_batch_header.attribute34 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE35' THEN
               x_batch_header.attribute35 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE36' THEN
               x_batch_header.attribute36 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE37' THEN
               x_batch_header.attribute37 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE38' THEN
               x_batch_header.attribute38 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE39' THEN
               x_batch_header.attribute39 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE40' THEN
               x_batch_header.attribute40 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN header_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_flex_batch_header;

    /*======================================================================
   -- NAME
   -- validate_flex_batch_step
   --
   -- DESCRIPTION
   --    This procedure will validate the BATCH_STEPS_DTL_FLEX, descriptive flex field
   --    for batch steps using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- SYNOPSIS:

        validate_flex_batch_step  (p_batch_step => a_batch_step,
                                   x_batch_step => b_batch_step,
                                   x_return_status =>l_return_status);
   -- HISTORY
   -- A.Sriram    19-FEB-2004     Created --  BUG#3406639

   -- G. Muratore 05-MAY-2004     Bug 3575735
   --  New profile added to control whether or not this procedure should be
   --  executed. A problem occurs when there is a flexfield of value set type,
   --  that has a where clause using a block field on the form.
   --
   -- G. Muratore 25-MAY-2004     Bug 3649415
   --  This is a follow up fix to bug 3575735.
   --  The flex field data entered by the user on the form is still saved even
   --  if the profile says not to validate it on the server side.
   --  Additional fix 3556979. The code will no longer fail during insert.
   --
   -- G. Muratore 11-JUN-2004     Bug 3681718
   --  This is a follow up fix to bug 3649415.
   --  Only flex field data will be overwritten in x_material_detail parameter.
     ======================================================================= */
   PROCEDURE validate_flex_batch_step (
      p_batch_step      IN              gme_batch_steps%ROWTYPE
     ,x_batch_step      IN OUT NOCOPY   gme_batch_steps%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category   VARCHAR2 (240);
      appl_short_name        VARCHAR2 (30)             := 'GME';
      desc_flex_name         VARCHAR2 (30)          := 'BATCH_STEPS_DTL_FLEX';
      values_or_ids          VARCHAR2 (10)             := 'I';
      validation_date        DATE                      := SYSDATE;
      error_msg              VARCHAR2 (5000);
      validation_error       EXCEPTION;
      step_fetch_error       EXCEPTION;
      l_field_value          VARCHAR2 (240);
      l_field_name           VARCHAR2 (100);
      n                      NUMBER                    := 0;
      l_batch_step_row       gme_batch_steps%ROWTYPE;
      --3556979
      l_exists               NUMBER;
      l_dummy                BOOLEAN;

      CURSOR cur_record_exists (v_rec_id NUMBER)
      IS
         SELECT 1
           FROM gme_batch_steps
          WHERE batchstep_id = v_rec_id;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      -- 3556979 Check if record being worked on already exists
      OPEN cur_record_exists (p_batch_step.batchstep_id);

      FETCH cur_record_exists
       INTO l_exists;

      IF cur_record_exists%NOTFOUND THEN
         l_batch_step_row := p_batch_step;
      ELSE
         l_dummy :=
               gme_batch_steps_dbl.fetch_row (p_batch_step, l_batch_step_row);
      END IF;

      CLOSE cur_record_exists;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      /* Bug 3649415 - Retain all current flexfield values in l_batch_step_row.     */
      /* This will allow us to pass back the correct row with all the proper values */
      /* in the event the flex field validation on the server side is off.          */
      /* All the following if statements will now retain that data.                 */
      IF p_batch_step.attribute_category IS NULL THEN
         l_attribute_category :=
                                NVL (l_batch_step_row.attribute_category, '');
      ELSIF p_batch_step.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      ELSE
         l_attribute_category := p_batch_step.attribute_category;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);
      l_batch_step_row.attribute_category := l_attribute_category;

      IF p_batch_step.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE1'
                                          ,NVL (l_batch_step_row.attribute1
                                               ,'') );
      ELSIF p_batch_step.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
         l_batch_step_row.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_batch_step.attribute1);
         l_batch_step_row.attribute1 := p_batch_step.attribute1;
      END IF;

      IF p_batch_step.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE2'
                                          ,NVL (l_batch_step_row.attribute2
                                               ,'') );
      ELSIF p_batch_step.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
         l_batch_step_row.attribute2 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_batch_step.attribute2);
         l_batch_step_row.attribute2 := p_batch_step.attribute2;
      END IF;

      IF p_batch_step.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE3'
                                          ,NVL (l_batch_step_row.attribute3
                                               ,'') );
      ELSIF p_batch_step.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_batch_step_row.attribute3 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_batch_step.attribute3);
         l_batch_step_row.attribute3 := p_batch_step.attribute3;
      END IF;

      IF p_batch_step.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE4'
                                          ,NVL (l_batch_step_row.attribute4
                                               ,'') );
      ELSIF p_batch_step.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4', '');
         l_batch_step_row.attribute4 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_batch_step.attribute4);
         l_batch_step_row.attribute4 := p_batch_step.attribute4;
      END IF;

      IF p_batch_step.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE5'
                                          ,NVL (l_batch_step_row.attribute5
                                               ,'') );
      ELSIF p_batch_step.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
         l_batch_step_row.attribute5 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_batch_step.attribute5);
         l_batch_step_row.attribute5 := p_batch_step.attribute5;
      END IF;

      IF p_batch_step.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE6'
                                          ,NVL (l_batch_step_row.attribute6
                                               ,'') );
      ELSIF p_batch_step.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
         l_batch_step_row.attribute6 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_batch_step.attribute6);
         l_batch_step_row.attribute6 := p_batch_step.attribute6;
      END IF;

      IF p_batch_step.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE7'
                                          ,NVL (l_batch_step_row.attribute7
                                               ,'') );
      ELSIF p_batch_step.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
         l_batch_step_row.attribute7 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_batch_step.attribute7);
         l_batch_step_row.attribute7 := p_batch_step.attribute7;
      END IF;

      IF p_batch_step.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE8'
                                          ,NVL (l_batch_step_row.attribute8
                                               ,'') );
      ELSIF p_batch_step.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
         l_batch_step_row.attribute8 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_batch_step.attribute8);
         l_batch_step_row.attribute8 := p_batch_step.attribute8;
      END IF;

      IF p_batch_step.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value
                                          ('ATTRIBUTE9'
                                          ,NVL (l_batch_step_row.attribute9
                                               ,'') );
      ELSIF p_batch_step.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
         l_batch_step_row.attribute9 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_batch_step.attribute9);
         l_batch_step_row.attribute9 := p_batch_step.attribute9;
      END IF;

      IF p_batch_step.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE10'
                                         ,NVL (l_batch_step_row.attribute10
                                              ,'') );
      ELSIF p_batch_step.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
         l_batch_step_row.attribute10 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_batch_step.attribute10);
         l_batch_step_row.attribute10 := p_batch_step.attribute10;
      END IF;

      IF p_batch_step.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE11'
                                         ,NVL (l_batch_step_row.attribute11
                                              ,'') );
      ELSIF p_batch_step.attribute11 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
         l_batch_step_row.attribute11 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_batch_step.attribute11);
         l_batch_step_row.attribute11 := p_batch_step.attribute11;
      END IF;

      IF p_batch_step.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE12'
                                         ,NVL (l_batch_step_row.attribute12
                                              ,'') );
      ELSIF p_batch_step.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
         l_batch_step_row.attribute12 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_batch_step.attribute12);
         l_batch_step_row.attribute12 := p_batch_step.attribute12;
      END IF;

      IF p_batch_step.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE13'
                                         ,NVL (l_batch_step_row.attribute13
                                              ,'') );
      ELSIF p_batch_step.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
         l_batch_step_row.attribute13 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_batch_step.attribute13);
         l_batch_step_row.attribute13 := p_batch_step.attribute13;
      END IF;

      IF p_batch_step.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE14'
                                         ,NVL (l_batch_step_row.attribute14
                                              ,'') );
      ELSIF p_batch_step.attribute14 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
         l_batch_step_row.attribute14 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_batch_step.attribute14);
         l_batch_step_row.attribute14 := p_batch_step.attribute14;
      END IF;

      IF p_batch_step.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE15'
                                         ,NVL (l_batch_step_row.attribute15
                                              ,'') );
      ELSIF p_batch_step.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
         l_batch_step_row.attribute15 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_batch_step.attribute15);
         l_batch_step_row.attribute15 := p_batch_step.attribute15;
      END IF;

      IF p_batch_step.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE16'
                                         ,NVL (l_batch_step_row.attribute16
                                              ,'') );
      ELSIF p_batch_step.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
         l_batch_step_row.attribute16 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_batch_step.attribute16);
         l_batch_step_row.attribute16 := p_batch_step.attribute16;
      END IF;

      IF p_batch_step.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE17'
                                         ,NVL (l_batch_step_row.attribute17
                                              ,'') );
      ELSIF p_batch_step.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
         l_batch_step_row.attribute17 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_batch_step.attribute17);
         l_batch_step_row.attribute17 := p_batch_step.attribute17;
      END IF;

      IF p_batch_step.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE18'
                                         ,NVL (l_batch_step_row.attribute18
                                              ,'') );
      ELSIF p_batch_step.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
         l_batch_step_row.attribute18 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_batch_step.attribute18);
         l_batch_step_row.attribute18 := p_batch_step.attribute18;
      END IF;

      IF p_batch_step.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE19'
                                         ,NVL (l_batch_step_row.attribute19
                                              ,'') );
      ELSIF p_batch_step.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
         l_batch_step_row.attribute19 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_batch_step.attribute19);
         l_batch_step_row.attribute19 := p_batch_step.attribute19;
      END IF;

      IF p_batch_step.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE20'
                                         ,NVL (l_batch_step_row.attribute20
                                              ,'') );
      ELSIF p_batch_step.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
         l_batch_step_row.attribute20 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_batch_step.attribute20);
         l_batch_step_row.attribute20 := p_batch_step.attribute20;
      END IF;

      IF p_batch_step.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE21'
                                         ,NVL (l_batch_step_row.attribute21
                                              ,'') );
      ELSIF p_batch_step.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
         l_batch_step_row.attribute21 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_batch_step.attribute21);
         l_batch_step_row.attribute21 := p_batch_step.attribute21;
      END IF;

      IF p_batch_step.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE22'
                                         ,NVL (l_batch_step_row.attribute22
                                              ,'') );
      ELSIF p_batch_step.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
         l_batch_step_row.attribute22 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_batch_step.attribute22);
         l_batch_step_row.attribute22 := p_batch_step.attribute22;
      END IF;

      IF p_batch_step.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE23'
                                         ,NVL (l_batch_step_row.attribute23
                                              ,'') );
      ELSIF p_batch_step.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
         l_batch_step_row.attribute23 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_batch_step.attribute23);
         l_batch_step_row.attribute23 := p_batch_step.attribute23;
      END IF;

      IF p_batch_step.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE24'
                                         ,NVL (l_batch_step_row.attribute24
                                              ,'') );
      ELSIF p_batch_step.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
         l_batch_step_row.attribute24 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_batch_step.attribute24);
         l_batch_step_row.attribute24 := p_batch_step.attribute24;
      END IF;

      IF p_batch_step.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE25'
                                         ,NVL (l_batch_step_row.attribute25
                                              ,'') );
      ELSIF p_batch_step.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
         l_batch_step_row.attribute25 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_batch_step.attribute25);
         l_batch_step_row.attribute25 := p_batch_step.attribute25;
      END IF;

      IF p_batch_step.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE26'
                                         ,NVL (l_batch_step_row.attribute26
                                              ,'') );
      ELSIF p_batch_step.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
         l_batch_step_row.attribute26 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_batch_step.attribute26);
         l_batch_step_row.attribute26 := p_batch_step.attribute26;
      END IF;

      IF p_batch_step.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE27'
                                         ,NVL (l_batch_step_row.attribute27
                                              ,'') );
      ELSIF p_batch_step.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
         l_batch_step_row.attribute27 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_batch_step.attribute27);
         l_batch_step_row.attribute27 := p_batch_step.attribute27;
      END IF;

      IF p_batch_step.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE28'
                                         ,NVL (l_batch_step_row.attribute28
                                              ,'') );
      ELSIF p_batch_step.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
         l_batch_step_row.attribute28 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_batch_step.attribute28);
         l_batch_step_row.attribute28 := p_batch_step.attribute28;
      END IF;

      IF p_batch_step.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE29'
                                         ,NVL (l_batch_step_row.attribute29
                                              ,'') );
      ELSIF p_batch_step.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
         l_batch_step_row.attribute29 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_batch_step.attribute29);
         l_batch_step_row.attribute29 := p_batch_step.attribute29;
      END IF;

      IF p_batch_step.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value
                                         ('ATTRIBUTE30'
                                         ,NVL (l_batch_step_row.attribute30
                                              ,'') );
      ELSIF p_batch_step.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
         l_batch_step_row.attribute30 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_batch_step.attribute30);
         l_batch_step_row.attribute30 := p_batch_step.attribute30;
      END IF;

      /* Bug 3649415 - Do not run this validation if it is set to N. */
      /* It should only be set to N if it is a value set flexfield   */
      /* with a where clause using block fields from the form.       */
      /* Pass back all flexfield values w/ no validation.            */
      IF gme_common_pvt.g_flex_validate_prof = 0 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         /* Bug 3681718 - Only update flex field columns in x_ OUT parameter. */
         x_batch_step.attribute_category :=
                                           l_batch_step_row.attribute_category;
         x_batch_step.attribute1 := l_batch_step_row.attribute1;
         x_batch_step.attribute2 := l_batch_step_row.attribute2;
         x_batch_step.attribute3 := l_batch_step_row.attribute3;
         x_batch_step.attribute4 := l_batch_step_row.attribute4;
         x_batch_step.attribute5 := l_batch_step_row.attribute5;
         x_batch_step.attribute6 := l_batch_step_row.attribute6;
         x_batch_step.attribute7 := l_batch_step_row.attribute7;
         x_batch_step.attribute8 := l_batch_step_row.attribute8;
         x_batch_step.attribute9 := l_batch_step_row.attribute9;
         x_batch_step.attribute10 := l_batch_step_row.attribute10;
         x_batch_step.attribute11 := l_batch_step_row.attribute11;
         x_batch_step.attribute12 := l_batch_step_row.attribute12;
         x_batch_step.attribute13 := l_batch_step_row.attribute13;
         x_batch_step.attribute14 := l_batch_step_row.attribute14;
         x_batch_step.attribute15 := l_batch_step_row.attribute15;
         x_batch_step.attribute16 := l_batch_step_row.attribute16;
         x_batch_step.attribute17 := l_batch_step_row.attribute17;
         x_batch_step.attribute18 := l_batch_step_row.attribute18;
         x_batch_step.attribute19 := l_batch_step_row.attribute19;
         x_batch_step.attribute20 := l_batch_step_row.attribute20;
         x_batch_step.attribute21 := l_batch_step_row.attribute21;
         x_batch_step.attribute22 := l_batch_step_row.attribute22;
         x_batch_step.attribute23 := l_batch_step_row.attribute23;
         x_batch_step.attribute24 := l_batch_step_row.attribute24;
         x_batch_step.attribute25 := l_batch_step_row.attribute25;
         x_batch_step.attribute26 := l_batch_step_row.attribute26;
         x_batch_step.attribute27 := l_batch_step_row.attribute27;
         x_batch_step.attribute28 := l_batch_step_row.attribute28;
         x_batch_step.attribute29 := l_batch_step_row.attribute29;
         x_batch_step.attribute30 := l_batch_step_row.attribute30;
         RETURN;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_batch_step.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_batch_step.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_batch_step.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_batch_step.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_batch_step.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_batch_step.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_batch_step.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_batch_step.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_batch_step.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_batch_step.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_batch_step.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_batch_step.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_batch_step.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_batch_step.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_batch_step.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_batch_step.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_batch_step.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_batch_step.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_batch_step.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_batch_step.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_batch_step.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_batch_step.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_batch_step.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_batch_step.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_batch_step.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_batch_step.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_batch_step.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_batch_step.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_batch_step.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_batch_step.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_batch_step.attribute30 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN step_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_flex_batch_step;

    /*======================================================================
   -- NAME
   -- validate_flex_step_activities
   --
   -- DESCRIPTION
   --  This procedure will validate the GME_BATCH_STEP_ACTIVITIES_FLEX, descriptive flex field
   --  for batch step activities using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- SYNOPSIS:

        validate_flex_step_activities  (p_step_activities => a_step_activities,
                                       x_step_activities => b_step_activities,
                                       x_return_status =>l_return_status);
   -- HISTORY
   -- A.Sriram    19-FEB-2004     Created -- BUG#3406639

   -- G. Muratore 05-MAY-2004     Bug 3575735
   --  New profile added to control whether or not this procedure should be
   --  executed. A problem occurs when there is a flexfield of value set type,
   --  that has a where clause using a block field on the form.
   --
   -- G. Muratore 25-MAY-2004     Bug 3649415
   --  This is a follow up fix to bug 3575735.
   --  The flex field data entered by the user on the form is still saved even
   --  if the profile says not to validate it on the server side.
   --  Additional fix 3556979. The code will no longer fail during insert.
   --
   -- G. Muratore 11-JUN-2004     Bug 3681718
   --  This is a follow up fix to bug 3649415.
   --  Only flex field data will be overwritten in x_material_detail parameter.
   ======================================================================= */
   PROCEDURE validate_flex_step_activities (
      p_step_activities   IN              gme_batch_step_activities%ROWTYPE
     ,x_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category    VARCHAR2 (240);
      appl_short_name         VARCHAR2 (30)                       := 'GME';
      desc_flex_name          VARCHAR2 (30)
                                          := 'GME_BATCH_STEP_ACTIVITIES_FLEX';
      values_or_ids           VARCHAR2 (10)                       := 'I';
      validation_date         DATE                                := SYSDATE;
      error_msg               VARCHAR2 (5000);
      validation_error        EXCEPTION;
      step_fetch_error        EXCEPTION;
      l_field_value           VARCHAR2 (240);
      l_field_name            VARCHAR2 (100);
      n                       NUMBER                              := 0;
      l_step_activities_row   gme_batch_step_activities%ROWTYPE;
      --3556979
      l_exists                NUMBER;
      l_dummy                 BOOLEAN;

      CURSOR cur_record_exists (v_rec_id NUMBER)
      IS
         SELECT 1
           FROM gme_batch_step_activities
          WHERE batchstep_activity_id = v_rec_id;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      -- 3556979 Check if record being worked on already exists
      OPEN cur_record_exists (p_step_activities.batchstep_activity_id);

      FETCH cur_record_exists
       INTO l_exists;

      IF cur_record_exists%NOTFOUND THEN
         l_step_activities_row := p_step_activities;
      ELSE
         l_dummy :=
            gme_batch_step_activities_dbl.fetch_row (p_step_activities
                                                    ,l_step_activities_row);
      END IF;

      CLOSE cur_record_exists;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      /* Bug 3649415 - Retain all current flexfield values in l_step_activities_row.*/
      /* This will allow us to pass back the correct row with all the proper values */
      /* in the event the flex field validation on the server side is off.          */
      /* All the following if statements will now retain that data.                 */
      IF p_step_activities.attribute_category IS NULL THEN
         l_attribute_category :=
                           NVL (l_step_activities_row.attribute_category, '');
      ELSIF p_step_activities.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      ELSE
         l_attribute_category := p_step_activities.attribute_category;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);
      l_step_activities_row.attribute_category := l_attribute_category;

      IF p_step_activities.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE1'
                                     ,NVL (l_step_activities_row.attribute1
                                          ,'') );
      ELSIF p_step_activities.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
         l_step_activities_row.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_step_activities.attribute1);
         l_step_activities_row.attribute1 := p_step_activities.attribute1;
      END IF;

      IF p_step_activities.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE2'
                                     ,NVL (l_step_activities_row.attribute2
                                          ,'') );
      ELSIF p_step_activities.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
         l_step_activities_row.attribute2 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_step_activities.attribute2);
         l_step_activities_row.attribute2 := p_step_activities.attribute2;
      END IF;

      IF p_step_activities.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE3'
                                     ,NVL (l_step_activities_row.attribute3
                                          ,'') );
      ELSIF p_step_activities.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_step_activities_row.attribute3 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_step_activities.attribute3);
         l_step_activities_row.attribute3 := p_step_activities.attribute3;
      END IF;

      IF p_step_activities.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE4'
                                     ,NVL (l_step_activities_row.attribute4
                                          ,'') );
      ELSIF p_step_activities.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4', '');
         l_step_activities_row.attribute4 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_step_activities.attribute4);
         l_step_activities_row.attribute4 := p_step_activities.attribute4;
      END IF;

      IF p_step_activities.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE5'
                                     ,NVL (l_step_activities_row.attribute5
                                          ,'') );
      ELSIF p_step_activities.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
         l_step_activities_row.attribute5 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_step_activities.attribute5);
         l_step_activities_row.attribute5 := p_step_activities.attribute5;
      END IF;

      IF p_step_activities.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE6'
                                     ,NVL (l_step_activities_row.attribute6
                                          ,'') );
      ELSIF p_step_activities.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
         l_step_activities_row.attribute6 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_step_activities.attribute6);
         l_step_activities_row.attribute6 := p_step_activities.attribute6;
      END IF;

      IF p_step_activities.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE7'
                                     ,NVL (l_step_activities_row.attribute7
                                          ,'') );
      ELSIF p_step_activities.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
         l_step_activities_row.attribute7 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_step_activities.attribute7);
         l_step_activities_row.attribute7 := p_step_activities.attribute7;
      END IF;

      IF p_step_activities.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE8'
                                     ,NVL (l_step_activities_row.attribute8
                                          ,'') );
      ELSIF p_step_activities.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
         l_step_activities_row.attribute8 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_step_activities.attribute8);
         l_step_activities_row.attribute8 := p_step_activities.attribute8;
      END IF;

      IF p_step_activities.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE9'
                                     ,NVL (l_step_activities_row.attribute9
                                          ,'') );
      ELSIF p_step_activities.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
         l_step_activities_row.attribute9 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_step_activities.attribute9);
         l_step_activities_row.attribute9 := p_step_activities.attribute9;
      END IF;

      IF p_step_activities.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE10'
                                    ,NVL (l_step_activities_row.attribute10
                                         ,'') );
      ELSIF p_step_activities.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
         l_step_activities_row.attribute10 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_step_activities.attribute10);
         l_step_activities_row.attribute10 := p_step_activities.attribute10;
      END IF;

      IF p_step_activities.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE11'
                                    ,NVL (l_step_activities_row.attribute11
                                         ,'') );
      ELSIF p_step_activities.attribute11 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
         l_step_activities_row.attribute11 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_step_activities.attribute11);
         l_step_activities_row.attribute11 := p_step_activities.attribute11;
      END IF;

      IF p_step_activities.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE12'
                                    ,NVL (l_step_activities_row.attribute12
                                         ,'') );
      ELSIF p_step_activities.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
         l_step_activities_row.attribute12 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_step_activities.attribute12);
         l_step_activities_row.attribute12 := p_step_activities.attribute12;
      END IF;

      IF p_step_activities.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE13'
                                    ,NVL (l_step_activities_row.attribute13
                                         ,'') );
      ELSIF p_step_activities.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
         l_step_activities_row.attribute13 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_step_activities.attribute13);
         l_step_activities_row.attribute13 := p_step_activities.attribute13;
      END IF;

      IF p_step_activities.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE14'
                                    ,NVL (l_step_activities_row.attribute14
                                         ,'') );
      ELSIF p_step_activities.attribute14 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
         l_step_activities_row.attribute14 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_step_activities.attribute14);
         l_step_activities_row.attribute14 := p_step_activities.attribute14;
      END IF;

      IF p_step_activities.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE15'
                                    ,NVL (l_step_activities_row.attribute15
                                         ,'') );
      ELSIF p_step_activities.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
         l_step_activities_row.attribute15 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_step_activities.attribute15);
         l_step_activities_row.attribute15 := p_step_activities.attribute15;
      END IF;

      IF p_step_activities.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE16'
                                    ,NVL (l_step_activities_row.attribute16
                                         ,'') );
      ELSIF p_step_activities.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
         l_step_activities_row.attribute16 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_step_activities.attribute16);
         l_step_activities_row.attribute16 := p_step_activities.attribute16;
      END IF;

      IF p_step_activities.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE17'
                                    ,NVL (l_step_activities_row.attribute17
                                         ,'') );
      ELSIF p_step_activities.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
         l_step_activities_row.attribute17 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_step_activities.attribute17);
         l_step_activities_row.attribute17 := p_step_activities.attribute17;
      END IF;

      IF p_step_activities.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE18'
                                    ,NVL (l_step_activities_row.attribute18
                                         ,'') );
      ELSIF p_step_activities.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
         l_step_activities_row.attribute18 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_step_activities.attribute18);
         l_step_activities_row.attribute18 := p_step_activities.attribute18;
      END IF;

      IF p_step_activities.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE19'
                                    ,NVL (l_step_activities_row.attribute19
                                         ,'') );
      ELSIF p_step_activities.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
         l_step_activities_row.attribute19 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_step_activities.attribute19);
         l_step_activities_row.attribute19 := p_step_activities.attribute19;
      END IF;

      IF p_step_activities.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE20'
                                    ,NVL (l_step_activities_row.attribute20
                                         ,'') );
      ELSIF p_step_activities.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
         l_step_activities_row.attribute20 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_step_activities.attribute20);
         l_step_activities_row.attribute20 := p_step_activities.attribute20;
      END IF;

      IF p_step_activities.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE21'
                                    ,NVL (l_step_activities_row.attribute21
                                         ,'') );
      ELSIF p_step_activities.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
         l_step_activities_row.attribute21 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_step_activities.attribute21);
         l_step_activities_row.attribute21 := p_step_activities.attribute21;
      END IF;

      IF p_step_activities.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE22'
                                    ,NVL (l_step_activities_row.attribute22
                                         ,'') );
      ELSIF p_step_activities.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
         l_step_activities_row.attribute22 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_step_activities.attribute22);
         l_step_activities_row.attribute22 := p_step_activities.attribute22;
      END IF;

      IF p_step_activities.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE23'
                                    ,NVL (l_step_activities_row.attribute23
                                         ,'') );
      ELSIF p_step_activities.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
         l_step_activities_row.attribute23 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_step_activities.attribute23);
         l_step_activities_row.attribute23 := p_step_activities.attribute23;
      END IF;

      IF p_step_activities.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE24'
                                    ,NVL (l_step_activities_row.attribute24
                                         ,'') );
      ELSIF p_step_activities.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
         l_step_activities_row.attribute24 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_step_activities.attribute24);
         l_step_activities_row.attribute24 := p_step_activities.attribute24;
      END IF;

      IF p_step_activities.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE25'
                                    ,NVL (l_step_activities_row.attribute25
                                         ,'') );
      ELSIF p_step_activities.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
         l_step_activities_row.attribute25 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_step_activities.attribute25);
         l_step_activities_row.attribute25 := p_step_activities.attribute25;
      END IF;

      IF p_step_activities.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE26'
                                    ,NVL (l_step_activities_row.attribute26
                                         ,'') );
      ELSIF p_step_activities.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
         l_step_activities_row.attribute26 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_step_activities.attribute26);
         l_step_activities_row.attribute26 := p_step_activities.attribute26;
      END IF;

      IF p_step_activities.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE27'
                                    ,NVL (l_step_activities_row.attribute27
                                         ,'') );
      ELSIF p_step_activities.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
         l_step_activities_row.attribute27 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_step_activities.attribute27);
         l_step_activities_row.attribute27 := p_step_activities.attribute27;
      END IF;

      IF p_step_activities.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE28'
                                    ,NVL (l_step_activities_row.attribute28
                                         ,'') );
      ELSIF p_step_activities.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
         l_step_activities_row.attribute28 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_step_activities.attribute28);
         l_step_activities_row.attribute28 := p_step_activities.attribute28;
      END IF;

      IF p_step_activities.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE29'
                                    ,NVL (l_step_activities_row.attribute29
                                         ,'') );
      ELSIF p_step_activities.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
         l_step_activities_row.attribute29 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_step_activities.attribute29);
         l_step_activities_row.attribute29 := p_step_activities.attribute29;
      END IF;

      IF p_step_activities.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value
                                    ('ATTRIBUTE30'
                                    ,NVL (l_step_activities_row.attribute30
                                         ,'') );
      ELSIF p_step_activities.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
         l_step_activities_row.attribute30 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_step_activities.attribute30);
         l_step_activities_row.attribute30 := p_step_activities.attribute30;
      END IF;

      /* Bug 3649415 - Do not run this validation if it is set to N. */
      /* It should only be set to N if it is a value set flexfield   */
      /* with a where clause using block fields from the form.       */
      /* Pass back all flexfield values w/ no validation.            */
      IF gme_common_pvt.g_flex_validate_prof = 0 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         /* Bug 3681718 - Only update flex field columns in x_ OUT parameter. */
         x_step_activities.attribute_category :=
                                      l_step_activities_row.attribute_category;
         x_step_activities.attribute1 := l_step_activities_row.attribute1;
         x_step_activities.attribute2 := l_step_activities_row.attribute2;
         x_step_activities.attribute3 := l_step_activities_row.attribute3;
         x_step_activities.attribute4 := l_step_activities_row.attribute4;
         x_step_activities.attribute5 := l_step_activities_row.attribute5;
         x_step_activities.attribute6 := l_step_activities_row.attribute6;
         x_step_activities.attribute7 := l_step_activities_row.attribute7;
         x_step_activities.attribute8 := l_step_activities_row.attribute8;
         x_step_activities.attribute9 := l_step_activities_row.attribute9;
         x_step_activities.attribute10 := l_step_activities_row.attribute10;
         x_step_activities.attribute11 := l_step_activities_row.attribute11;
         x_step_activities.attribute12 := l_step_activities_row.attribute12;
         x_step_activities.attribute13 := l_step_activities_row.attribute13;
         x_step_activities.attribute14 := l_step_activities_row.attribute14;
         x_step_activities.attribute15 := l_step_activities_row.attribute15;
         x_step_activities.attribute16 := l_step_activities_row.attribute16;
         x_step_activities.attribute17 := l_step_activities_row.attribute17;
         x_step_activities.attribute18 := l_step_activities_row.attribute18;
         x_step_activities.attribute19 := l_step_activities_row.attribute19;
         x_step_activities.attribute20 := l_step_activities_row.attribute20;
         x_step_activities.attribute21 := l_step_activities_row.attribute21;
         x_step_activities.attribute22 := l_step_activities_row.attribute22;
         x_step_activities.attribute23 := l_step_activities_row.attribute23;
         x_step_activities.attribute24 := l_step_activities_row.attribute24;
         x_step_activities.attribute25 := l_step_activities_row.attribute25;
         x_step_activities.attribute26 := l_step_activities_row.attribute26;
         x_step_activities.attribute27 := l_step_activities_row.attribute27;
         x_step_activities.attribute28 := l_step_activities_row.attribute28;
         x_step_activities.attribute29 := l_step_activities_row.attribute29;
         x_step_activities.attribute30 := l_step_activities_row.attribute30;
         RETURN;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_step_activities.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_step_activities.attribute1 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_step_activities.attribute2 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_step_activities.attribute3 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_step_activities.attribute4 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_step_activities.attribute5 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_step_activities.attribute6 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_step_activities.attribute7 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_step_activities.attribute8 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_step_activities.attribute9 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_step_activities.attribute10 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_step_activities.attribute11 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_step_activities.attribute12 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_step_activities.attribute13 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_step_activities.attribute14 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_step_activities.attribute15 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_step_activities.attribute16 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_step_activities.attribute17 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_step_activities.attribute18 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_step_activities.attribute19 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_step_activities.attribute20 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_step_activities.attribute21 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_step_activities.attribute22 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_step_activities.attribute23 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_step_activities.attribute24 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_step_activities.attribute25 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_step_activities.attribute26 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_step_activities.attribute27 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_step_activities.attribute28 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_step_activities.attribute29 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_step_activities.attribute30 :=
                                              fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN step_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_flex_step_activities;

    /*======================================================================
   -- NAME
   -- validate_flex_step_resources
   --
   -- DESCRIPTION
   --   This procedure will validate the GME_BATCH_STEP_RESOURCES_FLEX, descriptive flex field
   --   for batch step resources using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- SYNOPSIS:

        validate_flex_step_resources  (p_step_resources => a_step_resources,
                                       x_step_resources => b_step_resources,
                                       x_return_status =>l_return_status);
   -- HISTORY
   -- A.Sriram    19-FEB-2004     Created -- BUG#3406639

   -- G. Muratore 05-MAY-2004     Bug 3575735
   --  New profile added to control whether or not this procedure should be
   --  executed. A problem occurs when there is a flexfield of value set type,
   --  that has a where clause using a block field on the form.
   --
   -- G. Muratore 25-MAY-2004     Bug 3649415
   --  This is a follow up fix to bug 3575735.
   --  The flex field data entered by the user on the form is still saved even
   --  if the profile says not to validate it on the server side.
   --  Additional fix 3556979. The code will no longer fail during insert.
   --
   -- G. Muratore 11-JUN-2004     Bug 3681718
   --  This is a follow up fix to bug 3649415.
   --  Only flex field data will be overwritten in x_material_detail parameter.

   --- 16-March-2005  Punit Kumar Convergence changes
   ======================================================================= */
   PROCEDURE validate_flex_step_resources (
      p_step_resources   IN              gme_batch_step_resources%ROWTYPE
     ,x_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category   VARCHAR2 (240);
      appl_short_name        VARCHAR2 (30)                      := 'GME';
      desc_flex_name         VARCHAR2 (30) := 'GME_BATCH_STEP_RESOURCES_FLEX';
      values_or_ids          VARCHAR2 (10)                      := 'I';
      validation_date        DATE                               := SYSDATE;
      error_msg              VARCHAR2 (5000);
      validation_error       EXCEPTION;
      step_fetch_error       EXCEPTION;
      l_field_value          VARCHAR2 (240);
      l_field_name           VARCHAR2 (100);
      n                      NUMBER                             := 0;
      l_step_resource_row    gme_batch_step_resources%ROWTYPE;
      --3556979
      l_exists               NUMBER;
      l_dummy                BOOLEAN;

      CURSOR cur_record_exists (v_rec_id NUMBER)
      IS
         SELECT 1
           FROM gme_batch_step_resources
          WHERE batchstep_resource_id = v_rec_id;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      -- 3556979 Check if record being worked on already exists
      OPEN cur_record_exists (p_step_resources.batchstep_resource_id);

      FETCH cur_record_exists
       INTO l_exists;

      IF cur_record_exists%NOTFOUND THEN
         l_step_resource_row := p_step_resources;
      ELSE
         l_dummy :=
            gme_batch_step_resources_dbl.fetch_row (p_step_resources
                                                   ,l_step_resource_row);
      END IF;

      CLOSE cur_record_exists;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      x_step_resources := p_step_resources;

      /* Bug 3649415 - Retain all current flexfield values in l_step_resource_row.  */
      /* This will allow us to pass back the correct row with all the proper values */
      /* in the event the flex field validation on the server side is off.          */
      /* All the following if statements will now retain that data.                 */
      IF p_step_resources.attribute_category IS NULL THEN
         l_attribute_category :=
                             NVL (l_step_resource_row.attribute_category, '');
      ELSIF p_step_resources.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      ELSE
         l_attribute_category := p_step_resources.attribute_category;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);
      l_step_resource_row.attribute_category := l_attribute_category;

      IF p_step_resources.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE1'
                                       ,NVL (l_step_resource_row.attribute1
                                            ,'') );
      ELSIF p_step_resources.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
         l_step_resource_row.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_step_resources.attribute1);
         l_step_resource_row.attribute1 := p_step_resources.attribute1;
      END IF;

      IF p_step_resources.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE2'
                                       ,NVL (l_step_resource_row.attribute2
                                            ,'') );
      ELSIF p_step_resources.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
         l_step_resource_row.attribute2 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_step_resources.attribute2);
         l_step_resource_row.attribute2 := p_step_resources.attribute2;
      END IF;

      IF p_step_resources.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE3'
                                       ,NVL (l_step_resource_row.attribute3
                                            ,'') );
      ELSIF p_step_resources.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_step_resource_row.attribute3 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_step_resources.attribute3);
         l_step_resource_row.attribute3 := p_step_resources.attribute3;
      END IF;

      IF p_step_resources.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE4'
                                       ,NVL (l_step_resource_row.attribute4
                                            ,'') );
      ELSIF p_step_resources.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4', '');
         l_step_resource_row.attribute4 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_step_resources.attribute4);
         l_step_resource_row.attribute4 := p_step_resources.attribute4;
      END IF;

      IF p_step_resources.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE5'
                                       ,NVL (l_step_resource_row.attribute5
                                            ,'') );
      ELSIF p_step_resources.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
         l_step_resource_row.attribute5 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_step_resources.attribute5);
         l_step_resource_row.attribute5 := p_step_resources.attribute5;
      END IF;

      IF p_step_resources.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE6'
                                       ,NVL (l_step_resource_row.attribute6
                                            ,'') );
      ELSIF p_step_resources.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
         l_step_resource_row.attribute6 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_step_resources.attribute6);
         l_step_resource_row.attribute6 := p_step_resources.attribute6;
      END IF;

      IF p_step_resources.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE7'
                                       ,NVL (l_step_resource_row.attribute7
                                            ,'') );
      ELSIF p_step_resources.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
         l_step_resource_row.attribute7 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_step_resources.attribute7);
         l_step_resource_row.attribute7 := p_step_resources.attribute7;
      END IF;

      IF p_step_resources.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE8'
                                       ,NVL (l_step_resource_row.attribute8
                                            ,'') );
      ELSIF p_step_resources.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
         l_step_resource_row.attribute8 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_step_resources.attribute8);
         l_step_resource_row.attribute8 := p_step_resources.attribute8;
      END IF;

      IF p_step_resources.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE9'
                                       ,NVL (l_step_resource_row.attribute9
                                            ,'') );
      ELSIF p_step_resources.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
         l_step_resource_row.attribute9 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_step_resources.attribute9);
         l_step_resource_row.attribute9 := p_step_resources.attribute9;
      END IF;

      IF p_step_resources.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE10'
                                      ,NVL (l_step_resource_row.attribute10
                                           ,'') );
      ELSIF p_step_resources.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
         l_step_resource_row.attribute10 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_step_resources.attribute10);
         l_step_resource_row.attribute10 := p_step_resources.attribute10;
      END IF;

      IF p_step_resources.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE11'
                                      ,NVL (l_step_resource_row.attribute11
                                           ,'') );
      ELSIF p_step_resources.attribute11 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
         l_step_resource_row.attribute11 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_step_resources.attribute11);
         l_step_resource_row.attribute11 := p_step_resources.attribute11;
      END IF;

      IF p_step_resources.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE12'
                                      ,NVL (l_step_resource_row.attribute12
                                           ,'') );
      ELSIF p_step_resources.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
         l_step_resource_row.attribute12 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_step_resources.attribute12);
         l_step_resource_row.attribute12 := p_step_resources.attribute12;
      END IF;

      IF p_step_resources.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE13'
                                      ,NVL (l_step_resource_row.attribute13
                                           ,'') );
      ELSIF p_step_resources.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
         l_step_resource_row.attribute13 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_step_resources.attribute13);
         l_step_resource_row.attribute13 := p_step_resources.attribute13;
      END IF;

      IF p_step_resources.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE14'
                                      ,NVL (l_step_resource_row.attribute14
                                           ,'') );
      ELSIF p_step_resources.attribute14 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
         l_step_resource_row.attribute14 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_step_resources.attribute14);
         l_step_resource_row.attribute14 := p_step_resources.attribute14;
      END IF;

      IF p_step_resources.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE15'
                                      ,NVL (l_step_resource_row.attribute15
                                           ,'') );
      ELSIF p_step_resources.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
         l_step_resource_row.attribute15 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_step_resources.attribute15);
         l_step_resource_row.attribute15 := p_step_resources.attribute15;
      END IF;

      IF p_step_resources.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE16'
                                      ,NVL (l_step_resource_row.attribute16
                                           ,'') );
      ELSIF p_step_resources.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
         l_step_resource_row.attribute16 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_step_resources.attribute16);
         l_step_resource_row.attribute16 := p_step_resources.attribute16;
      END IF;

      IF p_step_resources.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE17'
                                      ,NVL (l_step_resource_row.attribute17
                                           ,'') );
      ELSIF p_step_resources.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
         l_step_resource_row.attribute17 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_step_resources.attribute17);
         l_step_resource_row.attribute17 := p_step_resources.attribute17;
      END IF;

      IF p_step_resources.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE18'
                                      ,NVL (l_step_resource_row.attribute18
                                           ,'') );
      ELSIF p_step_resources.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
         l_step_resource_row.attribute18 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_step_resources.attribute18);
         l_step_resource_row.attribute18 := p_step_resources.attribute18;
      END IF;

      IF p_step_resources.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE19'
                                      ,NVL (l_step_resource_row.attribute19
                                           ,'') );
      ELSIF p_step_resources.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
         l_step_resource_row.attribute19 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_step_resources.attribute19);
         l_step_resource_row.attribute19 := p_step_resources.attribute19;
      END IF;

      IF p_step_resources.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE20'
                                      ,NVL (l_step_resource_row.attribute20
                                           ,'') );
      ELSIF p_step_resources.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
         l_step_resource_row.attribute20 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_step_resources.attribute20);
         l_step_resource_row.attribute20 := p_step_resources.attribute20;
      END IF;

      IF p_step_resources.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE21'
                                      ,NVL (l_step_resource_row.attribute21
                                           ,'') );
      ELSIF p_step_resources.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
         l_step_resource_row.attribute21 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_step_resources.attribute21);
         l_step_resource_row.attribute21 := p_step_resources.attribute21;
      END IF;

      IF p_step_resources.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE22'
                                      ,NVL (l_step_resource_row.attribute22
                                           ,'') );
      ELSIF p_step_resources.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
         l_step_resource_row.attribute22 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_step_resources.attribute22);
         l_step_resource_row.attribute22 := p_step_resources.attribute22;
      END IF;

      IF p_step_resources.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE23'
                                      ,NVL (l_step_resource_row.attribute23
                                           ,'') );
      ELSIF p_step_resources.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
         l_step_resource_row.attribute23 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_step_resources.attribute23);
         l_step_resource_row.attribute23 := p_step_resources.attribute23;
      END IF;

      IF p_step_resources.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE24'
                                      ,NVL (l_step_resource_row.attribute24
                                           ,'') );
      ELSIF p_step_resources.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
         l_step_resource_row.attribute24 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_step_resources.attribute24);
         l_step_resource_row.attribute24 := p_step_resources.attribute24;
      END IF;

      IF p_step_resources.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE25'
                                      ,NVL (l_step_resource_row.attribute25
                                           ,'') );
      ELSIF p_step_resources.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
         l_step_resource_row.attribute25 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_step_resources.attribute25);
         l_step_resource_row.attribute25 := p_step_resources.attribute25;
      END IF;

      IF p_step_resources.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE26'
                                      ,NVL (l_step_resource_row.attribute26
                                           ,'') );
      ELSIF p_step_resources.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
         l_step_resource_row.attribute26 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_step_resources.attribute26);
         l_step_resource_row.attribute26 := p_step_resources.attribute26;
      END IF;

      IF p_step_resources.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE27'
                                      ,NVL (l_step_resource_row.attribute27
                                           ,'') );
      ELSIF p_step_resources.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
         l_step_resource_row.attribute27 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_step_resources.attribute27);
         l_step_resource_row.attribute27 := p_step_resources.attribute27;
      END IF;

      IF p_step_resources.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE28'
                                      ,NVL (l_step_resource_row.attribute28
                                           ,'') );
      ELSIF p_step_resources.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
         l_step_resource_row.attribute28 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_step_resources.attribute28);
         l_step_resource_row.attribute28 := p_step_resources.attribute28;
      END IF;

      IF p_step_resources.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE29'
                                      ,NVL (l_step_resource_row.attribute29
                                           ,'') );
      ELSIF p_step_resources.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
         l_step_resource_row.attribute29 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_step_resources.attribute29);
         l_step_resource_row.attribute29 := p_step_resources.attribute29;
      END IF;

      IF p_step_resources.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE30'
                                      ,NVL (l_step_resource_row.attribute30
                                           ,'') );
      ELSIF p_step_resources.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
         l_step_resource_row.attribute30 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_step_resources.attribute30);
         l_step_resource_row.attribute30 := p_step_resources.attribute30;
      END IF;

      /* Bug 3649415 - Do not run this validation if it is set to N. */
      /* It should only be set to N if it is a value set flexfield   */
      /* with a where clause using block fields from the form.       */
      /* Pass back all flexfield values w/ no validation.            */
      IF gme_common_pvt.g_flex_validate_prof = 0 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         /* Bug 3681718 - Only update flex field columns in x_ OUT parameter. */
         x_step_resources.attribute_category :=
                                        l_step_resource_row.attribute_category;
         x_step_resources.attribute1 := l_step_resource_row.attribute1;
         x_step_resources.attribute2 := l_step_resource_row.attribute2;
         x_step_resources.attribute3 := l_step_resource_row.attribute3;
         x_step_resources.attribute4 := l_step_resource_row.attribute4;
         x_step_resources.attribute5 := l_step_resource_row.attribute5;
         x_step_resources.attribute6 := l_step_resource_row.attribute6;
         x_step_resources.attribute7 := l_step_resource_row.attribute7;
         x_step_resources.attribute8 := l_step_resource_row.attribute8;
         x_step_resources.attribute9 := l_step_resource_row.attribute9;
         x_step_resources.attribute10 := l_step_resource_row.attribute10;
         x_step_resources.attribute11 := l_step_resource_row.attribute11;
         x_step_resources.attribute12 := l_step_resource_row.attribute12;
         x_step_resources.attribute13 := l_step_resource_row.attribute13;
         x_step_resources.attribute14 := l_step_resource_row.attribute14;
         x_step_resources.attribute15 := l_step_resource_row.attribute15;
         x_step_resources.attribute16 := l_step_resource_row.attribute16;
         x_step_resources.attribute17 := l_step_resource_row.attribute17;
         x_step_resources.attribute18 := l_step_resource_row.attribute18;
         x_step_resources.attribute19 := l_step_resource_row.attribute19;
         x_step_resources.attribute20 := l_step_resource_row.attribute20;
         x_step_resources.attribute21 := l_step_resource_row.attribute21;
         x_step_resources.attribute22 := l_step_resource_row.attribute22;
         x_step_resources.attribute23 := l_step_resource_row.attribute23;
         x_step_resources.attribute24 := l_step_resource_row.attribute24;
         x_step_resources.attribute25 := l_step_resource_row.attribute25;
         x_step_resources.attribute26 := l_step_resource_row.attribute26;
         x_step_resources.attribute27 := l_step_resource_row.attribute27;
         x_step_resources.attribute28 := l_step_resource_row.attribute28;
         x_step_resources.attribute29 := l_step_resource_row.attribute29;
         x_step_resources.attribute30 := l_step_resource_row.attribute30;
         RETURN;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_step_resources.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_step_resources.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_step_resources.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_step_resources.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_step_resources.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_step_resources.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_step_resources.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_step_resources.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_step_resources.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_step_resources.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_step_resources.attribute10 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_step_resources.attribute11 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_step_resources.attribute12 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_step_resources.attribute13 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_step_resources.attribute14 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_step_resources.attribute15 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_step_resources.attribute16 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_step_resources.attribute17 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_step_resources.attribute18 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_step_resources.attribute19 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_step_resources.attribute20 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_step_resources.attribute21 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_step_resources.attribute22 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_step_resources.attribute23 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_step_resources.attribute24 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_step_resources.attribute25 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_step_resources.attribute26 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_step_resources.attribute27 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_step_resources.attribute28 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_step_resources.attribute29 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_step_resources.attribute30 :=
                                              fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN step_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_flex_step_resources;

   /*======================================================================
   -- NAME
   -- validate_rsrc_txn_flex
   --
   -- DESCRIPTION
   --   This procedure will validate the GME_RESOURCE_TXN_FLEX, descriptive flex field
   --   for  resources txns using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- HISTORY

   --- 16-March-2005  Punit Kumar Created new procedure
   --- 20-OCT-2005 added new parameter
   ======================================================================= */
   PROCEDURE validate_rsrc_txn_flex (
      p_resource_txn_rec   IN              gme_resource_txns%ROWTYPE
     ,x_resource_txn_rec   IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category   VARCHAR2 (240);
      appl_short_name        VARCHAR2 (30)                      := 'GME';
      --FPBug#4395561 corrected desc_flex_name
      desc_flex_name         VARCHAR2 (30)                      := 'GME_RSRC_TXN_FLEX';
      values_or_ids          VARCHAR2 (10)                      := 'I';
      validation_date        DATE                               := SYSDATE;
      error_msg              VARCHAR2 (5000);
      validation_error       EXCEPTION;
      step_fetch_error       EXCEPTION;
      l_field_value          VARCHAR2 (240);
      l_field_name           VARCHAR2 (100);
      n                      NUMBER                             := 0;
      l_step_resource_row    gme_batch_step_resources%ROWTYPE;
      --3556979
      l_exists               NUMBER;
      l_dummy                BOOLEAN;
      /*start, Punit Kumar*/
      l_resource_txn_rec     gme_resource_txns%ROWTYPE;

      /*end */
      CURSOR cur_record_exists (v_rec_id NUMBER)
      IS
         SELECT 1
           FROM gme_resource_txns
          WHERE poc_trans_id = v_rec_id;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      OPEN cur_record_exists (p_resource_txn_rec.poc_trans_id);

      FETCH cur_record_exists
       INTO l_exists;

      IF cur_record_exists%NOTFOUND THEN
         l_resource_txn_rec := p_resource_txn_rec;
      ELSE
         l_dummy :=
            gme_resource_txns_dbl.fetch_row (p_resource_txn_rec
                                            ,l_resource_txn_rec);
      END IF;

      CLOSE cur_record_exists;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      IF p_resource_txn_rec.attribute_category IS NULL THEN
         l_attribute_category := l_resource_txn_rec.attribute_category;
      ELSIF p_resource_txn_rec.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      ELSE
         l_attribute_category := p_resource_txn_rec.attribute_category;
      END IF;

      /* end */
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);
      l_resource_txn_rec.attribute_category := l_attribute_category;

      IF p_resource_txn_rec.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,l_resource_txn_rec.attribute1);
      ELSIF p_resource_txn_rec.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
         l_resource_txn_rec.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_resource_txn_rec.attribute1);
         l_resource_txn_rec.attribute1 := p_resource_txn_rec.attribute1;
      END IF;

      IF p_resource_txn_rec.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,l_resource_txn_rec.attribute2);
      ELSIF p_resource_txn_rec.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
         l_resource_txn_rec.attribute2 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_resource_txn_rec.attribute2);
         l_resource_txn_rec.attribute2 := p_resource_txn_rec.attribute2;
      END IF;

      IF p_resource_txn_rec.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,l_resource_txn_rec.attribute3);
      ELSIF p_resource_txn_rec.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_resource_txn_rec.attribute3 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_resource_txn_rec.attribute3);
         l_resource_txn_rec.attribute3 := p_resource_txn_rec.attribute3;
      END IF;

      IF p_resource_txn_rec.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,l_resource_txn_rec.attribute4);
      ELSIF p_resource_txn_rec.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4', '');
         l_resource_txn_rec.attribute4 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_resource_txn_rec.attribute4);
         l_resource_txn_rec.attribute4 := p_resource_txn_rec.attribute4;
      END IF;

      IF p_resource_txn_rec.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,l_resource_txn_rec.attribute5);
      ELSIF p_resource_txn_rec.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
         l_resource_txn_rec.attribute5 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_resource_txn_rec.attribute5);
         l_resource_txn_rec.attribute5 := p_resource_txn_rec.attribute5;
      END IF;

      IF p_resource_txn_rec.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,l_resource_txn_rec.attribute6);
      ELSIF p_resource_txn_rec.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
         l_resource_txn_rec.attribute6 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_resource_txn_rec.attribute6);
         l_resource_txn_rec.attribute6 := p_resource_txn_rec.attribute6;
      END IF;

      IF p_resource_txn_rec.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,l_resource_txn_rec.attribute7);
      ELSIF p_resource_txn_rec.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
         l_resource_txn_rec.attribute7 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_resource_txn_rec.attribute7);
         l_resource_txn_rec.attribute7 := p_resource_txn_rec.attribute7;
      END IF;

      IF p_resource_txn_rec.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,l_resource_txn_rec.attribute8);
      ELSIF p_resource_txn_rec.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
         l_resource_txn_rec.attribute8 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_resource_txn_rec.attribute8);
         l_resource_txn_rec.attribute8 := p_resource_txn_rec.attribute8;
      END IF;

      IF p_resource_txn_rec.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,l_resource_txn_rec.attribute9);
      ELSIF p_resource_txn_rec.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
         l_resource_txn_rec.attribute9 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_resource_txn_rec.attribute9);
         l_resource_txn_rec.attribute9 := p_resource_txn_rec.attribute9;
      END IF;

      IF p_resource_txn_rec.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,l_resource_txn_rec.attribute10);
      ELSIF p_resource_txn_rec.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
         l_resource_txn_rec.attribute10 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_resource_txn_rec.attribute10);
         l_resource_txn_rec.attribute10 := p_resource_txn_rec.attribute10;
      END IF;

      IF p_resource_txn_rec.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,l_resource_txn_rec.attribute11);
      ELSIF p_resource_txn_rec.attribute11 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
         l_resource_txn_rec.attribute11 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_resource_txn_rec.attribute11);
         l_resource_txn_rec.attribute11 := p_resource_txn_rec.attribute11;
      END IF;

      IF p_resource_txn_rec.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,l_resource_txn_rec.attribute12);
      ELSIF p_resource_txn_rec.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
         l_resource_txn_rec.attribute12 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_resource_txn_rec.attribute12);
         l_resource_txn_rec.attribute12 := p_resource_txn_rec.attribute12;
      END IF;

      IF p_resource_txn_rec.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,l_resource_txn_rec.attribute13);
      ELSIF p_resource_txn_rec.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
         l_resource_txn_rec.attribute13 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_resource_txn_rec.attribute13);
         l_resource_txn_rec.attribute13 := p_resource_txn_rec.attribute13;
      END IF;

      IF p_resource_txn_rec.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,l_resource_txn_rec.attribute14);
      ELSIF p_resource_txn_rec.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
         l_resource_txn_rec.attribute14 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_resource_txn_rec.attribute14);
         l_resource_txn_rec.attribute14 := p_resource_txn_rec.attribute14;
      END IF;

      IF p_resource_txn_rec.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,l_resource_txn_rec.attribute15);
      ELSIF p_resource_txn_rec.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
         l_resource_txn_rec.attribute15 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_resource_txn_rec.attribute15);
         l_resource_txn_rec.attribute15 := p_resource_txn_rec.attribute15;
      END IF;

      IF p_resource_txn_rec.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,l_resource_txn_rec.attribute16);
      ELSIF p_resource_txn_rec.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
         l_resource_txn_rec.attribute16 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_resource_txn_rec.attribute16);
         l_resource_txn_rec.attribute16 := p_resource_txn_rec.attribute16;
      END IF;

      IF p_resource_txn_rec.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,l_resource_txn_rec.attribute17);
      ELSIF p_resource_txn_rec.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
         l_resource_txn_rec.attribute17 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_resource_txn_rec.attribute17);
         l_resource_txn_rec.attribute17 := p_resource_txn_rec.attribute17;
      END IF;

      IF p_resource_txn_rec.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,l_resource_txn_rec.attribute18);
      ELSIF p_resource_txn_rec.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
         l_resource_txn_rec.attribute18 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_resource_txn_rec.attribute18);
         l_resource_txn_rec.attribute18 := p_resource_txn_rec.attribute18;
      END IF;

      IF p_resource_txn_rec.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,l_resource_txn_rec.attribute19);
      ELSIF p_resource_txn_rec.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
         l_resource_txn_rec.attribute19 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_resource_txn_rec.attribute19);
         l_resource_txn_rec.attribute19 := p_resource_txn_rec.attribute19;
      END IF;

      IF p_resource_txn_rec.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,l_resource_txn_rec.attribute20);
      ELSIF p_resource_txn_rec.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
         l_resource_txn_rec.attribute20 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_resource_txn_rec.attribute20);
         l_resource_txn_rec.attribute20 := p_resource_txn_rec.attribute20;
      END IF;

      IF p_resource_txn_rec.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,l_resource_txn_rec.attribute21);
      ELSIF p_resource_txn_rec.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
         l_resource_txn_rec.attribute21 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_resource_txn_rec.attribute21);
         l_resource_txn_rec.attribute21 := p_resource_txn_rec.attribute21;
      END IF;

      IF p_resource_txn_rec.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,l_resource_txn_rec.attribute22);
      ELSIF p_resource_txn_rec.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
         l_resource_txn_rec.attribute22 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_resource_txn_rec.attribute22);
         l_resource_txn_rec.attribute22 := p_resource_txn_rec.attribute22;
      END IF;

      IF p_resource_txn_rec.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,l_resource_txn_rec.attribute23);
      ELSIF p_resource_txn_rec.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
         l_resource_txn_rec.attribute23 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_resource_txn_rec.attribute23);
         l_resource_txn_rec.attribute23 := p_resource_txn_rec.attribute23;
      END IF;

      IF p_resource_txn_rec.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,l_resource_txn_rec.attribute1);
      ELSIF p_resource_txn_rec.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
         l_resource_txn_rec.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_resource_txn_rec.attribute24);
         l_resource_txn_rec.attribute24 := p_resource_txn_rec.attribute24;
      END IF;

      IF p_resource_txn_rec.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,l_resource_txn_rec.attribute25);
      ELSIF p_resource_txn_rec.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
         l_resource_txn_rec.attribute25 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_resource_txn_rec.attribute25);
         l_resource_txn_rec.attribute25 := p_resource_txn_rec.attribute25;
      END IF;

      IF p_resource_txn_rec.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,l_resource_txn_rec.attribute26);
      ELSIF p_resource_txn_rec.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
         l_resource_txn_rec.attribute26 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_resource_txn_rec.attribute26);
         l_resource_txn_rec.attribute26 := p_resource_txn_rec.attribute26;
      END IF;

      IF p_resource_txn_rec.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,l_resource_txn_rec.attribute27);
      ELSIF p_resource_txn_rec.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
         l_resource_txn_rec.attribute27 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_resource_txn_rec.attribute27);
         l_resource_txn_rec.attribute27 := p_resource_txn_rec.attribute27;
      END IF;

      IF p_resource_txn_rec.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,l_resource_txn_rec.attribute28);
      ELSIF p_resource_txn_rec.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
         l_resource_txn_rec.attribute28 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_resource_txn_rec.attribute28);
         l_resource_txn_rec.attribute28 := p_resource_txn_rec.attribute28;
      END IF;

      IF p_resource_txn_rec.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,l_resource_txn_rec.attribute29);
      ELSIF p_resource_txn_rec.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
         l_resource_txn_rec.attribute29 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_resource_txn_rec.attribute29);
         l_resource_txn_rec.attribute29 := p_resource_txn_rec.attribute29;
      END IF;

      IF p_resource_txn_rec.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,l_resource_txn_rec.attribute30);
      ELSIF p_resource_txn_rec.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
         l_resource_txn_rec.attribute30 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_resource_txn_rec.attribute30);
         l_resource_txn_rec.attribute30 := p_resource_txn_rec.attribute30;
      END IF;

      --FPBug#4395561 modified following if condition to consider global flex field validate flag
      IF gme_common_pvt.g_flex_validate_prof = 0 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         x_resource_txn_rec.attribute_category :=
                                         l_resource_txn_rec.attribute_category;
         x_resource_txn_rec.attribute1 := l_resource_txn_rec.attribute1;
         x_resource_txn_rec.attribute2 := l_resource_txn_rec.attribute2;
         x_resource_txn_rec.attribute3 := l_resource_txn_rec.attribute3;
         x_resource_txn_rec.attribute4 := l_resource_txn_rec.attribute4;
         x_resource_txn_rec.attribute5 := l_resource_txn_rec.attribute5;
         x_resource_txn_rec.attribute6 := l_resource_txn_rec.attribute6;
         x_resource_txn_rec.attribute7 := l_resource_txn_rec.attribute7;
         x_resource_txn_rec.attribute8 := l_resource_txn_rec.attribute8;
         x_resource_txn_rec.attribute9 := l_resource_txn_rec.attribute9;
         x_resource_txn_rec.attribute10 := l_resource_txn_rec.attribute10;
         x_resource_txn_rec.attribute11 := l_resource_txn_rec.attribute11;
         x_resource_txn_rec.attribute12 := l_resource_txn_rec.attribute12;
         x_resource_txn_rec.attribute13 := l_resource_txn_rec.attribute13;
         x_resource_txn_rec.attribute14 := l_resource_txn_rec.attribute14;
         x_resource_txn_rec.attribute15 := l_resource_txn_rec.attribute15;
         x_resource_txn_rec.attribute16 := l_resource_txn_rec.attribute16;
         x_resource_txn_rec.attribute17 := l_resource_txn_rec.attribute17;
         x_resource_txn_rec.attribute18 := l_resource_txn_rec.attribute18;
         x_resource_txn_rec.attribute19 := l_resource_txn_rec.attribute19;
         x_resource_txn_rec.attribute20 := l_resource_txn_rec.attribute20;
         x_resource_txn_rec.attribute21 := l_resource_txn_rec.attribute21;
         x_resource_txn_rec.attribute22 := l_resource_txn_rec.attribute22;
         x_resource_txn_rec.attribute23 := l_resource_txn_rec.attribute23;
         x_resource_txn_rec.attribute24 := l_resource_txn_rec.attribute24;
         x_resource_txn_rec.attribute25 := l_resource_txn_rec.attribute25;
         x_resource_txn_rec.attribute26 := l_resource_txn_rec.attribute26;
         x_resource_txn_rec.attribute27 := l_resource_txn_rec.attribute27;
         x_resource_txn_rec.attribute28 := l_resource_txn_rec.attribute28;
         x_resource_txn_rec.attribute29 := l_resource_txn_rec.attribute29;
         x_resource_txn_rec.attribute30 := l_resource_txn_rec.attribute30;
         RETURN;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_resource_txn_rec.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_resource_txn_rec.attribute1 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_resource_txn_rec.attribute2 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_resource_txn_rec.attribute3 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_resource_txn_rec.attribute4 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_resource_txn_rec.attribute5 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_resource_txn_rec.attribute6 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_resource_txn_rec.attribute7 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_resource_txn_rec.attribute8 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_resource_txn_rec.attribute9 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_resource_txn_rec.attribute10 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_resource_txn_rec.attribute11 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_resource_txn_rec.attribute12 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_resource_txn_rec.attribute13 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_resource_txn_rec.attribute14 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_resource_txn_rec.attribute15 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_resource_txn_rec.attribute16 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_resource_txn_rec.attribute17 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_resource_txn_rec.attribute18 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_resource_txn_rec.attribute19 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_resource_txn_rec.attribute20 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_resource_txn_rec.attribute21 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_resource_txn_rec.attribute22 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_resource_txn_rec.attribute23 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_resource_txn_rec.attribute24 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_resource_txn_rec.attribute25 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_resource_txn_rec.attribute26 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_resource_txn_rec.attribute27 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_resource_txn_rec.attribute28 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_resource_txn_rec.attribute29 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_resource_txn_rec.attribute30 :=
                                              fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN step_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_rsrc_txn_flex;

   /*end*/

   /*======================================================================
   -- NAME
   -- validate_flex_material_detials
   --
   -- DESCRIPTION
   --    This procedure will validate the BATCH_DTL_FLEX, descriptive flex field
   --    for batch material details using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- SYNOPSIS:

         validate_flex_material_detials (
                        p_material_detail   => a_material_detail
                       ,x_material_detail   => b_material_detail
                       ,x_return_status     => l_return_status);
   --HISTORY
   --SivakumarG 07-MAR-2006 Bug#5078853
   -- rewritten the following procedure
   ======================================================================= */

   PROCEDURE validate_flex_material_details (
      p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,x_material_detail_rec   IN OUT NOCOPY   gme_material_details%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category    VARCHAR2 (240);
      appl_short_name         VARCHAR2 (30)                  := 'GME';
      desc_flex_name          VARCHAR2 (30)                  := 'BATCH_DTL_FLEX';
      values_or_ids           VARCHAR2 (10)                  := 'I';
      validation_date         DATE                           := SYSDATE;
      error_msg               VARCHAR2 (5000);
      l_field_value           VARCHAR2 (240);
      l_field_name            VARCHAR2 (100);
      n                       NUMBER;
      l_material_detail_rec   gme_material_details%ROWTYPE;

      validation_error        EXCEPTION;
      material_fetch_err      EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      IF p_material_detail_rec.material_detail_id IS NOT NULL THEN
        IF NOT gme_material_details_dbl.fetch_row(p_material_detail_rec, l_material_detail_rec) THEN
         RAISE material_fetch_err;
        END IF;
      ELSE
        l_material_detail_rec := p_material_detail_rec;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      IF p_material_detail_rec.attribute_category IS NULL THEN
         l_attribute_category :=
                           NVL (l_material_detail_rec.attribute_category, '');
      ELSIF p_material_detail_rec.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      ELSE
         l_attribute_category := p_material_detail_rec.attribute_category;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);
      l_material_detail_rec.attribute_category := l_attribute_category;

      IF p_material_detail_rec.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE1'
                                     ,NVL (l_material_detail_rec.attribute1
                                          ,'') );
      ELSIF p_material_detail_rec.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
         l_material_detail_rec.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_material_detail_rec.attribute1);
         l_material_detail_rec.attribute1 := p_material_detail_rec.attribute1;
      END IF;

      IF p_material_detail_rec.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE2'
                                     ,NVL (l_material_detail_rec.attribute2
                                          ,'') );
      ELSIF p_material_detail_rec.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
         l_material_detail_rec.attribute2 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_material_detail_rec.attribute2);
         l_material_detail_rec.attribute2 := p_material_detail_rec.attribute2;
      END IF;

      IF p_material_detail_rec.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE3'
                                     ,NVL (l_material_detail_rec.attribute3
                                          ,'') );
      ELSIF p_material_detail_rec.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_material_detail_rec.attribute3 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_material_detail_rec.attribute3);
         l_material_detail_rec.attribute3 := p_material_detail_rec.attribute3;
      END IF;

       IF p_material_detail_rec.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE4'
                                     ,NVL (l_material_detail_rec.attribute4
                                          ,'') );
      ELSIF p_material_detail_rec.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_material_detail_rec.attribute4 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_material_detail_rec.attribute4);
         l_material_detail_rec.attribute4 := p_material_detail_rec.attribute4;
      END IF;

       IF p_material_detail_rec.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE5'
                                     ,NVL (l_material_detail_rec.attribute5
                                          ,'') );
      ELSIF p_material_detail_rec.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
         l_material_detail_rec.attribute5 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_material_detail_rec.attribute5);
         l_material_detail_rec.attribute5 := p_material_detail_rec.attribute5;
      END IF;

      IF p_material_detail_rec.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE6'
                                     ,NVL (l_material_detail_rec.attribute6
                                          ,'') );
      ELSIF p_material_detail_rec.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
         l_material_detail_rec.attribute6 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_material_detail_rec.attribute6);
         l_material_detail_rec.attribute6 := p_material_detail_rec.attribute6;
      END IF;

      IF p_material_detail_rec.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE7'
                                     ,NVL (l_material_detail_rec.attribute7
                                          ,'') );
      ELSIF p_material_detail_rec.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
         l_material_detail_rec.attribute7 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_material_detail_rec.attribute7);
         l_material_detail_rec.attribute7 := p_material_detail_rec.attribute7;
      END IF;

      IF p_material_detail_rec.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE8'
                                     ,NVL (l_material_detail_rec.attribute8
                                          ,'') );
      ELSIF p_material_detail_rec.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
         l_material_detail_rec.attribute8 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_material_detail_rec.attribute8);
         l_material_detail_rec.attribute8 := p_material_detail_rec.attribute8;
      END IF;

      IF p_material_detail_rec.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE9'
                                     ,NVL (l_material_detail_rec.attribute9
                                          ,'') );
      ELSIF p_material_detail_rec.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
         l_material_detail_rec.attribute9 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_material_detail_rec.attribute9);
         l_material_detail_rec.attribute9 := p_material_detail_rec.attribute9;
      END IF;

      IF p_material_detail_rec.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE10'
                                     ,NVL (l_material_detail_rec.attribute10
                                          ,'') );
      ELSIF p_material_detail_rec.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
         l_material_detail_rec.attribute10 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_material_detail_rec.attribute10);
         l_material_detail_rec.attribute10 := p_material_detail_rec.attribute10;
      END IF;

      IF p_material_detail_rec.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE11'
                                     ,NVL (l_material_detail_rec.attribute11
                                          ,'') );
      ELSIF p_material_detail_rec.attribute11 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
         l_material_detail_rec.attribute11 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_material_detail_rec.attribute11);
         l_material_detail_rec.attribute11 := p_material_detail_rec.attribute11;
      END IF;

      IF p_material_detail_rec.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE12'
                                     ,NVL (l_material_detail_rec.attribute12
                                          ,'') );
      ELSIF p_material_detail_rec.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
         l_material_detail_rec.attribute12 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_material_detail_rec.attribute12);
         l_material_detail_rec.attribute12 := p_material_detail_rec.attribute12;
      END IF;

      IF p_material_detail_rec.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE13'
                                     ,NVL (l_material_detail_rec.attribute13
                                          ,'') );
      ELSIF p_material_detail_rec.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
         l_material_detail_rec.attribute13 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_material_detail_rec.attribute13);
         l_material_detail_rec.attribute13 := p_material_detail_rec.attribute13;
      END IF;

      IF p_material_detail_rec.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE14'
                                     ,NVL (l_material_detail_rec.attribute14
                                          ,'') );
      ELSIF p_material_detail_rec.attribute14 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
         l_material_detail_rec.attribute14 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_material_detail_rec.attribute14);
         l_material_detail_rec.attribute14 := p_material_detail_rec.attribute14;
      END IF;

      IF p_material_detail_rec.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE15'
                                     ,NVL (l_material_detail_rec.attribute15
                                          ,'') );
      ELSIF p_material_detail_rec.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
         l_material_detail_rec.attribute15 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_material_detail_rec.attribute15);
         l_material_detail_rec.attribute15 := p_material_detail_rec.attribute15;
      END IF;

      IF p_material_detail_rec.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE16'
                                     ,NVL (l_material_detail_rec.attribute16
                                          ,'') );
      ELSIF p_material_detail_rec.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
         l_material_detail_rec.attribute16 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_material_detail_rec.attribute16);
         l_material_detail_rec.attribute16 := p_material_detail_rec.attribute16;
      END IF;

      IF p_material_detail_rec.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE17'
                                     ,NVL (l_material_detail_rec.attribute17
                                          ,'') );
      ELSIF p_material_detail_rec.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
         l_material_detail_rec.attribute17 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_material_detail_rec.attribute17);
         l_material_detail_rec.attribute17 := p_material_detail_rec.attribute17;
      END IF;

      IF p_material_detail_rec.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE18'
                                     ,NVL (l_material_detail_rec.attribute18
                                          ,'') );
      ELSIF p_material_detail_rec.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
         l_material_detail_rec.attribute18 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_material_detail_rec.attribute18);
         l_material_detail_rec.attribute18 := p_material_detail_rec.attribute18;
      END IF;

      IF p_material_detail_rec.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE19'
                                     ,NVL (l_material_detail_rec.attribute19
                                          ,'') );
      ELSIF p_material_detail_rec.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
         l_material_detail_rec.attribute19 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_material_detail_rec.attribute19);
         l_material_detail_rec.attribute19 := p_material_detail_rec.attribute19;
      END IF;

      IF p_material_detail_rec.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE20'
                                     ,NVL (l_material_detail_rec.attribute20
                                          ,'') );
      ELSIF p_material_detail_rec.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
         l_material_detail_rec.attribute20 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_material_detail_rec.attribute20);
         l_material_detail_rec.attribute20 := p_material_detail_rec.attribute20;
      END IF;

      IF p_material_detail_rec.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE21'
                                     ,NVL (l_material_detail_rec.attribute21
                                          ,'') );
      ELSIF p_material_detail_rec.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
         l_material_detail_rec.attribute21 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_material_detail_rec.attribute21);
         l_material_detail_rec.attribute21 := p_material_detail_rec.attribute21;
      END IF;

      IF p_material_detail_rec.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE22'
                                     ,NVL (l_material_detail_rec.attribute22
                                          ,'') );
      ELSIF p_material_detail_rec.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
         l_material_detail_rec.attribute22 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_material_detail_rec.attribute22);
         l_material_detail_rec.attribute22 := p_material_detail_rec.attribute22;
      END IF;

      IF p_material_detail_rec.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE23'
                                     ,NVL (l_material_detail_rec.attribute23
                                          ,'') );
      ELSIF p_material_detail_rec.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
         l_material_detail_rec.attribute23 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_material_detail_rec.attribute23);
         l_material_detail_rec.attribute23 := p_material_detail_rec.attribute23;
      END IF;

      IF p_material_detail_rec.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE24'
                                     ,NVL (l_material_detail_rec.attribute24
                                          ,'') );
      ELSIF p_material_detail_rec.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
         l_material_detail_rec.attribute24 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_material_detail_rec.attribute24);
         l_material_detail_rec.attribute24 := p_material_detail_rec.attribute24;
      END IF;

      IF p_material_detail_rec.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE25'
                                     ,NVL (l_material_detail_rec.attribute25
                                          ,'') );
      ELSIF p_material_detail_rec.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
         l_material_detail_rec.attribute25 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_material_detail_rec.attribute25);
         l_material_detail_rec.attribute25 := p_material_detail_rec.attribute25;
      END IF;

      IF p_material_detail_rec.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE26'
                                     ,NVL (l_material_detail_rec.attribute26
                                          ,'') );
      ELSIF p_material_detail_rec.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
         l_material_detail_rec.attribute26 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_material_detail_rec.attribute26);
         l_material_detail_rec.attribute26 := p_material_detail_rec.attribute26;
      END IF;

      IF p_material_detail_rec.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE27'
                                     ,NVL (l_material_detail_rec.attribute27
                                          ,'') );
      ELSIF p_material_detail_rec.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
         l_material_detail_rec.attribute27 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_material_detail_rec.attribute27);
         l_material_detail_rec.attribute27 := p_material_detail_rec.attribute27;
      END IF;

      IF p_material_detail_rec.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE28'
                                     ,NVL (l_material_detail_rec.attribute28
                                          ,'') );
      ELSIF p_material_detail_rec.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
         l_material_detail_rec.attribute28 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_material_detail_rec.attribute28);
         l_material_detail_rec.attribute28 := p_material_detail_rec.attribute28;
      END IF;

      IF p_material_detail_rec.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE29'
                                     ,NVL (l_material_detail_rec.attribute29
                                          ,'') );
      ELSIF p_material_detail_rec.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
         l_material_detail_rec.attribute29 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_material_detail_rec.attribute29);
         l_material_detail_rec.attribute29 := p_material_detail_rec.attribute29;
      END IF;

      IF p_material_detail_rec.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value
                                     ('ATTRIBUTE30'
                                     ,NVL (l_material_detail_rec.attribute30
                                          ,'') );
      ELSIF p_material_detail_rec.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
         l_material_detail_rec.attribute30 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_material_detail_rec.attribute30);
         l_material_detail_rec.attribute30 := p_material_detail_rec.attribute30;
      END IF;

      /* if gme_common_pvt.g_flex_validate_prof is 0 then no validation required so
         copy values back */
      IF gme_common_pvt.g_flex_validate_prof = 0 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         /* only flex field values will be copied back */
         x_material_detail_rec.attribute_category :=
                                      l_material_detail_rec.attribute_category;
         x_material_detail_rec.attribute1 := l_material_detail_rec.attribute1;
         x_material_detail_rec.attribute2 := l_material_detail_rec.attribute2;
         x_material_detail_rec.attribute3 := l_material_detail_rec.attribute3;
         x_material_detail_rec.attribute4 := l_material_detail_rec.attribute4;
         x_material_detail_rec.attribute5 := l_material_detail_rec.attribute5;
         x_material_detail_rec.attribute6 := l_material_detail_rec.attribute6;
         x_material_detail_rec.attribute7 := l_material_detail_rec.attribute7;
         x_material_detail_rec.attribute8 := l_material_detail_rec.attribute8;
         x_material_detail_rec.attribute9 := l_material_detail_rec.attribute9;
         x_material_detail_rec.attribute10 := l_material_detail_rec.attribute10;
         x_material_detail_rec.attribute11 := l_material_detail_rec.attribute11;
         x_material_detail_rec.attribute12 := l_material_detail_rec.attribute12;
         x_material_detail_rec.attribute13 := l_material_detail_rec.attribute13;
         x_material_detail_rec.attribute14 := l_material_detail_rec.attribute14;
         x_material_detail_rec.attribute15 := l_material_detail_rec.attribute15;
         x_material_detail_rec.attribute16 := l_material_detail_rec.attribute16;
         x_material_detail_rec.attribute17 := l_material_detail_rec.attribute17;
         x_material_detail_rec.attribute18 := l_material_detail_rec.attribute18;
         x_material_detail_rec.attribute19 := l_material_detail_rec.attribute19;
         x_material_detail_rec.attribute20 := l_material_detail_rec.attribute20;
         x_material_detail_rec.attribute21 := l_material_detail_rec.attribute21;
         x_material_detail_rec.attribute22 := l_material_detail_rec.attribute22;
         x_material_detail_rec.attribute23 := l_material_detail_rec.attribute23;
         x_material_detail_rec.attribute24 := l_material_detail_rec.attribute24;
         x_material_detail_rec.attribute25 := l_material_detail_rec.attribute25;
         x_material_detail_rec.attribute26 := l_material_detail_rec.attribute26;
         x_material_detail_rec.attribute27 := l_material_detail_rec.attribute27;
         x_material_detail_rec.attribute28 := l_material_detail_rec.attribute28;
         x_material_detail_rec.attribute29 := l_material_detail_rec.attribute29;
         x_material_detail_rec.attribute30 := l_material_detail_rec.attribute30;
         RETURN;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_material_detail_rec.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_material_detail_rec.attribute1 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_material_detail_rec.attribute2 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_material_detail_rec.attribute3 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_material_detail_rec.attribute4 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_material_detail_rec.attribute5 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_material_detail_rec.attribute6 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_material_detail_rec.attribute7 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_material_detail_rec.attribute8 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_material_detail_rec.attribute9 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_material_detail_rec.attribute10 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_material_detail_rec.attribute11 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_material_detail_rec.attribute12 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_material_detail_rec.attribute13 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_material_detail_rec.attribute14 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_material_detail_rec.attribute15 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_material_detail_rec.attribute16 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_material_detail_rec.attribute17 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_material_detail_rec.attribute18 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_material_detail_rec.attribute19 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_material_detail_rec.attribute20 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_material_detail_rec.attribute21 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_material_detail_rec.attribute22 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_material_detail_rec.attribute23 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_material_detail_rec.attribute24 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_material_detail_rec.attribute25 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_material_detail_rec.attribute26 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_material_detail_rec.attribute27 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_material_detail_rec.attribute28 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_material_detail_rec.attribute29 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_material_detail_rec.attribute30 :=
                                              fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

       IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN material_fetch_err THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_flex_material_details;

    /*======================================================================
   -- NAME
   -- validate_flex_process_param
   --
   -- DESCRIPTION
   --    This procedure will validate the GME_BATCH_PROC_PARAM_FLEX, descriptive flex field
   --    for process parameter, using serverside flex field validation package FND_FLEX_DESCVAL.
   --
   -- SYNOPSIS:

        validate_flex_process_param(p_process_param_rec => a_process_param_rec,
                                   x_process_param_rec => b_process_param_rec,
                                   x_return_status =>l_return_status);
   -- HISTORY
   -- A.Sriram    23-FEB-2004     Created --BUG#3406639

   -- G. Muratore 05-MAY-2004     Bug 3575735
   --  New profile added to control whether or not this procedure should be
   --  executed. A problem occurs when there is a flexfield of value set type,
   --  that has a where clause using a block field on the form.
   --
   -- G. Muratore 25-MAY-2004     Bug 3649415
   --  This is a follow up fix to bug 3575735.
   --  The flex field data entered by the user on the form is still saved even
   --  if the profile says not to validate it on the server side.
   --  Additional fix 3556979. The code will no longer fail during insert.
   --
   -- G. Muratore 11-JUN-2004     Bug 3681718
   --  This is a follow up fix to bug 3649415.
   --  Only flex field data will be overwritten in x_material_detail parameter.
   ======================================================================= */
   PROCEDURE validate_flex_process_param (
      p_process_param_rec     IN              gme_process_parameters%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2
     ,x_process_param_rec     IN OUT NOCOPY   gme_process_parameters%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_attribute_category        VARCHAR2 (240);
      appl_short_name             VARCHAR2 (30)                    := 'GME';
      desc_flex_name              VARCHAR2 (30)
                                               := 'GME_BATCH_PROC_PARAM_FLEX';
      values_or_ids               VARCHAR2 (10)                    := 'I';
      validation_date             DATE                             := SYSDATE;
      error_msg                   VARCHAR2 (5000);
      validation_error            EXCEPTION;
      process_param_fetch_error   EXCEPTION;
      l_field_value               VARCHAR2 (240);
      l_field_name                VARCHAR2 (100);
      n                           NUMBER                           := 0;
      l_process_param_rec         gme_process_parameters%ROWTYPE;
      l_exists                    NUMBER;
      l_dummy                     BOOLEAN;

      CURSOR cur_record_exists (v_rec_id NUMBER)
      IS
         SELECT 1
           FROM gme_process_parameters
          WHERE process_param_id = v_rec_id;
   BEGIN
      /* Set return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Check if flexfield is enabled : '
                             || desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;

      FETCH cur_get_appl_id
       INTO pkg_application_id;

      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         ('Flexfield is not enabled, No validation required.');
         END IF;

         RETURN;
      END IF;

      -- 3556979 Check if record being worked on already exists
      OPEN cur_record_exists (p_process_param_rec.process_param_id);

      FETCH cur_record_exists
       INTO l_exists;

      IF cur_record_exists%NOTFOUND THEN
         l_process_param_rec := p_process_param_rec;
      ELSE
         l_dummy :=
            gme_process_parameters_dbl.fetch_row (p_process_param_rec
                                                 ,l_process_param_rec);
      END IF;

      CLOSE cur_record_exists;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation of the Flex field : '
                             || desc_flex_name);
         gme_debug.put_line
            ('Assignment of the attribute Category And Attribute Values to Local Variables');
      END IF;

      /* Bug 3649415 - Retain all current flexfield values in l_process_param_rec.  */
      /* This will allow us to pass back the correct row with all the proper values */
      /* in the event the flex field validation on the server side is off.          */
      /* All the following if statements will now retain that data.                 */
      IF p_process_param_rec.attribute_category IS NULL THEN
         l_attribute_category :=
                             NVL (l_process_param_rec.attribute_category, '');
      ELSIF p_process_param_rec.attribute_category = fnd_api.g_miss_char THEN
         l_attribute_category := '';
      ELSE
         l_attribute_category := p_process_param_rec.attribute_category;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
            ('setting set column values for the context value,for Global Data Elements and for context code.');
      END IF;

      fnd_flex_descval.set_context_value (l_attribute_category);
      l_process_param_rec.attribute_category := l_attribute_category;

      IF p_process_param_rec.attribute1 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE1'
                                       ,NVL (l_process_param_rec.attribute1
                                            ,'') );
      ELSIF p_process_param_rec.attribute1 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE1', '');
         l_process_param_rec.attribute1 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE1'
                                           ,p_process_param_rec.attribute1);
         l_process_param_rec.attribute1 := p_process_param_rec.attribute1;
      END IF;

      IF p_process_param_rec.attribute2 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE2'
                                       ,NVL (l_process_param_rec.attribute2
                                            ,'') );
      ELSIF p_process_param_rec.attribute2 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE2', '');
         l_process_param_rec.attribute2 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE2'
                                           ,p_process_param_rec.attribute2);
         l_process_param_rec.attribute2 := p_process_param_rec.attribute2;
      END IF;

      IF p_process_param_rec.attribute3 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE3'
                                       ,NVL (l_process_param_rec.attribute3
                                            ,'') );
      ELSIF p_process_param_rec.attribute3 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE3', '');
         l_process_param_rec.attribute3 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE3'
                                           ,p_process_param_rec.attribute3);
         l_process_param_rec.attribute3 := p_process_param_rec.attribute3;
      END IF;

      IF p_process_param_rec.attribute4 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE4'
                                       ,NVL (l_process_param_rec.attribute4
                                            ,'') );
      ELSIF p_process_param_rec.attribute4 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE4', '');
         l_process_param_rec.attribute4 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE4'
                                           ,p_process_param_rec.attribute4);
         l_process_param_rec.attribute4 := p_process_param_rec.attribute4;
      END IF;

      IF p_process_param_rec.attribute5 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE5'
                                       ,NVL (l_process_param_rec.attribute5
                                            ,'') );
      ELSIF p_process_param_rec.attribute5 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE5', '');
         l_process_param_rec.attribute5 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE5'
                                           ,p_process_param_rec.attribute5);
         l_process_param_rec.attribute5 := p_process_param_rec.attribute5;
      END IF;

      IF p_process_param_rec.attribute6 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE6'
                                       ,NVL (l_process_param_rec.attribute6
                                            ,'') );
      ELSIF p_process_param_rec.attribute6 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE6', '');
         l_process_param_rec.attribute6 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE6'
                                           ,p_process_param_rec.attribute6);
         l_process_param_rec.attribute6 := p_process_param_rec.attribute6;
      END IF;

      IF p_process_param_rec.attribute7 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE7'
                                       ,NVL (l_process_param_rec.attribute7
                                            ,'') );
      ELSIF p_process_param_rec.attribute7 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE7', '');
         l_process_param_rec.attribute7 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE7'
                                           ,p_process_param_rec.attribute7);
         l_process_param_rec.attribute7 := p_process_param_rec.attribute7;
      END IF;

      IF p_process_param_rec.attribute8 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE8'
                                       ,NVL (l_process_param_rec.attribute8
                                            ,'') );
      ELSIF p_process_param_rec.attribute8 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE8', '');
         l_process_param_rec.attribute8 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE8'
                                           ,p_process_param_rec.attribute8);
         l_process_param_rec.attribute8 := p_process_param_rec.attribute8;
      END IF;

      IF p_process_param_rec.attribute9 IS NULL THEN
         fnd_flex_descval.set_column_value
                                       ('ATTRIBUTE9'
                                       ,NVL (l_process_param_rec.attribute9
                                            ,'') );
      ELSIF p_process_param_rec.attribute9 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE9', '');
         l_process_param_rec.attribute9 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE9'
                                           ,p_process_param_rec.attribute9);
         l_process_param_rec.attribute9 := p_process_param_rec.attribute9;
      END IF;

      IF p_process_param_rec.attribute10 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE10'
                                      ,NVL (l_process_param_rec.attribute10
                                           ,'') );
      ELSIF p_process_param_rec.attribute10 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE10', '');
         l_process_param_rec.attribute10 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE10'
                                           ,p_process_param_rec.attribute10);
         l_process_param_rec.attribute10 := p_process_param_rec.attribute10;
      END IF;

      IF p_process_param_rec.attribute11 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE11'
                                      ,NVL (l_process_param_rec.attribute11
                                           ,'') );
      ELSIF p_process_param_rec.attribute11 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE11', '');
         l_process_param_rec.attribute11 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE11'
                                           ,p_process_param_rec.attribute11);
         l_process_param_rec.attribute11 := p_process_param_rec.attribute11;
      END IF;

      IF p_process_param_rec.attribute12 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE12'
                                      ,NVL (l_process_param_rec.attribute12
                                           ,'') );
      ELSIF p_process_param_rec.attribute12 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE12', '');
         l_process_param_rec.attribute12 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE12'
                                           ,p_process_param_rec.attribute12);
         l_process_param_rec.attribute12 := p_process_param_rec.attribute12;
      END IF;

      IF p_process_param_rec.attribute13 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE13'
                                      ,NVL (l_process_param_rec.attribute13
                                           ,'') );
      ELSIF p_process_param_rec.attribute13 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE13', '');
         l_process_param_rec.attribute13 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE13'
                                           ,p_process_param_rec.attribute13);
         l_process_param_rec.attribute13 := p_process_param_rec.attribute13;
      END IF;

      IF p_process_param_rec.attribute14 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE14'
                                      ,NVL (l_process_param_rec.attribute14
                                           ,'') );
      ELSIF p_process_param_rec.attribute14 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE14', '');
         l_process_param_rec.attribute14 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE14'
                                           ,p_process_param_rec.attribute14);
         l_process_param_rec.attribute14 := p_process_param_rec.attribute14;
      END IF;

      IF p_process_param_rec.attribute15 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE15'
                                      ,NVL (l_process_param_rec.attribute15
                                           ,'') );
      ELSIF p_process_param_rec.attribute15 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE15', '');
         l_process_param_rec.attribute15 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE15'
                                           ,p_process_param_rec.attribute15);
         l_process_param_rec.attribute15 := p_process_param_rec.attribute15;
      END IF;

      IF p_process_param_rec.attribute16 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE16'
                                      ,NVL (l_process_param_rec.attribute16
                                           ,'') );
      ELSIF p_process_param_rec.attribute16 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE16', '');
         l_process_param_rec.attribute16 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE16'
                                           ,p_process_param_rec.attribute16);
         l_process_param_rec.attribute16 := p_process_param_rec.attribute16;
      END IF;

      IF p_process_param_rec.attribute17 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE17'
                                      ,NVL (l_process_param_rec.attribute17
                                           ,'') );
      ELSIF p_process_param_rec.attribute17 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE17', '');
         l_process_param_rec.attribute17 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE17'
                                           ,p_process_param_rec.attribute17);
         l_process_param_rec.attribute17 := p_process_param_rec.attribute17;
      END IF;

      IF p_process_param_rec.attribute18 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE18'
                                      ,NVL (l_process_param_rec.attribute18
                                           ,'') );
      ELSIF p_process_param_rec.attribute18 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE18', '');
         l_process_param_rec.attribute18 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE18'
                                           ,p_process_param_rec.attribute18);
         l_process_param_rec.attribute18 := p_process_param_rec.attribute18;
      END IF;

      IF p_process_param_rec.attribute19 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE19'
                                      ,NVL (l_process_param_rec.attribute19
                                           ,'') );
      ELSIF p_process_param_rec.attribute19 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE19', '');
         l_process_param_rec.attribute19 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE19'
                                           ,p_process_param_rec.attribute19);
         l_process_param_rec.attribute19 := p_process_param_rec.attribute19;
      END IF;

      IF p_process_param_rec.attribute20 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE20'
                                      ,NVL (l_process_param_rec.attribute20
                                           ,'') );
      ELSIF p_process_param_rec.attribute20 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE20', '');
         l_process_param_rec.attribute20 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE20'
                                           ,p_process_param_rec.attribute20);
         l_process_param_rec.attribute20 := p_process_param_rec.attribute20;
      END IF;

      IF p_process_param_rec.attribute21 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE21'
                                      ,NVL (l_process_param_rec.attribute21
                                           ,'') );
      ELSIF p_process_param_rec.attribute21 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE21', '');
         l_process_param_rec.attribute21 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE21'
                                           ,p_process_param_rec.attribute21);
         l_process_param_rec.attribute21 := p_process_param_rec.attribute21;
      END IF;

      IF p_process_param_rec.attribute22 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE22'
                                      ,NVL (l_process_param_rec.attribute22
                                           ,'') );
      ELSIF p_process_param_rec.attribute22 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE22', '');
         l_process_param_rec.attribute22 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE22'
                                           ,p_process_param_rec.attribute22);
         l_process_param_rec.attribute22 := p_process_param_rec.attribute22;
      END IF;

      IF p_process_param_rec.attribute23 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE23'
                                      ,NVL (l_process_param_rec.attribute23
                                           ,'') );
      ELSIF p_process_param_rec.attribute23 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE23', '');
         l_process_param_rec.attribute23 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE23'
                                           ,p_process_param_rec.attribute23);
         l_process_param_rec.attribute23 := p_process_param_rec.attribute23;
      END IF;

      IF p_process_param_rec.attribute24 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE24'
                                      ,NVL (l_process_param_rec.attribute24
                                           ,'') );
      ELSIF p_process_param_rec.attribute24 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE24', '');
         l_process_param_rec.attribute24 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE24'
                                           ,p_process_param_rec.attribute24);
         l_process_param_rec.attribute24 := p_process_param_rec.attribute24;
      END IF;

      IF p_process_param_rec.attribute25 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE25'
                                      ,NVL (l_process_param_rec.attribute25
                                           ,'') );
      ELSIF p_process_param_rec.attribute25 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE25', '');
         l_process_param_rec.attribute25 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE25'
                                           ,p_process_param_rec.attribute25);
         l_process_param_rec.attribute25 := p_process_param_rec.attribute25;
      END IF;

      IF p_process_param_rec.attribute26 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE26'
                                      ,NVL (l_process_param_rec.attribute26
                                           ,'') );
      ELSIF p_process_param_rec.attribute26 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE26', '');
         l_process_param_rec.attribute26 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE26'
                                           ,p_process_param_rec.attribute26);
         l_process_param_rec.attribute26 := p_process_param_rec.attribute26;
      END IF;

      IF p_process_param_rec.attribute27 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE27'
                                      ,NVL (l_process_param_rec.attribute27
                                           ,'') );
      ELSIF p_process_param_rec.attribute27 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE27', '');
         l_process_param_rec.attribute27 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE27'
                                           ,p_process_param_rec.attribute27);
         l_process_param_rec.attribute27 := p_process_param_rec.attribute27;
      END IF;

      IF p_process_param_rec.attribute28 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE28'
                                      ,NVL (l_process_param_rec.attribute28
                                           ,'') );
      ELSIF p_process_param_rec.attribute28 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE28', '');
         l_process_param_rec.attribute28 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE28'
                                           ,p_process_param_rec.attribute28);
         l_process_param_rec.attribute28 := p_process_param_rec.attribute28;
      END IF;

      IF p_process_param_rec.attribute29 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE29'
                                      ,NVL (l_process_param_rec.attribute29
                                           ,'') );
      ELSIF p_process_param_rec.attribute29 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE29', '');
         l_process_param_rec.attribute29 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE29'
                                           ,p_process_param_rec.attribute29);
         l_process_param_rec.attribute29 := p_process_param_rec.attribute29;
      END IF;

      IF p_process_param_rec.attribute30 IS NULL THEN
         fnd_flex_descval.set_column_value
                                      ('ATTRIBUTE30'
                                      ,NVL (l_process_param_rec.attribute30
                                           ,'') );
      ELSIF p_process_param_rec.attribute30 = fnd_api.g_miss_char THEN
         fnd_flex_descval.set_column_value ('ATTRIBUTE30', '');
         l_process_param_rec.attribute30 := '';
      ELSE
         fnd_flex_descval.set_column_value ('ATTRIBUTE30'
                                           ,p_process_param_rec.attribute30);
         l_process_param_rec.attribute30 := p_process_param_rec.attribute30;
      END IF;

      /* Do not run this validation if it is set to N. */
      /* It should only be set to N if it is a value set flexfield   */
      /* with a where clause using block fields from the form.       */
      /* Pass back all flexfield values w/ no validation.            */

      /* Nsinha changed the condition IF g_flex_validate_prof = 0 THEN as part of GME_Process_Parameter_APIs_TD */
      IF p_validate_flexfields = fnd_api.g_false THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                     ('GME Flexfield is not enabled, No validation required.');
         END IF;

         /* Only update flex field columns in x_out parameter. */
         x_process_param_rec.attribute_category :=
                                        l_process_param_rec.attribute_category;
         x_process_param_rec.attribute1 := l_process_param_rec.attribute1;
         x_process_param_rec.attribute2 := l_process_param_rec.attribute2;
         x_process_param_rec.attribute3 := l_process_param_rec.attribute3;
         x_process_param_rec.attribute4 := l_process_param_rec.attribute4;
         x_process_param_rec.attribute5 := l_process_param_rec.attribute5;
         x_process_param_rec.attribute6 := l_process_param_rec.attribute6;
         x_process_param_rec.attribute7 := l_process_param_rec.attribute7;
         x_process_param_rec.attribute8 := l_process_param_rec.attribute8;
         x_process_param_rec.attribute9 := l_process_param_rec.attribute9;
         x_process_param_rec.attribute10 := l_process_param_rec.attribute10;
         x_process_param_rec.attribute11 := l_process_param_rec.attribute11;
         x_process_param_rec.attribute12 := l_process_param_rec.attribute12;
         x_process_param_rec.attribute13 := l_process_param_rec.attribute13;
         x_process_param_rec.attribute14 := l_process_param_rec.attribute14;
         x_process_param_rec.attribute15 := l_process_param_rec.attribute15;
         x_process_param_rec.attribute16 := l_process_param_rec.attribute16;
         x_process_param_rec.attribute17 := l_process_param_rec.attribute17;
         x_process_param_rec.attribute18 := l_process_param_rec.attribute18;
         x_process_param_rec.attribute19 := l_process_param_rec.attribute19;
         x_process_param_rec.attribute20 := l_process_param_rec.attribute20;
         x_process_param_rec.attribute21 := l_process_param_rec.attribute21;
         x_process_param_rec.attribute22 := l_process_param_rec.attribute22;
         x_process_param_rec.attribute23 := l_process_param_rec.attribute23;
         x_process_param_rec.attribute24 := l_process_param_rec.attribute24;
         x_process_param_rec.attribute25 := l_process_param_rec.attribute25;
         x_process_param_rec.attribute26 := l_process_param_rec.attribute26;
         x_process_param_rec.attribute27 := l_process_param_rec.attribute27;
         x_process_param_rec.attribute28 := l_process_param_rec.attribute28;
         x_process_param_rec.attribute29 := l_process_param_rec.attribute29;
         x_process_param_rec.attribute30 := l_process_param_rec.attribute30;
         RETURN;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling FND_FLEX_DESCVAL.validate_desccols ');
      END IF;

      IF fnd_flex_descval.validate_desccols
                                          (appl_short_name      => appl_short_name
                                          ,desc_flex_name       => desc_flex_name
                                          ,values_or_ids        => values_or_ids
                                          ,validation_date      => validation_date) THEN
         --SUCCESS
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Success ');
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         n := fnd_flex_descval.segment_count;

         /*Now let us copy back the storage value  */
         FOR i IN 1 .. n LOOP
            IF fnd_flex_descval.segment_column_name (i) =
                                                         'ATTRIBUTE_CATEGORY' THEN
               x_process_param_rec.attribute_category :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_process_param_rec.attribute1 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_process_param_rec.attribute2 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_process_param_rec.attribute3 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_process_param_rec.attribute4 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_process_param_rec.attribute5 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_process_param_rec.attribute6 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_process_param_rec.attribute7 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_process_param_rec.attribute8 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_process_param_rec.attribute9 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_process_param_rec.attribute10 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_process_param_rec.attribute11 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_process_param_rec.attribute12 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_process_param_rec.attribute13 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_process_param_rec.attribute14 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_process_param_rec.attribute15 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_process_param_rec.attribute16 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_process_param_rec.attribute17 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_process_param_rec.attribute18 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_process_param_rec.attribute19 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_process_param_rec.attribute20 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_process_param_rec.attribute21 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_process_param_rec.attribute22 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_process_param_rec.attribute23 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_process_param_rec.attribute24 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_process_param_rec.attribute25 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_process_param_rec.attribute26 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_process_param_rec.attribute27 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_process_param_rec.attribute28 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_process_param_rec.attribute29 :=
                                              fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_process_param_rec.attribute30 :=
                                              fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Validation Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR'
                                    ,'MSG'
                                    ,error_msg);
         RAISE validation_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Validation completed for the Flex field : '
                             || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN validation_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                 (   'Validation completed with errors for the Flex field : '
                  || desc_flex_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN process_param_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || desc_flex_name
                                || ': '
                                || 'in unexpected error');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END validate_flex_process_param;

   -- FPBug#4395561 Start
   /*======================================================================
    -- NAME
    -- create_flex_batch_header
    --
    -- DESCRIPTION
    --    This procedure will assign the default values of the segments into the columns.
    --
    -- SYNOPSIS:

       create_flex_batch_header (
                  p_batch_header    IN              gme_batch_header%ROWTYPE,
                  x_batch_header    IN OUT NOCOPY   gme_batch_header%ROWTYPE
                  x_return_status   OUT NOCOPY      VARCHAR2);
    -- HISTORY
    -- K.Swapna    07-MAR-2005     Created --BUG#4050727
    --25-MAY-2005 Swapna K Bug#4257930
      Changed the whole logic by adding the function call,
      fnd_flex_descval.validate_desccols with the parameter,values_or_ids as 'D'
      and erroring out from the procedure based on global validate flag
  ======================================================================= */
    PROCEDURE create_flex_batch_header (
      p_batch_header    IN              gme_batch_header%ROWTYPE,
      x_batch_header    IN OUT NOCOPY   gme_batch_header%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
    ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'BATCH_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;

    BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_batch_header := p_batch_header;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_batch_header');
      END IF;
       IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;
      l_attribute_category := NVL(x_batch_header.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_batch_header.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_batch_header.attribute2, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_batch_header.attribute3, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_batch_header.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_batch_header.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_batch_header.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_batch_header.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_batch_header.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_batch_header.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_batch_header.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_batch_header.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_batch_header.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_batch_header.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_batch_header.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_batch_header.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_batch_header.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_batch_header.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_batch_header.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_batch_header.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_batch_header.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_batch_header.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_batch_header.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_batch_header.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_batch_header.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_batch_header.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_batch_header.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_batch_header.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_batch_header.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_batch_header.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_batch_header.attribute30, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE31',
            NVL (x_batch_header.attribute31, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE32',
            NVL (x_batch_header.attribute32, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE33',
            NVL (x_batch_header.attribute33, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE34',
            NVL (x_batch_header.attribute34, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE35',
            NVL (x_batch_header.attribute35, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE36',
            NVL (x_batch_header.attribute36, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE37',
            NVL (x_batch_header.attribute37, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE38',
            NVL (x_batch_header.attribute38, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE39',
            NVL (x_batch_header.attribute39, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE40',
            NVL (x_batch_header.attribute40, ''));


      IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_batch_header.attribute_category := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_batch_header.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_batch_header.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_batch_header.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_batch_header.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_batch_header.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_batch_header.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_batch_header.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_batch_header.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_batch_header.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_batch_header.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_batch_header.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_batch_header.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_batch_header.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_batch_header.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_batch_header.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_batch_header.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_batch_header.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_batch_header.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_batch_header.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_batch_header.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_batch_header.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_batch_header.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_batch_header.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_batch_header.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_batch_header.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_batch_header.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_batch_header.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_batch_header.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_batch_header.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_batch_header.attribute30 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE31' THEN
               x_batch_header.attribute31 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE32' THEN
               x_batch_header.attribute32 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE33' THEN
               x_batch_header.attribute33 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE34' THEN
               x_batch_header.attribute34 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE35' THEN
               x_batch_header.attribute35 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE36' THEN
               x_batch_header.attribute36 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE37' THEN
               x_batch_header.attribute37 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE38' THEN
               x_batch_header.attribute38 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE39' THEN
               x_batch_header.attribute39 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE40' THEN
               x_batch_header.attribute40 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;

         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
        /* error out based on global validate flag */
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_batch_header;

   /*======================================================================
     -- NAME
     -- create_flex_batch_step
     --
     -- DESCRIPTION
     --    This procedure will assign the default values of the segments into the columns.
     -- SYNOPSIS:

      create_flex_batch_step (
                  p_batch_step      IN              gme_batch_steps%ROWTYPE,
                  x_batch_step      IN OUT NOCOPY   gme_batch_steps%ROWTYPE,
                  x_return_status   OUT NOCOPY      VARCHAR2);
     -- HISTORY
     -- K.Swapna    07-MAR-2005     Created --BUG#4050727
     --K Swapna Bug#4257930   25-MAY-2005
       Changed the whole logic by adding the function call,
       fnd_flex_descval.validate_desccols with the parameter,values_or_ids as 'D'
       and erroring out from the procedure based on global validate flag
  ======================================================================= */
     PROCEDURE create_flex_batch_step (
      p_batch_step      IN              gme_batch_steps%ROWTYPE,
      x_batch_step      IN OUT NOCOPY   gme_batch_steps%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
     ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'BATCH_STEPS_DTL_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n                      NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_batch_step := p_batch_step;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_batch_step');
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;

      l_attribute_category := NVL (x_batch_step.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_batch_step.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_batch_step.attribute2, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_batch_step.attribute3, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_batch_step.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_batch_step.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_batch_step.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_batch_step.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_batch_step.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_batch_step.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_batch_step.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_batch_step.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_batch_step.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_batch_step.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_batch_step.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_batch_step.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_batch_step.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_batch_step.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_batch_step.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_batch_step.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_batch_step.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_batch_step.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_batch_step.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_batch_step.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_batch_step.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_batch_step.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_batch_step.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_batch_step.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_batch_step.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_batch_step.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_batch_step.attribute30, ''));
      IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_batch_step.attribute_category := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_batch_step.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_batch_step.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_batch_step.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_batch_step.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_batch_step.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_batch_step.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_batch_step.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_batch_step.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_batch_step.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_batch_step.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_batch_step.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_batch_step.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_batch_step.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_batch_step.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_batch_step.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_batch_step.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_batch_step.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_batch_step.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_batch_step.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_batch_step.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_batch_step.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_batch_step.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_batch_step.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_batch_step.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_batch_step.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_batch_step.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_batch_step.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_batch_step.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_batch_step.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_batch_step.attribute30 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;
         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
         /* error out based on value global validate flag */
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;
      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;

   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_batch_step;
   /*======================================================================
   -- NAME
   -- create_flex_step_activities
   --
   -- DESCRIPTION
   --    This procedure will assign the default values of the segments into the columns.
   -- SYNOPSIS:

     create_flex_step_activities (
                 p_step_activities   IN              gme_batch_step_activities%ROWTYPE,
                 x_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE,
                 x_return_status   OUT NOCOPY      VARCHAR2
   -- HISTORY
   -- K.Swapna    07-MAR-2005     Created --BUG#4050727
   --K Swapna Bug#4257930   25-MAY-2005
     Changed the whole logic by adding the function call,
     fnd_flex_descval.validate_desccols with the parameter,values_or_ids as 'D'
     and erroring out from the procedure based on global validate flag
   ======================================================================= */
     PROCEDURE create_flex_step_activities (
      p_step_activities   IN              gme_batch_step_activities%ROWTYPE,
      x_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
     ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'GME_BATCH_STEP_ACTIVITIES_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n                      NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_step_activities :=  p_step_activities;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_step_activities');
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;
      l_attribute_category := NVL (x_step_activities.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_step_activities.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_step_activities.attribute2, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_step_activities.attribute3, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_step_activities.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_step_activities.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_step_activities.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_step_activities.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_step_activities.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_step_activities.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_step_activities.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_step_activities.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_step_activities.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_step_activities.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_step_activities.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_step_activities.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_step_activities.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_step_activities.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_step_activities.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_step_activities.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_step_activities.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_step_activities.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_step_activities.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_step_activities.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_step_activities.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_step_activities.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_step_activities.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_step_activities.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_step_activities.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_step_activities.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_step_activities.attribute30, ''));
      IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_step_activities.attribute_category :=fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_step_activities.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_step_activities.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_step_activities.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_step_activities.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_step_activities.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_step_activities.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_step_activities.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_step_activities.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_step_activities.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_step_activities.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_step_activities.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_step_activities.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_step_activities.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_step_activities.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_step_activities.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_step_activities.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_step_activities.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_step_activities.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_step_activities.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_step_activities.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_step_activities.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_step_activities.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_step_activities.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_step_activities.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_step_activities.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_step_activities.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_step_activities.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_step_activities.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_step_activities.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_step_activities.attribute30 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;
         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
        /* error out based on global validate flag*/
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_step_activities;

   /*======================================================================
  -- NAME
  -- create_flex_step_resources
  --
  -- DESCRIPTION
  --    This procedure will assign the default values of the segments into the columns.
  -- SYNOPSIS:

      create_flex_step_resources (
                p_step_resources   IN              gme_batch_step_resources%ROWTYPE,
                x_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE,
                x_return_status   OUT NOCOPY      VARCHAR2);
  -- HISTORY
  -- K.Swapna    07-MAR-2005     Created --BUG#4050727
  --K Swapna Bug#4257930   25-MAY-2005
    Changed the whole logic by adding the function call,
     fnd_flex_descval.validate_desccols with the parameter,values_or_ids as 'D'
     and erroring out from the procedure based on global validate flag
  ======================================================================= */
     PROCEDURE create_flex_step_resources (
      p_step_resources   IN              gme_batch_step_resources%ROWTYPE,
      x_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
     ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'GME_BATCH_STEP_RESOURCES_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n                      NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_step_resources :=  p_step_resources;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_step_resources');
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;
      l_attribute_category := NVL (x_step_resources.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_step_resources.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_step_resources.attribute2, ''));

         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_step_resources.attribute3, ''));

         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_step_resources.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_step_resources.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_step_resources.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_step_resources.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_step_resources.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_step_resources.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_step_resources.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_step_resources.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_step_resources.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_step_resources.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_step_resources.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_step_resources.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_step_resources.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_step_resources.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_step_resources.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_step_resources.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_step_resources.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_step_resources.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_step_resources.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_step_resources.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_step_resources.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_step_resources.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_step_resources.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_step_resources.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_step_resources.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_step_resources.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_step_resources.attribute30, ''));
      IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_step_resources.attribute_category := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_step_resources.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_step_resources.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_step_resources.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_step_resources.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_step_resources.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_step_resources.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_step_resources.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_step_resources.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_step_resources.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_step_resources.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_step_resources.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_step_resources.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_step_resources.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_step_resources.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_step_resources.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_step_resources.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_step_resources.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_step_resources.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_step_resources.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_step_resources.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_step_resources.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_step_resources.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_step_resources.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_step_resources.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_step_resources.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_step_resources.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_step_resources.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_step_resources.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_step_resources.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_step_resources.attribute30 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;
         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
         /* error out based on global validate flag */
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_step_resources;

   /*======================================================================
    -- NAME
    -- create_flex_process_param
    --
    -- DESCRIPTION
    --    This procedure will assign the default values of the segments into the columns.
    -- SYNOPSIS:
       create_flex_process_param (
                p_process_param_rec   IN              gme_process_parameters%ROWTYPE,
                x_process_param_rec   IN OUT NOCOPY   gme_process_parameters%ROWTYPE,
                x_return_status   OUT NOCOPY      VARCHAR2
    -- HISTORY
    -- K.Swapna    07-MAR-2005     Created --BUG#4050727
    -- K Swapna Bug#4257930   25-MAY-2005
       Changed the whole logic by adding the function call,
       fnd_flex_descval.validate_desccols with the parameter,values_or_ids as 'D'
       and erroring out from the procedure based on profile, GME:Validate Flex on sertver.
  ======================================================================= */
  PROCEDURE create_flex_process_param (
      p_process_param_rec   IN              gme_process_parameters%ROWTYPE,
      x_process_param_rec   IN OUT NOCOPY   gme_process_parameters%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'GME_BATCH_PROC_PARAM_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n                      NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_process_param_rec :=  p_process_param_rec;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_process_param');
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;
      l_attribute_category := NVL (x_process_param_rec.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_process_param_rec.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_process_param_rec.attribute2, ''));

         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_process_param_rec.attribute3, ''));

         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_process_param_rec.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_process_param_rec.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_process_param_rec.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_process_param_rec.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_process_param_rec.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_process_param_rec.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_process_param_rec.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_process_param_rec.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_process_param_rec.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_process_param_rec.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_process_param_rec.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_process_param_rec.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_process_param_rec.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_process_param_rec.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_process_param_rec.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_process_param_rec.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_process_param_rec.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_process_param_rec.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_process_param_rec.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_process_param_rec.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_process_param_rec.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_process_param_rec.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_process_param_rec.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_process_param_rec.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_process_param_rec.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_process_param_rec.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_process_param_rec.attribute30, ''));
      IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_process_param_rec.attribute_category := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_process_param_rec.attribute1 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_process_param_rec.attribute2 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_process_param_rec.attribute3 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_process_param_rec.attribute4 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_process_param_rec.attribute5 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_process_param_rec.attribute6 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_process_param_rec.attribute7 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_process_param_rec.attribute8 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_process_param_rec.attribute9 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_process_param_rec.attribute10 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_process_param_rec.attribute11 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_process_param_rec.attribute12 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_process_param_rec.attribute13 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_process_param_rec.attribute14 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_process_param_rec.attribute15 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_process_param_rec.attribute16 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_process_param_rec.attribute17 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_process_param_rec.attribute18 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_process_param_rec.attribute19 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_process_param_rec.attribute20 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_process_param_rec.attribute21 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_process_param_rec.attribute22 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_process_param_rec.attribute23 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_process_param_rec.attribute24 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_process_param_rec.attribute25 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_process_param_rec.attribute26 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_process_param_rec.attribute27 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_process_param_rec.attribute28 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_process_param_rec.attribute29 := fnd_flex_descval.segment_id(i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_process_param_rec.attribute30 := fnd_flex_descval.segment_id(i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;
        gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
        /* error out based on global validate flag */
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;
      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_process_param;
   /*======================================================================
    *   NAME
    *   create_flex_material_details
    *
    *  DESCRIPTION
    *  This procedure will assign the default values of the segments
    *   into the columns.
    *  SYNOPSIS:
    *  create_flex_material_details (
    *                p_process_param_rec   IN
    *                gme_process_parameters%ROWTYPE,
    *                x_process_param_rec   IN OUT NOCOPY gme_process_parameters%ROWTYPE,
    *                x_return_status OUT NOCOPY VARCHAR2);
    *  HISTORY
    *  K.Swapna 07-MAR-2005 Created --BUG#4050727
    *  K Swapna 25-MAY-2005 Bug#4257930
    *    Changed the whole logic by adding the function call,
    *    fnd_flex_descval.validate_desccols with the parameter,values_or_ids as 'D'
    *    and erroring out from the procedure based on global validate flag
    * ======================================================================= */

     PROCEDURE create_flex_material_details (
      p_material_detail   IN              gme_material_details%ROWTYPE,
      x_material_detail   IN OUT NOCOPY   gme_material_details%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
     ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'BATCH_DTL_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n                      NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;

   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_material_detail :=  p_material_detail;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_material_details');
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;
      l_attribute_category := NVL (x_material_detail.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_material_detail.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_material_detail.attribute2, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_material_detail.attribute3, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_material_detail.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_material_detail.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_material_detail.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_material_detail.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_material_detail.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_material_detail.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_material_detail.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_material_detail.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_material_detail.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_material_detail.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_material_detail.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_material_detail.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_material_detail.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_material_detail.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_material_detail.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_material_detail.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_material_detail.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_material_detail.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_material_detail.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_material_detail.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_material_detail.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_material_detail.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_material_detail.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_material_detail.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_material_detail.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_material_detail.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_material_detail.attribute30, ''));
      IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_material_detail.attribute_category := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_material_detail.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_material_detail.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_material_detail.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_material_detail.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_material_detail.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_material_detail.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_material_detail.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_material_detail.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_material_detail.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_material_detail.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_material_detail.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_material_detail.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_material_detail.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_material_detail.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_material_detail.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_material_detail.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_material_detail.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_material_detail.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_material_detail.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_material_detail.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_material_detail.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_material_detail.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_material_detail.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_material_detail.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_material_detail.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_material_detail.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_material_detail.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_material_detail.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_material_detail.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_material_detail.attribute30 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;
         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
         /* error out based on global validate flag */
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;
      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_material_details;

   /*======================================================================
    -- NAME
    -- create_flex_resource_txns
    --
    -- DESCRIPTION
    --    This procedure will assign the default values of the segments into the columns.
    --
    -- SYNOPSIS:
       create_flex_resource_txns (
                                  p_resource_txns   IN              gme_resource_txns%ROWTYPE,
                                  x_resource_txns   IN OUT NOCOPY   gme_resource_txns%ROWTYPE,
                                  x_return_status   OUT NOCOPY      VARCHAR2
                                );
    -- HISTORY
    -- Sivakumar.G    03-NOV-2005   Created --BUG#4395561
  ======================================================================= */
   PROCEDURE create_flex_resource_txns (
      p_resource_txns   IN              gme_resource_txns%ROWTYPE,
      x_resource_txns   IN OUT NOCOPY   gme_resource_txns%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      appl_short_name        VARCHAR2 (30)              := 'GME';
      desc_flex_name         VARCHAR2 (30)              := 'GME_RSRC_TXN_FLEX';
      values_or_ids          VARCHAR2 (10)              := 'D';
      validation_date        DATE                       := SYSDATE;
      error_msg              VARCHAR2 (5000);
      n                      NUMBER := 0;
      l_attribute_category   VARCHAR2 (240);
      defaulting_error       EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_resource_txns :=  p_resource_txns;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Entered into the procedure create_flex_material_details');
      END IF;

      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line ('Check if flexfield is enabled : ' ||desc_flex_name);
      END IF;

      OPEN cur_get_appl_id;
      FETCH cur_get_appl_id INTO pkg_application_id;
      CLOSE cur_get_appl_id;

      IF NOT fnd_flex_apis.is_descr_setup (pkg_application_id, desc_flex_name) THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Flexfield is not enabled, No validation required.');
         END IF;
         RETURN;
      END IF;
      l_attribute_category := NVL (x_resource_txns.attribute_category, '');
      fnd_flex_descval.set_context_value (l_attribute_category);
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE1',
            NVL (x_resource_txns.attribute1, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE2',
            NVL (x_resource_txns.attribute2, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE3',
            NVL (x_resource_txns.attribute3, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE4',
            NVL (x_resource_txns.attribute4, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE5',
            NVL (x_resource_txns.attribute5, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE6',
            NVL (x_resource_txns.attribute6, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE7',
            NVL (x_resource_txns.attribute7, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE8',
            NVL (x_resource_txns.attribute8, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE9',
            NVL (x_resource_txns.attribute9, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE10',
            NVL (x_resource_txns.attribute10, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE11',
            NVL (x_resource_txns.attribute11, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE12',
            NVL (x_resource_txns.attribute12, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE13',
            NVL (x_resource_txns.attribute13, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE14',
            NVL (x_resource_txns.attribute14, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE15',
            NVL (x_resource_txns.attribute15, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE16',
            NVL (x_resource_txns.attribute16, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE17',
            NVL (x_resource_txns.attribute17, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE18',
            NVL (x_resource_txns.attribute18, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE19',
            NVL (x_resource_txns.attribute19, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE20',
            NVL (x_resource_txns.attribute20, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE21',
            NVL (x_resource_txns.attribute21, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE22',
            NVL (x_resource_txns.attribute22, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE23',
            NVL (x_resource_txns.attribute23, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE24',
            NVL (x_resource_txns.attribute24, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE25',
            NVL (x_resource_txns.attribute25, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE26',
            NVL (x_resource_txns.attribute26, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE27',
            NVL (x_resource_txns.attribute27, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE28',
            NVL (x_resource_txns.attribute28, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE29',
            NVL (x_resource_txns.attribute29, ''));
         fnd_flex_descval.set_column_value (
            'ATTRIBUTE30',
            NVL (x_resource_txns.attribute30, ''));

		IF fnd_flex_descval.validate_desccols (
            appl_short_name     => appl_short_name,
            desc_flex_name      => desc_flex_name,
            values_or_ids       => values_or_ids,
            validation_date     => validation_date
         ) THEN
         --SUCCESS
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Success. ');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         n := fnd_flex_descval.segment_count;
         /*Now let us copy back the default values returned from the above call */
         FOR i IN 1 .. n
         LOOP
            IF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE_CATEGORY' THEN
               x_resource_txns.attribute_category := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE1' THEN
               x_resource_txns.attribute1 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE2' THEN
               x_resource_txns.attribute2 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE3' THEN
               x_resource_txns.attribute3 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE4' THEN
               x_resource_txns.attribute4 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE5' THEN
               x_resource_txns.attribute5 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE6' THEN
               x_resource_txns.attribute6 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE7' THEN
               x_resource_txns.attribute7 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE8' THEN
               x_resource_txns.attribute8 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE9' THEN
               x_resource_txns.attribute9 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE10' THEN
               x_resource_txns.attribute10 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE11' THEN
               x_resource_txns.attribute11 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE12' THEN
               x_resource_txns.attribute12 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE13' THEN
               x_resource_txns.attribute13 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE14' THEN
               x_resource_txns.attribute14 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE15' THEN
               x_resource_txns.attribute15 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE16' THEN
               x_resource_txns.attribute16 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE17' THEN
               x_resource_txns.attribute17 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE18' THEN
               x_resource_txns.attribute18 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE19' THEN
               x_resource_txns.attribute19 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE20' THEN
               x_resource_txns.attribute20 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE21' THEN
               x_resource_txns.attribute21 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE22' THEN
               x_resource_txns.attribute22 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE23' THEN
               x_resource_txns.attribute23 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE24' THEN
               x_resource_txns.attribute24 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE25' THEN
               x_resource_txns.attribute25 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE26' THEN
               x_resource_txns.attribute26 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE27' THEN
               x_resource_txns.attribute27 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE28' THEN
               x_resource_txns.attribute28 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE29' THEN
               x_resource_txns.attribute29 := fnd_flex_descval.segment_id (i);
            ELSIF fnd_flex_descval.segment_column_name (i) = 'ATTRIBUTE30' THEN
               x_resource_txns.attribute30 := fnd_flex_descval.segment_id (i);
            END IF;
         END LOOP;
      ELSE
         error_msg := fnd_flex_descval.error_message;
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line ('Defaulting Ends With Error(s) :');
            gme_debug.put_line ('Error :' || error_msg);
         END IF;
         gme_common_pvt.log_message ('FLEX-USER DEFINED ERROR', 'MSG', error_msg);
         /* error out based on global validate flag */
        IF gme_common_pvt.g_flex_validate_prof = 1 THEN
          IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
             gme_debug.put_line ('GME Flexfield is enabled, Give the Error.');
          END IF;
          RAISE defaulting_error;
        END IF;
      END IF;
      IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
         gme_debug.put_line (
            'Defaulting completed for the Flex field : ' || desc_flex_name);
      END IF;
   EXCEPTION
      WHEN defaulting_error THEN
         IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
            gme_debug.put_line (
               'Defaulting completed with errors for the Flex field : ' ||desc_flex_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line (g_pkg_name||'.'||desc_flex_name||': '||'in unexpected error');
        END IF;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg (g_pkg_name, desc_flex_name);
   END create_flex_resource_txns;

   --FPBug#4395561 End
END gme_validate_flex_fld_pvt;

/
