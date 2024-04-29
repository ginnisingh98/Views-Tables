--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_TYPE_PVT" AS
/* $Header: jtfvttyb.pls 120.0 2005/06/02 18:23:08 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_TYPE_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting territory type
--      related information in to information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--    PROCEDURE:
--         (see below for specification)
--
--    NOTES
--      This package is for private use only
--
--    HISTORY
--      07/29/99   VNEDUNGA         Created
--      11/29/99   Vnedunga         Added a  new validation routine
--                                  Is_TerrType_Deletable
--      01/25/00   VNEDUNGA         Adding Copy terr Type procedure
--      02/10/00   VNEDUNGA         Change the call to TABLE HANDLER
--                                  to pass in the dates from the record
--                                  passed
--      02/20/00   VNEDUNGA         Chaging the Insert_Row/Update_Row
--                                  to pass org_id to table handler
--      02/25/00   VNEDUNGA         Fixing the Insert_row and update_row
--                                  to use the id passed to the API
--      03/09/00   VNEDUNGA         Chnages to validaton routines
--      05/02/00   VNEDUNGA         Addding rownum < 2 in validate_qualifer
--      07/20/00    JDOCHERT        Changed as follows in Create_terrtype_record
--                                  as this meant that a terr_type_id passed
--                                  into Create API was ignored:
--                                  l_terr_type_id := 0;
--                                  TO
--                                  l_terrtype_id                 NUMBER := P_TERRTYPE_REC.TERR_TYPE_ID;
--
--    End of Comments
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   g_pkg_name           CONSTANT VARCHAR2(30) := 'JTF_TERRITORY_TYPE_PVT';
   g_file_name          CONSTANT VARCHAR2(12) := 'jtfvttyb.pls';
   g_appl_id                     NUMBER := fnd_global.prog_appl_id;
   g_login_id                    NUMBER := fnd_global.conc_login_id;
   g_program_id                  NUMBER := fnd_global.conc_program_id;
   g_user_id                     NUMBER := fnd_global.user_id;
   g_request_id                  NUMBER := fnd_global.conc_request_id;
   g_app_short_name              VARCHAR2(15)
            := fnd_global.application_short_name;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : create_terrtype
--    type           : public.
--    function       : creates territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :

--    in:
--        p_api_version_number        in  number                     required
--        p_init_msg_list             in  varchar2                   optional --default = fnd_api.g_false
--        p_commit                    in  varchar2                   optional --default = fnd_api.g_false
--        p_TerrType_rec              in  TerrType_rec_type          required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl          in  TerrTypequal_tbl_type      required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypeusgs_tbl          in  TerrTypeusgs_rec_type      required --default = g_miss_tersrc_rec
--        p_TypequalTypeusgs_tbl      in  TypeQualTypeUsgs_tbl_type  required --default = g_miss_tersrc_tbl,
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
      p_validation_level           IN       NUMBER   := fnd_api.g_valid_level_full,
      p_terrtype_rec               IN       terrtype_rec_type := g_miss_terrtype_rec,
      p_terrtypequal_tbl           IN       terrtypequal_tbl_type := g_miss_terrtypequal_tbl,
      p_terrtypeusgs_tbl           IN       terrtypeusgs_tbl_type := g_miss_terrtypeusgs_tbl,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_terrtype_id                OUT NOCOPY      NUMBER,
      x_terrtypequal_out_tbl       OUT NOCOPY      terrtypequal_out_tbl_type,
      x_terrtypeusgs_out_tbl       OUT NOCOPY      terrtypeusgs_out_tbl_type,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      -- Status Local Variables
      l_return_status               VARCHAR2(1);   -- Return value from procedures
      l_return_status_full          VARCHAR2(1);   -- Calculated return status from

      -- all return values
      l_terrtype_out_rec            terrtype_out_rec_type;
      l_terrtypeusgs_out_tbl        terrtypeusgs_out_tbl_type;
      l_typequaltypeusgs_out_tbl    typequaltypeusgs_out_tbl_type;
      l_terrtypequal_out_tbl        terrtypequal_out_tbl_type;
      l_terrtypequal_tbl            terrtypequal_tbl_type;
      l_terrtype_id                 NUMBER := 0;
      l_terrtypequal_id             NUMBER := 0;
      l_qual_counter                NUMBER := 1;
      l_counter                     NUMBER := 0;
      l_index                       NUMBER := 0;
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2(2000);
   BEGIN
      --dbms_ourtput.put_line('create_terrtype PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terrtype_pvt;

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
      --
      -- If incomming data is good
      -- Start creating territory related records
      --
      --dbms_ourtput.put_line('create_terrtype PVT: Before Calling Create_TerrType_Header PVT');
      --
      create_terrtype_header (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_rec => p_terrtype_rec,
         p_terrtypeusgs_tbl => p_terrtypeusgs_tbl,
         p_typequaltypeusgs_tbl => p_typequaltypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         x_terrtype_out_rec => l_terrtype_out_rec,
         x_terrtypeusgs_out_tbl => l_terrtypeusgs_out_tbl,
         x_typequaltypeusgs_out_tbl => l_typequaltypeusgs_out_tbl
      );
      --Save the territory id for later use
      l_terrtype_id := l_terrtype_out_rec.terr_type_id;
      x_terrtype_id := l_terrtype_out_rec.terr_type_id;
      x_terrtypeusgs_out_tbl := l_terrtypeusgs_out_tbl;
      x_typequaltypeusgs_out_tbl := l_typequaltypeusgs_out_tbl;
      x_return_status := l_return_status;

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --dbms_ourtput.put_line('create_terrtype PVT: Before Calling Create_TerrType_Qualifier PVT');
      create_terrtype_qualifier (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_id => l_terrtype_id,
         p_terrtypequal_tbl => p_terrtypequal_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtypequal_out_tbl => l_terrtypequal_out_tbl
      );
      x_terrtypequal_out_tbl := l_terrtypequal_out_tbl;
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
   --dbms_ourtput.put_line('create_terrtype PVT: Exiting API');
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO create_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO create_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('create_terrtype PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO create_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
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
      p_validation_level           IN       NUMBER   := fnd_api.g_valid_level_full,
      p_terrtype_rec               IN       terrtype_rec_type := g_miss_terrtype_rec,
      p_terrtypequal_tbl           IN       terrtypequal_tbl_type := g_miss_terrtypequal_tbl,
      p_terrtypeusgs_tbl           IN       terrtypeusgs_tbl_type := g_miss_terrtypeusgs_tbl,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_terrtype_out_rec           OUT NOCOPY      terrtype_out_rec_type,
      x_terrtypequal_out_tbl       OUT NOCOPY      terrtypequal_out_tbl_type,
      x_terrtypeusgs_out_tbl       OUT NOCOPY      terrtypeusgs_out_tbl_type,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      --dbms_ourtput.put_line('Update_Terrtype PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT update_terrtype_pvt;

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
      --dbms_ourtput.put_line('Update_Terrtype PVT: Before Calling Update_TerrType_Record');
      update_terrtype_record (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_rec => p_terrtype_rec,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtype_out_rec => x_terrtype_out_rec
      );

      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --dbms_ourtput.put_line('Update_Terrtype PVT: Before Calling Update_TerrTypeQualType_Usage');
      update_terrtypequaltype_usage (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_typequaltypeusgs_tbl => p_typequaltypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_typequaltypeusgs_out_tbl => x_typequaltypeusgs_out_tbl
      );

      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --dbms_ourtput.put_line('Update_Terrtype PVT: Before Calling Update_TerrType_Usages');
      update_terrtype_usages (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtypeusgs_tbl => p_terrtypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtypeusgs_out_tbl => x_terrtypeusgs_out_tbl
      );

      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --dbms_ourtput.put_line('Update_Terrtype PVT: Before Calling Update_TerrType_Qualifier');
      update_terrtype_qualifier (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtypequal_tbl => p_terrtypequal_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtypequal_out_tbl => x_terrtypequal_out_tbl
      );

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
   --dbms_ourtput.put_line('Update_Terrtype PVT: Exiting API');
   --
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_ourtput.put_line('Update_Terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO update_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Update_Terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO update_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Update_Terrtype PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END;

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
      p_validation_level     IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_id          IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   AS
      l_terrtype_id                 NUMBER := p_terrtype_id;

      --Declare cursor to get Terr Qualifier
      CURSOR c_getterrtypequal
      IS
         SELECT jtq.terr_type_qual_id
           FROM jtf_terr_type_qual jtq
          WHERE jtq.terr_type_id = l_terrtype_id
            FOR UPDATE;

      --Declare cursor to get qualifiers Type usages
      CURSOR c_gettypequaltypeusgs
      IS
         SELECT jtqu.type_qtype_usg_id
           FROM jtf_type_qtype_usgs jtqu
          WHERE jtqu.terr_type_id = l_terrtype_id
            FOR UPDATE;

      --Declare cursor to get Terr Usages
      CURSOR c_getterrtypeusgs
      IS
         SELECT jtu.terr_type_usg_id
           FROM jtf_terr_type_usgs jtu
          WHERE jtu.terr_type_id = l_terrtype_id
            FOR UPDATE;

      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Territory';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terr_value_id               NUMBER;
      l_terr_qual_id                NUMBER;
      l_terr_usg_id                 NUMBER;
      l_terr_qual_type_usg_id       NUMBER;
   BEGIN
--
      --dbms_ourtput.put_line('Delete_Terrtype PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT delete_territory_pvt;

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
      --Is_Territory_Deletable(....);
      --
      --IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --   RAISE FND_API.G_EXC_ERROR;
      --END IF;

      --dbms_ourtput.put_line('Delete_Terrtype PVT: Before opening C_GetTerrTypeQual');
      FOR c IN c_getterrtypequal
      LOOP
         --dbms_ourtput.put_line('Delete_Terrtype PVT: Before calling  Delete_TerrType_Qualifier');
         delete_terrtype_qualifier (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_terrtypequal_id => c.terr_type_qual_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      --

      END LOOP;

      --
      --dbms_ourtput.put_line('Delete_Terrtype PVT: Before opening C_GetTypeQualTypeUsgs');
      FOR c IN c_gettypequaltypeusgs
      LOOP
         --
         --dbms_ourtput.put_line('Delete_Terrtype PVT: Before calling  Delete_TerrTypeQualType_Usage');
         delete_terrtypequaltype_usage (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_terrtypequaltype_usg_id => c.type_qtype_usg_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      --

      END LOOP;

      --
      --dbms_ourtput.put_line('Delete_Terrtype PVT: Before opening  C_GetTerrTypeUsgs');
      FOR c IN c_getterrtypeusgs
      LOOP
         --
         --dbms_ourtput.put_line('Delete_Terrtype PVT: Before calling  Delete_TerrType_Usages');
         delete_terrtype_usages (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_terrtypeusg_id => c.terr_type_usg_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      --

      END LOOP;

      --dbms_ourtput.put_line('Delete_Terrtype PVT: Before calling  Delete_TerrType_Record');
      delete_terrtype_record (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_terrtype_id => l_terrtype_id,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
      );

      IF x_return_status <> fnd_api.g_ret_sts_success
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
   --dbms_ourtput.put_line('Delete_Terrtype PVT: Exiting API');
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_ourtput.put_line('Delete_Terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO delete_territory_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Delete_Terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO delete_territory_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Delete_Terrtype PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO delete_territory_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
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
      p_validation_level     IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_id          IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   AS
      CURSOR c_getterrtype (l_terrtype_id NUMBER)
      IS
         SELECT ROWID,
                terr_type_id,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                last_update_login,
                application_short_name,
                name,
                enabled_flag,
                description,
                start_date_active,
                end_date_active,
                org_id,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
           FROM jtf_terr_types
          WHERE terr_type_id = l_terrtype_id
            FOR UPDATE NOWAIT;

      --Local variable declaration
      l_api_name           CONSTANT VARCHAR2(30) := 'Deactivate_TerrType';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_rowid                       VARCHAR2(50);
      l_return_status               VARCHAR2(1);
      l_ref_terrtype_rec            terrtype_rec_type;
   BEGIN
      --dbms_ourtput.put_line('De-Activate_Terrtype PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT deactivate_territory_pvt;

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
      -- Initialize API return status to SUCCESS
      x_return_status := fnd_api.g_ret_sts_success;
      --dbms_ourtput.put_line('De-Activate_Terrtype PVT: Before opening C_GetTerrType');
      OPEN c_getterrtype (p_terrtype_id);
      --
      --dbms_ourtput.put_line('Update_TerrType_Record PVT:Before fetch');
      FETCH c_getterrtype INTO l_rowid,
                               l_ref_terrtype_rec.terr_type_id,
                               l_ref_terrtype_rec.last_updated_by,
                               l_ref_terrtype_rec.last_update_date,
                               l_ref_terrtype_rec.created_by,
                               l_ref_terrtype_rec.creation_date,
                               l_ref_terrtype_rec.last_update_login,
                               l_ref_terrtype_rec.application_short_name,
                               l_ref_terrtype_rec.name,
                               l_ref_terrtype_rec.enabled_flag,
                               l_ref_terrtype_rec.description,
                               l_ref_terrtype_rec.start_date_active,
                               l_ref_terrtype_rec.end_date_active,
                               l_ref_terrtype_rec.org_id,
                               l_ref_terrtype_rec.attribute_category,
                               l_ref_terrtype_rec.attribute1,
                               l_ref_terrtype_rec.attribute2,
                               l_ref_terrtype_rec.attribute3,
                               l_ref_terrtype_rec.attribute4,
                               l_ref_terrtype_rec.attribute5,
                               l_ref_terrtype_rec.attribute6,
                               l_ref_terrtype_rec.attribute7,
                               l_ref_terrtype_rec.attribute8,
                               l_ref_terrtype_rec.attribute9,
                               l_ref_terrtype_rec.attribute10,
                               l_ref_terrtype_rec.attribute11,
                               l_ref_terrtype_rec.attribute12,
                               l_ref_terrtype_rec.attribute13,
                               l_ref_terrtype_rec.attribute14,
                               l_ref_terrtype_rec.attribute15;

      --
      IF (c_getterrtype%NOTFOUND)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            --dbms_ourtput.put_line('De-Activate Terrtype PVT: C_GetTerrType%NOTFOUND');
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
            fnd_message.set_token ('TABLE_NAME', 'JTF_TERR_TYPES');
            fnd_message.set_token ('PK_ID', TO_CHAR (p_terrtype_id));
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_getterrtype;
      --dbms_ourtput.put_line('De-Activate_Terrtype PVT: Before Calling JTF_TERR_TYPES_PKG.Update_Row');
      jtf_terr_types_pkg.update_row (
         x_rowid => l_rowid,
         x_terr_type_id => l_ref_terrtype_rec.terr_type_id,
         x_last_updated_by => l_ref_terrtype_rec.last_updated_by,
         x_last_update_date => l_ref_terrtype_rec.last_update_date,
         x_created_by => l_ref_terrtype_rec.created_by,
         x_creation_date => l_ref_terrtype_rec.creation_date,
         x_last_update_login => l_ref_terrtype_rec.last_update_login,
         x_application_short_name => g_app_short_name,
         x_name => l_ref_terrtype_rec.name,
         x_enabled_flag => 'N',
         x_description => l_ref_terrtype_rec.description,
         x_start_date_active => (SYSDATE - 1),
         x_end_date_active => (SYSDATE - 1),
         x_attribute_category => l_ref_terrtype_rec.attribute_category,
         x_attribute1 => l_ref_terrtype_rec.attribute1,
         x_attribute2 => l_ref_terrtype_rec.attribute2,
         x_attribute3 => l_ref_terrtype_rec.attribute3,
         x_attribute4 => l_ref_terrtype_rec.attribute4,
         x_attribute5 => l_ref_terrtype_rec.attribute5,
         x_attribute6 => l_ref_terrtype_rec.attribute6,
         x_attribute7 => l_ref_terrtype_rec.attribute7,
         x_attribute8 => l_ref_terrtype_rec.attribute8,
         x_attribute9 => l_ref_terrtype_rec.attribute9,
         x_attribute10 => l_ref_terrtype_rec.attribute10,
         x_attribute11 => l_ref_terrtype_rec.attribute11,
         x_attribute12 => l_ref_terrtype_rec.attribute12,
         x_attribute13 => l_ref_terrtype_rec.attribute13,
         x_attribute14 => l_ref_terrtype_rec.attribute14,
         x_attribute15 => l_ref_terrtype_rec.attribute15,
         x_org_id => l_ref_terrtype_rec.org_id
      );
      x_return_status := fnd_api.g_ret_sts_success;

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
   --dbms_ourtput.put_line('De-Activate_Terrtype PVT: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_ourtput.put_line('De-Activate_Terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO deactivate_territory_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('De-Activate_Terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO deactivate_territory_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('De-Activate_Terrtype PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO deactivate_territory_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Deactivate_TerrType' || SQLERRM
            );
         END IF;
   END deactivate_terrtype;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Copy_TerrType
--    type           : public.
--    function       : Copy_territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :
--
--    in:
--        p_api_version_number   in  number               required
--        p_init_msg_list        in  varchar2             optional --default = fnd_api.g_false
--        p_commit               in  varchar2             optional --default = fnd_api.g_false
--        p_TerrType_id          in  number
--        p_TerrType_Name        in  varchar2
--        p_Start_Date           in  date
--        p_End_Date             in  date
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
--    notes:              API for Copying territory types
--
-- end of comments
   PROCEDURE copy_terrtype (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_id            IN       NUMBER,
      p_terrtype_name          IN       VARCHAR2,
      p_terrtype_description   IN       VARCHAR2,
      p_enabled_flag           IN       VARCHAR2,
      p_start_date             IN       DATE,
      p_end_date               IN       DATE,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtype_id            OUT NOCOPY      NUMBER
   )
   AS
      --Declare cursor to get Terr Qualifier
      CURSOR c_getterrtypequal
      IS
         SELECT jtq.terr_type_qual_id,
                jtq.last_update_date,
                jtq.last_updated_by,
                jtq.creation_date,
                jtq.created_by,
                jtq.last_update_login,
                jtq.qual_usg_id,
                jtq.terr_type_id,
                jtq.exclusive_use_flag,
                jtq.overlap_allowed_flag,
                jtq.in_use_flag,
                jtq.qualifier_mode,
                jtq.org_id
           FROM jtf_terr_type_qual jtq
          WHERE jtq.terr_type_id = p_terrtype_id
            FOR UPDATE;

      --Declare cursor to get qualifiers Type usages
      CURSOR c_gettypequaltypeusgs
      IS
         SELECT jtqu.type_qtype_usg_id,
                jtqu.terr_type_id,
                jtqu.qual_type_usg_id,
                jtqu.last_update_date,
                jtqu.last_updated_by,
                jtqu.creation_date,
                jtqu.created_by,
                jtqu.last_update_login,
                jtqu.org_id
           FROM jtf_type_qtype_usgs jtqu
          WHERE jtqu.terr_type_id = p_terrtype_id
            FOR UPDATE;

      --Declare cursor to get Terr Usages
      CURSOR c_getterrtypeusgs
      IS
         SELECT jtu.terr_type_usg_id,
                jtu.source_id,
                jtu.terr_type_id,
                jtu.last_update_date,
                jtu.last_updated_by,
                jtu.creation_date,
                jtu.created_by,
                jtu.last_update_login,
                jtu.org_id
           FROM jtf_terr_type_usgs jtu
          WHERE jtu.terr_type_id = p_terrtype_id
            FOR UPDATE;

      l_api_name           CONSTANT VARCHAR2(30) := 'Copy_Territory_Type';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_terrtypeusg_id              NUMBER;
      l_terrtype_id                 NUMBER;
      l_terrtype_rec                terrtype_rec_type;
      l_terrtypeusgs_rec            terrtypeusgs_rec_type;
      l_terrtypeusgs_tbl            terrtypeusgs_tbl_type;
      l_typequaltypeusgs_tbl        typequaltypeusgs_tbl_type;
      l_typequaltypeusgs_rec        typequaltypeusgs_rec_type;
      l_terrtypequal_rec            terrtypequal_rec_type;
      l_terrtypequal_tbl            terrtypequal_tbl_type;
      l_terrtype_out_rec            terrtype_out_rec_type;
      l_terrtypeusgs_out_tbl        terrtypeusgs_out_tbl_type;
      l_typequaltypeusgs_out_tbl    typequaltypeusgs_out_tbl_type;
      l_terrtypequal_out_tbl        terrtypequal_out_tbl_type;
      l_counter                     NUMBER := 0;
   BEGIN
--
      --dbms_output.put_line('Copy_Terrtype PVT: Entering API - ' || p_enabled_flag);

      -- Standard Start of API savepoint
      SAVEPOINT copy_terrtype_pvt;

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
      -- Save the old record in the record type
      SELECT terr_type_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             application_short_name,
             name,
             enabled_flag,
             start_date_active,
             end_date_active,
             description,
             org_id,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15
        INTO l_terrtype_rec.terr_type_id,
             l_terrtype_rec.last_update_date,
             l_terrtype_rec.last_updated_by,
             l_terrtype_rec.creation_date,
             l_terrtype_rec.created_by,
             l_terrtype_rec.last_update_login,
             l_terrtype_rec.application_short_name,
             l_terrtype_rec.name,
             l_terrtype_rec.enabled_flag,
             l_terrtype_rec.start_date_active,
             l_terrtype_rec.end_date_active,
             l_terrtype_rec.description,
             l_terrtype_rec.org_id,
             l_terrtype_rec.attribute_category,
             l_terrtype_rec.attribute1,
             l_terrtype_rec.attribute2,
             l_terrtype_rec.attribute3,
             l_terrtype_rec.attribute4,
             l_terrtype_rec.attribute5,
             l_terrtype_rec.attribute6,
             l_terrtype_rec.attribute7,
             l_terrtype_rec.attribute8,
             l_terrtype_rec.attribute9,
             l_terrtype_rec.attribute10,
             l_terrtype_rec.attribute11,
             l_terrtype_rec.attribute12,
             l_terrtype_rec.attribute13,
             l_terrtype_rec.attribute14,
             l_terrtype_rec.attribute15
        FROM jtf_terr_types
       WHERE terr_type_id = p_terrtype_id;
      l_terrtype_rec.terr_type_id := NULL;
      l_terrtype_rec.name := p_terrtype_name;
      l_terrtype_rec.description := p_terrtype_description;
      l_terrtype_rec.enabled_flag := p_enabled_flag;
      l_terrtype_rec.start_date_active := p_start_date;
      l_terrtype_rec.end_date_active := p_end_date;
      -- Create Territory Record
      --dbms_output.put_line('Copy_Terrtype PVT: Before calling  Copy_TerrType_Record');
      create_terrtype_record (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_rec => l_terrtype_rec,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtype_id => l_terrtype_id,
         x_terrtype_out_rec => l_terrtype_out_rec
      );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --dbms_output.put_line('Before opening C_GetTerrTypeUsgs l_TerrType_Id - ' || l_TerrType_Id);

      -- Create Territory Type Usage
      OPEN c_getterrtypeusgs;
      FETCH c_getterrtypeusgs INTO l_terrtypeusgs_rec;

      --dbms_output.put_line('TERR_TYPE_USG_ID - ' ||  to_char(l_TerrTypeUsgs_Rec.TERR_TYPE_USG_ID) );
      WHILE c_getterrtypeusgs%FOUND
      LOOP
         --
         --dbms_output.put_line('Inside while LOOP Create_terrtype PVT: Create_TerrType_Usages');
         l_terrtypeusgs_rec.terr_type_usg_id := NULL;
         l_counter := l_counter + 1;
         l_terrtypeusgs_tbl (l_counter) := l_terrtypeusgs_rec;
         --fetche the next record
         FETCH c_getterrtypeusgs INTO l_terrtypeusgs_rec;
      --

      END LOOP;

      CLOSE c_getterrtypeusgs;
      --dbms_output.put_line('Create_terrtype PVT: Before Calling Create_TerrType_Usages PVT');
      create_terrtype_usages (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_id => l_terrtype_id,
         p_terrtypeusgs_tbl => l_terrtypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtypeusgs_out_tbl => l_terrtypeusgs_out_tbl
      );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      l_terrtypeusg_id := l_terrtypeusgs_out_tbl (1).terr_type_usg_id;
      --
      --dbms_output.put_line('Before opening C_GetTypeQualTypeUsgs');
      l_counter := 0;
      OPEN c_gettypequaltypeusgs;
      FETCH c_gettypequaltypeusgs INTO l_typequaltypeusgs_rec;

      WHILE c_gettypequaltypeusgs%FOUND
      LOOP
         --
         --dbms_output.put_line('Inside while LOOP Create_terrtype PVT: C_GetTypeQualTypeUsgs');
         l_counter := l_counter + 1;
         l_typequaltypeusgs_rec.type_qual_type_usg_id := NULL;
         l_typequaltypeusgs_tbl (l_counter) := l_typequaltypeusgs_rec;
         --fetch the next record
         FETCH c_gettypequaltypeusgs INTO l_typequaltypeusgs_rec;
      --

      END LOOP;

      CLOSE c_gettypequaltypeusgs;
      --
      --  Call api to insert records into jtf_terr_qualtype_usgs
      --
      --dbms_output.put_line('Create_terrtype PVT: Before Calling Create_TerrTypeQualType_Usage PVT');
      create_terrtypequaltype_usage (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_id => l_terrtype_id,
         p_terrtypeusg_id => l_terrtypeusg_id,
         p_typequaltypeusgs_tbl => l_typequaltypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_typequaltypeusgs_out_tbl => l_typequaltypeusgs_out_tbl
      );

      --
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --dbms_output.put_line('Before opening C_GetTerrTypeQual');
      l_counter := 0;
      OPEN c_getterrtypequal;
      FETCH c_getterrtypequal INTO l_terrtypequal_rec;

      WHILE c_getterrtypequal%FOUND
      LOOP
         --
         --dbms_output.put_line('Inside while LOOP Create_terrtype PVT: C_GetTerrTypeQual');
         l_counter := l_counter + 1;
         l_terrtypequal_rec.terr_type_qual_id := NULL;
         l_terrtypequal_tbl (l_counter) := l_terrtypequal_rec;
         FETCH c_getterrtypequal INTO l_terrtypequal_rec;
      --

      END LOOP;

      CLOSE c_getterrtypequal;
      --dbms_output.put_line('create_terrtype PVT: Before Calling Create_TerrType_Qualifier PVT');
      create_terrtype_qualifier (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_id => l_terrtype_id,
         p_terrtypequal_tbl => l_terrtypequal_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtypequal_out_tbl => l_terrtypequal_out_tbl
      );

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

      -- If Copy was successfull move the new territory type id to o/p parameter
      x_terrtype_id := l_terrtype_id;
   --dbms_output.put_line('Copy_Terrtype PVT: Exiting API');
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('Copy_Terrtype PVT: FND_API.G_EXC_ERROR' || SQLERRM);
         ROLLBACK TO copy_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('Copy_Terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR' || SQLERRM);
         ROLLBACK TO copy_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Copy_Terrtype PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO copy_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END copy_terrtype;

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_Header
--    Type      : PUBLIC
--    Function  : To create Territories Types - which inludes the creation of following
--                Territory Type Header, Territory Type Usages, Territory Type qualifier
--                type usages table.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Api_Version_Number          NUMBER
--      P_TerrType_Rec                TerrType_Rec_Type                := G_Miss_TerrType_Rec
--      P_TerrTypeUsgs_Tbl            TerrTypeusgs_Tbl_Type            := G_MISS_TerrTypeusgs_Tbl
--      P_TypeQualTypeUsgs_Tbl        TypeQualTypeUsgs_Tbl_Type        := G_Miss_TypeQualTypeUsgs_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      P_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      P_Commit                      VARCHAR2                         := FND_API.G_FALSE
--      p_validation_level            NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Msg_Count                   NUMBER
--      X_Msg_Data                    VARCHAR2(2000)
--      X_TerrType_Out_Rec            TerrType_Out_Rec_Type
--      X_TerrTypeusgs_Out_Tbl        TerrTypeusgs_Out_Tbl_Type
--      X_TypeQualTypeUsgs_Out_Tbl    TypeQualTypeUsgs_Out_Tbl_Type
--
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_terrtype_header (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN       NUMBER   := fnd_api.g_valid_level_full,
      p_terrtype_rec               IN       terrtype_rec_type := g_miss_terrtype_rec,
      p_terrtypeusgs_tbl           IN       terrtypeusgs_tbl_type := g_miss_terrtypeusgs_tbl,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_terrtype_out_rec           OUT NOCOPY      terrtype_out_rec_type,
      x_terrtypeusgs_out_tbl       OUT NOCOPY      terrtypeusgs_out_tbl_type,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   AS
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_TerrType_Header';
      l_rowid                       ROWID;
      l_return_status               VARCHAR2(1);
      l_terrtype_id                 NUMBER;
      l_terrtypeusg_id              NUMBER;
      l_typequaltypeusg_id          NUMBER;
      l_terrtypeusgs_tbl_count      NUMBER := p_terrtypeusgs_tbl.COUNT;
      l_typequaltypeusgs_tbl_count  NUMBER := p_typequaltypeusgs_tbl.COUNT;
      l_counter                     NUMBER;
      l_terrtype_out_rec            terrtype_out_rec_type;
      l_terrtypeusgs_out_tbl        terrtypeusgs_out_tbl_type;
      l_typequaltypeusgs_out_tbl    typequaltypeusgs_out_tbl_type;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrType_Header PVT: Entering API');

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --dbms_ourtput.put_line('Create_terrtype PVT: Before Calling Create_TerrType_Record PVT');
      -- Call create_territory_record API
      create_terrtype_record (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_rec => p_terrtype_rec,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtype_id => l_terrtype_id,
         x_terrtype_out_rec => l_terrtype_out_rec
      );
      --
      -- Save the statuses
      x_return_status := l_return_status;
      --
      --Save the out status record
      x_terrtype_out_rec := l_terrtype_out_rec;

      --If there is a major error
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --
      --dbms_ourtput.put_line('Create_terrtype PVT: Before Calling Create_TerrType_Usages PVT');
      create_terrtype_usages (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_id => l_terrtype_id,
         p_terrtypeusgs_tbl => p_terrtypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_terrtypeusgs_out_tbl => l_terrtypeusgs_out_tbl
      );
      --
      -- Save the statuses
      x_return_status := l_return_status;
      --
      --Save the out status record
      x_terrtypeusgs_out_tbl := l_terrtypeusgs_out_tbl;
      l_terrtypeusg_id := l_terrtypeusgs_out_tbl (1).terr_type_usg_id;

      --
      --If there is a major error
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --  Call api to insert records into jtf_terr_qualtype_usgs
      --
      --dbms_ourtput.put_line('Create_terrtype PVT: Before Calling Create_TerrTypeQualType_Usage PVT');
      create_terrtypequaltype_usage (
         p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_validation_level => p_validation_level,
         p_terrtype_id => l_terrtype_id,
         p_terrtypeusg_id => l_terrtypeusg_id,
         p_typequaltypeusgs_tbl => p_typequaltypeusgs_tbl,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_typequaltypeusgs_out_tbl => l_typequaltypeusgs_out_tbl
      );
      --
      -- Save the statuses
      x_return_status := l_return_status;
      --
      --Save the out status record
      x_typequaltypeusgs_out_tbl := l_typequaltypeusgs_out_tbl;

      --If there is a major error
      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'Create TerrType Header: End');
         fnd_msg_pub.add;
      END IF;
   --dbms_ourtput.put_line('Create_TerrType_Header PVT: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_ourtput.put_line('Create_TerrType_Header PVT: FND_API.G_EXC_ERROR');
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Create_TerrType_Header PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Create_TerrType_Header PVT: OTHERS - ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside create_terrtype_header ' || sqlerrm);
         END IF;
   END create_terrtype_header;

--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_record
--    Type      : PUBLIC
--    Function  : To create a records in jtf_Terr_Type_all table
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                         Default
--      X_TerrType_Rec                TerrType_Rec_Type                 := G_Miss_TerrType_Rec,
--
--     OUT     :
--      Parameter Name                Data Type
--      X_terr_id                     NUMBER;
--      X_Return_Status               VARCHAR2(1)
--      X_TerrType_Out_Rec            TerrType_Out_Rec_Type
--
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_terrtype_record (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level     IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_rec         IN       terrtype_rec_type := g_miss_terrtype_rec,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_terrtype_id          OUT NOCOPY      NUMBER,
      x_terrtype_out_rec     OUT NOCOPY      terrtype_out_rec_type
   )
   AS
      l_rowid                       ROWID;
      l_terrtype_id                 NUMBER := P_TERRTYPE_REC.TERR_TYPE_ID;
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_TerrType_Record';
      l_api_version_number CONSTANT NUMBER := 1.0;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrType_Record PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terr_rec_pvt;

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

      -- VAalidate
      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
         -- Debug message
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
            fnd_message.set_token ('PROC_NAME', 'Validate_TerrType_Record');
            fnd_msg_pub.add;
         END IF;

         --
         -- Invoke validation procedures
         validate_terrtype_record (
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_terr_type_rec => p_terrtype_rec
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --Intialize the application short name
      g_app_short_name := fnd_global.application_short_name;

      /* Intialise to NULL if FND_API.G_MISS_NUM,
      ** otherwise used passed in value
      */
      IF (l_terrtype_id = FND_API.G_MISS_NUM) THEN
        l_terrtype_id := NULL;
      END IF;

      --dbms_output.put_line('Value of l_terrtype_id='||TO_CHAR(l_terrtype_id));

      -- Call insert terr_all table handler
      --dbms_ourtput.put_line('Create_TerrType_Record PVT: Before calling JTF_TERR_TYPES_PKG.Insert_Row');
      jtf_terr_types_pkg.insert_row (
         x_rowid => l_rowid,
         x_terr_type_id => l_terrtype_id,
         x_last_updated_by => p_terrtype_rec.last_updated_by,
         x_last_update_date => p_terrtype_rec.last_update_date,
         x_created_by => p_terrtype_rec.created_by,
         x_creation_date => p_terrtype_rec.creation_date,
         x_last_update_login => p_terrtype_rec.last_update_login,
         x_application_short_name => p_terrtype_rec.application_short_name,
         x_name => p_terrtype_rec.name,
         x_enabled_flag => p_terrtype_rec.enabled_flag,
         x_description => p_terrtype_rec.description,
         x_start_date_active => p_terrtype_rec.start_date_active,
         x_end_date_active => p_terrtype_rec.end_date_active,
         x_attribute_category => p_terrtype_rec.attribute_category,
         x_attribute1 => p_terrtype_rec.attribute1,
         x_attribute2 => p_terrtype_rec.attribute2,
         x_attribute3 => p_terrtype_rec.attribute3,
         x_attribute4 => p_terrtype_rec.attribute4,
         x_attribute5 => p_terrtype_rec.attribute5,
         x_attribute6 => p_terrtype_rec.attribute6,
         x_attribute7 => p_terrtype_rec.attribute7,
         x_attribute8 => p_terrtype_rec.attribute8,
         x_attribute9 => p_terrtype_rec.attribute9,
         x_attribute10 => p_terrtype_rec.attribute10,
         x_attribute11 => p_terrtype_rec.attribute11,
         x_attribute12 => p_terrtype_rec.attribute12,
         x_attribute13 => p_terrtype_rec.attribute13,
         x_attribute14 => p_terrtype_rec.attribute14,
         x_attribute15 => p_terrtype_rec.attribute15,
         x_org_id => p_terrtype_rec.org_id
      );
      x_terrtype_out_rec.terr_type_id := l_terrtype_id;
      x_terrtype_id := l_terrtype_id;
      x_terrtype_out_rec.return_status := fnd_api.g_ret_sts_success;

      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   --dbms_ourtput.put_line('Create_TerrType_Record PVT: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('HELLO create_terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO create_terr_rec_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO create_terr_rec_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Create_TerrType_Record PVT: OTHERS - ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO create_terr_rec_pvt;
         x_terrtype_out_rec.return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Insert_Territory_Type_Record'
            );
         END IF;
   END create_terrtype_record;

