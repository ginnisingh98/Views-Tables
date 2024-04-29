--------------------------------------------------------
--  DDL for Package Body CSI_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PARTY_MERGE_PKG" AS
/* $Header: csipymgb.pls 120.1.12010000.2 2009/08/12 04:05:31 jgootyag ship $ */

G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CSI_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

PROCEDURE CSI_ITEM_INSTANCES_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   v_location_type_code         VARCHAR2(30) := 'HZ_PARTY_SITES';
   v_install_location_type_code VARCHAR2(30) := 'HZ_PARTY_SITES';
   v_owner_party_source_table   VARCHAR2(30) := 'HZ_PARTIES';
   v_source_transaction_type    VARCHAR2(30) := 'PARTY_MERGE';

   cursor c1 is
   select 1
   from   csi_item_instances
   where  owner_party_id = p_from_fk_id
   and    owner_party_source_table = v_owner_party_source_table
   for    update nowait;

   cursor c2 is
   select 1
   from   csi_item_instances
   where  ( install_location_type_code = v_install_location_type_code and install_location_id = p_from_fk_id ) or
          ( location_type_code         = v_install_location_type_code and location_id         = p_from_fk_id )
   for    update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CSI_ITEM_INSTANCES_MERGE';
   l_column_name                VARCHAR2(30);
   l_count                      NUMBER(10)   := 0;
   l_cp_audit_id                NUMBER;
   v_transaction_type_id        NUMBER;
   v_transaction_id             NUMBER;
   v_no_of_rows                 NUMBER;
   v_error_message              varchar2(255);
   v_internal_party_message     varchar2(255);
   v_txn_type_not_found_msg     varchar2(255);
   v_instance_history_id        NUMBER;
   v_internal_party_id          NUMBER;
   internal_party_error         EXCEPTION;
   txn_type_not_found_error     EXCEPTION;
   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);
