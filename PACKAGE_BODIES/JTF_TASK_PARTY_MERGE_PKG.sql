--------------------------------------------------------
--  DDL for Package Body JTF_TASK_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_PARTY_MERGE_PKG" as
/* $Header: jtftkpmb.pls 120.2 2005/12/23 02:15:35 sbarat ship $ */
--/**==================================================================*
--   Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA
--            All rights reserved.
--+====================================================================+
-- Package body for JTF_TASK_PARTY_MERGE_PKG package
--
--  Version :  1.0
-- Performs a Party Merge for TASKS module.
-------------------------------------------------------------------------------------------
--              History
-------------------------------------------------------------------------------------------
--  16-FEB-01   tivanov     Created.
--  30-APR-02   sanjeev     changed. added object_version_number clause in the
--                          updates for bug 2272073
--  17-SEP-03   tsinghal    Modified for bug # 3138768 , added jtf_task_utl.check_truncation
--  04-NOV-03   tsinghal    Modified for bug # 3138768 , added jtf_task_utl.check_truncation to some more apis
--  23-DEC-05   sbarat      Fixed SQL Literal issue for bug# 4614088
---------------------------------------------------------------------------------
-- End of comments
------------------------------------------------------------------------------------------
-- Procedure:   TASK_MERGE_PARTY -  Performs party ids  merge in JTF_TASKS_B table.
-- Columns: CUSTOMER_ID
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_PARTY(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASKS_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with customer_id = 1000 to 2000

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_tasks_b
    SET customer_id   = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE customer_id = p_from_fk_id; -- just to make sure it is the right one
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END TASK_MERGE_PARTY;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_AUDIT_MERGE_NEW_CUSTOMER
--      Performs party ids merge in JTF_TASK_AUDITS_B table.
-- Columns: NEW_CUSTOMER_ID
------------------------------------------------------------------------------------------


PROCEDURE TASK_AUDIT_MERGE_NEW_CUSTOMER(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) Is

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_AUDITS_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with new_customer_id = 1000 to 2000

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_task_audits_b
    SET new_customer_id   = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE new_customer_id = p_from_fk_id; -- just to make sure it is the right one
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END TASK_AUDIT_MERGE_NEW_CUSTOMER;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_AUDIT_MERGE_OLD_CUSTOMER
--      Performs party ids merge in JTF_TASK_AUDITS_B table.
-- Columns: OLD_CUSTOMER_ID
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_OLD_CUSTOMER(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) Is

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_AUDITS_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with old_customer_id = 1000 to 2000

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_task_audits_b
    SET old_customer_id   = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE old_customer_id = p_from_fk_id; -- just to make sure it is the right one
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_AUDIT_MERGE_OLD_CUSTOMER;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_MERGE_SOURCE_OBJECT -  Performs party ids merge in JTF_TASKS_B table.
-- Columns: SOURCE_OBJECT_ID , SOURCE_OBJECT_NAME
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_SOURCE_OBJECT(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

--Cursor  c_name Is
--select  o.select_name
--from    jtf_objects_vl o,
--    jtf_tasks_b t
--where   t.task_id = p_from_id
--and t.source_object_type_code = o.object_code
--and nvl(start_date_active, sysdate) <= sysdate
--and nvl(end_date_active, sysdate) >= sysdate;

Cursor  c_name Is
select  select_name
from    jtf_objects_vl
where   object_code = 'PARTY'
and nvl(start_date_active, sysdate) <= sysdate
and nvl(end_date_active, sysdate)   >= sysdate;

l_name          jtf_objects_vl.select_name%TYPE;
l_select_stat   varchar2(1000);


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASKS_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with source_object_id = 1000 to 2000
   -- and also update the source_object_name where source_object_type_code = 'PARTY'

open c_name;
fetch c_name into l_name;
close c_name;

if l_name is not NULL then

-- Modified by TSINGHAL for bug # 3138768 dt 17/sept/2003 start
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    l_select_stat :=
           'UPDATE jtf_tasks_b'
        || '   SET source_object_id = :1'
        ||     ' , source_object_name = (SELECT jtf_task_utl.check_truncation(:2) FROM hz_parties WHERE party_id = :3)'
        ||     ' , last_update_date   = hz_utility_pub.last_update_date'
        ||     ' , last_updated_by    = hz_utility_pub.user_id'
        ||     ' , last_update_login  = hz_utility_pub.last_update_login'
        ||     ' , object_version_number = object_version_number + 1'
        || ' WHERE source_object_id = :4'
        || '   AND source_object_type_code = ''PARTY''';

-- Modified by TSINGHAL for bug # 3138768 dt 17/sept/2003 End
end if;

if l_select_stat is not NULL then
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    EXECUTE IMMEDIATE l_select_stat
            USING to_char(p_to_fk_id) ,
                  l_name ,
                  to_char(p_to_fk_id) ,
                  to_char(p_from_fk_id);
else
    fnd_message.set_name('JTF', 'JTF_TASK_DYNAMYC_SELECT');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_MERGE_SOURCE_OBJECT;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_AUDIT_MERGE_NEW_S_OBJECT
--      Performs party ids merge in JTF_TASK_AUDITS_B table.
-- Columns: NEW_SOURCE_OBJECT_ID , NEW_SOURCE_OBJECT_NAME
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_NEW_S_OBJECT(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS
l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

--Cursor  c_name Is
--select  o.select_name
--from    jtf_objects_vl o,
--    jtf_task_audits_b a
--where   a.task_audit_id = p_from_id
--and a.new_source_object_type_code = o.object_code
--and nvl(start_date_active, sysdate) <= sysdate
--and nvl(end_date_active, sysdate) >= sysdate;

Cursor  c_name Is
select  select_name
from    jtf_objects_vl
where   object_code = 'PARTY'
and nvl(start_date_active, sysdate) <= sysdate
and nvl(end_date_active, sysdate)   >= sysdate;

l_name      jtf_objects_vl.select_name%TYPE;
l_select_stat   varchar2(1000);

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_AUDITS_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with new_source_object_id = 1000 to 2000
   -- and also update the new_source_object_name where new_source_object_type_code = 'PARTY'

open c_name;
fetch c_name into l_name;
close c_name;

if l_name is not NULL then
-- Modified by TSINGHAL for bug # 3138768 dt 17/sept/2003 start
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    l_select_stat := 'UPDATE jtf_task_audits_b '
            ||          'SET new_source_object_id = :1'
            ||           ' , new_source_object_name = (SELECT jtf_task_utl.check_truncation(:2) FROM hz_parties WHERE party_id = :3)'
            ||           ' , last_update_date = hz_utility_pub.last_update_date'
            ||           ' , last_updated_by   = hz_utility_pub.user_id'
            ||           ' , last_update_login = hz_utility_pub.last_update_login'
            ||           ' , object_version_number = object_version_number + 1'
            ||       ' WHERE new_source_object_id = :4'
            ||       '   AND new_source_object_type_code = ''PARTY''';
end if;
-- Modified by TSINGHAL for bug # 3138768 dt 17/sept/2003 End
if l_select_stat is not NULL then
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    EXECUTE IMMEDIATE l_select_stat
            USING to_char(p_to_fk_id) ,
                  l_name ,
                  to_char(p_to_fk_id) ,
                  to_char(p_from_fk_id);
else
    fnd_message.set_name('JTF', 'JTF_TASK_DYNAMYC_SELECT');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END TASK_AUDIT_MERGE_NEW_S_OBJECT;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_AUDIT_MERGE_OLD_S_OBJECT
--      Performs party ids merge in JTF_TASK_AUDITS_B table.
-- Columns: OLD_SOURCE_OBJECT_ID , OLD_SOURCE_OBJECT_NAME
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_OLD_S_OBJECT(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

--Cursor  c_name Is
--select  o.select_name
--from    jtf_objects_vl o,
--    jtf_task_audits_b a
--where   a.task_audit_id = p_from_id
--and a.old_source_object_type_code = o.object_code
--and nvl(start_date_active, sysdate) <= sysdate
--and nvl(end_date_active, sysdate) >= sysdate;

Cursor  c_name Is
select  select_name
from    jtf_objects_vl
where   object_code = 'PARTY'
and nvl(start_date_active, sysdate) <= sysdate
and nvl(end_date_active, sysdate)   >= sysdate;

l_name      jtf_objects_vl.select_name%TYPE;
l_select_stat   varchar2(1000);

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_AUDITS_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with old_source_object_id = 1000 to 2000
   -- and also update the old_source_object_name where old_source_object_type_code = 'PARTY'


open c_name;
fetch c_name into l_name;
close c_name;

if l_name is not NULL then
-- Modified by TSINGHAL for bug # 3138768 dt 01/Oct/2003 Start
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    l_select_stat := 'UPDATE jtf_task_audits_b'
            ||         ' SET old_source_object_id = :1'
            ||           ' , old_source_object_name = (SELECT jtf_task_utl.check_truncation(:2) FROM hz_parties WHERE party_id = :3 )'
            ||           ' , last_update_date = hz_utility_pub.last_update_date'
            ||           ' , last_updated_by   = hz_utility_pub.user_id'
            ||           ' , last_update_login = hz_utility_pub.last_update_login'
            ||           ' , object_version_number = object_version_number + 1'
            ||       ' WHERE old_source_object_id = :4'
            ||         ' AND old_source_object_type_code = ''PARTY''';
   -- Modified by TSINGHAL for bug # 3138768 dt 01/Oct/2003 End
end if;

if l_select_stat is not NULL then
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    EXECUTE IMMEDIATE l_select_stat
            USING to_char(p_to_fk_id) ,
                  l_name ,
                  to_char(p_to_fk_id) ,
                  to_char(p_from_fk_id);
else
    fnd_message.set_name('JTF', 'JTF_TASK_DYNAMYC_SELECT');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END TASK_AUDIT_MERGE_OLD_S_OBJECT;


------------------------------------------------------------------------------------------
-- Procedure:   TASK_REF_MERGE_PARTY_OBJECT
--      Performs party ids merge in JTF_TASK_REFERENCES_B table for objects of type --      'PARTY'.
-- Columns: OBJECT_ID , OBJECT_NAME
------------------------------------------------------------------------------------------


PROCEDURE TASK_REF_MERGE_PARTY_OBJECT(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS
l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

--Cursor  c_name Is
--select  o.select_name
--from    jtf_objects_vl o,
--    jtf_task_references_b r
--where   r.task_reference_id = p_from_id
--and r.object_type_code = o.object_code
--and nvl(start_date_active, sysdate) <= sysdate
--and nvl(end_date_active, sysdate) >= sysdate;

Cursor  c_name Is
select  select_name
from    jtf_objects_vl
where   object_code = 'PARTY'
and nvl(start_date_active, sysdate) <= sysdate
and nvl(end_date_active, sysdate)   >= sysdate;

l_name      jtf_objects_vl.select_name%TYPE;
l_select_stat   varchar2(1000);


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_REFERENCES_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with object_id = 1000 to 2000 ,
   -- and also update the object_name where object_type_code = 'PARTY'


open c_name;
fetch c_name into l_name;
close c_name;

if l_name is not NULL then
/* Modified by tsinghal 4th Nov '03 bug # 3138768 Start */
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    l_select_stat := 'UPDATE jtf_task_references_b'
            ||         ' SET object_id = :1'
            ||           ' , object_name = (SELECT jtf_task_utl.check_truncation(:2) FROM hz_parties WHERE party_id = :3 )'
            ||           ' , last_update_date = hz_utility_pub.last_update_date'
            ||           ' , last_updated_by   = hz_utility_pub.user_id'
            ||           ' , last_update_login = hz_utility_pub.last_update_login'
            ||           ' , object_version_number = object_version_number + 1'
            ||       ' WHERE object_id = :4'
            ||         ' AND object_type_code = ''PARTY''';
