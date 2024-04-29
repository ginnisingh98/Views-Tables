--------------------------------------------------------
--  DDL for Package Body CSC_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PARTY_MERGE_PKG" AS
/* $Header: cscvmptb.pls 115.8 2004/04/28 08:09:51 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate parties in Customer Care tables. The
--                    Customer Care table that need to be considered for
--                    Party Merge are:
--                    CSC_CUSTOMERS,              CSC_CUSTOMERS_AUDIT_HIST,
--                    CSC_CUSTOMIZED_PLANS,       CSC_CUST_PLANS,
--                    CSC_CUST_PLANS_AUDIT
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-10-2000    dejoseph      Created.
-- 10-25-2001    dejoseph      Made the following corrections:
--                             -- Replaced calls to arp_message with fnd_file.put_line
--                             -- Removed logic to stop merge for CSC_CUSTOMERS
--                             -- Added logic for CSC_CUSTOMERS to handle cases where
--                                only the From or To party exists in the table.
--                             -- Does not return an error status for any reason. Instead
--                                prg. logs an error and returns control so that
--                                execution can continue for the other products.
--                             -- Included the dbdrv command for the auto db driver.
-- 10-31-2001   dejoseph       Corrected the update statement in the condition where the
--                             to party does not exist from 'where party_id = p_to_fk_id'
--                             to 'where party_id = p_from_fk_id'.
--                             Ref. Bug # 2090117.
-- 13-JUN-2003	bhroy		Audit table was not entering correct data, Ref. Bug# 2919377
-- 26-JUN-2003	bhroy		Corrected end date for transferred plans, Ref. Bug# 2919469
-- 03-FEB-2004	bhroy		Corrected update of Critical Customer Audit History table, Ref. Bug# 3404893
-- 04-FEB-2004	bhroy		Corrected Account transfer in case of Party merge, Ref. Bug# 3408084
-- 28-APR-2004	bhroy		Corrected update of Critical Customer table, trunc(SYSDATE) Ref. Bug# 3589317
--
-- End of Comments
-- GLOBAL VARIABLE TO STORE REQUEST_ID and MERGE_REASON_CODE OF CURRENT MERGE BATCH
G_REQUEST_ID           NUMBER(15)    := TO_NUMBER(NULL);
G_MERGE_REASON_CODE    VARCHAR2(30)  := NULL;
G_MERGE_PLAN           VARCHAR2(10)  := CSC_CORE_UTILS_PVT.MERGE_PLAN;
G_TRANSFER_PLAN        VARCHAR2(10)  := CSC_CORE_UTILS_PVT.TRANSFER_PLAN;

PROCEDURE get_hz_merge_batch (
    p_batch_id                   IN   NUMBER )
IS
BEGIN
   select request_id           , merge_reason_code
   into   G_REQUEST_ID         , G_MERGE_REASON_CODE
   from   hz_merge_batch
   where  batch_id = p_batch_id;

EXCEPTION
   when others then
	 G_REQUEST_ID          := TO_NUMBER(NULL);
	 G_MERGE_REASON_CODE   := NULL;
END;

PROCEDURE CSC_CUSTOMERS_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   csc_customers
   where  party_id = p_from_fk_id
   for    update nowait;

   cursor get_from_pty is
   select override_flag               from_override_flag,
		overridden_critical_flag    from_overridden_critical_flag,
		rowid                       from_rowid,
		cust_account_id             from_cust_account_id,
		overridden_critical_flag    from_overridden_critical_flag,
		override_reason_code        from_override_reason_code
   from   csc_customers
   where  party_id     = p_from_fk_id;

   cursor get_to_pty is
   select override_flag               to_override_flag,
		overridden_critical_flag    to_overridden_critical_flag
   from   csc_customers
   where  party_id     = p_to_fk_id;

   G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CSC_PARTY_MERGE_PKG';
   G_FILE_NAME        CONSTANT  VARCHAR2(12)  := 'cscvmpts.pls';
   G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
   G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.CONC_LOGIN_ID;

   l_api_name                            VARCHAR2(30) := 'CSC_CUSTOMERS_MERGE';
   l_count                               NUMBER(10)   := 0;
   l_to_override_flag                    VARCHAR2(3);
   l_from_override_flag                  VARCHAR2(3);
   l_to_critical_flag                    VARCHAR2(3);
   l_from_critical_flag                  VARCHAR2(3);
   l_from_rowid                          VARCHAR2(2000);
   l_from_cust_account_id                NUMBER(15);
   l_from_overridden_crit_flag           VARCHAR2(3);
   l_from_override_reason_code           VARCHAR2(30);

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

   g_mesg                       VARCHAR2(1000) := '';

BEGIN

   g_mesg := 'CSC_PARTY_MERGE_PKG.CSC_CUSTOMERS_MERGE';
   fnd_file.put_line(fnd_file.log, g_mesg);

   x_return_status := CSC_CORE_UTILS_PVT.G_RET_STS_SUCCESS;

   if (g_merge_reason_code is null) then
	 get_hz_merge_batch(
	    p_batch_id         => p_batch_id);
   end if;

   if G_MERGE_REASON_CODE = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return
   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      g_mesg := 'To and From Parties are the same. Merge not required.';
      fnd_file.put_line(fnd_file.log, g_mesg);
      return;
   end if;

   -- Please ignore the following comments. Parties in CSC_CUSTOMERS will be
   -- allowed to merge always, ir-respective of the criticality of the From
   -- or To party.
/* ignore comments section
   -- The following are the scenarios that are to be considered when merging
   -- parties in the CSC_CUSTOMERS table. If Party A is merging with Party B,
   -- then these are the following scenarios and their merge outcomes.
   -- (OSa => Over-ride state of party A) (values are off column OVERRIDE_FLAG)
   --    Party A   Party B        Allow Merge or Not
   --   ------------------------------------------------------------------------
   --      Y         N      Do not allow if OSa='Critical', else allow
   --      Y         Y      Allow if OSa=OSb or OSa IN (not critical, system determined)
   --                       else do not allow
   --      N         N      Always allow
   --      N         Y      Always allow
end ignore comments section */

   open get_from_pty;
   fetch get_from_pty into l_from_override_flag        ,  l_from_critical_flag,
			   l_from_rowid                ,  l_from_cust_account_id,
			   l_from_overridden_crit_flag ,  l_from_override_reason_code;

   -- If the From party is not found in CSC_CUSTOMERS, then the merge process need not be
   -- performed, coz there is no party to merge.

   if ( get_from_pty%NOTFOUND ) then
      close get_from_pty;
      g_mesg := 'From party not defined in CSC_CUSTOMERS. Merge not required.';
      fnd_file.put_line(fnd_file.log, g_mesg);
      return;
   end if;

   close get_from_pty;

   open get_to_pty;
   fetch get_to_pty into   l_to_override_flag          , l_to_critical_flag;

   -- if the To party does not exist in CSC_CUSTOMERS, then update the 'from' party_id
   -- of CSC_CUSTOMERS to the 'to' party id and insert a record into the audit table
   -- recording the operation.

   if ( get_to_pty%NOTFOUND ) then
      close get_to_pty;

      begin
	 update csc_customers
         set    party_id               = p_to_fk_id,
                last_update_date       = trunc(SYSDATE),
                last_updated_by        = G_USER_ID,
                last_update_login      = G_LOGIN_ID,
                request_id             = G_REQUEST_ID,
                program_application_id = ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
                program_id             = ARP_STANDARD.PROFILE.PROGRAM_ID,
                program_update_date    = trunc(SYSDATE)
         where  party_id = p_from_fk_id;

         insert into csc_customers_audit_hist (
	    cust_hist_id,                         party_id,             last_update_date,
	    last_updated_by,                      last_update_login,    creation_date,
	    created_by,                           changed_date,         changed_by,
	    sys_det_critical_flag,                override_flag,        overridden_critical_flag,
	    override_reason_code,                 request_id,
	    program_application_id,
	    program_id,                           program_update_date)
         values (
	    csc_customers_audit_hist_s.nextval,   p_to_fk_id,         sysdate,
            g_user_id,                            g_login_id,           sysdate,
	    g_user_id,                            sysdate,              g_user_id,
	    'N',                                  l_from_override_flag, l_from_overridden_crit_flag,
	    l_from_override_reason_code ,         G_REQUEST_ID,
	    ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	    ARP_STANDARD.PROFILE.PROGRAM_ID,      SYSDATE );

         return;
      exception
	 when others then
	    g_mesg := substr('To party does not exist; The following SQL error occured : '
			      || sqlerrm,1,1000);
            fnd_file.put_line(fnd_file.log, g_mesg);
	    return;
      end;
   end if;

   close get_to_pty;