--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_Usages
--    Type      : PUBLIC
--    Function  : To create Territories Type usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER;
--      P_TerrTypeUsgs_Tbl            TerrTypeUsgs_Tbl_Type            := G_MISS_TerrTypeUsgs_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrTypeUsgs_Out_Tbl        TerrTypeUsgs_Out_Tbl,
--
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_terrtype_usages (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_id            IN       NUMBER,
      p_terrtypeusgs_tbl       IN       terrtypeusgs_tbl_type
            := g_miss_terrtypeusgs_tbl,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypeusgs_out_tbl   OUT NOCOPY      terrtypeusgs_out_tbl_type
   )
   AS
      l_rowid                       ROWID;
      l_terrtypeusg_id              NUMBER;
      l_terrtypeusgs_tbl_count      NUMBER := p_terrtypeusgs_tbl.COUNT;
      l_terrtypeusgs_out_tbl_count  NUMBER;
      l_terrtypeusgs_out_tbl        terrtypeusgs_out_tbl_type;
      l_counter                     NUMBER;
      l_api_name           CONSTANT VARCHAR2(30) := 'Create_TerrType_Usages';
      l_api_version_number CONSTANT NUMBER := 1.0;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrType_Usages PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terr_type_usg_pvt;

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

      FOR l_counter IN 1 .. l_terrtypeusgs_tbl_count
      LOOP
         --
         BEGIN
            -- dbms_ourtput.put_line('Create_TerrType_Usages PVT: Inside Loop JTF_TERR_TYPE_USGS_PKG.Insert_Row');
            -- Initialize API return status to success
            x_return_status := fnd_api.g_ret_sts_success;

            IF (p_validation_level >= fnd_api.g_valid_level_full)
            THEN
               -- Debug message
               IF fnd_msg_pub.check_msg_level (
                     fnd_msg_pub.g_msg_lvl_debug_low
               )
               THEN
                  fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
                  fnd_message.set_token ('PROC_NAME', 'Validate_TerrType_Usage');
                  fnd_msg_pub.add;
               END IF;

               --
               -- Invoke validation procedures
               validate_terrtype_usage (
                  p_init_msg_list => fnd_api.g_false,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_terr_type_id => p_terrtype_id,
                  p_terrtypeusgs_rec => p_terrtypeusgs_tbl (l_counter)
               );

               --
               IF x_return_status <> fnd_api.g_ret_sts_success
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            --

            END IF;

            l_terrtypeusg_id := p_terrtypeusgs_tbl (l_counter).terr_type_usg_id;

            /* Intialise to NULL if FND_API.G_MISS_NUM,
            ** otherwise used passed in value
            */
            IF (l_terrtypeusg_id = FND_API.G_MISS_NUM) THEN
               l_terrtypeusg_id := NULL;
            END IF;

            --
            jtf_terr_type_usgs_pkg.insert_row (
               x_rowid => l_rowid,
               x_terr_type_usg_id => l_terrtypeusg_id,
               x_last_update_date => p_terrtypeusgs_tbl (l_counter).last_update_date,
               x_last_updated_by => p_terrtypeusgs_tbl (l_counter).last_updated_by,
               x_creation_date => p_terrtypeusgs_tbl (l_counter).creation_date,
               x_created_by => p_terrtypeusgs_tbl (l_counter).created_by,
               x_last_update_login => p_terrtypeusgs_tbl (l_counter).last_update_login,
               x_terr_type_id => p_terrtype_id,
               x_source_id => p_terrtypeusgs_tbl (l_counter).source_id,
               x_org_id => p_terrtypeusgs_tbl (l_counter).org_id
            );
            -- Save the terr_usg_id and
            x_terrtypeusgs_out_tbl (l_counter).terr_type_usg_id :=
               l_terrtypeusg_id;

            -- If successful then save the success status for the record
            x_terrtypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_success;
         EXCEPTION
            WHEN OTHERS
            THEN
               --dbms_ourtput.put_line('Create_TerrType_Usages PVT:Inside LOOP OTHERS - ' || SQLERRM);
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               x_terrtypeusgs_out_tbl (l_counter).terr_type_usg_id := NULL;
               x_terrtypeusgs_out_tbl (l_counter).return_status :=
                  x_return_status;

               IF fnd_msg_pub.check_msg_level (
                     fnd_msg_pub.g_msg_lvl_unexp_error
               )
               THEN
                  fnd_msg_pub.add_exc_msg (
                     g_pkg_name,
                     'Others exception in Insert_Territory_Type_Usages'
                  );
               END IF;
         END;
      --

      END LOOP;

      --Get the API overall return status
      x_return_status := fnd_api.g_ret_sts_success;
      --Get number of records in the ouput table
      l_terrtypeusgs_out_tbl_count := x_terrtypeusgs_out_tbl.COUNT;
      l_terrtypeusgs_out_tbl := x_terrtypeusgs_out_tbl;

      FOR l_counter IN 1 .. l_terrtypeusgs_out_tbl_count
      LOOP
         IF    l_terrtypeusgs_out_tbl (l_counter).return_status =
                  fnd_api.g_ret_sts_unexp_error
            OR l_terrtypeusgs_out_tbl (l_counter).return_status =
                  fnd_api.g_ret_sts_error
         THEN
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      --
      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   --
   --dbms_ourtput.put_line('Create_TerrType_Usages PVT: Exiting API');
   --

   END create_terrtype_usages;

