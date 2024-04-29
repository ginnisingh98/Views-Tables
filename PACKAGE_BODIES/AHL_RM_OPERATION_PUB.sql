--------------------------------------------------------
--  DDL for Package Body AHL_RM_OPERATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_OPERATION_PUB" AS
/* $Header: AHLPOPEB.pls 120.4 2008/03/13 13:48:42 amsriniv ship $ */



PROCEDURE Create_Operation
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_x_oper_rec        		IN OUT NOCOPY 	AHL_RM_OPERATION_PVT.operation_rec_type,
	p_x_oper_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_oper_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_oper_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type,
	p_x_oper_panel_tbl		IN OUT NOCOPY	AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
)
IS
l_api_name       CONSTANT   VARCHAR2(30)   := 'CREATE_OPERATION';
l_api_version    CONSTANT   NUMBER         := 2.0;
l_debug_module   CONSTANT   VARCHAR2(60)  := 'ahl.plsql.'||g_pkg_name||'.'||l_api_name;
l_x_rt_oper_cost_rec AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_cost_rec_type;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_operation_pub;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.begin',
		'At the start of PLSQL procedure'
	);
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module ,
	     'Before calling the private API AHL_RM_OPERATION_PVT.process_operation.....'
         );

  END IF;

  -- PRITHWI: discuss with Shailaja whether to default to 'C' or to throw error if there is no Defaul
  IF p_x_oper_rec.DML_OPERATION = 'C'
  THEN

  	AHL_RM_OPERATION_PVT.process_operation
  	(
  	 p_api_version		=>	1.0,
  	 p_init_msg_list	=>	FND_API.G_FALSE,
  	 p_commit		=>	FND_API.G_FALSE,
  	 p_validation_level	=>	FND_API.G_VALID_LEVEL_FULL,
  	 p_default		=>	p_default,
  	 p_module_type		=>	p_module_type,
  	 x_return_status	=>	x_return_status,
  	 x_msg_count		=>	x_msg_count,
  	 x_msg_data		=>	x_msg_data,
  	 p_x_operation_rec	=>	p_x_oper_rec
	);

	  -- to raise errors from AHL_RM_OPERATION_PVT.process_operation
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
          -- if the OPERATION ID returned is null then throw error
          IF p_x_oper_rec.OPERATION_ID IS NULL THEN
          -- if not id has been created then throw unexpected error
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

   ElSE
          -- If the DML operation is not Cretae then its invalid
          FND_MESSAGE.SET_NAME('AHL','AHL_COM_INVALID_DML_FLAG');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
       			    l_debug_module ,
			    'Invalid DML Operation is specified....DML Operation should be create'
		    );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
            l_debug_module ,
	     'Operation Id of the Operation created  .....' || p_x_oper_rec.OPERATION_ID
         );

  END IF;



  -- populate the record attributes that are necessary for the API

  -- Attach documents
  IF p_x_oper_doc_tbl.count > 0 THEN

         FOR i in p_x_oper_doc_tbl.FIRST .. p_x_oper_doc_tbl.LAST
         LOOP
		 p_x_oper_doc_tbl(i).OBJECT_TYPE_CODE  := 'OPERATION';
		 p_x_oper_doc_tbl(i).OBJECT_ID := p_x_oper_rec.OPERATION_ID;
		 p_x_oper_doc_tbl(i).DML_OPERATION := 'C';

         END LOOP;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

	         fnd_log.string
	         (
		     fnd_log.level_statement,
	            l_debug_module,
		     'Before calling the private API AHL_RM_ASSO_DOCASO_PVT.PROCESS_ASSOCIATION.....'
	         );

	  END IF;

	  AHL_RM_ASSO_DOCASO_PVT.PROCESS_ASSOCIATION
	  (

	  	 p_api_version		=>	1.0,
	  	 p_init_msg_list	=>	FND_API.G_FALSE,
	  	 p_commit		=>	FND_API.G_FALSE,
	  	 p_validation_level	=>	FND_API.G_VALID_LEVEL_FULL,
	  	 p_default		=>	p_default,
	  	 p_module_type		=>	p_module_type,
	  	 x_return_status	=>	x_return_status,
	  	 x_msg_count		=>	x_msg_count,
	  	 x_msg_data		=>	x_msg_data,
	 	 p_x_association_tbl     =>     p_x_oper_doc_tbl
	  );

	  -- to raise errors from AHL_RM_ASSO_DOCASO_PVT.PROCESS_ASSOCIATION
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  END IF;

  -- Attach Resources
  IF p_x_oper_resource_tbl.count > 0 THEN

         FOR i in p_x_oper_resource_tbl.FIRST .. p_x_oper_resource_tbl.LAST
         LOOP

		 p_x_oper_resource_tbl(i).DML_OPERATION := 'C';

         END LOOP;

	 AHL_RM_RT_OPER_RESOURCE_PVT.process_rt_oper_resource
	 (
			 p_api_version		   =>	1.0,
			 p_init_msg_list	   =>	FND_API.G_FALSE,
			 p_commit		   =>	FND_API.G_FALSE,
			 p_validation_level	   =>	FND_API.G_VALID_LEVEL_FULL,
			 p_default		   =>	p_default,
			 p_module_type		   =>	p_module_type,
			 x_return_status	   =>	x_return_status,
			 x_msg_count		   =>	x_msg_count,
			 x_msg_data		   =>	x_msg_data,
			 p_x_rt_oper_resource_tbl  =>   p_x_oper_resource_tbl,
			 p_association_type_code   =>   'OPERATION',
			 p_object_id               =>   p_x_oper_rec.OPERATION_ID
	 );

	  -- to raise errors from AHL_RM_RT_OPER_RESOURCE_PVT.process_rt_oper_resource
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  -- populate the cost rec from the resource rec and call the cost api to add costing info
	  -- per resource rec
	  FOR i IN 1..p_x_oper_resource_tbl.count LOOP

		  l_x_rt_oper_cost_rec.RT_OPER_RESOURCE_ID := p_x_oper_resource_tbl(i).RT_OPER_RESOURCE_ID ;
		  l_x_rt_oper_cost_rec.OBJECT_VERSION_NUMBER := p_x_oper_resource_tbl(i).OBJECT_VERSION_NUMBER;
		  l_x_rt_oper_cost_rec.ACTIVITY_ID := p_x_oper_resource_tbl(i).ACTIVITY_ID;
		  l_x_rt_oper_cost_rec.ACTIVITY  := p_x_oper_resource_tbl(i).ACTIVITY;
		  l_x_rt_oper_cost_rec.COST_BASIS_ID := p_x_oper_resource_tbl(i).COST_BASIS_ID;
		  l_x_rt_oper_cost_rec.COST_BASIS := p_x_oper_resource_tbl(i).COST_BASIS;
		  l_x_rt_oper_cost_rec.SCHEDULED_TYPE_ID := p_x_oper_resource_tbl(i).SCHEDULED_TYPE_ID;
		  l_x_rt_oper_cost_rec.SCHEDULED_TYPE := p_x_oper_resource_tbl(i).SCHEDULED_TYPE;
		  l_x_rt_oper_cost_rec.AUTOCHARGE_TYPE_ID := p_x_oper_resource_tbl(i).AUTOCHARGE_TYPE_ID;
		  l_x_rt_oper_cost_rec.AUTOCHARGE_TYPE := p_x_oper_resource_tbl(i).AUTOCHARGE_TYPE;
		  l_x_rt_oper_cost_rec.STANDARD_RATE_FLAG := p_x_oper_resource_tbl(i).STANDARD_RATE_FLAG;
		  l_x_rt_oper_cost_rec.STANDARD_RATE  := p_x_oper_resource_tbl(i).STANDARD_RATE;

		  AHL_RM_RT_OPER_RESOURCE_PVT.define_cost_parameter
		  (
		    p_api_version        => 1.0,
		    p_init_msg_list      => FND_API.G_FALSE,
		    p_commit             => FND_API.G_FALSE,
		    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		    p_default            => FND_API.G_FALSE,
		    p_module_type        => NULL,
		    x_return_status      => x_return_status,
		    x_msg_count          => x_msg_count,
		    x_msg_data           => x_msg_data,
		    p_x_rt_oper_cost_rec => l_x_rt_oper_cost_rec
		  );

		  x_msg_count := FND_MSG_PUB.count_msg;

		  IF x_msg_count > 0 THEN
		     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		     RAISE FND_API.G_EXC_ERROR;
	          END IF;

	  END LOOP;
  END IF;


  --Attach Material Requirements
  IF p_x_oper_material_tbl.count > 0 THEN

         FOR i in p_x_oper_material_tbl.FIRST .. p_x_oper_material_tbl.LAST
         LOOP

		 p_x_oper_material_tbl(i).DML_OPERATION := 'C';

         END LOOP;

	 AHL_RM_MATERIAL_AS_PVT.process_material_req
	 (
			 p_api_version		   =>	1.0,
			 p_init_msg_list	   =>	FND_API.G_FALSE,
			 p_commit		   =>	FND_API.G_FALSE,
			 p_validation_level	   =>	FND_API.G_VALID_LEVEL_FULL,
			 p_default		   =>	p_default,
			 p_module_type		   =>	p_module_type,
			 x_return_status	   =>	x_return_status,
			 x_msg_count		   =>	x_msg_count,
			 x_msg_data		   =>	x_msg_data,
			 p_x_material_req_tbl      =>   p_x_oper_material_tbl,
			 p_object_id		   =>   p_x_oper_rec.OPERATION_ID,
			 p_association_type        =>   'OPERATION'
	 );
 	  -- to raise errors from AHL_RM_MATERIAL_AS_PVT.process_material_req
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  END IF;

  --Adithya added for Access Panels ER# 6143687.
  --Attach Access Panels
  IF p_x_oper_panel_tbl.count > 0 THEN

         FOR i in p_x_oper_panel_tbl.FIRST .. p_x_oper_panel_tbl.LAST
         LOOP
         p_x_oper_panel_tbl(i).DML_OPERATION := 'C';
         END LOOP;

	 AHL_RM_RT_OPER_PANEL_PVT.process_rt_oper_panel
	 (
			 p_api_version		   =>	1.0,
			 p_init_msg_list	   =>	FND_API.G_FALSE,
			 p_commit		   =>	FND_API.G_FALSE,
			 p_validation_level	   =>	FND_API.G_VALID_LEVEL_FULL,
			 p_default		   =>	p_default,
			 p_module_type		   =>	p_module_type,
			 x_return_status	   =>	x_return_status,
			 x_msg_count		   =>	x_msg_count,
			 x_msg_data		   =>	x_msg_data,
			 p_x_rt_oper_panel_tbl     =>   p_x_oper_panel_tbl,
			 p_association_type_code   =>   'OPERATION',
			 p_object_id		   =>   p_x_oper_rec.OPERATION_ID
	 );
 	  -- to raise errors from AHL_RM_RT_OPER_PANEL_PVT.process_rt_oper_panel
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.End',
		'At the end of PLSQL procedure...'
	);
  END IF;

  -- Check Error Message stack.
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised expected error....'
       );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised unexpected error....'
       );
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     Rollback to create_operation_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to create_operation_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to create_operation_pub;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'CREATE_OPERATION',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                  p_encoded => fnd_api.g_false);

