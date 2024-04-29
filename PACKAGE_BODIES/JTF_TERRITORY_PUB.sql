--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_PUB" AS
/* $Header: jtfpterb.pls 120.0.12010000.2 2009/09/07 06:26:45 vpalle ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting territory
--      related information IN to information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/09/99    VNEDUNGA        Created
--      07/14/99    JDOCHERT        Updated existing public APIs and
--                                  added new public APIs
--      12/22/99    VNEDUNGA        Changing the procedure to include
--                                  changes coresponding to JTF_TERR-RSC
--                                  chnages
--      03/22/00    VNEDUNGA        Putting in FND_MESSAGE calls and
--                                  changes corresponding to FULL_ACCESS_FLAG
--                                  addition
--      06/08/00    VNEDUNGA        Changing convert pub to pvt resource record
--      07/14/00    JDOCHERT        BUG# 1355914 - FIX
--      09/17/00    JDOCHERT        BUG#1408610 FIX
--      12/03/04    achanda         added value4_id : bug # 3726007
--
--    End of Comments
--
   g_pkg_name           CONSTANT VARCHAR2(30) := 'JTF_TERRITORY_PUB';
   g_file_name          CONSTANT VARCHAR2(12) := 'jtfpterb.pls';

-- -------------------------------------------------
--   Package Name : Convert_TerrRec_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  jtf_terr_rec from pub to pvt before
--                  calling the JTF_TERRITORY_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrrec_pubtopvt (
      p_terr_rec   IN       jtf_territory_pub.terr_all_rec_type
            := g_miss_terr_all_rec,
      x_terr_rec   OUT NOCOPY      jtf_territory_pvt.terr_all_rec_type
   )
   AS
   BEGIN
      --dbms_output.put_line('Convert_TerrRec_PubToPvt: Entering API');
      x_terr_rec.terr_id := p_terr_rec.terr_id;
      x_terr_rec.last_update_date := p_terr_rec.last_update_date;
      x_terr_rec.last_updated_by := p_terr_rec.last_updated_by;
      x_terr_rec.creation_date := p_terr_rec.creation_date;
      x_terr_rec.created_by := p_terr_rec.created_by;
      x_terr_rec.last_update_login := p_terr_rec.last_update_login;
      x_terr_rec.application_short_name := p_terr_rec.application_short_name;
      x_terr_rec.name := p_terr_rec.name;
      x_terr_rec.enabled_flag := p_terr_rec.enabled_flag;
      x_terr_rec.request_id := p_terr_rec.request_id;
      x_terr_rec.program_application_id := p_terr_rec.program_application_id;
      x_terr_rec.program_id := p_terr_rec.program_id;
      x_terr_rec.program_update_date := p_terr_rec.program_update_date;
      x_terr_rec.start_date_active := p_terr_rec.start_date_active;
      x_terr_rec.rank := p_terr_rec.rank;
      x_terr_rec.end_date_active := p_terr_rec.end_date_active;
      x_terr_rec.description := p_terr_rec.description;
      x_terr_rec.update_flag := p_terr_rec.update_flag;
      x_terr_rec.auto_assign_resources_flag :=
         p_terr_rec.auto_assign_resources_flag;
      x_terr_rec.planned_flag := p_terr_rec.planned_flag;
      x_terr_rec.territory_type_id := p_terr_rec.territory_type_id;
      x_terr_rec.parent_territory_id := p_terr_rec.parent_territory_id;
      x_terr_rec.template_flag := p_terr_rec.template_flag;
      x_terr_rec.template_territory_id := p_terr_rec.template_territory_id;
      x_terr_rec.escalation_territory_flag :=
         p_terr_rec.escalation_territory_flag;
      x_terr_rec.escalation_territory_id :=
         p_terr_rec.escalation_territory_id;
      x_terr_rec.overlap_allowed_flag := p_terr_rec.overlap_allowed_flag;
      x_terr_rec.attribute_category := p_terr_rec.attribute_category;
      x_terr_rec.attribute1 := p_terr_rec.attribute1;
      x_terr_rec.attribute2 := p_terr_rec.attribute2;
      x_terr_rec.attribute3 := p_terr_rec.attribute3;
      x_terr_rec.attribute4 := p_terr_rec.attribute4;
      x_terr_rec.attribute5 := p_terr_rec.attribute5;
      x_terr_rec.attribute6 := p_terr_rec.attribute6;
      x_terr_rec.attribute7 := p_terr_rec.attribute7;
      x_terr_rec.attribute8 := p_terr_rec.attribute8;
      x_terr_rec.attribute9 := p_terr_rec.attribute9;
      x_terr_rec.attribute10 := p_terr_rec.attribute10;
      x_terr_rec.attribute11 := p_terr_rec.attribute11;
      x_terr_rec.attribute12 := p_terr_rec.attribute12;
      x_terr_rec.attribute13 := p_terr_rec.attribute13;
      x_terr_rec.attribute14 := p_terr_rec.attribute14;
      x_terr_rec.attribute15 := p_terr_rec.attribute15;
      x_terr_rec.org_id      := p_terr_rec.org_id;
      x_terr_rec.num_winners := p_terr_rec.num_winners;
   --

   END convert_terrrec_pubtopvt;

-- --------------------------------------------------------
--   Package Name : Convert_TerrQualTbl_PubToPvt
-- --------------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  JTF_TERR_QUAL_TBL from pub to pvt
--                  before calling the JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- ---------------------------------------------------------
   PROCEDURE convert_terrqualtbl_pubtopvt (
      p_terrqual_tbl   IN       jtf_territory_pub.terr_qual_tbl_type,
      x_terrqual_tbl   OUT NOCOPY      jtf_territory_pvt.terr_qual_tbl_type
   )
   AS
      l_counter                     NUMBER;
   --
   BEGIN
      --dbms_output.put_line('Convert_TerrQualTbl_PubToPvt: Entering API');
      IF p_terrqual_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      FOR l_counter IN 1 .. p_terrqual_tbl.COUNT
      LOOP
         --
         x_terrqual_tbl (l_counter).terr_qual_id :=
            p_terrqual_tbl (l_counter).terr_qual_id;
         x_terrqual_tbl (l_counter).last_update_date :=
            p_terrqual_tbl (l_counter).last_update_date;
         x_terrqual_tbl (l_counter).last_updated_by :=
            p_terrqual_tbl (l_counter).last_updated_by;
         x_terrqual_tbl (l_counter).creation_date :=
            p_terrqual_tbl (l_counter).creation_date;
         x_terrqual_tbl (l_counter).created_by :=
            p_terrqual_tbl (l_counter).created_by;
         x_terrqual_tbl (l_counter).last_update_login :=
            p_terrqual_tbl (l_counter).last_update_login;
         x_terrqual_tbl (l_counter).terr_id :=
            p_terrqual_tbl (l_counter).terr_id;
         x_terrqual_tbl (l_counter).qual_usg_id :=
            p_terrqual_tbl (l_counter).qual_usg_id;
         x_terrqual_tbl (l_counter).use_to_name_flag :=
            p_terrqual_tbl (l_counter).use_to_name_flag;
         x_terrqual_tbl (l_counter).generate_flag :=
            p_terrqual_tbl (l_counter).generate_flag;
         x_terrqual_tbl (l_counter).overlap_allowed_flag :=
            p_terrqual_tbl (l_counter).overlap_allowed_flag;
         x_terrqual_tbl (l_counter).qualifier_mode :=
            p_terrqual_tbl (l_counter).qualifier_mode;
         x_terrqual_tbl (l_counter).org_id :=
            p_terrqual_tbl (l_counter).org_id;
      --
      END LOOP;
   --
   END convert_terrqualtbl_pubtopvt;

-- --------------------------------------------------------
--   Package Name : Convert_TerrQualrec_PubToPvt
-- --------------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  JTF_TERR_QUAL_REC from pub to pvt
--                  before calling the JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  VPALLE Created
-- ---------------------------------------------------------
   PROCEDURE convert_terrqualrec_pubtopvt (
      p_terrqual_rec   IN       jtf_territory_pub.terr_qual_rec_type,
      x_terrqual_rec   OUT NOCOPY      jtf_territory_pvt.terr_qual_rec_type
   )
   AS
      l_counter                     NUMBER;
   --
   BEGIN
        --
        x_terrqual_rec.terr_qual_id :=          p_terrqual_rec .terr_qual_id;
        x_terrqual_rec .last_update_date :=     p_terrqual_rec.last_update_date;
         x_terrqual_rec.last_updated_by :=      p_terrqual_rec.last_updated_by;
         x_terrqual_rec .creation_date :=       p_terrqual_rec .creation_date;
         x_terrqual_rec .created_by :=          p_terrqual_rec.created_by;
         x_terrqual_rec.last_update_login :=    p_terrqual_rec.last_update_login;
         x_terrqual_rec.terr_id :=              p_terrqual_rec.terr_id;
         x_terrqual_rec.qual_usg_id :=          p_terrqual_rec.qual_usg_id;
         x_terrqual_rec.use_to_name_flag :=     p_terrqual_rec.use_to_name_flag;
         x_terrqual_rec.generate_flag :=        p_terrqual_rec.generate_flag;
         x_terrqual_rec.overlap_allowed_flag := p_terrqual_rec.overlap_allowed_flag;
         x_terrqual_rec.qualifier_mode :=       p_terrqual_rec.qualifier_mode;
         x_terrqual_rec.org_id :=               p_terrqual_rec.org_id;
       --
   END convert_terrqualrec_pubtopvt;

-- -----------------------------------------------------
--   Package Name : Convert_TerrValueTbl_PubToPvt
-- -----------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  JTF_TERR_VALUES_TBL from pub to pvt
--                  before calling the JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -----------------------------------------------------
   PROCEDURE convert_terrvaluetbl_pubtopvt (
      p_terrvalues_tbl   IN       jtf_territory_pub.terr_values_tbl_type,
      x_terrvalues_tbl   OUT NOCOPY      jtf_territory_pvt.terr_values_tbl_type
   )
   AS
      --
      l_counter                     NUMBER;
   --
   BEGIN
      --dbms_output.put_line('Convert_TerrValueTbl_PubToPvt: Entering API' || to_char(p_TerrValues_Tbl.Count));
      IF p_terrvalues_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      FOR l_counter IN 1 .. p_terrvalues_tbl.COUNT
      LOOP
         --
         --dbms_output.put_line('Counter - ' || to_char(l_Counter));
         x_terrvalues_tbl (l_counter).terr_value_id :=
            p_terrvalues_tbl (l_counter).terr_value_id;
         x_terrvalues_tbl (l_counter).last_update_date :=
            p_terrvalues_tbl (l_counter).last_update_date;
         x_terrvalues_tbl (l_counter).last_updated_by :=
            p_terrvalues_tbl (l_counter).last_updated_by;
         x_terrvalues_tbl (l_counter).creation_date :=
            p_terrvalues_tbl (l_counter).creation_date;
         x_terrvalues_tbl (l_counter).created_by :=
            p_terrvalues_tbl (l_counter).created_by;
         x_terrvalues_tbl (l_counter).last_update_login :=
            p_terrvalues_tbl (l_counter).last_update_login;
         x_terrvalues_tbl (l_counter).terr_qual_id :=
            p_terrvalues_tbl (l_counter).terr_qual_id;
         x_terrvalues_tbl (l_counter).include_flag :=
            p_terrvalues_tbl (l_counter).include_flag;
         x_terrvalues_tbl (l_counter).comparison_operator :=
            p_terrvalues_tbl (l_counter).comparison_operator;
         x_terrvalues_tbl (l_counter).low_value_char :=
            p_terrvalues_tbl (l_counter).low_value_char;
         x_terrvalues_tbl (l_counter).high_value_char :=
            p_terrvalues_tbl (l_counter).high_value_char;
         x_terrvalues_tbl (l_counter).low_value_number :=
            p_terrvalues_tbl (l_counter).low_value_number;
         x_terrvalues_tbl (l_counter).high_value_number :=
            p_terrvalues_tbl (l_counter).high_value_number;
         x_terrvalues_tbl (l_counter).value_set :=
            p_terrvalues_tbl (l_counter).value_set;
         x_terrvalues_tbl (l_counter).interest_type_id :=
            p_terrvalues_tbl (l_counter).interest_type_id;
         x_terrvalues_tbl (l_counter).primary_interest_code_id :=
            p_terrvalues_tbl (l_counter).primary_interest_code_id;
         x_terrvalues_tbl (l_counter).secondary_interest_code_id :=
            p_terrvalues_tbl (l_counter).secondary_interest_code_id;
         x_terrvalues_tbl (l_counter).currency_code :=
            p_terrvalues_tbl (l_counter).currency_code;
         x_terrvalues_tbl (l_counter).id_used_flag :=
            p_terrvalues_tbl (l_counter).id_used_flag;
         x_terrvalues_tbl (l_counter).low_value_char_id :=
            p_terrvalues_tbl (l_counter).low_value_char_id;
         x_terrvalues_tbl (l_counter).qualifier_tbl_index :=
            p_terrvalues_tbl (l_counter).qualifier_tbl_index;
         x_terrvalues_tbl (l_counter).org_id :=
            p_terrvalues_tbl (l_counter).org_id;

         x_terrvalues_tbl (l_counter).cnr_group_id :=
            p_terrvalues_tbl (l_counter).cnr_group_id;

         x_terrvalues_tbl (l_counter).value1_id :=
            p_terrvalues_tbl (l_counter).value1_id;

         x_terrvalues_tbl (l_counter).value2_id :=
            p_terrvalues_tbl (l_counter).value2_id;

         x_terrvalues_tbl (l_counter).value3_id :=
            p_terrvalues_tbl (l_counter).value3_id;

         x_terrvalues_tbl (l_counter).value4_id :=
            p_terrvalues_tbl (l_counter).value4_id;

      --
      END LOOP;
      --dbms_output.put_line('Convert_TerrValueTbl_PubToPvt: Exiting API');
   --
   END convert_terrvaluetbl_pubtopvt;

-- -----------------------------------------------------
--   Package Name : Convert_TerrUsgsTbl_PubToPvt
-- -----------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  JTF_TERR_USGS_TBL from pub to pvt
--                  before calling the JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -----------------------------------------------------
   PROCEDURE convert_terrusgstbl_pubtopvt (
      p_terrusgs_tbl   IN       jtf_territory_pub.terr_usgs_tbl_type,
      x_terrusgs_tbl   OUT NOCOPY      jtf_territory_pvt.terr_usgs_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      --dbms_output.put_line('Convert_TerrUsgsTbl_PubToPvt: Entering API');
      IF p_terrusgs_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      FOR l_counter IN 1 .. p_terrusgs_tbl.COUNT
      LOOP
         --
         x_terrusgs_tbl (l_counter).terr_usg_id :=
            p_terrusgs_tbl (l_counter).terr_usg_id;
         x_terrusgs_tbl (l_counter).source_id :=
            p_terrusgs_tbl (l_counter).source_id;
         x_terrusgs_tbl (l_counter).terr_id :=
            p_terrusgs_tbl (l_counter).terr_id;
         x_terrusgs_tbl (l_counter).last_update_date :=
            p_terrusgs_tbl (l_counter).last_update_date;
         x_terrusgs_tbl (l_counter).last_updated_by :=
            p_terrusgs_tbl (l_counter).last_updated_by;
         x_terrusgs_tbl (l_counter).creation_date :=
            p_terrusgs_tbl (l_counter).creation_date;
         x_terrusgs_tbl (l_counter).created_by :=
            p_terrusgs_tbl (l_counter).created_by;
         x_terrusgs_tbl (l_counter).last_update_login :=
            p_terrusgs_tbl (l_counter).last_update_login;
         x_terrusgs_tbl (l_counter).org_id :=
            p_terrusgs_tbl (l_counter).org_id;
      --
      END LOOP;
   END convert_terrusgstbl_pubtopvt;

-- -----------------------------------------------------
--   Package Name : Convert_TerQTypUsgTbl_PubToPvt
-- -----------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  JTF_TERR_QUAL_TYPE_USGS_TBL from pub
--                  to pvt before calling the JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -----------------------------------------------------
   PROCEDURE convert_terqtypusgtbl_pubtopvt (
      p_terrqtypeusgs_tbl   IN       jtf_territory_pub.terr_qualtypeusgs_tbl_type,
      x_terrqtypeusgs_tbl   OUT NOCOPY      jtf_territory_pvt.terr_qualtypeusgs_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      --dbms_output.put_line('Convert_TerQTypUsgTbl_PubToPvt: Entering API');
      IF p_terrqtypeusgs_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrqtypeusgs_tbl.COUNT
      LOOP
         --
         x_terrqtypeusgs_tbl (l_counter).terr_qual_type_usg_id :=
            p_terrqtypeusgs_tbl (l_counter).terr_qual_type_usg_id;
         x_terrqtypeusgs_tbl (l_counter).terr_id :=
            p_terrqtypeusgs_tbl (l_counter).terr_id;
         x_terrqtypeusgs_tbl (l_counter).qual_type_usg_id :=
            p_terrqtypeusgs_tbl (l_counter).qual_type_usg_id;
         x_terrqtypeusgs_tbl (l_counter).last_update_date :=
            p_terrqtypeusgs_tbl (l_counter).last_update_date;
         x_terrqtypeusgs_tbl (l_counter).last_updated_by :=
            p_terrqtypeusgs_tbl (l_counter).last_updated_by;
         x_terrqtypeusgs_tbl (l_counter).creation_date :=
            p_terrqtypeusgs_tbl (l_counter).creation_date;
         x_terrqtypeusgs_tbl (l_counter).created_by :=
            p_terrqtypeusgs_tbl (l_counter).created_by;
         x_terrqtypeusgs_tbl (l_counter).last_update_login :=
            p_terrqtypeusgs_tbl (l_counter).last_update_login;
         x_terrqtypeusgs_tbl (l_counter).org_id :=
            p_terrqtypeusgs_tbl (l_counter).org_id;
      --
      END LOOP;
   --
   END convert_terqtypusgtbl_pubtopvt;

--
-- -------------------------------------------------
--   Package Name : Convert_TerrOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  terr_out_rec from pvt to pub
--                  after calling JTF_TERRITORY_TYPE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrout_pvttopub (
      p_terr_rec   IN       jtf_territory_pvt.terr_all_out_rec_type,
      x_terr_rec   OUT NOCOPY      jtf_territory_pub.terr_all_out_rec_type
   )
   AS
   BEGIN
   --
      x_terr_rec.terr_id := p_terr_rec.terr_id;
      x_terr_rec.return_status := p_terr_rec.return_status;
   --
   END convert_terrout_pvttopub;

--
-- -------------------------------------------------
--   Package Name : Convert_TerrUsgOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_Usgs_out_Tbl from pvt to pub
--                  after calling JTF_TERRITORY_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrusgout_pvttopub (
      p_terrusgsout_tbl   IN       jtf_territory_pvt.terr_usgs_out_tbl_type,
      x_terrusgsout_tbl   OUT NOCOPY      jtf_territory_pub.terr_usgs_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      IF p_terrusgsout_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrusgsout_tbl.COUNT
      LOOP
         x_terrusgsout_tbl (l_counter).terr_usg_id :=
            p_terrusgsout_tbl (l_counter).terr_usg_id;
         x_terrusgsout_tbl (l_counter).return_status :=
            p_terrusgsout_tbl (l_counter).return_status;
      END LOOP;
   --

   END convert_terrusgout_pvttopub;

-- -------------------------------------------------
--   Package Name : Convert_TerrQTUsgOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_QualTypeUsgs_Out_Tbl from pvt
--                  to pub after calling JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrqtusgout_pvttopub (
      p_terrqualtypeusgs_tbl   IN       jtf_territory_pvt.terr_qualtypeusgs_out_tbl_type,
      x_terrqualtypeusgs_tbl   OUT NOCOPY      jtf_territory_pub.terr_qualtypeusgs_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      IF p_terrqualtypeusgs_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrqualtypeusgs_tbl.COUNT
      LOOP
         --
         x_terrqualtypeusgs_tbl (l_counter).terr_qual_type_usg_id :=
            p_terrqualtypeusgs_tbl (l_counter).terr_qual_type_usg_id;
         x_terrqualtypeusgs_tbl (l_counter).return_status :=
            p_terrqualtypeusgs_tbl (l_counter).return_status;
      --
      END LOOP;
   --
   END convert_terrqtusgout_pvttopub;

-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_Qual_Out_Tbl from pvt
--                  to pub after calling JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrqualout_pvttopub (
      p_terrqual_tbl   IN       jtf_territory_pvt.terr_qual_out_tbl_type,
      x_terrqual_tbl   OUT NOCOPY      jtf_territory_pub.terr_qual_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      --
      IF p_terrqual_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrqual_tbl.COUNT
      LOOP
         --
         x_terrqual_tbl (l_counter).terr_qual_id :=
            p_terrqual_tbl (l_counter).terr_qual_id;
         x_terrqual_tbl (l_counter).return_status :=
            p_terrqual_tbl (l_counter).return_status;
      --
      END LOOP;
   --
   END convert_terrqualout_pvttopub;

-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_Qual_Out_Tbl from pvt
--                  to pub after calling JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrqualout_pvttopub (
      p_terrqual_rec   IN       jtf_territory_pvt.terr_qual_out_rec_type,
      x_terrqual_rec   OUT NOCOPY      jtf_territory_pub.terr_qual_out_rec_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN

         x_terrqual_rec.terr_qual_id :=  p_terrqual_rec.terr_qual_id;
         x_terrqual_rec.return_status := p_terrqual_rec.return_status;

   END convert_terrqualout_pvttopub;

-- -------------------------------------------------
--   Package Name : Convert_TerrValuesOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_Values_Out_Tbl from pvt
--                  to pub after calling JTF_TERRITORY_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrvaluesout_pvttopub (
      p_terrvaluesout_tbl   IN       jtf_territory_pvt.terr_values_out_tbl_type,
      x_terrvaluesout_tbl   OUT NOCOPY      jtf_territory_pub.terr_values_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      --
      IF p_terrvaluesout_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrvaluesout_tbl.COUNT
      LOOP
         --
         x_terrvaluesout_tbl (l_counter).terr_value_id :=
            p_terrvaluesout_tbl (l_counter).terr_value_id;
         x_terrvaluesout_tbl (l_counter).return_status :=
            p_terrvaluesout_tbl (l_counter).return_status;
      --

      END LOOP;
   --
   END convert_terrvaluesout_pvttopub;

-- -------------------------------------------------
--   Package Name : Convert_TerRsc_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  jtf_terrResource_Tbl from pub to pvt
--                  before calling the JTF_TERRITORY_RESOURCE_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrrsc_pubtopvt (
      p_terrrsc_tbl   IN       jtf_territory_pub.terrresource_tbl_type,
      x_terrrsc_tbl   OUT NOCOPY      jtf_territory_resource_pvt.terrresource_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_terrrsc_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrrsc_tbl.COUNT
      LOOP
         --
         x_terrrsc_tbl (l_counter).terr_rsc_id :=
            p_terrrsc_tbl (l_counter).terr_rsc_id;
         x_terrrsc_tbl (l_counter).last_update_date :=
            p_terrrsc_tbl (l_counter).last_update_date;
         x_terrrsc_tbl (l_counter).last_updated_by :=
            p_terrrsc_tbl (l_counter).last_updated_by;
         x_terrrsc_tbl (l_counter).creation_date :=
            p_terrrsc_tbl (l_counter).creation_date;
         x_terrrsc_tbl (l_counter).created_by :=
            p_terrrsc_tbl (l_counter).created_by;
         x_terrrsc_tbl (l_counter).last_update_login :=
            p_terrrsc_tbl (l_counter).last_update_login;
         x_terrrsc_tbl (l_counter).terr_id :=
            p_terrrsc_tbl (l_counter).terr_id;
         x_terrrsc_tbl (l_counter).resource_id :=
            p_terrrsc_tbl (l_counter).resource_id;
         x_terrrsc_tbl (l_counter).group_id :=
            p_terrrsc_tbl (l_counter).group_id;
         x_terrrsc_tbl (l_counter).resource_type :=
            p_terrrsc_tbl (l_counter).resource_type;
         x_terrrsc_tbl (l_counter).role := p_terrrsc_tbl (l_counter).role;
         x_terrrsc_tbl (l_counter).primary_contact_flag :=
            p_terrrsc_tbl (l_counter).primary_contact_flag;

          /* BUG# 1355914 - FIX START*/
          x_terrrsc_tbl (l_counter).start_date_active :=
            p_terrrsc_tbl (l_counter).start_date_active;
         x_terrrsc_tbl (l_counter).end_date_active :=
            p_terrrsc_tbl (l_counter).end_date_active;
          /* BUG# 1355914 - FIX END*/

         x_terrrsc_tbl (l_counter).full_access_flag :=
            p_terrrsc_tbl (l_counter).full_access_flag;
         x_terrrsc_tbl (l_counter).org_id := p_terrrsc_tbl (l_counter).org_id;
         -- Adding the attribute columns as fix for bug 7168485.
         x_terrrsc_tbl (l_counter).ATTRIBUTE_CATEGORY := p_terrrsc_tbl (l_counter).ATTRIBUTE_CATEGORY;
         x_terrrsc_tbl (l_counter).ATTRIBUTE1  := p_terrrsc_tbl (l_counter).ATTRIBUTE1;
         x_terrrsc_tbl (l_counter).ATTRIBUTE2  := p_terrrsc_tbl (l_counter).ATTRIBUTE2;
         x_terrrsc_tbl (l_counter).ATTRIBUTE3  := p_terrrsc_tbl (l_counter).ATTRIBUTE3;
         x_terrrsc_tbl (l_counter).ATTRIBUTE4  := p_terrrsc_tbl (l_counter).ATTRIBUTE4;
         x_terrrsc_tbl (l_counter).ATTRIBUTE5  := p_terrrsc_tbl (l_counter).ATTRIBUTE5;
         x_terrrsc_tbl (l_counter).ATTRIBUTE6  := p_terrrsc_tbl (l_counter).ATTRIBUTE6;
         x_terrrsc_tbl (l_counter).ATTRIBUTE7  := p_terrrsc_tbl (l_counter).ATTRIBUTE7;
         x_terrrsc_tbl (l_counter).ATTRIBUTE8  := p_terrrsc_tbl (l_counter).ATTRIBUTE8;
         x_terrrsc_tbl (l_counter).ATTRIBUTE9  := p_terrrsc_tbl (l_counter).ATTRIBUTE9;
         x_terrrsc_tbl (l_counter).ATTRIBUTE10 := p_terrrsc_tbl (l_counter).ATTRIBUTE10;
         x_terrrsc_tbl (l_counter).ATTRIBUTE11 := p_terrrsc_tbl (l_counter).ATTRIBUTE11;
         x_terrrsc_tbl (l_counter).ATTRIBUTE12 := p_terrrsc_tbl (l_counter).ATTRIBUTE12;
         x_terrrsc_tbl (l_counter).ATTRIBUTE13 := p_terrrsc_tbl (l_counter).ATTRIBUTE13;
         x_terrrsc_tbl (l_counter).ATTRIBUTE14 := p_terrrsc_tbl (l_counter).ATTRIBUTE14;
         x_terrrsc_tbl (l_counter).ATTRIBUTE15 := p_terrrsc_tbl (l_counter).ATTRIBUTE15;
      END LOOP;
   --
   END convert_terrrsc_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TerrRscAcc_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  TerrRsc_Access_tbl from pub to pvt before
