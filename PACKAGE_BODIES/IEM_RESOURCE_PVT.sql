--------------------------------------------------------
--  DDL for Package Body IEM_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_RESOURCE_PVT" AS
/* $Header: iemvresb.pls 115.2 2002/12/09 21:47:55 liangxia noship $ */

PROCEDURE CREATE_RESOURCE
   (X_RESOURCE_ID            OUT  NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
   )
IS
  l_api_version         NUMBER       := 1.0;
  l_init_msg_list               VARCHAR2(1) :=FND_API.G_TRUE;
  l_commit                      VARCHAR2(1) :=FND_API.G_TRUE;
  l_return_status               VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_catagory            JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE := 'OTHER';
  l_resource_id         JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
  l_resource_number     JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE;
  l_resource_name       JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE :='ORACLE_PREDICTIVE';
  l_source_name         JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE :='ORACLE_PREDICTIVE';
  l_user_name           VARCHAR2(100) :='IEMDUMMYUSER';
  l_count                       NUMBER := 0;
BEGIN
        SELECT count(*) INTO l_count FROM JTF_RS_RESOURCE_EXTNS A,JTF_RS_RESOURCE_EXTNS_TL B
      WHERE A.source_name = l_source_name and B.resource_name = l_resource_name
      and A.resource_id = B.resource_id
        and A.user_name = l_user_name;


        IF l_count = 0 THEN
       -- dbms_output.put_line('Oracle Advanced Outbound Will Create A Resource For Predictive.');
          JTF_RS_RESOURCE_PUB.create_resource
          (P_API_VERSION  => l_api_version,
           P_INIT_MSG_LIST => l_init_msg_list,
           P_COMMIT        => l_commit,
           P_CATEGORY      => l_catagory,
         P_START_DATE_ACTIVE => sysdate,
           X_RETURN_STATUS => l_return_status,
           X_MSG_COUNT     => l_msg_count,
           X_MSG_DATA      => l_msg_data,
           X_RESOURCE_ID   => l_resource_id,
           X_RESOURCE_NUMBER  => l_resource_number,
           P_RESOURCE_NAME    => l_resource_name,
           P_SOURCE_NAME      => l_source_name,
         P_USER_NAME        => l_user_name
          );
      ELSE
         -- dbms_output.put_line('Oracle Advanced Outbound Already Has A Resource For Predictive');

          GET_PRED_RES_ID(l_resource_id);
      END IF;

        X_RESOURCE_ID   := l_resource_id;

       -- dbms_output.put_line('THE RESOURCE ID FOR Predictive = '||X_RESOURCE_ID);

END CREATE_RESOURCE;

PROCEDURE GET_PRED_RES_ID
   (X_RESOURCE_ID            OUT  NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
   )
IS
  l_resource_name       JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE :='ORACLE_PREDICTIVE';
  l_source_name         JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE :='ORACLE_PREDICTIVE';
  l_user_name           VARCHAR2(100) :='IEMDUMMYUSER';
  l_resource_id         JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE := -1;
BEGIN
        SELECT A.resource_id INTO l_resource_id
        FROM JTF_RS_RESOURCE_EXTNS A,JTF_RS_RESOURCE_EXTNS_TL B
        WHERE A.source_name = l_source_name and B.resource_name = l_resource_name
        and A.resource_id = B.resource_id  and A.user_name = l_user_name
        and rownum <2;

        X_RESOURCE_ID   := l_resource_id;
END GET_PRED_RES_ID;

END IEM_RESOURCE_PVT;


/