END Create_Operation;

-- Overloaded procedure retained for backaward compatibility (pre 12.0.4).
-- This procedure will call the above procedure with api_version = 2.
PROCEDURE Create_Operation
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_x_oper_rec        		IN OUT NOCOPY 	AHL_RM_OPERATION_PVT.operation_rec_type,
	p_x_oper_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_oper_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_oper_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
)
IS

l_api_name       CONSTANT   VARCHAR2(30)   := 'CREATE_OPERATION';
l_api_version    CONSTANT   NUMBER         := 1.0;

l_x_oper_panel_tbl AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type;

BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME
     )
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   AHL_RM_OPERATION_PUB.Create_Operation
       (
	-- standard IN params
	p_api_version	        => 2.0,
	p_init_msg_list		=> p_init_msg_list,
	p_commit		=> p_commit,
	p_validation_level	=> p_validation_level,
	p_default		=> p_default,
	p_module_type		=> p_module_type,
	-- standard OUT params
	x_return_status         => x_return_status,
	x_msg_count             => x_msg_count,
	x_msg_data              => x_msg_data,
	-- procedure params
	p_x_oper_rec        	=> p_x_oper_rec,
	p_x_oper_doc_tbl  	=> p_x_oper_doc_tbl,
	p_x_oper_resource_tbl	=> p_x_oper_resource_tbl,
	p_x_oper_material_tbl 	=> p_x_oper_material_tbl,
	p_x_oper_panel_tbl	=> l_x_oper_panel_tbl);

  --
  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'CREATE_OPERATION',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Create_Operation;