--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrTypeQualType_Usage
--    Type      : PUBLIC
--    Function  : To create Territory type qualifier type
--                usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      p_terr_usg_id                 NUMBER;
--      P_Terr_QualTypeUsgs_Rec       Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_terrtypequaltype_usage (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN       NUMBER   := fnd_api.g_valid_level_full,
      p_terrtype_id                IN       NUMBER,
      p_terrtypeusg_id             IN       NUMBER,
      p_typequaltypeusgs_rec       IN       typequaltypeusgs_rec_type := g_miss_typequaltypeusgs_rec,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_typequaltypeusgs_id        OUT NOCOPY      NUMBER,
      x_typequaltypeusgs_out_rec   OUT NOCOPY      typequaltypeusgs_out_rec_type
   )
   AS
      l_rowid                       ROWID;
      l_typequaltype_usg_id         NUMBER := p_typequaltypeusgs_rec.type_qual_type_usg_id;
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Create_TerrTypeQualType_Usage';
      l_api_version_number CONSTANT NUMBER := 1.0;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage REC: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_type_qtype_usg_pvt;

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

      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
         -- Debug message
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
            fnd_message.set_token ('PROC_NAME', 'Validate_Territory_Usage');
            fnd_msg_pub.add;
         END IF;

         -- Invoke validation procedures
         validate_type_qtype_usage (
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_terr_type_id => p_terrtype_id,
            p_type_qualtypeusgs_rec => p_typequaltypeusgs_rec
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --
      --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage REC: Calling JTF_TYPE_QTYPE_USGS_PKG.Insert_Row');

      /* Intialise to NULL if FND_API.G_MISS_NUM,
      ** otherwise used passed in value
      */
      IF (l_typequaltype_usg_id = FND_API.G_MISS_NUM) THEN
          l_typequaltype_usg_id := NULL;
      END IF;

      -- Call insert terr_Qual_Type_Usgs table handler
      jtf_type_qtype_usgs_pkg.insert_row (
         x_rowid => l_rowid,
         x_type_qtype_usg_id => l_typequaltype_usg_id,
         x_last_updated_by => p_typequaltypeusgs_rec.last_updated_by,
         x_last_update_date => p_typequaltypeusgs_rec.last_update_date,
         x_created_by => p_typequaltypeusgs_rec.created_by,
         x_creation_date => p_typequaltypeusgs_rec.creation_date,
         x_last_update_login => p_typequaltypeusgs_rec.last_update_login,
         x_terr_type_id => p_terrtype_id,
         x_qual_type_usg_id => p_typequaltypeusgs_rec.qual_type_usg_id,
         x_org_id => p_typequaltypeusgs_rec.org_id
      );
      -- Save the typequaltype_usg_id
      x_typequaltypeusgs_id := l_typequaltype_usg_id;
      -- Save the terr_usg_id and
      x_typequaltypeusgs_out_rec.type_qual_type_usg_id :=
         l_typequaltype_usg_id;
      -- If successful then save the success status for the record
      x_typequaltypeusgs_out_rec.return_status := fnd_api.g_ret_sts_success;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage REC: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO create_type_qtype_usg_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO create_type_qtype_usg_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage REC: OTHERS - ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --
         ROLLBACK TO create_type_qtype_usg_pvt;
         x_typequaltypeusgs_out_rec.type_qual_type_usg_id := NULL;
         x_typequaltypeusgs_out_rec.return_status := x_return_status;

         --
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Create_TerrTypeQualType_Usage' || SQLERRM
            );
         END IF;
