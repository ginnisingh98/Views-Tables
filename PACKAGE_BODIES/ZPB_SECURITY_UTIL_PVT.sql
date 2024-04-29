--------------------------------------------------------
--  DDL for Package Body ZPB_SECURITY_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_SECURITY_UTIL_PVT" AS
/* $Header: ZPBVSCUB.pls 120.4 2007/12/04 14:40:22 mbhat noship $ */


  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ZPB_SECURITY_UTIL_PVT';

-------------------------------------------------------------------------------

/* This procedure validates that the given user is an EPB user and whether read access has been assigned */

   PROCEDURE validate_user(p_user_id             IN  NUMBER,
                           p_business_area_id  IN  NUMBER,
                              p_api_version         IN  NUMBER,
                              p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                              p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                              p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                              x_user_account_state  OUT NOCOPY varchar2,
                              x_return_status       OUT NOCOPY varchar2,
                              x_msg_count           OUT NOCOPY number,
                              x_msg_data            OUT NOCOPY varchar2)


           IS

             l_api_name      CONSTANT VARCHAR2(32) := 'validate_user';
             l_api_version   CONSTANT NUMBER       := 1.0;

             l_invalid_user  CONSTANT VARCHAR2(12) := 'INVALID_USER';
             l_has_read_acc  CONSTANT VARCHAR2(12) := 'HAS_READ_ACC';
             l_no_read_acc   CONSTANT VARCHAR2(11) := 'NO_READ_ACC';

             l_schema        VARCHAR2(64);
             l_shared_aw     VARCHAR2(128);
             l_code_aw       VARCHAR2(128);
             l_status        VARCHAR2(1);
             l_user_id       VARCHAR2(16);
             l_count         NUMBER;
             l_data          VARCHAR2(4000);
             l_secAdminId    NUMBER;
             l_readAcc       VARCHAR2(3);


           BEGIN

             -- Standard Start of API savepoint
             SAVEPOINT zpb_excp_pvt_populate_results;
             -- Standard call to check for call compatibility.
             IF NOT FND_API.Compatible_API_Call( l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME)
             THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             -- Initialize message list if p_init_msg_list is set to TRUE.
             IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
             END IF;
             --  Initialize API return status to success
             x_return_status := FND_API.G_RET_STS_SUCCESS;

             -- API body

             ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Validating user ' || p_user_id || '...');

             l_user_id := to_char(p_user_id);

             l_readAcc := ZPB_AW.INTERP('shw sc.has.read.acc(''' || p_user_id || ''')');
             if l_readAcc = 'YES' then
                x_user_account_state := l_has_read_acc;
             else
                x_user_account_state := l_no_read_acc;
             end if;

             ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'User validation complete.');

             -- End of API body.

             -- Standard check of p_commit.
             IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
             END IF;
             -- Standard call to get message count and if count is 1, get message info.
             FND_MSG_PUB.Count_And_Get(
             p_count =>  x_msg_count, p_data  =>  x_msg_data );

             EXCEPTION
               WHEN FND_API.G_EXC_ERROR THEN
                 ROLLBACK TO zpb_excp_pvt_populate_results;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MSG_PUB.Count_And_Get(
                   p_count =>  x_msg_count,
                   p_data  =>  x_msg_data
                 );
               WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 ROLLBACK TO zpb_excp_pvt_populate_results;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 FND_MSG_PUB.Count_And_Get(
                   p_count =>  x_msg_count,
                   p_data  =>  x_msg_data
                 );
               WHEN OTHERS THEN
                 ROLLBACK TO zpb_excp_pvt_populate_results;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                   FND_MSG_PUB.Add_Exc_Msg(
                     G_PKG_NAME,
                     l_api_name
                   );
                 END IF;
                 FND_MSG_PUB.Count_And_Get(
                   p_count =>  x_msg_count,
                   p_data  =>  x_msg_data
                 );


 END validate_user;

 PROCEDURE has_read_access (p_user_id           IN  NUMBER,
                            p_business_area_id  IN  NUMBER,
                          p_api_version         IN  NUMBER,
                          p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                          p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                          p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                          x_user_read_access    OUT NOCOPY varchar2,
                          x_return_status       OUT NOCOPY varchar2,
                          x_msg_count           OUT NOCOPY number,
                          x_msg_data            OUT NOCOPY varchar2)

 IS

      l_api_name      CONSTANT VARCHAR2(32) := 'validate_user';
      l_api_version   CONSTANT NUMBER       := 1.0;

      l_has_read_acc  CONSTANT VARCHAR2(12) := 'HAS_READ_ACC';
      l_no_read_acc   CONSTANT VARCHAR2(11) := 'NO_READ_ACC';

      l_user_name     VARCHAR2(128);
      l_read_acc      NUMBER;
      l_data          VARCHAR2(4000);
      l_secAdminId    NUMBER;


BEGIN

-- Standard Start of API savepoint
SAVEPOINT zpb_excp_pvt_populate_results;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call( l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME)
THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API body

ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Check for read access assigned to user ' || p_user_id || '...');

select max(has_read_access) into l_read_acc
  from zpb_account_states
   where user_id = p_user_id
   and business_area_id = p_business_area_id;

if l_read_acc = 1 then
        x_user_read_access := l_has_read_acc;
else
        x_user_read_access := l_no_read_acc;
end if;

ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Read access check complete.');

-- End of API body.

-- Standard check of p_commit.
IF FND_API.To_Boolean( p_commit ) THEN
COMMIT WORK;
END IF;
-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(
p_count =>  x_msg_count, p_data  =>  x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO zpb_excp_pvt_populate_results;
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data
  );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO zpb_excp_pvt_populate_results;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data
  );
WHEN OTHERS THEN
  ROLLBACK TO zpb_excp_pvt_populate_results;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(
      G_PKG_NAME,
      l_api_name
    );
  END IF;
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data
  );


 END has_read_access;


/* This procedure sets the read access state in zpb_account_states */

    PROCEDURE set_user_access_state
                              (p_user_id             IN  NUMBER,
                               p_read_access_state   IN  varchar2,
                               p_api_version         IN  NUMBER,
                               p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                               p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                               p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                               x_read_access_state   OUT NOCOPY varchar2,
                               x_return_status       OUT NOCOPY varchar2,
                               x_msg_count           OUT NOCOPY number,
                               x_msg_data            OUT NOCOPY varchar2)


            IS

              l_api_name      CONSTANT VARCHAR2(32) := 'set_user_access_state';
              l_api_version   CONSTANT NUMBER       := 1.0;

              l_invalid_user  CONSTANT VARCHAR2(12) := 'INVALID_USER';
              l_has_read_acc  CONSTANT VARCHAR2(12) := 'HAS_READ_ACC';
              l_no_read_acc   CONSTANT VARCHAR2(11) := 'NO_READ_ACC';

              l_schema        VARCHAR2(64);
              l_shared_aw     VARCHAR2(128);
              l_code_aw       VARCHAR2(128);
              l_status        VARCHAR2(1);
              l_user_id       VARCHAR2(16);
              l_count         NUMBER;
              l_data          VARCHAR2(4000);
              l_secAdminId    NUMBER;
              l_readAcc       NUMBER(1);


            BEGIN

              -- Standard Start of API savepoint
              SAVEPOINT zpb_excp_pvt_populate_results;
              -- Standard call to check for call compatibility.
              IF NOT FND_API.Compatible_API_Call( l_api_version,
                                                  p_api_version,
                                                  l_api_name,
                                                  G_PKG_NAME)
              THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              -- Initialize message list if p_init_msg_list is set to TRUE.
              IF FND_API.to_Boolean(p_init_msg_list) THEN
                 FND_MSG_PUB.initialize;
              END IF;
              --  Initialize API return status to success
              x_return_status := FND_API.G_RET_STS_SUCCESS;

              -- API body

              ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Setting read access state for user ' || p_user_id || ' ...');

              l_user_id := to_char(p_user_id);

              if p_read_access_state = l_has_read_acc
              then
                 l_readAcc := 1;
              else
                 l_readAcc := 0;
              end if;

              update ZPB_ACCOUNT_STATES
                set has_read_access = l_readAcc
                where user_id = p_user_id;

              ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'User access state has been set to ' || l_readAcc || '.');

              -- End of API body.

              -- Standard check of p_commit.
              IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
              END IF;
              -- Standard call to get message count and if count is 1, get message info.
              FND_MSG_PUB.Count_And_Get(
              p_count =>  x_msg_count, p_data  =>  x_msg_data );

              EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                  ROLLBACK TO zpb_excp_pvt_populate_results;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data
                  );
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  ROLLBACK TO zpb_excp_pvt_populate_results;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data
                  );
                WHEN OTHERS THEN
                  ROLLBACK TO zpb_excp_pvt_populate_results;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                    FND_MSG_PUB.Add_Exc_Msg(
                      G_PKG_NAME,
                      l_api_name
                    );
                  END IF;
                  FND_MSG_PUB.Count_And_Get(
                    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data
                  );


 END set_user_access_state;

 END ZPB_SECURITY_UTIL_PVT;


/
