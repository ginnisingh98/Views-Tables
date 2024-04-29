--------------------------------------------------------
--  DDL for Package Body HZ_ORIG_SYSTEM_REF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORIG_SYSTEM_REF_PUB" AS
/*$Header: ARHPOSRB.pls 120.4 2006/05/31 12:24:23 idali noship $ */

--------------------------------------
-- declaration of procedures and functions
--------------------------------------

PROCEDURE get_orig_sys_entity_map_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_orig_system			    in varchar2,
    p_owner_table_name			    in varchar2,
    x_orig_sys_entity_map_rec               OUT    NOCOPY ORIG_SYS_ENTITY_MAP_REC_TYPE,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) IS
l_orig_system varchar2(30) := p_orig_system;
l_owner_table_name varchar2(30) := p_owner_table_name;
l_object_version_number number;
BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF (p_orig_system IS NULL OR
       p_orig_system  = FND_API.G_MISS_CHAR) and
       (p_owner_table_name IS NULL OR
       p_owner_table_name  = FND_API.G_MISS_CHAR)
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+owner_table_name');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    HZ_ORIG_SYS_ENTITY_MAP_PKG.Select_Row (
      x_orig_system                           => l_orig_system,
      x_owner_table_name                      => l_owner_table_name,
      x_status                                => x_orig_sys_entity_map_rec.status,
      x_multiple_flag                         => x_orig_sys_entity_map_rec.multiple_flag,
--raji
      x_multi_osr_flag                        => x_orig_sys_entity_map_rec.multi_osr_flag,
      x_object_version_number                 => l_object_version_number,
      x_created_by_module                     => x_orig_sys_entity_map_rec.created_by_module,
      x_application_id                        => x_orig_sys_entity_map_rec.application_id,
      x_attribute_category                    => x_orig_sys_entity_map_rec.attribute_category,
      x_attribute1                            => x_orig_sys_entity_map_rec.attribute1,
      x_attribute2                            => x_orig_sys_entity_map_rec.attribute2,
      x_attribute3                            => x_orig_sys_entity_map_rec.attribute3,
      x_attribute4                            => x_orig_sys_entity_map_rec.attribute4,
      x_attribute5                            => x_orig_sys_entity_map_rec.attribute5,
      x_attribute6                            => x_orig_sys_entity_map_rec.attribute6,
      x_attribute7                            => x_orig_sys_entity_map_rec.attribute7,
      x_attribute8                            => x_orig_sys_entity_map_rec.attribute8,
      x_attribute9                            => x_orig_sys_entity_map_rec.attribute9,
      x_attribute10                           => x_orig_sys_entity_map_rec.attribute10,
      x_attribute11                           => x_orig_sys_entity_map_rec.attribute11,
      x_attribute12                           => x_orig_sys_entity_map_rec.attribute12,
      x_attribute13                           => x_orig_sys_entity_map_rec.attribute13,
      x_attribute14                           => x_orig_sys_entity_map_rec.attribute14,
      x_attribute15                           => x_orig_sys_entity_map_rec.attribute15,
      x_attribute16                           => x_orig_sys_entity_map_rec.attribute16,
      x_attribute17                           => x_orig_sys_entity_map_rec.attribute17,
      x_attribute18                           => x_orig_sys_entity_map_rec.attribute18,
      x_attribute19                           => x_orig_sys_entity_map_rec.attribute19,
      x_attribute20                           => x_orig_sys_entity_map_rec.attribute20
    );

    x_orig_sys_entity_map_rec.orig_system := l_orig_system;
    x_orig_sys_entity_map_rec.owner_table_name := l_owner_table_name;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

END get_orig_sys_entity_map_rec;


PROCEDURE get_orig_sys_reference_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_orig_system_ref_id		    in number,
    x_orig_sys_reference_rec               OUT    NOCOPY ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) is
l_object_version_number number;
BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF (p_orig_system_ref_id IS NULL OR
       p_orig_system_ref_id  = FND_API.G_MISS_NUM)
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system_ref_id');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_ORIG_SYSTEM_REF_PKG.Select_Row (
      x_orig_system_ref_id                    => x_orig_sys_reference_rec.orig_system_ref_id,
      x_orig_system                           => x_orig_sys_reference_rec.orig_system,
      x_orig_system_reference                 => x_orig_sys_reference_rec.orig_system_reference,
      x_owner_table_name                      => x_orig_sys_reference_rec.owner_table_name,
      x_owner_table_id                        => x_orig_sys_reference_rec.owner_table_id,
