--------------------------------------------------------
--  DDL for Package Body BOMPLDCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPLDCI" as
/* $Header: BOMLDCIB.pls 115.7 99/09/16 16:00:42 porting ship $ */

function get_validation_org ( opunit in number,
                              site_level_org_id in number)
return integer
is

lValue          fnd_profile_option_values.profile_option_value%type;
loldvalue       fnd_profile_option_values.profile_option_value%type;
lValidOrg       number;


  cursor validation_org is
  select  distinct POV.profile_option_value
  from    fnd_profile_options PO,
          fnd_profile_option_values POV,
          fnd_responsibility FR,
          fnd_profile_options PO2,
          fnd_profile_option_values POV2
   where  PO.profile_option_name = 'SO_ORGANIZATION_ID'
   and    POV.application_id = PO.application_id
   and    POV.profile_option_id = PO.profile_option_id
   and    POV.level_id = 10003
   and    FR.application_id = POV.level_value_application_id
   and    FR.responsibility_id = POV.level_value
   and    PO2.profile_option_name = 'ORG_ID'
   and    POV2.application_id = PO2.application_id
   and    POV2.profile_option_id = PO2.profile_option_id
   and    POV2.level_id = 10003
   and    POV2.profile_option_value = to_char(opunit)
   and    POV2.level_value_Application_id = 300
   and    FR.application_id = POV2.level_value_application_id
   and    FR.responsibility_id = POV2.level_value;

 multiorg_error      EXCEPTION;

begin

   lOldValue := 0;
   /*------------------------------------------------------+
     Get the site level values for so_organization_id
     for the OE responsibility of operating unit opunit.
     Only one row should be returned. If no row is returned,
     use the profile value returned by bmlcci (site_level_org_id)
   +-------------------------------------------------------*/

   open validation_org;

   fetch validation_org into lvalue;
   lOldValue := lValue;

   while validation_org%found
   loop
       fetch validation_org into lvalue;
       if validation_org%rowcount > 1 then
          if lOldValue <> lvalue then
               raise multiorg_error;
          end if;
       end if;
   end loop;
   if validation_org%rowcount = 0 then
      lValidOrg :=  site_level_org_id;
   else
      lValidOrg := to_number(lOldvalue);
   end if;
   close validation_org;
   return (lValidOrg);
exception
  when others then
     raise multiorg_error;
end get_validation_org;


