--------------------------------------------------------
--  DDL for Package Body INVPVALI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVALI" AS
/* $Header: INVPVALB.pls 120.11.12010000.3 2009/08/10 23:16:34 mshirkol ship $ */

------------------------ validate_item_revs -----------------------------------

function validate_item_revs
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER     DEFAULT -999
)
return integer
is

	/*
???	** we have already validate org_id, catg_set_id and catg_id
	** in assign function. we only validate item_id here
	*/

   /*
   ** any row that does not have a corresponding item row in prod or
   ** inteface table must be flagged as error
   */

   CURSOR cc is
	select  i.transaction_id,
	        i.transaction_type,
	        i.inventory_item_id,
		i.organization_id ,
		i.revision,
                rowid
	from mtl_item_revisions_interface i
	where i.process_flag = 2
        and   i.set_process_id  = xset_id
	and (i.organization_id = org_id or all_org = 1)
	and not exists (select 'X'
			from mtl_system_items m
			where m.organization_id = i.organization_id
                          and m.inventory_item_id = i.inventory_item_id)
	and not exists  (select 'X'
                         from mtl_system_items_interface mi
                        where mi.organization_id = i.organization_id
                          and mi.inventory_item_id = i.inventory_item_id
			  and process_flag = 4);

	/*
	** We are going to check for the validity against the unique index
	**	ORGANIZATION_ID,REVISION and INVENTORY_ITEM_ID
	*/
/*
** if the item-revision combination already exists in production, then
** mark it as an error
*/
/*
   Bug 1725851 : Removed + 0 on Set Process Id as it was causing
   Performance issues. Removing this uses Index
   mtl_item_revs_interface_N3 index instead of FULL Table Scan.
   Also removed mtl_parameters as it is not required here
*/
	--User can now populate revision_id in the interface table.
	CURSOR dd is
	select transaction_id,
	       transaction_type,
	       organization_id,
	       inventory_item_id,
	       revision,
	       revision_id,
	       rowid
	from mtl_item_revisions_interface
	where set_process_id  = xset_id
	and   process_flag    = 2;
	--2808277 : Above validation applicable to only CREATE
	--Above cursor modified to check revision id uniqueness

        --Start: Check for data security and user privileges
	--6318972:Privledge check missing on Rev creation
        CURSOR c_get_rev_item is
        select i.rowid,
	       i.organization_id,
               i.inventory_item_id,
	       i.transaction_id,
	       i.created_by
        from mtl_item_revisions_interface i
        where i.set_process_id   = xset_id
        and   i.process_flag     = 2
	and   (i.transaction_type  = 'UPDATE'
	       or  exists (select null
			  from  mtl_system_items_b m
			  where m.organization_id   = i.organization_id
                          and   m.inventory_item_id = i.inventory_item_id));
        --End: Check for data security and user privileges
/*
** if there are duplicate rows in interface table for item-rev
** combination, mark as error
*/
/* Bug 1725851
   Rewriting the below cursor to avoid performance issue
*/
        CURSOR ee is
        select m.transaction_id,
	       m.transaction_type,
               m.organization_id,
               m.inventory_item_id,
               m.revision,
	       m.rowid
        from mtl_item_revisions_interface m
        where m.set_process_id = xset_id
        and   m.process_flag = 2;

/*
** item revs must be in alphanumeric and chronological order must check against
** the interface table AND the database table
*/
/* Bug 1725851
   Rewriting the below cursor to avoid performance issue
   2806275 : Revision Reason validation
*/
        CURSOR ff is
        select m.transaction_id,
	       m.transaction_type,
               m.organization_id,
               m.inventory_item_id,
               m.revision,
	       m.revision_id,
               m.effectivity_date,
	       m.ecn_initiation_date,
	       m.implementation_date,
	       m.revision_reason
        from mtl_item_revisions_interface m
        where m.set_process_id = xset_id
        and   m.process_flag = 2;

              /*NP 07SEP94 In cursor gg added an or clause here
              **effectivity date being less or equal to current
              **effective date..ie an invalid condition
              **NP 21DEC95 removed check on past effectivity dates.
              **They are allowed now.
              */
  -- Bug 4299292. Use base table mtl_item_revisions_b to fix performance issue
        CURSOR gg is
        select i.transaction_id,
               i.organization_id,
	       i.rowid
        from mtl_item_revisions_b m,
             mtl_item_revisions_interface i
        where m.organization_id = i.organization_id
        and   i.set_process_id  = xset_id
        and   m.inventory_item_id = i.inventory_item_id
        and   ( (m.revision < i.revision and  m.effectivity_date >=
                                                      i.effectivity_date)
              or (i.revision < m.revision and  i.effectivity_date >=
                                                      m.effectivity_date)
               )
	and   i.process_flag = 2;
	--3569925 : Added = condition for > on effectivity dates.

