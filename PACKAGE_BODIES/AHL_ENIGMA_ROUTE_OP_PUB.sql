--------------------------------------------------------
--  DDL for Package Body AHL_ENIGMA_ROUTE_OP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_ENIGMA_ROUTE_OP_PUB" AS
/* $Header: AHLPEROB.pls 120.0.12010000.5 2009/04/09 02:25:36 bachandr noship $ */
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;
G_PKG_NAME					VARCHAR2(30) := 'AHL_ENIGMA_ROUTE_OP_PUB';

-----------------------------------
-- Process Routes Details --
------------------------------------
PROCEDURE Process_Route_Details
(
	p_api_version	      IN	    NUMBER     := '1.0',
	p_init_msg_list      IN	    VARCHAR2   := FND_API.G_TRUE,
	p_commit					IN	    VARCHAR2   := FND_API.G_FALSE,
	p_validation_level   IN	    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
	p_default				IN	    VARCHAR2   := FND_API.G_FALSE,
	p_module_type	      IN	    VARCHAR2   := NULL,
	x_return_status      OUT NOCOPY    VARCHAR2,
	x_msg_count				OUT NOCOPY    NUMBER,
	x_msg_data				OUT NOCOPY    VARCHAR2,
	p_enigma_route_rec	IN enigma_route_rec_type,
	p_enigma_op_tbl      IN enigma_op_tbl_type,
	p_context				IN VARCHAR2,
	p_pub_date				IN DATE
);

-----------------------------------
-- Process Operations Details--
------------------------------------
PROCEDURE Process_OP_Details
(
	p_api_version	      IN	    NUMBER     := '1.0',
	p_init_msg_list      IN	    VARCHAR2   := FND_API.G_TRUE,
	p_commit					IN	    VARCHAR2   := FND_API.G_FALSE,
	p_validation_level   IN	    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
	p_default				IN	    VARCHAR2   := FND_API.G_FALSE,
	p_module_type	      IN	    VARCHAR2   := NULL,
	x_return_status      OUT NOCOPY    VARCHAR2,
	x_msg_count				OUT NOCOPY    NUMBER,
	x_msg_data				OUT NOCOPY    VARCHAR2,
	p_enigma_op_tbl      IN enigma_op_tbl_type,
	p_context				IN VARCHAR2,
	p_pub_date				IN DATE,
	p_parent_route_id	IN	VARCHAR2
);

PROCEDURE upload_revision_report(
  p_file_name     IN         VARCHAR2,
  x_file_id       OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
);


------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : Process_Route_Operations
--  Type                : Public
--  Function            : Processes the Routes and operations from Enigma.
--  Pre-reqs            :
--  End of Comments.
------------------------------------------------------------------------------------------------------------------
PROCEDURE Process_Route_Operations
(
	  p_api_version          IN               NUMBER        := 1.0,
	  p_init_msg_list        IN               VARCHAR2      := FND_API.G_FALSE,
	  p_commit               IN               VARCHAR2      := FND_API.G_FALSE,
	  p_validation_level     IN               NUMBER        := FND_API.G_VALID_LEVEL_FULL,
	  p_module_type          IN               VARCHAR2,
	  p_context              IN               VARCHAR2,
	  p_pub_date             IN               DATE,
	  p_enigma_route_rec     IN               enigma_route_rec_type,
	  p_enigma_op_tbl        IN               enigma_op_tbl_type,
	  x_return_status        OUT    NOCOPY    VARCHAR2,
	  x_msg_count            OUT    NOCOPY    NUMBER,
	  x_msg_data             OUT    NOCOPY    VARCHAR2
)
IS


/*-- This cursor checks the existence of the Enigma Route in the staging table with status as pending.
CURSOR check_route_exists (p_route_id IN VARCHAR2)
IS
	SELECT 'X'
	FROM AHL_RT_OPER_INTERFACE
	WHERE ROUTE_ID = p_route_id
	AND STATUS = 'PENDING';*/

-- This cursor is used to fetch the details of the routes that exists in the staging table with status PENDING
CURSOR get_route_data
IS
	SELECT
		ROUTE_ID,
		STATUS,
		ATA_CODE,
		DESCRIPTION,
		REVISION_DATE,
		ENIGMA_ID,
		CHANGE_FLAG,
		PDF
	FROM
		AHL_RT_OPER_INTERFACE
	WHERE
		STATUS = 'PENDING'
	AND	PARENT_ROUTE_ID IS NULL;

-- This cursor is used to fetch the details of the operartion that exists in the staging table
-- which is assocaited to a the route and with status PENDING
CURSOR get_oper_data (p_route_id IN VARCHAR2)
IS
	SELECT
		OPERATION_ID,
		STATUS,
		ATA_CODE,
		DESCRIPTION,
		PARENT_ROUTE_ID,
		ENIGMA_ID,
		CHANGE_FLAG
	FROM
		AHL_RT_OPER_INTERFACE
	WHERE PARENT_ROUTE_ID = p_route_id
	AND STATUS = 'PENDING';

   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'Process_Route_Operations';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'AHL_ENIGMA_ROUTE_OP_PUB'||'.'||l_api_name;

   l_dummy		VARCHAR2(1);
   l_route_exists	VARCHAR2(1) := FND_API.G_FALSE;
   l_route_id		VARCHAR2(2000);


   l_route_data_rec         get_route_data%ROWTYPE;
   l_oper_data_tbl	    enigma_op_tbl_type;


BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Process_Route_Operations_SP;

	-- Initialize return status to success before any code logic/validation
	x_return_status:= FND_API.G_RET_STS_SUCCESS;

	-- Standard call to check for call compatibility
	IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list = FND_API.G_TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
	FND_MSG_PUB.INITIALIZE;
	END IF;

	-- initialise it only if it is a OA Adapter !
	-- Apps initialise does a commit which causes commit/rollback related issues discussed.
	-- Hence commenting out this piece of code.
	--fnd_global.APPS_INITIALIZE (1003259,62211, 867);

	-- Log API entry point
	IF (l_log_procedure >= l_log_current_level) THEN
	fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
	END IF;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
	    fnd_log.string
	    (
	      fnd_log.level_procedure,
	      l_debug_module ||'.begin',
	      'Inside Process_Route_Operations'
	    );
	END IF;

	-- Check  if the route is found in the staging table
	-- Then , query and get all the routes from the staging table which are in status pending.
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Polling for pending routes'
	    );
	END IF;

	OPEN get_route_data;
	LOOP
		FETCH get_route_data INTO l_route_data_rec;
		EXIT WHEN get_route_data%NOTFOUND;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'Pending Routes foung in staging table'
		    );
		END IF;

		l_route_id := l_route_data_rec.route_id;

		-- Check if the route has any associated operations.
		-- If so collect them into l_oper_data_tbl .
		OPEN get_oper_data (l_route_id);
		FETCH get_oper_data INTO l_oper_data_tbl(0);

		IF (l_log_statement >= l_log_current_level) THEN
			fnd_log.string(fnd_log.level_statement,l_debug_module,'Calling PROCESS_ROUTE_DETAILS');
		END IF;

		-- Delete all the routes in pending status from the stagin table
		-- as they have already been queried by the cursor
		DELETE FROM AHL_RT_OPER_INTERFACE
		WHERE STATUS = 'PENDING' AND PARENT_ROUTE_ID IS NULL;

		-- Delete all the operations from the stagin table that are in the pending status
		-- and that correspond to the parent route

		DELETE FROM AHL_RT_OPER_INTERFACE
		WHERE PARENT_ROUTE_ID = l_route_id AND STATUS = 'PENDING';

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'before calling process_route_details'
		    );
		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'l_route_data_rec.route_id -> '|| l_route_data_rec.route_id
		    );
		END IF;

		-- Calling the procedure to process the route and operation details
		PROCESS_ROUTE_DETAILS
		(
			'1.0',
			FND_API.G_TRUE,
			FND_API.G_FALSE,
			FND_API.G_VALID_LEVEL_FULL,
			FND_API.G_FALSE,
			NULL,
			x_return_status,
			x_msg_count,
			x_msg_data,
			l_route_data_rec,
			l_oper_data_tbl,
			p_context,
			p_pub_date
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'after calling process_route_details'
		    );
		END IF;
		CLOSE get_oper_data;
	END LOOP;
	CLOSE get_route_data;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Dumping all the paramters...'
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_api_version -> '||p_api_version
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_init_msg_list -> '||p_init_msg_list
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_commit -> '||p_commit
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_validation_level -> '||p_validation_level
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_module_type -> '||p_module_type
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_context -> '||p_context
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'p_pub_date -> '||p_pub_date
	    );
	END IF;

	-- Process the incoming enigma record.
   	-- Validate if the Enigma Route Id is  null throw an error if the id is null.
	IF (p_enigma_route_rec.route_ID IS NULL OR p_enigma_route_rec.ROUTE_ID = FND_API.G_MISS_CHAR)
	THEN
		FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_ROUTE_ID_NULL');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Calling the procedure to process the route and operation details passing the input record
	-- p_enigma_route_rec, irrespective of whether the route is in the staging table or not.
	-- Call the procedure with the passed inout records only if the same record is not found in
	-- staging table and the operation is not delete ?!?!
	PROCESS_ROUTE_DETAILS
	(
		'1.0',
		FND_API.G_TRUE,
		FND_API.G_FALSE,
		FND_API.G_VALID_LEVEL_FULL,
		FND_API.G_FALSE,
		NULL,
		x_return_status,
		x_msg_count,
		x_msg_data,
		p_enigma_route_rec,
		p_enigma_op_tbl,
		p_context,
		p_pub_date
	);


	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
	RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard check for p_commit
	IF FND_API.To_Boolean (p_commit)
	THEN
	COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
		    p_data  => x_msg_data,
		    p_encoded => fnd_api.g_false );

	EXCEPTION
	    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		Rollback to Process_Route_Operations_SP;
		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
			       p_data  => x_msg_data,
			       p_encoded => fnd_api.g_false);

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Route_Operations_SP;
		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
			       p_data  => x_msg_data,
			       p_encoded => fnd_api.g_false);

	    WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Route_Operations_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
		    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
				p_procedure_name => 'Process_Route_Operations',
				p_error_text     => SUBSTR(SQLERRM,1,240));
		END IF;
		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
			       p_data  => x_msg_data,
			       p_encoded => fnd_api.g_false);