function bmldite_load_item (
	org_id           in     number,
        ci_delimiter     in out VARCHAR2,
        l_item_type        in   VARCHAR2,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer
is
    multiorg_error      EXCEPTION;
    load_error          EXCEPTION;
    dupl_error          EXCEPTION;
    loop_other_error    EXCEPTION;
    del_error		EXCEPTION;
    segment_name_error  EXCEPTION;
    flex_error          EXCEPTION;
    seg_del	  VARCHAR2(1);
    ci_del	  VARCHAR2(1);
    dummy_name    VARCHAR2(30);
    dupl_total_stmt  VARCHAR2(6000);
    dupl_tmp_stmt    VARCHAR2(50);
    del_len	  NUMBER;
    method	  NUMBER;
    loop_ctr      NUMBER;
    hold_next_seq NUMBER;
    org_buf       NUMBER;
    org_method    NUMBER;
    stmt_num      NUMBER;
    fnd_size      NUMBER;
    inv_id        NUMBER;
    o_id        NUMBER;
    rows_processed NUMBER;
    dupl_cursor   NUMBER;
    CURSOR check_segment IS
		SELECT distinct organization_id
		FROM mtl_demand
	    	WHERE config_group_id = USERENV('SESSIONID');
    CURSOR fnd_check(l_org_id NUMBER) IS
     select  nvl(FV.MAXIMUM_SIZE,-99)
     from    BOM_PARAMETERS P,
             FND_ID_FLEX_SEGMENTS FS,
	     FND_FLEX_VALUE_SETS FV
      where  P.ORGANIZATION_ID = l_org_id
      and    FS.ID_FLEX_CODE = 'MSTK'
      and    FS.ID_FLEX_NUM = 101
      and    FS.SEGMENT_NAME = P.CONFIG_SEGMENT_NAME
      and    FS.APPLICATION_ID = 401   /* INV */
      and    FS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID;
    TYPE SIsegTYPE is TABLE of
                mtl_system_items_interface.segment1%TYPE
                index by BINARY_INTEGER;
    seg        SIsegTYPE;
    ind             BINARY_INTEGER;
  BEGIN

    /*
    **  Check delimiter to ensure it is a length of one and that it
    **  isn't the same as the item delimiter value.
    */

/*	ATOPUTIL.info('In BOMPLDCI'); */
	stmt_num := 5;
    select length(ci_delimiter) into del_len from dual;
    if (del_len <> 1 ) then
   	raise del_error;
    else
	ci_del := substrb(ci_delimiter,1,1);
    end if;

    table_name := 'FND_ID_FLEX_STRUCTURES ';
	stmt_num := 10;
    select concatenated_segment_delimiter
	into seg_del
    from fnd_id_flex_structures
    where application_id = 401
    and id_flex_code = 'MSTK'
    and id_flex_num = 101;

    if (seg_del = ci_del) then
	raise del_error;
    end if;

    if (ci_del = ' ') then
	ci_del := '';
    end if;

    /*
    ** Check to see if the config_segment_name exists in bom_parameters
    ** for the given organizations
    */
	table_name := 'BOM_PARAMETERS';
	stmt_num :=15;

	IF org_id = -1 THEN
		stmt_num := 16;
		OPEN check_segment;
	     LOOP
		stmt_num := 17;
		FETCH check_segment INTO org_buf;
		EXIT WHEN check_segment%NOTFOUND;
		stmt_num :=  18;
		select config_segment_name into dummy_name
	           from bom_parameters
       		   where organization_id = org_buf;
         	IF dummy_name is NULL THEN RAISE segment_name_error;
         	END IF;
		OPEN fnd_check(org_buf);
	        FETCH fnd_check INTO fnd_size;
        	IF fnd_check%NOTFOUND THEN
		 	raise flex_error;
	        ELSIF fnd_size = -99 THEN
			raise flex_error;
		END IF;

		CLOSE fnd_check;

             END LOOP;
	        CLOSE check_segment;
	ELSE
		stmt_num := 19;
	   select config_segment_name into dummy_name
	   from bom_parameters
	   where organization_id = org_id;
        	 IF dummy_name is NULL THEN RAISE segment_name_error;
	 	 END IF;
	   OPEN fnd_check(org_id);
	   FETCH fnd_check INTO fnd_size;
        	IF fnd_check%NOTFOUND THEN
		 	raise flex_error;
	        ELSIF fnd_size = -99 THEN
			raise flex_error;
		END IF;
	   CLOSE fnd_check;

	END IF;


    /*
    ** Insert a row into the new mtl_system_items_interface table.
    */

      table_name := 'INSERT MTL_SYSTEM_ITEMS_IF ';
	stmt_num := 20;
      insert into MTL_SYSTEM_ITEMS_INTERFACE
	    (INVENTORY_ITEM_ID,
	     ORGANIZATION_ID,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     SEGMENT1,
	     SEGMENT2,
	     SEGMENT3,
	     SEGMENT4,
	     SEGMENT5,
	     SEGMENT6,
	     SEGMENT7,
	     SEGMENT8,
	     SEGMENT9,
	     SEGMENT10,
	     SEGMENT11,
	     SEGMENT12,
	     SEGMENT13,
	     SEGMENT14,
	     SEGMENT15,
	     SEGMENT16,
	     SEGMENT17,
	     SEGMENT18,
	     SEGMENT19,
	     SEGMENT20,
	     ATP_FLAG,
	     MRP_PLANNING_CODE,
             REPETITIVE_PLANNING_FLAG,
	     SHIPPABLE_ITEM_FLAG,
             CUSTOMER_ORDER_FLAG,
             INTERNAL_ORDER_FLAG,
	     BUILD_IN_WIP_FLAG,
	     PICK_COMPONENTS_FLAG,
	     REPLENISH_TO_ORDER_FLAG,
	     BASE_ITEM_ID,
             DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
	     BOM_ENABLED_FLAG,
	     BOM_ITEM_TYPE,
	     AUTO_CREATED_CONFIG_FLAG,
             DEMAND_SOURCE_LINE,
	     DEMAND_SOURCE_TYPE,
	     DEMAND_SOURCE_HEADER_ID,
             COPY_ITEM_ID,
             SET_ID,
	     ITEM_CATALOG_GROUP_ID,
             INVENTORY_ITEM_FLAG,
             STOCK_ENABLED_FLAG,
	     MTL_TRANSACTIONS_ENABLED_FLAG,
	     SO_TRANSACTIONS_FLAG,
	     RESERVABLE_TYPE,
	     REVISION,
             ITEM_TYPE,
	     CUSTOMER_ORDER_ENABLED_FLAG,
	     INTERNAL_ORDER_ENABLED_FLAG
            )
      select  MTL_SYSTEM_ITEMS_S.NEXTVAL,
             D.ORGANIZATION_ID,
	     SYSDATE,                /* LAST_UPDATE_DATE */
	     1,                      /* LAST_UPDATED_BY */
	     SYSDATE,                /* CREATION_DATE */
	     1,                      /* CREATED_BY */
	     get_validation_org(SL.ORG_ID, org_id),    /* last_update_login =  validation_org */
             /* config_number_method_type:
                1 = Append with next sequence
                2 = Replace with next sequence
                3 = Replace with order header num/line num/delivery  */
	   decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT1',
		     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT1,1,decode(GREATEST(FV.MAXIMUM_SIZE,
	40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                         L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT1),S.SEGMENT1),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT2',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT2,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT2),S.SEGMENT2),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT3',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT3,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT3),S.SEGMENT3),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT4',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT4,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT4),S.SEGMENT4),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT5',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT5,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT5),S.SEGMENT5),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT6',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT6,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT6),S.SEGMENT6),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT7',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT7,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT7),S.SEGMENT7),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT8',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT8,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT8),S.SEGMENT8),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT9',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT9,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT9),S.SEGMENT9),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT10',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT10,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT10),S.SEGMENT10),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT11',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT11,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT11),S.SEGMENT11),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT12',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT12,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT12),S.SEGMENT12),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT13',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT13,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT13),S.SEGMENT13),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT14',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT14,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT14),S.SEGMENT14),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT15',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT15,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT15),S.SEGMENT15),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT16',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT16,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT16),S.SEGMENT16),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT17',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT17,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT17),S.SEGMENT17),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT18',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT18,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT18),S.SEGMENT18),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT19',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT19,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1 || ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT19),S.SEGMENT19),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT20',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT20,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                        40),40,FV.MAXIMUM_SIZE-1-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),39-length(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL))) ||ci_del||
                        TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     2, TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
                     3, DECODE(D.USER_DELIVERY, NULL, L.SEGMENT1|| ci_del || D.USER_LINE_NUM,
                     L.SEGMENT1|| ci_del || D.USER_LINE_NUM || ci_del || D.USER_DELIVERY),
                     4, BOMPCFGI.user_item_number(D.INVENTORY_ITEM_ID),
                     S.SEGMENT20),S.SEGMENT20),
	     'N',		    /* ATP_FLAG */
	     S.MRP_PLANNING_CODE, /* MRP_PLANNING_CODE */
             S.REPETITIVE_PLANNING_FLAG, /* REPETITIVE_PLANNING_FLAG */
	     'Y',                   /* SHIPPABLE_ITEM_FLAG = YES */
             'N',                   /* CUSTOMER_ORDER_FLAG = NO */
             'N',                   /* INTERNAL_ORDER_FLAG = NO */
	     'Y',                   /* BUILD_IN_WIP_FLAG = YES */
	     'N',                   /* PICK_COMPONENTS_FLAG */
	     'Y',                   /* REPLENISH_TO_ORDER_FLAG = YES */
	     D.INVENTORY_ITEM_ID,   /* BASE_ITEM_ID = Model's Item ID */
             'Y',                /* DEFAULT_INCLUDE_IN_ROLLUP_FLAG = YES */
	     'Y',		    /* BOM_ENABLED_FLAG = Yes */
	     4,			    /* BOM_ITEM_TYPE = Standard */
	     'Y',		    /* AUTO_CREATED_CONFIG_FLAG = YES */
             D.DEMAND_SOURCE_LINE,  /* DEMAND_SOURCE_LINE */
	     D.DEMAND_SOURCE_TYPE,  /* DEMAND_SOURCE_TYPE */
	     D.DEMAND_SOURCE_HEADER_ID, /* DEMAND_SOURCE_HEADER_ID */
             D.INVENTORY_ITEM_ID,   /* COPY_ITEM_ID */
             USERENV('SESSIONID'),  /* SET_ID */
	     S.ITEM_CATALOG_GROUP_ID,
             'Y',
             'Y',
             'Y',		    /* MTL_TRANSACTIONS_ENABLED_FLAG */
             'Y',		    /* SO_TRANSACTIONS_FLAG */
	     1,			    /* RESERVABLE_TYPE */
	     MP.STARTING_REVISION,   /* REVISION */
             l_item_type,
	     'N',
	     'N'
      from   MTL_DEMAND D,
             MTL_SYSTEM_ITEMS S,
             BOM_PARAMETERS P,
	     MTL_SALES_ORDERS L,
             SO_LINES_ALL SL,
             FND_ID_FLEX_SEGMENTS FS,
	     FND_FLEX_VALUE_SETS FV,
	     MTL_PARAMETERS MP
      where  D.config_group_id = USERENV('SESSIONID')
      and    D.ORGANIZATION_ID = S.ORGANIZATION_ID
      and    D.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
      and    D.DUPLICATED_CONFIG_ITEM_ID is NULL
      and    D.DUPLICATED_CONFIG_DEMAND_ID is NULL
      and    P.ORGANIZATION_ID = D.ORGANIZATION_ID
      and    L.SALES_ORDER_ID = D.DEMAND_SOURCE_HEADER_ID
      and    SL.INVENTORY_ITEM_ID = D.INVENTORY_ITEM_ID
      and    SL.LINE_ID       = D.DEMAND_SOURCE_LINE
      and    FS.ID_FLEX_CODE = 'MSTK'
      and    FS.ID_FLEX_NUM = 101
      and    FS.SEGMENT_NAME = P.CONFIG_SEGMENT_NAME
      and    FS.APPLICATION_ID = 401   /* INV */
      and    FS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID
      and    MP.ORGANIZATION_ID = S.ORGANIZATION_ID;

	rows_processed := SQL%ROWCOUNT;
