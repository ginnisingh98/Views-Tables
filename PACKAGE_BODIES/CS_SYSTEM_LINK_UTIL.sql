--------------------------------------------------------
--  DDL for Package Body CS_SYSTEM_LINK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SYSTEM_LINK_UTIL" AS
/* $Header: cscsiutb.pls 115.7 2001/01/04 13:57:23 pkm ship     $ */

-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_System_Link_UTIL';
G_USER CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;
------------------------------------------------------------

PROCEDURE Associate_System_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
)  IS

    l_api_name     CONSTANT   VARCHAR2(30) := 'Associate_System_With_User';
    l_link_id      NUMBER;
    l_dummy		   NUMBER;

    CURSOR c1 IS
    SELECT party_id
    FROM CS_SYSTEM_PARTY_LINKS
    WHERE party_id = p_party_id
    AND system_id = p_system_id
    AND end_date is null;

BEGIN
    SAVEPOINT Associate_System_User;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_dummy;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
        SELECT CS_SYSTEM_PARTY_LINKS_S1.NEXTVAL
		INTO   l_link_id
		FROM   dual;

        INSERT INTO CS_SYSTEM_PARTY_LINKS
        (
        party_id,
        system_id,
        start_date,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        system_party_link_id,
        object_version_number
        )
        VALUES
        (
        p_party_id,
        p_system_id,
        sysdate,
        sysdate,
        G_USER,
        G_USER,
        sysdate,
        l_link_id,
        1
        );
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
    END IF;
    CLOSE c1;
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    EXCEPTION
        WHEN OTHERS THEN
            CLOSE c1;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('CS','CS_INSERT_UNEXP_ERR');
		    FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get (
               p_count => x_msg_count ,
               p_data => x_msg_data
            );
            x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		    ROLLBACK TO Associate_System_User;

END Associate_System_With_User;

PROCEDURE Disassociate_System_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
) IS
    l_api_name     CONSTANT   VARCHAR2(30) := 'Disassociate_System_With_User';
    l_party_id      NUMBER;
    l_system_id     NUMBER;
    l_dummy			NUMBER;
    CURSOR c1 IS
    SELECT party_id
    FROM CS_SYSTEM_PARTY_LINKS
    WHERE party_id = p_party_id
    AND system_id = p_system_id
    AND end_date is null;

BEGIN

    SAVEPOINT Disassociate_System_User;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_dummy;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CS','CS_NO_LINK_FOUND');
	   FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get (
               p_count => x_msg_count ,
               p_data => x_msg_data
       );
       x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    ELSE
       UPDATE CS_SYSTEM_PARTY_LINKS SET
       end_date = sysdate,
       last_update_date = sysdate,
       last_updated_by = G_USER,
       object_version_number = object_version_number + 1
       WHERE party_id = p_party_id AND system_id = p_system_id AND end_date is null;

       x_return_status := FND_API.G_RET_STS_SUCCESS;
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
       END IF;
    END IF;
    CLOSE c1;

    EXCEPTION
        WHEN OTHERS THEN
          CLOSE c1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MESSAGE.SET_NAME('CS','CS_UPDATE_UNEXP_ERR');
		  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		  ROLLBACK TO Disassociate_System_User;

END Disassociate_System_With_User;

PROCEDURE Associate_Name_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
)  IS
    l_api_name     CONSTANT   VARCHAR2(30) := 'Associate_Name_With_User';
    l_system_id     NUMBER;
    CURSOR c1 IS
    SELECT system_id
    FROM CS_SYSTEMS_ALL_VL
    WHERE name = p_system_name;

BEGIN

    SAVEPOINT Associate_Name_User;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_system_id;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_NOT_EXIST');
	   FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get(
           p_count => x_msg_count ,
           p_data => x_msg_data
       );
       x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    ELSE
        Associate_System_With_User (p_api_version_number,
                                    p_init_msg_list,
                                    p_commit,
                                    l_system_id,
                                    p_party_id,
                                    x_return_status,
                                    x_msg_count,
	                                x_msg_data,
                                    x_java_msg);

    END IF;
    CLOSE c1;

    EXCEPTION
        WHEN OTHERS THEN
          CLOSE c1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_UNEXP_ERR');
		  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		  ROLLBACK TO Associate_Name_User;

END Associate_Name_With_User;

PROCEDURE Disassociate_Name_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
) IS
    l_api_name     CONSTANT   VARCHAR2(30) := 'Disassociate_Name_With_User';
    l_system_id     NUMBER;
    CURSOR c1 IS
    SELECT system_id
    FROM CS_SYSTEMS_ALL_VL
    WHERE name = p_system_name;

BEGIN

    SAVEPOINT Disassociate_Name_User;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_system_id;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_NOT_EXIST');
		  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    ELSE
        Disassociate_System_With_User (p_api_version_number,
                                    p_init_msg_list,
                                    p_commit,
                                    l_system_id,
                                    p_party_id,
                                    x_return_status,
                                    x_msg_count,
	                                x_msg_data,
                                    x_java_msg);

    END IF;
    CLOSE c1;

    EXCEPTION
        WHEN OTHERS THEN
          CLOSE c1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_UNEXP_ERR');
		  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		  ROLLBACK TO Disassociate_Name_User;

