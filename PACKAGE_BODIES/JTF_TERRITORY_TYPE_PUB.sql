--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_TYPE_PUB" AS
/* $Header: jtfpttyb.pls 120.0 2005/06/02 18:21:03 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_TYPE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting territory type
--      related information in to information into JTF tables.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/29/99   JDOCHERT         Created
--      11-20-99   VNEDUNGA         Changed the QUALIFER_MODE from
--                                  NUMBER to VARCHAR2
--      02-22-00   VNEDUNGA         Changing the copy record routines
--                                  to consider org_id
--      03-28-00   VNEDUNGA         Adding the fnd_message calls
--
--
--    End of Comments
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   g_pkg_name           CONSTANT VARCHAR2(30) := 'JTF_TERRITORY_TYPE_PUB';
   g_file_name          CONSTANT VARCHAR2(12) := 'jtfpttyb.pls';
   g_appl_id                     NUMBER := fnd_global.prog_appl_id;
   g_login_id                    NUMBER := fnd_global.conc_login_id;
   g_program_id                  NUMBER := fnd_global.conc_program_id;
   g_user_id                     NUMBER := fnd_global.user_id;
   g_request_id                  NUMBER := fnd_global.conc_request_id;

-- -------------------------------------------------
--   Package Name : Convert_TerTypeRec_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  jtf_TerrType_rec from pub to pvt before
--                  calling the JTF_TERRITORY_TYPE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_tertyperec_pubtopvt (
      p_terrtype_rec   IN       jtf_territory_type_pub.terrtype_rec_type,
      x_terrtype_rec   OUT NOCOPY      jtf_territory_type_pvt.terrtype_rec_type
   )
   AS
   BEGIN
      x_terrtype_rec.terr_type_id := p_terrtype_rec.terr_type_id;
      x_terrtype_rec.name := p_terrtype_rec.name;
      x_terrtype_rec.last_update_date := p_terrtype_rec.last_update_date;
      x_terrtype_rec.last_updated_by := p_terrtype_rec.last_updated_by;
      x_terrtype_rec.creation_date := p_terrtype_rec.creation_date;
      x_terrtype_rec.created_by := p_terrtype_rec.created_by;
      x_terrtype_rec.last_update_login := p_terrtype_rec.last_update_login;
      x_terrtype_rec.enabled_flag := p_terrtype_rec.enabled_flag;
      x_terrtype_rec.application_short_name :=
         p_terrtype_rec.application_short_name;
      x_terrtype_rec.description := p_terrtype_rec.description;
      x_terrtype_rec.org_id := p_terrtype_rec.org_id;
      x_terrtype_rec.attribute_category := p_terrtype_rec.attribute_category;
      x_terrtype_rec.attribute1 := p_terrtype_rec.attribute1;
      x_terrtype_rec.attribute2 := p_terrtype_rec.attribute2;
      x_terrtype_rec.attribute3 := p_terrtype_rec.attribute3;
      x_terrtype_rec.attribute4 := p_terrtype_rec.attribute4;
      x_terrtype_rec.attribute5 := p_terrtype_rec.attribute5;
      x_terrtype_rec.attribute6 := p_terrtype_rec.attribute6;
      x_terrtype_rec.attribute7 := p_terrtype_rec.attribute7;
      x_terrtype_rec.attribute8 := p_terrtype_rec.attribute8;
      x_terrtype_rec.attribute9 := p_terrtype_rec.attribute9;
      x_terrtype_rec.attribute10 := p_terrtype_rec.attribute10;
      x_terrtype_rec.attribute11 := p_terrtype_rec.attribute11;
      x_terrtype_rec.attribute12 := p_terrtype_rec.attribute12;
      x_terrtype_rec.attribute13 := p_terrtype_rec.attribute13;
      x_terrtype_rec.attribute14 := p_terrtype_rec.attribute14;
      x_terrtype_rec.attribute15 := p_terrtype_rec.attribute15;
      x_terrtype_rec.start_date_active := p_terrtype_rec.start_date_active;
      x_terrtype_rec.end_date_active := p_terrtype_rec.end_date_active;
   --

   END convert_tertyperec_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TerTypeUsg_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  jtf_TerrTypeUsg_Tbl from pub to pvt
--                  before calling the JTF_TERRITORY_TYPE_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_tertypeusg_pubtopvt (
      p_terrtypeusgs_tbl   IN       jtf_territory_type_pub.terrtypeusgs_tbl_type,
      x_terrtypeusgs_tbl   OUT NOCOPY      jtf_territory_type_pvt.terrtypeusgs_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_terrtypeusgs_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrtypeusgs_tbl.COUNT
      LOOP
         --
         x_terrtypeusgs_tbl (l_counter).terr_type_usg_id :=
            p_terrtypeusgs_tbl (l_counter).terr_type_usg_id;
         x_terrtypeusgs_tbl (l_counter).source_id :=
            p_terrtypeusgs_tbl (l_counter).source_id;
         x_terrtypeusgs_tbl (l_counter).terr_type_id :=
            p_terrtypeusgs_tbl (l_counter).terr_type_id;
         x_terrtypeusgs_tbl (l_counter).last_update_date :=
            p_terrtypeusgs_tbl (l_counter).last_update_date;
         x_terrtypeusgs_tbl (l_counter).last_updated_by :=
            p_terrtypeusgs_tbl (l_counter).last_updated_by;
         x_terrtypeusgs_tbl (l_counter).creation_date :=
            p_terrtypeusgs_tbl (l_counter).creation_date;
         x_terrtypeusgs_tbl (l_counter).created_by :=
            p_terrtypeusgs_tbl (l_counter).created_by;
         x_terrtypeusgs_tbl (l_counter).last_update_login :=
            p_terrtypeusgs_tbl (l_counter).last_update_login;
         x_terrtypeusgs_tbl (l_counter).org_id :=
            p_terrtypeusgs_tbl (l_counter).org_id;
      --
      END LOOP;
   --

   END convert_tertypeusg_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TypeQtypeUsg_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  TypeQualTypeUsgs from pub to pvt before
--                  calling the JTF_TERRITORY_TYPE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_typeqtypeusg_pubtopvt (
      p_typequaltypeusgs_tbl   IN       jtf_territory_type_pub.typequaltypeusgs_tbl_type,
      x_typequaltypeusgs_tbl   OUT NOCOPY      jtf_territory_type_pvt.typequaltypeusgs_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_typequaltypeusgs_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;
      --
      FOR l_counter IN 1 .. p_typequaltypeusgs_tbl.COUNT
      LOOP
         --
         x_typequaltypeusgs_tbl (l_counter).type_qual_type_usg_id :=
            p_typequaltypeusgs_tbl (l_counter).type_qual_type_usg_id;
         x_typequaltypeusgs_tbl (l_counter).terr_type_id :=
            p_typequaltypeusgs_tbl (l_counter).terr_type_id;
         x_typequaltypeusgs_tbl (l_counter).qual_type_usg_id :=
            p_typequaltypeusgs_tbl (l_counter).qual_type_usg_id;
         x_typequaltypeusgs_tbl (l_counter).last_update_date :=
            p_typequaltypeusgs_tbl (l_counter).last_update_date;
         x_typequaltypeusgs_tbl (l_counter).last_updated_by :=
            p_typequaltypeusgs_tbl (l_counter).last_updated_by;
         x_typequaltypeusgs_tbl (l_counter).creation_date :=
            p_typequaltypeusgs_tbl (l_counter).creation_date;
         x_typequaltypeusgs_tbl (l_counter).created_by :=
            p_typequaltypeusgs_tbl (l_counter).created_by;
         x_typequaltypeusgs_tbl (l_counter).last_update_login :=
            p_typequaltypeusgs_tbl (l_counter).last_update_login;
         x_typequaltypeusgs_tbl (l_counter).org_id :=
            p_typequaltypeusgs_tbl (l_counter).org_id;
      --
      END LOOP;
   --

   END convert_typeqtypeusg_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TerrTypeQual_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  TerrTypequal from pub to pvt before
--                  calling the JTF_TERRITORY_TYPE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrtypequal_pubtopvt (
      p_terrtypequal_tbl   IN       jtf_territory_type_pub.terrtypequal_tbl_type,
      x_terrtypequal_tbl   OUT NOCOPY      jtf_territory_type_pvt.terrtypequal_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      --  If the table is empty
      IF p_terrtypequal_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrtypequal_tbl.COUNT
      LOOP
         --
         x_terrtypequal_tbl (l_counter).terr_type_qual_id :=
            p_terrtypequal_tbl (l_counter).terr_type_qual_id;
         x_terrtypequal_tbl (l_counter).last_update_date :=
            p_terrtypequal_tbl (l_counter).last_update_date;
         x_terrtypequal_tbl (l_counter).last_updated_by :=
            p_terrtypequal_tbl (l_counter).last_updated_by;
         x_terrtypequal_tbl (l_counter).creation_date :=
            p_terrtypequal_tbl (l_counter).creation_date;
         x_terrtypequal_tbl (l_counter).created_by :=
            p_terrtypequal_tbl (l_counter).created_by;
         x_terrtypequal_tbl (l_counter).last_update_login :=
            p_terrtypequal_tbl (l_counter).last_update_login;
         x_terrtypequal_tbl (l_counter).qual_usg_id :=
            p_terrtypequal_tbl (l_counter).qual_usg_id;
         x_terrtypequal_tbl (l_counter).terr_type_id :=
            p_terrtypequal_tbl (l_counter).terr_type_id;
         x_terrtypequal_tbl (l_counter).exclusive_use_flag :=
            p_terrtypequal_tbl (l_counter).exclusive_use_flag;
         x_terrtypequal_tbl (l_counter).overlap_allowed_flag :=
            p_terrtypequal_tbl (l_counter).overlap_allowed_flag;
         x_terrtypequal_tbl (l_counter).in_use_flag :=
            p_terrtypequal_tbl (l_counter).in_use_flag;
         x_terrtypequal_tbl (l_counter).qualifier_mode :=
            p_terrtypequal_tbl (l_counter).qualifier_mode;
         x_terrtypequal_tbl (l_counter).org_id :=
            p_terrtypequal_tbl (l_counter).org_id;
      --
      END LOOP;
   --

   END convert_terrtypequal_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TerrTypeOut_PubToPvt
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  terr_type_out_rec from pvt to pub
--                  after calling JTF_TERRITORY_TYPE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_terrtypeout_pubtopvt (
      p_terrtype_rec   IN       jtf_territory_type_pvt.terrtype_out_rec_type,
      x_terrtype_rec   OUT NOCOPY      jtf_territory_type_pub.terrtype_out_rec_type
   )
   AS
   BEGIN
   --
      x_terrtype_rec.terr_type_id := p_terrtype_rec.terr_type_id;
      x_terrtype_rec.return_status := p_terrtype_rec.return_status;
   --
   END convert_terrtypeout_pubtopvt;

-- -------------------------------------------------
--   Package Name : Convert_TypeUsgOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_Type_Usgs_out_Tbl from pvt to pub
--                  after calling JTF_TERRITORY_TYPE_PVT pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_typeusgout_pvttopub (
      p_terrtypeusgsout_tbl   IN       jtf_territory_type_pvt.terrtypeusgs_out_tbl_type,
      x_terrtypeusgsout_tbl   OUT NOCOPY      jtf_territory_type_pub.terrtypeusgs_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      IF p_terrtypeusgsout_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrtypeusgsout_tbl.COUNT
      LOOP
         x_terrtypeusgsout_tbl (l_counter).terr_type_usg_id :=
            p_terrtypeusgsout_tbl (l_counter).terr_type_usg_id;
         x_terrtypeusgsout_tbl (l_counter).return_status :=
            p_terrtypeusgsout_tbl (l_counter).return_status;
      END LOOP;
      --
   END convert_typeusgout_pvttopub;

-- -------------------------------------------------
--   Package Name : Convert_TypeQTUsgOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_QualTypeUsgs_Out_Tbl from pvt
--                  to pub after calling JTF_TERRITORY_TYPE_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_typeqtusgout_pvttopub (
      p_typequaltypeusgs_tbl   IN       jtf_territory_type_pvt.typequaltypeusgs_out_tbl_type,
      x_typequaltypeusgs_tbl   OUT NOCOPY      jtf_territory_type_pub.typequaltypeusgs_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      IF p_typequaltypeusgs_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_typequaltypeusgs_tbl.COUNT
      LOOP
         --
         x_typequaltypeusgs_tbl (l_counter).type_qual_type_usg_id :=
            p_typequaltypeusgs_tbl (l_counter).type_qual_type_usg_id;
         x_typequaltypeusgs_tbl (l_counter).return_status :=
            p_typequaltypeusgs_tbl (l_counter).return_status;
      --

      END LOOP;
   --
   END convert_typeqtusgout_pvttopub;

-- -------------------------------------------------
--   Package Name : Convert_TypeQualOut_PvtToPub
-- -------------------------------------------------
--   Purpose      : This utility procedure will convert
--                  Terr_QualTypeUsgs_Out_Tbl from pvt
--                  to pub after calling JTF_TERRITORY_TYPE_PVT
--                  pkg.
--   Notes        :
--   History      :
--                  08/23/99 VNEDUNGA Created
-- -------------------------------------------------
   PROCEDURE convert_typequalout_pvttopub (
      p_terrtypequal_tbl   IN       jtf_territory_type_pvt.terrtypequal_out_tbl_type,
      x_terrtypequal_tbl   OUT NOCOPY      jtf_territory_type_pub.terrtypequal_out_tbl_type
   )
   AS
      l_counter                     NUMBER;
   BEGIN
      --
      IF p_terrtypequal_tbl.COUNT = 0
      THEN
         RETURN;
      END IF;

      --
      FOR l_counter IN 1 .. p_terrtypequal_tbl.COUNT
      LOOP
         --
         x_terrtypequal_tbl (l_counter).terr_type_qual_id :=
            p_terrtypequal_tbl (l_counter).terr_type_qual_id;
         x_terrtypequal_tbl (l_counter).return_status :=
            p_terrtypequal_tbl (l_counter).return_status;
      --

      END LOOP;
   --

   END convert_typequalout_pvttopub;

--    ***************************************************

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : create_terrtype
--    type           : public.
--    function       : creates territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :

--    in:
--        p_api_version_number        in  number                    required
--        p_init_msg_list             in  varchar2                  optional --default = fnd_api.g_false
--        p_commit                    in  varchar2                  optional --default = fnd_api.g_false
--        p_TerrType_rec               in  TerrType_rec_type          required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl           in  TerrTypequal_tbl_type      required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypeusgs_tbl           in  TerrTypeusgs_rec_type      required --default = g_miss_tersrc_rec
--        p_TypequalTypeusgs_tbl      in  TypeQualTypeUsgs_tbl_type required --default = g_miss_tersrc_tbl,
--
--    out:
--        p_return_status             out varchar2(1)
--        p_msg_count                 out number
--        p_msg_data                  out varchar2(2000)
--        p_TerrType_id               out number
--        p_TerrTypequal_out_tbl       out TerrTypequal_out_tbl_type
--        p_TerrTypeusgs_out_tbl       out TerrTypeusgs_out_tbl_type
--        p_TypeQualTypeUsgs_out_tbl  out TypeQualTypeUsgs_out_tbl_type
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:     api for creating territory types
--
-- end of comments
   PROCEDURE create_terrtype (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_terrtype_rec               IN       terrtype_rec_type
            := g_miss_terrtype_rec,
      p_terrtypequal_tbl           IN       terrtypequal_tbl_type
            := g_miss_terrtypequal_tbl,
      p_terrtypeusgs_tbl           IN       terrtypeusgs_tbl_type
            := g_miss_terrtypeusgs_tbl,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type
            := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_terrtype_id                OUT NOCOPY      NUMBER,
      x_terrtypequal_out_tbl       OUT NOCOPY      terrtypequal_out_tbl_type,
      x_terrtypeusgs_out_tbl       OUT NOCOPY      terrtypeusgs_out_tbl_type,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   IS
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      -- Status Local Variables
      l_return_status               VARCHAR2(1);   -- Return value from procedures
      l_terrtype_rec                jtf_territory_type_pvt.terrtype_rec_type;
      l_terrtypequal_tbl            jtf_territory_type_pvt.terrtypequal_tbl_type;
      l_terrtypeusgs_tbl            jtf_territory_type_pvt.terrtypeusgs_tbl_type;
      l_typequaltypeusgs_tbl        jtf_territory_type_pvt.typequaltypeusgs_tbl_type;
      l_terrtypequal_out_tbl        jtf_territory_type_pvt.terrtypequal_out_tbl_type;
      l_terrtypeusgs_out_tbl        jtf_territory_type_pvt.terrtypeusgs_out_tbl_type;
      l_typequaltypeusgs_out_tbl    jtf_territory_type_pvt.typequaltypeusgs_out_tbl_type;
--

   BEGIN
      --dbms_output.put_line('Create_terrtype PUB: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terrtype_pub;

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
      --dbms_output.put_line('Create_terrtype PUB: Before Convertion from PUB to PVT routines');
      convert_tertyperec_pubtopvt (
         p_terrtype_rec => p_terrtype_rec,
         x_terrtype_rec => l_terrtype_rec
      );
      convert_terrtypequal_pubtopvt (
         p_terrtypequal_tbl => p_terrtypequal_tbl,
         x_terrtypequal_tbl => l_terrtypequal_tbl
      );
      convert_tertypeusg_pubtopvt (
         p_terrtypeusgs_tbl => p_terrtypeusgs_tbl,
         x_terrtypeusgs_tbl => l_terrtypeusgs_tbl
      );
      convert_typeqtypeusg_pubtopvt (
         p_typequaltypeusgs_tbl => p_typequaltypeusgs_tbl,
         x_typequaltypeusgs_tbl => l_typequaltypeusgs_tbl
      );
      --dbms_output.put_line('Create_terrtype PVT: Before Calling JTF_TERRITORY_TYPE_PVT.create_terrtype');
      jtf_territory_type_pvt.create_terrtype (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         p_terrtype_rec => l_terrtype_rec,
         p_terrtypequal_tbl => l_terrtypequal_tbl,
         p_terrtypeusgs_tbl => l_terrtypeusgs_tbl,
         p_typequaltypeusgs_tbl => l_typequaltypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtype_id => x_terrtype_id,
         x_terrtypequal_out_tbl => l_terrtypequal_out_tbl,
         x_terrtypeusgs_out_tbl => l_terrtypeusgs_out_tbl,
         x_typequaltypeusgs_out_tbl => l_typequaltypeusgs_out_tbl
      );

      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --dbms_output.put_line('Create_terrtype PUB: Before Convertion from PVT to PUB routines');
      convert_typeusgout_pvttopub (
         p_terrtypeusgsout_tbl => l_terrtypeusgs_out_tbl,
         x_terrtypeusgsout_tbl => x_terrtypeusgs_out_tbl
      );
      convert_typeqtusgout_pvttopub (
         p_typequaltypeusgs_tbl => l_typequaltypeusgs_out_tbl,
         x_typequaltypeusgs_tbl => x_typequaltypeusgs_out_tbl
      );
      convert_typequalout_pvttopub (
         p_terrtypequal_tbl => l_terrtypequal_out_tbl,
         x_terrtypequal_tbl => x_terrtypequal_out_tbl
      );

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
   --dbms_output.put_line('Create_terrtype PUB: Exiting API');
   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Create_terrtype PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO create_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Create_terrtype PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO create_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Create_terrtype PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO create_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Create_TerrType PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END create_terrtype;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : update_Terrtype
--    type           : public.
--    function       : Update territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :

--    in:
--        p_api_version_number   in  number                  required
--        p_init_msg_list        in  varchar2                optional --default = fnd_api.g_false
--        p_commit               in  varchar2                optional --default = fnd_api.g_false
--        p_TerrType_rec          in  TerrType_rec_type        required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl      in  TerrTypequal_tbl_type    required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypesrc_tbl       in  TerrTypesrc_rec_type     required --default = g_miss_tersrc_rec
--        p_TerrTypeSrcType_tbl   in  TerrTypeSrcType_tbl_type required --default = g_miss_tersrc_tbl,
--    out:
--        p_return_status            out varchar2(1)
--        p_msg_count                out number
--        p_msg_data                 out varchar2(2000)
--        p_TerrTypequal_out_tbl      out   TerrTypequal_out_tbl_type,
--        p_TerrTypesrc_out_tbl       out   TerrTypeSrc_out_tbl_type,
--        p_TerrTypeSrcType_out_tbl   out   TerrTypeSrcType_out_tbl_type
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              api for Updating territory types
--
-- end of comments
   PROCEDURE update_terrtype (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_terrtype_rec               IN       terrtype_rec_type
            := g_miss_terrtype_rec,
      p_terrtypequal_tbl           IN       terrtypequal_tbl_type
            := g_miss_terrtypequal_tbl,
      p_terrtypeusgs_tbl           IN       terrtypeusgs_tbl_type
            := g_miss_terrtypeusgs_tbl,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type
            := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_terrtype_out_rec           OUT NOCOPY      terrtype_out_rec_type,
      x_terrtypequal_out_tbl       OUT NOCOPY      terrtypequal_out_tbl_type,
      x_terrtypeusgs_out_tbl       OUT NOCOPY      terrtypeusgs_out_tbl_type,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   IS
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      -- Status Local Variables
      l_return_status               VARCHAR2(1);   -- Return value from procedures
      l_terrtype_rec                jtf_territory_type_pvt.terrtype_rec_type;
      l_terrtypequal_tbl            jtf_territory_type_pvt.terrtypequal_tbl_type;
      l_terrtypeusgs_tbl            jtf_territory_type_pvt.terrtypeusgs_tbl_type;
      l_typequaltypeusgs_tbl        jtf_territory_type_pvt.typequaltypeusgs_tbl_type;
      l_terrtype_out_rec            jtf_territory_type_pvt.terrtype_out_rec_type;
      l_terrtypequal_out_tbl        jtf_territory_type_pvt.terrtypequal_out_tbl_type;
      l_terrtypeusgs_out_tbl        jtf_territory_type_pvt.terrtypeusgs_out_tbl_type;
      l_typequaltypeusgs_out_tbl    jtf_territory_type_pvt.typequaltypeusgs_out_tbl_type;
--

   BEGIN
      --dbms_output.put_line('Update_terrtype PUB: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT upadate_terrtype_pub;

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
      --dbms_output.put_line('Update_terrtype PUB: Before Convertion from PUB to PVT routines');
      convert_tertyperec_pubtopvt (
         p_terrtype_rec => p_terrtype_rec,
         x_terrtype_rec => l_terrtype_rec
      );
      convert_terrtypequal_pubtopvt (
         p_terrtypequal_tbl => p_terrtypequal_tbl,
         x_terrtypequal_tbl => l_terrtypequal_tbl
      );
      convert_tertypeusg_pubtopvt (
         p_terrtypeusgs_tbl => p_terrtypeusgs_tbl,
         x_terrtypeusgs_tbl => l_terrtypeusgs_tbl
      );
      convert_typeqtypeusg_pubtopvt (
         p_typequaltypeusgs_tbl => p_typequaltypeusgs_tbl,
         x_typequaltypeusgs_tbl => l_typequaltypeusgs_tbl
      );
      --
      --dbms_output.put_line('Update_terrtype PVT: Before Calling JTF_TERRITORY_TYPE_PVT.Update_terrtype');
      jtf_territory_type_pvt.update_terrtype (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         p_terrtype_rec => l_terrtype_rec,
         p_terrtypequal_tbl => l_terrtypequal_tbl,
         p_terrtypeusgs_tbl => l_terrtypeusgs_tbl,
         p_typequaltypeusgs_tbl => l_typequaltypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtype_out_rec => l_terrtype_out_rec,
         x_terrtypequal_out_tbl => l_terrtypequal_out_tbl,
         x_terrtypeusgs_out_tbl => l_terrtypeusgs_out_tbl,
         x_typequaltypeusgs_out_tbl => l_typequaltypeusgs_out_tbl
      );

      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --dbms_output.put_line('Update_terrtype PUB: Before Convertion from PVT to PUB routines');
      convert_terrtypeout_pubtopvt (
         p_terrtype_rec => l_terrtype_out_rec,
         x_terrtype_rec => x_terrtype_out_rec
      );
      convert_typeusgout_pvttopub (
         p_terrtypeusgsout_tbl => l_terrtypeusgs_out_tbl,
         x_terrtypeusgsout_tbl => x_terrtypeusgs_out_tbl
      );
      convert_typeqtusgout_pvttopub (
         p_typequaltypeusgs_tbl => l_typequaltypeusgs_out_tbl,
         x_typequaltypeusgs_tbl => x_typequaltypeusgs_out_tbl
      );
      convert_typequalout_pvttopub (
         p_terrtypequal_tbl => l_terrtypequal_out_tbl,
         x_terrtypequal_tbl => x_terrtypequal_out_tbl
      );

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
   --dbms_output.put_line('Update_terrtype PUB: Exiting API');

   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Update_terrtype PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO update_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Update_terrtype PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO update_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Update_terrtype PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Update_TerrType PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END update_terrtype;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Delete_TerrType
--    type           : public.
--    function       : Delete territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :
--
--    in:
--        p_api_version_number   in  number               required
--        p_init_msg_list        in  varchar2             optional --default = fnd_api.g_false
--        p_commit               in  varchar2             optional --default = fnd_api.g_false
--        p_TerrType_id          in  number
--
--    out:
--        p_return_status        out varchar2(1)
--        p_msg_count            out number
--        p_msg_data             out varchar2(2000)
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              API for Deleting territory types
--
-- end of comments
   PROCEDURE delete_terrtype (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_terrtype_id          IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      --dbms_output.put_line('Delete_terrtype PUB: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT delete_terrtype_pub;

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
      --dbms_output.put_line('Delete__terrtype PVT: Before Calling JTF_TERRITORY_TYPE_PVT.Delete_TerrType');
      jtf_territory_type_pvt.delete_terrtype (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terrtype_id => p_terrtype_id
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
   --dbms_output.put_line('Delete_terrtype PUB: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Delete__terrtype PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO delete_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Delete__terrtype PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO delete_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Delete__terrtype PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO delete_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Delete_TerrType PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END delete_terrtype;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Deactivate_TerrType
--    type           : public.
--    function       : Deactivate territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :
--
--    in:
--        p_api_version_number   in  number               required
--        p_init_msg_list        in  varchar2             optional --default = fnd_api.g_false
--        p_commit               in  varchar2             optional --default = fnd_api.g_false
--        p_TerrType_id          in  number
--
--    out:
--        p_return_status        out varchar2(1)
--        p_msg_count            out number
--        p_msg_data             out varchar2(2000)
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              API for Deleting territory types
--
-- end of comments
   PROCEDURE deactivate_terrtype (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_terrtype_id          IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Deactivate_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT deactivate_terrtype_pub;

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
      --dbms_output.put_line('De-Activate_terrtype PVT: Before Calling JTF_TERRITORY_TYPE_PVT.Deactivate_TerrType');
      jtf_territory_type_pvt.deactivate_terrtype (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terrtype_id => p_terrtype_id
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
   --dbms_output.put_line('De-Activate_terrtype PUB: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('De-Activate_terrtype PUB: FND_API.G_EXC_ERROR');
         ROLLBACK TO deactivate_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('De-Activate_terrtype PUB: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO deactivate_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('De-Activate_terrtype PUB: OTHERS - ' || SQLERRM);
         ROLLBACK TO deactivate_terrtype_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               'Others exception in Deactivate_TerrType PUB' || SQLERRM
            );
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END deactivate_terrtype;
--

END jtf_territory_type_pub;   -- Package body

/