/**** do not perform any check to stop the merge process. Merge in CSC_CUSTOMERS
      will always happen.

   IF (   (     ( l_from_override_flag = 'Y' and l_to_override_flag = 'N' )
	       AND ( l_from_critical_flag <> 'N' ) )
       OR (     ( l_from_override_flag = 'Y' and l_to_override_flag = 'Y' )
		  AND ( (      l_from_critical_flag = l_to_critical_flag
			     or   l_from_critical_flag = 'N' ) ) )
       OR ( l_from_override_flag = 'N' and l_to_override_flag = 'N')
	  OR ( l_from_override_flag = 'N' and l_to_override_flag = 'Y' ) )
   THEN
*****/
      -- If the parent has changed(id. Parent is getting merged) then transfer the
      -- dependent record to the new parent. Before transferring check if a similar
      -- dependent record exists on the new parent. If a duplicate exists then do
      -- not transfer and return the id of the duplicate record as the Merged To Id

      -- In the case of the table CSC_CUSTOMERS there will not be a situation to
      -- check for duplicates because, the column party_id, which is going to be
      -- merged/transferred, itself is the primary key for the table.
	 -- Hence, we cannot update the party_id in this table. Instead, set the
	 -- party_status of the merge from party to 'M' (Merged); this record will
	 -- not be shown in the CSC_CUSTOMERS views.

      if p_from_fk_id <> p_to_fk_id then
         begin

	    open  c1;
	    close c1;


            csc_customers_pkg.update_row (
			x_rowid                      => l_from_rowid,
			x_party_id                   => p_from_fk_id,
			x_cust_account_id            => l_from_cust_account_id,
			x_last_update_date           => SYSDATE,
			x_last_updated_by            => G_USER_ID,
			x_last_update_login          => G_LOGIN_ID,
			x_creation_date              => SYSDATE, -- value used for audit table purposes
			x_created_by                 => G_USER_ID, -- value used for audit table purposes
			x_sys_det_critical_flag      => 'N', -- value not changed in update stmt. in pkg
			x_override_flag              => l_from_override_flag,
			x_overridden_critical_flag   => l_from_overridden_crit_flag,
			x_override_reason_code       => l_from_override_reason_code,
	                p_party_status               => 'M',
	                p_request_id                 => G_REQUEST_ID,
			p_program_application_id     => ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	                p_program_id                 => ARP_STANDARD.PROFILE.PROGRAM_ID,
	                p_program_update_date        => SYSDATE );

         exception
	       when resource_busy then
	          -- x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_ERROR;
		  g_mesg := 'Could not obtain lock for records in table CSC_CUSTOMERS. Please '
			    || 'retry the Merge operation later.';
                  fnd_file.put_line(fnd_file.log, g_mesg);
	          --arp_message.set_line(g_proc_name || '.' || l_api_name ||
		          --'; Could not obtain lock for records in table '  ||
			     --'CSC_CUSTOMERS for party_id = ' || p_from_fk_id );
	          raise;

            when others then
	          -- x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_ERROR;
		  g_mesg := substr(g_proc_name || '.' || l_api_name || ' : ' || sqlerrm,1,1000);
                  fnd_file.put_line(fnd_file.log, g_mesg);
	          --arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
	          raise;
         end;
      end if;
   /***
   ELSE
	 x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_ERROR;
	 g_mesg := 'Merge not allowed. Please check criticality of merging parties';
         fnd_file.put_line(fnd_file.log, g_mesg);
	 --arp_message.set_line(g_proc_name || '.' || l_api_name ||
		 --'; Merge not allowed. Please check criticality of merging parties');
      return;
   END IF;
   ***/