END Process_Route_Operations;


PROCEDURE Process_Route_Details
(
	p_api_version	      IN	    NUMBER     := '1.0',
	p_init_msg_list       IN	    VARCHAR2   := FND_API.G_TRUE,
	p_commit	      IN	    VARCHAR2   := FND_API.G_FALSE,
	p_validation_level    IN	    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
	p_default	      IN	    VARCHAR2   := FND_API.G_FALSE,
	p_module_type	      IN	    VARCHAR2   := NULL,
	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count	      OUT NOCOPY    NUMBER,
	x_msg_data	      OUT NOCOPY    VARCHAR2,
	p_enigma_route_rec    IN		enigma_route_rec_type,
	p_enigma_op_tbl       IN		enigma_op_tbl_type,
	p_context	      IN		VARCHAR2,
	p_pub_date	      IN		DATE
)
IS

CURSOR get_latest_route_rev (p_route_id VARCHAR2)
IS
	SELECT
		route_id,
		object_version_number,
		revision_status_code revision_status
	FROM	AHL_ROUTES_B
	WHERE	UPPER(TRIM(ENIGMA_ROUTE_ID)) = UPPER(TRIM(p_route_id))
	AND REVISION_NUMBER =
	(	SELECT
			MAX( revision_number )
		FROM
			AHL_ROUTES_B
		WHERE
			UPPER(TRIM(ENIGMA_ROUTE_ID)) = UPPER(TRIM(p_route_id)) );

   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'PROCESS_ROUTE_DETAILS';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'AHL.PLSQL.'||'AHL_ENIGMA_ROUTE_OP_PUB'||'.'||'PROCESS_ROUTE_DETAILS';

	x_route_id NUMBER;
	l_ovn NUMBER;
	x_file_id NUMBER;

	l_get_latest_route_rev	   get_latest_route_rev%ROWTYPE;
	p_process_route_input_rec  AHL_RM_ROUTE_PVT.route_rec_type;

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Process_Route_Details_SP;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
   END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN

	    fnd_log.string
	    (
	      fnd_log.level_procedure,
	      l_debug_module ||'.begin',
	      'Inside process_route_details'
	    );
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Calling from BPEL service Parameters p_enigma_route_rec.route_id -> '||p_enigma_route_rec.route_id
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Calling from BPEL service Parameters p_enigma_route_rec.change_flag -> '||p_enigma_route_rec.change_flag
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Calling from BPEL service Parameters p_enigma_route_rec.ATA_CODE-> '||p_enigma_route_rec.ATA_CODE
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Calling from BPEL service Parameters p_enigma_route_rec.DESCRIPTION-> '||p_enigma_route_rec.DESCRIPTION
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Calling from BPEL service Parameters p_enigma_route_rec.REVISION_DATE-> '||p_enigma_route_rec.REVISION_DATE
	    );
	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Calling from BPEL service Parameters p_enigma_route_rec.PDF-> '||p_enigma_route_rec.PDF
	    );
	END IF;
	-- Start of validations
	-- validate if all the mandatory parameters are passed for the route rec

	-- Verify if the Change flag is right...
	IF (p_enigma_route_rec.change_flag NOT IN ( 'C', 'D', 'U'))
	THEN
		 FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_DML');
		 FND_MESSAGE.SET_TOKEN('FIELD', p_enigma_route_rec.change_flag);
		 FND_MESSAGE.SET_TOKEN('RECORD', p_enigma_route_rec.route_id);
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- When all clear, process the route rec by checking the change_flag (DML Operation).
	-- Check if the flag id delete and if so delete the route from the CMRO system .
	IF (p_enigma_route_rec.change_flag = 'D') THEN

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'Inside Delete'
		    );
		END IF;

		-- Query for the latest revision of the route existing in CMRO end
		OPEN get_latest_route_rev (p_enigma_route_rec.route_id);
		FETCH get_latest_route_rev
				INTO  l_get_latest_route_rev.route_id,
						l_get_latest_route_rev.object_version_number,
						l_get_latest_route_rev.revision_status;

		IF get_latest_route_rev%FOUND THEN

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Latest Revision of route found'
			    );
			END IF;

			-- IF the route is in Approval Pending status , then insert the Enigma Record into the
			-- staging table with status as pending.
			IF ( upper(l_get_latest_route_rev.revision_status) = 'APPROVAL_PENDING' ) THEN

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Route is in Approval Pending'
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Before Inserting into the staging table'
				    );
				END IF;

				INSERT INTO AHL_RT_OPER_INTERFACE
				(
					CONTEXT,
					PUBLISH_DATE,
					ROUTE_ID,
					PDF,
					REVISION_DATE,
					CHANGE_FLAG,
					ATA_CODE,
					DESCRIPTION,
					STATUS,
					REASON,
					ENIGMA_ID
				)
				VALUES
				(
					p_context,
					p_pub_date,
					p_enigma_route_rec.route_id,
					p_enigma_route_rec.pdf,
					p_enigma_route_rec.revision_date,
					p_enigma_route_rec.change_flag,
					p_enigma_route_rec.ata_code,
					p_enigma_route_rec.description,
					'PENDING',
					'Route is in approval pending status',
					p_enigma_route_rec.enigma_id
				);

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'After Inserting into the staging table'
				    );
				END IF;

			ELSE
				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Before calling delete_routes'
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_route_rev.route_id -> ' || l_get_latest_route_rev.route_id
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_route_rev.object_version_number -> ' || l_get_latest_route_rev.object_version_number
				    );
				END IF;

				-- Call delete_route procedure to delete the route from CMRO End.
				AHL_RM_ROUTE_PVT.delete_route
					(
					 '1.0',
					 FND_API.G_TRUE,
					 FND_API.G_FALSE,
					 FND_API.G_VALID_LEVEL_FULL,
					 FND_API.G_FALSE,
					 'ENIGMA',
					 x_return_status,
					 x_msg_count,
					 x_msg_data,
					 l_get_latest_route_rev.route_id,
					 l_get_latest_route_rev.object_version_number
					);

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'After calling delete_routes'
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'x_return_status -> ' || x_return_status
				    );
				END IF;

				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_ROUTE_PVT.create_route_revision');
				END IF;

				-- Check the return status , and if the status is not success , then raise an error
				IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.delete_route Error');
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.delete_route -> Deleted');
				END IF;

			END IF;
		ELSE
			-- Raise an error if the route is not found in CMRO..
			FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_ROUTE_DONOT_EXIST');
			FND_MSG_PUB.ADD;
			CLOSE get_latest_route_rev;
			RAISE FND_API.G_EXC_ERROR;
		END IF; -- Cursor
		CLOSE get_latest_route_rev;
	END IF; -- change Flag

	IF (p_enigma_route_rec.change_flag = 'U') THEN

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'Inside update'
		    );
                END IF;

		-- Query for the latest revision of the route existing in CMRO end
			OPEN get_latest_route_rev (p_enigma_route_rec.route_id);
			FETCH get_latest_route_rev
				INTO  l_get_latest_route_rev.route_id,
				      l_get_latest_route_rev.object_version_number,
				      l_get_latest_route_rev.revision_status;

			IF get_latest_route_rev%FOUND THEN
				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'latest revision of route Found'
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_route_rev.route_id -> ' || l_get_latest_route_rev.route_id
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_route_rev.revision_status_code-> ' || l_get_latest_route_rev.revision_status
				    );
				END IF;

				-- IF the route is in Approval Pending status , then inser the Enigma Record into the
				-- staging table with status as pending.
				IF ( upper(l_get_latest_route_rev.revision_status) = 'APPROVAL_PENDING' ) THEN

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Route is in Approval pending'
					    );
					END IF;

					INSERT INTO AHL_RT_OPER_INTERFACE
					(
						CONTEXT,
						PUBLISH_DATE,
						ROUTE_ID,
						PDF,
						REVISION_DATE,
						CHANGE_FLAG,
						ATA_CODE,
						DESCRIPTION,
						STATUS,
						REASON,
						ENIGMA_ID
					)
					VALUES
					(
						p_context,
						p_pub_date,
						p_enigma_route_rec.route_id,
						p_enigma_route_rec.pdf,
						p_enigma_route_rec.revision_date,
						p_enigma_route_rec.change_flag,
						p_enigma_route_rec.ata_code,
						p_enigma_route_rec.description,
						'PENDING',
						'Route is in approval pending status',
						p_enigma_route_rec.enigma_id
					);

					-- If the route has any assocaited operations, add them also to the stating table
					-- marking the status as pending.
					IF ( p_enigma_op_tbl.COUNT > 0) THEN

						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN
						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'There are operations attached'
						    );
						END IF;

						FOR i IN p_enigma_op_tbl.FIRST..p_enigma_op_tbl.LAST
						LOOP
							IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
							THEN
							    fnd_log.string
							    (
							      fnd_log.level_statement,
							      l_debug_module,
							      'Inserting the operations into the staging table'
							    );
							END IF;

							INSERT INTO AHL_RT_OPER_INTERFACE
							(
								CONTEXT,
								PUBLISH_DATE,
								OPERATION_ID,
								PARENT_ROUTE_ID,
								CHANGE_FLAG,
								ATA_CODE,
								DESCRIPTION,
								STATUS,
								REASON,
								ENIGMA_ID
							)
							VALUES
							(
								p_context,
								p_pub_date,
								p_enigma_op_tbl(i).operation_id,
								p_enigma_op_tbl(i).parent_route_id,
								p_enigma_op_tbl(i).change_flag,
								p_enigma_op_tbl(i).ata_code,
								p_enigma_op_tbl(i).description,
								'PENDING',
								'Parent Route is in approval pending status',
								p_enigma_op_tbl(i).enigma_id
							);
						END LOOP;
					END IF;

				ELSIF (upper(l_get_latest_route_rev.revision_status) = 'COMPLETE') THEN

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Route is in complete'
					    );
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Before calling create_route_revision'
					    );
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'l_get_latest_route_rev.route_id -> ' || l_get_latest_route_rev.route_id
					    );
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'l_get_latest_route_rev.object_version_number -> ' || l_get_latest_route_rev.object_version_number
					    );
					END IF;

                                        -- Call the API to create a new revision of the route
					AHL_RM_ROUTE_PVT.create_route_revision
					(
						 '1.0',
						 FND_API.G_TRUE,
						 FND_API.G_FALSE,
						 FND_API.G_VALID_LEVEL_FULL,
						 FND_API.G_FALSE,
						 NULL,
						 x_return_status,
						 x_msg_count,
						 x_msg_data,
						 l_get_latest_route_rev.route_id,
						 l_get_latest_route_rev.object_version_number,
						 x_route_id
					);

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'After calling create_route_revision'
					    );
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'x_route_id -> ' ||  x_route_id
					    );
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_ROUTE_PVT.create_route_revision');
					END IF;

					IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.create_route_revision Error');
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.create_route_revision -> revision Created');
						fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.create_route_revision -> x_route_id = ' || x_route_id);
					END IF;

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Populate the input record for updation'
					    );
					END IF;

					-- If the return status is success, populate the input rec for process_route for updation
					IF ( x_route_id  <> FND_API.G_MISS_NUM AND x_route_id  IS NOT NULL) THEN
						p_process_route_input_rec.ROUTE_ID := x_route_id ;
					END IF;

                                        IF p_enigma_route_rec.pdf IS NOT NULL
                                        THEN
						-- Call the procedure to upload the file
						UPLOAD_REVISION_REPORT
						(
						  p_enigma_route_rec.pdf,
						  x_file_id,
						  x_return_status
						);
                                        END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'After UPLOAD_REVISION_REPORT Call ');
					END IF;

					IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'UPLOAD_REVISION_REPORT Error');
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'UPLOAD_REVISION_REPORT-> File upload done');
						fnd_log.string(fnd_log.level_statement,l_debug_module,'File Id -> = ' || x_file_id);
					END IF;

					-- If the return status is success, populate the input rec for process_route for updation
					IF ( x_file_id  <> FND_API.G_MISS_NUM AND x_file_id  IS NOT NULL) THEN

						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'File id ->' || x_file_id
						    );
						END IF;

						p_process_route_input_rec.FILE_ID := x_file_id ;
						-- Update the route revision with file_id
						/*
						UPDATE
						  AHL_ROUTES_B
						SET
						  FILE_ID = x_file_id,
						  OBJECT_VERSION_NUMBER = l_get_latest_route_rev.object_version_number + 1
						WHERE
						   ROUTE_ID = l_get_latest_route_rev.route_id
						   AND OBJECT_VERSION_NUMBER = l_get_latest_route_rev.object_version_number;
                                               */
					END IF;

					SELECT object_version_number INTO l_ovn from
					AHL_ROUTES_B where route_id = x_route_id;

					IF (l_ovn <> FND_API.G_MISS_NUM AND l_ovn IS NOT NULL ) THEN
						p_process_route_input_rec.object_version_number  := l_ovn;
					END IF;

					IF (p_context <> FND_API.G_MISS_CHAR AND p_context IS NOT NULL ) THEN
						p_process_route_input_rec.model_code  := p_context;
					END IF;

					IF (p_pub_date <> FND_API.G_MISS_DATE AND p_pub_date  IS NOT NULL ) THEN
						p_process_route_input_rec.enigma_publish_date  := p_pub_date ;
					END IF;
                                        /*
                                         Route No is not updatable
					IF (p_enigma_route_rec.ata_code <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.ata_code IS NOT NULL ) THEN
						p_process_route_input_rec.route_no  := p_enigma_route_rec.ata_code;
					END IF;
					*/

					IF (p_enigma_route_rec.description <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.description IS NOT NULL ) THEN
						p_process_route_input_rec.TITLE  := p_enigma_route_rec.description;
					END IF;

					IF (p_enigma_route_rec.revision_date <> FND_API.G_MISS_DATE AND p_enigma_route_rec.revision_date IS NOT NULL ) THEN
						p_process_route_input_rec.ACTIVE_START_DATE  := p_enigma_route_rec.revision_date;
					END IF;

					IF (p_enigma_route_rec.enigma_id <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.enigma_id IS NOT NULL ) THEN
						p_process_route_input_rec.enigma_doc_id  := p_enigma_route_rec.enigma_id;
					END IF;

					IF (p_enigma_route_rec.route_id <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.route_id IS NOT NULL ) THEN
						p_process_route_input_rec.enigma_route_id  := p_enigma_route_rec.route_id;
					END IF;

					p_process_route_input_rec.dml_operation := 'U';

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Before calling process_route in update mode'
					    );
					END IF;

					-- Call the API for update
					AHL_RM_ROUTE_PVT.process_route
						(
						 '1.0',
						 FND_API.G_TRUE,
						 FND_API.G_FALSE,
						 FND_API.G_VALID_LEVEL_FULL,
						 FND_API.G_FALSE,
						 NULL,
						 x_return_status,
						 x_msg_count,
						 x_msg_data,
						 p_process_route_input_rec
						);

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'After calling process_route in update mode'
					    );
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'x_return_status -> ' || x_return_status
					    );
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_ROUTE_PVT.process_route');
					END IF;

					IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.process_route Error');
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.process_route -> updation Successful');
					END IF;

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'before insertion into staging table'
					    );
					END IF;

					-- Insert the transaction record into the staging table, with status as success
					INSERT INTO AHL_RT_OPER_INTERFACE
					(
						CONTEXT,
						PUBLISH_DATE,
						ROUTE_ID,
						PDF,
						REVISION_DATE,
						CHANGE_FLAG,
						ATA_CODE,
						DESCRIPTION,
						STATUS,
						REASON,
						ENIGMA_ID
					)
					VALUES
					(
						p_context,
						p_pub_date,
						p_enigma_route_rec.route_id,
						p_enigma_route_rec.pdf,
						p_enigma_route_rec.revision_date,
						p_enigma_route_rec.change_flag,
						p_enigma_route_rec.ata_code,
						p_enigma_route_rec.description,
						'SUCCESS',
						'Route updated Successfully',
						p_enigma_route_rec.enigma_id
					);

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'After insertion into staging table'
					    );
					END IF;

					-- Check if the route has any operations, if then call the process operation procedure
					IF ( p_enigma_op_tbl.COUNT > 0) THEN
						FOR i IN p_enigma_op_tbl.FIRST..p_enigma_op_tbl.LAST
						LOOP

							IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
							THEN

							    fnd_log.string
							    (
							      fnd_log.level_statement,
							      l_debug_module,
							      'Process the operations , Calling Process_OP_Details '
							    );
							END IF;

							Process_OP_Details
							(
								'1.0',
								 FND_API.G_TRUE,
								 FND_API.G_FALSE,
								 FND_API.G_VALID_LEVEL_FULL,
								 FND_API.G_FALSE,
								 NULL,
								 x_return_status,
								 x_msg_count,
								 x_msg_data,
								 p_enigma_op_tbl,
								 p_context,
								 p_pub_date,
								 p_enigma_route_rec.route_id
							);

							IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
							THEN

							    fnd_log.string
							    (
							      fnd_log.level_statement,
							      l_debug_module,
							      'After Calling Process_OP_Details '
							    );
							END IF;

							IF (l_log_statement >= l_log_current_level) THEN
								fnd_log.string(fnd_log.level_statement,l_debug_module,'After Process_OP_Details');
							END IF;

							IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
								IF (l_log_statement >= l_log_current_level) THEN
									fnd_log.string(fnd_log.level_statement,l_debug_module,'Process_OP_Details Error');
								END IF;
								RAISE FND_API.G_EXC_ERROR;
							END IF;
						END LOOP;
					END IF; -- oper table count

				ELSIF ( l_get_latest_route_rev.revision_status = 'DRAFT'
						  OR l_get_latest_route_rev.revision_status = 'APPROVAL_REJECTED' ) THEN
					-- Start of Validations for all the mandatory common attributes.
					-- Validate is publish_date is Null and If so throw an error

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Inside Draft'
					    );
					END IF;

					IF (p_pub_date IS NULL AND p_pub_date = FND_API.G_MISS_DATE)
					THEN
						FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_PUB_DATE_NULL');
						FND_MSG_PUB.ADD;
					END IF;

					-- Validate is context is Null and If so throw an error
					IF (p_context IS  NULL AND p_context = FND_API.G_MISS_CHAR)
					THEN
						FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_CONTEXT_NULL');
						FND_MSG_PUB.ADD;
					END IF;

					-- Validate is Enigma_Id is Null and If so throw an error
					IF (p_enigma_route_rec.enigma_ID IS NULL AND p_enigma_route_rec.enigma_ID = FND_API.G_MISS_CHAR)
					THEN
						FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_ENIGMA_ID_NULL');
						FND_MSG_PUB.ADD;
					END IF;

					-- Check the error stack and raise error messages , if any
					x_msg_count := FND_MSG_PUB.count_msg;
					IF x_msg_count > 0
					THEN
					  RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'populate the records'
					    );
					END IF;

                                        IF p_enigma_route_rec.pdf IS NOT NULL
                                        THEN

						-- Call the procedure to upload the file
						UPLOAD_REVISION_REPORT
						(
						  p_enigma_route_rec.pdf,
						  x_file_id,
						  x_return_status
						);
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'After UPLOAD_REVISION_REPORT Call ');
					END IF;

					IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'UPLOAD_REVISION_REPORT Error');
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'UPLOAD_REVISION_REPORT-> File upload done');
						fnd_log.string(fnd_log.level_statement,l_debug_module,'File Id -> = ' || x_file_id);
					END IF;

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'file upload done'
					    );
					END IF;

					-- If the return status is success, populate the input rec for process_route for updation
					IF ( x_file_id  <> FND_API.G_MISS_NUM AND x_file_id  IS NOT NULL) THEN
						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'File id ->' || x_file_id
						    );
						END IF;
						p_process_route_input_rec.FILE_ID := x_file_id ;
					END IF;

					IF ( l_get_latest_route_rev.route_id <> FND_API.G_MISS_NUM AND l_get_latest_route_rev.route_id IS NOT NULL) THEN
						p_process_route_input_rec.ROUTE_ID := l_get_latest_route_rev.route_id;
					END IF;

					IF (l_get_latest_route_rev.object_version_number <> FND_API.G_MISS_NUM AND l_get_latest_route_rev.object_version_number IS NOT NULL ) THEN
						p_process_route_input_rec.object_version_number  := l_get_latest_route_rev.object_version_number;
					END IF;

					IF (p_context <> FND_API.G_MISS_CHAR AND p_context IS NOT NULL ) THEN
						p_process_route_input_rec.model_code  := p_context;
					END IF;

					IF (p_pub_date  <> FND_API.G_MISS_DATE AND p_pub_date IS NOT NULL ) THEN
						p_process_route_input_rec.enigma_publish_date  := p_pub_date;
					END IF;

                                        /* Route no is not updatable
					IF (p_enigma_route_rec.ata_code <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.ata_code IS NOT NULL ) THEN
						p_process_route_input_rec.route_no  := p_enigma_route_rec.ata_code;
					END IF;
                                        */
					IF (p_enigma_route_rec.description <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.description IS NOT NULL ) THEN
						p_process_route_input_rec.title  := p_enigma_route_rec.description;
					END IF;

					IF (p_enigma_route_rec.revision_date <> FND_API.G_MISS_DATE AND p_enigma_route_rec.revision_date IS NOT NULL ) THEN
						p_process_route_input_rec.ACTIVE_START_DATE  := p_enigma_route_rec.revision_date;
					END IF;

					IF (p_enigma_route_rec.enigma_id <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.enigma_id IS NOT NULL ) THEN
						p_process_route_input_rec.enigma_doc_id  := p_enigma_route_rec.enigma_id;
					END IF;

					IF (p_enigma_route_rec.route_id <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.route_id IS NOT NULL ) THEN
						p_process_route_input_rec.enigma_route_id  := p_enigma_route_rec.route_id;
					END IF;

					p_process_route_input_rec.dml_operation := 'U';

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'calling process_route'
					    );
					END IF;

					-- Call the API for update.
					AHL_RM_ROUTE_PVT.process_route
						(
						 '1.0',
						 FND_API.G_TRUE,
						 FND_API.G_FALSE,
						 FND_API.G_VALID_LEVEL_FULL,
						 FND_API.G_FALSE,
						 NULL,
						 x_return_status,
						 x_msg_count,
						 x_msg_data,
						 p_process_route_input_rec
						);

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'after calling process_route'
					    );
					END IF;

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_ROUTE_PVT.process_route');
					END IF;

					IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.process_route Error');
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					-- If the return status is success, then add the transaction to the stating table and status as "Success"
					INSERT INTO AHL_RT_OPER_INTERFACE
					(
						CONTEXT,
						PUBLISH_DATE,
						ROUTE_ID,
						PDF,
						REVISION_DATE,
						CHANGE_FLAG,
						ATA_CODE,
						DESCRIPTION,
						STATUS,
						REASON,
						ENIGMA_ID
					)
					VALUES
					(
						p_context,
						p_pub_date,
						p_enigma_route_rec.route_id,
						p_enigma_route_rec.pdf,
						p_enigma_route_rec.revision_date,
						p_enigma_route_rec.change_flag,
						p_enigma_route_rec.ata_code,
						p_enigma_route_rec.description,
						'SUCCESS',
						'Route updates Successfully',
						p_enigma_route_rec.enigma_id
					);

					-- Check if the route has any operations, if then call the process operation procedure
					IF ( p_enigma_op_tbl.COUNT > 0) THEN
						--FOR i IN p_enigma_op_tbl.FIRST..p_enigma_op_tbl.LAST
						--LOOP

							Process_OP_Details
							(
								'1.0',
								 FND_API.G_TRUE,
								 FND_API.G_FALSE,
								 FND_API.G_VALID_LEVEL_FULL,
								 FND_API.G_FALSE,
								 NULL,
								 x_return_status,
								 x_msg_count,
								 x_msg_data,
								 p_enigma_op_tbl,
								 p_context,
								 p_pub_date,
								 p_enigma_route_rec.route_id
							);

							IF (l_log_statement >= l_log_current_level) THEN
								fnd_log.string(fnd_log.level_statement,l_debug_module,'After Process_OP_Details');
							END IF;

							IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
								IF (l_log_statement >= l_log_current_level) THEN
									fnd_log.string(fnd_log.level_statement,l_debug_module,'Process_OP_Details Error');
								END IF;
								RAISE FND_API.G_EXC_ERROR;
							END IF;
						--END LOOP;
					END IF; -- oper table count

				END IF; -- Status check
		ELSE
			CLOSE get_latest_route_rev;
			-- Raise an error if the route is not found in CMRO..
			FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_ROUTE_DONOT_EXIST1');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		END IF; -- Cursor
		CLOSE get_latest_route_rev;
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN

		    fnd_log.string
		    (
		      fnd_log.level_statement,
		      l_debug_module,
		      'End if of change Flag U'
		    );
		END IF;

	END IF; -- Change Flag U

	IF (p_enigma_route_rec.change_flag = 'C') THEN

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Inside Create'
			    );
		        END IF;

			-- Start of Validations for all the mandatory common attributes.
			-- Validate is publish_date is Null and If so throw an error

			IF (p_pub_date IS NULL AND p_pub_date = FND_API.G_MISS_DATE)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_PUB_DATE_NULL');
				FND_MSG_PUB.ADD;
			END IF;

			-- Validate is context is Null and If so throw an error
			IF (p_context IS  NULL AND p_context = FND_API.G_MISS_CHAR)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_CONTEXT_NULL');
				FND_MSG_PUB.ADD;
			END IF;

			-- Validate is Enigma_Id is Null and If so throw an error
			IF (p_enigma_route_rec.enigma_ID IS NULL AND p_enigma_route_rec.enigma_ID = FND_API.G_MISS_CHAR)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_ENIGMA_ID_NULL');
				FND_MSG_PUB.ADD;
			END IF;

			-- Check the error stack and raise error messages , if any
			x_msg_count := FND_MSG_PUB.count_msg;
			IF x_msg_count > 0
			THEN
			  RAISE FND_API.G_EXC_ERROR;
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Passed all validations'
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_context -> ' || p_context
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_enigma_route_rec.revision_date -> ' || p_enigma_route_rec.revision_date
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_pub_date -> ' || p_pub_date
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_enigma_route_rec.ata_code -> ' || p_enigma_route_rec.ata_code
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_enigma_route_rec.description -> ' || p_enigma_route_rec.description
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_enigma_route_rec.enigma_id -> ' || p_enigma_route_rec.enigma_id
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_enigma_route_rec.route_id -> ' ||  p_enigma_route_rec.route_id
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_enigma_route_rec.change_flag -> ' || p_enigma_route_rec.change_flag
			    );
		        END IF;

			-- Populate the input record with values.
			IF (p_context <> FND_API.G_MISS_CHAR AND p_context IS NOT  NULL ) THEN
				p_process_route_input_rec.model_code  := p_context;
			END IF;

			-- If revision date is not being passed, then set it to sysdate
			IF (p_enigma_route_rec.revision_date IS NULL AND p_enigma_route_rec.revision_date = FND_API.G_MISS_DATE)
			THEN
				p_process_route_input_rec.ACTIVE_START_DATE  := sysdate;
			ELSE
				p_process_route_input_rec.ACTIVE_START_DATE  := p_enigma_route_rec.revision_date;
			END IF;

			IF (p_pub_date  <> FND_API.G_MISS_DATE AND p_pub_date  IS NOT  NULL ) THEN
				p_process_route_input_rec.enigma_publish_date  := p_pub_date;
			END IF;

			IF (p_enigma_route_rec.ata_code <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.ata_code IS NOT  NULL ) THEN
				p_process_route_input_rec.route_no  := p_enigma_route_rec.ata_code;
			END IF;

			IF (p_enigma_route_rec.description <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.description IS NOT  NULL ) THEN
				p_process_route_input_rec.title  := p_enigma_route_rec.description;
			ELSE
			        p_process_route_input_rec.title  := p_enigma_route_rec.ata_code;
			END IF;

			IF (p_enigma_route_rec.enigma_id <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.enigma_id IS NOT  NULL ) THEN
				p_process_route_input_rec.enigma_doc_id  := p_enigma_route_rec.enigma_id;
			END IF;

			IF (p_enigma_route_rec.route_id <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.route_id IS NOT NULL ) THEN
				p_process_route_input_rec.enigma_route_id  := p_enigma_route_rec.route_id;
			END IF;

			IF (p_enigma_route_rec.change_flag <> FND_API.G_MISS_CHAR AND p_enigma_route_rec.change_flag IS NOT NULL ) THEN
				p_process_route_input_rec.dml_operation := p_enigma_route_rec.change_flag;
			END IF;

			IF p_enigma_route_rec.pdf IS NOT NULL
			THEN

				-- Call the procedure to upload the file
				UPLOAD_REVISION_REPORT
				(
				  p_enigma_route_rec.pdf,
				  x_file_id,
				  x_return_status
				);
			END IF;

			IF (l_log_statement >= l_log_current_level) THEN
				fnd_log.string(fnd_log.level_statement,l_debug_module,'After UPLOAD_REVISION_REPORT Call ');
			END IF;

			IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'UPLOAD_REVISION_REPORT Error');
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			IF (l_log_statement >= l_log_current_level) THEN
				fnd_log.string(fnd_log.level_statement,l_debug_module,'UPLOAD_REVISION_REPORT-> File upload done');
				fnd_log.string(fnd_log.level_statement,l_debug_module,'File Id -> = ' || x_file_id);
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'file upload done'
			    );
			END IF;

			-- If the return status is success, populate the input rec for process_route for updation
			IF ( x_file_id  <> FND_API.G_MISS_NUM AND x_file_id  IS NOT NULL) THEN
				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'File id ->' || x_file_id
				    );
				END IF;
				p_process_route_input_rec.FILE_ID := x_file_id ;
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Populated values '
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.model_code -> ' || p_process_route_input_rec.model_code
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.ACTIVE_START_DATE -> ' || p_process_route_input_rec.ACTIVE_START_DATE
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.enigma_publish_date -> ' || p_process_route_input_rec.enigma_publish_date
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.route_no -> ' || p_process_route_input_rec.route_no
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.title -> ' || p_process_route_input_rec.title
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.enigma_doc_id -> ' || p_process_route_input_rec.enigma_doc_id
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.enigma_route_id -> ' || p_process_route_input_rec.enigma_route_id
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'p_process_route_input_rec.dml_operation -> ' || p_process_route_input_rec.dml_operation
			    );
			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Calling process_route in Create mode'
			    );
			END IF;

			-- Call the API for update.
			AHL_RM_ROUTE_PVT.process_route
				(
				 '1.0',
				 FND_API.G_TRUE,
				 FND_API.G_FALSE,
				 FND_API.G_VALID_LEVEL_FULL,
				 FND_API.G_FALSE,
				 NULL,
				 x_return_status,
				 x_msg_count,
				 x_msg_data,
				 p_process_route_input_rec
				);

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'After Calling process_route in Create mode'
			    );
			END IF;

			IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.process_route Error');
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			IF (l_log_statement >= l_log_current_level) THEN
				fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_ROUTE_PVT.process_route -> creation Successful');
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Before inserting into the staging table'
			    );
			END IF;

			-- If the return status is success, then add the transaction to the stating table and status as "Success"
			INSERT INTO AHL_RT_OPER_INTERFACE
			(
				CONTEXT,
				PUBLISH_DATE,
				ROUTE_ID,
				PDF,
				REVISION_DATE,
				CHANGE_FLAG,
				ATA_CODE,
				DESCRIPTION,
				STATUS,
				REASON,
				ENIGMA_ID
			)
			VALUES
			(
				p_context,
				p_pub_date,
				p_enigma_route_rec.route_id,
				p_enigma_route_rec.pdf,
				p_enigma_route_rec.revision_date,
				p_enigma_route_rec.change_flag,
				p_enigma_route_rec.ata_code,
				p_enigma_route_rec.description,
				'SUCCESS',
				'Route created Successfully',
				p_enigma_route_rec.enigma_id
			);

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'After inserting into the staging table'
			    );
			END IF;

			-- Check if the route has any operations, if then call the process operation procedure
			IF ( p_enigma_op_tbl.COUNT > 0) THEN
				--FOR i IN p_enigma_op_tbl.FIRST..p_enigma_op_tbl.LAST
				--LOOP

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Operations Found Calling Process_OP_Details '
					    );
					END IF;

					Process_OP_Details
					(
						'1.0',
						 FND_API.G_TRUE,
						 FND_API.G_FALSE,
						 FND_API.G_VALID_LEVEL_FULL,
						 FND_API.G_FALSE,
						 NULL,
						 x_return_status,
						 x_msg_count,
						 x_msg_data,
						 p_enigma_op_tbl,
						 p_context,
						 p_pub_date,
						 p_enigma_route_rec.route_id
					);

					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'After Process_OP_Details');
					END IF;

					IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'Process_OP_Details Error');
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					END IF;
				--END LOOP;
			END IF; -- oper table count


	END IF; -- status check 'C'

	-- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check for p_commit
    IF FND_API.To_Boolean (p_commit)
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                    p_data  => x_msg_data,
                    p_encoded => fnd_api.g_false );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Process_Route_Details_SP;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Route_Details_SP;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Route_Details_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                        p_procedure_name => 'Process_Route_Details',
                        p_error_text     => SUBSTR(SQLERRM,1,240));
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

