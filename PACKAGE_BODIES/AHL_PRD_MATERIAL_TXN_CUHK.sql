--------------------------------------------------------
--  DDL for Package Body AHL_PRD_MATERIAL_TXN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_MATERIAL_TXN_CUHK" AS
/*$Header: AHLCMTXB.pls 120.2 2007/10/26 22:33:55 sracha noship $*/

G_PKG_NAME VARCHAR2(30) := 'AHL_PRD_MATERIAL_TXN_CUHK';

 -- Add pre transaction specific validations in this api.
 PROCEDURE PERFORM_MTLTXN_PRE (
        p_x_material_txn_tbl IN OUT NOCOPY   AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type,
        x_return_status      OUT NOCOPY      VARCHAR2,
        x_msg_count          OUT NOCOPY      NUMBER,
        x_msg_data           OUT NOCOPY      VARCHAR2
        )
 IS
    l_api_name          VARCHAR2(30) := 'PERFORM_MTLTXN_PRE';

 BEGIN
   SAVEPOINT PERFORM_MTLTXN_PRE_CUHK;

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
   -- customer to add the customization codes here
   -- for pre processing
   --
   --
 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PERFORM_MTLTXN_PRE_CUHK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PERFORM_MTLTXN_PRE_CUHK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO PERFORM_MTLTXN_PRE_CUHK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

 End PERFORM_MTLTXN_PRE;


 -- Add post transaction specific validations in this api.
 PROCEDURE PERFORM_MTLTXN_POST(
        p_material_txn_tbl   IN OUT NOCOPY   AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type,
        x_return_status      OUT NOCOPY      VARCHAR2,
        x_msg_count          OUT NOCOPY      NUMBER,
        x_msg_data           OUT NOCOPY      VARCHAR2
        )
IS
    l_api_name          VARCHAR2(30) := 'PERFORM_MTLTXN_POST';

 Begin
   SAVEPOINT PERFORM_MTLTXN_POST_CUHK;

   x_return_status:=FND_API.G_RET_STS_SUCCESS;
   -- customer to add the customization codes here
   -- for post processing
   --
   --

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PERFORM_MTLTXN_POST_CUHK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PERFORM_MTLTXN_POST_CUHK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO PERFORM_MTLTXN_POST_CUHK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

 End PERFORM_MTLTXN_POST;

End AHL_PRD_MATERIAL_TXN_CUHK;

/
