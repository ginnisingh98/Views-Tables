--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_ORGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_ORGS_PVT" AS
  /* $Header: jtfrseob.pls 120.0 2005/05/11 08:19:56 appldev noship $ */

  /*****************************************************************************************
   This is a private API that caller will invoke.
   It provides procedures for managing resource group to HR Org mapping
   Its main procedures are as following:
   Create Group Org
   Update Group Org
   Delete Group Org
   Calls to these procedures will invoke calls to table handlers which
   do actual insert, update and delete into tables.
   ******************************************************************************************/

   --Package variables.

   G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_GROUP_ORGS_PVT';

  /* Procedure to create the resource group - HR Org mapping
  */

  PROCEDURE  create_group_org
  (P_API_VERSION           IN  NUMBER,
   P_INIT_MSG_LIST         IN  VARCHAR2,
   P_COMMIT                IN  VARCHAR2,
   P_GROUP_ID              IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID       IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_ATTRIBUTE1            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY    IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS         OUT NOCOPY  	VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY  	NUMBER,
   X_MSG_DATA              OUT NOCOPY  	VARCHAR2
  ) IS

    l_api_version            CONSTANT NUMBER := 1.0;
    l_api_name               CONSTANT VARCHAR2(50) := 'CREATE_GROUP_ORG';

    l_return_status          VARCHAR2(30);
    l_msg_data               VARCHAR2(2000);
    l_msg_count              NUMBER;

    l_group_id               JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE;
    l_organization_id        JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE;
    l_group_start_date       DATE;
    l_group_end_date         DATE;
    l_group_name             jtf_rs_groups_tl.group_name%TYPE;
    l_org_start_date         DATE;
    l_org_end_date           DATE;
    l_org_name               hr_all_organization_units_tl.NAME%TYPE;
    l_mapping_exist          VARCHAR2(30);

    CURSOR c_validate_group(ll_group_id IN JTF_RS_GROUPS_B.GROUP_ID%TYPE) IS
      SELECT start_date_active,
	         NVL(end_date_active, TRUNC(SYSDATE)+1),
	         group_name
      FROM   jtf_rs_groups_vl
      WHERE  group_id = ll_group_id
	  ;

    CURSOR c_validate_hr_org(ll_org_id IN hr_all_organization_units.organization_id%TYPE) IS
      SELECT hr.date_from,
   	         NVL(hr.date_to, TRUNC(SYSDATE)+1),
   	         hr.NAME
      FROM   hr_all_organization_units_vl hr
      WHERE  hr.organization_id = ll_org_id
      ;

    CURSOR c_check_dup_group_org_map(ll_group_id IN JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
                                     ll_org_id   IN JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE) IS
      SELECT 'Y'
      FROM   jtf_rs_group_organizations
      WHERE  group_id = ll_group_id
      AND    organization_id = ll_org_id
      ;

  BEGIN

    SAVEPOINT create_group_org;

    --initialize variables
    l_group_id            := p_group_id;
    l_organization_id     := p_organization_id;
    l_mapping_exist       := 'N';
    x_return_status       := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Validate that the group is valid and not end dated */

    OPEN   c_validate_group(l_group_id);
    FETCH  c_validate_group INTO l_group_start_date, l_group_end_date, l_group_name;
    CLOSE  c_validate_group;


    IF (l_group_start_date IS NULL) THEN
	  fnd_message.set_name('JTF', 'JTF_RS_INVALID_GROUP');
	  fnd_message.set_token('P_GROUP_ID',l_group_id);
	  fnd_msg_pub.add;
  	  RAISE fnd_api.g_exc_error;
    ELSIF
      ((l_group_start_date IS NOT NULL) AND
       (l_group_end_date < TRUNC(SYSDATE))
       ) THEN
	  fnd_message.set_name('JTF', 'JTF_RS_INACTIVE_GROUP');
	  fnd_message.set_token('P_GROUP_NAME',l_group_name);
	  fnd_msg_pub.add;
  	  RAISE fnd_api.g_exc_error;
    END IF;


    /* Validate that the HR Org is valid and not end dated */

    OPEN   c_validate_hr_org(l_organization_id);
    FETCH  c_validate_hr_org INTO l_org_start_date, l_org_end_date, l_org_name;
    CLOSE  c_validate_hr_org;


    IF (l_org_start_date IS NULL) THEN
	  fnd_message.set_name('JTF', 'JTF_RS_INVALID_HR_ORG');
	  fnd_message.set_token('P_ORG_ID',l_organization_id);
	  fnd_msg_pub.add;
  	  RAISE fnd_api.g_exc_error;
    ELSIF
      ((l_org_start_date IS NOT NULL) AND
       (l_org_end_date < TRUNC(SYSDATE))
       ) THEN
	  fnd_message.set_name('JTF', 'JTF_RS_INACTIVE_HR_ORG');
	  fnd_message.set_token('P_ORG_NAME',l_org_name);
	  fnd_msg_pub.add;
  	  RAISE fnd_api.g_exc_error;
    END IF;

  /* Validate that Resource Group and HR Org mapping does not already exist */

    OPEN   c_check_dup_group_org_map(l_group_id,l_organization_id);
    FETCH  c_check_dup_group_org_map INTO l_mapping_exist;
    CLOSE  c_check_dup_group_org_map;

    IF (l_mapping_exist = 'Y') THEN
	  fnd_message.set_name('JTF', 'JTF_RS_GROUP_ORG_MAP_EXIST');
	  fnd_message.set_token('P_GROUP_NAME',l_group_name);
 	  fnd_message.set_token('P_ORG_NAME',l_org_name);
	  fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    /* Insert the row into the table */

	  INSERT INTO jtf_rs_group_organizations (
	    GROUP_ID,
	    ORGANIZATION_ID,
	    OBJECT_VERSION_NUMBER,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    ATTRIBUTE1,
	    ATTRIBUTE2,
	    ATTRIBUTE3,
	    ATTRIBUTE4,
	    ATTRIBUTE5,
	    ATTRIBUTE6,
	    ATTRIBUTE7,
	    ATTRIBUTE8,
	    ATTRIBUTE9,
	    ATTRIBUTE10,
	    ATTRIBUTE11,
	    ATTRIBUTE12,
	    ATTRIBUTE13,
	    ATTRIBUTE14,
	    ATTRIBUTE15,
	    ATTRIBUTE_CATEGORY
	    ) VALUES (
	    P_GROUP_ID,
	    P_ORGANIZATION_ID,
	    1,
	    SYSDATE,
	    jtf_resource_utl.created_by,
	    SYSDATE,
	    jtf_resource_utl.updated_by,
	    jtf_resource_utl.login_id,
	    P_ATTRIBUTE1,
	    P_ATTRIBUTE2,
	    P_ATTRIBUTE3,
	    P_ATTRIBUTE4,
	    P_ATTRIBUTE5,
	    P_ATTRIBUTE6,
	    P_ATTRIBUTE7,
	    P_ATTRIBUTE8,
	    P_ATTRIBUTE9,
	    P_ATTRIBUTE10,
	    P_ATTRIBUTE11,
	    P_ATTRIBUTE12,
	    P_ATTRIBUTE13,
	    P_ATTRIBUTE14,
	    P_ATTRIBUTE15,
	    P_ATTRIBUTE_CATEGORY
	  );

    IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_group_org;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_group_org;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_group_org;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', g_pkg_name||'.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END create_group_org;


  /* Procedure to update the resource group - HR Org mapping
  */

  PROCEDURE  update_group_org
  (P_API_VERSION           IN  NUMBER,
   P_INIT_MSG_LIST         IN  VARCHAR2,
   P_COMMIT                IN  VARCHAR2,
   P_GROUP_ID              IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID       IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_ATTRIBUTE1            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9            IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15           IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY    IN  JTF_RS_GROUP_ORGANIZATIONS.ATTRIBUTE_CATEGORY%TYPE,
   P_OBJECT_VERSION_NUMBER IN OUT NOCOPY JTF_RS_GROUP_ORGANIZATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS         OUT NOCOPY  		VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY  		NUMBER,
   X_MSG_DATA              OUT NOCOPY  		VARCHAR2
  )
  IS
    l_api_version         	CONSTANT NUMBER := 1.0;
    l_api_name            	CONSTANT VARCHAR2(30) := 'UPDATE_GROUP_ORG';
    l_group_id              JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE;
    l_organization_id       JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE;
    l_object_version_number JTF_RS_GROUP_ORGANIZATIONS.object_version_number%type;

    CURSOR c_group_org_update(ll_group_id IN NUMBER,
       	                      ll_organization_id IN NUMBER) IS
      SELECT
         group_id l_group_id,
         organization_id l_organization_id,
         object_version_number l_object_version_number,
         DECODE(p_attribute1,fnd_api.g_miss_char, attribute1, p_attribute1) l_attribute1,
         DECODE(p_attribute2,fnd_api.g_miss_char, attribute2, p_attribute2) l_attribute2,
         DECODE(p_attribute3,fnd_api.g_miss_char, attribute3, p_attribute3) l_attribute3,
         DECODE(p_attribute4,fnd_api.g_miss_char, attribute4, p_attribute4) l_attribute4,
         DECODE(p_attribute5,fnd_api.g_miss_char, attribute5, p_attribute5) l_attribute5,
         DECODE(p_attribute6,fnd_api.g_miss_char, attribute6, p_attribute6) l_attribute6,
         DECODE(p_attribute7,fnd_api.g_miss_char, attribute7, p_attribute7) l_attribute7,
         DECODE(p_attribute8,fnd_api.g_miss_char, attribute8, p_attribute8) l_attribute8,
         DECODE(p_attribute9,fnd_api.g_miss_char, attribute9, p_attribute9) l_attribute9,
         DECODE(p_attribute10,fnd_api.g_miss_char, attribute10, p_attribute10) l_attribute10,
         DECODE(p_attribute11,fnd_api.g_miss_char, attribute11, p_attribute11) l_attribute11,
         DECODE(p_attribute12,fnd_api.g_miss_char, attribute12, p_attribute12) l_attribute12,
         DECODE(p_attribute13,fnd_api.g_miss_char, attribute13, p_attribute13) l_attribute13,
         DECODE(p_attribute14,fnd_api.g_miss_char, attribute14, p_attribute14) l_attribute14,
         DECODE(p_attribute15,fnd_api.g_miss_char, attribute15, p_attribute15) l_attribute15,
         DECODE(p_attribute_category,fnd_api.g_miss_char, attribute_category, p_attribute_category) l_attribute_category
      FROM  jtf_rs_group_organizations
      WHERE group_id = ll_group_id
	  AND   organization_id = ll_organization_id;

      group_org_rec c_group_org_update%ROWTYPE;

  BEGIN
    SAVEPOINT sp_update_group_org;

    -- initialize valriables
    l_group_id	              := p_group_id;
    l_organization_id	      := p_organization_id;
    l_object_version_number   := p_object_version_number;
	x_return_status           := fnd_api.g_ret_sts_success;

	IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
    END IF;

    --Fetch the existing data from table
    OPEN c_group_org_update(l_group_id, l_organization_id);
    FETCH c_group_org_update INTO group_org_rec;
    IF c_group_org_update%NOTFOUND THEN
       CLOSE c_group_org_update;
       fnd_message.set_name('JTF', 'JTF_RS_INVALID_GRP_ORG_ID');
       fnd_message.set_token('P_GRP_ID', l_group_id);
       fnd_message.set_token('P_ORG_ID', l_organization_id);
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_unexpected_error;
    ELSE
       CLOSE c_group_org_update;
    END IF;

   --Check if object Version numbers match
   IF (group_org_rec.l_object_version_number = l_object_version_number)
   THEN
     NULL;
   ELSE
     fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
     fnd_msg_pub.add;
     RAISE fnd_api.g_exc_error;
   END IF;

   --Update the Object Version Number by Incrementing It
   l_object_version_number    := l_object_version_number+1;

   --Update the Values in jtf_rs_group_organizations

   UPDATE jtf_rs_group_organizations SET
	    GROUP_ID        = group_org_rec.l_group_id,
	    ORGANIZATION_ID = group_org_rec.l_organization_id,
	    OBJECT_VERSION_NUMBER = l_object_version_number,
	    LAST_UPDATE_DATE = SYSDATE,
	    LAST_UPDATED_BY = jtf_resource_utl.updated_by,
	    LAST_UPDATE_LOGIN = jtf_resource_utl.login_id,
	    ATTRIBUTE1 = group_org_rec.l_attribute1,
	    ATTRIBUTE2 = group_org_rec.l_attribute2,
	    ATTRIBUTE3 = group_org_rec.l_attribute3,
	    ATTRIBUTE4 = group_org_rec.l_attribute4,
	    ATTRIBUTE5 = group_org_rec.l_attribute5,
	    ATTRIBUTE6 = group_org_rec.l_attribute6,
	    ATTRIBUTE7 = group_org_rec.l_attribute7,
	    ATTRIBUTE8 = group_org_rec.l_attribute8,
	    ATTRIBUTE9 = group_org_rec.l_attribute9,
	    ATTRIBUTE10 = group_org_rec.l_attribute10,
	    ATTRIBUTE11 = group_org_rec.l_attribute11,
	    ATTRIBUTE12 = group_org_rec.l_attribute12,
	    ATTRIBUTE13 = group_org_rec.l_attribute13,
	    ATTRIBUTE14 = group_org_rec.l_attribute14,
	    ATTRIBUTE15 = group_org_rec.l_attribute15,
	    ATTRIBUTE_CATEGORY = group_org_rec.l_attribute_category
	  WHERE GROUP_ID = l_group_id
	  AND   ORGANIZATION_ID = l_organization_id;

      p_object_version_number := l_object_version_number;

   IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
   END IF;

   fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO sp_update_group_org;
         x_return_status := fnd_api.g_ret_sts_error;
         FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO sp_update_group_org;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO sp_update_group_org;
         fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
         fnd_message.set_token('P_SQLCODE',SQLCODE);
         fnd_message.set_token('P_SQLERRM',SQLERRM);
         fnd_message.set_token('P_API_NAME',g_pkg_name||'.'||l_api_name);
         FND_MSG_PUB.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END update_group_org;


  /* Procedure to delete resource group - HR Org mapping
  */

  PROCEDURE  delete_group_org
  (P_API_VERSION            IN  NUMBER,
   P_INIT_MSG_LIST          IN  VARCHAR2,
   P_COMMIT                 IN  VARCHAR2,
   P_GROUP_ID              IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID       IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_OBJECT_VERSION_NUMBER  IN  JTF_RS_GROUP_ORGANIZATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT              OUT NOCOPY  NUMBER,
   X_MSG_DATA               OUT NOCOPY  VARCHAR2
  )

  IS

    l_api_version            CONSTANT NUMBER := 1.0;
    l_api_name               CONSTANT VARCHAR2(30) := 'DELETE_GROUP_ORG';

    l_object_version_number  JTF_RS_GROUP_ORGANIZATIONS.OBJECT_VERSION_NUMBER%TYPE;

    CURSOR c_group_org_id(ll_group_id  IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
 	                      ll_organization_id  IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE)
    IS
      SELECT object_version_number
      FROM   jtf_rs_group_organizations
      WHERE  group_id = ll_group_id
	  AND    organization_id = ll_organization_id
      ;

  BEGIN

    SAVEPOINT sp_delete_group_org;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Validate that the specified group id and organization_id is valid */

    OPEN c_group_org_id(p_group_id, p_organization_id);
    FETCH c_group_org_id INTO  l_object_version_number;
    CLOSE c_group_org_id;

    IF (l_object_version_number IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_RS_INVALID_GRP_ORG_ID');
      fnd_message.set_token('P_GRP_ID', p_group_id);
      fnd_message.set_token('P_ORG_ID', p_organization_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    --Check if object Version numbers match
    IF (l_object_version_number = p_object_version_number)
     THEN
       NULL;
     ELSE
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
    END IF;

    /* delete table data*/

    DELETE FROM jtf_rs_group_organizations
    WHERE GROUP_ID = P_GROUP_ID
	AND   ORGANIZATION_ID = P_ORGANIZATION_ID;

    IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO sp_delete_group_org;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_delete_group_org;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO sp_delete_group_org;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', g_pkg_name||'.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END delete_group_org;

END jtf_rs_group_orgs_pvt;

/