PROCEDURE Modify_Operation
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_oper_rec        	        IN	        AHL_RM_OPERATION_PVT.operation_rec_type,
	p_x_oper_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_oper_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_oper_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type,
	p_x_oper_panel_tbl		IN OUT NOCOPY	AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
)
IS
l_api_name       CONSTANT   VARCHAR2(30)   := 'MODIFY_OPERATION';
l_api_version    CONSTANT   NUMBER         := 2.0;
l_debug_module  CONSTANT   VARCHAR2(60)  := 'ahl.plsql.'||g_pkg_name||'.'||l_api_name;
l_oper_id                   NUMBER;
l_oper_rec       AHL_RM_OPERATION_PVT.operation_rec_type;
l_x_rt_oper_cost_rec AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_cost_rec_type;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT modify_operation_pub;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.begin',
		'At the start of PLSQL procedure'
	);
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Before calling the private API AHL_RM_OPERATION_PVT.process_operation.....'
         );

  END IF;

  l_oper_id := p_oper_rec.operation_id;

  -- If Id is null derive Operation id from Operation Number and revision
  IF l_oper_id IS NULL THEN

  	-- Function to convert Operation number, operation revision to id

  	 AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
  	  (
  	   p_operation_number		=>	p_oper_rec.concatenated_segments,
  	   p_operation_revision		=>	p_oper_rec.revision_number,
  	   x_operation_id		=>	l_oper_id,
  	   x_return_status		=>	x_return_status
  	  );

  	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
  	     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
  		 fnd_log.string
  		 (
  		     fnd_log.level_error,
  		     l_debug_module,
  		     'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
  		 );
  	     END IF;
  	     RAISE FND_API.G_EXC_ERROR;
  	  END IF;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Operation Id of the Operation that is being updated  .....' || l_oper_id
         );

  END IF;



  -- if DML is 'U' then the operation has to be updated
  -- no check on OBJ VER NO as PVT already does it.
  IF p_oper_rec.DML_OPERATION = 'U'
  THEN

        l_oper_rec := p_oper_rec;

  	AHL_RM_OPERATION_PVT.process_operation
  	(
  	 p_api_version		=>	1.0,
  	 p_init_msg_list	=>	FND_API.G_FALSE,
  	 p_commit		=>	FND_API.G_FALSE,
  	 p_validation_level	=>	FND_API.G_VALID_LEVEL_FULL,
  	 p_default		=>	p_default,
  	 p_module_type		=>	p_module_type,
  	 x_return_status	=>	x_return_status,
  	 x_msg_count		=>	x_msg_count,
  	 x_msg_data		=>	x_msg_data,
  	 p_x_operation_rec	=>	l_oper_rec
	);
	  -- to raise errors from AHL_RM_OPERATION_PVT.process_operation
	  x_msg_count := FND_MSG_PUB.count_msg;


	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

   ElSIF p_oper_rec.DML_OPERATION IS NOT NULL	THEN
          -- If the DML operation is not 'U' and is also not NULL, then throw an error
          FND_MESSAGE.SET_NAME('AHL','AHL_COM_INVALID_DML_FLAG');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
       			    l_debug_module,
			    'Invalid DML Operation is specified....DML Operation should be Update'
		    );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
  END IF;




  -- populate the record attributes that are necessary for the API


  -- Attach documents
  IF p_x_oper_doc_tbl.count > 0 THEN

         FOR i in p_x_oper_doc_tbl.FIRST .. p_x_oper_doc_tbl.LAST
         LOOP

		 p_x_oper_doc_tbl(i).OBJECT_TYPE_CODE  := 'OPERATION';
		 p_x_oper_doc_tbl(i).OBJECT_ID := l_oper_id;
		 --p_x_oper_doc_tbl(i).DML_OPERATION := 'C'; amsriniv. Bug 6032272

         END LOOP;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

	         fnd_log.string
	         (
		     fnd_log.level_statement,
	             l_debug_module,
		     'Before calling the private API AHL_RM_ASSO_DOCASO_PVT.PROCESS_ASSOCIATION.....'
	         );

	  END IF;

	  AHL_RM_ASSO_DOCASO_PVT.PROCESS_ASSOCIATION
	  (

	  	 p_api_version		=>	1.0,
	  	 p_init_msg_list	=>	FND_API.G_FALSE,
	  	 p_commit		=>	FND_API.G_FALSE,
	  	 p_validation_level	=>	FND_API.G_VALID_LEVEL_FULL,
	  	 p_default		=>	p_default,
	  	 p_module_type		=>	p_module_type,
	  	 x_return_status	=>	x_return_status,
	  	 x_msg_count		=>	x_msg_count,
	  	 x_msg_data		=>	x_msg_data,
	 	 p_x_association_tbl     =>     p_x_oper_doc_tbl
	  );

	  -- to raise errors from AHL_RM_ASSO_DOCASO_PVT.PROCESS_ASSOCIATION
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  END IF;

  -- Attach Resources
  IF p_x_oper_resource_tbl.count > 0 THEN

	 AHL_RM_RT_OPER_RESOURCE_PVT.process_rt_oper_resource
	 (
			 p_api_version		   =>	1.0,
			 p_init_msg_list	   =>	FND_API.G_FALSE,
			 p_commit		   =>	FND_API.G_FALSE,
			 p_validation_level	   =>	FND_API.G_VALID_LEVEL_FULL,
			 p_default		   =>	p_default,
			 p_module_type		   =>	p_module_type,
			 x_return_status	   =>	x_return_status,
			 x_msg_count		   =>	x_msg_count,
			 x_msg_data		   =>	x_msg_data,
			 p_x_rt_oper_resource_tbl  =>   p_x_oper_resource_tbl,
			 p_association_type_code   =>   'OPERATION',
			 p_object_id               =>   l_oper_id
	 );

	  -- to raise errors from AHL_RM_RT_OPER_RESOURCE_PVT.process_rt_oper_resource
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  -- populate the cost rec from the resource rec and call the cost api to add costing info
	  -- per resource rec
	  FOR i IN 1..p_x_oper_resource_tbl.count LOOP
		  --pdoki added condition to check if the DML operation is Delete for Bug# 6435925
      IF ( p_x_oper_resource_tbl(i).dml_operation <> 'D' ) THEN

				l_x_rt_oper_cost_rec.RT_OPER_RESOURCE_ID := p_x_oper_resource_tbl(i).RT_OPER_RESOURCE_ID ;
				l_x_rt_oper_cost_rec.OBJECT_VERSION_NUMBER := p_x_oper_resource_tbl(i).OBJECT_VERSION_NUMBER;
				l_x_rt_oper_cost_rec.ACTIVITY_ID := p_x_oper_resource_tbl(i).ACTIVITY_ID;
				l_x_rt_oper_cost_rec.ACTIVITY  := p_x_oper_resource_tbl(i).ACTIVITY;
				l_x_rt_oper_cost_rec.COST_BASIS_ID := p_x_oper_resource_tbl(i).COST_BASIS_ID;
				l_x_rt_oper_cost_rec.COST_BASIS := p_x_oper_resource_tbl(i).COST_BASIS;
				l_x_rt_oper_cost_rec.SCHEDULED_TYPE_ID := p_x_oper_resource_tbl(i).SCHEDULED_TYPE_ID;
				l_x_rt_oper_cost_rec.SCHEDULED_TYPE := p_x_oper_resource_tbl(i).SCHEDULED_TYPE;
				l_x_rt_oper_cost_rec.AUTOCHARGE_TYPE_ID := p_x_oper_resource_tbl(i).AUTOCHARGE_TYPE_ID;
				l_x_rt_oper_cost_rec.AUTOCHARGE_TYPE := p_x_oper_resource_tbl(i).AUTOCHARGE_TYPE;
				l_x_rt_oper_cost_rec.STANDARD_RATE_FLAG := p_x_oper_resource_tbl(i).STANDARD_RATE_FLAG;
				l_x_rt_oper_cost_rec.STANDARD_RATE  := p_x_oper_resource_tbl(i).STANDARD_RATE;

				AHL_RM_RT_OPER_RESOURCE_PVT.define_cost_parameter
				(
					p_api_version        => 1.0,
					p_init_msg_list      => FND_API.G_FALSE,
					p_commit             => FND_API.G_FALSE,
					p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
					p_default            => FND_API.G_FALSE,
					p_module_type        => NULL,
					x_return_status      => x_return_status,
					x_msg_count          => x_msg_count,
					x_msg_data           => x_msg_data,
					p_x_rt_oper_cost_rec => l_x_rt_oper_cost_rec
				);

				IF x_msg_count > 0 THEN
					 X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					 RAISE FND_API.G_EXC_ERROR;
							END IF;
	     END IF;

	  END LOOP;

