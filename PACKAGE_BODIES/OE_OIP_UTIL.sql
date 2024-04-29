--------------------------------------------------------
--  DDL for Package Body OE_OIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OIP_UTIL" As
/* $Header: OEXUOIPB.pls 120.0 2005/05/31 23:51:51 appldev noship $ */

PROCEDURE print_msg( msg in varchar2)
is
Begin

  if(OE_OIP_UTIL.debug = 1) Then
 /* Comment because of GSCC standard */
 /*	dbms_output.put_line(msg); */
	 null;
  end if;

end;

PROCEDURE set_Debug (debug_flag in number)
is
Begin
	OE_OIP_UTIL.debug := debug_flag;
End;

PROCEDURE DELETE_OIP_AK_PAGE
(   p_region_page                   IN VARCHAR2
, p_region_style                   IN VARCHAR2
) is

cursor ak_region_pages (x_region_page in varchar2,
                        x_region_style in varchar2) is
select region_code
 from AK_REGIONS
where REGION_APPLICATION_ID = 660
  and REGION_CODE = x_region_page
  and REGION_STYLE =x_region_style;

cursor ak_region_lov_rel (x_region_name in varchar2,
                          x_attribute_code in varchar2) is
select REGION_APPLICATION_ID,
       REGION_CODE,
       ATTRIBUTE_APPLICATION_ID,
       ATTRIBUTE_CODE,
       LOV_REGION_APPL_ID,
       LOV_REGION_CODE,
       LOV_ATTRIBUTE_APPL_ID,
       LOV_ATTRIBUTE_CODE,
       BASE_ATTRIBUTE_APPL_ID,
       BASE_ATTRIBUTE_CODE,
       DIRECTION_FLAG
 from AK_REGION_LOV_RELATIONS
where REGION_APPLICATION_ID = 660
  and REGION_CODE = x_region_name
  and ATTRIBUTE_CODE = x_attribute_code;

cursor ak_region_items (x_region_name in varchar2) is
select level b,
       a.region_application_id b2,
       a.region_code b3,
       attribute_application_id c1,
       a.attribute_code c
from ak_region_items a
where  a.region_application_id =660
start with a.region_code = x_region_name
connect by a.region_code = PRIOR a.nested_region_code
order by level desc;

 p_region_appl_id number;
 p_attr_appl_id number;
 p_attribute_code varchar2(100);
 p_region_code varchar2(100);
 p_region_page_1 varchar2(100);
 p_level number;
 mycount number;
 mycount1 number;
 mycount2 number;
 p_style number;
 p_style_name varchar2(20);
 v_region_page varchar2(100);
 v_region_style varchar2(100);

   p_attribute_code_LOV varchar2(100);
   p_region_code_LOV varchar2(100);
   p_REGION_APPLICATION_ID  NUMBER;
   p_ATTRIBUTE_APPLICATION_ID  NUMBER;
   p_LOV_REGION_APPL_ID  NUMBER;
   p_LOV_REGION_CODE  varchar2(100);
   p_LOV_ATTRIBUTE_APPL_ID  NUMBER;
   p_LOV_ATTRIBUTE_CODE  varchar2(100);
   p_BASE_ATTRIBUTE_APPL_ID  NUMBER;
   p_BASE_ATTRIBUTE_CODE  varchar2(100);
   p_DIRECTION_FLAG  VARCHAR(20);
   p_ind number;

   error_exception exception ;

BEGIN

  v_region_style := p_region_style;
  v_region_page := p_region_page;
  print_msg('region style ' || p_region_style);
  print_msg('region page ' || p_region_page);

/* check if the input region name with input region style is matched */

  OPEN ak_region_pages (v_region_page, v_region_style);
   FETCH ak_region_pages into p_region_page_1;
   if ak_region_pages%NOTFOUND then
     print_msg('WARNING: NO SUCH REGION EXISTS WITH THIS STYLE EXIST');
/*
     raise error_exception;
*/
   end if;
   print_msg('Start getting AK region_items  for '|| p_region_page_1);

/*                                              */
/* loop thru each region item in a given region */
/*                                              */

   OPEN ak_region_items (p_region_page_1);
   LOOP
        FETCH ak_region_items INTO p_level, p_region_appl_id, p_region_code,
          p_attr_appl_id, p_attribute_code;

        EXIT WHEN ak_region_items%NOTFOUND;

        select count(*)
          into mycount
         from AK_REGION_LOV_RELATIONS
        where REGION_APPLICATION_ID = 660
        and REGION_CODE = p_region_code
        and ATTRIBUTE_CODE = p_attribute_code;

        if (mycount = 0) then
          print_msg('NO AK LOV relationship for region' || p_region_code || '.' || p_attribute_code);
        else
        print_msg('Start getting AK LOV relationship for region' || p_region_code || '.' || p_attribute_code);

