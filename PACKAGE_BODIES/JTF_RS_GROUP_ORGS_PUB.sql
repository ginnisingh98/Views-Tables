--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_ORGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_ORGS_PUB" AS
  /* $Header: jtfrsuob.pls 120.0 2005/05/11 08:22:49 appldev noship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing Resource Group to HR Org mapping, like
   create, update and delete from other modules.
   Its main procedures are as following:
   Create Resource Group to HR Org mapping
   Update Resource Group to HR Org mapping
   Delete Resource Group to HR Org mapping
   Calls to these procedures will invoke procedures from jtf_rs_group_orgs_pvt
   to do business validations and to do actual inserts, updates and deletes into
   tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME        CONSTANT VARCHAR2(30) := 'JTF_RS_GROUP_ORGS_PUB';

  /* Procedure to create the Resource Group to HR Org mapping
	based on input values passed by calling routines. */

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
  )  IS

    l_api_version         CONSTANT NUMBER       := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_GROUP_ORG';

  BEGIN

    SAVEPOINT sp_create_group_org;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Call the private API to do validations and data processing */
    JTF_RS_GROUP_ORGS_PVT.create_group_org
         (P_API_VERSION           => P_API_VERSION,
          P_INIT_MSG_LIST         => P_INIT_MSG_LIST,
	      P_COMMIT                => P_COMMIT,
          P_GROUP_ID              => P_GROUP_ID,
          P_ORGANIZATION_ID       => P_ORGANIZATION_ID,
          P_ATTRIBUTE1 			  => P_ATTRIBUTE1,
          P_ATTRIBUTE2 			  => P_ATTRIBUTE2,
          P_ATTRIBUTE3 			  => P_ATTRIBUTE3,
          P_ATTRIBUTE4 			  => P_ATTRIBUTE4,
          P_ATTRIBUTE5 			  => P_ATTRIBUTE5,
          P_ATTRIBUTE6 			  => P_ATTRIBUTE6,
          P_ATTRIBUTE7 			  => P_ATTRIBUTE7,
          P_ATTRIBUTE8 			  => P_ATTRIBUTE8,
          P_ATTRIBUTE9 			  => P_ATTRIBUTE9,
          P_ATTRIBUTE10 		  => P_ATTRIBUTE10,
          P_ATTRIBUTE11 		  => P_ATTRIBUTE11,
          P_ATTRIBUTE12 		  => P_ATTRIBUTE12,
          P_ATTRIBUTE13 		  => P_ATTRIBUTE13,
          P_ATTRIBUTE14 		  => P_ATTRIBUTE14,
          P_ATTRIBUTE15 		  => P_ATTRIBUTE15,
          P_ATTRIBUTE_CATEGORY 	  => P_ATTRIBUTE_CATEGORY,
          X_RETURN_STATUS         => X_RETURN_STATUS,
          X_MSG_COUNT             => X_MSG_COUNT,
          X_MSG_DATA              => X_MSG_DATA
		  );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_create_group_org;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO sp_create_group_org;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',g_pkg_name||'.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END create_group_org;

  /* Procedure to update the Resource Group to HR Org mapping Attributes
	based on input values passed by calling routines. */

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
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_GROUP_ORG';

  BEGIN

    SAVEPOINT sp_update_group_org;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Call the private API to do validations and data processing */
    JTF_RS_GROUP_ORGS_PVT.update_group_org
         (P_API_VERSION           => P_API_VERSION,
          P_INIT_MSG_LIST         => P_INIT_MSG_LIST,
	      P_COMMIT                => P_COMMIT,
          P_GROUP_ID              => P_GROUP_ID,
          P_ORGANIZATION_ID       => P_ORGANIZATION_ID,
          P_ATTRIBUTE1 			  => P_ATTRIBUTE1,
          P_ATTRIBUTE2 			  => P_ATTRIBUTE2,
          P_ATTRIBUTE3 			  => P_ATTRIBUTE3,
          P_ATTRIBUTE4 			  => P_ATTRIBUTE4,
          P_ATTRIBUTE5 			  => P_ATTRIBUTE5,
          P_ATTRIBUTE6 			  => P_ATTRIBUTE6,
          P_ATTRIBUTE7 			  => P_ATTRIBUTE7,
          P_ATTRIBUTE8 			  => P_ATTRIBUTE8,
          P_ATTRIBUTE9 			  => P_ATTRIBUTE9,
          P_ATTRIBUTE10 		  => P_ATTRIBUTE10,
          P_ATTRIBUTE11 		  => P_ATTRIBUTE11,
          P_ATTRIBUTE12 		  => P_ATTRIBUTE12,
          P_ATTRIBUTE13 		  => P_ATTRIBUTE13,
          P_ATTRIBUTE14 		  => P_ATTRIBUTE14,
          P_ATTRIBUTE15 		  => P_ATTRIBUTE15,
          P_ATTRIBUTE_CATEGORY 	  => P_ATTRIBUTE_CATEGORY,
          P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER,
          X_RETURN_STATUS         => X_RETURN_STATUS,
          X_MSG_COUNT             => X_MSG_COUNT,
          X_MSG_DATA              => X_MSG_DATA
		  );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

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

  /* Procedure to delete resource group - HR Org mapping  */

  PROCEDURE  delete_group_org
  (P_API_VERSION            IN  NUMBER,
   P_INIT_MSG_LIST          IN  VARCHAR2,
   P_COMMIT                 IN  VARCHAR2,
   P_GROUP_ID               IN  JTF_RS_GROUP_ORGANIZATIONS.GROUP_ID%TYPE,
   P_ORGANIZATION_ID        IN  JTF_RS_GROUP_ORGANIZATIONS.ORGANIZATION_ID%TYPE,
   P_OBJECT_VERSION_NUMBER  IN  JTF_RS_GROUP_ORGANIZATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT              OUT NOCOPY  NUMBER,
   X_MSG_DATA               OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_GROUP_ORG';

  BEGIN

    SAVEPOINT sp_delete_group_org;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Call the private API to do validations and data processing */
    JTF_RS_GROUP_ORGS_PVT.delete_group_org
         (P_API_VERSION           => P_API_VERSION,
          P_INIT_MSG_LIST         => P_INIT_MSG_LIST,
	      P_COMMIT                => P_COMMIT,
          P_GROUP_ID              => P_GROUP_ID,
          P_ORGANIZATION_ID       => P_ORGANIZATION_ID,
          P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER,
          X_RETURN_STATUS         => X_RETURN_STATUS,
          X_MSG_COUNT             => X_MSG_COUNT,
          X_MSG_DATA              => X_MSG_DATA
		  );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
	 COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_delete_group_org;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO sp_delete_group_org;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',g_pkg_name||'.'||l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END delete_group_org;

END JTF_RS_GROUP_ORGS_PUB;

/
