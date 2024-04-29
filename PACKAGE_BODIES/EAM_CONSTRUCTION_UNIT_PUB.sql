--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_UNIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_UNIT_PUB" as
/* $Header: EAMPCUB.pls 120.0.12010000.3 2008/11/20 10:19:34 dsingire noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'EAM_CONSTRUCTION_UNIT_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMPCUB.pls';


PROCEDURE create_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    CU_rec
     ,p_cu_activity_tbl         IN    CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2

      )  IS
  l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONSTRUCTION_UNIT';
  l_api_version       CONSTANT NUMBER       := 1.0;
BEGIN

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set Debug flag
    EAM_CONSTRUCTION_UNIT_PVT.set_debug;

    EAM_CONSTRUCTION_UNIT_PVT.create_construction_unit(
             p_api_version  =>  p_api_version
            ,p_commit => p_commit
            ,p_cu_rec		=>   p_cu_rec
            ,p_cu_activity_tbl		=>   p_cu_activity_tbl
            ,x_cu_id		=>   x_cu_id
            ,x_return_status		=>   x_return_status
            ,x_msg_count		=>   x_msg_count
            ,x_msg_data		=>   x_msg_data
            );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := fnd_api.g_ret_sts_error;
	x_msg_data := fnd_message.get;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERRORR');
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
      ) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONSTRUCTION_UNIT';
  l_api_version       CONSTANT NUMBER       := 1.0;
 BEGIN

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set Debug flag
    EAM_CONSTRUCTION_UNIT_PVT.set_debug;

    EAM_CONSTRUCTION_UNIT_PVT.update_construction_unit(
             p_api_version  =>  p_api_version
            ,p_commit => p_commit
            ,p_cu_rec		=>   p_cu_rec
            ,p_cu_activity_tbl		=>   p_cu_activity_tbl
            ,x_cu_id		=>   x_cu_id
            ,x_return_status		=>   x_return_status
            ,x_msg_count		=>   x_msg_count
            ,x_msg_data		=>   x_msg_data
            );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
	x_msg_data := fnd_message.get;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERRORR');
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
      ) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'COPY_CONSTRUCTION_UNIT';
  l_api_version       CONSTANT NUMBER       := 1.0;
 BEGIN

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set Debug flag
    EAM_CONSTRUCTION_UNIT_PVT.set_debug;

    EAM_CONSTRUCTION_UNIT_PVT.copy_construction_unit(
             p_api_version  =>  p_api_version
            ,p_commit => p_commit
            ,p_cu_rec		=>   p_cu_rec
            ,p_cu_activity_tbl		=>   p_cu_activity_tbl
            ,p_source_cu_id_tbl   =>   p_source_cu_id_tbl
            ,x_cu_id		=>   x_cu_id
            ,x_return_status		=>   x_return_status
            ,x_msg_count		=>   x_msg_count
            ,x_msg_data		=>   x_msg_data
            );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
	x_msg_data := fnd_message.get;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('EAM','EAM_CU_UNEXP_SQL_ERRORR');
    fnd_message.set_token('API_NAME',l_api_name);
    fnd_message.set_token('SQL_ERROR',SQLERRM);
    FND_MSG_PUB.Add;
    x_msg_data := fnd_message.get;
END copy_construction_unit;

End EAM_CONSTRUCTION_UNIT_PUB;

/