BEGIN
   arp_message.set_line('CSI_PARTY_MERGE_PKG.CSI_ITEM_INSTANCES_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   begin
      select internal_party_id
      into   v_internal_party_id
      from   csi_install_parameters;
   exception
      when no_data_found then
         v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. Data exists in Installed Base, but Install Parameters are not defined';
         raise internal_party_error;
      when others then
         arp_message.set_line(g_proc_name || '.' ||l_api_name || ': ' ||sqlerrm);
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         raise;
   end;

   if v_internal_party_id = p_from_fk_id or
      v_internal_party_id = p_to_fk_id
   then
      v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. One of the party ids is defined as internal party in CSI-Installed Base';
      raise internal_party_error;
   end if;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to
      -- happen without any validations.
      null;
   else
      -- if there are any validations to be done, include it in this section
      null;
   end if;

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
   end if;

   IF p_from_fk_id <> p_to_fk_id then
      BEGIN
         If p_parent_entity_name = 'HZ_PARTIES' Then

            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CSI_ITEM_INSTANCES', FALSE);

            l_column_name := 'owner_party_id';

            open  c1;
	    close c1;

            update csi_item_instances
            set    owner_party_id    = p_to_fk_id,
                   last_update_date  = SYSDATE,
                   last_updated_by   = G_USER_ID,
                   last_update_login = G_LOGIN_ID
            where  owner_party_id           = p_from_fk_id
            and    owner_party_source_table = v_owner_party_source_table;

            l_count := sql%rowcount;

            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
            arp_message.set_token('NUM_ROWS', to_char(l_count) );

         Elsif p_parent_entity_name = 'HZ_PARTY_SITES' Then

            /* insert record into transaction table */
            v_no_of_rows := 0;

            Begin

               Begin
                  SELECT transaction_type_id
                  INTO   v_transaction_type_id
                  FROM   csi_txn_types
                  WHERE  source_transaction_type = v_source_transaction_type;
               Exception
                  when no_data_found then
                     v_txn_type_not_found_msg := 'Invalid Transaction Type.';
                     raise txn_type_not_found_error;
               End;

               SELECT transaction_id
               INTO   v_transaction_id
               FROM   csi_transactions
               WHERE  source_line_ref_id  = p_batch_id AND
                      transaction_type_id = v_transaction_type_id;

            Exception

               When no_data_found Then

               Begin

                  Begin

                     SELECT CSI_TRANSACTIONS_S.nextval
                     INTO   v_transaction_id
                     FROM   dual;

                  End;

                  INSERT INTO csi_transactions(
                     transaction_id
                     ,transaction_date
                     ,source_transaction_date
                     ,transaction_type_id
                     ,source_line_ref_id
                     ,created_by
                     ,creation_date
                     ,last_updated_by
                     ,last_update_date
                     ,last_update_login
                     ,object_version_number
                     )
                  VALUES(
                     v_transaction_id
                     ,sysdate
                     ,sysdate
                     ,v_transaction_type_id
                     ,p_batch_id
       	             ,arp_standard.profile.user_id
                     ,sysdate
   	             ,arp_standard.profile.user_id
   	             ,sysdate
	             ,arp_standard.profile.user_id
	             ,1
                     );

               End;

            End;

          /* insert record into history table */
	    BEGIN
            INSERT INTO CSI_ITEM_INSTANCES_H
               (
		 INSTANCE_HISTORY_ID
		,INSTANCE_ID
		,TRANSACTION_ID
		,OLD_LOCATION_ID
		,NEW_LOCATION_ID
		,FULL_DUMP_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
		,OBJECT_VERSION_NUMBER
                ,OLD_INST_LOC_ID
                ,NEW_INST_LOC_ID
	       )
	    SELECT
                 CSI_ITEM_INSTANCES_H_S.nextval
                ,cii.INSTANCE_ID
		,v_transaction_id
		,decode( cii.location_id, p_from_fk_id, cii.location_id,        null )
		,decode( cii.location_id, p_from_fk_id, p_to_fk_id,             null )
                ,'N'
                ,arp_standard.profile.user_id
                ,sysdate
                ,arp_standard.profile.user_id
                ,sysdate
                ,arp_standard.profile.user_id
		,1
                ,decode( cii.install_location_id, p_from_fk_id, cii.install_location_id,        null )
                ,decode( cii.install_location_id, p_from_fk_id, p_to_fk_id,                     null )
	    FROM   csi_item_instances cii
            WHERE  ( install_location_type_code = v_install_location_type_code and
                     install_location_id        = p_from_fk_id ) or
                   ( location_type_code         = v_install_location_type_code and
                     location_id                = p_from_fk_id );


            arp_message.set_Name('CSI', 'CSI_ROWS_INSERTED');

            v_no_of_rows := sql%rowcount;
            arp_message.set_token('NUM_ROWS',to_char(v_no_of_rows));
            v_error_message := 'Done with the insert of item instance history';
            arp_message.set_line(v_error_message);
         EXCEPTION
		 WHEN DUP_VAL_ON_INDEX THEN
                BEGIN
                  UPDATE csi_item_instances_h cih
				  SET cih.new_location_id = decode(cih.new_location_id, p_from_fk_id, p_to_fk_id),
                      cih.new_inst_loc_id = decode(cih.new_inst_loc_id, p_from_fk_id, p_to_fk_id),
                      last_update_date = sysdate
                  WHERE cih.transaction_id = v_transaction_id
                    AND cih.instance_history_id IN
                      (SELECT cii2.instance_history_id
                       FROM csi_item_instances_h cii2
                       WHERE(cii2.new_location_id = p_from_fk_id OR cii2.new_inst_loc_id = p_from_fk_id)
                       AND cii2.transaction_id = v_transaction_id);
                EXCEPTION
                WHEN others THEN
                         arp_message.set_line(g_proc_name || '.' || l_api_name || ': '
                                                                  || sqlerrm);
                         x_return_status :=  FND_API.G_RET_STS_ERROR;
                         raise;
                END;

        WHEN others THEN
                arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' ||
                                                         sqlerrm);
                x_return_status :=  FND_API.G_RET_STS_ERROR;
                raise;

        END;
            /*
               After inserting into the history tables for the location(s) update,
               now update the install_location_id and location_id, if applicable
            */

            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CSI_ITEM_INSTANCES', FALSE);

            l_column_name := 'location_id';

            open  c2;
	    close c2;

            /* Modified udpate statement to retain the install_location_id & location_id instead of nulling them out - Bug#6848272*/
	    update csi_item_instances
            set    install_location_id = decode( install_location_id, p_from_fk_id, p_to_fk_id, install_location_id ),
                   location_id         = decode( location_id,         p_from_fk_id, p_to_fk_id, location_id ),
                   last_update_date    = SYSDATE,
                   last_updated_by     = G_USER_ID,
                   last_update_login   = G_LOGIN_ID
            where  ( install_location_type_code = v_install_location_type_code and
                     install_location_id        = p_from_fk_id ) or
                   ( location_type_code         = v_install_location_type_code and
                     location_id                = p_from_fk_id );

            l_count := sql%rowcount;

            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
            arp_message.set_token('NUM_ROWS', to_char(l_count) );

         End If;

      EXCEPTION
         when internal_party_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || v_internal_party_message);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when  txn_type_not_found_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || v_txn_type_not_found_msg);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when resource_busy then
            arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CSI_ITEM_INSTANCES  for '||l_column_name ||' = '|| p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when others then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
      END;
   END IF;