--

   END create_terrtypequaltype_usage;

--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrTypeQualType_Usage
--    Type      : PUBLIC
--    Function  : To create Territories type qualifier usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrType_Id                 NUMBER
--      P_TerrTypeUsg_Id              NUMBER;
--      P_TypeQualTypeUsgs_Tbl        TypeQualTypeUsgs_Tbl_Type       := G_Miss_TypeQualTypeUsgs_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TypeQualTypeUsgs_Out_Tbl    TypeQualTypeUsgs_Out_Tbl,
--
--    Notes:
--
--
--    End of Comments
--
   PROCEDURE create_terrtypequaltype_usage (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN       NUMBER
            := fnd_api.g_valid_level_full,
      p_terrtype_id                IN       NUMBER,
      p_terrtypeusg_id             IN       NUMBER,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type
            := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   AS
      l_rowid                       ROWID;
      l_return_status               VARCHAR2(1);
      l_typequaltypeusg_id          NUMBER;
      l_typequaltypeusgs_tbl_count  NUMBER := p_typequaltypeusgs_tbl.COUNT;
      l_typeqtypusg_out_tbl_count   NUMBER;
      l_typequaltypeusgs_out_rec    typequaltypeusgs_out_rec_type;
      l_typequaltypeusgs_out_tbl    typequaltypeusgs_out_tbl_type;
      l_counter                     NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Create_Terr_Qualtype_Usage';
      l_api_version_number CONSTANT NUMBER := 1.0;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage TBL: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terr_qtype_usg_pvt;

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

      -- Call insert terr_Qual_Type_Usgs table handler
      FOR l_counter IN 1 .. l_typequaltypeusgs_tbl_count
      LOOP
         --
         --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage TBL: Before Calling Create_TerrTypeQualType_Usage');
         create_terrtypequaltype_usage (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            p_terrtype_id => p_terrtype_id,
            p_terrtypeusg_id => p_terrtypeusg_id,
            p_typequaltypeusgs_rec => p_typequaltypeusgs_tbl (l_counter),
            x_typequaltypeusgs_id => l_typequaltypeusg_id,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_typequaltypeusgs_out_rec => l_typequaltypeusgs_out_rec
         );

         --
         --If there is a major error
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_typequaltypeusgs_out_tbl (l_counter).type_qual_type_usg_id :=
               NULL;
            -- If save the ERROR status for the record
            x_typequaltypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_unexp_error;
         ELSE
            --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_typequaltypeusgs_out_tbl (l_counter).type_qual_type_usg_id :=
               l_typequaltypeusg_id;

            -- If successful then save the success status for the record
            x_typequaltypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_success;
         END IF;
      --

      END LOOP;

      --Get the API overall return status
      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --Get number of records in the ouput table
      l_typequaltypeusgs_tbl_count := x_typequaltypeusgs_out_tbl.COUNT;
      l_typequaltypeusgs_out_tbl := x_typequaltypeusgs_out_tbl;

      FOR l_counter IN 1 .. l_typequaltypeusgs_tbl_count
      LOOP
         IF    l_typequaltypeusgs_out_tbl (l_counter).return_status =
                  fnd_api.g_ret_sts_unexp_error OR
               l_typequaltypeusgs_out_tbl (l_counter).return_status =
                  fnd_api.g_ret_sts_error
         THEN
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   --dbms_ourtput.put_line('Create_TerrTypeQualType_Usage TBL: Exiting API');
   --

   END create_terrtypequaltype_usage;

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_QualIfier
--    Type      : PUBLIC
--    Function  : To create Territories qualifier
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terrType_id                 NUMBER
--      P_TerrTypeQual_Rec            TerrTypeQual_Rec_Type               := G_Miss_TerrTypeQual_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_TerrTypeQual_Id             NUMBER
--      X_Return_Status               VARCHAR2(1)
--      X_TerrTypeQual_Out_Rec        TerrTypeQual_Out_Rec
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--
   PROCEDURE create_terrtype_qualifier (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_id            IN       NUMBER,
      p_terrtypequal_rec       IN       terrtypequal_rec_type := g_miss_terrtypequal_rec,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypequal_id        OUT NOCOPY      NUMBER,
      x_terrtypequal_out_rec   OUT NOCOPY      terrtypequal_out_rec_type
   )
   AS
      l_rowid                       ROWID;
      l_terrtypequal_id             NUMBER := p_terrtypequal_rec.terr_type_qual_id;
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Create_TerrType_Qualifier';
      l_api_version_number CONSTANT NUMBER := 1.0;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrType_Qualifier REC: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terr_type_qual_pvt;

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

      -- Check the validation level
      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
         -- Debug message
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
            fnd_message.set_token ('PROC_NAME', 'validate_qualifier');
            fnd_msg_pub.add;
         END IF;

         --
         -- Invoke validation procedures
         validate_qualifier (
            p_init_msg_list => fnd_api.g_false,
            p_terrtypequal_rec => p_terrtypequal_rec,
            p_terr_type_id => p_terrtype_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_output.put_line('Validate_Qualifier Procedure failed');
            RAISE fnd_api.g_exc_error;
         END IF;
      --

      END IF;

      /* Intialise to NULL if FND_API.G_MISS_NUM,
      ** otherwise used passed in value
      */
      IF (l_terrtypequal_id = FND_API.G_MISS_NUM) THEN
          l_terrtypequal_id := NULL;
      END IF;

      -- Call insert terrtype_Qualifier table handler
      --dbms_ourtput.put_line('Create_TerrType_Qualifier REC: JTF_TERR_TYPE_QUAL_PKG.Insert_Row');
      jtf_terr_type_qual_pkg.insert_row (
         x_rowid => l_rowid,
         x_terr_type_qual_id => l_terrtypequal_id,
         x_last_update_date => p_terrtypequal_rec.last_update_date,
         x_last_updated_by => p_terrtypequal_rec.last_updated_by,
         x_creation_date => p_terrtypequal_rec.creation_date,
         x_created_by => p_terrtypequal_rec.created_by,
         x_last_update_login => p_terrtypequal_rec.last_update_login,
         x_terr_type_id => p_terrtype_id,
         x_qual_usg_id => p_terrtypequal_rec.qual_usg_id,
         x_in_use_flag => p_terrtypequal_rec.in_use_flag,
         x_exclusive_use_flag => p_terrtypequal_rec.exclusive_use_flag,
         x_overlap_allowed_flag => p_terrtypequal_rec.overlap_allowed_flag,
         x_qualifier_mode => p_terrtypequal_rec.qualifier_mode,
         x_org_id => p_terrtypequal_rec.org_id
      );
      --
      -- Save the terr_qual_id returned by the table handler
      x_terrtypequal_id := l_terrtypequal_id;

      -- Save the terr_usg_id and
      x_terrtypequal_out_rec.terr_type_qual_id := l_terrtypequal_id;

      -- If successful then save the success status for the record
      x_terrtypequal_out_rec.return_status := fnd_api.g_ret_sts_success;

      --
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      --dbms_ourtput.put_line('Create_TerrType_Qualifier PVT: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line('GOODBYE create_terrtype PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO create_terr_type_qual_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO create_terr_type_qual_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line('Create_TerrType_Qualifier PVT: OTHERS - ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO create_terr_type_qual_pvt;
         --
         x_terrtypequal_out_rec.terr_type_qual_id := NULL;
         x_terrtypequal_out_rec.return_status := x_return_status;

         --
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error create_terrtype_qualifier ' || SQLERRM
            );
         END IF;
--

   END create_terrtype_qualifier;

--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_Qualifier
--    Type      : PUBLIC
--    Function  : To create Territories type qualifier
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terrType_id                 NUMBER
--      P_TerrTypeQual_Tbl            TerrTypeQual_Tbl_Type               := G_Miss_TerrTypeQual_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrTypeQual_Out_Tbl        TerrTypeQual_Out_Tbl
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--
   PROCEDURE create_terrtype_qualifier (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_id            IN       NUMBER,
      p_terrtypequal_tbl       IN       terrtypequal_tbl_type := g_miss_terrtypequal_tbl,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypequal_out_tbl   OUT NOCOPY      terrtypequal_out_tbl_type
   )
   AS
      --l_rowid                     ROWID;
      l_terrtypequal_id             NUMBER;
      l_return_status               VARCHAR2(1);
      l_terrtypequal_tbl_count      NUMBER := p_terrtypequal_tbl.COUNT;
      l_terrtypequal_out_tbl_count  NUMBER;
      l_terrtypequal_out_tbl        terrtypequal_out_tbl_type;
      l_terrtypequal_out_rec        terrtypequal_out_rec_type;
      l_counter                     NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Create_TerrType_Qualifier';
      l_api_version_number CONSTANT NUMBER := 1.0;
   BEGIN
      --dbms_ourtput.put_line('Create_TerrType_Qualifier TBL: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT create_terr_qual_pvt;

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
         fnd_message.set_name ('JTF', 'Create_Type_Qual PVT: Start');
         fnd_msg_pub.add;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- Call overloaded Create_Terr_Qualifier procedure
      --
      FOR l_counter IN 1 .. l_terrtypequal_tbl_count
      LOOP
         --
         --dbms_ourtput.put_line('Create_TerrType_Qualifier TBL: Before Calling Create_TerrType_Qualifier');
         create_terrtype_qualifier (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            p_terrtype_id => p_terrtype_id,
            p_terrtypequal_rec => p_terrtypequal_tbl (l_counter),
            x_terrtypequal_id => l_terrtypequal_id,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_terrtypequal_out_rec => l_terrtypequal_out_rec
         );

         --
         --If there is a major error
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_ourtput.put_line('Create_TerrType_Qualifier TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_terrtypequal_out_tbl (l_counter).terr_type_qual_id := NULL;

            -- If save the ERROR status for the record
            x_terrtypequal_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_unexp_error;
         ELSE
            --dbms_ourtput.put_line('Create_TerrType_Qualifier TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_terrtypequal_out_tbl (l_counter).terr_type_qual_id :=
               l_terrtypequal_id;

            -- If successful then save the success status for the record
            x_terrtypequal_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_success;
         END IF;
      --

      END LOOP;

      --Get the API overall return status
      x_return_status := fnd_api.g_ret_sts_success;

      --Get number of records in the ouput table
      l_terrtypequal_out_tbl_count := x_terrtypequal_out_tbl.COUNT;
      l_terrtypequal_out_tbl := x_terrtypequal_out_tbl;

      FOR l_counter IN 1 .. l_terrtypequal_out_tbl_count
      LOOP
         IF l_terrtypequal_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_unexp_error OR
            l_terrtypequal_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_error
         THEN
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'Create_Type_Qual PVT: End');
         fnd_msg_pub.add;
      END IF;

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

      --dbms_ourtput.put_line('Create_TerrType_Qualifier TBL: Exiting API');
--

   END create_terrtype_qualifier;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Record
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_TerrType_Rec              TerrType_Rec_Type  := G_MISS_TERRTYPE_REC
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--     X_TerrType_Out_rec          TerrType_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtype_record (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level     IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtype_rec         IN       terrtype_rec_type := g_miss_terrtype_rec,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_terrtype_out_rec     OUT NOCOPY      terrtype_out_rec_type
   )
   AS
      CURSOR c_getterrtype (l_terrtype_id NUMBER)
      IS
         SELECT ROWID,
                terr_type_id,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                last_update_login,
                application_short_name,
                name,
                enabled_flag,
                description,
                start_date_active,
                end_date_active,
                org_id,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
           FROM jtf_terr_types
          WHERE terr_type_id = l_terrtype_id
            FOR UPDATE NOWAIT;

      --
      --Local variable declaration
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_TerrType_Record';
      l_rowid                       VARCHAR2(50);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_ref_terrtype_rec            terrtype_rec_type;
   BEGIN
      --dbms_ourtput.put_line('Update_TerrType_Record PVT: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT update_terrtype_pvt;

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

      -- Initialize API return status to SUCCESS
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --dbms_ourtput.put_line('Update_TerrType_Record PVT: Opening C_GetTerrType' || to_char(nvl(P_TerrType_Rec.Terr_Type_Id,0)));
      OPEN c_getterrtype (p_terrtype_rec.terr_type_id);
      --
      --dbms_ourtput.put_line('Update_TerrType_Record PVT:Before fetch');
      FETCH c_getterrtype INTO l_rowid,
                               l_ref_terrtype_rec.terr_type_id,
                               l_ref_terrtype_rec.last_updated_by,
                               l_ref_terrtype_rec.last_update_date,
                               l_ref_terrtype_rec.created_by,
                               l_ref_terrtype_rec.creation_date,
                               l_ref_terrtype_rec.last_update_login,
                               l_ref_terrtype_rec.application_short_name,
                               l_ref_terrtype_rec.name,
                               l_ref_terrtype_rec.enabled_flag,
                               l_ref_terrtype_rec.description,
                               l_ref_terrtype_rec.start_date_active,
                               l_ref_terrtype_rec.end_date_active,
                               l_ref_terrtype_rec.org_id,
                               l_ref_terrtype_rec.attribute_category,
                               l_ref_terrtype_rec.attribute1,
                               l_ref_terrtype_rec.attribute2,
                               l_ref_terrtype_rec.attribute3,
                               l_ref_terrtype_rec.attribute4,
                               l_ref_terrtype_rec.attribute5,
                               l_ref_terrtype_rec.attribute6,
                               l_ref_terrtype_rec.attribute7,
                               l_ref_terrtype_rec.attribute8,
                               l_ref_terrtype_rec.attribute9,
                               l_ref_terrtype_rec.attribute10,
                               l_ref_terrtype_rec.attribute11,
                               l_ref_terrtype_rec.attribute12,
                               l_ref_terrtype_rec.attribute13,
                               l_ref_terrtype_rec.attribute14,
                               l_ref_terrtype_rec.attribute15;

      --
      --dbms_ourtput.put_line('Update_TerrType_Record PVT: After fetch');
      IF (c_getterrtype%NOTFOUND)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'API_MISSING_UPDATE_TARGET');
            fnd_message.set_token ('INFO', 'TERRITORY_TYPE', FALSE);
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      --
      CLOSE c_getterrtype;

      -- VAalidate
      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
         -- Debug message
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
            fnd_message.set_token ('PROC_NAME', 'Validate_TerrType_Record');
            fnd_msg_pub.add;
         END IF;

         --
         -- Invoke validation procedures
         validate_terrtype_record (
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_terr_type_rec => p_terrtype_rec
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --
      --dbms_ourtput.put_line('Update_TerrType_Record PVT: Before Calling JTF_TERR_TYPES_PKG.Update_Row');
      jtf_terr_types_pkg.update_row (
         x_rowid => l_rowid,
         x_terr_type_id => p_terrtype_rec.terr_type_id,
         x_last_updated_by => p_terrtype_rec.last_updated_by,
         x_last_update_date => p_terrtype_rec.last_update_date,
         x_created_by => p_terrtype_rec.created_by,
         x_creation_date => p_terrtype_rec.creation_date,
         x_last_update_login => p_terrtype_rec.last_update_login,
         x_application_short_name => p_terrtype_rec.application_short_name,
         x_name => p_terrtype_rec.name,
         x_enabled_flag => p_terrtype_rec.enabled_flag,
         x_description => p_terrtype_rec.description,
         x_start_date_active => p_terrtype_rec.start_date_active,
         x_end_date_active => p_terrtype_rec.end_date_active,
         x_attribute_category => p_terrtype_rec.attribute_category,
         x_attribute1 => p_terrtype_rec.attribute1,
         x_attribute2 => p_terrtype_rec.attribute2,
         x_attribute3 => p_terrtype_rec.attribute3,
         x_attribute4 => p_terrtype_rec.attribute4,
         x_attribute5 => p_terrtype_rec.attribute5,
         x_attribute6 => p_terrtype_rec.attribute6,
         x_attribute7 => p_terrtype_rec.attribute7,
         x_attribute8 => p_terrtype_rec.attribute8,
         x_attribute9 => p_terrtype_rec.attribute9,
         x_attribute10 => p_terrtype_rec.attribute10,
         x_attribute11 => p_terrtype_rec.attribute11,
         x_attribute12 => p_terrtype_rec.attribute12,
         x_attribute13 => p_terrtype_rec.attribute13,
         x_attribute14 => p_terrtype_rec.attribute14,
         x_attribute15 => p_terrtype_rec.attribute15,
         x_org_id => p_terrtype_rec.org_id
      );
      x_terrtype_out_rec.terr_type_id := p_terrtype_rec.terr_type_id;
      x_terrtype_out_rec.return_status := fnd_api.g_ret_sts_success;
      x_return_status := fnd_api.g_ret_sts_success;

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

      --dbms_ourtput.put_line('Update_TerrType_Record PVT: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_terrtype_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         x_terrtype_out_rec.terr_type_id := p_terrtype_rec.terr_type_id;
         x_terrtype_out_rec.return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_terrtype_pvt;
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_terrtype_out_rec.terr_type_id := p_terrtype_rec.terr_type_id;
         x_terrtype_out_rec.return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_terrtype_pvt;
         --dbms_ourtput.put_line('Update_TerrType_Record PVT: OTHERS - ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_terrtype_out_rec.terr_type_id := p_terrtype_rec.terr_type_id;
         x_terrtype_out_rec.return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Update_TerrType_Record ' || SQLERRM
            );
         END IF;
--

   END update_terrtype_record;

--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type               Default
--     P_TerrTypeUsgs_Rec          TerrTypeUsgs_Rec_Type   := G_MISS_TERRTYPEUSGS_REC
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type               Default
--     X_Return_Status             VARCHAR2
--     X_TerrTypeUsgs_Out_Rec      TerrTypeUsgs_Out_Rec_Type
--
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtype_usages (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtypeusgs_rec       IN       terrtypeusgs_rec_type := g_miss_terrtypeusgs_rec,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypeusgs_out_rec   OUT NOCOPY      terrtypeusgs_out_rec_type
   )
   AS
      CURSOR c_getterrtypeusage (l_terr_type_usg_id NUMBER)
      IS
         SELECT ROWID,
                terr_type_usg_id,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                last_update_login,
                terr_type_id,
                source_id
           FROM jtf_terr_type_usgs
          WHERE terr_type_usg_id = l_terr_type_usg_id
            FOR UPDATE NOWAIT;

      --Local variable declaration
      l_api_name           CONSTANT VARCHAR2(30) := 'Update_TerrType_Usages';
      l_rowid                       VARCHAR2(50);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_ref_terrtypeusgs_rec        terrtypeusgs_rec_type;
   BEGIN
      -- Standard start of PAI savepoint
      SAVEPOINT update_terrtype_usgs_pvt;

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

      -- Initialize API return status to SUCCESS
      x_return_status := fnd_api.g_ret_sts_success;

      --dbms_ourtput.put_line('Update_TerrType_Usages REC: opening cursor C_GetTerrTypeUsage');
      OPEN c_getterrtypeusage (p_terrtypeusgs_rec.terr_type_usg_id);
      FETCH c_getterrtypeusage
       INTO l_rowid,
            l_ref_terrtypeusgs_rec.terr_type_usg_id,
            l_ref_terrtypeusgs_rec.last_updated_by,
            l_ref_terrtypeusgs_rec.last_update_date,
            l_ref_terrtypeusgs_rec.created_by,
            l_ref_terrtypeusgs_rec.creation_date,
            l_ref_terrtypeusgs_rec.last_update_login,
            l_ref_terrtypeusgs_rec.terr_type_id,
            l_ref_terrtypeusgs_rec.source_id;

      IF (c_getterrtypeusage%NOTFOUND)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            --dbms_ourtput.put_line('Update_TerrType_Usages REC: C_GetTerrTypeUsage%NOTFOUND');
            fnd_message.set_name ('JTF', 'API_MISSING_UPDATE_TARGET');
            fnd_message.set_token ('INFO', 'TERRITORY_TYPE_USAGE', FALSE);
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_getterrtypeusage;

      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
          -- Debug message
          IF fnd_msg_pub.check_msg_level (
             fnd_msg_pub.g_msg_lvl_debug_low
          )
          THEN
             fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
             fnd_message.set_token ('PROC_NAME', 'Validate_TerrType_Usage');
             fnd_msg_pub.add;
          END IF;

          --
          -- Invoke validation procedures
          validate_terrtype_usage (
             p_init_msg_list => fnd_api.g_false,
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_terr_type_id => p_terrtypeusgs_rec.terr_type_id,
             p_terrtypeusgs_rec => p_terrtypeusgs_rec
          );

          --
          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error;
          END IF;
      End If;

      --dbms_ourtput.put_line('Update_TerrType_Usages REC: Before Calling JTF_TERR_TYPE_USGS_PKG.Update_Row');
      -- Call insert terr_Qual_Type_Usgs table handler
      jtf_terr_type_usgs_pkg.update_row (
         x_rowid => l_rowid,
         x_terr_type_usg_id => p_terrtypeusgs_rec.terr_type_usg_id,
         x_last_update_date => p_terrtypeusgs_rec.last_update_date,
         x_last_updated_by => p_terrtypeusgs_rec.last_updated_by,
         x_creation_date => p_terrtypeusgs_rec.creation_date,
         x_created_by => p_terrtypeusgs_rec.created_by,
         x_last_update_login => p_terrtypeusgs_rec.last_update_login,
         x_terr_type_id => p_terrtypeusgs_rec.terr_type_id,
         x_source_id => p_terrtypeusgs_rec.source_id,
         x_org_id => p_terrtypeusgs_rec.org_id
      );
      --
      x_terrtypeusgs_out_rec.terr_type_usg_id := p_terrtypeusgs_rec.terr_type_id;
      x_terrtypeusgs_out_rec.return_status := fnd_api.g_ret_sts_success;
      x_return_status := fnd_api.g_ret_sts_success;

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
   --dbms_ourtput.put_line('Update_TerrType_Usages REC: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_terrtype_usgs_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         x_terrtypeusgs_out_rec.terr_type_usg_id :=
            p_terrtypeusgs_rec.terr_type_id;
         x_terrtypeusgs_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_terrtype_usgs_pvt;
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_terrtypeusgs_out_rec.terr_type_usg_id :=
            p_terrtypeusgs_rec.terr_type_id;
         x_terrtypeusgs_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_terrtype_usgs_pvt;
         --dbms_ourtput.put_line('Update_TerrType_Usages REC: OTHERS - ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_terrtypeusgs_out_rec.terr_type_usg_id :=
            p_terrtypeusgs_rec.terr_type_id;
         x_terrtypeusgs_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Update_Territory_Usages ' || SQLERRM
            );
         END IF;
--

   END update_terrtype_usages;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type               Default
--     P_TerrTypeUsgs_Tbl          TerrTypeUsgs_Tbl_Type   := G_MISS_TERRTYPEUSGS_TBL
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type               Default
--     X_Return_Status             VARCHAR2
--     X_TerrTypeUsgs_Out_Tbl      TerrTypeUsgs_Out_Tbl_Type
--
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtype_usages (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtypeusgs_tbl       IN       terrtypeusgs_tbl_type := g_miss_terrtypeusgs_tbl,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypeusgs_out_tbl   OUT NOCOPY      terrtypeusgs_out_tbl_type
   )
   AS
      l_rowid                       ROWID;
      l_return_status               VARCHAR2(1);
      l_terr_qual_type_usg_id       NUMBER;
      l_terrtypeusgs_tbl_count      NUMBER := p_terrtypeusgs_tbl.COUNT;
      l_terrtypeusgs_out_tbl_count  NUMBER;
      l_terrtypeusgs_out_tbl        terrtypeusgs_out_tbl_type;
      l_terrtypeusgs_out_rec        terrtypeusgs_out_rec_type;
      l_counter                     NUMBER;
   BEGIN
      --dbms_ourtput.put_line('Update_TerrType_Usages TBL: Entering API');

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- Call insert terr_Qual_Type_Usgs table handler
      --
      FOR l_counter IN 1 .. l_terrtypeusgs_tbl_count
      LOOP
         --
         --dbms_ourtput.put_line('Update_TerrType_Usages TBL: Before Calling Update_TerrType_Usages REC');
         update_terrtype_usages (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            p_terrtypeusgs_rec => p_terrtypeusgs_tbl (l_counter),
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_terrtypeusgs_out_rec => l_terrtypeusgs_out_rec
         );

         --
         --If there is a major error
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_ourtput.put_line('Update_TerrType_Usages TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_terrtypeusgs_out_tbl (l_counter).terr_type_usg_id :=
               l_terrtypeusgs_out_rec.terr_type_usg_id;

            -- If save the ERROR status for the record
            x_terrtypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_unexp_error;
         ELSE
            --dbms_ourtput.put_line('Update_TerrType_Usages TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_terrtypeusgs_out_tbl (l_counter).terr_type_usg_id :=
               l_terrtypeusgs_out_rec.terr_type_usg_id;

            -- If successful then save the success status for the record
            x_terrtypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_success;
         END IF;
      --

      END LOOP;

      --Get the API overall return status
      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --Get number of records in the ouput table
      l_terrtypeusgs_out_tbl_count := x_terrtypeusgs_out_tbl.COUNT;
      l_terrtypeusgs_out_tbl := x_terrtypeusgs_out_tbl;

      --
      FOR l_counter IN 1 .. l_terrtypeusgs_out_tbl_count
      LOOP
         IF l_terrtypeusgs_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_unexp_error OR
            l_terrtypeusgs_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_error
         THEN
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;
      --dbms_ourtput.put_line('Update_TerrType_Usages TBL: Exiting API');
   --
   END update_terrtype_usages;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrTypeQualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtypequaltype_usage (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN       NUMBER   := fnd_api.g_valid_level_full,
      p_typequaltypeusgs_rec       IN       typequaltypeusgs_rec_type := g_miss_typequaltypeusgs_rec,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_typequaltypeusgs_out_rec   OUT NOCOPY      typequaltypeusgs_out_rec_type
   )
   AS
      CURSOR c_gettypequaltypeusgs (l_type_qual_type_usg_id NUMBER)
      IS
         SELECT ROWID,
                type_qtype_usg_id,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                last_update_login,
                terr_type_id,
                qual_type_usg_id
           FROM jtf_type_qtype_usgs
          WHERE type_qtype_usg_id = l_type_qual_type_usg_id
            FOR UPDATE NOWAIT;

      --Local variable declaration
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Update_TerrTypeQualType_Usage';
      l_rowid                       VARCHAR2(50);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_ref_typequaltypeusgs_rec    typequaltypeusgs_rec_type;
   BEGIN
      --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage REC: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT update_typeqtype_usgs_pvt;

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

      -- Initialize API return status to SUCCESS
      x_return_status := fnd_api.g_ret_sts_success;
      --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage REC: opening cursor  C_GetTypeQualTypeUsgs');
      OPEN c_gettypequaltypeusgs (p_typequaltypeusgs_rec.type_qual_type_usg_id);
      FETCH c_gettypequaltypeusgs
       INTO l_rowid,
            l_ref_typequaltypeusgs_rec.type_qual_type_usg_id,
            l_ref_typequaltypeusgs_rec.last_updated_by,
            l_ref_typequaltypeusgs_rec.last_update_date,
            l_ref_typequaltypeusgs_rec.created_by,
            l_ref_typequaltypeusgs_rec.creation_date,
            l_ref_typequaltypeusgs_rec.last_update_login,
            l_ref_typequaltypeusgs_rec.terr_type_id,
            l_ref_typequaltypeusgs_rec.qual_type_usg_id;

      IF (c_gettypequaltypeusgs%NOTFOUND)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage REC: C_GetTypeQualTypeUsgs%NOTFOUND');
            fnd_message.set_name ('JTF', 'API_MISSING_UPDATE_TARGET');
            fnd_message.set_token ('INFO', 'TERRITORY', FALSE);
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_gettypequaltypeusgs;

      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
         -- Debug message
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
            fnd_message.set_token ('PROC_NAME', 'Validate_Territory_Usage');
            fnd_msg_pub.add;
         END IF;

         -- Invoke validation procedures
         validate_type_qtype_usage (
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_terr_type_id => p_typequaltypeusgs_rec.terr_type_id,
            p_type_qualtypeusgs_rec => p_typequaltypeusgs_rec
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage REC: JTF_TYPE_QTYPE_USGS_PKG.Update_Row');
      jtf_type_qtype_usgs_pkg.update_row (
         x_rowid => l_rowid,
         x_type_qtype_usg_id => p_typequaltypeusgs_rec.type_qual_type_usg_id,
         x_last_updated_by => p_typequaltypeusgs_rec.last_updated_by,
         x_last_update_date => p_typequaltypeusgs_rec.last_update_date,
         x_created_by => p_typequaltypeusgs_rec.created_by,
         x_creation_date => p_typequaltypeusgs_rec.creation_date,
         x_last_update_login => p_typequaltypeusgs_rec.last_update_login,
         x_terr_type_id => p_typequaltypeusgs_rec.terr_type_id,
         x_qual_type_usg_id => p_typequaltypeusgs_rec.qual_type_usg_id,
         x_org_id => p_typequaltypeusgs_rec.org_id
      );
      --
      x_typequaltypeusgs_out_rec.type_qual_type_usg_id :=
         p_typequaltypeusgs_rec.type_qual_type_usg_id;
      x_typequaltypeusgs_out_rec.return_status := fnd_api.g_ret_sts_success;
      x_return_status := fnd_api.g_ret_sts_success;

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
   --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage REC: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_typeqtype_usgs_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         x_typequaltypeusgs_out_rec.type_qual_type_usg_id :=
            p_typequaltypeusgs_rec.type_qual_type_usg_id;
         x_typequaltypeusgs_out_rec.return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_typeqtype_usgs_pvt;
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_typequaltypeusgs_out_rec.type_qual_type_usg_id :=
            p_typequaltypeusgs_rec.type_qual_type_usg_id;
         x_typequaltypeusgs_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage REC: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_typeqtype_usgs_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_typequaltypeusgs_out_rec.type_qual_type_usg_id :=
            p_typequaltypeusgs_rec.type_qual_type_usg_id;
         x_typequaltypeusgs_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Update error inside Update_TerrTypeQualType_Usage'
            );
         END IF;
--

   END update_terrtypequaltype_usage;

--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrTypeQualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtypequaltype_usage (
      p_api_version_number         IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                     IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN       NUMBER   := fnd_api.g_valid_level_full,
      p_typequaltypeusgs_tbl       IN       typequaltypeusgs_tbl_type := g_miss_typequaltypeusgs_tbl,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_typequaltypeusgs_out_tbl   OUT NOCOPY      typequaltypeusgs_out_tbl_type
   )
   AS
      l_rowid                       ROWID;
      l_return_status               VARCHAR2(1);
      l_typequaltypeusg_id          NUMBER;
      l_typequaltypeusgs_tbl_count  NUMBER := p_typequaltypeusgs_tbl.COUNT;
      l_typeqtypusgs_out_tbl_count  NUMBER;
      l_typeqtypusgs_out_tbl        typequaltypeusgs_out_tbl_type;
      l_typeqtypusgs_out_rec        typequaltypeusgs_out_rec_type;
      l_counter                     NUMBER;
   BEGIN
      --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage TBL: Entering API');

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- Call insert terr_Qual_Type_Usgs table handler
      --
      FOR l_counter IN 1 .. l_typequaltypeusgs_tbl_count
      LOOP
         --
         --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage TBL: Before Calling Update_TerrTypeQualType_Usage REC');
         update_terrtypequaltype_usage (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            p_typequaltypeusgs_rec => p_typequaltypeusgs_tbl (l_counter),
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_typequaltypeusgs_out_rec => l_typeqtypusgs_out_rec
         );

         --
         --If there is a major error
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_typequaltypeusgs_out_tbl (l_counter).type_qual_type_usg_id :=
               l_typeqtypusgs_out_rec.type_qual_type_usg_id;
            -- If save the ERROR status for the record
            x_typequaltypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_unexp_error;
         ELSE
            --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_typequaltypeusgs_out_tbl (l_counter).type_qual_type_usg_id :=
               l_typeqtypusgs_out_rec.type_qual_type_usg_id;
            -- If successful then save the success status for the record
            x_typequaltypeusgs_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_success;
         END IF;
      --

      END LOOP;

      --Get the API overall return status
      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --Get number of records in the ouput table
      l_typeqtypusgs_out_tbl_count := x_typequaltypeusgs_out_tbl.COUNT;
      l_typeqtypusgs_out_tbl := x_typequaltypeusgs_out_tbl;

      FOR l_counter IN 1 .. l_typeqtypusgs_out_tbl_count
      LOOP
         IF l_typeqtypusgs_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_unexp_error OR
            l_typeqtypusgs_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_error
         THEN
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;
   --dbms_ourtput.put_line('Update_TerrTypeQualType_Usage TBL: Exiting API');
--

   END update_terrtypequaltype_usage;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrTypeQual_Rec            TerrTypeQual_Rec_Type            := G_Miss_TerrTypeQual_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtype_qualifier (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtypequal_rec       IN       terrtypequal_rec_type := g_miss_terrtypequal_rec,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypequal_out_rec   OUT NOCOPY      terrtypequal_out_rec_type
   )
   AS
      CURSOR c_getterrqualifier (l_terrtypequal_id NUMBER)
      IS
         SELECT ROWID,
                terr_type_qual_id,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                last_update_login,
                qual_usg_id,
                terr_type_id,
                exclusive_use_flag,
                overlap_allowed_flag,
                in_use_flag
           FROM jtf_terr_type_qual
          WHERE terr_type_qual_id = l_terrtypequal_id
            FOR UPDATE NOWAIT;

      --
      --Local variable declaration
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Update_Terr_Type_Qualifier';
      l_rowid                       VARCHAR2(50);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
      l_ref_terrtypequal_rec        terrtypequal_rec_type;
   BEGIN
      --dbms_ourtput.put_line('Update_TerrType_Qualifier REC: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT update_terrtype_qualifier;

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

      -- Initialize API return status to SUCCESS
      x_return_status := fnd_api.g_ret_sts_success;
      --dbms_ourtput.put_line('Update_TerrType_Qualifier REC: opening cursor C_GetTerrQualifier');
      --
      OPEN c_getterrqualifier (p_terrtypequal_rec.terr_type_qual_id);
      --
      FETCH c_getterrqualifier
       INTO l_rowid,
            l_ref_terrtypequal_rec.terr_type_qual_id,
            l_ref_terrtypequal_rec.last_updated_by,
            l_ref_terrtypequal_rec.last_update_date,
            l_ref_terrtypequal_rec.created_by,
            l_ref_terrtypequal_rec.creation_date,
            l_ref_terrtypequal_rec.last_update_login,
            l_ref_terrtypequal_rec.qual_usg_id,
            l_ref_terrtypequal_rec.terr_type_id,
            l_ref_terrtypequal_rec.exclusive_use_flag,
            l_ref_terrtypequal_rec.overlap_allowed_flag,
            l_ref_terrtypequal_rec.in_use_flag;
      --
      IF (c_getterrqualifier%NOTFOUND)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'API_MISSING_UPDATE_TARGET');
            fnd_message.set_token ('INFO', 'TERRITORY_TYPE_QUALIFIER', FALSE);
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_getterrqualifier;


      -- Check the validation level
      IF (p_validation_level >= fnd_api.g_valid_level_full)
      THEN
         -- Debug message
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_VALIDATE_MSG');
            fnd_message.set_token ('PROC_NAME', 'validate_qualifier');
            fnd_msg_pub.add;
         END IF;

         --
         -- Invoke validation procedures
         validate_qualifier (
            p_init_msg_list => fnd_api.g_false,
            p_terrtypequal_rec => p_terrtypequal_rec,
            p_terr_type_id => p_terrtypequal_rec.terr_type_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_ourtput.put_line('Validate_Qualifier Procedure failed');
            RAISE fnd_api.g_exc_error;
         END IF;
      --
      END IF;

      --dbms_ourtput.put_line('Update_TerrType_Qualifier REC: Before Calling JTF_TERR_TYPE_QUAL_PKG.Update_Row');
      jtf_terr_type_qual_pkg.update_row (
         x_rowid => l_rowid,
         x_terr_type_qual_id => p_terrtypequal_rec.terr_type_qual_id,
         x_last_update_date => p_terrtypequal_rec.last_update_date,
         x_last_updated_by => p_terrtypequal_rec.last_updated_by,
         x_creation_date => p_terrtypequal_rec.creation_date,
         x_created_by => p_terrtypequal_rec.created_by,
         x_last_update_login => p_terrtypequal_rec.last_update_login,
         x_qual_usg_id => p_terrtypequal_rec.qual_usg_id,
         x_terr_type_id => p_terrtypequal_rec.terr_type_id,
         x_exclusive_use_flag => p_terrtypequal_rec.exclusive_use_flag,
         x_overlap_allowed_flag => p_terrtypequal_rec.overlap_allowed_flag,
         x_in_use_flag => p_terrtypequal_rec.in_use_flag,
         x_qualifier_mode => p_terrtypequal_rec.qualifier_mode,
         x_org_id => p_terrtypequal_rec.org_id
      );
      --Call the update table handler
      x_terrtypequal_out_rec.terr_type_qual_id :=
         p_terrtypequal_rec.terr_type_qual_id;
      x_terrtypequal_out_rec.return_status := fnd_api.g_ret_sts_success;
      x_return_status := fnd_api.g_ret_sts_success;

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

      --dbms_ourtput.put_line('Update_TerrType_Qualifier REC: Exiting API');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_terrtype_qualifier;
         x_return_status := fnd_api.g_ret_sts_error;
         x_terrtypequal_out_rec.terr_type_qual_id :=
            p_terrtypequal_rec.terr_type_qual_id;
         x_terrtypequal_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('create_terrtype PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO update_terrtype_qualifier;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_terrtypequal_out_rec.terr_type_qual_id :=
            p_terrtypequal_rec.terr_type_qual_id;
         x_terrtypequal_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Update_TerrType_Qualifier REC: OTHERS - ' || SQLERRM);
         ROLLBACK TO update_terrtype_qualifier;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_terrtypequal_out_rec.terr_type_qual_id :=
            p_terrtypequal_rec.terr_type_qual_id;
         x_terrtypequal_out_rec.return_status :=
            fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Update_TerrType_Qualifer ' || SQLERRM
            );
         END IF;
   END update_terrtype_qualifier;

--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrTypeQual_Tbl            TerrTypeQual_Tbl_Type            := G_Miss_TerrTypeQual_Tbl
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_TerrTypeQual_Out_Tbl        TerrTypeQual_Out_Tbl_Type
--
--   Note:
--
--   End of Comments
--
   PROCEDURE update_terrtype_qualifier (
      p_api_version_number     IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      p_commit                 IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full,
      p_terrtypequal_tbl       IN       terrtypequal_tbl_type := g_miss_terrtypequal_tbl,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_terrtypequal_out_tbl   OUT NOCOPY      terrtypequal_out_tbl_type
   )
   AS
      l_terr_qual_id                NUMBER;
      l_return_status               VARCHAR2(1);
      l_terrtypequal_tbl_count      NUMBER := p_terrtypequal_tbl.COUNT;
      l_terrtypequal_out_tbl_count  NUMBER;
      l_terrtypequal_out_tbl        terrtypequal_out_tbl_type;
      l_terrtypequal_out_rec        terrtypequal_out_rec_type;
      l_counter                     NUMBER;
   BEGIN
      --dbms_ourtput.put_line('Update_TerrType_Qualifier TBL: Entering API');

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- Call overloaded Create_Terr_Qualifier procedure
      --
      FOR l_counter IN 1 .. l_terrtypequal_tbl_count
      LOOP
         --
         --dbms_ourtput.put_line('Update_TerrType_Qualifier TBL: Before calling Update_TerrType_Qualifier');
         update_terrtype_qualifier (
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            p_terrtypequal_rec => p_terrtypequal_tbl (l_counter),
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_terrtypequal_out_rec => l_terrtypequal_out_rec
         );

         --
         --If there is a major error
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            --dbms_ourtput.put_line('Update_TerrType_Qualifier TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_terrtypequal_out_tbl (l_counter).terr_type_qual_id :=
               l_terrtypequal_out_rec.terr_type_qual_id;
            -- If save the ERROR status for the record
            x_terrtypequal_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_unexp_error;
         ELSE
            --dbms_ourtput.put_line('Update_TerrType_Qualifier TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
            -- Save the terr_usg_id and
            x_terrtypequal_out_tbl (l_counter).terr_type_qual_id :=
               l_terrtypequal_out_rec.terr_type_qual_id;
            -- If successful then save the success status for the record
            x_terrtypequal_out_tbl (l_counter).return_status :=
               fnd_api.g_ret_sts_success;
         END IF;
      --

      END LOOP;

      --Get the API overall return status
      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      --Get number of records in the ouput table
      l_terrtypequal_out_tbl_count := x_terrtypequal_out_tbl.COUNT;
      l_terrtypequal_out_tbl := x_terrtypequal_out_tbl;

      FOR l_counter IN 1 .. l_terrtypequal_out_tbl_count
      LOOP
         IF l_terrtypequal_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_unexp_error OR
            l_terrtypequal_out_tbl (l_counter).return_status =
            fnd_api.g_ret_sts_error
         THEN
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;
      --
      --dbms_ourtput.put_line('Update_TerrType_Qualifier TBL: Exiting API');
   --
   END update_terrtype_qualifier;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrType_Record
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           FND_API.G_FALSE
--     P_Commit                    VARCHAR2
--     P_TerrType_Id               NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
   PROCEDURE delete_terrtype_record (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_terrtype_id          IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   AS
      l_row_count                   NUMBER;
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_TerrType_Record';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      --dbms_ourtput.put_line('Delete_TerrType_Record PVT: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT delete_terr_record_pvt;

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

      --Initialize the return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --dbms_ourtput.put_line('Delete_TerrType_Record PVT: Before Calling JTF_TERR_TYPES_PKG.Delete_Row');
      jtf_terr_types_pkg.delete_row (x_terr_type_id => p_terrtype_id);
      --
      --Prepare message name
      fnd_message.set_name ('JTF', 'TERRTYPE_RECORDS_DELETED');

      IF SQL%FOUND
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Record PVT: NO-RCORDS-FOUND');
         x_return_status := fnd_api.g_ret_sts_success;
         l_row_count := SQL%ROWCOUNT;
      END IF;

      --Prepare message token
      fnd_message.set_name ('ITEMS_DELETED', l_row_count);

      --Add message to API message list
      fnd_msg_pub.add;

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
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Record PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO delete_terr_record_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Record PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO delete_terr_record_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Delete_TerrType_Record ' || SQLERRM
            );
         END IF;
   --
   END delete_terrtype_record;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrType_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           FND_API.G_FALSE
--     P_Commit                    VARCHAR2
--     P_TerrTypeUsg_Id            NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
   PROCEDURE delete_terrtype_usages (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_terrtypeusg_id       IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   AS
      l_row_count                   NUMBER;
      l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Territory_Usages';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      --dbms_ourtput.put_line('Delete_TerrType_Usages PVT: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT delete_terrtype_usgs_pvt;

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

      --Initialize the return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --dbms_ourtput.put_line('Delete_TerrType_Usages PVT: Before Calling JTF_TERR_TYPE_USGS_PKG.Delete_Row');
      jtf_terr_type_usgs_pkg.delete_row (
         x_terr_type_usg_id => p_terrtypeusg_id
      );
      --
      --Prepare message name
      fnd_message.set_name ('JTF', 'TERRTYPE_USGS_DELETED');

      IF SQL%FOUND
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Usages PVT: NO-RCORDS-FOUND');
         x_return_status := fnd_api.g_ret_sts_success;
         l_row_count := SQL%ROWCOUNT;
      END IF;

      --Prepare message token
      fnd_message.set_name ('ITEMS_DELETED', l_row_count);
      --Add message to API message list
      fnd_msg_pub.add;

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
   --dbms_ourtput.put_line('Delete_TerrType_Usages PVT: Exiting API');
--
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Usages PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO delete_terrtype_usgs_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Usages PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO delete_terrtype_usgs_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Delete_TerrType_Usages ' || SQLERRM
            );
         END IF;
   --

   END delete_terrtype_usages;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrTypeQualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           := FND_API.G_FALSE
--     P_Commit                    VARCHAR2           := FND_API.G_FALSE
--     P_Terr_Qual_Type_Usg_Id     NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
   PROCEDURE delete_terrtypequaltype_usage (
      p_api_version_number        IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
      p_commit                    IN       VARCHAR2 := fnd_api.g_false,
      p_terrtypequaltype_usg_id   IN       NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      VARCHAR2,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   )
   AS
      l_row_count                   NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Delete_TerrTypeQualType_Usage';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      --dbms_ourtput.put_line('Delete_TerrTypeQualType_Usage PVT: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT delete_typequaltypeusg_pvt;

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

      --Initialize the return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --dbms_ourtput.put_line('Delete_TerrTypeQualType_Usage PVT: Before Calling JTF_TYPE_QTYPE_USGS_PKG.Delete_Row');
      jtf_type_qtype_usgs_pkg.delete_row (
         x_type_qtype_usg_id => p_terrtypequaltype_usg_id
      );
      --
      --
      --Prepare message name
      fnd_message.set_name ('JTF', 'TERRTYPE_QUALUSGS_DELETED');

      --
      IF SQL%FOUND
      THEN
         --dbms_ourtput.put_line('Delete_TerrTypeQualType_Usage PVT: NO-RCORDS-FOUND');
         x_return_status := fnd_api.g_ret_sts_success;
         l_row_count := SQL%ROWCOUNT;
      END IF;

      --Prepare message token
      fnd_message.set_name ('ITEMS_DELETED', l_row_count);
      --Add message to API message list
      fnd_msg_pub.add;

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
   --dbms_ourtput.put_line('Delete_TerrTypeQualType_Usage PVT: Exiting API');
--
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Delete_TerrTypeQualType_Usage PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO delete_typequaltypeusg_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Delete_TerrTypeQualType_Usage PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO delete_typequaltypeusg_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Error inside Delete_TerrTypeQualType_Usage ' || SQLERRM
            );
         END IF;
   --

   END delete_terrtypequaltype_usage;

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrType_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           FND_API.G_FALSE
--     P_Commit                    VARCHAR2
--     P_TerrTypeQual_Id           NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
   PROCEDURE delete_terrtype_qualifier (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_terrtypequal_id      IN       NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   AS
      l_row_count                   NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Delete_TerrType_Qualifier';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status               VARCHAR2(1);
   BEGIN
      --dbms_ourtput.put_line('Delete_TerrType_Qualifier PVT: Entering API');

      -- Standard start of PAI savepoint
      SAVEPOINT delete_terrtypequal_pvt;

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

      --Initialize the return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --dbms_ourtput.put_line('Delete_TerrType_Qualifier PVT: Before Calling JTF_TERR_TYPE_QUAL_PKG.Delete_Row');
      jtf_terr_type_qual_pkg.delete_row (
         x_terr_type_qual_id => p_terrtypequal_id
      );
      --
      --Prepare message name
      fnd_message.set_name ('JTF', 'TERRTYPE_QUALIFIERS_DELETED');

      IF SQL%FOUND
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Qualifier PVT: NO-RCORDS-FOUND');
         x_return_status := fnd_api.g_ret_sts_success;
         l_row_count := SQL%ROWCOUNT;
      END IF;

      --Prepare message token
      fnd_message.set_name ('ITEMS_DELETED', l_row_count);
      --Add message to API message list
      fnd_msg_pub.add ();

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
   --dbms_ourtput.put_line('Delete_TerrType_Qualifier PVT: Exiting API');
   --
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Qualifier PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO delete_terrtypequal_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_ourtput.put_line('Delete_TerrType_Qualifier PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO delete_terrtypequal_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
               g_pkg_name,
               'Delete error inside Delete_TerrType_Qualifier'
            );
         END IF;
   END delete_terrtype_qualifier;

   --
   -- Validate the Territory Type RECORD
   -- Validate Territory Type Name
   PROCEDURE validate_terrtype_record (
      p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false,
      p_terr_type_rec   IN       terrtype_rec_type := g_miss_terrtype_rec,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      --dbms_output.put_line ('Validate_TerrType_Header: Entering API');

      -- Initialize the status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- Check whether the territory Name is specified
      --
      IF (p_terr_type_rec.name IS NULL) OR
         (p_terr_type_rec.name = fnd_api.g_miss_char)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'NAME');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Check whether application short name is specified
      --
      IF    (p_terr_type_rec.application_short_name IS NULL)
         OR (p_terr_type_rec.application_short_name = fnd_api.g_miss_char)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'APPLICATION_SHORT_NAME');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Check whether the enabled_flag is specified
      --
      IF    (p_terr_type_rec.enabled_flag IS NULL)
         OR (p_terr_type_rec.enabled_flag = fnd_api.g_miss_char)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'ENABLED_FLAG');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      /* -- Check for ORG_ID - Not Required: ORG_ID is NULLable
      IF    (p_terr_type_rec.org_id IS NULL)
         OR (p_terr_type_rec.org_id = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'ORG_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */

      --Check created by
      IF (  p_terr_type_rec.created_by IS NULL
         OR p_terr_type_rec.created_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check creation date
      IF (  p_terr_type_rec.creation_date IS NULL
         OR p_terr_type_rec.creation_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATION_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Validate last updated by
      IF (  p_terr_type_rec.last_updated_by IS NULL
         OR p_terr_type_rec.last_updated_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Check last update date
      IF (  p_terr_type_rec.last_update_date IS NULL
         OR p_terr_type_rec.last_update_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check last update login
      IF (  p_terr_type_rec.last_update_login IS NULL
         OR p_terr_type_rec.last_update_login = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_LOGIN');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Since the message stack is already set
      --
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line (
         --   'Validate_TerrType_Header: FND_API.G_EXC_ERROR'
         --);
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line (
         --   'Validate_TerrType_Header: FND_API.G_EXC_UNEXPECTED_ERROR'
         --);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line (
         --   'Validate_TerrType_Header: OTHERS - ' || SQLERRM
         --);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END validate_terrtype_record;

   --
   -- This procedure will check whether the qualifiers passed are
   -- valid.
   --
   PROCEDURE validate_qualifier (
      p_terrtypequal_rec   IN       terrtypequal_rec_type
            := g_miss_terrtypequal_rec,
      p_terr_type_id       IN       NUMBER,
      p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   AS
      l_counter                     NUMBER;
      l_temp                        VARCHAR2(01);
   BEGIN
      --dbms_output.put_line ('Validate_Qualifier: Entering API - p_Terr_Type_Id ' || to_char(p_Terr_Type_Id));
      -- Initialize the status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      --dbms_output.put_line (
      --   'Validate P_TerrTypequal_Rec.Qual_Usg_Id - ' ||
      --   TO_CHAR (p_terrtypequal_rec.qual_usg_id)
      --);

      --
      -- Check whether the qualfier is enabled and
      BEGIN
         IF p_terr_type_id IS NOT NULL
         THEN
            SELECT 'x'
              INTO l_temp
              FROM jtf_qual_usgs jqu,
                   jtf_qual_type_usgs jqtu,
                   jtf_type_qtype_usgs jtqu
             WHERE jtqu.terr_type_id = p_terr_type_id
               AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
               AND jqu.qual_usg_id = p_terrtypequal_rec.qual_usg_id
               AND jqu.enabled_flag = 'Y'
               AND jqtu.qual_type_id IN
                      ( SELECT related_id
                          FROM jtf_qual_type_denorm_v
                         WHERE qual_type_id = jqtu.qual_type_id)
               AND rownum < 2;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --dbms_output.put_line (
            --   'Validate_Qualifier: NO_DATA_FOUND Exception'
            --);
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_TERR_DISABLED_TERR_QUAL');
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (
               p_count => x_msg_count,
               p_data => x_msg_data
            );
      END;

      /* -- Check for ORG_ID - not required: ORG_ID is NULLable
      IF (  p_terrtypequal_rec.org_id IS NULL
         OR p_terrtypequal_rec.org_id = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'ORG_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */

      --Check created by
      IF (  p_terrtypequal_rec.created_by IS NULL
         OR p_terrtypequal_rec.created_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check creation date
      IF (  p_terrtypequal_rec.creation_date IS NULL
         OR p_terrtypequal_rec.creation_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATION_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Validate last updated by
      IF (  p_terrtypequal_rec.last_updated_by IS NULL
         OR p_terrtypequal_rec.last_updated_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Check last update date
      IF (  p_terrtypequal_rec.last_update_date IS NULL
         OR p_terrtypequal_rec.last_update_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check last update login
      IF (  p_terrtypequal_rec.last_update_login IS NULL
         OR p_terrtypequal_rec.last_update_login = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_LOGIN');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      --dbms_output.put_line ('Validate_Qualifier: Exiting API');
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         --dbms_output.put_line ('Validate_Qualifier: Others Exception');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         fnd_msg_pub.add;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END validate_qualifier;

   --
---------------------------------------------------------------------
--                Validate the Territory Type Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Type Usage is specified
--         Make sure the Territory Type Id is valid
--         Make sure the territory Type usage Id is Valid
---------------------------------------------------------------------
   PROCEDURE validate_terrtype_usage (
      p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_terrtypeusgs_rec   IN       terrtypeusgs_rec_type
            := g_miss_terrtypeusgs_rec,
      p_terr_type_id       IN       NUMBER
   )
   AS
      l_rec_counter                 NUMBER;
      l_validate_id                 NUMBER;
   BEGIN
      --dbms_output.put_line ('Validate_TerrType_Usage: Entering API');
      -- Initialize the status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- Validate the territory Id
      IF p_terr_type_id IS NOT NULL
      THEN
         l_validate_id := p_terr_type_id;

         IF jtf_ctm_utility_pvt.fk_id_is_valid (
               l_validate_id,
               'TERR_TYPE_ID',
               'JTF_TERR_TYPES'
            ) <>
               fnd_api.g_true
         THEN
            --dbms_output.put_line (
            --   'Validate_Territory_Usage: l_status <> FND_API.G_TRUE'
            --);
            fnd_message.set_name ('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
            fnd_message.set_token ('TABLE_NAME', 'JTF_TERR_TYPES');
            fnd_message.set_token ('COLUMN_NAME', 'TERR_TYPE_ID');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;

         --dbms_output.put_line (
         --   'Validate_Territory_Usage: TERR_TYPE_ID(' ||
         --  TO_CHAR (l_validate_id) ||
         --   ') is valid'
         --);
      END IF;

      -- Validate the source_id
      l_validate_id := p_terrtypeusgs_rec.source_id;

      -- Make sure the foreign key source_id is valid
      IF jtf_ctm_utility_pvt.fk_id_is_valid (
            l_validate_id,
            'SOURCE_ID',
            'JTF_SOURCES'
         ) <>
            fnd_api.g_true
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            --dbms_output.put_line ('Validate_Territory_Usage: FND_MSG_PUB.ADD');
            fnd_message.set_name ('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
            fnd_message.set_token ('TABLE_NAME', 'JTF_SOURCES');
            fnd_message.set_token ('COLUMN_NAME', 'SOURCE_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      /* -- Check for ORG_ID - Not Required: ORG_ID is NULLable
      IF    (p_terrtypeusgs_rec.org_id IS NULL)
         OR (p_terrtypeusgs_rec.org_id = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'ORG_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */

      --Check created by
      IF (  p_terrtypeusgs_rec.created_by IS NULL
         OR p_terrtypeusgs_rec.created_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check creation date
      IF (  p_terrtypeusgs_rec.creation_date IS NULL
         OR p_terrtypeusgs_rec.creation_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATION_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Validate last updated by
      IF (  p_terrtypeusgs_rec.last_updated_by IS NULL
         OR p_terrtypeusgs_rec.last_updated_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Check last update date
      IF (  p_terrtypeusgs_rec.last_update_date IS NULL
         OR p_terrtypeusgs_rec.last_update_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check last update login
      IF (  p_terrtypeusgs_rec.last_update_login IS NULL
         OR p_terrtypeusgs_rec.last_update_login = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_LOGIN');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line ('Validate_TerrType_Usage: FND_API.G_EXC_ERROR');
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line (
         --   'Validate_TerrType_Usage: FND_API.G_EXC_UNEXPECTED_ERROR'
         --);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line (
         --   'Validate_TerrType_Usage: OTHERS - ' || SQLERRM
         --);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
--

   END validate_terrtype_usage;

---------------------------------------------------------------------
--             Validate the Territory Qualifer Type Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Qual Type Usage is specified
--         Make sure the Territory Id is valid
--         Make sure the QUAL_TYPE_USG_ID is valid
---------------------------------------------------------------------
   PROCEDURE validate_type_qtype_usage (
      p_init_msg_list           IN       VARCHAR2 := fnd_api.g_false,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      p_type_qualtypeusgs_rec   IN       typequaltypeusgs_rec_type
            := g_miss_typequaltypeusgs_rec,
      p_terr_type_id            IN       NUMBER
   )
   AS
      l_rec_counter                 NUMBER;
      l_validate_id                 NUMBER;
      l_dummy                       NUMBER;
      l_source_id                   NUMBER;
      l_qual_type_usg_id            NUMBER;
   BEGIN
      --dbms_output.put_line ('Validate_Type_Qtype_Usage: Entering API - p_Terr_Type_Id ' || to_char(p_Terr_Type_Id));
      -- Initialize the status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- This block will validate territory
      -- qual_Type_Usg_id specified
      BEGIN
         l_qual_type_usg_id := p_type_qualtypeusgs_rec.qual_type_usg_id;
         --Check the qual_type_usg_id specified is valid
         SELECT 1
           INTO l_dummy
           FROM jtf_terr_type_usgs jtu, jtf_qual_type_usgs jqtu
          WHERE jtu.terr_type_id = p_terr_type_id
            AND jtu.source_id = jqtu.source_id
            AND jqtu.qual_type_usg_id = l_qual_type_usg_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_INVALID_TERR_QTYPE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      -- Validate the territory Id
      l_validate_id := p_terr_type_id;

      IF p_terr_type_id IS NOT NULL
      THEN
         --dbms_output.put_line (
         --   'Validate_Terr_Qtype_Usage: TERR_TYPE_ID(' ||
         --   TO_CHAR (l_validate_id) ||
         --   ')'
         --);

         IF jtf_ctm_utility_pvt.fk_id_is_valid (
               l_validate_id,
               'TERR_TYPE_ID',
               'JTF_TERR_TYPES'
            ) <>
               fnd_api.g_true
         THEN
            --dbms_output.put_line (
            --   'Validate_Foreign_Key: l_status <> FND_API.G_TRUE'
            --);

            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
               fnd_message.set_token ('TABLE_NAME', 'JTF_TERR_TYPES');
               fnd_message.set_token ('COLUMN_NAME', 'TERR_TYPE_ID');
               fnd_msg_pub.add;
            END IF;

            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;

      --
      --
      /* -- Check for ORG_ID - Not Required: ORG_ID is NULLable
      IF    (p_type_qualtypeusgs_rec.org_id IS NULL)
         OR (p_type_qualtypeusgs_rec.org_id = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'ORG_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */

      --Check created by
      IF (  p_type_qualtypeusgs_rec.created_by IS NULL
         OR p_type_qualtypeusgs_rec.created_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check creation date
      IF (  p_type_qualtypeusgs_rec.creation_date IS NULL
         OR p_type_qualtypeusgs_rec.creation_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'CREATION_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Validate last updated by
      IF (  p_type_qualtypeusgs_rec.last_updated_by IS NULL
         OR p_type_qualtypeusgs_rec.last_updated_by = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATED_BY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Check last update date
      IF (  p_type_qualtypeusgs_rec.last_update_date IS NULL
         OR p_type_qualtypeusgs_rec.last_update_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_DATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --Check last update login
      IF (  p_type_qualtypeusgs_rec.last_update_login IS NULL
         OR p_type_qualtypeusgs_rec.last_update_login = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            fnd_message.set_token ('COL_NAME', 'LAST_UPDATE_LOGIN');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         --dbms_output.put_line (
         --   'Validate_Type_Qtype_Usage: FND_API.G_EXC_ERROR'
         --);
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         --dbms_output.put_line (
         --   'Validate_Type_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR'
         --);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         --dbms_output.put_line (
         --   'Validate_Type_Qtype_Usage: OTHERS - ' || SQLERRM
         --);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END validate_type_qtype_usage;

   --
   -- This procedure is called from the form before
   -- deleting a territory Type
   --
   PROCEDURE is_terrtype_deletable (
      p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false,
      p_terrtype_id     IN       NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      VARCHAR2,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   AS
      l_count                       NUMBER;
   BEGIN
      -- Initialize the status to success
      x_return_status := fnd_api.g_ret_sts_success;
      --
      SELECT COUNT (*)
        INTO l_count
        FROM jtf_terr
       WHERE territory_type_id = p_terrtype_id;

      --
      -- If there are therritories that use this territory Type
      IF l_count > 0
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      ELSE
         x_return_status := fnd_api.g_ret_sts_success;
      END IF;

      --
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      --
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TERR_UNKNOWN_ERROR');
         fnd_message.set_name ('P_TEXT', SQLERRM);
         fnd_msg_pub.add;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   --

   END is_terrtype_deletable;

--
-- Package body
END JTF_TERRITORY_TYPE_PVT;



/
