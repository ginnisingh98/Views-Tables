--------------------------------------------------------
--  DDL for Package Body INVIDIT4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVIDIT4" as
/* $Header: INVIDI4B.pls 115.0 99/07/16 10:54:12 porting ship $ */

FUNCTION get_struct_num_flex
   ( appl_name  in varchar2,
     flex_code  in varchar2,
     struct_num in number,
     cc_id      in number
   ) return BOOLEAN is
 torf boolean;
 sta_date date;
 end_date date;
 v_segs varchar2(2000);
begin
 torf :=
/*
  fnd_flex_server_api.validate_ccid
*/
  fnd_flex_keyval.validate_ccid
  ( appl_name,
    flex_code,
    struct_num,
    cc_id,
    'ALL',
    null,
    null,
    'ENFORCE',
    null,
    null,
    null,
    null
  );

  if torf then
    /*  torf := fnd_flex_server_api.enabled_flag;  */
    torf := fnd_flex_keyval.enabled_flag;
      if torf then
	/*  sta_date := fnd_flex_server_api.start_date;  */
        sta_date := fnd_flex_keyval.start_date;
	/*  end_date := fnd_flex_server_api.end_date;  */
        end_date := fnd_flex_keyval.end_date;
        if nvl(sta_date,sysdate-1) < sysdate
           and nvl(end_date,sysdate+1) > sysdate
        then
           torf := true;
        else
           torf := false;
        end if;
      end if;
   end if;

 return (torf);

end get_struct_num_flex;




FUNCTION get_data_set_flex
  ( appl_name  in varchar2,
    flex_code  in varchar2,
    data_set   in number,
    cc_id      in number
  ) return BOOLEAN is
 torf boolean;
 sta_date date;
 end_date date;
begin
  torf :=
/*
  fnd_flex_server_api.validate_ccid
*/
  fnd_flex_keyval.validate_ccid
  ( appl_name,
    flex_code,
    101,
    cc_id,
    'ALL',
    data_set,
    null,
    'ENFORCE',
    null,
    null,
    null,
    null
  );

  if torf then
   /*  torf := fnd_flex_server_api.enabled_flag;  */
   torf := fnd_flex_keyval.enabled_flag;
    if torf then
      /*  sta_date := fnd_flex_server_api.start_date;  */
      sta_date := fnd_flex_keyval.start_date;
      /*  end_date := fnd_flex_server_api.end_date;  */
      end_date := fnd_flex_keyval.end_date;
      if nvl(sta_date,sysdate-1) < sysdate
         and nvl(end_date,sysdate+1) > sysdate
      then
        torf := true;
      else
        torf := false;
      end if;
    else
      torf := false;
    end if;
  end if;

 return (torf);

end get_data_set_flex;



END INVIDIT4;

/