end if;
/* Modified by tsinghal 4th Nov '03 bug # 3138768 End */
if l_select_stat is not NULL then
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    EXECUTE IMMEDIATE l_select_stat
            USING to_char(p_to_fk_id) ,
                  l_name ,
                  to_char(p_to_fk_id) ,
                  to_char(p_from_fk_id);

else
    fnd_message.set_name('JTF', 'JTF_TASK_DYNAMYC_SELECT');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_REF_MERGE_PARTY_OBJECT;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_REF_MERGE_PSITE_OBJECT
--      Performs party ids merge in JTF_TASK_REFERENCES_B table for objects of type --      'PARTY_SITE'.
-- Columns: OBJECT_ID , OBJECT_NAME
------------------------------------------------------------------------------------------


PROCEDURE TASK_REF_MERGE_PSITE_OBJECT(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS
l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

--Cursor  c_name Is
--select  o.select_name
--from    jtf_objects_vl o,
--    jtf_task_references_b r
--where   r.task_reference_id = p_from_id
--and r.object_type_code = o.object_code
--and nvl(start_date_active, sysdate) <= sysdate
--and nvl(end_date_active, sysdate) >= sysdate;

Cursor  c_name Is
select  select_name
from    jtf_objects_vl
where   object_code = 'SITE'
and nvl(start_date_active, sysdate) <= sysdate
and nvl(end_date_active, sysdate)   >= sysdate;

l_name      jtf_objects_vl.select_name%TYPE;
l_select_stat   varchar2(1000);


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;


if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return


if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_REFERENCES_B table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with object_id = 1000 to 2000 ,
   -- and also update the object_name where object_type_code = 'PARTY'



open c_name;
fetch c_name into l_name;
close c_name;

if l_name is not NULL then
/* Modified by tsinghal 4th Nov '03 bug # 3138768 Start */
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    l_select_stat := 'UPDATE jtf_task_references_b'
            ||         ' SET object_id = :1'
            ||           ' , object_name = (SELECT jtf_task_utl.check_truncation(:2) FROM hz_party_sites WHERE party_site_id = :3 )'
            ||           ' , last_update_date = hz_utility_pub.last_update_date'
            ||           ' , last_updated_by   = hz_utility_pub.user_id'
            ||           ' , last_update_login = hz_utility_pub.last_update_login'
            ||           ' , object_version_number = object_version_number + 1'
            ||       ' WHERE object_id = :4'
            ||         ' AND object_type_code = ''SITE''';
end if;
/* Modified by tsinghal 4th Nov '03 bug # 3138768 End */
if l_select_stat is not NULL then
-- Modified by SBARAT on 23/12/2005 for SQL Literal issue, bug# 4614088
    EXECUTE IMMEDIATE l_select_stat
            USING to_char(p_to_fk_id) ,
                  l_name ,
                  to_char(p_to_fk_id) ,
                  to_char(p_from_fk_id);
else
    fnd_message.set_name('JTF', 'JTF_TASK_DYNAMYC_SELECT');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_REF_MERGE_PSITE_OBJECT;



------------------------------------------------------------------------------------------
-- Procedure:   TASK_MERGE_ADDRESS
--      Performs party_site merge in JTF_TASKS_B table.
-- Columns: ADDRESS_ID
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_ADDRESS(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return
-- If the party_site has been transferred then nothing should be done.

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASKS_B table, if party_site_id 1111 got merged to party_site_id  2222
   -- then, we have to update all records with address_id = 1111 to 2222

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_tasks_b
    SET address_id    = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE   --task_id = p_from_id
    --AND
          address_id = p_from_fk_id; -- just to make sure it is the right one
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_MERGE_ADDRESS;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_AUDIT_MERGE_NEW_ADDRESS
--      Performs party_site merge in JTF_TASK_AUDITS_B table.
-- Columns: NEW_ADDRESS_ID
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_NEW_ADDRESS(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return
-- If the party_site has been transferred then nothing should be done.

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_AUDITS_B table, if party_site_id 1111 got merged to party_site_id  2222
   -- then, we have to update all records with new_address_id = 1111 to 2222

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_task_audits_b
    SET new_address_id    = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE   --task_audit_id  = p_from_id
    --AND
        new_address_id = p_from_fk_id; -- just to make sure it is the right one
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_AUDIT_MERGE_NEW_ADDRESS;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_AUDIT_MERGE_OLD_ADDRESS
--      Performs party_site merge in JTF_TASK_AUDITS_B table.
-- Columns: OLD_ADDRESS_ID
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_OLD_ADDRESS(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return
-- If the party_site has been transferred then nothing should be done.

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_AUDITS_B table, if party_site_id 1111 got merged to party_site_id  2222
   -- then, we have to update all records with old_address_id = 1111 to 2222

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_task_audits_b
    SET old_address_id    = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE   --task_audit_id  = p_from_id
    --AND
         old_address_id = p_from_fk_id; -- just to make sure it is the right one
end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_AUDIT_MERGE_OLD_ADDRESS;

------------------------------------------------------------------------------------------
-- Procedure:   TASK_MERGE_CONTACTS
--      Performs party_id merge in JTF_TASK_CONTACTS table.
-- Columns: CONTACT_ID where CONTACT_TYPE_CODE = 'CUST'
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_CONTACTS(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) Is

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_CONTACTS table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with contact_id = 1000 to 2000
   -- for contacts of type 'Customer' - contact_type_code = 'CUST'

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_task_contacts
    SET contact_id  = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE  --task_contact_id = p_from_id
        contact_type_code = 'CUST'
    AND contact_id = p_from_fk_id; --just to make sure it is the right one

end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_MERGE_CONTACTS;


------------------------------------------------------------------------------------------
-- Procedure:   TASK_MERGE_CONTACT_POINTS
--      Performs contact_point_id merge in JTF_TASK_PHONES table.
-- Columns: PHONE_ID
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_CONTACT_POINTS(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) Is

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For JTF_TASK_PHONES table, if contact_point_id 1000 got merged to contact_point_id
   -- 2000  then, we have to update all records with phone_id = 1000 to 2000

if p_from_fk_id  <> p_to_fk_id then

    UPDATE  jtf_task_phones
    SET phone_id = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        object_version_number = object_version_number + 1
    WHERE   --task_phone_id = p_from_id
    --AND
        phone_id = p_from_fk_id; --just to make sure it is the right one

end if;


exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_MERGE_CONTACT_POINTS;


------------------------------------------------------------------------------------------
-- Procedure:   SEARCH_MERGE_NUMBER_PARTY_ID - Performs party ids  merge in JTF_PERZ_QUERY_PARAM table for Customer Number saved searches.
-- Columns: Updates PARAMETER_VALUE where PARAMETER_NAME='CUSTOMER_ID'
-- Parameters:  p_from_id = jtf_perz_query_param.query_param_id
------------------------------------------------------------------------------------------

PROCEDURE SEARCH_MERGE_NUMBER_PARTY_ID(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;



-- get CUSTOMER_NAME's  query_param_id

--cursor get_query_customer_name(p_from_id NUMBER) Is
--SELECT  p2.query_param_id
--FROM    jtf_perz_query_param p1,
--    jtf_perz_query_param p2
--WHERE   p1.query_param_id = p_from_id
--AND p1.query_id = p2.query_id
--AND p2.parameter_name = 'CUSTOMER_NAME';

-- get Customer new Name - using the p_to_fk_id

cursor get_new_customer_number(p_to_fk_id NUMBER) Is
SELECT party_number
FROM hz_parties
WHERE party_id = p_to_fk_id;

--l_query_customer_name_id    jtf_perz_query_param.query_param_id%TYPE;
l_customer_new_number     hz_parties.party_number%TYPE;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.

if p_from_fk_id  <> p_to_fk_id then

--open    get_query_customer_name(p_from_id);
--fetch   get_query_customer_name into l_query_customer_name_id;
--close   get_query_customer_name;

--open    get_new_customer_name(p_to_fk_id);
open    get_new_customer_number(p_to_fk_id);
fetch   get_new_customer_number into l_customer_new_number;
close   get_new_customer_number;

      if --(SQL%ROWCOUNT > 0)
     --and
           (l_customer_new_number is not NULL)
     --and (l_query_customer_name_id is not NULL)
     then

    UPDATE  jtf_perz_query_param
    -- Fix bug 3738509
        SET parameter_value  = l_customer_new_number,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    WHERE   --query_param_id = l_query_customer_name_id
        query_param_id IN (SELECT param.query_param_id
                             FROM jtf_perz_query_param param
                                , (SELECT q.query_id
                                     FROM jtf_perz_query q
                                        , jtf_perz_query_param p
                                    WHERE q.query_type = 'JTF_TASK'
                                      AND q.application_id = 690
                                      AND p.query_id = q.query_id
                                      AND p.parameter_name = 'CUSTOMER'
                                      AND p.parameter_value = 'NUMBER') query
                            WHERE param.query_id = query.query_id
                              AND param.parameter_name = 'CUSTOMER_NAME'
                              AND EXISTS (SELECT 1
                                            FROM jtf_perz_query_param pm
                                           WHERE pm.query_id = param.query_id
                                             AND pm.parameter_name = 'CUSTOMER_ID'
                                             AND pm.parameter_value = to_char(p_from_fk_id))
                           );

     end if;

    UPDATE  jtf_perz_query_param p
    SET parameter_value  = to_char(p_to_fk_id),
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    WHERE   --query_param_id = p_from_id
        query_param_id IN (SELECT param.query_param_id
                             FROM jtf_perz_query_param param
                                , (SELECT q.query_id
                                     FROM jtf_perz_query q
                                        , jtf_perz_query_param p
                                    WHERE q.query_type = 'JTF_TASK'
                                      AND q.application_id = 690
                                      AND p.query_id = q.query_id
                                      AND p.parameter_name = 'CUSTOMER'
                                      AND p.parameter_value = 'NUMBER') query
                            WHERE param.query_id = query.query_id
                              AND param.parameter_name = 'CUSTOMER_ID'
                              AND param.parameter_value = to_char(p_from_fk_id));


end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END SEARCH_MERGE_NUMBER_PARTY_ID;


------------------------------------------------------------------------------------------
-- Procedure:   SEARCH_MERGE_NAME_PARTY_ID - Performs party ids  merge in JTF_PERZ_QUERY_PARAM table for Customer Name saved searches.
-- Columns: Updates PARAMETER_VALUE where PARAMETER_NAME='CUSTOMER_ID'
-- Parameters:  p_from_id = jtf_perz_query_param.query_param_id
------------------------------------------------------------------------------------------

PROCEDURE SEARCH_MERGE_NAME_PARTY_ID(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;



-- get CUSTOMER_NAME's  query_param_id

--cursor get_query_customer_name(p_from_id NUMBER) Is
--SELECT  p2.query_param_id
--FROM    jtf_perz_query_param p1,
--    jtf_perz_query_param p2
--WHERE   p1.query_param_id = p_from_id
--AND p1.query_id = p2.query_id
--AND p2.parameter_name = 'CUSTOMER_NAME';

-- get Customer new Name - using the p_to_fk_id

cursor get_new_customer_name(p_to_fk_id NUMBER) Is
SELECT party_name
FROM hz_parties
WHERE party_id = p_to_fk_id;

--l_query_customer_name_id    jtf_perz_query_param.query_param_id%TYPE;
l_customer_new_name     hz_parties.party_name%TYPE;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.


if p_from_fk_id  <> p_to_fk_id then

--open    get_query_customer_name(p_from_id);
--fetch   get_query_customer_name into l_query_customer_name_id;
--close   get_query_customer_name;

open    get_new_customer_name(p_to_fk_id);
fetch   get_new_customer_name into l_customer_new_name;
close   get_new_customer_name;

--    UPDATE  jtf_perz_query_param
--    SET parameter_value  = to_char(p_to_fk_id),
--        last_update_date  = hz_utility_pub.last_update_date,
--        last_updated_by   = hz_utility_pub.user_id,
--        last_update_login = hz_utility_pub.last_update_login
--    WHERE   query_param_id = p_from_id
--    AND parameter_value = to_char(p_from_fk_id);


      if --(SQL%ROWCOUNT > 0)
--     and
          (l_customer_new_name is not NULL)
--     and (l_query_customer_name_id is not NULL)
      then

--    UPDATE  jtf_perz_query_param
--    SET parameter_value  = l_customer_new_name,
--        last_update_date  = hz_utility_pub.last_update_date,
--        last_updated_by   = hz_utility_pub.user_id,
--        last_update_login = hz_utility_pub.last_update_login
--    WHERE   query_param_id = l_query_customer_name_id;

--     end if;

    UPDATE  jtf_perz_query_param
    SET parameter_value  = l_customer_new_name,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    WHERE   --query_param_id = l_query_customer_name_id
        query_param_id IN (SELECT param.query_param_id
                             FROM jtf_perz_query_param param
                                , (SELECT q.query_id
                                     FROM jtf_perz_query q
                                        , jtf_perz_query_param p
                                    WHERE q.query_type = 'JTF_TASK'
                                      AND q.application_id = 690
                                      AND p.query_id = q.query_id
                                      AND p.parameter_name = 'CUSTOMER'
                                      AND p.parameter_value = 'NAME') query
                            WHERE param.query_id = query.query_id
                              AND param.parameter_name = 'CUSTOMER_NAME'
                              AND EXISTS (SELECT 1
                                            FROM jtf_perz_query_param pm
                                           WHERE pm.query_id = param.query_id
                                             AND pm.parameter_name = 'CUSTOMER_ID'
                                             AND pm.parameter_value = to_char(p_from_fk_id))
                           );

     end if;

    UPDATE  jtf_perz_query_param p
    SET parameter_value  = to_char(p_to_fk_id),
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    WHERE   --query_param_id = p_from_id
        query_param_id IN (SELECT param.query_param_id
                             FROM jtf_perz_query_param param
                                , (SELECT q.query_id
                                     FROM jtf_perz_query q
                                        , jtf_perz_query_param p
                                    WHERE q.query_type = 'JTF_TASK'
                                      AND q.application_id = 690
                                      AND p.query_id = q.query_id
                                      AND p.parameter_name = 'CUSTOMER'
                                      AND p.parameter_value = 'NAME') query
                            WHERE param.query_id = query.query_id
                              AND param.parameter_name = 'CUSTOMER_ID'
                              AND param.parameter_value = to_char(p_from_fk_id));

end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END SEARCH_MERGE_NAME_PARTY_ID;


------------------------------------------------------------------------------------------
-- Procedure:   TASK_ASSIGNMENTS_MERGE - Performs party ids  merge in
--      JTF_TASK_ASSIGNMENTS table.
-- Columns: Updates RESOURCE_ID where RESOURCE_TYPE is of party type
------------------------------------------------------------------------------------------

PROCEDURE TASK_ASSIGNMENTS_MERGE(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;

CURSOR c_party IS
SELECT party_type
  FROM hz_parties
 WHERE party_id = p_from_fk_id;

l_party_type hz_parties.party_type%TYPE;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.

if p_from_fk_id  <> p_to_fk_id then

   UPDATE jtf_task_assignments
      SET resource_id           = p_to_fk_id,
          last_update_date      = hz_utility_pub.last_update_date,
          last_updated_by       = hz_utility_pub.user_id,
          last_update_login     = hz_utility_pub.last_update_login,
          object_version_number = object_version_number + 1
    WHERE resource_id = p_from_fk_id
      AND resource_type_code IN (SELECT object_code
                                  FROM jtf_objects_b
                                 WHERE LTRIM(RTRIM(UPPER(from_table))) = 'HZ_PARTIES'
                                   AND RTRIM(LTRIM(UPPER(select_id))) = 'PARTY_ID');

end if;

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_ASSIGNMENTS_MERGE;


END JTF_TASK_PARTY_MERGE_PKG;

/
