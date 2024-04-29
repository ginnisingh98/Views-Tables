--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UF_PUB" AS
--/* $Header: AHLPUMFB.pls 115.2 2002/12/04 23:20:29 sikumar noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_UF_PUB';

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : process_utilization_forecast
--  Type              : Public
--  Function          : For a given set of utilization forecast header and details, will validate and insert/update
--                      the utilization forecast information.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_utilization_forecast Parameters:
--
--       p_x_uf_header_rec         IN OUT  AHL_UMP_UF_PVT.uf_header_rec_type    Required
--         Utilization Forecast Header Details
--       p_x_uf_detail_tbl        IN OUT  AHL_UMP_UF_PVT.uf_detail_tbl_type   Required
--         Utilization Forecast details
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE process_utilization_forecast (
    p_api_version           IN              NUMBER    := 1.0,
    p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN              VARCHAR2  := NULL,
    p_x_uf_header_rec       IN OUT  NOCOPY  AHL_UMP_UF_PVT.uf_header_rec_type,
    p_x_uf_details_tbl      IN OUT  NOCOPY  AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2)  IS

  l_api_name       CONSTANT VARCHAR2(30) := 'process_utilization_forecast';
  l_api_version    CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT process_uf_Pub;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Call Private API.
  AHL_UMP_UF_PVT.process_utilization_forecast (
     	                      p_api_version           => 1.0,
                              p_x_uf_header_rec       => p_x_uf_header_rec,
                              p_x_uf_details_tbl      => p_x_uf_details_tbl,
                              x_return_status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data );



  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to process_uf_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to process_uf_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to process_uf_Pub;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'process_utilization_forecast',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


END process_utilization_forecast;

END AHL_UMP_UF_PUB;

/
