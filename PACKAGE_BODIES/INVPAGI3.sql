--------------------------------------------------------
--  DDL for Package Body INVPAGI3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPAGI3" AS
/* $Header: INVPAG3B.pls 120.7.12010000.4 2009/12/21 08:36:32 jewen ship $ */

l_process_flag_1    CONSTANT  NUMBER :=  1;
l_process_flag_2    CONSTANT  NUMBER :=  2;
l_process_flag_3    CONSTANT  NUMBER :=  3;
l_all_org           CONSTANT  NUMBER :=  1;

------------------------------- assign_item_revs ------------------------------

function assign_item_revs
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER          DEFAULT -999,
default_flag IN NUMBER          DEFAULT 1
)
return integer
is

  CURSOR c_item_number_err IS
    SELECT organization_id,rowid
		FROM mtl_item_revisions_interface
    WHERE  inventory_item_id IS NULL
    AND set_process_id  = xset_id
    AND process_flag = 1
    AND (organization_id = org_id OR
         all_org = l_all_org );
	/*
	** for assign item id from item number
	*/
 CURSOR cc is select distinct item_number,
            organization_id
            from mtl_item_revisions_interface
            where inventory_item_id is NULL
            and item_number is not NULL
            and organization_id is not NULL
            and set_process_id  = xset_id
            and process_flag = 1;

	/*
	** for assign transacton id
	*/
	CURSOR ff is select distinct inventory_item_id,
				organization_id
		from mtl_item_revisions_interface
		where process_flag = 1
                and   set_process_id  = xset_id
		and   transaction_id IS NULL --Bug: 3019435 Added condition
		and   (organization_id = org_id or
			all_org = 1);

  /*
	** R12 C for assign revision id during default
	*/
  CURSOR c_null_rev_id IS
      SELECT  rowid
		  FROM  mtl_item_revisions_interface
		 WHERE  process_flag = 1
         AND  set_process_id  = xset_id
		   AND  transaction_type = 'CREATE'
         AND  revision_id IS NULL
		   AND (organization_id = org_id OR all_org = 1)
       ORDER BY revision;

	     flex_id		number;
        status          number := 0;
        dumm_status     number;
        tran_id         number := 0;
        rev_id          number;
        l_sysdate       date    := sysdate;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level; --Bug: 4667452
        ASSIGN_ERROR    exception;
        LOGGING_ERROR   exception;

	--Begin: Jewen
   /*
    *Bug:9154307
    *for assign item id based on transaction_id
    */
   CURSOR ct is select distinct transaction_id
           from mtl_item_revisions_interface
           where inventory_item_id is NULL
           and transaction_id is not NULL
           and organization_id is not NULL
           and set_process_id  = xset_id
           and process_flag = 1;

   --End: Jewen
begin

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPAGI3.assign_item_revs : begin');
   END IF;

        /*
        ** assign all the missing organization_id from organization_code
        */

        update MTL_ITEM_REVISIONS_INTERFACE i
        set i.organization_id = (select o.organization_id
                from MTL_PARAMETERS o
                where o.organization_code = i.organization_code)
        where i.organization_id is NULL
        and   set_process_id  = xset_id
        and   i.process_flag = l_process_flag_1;

	 --Begin:Jewen
 	         /*
 	          *Bug:9154307
 	          *for assign item id based on transaction_id
 	          */
 	    for ctr in ct LOOP
 	    		/* Start of Bug 9099489 : Added the Exception Block */
 	         begin
 	             SELECT inventory_item_id INTO flex_id
 	               FROM mtl_system_items_interface
 	              WHERE transaction_id = ctr.transaction_id
 	                AND ROWNUM = 1;

 	             UPDATE mtl_item_revisions_interface
 	                SET inventory_item_id = flex_id
 	              WHERE transaction_id = ctr.transaction_id
 	                AND set_process_id   = xset_id;

 	         exception
 	                 when no_data_found then
 	                         NULL;
 	         end;
 	           /* End of Bug 9099489 */

 	    end loop;
 	     flex_id := 0;
 	   --End:Jewen

	/*
	** assign missing inventory_item_id from item number
	*/

	for cr in cc loop

		status := INVPUOPI.mtl_pr_parse_flex_name (
                        cr.organization_id,
                        'MSTK',
                        cr.item_number,
                        flex_id,
                        0,
                        err_text);

                if status <> 0 then /* Oracle error */
----Bug: 3019435 Changed the code with in IF st.
                        update mtl_item_revisions_interface
			set    process_flag = l_process_flag_3,
			       transaction_id = NVL(transaction_id,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval)

			where item_number = cr.item_number
			and   inventory_item_id is NULL
			and   process_flag = l_process_flag_1
      and   set_process_id   = xset_id
      and   organization_id   = cr.organization_id
      RETURNING transaction_id INTO tran_id;

/*
			select MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
		          into tran_id
		          from dual;
*/
                	dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
				'item_number',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
                         If dumm_status < 0 then
                            raise LOGGING_ERROR ;
                         End if ;