END CSI_ITEM_INSTANCES_MERGE;


PROCEDURE CSI_I_PARTIES_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   v_source_transaction_type    VARCHAR2(30) := 'PARTY_MERGE';
   v_party_source_table         VARCHAR2(30) := 'HZ_PARTIES';

   cursor c1 is
   select 1
   from   csi_i_parties
   where  party_id           = p_from_fk_id
   and    party_source_table = v_party_source_table
   for    update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CSI_I_PARTIES_MERGE';
   l_column_name                VARCHAR2(30);
   l_count                      NUMBER(10)   := 0;
   l_cp_audit_id                NUMBER;
   v_transaction_type_id        NUMBER;
   v_transaction_id             NUMBER;
   v_no_of_rows                 NUMBER;
   v_error_message              varchar2(255);
   v_internal_party_message     varchar2(255);
   v_txn_type_not_found_msg     varchar2(255);
   v_instance_party_history_id  NUMBER;
   v_internal_party_id          NUMBER;
   internal_party_error         EXCEPTION;
   txn_type_not_found_error     EXCEPTION;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);
BEGIN
   arp_message.set_line('CSI_PARTY_MERGE_PKG.CSI_I_PARTIES_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   begin
      select internal_party_id
      into   v_internal_party_id
      from   csi_install_parameters;
   exception
      when no_data_found then
         v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. Data exists in Installed Base, but Install Parameters are not defined';
         raise internal_party_error;
      when others then
         arp_message.set_line(g_proc_name || '.' ||l_api_name || ': ' ||sqlerrm);
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         raise;
   end;

   if v_internal_party_id = p_from_fk_id or
      v_internal_party_id = p_to_fk_id
   then
      v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. One of the party ids is defined as internal party in CSI-Installed Base application.';
         raise internal_party_error;
   end if;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to
      -- happen without any validations.
      null;
   else
      -- if there are any validations to be done, include it in this section
      null;
   end if;

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
   end if;

   IF p_from_fk_id <> p_to_fk_id then
      BEGIN
         /* insert record into transaction table */
         v_no_of_rows := 0;

         Begin
            Begin
               SELECT transaction_type_id
               INTO   v_transaction_type_id
               FROM   csi_txn_types
               WHERE  source_transaction_type = v_source_transaction_type;
            Exception
               when no_data_found then
                  v_txn_type_not_found_msg := 'Invalid Transaction Type..';
                  raise txn_type_not_found_error;
            End;
            SELECT transaction_id
            INTO   v_transaction_id
            FROM   csi_transactions
            WHERE  source_line_ref_id  = p_batch_id
              AND  transaction_type_id = v_transaction_type_id;
         Exception
            When no_data_found Then
            Begin
               Begin
                  SELECT CSI_TRANSACTIONS_S.nextval
                  INTO   v_transaction_id
                  FROM   dual;
               End;
               INSERT INTO csi_transactions
                  (
                    transaction_id
                   ,transaction_date
                   ,source_transaction_date
                   ,transaction_type_id
                   ,source_line_ref_id
                   ,created_by
                   ,creation_date
                   ,last_updated_by
                   ,last_update_date
                   ,last_update_login
                   ,object_version_number
                  )
               VALUES
                  (
                    v_transaction_id
                   ,sysdate
                   ,sysdate
                   ,v_transaction_type_id
                   ,p_batch_id
       	           ,arp_standard.profile.user_id
                   ,sysdate
   	           ,arp_standard.profile.user_id
   	           ,sysdate
	           ,arp_standard.profile.user_id
	           ,1
                  );
            End;
         End;

         /* insert record into history table */

         INSERT INTO csi_i_parties_h
            (
             instance_party_history_id,
             instance_party_id,
             transaction_id,
             old_party_source_table,
             new_party_source_table,
             old_party_id,
             new_party_id,
             full_dump_flag,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             object_version_number
            )
            SELECT csi_i_parties_h_s.nextval,
                   cip.instance_party_id,
                   v_transaction_id,
                   v_party_source_table,
                   v_party_source_table,
                   p_from_fk_id,
		   p_to_fk_id,
                   'N',
                   arp_standard.profile.user_id,
                   sysdate,
                   arp_standard.profile.user_id,
                   sysdate,
                   arp_standard.profile.user_id,
                   1
             FROM  csi_i_parties cip
             WHERE cip.party_source_table = v_party_source_table
	     AND   cip.party_id           = p_from_fk_id;

         arp_message.set_Name('CSI', 'CSI_ROWS_INSERTED');

         v_no_of_rows := sql%rowcount;
         arp_message.set_token('NUM_ROWS',to_char(v_no_of_rows));
         v_error_message := 'Done with the insert of party history';
         arp_message.set_line(v_error_message);

         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CSI_I_PARTIES', FALSE);

	 l_column_name := 'party_id';

         open  c1;
	 close c1;

	 update csi_i_parties
	 set    party_id            = p_to_fk_id,
	        last_update_date    = SYSDATE,
	        last_updated_by     = G_USER_ID,
	        last_update_login   = G_LOGIN_ID
         where  party_id            = p_from_fk_id
         and    party_source_table  = v_party_source_table;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      EXCEPTION
         when internal_party_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' ||v_internal_party_message);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when  txn_type_not_found_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || v_txn_type_not_found_msg);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when resource_busy then
            arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CSI_I_PARTIES  for '||l_column_name ||' = '|| p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when others then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
      END;
   END IF;
END CSI_I_PARTIES_MERGE;

PROCEDURE CSI_SYSTEMS_B_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   cursor c1 is
   select 1
   from   csi_systems_b
   where  install_site_use_id = p_from_fk_id
   for    update nowait;

   cursor c2 is
   select 1
   from   csi_systems_b
   where  ship_to_contact_id       = p_from_fk_id
   or     bill_to_contact_id       = p_from_fk_id
   or     technical_contact_id     = p_from_fk_id
   or     service_admin_contact_id = p_from_fk_id
   for    update nowait;

   v_source_transaction_type    VARCHAR2(30) := 'PARTY_MERGE';
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CSI_SYSTEMS_B_MERGE';
   l_count                      NUMBER(10)   := 0;
   l_system_audit_id            NUMBER;
   l_column_name                VARCHAR2(30);
   v_transaction_type_id        NUMBER;
   v_transaction_id             NUMBER;
   v_no_of_rows                 NUMBER;
   v_error_message              varchar2(255);
   v_internal_party_message     varchar2(255);
   v_txn_type_not_found_msg     varchar2(255);
   v_system_history_id          NUMBER;
   v_internal_party_id          NUMBER;
   internal_party_error         EXCEPTION;
   txn_type_not_found_error     EXCEPTION;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CSI_PARTY_MERGE_PKG.CSI_SYSTEMS_B_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   begin
      select internal_party_id
      into   v_internal_party_id
      from   csi_install_parameters;
   exception
      when no_data_found then
         v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. Data exists in Installed Base, but Install Parameters are not defined';
         raise internal_party_error;
      when others then
         arp_message.set_line(g_proc_name || '.' ||l_api_name || ': ' ||sqlerrm);
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         raise;
   end;

   if v_internal_party_id = p_from_fk_id or
      v_internal_party_id = p_to_fk_id
   then
      v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. One of the party ids is defined as internal party in CSI-Installed Base';
         raise internal_party_error;
   end if;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
      null;
   else
      null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   If p_from_fk_id = p_to_fk_id Then
      x_to_id := p_from_id;
      return;
   End If;

   If p_from_fk_id <> p_to_fk_id Then

      Begin
         BEGIN

           Begin
             SELECT transaction_type_id
             INTO   v_transaction_type_id
             FROM   csi_txn_types
             WHERE  source_transaction_type = v_source_transaction_type;
           Exception
             when no_data_found then
               v_txn_type_not_found_msg := 'Invalid Transaction Type...';
               raise txn_type_not_found_error;
           End;

           SELECT transaction_id
           INTO   v_transaction_id
           FROM   csi_transactions
           WHERE  source_line_ref_id = p_batch_id
             AND  transaction_type_id = v_transaction_type_id;

         EXCEPTION
            When no_data_found Then

               Begin

                  Begin
                     SELECT CSI_TRANSACTIONS_S.nextval
                     INTO   v_transaction_id
                     FROM   dual;
                  End;

                  INSERT INTO csi_transactions(
                     transaction_id
                     ,transaction_date
                     ,source_transaction_date
                     ,transaction_type_id
                     ,source_line_ref_id
                     ,created_by
                     ,creation_date
                     ,last_updated_by
                     ,last_update_date
                     ,last_update_login
                     ,object_version_number
                     )
                  VALUES(
                     v_transaction_id
                     ,sysdate
                     ,sysdate
                     ,v_transaction_type_id
                     ,p_batch_id
                     ,arp_standard.profile.user_id
                     ,sysdate
                     ,arp_standard.profile.user_id
                     ,sysdate
                     ,arp_standard.profile.user_id
                     ,1
                     );
               End;
         END;

         If p_parent_entity_name = 'HZ_PARTY_SITES' Then
            v_no_of_rows := 0;

            INSERT INTO csi_systems_h
               (system_history_id,
                system_id,
                transaction_id,
                old_install_site_use_id,
                new_install_site_use_id,
                full_dump_flag,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                object_version_number
               )
            SELECT csi_systems_h_s.nextval,
                   csb.system_id,
                   v_transaction_id,
                   p_from_fk_id,
                   p_to_fk_id,
                   'N',
                   arp_standard.profile.user_id,
                   sysdate,
                   arp_standard.profile.user_id,
                   sysdate,
                   arp_standard.profile.user_id,
                   1
             FROM  csi_systems_b csb
             WHERE csb.install_site_use_id = p_from_fk_id;

            arp_message.set_Name('CSI', 'CSI_ROWS_INSERTED');

            v_no_of_rows := sql%rowcount;
            arp_message.set_token('NUM_ROWS',to_char(v_no_of_rows));
            v_error_message := 'Done with the insert of systems history';
            arp_message.set_line(v_error_message);

            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CSI_SYSTEMS_B', FALSE);

	    l_column_name := 'install_site_use_id';

            open  c1;
	    close c1;

            update csi_systems_b
	    set    install_site_use_id = p_to_fk_id,
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
            where  install_site_use_id = p_from_fk_id;

            l_count := sql%rowcount;

            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
            arp_message.set_token('NUM_ROWS', to_char(l_count) );

         Elsif p_parent_entity_name = 'HZ_PARTIES' Then

            v_no_of_rows := 0;

            INSERT INTO csi_systems_h
               (
                system_history_id,
                system_id,
                transaction_id,
                old_ship_to_contact_id,
                new_ship_to_contact_id,
                old_bill_to_contact_id,
                new_bill_to_contact_id,
                old_technical_contact_id,
                new_technical_contact_id,
                old_service_admin_contact_id,
                new_service_admin_contact_id,
                full_dump_flag,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                object_version_number
               )
            SELECT csi_systems_h_s.nextval,
                   csb.system_id,
                   v_transaction_id,
                   decode( csb.ship_to_contact_id,       p_from_fk_id, p_from_fk_id, null ),
                   decode( csb.ship_to_contact_id,       p_from_fk_id, p_to_fk_id,   null ),
                   decode( csb.bill_to_contact_id,       p_from_fk_id, p_from_fk_id, null ),
                   decode( csb.bill_to_contact_id,       p_from_fk_id, p_to_fk_id,   null ),
                   decode( csb.technical_contact_id,     p_from_fk_id, p_from_fk_id, null ),
                   decode( csb.technical_contact_id,     p_from_fk_id, p_to_fk_id,   null ),
                   decode( csb.service_admin_contact_id, p_from_fk_id, p_from_fk_id, null ),
                   decode( csb.service_admin_contact_id, p_from_fk_id, p_to_fk_id,   null ),
                   'N',
                   arp_standard.profile.user_id,
                   sysdate,
                   arp_standard.profile.user_id,
                   sysdate,
                   arp_standard.profile.user_id,
                   1
             FROM  csi_systems_b csb
             WHERE ship_to_contact_id       = p_from_fk_id
               OR  bill_to_contact_id       = p_from_fk_id
               OR  technical_contact_id     = p_from_fk_id
               OR  service_admin_contact_id = p_from_fk_id ;

            arp_message.set_Name('CSI', 'CSI_ROWS_INSERTED');

            v_no_of_rows := sql%rowcount;
            arp_message.set_token('NUM_ROWS',to_char(v_no_of_rows));
            v_error_message := 'Done with the insert of systems history';
            arp_message.set_line(v_error_message);

            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CSI_SYSTEMS_B', FALSE);

	    l_column_name := 'contact_ids';

	    open  c2;
	    close c2;

            /* Modified udpate statement to retain : ship_to_contact_id, bill_to_contact_id, technical_contact_id &
 	     * service_admin_contact_id instead of nulling them out - Bug#6848272
             */
	    update csi_systems_b
            set    ship_to_contact_id       = decode( ship_to_contact_id,       p_from_fk_id, p_to_fk_id, ship_to_contact_id ),
                   bill_to_contact_id       = decode( bill_to_contact_id,       p_from_fk_id, p_to_fk_id, bill_to_contact_id ),
                   technical_contact_id     = decode( technical_contact_id,     p_from_fk_id, p_to_fk_id, technical_contact_id ),
                   service_admin_contact_id = decode( service_admin_contact_id, p_from_fk_id, p_to_fk_id, service_admin_contact_id ),
	           last_update_date         = SYSDATE,
	           last_updated_by          = G_USER_ID,
	           last_update_login        = G_LOGIN_ID
            where  ship_to_contact_id       = p_from_fk_id
               or  bill_to_contact_id       = p_from_fk_id
               or  technical_contact_id     = p_from_fk_id
               or  service_admin_contact_id = p_from_fk_id ;

            l_count := sql%rowcount;

            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
            arp_message.set_token('NUM_ROWS', to_char(l_count) );

         End If;

      EXCEPTION
         when internal_party_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' ||v_internal_party_message);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when  txn_type_not_found_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || v_txn_type_not_found_msg);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when resource_busy then
            arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CSI_SYSTEMS_B  for '||l_column_name ||' = '|| p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;

         when others then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
      END;
   end if;
END CSI_SYSTEMS_B_MERGE;

PROCEDURE CSI_T_TXN_SYSTEMS_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS

   cursor c1 is
   select 1
   from   csi_t_txn_systems
   where  install_site_use_id = p_from_fk_id
   for    update nowait;

   cursor c2 is
   select 1
   from   csi_t_txn_systems
   where  ship_to_contact_id       = p_from_fk_id
      or  bill_to_contact_id       = p_from_fk_id
      or  technical_contact_id     = p_from_fk_id
      or  service_admin_contact_id = p_from_fk_id
   for    update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CSI_T_TXN_SYSTEMS_MERGE';
   l_count                      NUMBER(10)   := 0;
   l_system_audit_id            NUMBER;
   l_column_name                VARCHAR2(30);
   v_no_of_rows                 NUMBER;
   v_error_message              varchar2(255);
   v_internal_party_message     varchar2(255);
   v_internal_party_id          NUMBER;
   internal_party_error         EXCEPTION;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CSI_PARTY_MERGE_PKG.CSI_T_TXN_SYSTEMS_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   begin
      select internal_party_id
      into   v_internal_party_id
      from   csi_install_parameters;
   exception
      when no_data_found then
         v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. Data exists in Installed Base, but Install Parameters are not defined';
         raise internal_party_error;
      when others then
         arp_message.set_line(g_proc_name || '.' ||l_api_name || ': ' ||sqlerrm);
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         raise;
   end;

   if v_internal_party_id = p_from_fk_id or
      v_internal_party_id = p_to_fk_id
   then
      v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. One of the party ids is defined as internal party in CSI-Installed Base';
      raise internal_party_error;
   end if;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
      null;
   else
      null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
   end if;

   if p_from_fk_id <> p_to_fk_id then
      begin

         If p_parent_entity_name = 'HZ_PARTY_SITES' Then

            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CSI_T_TXN_SYSTEMS', FALSE);

            l_column_name := 'install_site_use_id';

	    open  c1;
	    close c1;

	    update csi_t_txn_systems
	    set    install_site_use_id = p_to_fk_id,
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
            where  install_site_use_id = p_from_fk_id;

            l_count := sql%rowcount;

            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
            arp_message.set_token('NUM_ROWS', to_char(l_count) );

         Elsif p_parent_entity_name = 'HZ_PARTIES' Then

            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CSI_T_TXN_SYSTEMS', FALSE);

            l_column_name := 'contact_ids';

	    open  c2;
	    close c2;

	    update csi_t_txn_systems
	    set    bill_to_contact_id       = decode(bill_to_contact_id,   p_from_fk_id, p_to_fk_id, bill_to_contact_id ),
                   ship_to_contact_id       = decode(ship_to_contact_id,   p_from_fk_id, p_to_fk_id, ship_to_contact_id ),
                   technical_contact_id     = decode(technical_contact_id, p_from_fk_id, p_to_fk_id, technical_contact_id ),
                   service_admin_contact_id = decode(service_admin_contact_id,
                                                     p_from_fk_id, p_to_fk_id, service_admin_contact_id ),
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
            where  ship_to_contact_id       = p_from_fk_id
               or  bill_to_contact_id       = p_from_fk_id
               or  technical_contact_id     = p_from_fk_id
               or  service_admin_contact_id = p_from_fk_id;

            l_count := sql%rowcount;

            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
            arp_message.set_token('NUM_ROWS', to_char(l_count) );

         End If;

      EXCEPTION
         when internal_party_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' ||v_internal_party_message);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when resource_busy then
            arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CSI_T_TXN_SYSTEMS  for '||l_column_name ||' = '|| p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when others then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
      END;

   end if;

END CSI_T_TXN_SYSTEMS_MERGE;

PROCEDURE CSI_T_PARTY_DETAILS_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   v_party_source_table         VARCHAR2(30) := 'HZ_PARTIES';

   cursor c1 is
   select 1
   from   csi_t_party_details
   where  party_source_id = p_from_fk_id
   and    party_source_table = v_party_source_table
   for    update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CSI_T_PARTY_DETAILS_MERGE';
   l_column_name                VARCHAR2(30);
   l_count                      NUMBER(10)   := 0;
   l_cp_audit_id                NUMBER;
   v_no_of_rows                 NUMBER;
   v_error_message              varchar2(255);
   v_internal_party_message     varchar2(255);
   v_internal_party_id          NUMBER;
   internal_party_error         EXCEPTION;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);