END Process_Route_Details;


PROCEDURE Process_OP_Details
(
	p_api_version	     IN	    NUMBER     := '1.0',
	p_init_msg_list      IN	    VARCHAR2   := FND_API.G_TRUE,
	p_commit	     IN	    VARCHAR2   := FND_API.G_FALSE,
	p_validation_level   IN	    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
	p_default	     IN	    VARCHAR2   := FND_API.G_FALSE,
	p_module_type	     IN	    VARCHAR2   := NULL,
	x_return_status      OUT NOCOPY    VARCHAR2,
	x_msg_count	     OUT NOCOPY    NUMBER,
	x_msg_data	     OUT NOCOPY    VARCHAR2,
	p_enigma_op_tbl      IN enigma_op_tbl_type,
	p_context	     IN VARCHAR2,
	p_pub_date	     IN DATE,
	p_parent_route_id    IN VARCHAR2
)
IS

CURSOR get_latest_oper_rev (c_operation_id IN VARCHAR2)
IS
	SELECT
		operation_id,
		object_version_number,
		revision_status_code revision_status
	FROM	AHL_OPERATIONS_B
	WHERE	UPPER(TRIM(ENIGMA_OP_ID)) = UPPER(TRIM(c_operation_id))
	AND REVISION_NUMBER =
	(	SELECT
			MAX( revision_number )
		FROM
			AHL_OPERATIONS_B
		WHERE
			UPPER(TRIM(ENIGMA_OP_ID)) = UPPER(TRIM(c_operation_id))
	);