/*                                                                       */
/* for each region item, loop through its lov rel. Delete its lov rel    */
/* before we delete region item                                          */
/*                                                                       */

        OPEN ak_region_lov_rel (p_region_code, p_attribute_code);
        LOOP
           FETCH ak_region_lov_rel INTO
             P_REGION_APPLICATION_ID,
             P_REGION_CODE_LOV,
             P_ATTRIBUTE_APPLICATION_ID,
             P_ATTRIBUTE_CODE_LOV ,
             P_LOV_REGION_APPL_ID,
             P_LOV_REGION_CODE,
             P_LOV_ATTRIBUTE_APPL_ID,
             P_LOV_ATTRIBUTE_CODE,
             P_BASE_ATTRIBUTE_APPL_ID,
             P_BASE_ATTRIBUTE_CODE,
             P_DIRECTION_FLAG;

           EXIT WHEN ak_region_lov_rel%NOTFOUND;

           print_msg('************************');
           print_msg('REGION_CODE = ' ||  P_REGION_CODE_LOV);
           print_msg('ATTRIBUTE_CODE = ' ||  P_ATTRIBUTE_CODE_LOV);
           print_msg('LOV_REGION_CODE = ' ||  P_LOV_REGION_CODE);
           print_msg('BASE_ATTRIBUTE_CODE = ' ||  P_BASE_ATTRIBUTE_CODE );
           print_msg('DIRECTION_FLAG = ' ||  P_DIRECTION_FLAG || ' will be deteled');


           AK_LOV_RELATIONS_PKG.DELETE_ROW (
             X_REGION_APPLICATION_ID => P_REGION_APPLICATION_ID,
             X_REGION_CODE => P_REGION_CODE,
             X_ATTRIBUTE_APPLICATION_ID => P_ATTRIBUTE_APPLICATION_ID,
             X_ATTRIBUTE_CODE => P_ATTRIBUTE_CODE ,
             X_LOV_REGION_APPL_ID => P_LOV_REGION_APPL_ID,
             X_LOV_REGION_CODE => P_LOV_REGION_CODE,
             X_LOV_ATTRIBUTE_APPL_ID => P_LOV_ATTRIBUTE_APPL_ID,
             X_LOV_ATTRIBUTE_CODE => P_LOV_ATTRIBUTE_CODE,
             X_BASE_ATTRIBUTE_APPL_ID => P_BASE_ATTRIBUTE_APPL_ID,
             X_BASE_ATTRIBUTE_CODE =>P_BASE_ATTRIBUTE_CODE,
             X_DIRECTION_FLAG => P_DIRECTION_FLAG);
           print_msg('REGION_CODE = ' ||  P_REGION_CODE_LOV);
           print_msg('ATTRIBUTE_CODE = ' ||  P_ATTRIBUTE_CODE_LOV);
           print_msg('LOV_REGION_CODE = ' ||  P_LOV_REGION_CODE);
           print_msg('BASE_ATTRIBUTE_CODE = ' ||  P_BASE_ATTRIBUTE_CODE );
           print_msg('DIRECTION_FLAG = ' ||  P_DIRECTION_FLAG || ' will be deteled');

        END LOOP;
        CLOSE ak_region_lov_rel;
        end if;
        print_msg('=================================================================');
        print_msg('REGION_ITEM = ' ||  p_region_code || '.' || p_attribute_code || ' will be deleted');

        select count(*)
          into mycount1
         from AK_REGION_ITEMS
        where REGION_APPLICATION_ID = 660
        and REGION_CODE = p_region_code
        and ATTRIBUTE_CODE = p_attribute_code;

        if (mycount1 = 0) then
          print_msg('NO such AK item ' || p_region_code || '.' || p_attribute_code);

        else

/* real code to delete ak region items */

        AK_REGION_ITEMS_PKG.DELETE_ROW(
          X_REGION_APPLICATION_ID => p_region_appl_id,
          X_REGION_CODE => p_region_code,
          X_ATTRIBUTE_APPLICATION_ID => p_attr_appl_id,
          X_ATTRIBUTE_CODE => p_attribute_code);
        print_msg('REGION_ITEM = ' ||  p_region_code || '.' || p_attribute_code || ' has been deleted');

        end if;
   END LOOP;
   print_msg('#################################################################');
   CLOSE ak_region_items;

        print_msg('=================================================================');
        print_msg('REGION:' ||  p_region_page_1 || '(' ||
        p_style_name || ')' || ' will be deleted');

        select count(*)
          into mycount2
         from AK_REGIONS
        where REGION_APPLICATION_ID = 660
        and REGION_CODE = p_region_page_1;

        if (mycount2 = 0) then
          print_msg('NO such AK region ' || p_region_code );
        else
/* real code to delete regions */
          AK_REGIONS_PKG.DELETE_ROW(
          X_REGION_APPLICATION_ID =>660,
          X_REGION_CODE => p_region_page_1);
        print_msg('REGION:' ||  p_region_page_1 || '(' ||
        p_style_name || ')' || ' has be deleted');
   print_msg('#################################################################');
        end if;

  print_msg('ak  entries are deleted');
 exception
      when error_exception then
      raise_application_error(-20001, sqlerrm);

      when others then
      raise_application_error(-20001, sqlerrm);

END DELETE_OIP_AK_PAGE;

END OE_OIP_UTIL;


/
