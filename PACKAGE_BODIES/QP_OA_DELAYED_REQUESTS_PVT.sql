--------------------------------------------------------
--  DDL for Package Body QP_OA_DELAYED_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_OA_DELAYED_REQUESTS_PVT" AS
/* $Header: QPXVJREB.pls 120.0 2005/06/02 01:15:30 appldev noship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_OA_Delayed_Requests_PVT';

PROCEDURE insert_msg (l_request system.QP_FWK_DELAYED_REQ_REC_OBJECT,
                      l_return_status varchar2) as
 pragma AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO qp_fwk_delayed_requests(
   request_type,
   entity_id,
   entity_code,
   status,
   request_unique_key1,
   request_unique_key2,
   request_unique_key3,
   request_unique_key4,
   request_unique_key5,
   param1,
   param2,
   param3,
   param4,
   param5,
   param6,
   param7,
   param8,
   param9,
   param10,
   param11,
   param12,
   param13,
   param14,
   param15,
   param16,
   param17,
   param18,
   param19,
   param20,
   param21,
   param22,
   param23,
   param24,
   param25,
   long_param1)
  VALUES(
   l_request.request_type ,
   l_request.entity_id,
   l_request.entity_code,
   l_return_status,
   l_request.request_unique_key1,
   l_request.request_unique_key2,
   l_request.request_unique_key3,
   l_request.request_unique_key4,
   l_request.request_unique_key5,
   l_request.param1,
   l_request.param2,
   l_request.param3,
   l_request.param4,
   l_request.param5,
   l_request.param6,
   l_request.param7,
   l_request.param8,
   l_request.param9,
   l_request.param10,
   l_request.param11,
   l_request.param12,
   l_request.param13,
   l_request.param14,
   l_request.param15,
   l_request.param16,
   l_request.param17,
   l_request.param18,
   l_request.param19,
   l_request.param20,
   l_request.param21,
   l_request.param22,
   l_request.param23,
   l_request.param24,
   l_request.param25,
   l_request.long_param1);

    COMMIT;

END insert_msg;

PROCEDURE Execute(requestTbl IN system.QP_FWK_DELAYED_REQ_TAB_OBJECT,
                  x_error_request_type OUT NOCOPY VARCHAR2,
                  x_error_entity_id  OUT NOCOPY NUMBER,
                  x_error_entity_code OUT NOCOPY VARCHAR2,
                  x_error_type    OUT NOCOPY VARCHAR2,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_return_status_text OUT NOCOPY VARCHAR2) is

 l_request       system.QP_FWK_DELAYED_REQ_REC_OBJECT;
 l_return_status VARCHAR2(30);

BEGIN

 SAVEPOINT delayedRequestSavePoint;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 FOR i IN 1 .. requestTbl.COUNT
 LOOP

  l_request := requestTbl(i);

  QP_Delayed_Requests_PVT.Log_Request(
   l_request.entity_code,
   l_request.entity_id,
   l_request.requesting_entity_code,
   l_request.requesting_entity_id,
   l_request.request_type,
   l_request.request_unique_key1,
   l_request.request_unique_key2,
   l_request.request_unique_key3,
   l_request.request_unique_key4,
   l_request.request_unique_key5,
   l_request.param1,
   l_request.param2,
   l_request.param3,
   l_request.param4,
   l_request.param5,
   l_request.param6,
   l_request.param7,
   l_request.param8,
   l_request.param9,
   l_request.param10,
   l_request.param11,
   l_request.param12,
   l_request.param13,
   l_request.param14,
   l_request.param15,
   l_request.param16,
   l_request.param17,
   l_request.param18,
   l_request.param19,
   l_request.param20,
   l_request.param21,
   l_request.param22,
   l_request.param23,
   l_request.param24,
   l_request.param25,
   l_request.long_param1,
   l_return_status);

   IF (l_return_status IN (FND_API.G_RET_STS_UNEXP_ERROR,FND_API.G_RET_STS_ERROR)) THEN
    x_error_type := 'LOGGING';
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


 END LOOP;

 FOR i in 1 .. requestTbl.COUNT
 LOOP

  l_request := requestTbl(i);

   QP_DELAYED_REQUESTS_PVT.Process_Request_For_ReqType(l_request.request_type,FND_API.G_TRUE,l_return_status);

   insert_msg(l_request,l_return_status);

   /*insert into del_request_test values(l_request.request_type,l_request.entity_id,
                                         l_request.entity_code, l_return_status);*/

   IF (l_return_status IN (FND_API.G_RET_STS_UNEXP_ERROR,FND_API.G_RET_STS_ERROR)) THEN
    x_error_type := 'DELAYED_REQUEST';
    x_error_request_type := l_request.request_type;
    x_error_entity_id := l_request.entity_id;
    x_error_entity_code := l_request.entity_code;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


 END LOOP;

 oe_msg_pub.initialize;
 QP_Delayed_Requests_PVT.Clear_Request(l_return_status);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delayedRequestSavePoint;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_return_status_text := oe_msg_pub.get(1,'F');
        oe_msg_pub.initialize;
        QP_Delayed_Requests_PVT.Clear_Request(l_return_status);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delayedRequestSavePoint;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_return_status_text := oe_msg_pub.get(1,'F');
        oe_msg_pub.initialize;
        QP_Delayed_Requests_PVT.Clear_Request(l_return_status);

   WHEN OTHERS THEN
      ROLLBACK TO delayedRequestSavePoint;
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'LOGREQUEST');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := oe_msg_pub.get(1,'F');
      oe_msg_pub.initialize;
      QP_Delayed_Requests_PVT.Clear_Request(l_return_status);

END;


END QP_OA_Delayed_Requests_PVT;

/