CURSOR c_get_op_rec (c_oper_id IN NUMBER)
IS
SELECT
  aop.object_version_number
FROM
  ahl_operations_b aop
WHERE
  aop.operation_id = c_oper_id;

	-- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'Process_OP_Details';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'AHL_ENIGMA_ROUTE_OP_PUB'||'.'||l_api_name;

        -- Bug # 8285733
	l_rev_op_rec c_get_op_rec%ROWTYPE;
	l_get_latest_oper_rev	   get_latest_oper_rev%ROWTYPE;
	p_process_oper_input_rec   AHL_RM_OPERATION_PVT.operation_rec_type;
	route_operation_tbl_type   AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type;

	x_operation_id NUMBER;
	parent_route_id VARCHAR2(2000);
	x_revision_number VARCHAR2(30);
	p_route_id NUMBER;

	l_operation_id NUMBER;
	l_object_version_number NUMBER;
	l_revision_status VARCHAR2(100);

	l_step_count NUMBER;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Process_OP_Details_SP;

	-- Initialize return status to success before any code logic/validation
	x_return_status:= FND_API.G_RET_STS_SUCCESS;

	-- Standard call to check for call compatibility
	IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list = FND_API.G_TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.INITIALIZE;
	END IF;

	-- initialise it only if it is a OA Adapter !
	--fnd_global.APPS_INITIALIZE (1003259,62211, 867);

	-- Log API entry point
	IF (l_log_procedure >= l_log_current_level) THEN
		fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN

	    fnd_log.string
	    (
	      fnd_log.level_statement,
	      l_debug_module,
	      'Inside Process_OP_Details... p_enigma_op_tbl.COUNT ->'||p_enigma_op_tbl.COUNT
	    );
	END IF;

        l_step_count := 1;

	-- Check if the tbale has any operations,
	-- If so process them depending on their change flag .
	IF ( p_enigma_op_tbl.COUNT > 0) THEN
		FOR i IN p_enigma_op_tbl.FIRST..p_enigma_op_tbl.LAST
		LOOP

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Inside Process_OP_Details -> Operations Found i->'||i
			    );
			END IF;

			IF ( p_enigma_op_tbl(i).parent_route_id IS NULL OR p_enigma_op_tbl(i).parent_route_id = FND_API.G_MISS_CHAR )
			THEN
				parent_route_id := p_parent_route_id;
			ELSE
				parent_route_id := p_enigma_op_tbl(i).parent_route_id;
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Parent RouteId  ' || parent_route_id
			    );
			END IF;

			-- Verify if the Change flag is right...
			IF (p_enigma_op_tbl(i).change_flag NOT IN ( 'C', 'D', 'U'))
			THEN
				 FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_DML');
				 FND_MESSAGE.SET_TOKEN('FIELD', p_enigma_op_tbl(i).change_flag);
				 FND_MESSAGE.SET_TOKEN('RECORD', p_enigma_op_tbl(i).operation_id);
				 FND_MSG_PUB.ADD;
				 RAISE FND_API.G_EXC_ERROR;
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Change Flag set right'
			    );
			END IF;

			-- Vefify is the operation_id null, if so throw an error .
			IF ( p_enigma_op_tbl(i).operation_id IS NULL OR p_enigma_op_tbl(i).operation_id = FND_API.G_MISS_CHAR)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_OPER_ID_NULL');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN

			    fnd_log.string
			    (
			      fnd_log.level_statement,
			      l_debug_module,
			      'Operation Id is not null'
			    );
			END IF;

			-- If the operation change flag is "D" then process the operation accordingly .
			IF (p_enigma_op_tbl(i).change_flag = 'D') THEN

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Operation Flag is D'
				    );
				END IF;

				l_get_latest_oper_rev := NULL;

				OPEN get_latest_oper_rev (p_enigma_op_tbl(i).operation_id);
				FETCH get_latest_oper_rev INTO
							l_get_latest_oper_rev.operation_id,
							l_get_latest_oper_rev.object_version_number,
							l_get_latest_oper_rev.revision_status;
				CLOSE get_latest_oper_rev;

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_oper_rev.operation_id ->' || l_get_latest_oper_rev.operation_id
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_oper_rev.object_version_number ->' || l_get_latest_oper_rev.object_version_number
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_oper_rev.revision_status ->' || l_get_latest_oper_rev.revision_status
				    );
				END IF;

				IF l_get_latest_oper_rev.operation_id IS NOT NULL THEN


					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN
					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Cursor Found '
					    );
					END IF;

					-- IF the operation is in Approval Pending status , then insert the operation record into the
					-- staging table with status as pending.
					IF ( upper(l_get_latest_oper_rev.revision_status) = 'APPROVAL_PENDING' ) THEN
						INSERT INTO AHL_RT_OPER_INTERFACE
						(
							CONTEXT,
							PUBLISH_DATE,
							OPERATION_ID,
							PARENT_ROUTE_ID,
							CHANGE_FLAG,
							ATA_CODE,
							DESCRIPTION,
							STATUS,
							REASON,
							ENIGMA_ID
						)
						VALUES
						(
							p_context,
							p_pub_date,
							p_enigma_op_tbl(i).operation_id,
							parent_route_id,
							p_enigma_op_tbl(i).change_flag,
							p_enigma_op_tbl(i).ata_code,
							p_enigma_op_tbl(i).description,
							'PENDING',
							'Operation is in approval pending status',
							p_enigma_op_tbl(i).enigma_id
						);

					ELSE
						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN
						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'Inside else , calling delete operation'
						    );
						END IF;

						-- Call the delete operation API
						AHL_RM_OPERATION_PVT.delete_operation
						(
							1.0,
							FND_API.G_TRUE,
							FND_API.G_FALSE,
							FND_API.G_VALID_LEVEL_FULL,
							FND_API.G_FALSE,
							NULL,
							x_return_status,
							x_msg_count,
							x_msg_data,
							l_get_latest_oper_rev.operation_id,
							l_get_latest_oper_rev.object_version_number
						);

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_OPERATION_PVT.delete_operation');
						END IF;

						IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
							IF (l_log_statement >= l_log_current_level) THEN
								fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.delete_operation Error');
							END IF;
							RAISE FND_API.G_EXC_ERROR;
						END IF;

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.delete_operation -> deletion Successful');
						END IF;

						--CLOSE get_latest_oper_rev;
					END IF;
				ELSE
					-- If the operation is not found, then raise an error
					--CLOSE get_latest_oper_rev;
					FND_MESSAGE.SET_NAME('AHL', 'AHL_ENIGMA_OPER_DONOT_EXIST');
					FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;
				END IF; -- Cursor Found
			END IF;	-- Change Flag "D"

			-- If the operation change flag is "U" then process the operation accordingly .
			IF (p_enigma_op_tbl(i).change_flag = 'U') THEN

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Operation Flag is U'
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'p_enigma_op_tbl(i).operation_id -> ' || p_enigma_op_tbl(i).operation_id
				    );
				END IF;

				l_get_latest_oper_rev := NULL;

				OPEN get_latest_oper_rev (p_enigma_op_tbl(i).operation_id);
				FETCH get_latest_oper_rev INTO
							l_get_latest_oper_rev.operation_id,
							l_get_latest_oper_rev.object_version_number,
							l_get_latest_oper_rev.revision_status;
				CLOSE get_latest_oper_rev;

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_oper_rev.operation_id ->' || l_get_latest_oper_rev.operation_id
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_oper_rev.object_version_number ->' || l_get_latest_oper_rev.object_version_number
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'l_get_latest_oper_rev.revision_status ->' || l_get_latest_oper_rev.revision_status
				    );
				END IF;

				IF l_get_latest_oper_rev.operation_id IS NOT NULL THEN

				        -- Bug # 8285733
					--CLOSE get_latest_oper_rev;

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'Latest Operation Found'
					    );
					 END IF;

					-- If the operation is in Approval Pending status , then insert the operation record into the
					-- staging table with status as pending.
					IF ( upper(l_get_latest_oper_rev.revision_status) = 'APPROVAL_PENDING' ) THEN
						INSERT INTO AHL_RT_OPER_INTERFACE
						(
							CONTEXT,
							PUBLISH_DATE,
							OPERATION_ID,
							PARENT_ROUTE_ID,
							CHANGE_FLAG,
							ATA_CODE,
							DESCRIPTION,
							STATUS,
							REASON,
							ENIGMA_ID
						)
						VALUES
						(
							p_context,
							p_pub_date,
							p_enigma_op_tbl(i).operation_id,
							parent_route_id,
							p_enigma_op_tbl(i).change_flag,
							p_enigma_op_tbl(i).ata_code,
							p_enigma_op_tbl(i).description,
							'PENDING',
							'Operation is in approval pending status',
							p_enigma_op_tbl(i).enigma_id
						);

					-- When the operation is in complete, do the following process
					ELSIF (upper(l_get_latest_oper_rev.revision_status) = 'COMPLETE' ) THEN
						-- Call the API to create a new revision of the operation.
						AHL_RM_OPERATION_PVT.create_oper_revision
						(
							 '1.0',
							 FND_API.G_TRUE,
							 FND_API.G_FALSE,
							 FND_API.G_VALID_LEVEL_FULL,
							 FND_API.G_FALSE,
							 NULL,
							 x_return_status,
							 x_msg_count,
							 x_msg_data,
							 l_get_latest_oper_rev.operation_id,
							 l_get_latest_oper_rev.object_version_number,
							 x_operation_id
						);

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_OPERATION_PVT.create_oper_revision');
						END IF;

						IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
							IF (l_log_statement >= l_log_current_level) THEN
								fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.create_oper_revision Error');
							END IF;
							RAISE FND_API.G_EXC_ERROR;
						END IF;

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.create_oper_revision -> revision Created');
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.create_oper_revision -> x_operation_id= ' || x_operation_id);
						END IF;

						-- If the return status is success, populate the input rec for process_operation for updation
						-- Do the mandatory validations

						IF (p_enigma_op_tbl(i).operation_id IS NULL AND p_enigma_op_tbl(i).operation_id = FND_API.G_MISS_DATE)
						THEN
							FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_OPER_ID_NULL');
							FND_MSG_PUB.ADD;
						END IF;

						IF (p_context IS NULL AND p_context = FND_API.G_MISS_DATE)
						THEN
							FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_CONTEXT_NULL');
							FND_MSG_PUB.ADD;
						END IF;

						-- Check the error stack and raise error messages , if any
						x_msg_count := FND_MSG_PUB.count_msg;
						IF x_msg_count > 0
						THEN
						  RAISE FND_API.G_EXC_ERROR;
						END IF;

						IF ( x_operation_id  <> FND_API.G_MISS_NUM AND x_operation_id  IS NOT  NULL) THEN
							p_process_oper_input_rec.OPERATION_ID := x_operation_id ;
						END IF;

						OPEN c_get_op_rec (p_process_oper_input_rec.OPERATION_ID);
						FETCH c_get_op_rec INTO
									l_rev_op_rec.object_version_number;

                                                CLOSE c_get_op_rec;

						IF (l_rev_op_rec.object_version_number <> FND_API.G_MISS_NUM AND l_rev_op_rec.object_version_number IS NOT  NULL ) THEN
							p_process_oper_input_rec.OBJECT_VERSION_NUMBER  := l_rev_op_rec.object_version_number;
						END IF;

						IF (p_context <> FND_API.G_MISS_CHAR AND p_context IS NOT  NULL ) THEN
							p_process_oper_input_rec.MODEL_CODE  := p_context;
							p_process_oper_input_rec.SEGMENT1  := p_context;
						END IF;

						IF (p_enigma_op_tbl(i).description <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).description IS NOT  NULL ) THEN
							p_process_oper_input_rec.DESCRIPTION  := p_enigma_op_tbl(i).description;
						END IF;

						IF (p_enigma_op_tbl(i).operation_id <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).operation_id IS NOT  NULL ) THEN
							p_process_oper_input_rec.ENIGMA_OP_ID  := p_enigma_op_tbl(i).operation_id;
						END IF;

						IF (p_enigma_op_tbl(i).ATA_CODE <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).ATA_CODE IS NOT NULL ) THEN
							p_process_oper_input_rec.SEGMENT2  := p_enigma_op_tbl(i).ATA_CODE;
						END IF;


						p_process_oper_input_rec.DML_OPERATION := 'U';

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(
							   fnd_log.level_statement,
							   l_debug_module,
							   ' After revision operation_id -> '||p_process_oper_input_rec.OPERATION_ID
							);
							fnd_log.string(
							   fnd_log.level_statement,
							   l_debug_module,
							   'After revision object ver no ->  ' || p_process_oper_input_rec.OBJECT_VERSION_NUMBER
							);
						END IF;
						-- Call the API for update
						AHL_RM_OPERATION_PVT.process_operation
							(
							 '1.0',
							 FND_API.G_TRUE,
							 FND_API.G_FALSE,
							 FND_API.G_VALID_LEVEL_FULL,
							 FND_API.G_FALSE,
							 NULL,
							 x_return_status,
							 x_msg_count,
							 x_msg_data,
							 p_process_oper_input_rec
							);

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_OPERATION_PVT.process_operation');
						END IF;

						IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
							IF (l_log_statement >= l_log_current_level) THEN
								fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.process_operation Error');
							END IF;
							RAISE FND_API.G_EXC_ERROR;
						END IF;

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.process_operation -> updation Successful');
						END IF;

						-- Insert the transaction record into the staging table, with status as success
						INSERT INTO AHL_RT_OPER_INTERFACE
						(
							CONTEXT,
							PUBLISH_DATE,
							OPERATION_ID,
							PARENT_ROUTE_ID,
							CHANGE_FLAG,
							ATA_CODE,
							DESCRIPTION,
							STATUS,
							REASON,
							ENIGMA_ID
						)
						VALUES
						(
							p_context,
							p_pub_date,
							p_enigma_op_tbl(i).operation_id,
							parent_route_id,
							p_enigma_op_tbl(i).change_flag,
							p_enigma_op_tbl(i).ata_code,
							p_enigma_op_tbl(i).description,
							'SUCCESS',
							'Operation updated successfully',
							p_enigma_op_tbl(i).enigma_id
						);

					-- If the status is Draft or Approval Rejected , do the following.
					ELSIF ( UPPER(l_get_latest_oper_rev.revision_status) = 'DRAFT'
							  OR UPPER(l_get_latest_oper_rev.revision_status) = 'APPROVAL_REJECTED' ) THEN

						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'Update Operation-> Draft'
						    );
						 END IF;

						-- Do the mandatory validations
						IF (p_enigma_op_tbl(i).operation_id IS NULL AND p_enigma_op_tbl(i).operation_id = FND_API.G_MISS_DATE)
						THEN
							FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_OPER_ID_NULL');
							FND_MSG_PUB.ADD;
						END IF;

						IF (p_context IS NULL AND p_context = FND_API.G_MISS_DATE)
						THEN
							FND_MESSAGE.Set_Name('AHL','AHL_ENIGMA_CONTEXT_NULL');
							FND_MSG_PUB.ADD;
						END IF;

						-- Check the error stack and raise error messages , if any
						x_msg_count := FND_MSG_PUB.count_msg;
						IF x_msg_count > 0
						THEN
						  RAISE FND_API.G_EXC_ERROR;
						END IF;

						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'populate the input rec'
						    );
						 END IF;

						-- If the return status is success, populate the input rec for process_operation for updation
						IF ( l_get_latest_oper_rev.operation_id  <> FND_API.G_MISS_NUM AND l_get_latest_oper_rev.operation_id  IS NOT  NULL) THEN
							p_process_oper_input_rec.OPERATION_ID := l_get_latest_oper_rev.operation_id ;
						END IF;

						IF (l_get_latest_oper_rev.object_version_number <> FND_API.G_MISS_NUM AND l_get_latest_oper_rev.object_version_number IS NOT NULL ) THEN
							p_process_oper_input_rec.OBJECT_VERSION_NUMBER  := l_get_latest_oper_rev.object_version_number;
						END IF;


						IF (p_context <> FND_API.G_MISS_CHAR AND p_context IS NOT NULL ) THEN
							p_process_oper_input_rec.MODEL_CODE  := p_context;
							p_process_oper_input_rec.SEGMENT1  := p_context;
						END IF;

						IF (p_enigma_op_tbl(i).description <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).description IS NOT  NULL ) THEN
							p_process_oper_input_rec.DESCRIPTION  := p_enigma_op_tbl(i).description;
						END IF;

						IF (p_enigma_op_tbl(i).operation_id <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).operation_id IS NOT  NULL ) THEN
							p_process_oper_input_rec.ENIGMA_OP_ID  := p_enigma_op_tbl(i).operation_id;
						END IF;

						IF (p_enigma_op_tbl(i).ATA_CODE <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).ATA_CODE IS NOT NULL ) THEN
							p_process_oper_input_rec.SEGMENT2  := p_enigma_op_tbl(i).ATA_CODE;
						END IF;

						p_process_oper_input_rec.DML_OPERATION := 'U';


						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'p_process_oper_input_rec.OPERATION_ID-> ' || p_process_oper_input_rec.OPERATION_ID
						    );
						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'l_get_latest_oper_rev.object_version_number -> ' || l_get_latest_oper_rev.object_version_number
						    );
						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'p_enigma_op_tbl(i).description -> ' || p_enigma_op_tbl(i).description
						    );
						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'p_process_oper_input_rec.ENIGMA_OP_ID -> ' || p_process_oper_input_rec.ENIGMA_OP_ID
						    );
						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'p_process_oper_input_rec.SEGMENT2   -> ' || p_process_oper_input_rec.SEGMENT2
						    );
						 END IF;

						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'Calling AHL_RM_OPERATION_PVT.process_operation '
						    );
						END IF;

						-- Call the API for update
						AHL_RM_OPERATION_PVT.process_operation
							(
							 '1.0',
							 FND_API.G_TRUE,
							 FND_API.G_FALSE,
							 FND_API.G_VALID_LEVEL_FULL,
							 FND_API.G_FALSE,
							 NULL,
							 x_return_status,
							 x_msg_count,
							 x_msg_data,
							 p_process_oper_input_rec
							);

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_OPERATION_PVT.process_operation');
						END IF;

						IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
							IF (l_log_statement >= l_log_current_level) THEN
								fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.process_operation Error');
							END IF;
							RAISE FND_API.G_EXC_ERROR;
						END IF;

						IF (l_log_statement >= l_log_current_level) THEN
							fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.process_operation -> updation Successful');
						END IF;

						IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
						THEN

						    fnd_log.string
						    (
						      fnd_log.level_statement,
						      l_debug_module,
						      'Before inserting into the staging table'
						    );
						END IF;

						-- Insert the transaction record into the staging table, with status as success
						INSERT INTO AHL_RT_OPER_INTERFACE
						(
							CONTEXT,
							PUBLISH_DATE,
							OPERATION_ID,
							PARENT_ROUTE_ID,
							CHANGE_FLAG,
							ATA_CODE,
							DESCRIPTION,
							STATUS,
							REASON,
							ENIGMA_ID
						)
						VALUES
						(
							p_context,
							p_pub_date,
							p_enigma_op_tbl(i).operation_id,
							parent_route_id,
							p_enigma_op_tbl(i).change_flag,
							p_enigma_op_tbl(i).ata_code,
							p_enigma_op_tbl(i).description,
							'SUCCESS',
							'Operation updated successfully',
							p_enigma_op_tbl(i).enigma_id
						);

					END IF ; -- Status check

					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
					THEN

					    fnd_log.string
					    (
					      fnd_log.level_statement,
					      l_debug_module,
					      'After inserting into the staging table'
					    );
					END IF;
				ELSE
				-- If the operation is not found, then raise an error
					--CLOSE get_latest_oper_rev;
					FND_MESSAGE.SET_NAME('AHL', 'AHL_ENIGMA_OPER_DONOT_EXIST');
					FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;
				END IF; -- Cursor Found
			END IF; -- Change Flag "U"

			-- If the change flag is C then create a new operation.
			IF (p_enigma_op_tbl(i).change_flag = 'C') THEN


				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Inside Process_OP_Details -> Inside C '
				    );
				END IF;

				-- Populate the input records
				IF (p_context <> FND_API.G_MISS_CHAR AND p_context IS NOT  NULL ) THEN
					p_process_oper_input_rec.MODEL_CODE  := p_context;
					p_process_oper_input_rec.SEGMENT1  := p_context;
				END IF;

				IF (p_enigma_op_tbl(i).description <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).description  IS NOT NULL ) THEN
					p_process_oper_input_rec.DESCRIPTION  := p_enigma_op_tbl(i).description;
				ELSE
				        p_process_oper_input_rec.DESCRIPTION  := p_enigma_op_tbl(i).ATA_CODE;
				END IF;

				IF (p_enigma_op_tbl(i).operation_id <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).operation_id IS NOT NULL ) THEN
					p_process_oper_input_rec.ENIGMA_OP_ID  := p_enigma_op_tbl(i).operation_id;
				END IF;

				IF (p_enigma_op_tbl(i).ATA_CODE <> FND_API.G_MISS_CHAR AND p_enigma_op_tbl(i).ATA_CODE IS NOT NULL ) THEN
					p_process_oper_input_rec.SEGMENT2  := p_enigma_op_tbl(i).ATA_CODE;
				END IF;

				p_process_oper_input_rec.ACTIVE_START_DATE := sysdate;
				p_process_oper_input_rec.DML_OPERATION := p_enigma_op_tbl(i).change_flag;
				p_process_oper_input_rec.STANDARD_OPERATION_FLAG := 'N';

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Inside Process_OP_Details calling process_operations'
				    );
				END IF;

				-- Call the API for update
				AHL_RM_OPERATION_PVT.process_operation
				(
					 '1.0',
					 FND_API.G_TRUE,
					 FND_API.G_FALSE,
					 FND_API.G_VALID_LEVEL_FULL,
					 FND_API.G_FALSE,
					 NULL,
					 x_return_status,
					 x_msg_count,
					 x_msg_data,
					 p_process_oper_input_rec
				);

				x_operation_id := p_process_oper_input_rec.operation_id;
				x_revision_number := p_process_oper_input_rec.REVISION_NUMBER;

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Operation Created ->' || x_operation_id
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Operation Created Revision->' || x_revision_number
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Process_OP_Details after calling process_operations'
				    );
				END IF;

				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_OPERATION_PVT.process_operation');
				END IF;

				IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.process_operation Error');
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OPERATION_PVT.process_operation -> creation Successful');
				END IF;

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'before inserting the operations into staging table '
				    );
				END IF;

				-- Insert the transaction record into the staging table, with status as success
				INSERT INTO AHL_RT_OPER_INTERFACE
				(
					CONTEXT,
					PUBLISH_DATE,
					OPERATION_ID,
					PARENT_ROUTE_ID,
					CHANGE_FLAG,
					ATA_CODE,
					DESCRIPTION,
					STATUS,
					REASON,
					ENIGMA_ID
				)
				VALUES
				(
					p_context,
					p_pub_date,
					p_enigma_op_tbl(i).operation_id,
					parent_route_id,
					p_enigma_op_tbl(i).change_flag,
					p_enigma_op_tbl(i).ata_code,
					p_enigma_op_tbl(i).description,
					'SUCCESS',
					'Operation created successfully',
					p_enigma_op_tbl(i).enigma_id
				);

				-- Populate the input record to pass to the procedure to assocaite the operation to the route

				SELECT route_id INTO p_route_id FROM AHL_ROUTES_B
				WHERE ENIGMA_ROUTE_ID = parent_route_id;

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'p_route_id ->  '|| p_route_id
				    );
				END IF;

				route_operation_tbl_type(1) := null;

				route_operation_tbl_type(1).OPERATION_ID := x_operation_id;
				route_operation_tbl_type(1).STEP := l_step_count;
				route_operation_tbl_type(1).DML_OPERATION := 'C';
				route_operation_tbl_type(1).REVISION_NUMBER := x_revision_number;
				route_operation_tbl_type(1).check_point_flag := 'N';

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'route_operation_tbl_type(i).OPERATION_ID ->  '|| route_operation_tbl_type(1).OPERATION_ID
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'route_operation_tbl_type(i).STEP  ->  ' || route_operation_tbl_type(1).STEP
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'route_operation_tbl_type(i).DML_OPERATION   ->  ' || route_operation_tbl_type(1).DML_OPERATION
				    );
				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'route_operation_tbl_type(i).REVISION_NUMBER ->  '|| route_operation_tbl_type(1).REVISION_NUMBER
				    );
				END IF;

				AHL_RM_OP_ROUTE_AS_PVT.process_route_operation_as
				(
					 1.0,
					 FND_API.G_TRUE,
					 FND_API.G_FALSE,
					 FND_API.G_VALID_LEVEL_FULL,
					 FND_API.G_TRUE,
					 NULL,
					 x_return_status,
					 x_msg_count ,
					 x_msg_data ,
					 route_operation_tbl_type,
					 p_route_id
				);

				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
				THEN

				    fnd_log.string
				    (
				      fnd_log.level_statement,
				      l_debug_module,
				      'Association ID x_return_status-> '|| x_return_status
				    );
				END IF;

				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_RM_OP_ROUTE_AS_PVT.process_route_operation_as');
				END IF;

				IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
					IF (l_log_statement >= l_log_current_level) THEN
						fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OP_ROUTE_AS_PVT.process_route_operation_as Error');
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				l_step_count := l_step_count + 1;

				IF (l_log_statement >= l_log_current_level) THEN
					fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_RM_OP_ROUTE_AS_PVT.process_route_operation_as -> association Successful');
				END IF;

			END IF; -- Change Flag "C"
			-- Bug # 8285733. Reset input rec.
			p_process_oper_input_rec := NULL;
		END LOOP;
	END IF; -- Oper Tbl Count

	-- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check for p_commit
    IF FND_API.To_Boolean (p_commit)
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                    p_data  => x_msg_data,
                    p_encoded => fnd_api.g_false );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Process_OP_Details_SP;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_OP_Details_SP;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_OP_Details_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                        p_procedure_name => 'Process_OP_Details_SP',
                        p_error_text     => SUBSTR(SQLERRM,1,240));
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);