--raji
      x_party_id                              => x_orig_sys_reference_rec.party_id,
      x_status                                => x_orig_sys_reference_rec.status,
      x_reason_code                           => x_orig_sys_reference_rec.reason_code,
      x_old_orig_system_reference              => x_orig_sys_reference_rec.old_orig_system_reference,
      x_start_date_active                     => x_orig_sys_reference_rec.start_date_active,
      x_end_date_active                       => x_orig_sys_reference_rec.end_date_active,
      x_object_version_number                 => l_object_version_number,
      x_created_by_module                     => x_orig_sys_reference_rec.created_by_module,
      x_application_id                        => x_orig_sys_reference_rec.application_id,
      x_attribute_category                    => x_orig_sys_reference_rec.attribute_category,
      x_attribute1                            => x_orig_sys_reference_rec.attribute1,
      x_attribute2                            => x_orig_sys_reference_rec.attribute2,
      x_attribute3                            => x_orig_sys_reference_rec.attribute3,
      x_attribute4                            => x_orig_sys_reference_rec.attribute4,
      x_attribute5                            => x_orig_sys_reference_rec.attribute5,
      x_attribute6                            => x_orig_sys_reference_rec.attribute6,
      x_attribute7                            => x_orig_sys_reference_rec.attribute7,
      x_attribute8                            => x_orig_sys_reference_rec.attribute8,
      x_attribute9                            => x_orig_sys_reference_rec.attribute9,
      x_attribute10                           => x_orig_sys_reference_rec.attribute10,
      x_attribute11                           => x_orig_sys_reference_rec.attribute11,
      x_attribute12                           => x_orig_sys_reference_rec.attribute12,
      x_attribute13                           => x_orig_sys_reference_rec.attribute13,
      x_attribute14                           => x_orig_sys_reference_rec.attribute14,
      x_attribute15                           => x_orig_sys_reference_rec.attribute15,
      x_attribute16                           => x_orig_sys_reference_rec.attribute16,
      x_attribute17                           => x_orig_sys_reference_rec.attribute17,
      x_attribute18                           => x_orig_sys_reference_rec.attribute18,
      x_attribute19                           => x_orig_sys_reference_rec.attribute19,
      x_attribute20                           => x_orig_sys_reference_rec.attribute20
    );
      --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

END get_orig_sys_reference_rec;

/* Public API */
PROCEDURE create_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_orig_sys_reference_rec	  IN      ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
) is
l_orig_sys_reference_rec ORIG_SYS_REFERENCE_REC_TYPE := p_orig_sys_reference_rec;
l_object_version_number number;
begin
    -- standard start of API savepoint
    SAVEPOINT create_orig_sys_reference;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    HZ_ORIG_SYSTEM_REF_PVT.create_orig_system_reference(
			FND_API.G_FALSE,
			FND_API.G_VALID_LEVEL_FULL,
			p_orig_sys_reference_rec,
			x_return_status,
		        x_msg_count,
		        x_msg_data);
    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_orig_sys_reference;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_orig_sys_reference;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_orig_sys_reference;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

end create_orig_system_reference;

/* Public API */
PROCEDURE update_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_orig_sys_reference_rec       IN      ORIG_SYS_REFERENCE_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
)is
l_object_version_number number:= p_object_version_number;
l_orig_sys_reference_rec ORIG_SYS_REFERENCE_REC_TYPE := p_orig_sys_reference_rec;
begin

    -- standard start of API savepoint
    SAVEPOINT update_orig_sys_reference;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    HZ_ORIG_SYSTEM_REF_PVT.update_orig_system_reference(
			FND_API.G_FALSE,
			FND_API.G_VALID_LEVEL_FULL,
			p_orig_sys_reference_rec,
			p_object_version_number,
			x_return_status,
		        x_msg_count,
		        x_msg_data);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_orig_sys_reference;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_orig_sys_reference;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_orig_sys_reference;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

end update_orig_system_reference;

/* public api */
PROCEDURE  remap_internal_identifier(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_old_owner_table_id     IN  NUMBER,
    p_new_owner_table_id     IN  NUMBER,
    p_owner_table_name  IN VARCHAR2,
    p_orig_system IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    p_reason_code IN VARCHAR2,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data		OUT     NOCOPY 	VARCHAR2
) is

begin
	HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
				p_init_msg_list => FND_API.G_FALSE,
			        p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
				p_old_owner_table_id   => p_old_owner_table_id,
				p_new_owner_table_id   => p_new_owner_table_id,
				p_owner_table_name  =>p_owner_table_name,
				p_orig_system =>p_orig_system,
				p_orig_system_reference => p_orig_system_reference,
				p_reason_code => p_reason_code,
				x_return_status => x_return_status,
				x_msg_count =>x_msg_count,
				x_msg_data  =>x_msg_data);
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

end remap_internal_identifier;

procedure get_owner_table_id(p_orig_system in varchar2,
			p_orig_system_reference in varchar2,
			 p_owner_table_name in varchar2,
			x_owner_table_id out nocopy number,
			x_return_status out nocopy varchar2)
is
	cursor get_owner_table_id_csr is
	SELECT OWNER_TABLE_ID
        FROM   HZ_ORIG_SYS_REFERENCES
        WHERE  ORIG_SYSTEM = p_orig_system
	and ORIG_SYSTEM_REFERENCE = p_orig_system_reference
	and owner_table_name = p_owner_table_name
	and status = 'A';

l_owner_table_id number;
l_count number;
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_count :=hz_mosr_validate_pkg.get_orig_system_ref_count(p_orig_system,
				p_orig_system_reference,p_owner_table_name);
	if l_count > 1
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_MOSR_CANNOT_UPDATE');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
	elsif l_count = 0
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference');
		FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
	elsif l_count = 1
	then
		open get_owner_table_id_csr;
		fetch get_owner_table_id_csr into l_owner_table_id;
		close get_owner_table_id_csr;
		x_owner_table_id := l_owner_table_id;
	end if;
end get_owner_table_id;


END HZ_ORIG_SYSTEM_REF_PUB;

/