/*
** item revs life cycle  and phases validation
*/

        CURSOR c_get_revision_lifecycle IS
	   SELECT rowid,
	          inventory_item_id,
	          organization_id,
	          lifecycle_id,
	          current_phase_id,
		  transaction_id,
		  transaction_type,
		  revision,
		  revision_id
	   FROM   mtl_item_revisions_interface i
	   WHERE  set_process_id = xset_id
           AND    process_flag = 2
	   FOR UPDATE OF current_phase_id NOWAIT;

        --3059993:Revision create should honour items phase policy
	--Changes added lifecycle,phase ids in the select list.
	CURSOR c_get_item_ids(cp_org_id         NUMBER,
	                      cp_item_id        NUMBER)
	IS
           SELECT mi.item_catalog_group_id
   		 ,mi.lifecycle_id
	         ,mi.current_phase_id
		 ,'U'
                 ,mi.transaction_type
           FROM  mtl_system_items_interface mi
           WHERE mi.organization_id        = cp_org_id
           AND   mi.inventory_item_id      = cp_item_id
           AND   mi.process_flag           = 4
	   UNION
           SELECT m.item_catalog_group_id
   		 ,m.lifecycle_id
	         ,m.current_phase_id
		 ,NVL(m.approval_status,'A')
		 ,'EXISTS'
	   FROM  mtl_system_items_b m
           WHERE m.organization_id        = cp_org_id
           AND   m.inventory_item_id      = cp_item_id;


       --2806275 : Revision Reason validation
       CURSOR c_check_lookup (cp_type fnd_lookup_values_vl.lookup_type%TYPE,
                              cp_code fnd_lookup_values_vl.lookup_code%TYPE)
       IS
         SELECT 'Y'
         FROM   fnd_lookup_values_vl
         WHERE  lookup_type  = cp_type
         AND    lookup_code  = cp_code
         AND    SYSDATE BETWEEN NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
         AND    enabled_flag = 'Y';

       --2885843: default revision error propagated to imported item
       CURSOR c_get_default_rev(cp_org_id NUMBER)
       IS
          select  starting_revision
          from  mtl_parameters
          where organization_id = cp_org_id;

        CURSOR is_gdsn_batch(cp_xset_id NUMBER) IS
          SELECT 1 FROM ego_import_option_sets
           WHERE batch_id = cp_xset_id
             AND enabled_for_data_pool = 'Y';

	status		  number;
	error_msg	  varchar2(70);
        l_process_flag_2  number := 2 ;
        l_process_flag_3  number := 3 ;
        l_process_flag_4  number := 4 ;
        l_all_org         number := 1 ;
        temp_count        number := 0;
	LOGGING_ERR	  exception;
        l_item_catalog    NUMBER;
	l_lookup_exist    VARCHAR2(1):='N';
	l_default_rev     VARCHAR2(3);
	l_lifecycle_error BOOLEAN := FALSE;

	--2808277: Update validations for Lifecycle-Phase
	l_row_count        NUMBER(3) := 0;
        l_Old_Phase_Id     mtl_item_revisions_b.current_phase_id%TYPE;
	l_Policy_Code      VARCHAR2(20);
        l_Return_Status    VARCHAR2(1);
        l_Error_Code       NUMBER;
        l_Msg_Count        NUMBER;
        l_Msg_Data         VARCHAR2(2000);
	l_has_privilege    VARCHAR2(1) := 'F';

	--Start:3059993:Revision create should honour items phase policy
	l_item_phase_id     mtl_item_revisions_b.current_phase_id%TYPE;
	l_item_lifecycle_id mtl_item_revisions_b.lifecycle_id%TYPE;
	--End:3059993:Revision create should honour items phase policy
	l_revision_id       mtl_item_revisions_interface.revision_id%TYPE;
	l_revid_error       BOOLEAN := FALSE;

	l_item_approved    mtl_system_items_b.approval_status%TYPE  := NULL;
	l_item_trans_type  mtl_system_items_interface.transaction_type%TYPE := NULL;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
	l_process_control     VARCHAR2(2000) := NULL; --Used by EGO API only for internal flow control
   l_is_gdsn_batch   NUMBER;

   /* Bug 7513461*/
   currval_not_def exception;
   pragma exception_init(currval_not_def, -8002);