EXCEPTION
   WHEN OTHERS THEN
      g_mesg := substr(g_proc_name || '.' || l_api_name || ' : ' || sqlerrm,1,1000);
      fnd_file.put_line(fnd_file.log, g_mesg);
      raise;

END CSC_CUSTOMERS_MERGE;


PROCEDURE CSC_CUST_PLANS_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS

   cursor c1 is
   select 1
   from   csc_cust_plans
   where  party_id = p_from_fk_id
   for    update nowait;

   G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CSC_PARTY_MERGE_PKG';
   G_FILE_NAME        CONSTANT  VARCHAR2(12)  := 'cscvmpts.pls';
   G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
   G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.CONC_LOGIN_ID;

   l_api_name                   VARCHAR2(30) := 'CSC_CUST_PLANS_MERGE';
   l_count                      NUMBER(10)   := 0;
   audit_count                  NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

    g_mesg                      VARCHAR2(1000) := '';

BEGIN
   --arp_message.set_line('CSC_PARTY_MERGE_PKG.CSC_CUST_PLANS_MERGE()+');
   g_mesg := 'CSC_PARTY_MERGE_PKG.CSC_CUST_PLANS_MERGE';
   fnd_file.put_line(fnd_file.log, g_mesg);

   x_return_status := CSC_CORE_UTILS_PVT.G_RET_STS_SUCCESS;

   if (g_merge_reason_code is null) then
	 get_hz_merge_batch(
	    p_batch_id         => p_batch_id);
   end if;

   if G_MERGE_REASON_CODE = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id as same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      g_mesg := 'To and From Parties are the same. Merge not required.';
      fnd_file.put_line(fnd_file.log, g_mesg);
      return;
   end if;

   -- If the parent has changed(id. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
	 open  c1;
	 close c1;

	 -- NOTE : If update performance is bad...then consider acheiving the same
	 --        logic thru the use of cursors..updating records individually.
	 -- Perform transfer if duplicate plans do not exist between the TO and FROM
	 -- parties
-- Bug# 2919377, if plan is transfered then one record will be inserted for
-- p_to_fk_id with status transferred, one record will be inserted for
-- p_from_fk_id with status merged.Update the Audit table first in case of plan transfer.
         insert into csc_cust_plans_audit (
	       plan_audit_id,                   plan_id,                party_id,    cust_account_id,
	       plan_status_code,                request_id,             creation_date,
	       created_by,                      last_update_date,       last_updated_by,
	       last_update_login,               program_application_id,
	       program_id,                      program_update_date,    object_version_number )
	    select
	       csc_cust_plans_audit_s.nextval,  plan_id,                 p_to_fk_id, cust_account_id,
	       G_TRANSFER_PLAN,                 G_REQUEST_ID,            SYSDATE,
	       G_USER_ID,                       SYSDATE,                 G_USER_ID,
	       G_LOGIN_ID,                      ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	       ARP_STANDARD.PROFILE.PROGRAM_ID, SYSDATE,                 1
         from csc_cust_plans
	    where party_id     = p_from_fk_id
	    and   cust_account_id   is   not null;
	 audit_count := sql%rowcount;

         insert into csc_cust_plans_audit (
	       plan_audit_id,                   plan_id,                party_id,    cust_account_id,
	       plan_status_code,                request_id,             creation_date,
	       created_by,                      last_update_date,       last_updated_by,
	       last_update_login,               program_application_id,
	       program_id,                      program_update_date,    object_version_number )
	    select
	       csc_cust_plans_audit_s.nextval,  plan_id,                 p_to_fk_id, cust_account_id,
	       G_TRANSFER_PLAN,                 G_REQUEST_ID,            SYSDATE,
	       G_USER_ID,                       SYSDATE,                 G_USER_ID,
	       G_LOGIN_ID,                      ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	       ARP_STANDARD.PROFILE.PROGRAM_ID, SYSDATE,                 1
         from csc_cust_plans
	    where party_id     = p_from_fk_id and cust_account_id is null
	    and   plan_id      not in ( select plan_id
					            from   csc_cust_plans
					            where  party_id = p_to_fk_id );
	 audit_count := audit_count+sql%rowcount;

         insert into csc_cust_plans_audit (
	       plan_audit_id,                   plan_id,                party_id,    cust_account_id,
	       plan_status_code,                request_id,             creation_date,
	       created_by,                      last_update_date,       last_updated_by,
	       last_update_login,               program_application_id,
	       program_id,                      program_update_date,    object_version_number )
	    select
	       csc_cust_plans_audit_s.nextval,  plan_id,                 p_from_fk_id, cust_account_id,
	       G_MERGE_PLAN,                 G_REQUEST_ID,            SYSDATE,
	       G_USER_ID,                       SYSDATE,                 G_USER_ID,
	       G_LOGIN_ID,                      ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	       ARP_STANDARD.PROFILE.PROGRAM_ID, SYSDATE,                 1
         from csc_cust_plans
	    where party_id     = p_from_fk_id
	    and   cust_account_id  is  not null;
	 audit_count := audit_count+sql%rowcount;

         insert into csc_cust_plans_audit (
	       plan_audit_id,                   plan_id,                party_id,    cust_account_id,
	       plan_status_code,                request_id,             creation_date,
	       created_by,                      last_update_date,       last_updated_by,
	       last_update_login,               program_application_id,
	       program_id,                      program_update_date,    object_version_number )
	    select
	       csc_cust_plans_audit_s.nextval,  plan_id,                 p_from_fk_id, cust_account_id,
	       G_MERGE_PLAN,                 G_REQUEST_ID,            SYSDATE,
	       G_USER_ID,                       SYSDATE,                 G_USER_ID,
	       G_LOGIN_ID,                      ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	       ARP_STANDARD.PROFILE.PROGRAM_ID, SYSDATE,                 1
         from csc_cust_plans
	    where party_id     = p_from_fk_id and cust_account_id is null
	    and   plan_id      not in ( select plan_id
					            from   csc_cust_plans
					            where  party_id = p_to_fk_id );
	 audit_count := audit_count+sql%rowcount;

	 update csc_cust_plans
	 set    party_id                = p_to_fk_id,
		plan_status_code        = G_TRANSFER_PLAN,
		request_id              = G_REQUEST_ID,
--	        end_date_active         = SYSDATE,
	        last_update_date        = SYSDATE,
	        last_updated_by         = G_USER_ID,
	        last_update_login       = G_LOGIN_ID,
		program_application_id  = ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	        program_id              = ARP_STANDARD.PROFILE.PROGRAM_ID,
	        program_update_date     = SYSDATE,
	        object_version_number   = object_version_number + 1
         where  party_id   = p_from_fk_id
	 and    cust_account_id is   not null;
	 l_count := sql%rowcount;

	 update csc_cust_plans
	 set    party_id                = p_to_fk_id,
		plan_status_code        = G_TRANSFER_PLAN,
		request_id              = G_REQUEST_ID,
--	        end_date_active         = SYSDATE,
	        last_update_date        = SYSDATE,
	        last_updated_by         = G_USER_ID,
	        last_update_login       = G_LOGIN_ID,
		program_application_id  = ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	        program_id              = ARP_STANDARD.PROFILE.PROGRAM_ID,
	        program_update_date     = SYSDATE,
	        object_version_number   = object_version_number + 1
         where  party_id   = p_from_fk_id and cust_account_id is null
	 and    plan_id    not in ( select plan_id
				    from   csc_cust_plans
				    where  party_id = p_to_fk_id );

	 l_count := l_count+sql%rowcount;

         g_mesg := 'Number of CSC_CUST_PLANS records transferred = ' || to_char(l_count) ;
         fnd_file.put_line(fnd_file.log, g_mesg);

	 --arp_message.set_line('Number of CSC_CUST_PLANS records transferred = ' ||
	 --to_char(sql%rowcount) );


	 if ( ( l_count > 0 ) AND (audit_count > 0) ) then
         g_mesg := 'Number of CSC_CUST_PLANS_AUDIT records inserted coresponding to the '
		   || 'CSC_CUST_PLANS records transferred = ' || to_char(audit_count) ;
         fnd_file.put_line(fnd_file.log, g_mesg);
	end if;

--	 if ( l_count > 0 ) then
 --        insert into csc_cust_plans_audit (
--	       plan_audit_id,                   plan_id,                party_id,
--	       plan_status_code,                request_id,             creation_date,
--	       created_by,                      last_update_date,       last_updated_by,
--	       last_update_login,               program_application_id,
--	       program_id,                      program_update_date,    object_version_number )
--	    select
--	       csc_cust_plans_audit_s.nextval,  plan_id,                 p_to_fk_id,
--	       G_TRANSFER_PLAN,                 G_REQUEST_ID,            SYSDATE,
--	       G_USER_ID,                       SYSDATE,                 G_USER_ID,
--	       G_LOGIN_ID,                      ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
--	       ARP_STANDARD.PROFILE.PROGRAM_ID, SYSDATE,                 1
 --        from csc_cust_plans
--	    where party_id     = p_from_fk_id
--	    and   plan_id      not in ( select plan_id
--					            from   csc_cust_plans
--					            where  party_id = p_to_fk_id );

 --        g_mesg := 'Number of CSC_CUST_PLANS_AUDIT records inserted coresponding to the '
--		   || 'CSC_CUST_PLANS records transferred = ' || to_char(sql%rowcount) ;
 --        fnd_file.put_line(fnd_file.log, g_mesg);

	 --arp_message.set_line('Number of CSC_CUST_PLANS_AUDIT records inserted ' ||
         --'coresponding to the CSC_CUST_PLANS records ' ||
         --'transferred = ' || to_char(sql%rowcount) );

  --    end if;

	 -- Perform merge if duplicate plans exist between the TO and FROM
	 -- parties
	 update csc_cust_plans
	 set    plan_status_code        = G_MERGE_PLAN,
		end_date_active         = SYSDATE,
		request_id              = G_REQUEST_ID,
                last_update_date        = SYSDATE,
                last_updated_by         = G_USER_ID,
                last_update_login       = G_LOGIN_ID,
		program_application_id  = ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	        program_id              = ARP_STANDARD.PROFILE.PROGRAM_ID,
	        program_update_date     = SYSDATE,
                object_version_number   = object_version_number + 1
         where  party_id   = p_from_fk_id
	 and    plan_id    in ( select plan_id
			        from   csc_cust_plans
			        where  party_id = p_to_fk_id );

	 l_count := sql%rowcount;

	 g_mesg := 'Number of CSC_CUST_PLANS records merged = ' || to_char(l_count) ;
         fnd_file.put_line(fnd_file.log, g_mesg);

	 --arp_message.set_line('Number of CSC_CUST_PLANS records merged = ' ||
	 --to_char(sql%rowcount) );

-- Bug# 2919377, insert a record for FROM party with MERGE flag
	 if ( sql%rowcount > 0 ) then
            insert into csc_cust_plans_audit (
	       plan_audit_id,                   plan_id,                party_id,
	       plan_status_code,                request_id,             creation_date,
	       created_by,                      last_update_date,       last_updated_by,
	       last_update_login,               program_application_id,
	       program_id,                      program_update_date,    object_version_number )
	    select
	       csc_cust_plans_audit_s.nextval,  plan_id,                 p_from_fk_id,
	       G_MERGE_PLAN,                    G_REQUEST_ID,            SYSDATE,
	       G_USER_ID,                       SYSDATE,                 G_USER_ID,
	       G_LOGIN_ID,                      ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	       ARP_STANDARD.PROFILE.PROGRAM_ID, SYSDATE,                 1
            from  csc_cust_plans
	    where party_id     = p_from_fk_id
	    and   plan_id      in ( select plan_id
			            from   csc_cust_plans
				    where  party_id = p_to_fk_id );

	    g_mesg := 'Number of CSC_CUST_PLANS_AUDIT records inserted coresponding to the '
		      || 'CSC_CUST_PLANS records merged = ' || to_char(sql%rowcount) ;
            fnd_file.put_line(fnd_file.log, g_mesg);
	    --arp_message.set_line('Number of CSC_CUST_PLANS_AUDIT records inserted ' ||
	    --'coresponding to the CSC_CUST_PLANS records ' ||
	    --'merged = ' || to_char(sql%rowcount) );
      end if;
   end if;

EXCEPTION
   when RESOURCE_BUSY then
      -- x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_ERROR;
      g_mesg := substr(g_proc_name || '.' || l_api_name || '; Could not obtain lock for '
		       || 'records in table CSC_CUST_PLANS for party_id = ' || p_from_fk_id
		       || sqlerrm, 1, 1000);
      fnd_file.put_line(fnd_file.log, g_mesg);

      --arp_message.set_line(g_proc_name || '.' || l_api_name ||
      --'; Could not obtain lock for records in table '  ||
      --'CSC_CUST_PLANS for party_id = ' || p_from_fk_id );
      raise;

   when OTHERS then
      --x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_UNEXP_ERROR;
      g_mesg := substr(g_proc_name || '.' || l_api_name || ': ' || sqlerrm,1,1000);
      fnd_file.put_line(fnd_file.log, g_mesg);

      --arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
      raise;

END CSC_CUST_PLANS_MERGE;


PROCEDURE CSC_CUSTOMIZED_PLANS_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS

   cursor c1 is
   select 1
   from   csc_customized_plans
   where  party_id = p_from_fk_id
   for    update nowait;

   G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CSC_PARTY_MERGE_PKG';
   G_FILE_NAME        CONSTANT  VARCHAR2(12)  := 'cscvmpts.pls';
   G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
   G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.CONC_LOGIN_ID;

   l_api_name                   VARCHAR2(30) := 'CSC_CUSTOMIZED_PLANS_MERGE';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

   g_mesg                       VARCHAR2(1000) := '';

BEGIN
   --arp_message.set_line('CSC_PARTY_MERGE_PKG.CSC_CUSTOMIZED_PLANS_MERGE()+');
   g_mesg := 'CSC_PARTY_MERGE_PKG.CSC_CUSTOMIZED_PLANS_MERGE';
   fnd_file.put_line(fnd_file.log, g_mesg);

   x_return_status := CSC_CORE_UTILS_PVT.G_RET_STS_SUCCESS;

   if (g_merge_reason_code is null) then
	 get_hz_merge_batch(
	    p_batch_id         => p_batch_id);
   end if;

   if G_MERGE_REASON_CODE = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id as same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      g_mesg := 'To and From Parties are the same. Merge not required.';
      fnd_file.put_line(fnd_file.log, g_mesg);
      return;
   end if;

   -- If the parent has changed(id. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      -- obtain lock on records to be updated.
	 open  c1;
	 close c1;

	 -- NOTE : If update performance is bad...then consider acheiving the same
	 --        logic thru the use of cursors..updating records individually.

	 -- Perform transfer if duplicate plans do not exist between the TO and FROM
	 -- parties

	 update csc_customized_plans
	 set    party_id                = p_to_fk_id,
		request_id              = G_REQUEST_ID,
		program_application_id  = ARP_STANDARD.PROFILE.PROGRAM_APPLICATION_ID,
	        program_id              = ARP_STANDARD.PROFILE.PROGRAM_ID,
	        program_update_date     = SYSDATE,
		plan_status_code        = G_TRANSFER_PLAN
         where  party_id                = p_from_fk_id
	 and    plan_id    not in ( select plan_id
				    from   csc_customized_plans
				    where  party_id = p_to_fk_id );

	 l_count := sql%rowcount;

	 g_mesg := 'Number of CSC_CUSTOMIZED_PLANS records transferred = ' || to_char(l_count) ;
         fnd_file.put_line(fnd_file.log, g_mesg);

	 --arp_message.set_line('Number of CSC_CUSTOMIZED_PLANS records transferred = ' ||
	 --to_char(sql%rowcount) );

	 -- Delete records if duplicate customized plans exist between the TO
	 -- and FROM parties.
	 -- The delete operation is being performed temperorily until some additional
	 -- columns are added to the CSC_CUSTOMIZED_PLANS table to denote the merge
	 -- or transfer operation.

      delete from csc_customized_plans
      where  party_id   =  p_from_fk_id
      and    plan_id    in ( select plan_id
			     from   csc_customized_plans
			     where  party_id = p_to_fk_id );

      l_count := sql%rowcount;

      g_mesg := 'Number of CSC_CUSTOMIZED_PLANS records deleted = ' || to_char(l_count);
      fnd_file.put_line(fnd_file.log, g_mesg);

      --arp_message.set_line('Number of CSC_CUSTOMIZED_PLANS records deleted = ' ||
      --to_char(sql%rowcount) );

   end if;

EXCEPTION
   when RESOURCE_BUSY then
      -- x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_ERROR;
      g_mesg := g_proc_name || '.' || l_api_name || '; Could not obtain lock for '
		|| 'records in table CSC_CUSTOMIZED_PLANS for party_id = '
		|| p_from_fk_id;
      fnd_file.put_line(fnd_file.log, g_mesg);

      --arp_message.set_line(g_proc_name || '.' || l_api_name ||
      --'; Could not obtain lock for records in table '  ||
      --'CSC_CUSTOMIZED_PLANS for party_id = ' || p_from_fk_id );
      raise;

   when OTHERS then
      -- x_return_status  := CSC_CORE_UTILS_PVT.G_RET_STS_UNEXP_ERROR;
      g_mesg := substr( g_proc_name || '.' || l_api_name || ': ' || sqlerrm, 1, 1000 );
      fnd_file.put_line(fnd_file.log, g_mesg);
      -- arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
      raise;

END CSC_CUSTOMIZED_PLANS_MERGE;


END  CSC_PARTY_MERGE_PKG;

/
