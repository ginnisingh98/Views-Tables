--------------------------------------------------------
--  DDL for Package Body IGW_ORGANIZATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_ORGANIZATIONS_PVT" AS
--$Header: igwvorgb.pls 115.2 2002/11/14 18:47:29 vmedikon noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_ORGANIZATIONS_PVT';

   ---------------------------------------------------------------------------

   FUNCTION Get_Status(p_active_flag VARCHAR2)
   RETURN varchar2 IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Status';

   BEGIN

      IF p_active_flag = 'Y' THEN

         RETURN 'A';

      END IF;

      RETURN 'I';

   EXCEPTION

      WHEN others THEN

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Get_Status;

   ---------------------------------------------------------------------------

   FUNCTION Get_Country_Code(p_country_name VARCHAR2)
   RETURN varchar2 IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Country_Code';

      l_country_code           VARCHAR2(30);

   BEGIN

      IF p_country_name IS NOT NULL THEN

         SELECT territory_code
         INTO   l_country_code
         FROM   fnd_territories_vl
         WHERE  territory_short_name = p_country_name;

      END IF;

      RETURN l_country_code;

   EXCEPTION

      WHEN no_data_found THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_COUNTRY_INVALID');
         Fnd_Msg_Pub.Add;
         RETURN null;

      WHEN others THEN

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Get_Country_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Organization
   (
      p_init_msg_list     IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only     IN VARCHAR2   := Fnd_Api.G_False,
      p_commit            IN VARCHAR2   := Fnd_Api.G_False,
      x_party_id          OUT NOCOPY NUMBER,
      p_organization_name IN VARCHAR2,
      p_address1          IN VARCHAR2,
      p_address2          IN VARCHAR2,
      p_address3          IN VARCHAR2,
      p_city              IN VARCHAR2,
      p_state             IN VARCHAR2,
      p_postal_code       IN VARCHAR2,
      p_county            IN VARCHAR2,
      p_country_name      IN VARCHAR2,
      p_active_flag       IN VARCHAR2,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Organization';

      l_status                VARCHAR2(1);
      l_country_code          VARCHAR2(30);

      l_party_number          VARCHAR2(30);
      l_profile_id            NUMBER;
      l_location_id           NUMBER;
      l_party_site_id         NUMBER;
      l_party_site_number     VARCHAR2(30);

      l_organization_rec      Hz_Party_V2pub.Organization_Rec_Type;
      l_location_rec          Hz_Location_V2pub.Location_Rec_Type;
      l_party_site_rec        Hz_Party_Site_V2pub.Party_Site_Rec_Type;

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Organization_Pvt;

      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;

      l_status := Get_Status(p_active_flag);
      l_country_code := Get_Country_Code(p_country_name);

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      /*
      **   Discontinue processing if API invoked in validation mode
      */

      IF Fnd_Api.To_Boolean(p_validate_only) THEN

         RETURN;

      END IF;

      l_organization_rec.organization_name               := p_organization_name;
      l_organization_rec.created_by_module               := 'IGW';
      l_organization_rec.party_rec.orig_system_reference := 'IGW';
      l_organization_rec.party_rec.status                := l_status;

      IF Fnd_Profile.Value_Wnps('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN

         SELECT to_char(hz_party_number_s.nextval)
         INTO   l_organization_rec.party_rec.party_number
         FROM   dual;

      END IF;

      Hz_Party_V2pub.Create_Organization
      (
         p_init_msg_list    => Fnd_Api.G_False,
         p_organization_rec => l_organization_rec,
         x_party_id         => x_party_id,
         x_party_number     => l_party_number,
         x_profile_id       => l_profile_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      l_location_rec.address1          := p_address1;
      l_location_rec.address2          := p_address2;
      l_location_rec.address3          := p_address3;
      l_location_rec.city              := p_city;
      l_location_rec.state             := p_state;
      l_location_rec.postal_code       := p_postal_code;
      l_location_rec.county            := p_county;
      l_location_rec.country           := l_country_code;
      l_location_rec.created_by_module := 'IGW';

      Hz_Location_V2pub.Create_Location
      (
         p_init_msg_list  => Fnd_Api.G_False,
         p_location_rec   => l_location_rec,
         x_location_id    => l_location_id,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      l_party_site_rec.party_id                 := x_party_id;
      l_party_site_rec.location_id              := l_location_id;
      l_party_site_rec.identifying_address_flag := 'Y';
      l_party_site_rec.created_by_module        := 'IGW';

      IF Fnd_Profile.Value_Wnps('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN

         SELECT to_char(hz_party_site_number_s.nextval)
         INTO   l_party_site_rec.party_site_number
         FROM   dual;

      END IF;

      Hz_Party_Site_V2pub.Create_Party_Site
      (
         p_init_msg_list     => Fnd_Api.G_False,
         p_party_site_rec    => l_party_site_rec,
         x_party_site_id     => l_party_site_id,
         x_party_site_number => l_party_site_number,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;

   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Create_Organization_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Create_Organization_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Organization_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

   END Create_Organization;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Organization
   (
      p_init_msg_list     IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only     IN VARCHAR2   := Fnd_Api.G_False,
      p_commit            IN VARCHAR2   := Fnd_Api.G_False,
      p_party_id          IN NUMBER,
      p_party_version     IN NUMBER,
      p_location_id       IN NUMBER,
      p_location_version  IN NUMBER,
      p_organization_name IN VARCHAR2,
      p_address1          IN VARCHAR2,
      p_address2          IN VARCHAR2,
      p_address3          IN VARCHAR2,
      p_city              IN VARCHAR2,
      p_state             IN VARCHAR2,
      p_postal_code       IN VARCHAR2,
      p_county            IN VARCHAR2,
      p_country_name      IN VARCHAR2,
      p_active_flag       IN VARCHAR2,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Organization';

      l_status                VARCHAR2(1);
      l_country_code          VARCHAR2(30);

      l_profile_id            NUMBER;
      l_party_version         NUMBER := p_party_version;
      l_location_version      NUMBER := p_location_version;

      l_organization_rec      Hz_Party_V2pub.Organization_Rec_Type;
      l_location_rec          Hz_Location_V2pub.Location_Rec_Type;
      l_party_site_rec        Hz_Party_Site_V2pub.Party_Site_Rec_Type;

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Organization_Pvt;

      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;

      l_status := Get_Status(p_active_flag);
      l_country_code := Get_Country_Code(p_country_name);

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      /*
      **   Discontinue processing if API invoked in validation mode
      */

      IF Fnd_Api.To_Boolean(p_validate_only) THEN

         RETURN;

      END IF;

      l_organization_rec.party_rec.party_id              := p_party_id;
      l_organization_rec.organization_name               := p_organization_name;
      l_organization_rec.created_by_module               := 'IGW';
      l_organization_rec.party_rec.orig_system_reference := 'IGW';
      l_organization_rec.party_rec.status                := l_status;

      Hz_Party_V2pub.Update_Organization
      (
         p_init_msg_list               => Fnd_Api.G_False,
         p_organization_rec            => l_organization_rec,
         p_party_object_version_number => l_party_version,
         x_profile_id                  => l_profile_id,
         x_return_status               => x_return_status,
         x_msg_count                   => x_msg_count,
         x_msg_data                    => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      l_location_rec.location_id       := p_location_id;
      l_location_rec.address1          := p_address1;
      l_location_rec.address2          := p_address2;
      l_location_rec.address3          := p_address3;
      l_location_rec.city              := p_city;
      l_location_rec.state             := p_state;
      l_location_rec.postal_code       := p_postal_code;
      l_location_rec.county            := p_county;
      l_location_rec.country           := l_country_code;
      l_location_rec.created_by_module := 'IGW';

      Hz_Location_V2pub.Update_Location
      (
         p_init_msg_list         => Fnd_Api.G_False,
         p_location_rec          => l_location_rec,
         p_object_version_number => l_location_version,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;

   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Update_Organization_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Organization_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Organization_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

   END Update_Organization;

   ---------------------------------------------------------------------------

END Igw_Organizations_Pvt;

/