/*

YPE rt_oper_resource_rec_type IS RECORD
(
        RT_OPER_RESOURCE_ID              NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),
        ASO_RESOURCE_ID                  NUMBER,
        ASO_RESOURCE_NAME                VARCHAR2(30),
        RESOURCE_TYPE_ID                 NUMBER,
        RESOURCE_TYPE                    VARCHAR2(80),
        QUANTITY                         NUMBER,
        DURATION                         NUMBER,
        ACTIVITY_ID                      NUMBER,
        ACTIVITY                         VARCHAR2(10),
        COST_BASIS_ID                    NUMBER,
        COST_BASIS                       VARCHAR2(80),
        SCHEDULED_TYPE_ID                NUMBER,
        SCHEDULED_TYPE                   VARCHAR2(80),
        AUTOCHARGE_TYPE_ID               NUMBER,
        AUTOCHARGE_TYPE                  VARCHAR2(80),
        STANDARD_RATE_FLAG               NUMBER,
        STANDARD_RATE                    VARCHAR2(80),
        ATTRIBUTE_CATEGORY               VARCHAR2(30),
        ATTRIBUTE1                       VARCHAR2(150),
        ATTRIBUTE2                       VARCHAR2(150),
        ATTRIBUTE3                       VARCHAR2(150),
        ATTRIBUTE4                       VARCHAR2(150),
        ATTRIBUTE5                       VARCHAR2(150),
        ATTRIBUTE6                       VARCHAR2(150),
        ATTRIBUTE7                       VARCHAR2(150),
        ATTRIBUTE8                       VARCHAR2(150),
        ATTRIBUTE9                       VARCHAR2(150),
        ATTRIBUTE10                      VARCHAR2(150),
        ATTRIBUTE11                      VARCHAR2(150),
        ATTRIBUTE12                      VARCHAR2(150),
        ATTRIBUTE13                      VARCHAR2(150),
        ATTRIBUTE14                      VARCHAR2(150),
        ATTRIBUTE15                      VARCHAR2(150),
        DML_OPERATION                    VARCHAR2(1)
);
PROCEDURE define_cost_parameter
(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN            VARCHAR2   := NULL,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_rt_oper_cost_rec IN OUT NOCOPY rt_oper_cost_rec_type
);
TYPE rt_oper_cost_rec_type IS RECORD
(
        RT_OPER_RESOURCE_ID              NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        ACTIVITY_ID                      NUMBER,
        ACTIVITY                         VARCHAR2(10),
        COST_BASIS_ID                    NUMBER,
        COST_BASIS                       VARCHAR2(80),
        SCHEDULED_TYPE_ID                NUMBER,
        SCHEDULED_TYPE                   VARCHAR2(80),
        AUTOCHARGE_TYPE_ID               NUMBER,
        AUTOCHARGE_TYPE                  VARCHAR2(80),
        STANDARD_RATE_FLAG               NUMBER,
        STANDARD_RATE                    VARCHAR2(80)
);*/


  END IF;


  --Attach Material Requirements
  IF p_x_oper_material_tbl.count > 0 THEN


	 AHL_RM_MATERIAL_AS_PVT.process_material_req
	 (
			 p_api_version		   =>	1.0,
			 p_init_msg_list	   =>	FND_API.G_FALSE,
			 p_commit		   =>	FND_API.G_FALSE,
			 p_validation_level	   =>	FND_API.G_VALID_LEVEL_FULL,
			 p_default		   =>	p_default,
			 p_module_type		   =>	p_module_type,
			 x_return_status	   =>	x_return_status,
			 x_msg_count		   =>	x_msg_count,
			 x_msg_data		   =>	x_msg_data,
			 p_x_material_req_tbl      =>   p_x_oper_material_tbl,
			 p_object_id		   =>   l_oper_id,
			 p_association_type        =>   'OPERATION'
	 );

 	  -- to raise errors from AHL_RM_MATERIAL_AS_PVT.process_material_req
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  END IF;

  --Adithya added for Access Panels ER# 6143687.
  --Attach Access Panels
  IF p_x_oper_panel_tbl.count > 0 THEN


	 AHL_RM_RT_OPER_PANEL_PVT.process_rt_oper_panel
	 (
			 p_api_version		   =>	1.0,
			 p_init_msg_list	   =>	FND_API.G_FALSE,
			 p_commit		   =>	FND_API.G_FALSE,
			 p_validation_level	   =>	FND_API.G_VALID_LEVEL_FULL,
			 p_default		   =>	p_default,
			 p_module_type		   =>	p_module_type,
			 x_return_status	   =>	x_return_status,
			 x_msg_count		   =>	x_msg_count,
			 x_msg_data		   =>	x_msg_data,
			 p_x_rt_oper_panel_tbl     =>   p_x_oper_panel_tbl,
			 p_association_type_code   =>   'OPERATION',
			 p_object_id		   =>   l_oper_id
	 );

 	  -- to raise errors from AHL_RM_RT_OPER_PANEL_PVT.process_rt_oper_panel
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.End',
		'At the end of PLSQL procedure...'
	);
  END IF;

  -- Check Error Message stack.
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised expected error....'
       );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised unexpected error....'
       );
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     Rollback to modify_operation_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to modify_operation_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to modify_operation_pub;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'MODIFY_OPERATION',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                  p_encoded => fnd_api.g_false);