END Process_OP_Details;


PROCEDURE UPLOAD_REVISION_REPORT(
  p_file_name     IN         VARCHAR2,
  x_file_id       OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
)
IS

l_contentBlob	BLOB;
l_inputFilePtr	BFILE;
seqNo		NUMBER;
l_api_name      CONSTANT      VARCHAR2(30)      := 'UPLOAD_REVISION_REPORT';
l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'AHL_ENIGMA_ROUTE_OP_PUB'||'.'||l_api_name;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
  THEN

    fnd_log.string
    (
      fnd_log.level_statement,
      l_debug_module,
      'inside UPLOAD_REVISION_REPORT->p_file_name->'||p_file_name
    );
  END IF;


  IF p_file_name IS NULL THEN
    FND_MESSAGE.set_name( 'AHL','AHL_COM_REQD_PARAM_MISSING' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||'upload_revision_report'||':',
            'Revision report file name is null'
        );
    END IF;
    RETURN;
  END IF;

  l_inputFilePtr := BFILENAME('INPUTDIR', p_file_name);
  dbms_lob.open(l_inputFilePtr, dbms_lob.lob_readonly);

  dbms_lob.createtemporary(l_contentBlob,TRUE);
  dbms_lob.open(l_contentBlob,dbms_lob.lob_readWrite);
  dbms_lob.loadfromfile(l_contentBlob,l_inputFilePtr,dbms_lob.getlength(l_inputFilePtr));

  dbms_lob.fileclose(l_inputFilePtr);
  dbms_lob.close(l_contentBlob);

  select fnd_lobs_s.nextval into seqNo from dual;

  insert into fnd_lobs(
	     file_id,
	     file_name,
	     file_content_type,
	     language,
	     file_data,
	     file_format,
	     upload_date
	    )
   values(seqNo,
	  p_file_name,
	  'application/octet-stream',
	  'US',
	  l_contentBlob,
	  'binary',
	  sysdate
   );

   --File upload is successfull assign file_id to x_file_id output variable
   x_file_id := seqNo;


EXCEPTION
WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
		    p_procedure_name  =>  'UPLOAD_REVISION_REPORT',
		    p_error_text      => SUBSTR(SQLERRM,1,240));

	END IF;

END UPLOAD_REVISION_REPORT;

END AHL_ENIGMA_ROUTE_OP_PUB;

/
