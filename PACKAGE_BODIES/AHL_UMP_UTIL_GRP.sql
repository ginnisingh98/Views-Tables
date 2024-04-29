--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UTIL_GRP" AS
/* $Header: AHLGUMPB.pls 115.1 2003/09/24 04:57:50 sracha noship $*/

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_UTIL_GRP';

------------------------
-- Declare Procedures --
------------------------

-- Wrapper Procedure to call private API populate_appl_MRs.
-- Used by MR tab in the Service Request Form.

PROCEDURE Populate_Appl_MRs (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_csi_ii_id           IN            NUMBER,
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2 )
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'Populate_appl_MRs_grp';
    l_api_version    CONSTANT NUMBER       := 1.0;


BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Populate_appl_MRs_grp;

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

  AHL_UMP_UTIL_PKG.Populate_Appl_MRs (
    p_csi_ii_id       => p_csi_ii_id,
    x_return_status   => x_return_status,
    x_msg_count       =>x_msg_count,
    x_msg_data        => x_msg_data);


  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
   Rollback to Populate_Appl_Mrs_Grp;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Populate_Appl_Mrs_Grp;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Populate_Appl_Mrs_Grp;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Populate_Appl_Mrs',
                               p_error_text     => SQLERRM);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);





END Populate_Appl_MRs;


End AHL_UMP_UTIL_GRP;

/
