--------------------------------------------------------
--  DDL for Package Body HZ_ORIG_SYSTEM_REF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORIG_SYSTEM_REF_PVT" AS
/*$Header: ARHMOSRB.pls 120.29.12010000.2 2009/06/25 12:33:35 rgokavar ship $ */

--------------------------------------
-- declaration of procedures and functions
--------------------------------------
-- VJN Introduced function for doing the SST check
-- that would be used by DQM SYNC
/*
 * SSM SST Integration and Extension
 *
 * This function need not be called for non-profile entities as the concept of select/de-select
 *  datasource is obsoleted for non-profile entities.
 *
 * For profile entities, DQM sync considers SST record only.
 * Thus this function is not required at all.
 *
FUNCTION sst_rules_passed (
    p_owner_table_name                 IN     VARCHAR2,
    p_owner_table_id                   IN     NUMBER
) RETURN BOOLEAN
IS
g_entity_attr_id        NUMBER ;
g_mixnmatch_enabled     VARCHAR2(1) ;
g_selected_datasources  VARCHAR2(1000) ;
g_is_datasource_selected VARCHAR2(1);
db_actual_content_source VARCHAR2(30) ;
prim_key_column VARCHAR2(30);
counter NUMBER := 0 ;
p_sql_str VARCHAR2(3200);
l_owner_table_name VARCHAR2(30);
BEGIN
  -- Resolve passed in owner table name according to HZ conventions

  IF p_owner_table_name = 'HZ_PARTY_SITES' then
     l_owner_table_name := 'HZ_LOCATIONS';
  ELSIF p_owner_table_name = 'HZ_FINANCIAL_NUMBERS' then
     l_owner_table_name := 'HZ_FINANCIAL_REPORTS';
  ELSE
     l_owner_table_name := p_owner_table_name;
  END IF ;
  -- Find Selected DataSources
  HZ_MIXNM_UTILITY.LoadDataSources(
    p_entity_name                      => l_owner_table_name,
    p_entity_attr_id                   => g_entity_attr_id,
    p_mixnmatch_enabled                => g_mixnmatch_enabled,
    p_selected_datasources             => g_selected_datasources );

  -- IF mix and match is enabled
  IF g_mixnmatch_enabled = 'Y'
  THEN
            -- Find Primary Key Column
            FOR p_cur in
            ( select b.column_name as col_name
              from fnd_tables a, fnd_columns b, fnd_primary_key_columns c
              where a.table_name = p_owner_table_name
              and a.table_id = b.table_id
              and b.column_id = c.column_id
             )
            LOOP
                counter := counter + 1 ;
                prim_key_column := p_cur.col_name ;
                IF counter > 1
                THEN
                    EXIT ;
                END IF ;
            END LOOP ;


           -- Find Actual Content Source using a dynamic anonymous PLSQL block
            p_sql_str := 'select actual_content_source from '
                         || p_owner_table_name || ' where ' || prim_key_column || ' = ' || p_owner_table_id ;
            EXECUTE IMMEDIATE p_sql_str into db_actual_content_source ;


            -- See if DataSource is Selected for SST
            g_is_datasource_selected :=
            HZ_MIXNM_UTILITY.isDataSourceSelected (
              p_selected_datasources           => g_selected_datasources ,
              p_actual_content_source          => db_actual_content_source);
    END IF;

    IF g_mixnmatch_enabled = 'Y' and g_is_datasource_selected = 'Y'
    THEN
       RETURN TRUE ;
    ELSE
       RETURN FALSE ;
    END IF ;

END ;
*/

-- Function to get the Source system count that is displayed in the DL UI
function get_source_system_count(p_owner_table_name In VARCHAR2, p_owner_table_id In NUMBER) return number
is

   cursor get_pps_ssc_csr is
   select count(*)
   from hz_orig_sys_references
   where Owner_table_name = p_owner_table_name
     and owner_table_id = p_owner_table_id
     and status = 'A';

   cursor get_rel_ssc_csr is
   select count(*)
    from hz_orig_sys_references os,hz_org_contacts org
    where os.owner_table_id = org.org_contact_id
      and os.owner_table_name = p_owner_table_name
      and org.org_contact_id =  p_owner_table_id
      and os.status = 'A';

l_count Number;

begin

if p_owner_table_name = 'HZ_PARTIES' OR p_owner_table_name = 'HZ_PARTY_SITES' then
   open get_pps_ssc_csr;
   fetch get_pps_ssc_csr into l_count;
   close get_pps_ssc_csr;

elsif p_owner_table_name = 'HZ_ORG_CONTACTS' then
   open get_rel_ssc_csr;
   fetch get_rel_ssc_csr into l_count;
   close get_rel_ssc_csr;

end if;

return l_count;

End get_source_system_count;





PROCEDURE get_orig_sys_reference_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_orig_system_ref_id		    in number,
    x_orig_sys_reference_rec               OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) is
l_object_version_number number;
l_orig_system_ref_id number := p_orig_system_ref_id;
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
      x_orig_system_ref_id                    => l_orig_system_ref_id,
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
      x_orig_sys_reference_rec.orig_system_ref_id := l_orig_system_ref_id;

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


PROCEDURE do_create_orig_sys_entity_map(
    p_orig_sys_entity_map_rec        IN OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) is
begin

     --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     if p_validation_level = FND_API.G_VALID_LEVEL_FULL
     then
	HZ_MOSR_VALIDATE_PKG.VALIDATE_ORIG_SYS_ENTITY_MAP ('C',
					p_orig_sys_entity_map_rec,
					x_return_status);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
     end if;

	HZ_ORIG_SYS_ENTITY_MAP_PKG.Insert_Row (
      x_orig_system                           => p_orig_sys_entity_map_rec.orig_system,
      x_owner_table_name                      => p_orig_sys_entity_map_rec.owner_table_name,
      x_status                                => p_orig_sys_entity_map_rec.status,
      x_multiple_flag                         => p_orig_sys_entity_map_rec.multiple_flag,
--raji
      x_multi_osr_flag                        => p_orig_sys_entity_map_rec.multi_osr_flag,
      x_object_version_number                 => 1,
      x_created_by_module                     => p_orig_sys_entity_map_rec.created_by_module,
      x_application_id                        => p_orig_sys_entity_map_rec.application_id,
      x_attribute_category                    => p_orig_sys_entity_map_rec.attribute_category,
      x_attribute1                            => p_orig_sys_entity_map_rec.attribute1,
      x_attribute2                            => p_orig_sys_entity_map_rec.attribute2,
      x_attribute3                            => p_orig_sys_entity_map_rec.attribute3,
      x_attribute4                            => p_orig_sys_entity_map_rec.attribute4,
      x_attribute5                            => p_orig_sys_entity_map_rec.attribute5,
      x_attribute6                            => p_orig_sys_entity_map_rec.attribute6,
      x_attribute7                            => p_orig_sys_entity_map_rec.attribute7,
      x_attribute8                            => p_orig_sys_entity_map_rec.attribute8,
      x_attribute9                            => p_orig_sys_entity_map_rec.attribute9,
      x_attribute10                           => p_orig_sys_entity_map_rec.attribute10,
      x_attribute11                           => p_orig_sys_entity_map_rec.attribute11,
      x_attribute12                           => p_orig_sys_entity_map_rec.attribute12,
      x_attribute13                           => p_orig_sys_entity_map_rec.attribute13,
      x_attribute14                           => p_orig_sys_entity_map_rec.attribute14,
      x_attribute15                           => p_orig_sys_entity_map_rec.attribute15,
      x_attribute16                           => p_orig_sys_entity_map_rec.attribute16,
      x_attribute17                           => p_orig_sys_entity_map_rec.attribute17,
      x_attribute18                           => p_orig_sys_entity_map_rec.attribute18,
      x_attribute19                           => p_orig_sys_entity_map_rec.attribute19,
      x_attribute20                           => p_orig_sys_entity_map_rec.attribute20
    );
end do_create_orig_sys_entity_map;

PROCEDURE do_update_orig_sys_entity_map(
    p_orig_sys_entity_map_rec        IN OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) is
l_object_version_number             NUMBER;
begin

     --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER
        INTO   l_object_version_number
        FROM   HZ_ORIG_SYS_MAPPING
        WHERE  ORIG_SYSTEM = p_orig_sys_entity_map_rec.orig_system
	and owner_table_name = p_orig_sys_entity_map_rec.owner_table_name
        FOR UPDATE OF ORIG_SYSTEM NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is