/*	ATOPUTIL.info('Rows Inserted into Intf:' || rows_processed); */

      IF SQL%ROWCOUNT > 0 THEN
        /* Determine if the resulting configuration name is duplicated on
           the data base.   */
        loop_ctr := 0;
        <<dupl_loop>>
        LOOP
         IF loop_ctr = 10 THEN RAISE dupl_error;
         END IF;
         loop_ctr := loop_ctr + 1;


	for ind in 1..20 loop
		seg(ind) := 'SEGMENT' || ind ;
/*		ATOPUTIL.info(seg(ind)); */
	end loop;

		stmt_num := 21;
		OPEN check_segment;
	LOOP
		stmt_num := 22;
    /*
    ** Get the config segment name corresponding to the org_buf
    */
		FETCH check_segment INTO org_buf;
		IF check_segment%NOTFOUND THEN
		EXIT dupl_loop;
		END IF;

		stmt_num :=  23;
		select application_column_name into dummy_name
	           from fnd_id_flex_segments fs, bom_parameters p
       		   where p.organization_id = org_buf
		   and   fs.id_flex_code = 'MSTK'
		   and   fs.id_flex_num = 101
		   and   fs.segment_name = p.config_segment_name
		   and   fs.application_id = 401;
         	IF dummy_name is NULL THEN RAISE segment_name_error;
         	END IF;

