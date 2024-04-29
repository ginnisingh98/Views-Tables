--------------------------------------------------------
--  DDL for Package Body ASF_REC_VIEW_HIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_REC_VIEW_HIS_PUB" AS
/* $Header: asffrvhb.pls 115.2 2002/03/25 17:16:57 pkm ship  $ */

  procedure Update_Entry(p_object_code  IN  varchar2,
                         p_object_id    IN  number,
                         x_return_status OUT varchar2,
                         x_error_message OUT varchar2) IS
    l_exist   number;
    l_date    date;
    g_user_id number;
  BEGIN
    g_user_id := FND_GLOBAL.USER_ID;
    l_date := SYSDATE;

    select count(1) into l_exist
      from ASF_RECORD_VIEW_HISTORY
     where OBJECT_CODE = p_object_code
       and OBJECT_ID = p_object_id
       and LAST_UPDATED_BY = g_user_id;

    if (l_exist > 0) then
      update ASF_RECORD_VIEW_HISTORY
         set LAST_UPDATE_DATE = l_date
       where OBJECT_CODE = p_object_code
         and OBJECT_ID = p_object_id
         and LAST_UPDATED_BY = g_user_id;
    else
      select count(1) into l_exist
        from JTF_OBJECTS_B
       where OBJECT_CODE = p_object_code
         and nvl(START_DATE_ACTIVE, l_date) <= l_date
         and nvl(END_DATE_ACTIVE, l_date) >= l_date;
      if (l_exist > 0) then
        begin
          insert into ASF_RECORD_VIEW_HISTORY (
             OBJECT_CODE,
             OBJECT_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
          values (
             p_object_code,
             p_object_id,
             g_user_id,
             l_date,
             g_user_id,
             l_date);
        exception
          when DUP_VAL_ON_INDEX then null;
        end;

      else
        x_return_status := 'E';
        x_error_message := 'Invalid OBJECT_CODE ' || p_object_code;
        return;
      end if;
    end if;

    x_return_status := 'S';
    x_error_message := NULL;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      x_error_message := 'Unexpected error.  Please verify ASF_RECORD_VIEW_HISTORY table.';
      RETURN;
  END Update_Entry;

end ASF_REC_VIEW_HIS_PUB;

/
