--------------------------------------------------------
--  DDL for Package Body RCV_ROI_PARALLEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ROI_PARALLEL" AS
/* $Header: RCVPGRPB.pls 120.0.12010000.2 2010/01/25 22:57:55 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790
PROCEDURE spawn_process(p_num_of_groups IN NUMBER,
                        p_req_ids OUT NOCOPY RCV_ROI_PARALLEL.reqid_list) IS
  x_progress NUMBER;
/*
  cursor c_header is
      select header_interface_id from rcv_headers_interface
      where NVL(asn_type,'STD') in ('ASN','ASBN','STD')
      and   processing_status_code in ('PENDING')
      and   nvl(validation_flag,'N') = 'Y'
      for update of group_id nowait;


  TYPE interface_numtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
*/

  TYPE group_id_pool IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/*
  v_h_int_id INTERFACE_NUMTYPE;

  v_gid_table INTERFACE_NUMTYPE;

  v_id_table  INTERFACE_NUMTYPE;
*/

  v_group_id GROUP_ID_POOL;

/*
  v_cur_rec NUMBER;

  v_num_per_fetch NUMBER := 5000;
*/


  v_req_id NUMBER;

BEGIN
  IF (g_asn_debug = 'Y') THEN
     ASN_DEBUG.PUT_LINE('START SPAWNING PROCESS');
  END IF;

/*
  OPEN c_header;


  FOR i IN 1..p_num_of_groups LOOP
    SELECT RCV_INTERFACE_GROUPS_S.NEXTVAL
    INTO   v_group_id(i)
    FROM   dual;
  END LOOP;

  v_cur_rec := 0;

  IF (g_asn_debug = 'Y') THEN
     ASN_DEBUG.PUT_LINE('Before Looping');
  END IF;

  LOOP
    FETCH c_header BULK COLLECT INTO v_h_int_id LIMIT v_num_per_fetch;

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.PUT_LINE('Number of rows fetched: ' || v_h_int_id.COUNT);
    END IF;

    IF (v_h_int_id.COUNT = 0) THEN
      EXIT;
    END IF;

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.PUT_LINE('Still in...');
    END IF;

    FOR j IN 1..v_h_int_id.COUNT LOOP
      v_id_table(v_cur_rec + j) := v_h_int_id(j);
    END LOOP;

    v_cur_rec := v_cur_rec + v_h_int_id.COUNT;

    v_h_int_id.DELETE;

    EXIT WHEN c_header%NOTFOUND;
  END LOOP;

  CLOSE c_header;

  FOR i IN 1..v_id_table.COUNT LOOP
    v_gid_table(i) := v_group_id(CEIL(i/v_id_table.COUNT*p_num_of_groups));
  END LOOP;

  IF (g_asn_debug = 'Y') THEN
     ASN_DEBUG.PUT_LINE('Before Bulk Update of RCV_HEADERS_INTERFACE');
  END IF;

  FORALL k IN 1..v_id_table.COUNT
    UPDATE rcv_headers_interface
    SET    group_id = v_gid_table(k)
    WHERE  header_interface_id = v_id_table(k);

  IF (g_asn_debug = 'Y') THEN
     ASN_DEBUG.PUT_LINE('Before Bulk Update of RCV_TRANSACTIONS_INTERFACE');
  END IF;

  FORALL k IN 1..v_id_table.COUNT
    UPDATE rcv_transactions_interface
    SET    group_id = v_gid_table(k)
    WHERE  header_interface_id = v_id_table(k);

  COMMIT;
*/

  SELECT distinct group_id
  BULK COLLECT INTO   v_group_id
  FROM   RCV_HEADERS_INTERFACE
  WHERE  NVL(asn_type,'STD') in ('ASN','ASBN','STD')
  AND    processing_status_code in ('PENDING')
  AND    nvl(validation_flag,'N') = 'Y';

  IF (g_asn_debug = 'Y') THEN
     ASN_DEBUG.PUT_LINE('Number of groups: ' || v_group_id.COUNT);
  END IF;

  FOR k IN 1..v_group_id.COUNT LOOP
      v_req_id :=
		fnd_request.submit_request('PO',
		'RVCTP',
		null,
		null,
		false,
		'BATCH',
                v_group_id(k),
		chr(0),
		NULL,
		NULL,
		NULL,
		NULL,
		NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

     IF (g_asn_debug = 'Y') THEN
        ASN_DEBUG.PUT_LINE('Spawned worker ' || k);
     END IF;

     p_req_ids(k) := v_req_id;
   END LOOP;
END spawn_process;
END RCV_ROI_PARALLEL;

/
