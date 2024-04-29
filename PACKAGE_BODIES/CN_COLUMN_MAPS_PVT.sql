--------------------------------------------------------
--  DDL for Package Body CN_COLUMN_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLUMN_MAPS_PVT" as
/* $Header: cnvcmapb.pls 120.4 2005/09/13 09:32:07 apink noship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'CN_COLUMN_MAPS_PVT';
G_LAST_UPDATE_DATE          	DATE    := sysdate;
G_LAST_UPDATED_BY           	NUMBER  := fnd_global.user_id;
G_CREATION_DATE             	DATE    := sysdate;
G_CREATED_BY                	NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN        	NUMBER  := fnd_global.login_id;

-----------------------------------------------------------------------------+
-- Procedure   : insert_row
-----------------------------------------------------------------------------+
PROCEDURE insert_row
  (
   p_api_version            IN NUMBER,
   p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_destination_column_id  IN NUMBER,
   p_table_map_id           IN NUMBER,
   p_expression             IN VARCHAR2,
   p_editable               IN VARCHAR2,
   p_modified               IN VARCHAR2,
   p_update_clause          IN VARCHAR2,
   p_calc_ext_table_id      IN NUMBER,
   p_org_id                 IN NUMBER,
   x_col_map_id          IN OUT NOCOPY NUMBER) IS

     l_api_name              CONSTANT VARCHAR2(30) := 'insert_row';
     l_api_version           CONSTANT NUMBER  := 1.0;
     l_rowid                 ROWID;
     l_column_map_id         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT insert_row_sv;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API Body Begin


   cn_column_maps_pkg.Insert_Row
     (x_rowid                 => l_rowid,
      x_column_map_id         => l_column_map_id,
      x_destination_column_id => p_destination_column_id,
      x_table_map_id          => p_table_map_id,
      x_expression            => p_expression,
      x_editable              => p_editable,
      x_modified              => p_modified,
      x_update_clause         => p_update_clause,
      x_calc_ext_table_id     => p_calc_ext_table_id,
      x_creation_date         => G_CREATION_DATE,
      x_created_by            => G_CREATED_BY,
      X_org_id                => p_org_id);

      x_col_map_id := l_column_map_id;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_row_sv;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_row_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO insert_row_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
				p_encoded => FND_API.G_FALSE);
END insert_row;

-----------------------------------------------------------------------------+
-- Procedure   : update_row
-----------------------------------------------------------------------------+
PROCEDURE update_row
  (
   p_api_version   	    IN NUMBER,
   p_init_msg_list          IN VARCHAR2  := FND_API.G_FALSE,
   p_commit                 IN VARCHAR2  := FND_API.G_FALSE,
   p_validation_level       IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_column_map_id          IN NUMBER,
   p_destination_column_id  IN NUMBER,
   p_table_map_id           IN NUMBER,
   p_expression             IN VARCHAR2,
   p_editable               IN VARCHAR2,
   p_modified               IN VARCHAR2,
   p_update_clause          IN VARCHAR2,
   p_calc_ext_table_id      IN NUMBER,
   p_object_version_number  IN OUT NOCOPY NUMBER,
   p_org_id IN NUMBER) IS

      l_api_name               CONSTANT VARCHAR2(30) := 'update_row';
      l_api_version            CONSTANT NUMBER       := 1.0;
      l_object_version_number  cn_table_maps.object_version_number%TYPE;

      CURSOR l_ovn_csr IS
	 SELECT object_version_number
	   FROM cn_column_maps
	   WHERE column_map_id = p_column_map_id
       and org_id = p_org_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_row_sv;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API Body Begin

   -- check if the object version number is the same
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;

   if (l_object_version_number <> p_object_version_number) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CL_INVALID_OVN');
         fnd_msg_pub.add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;

   end if;



   cn_column_maps_pkg.Update_Row
     (x_column_map_id         => p_column_map_id,
      x_destination_column_id => p_destination_column_id,
      x_table_map_id          => p_table_map_id,
      x_expression            => p_expression,
      x_editable              => p_editable,
      x_modified              => p_modified,
      x_update_clause         => p_update_clause,
      x_calc_ext_table_id     => p_calc_ext_table_id,
      x_last_update_date      => G_LAST_UPDATE_DATE,
      x_last_updated_by       => G_LAST_UPDATED_BY,
      x_last_update_login     => g_last_update_login,
      x_object_version_number => p_object_version_number,
      x_org_id => p_org_id);

       p_object_version_number := l_object_version_number + 1;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_row_sv;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_row_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_row_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END update_row;

-----------------------------------------------------------------------------+
-- Procedure   : delete_row
-----------------------------------------------------------------------------+
PROCEDURE delete_row
  (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_column_map_id     IN NUMBER,
   p_org_id            IN NUMBER) IS

      l_api_name                  CONSTANT VARCHAR2(30) := 'delete_row';
      l_api_version               CONSTANT NUMBER  := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT delete_row_sv;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API Body Begin

   cn_column_maps_pkg.Delete_Row
     (x_column_map_id => p_column_map_id, x_org_id => p_org_id);

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_row_sv;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_row_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO delete_row_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END delete_row;


END cn_column_maps_pvt;

/
