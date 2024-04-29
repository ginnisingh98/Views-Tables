--------------------------------------------------------
--  DDL for Package Body AMS_GEN_SUP_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_GEN_SUP_LIST_PVT" AS
/* $Header: amsvsplb.pls 115.6 2003/02/15 00:00:11 gjoby ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_Gen_Sup_List_PVT
--
-- PROCEDURES
--
-- HISTORY
-- 30-MAY-2001 vbhandar      Created.
------------------------------------------------------------

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_Gen_Sup_List_PVT';

-----------------------------------------------------------
-- PROCEDURE
--    Schedule_Suppression_List
-- HISTORY
-----------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Schedule_Suppression_List(
   errbuf                  OUT NOCOPY   VARCHAR2,
   retcode                 OUT NOCOPY   NUMBER

)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;

   l_list_header_id     NUMBER;
   l_list_name          VARCHAR2(240);
   l_return_status      VARCHAR2(1);
   l_cnt                NUMBER := 0 ;
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);

   CURSOR c_sup_list IS
      SELECT list_header_id,list_name
      FROM   ams_list_headers_vl
      WHERE  list_type='SUPPRESSION'
      AND STATUS_CODE NOT IN('ARCHIVED','CANCELLED');

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Suppression List Generation ');

   OPEN c_sup_list;
   LOOP
      FETCH c_sup_list INTO l_list_header_id,l_list_name ;
      EXIT WHEN c_sup_list%NOTFOUND;

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Suppression list Header Id        : '||l_list_header_id );
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Suppression list Header Name        : '||l_list_name );

      errbuf:= 'Suppression List Generation';
      retcode:=0;


      AMS_ListGeneration_PKG.Generate_List (
         p_api_version           => L_API_VERSION,
         p_init_msg_list         => FND_API.g_true,
         p_commit                => FND_API.g_true,
	 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_list_header_id	 => l_list_header_id,
         x_return_status         => l_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data

      );

       IF l_return_status <> FND_API.g_ret_sts_success  THEN
	     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
	     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
	     FND_MSG_PUB.Add;
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION in list gen package: AMS_Gen_Sup_List_PVT.Schedule_Suppression_List ');

	     l_msg_count := FND_MSG_PUB.count_msg;
	     FOR i IN 1..FND_MSG_PUB.count_msg LOOP
	        l_msg_data := FND_MSG_PUB.get(i, FND_API.G_FALSE);
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : AMS_Gen_Sup_List_PVT.Schedule_Suppression_List '|| l_msg_data);
	     END LOOP;

	     -- clear message buffer
            l_return_status := FND_API.g_ret_sts_success  ;
	    FND_MSG_PUB.initialize;
       END IF;

   END LOOP;
   CLOSE c_sup_list;


   FND_FILE.PUT_LINE(FND_FILE.LOG,'End Suppression List Generation ');

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
	     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
	     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
	     FND_MSG_PUB.Add;
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION in list gen package: AMS_Gen_Sup_List_PVT.Schedule_Suppression_List ');

	     l_msg_count := FND_MSG_PUB.count_msg;
	     FOR i IN 1..FND_MSG_PUB.count_msg LOOP
	        l_msg_data := FND_MSG_PUB.get(i, FND_API.G_FALSE);
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : AMS_Gen_Sup_List_PVT.Schedule_Suppression_List '|| l_msg_data);
	     END LOOP;

	     -- clear message buffer
	    FND_MSG_PUB.initialize;

	WHEN FND_FILE.UTL_FILE_ERROR THEN
	   errbuf:= substr(FND_MESSAGE.get,1,254);
	   retcode:=2;

	WHEN OTHERS THEN
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : AMS_Gen_Sup_List_PVT.Schedule_Suppression_List ');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
	   errbuf:= substr(SQLERRM,1,254);
	   retcode:=SQLCODE;
	    FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
	    FND_MESSAGE.Set_Token('ROW','Error in Suppression List Generation ' || SQLERRM||' '||SQLCODE);


END Schedule_Suppression_List;


END AMS_Gen_Sup_List_PVT;

/