END Disassociate_Name_With_User;

PROCEDURE Associate_System_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
) IS

    l_api_name     CONSTANT   VARCHAR2(30) := 'Associate_System_With_SR';
    l_link_id      NUMBER;
    l_dummy			VARCHAR2(1);

    CURSOR c1 IS
    SELECT 'x'
    FROM CS_SYSTEM_SR_LINKS
    WHERE incident_id = p_service_request_id
    AND system_id = p_system_id
    AND end_date is null;

BEGIN

    SAVEPOINT Associate_System_SR;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_dummy;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
        SELECT CS_SYSTEM_SR_LINKS_S1.NEXTVAL
		INTO   l_link_id
		FROM   dual;

        INSERT INTO CS_SYSTEM_SR_LINKS
        (
        incident_id,
        system_id,
        start_date,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        system_sr_link_id,
        object_version_number
        )
        VALUES
        (
        p_service_request_id,
        p_system_id,
        sysdate,
        sysdate,
        G_USER,
        G_USER,
        sysdate,
        l_link_id,
        1
        );
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
    END IF;
    CLOSE c1;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
        WHEN OTHERS THEN
            CLOSE c1;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('CS','CS_INSERT_UNEXP_ERR');
		    FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get (
               p_count => x_msg_count ,
               p_data => x_msg_data
            );
            x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
            ROLLBACK TO Associate_System_SR;

END Associate_System_With_SR;

PROCEDURE Disassociate_System_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
) IS
    l_api_name     CONSTANT   VARCHAR2(30) := 'Disassociate_System_With_SR';
    l_service_request_id  NUMBER;
    l_system_id           NUMBER;
    l_dummy			VARCHAR2(1);

    CURSOR c1 IS
    SELECT 'x'
    FROM CS_SYSTEM_SR_LINKS
    WHERE incident_id = p_service_request_id
    AND system_id = p_system_id
    AND end_date is null;

BEGIN

    SAVEPOINT Disassociate_System_SR;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_dummy;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CS','CS_NO_LINK_FOUND');
	   FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count ,
          p_data => x_msg_data
       );
       x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    ELSE
        -- Will only update the end_date of the links that have end_date = null
        UPDATE CS_SYSTEM_SR_LINKS SET
        end_date = sysdate,
        last_update_date = sysdate,
        last_updated_by = G_USER,
        object_version_number = object_version_number + 1
        WHERE incident_id = p_service_request_id AND system_id = p_system_id AND end_date is null;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;
    END IF;
    CLOSE c1;

    EXCEPTION
        WHEN OTHERS THEN
            CLOSE c1;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('CS','CS_UPDATE_UNEXP_ERR');
		    FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count ,
               p_data => x_msg_data
            );
            x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		    ROLLBACK TO Disassociate_System_SR;


END Disassociate_System_With_SR;

PROCEDURE Associate_Name_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
)  IS
    l_api_name     CONSTANT   VARCHAR2(30) := 'Associate_Name_With_SR';
    l_system_id     NUMBER;
    CURSOR c1 IS
    SELECT system_id
    FROM CS_SYSTEMS_ALL_VL
    WHERE name = p_system_name;

BEGIN

    SAVEPOINT Associate_Name_SR;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_system_id;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_NOT_EXIST');
	   FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count ,
          p_data => x_msg_data
       );
       x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    ELSE
        Associate_System_With_SR (p_api_version_number,
                                    p_init_msg_list,
                                    p_commit,
                                    l_system_id,
                                    p_service_request_id,
                                    x_return_status,
                                    x_msg_count,
	                                x_msg_data,
                                    x_java_msg);

    END IF;
    CLOSE c1;

    EXCEPTION
        WHEN OTHERS THEN
          CLOSE c1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_UNEXP_ERR');
		  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		  ROLLBACK TO Associate_Name_SR;

END Associate_Name_With_SR;

PROCEDURE Disassociate_Name_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
) IS
    l_api_name     CONSTANT   VARCHAR2(30) := 'Disassociate_Name_With_SR';
    l_system_id     NUMBER;
    CURSOR c1 IS
    SELECT system_id
    FROM CS_SYSTEMS_ALL_VL
    WHERE name = p_system_name;

BEGIN

    SAVEPOINT Disassociate_Name_SR;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
	FETCH c1 INTO l_system_id;
    -- If there is no present link then insert.
	IF c1%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_NOT_EXIST');
	   FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get(
            p_count => x_msg_count ,
            p_data => x_msg_data
       );
       x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    ELSE
        Disassociate_System_With_SR (p_api_version_number,
                                    p_init_msg_list,
                                    p_commit,
                                    l_system_id,
                                    p_service_request_id,
                                    x_return_status,
                                    x_msg_count,
	                                x_msg_data,
                                    x_java_msg);

    END IF;
    CLOSE c1;

    EXCEPTION
        WHEN OTHERS THEN
          CLOSE c1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MESSAGE.SET_NAME('CS','CS_SYSTEM_NAME_UNEXP_ERR');
		  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          x_java_msg := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
		  ROLLBACK TO Disassociate_Name_SR;

END Disassociate_Name_With_SR;


END CS_System_Link_UTIL;

/
