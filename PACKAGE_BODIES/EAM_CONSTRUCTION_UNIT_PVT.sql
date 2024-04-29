--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_UNIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_UNIT_PVT" as
/* $Header: EAMVCUB.pls 120.0.12010000.5 2008/12/15 08:13:55 dsingire noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'EAM_CONSTRUCTION_UNIT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMVCUB.pls';

--Procedures and functions used for debug purpose
PROCEDURE debug(p_message IN varchar2) IS
BEGIN
  IF get_debug = 'Y' THEN
    EAM_ERROR_MESSAGE_PVT.Write_Debug(p_message);
  END IF;
EXCEPTION
  WHEN others THEN
    null;
END debug;

PROCEDURE set_debug
    IS
BEGIN
       g_debug_flag := NVL(fnd_profile.value('EAM_DEBUG'), 'N');
END Set_Debug;

FUNCTION get_debug RETURN VARCHAR2
    IS
BEGIN
       RETURN g_debug_flag;
END;


PROCEDURE create_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2

      )  IS
  l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONSTRUCTION_UNIT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_debug_level       NUMBER := 0;
  l_cu_rec            EAM_CONSTRUCTION_UNIT_PUB.CU_rec;
  l_cu_activity_tbl   EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl;
  l_cu_activity_rec   EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_rec;
  l_time_stamp        DATE := SYSDATE;
  l_cu_id             NUMBER;
  l_cu_activity_id    NUMBER;
  l_activity_index    NUMBER;
  l_temp              VARCHAR(10);
  l_qtantity          NUMBER;
  l_multiplier        NUMBER;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT  create_construction_unit;

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;


    l_cu_rec := p_cu_rec;
    l_cu_activity_tbl := p_cu_activity_tbl;
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    IF (l_debug_level > 0) THEN
      debug('CREATE_CONSTRUCTION_UNIT');
    END IF;

    --If the debug level = 2 then dump all the parameters values.
   IF (l_debug_level > 1) THEN
        debug('CREATE_CONSTRUCTION_UNIT ' ||
               p_api_version     ||'-'||
               p_commit);
        debug('Dumping values of p_cu_rec');
        debug('CU_ID              : ' || p_cu_rec.CU_ID);
        debug('CU_NAME            : ' || p_cu_rec.CU_NAME);
        debug('DESCRIPTION        : ' || p_cu_rec.DESCRIPTION);
        debug('ORGANIZATION_ID    : ' || p_cu_rec.ORGANIZATION_ID);
        debug('CU_EFFECTIVE_FROM  : ' || p_cu_rec.CU_EFFECTIVE_FROM);
        debug('CU_EFFECTIVE_TO    : ' || p_cu_rec.CU_EFFECTIVE_TO);
        debug('ATTRIBUTE_CATEGORY : ' || p_cu_rec.attribute_category);
        debug('ATTRIBUTE1         : ' || p_cu_rec.ATTRIBUTE1);
        debug('ATTRIBUTE2         : ' || p_cu_rec.ATTRIBUTE2);
        debug('ATTRIBUTE3         : ' || p_cu_rec.ATTRIBUTE3);
        debug('ATTRIBUTE4         : ' || p_cu_rec.ATTRIBUTE4);
        debug('ATTRIBUTE5         : ' || p_cu_rec.ATTRIBUTE5);
        debug('ATTRIBUTE6         : ' || p_cu_rec.ATTRIBUTE6);
        debug('ATTRIBUTE7         : ' || p_cu_rec.ATTRIBUTE7);
        debug('ATTRIBUTE8         : ' || p_cu_rec.ATTRIBUTE8);
        debug('ATTRIBUTE9         : ' || p_cu_rec.ATTRIBUTE9);
        debug('ATTRIBUTE10        : ' || p_cu_rec.ATTRIBUTE10);
        debug('ATTRIBUTE11        : ' || p_cu_rec.ATTRIBUTE11);
        debug('ATTRIBUTE12        : ' || p_cu_rec.ATTRIBUTE12);
        debug('ATTRIBUTE13        : ' || p_cu_rec.ATTRIBUTE13);
        debug('ATTRIBUTE14        : ' || p_cu_rec.ATTRIBUTE14);
        debug('ATTRIBUTE15        : ' || p_cu_rec.ATTRIBUTE15);
    END IF;

    validate_cu_details(
           p_api_version  =>  p_api_version
          ,p_commit => p_commit
          ,p_cu_rec			       => p_cu_rec
          ,p_cu_activity_tbl   => p_cu_activity_tbl
          ,p_action            => 'CREATE'
          ,x_return_status     => x_return_status
          ,x_msg_count         => x_msg_count
          ,x_msg_data          => x_msg_data
          );

    --Check for x_return_status
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF  l_cu_rec.CU_ID IS NULL OR l_cu_rec.CU_ID = FND_API.G_MISS_NUM THEN
        l_cu_id := NULL;
    ELSE
        l_cu_id := l_cu_rec.CU_ID;
    END IF;

    EAM_CONSTRUCTION_UNIT_PKG.Insert_CU_Row(
           px_cu_id		         => l_cu_id
          ,p_cu_name		       => l_cu_rec.CU_NAME
          ,p_description	     => l_cu_rec.DESCRIPTION
          ,p_organization_id	 => l_cu_rec.ORGANIZATION_ID
          ,p_cu_effective_from => l_cu_rec.CU_EFFECTIVE_FROM
          ,p_cu_effective_to   => l_cu_rec.CU_EFFECTIVE_TO
          ,p_attribute_category => l_cu_rec.attribute_category
		      ,p_attribute1        => l_cu_rec.attribute1
		      ,p_attribute2        => l_cu_rec.attribute2
		      ,p_attribute3        => l_cu_rec.attribute3
		      ,p_attribute4        => l_cu_rec.attribute4
		      ,p_attribute5        => l_cu_rec.attribute5
		      ,p_attribute6        => l_cu_rec.attribute6
		      ,p_attribute7        => l_cu_rec.attribute7
		      ,p_attribute8        => l_cu_rec.attribute8
		      ,p_attribute9        => l_cu_rec.attribute9
		      ,p_attribute10       => l_cu_rec.attribute10
		      ,p_attribute11       => l_cu_rec.attribute11
		      ,p_attribute12       => l_cu_rec.attribute12
		      ,p_attribute13       => l_cu_rec.attribute13
		      ,p_attribute14       => l_cu_rec.attribute14
		      ,p_attribute15     	 => l_cu_rec.attribute15
  		    ,p_creation_date     => SYSDATE
          ,p_created_by        => FND_GLOBAL.USER_ID
          ,p_last_update_date  => SYSDATE
          ,p_last_updated_by   => FND_GLOBAL.USER_ID
          ,p_last_update_login => FND_GLOBAL.CONC_LOGIN_ID
          );

    x_cu_id := l_cu_id;
    FOR l_activity_index IN 1 .. l_cu_activity_tbl.Count LOOP
      l_cu_activity_rec := NULL;
      l_cu_activity_rec :=   l_cu_activity_tbl(l_activity_index);
      l_cu_activity_id := NULL;

      EAM_CONSTRUCTION_UNIT_PKG.Insert_CU_Activity_Row(
           px_cu_detail_id		          => l_cu_activity_id
          ,p_cu_id			                => l_cu_id
          ,p_acct_class_code		        => l_cu_activity_rec.ACCT_CLASS_CODE
          ,p_activity_id		            => l_cu_activity_rec.ACTIVITY_ID
          ,p_cu_activity_qty		        => l_cu_activity_rec.CU_ACTIVITY_QTY
          ,p_cu_activity_effective_from => l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM
          ,p_cu_activity_effective_to   => l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_TO
          ,p_creation_date              => SYSDATE
          ,p_created_by                 => FND_GLOBAL.USER_ID
          ,p_last_update_date           => SYSDATE
          ,p_last_updated_by            => FND_GLOBAL.USER_ID
          ,p_last_update_login          => FND_GLOBAL.CONC_LOGIN_ID
          );

    END LOOP;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_construction_unit;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO create_construction_unit;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERROR');
    fnd_message.set_token('API_NAME',l_api_name);
    fnd_message.set_token('SQL_ERROR',SQLERRM);
    FND_MSG_PUB.Add;
    x_msg_data := fnd_message.get;
END create_construction_unit;

PROCEDURE update_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2

      )  IS
  l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONSTRUCTION_UNIT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_debug_level       NUMBER := 0;
  l_cu_rec  EAM_CONSTRUCTION_UNIT_PUB.CU_rec;
  l_cu_activity_tbl   EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl;
  l_cu_activity_rec   EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_rec;
  l_time_stamp        DATE := SYSDATE;
  l_cu_id             NUMBER;
  l_cu_activity_id    NUMBER;
  l_activity_index    NUMBER;
  l_temp              VARCHAR(10);
  l_qtantity          NUMBER;
  l_multiplier        NUMBER;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT  update_construction_unit;

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_cu_rec := p_cu_rec;
    l_cu_activity_tbl := p_cu_activity_tbl;
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;

    IF (l_debug_level > 0) THEN
      debug('UPDATE_CONSTRUCTION_UNIT');
    END IF;

    --If the debug level = 2 then dump all the parameters values.
   IF (l_debug_level > 1) THEN
        debug('UPDATE_CONSTRUCTION_UNIT' ||
               To_Char(p_api_version)     ||'-'||
               p_commit);
        debug('Dumping values of p_cu_rec');
        debug('CU_ID              : ' || p_cu_rec.CU_ID);
        debug('CU_NAME            : ' || p_cu_rec.CU_NAME);
        debug('DESCRIPTION        : ' || p_cu_rec.DESCRIPTION);
        debug('ORGANIZATION_ID    : ' || p_cu_rec.ORGANIZATION_ID);
        debug('CU_EFFECTIVE_FROM  : ' || p_cu_rec.CU_EFFECTIVE_FROM);
        debug('CU_EFFECTIVE_TO    : ' || p_cu_rec.CU_EFFECTIVE_TO);
        debug('ATTRIBUTE_CATEGORY : ' || p_cu_rec.attribute_category);
        debug('ATTRIBUTE1         : ' || p_cu_rec.ATTRIBUTE1);
        debug('ATTRIBUTE2         : ' || p_cu_rec.ATTRIBUTE2);
        debug('ATTRIBUTE3         : ' || p_cu_rec.ATTRIBUTE3);
        debug('ATTRIBUTE4         : ' || p_cu_rec.ATTRIBUTE4);
        debug('ATTRIBUTE5         : ' || p_cu_rec.ATTRIBUTE5);
        debug('ATTRIBUTE6         : ' || p_cu_rec.ATTRIBUTE6);
        debug('ATTRIBUTE7         : ' || p_cu_rec.ATTRIBUTE7);
        debug('ATTRIBUTE8         : ' || p_cu_rec.ATTRIBUTE8);
        debug('ATTRIBUTE9         : ' || p_cu_rec.ATTRIBUTE9);
        debug('ATTRIBUTE10        : ' || p_cu_rec.ATTRIBUTE10);
        debug('ATTRIBUTE11        : ' || p_cu_rec.ATTRIBUTE11);
        debug('ATTRIBUTE12        : ' || p_cu_rec.ATTRIBUTE12);
        debug('ATTRIBUTE13        : ' || p_cu_rec.ATTRIBUTE13);
        debug('ATTRIBUTE14        : ' || p_cu_rec.ATTRIBUTE14);
        debug('ATTRIBUTE15        : ' || p_cu_rec.ATTRIBUTE15);
    END IF;

    validate_cu_details(
           p_api_version  =>  p_api_version
          ,p_commit => p_commit
          ,p_cu_rec			       => p_cu_rec
          ,p_cu_activity_tbl   => p_cu_activity_tbl
          ,p_action            => 'UPDATE'
          ,x_return_status     => x_return_status
          ,x_msg_count         => x_msg_count
          ,x_msg_data          => x_msg_data
          );

    --Check for x_return_status
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF  l_cu_rec.CU_ID IS NULL OR l_cu_rec.CU_ID = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_CU_INVALID_CUID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_cu_id := l_cu_rec.CU_ID;
    END IF;

    EAM_CONSTRUCTION_UNIT_PKG.Update_CU_Row(
           p_cu_id		         => l_cu_id
          ,p_cu_name		       => l_cu_rec.CU_NAME
          ,p_description	     => l_cu_rec.DESCRIPTION
          ,p_organization_id	 => l_cu_rec.ORGANIZATION_ID
          ,p_cu_effective_from => l_cu_rec.CU_EFFECTIVE_FROM
          ,p_cu_effective_to   => l_cu_rec.CU_EFFECTIVE_TO
          ,p_attribute_category         => l_cu_rec.attribute_category
		      ,p_attribute1                 => l_cu_rec.attribute1
		      ,p_attribute2                 => l_cu_rec.attribute2
		      ,p_attribute3                 => l_cu_rec.attribute3
		      ,p_attribute4                 => l_cu_rec.attribute4
		      ,p_attribute5                 => l_cu_rec.attribute5
		      ,p_attribute6                 => l_cu_rec.attribute6
		      ,p_attribute7                 => l_cu_rec.attribute7
		      ,p_attribute8                 => l_cu_rec.attribute8
		      ,p_attribute9                 => l_cu_rec.attribute9
		      ,p_attribute10                => l_cu_rec.attribute10
		      ,p_attribute11                => l_cu_rec.attribute11
		      ,p_attribute12                => l_cu_rec.attribute12
		      ,p_attribute13                => l_cu_rec.attribute13
		      ,p_attribute14                => l_cu_rec.attribute14
		      ,p_attribute15     			=> l_cu_rec.attribute15
		      ,p_last_update_date  => SYSDATE
          ,p_last_updated_by   => FND_GLOBAL.USER_ID
          ,p_last_update_login => FND_GLOBAL.CONC_LOGIN_ID
          );

    x_cu_id := l_cu_id;

    FOR l_activity_index IN 1 .. l_cu_activity_tbl.Count LOOP
      l_cu_activity_rec := NULL;
      l_cu_activity_rec :=   l_cu_activity_tbl(l_activity_index);

      IF  l_cu_activity_rec.CU_DETAIL_ID IS NULL OR l_cu_activity_rec.CU_DETAIL_ID = FND_API.G_MISS_NUM THEN
          l_cu_activity_id := NULL;

          EAM_CONSTRUCTION_UNIT_PKG.Insert_CU_Activity_Row(
              px_cu_detail_id		          => l_cu_activity_id
              ,p_cu_id			                => l_cu_id
              ,p_acct_class_code		        => l_cu_activity_rec.ACCT_CLASS_CODE
              ,p_activity_id		            => l_cu_activity_rec.ACTIVITY_ID
              ,p_cu_activity_qty		        => l_cu_activity_rec.CU_ACTIVITY_QTY
              ,p_cu_activity_effective_from => l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM
              ,p_cu_activity_effective_to   => l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_TO
              ,p_creation_date              => SYSDATE
              ,p_created_by                 => FND_GLOBAL.USER_ID
              ,p_last_update_date           => SYSDATE
              ,p_last_updated_by            => FND_GLOBAL.USER_ID
              ,p_last_update_login          => FND_GLOBAL.CONC_LOGIN_ID
              );
      ELSE
          l_cu_activity_id := l_cu_activity_rec.CU_DETAIL_ID;

          EAM_CONSTRUCTION_UNIT_PKG.Update_CU_Activity_Row(
               p_cu_detail_id		            => l_cu_activity_id
              ,p_cu_id			                => l_cu_id
              ,p_acct_class_code		        => l_cu_activity_rec.ACCT_CLASS_CODE
              ,p_activity_id		            => l_cu_activity_rec.ACTIVITY_ID
              ,p_cu_activity_qty		        => l_cu_activity_rec.CU_ACTIVITY_QTY
              ,p_cu_activity_effective_from => l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM
              ,p_cu_activity_effective_to   => l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_TO
              ,p_last_update_date           => SYSDATE
              ,p_last_updated_by            => FND_GLOBAL.USER_ID
              ,p_last_update_login          => FND_GLOBAL.CONC_LOGIN_ID
              );
      END IF;
    END LOOP;
     -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_construction_unit;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO update_construction_unit;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERROR');
    fnd_message.set_token('API_NAME',l_api_name);
    fnd_message.set_token('SQL_ERROR',SQLERRM);
    FND_MSG_PUB.Add;
    x_msg_data := fnd_message.get;
END update_construction_unit;


PROCEDURE copy_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,p_source_cu_id_tbl        IN    EAM_CONSTRUCTION_UNIT_PUB.CU_ID_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      )  IS
  l_api_name          CONSTANT VARCHAR2(30) := 'COPY_CONSTRUCTION_UNIT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_debug_level       NUMBER := 0;
  l_temp              VARCHAR2(10);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT  copy_construction_unit;

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;

    IF (l_debug_level > 0) THEN
      debug('copy_construction_unit');
    END IF;

    --If the debug level = 2 then dump all the parameters values.
   IF (l_debug_level > 1) THEN
        debug('copy_construction_unit' ||
               p_api_version     ||'-'||
               p_commit);
        debug('Dumping values of p_cu_rec');
        debug('CU_ID              : ' || p_cu_rec.CU_ID);
        debug('CU_NAME            : ' || p_cu_rec.CU_NAME);
        debug('DESCRIPTION        : ' || p_cu_rec.DESCRIPTION);
        debug('ORGANIZATION_ID    : ' || p_cu_rec.ORGANIZATION_ID);
        debug('CU_EFFECTIVE_FROM  : ' || p_cu_rec.CU_EFFECTIVE_FROM);
        debug('CU_EFFECTIVE_TO    : ' || p_cu_rec.CU_EFFECTIVE_TO);
        debug('ATTRIBUTE_CATEGORY : ' || p_cu_rec.attribute_category);
        debug('ATTRIBUTE1         : ' || p_cu_rec.ATTRIBUTE1);
        debug('ATTRIBUTE2         : ' || p_cu_rec.ATTRIBUTE2);
        debug('ATTRIBUTE3         : ' || p_cu_rec.ATTRIBUTE3);
        debug('ATTRIBUTE4         : ' || p_cu_rec.ATTRIBUTE4);
        debug('ATTRIBUTE5         : ' || p_cu_rec.ATTRIBUTE5);
        debug('ATTRIBUTE6         : ' || p_cu_rec.ATTRIBUTE6);
        debug('ATTRIBUTE7         : ' || p_cu_rec.ATTRIBUTE7);
        debug('ATTRIBUTE8         : ' || p_cu_rec.ATTRIBUTE8);
        debug('ATTRIBUTE9         : ' || p_cu_rec.ATTRIBUTE9);
        debug('ATTRIBUTE10        : ' || p_cu_rec.ATTRIBUTE10);
        debug('ATTRIBUTE11        : ' || p_cu_rec.ATTRIBUTE11);
        debug('ATTRIBUTE12        : ' || p_cu_rec.ATTRIBUTE12);
        debug('ATTRIBUTE13        : ' || p_cu_rec.ATTRIBUTE13);
        debug('ATTRIBUTE14        : ' || p_cu_rec.ATTRIBUTE14);
        debug('ATTRIBUTE15        : ' || p_cu_rec.ATTRIBUTE15);
    END IF;

    IF p_cu_activity_tbl.Count < 1 THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_CU_ATLEAST_ONE_ACTIVITY');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR l_assign_count IN p_cu_activity_tbl.FIRST..p_cu_activity_tbl.LAST
    LOOP
        IF  p_cu_activity_tbl.EXISTS(l_assign_count)
        AND NVL(p_cu_activity_tbl(l_assign_count).CU_ASSIGN_TO_ORG ,FND_API.G_MISS_CHAR) = 'Y' THEN

          BEGIN
            SELECT  'X'
            INTO    l_temp
            FROM    mtl_system_items_b
            WHERE   inventory_item_id = p_cu_activity_tbl(l_assign_count).ACTIVITY_ID
            AND     organization_id = p_cu_rec.ORGANIZATION_ID;

          EXCEPTION
            WHEN No_Data_Found THEN
                EAM_Activity_PUB.Activity_org_assign (
                      p_api_version    => 1.0,
	                    x_return_status	 => x_return_status,
	                    x_msg_count		   => x_msg_count,
	                    x_msg_data		   => x_msg_data,
	                    p_org_id		     => p_cu_rec.ORGANIZATION_ID,
	                    p_activity_id	   => p_cu_activity_tbl(l_assign_count).ACTIVITY_ID);

                IF x_return_status = fnd_api.g_ret_sts_error THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
          END;
        END IF;

    END LOOP;


    create_construction_unit(
           p_api_version  =>  p_api_version
          ,p_commit => p_commit
          ,p_cu_rec			       => p_cu_rec
          ,p_cu_activity_tbl   => p_cu_activity_tbl
          ,x_cu_id             => x_cu_id
          ,x_return_status     => x_return_status
          ,x_msg_count         => x_msg_count
          ,x_msg_data          => x_msg_data
          );

    FOR  cu_id_ind IN  p_source_cu_id_tbl.FIRST .. p_source_cu_id_tbl.LAST LOOP
      fnd_attached_documents2_pkg.copy_attachments(
            X_from_entity_name      =>  'EAM_CONSTRUCTION_UNIT',
            X_from_pk1_value        =>  p_source_cu_id_tbl(cu_id_ind).CU_ID,
            X_from_pk2_value        =>  '',
            X_from_pk3_value        =>  '',
            X_from_pk4_value        =>  '',
            X_from_pk5_value        =>  '',
            X_to_entity_name        =>  'EAM_CONSTRUCTION_UNIT',
            X_to_pk1_value          =>  x_cu_id,
            X_to_pk2_value          =>  '',
            X_to_pk3_value          =>  '',
            X_to_pk4_value          =>  '',
            X_to_pk5_value          =>  '',
            X_created_by            =>  FND_GLOBAL.USER_ID,
            X_last_update_login     =>  '',
            X_program_application_id=>  '',
            X_program_id            =>  '',
            X_request_id            =>  ''
            );
    END LOOP;


         --Check for x_return_status
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO copy_construction_unit;
		x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO copy_construction_unit;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERROR');
    fnd_message.set_token('API_NAME',l_api_name);
    fnd_message.set_token('SQL_ERROR',SQLERRM);
    FND_MSG_PUB.Add;
    x_msg_data := fnd_message.get;

END copy_construction_unit;



PROCEDURE validate_cu_details(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,p_action                  IN    VARCHAR2
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      )  IS
  l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_CU_DETAILS';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_debug_level       NUMBER := 0;
  l_cu_rec            EAM_CONSTRUCTION_UNIT_PUB.CU_rec;
  l_cu_activity_tbl   EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl;
  l_cu_activity_rec   EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_rec;
  l_activity_index    NUMBER;
  l_temp              VARCHAR2(10);
  l_qtantity          NUMBER;
  l_activity_name     VARCHAR2(2000);
  l_org_code          VARCHAR2(2000);
BEGIN

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_debug_level > 0) THEN
      debug('VALIDATE_CU_DETAILS');
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    l_cu_rec := p_cu_rec;

    IF (l_cu_rec.CU_NAME IS NULL OR l_cu_rec.CU_NAME = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_CU_NAME_NULL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      BEGIN
        SELECT  'X'
        INTO    l_temp
        FROM    eam_construction_units
        WHERE   cu_name = l_cu_rec.CU_NAME
		    AND     cu_id <> Nvl(l_cu_rec.CU_ID, FND_API.G_MISS_NUM);

        FND_MESSAGE.SET_NAME('EAM','EAM_CU_NAME_DUPLICATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      EXCEPTION
        WHEN No_Data_Found THEN
          NULL;
      END;
    END IF;

    IF  Nvl(l_cu_rec.cu_effective_from,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE THEN
        IF p_action = 'CREATE' THEN
          l_cu_rec.cu_effective_from := SYSDATE;
        ELSE
          FND_MESSAGE.SET_NAME('EAM','EAM_CU_EFFECTIVE_FROM_NULL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF Nvl(l_cu_rec.cu_effective_to,FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
      IF l_cu_rec.cu_effective_to < l_cu_rec.cu_effective_from THEN
          FND_MESSAGE.SET_NAME('EAM','EAM_CU_EFFECTIVE_TO_FROM_ERROR');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF p_cu_activity_tbl.Count < 1 THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_CU_ATLEAST_ONE_ACTIVITY');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_cu_activity_tbl := p_cu_activity_tbl;

    -- Valication of CU Activity details - Begin
    FOR l_activity_index IN 1 .. l_cu_activity_tbl.Count LOOP
      l_cu_activity_rec := NULL;
      l_cu_activity_rec :=   l_cu_activity_tbl(l_activity_index);

      IF (l_debug_level > 1) THEN
            debug('Dumping values of l_cu_activity_rec');
            debug('CU_ID                      : ' || l_cu_activity_rec.CU_ID);
            debug('CU_DETAIL_ID               : ' || l_cu_activity_rec.CU_DETAIL_ID);
            debug('ACCT_CLASS_CODE            : ' || l_cu_activity_rec.ACCT_CLASS_CODE);
            debug('ACTIVITY_ID                : ' || l_cu_activity_rec.ACTIVITY_ID);
            debug('CU_ACTIVITY_QTY            : ' || l_cu_activity_rec.CU_ACTIVITY_QTY);
            debug('CU_ACTIVITY_EFFECTIVE_FROM : ' || l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM);
            debug('CU_ACTIVITY_EFFECTIVE_TO   : ' || l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_TO);
            debug('CU_ASSIGN_TO_ORG           : ' || l_cu_activity_rec.CU_ASSIGN_TO_ORG);
      END IF;


      BEGIN
        SELECT  concatenated_segments
        INTO    l_activity_name
        FROM    mtl_system_items_kfv
        WHERE   inventory_item_id = l_cu_activity_rec.ACTIVITY_ID
        AND     ROWNUM < 2 ;


        SELECT  organization_code
        INTO    l_org_code
        FROM    mtl_parameters
        WHERE   organization_id =  l_cu_rec.ORGANIZATION_ID
        AND     ROWNUM < 2 ;

      EXCEPTION
        WHEN No_Data_Found THEN
            FND_MESSAGE.SET_NAME('EAM','EAM_CU_INVALID_ACTIVITY');
	    FND_MESSAGE.SET_TOKEN('ACTIVITY',l_cu_activity_rec.ACTIVITY_ID);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          NULL;
      END;

      BEGIN
        SELECT  'X'
        INTO    l_temp
        FROM    mtl_system_items_b
        WHERE   inventory_item_id = l_cu_activity_rec.ACTIVITY_ID
        AND     organization_id = l_cu_rec.ORGANIZATION_ID;

      EXCEPTION
        WHEN No_Data_Found THEN
            FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACTIVITY_NOT_ASSIGNED');
            FND_MESSAGE.SET_TOKEN('ACTIVITY',l_activity_name);
            FND_MESSAGE.SET_TOKEN('ORG',l_org_code);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
      END;

      IF  Nvl(l_cu_activity_rec.ACCT_CLASS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
        BEGIN
          SELECT  'X'
          INTO    l_temp
          FROM    WIP_ACCOUNTING_CLASSES
          WHERE   organization_id = l_cu_rec.ORGANIZATION_ID
          AND     class_code = l_cu_activity_rec.ACCT_CLASS_CODE
          AND     ((disable_date IS NULL )OR (disable_date > SYSDATE))
          AND     class_type = 6;

        EXCEPTION
          WHEN No_Data_Found THEN
              FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACCTCLASS_NOT_ASSIGNED');
              FND_MESSAGE.SET_TOKEN('ACCTCLASS',l_cu_activity_rec.ACCT_CLASS_CODE);
              FND_MESSAGE.SET_TOKEN('ORG',l_org_code);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
        END;
      END IF;

      l_qtantity := l_cu_activity_rec.CU_ACTIVITY_QTY;
      IF  l_qtantity*100 <> Round(l_qtantity*100) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACT_QTY_DECIMAL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF  l_qtantity < 0 THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACT_QTY_POSITIVE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF  Nvl(l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE THEN
            FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACT_EFFECTIVE_FROM_NULL');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF  l_cu_rec.CU_EFFECTIVE_FROM >  l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACT_CU_EFFECTIVE_FROM');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF Nvl(l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_TO,FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
        IF l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_TO < l_cu_activity_rec.CU_ACTIVITY_EFFECTIVE_FROM   THEN
            FND_MESSAGE.SET_NAME('EAM','EAM_CU_ACT_EFFT_TO_FROM_ERROR');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
    -- Valication of CU Activity details - End

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data     := dump_error_stack;
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      FND_MSG_PUB.Add;
      x_msg_data := fnd_message.get;
END validate_cu_details;

  FUNCTION dump_error_stack RETURN varchar2
  IS
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_msg_index_out   number;
    x_msg_data        varchar2(4000);
  BEGIN
    x_msg_data := null;
    fnd_msg_pub.count_and_get(
      p_count  => l_msg_count,
      p_data   => l_msg_data);

    FOR l_ind IN 1..l_msg_count
    LOOP
      fnd_msg_pub.get(
        p_msg_index     => l_ind,
        p_encoded       => fnd_api.g_false,
        p_data          => l_msg_data,
        p_msg_index_out => l_msg_index_out);

      x_msg_data := ltrim(x_msg_data||' '||l_msg_data);
      IF length(x_msg_data) > 1999 THEN
        x_msg_data := substr(x_msg_data, 1, 1999);
        exit;
      END IF;
    END LOOP;
    RETURN x_msg_data;
  EXCEPTION
    when others then
      RETURN x_msg_data;
  END dump_error_stack;

End EAM_CONSTRUCTION_UNIT_PVT;

/
