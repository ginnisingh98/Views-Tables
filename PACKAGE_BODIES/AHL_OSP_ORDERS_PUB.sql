--------------------------------------------------------
--  DDL for Package Body AHL_OSP_ORDERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_ORDERS_PUB" AS
--/* $Header: AHLPOSPB.pls 120.2.12010000.2 2009/09/23 05:54:20 tchimira ship $ */


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_OSP_ORDERS_PUB';

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : process_osp_order
--  Type              : Public
--  Function          : For a given set of osp order header and lines, will validate and insert/update/delete
--                      the osp order information.
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
--  process_osp_order Parameters:
--
--       p_x_osp_order_rec         IN OUT  AHL_OSP_ORDERS_PVT.osp_order_rec_type    Required
--         OSP Order Header record
--       p_x_osp_order_lines_tbl        IN OUT  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type   Required
--         OSP Order Lines
--       p_org_id                  IN NUMBER
--         Optional Org Id Parameter for R12 MOAC Compliance.
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE process_osp_order(
    p_api_version           IN               NUMBER    := 1.0,
    p_init_msg_list         IN               VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN               VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN               VARCHAR2  := NULL,
    p_x_osp_order_rec       IN OUT  NOCOPY   AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    p_x_osp_order_lines_tbl IN OUT  NOCOPY   AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type,
    p_org_id                IN               NUMBER    := NULL,
    x_return_status         OUT NOCOPY       VARCHAR2,
    x_msg_count             OUT NOCOPY       NUMBER,
    x_msg_data              OUT NOCOPY       VARCHAR2) IS

  l_api_name       CONSTANT VARCHAR2(30) := 'process_osp_order';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_curr_org_id    NUMBER;
  l_org_id NUMBER := p_org_id;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT process_osp_order_pub;

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

  /*
   * R12 MOAC Related Changes
   * Made by jaramana on 9/9/05
   * Corrected on 9/15/05
   */
  MO_GLOBAL.validate_orgid_pub_api(org_id => l_org_id,  -- IN OUT Parameter
                                   status => x_return_status);

  l_curr_org_id := MO_GLOBAL.get_current_org_id();

  IF (l_curr_org_id IS NULL AND l_org_id IS NOT NULL) THEN
    -- MO Initialization not done
    -- Use the Org Id returned by validate_orgid_pub_api and do the initialization.
    MO_GLOBAL.set_org_context(p_org_id_char     => TO_CHAR(p_org_id),
                              p_sp_id_char      => null,
                              p_appl_short_name => 'AHL');
    -- Cannot use set_policy_context since it only sets the
    -- current org_id, but does not populate the temp table
  END IF;
  /* End MOAC Related Changes */

  -- Call Private API.
  AHL_OSP_ORDERS_PVT.process_osp_order (
     	                      p_api_version           => 1.0,
                              p_x_osp_order_rec       => p_x_osp_order_rec,
                              p_x_osp_order_lines_tbl => p_x_osp_order_lines_tbl,
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
   -- TCHIMIRA :: Bug 8847465 :: 17-SEP-2009
   -- Changed the roll-back from process_uf_Pub to process_osp_order_pub
   Rollback to process_osp_order_pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- TCHIMIRA :: Bug 8847465 :: 17-SEP-2009
   -- Changed the roll-back from process_uf_Pub to process_osp_order_pub
   Rollback to process_osp_order_pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to process_osp_order_pub;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'process_osp_order',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


END process_osp_order;

END AHL_OSP_ORDERS_PUB;
----------------------------------------------

/