/*	ATOPUTIL.info('Org_id:' || org_buf);
	ATOPUTIL.info('Config_segment:' || dummy_name);	*/
    /*
    ** Prepare cursor to select for duplicate item name check
    */
	<<dupl_per_org_loop>>
	LOOP
/*	ATOPUTIL.info('Starting dupl_check loop'); */
	stmt_num := 24;

	dupl_total_stmt := 'select I.inventory_item_id,I.organization_id from mtl_system_items_interface I where I.SET_ID = TO_CHAR(USERENV(''SESSIONID'')) and I.organization_id = :org_buf';

	dupl_total_stmt := dupl_total_stmt || ' ' || 'and exists((select ''exists'' from mtl_system_items S2 where S2.inventory_item_id <> I.inventory_item_id';

	ind := 0;
	stmt_num := 25;
	for ind in 1..20 loop

         if (seg(ind) = dummy_name) then

     select decode(ind,1,'and S2.segment1 = I.segment1',
		      2,'and S2.segment2 = I.segment2',
		      3,'and S2.segment3 = I.segment3',
		      4,'and S2.segment4 = I.segment4',
		      5,'and S2.segment5 = I.segment5',
		      6,'and S2.segment6 = I.segment6',
		      7,'and S2.segment7 = I.segment7',
		      8,'and S2.segment8 = I.segment8',
		      9,'and S2.segment9 = I.segment9',
		      10,'and S2.segment10 = I.segment10',
		      11,'and S2.segment11 = I.segment11',
		      12,'and S2.segment12 = I.segment12',
		      13,'and S2.segment13 = I.segment13',
		      14,'and S2.segment14 = I.segment14',
		      15,'and S2.segment15 = I.segment15',
		      16,'and S2.segment16 = I.segment16',
		      17,'and S2.segment17 = I.segment17',
		      18,'and S2.segment18 = I.segment18',
		      19,'and S2.segment19 = I.segment19',
		      20,'and S2.segment20 = I.segment20')
     into dupl_tmp_stmt
     from dual;
          dupl_total_stmt := dupl_total_stmt || ' ' || dupl_tmp_stmt ;

	else

  select decode(ind,1,'and nvl(S2.segment1,'' '') = nvl(I.segment1,'' '')',
		    2,'and nvl(S2.segment2,'' '') = nvl(I.segment2,'' '')',
		    3,'and nvl(S2.segment3,'' '') = nvl(I.segment3,'' '')',
		    4,'and nvl(S2.segment4,'' '') = nvl(I.segment4,'' '')',
		    5,'and nvl(S2.segment5,'' '') = nvl(I.segment5,'' '')',
		    6,'and nvl(S2.segment6,'' '') = nvl(I.segment6,'' '')',
		    7,'and nvl(S2.segment7,'' '') = nvl(I.segment7,'' '')',
		    8,'and nvl(S2.segment8,'' '') = nvl(I.segment8,'' '')',
		    9,'and nvl(S2.segment9,'' '') = nvl(I.segment9,'' '')',
		    10,'and nvl(S2.segment10,'' '') = nvl(I.segment10,'' '')',
		    11,'and nvl(S2.segment11,'' '') = nvl(I.segment11,'' '')',
		    12,'and nvl(S2.segment12,'' '') = nvl(I.segment12,'' '')',
		    13,'and nvl(S2.segment13,'' '') = nvl(I.segment13,'' '')',
		    14,'and nvl(S2.segment14,'' '') = nvl(I.segment14,'' '')',
		    15,'and nvl(S2.segment15,'' '') = nvl(I.segment15,'' '')',
		    16,'and nvl(S2.segment16,'' '') = nvl(I.segment16,'' '')',
		    17,'and nvl(S2.segment17,'' '') = nvl(I.segment17,'' '')',
		    18,'and nvl(S2.segment18,'' '') = nvl(I.segment18,'' '')',
		    19,'and nvl(S2.segment19,'' '') = nvl(I.segment19,'' '')',
		    20,'and nvl(S2.segment20,'' '') = nvl(I.segment20,'' '')')
      into dupl_tmp_stmt
      from dual;
          dupl_total_stmt := dupl_total_stmt || ' ' || dupl_tmp_stmt;

	end if;
	end loop;

	stmt_num := 26;
        dupl_total_stmt := dupl_total_stmt || ' '|| ') UNION (';

    /*
    ** Prepare cursor to select for duplicate item name check
    */
	stmt_num := 27;

	dupl_total_stmt := dupl_total_stmt || 'select ''exists'' from mtl_system_items_interface I2 where I2.SET_ID = TO_CHAR(USERENV(''SESSIONID'')) and I2.inventory_item_id <> I.inventory_item_id';

	ind := 0;
	stmt_num := 28;
	for ind in 1..20 loop

         if (seg(ind) = dummy_name) then

     select decode(ind,1,'and I2.segment1 = I.segment1',
		      2,'and I2.segment2 = I.segment2',
		      3,'and I2.segment3 = I.segment3',
		      4,'and I2.segment4 = I.segment4',
		      5,'and I2.segment5 = I.segment5',
		      6,'and I2.segment6 = I.segment6',
		      7,'and I2.segment7 = I.segment7',
		      8,'and I2.segment8 = I.segment8',
		      9,'and I2.segment9 = I.segment9',
		      10,'and I2.segment10 = I.segment10',
		      11,'and I2.segment11 = I.segment11',
		      12,'and I2.segment12 = I.segment12',
		      13,'and I2.segment13 = I.segment13',
		      14,'and I2.segment14 = I.segment14',
		      15,'and I2.segment15 = I.segment15',
		      16,'and I2.segment16 = I.segment16',
		      17,'and I2.segment17 = I.segment17',
		      18,'and I2.segment18 = I.segment18',
		      19,'and I2.segment19 = I.segment19',
		      20,'and I2.segment20 = I.segment20')
     into dupl_tmp_stmt
     from dual;
          dupl_total_stmt := dupl_total_stmt || ' ' || dupl_tmp_stmt ;

	else

   select decode(ind,1,'and nvl(I2.segment1,'' '') = nvl(I.segment1,'' '')',
		     2,'and nvl(I2.segment2,'' '') = nvl(I.segment2,'' '')',
		     3,'and nvl(I2.segment3,'' '') = nvl(I.segment3,'' '')',
		     4,'and nvl(I2.segment4,'' '') = nvl(I.segment4,'' '')',
		     5,'and nvl(I2.segment5,'' '') = nvl(I.segment5,'' '')',
		     6,'and nvl(I2.segment6,'' '') = nvl(I.segment6,'' '')',
		     7,'and nvl(I2.segment7,'' '') = nvl(I.segment7,'' '')',
		     8,'and nvl(I2.segment8,'' '') = nvl(I.segment8,'' '')',
		     9,'and nvl(I2.segment9,'' '') = nvl(I.segment9,'' '')',
		     10,'and nvl(I2.segment10,'' '') = nvl(I.segment10,'' '')',
		     11,'and nvl(I2.segment11,'' '') = nvl(I.segment11,'' '')',
		     12,'and nvl(I2.segment12,'' '') = nvl(I.segment12,'' '')',
		     13,'and nvl(I2.segment13,'' '') = nvl(I.segment13,'' '')',
		     14,'and nvl(I2.segment14,'' '') = nvl(I.segment14,'' '')',
		     15,'and nvl(I2.segment15,'' '') = nvl(I.segment15,'' '')',
		     16,'and nvl(I2.segment16,'' '') = nvl(I.segment16,'' '')',
		     17,'and nvl(I2.segment17,'' '') = nvl(I.segment17,'' '')',
		     18,'and nvl(I2.segment18,'' '') = nvl(I.segment18,'' '')',
		     19,'and nvl(I2.segment19,'' '') = nvl(I.segment19,'' '')',
		     20,'and nvl(I2.segment20,'' '') = nvl(I.segment20,'' '')')
      into dupl_tmp_stmt
      from dual;
          dupl_total_stmt := dupl_total_stmt || ' ' || dupl_tmp_stmt;

	end if;
	end loop;

	stmt_num := 29;

	dupl_total_stmt := dupl_total_stmt || '))';

