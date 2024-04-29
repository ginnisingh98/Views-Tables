--------------------------------------------------------
--  DDL for Package Body HZ_PARAM_TAB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARAM_TAB_PKG" as
/*$Header: ARHPRMTB.pls 120.1 2005/06/16 21:14:42 jhuang noship $ */

---------------------------------------------------------------------------------------------------------------------------------------
-- In TCA API V1 FND_API.G_MISS_<type> represent a Null Value => Test of Null value is based on FND_API.G_MISS_<type> before insertions
-- In TCA API V2 NULL represent a Null Value                  => Test of Null value is based on NULL before insertions
--                                                            if value = G_MISS_<TYPE> then insert NULL end if;
---------------------------------------------------------------------------------------------------------------------------------------
-- This is the V1 version
---------------------------------------------------------------------------------------------------------------------------------------
/**************************
 **** Insert statement ****
 **************************/
 PROCEDURE insert_row (
  x_item_key      in varchar2,
  x_param_name    in varchar2,
  x_param_value   in varchar2,
  x_param_indicator  in varchar2
 ) is
  l_param_value varchar2(4000) := x_param_value;
 begin
  l_param_value := trim(x_param_value);
  IF l_param_value IS NOT NULL  THEN
     IF l_param_value = FND_API.G_MISS_CHAR  THEN
        l_param_value := NULL;
     END IF;
     insert into hz_param_tab  (
       item_key      ,
       param_name    ,
       param_char    ,
       param_indicator ) values (
       x_item_key      ,
       x_param_name    ,
       l_param_value   ,
       x_param_indicator    );
   END IF;
 END;

 PROCEDURE insert_row (
  x_item_key      in varchar2,
  x_param_name    in varchar2,
  x_param_value   in number,
  x_param_indicator  in varchar2
 ) is
  l_param_value number := x_param_value;
 BEGIN
  IF l_param_value IS NOT NULL  THEN
     IF l_param_value = FND_API.G_MISS_NUM  THEN
        l_param_value := NULL;
     END IF;
     insert into hz_param_tab  (
       item_key      ,
       param_name    ,
       param_num     ,
       param_indicator ) values (
       x_item_key      ,
       x_param_name    ,
       l_param_value   ,
       x_param_indicator    );
   END IF;
 END;

 PROCEDURE insert_row (
  x_item_key      in varchar2,
  x_param_name    in varchar2,
  x_param_value   in date,
  x_param_indicator  in varchar2
 ) is
  l_param_value date := x_param_value;
 begin
  IF l_param_value IS NOT NULL  THEN
     IF l_param_value = FND_API.G_MISS_DATE  THEN
        l_param_value := NULL;
     END IF;
     insert into hz_param_tab  (
       item_key      ,
       param_name    ,
       param_date    ,
       param_indicator ) values (
       x_item_key      ,
       x_param_name    ,
       l_param_value   ,
       x_param_indicator    );
   END IF;
 end;



 procedure delete_row (
  x_item_key      in varchar2
 ) is
 begin
  delete from hz_param_tab
  where item_key = x_item_key;
 end;
end;

/