BEGIN
   arp_message.set_line('CSI_PARTY_MERGE_PKG.CSI_T_PARTY_DETAILS_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   begin
      select internal_party_id
      into   v_internal_party_id
      from   csi_install_parameters;
   exception
      when no_data_found then
         v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. Data exists in Installed Base, but Install Parameters are not defined';
         raise internal_party_error;
      when others then
         arp_message.set_line(g_proc_name || '.' ||l_api_name || ': ' ||sqlerrm);
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         raise;
   end;

   if v_internal_party_id = p_from_fk_id or
      v_internal_party_id = p_to_fk_id
   then
      v_internal_party_message := 'Cannot merge party id '||to_char(p_from_fk_id)||' '||'to party id '||to_char(p_to_fk_id)||'. One of the party ids is defined as internal party in CSI-Installed Base';
      raise internal_party_error;
   end if;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to
      -- happen without any validations.
      null;
   else
      -- if there are any validations to be done, include it in this section
      null;
   end if;

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
   end if;

   IF p_from_fk_id <> p_to_fk_id then

      BEGIN

         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CSI_T_PARTY_DETAILS', FALSE);
	 l_column_name := 'party_source_id';

         open  c1;
	 close c1;

	 update csi_t_party_details
	 set    party_source_id     = p_to_fk_id,
	        last_update_date    = SYSDATE,
	        last_updated_by     = G_USER_ID,
	        last_update_login   = G_LOGIN_ID
         where  party_source_id     = p_from_fk_id
         and    party_source_table = v_party_source_table;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CSI_T_PARTY_DETAILS', FALSE);

         l_column_name := 'contact_party_id';

      EXCEPTION
         when internal_party_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' ||v_internal_party_message);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when resource_busy then
            arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CSI_T_PARTY_DETAILS  for '||l_column_name ||' = '|| p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when others then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
      END;
   END IF;
END CSI_T_PARTY_DETAILS_MERGE;

PROCEDURE CSI_T_TXN_LINE_DETAILS_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   v_location_type_code         VARCHAR2(30) := 'HZ_PARTY_SITES';
   v_install_location_type_code VARCHAR2(30) := 'HZ_PARTY_SITES';

   cursor c1 is
   select 1
   from   csi_t_txn_line_details
   where  ( location_id         = p_from_fk_id and location_type_code         = v_location_type_code )
   or     ( install_location_id = p_from_fk_id and install_location_type_code = v_location_type_code )
   for    update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CSI_T_TXN_LINE_DETAILS_MERGE';
   l_column_name                VARCHAR2(30);
   l_count                      NUMBER(10)   := 0;
   l_cp_audit_id                NUMBER;
   v_transaction_type_id        NUMBER;
   v_transaction_id             NUMBER;
   v_no_of_rows                 NUMBER;
   v_error_message              varchar2(255);
   v_internal_party_message     varchar2(255);
   v_internal_party_id          NUMBER;
   internal_party_error         EXCEPTION;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);