--	dbms_output.put_line(dupl_total_stmt);
/*	ATOPUTIL.info(dupl_total_stmt); */


	stmt_num := 30;
	dupl_cursor := dbms_sql.open_cursor;

	stmt_num := 31;
	dbms_sql.parse(dupl_cursor,dupl_total_stmt,dbms_sql.v7);

	/*
	** Here we are defining the position of the select columns
	*/

	stmt_num := 32;
	dbms_sql.define_column(dupl_cursor,1,inv_id);

	stmt_num := 33;
	dbms_sql.define_column(dupl_cursor,2,o_id);

	stmt_num := 34;
	dbms_sql.bind_variable(dupl_cursor,'org_buf',org_buf);

        /*
        ** Get all the duplicated rows into the tables
	** We execute the sql statement
        */

	stmt_num :=35;
	rows_processed := dbms_sql.execute(dupl_cursor);

	stmt_num := 36;

  if dbms_sql.fetch_rows(dupl_cursor) = 0 then
/*	ATOPUTIL.info('Quitting fetch_rows loop'); */
	EXIT dupl_per_org_loop;
  else
	      stmt_num := 101;
	      dbms_sql.column_value(dupl_cursor,1,inv_id);
	      dbms_sql.column_value(dupl_cursor,2,o_id);
/*	ATOPUTIL.info('Duplicate Item:' || inv_id ||', Org_id:'|| o_id ); */

        select config_number_method_type into org_method
        from bom_parameters
        where organization_id = org_buf;

	      stmt_num := 102;
        if org_method = 4 THEN RAISE dupl_error;
        end if;

	if dbms_sql.is_open(dupl_cursor) then
		dbms_sql.close_cursor(dupl_cursor);
	end if;

	stmt_num := 37;
         select TO_CHAR(MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL)
         into   hold_next_seq
         from   dual;

