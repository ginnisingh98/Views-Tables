--------------------------------------------------------
--  DDL for Package Body AMW_OBJECT_ASSESSMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_OBJECT_ASSESSMENTS_PVT" AS
/* $Header: amwobassb.pls 120.0 2005/05/31 22:21:42 appldev noship $ */

G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_OBJECT_ASSESSMENTS_PVT';
G_FILE_NAME   CONSTANT VARCHAR2 (15) := 'amwobassb.pls';


FUNCTION check_object_assess_exists
(
    p_assessment_id	IN	   NUMBER,
    p_object_type       IN         VARCHAR2
)
RETURN VARCHAR2 IS

l_dummy NUMBER;

BEGIN
	SELECT 1 INTO l_dummy
	FROM amw_object_assessments
	WHERE assessment_id = p_assessment_id
	AND object_type = p_object_type;

	RETURN 'Y';

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN 'N';

		WHEN TOO_MANY_ROWS THEN
		RETURN 'Y';
END check_object_assess_exists;

PROCEDURE create_object_assessment
(
 p_api_version_number   IN NUMBER   := 1.0,
 p_init_msg_list        IN VARCHAR2 := FND_API.g_false,
 p_commit               IN VARCHAR2 := FND_API.g_false,
 p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
 p_object_type          IN VARCHAR2,
 p_assessment_id	IN NUMBER,
 p_certification_id     IN NUMBER,
 p_org_id	        IN NUMBER,
 p_process_id           IN NUMBER,
 x_return_status        OUT nocopy VARCHAR2,
 x_msg_count            OUT nocopy NUMBER,
 x_msg_data             OUT nocopy VARCHAR2
)
IS

l_api_name           CONSTANT VARCHAR2(30) := 'create_object_assessment';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT CREATE_OBJECT;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_object_type = 'PROCESS'
	THEN

		UPDATE amw_object_assessments apa
		SET apa.assessment_id      = p_assessment_id
		WHERE apa.pk1              = p_certification_id
		AND  apa.pk2               = p_org_id
		AND  apa.pk3               = p_process_id
                AND  apa.object_type       = p_object_type;

		INSERT INTO amw_object_assessments (
			object_assessment_id,
			assessment_id,
                        object_type,
			pk1,
			pk2,
			pk3,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			object_version_number)
		SELECT 	amw_object_assessments_s.nextval,
			p_assessment_id,
                        p_object_type,
			p_certification_id,
			p_org_id,
			p_process_id,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			1
		FROM dual
		WHERE NOT EXISTS
			  (SELECT 'Y' FROM amw_object_assessments
			   WHERE pk1     = p_certification_id
			   AND pk2       = p_org_id
			   AND pk3       = p_process_id
               AND object_type = 'PROCESS'
			  );
	END IF;

	EXCEPTION WHEN OTHERS THEN
	ROLLBACK TO CREATE_OBJECT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	FND_MSG_PUB.Count_And_Get(
	p_encoded =>  FND_API.G_FALSE,
	p_count   =>  x_msg_count,
	p_data    =>  x_msg_data);


END create_object_assessment;


PROCEDURE update_object_assessment
(
 p_api_version_number   IN NUMBER   := 1.0,
 p_init_msg_list        IN VARCHAR2 := FND_API.g_false,
 p_commit               IN VARCHAR2 := FND_API.g_false,
 p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
 p_object_type          IN VARCHAR2,
 p_assessment_id	IN NUMBER,
 p_certification_id	IN NUMBER,
 p_org_id	        IN NUMBER,
 p_process_id		IN NUMBER,
 x_return_status        OUT nocopy VARCHAR2,
 x_msg_count            OUT nocopy NUMBER,
 x_msg_data             OUT nocopy VARCHAR2
)
IS

l_api_name           CONSTANT VARCHAR2(30) := 'update_object_assessment';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT UPDATE_OBJECT;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_object_type = 'PROCESS'
	THEN
		UPDATE amw_object_assessments apa
		SET apa.assessment_id      = p_assessment_id
		WHERE apa.pk1              = p_certification_id
		AND  apa.pk2               = p_org_id
		AND  apa.pk3               = p_process_id
                AND  apa.object_type       = p_object_type;
	END IF;

	EXCEPTION WHEN OTHERS THEN
	ROLLBACK TO UPDATE_OBJECT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	FND_MSG_PUB.Count_And_Get(
	p_encoded =>  FND_API.G_FALSE,
	p_count   =>  x_msg_count,
	p_data    =>  x_msg_data);


END update_object_assessment;

PROCEDURE remove_object_assessment
(
 p_api_version_number   IN NUMBER   := 1.0,
 p_init_msg_list        IN VARCHAR2 := FND_API.g_false,
 p_commit               IN VARCHAR2 := FND_API.g_false,
 p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
 p_object_type          IN VARCHAR2,
 p_assessment_id	IN NUMBER,
 p_certification_id	IN NUMBER,
 p_org_id	        IN NUMBER,
 p_process_id		IN NUMBER,
 x_return_status        OUT nocopy VARCHAR2,
 x_msg_count            OUT nocopy NUMBER,
 x_msg_data             OUT nocopy VARCHAR2
)
IS

l_api_name           CONSTANT VARCHAR2(30) := 'remove_object_assessment';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN
	SAVEPOINT REMOVE_OBJECT;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

    -- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_object_type = 'PROCESS'
	THEN
		DELETE FROM amw_object_assessments apa
		WHERE apa.pk1              = p_certification_id
		AND  apa.pk2               = p_org_id
		AND  apa.pk3               = p_process_id
                AND  apa.object_type       = p_object_type;
	END IF;

	EXCEPTION WHEN OTHERS THEN
	ROLLBACK TO REMOVE_OBJECT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	FND_MSG_PUB.Count_And_Get(
	p_encoded =>  FND_API.G_FALSE,
	p_count   =>  x_msg_count,
	p_data    =>  x_msg_data);

END remove_object_assessment;

END AMW_OBJECT_ASSESSMENTS_PVT;



/