BEGIN
   arp_message.set_line('CSI_PARTY_MERGE_PKG.CSI_T_TXN_LINE_DETAILS_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to
      -- happen without any validations.
      null;
   else
      -- if there are any validations to be done, include it in this section
      null;
   end if;

   if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
   end if;

   IF p_from_fk_id <> p_to_fk_id then
      BEGIN
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CSI_T_TXN_LINE_DETAILS', FALSE);
	 l_column_name := 'location_id';

         open  c1;
	 close c1;

	 update csi_t_txn_line_details
	 set    location_id         = decode( location_id,         p_from_fk_id, p_to_fk_id, location_id         ),
                install_location_id = decode( install_location_id, p_from_fk_id, p_to_fk_id, install_location_id ),
	        last_update_date    = SYSDATE,
	        last_updated_by     = G_USER_ID,
	        last_update_login   = G_LOGIN_ID
         where  ( location_id         = p_from_fk_id and location_type_code         = v_location_type_code )
         or     ( install_location_id = p_from_fk_id and install_location_type_code = v_location_type_code );

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      EXCEPTION
         when internal_party_error then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || v_internal_party_message);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when resource_busy then
            arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CSI_T_TXN_LINE_DETAILS for '||l_column_name ||' = '|| p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
         when others then
            arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;
      END;
   END IF;
END CSI_T_TXN_LINE_DETAILS_MERGE;

END  CSI_PARTY_MERGE_PKG;

/