/*	ATOPUTIL.info('About to update MSI_Intf'); */

         table_name := 'UPDATE MTL_SYSTEM_ITEMS_IF ';
	stmt_num := 40;
	 update MTL_SYSTEM_ITEMS_INTERFACE I
	 set   (SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5,
		SEGMENT6, SEGMENT7, SEGMENT8, SEGMENT9, SEGMENT10,
		SEGMENT11, SEGMENT12, SEGMENT13, SEGMENT14, SEGMENT15,
		SEGMENT16, SEGMENT17, SEGMENT18, SEGMENT19, SEGMENT20)
             = (select
	    decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT1',
		     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT1,1,decode(GREATEST(FV.MAXIMUM_SIZE,
		     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                            L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                            L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                            TO_CHAR(hold_next_seq)), S.SEGMENT1),S.SEGMENT1),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT2',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT2,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT2),S.SEGMENT2),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT3',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT3,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT3),S.SEGMENT3),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT4',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT4,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT4),S.SEGMENT4),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT5',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT5,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                     L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                     TO_CHAR(hold_next_seq)), S.SEGMENT5),S.SEGMENT5),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT6',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT6,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT6),S.SEGMENT6),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT7',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT7,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT7),S.SEGMENT7),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT8',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT8,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT8),S.SEGMENT8),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT9',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT9,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT9),S.SEGMENT9),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT10',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT10,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT10),S.SEGMENT10),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT11',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT11,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT11),S.SEGMENT11),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT12',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT12,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT12),S.SEGMENT12),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT13',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT13,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT13),S.SEGMENT13),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT14',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT14,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                        L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                        L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                        TO_CHAR(hold_next_seq)), S.SEGMENT14),S.SEGMENT14),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT15',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT15,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT15),S.SEGMENT15),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT16',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT16,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                        L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                        L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                        TO_CHAR(hold_next_seq)), S.SEGMENT16),S.SEGMENT16),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT17',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT17,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT17),S.SEGMENT17),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT18',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT18,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT18),S.SEGMENT18),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT19',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT19,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1 || ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT19),S.SEGMENT19),
            decode(FS.APPLICATION_COLUMN_NAME, 'SEGMENT20',
                     decode(P.CONFIG_NUMBER_METHOD_TYPE,
                     1,SUBSTRB(S.SEGMENT20,1,decode(GREATEST(FV.MAXIMUM_SIZE,
                     40),40,FV.MAXIMUM_SIZE-1-length(hold_next_seq),39-length(hold_next_seq))) ||ci_del||
                        TO_CHAR(hold_next_seq),
                     2, TO_CHAR(hold_next_seq),
                     3, DECODE(D.USER_DELIVERY, NULL,
                          L.SEGMENT1|| ci_del || D.USER_LINE_NUM || ci_del || TO_CHAR(hold_next_seq),
                          L.SEGMENT1|| ci_del || D.USER_LINE_NUM ||ci_del|| D.USER_DELIVERY || ci_del ||
                          TO_CHAR(hold_next_seq)), S.SEGMENT20),S.SEGMENT20)
		from   MTL_SYSTEM_ITEMS_INTERFACE I2,
		       MTL_SYSTEM_ITEMS S,
		       BOM_PARAMETERS P,
                       MTL_SALES_ORDERS L,
		       MTL_DEMAND D,
                       FND_ID_FLEX_SEGMENTS FS,
		       FND_FLEX_VALUE_SETS FV
		where  I2.ORGANIZATION_ID = S.ORGANIZATION_ID
		and    I2.BASE_ITEM_ID = S.INVENTORY_ITEM_ID
		and    P.ORGANIZATION_ID = I2.ORGANIZATION_ID
                and    D.DEMAND_SOURCE_LINE = I2.DEMAND_SOURCE_LINE
                and    D.ORGANIZATION_ID = I2.ORGANIZATION_ID
                and    D.DEMAND_SOURCE_TYPE = I2.DEMAND_SOURCE_TYPE
                and    D.DEMAND_SOURCE_HEADER_ID = I2.DEMAND_SOURCE_HEADER_ID
                and    D.INVENTORY_ITEM_ID = I2.BASE_ITEM_ID
                and    D.DEMAND_SOURCE_HEADER_ID = L.SALES_ORDER_ID
		and    D.PRIMARY_UOM_QUANTITY <> 0
                and    FS.ID_FLEX_CODE = 'MSTK'
                and    FS.ID_FLEX_NUM = 101
                and    FS.SEGMENT_NAME = P.CONFIG_SEGMENT_NAME
                and    FS.APPLICATION_ID = 401   /* INV */
		and    FV.FLEX_VALUE_SET_ID = FS.FLEX_VALUE_SET_ID
                and    I2.ORGANIZATION_ID = I.ORGANIZATION_ID
		and    I2.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                and    I2.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID'))))
	  where  I.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')))
          and    I.inventory_item_id = inv_id
          and    I.organization_id = o_id;
 end if;
	END LOOP;
        END LOOP;

 END LOOP;

