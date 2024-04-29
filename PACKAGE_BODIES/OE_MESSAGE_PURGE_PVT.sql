--------------------------------------------------------
--  DDL for Package Body OE_MESSAGE_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_MESSAGE_PURGE_PVT" AS
/* $Header: OEXMPRGB.pls 120.4 2005/11/09 23:30:12 ssurapan noship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    OE_MESSAGE_PURGE_PVT
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--
--  End of Comments
------------------------------------------------------------------ */

/* -----------------------------------------------------------
   Procedure: Purge
 ----------------------------------------------------------- */
PROCEDURE PURGE(
errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER

  ,p_commit IN NUMBER DEFAULT 500
  ,p_start_date IN VARCHAR2
  ,p_end_date IN VARCHAR2
  ,p_message_source IN VARCHAR2
  ,p_customer_id_name IN NUMBER
  ,p_customer_id_number IN NUMBER
  ,p_order_type_id IN NUMBER
  ,p_start_order_num IN NUMBER
  ,p_end_order_num IN NUMBER
  ,p_message_status_code IN VARCHAR2 DEFAULT NULL) IS

  l_start DATE := null;
  l_end DATE := null;

  CURSOR c_messages IS
    SELECT m.transaction_id,
           m.rowid,
           o.order_number,
           o.order_type_id,
           o.sold_to_org_id,
           m.message_status_code
    FROM   oe_processing_msgs m, oe_order_headers_all o
    WHERE  m.header_id = o.header_id (+)
    AND    NVL(m.message_source_code, 'NULL') =
			NVL(p_message_source, NVL(m.message_source_code, 'NULL'))
    AND    TRUNC(m.creation_date) BETWEEN NVL(l_start, TRUNC(m.creation_date))
                                AND NVL(l_end, TRUNC(m.creation_date));

  l_cnt NUMBER := 0;
  l_commit NUMBER;
  l_customer NUMBER := NULL;
  l_debug_file VARCHAR2(500);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --Bug#4220950
   errbuf  := '';
   retcode := 0;

  FND_FILE.Put_Line(FND_FILE.OUTPUT,'Order Management Message Purge Concurrent Program');
  FND_FILE.Put_Line(FND_FILE.OUTPUT, '');
  l_debug_file := OE_DEBUG_PUB.set_debug_mode ('FILE');
  FND_FILE.Put_Line(FND_FILE.OUTPUT,'Debug File: ' || l_debug_file);
  FND_FILE.Put_Line(FND_FILE.OUTPUT, '');

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTER MESSAGE PURGE' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_COMMIT:'||TO_CHAR ( P_COMMIT ) ||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_START_DATE:'||P_START_DATE||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_END_DATE:'||P_END_DATE||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_MESSAGE_SOURCE:'||P_MESSAGE_SOURCE||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_CUSTOMER_ID_NAME:'||P_CUSTOMER_ID_NAME||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_CUSTOMER_ID_NUMBER:'||P_CUSTOMER_ID_NUMBER||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_ORDER_TYPE_ID:'||TO_CHAR ( P_ORDER_TYPE_ID ) ||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_START_ORDER_NUM:'||TO_CHAR ( P_START_ORDER_NUM ) ||'.' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_END_ORDER_NUM:'||TO_CHAR ( P_END_ORDER_NUM ) ||'.' ) ;
  END IF;

  l_start := TRUNC(TO_DATE(p_start_date,'YYYY/MM/DD HH24:MI:SS'));
  l_end := TRUNC(TO_DATE(p_end_date,'YYYY/MM/DD HH24:MI:SS'));
  IF p_commit > 0 THEN
    l_commit := p_commit;
  ELSE l_commit := NULL;
  END IF;

  FOR c_msg IN c_messages LOOP
    IF (p_customer_id_name IS NULL OR p_customer_id_name = c_msg.sold_to_org_id) AND
       (p_customer_id_number IS NULL OR p_customer_id_number = c_msg.sold_to_org_id) AND
       (p_order_type_id IS NULL OR p_order_type_id = c_msg.order_type_id) AND
       (p_start_order_num IS NULL OR p_start_order_num <= c_msg.order_number) AND
       (p_end_order_num IS NULL OR p_end_order_num >= c_msg.order_number) AND
       (p_message_status_code IS NULL OR p_message_status_code = nvl(c_msg.message_status_code,'OPEN')) THEN
      IF l_cnt >= l_commit THEN
	   COMMIT;
	   l_cnt := 0;
      END IF;
      DELETE oe_processing_msgs_tl
      WHERE  transaction_id = c_msg.transaction_id;
      DELETE oe_processing_msgs
      WHERE ROWID = c_msg.rowid;
      l_cnt := l_cnt + 1;
    END IF;
  END LOOP;

  COMMIT;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT MESSAGE PURGE' ) ;
  END IF;
  FND_FILE.Put_Line(FND_FILE.OUTPUT, '');
  FND_FILE.Put_Line(FND_FILE.OUTPUT,'End of Message Purge Concurrent Program');


END Purge;

END OE_MESSAGE_PURGE_PVT;

/