begin

        l_process_control := INV_EGO_REVISION_VALIDATE.Get_Process_Control;

	for cr in cc loop
		update mtl_item_revisions_interface
		set process_flag = l_process_flag_3
                where      rowid = cr.rowid ;

                status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'ITEM_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_NO_ITEM',
                                err_text);
                 if status < 0 then
                                 raise LOGGING_ERR;
                 end if;
	end loop;

        --Start User can now populate revision_id in the interface table
	for cr in dd loop
           l_revid_error := FALSE;
	   IF cr.transaction_type ='CREATE' AND cr.revision_id IS NOT NULL THEN
				/* Bug 7513461*/
	      BEGIN
	         SELECT MTL_ITEM_REVISIONS_B_S.CURRVAL
		 					INTO l_revision_id FROM DUAL;
    	  EXCEPTION
    	 		 WHEN currval_not_def THEN
    	 		 		SELECT MTL_ITEM_REVISIONS_B_S.NEXTVAL
							INTO l_revision_id FROM DUAL;
	         WHEN OTHERS THEN
		    			l_revision_id := cr.revision_id - 1;
	      END;

	      IF cr.revision_id > l_revision_id  THEN
        		l_revid_error := TRUE;
		 		END IF;

	      IF l_revid_error THEN
                 update mtl_item_revisions_interface
                 set process_flag = l_process_flag_3
	         where rowid = cr.rowid;

                 status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
																'REVISION_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_INVALID_REVISION_ID',
                                err_text);
                 if status < 0 then
                    raise LOGGING_ERR;
                 end if;
	      END IF;

	   END IF;

	    --Start :3456560 Revision code validation.
            IF cr.transaction_type ='CREATE'
	       AND cr.revision IS NULL THEN
               l_revid_error := TRUE;
            ELSIF cr.transaction_type ='UPDATE'
	       AND cr.revision IS NULL
	       AND cr.revision_id IS NULL THEN
               l_revid_error := TRUE;
            END IF;
	    IF l_revid_error THEN
               update mtl_item_revisions_interface
               set process_flag = l_process_flag_3
	       where rowid = cr.rowid;
               status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_INVALID_REVISION',
                                err_text);
               if status < 0 then
                  raise LOGGING_ERR;
               end if;
	    END IF;
	    --End :3456560 Revision code validation.

           SELECT count(1) INTO l_row_count
	   FROM   mtl_item_revisions_b
	   WHERE  organization_id   = cr.organization_id
	   AND    inventory_item_id = cr.inventory_item_id
	   AND    (revision = cr.revision  OR revision_id = cr.revision_id);

           IF cr.transaction_type ='CREATE' AND l_row_count > 0 THEN

              update mtl_item_revisions_interface
              set process_flag = l_process_flag_3
	      where rowid = cr.rowid;

              status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_DUP_2',
                                err_text);
              if status < 0 then
                 raise LOGGING_ERR;
              end if;
           ELSIF cr.transaction_type ='UPDATE' AND l_row_count = 0 THEN
              update mtl_item_revisions_interface
              set process_flag = l_process_flag_3
	      where rowid = cr.rowid;
              status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_NO_ITEM',
                                err_text);
              if status < 0 then
                 raise LOGGING_ERR;
              end if;
           END IF;

        end loop;
        --End User can now populate revision_id in the interface table

        --Start : Check for data security and user privileges
	-- Bug 4538382 - NOT chk when control is from PLM:UI for perf
    -- Bug 5218491 - Modified the IF clause : Changed <> to = in the below check
	IF (INSTR(NVL(l_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 )
	THEN
          for cr in c_get_rev_item loop
             --Fix for bug# 3032994. Changed the privilege to check from
	     --EGO_EDIT_ITEM to EGO_ADD_ITEM_REVISION
	     IF ( cr.created_by <> -99 ) THEN
                l_has_privilege := INV_EGO_REVISION_VALIDATE.check_data_security(
	       			     p_function           => 'EGO_ADD_ITEM_REVISION'
				    ,p_object_name        => 'EGO_ITEM'
				    ,p_instance_pk1_value => cr.inventory_item_id
				    ,p_instance_pk2_value => cr.organization_id
				    ,P_User_Id            => user_id);

                IF l_has_privilege <> 'T' THEN
                    update mtl_item_revisions_interface
                    set process_flag = l_process_flag_3
   	            where rowid = cr.rowid;

                    status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVENTORY_ITEM_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_ITEMREV_UPDATE_PRIV',
                                err_text);
                   if status < 0 then
                      raise LOGGING_ERR;
                   end if;
	         END IF; --has privilege
	     ELSE
                IF l_inv_debug_level IN(101, 102) THEN
                   INVPUTLI.info('INVPVALI.Security skipped for Item Org:' || cr.inventory_item_id || '-' || cr.organization_id  );
                END IF;
	     END IF; --created_by

	    end loop;
         END IF;
        --End : Check for data security and user privileges

        for cr in ee loop

                select count(*)
                into temp_count
                from mtl_item_revisions_interface i
                where i.organization_id    = cr.organization_id
                and   i.inventory_item_id  = cr.inventory_item_id
                -- and   i.set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
                and   i.set_process_id = xset_id
                and   i.revision = cr.revision
		--and   i.transaction_id     = cr.transaction_id --2808277 Removed for bug 5458317
                and   i.process_flag       = 2;

              if temp_count > 1 then

                 --Bypassing validation for GDSN batches
                 l_is_gdsn_batch := 0;
                 Open  is_gdsn_batch(xset_id);
                 Fetch is_gdsn_batch INTO l_is_gdsn_batch;
                 Close is_gdsn_batch;

                 if l_is_gdsn_batch <> 1 then

                   update mtl_item_revisions_interface
                   set process_flag     = l_process_flag_3
                   where transaction_id = cr.transaction_id
                     and   set_process_id = xset_id
                     and   revision       = cr.revision;

   -- R12C The duplicate Item-Org combination is already reported in INVPVHDR
   /* 2885843: Start default revision error propagated to imported item

		OPEN  c_get_default_rev(cp_org_id => cr.organization_id);
		FETCH c_get_default_rev INTO l_default_rev;
		CLOSE c_get_default_rev;

		IF  cr.transaction_type ='CREATE'
		AND l_default_rev = cr.revision THEN

		   UPDATE mtl_system_items_interface
		   SET    process_flag = l_process_flag_3
		   WHERE  inventory_item_id = cr.inventory_item_id
   		   AND    organization_id   = cr.organization_id
		   AND    set_process_id = xset_id;

		END IF;
		2885843: End default revision error propagated to imported item */

                status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DUP2',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_DUP_1',
                                err_text);
                  if status < 0 then
                     raise LOGGING_ERR;
                  end if;
                end if; --Is not GDSN Batch
              end if;
              -- Bug 4538382 - NOT chk when control is from PLM:UI for perf
              -- Bug 5218491 - Modified the IF clause : Changed <> to = in the below check
	      IF (INSTR(NVL(l_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 )
	      THEN
	      --Start: 3059993:Revision create should honour items phase policy
	       IF  cr.transaction_type ='CREATE'  THEN

        	 OPEN  c_get_default_rev(cp_org_id => cr.organization_id);
		 FETCH c_get_default_rev INTO l_default_rev;
		 CLOSE c_get_default_rev;

		 IF l_default_rev <> cr.revision THEN

                   OPEN  c_get_item_ids(cp_org_id  => cr.organization_id,
	                                cp_item_id => cr.inventory_item_id);
	           FETCH c_get_item_ids
		   INTO l_item_catalog
		       ,l_item_lifecycle_id
		       ,l_item_phase_id
	               ,l_item_approved
		       ,l_item_trans_type;

                   CLOSE c_get_item_ids;

		   IF l_item_lifecycle_id IS NOT NULL AND l_item_phase_id IS NOT NULL THEN
		         INV_EGO_REVISION_VALIDATE.phase_change_policy
	                     (P_ORGANIZATION_ID   => cr.organization_id
		             ,P_INVENTORY_ITEM_ID => cr.inventory_item_id
		             ,P_CURR_PHASE_ID     => l_item_phase_id
		             ,P_FUTURE_PHASE_ID   => NULL
		             ,P_PHASE_CHANGE_CODE => 'REVISE'
		             ,P_LIFECYCLE_ID      => l_item_lifecycle_id
		             ,X_POLICY_CODE       => l_Policy_Code
		             ,X_RETURN_STATUS     => l_Return_Status
		             ,X_ERRORCODE         => l_Error_Code
		             ,X_MSG_COUNT         => l_Msg_Count
		             ,X_MSG_DATA          => l_Msg_Data);

	                 IF l_Policy_Code <> 'ALLOWED' THEN

		             UPDATE mtl_item_revisions_interface
                             SET process_flag     = l_process_flag_3
		             WHERE rowid          = cr.rowid;
                             status := INVPUOPI.mtl_log_interface_err(
                                        cr.organization_id,
                                        user_id,
                                        login_id,
                                        prog_appid,
                                        prog_id,
                                        request_id,
                                        cr.TRANSACTION_ID,
                                        error_msg,
				       'TRANSACTION_TYPE',
                                       'MTL_ITEM_REVISIONS_INTERFACE',
                                       'INV_IOI_REV_PHASE_CONFLICT',
                                       err_text);
                             if status < 0 then
                                 raise LOGGING_ERR;
                             end if;

		          END IF; -- l_Policy_Code <> 'ALLOWED'
		    END IF;

		   --Revisions cannot be created for unapproved items.
		   --We allow only default revision
		   IF (l_item_trans_type = 'EXISTS' AND l_item_approved <> 'A')
		   OR (l_item_trans_type = 'CREATE' AND INVIDIT3.CHECK_NPR_CATALOG(l_item_catalog))
		   THEN
		      UPDATE mtl_item_revisions_interface
                      SET process_flag     = l_process_flag_3
		      WHERE rowid          = cr.rowid;
                      status := INVPUOPI.mtl_log_interface_err(
                                        cr.organization_id,
                                        user_id,
                                        login_id,
                                        prog_appid,
                                        prog_id,
                                        request_id,
                                        cr.TRANSACTION_ID,
                                        error_msg,
				       'TRANSACTION_TYPE',
                                       'MTL_ITEM_REVISIONS_INTERFACE',
                                       'INV_IOI_UNAPPROVED_ITEM_REV',
                                       err_text);
                      if status < 0 then
                         raise LOGGING_ERR;
                      end if;
		   END IF;

		 END IF; --l_default_rev <> cr.revision
               END IF;
	     END IF;
	      --End:3059993:Revision create should honour items phase policy

        end loop;

        for cr in ff loop

           --2808277: Included trans id , create/update will run under different trans id.
	   -- Cannot update past/current effective dates.
	   IF (cr.transaction_type='UPDATE') THEN

	       l_row_count:= 0;

	       SELECT count(1) INTO l_row_count
	       FROM   mtl_item_revisions_b
	       WHERE  revision_id = cr.revision_id
	       AND  TRUNC(effectivity_date)<= TRUNC(sysdate)
	       AND  TRUNC(effectivity_date) <> TRUNC(cr.effectivity_date);

	       IF (l_row_count > 0) THEN
	          update mtl_item_revisions_interface
                  set process_flag = l_process_flag_3
	          where transaction_id = cr.transaction_id
                  and   set_process_id = xset_id
	          and   revision = cr.revision;--Bug: 2593490

                  status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_REV_DATE_CHANGE_NOTALLOWED',
                                err_text);
                  if status < 0 then
                     raise LOGGING_ERR;
                   end if;
	       END IF;

               --3070781:ECO Rev's update allow on description and rev label.
	       SELECT COUNT(1) INTO l_row_count
	       FROM   mtl_item_revisions_b
	       where  revision_id = cr.revision_id
	       AND    change_notice IS NOT NULL
	       AND    ((cr.ecn_initiation_date is NULL OR ecn_initiation_date <> cr.ecn_initiation_date)
	               OR (effectivity_date <> cr.effectivity_date)
		       OR ((implementation_date IS NULL AND cr.implementation_date IS NOT NULL)
		           OR(implementation_date <> cr.implementation_date)));

	       IF (l_row_count > 0) THEN

	          update mtl_item_revisions_interface
                  set process_flag     = l_process_flag_3
	          where transaction_id = cr.transaction_id
                  and   set_process_id = xset_id
	          and   revision       = cr.revision;--Bug: 2593490

                  status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_REV_ECO_CHANGE_NOTALLOWED',
                                err_text);
                  if status < 0 then
                     raise LOGGING_ERR;
                   end if;
	       END IF;


	   END IF;

           select count(*)
           into    temp_count
           from mtl_item_revisions_interface i
           where  i.organization_id = cr.organization_id
           and   i.inventory_item_id = cr.inventory_item_id
           -- and   i.set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
           and   i.set_process_id = xset_id
	   --and    i.transaction_id     = cr.transaction_id  Commented for bug 5458317
           and  ((i.revision < cr.revision)
	          AND ((TRUNC(i.effectivity_date) = TRUNC(SYSDATE)
		        AND TRUNC(cr.effectivity_date) = TRUNC(SYSDATE)
			AND i.effectivity_date = cr.effectivity_date)
                       OR(i.effectivity_date   >= cr.effectivity_date)))
	    --2861248 : Effective date validation changed
	    --3569925 : Added = condition for > on effectivity dates.
	   /**Bug: 2593490 No need to check with  greater revisions
           or
           ( cr.revision < i.revision and   cr.effectivity_date > i.effectivity_date)
           ***/
            and   i.process_flag = 2 ;

            IF temp_count >= 1 THEN

               update mtl_item_revisions_interface
               set process_flag = l_process_flag_3
	       where transaction_id = cr.transaction_id
               and   set_process_id = xset_id
	       and   revision = cr.revision;--Bug: 2593490

               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVPVALI.validate_item_revs: validation error: conflict with MIRI');
               END IF;
               status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'EFF1',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_BAD_ORDER',
                                err_text);
               if status < 0 then
                  raise LOGGING_ERR;
               end if;
            end if;  -- If temp_count >=1

	    --Start 2806275 : Revision Reason validation
            IF cr.revision_reason IS NOT NULL THEN

	       l_lookup_exist := 'N';

	       OPEN  c_check_lookup(cp_type => 'EGO_ITEM_REVISION_REASON',
	                            cp_code => cr.revision_reason);
	       FETCH c_check_lookup INTO l_lookup_exist;
	       CLOSE c_check_lookup;

	       IF l_lookup_exist <> 'Y' THEN

	          update mtl_item_revisions_interface
                  set process_flag      = l_process_flag_3
	          where transaction_id  = cr.transaction_id
                  and   set_process_id  = xset_id
		  and   revision        = cr.revision;

		  --2885843: Start default revision error propagated to imported item
  		  OPEN  c_get_default_rev(cp_org_id => cr.organization_id);
		  FETCH c_get_default_rev INTO l_default_rev;
		  CLOSE c_get_default_rev;

		  IF  cr.transaction_type ='CREATE'
		  AND l_default_rev = cr.revision THEN

		     UPDATE mtl_system_items_interface
		     SET    process_flag = l_process_flag_3
		     WHERE  inventory_item_id = cr.inventory_item_id
     		     AND    organization_id   = cr.organization_id
		     AND    set_process_id = xset_id;

  		  END IF;
		  --2885843: End default revision error propagated to imported item

                  status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION_REASON',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_INVALID_REV_REASON',
                                err_text);

                  IF status < 0 THEN
                     raise LOGGING_ERR;
                  END IF;

	       END IF; -- l_lookup_exist != 'Y'
            END IF;
	    -- End 2806275 : Revision Reason validation

        end loop;

        for cr in gg loop

                update mtl_item_revisions_interface
                set process_flag = l_process_flag_3
		where rowid = cr.rowid;

                IF l_inv_debug_level IN(101, 102) THEN
                   INVPUTLI.info('INVPVALI.validate_item_revs: validation error: conflict with MIR');
                END IF;

                status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'EFF2',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_BAD_ORDER',
                                err_text);

           if status < 0 then
              raise LOGGING_ERR;
           end if;

        end loop;

      FOR cr in c_get_revision_lifecycle LOOP
         l_lifecycle_error := FALSE;

	 --2808277: Start Revision update changes
	 IF cr.transaction_type = 'UPDATE' THEN
	    SELECT current_phase_id
	    INTO   l_Old_Phase_Id
	    FROM   mtl_item_revisions_b
	    WHERE  revision_id = cr.revision_id;
	 END IF;
	 --2808277: End Revision update changes

         -- Bug: 3769153 -- added OR part
         IF cr.lifecycle_id IS NOT NULL OR cr.current_phase_id IS NOT NULL THEN

            OPEN  c_get_item_ids(cp_org_id  => cr.organization_id,
	                         cp_item_id => cr.inventory_item_id);
	    FETCH c_get_item_ids
 	    INTO l_item_catalog
	        ,l_item_lifecycle_id
	        ,l_item_phase_id
	        ,l_item_approved
	        ,l_item_trans_type;
            CLOSE c_get_item_ids;

            -- Bug: 3769153 - if lifecycle is not specified and phase is specified,
            --   then update the lifecycle of item to the revision
            IF cr.lifecycle_id IS NULL AND l_item_lifecycle_id IS NOT NULL THEN
               update mtl_item_revisions_interface
               set lifecycle_id = l_item_lifecycle_id
               where rowid = cr.rowid;
            END IF;

            -- 3624686 null check incorporated
            IF cr.lifecycle_id <> NVL(l_item_lifecycle_id,-1) THEN
               update mtl_item_revisions_interface
               set process_flag = l_process_flag_3
	       where rowid = cr.rowid;

               l_lifecycle_error := TRUE;

               status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'LIFECYCLE_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_INVALID_LIFECYCLE',
                                err_text);
               IF status < 0 THEN
                    raise LOGGING_ERR;
               END IF;
	    END IF;

	    IF cr.current_phase_id IS NOT NULL THEN
               -- Bug: 3769153 - added NVL in nvl(cr.lifecycle_id, l_item_lifecycle_id)
	       -- Bug 4538382 - NOT chk when control is from PLM:UI for perf
           -- Bug 5218491 - Modified the IF clause : Changed <> to = in the below check
             IF (INSTR(NVL(l_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 )
	     THEN
               IF NOT INV_EGO_REVISION_VALIDATE.Check_LifeCycle_Phase
                                    ( p_lifecycle_id       => nvl(cr.lifecycle_id, l_item_lifecycle_id),
                                      p_lifecycle_phase_id => cr.current_phase_id)
               THEN
                  update mtl_item_revisions_interface
                  set process_flag = l_process_flag_3
   		  where rowid = cr.rowid;

                  l_lifecycle_error := TRUE;

                  status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CURRENT_PHASSE_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_INVALID_PHASE',
                                err_text);
                  IF  status < 0 THEN
                     raise LOGGING_ERR;
                  END IF;
	        ELSE
  	          --Start: 3809876 :Unapproved item rev can have first phase ONLY.
		  IF  (l_item_trans_type = 'EXISTS' AND l_item_approved <> 'A')
		   OR (l_item_trans_type = 'CREATE' AND INVIDIT3.CHECK_NPR_CATALOG(l_item_catalog))
		  THEN
                     IF  cr.current_phase_id <> INV_EGO_REVISION_VALIDATE.Get_Initial_Lifecycle_Phase(nvl(cr.lifecycle_id, l_item_lifecycle_id))
		     THEN
                        update mtl_item_revisions_interface
                        set process_flag = l_process_flag_3
   		        where rowid = cr.rowid;

                        l_lifecycle_error := TRUE;

                        status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CURRENT_PHASSE_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_REV_UNAPPROVED_PHASE',
                                err_text);
                        IF  status < 0 THEN
                           raise LOGGING_ERR;
                        END IF;
		     END IF;
		  END IF;
	          -- End: 3809876 :Unapproved item rev can have first phase ONLY.
                END IF;
             END IF;
	    ELSE --cr.current_phase_id IS NOT NULL THEN
	       --2891650 : Start IOI should not default LC phase.
               update mtl_item_revisions_interface
               set process_flag = l_process_flag_3
	       where rowid = cr.rowid;

	       l_lifecycle_error := TRUE;

               status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CURRENT_PHASSE_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_PHASE_MANDATORY',
                                err_text);
               IF  status < 0 THEN
                     raise LOGGING_ERR;
               END IF;
	       --2891650 : End IOI should not default LC phase.

	    END IF; --Phase id if
          -- Bug 4538382 - NOT chk when control is from PLM:UI for perf
          -- Bug 5218491 - Modified the IF clause : Changed <> to = in the below check
	    IF (INSTR(NVL(l_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 )
	    THEN
	     -- 2808277 : Start Check phase change is allowed or not
	      IF (cr.transaction_type = 'UPDATE')
	         AND (cr.current_phase_id <> l_Old_Phase_Id) THEN

                --EGO Phase change policy called through INV wrapper.
 	        INV_EGO_REVISION_VALIDATE.phase_change_policy
	         (P_ORGANIZATION_ID   => cr.organization_id
		 ,P_INVENTORY_ITEM_ID => cr.inventory_item_id
		 ,P_CURR_PHASE_ID     => l_item_phase_id
		 ,P_FUTURE_PHASE_ID   => cr.current_phase_id
		 ,P_PHASE_CHANGE_CODE => NULL
		 ,P_LIFECYCLE_ID      => cr.lifecycle_id
	 	 ,X_POLICY_CODE       => l_Policy_Code
		 ,X_RETURN_STATUS     => l_Return_Status
		 ,X_ERRORCODE         => l_Error_Code
		 ,X_MSG_COUNT         => l_Msg_Count
		 ,X_MSG_DATA          => l_Msg_Data);

	        IF l_Policy_Code <> 'ALLOWED' THEN

	          update mtl_item_revisions_interface
                  set process_flag = l_process_flag_3
	          where rowid      = cr.rowid;

                  status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
	 			'CURRENT_PHASE_ID',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_PHASE_CHANGE_NOT_VALID',
                                 err_text);
                  IF status < 0 THEN
                     raise LOGGING_ERR;
                  END IF;

	        END IF; --Policy code

              END IF;

	    END IF;
 	    -- 2808277 : End Check phase change is allowed or not
         END IF;    -- cr.lifecycle_id IS NOT NULL OR cr.current_phase_id IS NOT NULL

         --2885843: Start default revision error propagated to imported item
         IF l_lifecycle_error AND cr.transaction_type ='CREATE' THEN

	    OPEN  c_get_default_rev(cp_org_id => cr.organization_id);
	    FETCH c_get_default_rev INTO l_default_rev;
	    CLOSE c_get_default_rev;

	    IF l_default_rev = cr.revision THEN
	       UPDATE mtl_system_items_interface
	       SET    process_flag      = l_process_flag_3
	       WHERE  inventory_item_id = cr.inventory_item_id
     	       AND    organization_id   = cr.organization_id
	       AND    set_process_id    = xset_id;

  	    END IF;
	 END IF;
	 --2885843: End default revision error propagated to imported item

      END LOOP;

      update mtl_item_revisions_interface
      set   process_flag     = l_process_flag_4,
	    revision_label   = NVL(revision_label,revision),
	    revision_id      = NVL(revision_id,MTL_ITEM_REVISIONS_B_S.NEXTVAL) --2808277
      where process_flag     = l_process_flag_2
      and   set_process_id   = xset_id
      and (organization_id   = org_id or all_org = l_all_org);

      return(0);

exception

        when LOGGING_ERR then
	   IF c_check_lookup%ISOPEN THEN
	      CLOSE c_check_lookup;
	   END IF;
           return(status);
        when OTHERS then
	   IF c_check_lookup%ISOPEN THEN
	      CLOSE c_check_lookup;
	   END IF;
           err_text := substr('INVPVALI.validate_item_revs ' || SQLERRM, 1,240);
          return(SQLCODE);

end validate_item_revs;

----------------------------- mtl_pr_validate_item ----------------------------

FUNCTION mtl_pr_validate_item
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER     DEFAULT -999
)
RETURN INTEGER
IS
   status    NUMBER := 0;
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
   l_process_control     VARCHAR2(2000) := NULL; --Used by EGO API only for internal flow control