END IF;

	stmt_num := 60;
	if dbms_sql.is_open(dupl_cursor) then
		dbms_sql.close_cursor(dupl_cursor);
	end if;

      /*
      ** Insert cost records for config items
      ** The cost organization id is either the organization id
      ** or the master organization id
      */

      /* Insert a row into the cst_item_costs_interface table */

      table_name := 'CST_ITEM_COSTS_INTERFACE';
	stmt_num := 70;
      insert into CST_ITEM_COSTS_INTERFACE
	    (INVENTORY_ITEM_ID,
	     ORGANIZATION_ID,
	     COST_TYPE_ID,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
             INVENTORY_ASSET_FLAG,
             LOT_SIZE,
             BASED_ON_ROLLUP_FLAG,
             SHRINKAGE_RATE,
             DEFAULTED_FLAG,
             COST_UPDATE_ID,
             PL_MATERIAL,
             PL_MATERIAL_OVERHEAD,
             PL_RESOURCE,
             PL_OUTSIDE_PROCESSING,
             PL_OVERHEAD,
             TL_MATERIAL,
             TL_MATERIAL_OVERHEAD,
             TL_RESOURCE,
             TL_OUTSIDE_PROCESSING,
             TL_OVERHEAD,
             MATERIAL_COST,
             MATERIAL_OVERHEAD_COST,
             RESOURCE_COST,
             OUTSIDE_PROCESSING_COST ,
             OVERHEAD_COST,
             PL_ITEM_COST,
             TL_ITEM_COST,
             ITEM_COST,
             UNBURDENED_COST ,
             BURDEN_COST,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15
            )
      select SI.INVENTORY_ITEM_ID,   /* INVENTORY_ITEM_ID */
	     M.COST_ORGANIZATION_ID,
	     C.COST_TYPE_ID,
	     SYSDATE,                /* LAST_UPDATE_DATE */
	     -1,                     /* LAST_UPDATED_BY */
	     SYSDATE,                /* CREATION_DATE */
	     -1,                     /* CREATED_BY */
	     -1,                     /* LAST_UPDATE_LOGIN */
	     C.INVENTORY_ASSET_FLAG,
             C.LOT_SIZE,
	     C.BASED_ON_ROLLUP_FLAG,
             C.SHRINKAGE_RATE,
             C.DEFAULTED_FLAG,
             NULL,		     /* COST_UPDATE_ID */
             C.PL_MATERIAL,
             C.PL_MATERIAL_OVERHEAD,
             C.PL_RESOURCE,
             C.PL_OUTSIDE_PROCESSING,
             C.PL_OVERHEAD,
             C.TL_MATERIAL,
             C.TL_MATERIAL_OVERHEAD,
             C.TL_RESOURCE,
             C.TL_OUTSIDE_PROCESSING,
             C.TL_OVERHEAD,
             C.MATERIAL_COST,
             C.MATERIAL_OVERHEAD_COST,
             C.RESOURCE_COST,
             C.OUTSIDE_PROCESSING_COST ,
             C.OVERHEAD_COST,
             C.PL_ITEM_COST,
             C.TL_ITEM_COST,
             C.ITEM_COST,
             C.UNBURDENED_COST ,
             C.BURDEN_COST,
	     C.ATTRIBUTE_CATEGORY,
             C.ATTRIBUTE1,
             C.ATTRIBUTE2,
             C.ATTRIBUTE3,
             C.ATTRIBUTE4,
             C.ATTRIBUTE5,
             C.ATTRIBUTE6,
             C.ATTRIBUTE7,
             C.ATTRIBUTE8,
             C.ATTRIBUTE9,
             C.ATTRIBUTE10,
             C.ATTRIBUTE11,
             C.ATTRIBUTE12,
             C.ATTRIBUTE13,
             C.ATTRIBUTE14,
             C.ATTRIBUTE15
      from
	     MTL_PARAMETERS M,
             CST_ITEM_COSTS C,
             MTL_SYSTEM_ITEMS_INTERFACE SI
      where  M.ORGANIZATION_ID = SI.ORGANIZATION_ID+0
      and    C.ORGANIZATION_ID = M.ORGANIZATION_ID
      and    C.INVENTORY_ITEM_ID = SI.COPY_ITEM_ID
      and    C.COST_TYPE_ID = M.primary_cost_method
      and    SI.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')));

      /* Insert rows into the cst_item_cst_dtls_interface table */

      table_name := 'CST_ITEM_CST_DTLS_INTERFACE';
	stmt_num := 80;
      insert into CST_ITEM_CST_DTLS_INTERFACE
	    (INVENTORY_ITEM_ID,
	     COST_TYPE_ID,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     ORGANIZATION_ID,
             OPERATION_SEQUENCE_ID,
             OPERATION_SEQ_NUM,
             DEPARTMENT_ID,
             LEVEL_TYPE,
             ACTIVITY_ID,
             RESOURCE_SEQ_NUM,
             RESOURCE_ID,
             RESOURCE_RATE,
             ITEM_UNITS,
             ACTIVITY_UNITS,
             USAGE_RATE_OR_AMOUNT,
             BASIS_TYPE,
             BASIS_RESOURCE_ID,
             BASIS_FACTOR,
             NET_YIELD_OR_SHRINKAGE_FACTOR,
             ITEM_COST,
             COST_ELEMENT_ID,
             ROLLUP_SOURCE_TYPE,
             ACTIVITY_CONTEXT,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15
            )
      select SI.INVENTORY_ITEM_ID,   /* INVENTORY_ITEM_ID */
	     C.COST_TYPE_ID,
	     SYSDATE,                /* LAST_UPDATE_DATE */
	     -1,                     /* LAST_UPDATED_BY */
	     SYSDATE,                /* CREATION_DATE */
	     -1,                     /* CREATED_BY */
	     -1,                     /* LAST_UPDATE_LOGIN */
	     M.COST_ORGANIZATION_ID,
             C.OPERATION_SEQUENCE_ID,
             C.OPERATION_SEQ_NUM,
             C.DEPARTMENT_ID,
             C.LEVEL_TYPE,
             C.ACTIVITY_ID,
             C.RESOURCE_SEQ_NUM,
             C.RESOURCE_ID,
             C.RESOURCE_RATE,
             C.ITEM_UNITS,
             C.ACTIVITY_UNITS,
             C.USAGE_RATE_OR_AMOUNT,
             C.BASIS_TYPE,
             C.BASIS_RESOURCE_ID,
             C.BASIS_FACTOR,
             C.NET_YIELD_OR_SHRINKAGE_FACTOR,
             C.ITEM_COST,
             C.COST_ELEMENT_ID,
             C.ROLLUP_SOURCE_TYPE,
             C.ACTIVITY_CONTEXT,
             C.ATTRIBUTE_CATEGORY,
             C.ATTRIBUTE1,
             C.ATTRIBUTE2,
             C.ATTRIBUTE3,
             C.ATTRIBUTE4,
             C.ATTRIBUTE5,
             C.ATTRIBUTE6,
             C.ATTRIBUTE7,
             C.ATTRIBUTE8,
             C.ATTRIBUTE9,
             C.ATTRIBUTE10,
             C.ATTRIBUTE11,
             C.ATTRIBUTE12,
             C.ATTRIBUTE13,
             C.ATTRIBUTE14,
             C.ATTRIBUTE15
      from
	     MTL_PARAMETERS M,
             CST_ITEM_COST_DETAILS C,
             MTL_SYSTEM_ITEMS_INTERFACE SI
      where  M.ORGANIZATION_ID = SI.ORGANIZATION_ID+0
      and    C.ORGANIZATION_ID = M.ORGANIZATION_ID
      and    C.INVENTORY_ITEM_ID = SI.COPY_ITEM_ID
      and    C.COST_TYPE_ID = M.primary_cost_method
      and    C.ROLLUP_SOURCE_TYPE = 1      /* User Defined */
      and    SI.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')));

      /* Insert rows into the mtl_desc_elem_val_interface table */

      table_name := 'MTL_DESC_ELEM_VAL_INTERFACE';
	stmt_num := 90;
      insert into MTL_DESC_ELEM_VAL_INTERFACE
	    (INVENTORY_ITEM_ID,
	     ELEMENT_NAME,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     ELEMENT_VALUE,
             DEFAULT_ELEMENT_FLAG,
	     ELEMENT_SEQUENCE
            )
      select SI.INVENTORY_ITEM_ID,   /* INVENTORY_ITEM_ID */
	     E.ELEMENT_NAME,         /* ELEMENT_NAME */
	     SYSDATE,                /* LAST_UPDATE_DATE */
	     1,                      /* LAST_UPDATED_BY */
	     SYSDATE,                /* CREATION_DATE */
	     1,                      /* CREATED_BY */
	     1,                      /* LAST_UPDATE_LOGIN */
	     D.ELEMENT_VALUE,        /* ELEMENT_VALUE */
             E.DEFAULT_ELEMENT_FLAG, /* DEFAULT_ELEMENT_FLAG */
	     E.ELEMENT_SEQUENCE      /* ELEMENT_SEQUENCE */
      from   MTL_SYSTEM_ITEMS_INTERFACE SI,
             MTL_DESCR_ELEMENT_VALUES D,
	     MTL_DESCRIPTIVE_ELEMENTS E
      where  D.INVENTORY_ITEM_ID = SI.COPY_ITEM_ID
      and    E.ITEM_CATALOG_GROUP_ID = SI.ITEM_CATALOG_GROUP_ID
      and    E.ELEMENT_NAME = D.ELEMENT_NAME
      and    SI.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')));
      return(1);

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return(1);
	WHEN flex_error THEN
		message_name := 'BOM_ATO_LINK_ERROR';
		error_message := 'BOM_ATO_CONFIG_SEGMENT_ERROR';
		return(0);
	WHEN segment_name_error THEN
		message_name := 'BOM_ATO_LINK_ERROR';
		error_message := 'BOM_ATO_CONFIG_SEGMENT_ERROR';
		return(0);
	WHEN multiorg_error THEN
		message_name := 'BOM_ATO_LINK_ERROR';
		error_message := 'BOMPLDCI: ' || to_char(stmt_num) || 'raised multi_org_error';
                return(0);
	WHEN del_error THEN
		message_name := 'BOM_ATO_DELIMITER_ERROR';
		error_message := 'BOMPLDCI:'||to_char(stmt_num)||':' || substrb(sqlerrm,1,130);
		return(0);
	WHEN dupl_error THEN
		message_name := 'BOM_ATO_DUPL_CONFIG_NAME';
		error_message := 'BOMPLDCI:' ||to_char(stmt_num)||':'|| substrb(sqlerrm,1,130);
		return(0);
	WHEN loop_other_error THEN
		message_name := 'BOM_ATO_LOAD_LOOP_ERROR';
		error_message := 'BOMPLDCI:' ||to_char(stmt_num)||':'|| substrb(sqlerrm,1,130);
		return(0);
        WHEN OTHERS THEN
          	error_message := 'BOMPLDCI:' ||to_char(stmt_num)||':'|| substrb(sqlerrm,1,130);
          	message_name := 'BOM_ATO_LOAD_ERROR';
	  	return(0);

  end bmldite_load_item;
end BOMPLDCI;


/