END Modify_Operation;


-- Overloaded procedure retained for backaward compatibility.
-- This procedure will call the above procedure with api_version = 2.
PROCEDURE Modify_Operation
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_oper_rec        	        IN 	        AHL_RM_OPERATION_PVT.operation_rec_type,
	p_x_oper_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_oper_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_oper_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
)
IS

  l_api_name       CONSTANT   VARCHAR2(30)   := 'CREATE_OPERATION';
  l_api_version    CONSTANT   NUMBER         := 1.0;

  l_x_oper_panel_tbl AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  AHL_RM_OPERATION_PUB.Modify_Operation
       (
	-- standard IN params
	p_api_version	        => 2.0,
	p_init_msg_list		=> p_init_msg_list,
	p_commit		=> p_commit,
	p_validation_level	=> p_validation_level,
	p_default		=> p_default,
	p_module_type		=> p_module_type,
	-- standard OUT params
	x_return_status         => x_return_status,
	x_msg_count             => x_msg_count,
	x_msg_data              => x_msg_data,
	-- procedure params
	p_oper_rec        	=> p_oper_rec,
	p_x_oper_doc_tbl  	=> p_x_oper_doc_tbl,
	p_x_oper_resource_tbl	=> p_x_oper_resource_tbl,
	p_x_oper_material_tbl 	=> p_x_oper_material_tbl,
	p_x_oper_panel_tbl	=> l_x_oper_panel_tbl
       );

  --
  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'MODIFY_OPERATION',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Modify_Operation;


