--------------------------------------------------------
--  DDL for Package Body IEX_CNSLD_DELINQUENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CNSLD_DELINQUENCY_PUB" AS
/* $Header: iexpcodb.pls 120.0 2004/01/24 03:19:11 appldev noship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'IEX_CNSLD_DELINQUENCY_PUB';
  G_FILE_NAME    CONSTANT VARCHAR2(12) := 'iexpcodb.pls';
  G_APPL_ID                NUMBER := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID               NUMBER := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID             NUMBER := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID                NUMBER := FND_GLOBAL.User_Id;
  G_REQUEST_ID             NUMBER := FND_GLOBAL.Conc_Request_Id;

  -- this will be the outside wrapper for the concurrent program to call the "creation" in batch
  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Consolidate_Delinquency_CONCUR(ERRBUF      OUT NOCOPY     VARCHAR2,
                                  RETCODE     OUT NOCOPY     VARCHAR2,
                                  p_list_name IN VARCHAR2)

  IS

  BEGIN
    null;
  END Consolidate_Delinquency_CONCUR;

  PROCEDURE Consolidate_Customer
      (p_api_version      IN  NUMBER,
       p_init_msg_list    IN  VARCHAR2,
       p_commit           IN  VARCHAR2,
       p_validation_level IN  NUMBER,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
     x_consolidated_cnt OUT NOCOPY NUMBER)
  IS

  BEGIN
    null;
  END Consolidate_Customer;

  PROCEDURE Consolidate_Account
      (p_api_version      IN  NUMBER,
       p_init_msg_list    IN  VARCHAR2,
       p_commit           IN  VARCHAR2,
       p_validation_level IN  NUMBER,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
       x_consolidated_cnt OUT NOCOPY NUMBER)
  IS
  BEGIN
    null;
  END Consolidate_Account;

  PROCEDURE Consolidate_Transaction
      (p_api_version      IN  NUMBER,
       p_init_msg_list    IN  VARCHAR2,
       p_commit           IN  VARCHAR2,
       p_validation_level IN  NUMBER,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
       x_consolidated_cnt OUT NOCOPY NUMBER)
  IS
  BEGIN
    null;
  END Consolidate_Transaction;
END IEX_CNSLD_DELINQUENCY_PUB;

/
