--------------------------------------------------------
--  DDL for Package Body GMS_AWARD_MANAGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARD_MANAGER_PKG" as
-- $Header: gmsawamb.pls 115.3 2002/08/01 09:42:18 gnema ship $

PROCEDURE insert_award_manager_id
(
 x_AWARD_ID in number ,
 x_qk_award_manager_id in number,
 x_start_date_active in date
)
IS
personnel_id number;
x_last_update_date date;
x_last_updated_by number;
x_last_update_login number;
x_creation_date date;
x_created_by number;
BEGIN
x_last_update_date := sysdate;
x_last_updated_by := fnd_global.user_id;
x_last_update_login := fnd_global.user_id;
x_creation_date := sysdate;
x_created_by := fnd_global.user_id;
select gms_personnel_s.nextval
into personnel_id
from dual;
insert into gms_personnel
(AWARD_ID   ,
PERSON_ID    ,
AWARD_ROLE    ,
START_DATE_ACTIVE,
LAST_UPDATE_DATE       ,
LAST_UPDATED_BY        ,
CREATION_DATE          ,
CREATED_BY         ,
LAST_UPDATE_LOGIN   ,
PERSONNEL_ID )
values
(
 x_AWARD_ID,
 x_qk_award_manager_id,
 'AM',
 x_start_date_active,
 x_last_update_date ,
 x_last_updated_by,
 x_creation_date ,
 x_created_by ,
 x_last_update_login ,
 personnel_id
);
END;
END GMS_AWARD_MANAGER_PKG;

/