PROCEDURE Delete_Operation
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_oper_id			IN		NUMBER,
	p_oper_number			IN		VARCHAR2,
	p_oper_revision			IN		NUMBER,
	p_oper_object_version 		IN		NUMBER
)
IS
l_api_name       CONSTANT   VARCHAR2(30)   := 'DELETE_OPERATION';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_debug_module  CONSTANT   VARCHAR2(60)  := 'ahl.plsql.'||g_pkg_name||'.'||l_api_name;
l_oper_id        NUMBER;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT delete_operation_pub;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.begin',
		'At the start of PLSQL procedure'
	);
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Before calling the private API AHL_RM_OPERATION_PVT.delete_operation.....'
         );

  END IF;

  l_oper_id := p_oper_id;
  -- If Id is null derive Operation id from Operation Number and revision
  IF l_oper_id IS NULL THEN

  	-- Function to convert Operation number, operation revision to id
  	-- PRITHWI : CODE ERROR
  	 AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
  	  (
  	   p_operation_number		=>	p_oper_number,
  	   p_operation_revision		=>	p_oper_revision,
  	   x_operation_id		=>	l_oper_id,
  	   x_return_status		=>	x_return_status
  	  );

  	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
  	     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
  		 fnd_log.string
  		 (
  		     fnd_log.level_error,
  		     l_debug_module,
  		     'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
  		 );
  	     END IF;
  	     RAISE FND_API.G_EXC_ERROR;
  	  END IF;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Operation Id of the Operation that is being deleted  .....' || l_oper_id
         );

  END IF;


	AHL_RM_OPERATION_PVT.delete_operation
	 (
	  p_api_version			=>	1.0,
	  p_init_msg_list		=>	FND_API.G_FALSE,
	  p_commit			=>	FND_API.G_FALSE,
	  p_validation_level		=>	FND_API.G_VALID_LEVEL_FULL,
	  p_default			=>	p_default,
	  p_module_type			=>	p_module_type,
	  x_return_status		=>	x_return_status,
	  x_msg_count			=>	x_msg_count,
	  x_msg_data			=>	x_msg_data,
	  p_operation_id		=>	l_oper_id ,
	  p_object_version_number	=>	p_oper_object_version
	 );
	  -- to raise errors from AHL_RM_OPERATION_PVT.process_operation
	  x_msg_count := FND_MSG_PUB.count_msg;

	  IF x_msg_count > 0 THEN
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.End',
		'At the end of PLSQL procedure...'
	);
  END IF;

  -- Check Error Message stack.
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised expected error....'
       );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised unexpected error....'
       );
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     Rollback to delete_operation_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to delete_operation_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to delete_operation_pub;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'DELETE_OPERATION',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                  p_encoded => fnd_api.g_false);

