--------------------------------------------------------
--  DDL for Package Body OKE_VERSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_VERSION_PUB" AS
/* $Header: OKEPVERB.pls 115.8 2002/11/20 20:39:13 who ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OKE_VERSION_PUB';

PROCEDURE version_contract
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
--,  p_Contract_Number        IN    VARCHAR2 := FND_API.G_MISS_CHAR
--,  p_Contract_Num_Modifier  IN    VARCHAR2 := FND_API.G_MISS_CHAR
,  p_Contract_Header_ID     IN    NUMBER   --:= FND_API.G_MISS_NUM
,  p_chg_request_id	    IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_Prev_Version           OUT   NOCOPY NUMBER
,  x_New_Version            OUT   NOCOPY NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'VERSION_CONTRACT';
l_api_version  CONSTANT NUMBER       := 1.0;

/*
cursor k is
  select id
  from   okc_k_headers_b
  where  contract_number = p_Contract_Number
  and    (  ( (  p_Contract_Num_Modifier IS NULL
              or p_Contract_Num_Modifier = FND_API.G_MISS_CHAR )
            and  contract_number_modifier IS NULL )
         or ( contract_number_modifier = p_Contract_Num_Modifier )
         );
*/
l_chr_id number;

BEGIN

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT version_contract_pub;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_chr_id := p_Contract_Header_ID;


/*
  --
  -- Value to ID conversions
  --
  IF ( p_Contract_Header_ID <> FND_API.G_MISS_NUM ) THEN
    l_chr_id := p_Contract_Header_ID;
  ELSE
    OPEN k;
    FETCH k INTO l_chr_id;
    CLOSE k;
  END IF;
*/
  --
  -- Calling Version Contract private API
  --
  OKE_VERSION_PVT.version_contract
                 ( p_api_version    => p_api_version
                 , x_msg_count      => x_msg_count
                 , x_msg_data       => x_msg_data
                 , x_return_status  => x_return_status
                 , p_chr_id         => l_chr_id
		 ,  p_chg_request_id	   =>  p_chg_request_id
		 ,  p_version_reason_code  =>  p_version_reason_code
                 , x_prev_vers      => x_Prev_Version
                 , x_new_vers       => x_New_Version
                 );

  --
  -- Standard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO version_contract_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO version_contract_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO version_contract_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => l_api_name );

    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

END version_contract;


PROCEDURE restore_contract_version
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
--,  p_Contract_Number        IN    VARCHAR2 := FND_API.G_MISS_CHAR
--,  p_Contract_Num_Modifier  IN    VARCHAR2 := FND_API.G_MISS_CHAR
,  p_Contract_Header_ID     IN    NUMBER   --:= FND_API.G_MISS_NUM
,  p_Restore_From_Version   IN    NUMBER   --:= FND_API.G_MISS_NUM
,  p_chg_request_id	    IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_New_Version            OUT   NOCOPY NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'RESTORE_CONTRACT_VERSION';
l_api_version  CONSTANT NUMBER       := 1.0;

/*
cursor k is
  select id
  from   okc_k_headers_b
  where  contract_number = p_Contract_Number
  and    (  ( (  p_Contract_Num_Modifier IS NULL
              or p_Contract_Num_Modifier = FND_API.G_MISS_CHAR )
            and  contract_number_modifier IS NULL )
         or ( contract_number_modifier = p_Contract_Num_Modifier )
         );
*/

l_chr_id number;

BEGIN

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT rstr_contract_version_pub;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_chr_id := p_Contract_Header_ID;

/*
  IF ( p_Contract_Header_ID is not null ) THEN
    l_chr_id := p_Contract_Header_ID;
  ELSE
    OPEN k;
    FETCH k INTO l_chr_id;
    CLOSE k;
  END IF;
*/

  OKE_VERSION_PVT.restore_contract_version
                 ( p_api_version    => p_api_version
                 , p_commit         => p_commit
                 , p_init_msg_list  => p_init_msg_list
                 , x_msg_count      => x_msg_count
                 , x_msg_data       => x_msg_data
                 , x_return_status  => x_return_status
                 , p_chr_id         => l_chr_id
                 , p_rstr_from_ver  => p_Restore_From_Version
		 ,  p_chg_request_id	   =>  p_chg_request_id
		 ,  p_version_reason_code  =>  p_version_reason_code
                 , x_new_vers       => x_New_Version
                 );

  --
  -- Standard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO rstr_contract_version_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO rstr_contract_version_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO rstr_contract_version_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => l_api_name );

    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

END restore_contract_version;

END oke_version_pub;

/
