--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WORKORDER_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WORKORDER_CUHK" AS
/*$Header: AHLCPRJB.pls 120.0.12010000.1 2009/01/12 23:33:43 sikumar noship $*/

G_PKG_NAME VARCHAR2(30) := 'AHL_PRD_WORKORDER_CUHK';

 PROCEDURE CREATE_JOB_PRE
(
	p_prd_workorder_rec			  	IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
	x_return_status             OUT NOCOPY VARCHAR2 ,
	x_msg_count                 OUT NOCOPY NUMBER  ,
	x_msg_data                  OUT NOCOPY VARCHAR2)
IS
    l_api_name          VARCHAR2(30) := 'create_job_pre';

 BEGIN
	 SAVEPOINT ahl_prd_workorder_cuhk;
   --dbms_output.put_line('Inside CREATE_JOB_PRE Hook -->'  );
   x_return_status:=FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
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

 End CREATE_JOB_PRE;


 PROCEDURE CREATE_JOB_POST
(
	 p_prd_workorder_rec		  			IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
	 p_operation_tbl								IN  AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
	 p_resource_tbl									IN  AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type,
	 p_material_tbl									IN  AHL_PP_MATERIALS_PVT.req_material_tbl_type,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2)

IS
    l_api_name          VARCHAR2(30) := 'create_job_post';

 Begin
	 SAVEPOINT ahl_prd_workorder_cuhk;
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('Inside CREATE_JOB_POST Hook -->'  );


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
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

 End CREATE_JOB_POST;


PROCEDURE  UPDATE_JOB_PRE
(
 p_prd_workorder_rec					  IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
 p_prd_workoper_tbl						  IN  AHL_PRD_WORKORDER_PVT.prd_workoper_tbl,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2)

IS
    l_api_name          VARCHAR2(30) := 'update_job_pre';

 Begin
 	 SAVEPOINT ahl_prd_workorder_cuhk;
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('Inside UPDATE_JOB_PRE Hook -->'  );

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
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

End UPDATE_JOB_PRE ;



PROCEDURE UPDATE_JOB_POST
(
 p_prd_workorder_rec				  	IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
 p_prd_workoper_tbl					  	IN  AHL_PRD_WORKORDER_PVT.prd_workoper_tbl,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2)
IS
    l_api_name          VARCHAR2(30) := 'update_job_post';

BEGIN
	 SAVEPOINT ahl_prd_workorder_cuhk;
	 x_return_status:=FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('Inside UPDATE_JOB_POST Hook -->'  );

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
		ROLLBACK TO ahl_prd_workorder_cuhk;
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

End UPDATE_JOB_POST;

End AHL_PRD_WORKORDER_CUHK;

/
