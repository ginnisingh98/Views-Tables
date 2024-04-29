--------------------------------------------------------
--  DDL for Package Body AST_PARTY_LOCATIONS_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_PARTY_LOCATIONS_V2PUB" AS
 /* $Header: astcul2b.pls 120.3 2005/10/26 12:13:29 rkumares ship $ */

 PROCEDURE Create_Address (
     p_address_rec       IN   AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_location_id       OUT NOCOPY  NUMBER) Is

   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_location_id NUMBER;
   l_loc_id      NUMBER;
   l_created_by_module VARCHAR2(150);
   l_application_id NUMBER;
   l_addr_val_level VARCHAR2(30);
   l_addr_val_status VARCHAR2(30);
   l_addr_warn_msg VARCHAR2(2000);
 Begin
   l_location_rec.address1 := p_address_rec.address1;
   l_location_rec.address2 := p_address_rec.address2;
   l_location_rec.address3 := p_address_rec.address3;
   l_location_rec.address4 := p_address_rec.address4;
   l_location_rec.city     := p_address_rec.city;
   l_location_rec.state    := p_address_rec.state;
   l_location_rec.county   := p_address_rec.county;
   l_location_rec.country  := p_address_rec.country;
   l_location_rec.postal_code := p_address_rec.postal_code;
   l_location_rec.province := p_address_rec.province;
   l_location_rec.attribute_category := p_address_rec.Attribute_Category;
   l_location_rec.attribute1 := p_address_rec.Attribute1;
   l_location_rec.attribute2 := p_address_rec.Attribute2;
   l_location_rec.attribute3 := p_address_rec.Attribute3;
   l_location_rec.attribute4 := p_address_rec.Attribute4;
   l_location_rec.attribute5 := p_address_rec.Attribute5;
   l_location_rec.attribute6 := p_address_rec.Attribute6;
   l_location_rec.attribute7 := p_address_rec.Attribute7;
   l_location_rec.attribute8 := p_address_rec.Attribute8;
   l_location_rec.attribute9 := p_address_rec.Attribute9;
   l_location_rec.attribute10 := p_address_rec.Attribute10;
   l_location_rec.attribute11 := p_address_rec.Attribute11;
   l_location_rec.attribute12 := p_address_rec.Attribute12;
   l_location_rec.attribute13 := p_address_rec.Attribute13;
   l_location_rec.attribute14 := p_address_rec.Attribute14;
   l_location_rec.attribute15 := p_address_rec.Attribute15;
   l_location_rec.attribute16 := p_address_rec.Attribute16;
   l_location_rec.attribute17 := p_address_rec.Attribute17;
   l_location_rec.attribute18 := p_address_rec.Attribute18;
   l_location_rec.attribute19 := p_address_rec.Attribute19;
   l_location_rec.attribute20 := p_address_rec.Attribute20;
   l_location_rec.address_lines_phonetic := p_address_rec.Address_lines_phonetic;
   l_location_rec.po_box_number          := p_address_rec.Po_box_number;
   l_location_rec.house_number           := p_address_rec.House_number;
   l_location_rec.street_suffix          := p_address_rec.Street_suffix;
   l_location_rec.street                 := p_address_rec.Street;
   l_location_rec.street_number          := p_address_rec.Street_number;
   l_location_rec.floor                  := p_address_rec.Floor;
   l_location_rec.suite                  := p_address_rec.Suite;
   l_location_rec.timezone_id            := p_address_rec.Timezone_id;
   l_location_rec.address_effective_date := p_address_rec.address_effective_date;
   l_location_rec.address_expiration_date := p_address_rec.address_expiration_date;
   l_location_rec.address_style := p_address_rec.address_style;
   l_location_rec.created_by_module      := p_address_rec.created_by_module;
   l_location_rec.application_id         := p_address_rec.application_id;
   l_created_by_module                   := p_address_rec.created_by_module;
   l_application_id                      := p_address_rec.application_id;

     HZ_LOCATION_V2PUB.create_location (
     p_init_msg_list     => FND_API.G_FALSE,
     p_location_rec      => l_location_rec,
     x_location_id       => l_location_id,
     x_return_status     => l_return_status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data
	);

     x_return_status := l_return_status;
     x_msg_count     := l_msg_count;
     x_msg_data      := l_msg_data;

     If x_return_status = FND_API.G_RET_STS_SUCCESS Then
          x_location_id   := l_location_id;
		  /* Added for R12 Address Validation */
		  If (l_location_id is not null and
			 nvl(fnd_profile.value('AS_PERFORM_ADDRESS_VALIDATION'),'N')= 'Y') then
			  HZ_GNR_PUB.validateLoc(
			   p_location_id          => l_location_id,
			   p_init_msg_list        => FND_API.G_FALSE,
			   x_addr_val_level       => l_addr_val_level,
			   x_addr_warn_msg		  => l_addr_warn_msg,
			   x_addr_val_status      => l_addr_val_status,
			   x_return_status        => l_return_status,
			   x_msg_count            => l_msg_count,
			   x_msg_data             => l_msg_data);

			   x_return_status := l_return_status;
			   x_msg_count     := l_msg_count;
			   x_msg_data      := l_msg_data;
		END IF;
	 End If;

 End Create_Address;

 PROCEDURE Update_Address (
     p_address_rec           IN     AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE,
     p_object_version_number IN OUT NOCOPY NUMBER,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) Is

   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_loc_id    NUMBER;
   l_created_by_module VARCHAR2(150);
   l_application_id NUMBER;
   l_addr_val_level VARCHAR2(30);
   l_addr_val_status VARCHAR2(30);
   l_addr_warn_msg VARCHAR2(2000);
 Begin
   l_location_rec.address1 := p_address_rec.address1;
   l_location_rec.address2 := p_address_rec.address2;
   l_location_rec.address3 := p_address_rec.address3;
   l_location_rec.address4 := p_address_rec.address4;
   l_location_rec.location_id := p_address_rec.location_id;
   l_location_rec.city     := p_address_rec.city;
   l_location_rec.state    := p_address_rec.state;
   l_location_rec.county   := p_address_rec.county;
   l_location_rec.country  := p_address_rec.country;
   l_location_rec.postal_code := p_address_rec.postal_code;
   l_location_rec.province := p_address_rec.province;
   l_location_rec.attribute_category := p_address_rec.Attribute_Category;
   l_location_rec.attribute1 := p_address_rec.Attribute1;
   l_location_rec.attribute2 := p_address_rec.Attribute2;
   l_location_rec.attribute3 := p_address_rec.Attribute3;
   l_location_rec.attribute4 := p_address_rec.Attribute4;
   l_location_rec.attribute5 := p_address_rec.Attribute5;
   l_location_rec.attribute6 := p_address_rec.Attribute6;
   l_location_rec.attribute7 := p_address_rec.Attribute7;
   l_location_rec.attribute8 := p_address_rec.Attribute8;
   l_location_rec.attribute9 := p_address_rec.Attribute9;
   l_location_rec.attribute10 := p_address_rec.Attribute10;
   l_location_rec.attribute11 := p_address_rec.Attribute11;
   l_location_rec.attribute12 := p_address_rec.Attribute12;
   l_location_rec.attribute13 := p_address_rec.Attribute13;
   l_location_rec.attribute14 := p_address_rec.Attribute14;
   l_location_rec.attribute15 := p_address_rec.Attribute15;
   l_location_rec.attribute16 := p_address_rec.Attribute16;
   l_location_rec.attribute17 := p_address_rec.Attribute17;
   l_location_rec.attribute18 := p_address_rec.Attribute18;
   l_location_rec.attribute19 := p_address_rec.Attribute19;
   l_location_rec.attribute20 := p_address_rec.Attribute20;
   l_location_rec.address_lines_phonetic := p_address_rec.Address_lines_phonetic;
   l_location_rec.po_box_number          := p_address_rec.Po_box_number;
   l_location_rec.house_number           := p_address_rec.House_number;
   l_location_rec.street_suffix          := p_address_rec.Street_suffix;
   l_location_rec.street                 := p_address_rec.Street;
   l_location_rec.street_number          := p_address_rec.Street_number;
   l_location_rec.floor                  := p_address_rec.Floor;
   l_location_rec.suite                  := p_address_rec.Suite;
   l_location_rec.timezone_id            := p_address_rec.Timezone_id;
   l_location_rec.address_effective_date := p_address_rec.address_effective_date;
   l_location_rec.address_expiration_date := p_address_rec.address_expiration_date;
   l_location_rec.address_style := p_address_rec.address_style;
   l_location_rec.application_id          := p_address_rec.application_id;
   l_location_rec.created_by_module       := p_address_rec.created_by_module;
   l_created_by_module                    := p_address_rec.created_by_module;
   l_application_id                       := p_address_rec.application_id;

     HZ_LOCATION_V2PUB.update_location (
     p_init_msg_list         => FND_API.G_FALSE,
     p_location_rec          => l_location_rec,
     p_object_version_number => p_object_version_number,
     x_return_status         => l_return_status,
     x_msg_count             => l_msg_count,
     x_msg_data              => l_msg_data
	);

     x_return_status := l_return_status;
     x_msg_count     := l_msg_count;
     x_msg_data      := l_msg_data;
	If x_return_status = FND_API.G_RET_STS_SUCCESS AND
		nvl(fnd_profile.value('AS_PERFORM_ADDRESS_VALIDATION'),'N')= 'Y' then
	   /* Added for R12 Address Validation */
		HZ_GNR_PUB.validateLoc(
           p_location_id          => l_location_rec.location_id,
           p_init_msg_list        => FND_API.G_FALSE,
           x_addr_val_level       => l_addr_val_level,
		   x_addr_warn_msg		  => l_addr_warn_msg,
           x_addr_val_status      => l_addr_val_status,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data);

		   x_return_status := l_return_status;
		   x_msg_count     := l_msg_count;
		   x_msg_data      := l_msg_data;
	END IF;
End Update_Address;

END AST_PARTY_LOCATIONS_V2PUB;

/