BEGIN

   l_process_control := INV_EGO_REVISION_VALIDATE.Get_Process_Control;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPVALI: first sta..set_id'||to_char(xset_id)||'org'||to_char(org_id)||'all'||to_char(all_org));
   END IF;

   if (xset_id < 900000000000) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVALM.validate_item_org1');
      END IF;
      status := INVPVALM.validate_item_org1(
		org_id,
		all_org,
		prog_appid,
		prog_id,
		request_id,
		user_id,
		login_id,
		err_text,
                xset_id);
   end if;

   if ( (status = 0) and (xset_id < 900000000000) ) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPALM2.validate_item_org4');
      END IF;
      status := INVPVLM2.validate_item_org4(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);
   end if;

   if ( status = 0 and xset_id < 900000000000 ) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVLM3.validate_item_org7');
      END IF;
      status := INVPVLM3.validate_item_org7(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
			xset_id);
   end if;

   --Start : Check for data security and user privileges
   if (status = 0) then
     -- Bug 4538382 - NOT chk when control is from PLM:UI for perf
     -- Bug 5218491 - Modified the IF clause : Changed <> to = in the below check
     IF (INSTR(NVL(l_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 )
     THEN
       IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('INVPVALI.mtl_pr_validate_item: before INV_EGO_REVISION_VALIDATE.validate_item_user_privileges');
       END IF;

       status := INV_EGO_REVISION_VALIDATE.validate_item_user_privileges(
			 P_Org_Id     => org_id
			,P_All_Org    => all_org
			,P_Prog_AppId => prog_appid
			,P_Prog_Id    => prog_id
			,P_Request_Id => request_id
			,P_User_Id    => user_id
			,P_Login_Id   => login_id
			,P_Set_Id     => xset_id
			,X_Err_Text   => err_text);

        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVALI.mtl_pr_validate_item: INV_EGO_REVISION_VALIDATE.validate_item_user_privileges');
        END IF;
      END IF;
    end if;
   --End : Check for data security and user privileges

   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVHDR.validate_item_header'||to_char(xset_id)||'org'||to_char(org_id)||'all'||to_char(all_org));
      END IF;
      status := INVPVHDR.validate_item_header(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);
   end if;

   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVDR2.validate_item_header2');
      END IF;

      status := INVPVDR2.validate_item_header2(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);
   end if;

   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVDR3.validate_item_header3');
      END IF;

      status := INVPVDR3.validate_item_header3(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);
   end if;

   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVDR4.validate_item_header4');
      END IF;


      status := INVPVDR4.validate_item_header4(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);
   end if;

   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI: before INVPVDR5.validate_item_header5');
      END IF;

      status := INVPVDR5.validate_item_header5(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);
   end if;

   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: before INVPVDR6.validate_item_header6');
      END IF;
      status := INVPVDR6.validate_item_header6 (
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: after INVPVDR6.validate_item_header6');
      END IF;
   end if;


   /* Start Bug 3713912 */
   if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: before INVPVDR7.validate_item_header7');
      END IF;

      status := INVPVDR7.validate_item_header7 (
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id);

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: after INVPVDR7.validate_item_header7');
      END IF;
   end if;
   /* End Bug 3713912 */


   -- Start 2777118 : Lifecycle and Phase validations for IOI
   IF (status = 0) THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: before INV_EGO_REVISION_VALIDATE.validate_items_lifecycle');
      END IF;
      status := INV_EGO_REVISION_VALIDATE.validate_items_lifecycle(
			 P_Org_Id     => org_id
			,P_All_Org    => all_org
			,P_Prog_AppId => prog_appid
			,P_Prog_Id    => prog_id
			,P_Request_Id => request_id
			,P_User_Id    => user_id
			,P_Login_Id   => login_id
			,P_Set_Id     => xset_id
			,X_Err_Text   => err_text);

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: INV_EGO_REVISION_VALIDATE.validate_items_lifecycle');
      END IF;
    END IF;
   -- End 2777118 : Lifecycle and Phase validations for IOI



   -- validate item revisions

--Bug:3531430 Validate Item revs irrespective of item is succeeded or not.
-- if (status = 0) then

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: before validate_item_revs');
      END IF;

      status := INVPVALI.validate_item_revs (
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
                        xset_id );

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVALI.mtl_pr_validate_item: after validate_item_revs');
      END IF;

--   end if;
     IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('INVPVALI.mtl_pr_validate_item: before validate_items_catalog_group');
     END IF;

      --5208102
     INV_EGO_REVISION_VALIDATE.Insert_Revision_UserAttr(P_Set_id=>xset_id);

   RETURN (status);

EXCEPTION

   when OTHERS then
      err_text := substr('INVPVALI.mtl_pr_validate_item ' || SQLERRM, 1,240);
      return(SQLCODE);

END mtl_pr_validate_item;


END INVPVALI;

/