null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_MAPPING');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_ORIG_SYS_MAPPING');
        FND_MESSAGE.SET_TOKEN('VALUE', p_orig_sys_entity_map_rec.orig_system);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;
   if p_validation_level = FND_API.G_VALID_LEVEL_FULL
   then
    -- call for validations.
        HZ_MOSR_VALIDATE_PKG.VALIDATE_ORIG_SYS_ENTITY_MAP ('U',
                                        p_orig_sys_entity_map_rec,
                                        x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;
   end if;
   -- call table handler


    HZ_ORIG_SYS_ENTITY_MAP_PKG.Update_Row (
      x_orig_system                           => p_orig_sys_entity_map_rec.orig_system,
      x_owner_table_name                      => p_orig_sys_entity_map_rec.owner_table_name,
      x_status                                => p_orig_sys_entity_map_rec.status,
      x_multiple_flag                         => p_orig_sys_entity_map_rec.multiple_flag,
--raji
      x_multi_osr_flag                        => p_orig_sys_entity_map_rec.multi_osr_flag,
      x_object_version_number                 => l_object_version_number,
      x_created_by_module                     => p_orig_sys_entity_map_rec.created_by_module,
      x_application_id                        => p_orig_sys_entity_map_rec.application_id,
      x_attribute_category                    => p_orig_sys_entity_map_rec.attribute_category,
      x_attribute1                            => p_orig_sys_entity_map_rec.attribute1,
      x_attribute2                            => p_orig_sys_entity_map_rec.attribute2,
      x_attribute3                            => p_orig_sys_entity_map_rec.attribute3,
      x_attribute4                            => p_orig_sys_entity_map_rec.attribute4,
      x_attribute5                            => p_orig_sys_entity_map_rec.attribute5,
      x_attribute6                            => p_orig_sys_entity_map_rec.attribute6,
      x_attribute7                            => p_orig_sys_entity_map_rec.attribute7,
      x_attribute8                            => p_orig_sys_entity_map_rec.attribute8,
      x_attribute9                            => p_orig_sys_entity_map_rec.attribute9,
      x_attribute10                           => p_orig_sys_entity_map_rec.attribute10,
      x_attribute11                           => p_orig_sys_entity_map_rec.attribute11,
      x_attribute12                           => p_orig_sys_entity_map_rec.attribute12,
      x_attribute13                           => p_orig_sys_entity_map_rec.attribute13,
      x_attribute14                           => p_orig_sys_entity_map_rec.attribute14,
      x_attribute15                           => p_orig_sys_entity_map_rec.attribute15,
      x_attribute16                           => p_orig_sys_entity_map_rec.attribute16,
      x_attribute17                           => p_orig_sys_entity_map_rec.attribute17,
      x_attribute18                           => p_orig_sys_entity_map_rec.attribute18,
      x_attribute19                           => p_orig_sys_entity_map_rec.attribute19,
      x_attribute20                           => p_orig_sys_entity_map_rec.attribute20
    );
end do_update_orig_sys_entity_map;

/* This is private API and should be only called in HTML admin UI */
PROCEDURE create_orig_sys_entity_mapping(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_entity_map_rec	IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
) is
l_orig_sys_entity_map_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE :=  p_orig_sys_entity_map_rec;

begin
	    -- standard start of API savepoint
    SAVEPOINT create_orig_sys_entity_mapping;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_orig_sys_entity_map(
	l_orig_sys_entity_map_rec,
        p_validation_level,
	x_return_status );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_orig_sys_entity_mapping;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_orig_sys_entity_mapping;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_orig_sys_entity_mapping;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
end create_orig_sys_entity_mapping;

/* This is private API and should be only called in HTML admin UI */
PROCEDURE update_orig_sys_entity_mapping(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_entity_map_rec	IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
) is
l_orig_sys_entity_map_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE := p_orig_sys_entity_map_rec;
begin

    -- standard start of API savepoint
    SAVEPOINT update_orig_sys_entity_mapping;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_update_orig_sys_entity_map(
        l_orig_sys_entity_map_rec,
        p_validation_level,
	p_object_version_number,
        x_return_status );

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_orig_sys_entity_mapping;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_orig_sys_entity_mapping;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_orig_sys_entity_mapping;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

end update_orig_sys_entity_mapping;

PROCEDURE do_create_orig_sys_reference(
    p_orig_sys_reference_rec        IN OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) is
l_dummy VARCHAR2(32);
l_status VARCHAR2(1);
begin

    --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_validation_level = FND_API.G_VALID_LEVEL_FULL
   then
	HZ_MOSR_VALIDATE_PKG.VALIDATE_ORIG_SYS_REFERENCE ('C',
					p_orig_sys_reference_rec,
					x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
   end if;
   if (p_orig_sys_reference_rec.end_date_active is not null
		and p_orig_sys_reference_rec.end_date_active <>fnd_api.g_miss_date
		and p_orig_sys_reference_rec.end_date_active <= sysdate)
   then
	p_orig_sys_reference_rec.status := 'I';
   else p_orig_sys_reference_rec.status := 'A';
   end if;

	HZ_ORIG_SYSTEM_REF_PKG.Insert_Row (
      x_orig_system_ref_id                    => p_orig_sys_reference_rec.orig_system_ref_id,
      x_orig_system                           => p_orig_sys_reference_rec.orig_system,
      x_orig_system_reference                 => p_orig_sys_reference_rec.orig_system_reference,
      x_owner_table_name                      => p_orig_sys_reference_rec.owner_table_name,
      x_owner_table_id                        => p_orig_sys_reference_rec.owner_table_id,
--raji
      x_party_id                              => p_orig_sys_reference_rec.party_id,
      x_status                                => p_orig_sys_reference_rec.status,
      x_reason_code                           => p_orig_sys_reference_rec.reason_code,
      x_old_orig_system_reference              => p_orig_sys_reference_rec.old_orig_system_reference,
      x_start_date_active                     => p_orig_sys_reference_rec.start_date_active,
      x_end_date_active                       => p_orig_sys_reference_rec.end_date_active,
      x_object_version_number                 => 1,
      x_created_by_module                     => p_orig_sys_reference_rec.created_by_module,
      x_application_id                        => p_orig_sys_reference_rec.application_id,
      x_attribute_category                    => p_orig_sys_reference_rec.attribute_category,
      x_attribute1                            => p_orig_sys_reference_rec.attribute1,
      x_attribute2                            => p_orig_sys_reference_rec.attribute2,
      x_attribute3                            => p_orig_sys_reference_rec.attribute3,
      x_attribute4                            => p_orig_sys_reference_rec.attribute4,
      x_attribute5                            => p_orig_sys_reference_rec.attribute5,
      x_attribute6                            => p_orig_sys_reference_rec.attribute6,
      x_attribute7                            => p_orig_sys_reference_rec.attribute7,
      x_attribute8                            => p_orig_sys_reference_rec.attribute8,
      x_attribute9                            => p_orig_sys_reference_rec.attribute9,
      x_attribute10                           => p_orig_sys_reference_rec.attribute10,
      x_attribute11                           => p_orig_sys_reference_rec.attribute11,
      x_attribute12                           => p_orig_sys_reference_rec.attribute12,
      x_attribute13                           => p_orig_sys_reference_rec.attribute13,
      x_attribute14                           => p_orig_sys_reference_rec.attribute14,
      x_attribute15                           => p_orig_sys_reference_rec.attribute15,
      x_attribute16                           => p_orig_sys_reference_rec.attribute16,
      x_attribute17                           => p_orig_sys_reference_rec.attribute17,
      x_attribute18                           => p_orig_sys_reference_rec.attribute18,
      x_attribute19                           => p_orig_sys_reference_rec.attribute19,
      x_attribute20                           => p_orig_sys_reference_rec.attribute20
    );

     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
           HZ_BUSINESS_EVENT_V2PVT.create_orig_system_ref_event(p_orig_sys_reference_rec);
     END IF;





IF p_orig_sys_reference_rec.owner_table_name = 'HZ_PARTIES'
THEN
    BEGIN
        -- SSM SST Integration and Extension
	-- Checking SST rules is now applicable only for profile entities.
	-- However as DQM sync considers SST record for profiles, therefore commenting out call to
	-- sst_rules_passed altogether.


        -- VJN Introduced change to make sure that source system reference information gets
        -- DQM SYNCED.

        -- SYNC PARTIES ONLY IF SST RULES PASS

/*         IF sst_rules_passed (p_orig_sys_reference_rec.owner_table_name, p_orig_sys_reference_rec.owner_table_id)
         THEN*/
             select party_type into l_dummy
             from hz_parties
             where party_id = p_orig_sys_reference_rec.owner_table_id ;

             IF l_dummy = 'ORGANIZATION'
             THEN
                 HZ_DQM_SYNC.sync_org(p_orig_sys_reference_rec.owner_table_id, 'U' );
             ELSIF l_dummy = 'PERSON'
             THEN
                 HZ_DQM_SYNC.sync_person(p_orig_sys_reference_rec.owner_table_id, 'U' );
             END IF;
--        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
            fnd_message.set_token('FK', 'party_id');
            fnd_message.set_token('COLUMN', 'party_id');
            fnd_message.set_token('TABLE', 'hz_parties');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;

    END;

-- SYNC PARTY SITES
ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_PARTY_SITES'
THEN
   BEGIN--bug 6069559
   SELECT status INTO l_status FROM hz_party_sites WHERE party_site_id=p_orig_sys_reference_rec.owner_table_id ;

   IF l_status Is NULL OR l_status = 'A' OR l_status = 'I' THEN
   HZ_DQM_SYNC.sync_party_site(p_orig_sys_reference_rec.owner_table_id  ,'U') ;
   END IF;
   EXCEPTION
   WHEN No_Data_Found THEN
   NULL;
   END;

-- SYNC CONTACTS
ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_ORG_CONTACTS'
THEN
   BEGIN--bug 6069559
   SELECT status INTO l_status FROM HZ_ORG_CONTACTS WHERE org_contact_id=p_orig_sys_reference_rec.owner_table_id;

   IF l_status Is NULL OR l_status = 'A' OR l_status = 'I' THEN
   HZ_DQM_SYNC.sync_contact(p_orig_sys_reference_rec.owner_table_id,'U') ;
   END IF;
   EXCEPTION
   WHEN No_Data_Found THEN
   NULL;
   END;

-- SYNC CONTACT POINTS
ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CONTACT_POINTS'
THEN
   BEGIN--bug 6069559
   SELECT status INTO l_status FROM hz_contact_points  WHERE contact_point_id=p_orig_sys_reference_rec.owner_table_id;

   IF l_status Is NULL OR l_status = 'A' OR l_status = 'I' THEN
   HZ_DQM_SYNC.sync_contact_point(p_orig_sys_reference_rec.owner_table_id,'U') ;
   END IF;
   EXCEPTION
   WHEN No_Data_Found THEN
   NULL;
   END;

END IF;


end do_create_orig_sys_reference;

/* this function is called only if owner_table_id is unique */
function get_orig_system_ref_id(p_orig_system in varchar2,
p_orig_system_reference in varchar2, p_owner_table_name in varchar2) return varchar2
is
	cursor get_orig_sys_ref_id_csr is
	SELECT ORIG_SYSTEM_REF_ID
        FROM   HZ_ORIG_SYS_REFERENCES
        WHERE  ORIG_SYSTEM = p_orig_system
	and ORIG_SYSTEM_REFERENCE = p_orig_system_reference
	and owner_table_name = p_owner_table_name
	and status = 'A';

l_orig_system_ref_id number;
begin
	open get_orig_sys_ref_id_csr;
	fetch get_orig_sys_ref_id_csr into l_orig_system_ref_id;
	close get_orig_sys_ref_id_csr;
	return l_orig_system_ref_id;
end get_orig_system_ref_id;
function get_start_date_active(p_orig_system in varchar2,
p_orig_system_reference in varchar2, p_owner_table_name in varchar2) return date
is
	cursor get_start_date_csr is
	SELECT start_date_active
        FROM   HZ_ORIG_SYS_REFERENCES
        WHERE  ORIG_SYSTEM = p_orig_system
	and ORIG_SYSTEM_REFERENCE = p_orig_system_reference
	and owner_table_name = p_owner_table_name
	and rownum = 1; -- start/end_date_active only used in update and
                                -- only if unique, we allow update.
				-- for created_by_module and appl_id, since we
                                -- are same for same system, no matter unique/no unique

l_date date;
begin
	open get_start_date_csr;
	fetch get_start_date_csr into l_date;
	close get_start_date_csr;
	return l_date;
end get_start_date_active;

PROCEDURE do_update_orig_sys_reference(
    p_orig_sys_reference_rec        IN OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
     p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) is
	cursor get_pk_by_owner_id is
		SELECT ORIG_SYSTEM_REF_ID
		FROM   HZ_ORIG_SYS_REFERENCES
		WHERE  ORIG_SYSTEM = p_orig_sys_reference_rec.orig_system
		and ORIG_SYSTEM_REFERENCE = p_orig_sys_reference_rec.orig_system_reference
		and owner_table_name = p_orig_sys_reference_rec.owner_table_name
		and owner_table_id = p_orig_sys_reference_rec.owner_table_id
		and status = 'A';
l_object_version_number             NUMBER;
l_orig_system_ref_id                NUMBER;
l_orig_system                       VARCHAR2(30);
l_orig_system_reference             VARCHAR2(255);
l_orig_sys_reference_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE := p_orig_sys_reference_rec;
l_old_orig_sys_reference_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
l_msg_count number;
l_msg_data varchar2(2000);
l_count number;
l_dummy varchar2(32);
l_temp varchar2(255);
l_status VARCHAR2(1);
begin
	  -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    if (p_orig_sys_reference_rec.owner_table_id is not null
	and p_orig_sys_reference_rec.owner_table_id<>fnd_api.g_miss_num)
    then
	open get_pk_by_owner_id;
	fetch get_pk_by_owner_id into l_orig_system_ref_id;
	close get_pk_by_owner_id;
        if l_orig_system_ref_id is null
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference+owner_table_id');
		FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	end if;
    end if;
    if (p_orig_sys_reference_rec.orig_system_ref_id is not null
	and p_orig_sys_reference_rec.orig_system_ref_id<>fnd_api.g_miss_num)
    then
	if nvl(l_orig_system_ref_id,p_orig_sys_reference_rec.orig_system_ref_id)<>p_orig_sys_reference_rec.orig_system_ref_id
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference+owner_table_id+orig_system_ref_id');
		FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	end if;
	l_orig_system_ref_id := p_orig_sys_reference_rec.orig_system_ref_id;
    end if;

    if l_orig_system_ref_id is null
    then
	l_count :=hz_mosr_validate_pkg.get_orig_system_ref_count(p_orig_sys_reference_rec.orig_system,
				p_orig_sys_reference_rec.orig_system_reference,p_orig_sys_reference_rec.owner_table_name);
	if l_count > 1
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_MOSR_CANNOT_UPDATE');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	elsif l_count = 0
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference');
		FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	elsif l_count = 1
	then
	   l_orig_system_ref_id :=get_orig_system_ref_id(p_orig_sys_reference_rec.orig_system,
						p_orig_sys_reference_rec.orig_system_reference,
						p_orig_sys_reference_rec.owner_table_name);
	end if;
    end if;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ORIG_SYSTEM,
               ORIG_SYSTEM_REFERENCE
        INTO   l_object_version_number,
               l_orig_system,
               l_orig_system_reference
        FROM   HZ_ORIG_SYS_REFERENCES
        WHERE  orig_system_ref_id = l_orig_system_ref_id
        FOR UPDATE OF ORIG_SYSTEM NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
            FND_MSG_PUB.ADD;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_ORIG_SYS_REFERENCES');
        FND_MESSAGE.SET_TOKEN('VALUE', l_orig_system_ref_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

-- Bug 4206884: Raise an error if orig_system_reference of a purchased content source is updated
   if p_orig_sys_reference_rec.orig_system_reference is not null and
      p_orig_sys_reference_rec.orig_system_reference <> fnd_api.g_miss_char and
      p_orig_sys_reference_rec.orig_system_reference <> l_orig_system_reference
   then
      if HZ_UTILITY_V2PUB.is_purchased_content_source(l_orig_system) = 'Y'
      then
       FND_MESSAGE.SET_NAME('AR', 'HZ_SSM_NO_UPDATE_PUR');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;
   end if;

   if p_validation_level = FND_API.G_VALID_LEVEL_FULL
   then
    -- call for validations.
        HZ_MOSR_VALIDATE_PKG.VALIDATE_ORIG_SYS_REFERENCE ('U',
                                        p_orig_sys_reference_rec,
                                        x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;
  end if;

  if (p_orig_sys_reference_rec.end_date_active is not null
		and p_orig_sys_reference_rec.end_date_active <>fnd_api.g_miss_date
		and p_orig_sys_reference_rec.end_date_active <= sysdate)
  then
	p_orig_sys_reference_rec.status := 'I';
  else p_orig_sys_reference_rec.status := 'A';
  end if;

   -- call table handler
    HZ_ORIG_SYSTEM_REF_PKG.Update_Row (
      x_orig_system_ref_id                    => l_orig_system_ref_id,
      x_orig_system                           => p_orig_sys_reference_rec.orig_system,
      x_orig_system_reference                 => p_orig_sys_reference_rec.orig_system_reference,
      x_owner_table_name                      => p_orig_sys_reference_rec.owner_table_name,
      x_owner_table_id                        => p_orig_sys_reference_rec.owner_table_id,
--raji
      x_party_id                              => p_orig_sys_reference_rec.party_id,
      x_status                                => p_orig_sys_reference_rec.status,
      x_reason_code                           => p_orig_sys_reference_rec.reason_code,
      x_old_orig_system_reference              => p_orig_sys_reference_rec.old_orig_system_reference,
      x_start_date_active                     => p_orig_sys_reference_rec.start_date_active,
      x_end_date_active                       => p_orig_sys_reference_rec.end_date_active,
      x_object_version_number                 => p_object_version_number,
      x_created_by_module                     => p_orig_sys_reference_rec.created_by_module,
      x_application_id                        => p_orig_sys_reference_rec.application_id,
      x_attribute_category                    => p_orig_sys_reference_rec.attribute_category,
      x_attribute1                            => p_orig_sys_reference_rec.attribute1,
      x_attribute2                            => p_orig_sys_reference_rec.attribute2,
      x_attribute3                            => p_orig_sys_reference_rec.attribute3,
      x_attribute4                            => p_orig_sys_reference_rec.attribute4,
      x_attribute5                            => p_orig_sys_reference_rec.attribute5,
      x_attribute6                            => p_orig_sys_reference_rec.attribute6,
      x_attribute7                            => p_orig_sys_reference_rec.attribute7,
      x_attribute8                            => p_orig_sys_reference_rec.attribute8,
      x_attribute9                            => p_orig_sys_reference_rec.attribute9,
      x_attribute10                           => p_orig_sys_reference_rec.attribute10,
      x_attribute11                           => p_orig_sys_reference_rec.attribute11,
      x_attribute12                           => p_orig_sys_reference_rec.attribute12,
      x_attribute13                           => p_orig_sys_reference_rec.attribute13,
      x_attribute14                           => p_orig_sys_reference_rec.attribute14,
      x_attribute15                           => p_orig_sys_reference_rec.attribute15,
      x_attribute16                           => p_orig_sys_reference_rec.attribute16,
      x_attribute17                           => p_orig_sys_reference_rec.attribute17,
      x_attribute18                           => p_orig_sys_reference_rec.attribute18,
      x_attribute19                           => p_orig_sys_reference_rec.attribute19,
      x_attribute20                           => p_orig_sys_reference_rec.attribute20
    );

   hz_orig_system_ref_pvt.get_orig_sys_reference_rec (
      p_orig_system_ref_id    => l_orig_system_ref_id,
      x_orig_sys_reference_rec   => l_old_orig_sys_reference_rec,
      x_return_status            => x_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

 	 --Bug8404145
 	 --There is a chance of not having value in orig_system_ref_id in actual parameter
 	 --Assigning l_orig_system_ref_id to Orig System Reference Rec.orig_system_ref_id

 	 IF l_orig_sys_reference_rec.orig_system_ref_id is NULL THEN
 	         l_orig_sys_reference_rec.orig_system_ref_id := l_orig_system_ref_id;
 	 END IF;

     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
         HZ_BUSINESS_EVENT_V2PVT.update_orig_system_ref_event(l_orig_sys_reference_rec, l_old_orig_sys_reference_rec);
     END IF;

-- VJN : THIS IS A FIX FOR 3480975
-- WE BASICALLY WANT TO ENSURE THAT SYNC GETS CALLED ONLY WHEN OWNER_TABLE_ID IS A VALID
-- NON-EMPTY STRING IE., IT IS NEITHER FND_G_MISS_CHAR NOR NULL.
-- THEREFORE , WE FETCH IT FROM DB.
select owner_table_id into l_temp
from hz_orig_sys_references
where orig_system_ref_id = l_orig_system_ref_id;



-- SYNC PARTIES
IF p_orig_sys_reference_rec.owner_table_name = 'HZ_PARTIES'
THEN
    BEGIN
        -- SSM SST Integration and Extension
	-- Checking SST rules is now applicable only for profile entities.
	-- However as DQM sync considers SST record for profiles, therefore commenting out call to
	-- sst_rules_passed altogether.

        -- CALL DQM SYNC ONLY IF SST RULES PASS (
        -- VJN Introduced change to make sure that source system reference information gets
        -- DQM SYNCED.
/*        IF sst_rules_passed (p_orig_sys_reference_rec.owner_table_name, l_temp )
        THEN */

            select party_type into l_dummy
            from hz_parties
            where party_id = l_temp ;

            IF l_dummy = 'ORGANIZATION'
            THEN
                HZ_DQM_SYNC.sync_org(l_temp, 'U' );
            ELSIF l_dummy = 'PERSON'
            THEN
                HZ_DQM_SYNC.sync_person(l_temp, 'U' );
            END IF;
--        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
            fnd_message.set_token('FK', 'party_id');
            fnd_message.set_token('COLUMN', 'party_id');
            fnd_message.set_token('TABLE', 'hz_parties');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;

     END;

-- SYNC PARTY SITES
ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_PARTY_SITES'
THEN
   BEGIN--bug 6069559
   SELECT status INTO l_status FROM hz_party_sites WHERE party_site_id=l_temp;

   IF l_status Is NULL OR l_status = 'A' OR l_status = 'I' THEN
   HZ_DQM_SYNC.sync_party_site(l_temp ,'U') ;
   END IF;
   EXCEPTION
   WHEN No_Data_Found THEN
   NULL;
   END;


-- SYNC CONTACTS
ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_ORG_CONTACTS'
THEN
   BEGIN--bug 6069559
   SELECT status INTO l_status FROM HZ_ORG_CONTACTS WHERE org_contact_id=l_temp;

   IF l_status Is NULL OR l_status = 'A' OR l_status = 'I' THEN
   HZ_DQM_SYNC.sync_contact(l_temp,'U') ;
   END IF;
   EXCEPTION
   WHEN No_Data_Found THEN
   NULL;
   END;



-- SYNC CONTACT POINTS
ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CONTACT_POINTS'
THEN
   BEGIN--bug 6069559
   SELECT status INTO l_status FROM hz_contact_points  WHERE contact_point_id=l_temp;

   IF l_status Is NULL OR l_status = 'A' OR l_status = 'I' THEN
   HZ_DQM_SYNC.sync_contact_point(l_temp,'U') ;
   END IF;
   EXCEPTION
   WHEN No_Data_Found THEN
   NULL;
   END;



END IF;
/* Bug Fix:4869208 Removed the exception block */
end do_update_orig_sys_reference;


/* Public API */
PROCEDURE create_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_reference_rec	  IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
) is
l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE :=p_orig_sys_reference_rec;
l_orig_sys_reference_rec1 HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE := p_orig_sys_reference_rec;
l_object_version_number number;
l_start_date_active date;

--raji
cursor get_multi_mosr_flag is
select multi_osr_flag
from hz_orig_sys_mapping
where owner_table_name = l_orig_sys_reference_rec.owner_table_name
and orig_system = l_orig_sys_reference_rec.orig_system
/*and status ='A'*/;

cursor get_orig_system_new is
		select 'Y'
		from hz_orig_sys_references
		where owner_table_id = l_orig_sys_reference_rec.owner_table_id
		and owner_table_name = l_orig_sys_reference_rec.owner_table_name
                and orig_system      = l_orig_sys_reference_rec.orig_system
                and status = 'A';

l_multi_osr_flag varchar2(1);
x_party_id HZ_PARTIES.party_id%TYPE;
l_dummy VARCHAR2(1);

begin
    -- standard start of API savepoint
    SAVEPOINT create_orig_sys_reference;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    if (l_orig_sys_reference_rec.old_orig_system_reference is not null and
	   l_orig_sys_reference_rec.old_orig_system_reference <> fnd_api.g_miss_char)
    then
	l_orig_sys_reference_rec.orig_system_reference :=l_orig_sys_reference_rec.old_orig_system_reference;
	l_orig_sys_reference_rec.status := 'I';
        l_orig_sys_reference_rec.end_date_active := SYSDATE;
	l_start_date_active := get_start_date_active(l_orig_sys_reference_rec.orig_system,
						l_orig_sys_reference_rec.orig_system_reference,
						l_orig_sys_reference_rec.owner_table_name);
	if l_start_date_active is null
        then
		l_orig_sys_reference_rec.start_date_active := sysdate;
	else    l_orig_sys_reference_rec.start_date_active := l_start_date_active;
	end if;

	do_update_orig_sys_reference(
		l_orig_sys_reference_rec,
		p_validation_level,
		l_object_version_number,
		x_return_status );
    end if;

--raji
--//Phase 2 logic

       open get_multi_mosr_flag;
       fetch get_multi_mosr_flag into l_multi_osr_flag;
       close get_multi_mosr_flag;

if l_multi_osr_flag = 'N' then
    open get_orig_system_new;
          fetch get_orig_system_new into l_dummy ;
       if get_orig_system_new%FOUND then
          if p_validation_level = FND_API.G_VALID_LEVEL_FULL then
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_MOSR_NO_MULTIPLE_ALLOWED' );
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
       else
--//logic for populating party_id
          get_party_id(l_orig_sys_reference_rec.owner_table_id,
             l_orig_sys_reference_rec.owner_table_name,
             x_party_id
             );
          l_orig_sys_reference_rec1.party_id := x_party_id;

          do_create_orig_sys_reference(
		l_orig_sys_reference_rec1,
		p_validation_level,
		x_return_status );
       end if;
close get_orig_system_new;

else --// l_multi_osr_flag = 'Y'
--//logic for populating party_id

get_party_id(l_orig_sys_reference_rec.owner_table_id,
             l_orig_sys_reference_rec.owner_table_name,
             x_party_id
             );
           l_orig_sys_reference_rec1.party_id := x_party_id;

           do_create_orig_sys_reference(
                l_orig_sys_reference_rec1,
                p_validation_level,
                x_return_status );
end if;


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

function inactive_mosr_exist(p_orig_system in varchar2,
p_orig_system_reference in varchar2, p_owner_table_name in varchar2,p_owner_table_id in number) return varchar2
is
	cursor inactive_mosr_exist_csr is
	SELECT 'Y'
        FROM   HZ_ORIG_SYS_REFERENCES
        WHERE  ORIG_SYSTEM = p_orig_system
	and ORIG_SYSTEM_REFERENCE = p_orig_system_reference
	and owner_table_name = p_owner_table_name
	and owner_table_id = p_owner_table_id
	and status = 'I'
	and rownum = 1;

l_tmp  varchar2(1);
begin
	open inactive_mosr_exist_csr;
	fetch inactive_mosr_exist_csr into l_tmp;
	close inactive_mosr_exist_csr;
	return nvl(l_tmp,'N');
end inactive_mosr_exist;

/* Public API */
PROCEDURE update_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_reference_rec       IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
)is

l_object_version_number number:= p_object_version_number;
l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE := p_orig_sys_reference_rec;
lc_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE := p_orig_sys_reference_rec;
l_start_date_active date;
l_inactive_mosr_exist varchar2(1);

--raji

  cursor get_multi_mosr_flag is
select multi_osr_flag
from hz_orig_sys_mapping
where owner_table_name = l_orig_sys_reference_rec.owner_table_name
and orig_system = l_orig_sys_reference_rec.orig_system
/*and status='A'*/;

cursor get_orig_system_new is
		select 'Y'
		from hz_orig_sys_references
		where owner_table_id = l_orig_sys_reference_rec.owner_table_id
		and owner_table_name = l_orig_sys_reference_rec.owner_table_name
		and orig_system	     = l_orig_sys_reference_rec.orig_system
                and status           = 'A';

l_multi_osr_flag varchar2(1);
x_party_id HZ_PARTIES.party_id%TYPE;
l_dummy VARCHAR2(1);

begin

    -- standard start of API savepoint
    SAVEPOINT update_orig_sys_reference;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--raji
--    //Phase 2 logic

       open get_multi_mosr_flag;
       fetch get_multi_mosr_flag into l_multi_osr_flag;
       close get_multi_mosr_flag;


    if (p_orig_sys_reference_rec.old_orig_system_reference=p_orig_sys_reference_rec.orig_system_reference)
    then
	l_orig_sys_reference_rec.old_orig_system_reference := null;
    end if;
    if (l_orig_sys_reference_rec.old_orig_system_reference is not null and
	   l_orig_sys_reference_rec.old_orig_system_reference <> fnd_api.g_miss_char)
    then
	l_orig_sys_reference_rec.orig_system_reference := p_orig_sys_reference_rec.old_orig_system_reference;
    else
	l_orig_sys_reference_rec.orig_system_reference :=p_orig_sys_reference_rec.orig_system_reference;
    end if;
    l_inactive_mosr_exist := inactive_mosr_exist(p_orig_sys_reference_rec.orig_system,
			l_orig_sys_reference_rec.orig_system_reference,
			p_orig_sys_reference_rec.owner_table_name,
			p_orig_sys_reference_rec.owner_table_id);

   if l_inactive_mosr_exist = 'Y' and p_orig_sys_reference_rec.status = 'A' -- update inactive to active
   then
	l_orig_sys_reference_rec.orig_system_ref_id := null; -- need to get it from sequence

        if l_multi_osr_flag = 'N' then
            open get_orig_system_new;
            fetch get_orig_system_new into l_dummy ;
            if get_orig_system_new%FOUND then
		if ((p_orig_sys_reference_rec.old_orig_system_reference <> p_orig_sys_reference_rec.orig_system_reference)
		     and (p_orig_sys_reference_rec.old_orig_system_reference is not null)
		     and (p_orig_sys_reference_rec.old_orig_system_reference <> fnd_api.g_miss_char)) then
		     -- first make the old OSR inactive
                  lc_orig_sys_reference_rec.orig_system_reference := p_orig_sys_reference_rec.old_orig_system_reference;
	          lc_orig_sys_reference_rec.status := 'I';
	          l_start_date_active := get_start_date_active(p_orig_sys_reference_rec.orig_system,
						lc_orig_sys_reference_rec.orig_system_reference,
						p_orig_sys_reference_rec.owner_table_name);
	          if l_start_date_active is null
                  then
		      lc_orig_sys_reference_rec.start_date_active := sysdate;
	          else
		      lc_orig_sys_reference_rec.start_date_active := l_start_date_active;
	          end if;

                  lc_orig_sys_reference_rec.end_date_active := SYSDATE;
	          do_update_orig_sys_reference(
		        lc_orig_sys_reference_rec,
                        p_validation_level,
		        l_object_version_number,
		        x_return_status );

		  l_orig_sys_reference_rec.orig_system_reference := p_orig_sys_reference_rec.orig_system_reference;
                  get_party_id(l_orig_sys_reference_rec.owner_table_id,
                    l_orig_sys_reference_rec.owner_table_name,
                    x_party_id
                    );
                  l_orig_sys_reference_rec.party_id := x_party_id;

	          do_create_orig_sys_reference(
		    l_orig_sys_reference_rec,
                    p_validation_level,
		    x_return_status );
	        else
                  if p_validation_level = FND_API.G_VALID_LEVEL_FULL then
                      FND_MESSAGE.SET_NAME( 'AR', 'HZ_MOSR_NO_MULTIPLE_ALLOWED' );
                      FND_MSG_PUB.ADD;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  end if;
	       end if;
            else
--//logic for populating party_id
                get_party_id(l_orig_sys_reference_rec.owner_table_id,
                    l_orig_sys_reference_rec.owner_table_name,
                    x_party_id
                    );
                l_orig_sys_reference_rec.party_id := x_party_id;

	        do_create_orig_sys_reference(
		    l_orig_sys_reference_rec,
                    p_validation_level,
		    x_return_status );
           end if;
           close get_orig_system_new;
       else  --  l_multi_osr_flag = 'Y'
--  //logic for populating party_id
		if ((p_orig_sys_reference_rec.old_orig_system_reference <> p_orig_sys_reference_rec.orig_system_reference)
		     and (p_orig_sys_reference_rec.old_orig_system_reference is not null)
		     and (p_orig_sys_reference_rec.old_orig_system_reference <> fnd_api.g_miss_char)) then
		     -- first make the old OSR inactive
                  lc_orig_sys_reference_rec.orig_system_reference := p_orig_sys_reference_rec.old_orig_system_reference;
	          lc_orig_sys_reference_rec.status := 'I';
	          l_start_date_active := get_start_date_active(p_orig_sys_reference_rec.orig_system,
						lc_orig_sys_reference_rec.orig_system_reference,
						p_orig_sys_reference_rec.owner_table_name);
	          if l_start_date_active is null
                  then
		      lc_orig_sys_reference_rec.start_date_active := sysdate;
	          else
		      lc_orig_sys_reference_rec.start_date_active := l_start_date_active;
	          end if;

                  lc_orig_sys_reference_rec.end_date_active := SYSDATE;
	          do_update_orig_sys_reference(
		        lc_orig_sys_reference_rec,
                        p_validation_level,
		        l_object_version_number,
		        x_return_status );
	       end if;

           l_orig_sys_reference_rec.orig_system_reference := p_orig_sys_reference_rec.orig_system_reference;
           get_party_id(l_orig_sys_reference_rec.owner_table_id,
               l_orig_sys_reference_rec.owner_table_name,
               x_party_id
               );
           l_orig_sys_reference_rec.party_id := x_party_id;

	   do_create_orig_sys_reference(
               l_orig_sys_reference_rec,
               p_validation_level,
	       x_return_status );
       end if;
       return;
   end if;

   if l_inactive_mosr_exist = 'Y' and p_orig_sys_reference_rec.status = 'I' -- update active to inactive
   then
	l_orig_sys_reference_rec.old_orig_system_reference := null;
        l_orig_sys_reference_rec.orig_system_reference := p_orig_sys_reference_rec.orig_system_reference;
	l_start_date_active := get_start_date_active(l_orig_sys_reference_rec.orig_system,
						l_orig_sys_reference_rec.orig_system_reference,
						l_orig_sys_reference_rec.owner_table_name);
	if l_start_date_active is null
        then
		l_orig_sys_reference_rec.start_date_active := sysdate;
	else    l_orig_sys_reference_rec.start_date_active := l_start_date_active;
	end if;

        l_orig_sys_reference_rec.end_date_active := SYSDATE;
	do_update_orig_sys_reference(
		l_orig_sys_reference_rec,
                p_validation_level,
		l_object_version_number,
		x_return_status );
        return;
   end if;

    -- call to business logic.


    if (l_orig_sys_reference_rec.old_orig_system_reference is not null and
	   l_orig_sys_reference_rec.old_orig_system_reference <> fnd_api.g_miss_char)
	   -- if old OSR passed
    then
	l_orig_sys_reference_rec.orig_system_reference :=l_orig_sys_reference_rec.old_orig_system_reference;
	l_orig_sys_reference_rec.status := 'I';
	l_start_date_active := get_start_date_active(l_orig_sys_reference_rec.orig_system,
						l_orig_sys_reference_rec.orig_system_reference,
						l_orig_sys_reference_rec.owner_table_name);
	if l_start_date_active is null
        then
		l_orig_sys_reference_rec.start_date_active := sysdate;
	else    l_orig_sys_reference_rec.start_date_active := l_start_date_active;
	end if;

        l_orig_sys_reference_rec.end_date_active := SYSDATE;
	do_update_orig_sys_reference(
		l_orig_sys_reference_rec,
                p_validation_level,
		l_object_version_number,
		x_return_status );

	lc_orig_sys_reference_rec.orig_system_ref_id := null; -- need to get it from sequence
	lc_orig_sys_reference_rec.status := 'A';
--raji
        if l_multi_osr_flag = 'N' then
       	    open get_orig_system_new;
	    fetch get_orig_system_new into l_dummy ;
            if get_orig_system_new%FOUND then
                if p_validation_level = FND_API.G_VALID_LEVEL_FULL then
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_MOSR_NO_MULTIPLE_ALLOWED' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
            else
--//logic for populating party_id
                get_party_id(l_orig_sys_reference_rec.owner_table_id,
                    l_orig_sys_reference_rec.owner_table_name,
                    x_party_id
                    );
                l_orig_sys_reference_rec.party_id := x_party_id;

	        do_create_orig_sys_reference(
		    lc_orig_sys_reference_rec,
                    p_validation_level,
		    x_return_status );

            end if;
            close get_orig_system_new;
        else
--       //l_multi_osr_flag = 'Y'
--       //logic for populating party_id
            get_party_id(l_orig_sys_reference_rec.owner_table_id,
                l_orig_sys_reference_rec.owner_table_name,
                x_party_id
                );
            l_orig_sys_reference_rec.party_id := x_party_id;

            do_create_orig_sys_reference(
		lc_orig_sys_reference_rec,
                p_validation_level,
		x_return_status );
        end if;

    else  -- if old OSR not passed
	  if p_orig_sys_reference_rec.status = 'I' then
		l_start_date_active := get_start_date_active(l_orig_sys_reference_rec.orig_system,
						l_orig_sys_reference_rec.orig_system_reference,
						l_orig_sys_reference_rec.owner_table_name);
		if l_start_date_active is null
        	then
			l_orig_sys_reference_rec.start_date_active := sysdate;
		else    l_orig_sys_reference_rec.start_date_active := l_start_date_active;
		end if;

	        l_orig_sys_reference_rec.end_date_active := SYSDATE;
	  end if;
	  do_update_orig_sys_reference(
		l_orig_sys_reference_rec,
                p_validation_level,
		l_object_version_number,
		x_return_status );
    end if;




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

PROCEDURE  remap_internal_identifier(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
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
	cursor get_orig_system_csr is
		select orig_system, orig_system_reference,orig_system_ref_id
		from hz_orig_sys_references
		where owner_table_id = p_old_owner_table_id
		and owner_table_name = p_owner_table_name
                and status = 'A';     /* Bug 3235877 */

l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
l_orig_system varchar2(30);
l_orig_system_reference varchar2(255);
l_orig_system_ref_id number;
l_object_version_number number;

--   //introduce this new cursor,

cursor get_multi_mosr_flag is
select multi_osr_flag
from hz_orig_sys_mapping
where owner_table_name = p_owner_table_name
and orig_system = (select orig_system from hz_orig_sys_references
                   where owner_table_id = p_old_owner_table_id
                   and owner_table_name = p_owner_table_name
                   and status ='A'
                   and rownum =1
                   );

cursor get_orig_system_new is
		select 'Y'
		from hz_orig_sys_references
		where owner_table_id = p_new_owner_table_id
		and owner_table_name = p_owner_table_name
-- Bug 3863486
and orig_system = (select orig_system from hz_orig_sys_references
                   where owner_table_id = p_old_owner_table_id
                   and owner_table_name = p_owner_table_name
                   and status ='A'
                   and rownum =1)
                and status = 'A';

--bug 4261242
cursor check_duplicates is
		select 'Y'
		from hz_orig_sys_references
             	where owner_table_id = p_new_owner_table_id
                and owner_table_name = p_owner_table_name
		and orig_system || orig_system_reference = l_orig_system||l_orig_system_reference
	        and status = 'A';

l_dup_exists varchar2(1);
l_multi_osr_flag varchar2(1);
x_party_id HZ_PARTIES.party_id%TYPE;
l_dummy VARCHAR2(1);
l_party_merge_flag BOOLEAN := FALSE; /*For Bug 3235877*/

begin

	 --Initialize API return status to success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	if p_orig_system is not null and p_orig_system_reference is not null
	then

--raji
--       //logic for populating party_id

           get_party_id(p_old_owner_table_id,
             p_owner_table_name,
             x_party_id
             );
            l_orig_sys_reference_rec.party_id := x_party_id;

		l_orig_sys_reference_rec.orig_system := p_orig_system;
		l_orig_sys_reference_rec.orig_system_reference := p_orig_system_reference;
		l_orig_sys_reference_rec.owner_table_name := p_owner_table_name;
		l_orig_sys_reference_rec.owner_table_id := p_old_owner_table_id;
		l_orig_sys_reference_rec.status := 'I';
		l_orig_sys_reference_rec.end_date_active := SYSDATE;
		l_orig_sys_reference_rec.reason_code := p_reason_code;

		update_orig_system_reference(
			FND_API.G_FALSE,
			p_validation_level,
			l_orig_sys_reference_rec,
			l_object_version_number,
			x_return_status,
		        x_msg_count,
		        x_msg_data);
		IF x_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
--raji
--  //logic for populating party_id

       get_party_id(p_new_owner_table_id,
             p_owner_table_name,
             x_party_id
             );
       l_orig_sys_reference_rec.party_id := x_party_id;

		l_orig_sys_reference_rec.orig_system := p_orig_system;
		l_orig_sys_reference_rec.orig_system_reference := p_orig_system_reference;
		l_orig_sys_reference_rec.owner_table_name := p_owner_table_name;
		l_orig_sys_reference_rec.owner_table_id := p_new_owner_table_id;
		l_orig_sys_reference_rec.reason_code := p_reason_code;
		l_orig_sys_reference_rec.status := 'A';
		l_orig_sys_reference_rec.end_date_active := null;
		create_orig_system_reference(
			FND_API.G_FALSE,
			p_validation_level,
			l_orig_sys_reference_rec,
			x_return_status,
		        x_msg_count,
		        x_msg_data);
		IF x_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;
	else
		open get_orig_system_csr;
		loop
			fetch get_orig_system_csr into l_orig_system,l_orig_system_reference,l_orig_system_ref_id;
			exit when get_orig_system_csr%NOTFOUND;
			  l_party_merge_flag := TRUE;  /*Bug 3235877*/
			-- if l_orig_system is not null and l_orig_system_reference is not null  /*Bug 3235877*/
			-- then -- for party/account merge, in case no data in MOSR	/*since the cursor has been
                             --  table, should skip without error			changed, this if is unnecessary*/
--         //logic for populating party_id

       get_party_id(p_old_owner_table_id,
             p_owner_table_name,
             x_party_id
             );
       l_orig_sys_reference_rec.party_id := x_party_id;

--//Phase 2 logic

       open get_multi_mosr_flag;
       fetch get_multi_mosr_flag into l_multi_osr_flag;
       close get_multi_mosr_flag;

				l_orig_sys_reference_rec.orig_system := l_orig_system;
				l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
				l_orig_sys_reference_rec.owner_table_name := p_owner_table_name;
				l_orig_sys_reference_rec.owner_table_id := p_old_owner_table_id;
				l_orig_sys_reference_rec.status := 'I';
				l_orig_sys_reference_rec.end_date_active := SYSDATE;
				l_orig_sys_reference_rec.reason_code := p_reason_code;
				l_orig_sys_reference_rec.orig_system_ref_id := l_orig_system_ref_id;
				update_orig_system_reference(
				FND_API.G_FALSE,
				p_validation_level,
				l_orig_sys_reference_rec,
				l_object_version_number,
				x_return_status,
				x_msg_count,
				x_msg_data);
				IF x_return_status <> fnd_api.g_ret_sts_success THEN
					RAISE FND_API.G_EXC_ERROR;
				END IF;

if l_multi_osr_flag = 'Y' then
--bug 4261242 check if merge-to party has ssm record with same orig_system and orig_system_reference as that of merge-from party
        l_dup_exists := 'N';
	open check_duplicates;
	fetch check_duplicates into l_dup_exists;
        close check_duplicates;
	if l_dup_exists = 'N' then
--//logic for populating party_id

                 get_party_id(p_new_owner_table_id,
                              p_owner_table_name,
                              x_party_id
                              );
                         l_orig_sys_reference_rec.party_id := x_party_id;
				l_orig_sys_reference_rec.orig_system := l_orig_system;
				l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
				l_orig_sys_reference_rec.owner_table_name := p_owner_table_name;
				l_orig_sys_reference_rec.owner_table_id := p_new_owner_table_id;
				l_orig_sys_reference_rec.status := 'A';
				l_orig_sys_reference_rec.end_date_active := null;
				l_orig_sys_reference_rec.reason_code := p_reason_code;
				l_orig_sys_reference_rec.orig_system_ref_id := null;
				create_orig_system_reference(
				FND_API.G_FALSE,
				p_validation_level,
				l_orig_sys_reference_rec,
				x_return_status,
				x_msg_count,
				x_msg_data);
				IF x_return_status <> fnd_api.g_ret_sts_success THEN
					RAISE FND_API.G_EXC_ERROR;
				END IF;
	end if;
else --//l_multi_osr_flag = 'N'
          open get_orig_system_new;
          fetch get_orig_system_new into  l_dummy;
            if get_orig_system_new%FOUND then
                NULL;
            else
                get_party_id(p_new_owner_table_id,
                           p_owner_table_name,
                           x_party_id
                           );
                 l_orig_sys_reference_rec.party_id := x_party_id;
                                l_orig_sys_reference_rec.orig_system := l_orig_system;
                                l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
                                l_orig_sys_reference_rec.owner_table_name := p_owner_table_name;
                                l_orig_sys_reference_rec.owner_table_id := p_new_owner_table_id;
                                l_orig_sys_reference_rec.status := 'A';
                                l_orig_sys_reference_rec.end_date_active := null;
                                l_orig_sys_reference_rec.reason_code := p_reason_code;
                                l_orig_sys_reference_rec.orig_system_ref_id := null;
                                create_orig_system_reference(
                                FND_API.G_FALSE,
                                p_validation_level,
                                l_orig_sys_reference_rec,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);
                                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;

            end if;
          close get_orig_system_new;
end if; --//multi_osr_flag
-- END IF;
		end loop;
		IF l_party_merge_flag = FALSE THEN /*Bug 3235877*/
                          if p_validation_level = FND_API.G_VALID_LEVEL_FULL then--YES
                            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
                            FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference+owner_table_id');
                            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                          end if;
		END IF;
		close get_orig_system_csr;
	end if;
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

end;

/* not called anywhere currently */
PROCEDURE create_mosr_for_merge(
    p_init_msg_list    IN   VARCHAR2 := FND_API.G_FALSE,
    p_owner_table_name IN VARCHAR2,
    p_owner_table_id   IN NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
) is
	cursor get_orig_system_csr is
		select orig_system, orig_system_reference, created_by_module
		from hz_orig_sys_references
		WHERE owner_table_name = p_owner_table_name
		and owner_table_id = p_owner_table_id
		and status = 'A';
l_created_by_module varchar2(150);
l_orig_system varchar2(30);
l_orig_system_reference varchar2(255);
l_orig_sys_reference_rec	HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

--//introduce this new cursor,

cursor get_multi_mosr_flag(p_orig_system NUMBER) is
select multi_osr_flag
from hz_orig_sys_mapping
where owner_table_name = p_owner_table_name
and orig_system = (select orig_system from hz_orig_sys_references
                   where owner_table_id = p_owner_table_id
                   and owner_table_name = p_owner_table_name
                   and status = 'A'
                   and rownum=1
                  );

l_multi_osr_flag varchar2(1);
x_party_id HZ_PARTIES.party_id%TYPE;


begin

	 --Initialize API return status to success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open get_orig_system_csr;
	loop
		fetch get_orig_system_csr into l_orig_system, l_orig_system_reference,l_created_by_module;
		exit when get_orig_system_csr%notfound;
		if l_orig_system is not null
		then
   open get_multi_mosr_flag(l_orig_system);
        fetch get_multi_mosr_flag into l_multi_osr_flag;
        close get_multi_mosr_flag;

   if l_multi_osr_flag = 'Y' then
--        //logic for populating party_id

        get_party_id(p_owner_table_id,
             p_owner_table_name,
             x_party_id
             );
        l_orig_sys_reference_rec.party_id := x_party_id;
			l_orig_sys_reference_rec.orig_system := l_orig_system;
			l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
			l_orig_sys_reference_rec.owner_table_name := p_owner_table_name ;
			l_orig_sys_reference_rec.owner_table_id := p_owner_table_id;
			l_orig_sys_reference_rec.reason_code := 'MERGED';
			l_orig_sys_reference_rec.created_by_module := l_created_by_module;
			create_orig_system_reference(
			FND_API.G_FALSE,
			FND_API.G_VALID_LEVEL_NONE,
			l_orig_sys_reference_rec,
			x_return_status,
		        x_msg_count,
		        x_msg_data);
			IF x_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		end if;
    end if;
	end loop;
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

end create_mosr_for_merge;

--//create a new procedure for getting the party id

PROCEDURE get_party_id( p_owner_table_id IN NUMBER,
                        p_owner_table_name IN VARCHAR2,
                        x_party_id OUT NOCOPY NUMBER
                       )
IS

--// Table hz_party_sites
    cursor c_party_site_id is
    select party_id
    from hz_party_sites
    where party_site_id = p_owner_table_id;
    --and status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_cust_accounts
    cursor c_cust_id is
    select party_id
    from hz_cust_accounts
    where cust_account_id = p_owner_table_id;
    --and status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_cust_acct_sites_all
    cursor c_cust_site_id is
    select cust.party_id
    from hz_cust_accounts cust,hz_cust_acct_sites sites
    where sites.cust_acct_site_id = p_owner_table_id
    and cust.cust_account_id = sites.cust_account_id;
    --and sites.status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_cust_site_uses_all
     cursor c_cust_site_uses_id is
     select cust.party_id
     from hz_cust_accounts cust,hz_cust_acct_sites sites,hz_cust_site_uses uses
     where uses.site_use_id = p_owner_table_id
     and uses.cust_acct_site_id = sites.cust_acct_site_id
     and sites.cust_account_id = cust.cust_account_id;
     --and uses.status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_contact_points
      cursor c_cust_cont_point_id is
      select party.party_id
      from hz_parties party,hz_contact_points cont
      where cont.contact_point_id = p_owner_table_id
      and cont.owner_table_id = party.party_id
      --and cont.status = 'A'  -- Bug 3196803 : Removed the check of status = 'A'
union
      select psite.party_site_id
      from hz_party_sites psite,hz_contact_points cont
      where cont.contact_point_id = p_owner_table_id
      and cont.owner_table_id = psite.party_site_id;
      --and cont.status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_org_contacts
    cursor c_org_cont_id is
    select rel.object_id
    from hz_org_contacts org ,hz_relationships rel
    where org.org_contact_id = p_owner_table_id
    and org.party_relationship_id = rel.relationship_id
    and rel.directional_flag = 'F';
    --and org.status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_org_contact_roles
    cursor c_org_cont_role_id is
    select rel.object_id
    from hz_org_contact_roles roles,hz_org_contacts org,hz_relationships rel
    where roles.org_contact_role_id = p_owner_table_id
    and roles.org_contact_id = org.org_contact_id
    and org.party_relationship_id = rel.relationship_id
    and rel.directional_flag = 'F';
    --and roles.status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

--//Table hz_cust_account_roles
    cursor c_cust_acct_role_id is
    select cust.party_id
    from hz_cust_account_roles role,hz_cust_accounts cust
    where role.cust_account_role_id = p_owner_table_id
    and role.cust_account_id = cust.cust_account_id;
    --and role.status = 'A';  -- Bug 3196803 : Removed the check of status = 'A'

begin

if p_owner_table_name = 'HZ_PARTIES' then
   x_party_id := p_owner_table_id;

elsif p_owner_table_name = 'HZ_PARTY_SITES' then
   open c_party_site_id;
   fetch c_party_site_id into x_party_id;
   close c_party_site_id;

elsif p_owner_table_name = 'HZ_CUST_ACCOUNTS' then
   open c_cust_id;
   fetch c_cust_id into x_party_id;
   close c_cust_id;

elsif p_owner_table_name = 'HZ_CUST_ACCT_SITES_ALL' then
   open c_cust_site_id;
   fetch c_cust_site_id into x_party_id;
   close c_cust_site_id;

elsif p_owner_table_name = 'HZ_CUST_SITE_USES_ALL' then
   open c_cust_site_uses_id ;
   fetch c_cust_site_uses_id into x_party_id;
   close c_cust_site_uses_id;

elsif p_owner_table_name = 'HZ_CONTACT_POINTS' then
    open c_cust_cont_point_id;
    fetch c_cust_cont_point_id into x_party_id;
    close c_cust_cont_point_id;

elsif p_owner_table_name = 'HZ_ORG_CONTACTS' then
     open c_org_cont_id;
     fetch c_org_cont_id into x_party_id;
     close c_org_cont_id;

elsif p_owner_table_name = 'HZ_ORG_CONTACT_ROLES' then
      open c_org_cont_role_id;
      fetch c_org_cont_role_id into x_party_id;
      close c_org_cont_role_id;

elsif p_owner_table_name = 'HZ_CUST_ACCOUNT_ROLES' then
      open c_cust_acct_role_id;
      fetch c_cust_acct_role_id into x_party_id;
      close c_cust_acct_role_id;

elsif p_owner_table_name = 'HZ_LOCATIONS' then
     x_party_id := NULL;
end if;

end get_party_id;

--  SSM SST Integration and Extension Project




PROCEDURE do_create_orig_system(
    p_orig_sys_rec        IN OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PVT.ORIG_SYS_REC_TYPE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) is
l_entity_name          HZ_ENTITY_ATTRIBUTES.ENTITY_NAME%TYPE;
l_attribute_name       HZ_ENTITY_ATTRIBUTES.ATTRIBUTE_NAME%TYPE;
p_entity_attribute_rec HZ_MIXNM_REGISTRY_PUB.ENTITY_ATTRIBUTE_REC_TYPE;
x_entity_attr_id       NUMBER;
x_msg_count            NUMBER;
x_msg_data             NUMBER;
l_data_source_tbl      HZ_MIXNM_REGISTRY_PUB.DATA_SOURCE_TBL;

CURSOR c_data_sources IS
    SELECT ENTITY_NAME,
           ATTRIBUTE_NAME
    FROM   HZ_ENTITY_ATTRIBUTES;
begin

     --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     if p_validation_level = FND_API.G_VALID_LEVEL_FULL
     then
	HZ_MOSR_VALIDATE_PKG.VALIDATE_ORIG_SYSTEM ('C',
					p_orig_sys_rec,
					x_return_status);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
     end if;


     HZ_ORIG_SYSTEMS_PKG.Insert_Row (
      x_orig_system_id			      => p_orig_sys_rec.orig_system_id,
      x_orig_system                           => p_orig_sys_rec.orig_system,
      x_orig_system_name		      => p_orig_sys_rec.orig_system_name,
      x_description			      => p_orig_sys_rec.description,
      x_orig_system_type		      => p_orig_sys_rec.orig_system_type,
      x_sst_flag			      => p_orig_sys_rec.sst_flag,
      x_status				      => p_orig_sys_rec.status,
      x_object_version_number                 => 1,
      x_created_by_module                     => p_orig_sys_rec.created_by_module,
      x_attribute_category                    => p_orig_sys_rec.attribute_category,
      x_attribute1                            => p_orig_sys_rec.attribute1,
      x_attribute2                            => p_orig_sys_rec.attribute2,
      x_attribute3                            => p_orig_sys_rec.attribute3,
      x_attribute4                            => p_orig_sys_rec.attribute4,
      x_attribute5                            => p_orig_sys_rec.attribute5,
      x_attribute6                            => p_orig_sys_rec.attribute6,
      x_attribute7                            => p_orig_sys_rec.attribute7,
      x_attribute8                            => p_orig_sys_rec.attribute8,
      x_attribute9                            => p_orig_sys_rec.attribute9,
      x_attribute10                           => p_orig_sys_rec.attribute10,
      x_attribute11                           => p_orig_sys_rec.attribute11,
      x_attribute12                           => p_orig_sys_rec.attribute12,
      x_attribute13                           => p_orig_sys_rec.attribute13,
      x_attribute14                           => p_orig_sys_rec.attribute14,
      x_attribute15                           => p_orig_sys_rec.attribute15,
      x_attribute16                           => p_orig_sys_rec.attribute16,
      x_attribute17                           => p_orig_sys_rec.attribute17,
      x_attribute18                           => p_orig_sys_rec.attribute18,
      x_attribute19                           => p_orig_sys_rec.attribute19,
      x_attribute20                           => p_orig_sys_rec.attribute20
    );

     /* Create records in HZ_SELECT_DATA_SOURCES for this orig_system and all entities + attributes */
     IF p_orig_sys_rec.sst_flag = 'Y' THEN
         OPEN c_data_sources;
         LOOP
             FETCH c_data_sources
             INTO  l_entity_name,
    	           l_attribute_name;
             IF c_data_sources%NOTFOUND THEN
	         EXIT;
             END IF;
             p_entity_attribute_rec.entity_name       := l_entity_name;
	     p_entity_attribute_rec.attribute_name    := l_attribute_name;
             p_entity_attribute_rec.created_by_module := 'TCA_MOSR_API';
	     p_entity_attribute_rec.application_id    := 222;
             l_data_source_tbl                        := HZ_MIXNM_REGISTRY_PUB.DATA_SOURCE_TBL(p_orig_sys_rec.orig_system);

	     HZ_MIXNM_REGISTRY_PUB.Add_EntityAttribute
	       (p_entity_attribute_rec => p_entity_attribute_rec,
	        p_data_source_tab      => l_data_source_tbl,
	        x_entity_attr_id       => x_entity_attr_id,
	        x_return_status        => x_return_status,
	        x_msg_count            => x_msg_count,
	        x_msg_data             => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

         END LOOP;
         CLOSE c_data_sources;
    END IF;


end do_create_orig_system;

PROCEDURE do_update_orig_system(
    p_orig_sys_rec        IN OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PVT.ORIG_SYS_REC_TYPE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) is
l_object_version_number NUMBER;
l_sst_flag              VARCHAR2(1);
x_entity_attr_id       NUMBER;
l_orig_system          HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM%TYPE;
l_entity_name          HZ_ENTITY_ATTRIBUTES.ENTITY_NAME%TYPE;
l_attribute_name       HZ_ENTITY_ATTRIBUTES.ATTRIBUTE_NAME%TYPE;
p_entity_attribute_rec HZ_MIXNM_REGISTRY_PUB.ENTITY_ATTRIBUTE_REC_TYPE;
l_data_source_tbl      HZ_MIXNM_REGISTRY_PUB.DATA_SOURCE_TBL;
x_msg_count            NUMBER;
x_msg_data             NUMBER;

CURSOR c_data_sources IS
    SELECT ENTITY_NAME,
           ATTRIBUTE_NAME
    FROM   HZ_ENTITY_ATTRIBUTES;

begin

     --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- check whether record has been updated by another user. If not, lock it.

    BEGIN
        SELECT OBJECT_VERSION_NUMBER, SST_FLAG, ORIG_SYSTEM
        INTO   l_object_version_number, l_sst_flag, l_orig_system
        FROM   HZ_ORIG_SYSTEMS_B
        WHERE  orig_system_id = p_orig_sys_rec.orig_system_id
        FOR UPDATE OF ORIG_SYSTEM NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is
null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYSTEMS_B');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_ORIG_SYSTEMS_B');
        FND_MESSAGE.SET_TOKEN('VALUE', p_orig_sys_rec.orig_system_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


   if p_validation_level = FND_API.G_VALID_LEVEL_FULL
   then
    -- call for validations.
        HZ_MOSR_VALIDATE_PKG.VALIDATE_ORIG_SYSTEM ('U',
                                        p_orig_sys_rec,
                                        x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;
   end if;

   -- call table handler


	HZ_ORIG_SYSTEMS_PKG.Update_Row (
      x_orig_system_id			      => p_orig_sys_rec.orig_system_id,
      x_orig_system                           => p_orig_sys_rec.orig_system,
      x_orig_system_name		      => p_orig_sys_rec.orig_system_name,
      x_description			      => p_orig_sys_rec.description,
      x_orig_system_type		      => p_orig_sys_rec.orig_system_type,
      x_sst_flag			      => p_orig_sys_rec.sst_flag,
      x_status				      => p_orig_sys_rec.status,
      x_object_version_number                 => p_object_version_number,
      x_created_by_module                     => p_orig_sys_rec.created_by_module,
      x_attribute_category                    => p_orig_sys_rec.attribute_category,
      x_attribute1                            => p_orig_sys_rec.attribute1,
      x_attribute2                            => p_orig_sys_rec.attribute2,
      x_attribute3                            => p_orig_sys_rec.attribute3,
      x_attribute4                            => p_orig_sys_rec.attribute4,
      x_attribute5                            => p_orig_sys_rec.attribute5,
      x_attribute6                            => p_orig_sys_rec.attribute6,
      x_attribute7                            => p_orig_sys_rec.attribute7,
      x_attribute8                            => p_orig_sys_rec.attribute8,
      x_attribute9                            => p_orig_sys_rec.attribute9,
      x_attribute10                           => p_orig_sys_rec.attribute10,
      x_attribute11                           => p_orig_sys_rec.attribute11,
      x_attribute12                           => p_orig_sys_rec.attribute12,
      x_attribute13                           => p_orig_sys_rec.attribute13,
      x_attribute14                           => p_orig_sys_rec.attribute14,
      x_attribute15                           => p_orig_sys_rec.attribute15,
      x_attribute16                           => p_orig_sys_rec.attribute16,
      x_attribute17                           => p_orig_sys_rec.attribute17,
      x_attribute18                           => p_orig_sys_rec.attribute18,
      x_attribute19                           => p_orig_sys_rec.attribute19,
      x_attribute20                           => p_orig_sys_rec.attribute20
	);
     IF l_sst_flag = 'N' AND
        P_orig_sys_rec.sst_flag = 'Y' THEN
	 OPEN c_data_sources;
         LOOP
             FETCH c_data_sources
             INTO  l_entity_name,
    	           l_attribute_name;
             IF c_data_sources%NOTFOUND THEN
	         EXIT;
             END IF;
             p_entity_attribute_rec.entity_name       := l_entity_name;
	     p_entity_attribute_rec.attribute_name    := l_attribute_name;
             p_entity_attribute_rec.created_by_module := 'TCA_MOSR_API';
	     p_entity_attribute_rec.application_id    := 222;
             l_data_source_tbl                        := HZ_MIXNM_REGISTRY_PUB.DATA_SOURCE_TBL(l_orig_system);

	     HZ_MIXNM_REGISTRY_PUB.Add_EntityAttribute
	       (p_entity_attribute_rec => p_entity_attribute_rec,
	        p_data_source_tab      => l_data_source_tbl,
	        x_entity_attr_id       => x_entity_attr_id,
	        x_return_status        => x_return_status,
	        x_msg_count            => x_msg_count,
	        x_msg_data             => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

         END LOOP;
         CLOSE c_data_sources;

     END IF;
end do_update_orig_system;

PROCEDURE create_orig_system(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_rec	  IN     ORIG_SYS_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
)IS
l_orig_sys_rec  ORIG_SYS_REC_TYPE :=  p_orig_sys_rec;
--p_validation_level
begin
	    -- standard start of API savepoint
    SAVEPOINT create_orig_system;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_orig_system(
	l_orig_sys_rec,
        p_validation_level,
	x_return_status );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_orig_system;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_orig_system;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_orig_system;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
end create_orig_system;

PROCEDURE update_orig_system(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_rec       IN      ORIG_SYS_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
)IS
l_orig_sys_rec ORIG_SYS_REC_TYPE :=  p_orig_sys_rec;
l_object_version_number number:= p_object_version_number;

begin
	    -- standard start of API savepoint
    SAVEPOINT update_orig_system;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_update_orig_system(
	l_orig_sys_rec,
        p_validation_level,
	l_object_version_number,
	x_return_status );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_orig_system;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_orig_system;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_orig_system;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
end update_orig_system;

END HZ_ORIG_SYSTEM_REF_PVT;

/