END Delete_Operation;


PROCEDURE Process_Oper_Alt_Resources
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_operation_number	        IN	VARCHAR2,
	p_operation_revision		IN	NUMBER,
        p_operation_id			IN	NUMBER,
        p_resource_id			IN	NUMBER,
        p_resource_name 		IN	VARCHAR2,
	p_x_alt_resource_tbl 		IN OUT NOCOPY	AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type
)
IS

-- cursor to fetch the resource Id if the resource name is known
CURSOR get_res_id( c_resource_name IN VARCHAR2)
IS
SELECT RESOURCE_ID
from AHL_RESOURCES
where name = c_resource_name;


-- cursor to get the resource association id given the operation and the resource details
CURSOR get_rt_oper_resource (c_operation_id IN NUMBER, c_resource_id IN NUMBER )
IS
SELECT rt_oper_resource_id
from AHL_RT_OPER_RESOURCES
where
object_ID = c_operation_id
and aso_resource_id = c_resource_id;



l_api_name       CONSTANT   VARCHAR2(30)   := 'PROCESS_OPER_ALT_RESOURCES';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_debug_module   CONSTANT   VARCHAR2(60)  := 'ahl.plsql.'||g_pkg_name||'.'||l_api_name;
l_rt_oper_resource_id       NUMBER;
l_resource_id               NUMBER;
l_operation_id              NUMBER;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT Process_Alt_Resources;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.begin',
		'At the start of PLSQL procedure'
	);
  END IF;

  l_operation_id := p_operation_id;
  -- If Id is null derive Operation id from Operation Number and revision
  IF l_operation_id IS NULL THEN

  	-- Function to convert Operation number, operation revision to id
  	 AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
  	  (
  	   p_operation_number		=>	p_operation_number,
  	   p_operation_revision		=>	p_operation_revision,
  	   x_operation_id		=>	l_operation_id,
  	   x_return_status		=>	x_return_status
  	  );
  	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
  	     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
  		 fnd_log.string
  		 (
  		     fnd_log.level_error,
  		     l_debug_module,
  		     'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
  		 );
  	     END IF;
  	     RAISE FND_API.G_EXC_ERROR;
  	  END IF;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Operation Id of the Operation that is being updated  .....' || l_operation_id
         );
  END IF;

  -- if Id is null derive Resource Id from Resource name
  -- if resource Id cannot be found then throw error
  l_resource_id := p_resource_id;
  IF l_resource_id IS NULL THEN

	OPEN get_res_id(p_resource_name );
	FETCH get_res_id INTO l_resource_id;

	IF get_res_id%NOTFOUND THEN
	-- PRITHWI : please run this message and check what it displays.
      		FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_ASO_RES_ID' );
      		FND_MESSAGE.set_token( 'RECORD', p_resource_name );
      		FND_MSG_PUB.add;
          	RAISE FND_API.G_EXC_ERROR;
    	END IF;

	CLOSE get_res_id;

  END IF;

  -- check whether the association ID between Operation and resource exists.
  OPEN get_rt_oper_resource (l_operation_id , l_resource_id);
  FETCH get_rt_oper_resource INTO l_rt_oper_resource_id;
  IF get_rt_oper_resource%NOTFOUND THEN
	-- PRITHWI : please run this message and check what it displays.
      	FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_OBJECT' );
      	FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_rt_oper_resource;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Before calling Private API AHL_RM_RT_OPER_RESOURCE_PVT.process_alternate_resource'
         );
  END IF;

  AHL_RM_RT_OPER_RESOURCE_PVT.process_alternate_resource
  (
    p_api_version        => 1.0 ,
    p_init_msg_list      => p_init_msg_list,
    p_commit             => p_commit,
    p_validation_level   => p_validation_level,
    p_default            => p_default,
    p_module_type        => p_module_type,
    x_return_status      => x_return_status,
    x_msg_count          => x_msg_count,
    x_msg_data           => x_msg_data,
    p_rt_oper_resource_id => l_rt_oper_resource_id,
    p_x_alt_resource_tbl  => p_x_alt_resource_tbl
  );

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'After calling Private API AHL_RM_RT_OPER_RESOURCE_PVT.process_alternate_resource'
         );
  END IF;


  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.End',
		'At the end of PLSQL procedure...'
	);
  END IF;

  -- Check Error Message stack.
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Public API raised expected error....'
       );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Public API raised unexpected error....'
       );
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     Rollback to Process_Alt_Resources;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Process_Alt_Resources;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Process_Alt_Resources;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'Process_Oper_Alt_Resources',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Process_Oper_Alt_Resources;



PROCEDURE Create_Oper_Revision
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_oper_id 			IN          	NUMBER,
	p_oper_number			IN		VARCHAR2,
	p_oper_revision			IN		NUMBER,
	p_oper_object_version		IN		NUMBER,
	x_new_oper_id         		OUT NOCOPY  	NUMBER
)
IS