/*
			update mtl_item_revisions_interface
			set    process_flag = l_process_flag_3,
			       transaction_id = tran_id
			where item_number = cr.item_number
			and   inventory_item_id is NULL
			and   process_flag = l_process_flag_1
                        and   set_process_id   = xset_id
			and   organization_id   = cr.organization_id;
*/
			if status < 0 then
				raise ASSIGN_ERROR;
			end if;

                else if status = 0 then
                        update mtl_item_revisions_interface
                        set inventory_item_id = flex_id
                        where item_number = cr.item_number
                        and   set_process_id   = xset_id
			and   organization_id  = cr.organization_id;
		     end if;
                end if;
	end loop;

	/*
	** Assign transaction_id
	*/
	for cr in ff loop

           select MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
             into tran_id
           from dual;

	   update  mtl_item_revisions_interface
	   set  transaction_id = tran_id
	   where  inventory_item_id  = cr.inventory_item_id
	     and  organization_id    = cr.organization_id
        -- and  set_process_id + 0  = xset_id -- fix for bug#8757041,removed + 0
             and  set_process_id  = xset_id
	     and  process_flag = l_process_flag_1;

	end loop;

  /* Assigning Revision Ids to all CREATE records during default phase - R12C */
   FOR cr IN c_null_rev_id LOOP
      select MTL_ITEM_REVISIONS_B_S.nextval
        into rev_id
        from dual;

	   update mtl_item_revisions_interface
	      set revision_id = rev_id
	    where rowid = cr.rowid;
   END LOOP;


	/*
	** update process flag , at last
        ** For bug 3226359 added code to update date fields with sysdate + 1/86400 (1 sec) if they are NULL
        */
	update mtl_item_revisions_interface
	set process_flag = DECODE(default_flag, 1, l_process_flag_2 , l_process_flag_1),
	    LAST_UPDATE_DATE = nvl(LAST_UPDATE_DATE,(sysdate + 1/86400)),
	    /* LAST_UPDATED_BY = -1,
            **  NP 13OCT94 If you encounter ORA-6502 then see TAR 106456.555
            **  The decode stmts are the culprits!
            */
	    LAST_UPDATED_BY =  decode(LAST_UPDATED_BY, NULL, user_id,LAST_UPDATED_BY),
	    CREATION_DATE = nvl(CREATION_DATE,(sysdate + 1/86400)),
	    /*CREATED_BY = -1,*/
	    CREATED_BY = decode(LAST_UPDATED_BY, NULL, user_id,LAST_UPDATED_BY),
	    CHANGE_NOTICE = NULL,
	    ECN_INITIATION_DATE = NULL,
            IMPLEMENTATION_DATE = nvl(effectivity_date, (l_sysdate + 1/86400)),
	    implemented_serial_number = NULL,
	    revised_item_sequence_id = NULL ,
	    effectivity_date = nvl(effectivity_date, (l_sysdate + 1/86400)),
            revision = trim(revision)    --Bugfix 6457167
	where inventory_item_id is not null
	      and process_flag = l_process_flag_1
              and   set_process_id  = xset_id
	      and (organization_id   = org_id or all_org = l_all_org);

	/*
	** set process flag for the records with errors
	*/

--Bug :3625086
/*	update mtl_item_revisions_interface i
        set i.process_flag = l_process_flag_3,
            i.LAST_UPDATE_DATE = sysdate,
            i.LAST_UPDATED_BY = decode(i.LAST_UPDATED_BY, NULL, user_id,i.LAST_UPDATED_BY),
            i.CREATION_DATE = l_sysdate,
            i.CREATED_BY = decode(i.LAST_UPDATED_BY, NULL, user_id,i.LAST_UPDATED_BY)
        where ( i.inventory_item_id is NULL or
                i.organization_id is NULL)
          and set_process_id  = xset_id
          and i.process_flag = l_process_flag_1
          and ( i.organization_id = org_id or
                all_org = l_all_org );*/
	/*
	** failed within the same set
	*/

   FOR rec IN c_item_number_err LOOP
    UPDATE mtl_item_revisions_interface i
    SET i.process_flag = l_process_flag_3,
        i.LAST_UPDATE_DATE = sysdate,
        i.LAST_UPDATED_BY = decode(i.LAST_UPDATED_BY, NULL, user_id,i.LAST_UPDATED_BY),
        i.CREATION_DATE = l_sysdate,
        i.CREATED_BY = decode(i.LAST_UPDATED_BY, NULL, user_id,i.LAST_UPDATED_BY),
        i.transaction_id = NVL(transaction_id,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval)
    WHERE i.rowid = rec.rowid
    RETURNING i.transaction_id INTO tran_id ;

    dumm_status := INVPUOPI.mtl_log_interface_err(
                        rec.organization_id,
                        user_id,
                        login_id,
                        prog_appid,
                        prog_id,
                        request_id,
                        tran_id,
                        null,
                        'item_number',
                        'MTL_ITEM_REVISIONS_INTERFACE',
                        'INV_IOI_ITEM_NUMBER_NO_EXIST',
                        err_text);

     IF dumm_status < 0 THEN
        raise LOGGING_ERROR ;
     END IF ;
  END LOOP;
--End 3625086
	update mtl_item_revisions_interface i
	set i.process_flag = l_process_flag_3
	where i.transaction_id in (select m.transaction_id
		from mtl_item_revisions_interface m
		where m.process_flag = l_process_flag_3
		and  (m.organization_id = org_id or
			all_org = l_all_org )
                and set_process_id = xset_id )
	and i.process_flag = l_process_flag_2
        and set_process_id   = xset_id
	and (i.organization_id = org_id or
		all_org = l_all_org);

	return (0);

exception

        when ASSIGN_ERROR  then
             return(status);
        when LOGGING_ERROR then
                return(dumm_status);
        when OTHERS then
                err_text := substr('INVPAGI3.assign_item_revs:' || SQLERRM , 1, 240);
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
				null,
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'BOM_PARSE_ITEM_ERROR',
                                err_text);
                return(SQLCODE);
--              return(status);

end assign_item_revs;


end INVPAGI3;

/
