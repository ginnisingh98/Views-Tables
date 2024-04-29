--------------------------------------------------------
--  DDL for Package Body FND_RT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RT_REQUEST" AS
/* $Header: AFRTREQB.pls 115.2 99/07/16 23:27:25 porting sh $ */

PROCEDURE get_test_id(testid IN OUT INTEGER) IS
BEGIN
     SELECT FND_RT_REQUESTS_S.nextval into testid FROM DUAL;
END get_test_id;

PROCEDURE log_request(testid IN INTEGER, requestid IN INTEGER) IS
BEGIN
    INSERT INTO FND_RT_REQUESTS VALUES (testid, requestid);
END log_request;

PROCEDURE search_requests(testid IN INTEGER, timeout IN INTEGER) IS

    cursor children(parent_id number) is
    select request_id
    from fnd_concurrent_requests
    where parent_request_id <> -1
    and   parent_request_id is not null
    start with request_id = parent_id
    connect by prior request_id = parent_request_id;

    cursor parents is
    select request_id
    from   fnd_rt_requests
    where  test_id = testid;

    cnt number;
    totalsleep integer;
BEGIN


    for parent in parents loop

      /* Wait until there is no more child running or pending under */
      /* this parent */
      cnt := 1;
      totalsleep := 0;
      while ((cnt > 0) and (totalsleep < timeout))loop
        /* the following sleep function is in second */
        dbms_lock.sleep(60);
        select count(*) into cnt
        from fnd_concurrent_requests
        where phase_code in ('P', 'R')
        start with request_id = parent.request_id
        connect by prior request_id = parent_request_id;
        totalsleep := totalsleep + 1;
      end loop;

      /* Now is time to fetch all the children for this parent */
      for child in children(parent.request_id) loop
        INSERT INTO FND_RT_REQUESTS VALUES (testid, child.request_id);
      end loop;

    end loop;

END search_requests;


PROCEDURE get_request(testid IN INTEGER, requestid OUT INTEGER) IS
    reqid integer;
BEGIN

    SELECT REQUEST_ID into reqid
    FROM FND_RT_REQUESTS
    WHERE TEST_ID = testid AND ROWNUM=1;

    DELETE FROM fnd_rt_requests
    WHERE TEST_ID = testid
    AND REQUEST_ID = reqid;

    requestid := reqid;

END get_request;
END fnd_rt_request;

/
