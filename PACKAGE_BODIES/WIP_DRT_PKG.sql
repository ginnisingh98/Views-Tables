--------------------------------------------------------
--  DDL for Package Body WIP_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DRT_PKG" AS
  /* $Header: wipdrconb.pls 120.0.12010000.2 2018/04/02 04:09:29 sisankar noship $ */

  procedure WIP_HR_DRC
    (person_id     IN NUMBER
    ,result_tbl    OUT NOCOPY PER_DRT_PKG.result_tbl_type
    )
  IS
    l_count Number := 0;
  BEGIN
    PER_DRT_PKG.write_log('In WIP_DRT_PKG.WIP_HR_DRC Pers : '||person_id, '10');

    select count(1)
    into l_count
    from wip_resource_actual_times
    where EMPLOYEE_ID = person_id
    and (status_type <> 2 or end_date is null);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'HR'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENDING_TIME_ENTRY'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1)
    into l_count
    from wip_cost_txn_interface
    where EMPLOYEE_ID = person_id;

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'HR'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENDING_RES_INST'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    PER_DRT_PKG.write_log('Returning from WIP_DRT_PKG.WIP_HR_DRC ', '20');
  EXCEPTION
    WHEN OTHERS THEN
      PER_DRT_PKG.write_log('Exception WIP_DRT_PKG.WIP_HR_DRC '||sqlerrm(sqlcode), '30');
  END WIP_HR_DRC;

  procedure WIP_FND_DRC
    (person_id     IN NUMBER
    ,result_tbl    OUT NOCOPY PER_DRT_PKG.result_tbl_type
    )
  IS
    l_count Number := 0;
    l_username VARCHAR2(500);
  BEGIN
    PER_DRT_PKG.write_log('In WIP_DRT_PKG.WIP_FND_DRC Pers : '||person_id, '10');

    begin
      select user_name into l_username
      from fnd_user where user_id = person_id;
    exception
      when others then
        null;
    end;

    if l_username is null then
      return;
    end if;

    select count(1) into l_count
    from WIP_JOB_SCHEDULE_INTERFACE
    where (LAST_UPDATED_BY_NAME = l_username or CREATED_BY_NAME = l_username);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WJSI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1) into l_count
    from WIP_COST_TXN_INTERFACE
    where (LAST_UPDATED_BY_NAME = l_username or CREATED_BY_NAME = l_username);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WCTI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1) into l_count
    from WIP_MOVE_TXN_INTERFACE
    where (LAST_UPDATED_BY_NAME = l_username or CREATED_BY_NAME = l_username);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WMTI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1) into l_count
    from WIP_SERIAL_MOVE_INTERFACE ser,
         WIP_MOVE_TXN_INTERFACE move
    where (ser.LAST_UPDATED_BY_NAME = l_username or ser.CREATED_BY_NAME = l_username)
    and ser.TRANSACTION_ID = move.TRANSACTION_ID;

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WSMI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1) into l_count
    from WSM_LOT_MOVE_TXN_INTERFACE
    where (LAST_UPDATED_BY_NAME = l_username or CREATED_BY_NAME = l_username);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WLMTI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1) into l_count
    from WSM_LOT_JOB_INTERFACE
    where (LAST_UPDATED_BY_NAME = l_username or CREATED_BY_NAME = l_username);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WLJI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    select count(1) into l_count
    from WSM_LOT_JOB_DTL_INTERFACE
    where (LAST_UPDATED_BY_NAME = l_username or CREATED_BY_NAME = l_username);

    if l_count >0 then
      PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'FND'
               , status      => 'E'
               , msgcode     => 'WIP_DRT_PENING_INTF_WLJDI'
               , msgaplid    => 706
               , result_tbl  => result_tbl);
    end if;

    PER_DRT_PKG.write_log('Returning from WIP_DRT_PKG.WIP_FND_DRC ', '20');
  EXCEPTION
    WHEN OTHERS THEN
      PER_DRT_PKG.write_log('Exception WIP_DRT_PKG.WIP_FND_DRC '||sqlerrm(sqlcode), '30');
  END WIP_FND_DRC;

END WIP_DRT_PKG;

/