--                  calling the JTF_TERRITORY_RESOURCE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrrscacc_pubtopvt (
      p_terrrscacc_tbl   IN       jtf_territory_pub.terrrsc_access_tbl_type,
      x_terrrscacc_tbl   OUT NOCOPY      jtf_territory_resource_pvt.terrrsc_access_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_terrrscacc_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrrscacc_tbl.COUNT
      LOOP
         --
         x_terrrscacc_tbl (l_counter).terr_rsc_access_id :=
            p_terrrscacc_tbl (l_counter).terr_rsc_access_id;
         x_terrrscacc_tbl (l_counter).last_update_date :=
            p_terrrscacc_tbl (l_counter).last_update_date;
         x_terrrscacc_tbl (l_counter).last_updated_by :=
            p_terrrscacc_tbl (l_counter).last_updated_by;
         x_terrrscacc_tbl (l_counter).creation_date :=
            p_terrrscacc_tbl (l_counter).creation_date;
         x_terrrscacc_tbl (l_counter).created_by :=
            p_terrrscacc_tbl (l_counter).created_by;
         x_terrrscacc_tbl (l_counter).last_update_login :=
            p_terrrscacc_tbl (l_counter).last_update_login;
         x_terrrscacc_tbl (l_counter).terr_rsc_id :=
            p_terrrscacc_tbl (l_counter).terr_rsc_id;
         x_terrrscacc_tbl (l_counter).access_type :=
            p_terrrscacc_tbl (l_counter).access_type;
         x_terrrscacc_tbl (l_counter).org_id :=
            p_terrrscacc_tbl (l_counter).org_id;
         x_terrrscacc_tbl (l_counter).qualifier_tbl_index :=
            p_terrrscacc_tbl (l_counter).qualifier_tbl_index;
         x_terrrscacc_tbl (l_counter).TRANS_ACCESS_CODE :=
            p_terrrscacc_tbl (l_counter).TRANS_ACCESS_CODE;
      --

      END LOOP;
   --

   END convert_terrrscacc_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TerrRscOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  jtf_terrResource_Out_Tbl from pvt to pub
--                  after calling JTF_TERRITORY_RESOURCE_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrrscout_pvttopub (
      p_terrrscout_tbl   IN       jtf_territory_resource_pvt.terrresource_out_tbl_type,
      x_terrrscout_tbl   OUT NOCOPY      jtf_territory_pub.terrresource_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_terrrscout_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrrscout_tbl.COUNT
      LOOP
         --
         x_terrrscout_tbl (l_counter).terr_rsc_id :=
            p_terrrscout_tbl (l_counter).terr_rsc_id;
         x_terrrscout_tbl (l_counter).return_status :=
            p_terrrscout_tbl (l_counter).return_status;
      --

      END LOOP;
   --

   END convert_terrrscout_pvttopub;

--
-- -------------------------------------------------
--   Package Name : Convert_TerRscAccOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  TerrRsc_Access_Out_tbl from pub to pvt after
--                  calling the JTF_TERRITORY_RESOURCE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrscaccout_pvttopub (
      p_terrrscaccout_tbl   IN       jtf_territory_resource_pvt.terrrsc_access_out_tbl_type,
      x_terrrscaccout_tbl   OUT NOCOPY      jtf_territory_pub.terrrsc_access_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_terrrscaccout_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrrscaccout_tbl.COUNT
      LOOP
         --
         x_terrrscaccout_tbl (l_counter).terr_rsc_access_id :=
            p_terrrscaccout_tbl (l_counter).terr_rsc_access_id;
         x_terrrscaccout_tbl (l_counter).return_status :=
            p_terrrscaccout_tbl (l_counter).return_status;
      --
      END LOOP;
   --
   END convert_terrscaccout_pvttopub;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory
--    Type      : PUBLIC
--    Function  : To create Territories - which inludes the creation of following
--                Territory Header, Territory Qualifier, terr Usages,
--                Territory Qualifiers and Territory Qualifier Values.
--                P_terr_values_tbl.QUALIFIER_TBL_INDEX is, associates the values with the Qualifier,
--                the index of qualifier record of the qualifier table. Atleast one qualifier value must be passed, otherwise,
--                Qualifiers won't be created.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--      p_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Id                     NUMBER
--      x_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      x_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--      x_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_territory (
      p_api_version_number          IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 := fnd_api.g_false,
      p_commit                      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2,
      p_terr_all_rec                IN       terr_all_rec_type
            := g_miss_terr_all_rec,
      p_terr_usgs_tbl               IN       terr_usgs_tbl_type
            := g_miss_terr_usgs_tbl,
-- Qual Type usages created created based on Territory Type.
      --p_terr_qualtypeusgs_tbl       IN       terr_qualtypeusgs_tbl_type
        --    := g_miss_terr_qualtypeusgs_tbl,
      p_terr_qual_tbl               IN       terr_qual_tbl_type
            := g_miss_terr_qual_tbl,
      p_terr_values_tbl             IN       terr_values_tbl_type
            := g_miss_terr_values_tbl,
      x_terr_id                     OUT NOCOPY      NUMBER,
      x_terr_usgs_out_tbl           OUT NOCOPY      terr_usgs_out_tbl_type,
      x_terr_qualtypeusgs_out_tbl   OUT NOCOPY      terr_qualtypeusgs_out_tbl_type,
      x_terr_qual_out_tbl           OUT NOCOPY      terr_qual_out_tbl_type,
      x_terr_values_out_tbl         OUT NOCOPY      terr_values_out_tbl_type
   )
   IS
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_Territory';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terr_usgs_out_tbl           jtf_territory_pvt.terr_usgs_out_tbl_type;
      l_terr_qualtypeusgs_out_tbl   jtf_territory_pvt.terr_qualtypeusgs_out_tbl_type;
      l_terr_qual_out_tbl           jtf_territory_pvt.terr_qual_out_tbl_type;
      l_terr_values_out_tbl         jtf_territory_pvt.terr_values_out_tbl_type;
      l_terr_rec                    jtf_territory_pvt.terr_all_rec_type;
      l_terr_usgs_tbl               jtf_territory_pvt.terr_usgs_tbl_type;
      l_terr_qualtypeusgs_tbl       jtf_territory_pvt.terr_qualtypeusgs_tbl_type;
      l_terr_qual_tbl               jtf_territory_pvt.terr_qual_tbl_type;
      l_terr_values_tbl             jtf_territory_pvt.terr_values_tbl_type;
   --

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      convert_terrrec_pubtopvt (
         p_terr_rec => p_terr_all_rec,
         x_terr_rec => l_terr_rec
      );
      convert_terrqualtbl_pubtopvt (
         p_terrqual_tbl => p_terr_qual_tbl,
         x_terrqual_tbl => l_terr_qual_tbl
      );
      convert_terrvaluetbl_pubtopvt (
         p_terrvalues_tbl => p_terr_values_tbl,
         x_terrvalues_tbl => l_terr_values_tbl
      );
      convert_terrusgstbl_pubtopvt (
         p_terrusgs_tbl => p_terr_usgs_tbl,
         x_terrusgs_tbl => l_terr_usgs_tbl
      );
     /* convert_terqtypusgtbl_pubtopvt (
         p_terrqtypeusgs_tbl => p_terr_qualtypeusgs_tbl,
         x_terrqtypeusgs_tbl => l_terr_qualtypeusgs_tbl
      ); */
      -- ******************************************************************
      jtf_territory_pvt.create_territory (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terr_all_rec => l_terr_rec,
         p_terr_usgs_tbl => l_terr_usgs_tbl,
         p_terr_qualtypeusgs_tbl => l_terr_qualtypeusgs_tbl,
         p_terr_qual_tbl => l_terr_qual_tbl,
         p_terr_values_tbl => l_terr_values_tbl,
         x_terr_id => x_terr_id,
         x_terr_usgs_out_tbl => l_terr_usgs_out_tbl,
         x_terr_qualtypeusgs_out_tbl => l_terr_qualtypeusgs_out_tbl,
         x_terr_qual_out_tbl => l_terr_qual_out_tbl,
         x_terr_values_out_tbl => l_terr_values_out_tbl
      );
      convert_terrusgout_pvttopub (
         p_terrusgsout_tbl => l_terr_usgs_out_tbl,
         x_terrusgsout_tbl => x_terr_usgs_out_tbl
      );
      convert_terrqtusgout_pvttopub (
         p_terrqualtypeusgs_tbl => l_terr_qualtypeusgs_out_tbl,
         x_terrqualtypeusgs_tbl => x_terr_qualtypeusgs_out_tbl
      );
      convert_terrqualout_pvttopub (
         p_terrqual_tbl => l_terr_qual_out_tbl,
         x_terrqual_tbl => x_terr_qual_out_tbl
      );
      convert_terrvaluesout_pvttopub (
         p_terrvaluesout_tbl => l_terr_values_out_tbl,
         x_terrvaluesout_tbl => x_terr_values_out_tbl
      );
      x_return_status := l_return_status;

      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Create_Territory PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END create_territory;

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Territory
--    Type      : PUBLIC
--    Function  : To delete Territories - which would also delete
--                Territory Header, Territory Qualifier, Territory Qual Types
--                Territory Qualifier Values and Resources.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
   PROCEDURE delete_territory (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      p_terr_id              IN       NUMBER
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Territory';
      l_api_version_number CONSTANT NUMBER := 1.0;
      --l_return_status               VARCHAR2(1);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      jtf_territory_pvt.delete_territory (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terr_id => p_terr_id
      );

      --l_return_status := x_return_status;

      --
      IF x_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Delete_Territory PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END delete_territory;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Territory
--    Type      : PUBLIC
--    Function  : To update existing Territory Header whcich will update
--                the records in JTF_TERR_ALL table.
--                We can't update the territory usage and Territory Qual Types.
--                Updating Qualifier Values can be done with Update_Qualifier_Value procedure.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      p_Return_Status               VARCHAR2(1)
--      p_Msg_Count                   NUMBER
--      p_Msg_Data                    VARCHAR2(2000)
--      p_Terr_All_Out_Rec            Terr_All_Out_Rec
--
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE update_territory (
      p_api_version_number          IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 := fnd_api.g_false,
      p_commit                      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2,
      p_terr_all_rec                IN       terr_all_rec_type
            := g_miss_terr_all_rec,
    /* Territory Usage and Transaction types cant be updated in R12.
      p_terr_usgs_tbl               IN       terr_usgs_tbl_type
            := g_miss_terr_usgs_tbl,
      p_terr_qualtypeusgs_tbl       IN       terr_qualtypeusgs_tbl_type
            := g_miss_terr_qualtypeusgs_tbl,
      p_terr_qual_tbl               IN       terr_qual_tbl_type
            := g_miss_terr_qual_tbl,
      p_terr_values_tbl             IN       terr_values_tbl_type
            := g_miss_terr_values_tbl, */
      x_terr_all_out_rec            OUT NOCOPY      terr_all_out_rec_type
     -- x_terr_usgs_out_tbl           OUT NOCOPY      terr_usgs_out_tbl_type,
     -- x_terr_qualtypeusgs_out_tbl   OUT NOCOPY      terr_qualtypeusgs_out_tbl_type,
     -- x_terr_qual_out_tbl           OUT NOCOPY      terr_qual_out_tbl_type,
     -- x_terr_values_out_tbl         OUT NOCOPY      terr_values_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_Territory';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terr_out_rec                jtf_territory_pvt.terr_all_out_rec_type;
      l_terr_usgs_out_tbl           jtf_territory_pvt.terr_usgs_out_tbl_type;
      l_terr_qualtypeusgs_out_tbl   jtf_territory_pvt.terr_qualtypeusgs_out_tbl_type;
      l_terr_qual_out_tbl           jtf_territory_pvt.terr_qual_out_tbl_type;
      l_terr_values_out_tbl         jtf_territory_pvt.terr_values_out_tbl_type;
      l_terr_rec                    jtf_territory_pvt.terr_all_rec_type;
      l_terr_usgs_tbl               jtf_territory_pvt.terr_usgs_tbl_type;
      l_terr_qualtypeusgs_tbl       jtf_territory_pvt.terr_qualtypeusgs_tbl_type;
      l_terr_qual_tbl               jtf_territory_pvt.terr_qual_tbl_type;
      l_terr_values_tbl             jtf_territory_pvt.terr_values_tbl_type;
   BEGIN
      --dbms_output.put_line('Update_Territory PUB: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT upadate_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      --
      --dbms_output.put_line('Update_Territory PUB: Before Calling Convertion routines');
      convert_terrrec_pubtopvt (
         p_terr_rec => p_terr_all_rec,
         x_terr_rec => l_terr_rec
      );
     /* convert_terrqualtbl_pubtopvt (
         p_terrqual_tbl => p_terr_qual_tbl,
         x_terrqual_tbl => l_terr_qual_tbl
      );
      convert_terrvaluetbl_pubtopvt (
         p_terrvalues_tbl => p_terr_values_tbl,
         x_terrvalues_tbl => l_terr_values_tbl
      );

       convert_terrusgstbl_pubtopvt (
         p_terrusgs_tbl => p_terr_usgs_tbl,
         x_terrusgs_tbl => l_terr_usgs_tbl
      );
      convert_terqtypusgtbl_pubtopvt (
         p_terrqtypeusgs_tbl => p_terr_qualtypeusgs_tbl,
         x_terrqtypeusgs_tbl => l_terr_qualtypeusgs_tbl
      ); */
      --dbms_output.put_line('Update_Territory PUB: Before Calling JTF_TERRITORY_PVT.Update_Territory');
      jtf_territory_pvt.update_territory (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terr_all_rec => l_terr_rec,
        -- p_terr_usgs_tbl => l_terr_usgs_tbl,
        -- p_terr_qualtypeusgs_tbl => l_terr_qualtypeusgs_tbl,
        -- p_terr_qual_tbl => l_terr_qual_tbl,
        -- p_terr_values_tbl => l_terr_values_tbl,
         x_terr_all_out_rec => l_terr_out_rec
        -- x_terr_usgs_out_tbl => l_terr_usgs_out_tbl,
        -- x_terr_qualtypeusgs_out_tbl => l_terr_qualtypeusgs_out_tbl,
        -- x_terr_qual_out_tbl => l_terr_qual_out_tbl,
        -- x_terr_values_out_tbl => l_terr_values_out_tbl
      );
      --dbms_output.put_line('Update_Territory PUB: Before Calling Convertion routine from PVT to PUB');
      convert_terrout_pvttopub (
         p_terr_rec => l_terr_out_rec,
         x_terr_rec => x_terr_all_out_rec
      );
     /* convert_terrusgout_pvttopub (
         p_terrusgsout_tbl => l_terr_usgs_out_tbl,
         x_terrusgsout_tbl => x_terr_usgs_out_tbl
      );
      convert_terrqtusgout_pvttopub (
         p_terrqualtypeusgs_tbl => l_terr_qualtypeusgs_out_tbl,
         x_terrqualtypeusgs_tbl => x_terr_qualtypeusgs_out_tbl
      );
      convert_terrqualout_pvttopub (
         p_terrqual_tbl => l_terr_qual_out_tbl,
         x_terrqual_tbl => x_terr_qual_out_tbl
      );
      convert_terrvaluesout_pvttopub (
         p_terrvaluesout_tbl => l_terr_values_out_tbl,
         x_terrvaluesout_tbl => x_terr_values_out_tbl
      );
      */
      --

      x_return_status := l_return_status;

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   --dbms_output.put_line('Update_Territory PUB: Exiting API');
   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Update_Territory PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Update_Territory PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Update_Territory PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Update_Territory PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END update_territory;

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Deactivate_Territory
--    Type      : PUBLIC
--    Function  : To deactivate Territories - this API also deactivates
--                any sub-territories of this territory.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE deactivate_territory (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      p_terr_id              IN       NUMBER
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Deactivate_Territory';
      l_api_version_number CONSTANT NUMBER := 1.0;
      --l_return_status               VARCHAR2(1);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT deactivate_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      jtf_territory_pvt.deactivate_territory (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terr_id => p_terr_id
      );
      --x_return_status := l_return_status;

      --
      IF x_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO deactivate_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO deactivate_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO deactivate_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Deactivate_Territory PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END deactivate_territory;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory_Qualifier
--    Type      : PUBLIC
--    Function  : To create Territories Qualifier and it's Values.
--                P_terr_values_tbl.QUALIFIER_TBL_INDEX is, associates the values with the Qualifier,
--                the index of qualifier record of the qualifier table.
--                Atleast one qualifier value must be passed, other wise, Qualifier can't be created.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_Qual_Rec               Terr_Qual_Rec_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--      p_validation_level            NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    End of Comments
--
PROCEDURE Create_Terr_qualifier
  (
    p_Api_Version_Number  IN  NUMBER,
    p_Init_Msg_List       IN  VARCHAR2 := FND_API.G_FALSE,
    p_Commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_Return_Status       OUT NOCOPY VARCHAR2,
    x_Msg_Count           OUT NOCOPY NUMBER,
    x_Msg_Data            OUT NOCOPY VARCHAR2,
    P_Terr_Qual_Rec       IN  Terr_Qual_Rec_Type := G_Miss_Terr_Qual_Rec,
    p_Terr_Values_Tbl     IN  Terr_Values_Tbl_Type := G_Miss_Terr_Values_Tbl,
    X_Terr_Qual_Out_Rec   OUT NOCOPY Terr_Qual_Out_Rec_Type,
    x_Terr_Values_Out_Tbl OUT NOCOPY Terr_Values_Out_Tbl_Type
 )
 AS
       l_api_name           CONSTANT VARCHAR2(30) := 'Create_Territory_Qualifier';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terr_qual_out_rec           jtf_territory_pvt.terr_qual_out_rec_type;
      l_terr_values_out_tbl         jtf_territory_pvt.terr_values_out_tbl_type;
      l_terr_qual_rec               jtf_territory_pvt.terr_qual_rec_type;
      l_terr_values_tbl             jtf_territory_pvt.terr_values_tbl_type;
   --

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      convert_terrqualrec_pubtopvt (
         p_terrqual_rec => p_terr_qual_rec,
         x_terrqual_rec => l_terr_qual_rec
      );
      convert_terrvaluetbl_pubtopvt (
         p_terrvalues_tbl => p_terr_values_tbl,
         x_terrvalues_tbl => l_terr_values_tbl
      );
      -- ******************************************************************
      jtf_territory_pvt.Create_Terr_qualifier (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terr_qual_rec => l_terr_qual_rec,
         p_terr_values_tbl => l_terr_values_tbl,
         x_terr_qual_out_rec => l_terr_qual_out_rec,
         x_terr_values_out_tbl => l_terr_values_out_tbl
      );
      convert_terrqualout_pvttopub (
         p_terrqual_rec => l_terr_qual_out_rec,
         x_terrqual_rec => x_terr_qual_out_rec
      );
      convert_terrvaluesout_pvttopub (
         p_terrvaluesout_tbl => l_terr_values_out_tbl,
         x_terrvaluesout_tbl => x_terr_values_out_tbl
      );

      x_return_status := l_return_status;

      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Create_Territory PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --
 END Create_Terr_qualifier;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Terr_Qualifier
--    Type      : PUBLIC
--    Function  : To delete a Territory Qualifier and its Values
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      P_Terr_Qual_Id             NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
   PROCEDURE Delete_Terr_Qualifier (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      P_Terr_Qual_Id         IN       NUMBER
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Terr_Qualifier';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      jtf_territory_pvt.Delete_Terr_Qualifier (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         P_Terr_Qual_Id => P_Terr_Qual_Id
      );

      x_return_status := l_return_status;

      --
      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Delete_Terr_Qualifier PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

  END Delete_Terr_Qualifier;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Qualifier_Value
--    Type      : PUBLIC
--    Function  : To create Territory Qualifier Values.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_terr_qual_id                NUMBER (Territory Qualifier ID)
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      p_Return_Status               VARCHAR2(1)
--      p_Msg_Count                   NUMBER
--      p_Msg_Data                    VARCHAR2(2000)
--      p_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    Notes: Custmer need to verify the validity of the Territory Qualifier Value being passed to the procedure.
--    Example : The city name as 'ADDION', instead of ADDISON, is not validated.
--
--    End of Comments
--
 PROCEDURE Create_Qualifier_Value (
      p_api_version_number          IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 := fnd_api.g_false,
      p_commit                      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2,
      p_terr_qual_id                IN  NUMBER,
      p_terr_values_tbl             IN       terr_values_tbl_type
            := g_miss_terr_values_tbl,
      x_terr_values_out_tbl         OUT NOCOPY      terr_values_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'create_terr_values';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terr_values_out_tbl         jtf_territory_pvt.terr_values_out_tbl_type;
      l_terr_values_tbl             jtf_territory_pvt.terr_values_tbl_type;
      l_Terr_Qual_Id NUMBER;
   BEGIN
      --dbms_output.put_line('create_terr_value PUB: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT upadate_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      --
      --dbms_output.put_line('Update_Territory PUB: Before Calling Convertion routines');

      convert_terrvaluetbl_pubtopvt (
         p_terrvalues_tbl => p_terr_values_tbl,
         x_terrvalues_tbl => l_terr_values_tbl
      );

      -- Check whether ant data is passed for update of value table
      If P_Terr_Values_Tbl.Count > 0 Then
         --dbms_output('Update_Territory PVT: Before Calling Update_Terr_Value');
         jtf_territory_pvt.create_terr_value( P_Api_Version_Number          =>  1.0,
                                              P_Init_Msg_List               =>  fnd_api.g_false,
                                              P_Commit                      =>  fnd_api.g_false,
                                              p_validation_level            =>  fnd_api.g_valid_level_full,
                                              P_Terr_Id                     =>  null,
                                              p_terr_qual_id                =>  p_terr_qual_id,
                                              P_Terr_Value_Tbl              =>  l_Terr_Values_Tbl,
                                              X_Return_Status               =>  l_Return_Status,
                                              X_Msg_Count                   =>  x_Msg_Count,
                                              X_Msg_Data                    =>  x_Msg_Data,
                                              X_Terr_Value_Out_Tbl          =>  l_Terr_Values_Out_Tbl);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      End If;

      --dbms_output.put_line('Update_Territory PUB: Before Calling Convertion routine from PVT to PUB');
      convert_terrvaluesout_pvttopub (
         p_terrvaluesout_tbl => l_terr_values_out_tbl,
         x_terrvaluesout_tbl => x_terr_values_out_tbl
      );

      x_return_status := l_return_status;
	  --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   --dbms_output.put_line('create_terr_value  PUB: Exiting API');
   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Update_Territory Values PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Update_Territory_Values PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Update_Territory Values PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in create_terr_values  ' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END Create_Qualifier_Value;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Value
--    Type      : PUBLIC
--    Function  : To update existing Territory Qualifier Values
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      p_Return_Status               VARCHAR2(1)
--      p_Msg_Count                   NUMBER
--      p_Msg_Data                    VARCHAR2(2000)
--      p_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    Notes: Custmoer need to verify the validity of the Territory Qualifier Value being passed to the procedure.
--    Example : The city name as 'ADDION', instead of ADDISON, is not validated.
--
--    End of Comments
--
 PROCEDURE Update_Qualifier_Value (
      p_api_version_number          IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 := fnd_api.g_false,
      p_commit                      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2,
      p_terr_values_tbl             IN       terr_values_tbl_type
            := g_miss_terr_values_tbl,
      x_terr_values_out_tbl         OUT NOCOPY      terr_values_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_Territory';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terr_values_out_tbl         jtf_territory_pvt.terr_values_out_tbl_type;
      l_terr_values_tbl             jtf_territory_pvt.terr_values_tbl_type;
   BEGIN
      --dbms_output.put_line('Update_Territory PUB: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT upadate_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      --
      --dbms_output.put_line('Update_Territory PUB: Before Calling Convertion routines');

      convert_terrvaluetbl_pubtopvt (
         p_terrvalues_tbl => p_terr_values_tbl,
         x_terrvalues_tbl => l_terr_values_tbl
      );

      -- Check whether ant data is passed for update of value table
      If P_Terr_Values_Tbl.Count > 0 Then
         --dbms_output('Update_Territory PVT: Before Calling Update_Terr_Value');
         jtf_territory_pvt.Update_Terr_Value( P_Api_Version_Number          =>  1.0,
                                              P_Init_Msg_List               =>  fnd_api.g_false,
                                              P_Commit                      =>  fnd_api.g_false,
                                              p_validation_level            =>  fnd_api.g_valid_level_full,
                                              P_Terr_Value_Tbl              =>  l_Terr_Values_Tbl,
                                              X_Return_Status               =>  l_Return_Status,
                                              X_Msg_Count                   =>  x_Msg_Count,
                                              X_Msg_Data                    =>  x_Msg_Data,
                                              X_Terr_Value_Out_Tbl          =>  l_Terr_Values_Out_Tbl);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      End If;

      --dbms_output.put_line('Update_Territory PUB: Before Calling Convertion routine from PVT to PUB');
      convert_terrvaluesout_pvttopub (
         p_terrvaluesout_tbl => l_terr_values_out_tbl,
         x_terrvaluesout_tbl => x_terr_values_out_tbl
      );

      x_return_status := l_return_status;
	  --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   --dbms_output.put_line('Update_Territory values PUB: Exiting API');
   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Update_Territory Values PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Update_Territory_Values PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Update_Territory Values PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Update_Territory Values ' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END Update_Qualifier_Value;

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Qualifier_Value
--    Type      : PUBLIC
--    Function  : To delete a Territoriy Qualifier Value
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      P_Terr_Value_Id             NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
   PROCEDURE Delete_Qualifier_Value (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      P_Terr_Value_Id         IN       NUMBER
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Terr_Value';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_territory_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --

      jtf_territory_pvt.Delete_Terr_Value (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         P_Terr_Value_Id => P_Terr_Value_Id
      );

      x_return_status := l_return_status;

      --
      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_territory_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Delete_Terr_Value PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END Delete_Qualifier_Value;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrResource
--    Type      : PUBLIC
--    Function  : To create Territory Resources - which will insert
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--                If the user doesnot provide access records, this procedure
--                inserts the rows into jtf_terr_rsc_access_all for all Transaction Types
--                associated with the territory with access as 'FULL_ACCESS'
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_terrresource (
      p_api_version_number       IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      x_return_status            OUT NOCOPY      VARCHAR2,
      x_msg_count                OUT NOCOPY      NUMBER,
      x_msg_data                 OUT NOCOPY      VARCHAR2,
      p_terrrsc_tbl              IN       terrresource_tbl_type
            := g_miss_terrresource_tbl,
      p_terrrsc_access_tbl       IN       terrrsc_access_tbl_type
            := g_miss_terrrsc_access_tbl,
      x_terrrsc_out_tbl          OUT NOCOPY      terrresource_out_tbl_type,
      x_terrrsc_access_out_tbl   OUT NOCOPY      terrrsc_access_out_tbl_type
   )
   IS
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_TerrResource';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terrrsc_tbl                 jtf_territory_resource_pvt.terrresource_tbl_type;
      l_terrrsc_access_tbl          jtf_territory_resource_pvt.terrrsc_access_tbl_type;
      l_terrrsc_out_tbl             jtf_territory_resource_pvt.terrresource_out_tbl_type;
      l_terrrsc_access_out_tbl      jtf_territory_resource_pvt.terrrsc_access_out_tbl_type;
   --

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_terrresource_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;
               fnd_msg_pub.initialize;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- Convert incomming data from public to private Tbl format
      convert_terrrsc_pubtopvt (
         p_terrrsc_tbl => p_terrrsc_tbl,
         x_terrrsc_tbl => l_terrrsc_tbl
      );
      convert_terrrscacc_pubtopvt (
         p_terrrscacc_tbl => p_terrrsc_access_tbl,
         x_terrrscacc_tbl => l_terrrsc_access_tbl
      );
      --
      -- API body
      --
      jtf_territory_resource_pvt.create_terrresource (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terrrsc_tbl => l_terrrsc_tbl,
         p_terrrsc_access_tbl => l_terrrsc_access_tbl,
         x_terrrsc_out_tbl => l_terrrsc_out_tbl,
         x_terrrsc_access_out_tbl => l_terrrsc_access_out_tbl
      );
      convert_terrrscout_pvttopub (
         p_terrrscout_tbl => l_terrrsc_out_tbl,
         x_terrrscout_tbl => x_terrrsc_out_tbl
      );
      convert_terrscaccout_pvttopub (
         p_terrrscaccout_tbl => l_terrrsc_access_out_tbl,
         x_terrrscaccout_tbl => x_terrrsc_access_out_tbl
      );

      x_return_status := l_return_status;

      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

      WHEN OTHERS
      THEN
         ROLLBACK TO create_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Create_TerrResource PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END create_terrresource;

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_TerrResource
--    Type      : PUBLIC
--    Function  : To delete Territories - which would also delete
--                records from jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_TerrRsc_Id               NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
   PROCEDURE delete_terrresource (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      p_terrrsc_id           IN       NUMBER
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_TerrResource';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_terrresource_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      jtf_territory_resource_pvt.delete_terr_resource (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terrrsc_id => p_terrrsc_id
      );

      x_return_status := l_return_status;

      --
      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Delete_TerrResource PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END delete_terrresource;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_TerrResource
--    Type      : PUBLIC
--    Function  : To Update Territory Resources - which will update
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE update_terrresource (
      p_api_version_number       IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      x_return_status            OUT NOCOPY      VARCHAR2,
      x_msg_count                OUT NOCOPY      NUMBER,
      x_msg_data                 OUT NOCOPY      VARCHAR2,
      p_terrrsc_tbl              IN       terrresource_tbl_type
            := g_miss_terrresource_tbl,
      p_terrrsc_access_tbl       IN       terrrsc_access_tbl_type
            := g_miss_terrrsc_access_tbl,
      x_terrrsc_out_tbl          OUT NOCOPY      terrresource_out_tbl_type,
      x_terrrsc_access_out_tbl   OUT NOCOPY      terrrsc_access_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_TerrResource';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terrrsc_tbl                 jtf_territory_resource_pvt.terrresource_tbl_type;
      l_terrrsc_access_tbl          jtf_territory_resource_pvt.terrrsc_access_tbl_type;
      l_terrrsc_out_tbl             jtf_territory_resource_pvt.terrresource_out_tbl_type;
      l_terrrsc_access_out_tbl      jtf_territory_resource_pvt.terrrsc_access_out_tbl_type;
   --

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT upadate_terrresource_pub;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (
                l_api_version_number,
                p_api_version_number,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      -- Convert incomming data from public to private Tbl format
      convert_terrrsc_pubtopvt (
         p_terrrsc_tbl => p_terrrsc_tbl,
         x_terrrsc_tbl => l_terrrsc_tbl
      );
      convert_terrrscacc_pubtopvt (
         p_terrrscacc_tbl => p_terrrsc_access_tbl,
         x_terrrscacc_tbl => l_terrrsc_access_tbl
      );
      --
      jtf_territory_resource_pvt.update_terrresource (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terrrsc_tbl => l_terrrsc_tbl,
         p_terrrsc_access_tbl => l_terrrsc_access_tbl,
         x_terrrsc_out_tbl => l_terrrsc_out_tbl,
         x_terrrsc_access_out_tbl => l_terrrsc_access_out_tbl
      );
      convert_terrrscout_pvttopub (
         p_terrrscout_tbl => l_terrrsc_out_tbl,
         x_terrrscout_tbl => x_terrrsc_out_tbl
      );
      convert_terrscaccout_pvttopub (
         p_terrrscaccout_tbl => l_terrrsc_access_out_tbl,
         x_terrrscaccout_tbl => x_terrrsc_access_out_tbl
      );

      x_return_status  := l_return_status;
      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

      WHEN OTHERS
      THEN
         ROLLBACK TO update_terrresource_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Update_TerrResource PUB' || SQLERRM
            );

         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END update_terrresource;
--

END jtf_territory_pub;

/