l_api_name       CONSTANT   VARCHAR2(30)   := 'CREATE_OPER_REVISION';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_debug_module   CONSTANT   VARCHAR2(60)  := 'ahl.plsql.'||g_pkg_name||'.'||l_api_name;
l_operation_id		    NUMBER;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_oper_revision_pub;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.begin',
		'At the start of PLSQL procedure'
	);
  END IF;

  -- If Id is null derive Operation id from Operation Number and revision
  l_operation_id := p_oper_id;
  IF ( p_oper_id IS NULL  OR
       p_oper_id = FND_API.G_MISS_NUM )
  THEN
	  -- Function to convert Operation number, operation revision to id
	  AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
	  (
	   p_operation_number		=>	p_oper_number,
	   p_operation_revision		=>	p_oper_revision,
	   x_operation_id		=>	l_operation_id,
	   x_return_status		=>	x_return_status
	  );
	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_error,
		     l_debug_module,
		     'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
		 );
	     END IF;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Before calling the private API.....'
         );
  END IF;

  -- Call the private API


  AHL_RM_OPERATION_PVT.create_oper_revision
  (
   p_api_version		=>	1.0,
   p_init_msg_list		=>	FND_API.G_FALSE,
   p_commit			=>	FND_API.G_FALSE,
   p_validation_level		=>	FND_API.G_VALID_LEVEL_FULL,
   p_default			=>	p_default,
   p_module_type		=>	p_module_type,
   x_return_status		=>	x_return_status,
   x_msg_count			=>	x_msg_count,
   x_msg_data			=>	x_msg_data,
   p_operation_id		        =>	l_operation_id,
   p_object_version_number	=>	p_oper_object_version,
   x_operation_id		=>	x_new_oper_id
  );


  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module ||'.End',
		'At the end of PLSQL procedure...'
	);
  END IF;

  -- Check Error Message stack.
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module ,
  	    'Private API raised expected error....'
       );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module ,
  	    'Private API raised unexpected error....'
       );
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     Rollback to create_oper_revision_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to create_oper_revision_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to create_oper_revision_pub;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'create_oper_revision',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                  p_encoded => fnd_api.g_false);

 END Create_Oper_Revision;


PROCEDURE Initiate_Oper_Approval
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_oper_id 			IN          	NUMBER,
	p_oper_number			IN		VARCHAR2,
	p_oper_revision			IN		NUMBER,
	p_oper_object_version		IN          	NUMBER,
	p_apprv_type		     	IN          	VARCHAR2	:='COMPLETE'
)
 IS
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_api_name	CONSTANT VARCHAR2(30) := 'INITIATE_OPER_APPROVAL';
 l_debug_module   CONSTANT   VARCHAR2(60)  := 'ahl.plsql.'||g_pkg_name||'.'||l_api_name;
 l_source_operation_id	 NUMBER;

 BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT initiate_oper_approval_pub;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		l_debug_module || '.begin',
		'At the start of PLSQL procedure'
	);
  END IF;

  -- If Id is null derive Operation id from Operation Number and revision
  l_source_operation_id := p_oper_id;
  IF ( p_oper_id IS NULL OR
       p_oper_id = FND_API.G_MISS_NUM )
  THEN
	  -- Function to convert Operation number, operation revision to id
	  AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
	  (
	   p_operation_number		=>	p_oper_number,
	   p_operation_revision		=>	p_oper_revision,
	   x_operation_id		=>	l_source_operation_id,
	   x_return_status		=>	x_return_status
	  );
	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_statement,
		     l_debug_module ,
		     'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
		 );
	     END IF;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
	     fnd_log.level_statement,
             l_debug_module,
	     'Before calling the private API.....'
         );
  END IF;


  -- Call the private API
  AHL_RM_APPROVAL_PVT.INITIATE_OPER_APPROVAL
   (
   p_api_version		=>	1.0,
   p_init_msg_list		=>	FND_API.G_FALSE,
   p_commit			=>	FND_API.G_FALSE,
   p_validation_level		=>	FND_API.G_VALID_LEVEL_FULL,
   p_default			=>	p_default,
   p_module_type		=>	p_module_type,
   x_return_status		=>	x_return_status,
   x_msg_count			=>	x_msg_count,
   x_msg_data			=>	x_msg_data,
   p_source_operation_id	=>	l_source_operation_id,
   p_object_Version_number	=>	p_oper_object_version,
   p_apprvl_type		=>	p_apprv_type
   );

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_procedure,
		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
		'At the end of PLSQL procedure...'
	);
  END IF;

  -- Check Error Message stack.
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised expected error....'
       );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
  	    fnd_log.level_error,
  	    l_debug_module,
  	    'Private API raised unexpected error....'
       );
      END IF;
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
     Rollback to initiate_oper_approval_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to initiate_oper_approval_pub;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to initiate_oper_approval_pub;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'INITIATE_OPER_APPROVAL',
                                 p_error_text     => SQLERRM);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                  p_encoded => fnd_api.g_false);

 END Initiate_Oper_Approval;

END AHL_RM_OPERATION_PUB;


/
