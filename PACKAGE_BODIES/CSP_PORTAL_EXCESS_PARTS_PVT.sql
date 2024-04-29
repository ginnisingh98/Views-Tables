--------------------------------------------------------
--  DDL for Package Body CSP_PORTAL_EXCESS_PARTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PORTAL_EXCESS_PARTS_PVT" AS
/* $Header: cspppexb.pls 120.1.12000000.2 2007/07/26 00:26:27 hhaugeru ship $ */

 G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_PORTAL_EXCESS_PARTS_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(30):='cspppexb.pls';

 PROCEDURE Portal_Excess_Parts
      (errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_resource_id            IN NUMBER
      ,P_resource_type          IN VARCHAR2
      ,p_condition_type	        IN VARCHAR2
      ) is

 l_api_version_number      CONSTANT NUMBER := 1.0;
 p_api_version             CONSTANT NUMBER := 1.0;
 l_api_name                CONSTANT VARCHAR2(30) := 'Portal_Excess_Parts';
 l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);
 l_sqlcode 		           Number;
 l_sqlerrm 		           Varchar2(2000);

 Cursor subinv(p_resource_id NUMBER, p_resource_type VARCHAR2, p_condition_type VARCHAR2)
 is
 select distinct organization_id,subinventory_code secondary_inventory_name,condition_type
   from csp_rs_subinventories_v
  where owner_resource_id = p_resource_id and
        owner_resource_type = p_resource_type and
        condition_type = p_condition_type and
       (EFFECTIVE_DATE_END is null or trunc(EFFECTIVE_DATE_END) > trunc(sysdate));

 Cursor planning(p_organization_id NUMBER,p_subinventory_code VARCHAR2,p_condition_type VARCHAR2)
 is
 select level_id from csp_planning_parameters
 where organization_id = p_organization_id and
       secondary_inventory = p_subinventory_code and
       condition_type = p_condition_type;

 Begin

  SAVEPOINT Portal_Excess_Parts_PVT;
  FND_MSG_PUB.initialize;

  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR SUBINVREC in subinv(p_resource_id, p_resource_type, p_condition_type)
  Loop

     CSP_EXCESS_PARTS_PVT.clean_up(p_organization_id => SUBINVREC.organization_id,
             p_subinventory_code => SUBINVREC.secondary_inventory_name,
             p_condition_type    => SUBINVREC.condition_type);

    FOR PLANNINGREC in planning(SUBINVREC.organization_id,SUBINVREC.secondary_inventory_name,SUBINVREC.condition_type)
    Loop

    CSP_EXCESS_PARTS_PVT.excess_parts
    (errbuf
    ,retcode
    ,SUBINVREC.organization_id
    ,PLANNINGREC.level_id
    ,2
    ,1
    ,SUBINVREC.secondary_inventory_name
    ,2
    ,null
    ,null
    ,null
    ,null
    ,null
    ,null
    ,null
    ,null
    ,null
    ,null
    ,1
    ,SYSDATE
    ,0
    ,SYSDATE
    ,0
    ,1318
    ,2
    ,Null
    ,Null
    ,1
    ,1
    ,1
    ,1
    ,1
    ,1
    ,2
    ,3
    ,1
    ,2
    ,2
    );

    IF nvl(retcode,0) <> 0 THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    End Loop;

  End Loop;

  COMMIT WORK;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get
     (p_count          =>   l_msg_count,
      p_data           =>   l_msg_data
     );

  retcode := 0;

  EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      retcode := 2;
	      errbuf := l_Msg_Data;
          l_return_status := FND_API.G_RET_STS_ERROR;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => l_MSG_COUNT
                  ,X_MSG_DATA => l_MSG_DATA
                  ,X_RETURN_STATUS => l_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      retcode := 2;
	      errbuf := l_Msg_Data;
          l_return_status := FND_API.G_RET_STS_ERROR;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => l_MSG_COUNT
                  ,X_MSG_DATA => l_MSG_DATA
                  ,X_RETURN_STATUS => l_RETURN_STATUS);

          WHEN OTHERS THEN

	      retcode := 2;
	      errbuf := l_Msg_Data;
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
          l_return_status := FND_API.G_RET_STS_ERROR;

              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	  	          ,P_SQLCODE	=> l_sqlcode
        	  	  ,P_SQLERRM    => l_sqlerrm
                  ,X_MSG_COUNT => l_MSG_COUNT
                  ,X_MSG_DATA => l_MSG_DATA
                  ,X_RETURN_STATUS => l_RETURN_STATUS);
 End;

END;

/
