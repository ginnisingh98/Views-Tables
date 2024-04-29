--------------------------------------------------------
--  DDL for Package Body FND_IMP_DEPENDENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IMP_DEPENDENCY_PKG" AS
/* $Header: afimpdepb.pls 120.2 2005/11/02 10:20:21 ravmohan noship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='FND_IMP_DEPENDENCY';
G_FILE_NAME     CONSTANT VARCHAR2(16):='afimpdepb.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_DEP_OBJECT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_object_id           OUT NOCOPY     fnd_imp_depobjects.object_id%TYPE,
  p_snapshot_id         IN      fnd_imp_depobjects.snapshot_id%TYPE,
  p_object_name         IN      fnd_imp_depobjects.object_name%TYPE,
  p_object_type         IN      fnd_imp_depobjects.object_type%TYPE,
  p_app_short_name      IN      fnd_imp_depobjects.app_short_name%TYPE,
  p_file_directory      IN      fnd_imp_depobjects.file_directory%TYPE,
  p_filename            IN      fnd_imp_depobjects.filename%TYPE,
  p_file_type           IN      fnd_imp_depobjects.file_type%TYPE,
  p_rcs_id              IN      fnd_imp_depobjects.rcs_id%TYPE,
  p_ochksum             IN      fnd_imp_depobjects.ochksum%TYPE,
  p_fchksum             IN      fnd_imp_depobjects.fchksum%TYPE,
  p_attrib0             IN      fnd_imp_depobjects.attrib0%TYPE,
  p_attrib1             IN      fnd_imp_depobjects.attrib1%TYPE,
  p_attrib2             IN      fnd_imp_depobjects.attrib2%TYPE,
  p_attrib3             IN      fnd_imp_depobjects.attrib3%TYPE,
  p_attrib4             IN      fnd_imp_depobjects.attrib4%TYPE,
  p_attrib5             IN      fnd_imp_depobjects.attrib5%TYPE,
  p_attrib6             IN      fnd_imp_depobjects.attrib6%TYPE,
  p_attrib7             IN      fnd_imp_depobjects.attrib7%TYPE,
  p_attrib8             IN      fnd_imp_depobjects.attrib8%TYPE,
  p_attrib9             IN      fnd_imp_depobjects.attrib9%TYPE,

  p_object_version_number OUT NOCOPY   fnd_imp_depobjects.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_DEP_OBJECT';
        l_api_version           NUMBER  := p_api_version;

        CURSOR sequence_cursor IS
          SELECT fnd_imp_depobjects_s.NEXTVAL from dual;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_DEP_OBJECT;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------


        select object_id into p_object_id
        from fnd_imp_depobjects
        where snapshot_id = p_snapshot_id
              and object_name = p_object_name
              and object_type = p_object_type;

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO INSERT_DEP_OBJECT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

   	OPEN sequence_cursor;
   	FETCH sequence_cursor INTO p_object_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;
        INSERT INTO fnd_imp_depobjects (object_id,
                                     object_version_number,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     -- security_group_id,
                                     snapshot_id,
                                     object_name,
                                     object_type,
                                     app_short_name,
                                     file_directory,
                                     filename,
                                     file_type,
                                     rcs_id,
                                     ochksum,
                                     fchksum,
                                     attrib0,
                                     attrib1,
                                     attrib2,
                                     attrib3,
                                     attrib4,
                                     attrib5,
                                     attrib6,
                                     attrib7,
                                     attrib8,
                                     attrib9
                                     )
        VALUES (p_object_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_snapshot_id,
                p_object_name,
                p_object_type,
                p_app_short_name,
                p_file_directory,
                p_filename,
                p_file_type,
                p_rcs_id,
                p_ochksum,
                p_fchksum,
                p_attrib0,
                p_attrib1,
                p_attrib2,
                p_attrib3,
                p_attrib4,
                p_attrib5,
                p_attrib6,
                p_attrib7,
                p_attrib8,
                p_attrib9);

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_DEP_OBJECT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   	OPEN sequence_cursor;
   	FETCH sequence_cursor INTO p_object_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;
        INSERT INTO fnd_imp_depobjects (object_id,
                                     object_version_number,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     -- security_group_id,
                                     snapshot_id,
                                     object_name,
                                     object_type,
                                     app_short_name,
                                     file_directory,
                                     filename,
                                     file_type,
                                     rcs_id,
                                     ochksum,
                                     fchksum,
                                     attrib0,
                                     attrib1,
                                     attrib2,
                                     attrib3,
                                     attrib4,
                                     attrib5,
                                     attrib6,
                                     attrib7,
                                     attrib8,
                                     attrib9
                                     )
        VALUES (p_object_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_snapshot_id,
                p_object_name,
                p_object_type,
                p_app_short_name,
                p_file_directory,
                p_filename,
                p_file_type,
                p_rcs_id,
                p_ochksum,
                p_fchksum,
                p_attrib0,
                p_attrib1,
                p_attrib2,
                p_attrib3,
                p_attrib4,
                p_attrib5,
                p_attrib6,
                p_attrib7,
                p_attrib8,
                p_attrib9);

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_DEP_OBJECT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   	OPEN sequence_cursor;
   	FETCH sequence_cursor INTO p_object_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;
        INSERT INTO fnd_imp_depobjects (object_id,
                                     object_version_number,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     -- security_group_id,
                                     snapshot_id,
                                     object_name,
                                     object_type,
                                     app_short_name,
                                     file_directory,
                                     filename,
                                     file_type,
                                     rcs_id,
                                     ochksum,
                                     fchksum,
                                     attrib0,
                                     attrib1,
                                     attrib2,
                                     attrib3,
                                     attrib4,
                                     attrib5,
                                     attrib6,
                                     attrib7,
                                     attrib8,
                                     attrib9
                                     )
        VALUES (p_object_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_snapshot_id,
                p_object_name,
                p_object_type,
                p_app_short_name,
                p_file_directory,
                p_filename,
                p_file_type,
                p_rcs_id,
                p_ochksum,
                p_fchksum,
                p_attrib0,
                p_attrib1,
                p_attrib2,
                p_attrib3,
                p_attrib4,
                p_attrib5,
                p_attrib6,
                p_attrib7,
                p_attrib8,
                p_attrib9);

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_DEP_OBJECT;

PROCEDURE INSERT_DEP_RELATION(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_parent_object_id      OUT NOCOPY     fnd_imp_depobjects.object_id%TYPE,
  p_child_object_id       OUT NOCOPY     fnd_imp_depobjects.object_id%TYPE,

  p_snapshot_id           IN      fnd_imp_depobjects.snapshot_id%TYPE,
  p_dependency_type       IN      fnd_imp_deprelations.dependency_type%TYPE,

  p_parent_object_name         IN      fnd_imp_depobjects.object_name%TYPE,
  p_parent_object_type         IN      fnd_imp_depobjects.object_type%TYPE,
  p_parent_app_short_name      IN      fnd_imp_depobjects.app_short_name%TYPE,
  p_parent_file_directory      IN      fnd_imp_depobjects.file_directory%TYPE,
  p_parent_filename            IN      fnd_imp_depobjects.filename%TYPE,
  p_parent_file_type           IN      fnd_imp_depobjects.file_type%TYPE,
  p_parent_rcs_id              IN      fnd_imp_depobjects.rcs_id%TYPE,
  p_parent_ochksum             IN      fnd_imp_depobjects.ochksum%TYPE,
  p_parent_fchksum             IN      fnd_imp_depobjects.fchksum%TYPE,
  p_parent_attrib0             IN      fnd_imp_depobjects.attrib0%TYPE,
  p_parent_attrib1             IN      fnd_imp_depobjects.attrib1%TYPE,
  p_parent_attrib2             IN      fnd_imp_depobjects.attrib2%TYPE,
  p_parent_attrib3             IN      fnd_imp_depobjects.attrib3%TYPE,
  p_parent_attrib4             IN      fnd_imp_depobjects.attrib4%TYPE,
  p_parent_attrib5             IN      fnd_imp_depobjects.attrib5%TYPE,
  p_parent_attrib6             IN      fnd_imp_depobjects.attrib6%TYPE,
  p_parent_attrib7             IN      fnd_imp_depobjects.attrib7%TYPE,
  p_parent_attrib8             IN      fnd_imp_depobjects.attrib8%TYPE,
  p_parent_attrib9             IN      fnd_imp_depobjects.attrib9%TYPE,

  p_child_object_name         IN      fnd_imp_depobjects.object_name%TYPE,
  p_child_object_type         IN      fnd_imp_depobjects.object_type%TYPE,
  p_child_app_short_name      IN      fnd_imp_depobjects.app_short_name%TYPE,
  p_child_file_directory      IN      fnd_imp_depobjects.file_directory%TYPE,
  p_child_filename            IN      fnd_imp_depobjects.filename%TYPE,
  p_child_file_type           IN      fnd_imp_depobjects.file_type%TYPE,
  p_child_rcs_id              IN      fnd_imp_depobjects.rcs_id%TYPE,
  p_child_ochksum             IN      fnd_imp_depobjects.ochksum%TYPE,
  p_child_fchksum             IN      fnd_imp_depobjects.fchksum%TYPE,
  p_child_attrib0             IN      fnd_imp_depobjects.attrib0%TYPE,
  p_child_attrib1             IN      fnd_imp_depobjects.attrib1%TYPE,
  p_child_attrib2             IN      fnd_imp_depobjects.attrib2%TYPE,
  p_child_attrib3             IN      fnd_imp_depobjects.attrib3%TYPE,
  p_child_attrib4             IN      fnd_imp_depobjects.attrib4%TYPE,
  p_child_attrib5             IN      fnd_imp_depobjects.attrib5%TYPE,
  p_child_attrib6             IN      fnd_imp_depobjects.attrib6%TYPE,
  p_child_attrib7             IN      fnd_imp_depobjects.attrib7%TYPE,
  p_child_attrib8             IN      fnd_imp_depobjects.attrib8%TYPE,
  p_child_attrib9             IN      fnd_imp_depobjects.attrib9%TYPE,

  p_object_version_number OUT NOCOPY   fnd_imp_deprelations.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_DEP_RELATION';
        l_api_version           NUMBER  := p_api_version;
        l_parent_object_id      NUMBER;
        l_child_object_id       NUMBER;
        l_object_version_number NUMBER;
        l_return_status         VARCHAR2(2000);

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_DEP_RELATION;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------



        INSERT_DEP_OBJECT( 1.0,
                           FND_API.G_TRUE,
                           FND_API.G_FALSE,
                           l_child_object_id,
                           p_snapshot_id,
                           p_child_object_name,
                           p_child_object_type,
                           p_child_app_short_name,
                           p_child_file_directory,
                           p_child_filename,
                           p_child_file_type,
                           p_child_rcs_id,
                           p_child_ochksum,
                           p_child_fchksum,
                           p_child_attrib0,
                           p_child_attrib1,
                           p_child_attrib2,
                           p_child_attrib3,
                           p_child_attrib4,
                           p_child_attrib5,
                           p_child_attrib6,
                           p_child_attrib7,
                           p_child_attrib8,
                           p_child_attrib9,
                           l_object_version_number,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        p_child_object_id := l_child_object_id;

        INSERT_DEP_OBJECT( 1.0,
                           FND_API.G_TRUE,
                           FND_API.G_FALSE,
                           l_parent_object_id,
                           p_snapshot_id,
                           p_parent_object_name,
                           p_parent_object_type,
                           p_parent_app_short_name,
                           p_parent_file_directory,
                           p_parent_filename,
                           p_parent_file_type,
                           p_parent_rcs_id,
                           p_parent_ochksum,
                           p_parent_fchksum,
                           p_parent_attrib0,
                           p_parent_attrib1,
                           p_parent_attrib2,
                           p_parent_attrib3,
                           p_parent_attrib4,
                           p_parent_attrib5,
                           p_parent_attrib6,
                           p_parent_attrib7,
                           p_parent_attrib8,
                           p_parent_attrib9,
                           l_object_version_number,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        p_parent_object_id := l_parent_object_id;

        p_object_version_number := 1;

        INSERT INTO fnd_imp_deprelations ( object_version_number,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     -- security_group_id,
                                     snapshot_id,
                                     parent_object_id,
                                     parent_object_name,
                                     parent_app_short_name,
                                     parent_object_type,
                                     child_object_id,
                                     child_object_name,
                                     child_app_short_name,
                                     child_object_type,
                                     dependency_type,
                                     graph_dependency)
        VALUES ( p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_snapshot_id,
                p_parent_object_id,
                p_parent_object_name,
                p_parent_app_short_name,
                p_parent_object_type,
                p_child_object_id,
                p_child_object_name,
                p_child_app_short_name,
                p_child_object_type,
                p_dependency_type,
                0);


        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO INSERT_DEP_RELATION;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_DEP_RELATION;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_DEP_RELATION;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_DEP_RELATION;

END FND_IMP_DEPENDENCY_PKG;

/
