--------------------------------------------------------
--  DDL for Package Body INV_ITEM_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_STATUS_PUB" AS
/* $Header: INVPISTB.pls 120.1 2006/05/26 07:24:58 lparihar noship $ */

G_PKG_NAME     CONSTANT  VARCHAR2(30)  :=  'INV_ITEM_STATUS_PUB';
G_FILE_NAME    CONSTANT  VARCHAR2(12)  :=  'INVPISTB.pls';

PROCEDURE Update_Pending_Status (p_api_version   IN   NUMBER
				,p_Org_Id        IN   NUMBER  := NULL
				,p_Item_Id       IN   NUMBER  := NULL
                                ,p_init_msg_list IN   VARCHAR2:=  FND_API.G_FALSE
                                ,p_commit        IN   VARCHAR2:=  FND_API.g_FALSE
				,x_return_status OUT  NOCOPY VARCHAR2
                                ,x_msg_count     OUT  NOCOPY NUMBER
                                ,x_msg_data      OUT  NOCOPY VARCHAR2)
IS
   l_api_name        CONSTANT  VARCHAR2(30)  :=  'Update_Pending_Status';
   l_api_version     CONSTANT  NUMBER        :=  1.0;
   l_errbuf          VARCHAR2(1000);
   l_ret_code        NUMBER(10);

BEGIN

   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   INV_ITEM_STATUS_CP.Process_Pending_Status
                         (ERRBUF          => l_errbuf
 		         ,RETCODE         => l_ret_code
			 ,p_Org_Id        => p_Org_Id
			 ,p_Item_Id       => p_Item_Id
                         ,p_commit        => p_commit
                         ,p_init_msg_list => p_init_msg_list
			 ,p_msg_logname   => 'PLM_LOG');

   INV_ITEM_MSG.Count_And_Get(p_count  =>  x_msg_count
                             ,p_data   =>  x_msg_data);

   --5230594 Commenting this delete call the messages will be accessed in UI
   --INV_ITEM_MSG.Write_List(p_delete => TRUE);

   IF l_ret_code IN(1,2) THEN
      x_return_status := FND_API.g_RET_STS_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
      INV_ITEM_MSG.Count_And_Get(p_count  =>  x_msg_count
                                ,p_data   =>  x_msg_data);
      INV_ITEM_MSG.Write_List(p_delete => TRUE);

   WHEN OTHERS THEN
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
      INV_ITEM_MSG.Count_And_Get(p_count  =>  x_msg_count
                                ,p_data   =>  x_msg_data);
      INV_ITEM_MSG.Write_List(p_delete => TRUE);

END Update_Pending_Status;

end INV_ITEM_STATUS_PUB;

/
