--------------------------------------------------------
--  DDL for Package Body HR_TRANSACTION_SNAPSHOT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRANSACTION_SNAPSHOT_SWI" as
/* $Header: hrsnpswi.pkb 120.0 2005/05/31 02:52:51 appldev noship $ */
--
-- Package variables
--
   g_date_format varchar2(10) := 'RRRR/MM/DD';
   g_package  varchar2(33) := 'HR_TRANSACTION_SNAPSHOT_SWI.';
   g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_transaction_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_transaction_snapshot
(
   P_DOCUMENT                   IN        CLOB
  ,P_SNAPSHOT_ID                IN OUT    NOCOPY NUMBER
  ,P_OBJECT_VERSION_NUMBER      IN OUT    NOCOPY NUMBER
  ,P_OBJECT_NAME                IN        VARCHAR2
  ,P_OBJECT_IDENTIFIER          IN        VARCHAR2
  ,P_VALIDATE                   IN        NUMBER     default hr_api.g_false_num
)
--
is
   l_proc varchar2(30) := 'create_transaction';
   l_SNAPSHOT_ID  hr_transaction_snapshot.SNAPSHOT_ID%type;
   PRAGMA AUTONOMOUS_TRANSACTION;
begin

   l_SNAPSHOT_ID := P_SNAPSHOT_ID;
   hr_snp_ins.set_base_key_value(l_SNAPSHOT_ID);

   hr_snp_ins.ins(
   p_document                => P_DOCUMENT
  ,p_snapshot_id             => P_SNAPSHOT_ID
  ,p_object_version_number   => P_OBJECT_VERSION_NUMBER
  ,p_object_name             => P_OBJECT_NAME
  ,p_object_identifier       => P_OBJECT_IDENTIFIER
   );

   If P_VALIDATE = hr_api.g_false_num Then
      commit;
    Else
      rollback;
    End If;

exception
    when OTHERS then
        rollback; -- to create_transaction;
        raise;
end create_transaction_snapshot;

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_transaction_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_transaction_snapshot
(
   P_DOCUMENT                 IN       CLOB
  ,P_SNAPSHOT_ID              IN       NUMBER
  ,P_OBJECT_VERSION_NUMBER    IN  OUT  NOCOPY NUMBER
  ,P_OBJECT_NAME              IN       VARCHAR2
  ,P_OBJECT_IDENTIFIER        IN       VARCHAR2
  ,P_VALIDATE                 IN       NUMBER     default hr_api.g_false_num

)
--
is
    l_proc varchar2(30) := 'update_transaction';
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
   hr_snp_upd.upd(
   p_document                =>    P_DOCUMENT
  ,p_snapshot_id             =>    P_SNAPSHOT_ID
  ,p_object_version_number   =>    P_OBJECT_VERSION_NUMBER
  ,p_object_name             =>    P_OBJECT_NAME
  ,p_object_identifier       =>    P_OBJECT_IDENTIFIER

     );
   If P_VALIDATE = hr_api.g_false_num Then
      commit;
    Else
      rollback;
    End If;
exception
    when OTHERS then
        rollback; -- to create_transaction;
end update_transaction_snapshot;

--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_transaction_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_transaction_snapshot
(
   P_SNAPSHOT_ID              IN    NUMBER
  ,P_OBJECT_VERSION_NUMBER    IN    NUMBER
)
--
is
    l_proc varchar2(30) := 'delete_transaction';
    PRAGMA AUTONOMOUS_TRANSACTION;
begin

   hr_snp_del.del(
   p_snapshot_id             =>     P_SNAPSHOT_ID
  ,p_object_version_number   =>     P_OBJECT_VERSION_NUMBER
     );
    commit;
exception
    when OTHERS then
        rollback;
end delete_transaction_snapshot;
--
end hr_transaction_snapshot_swi;
--

/
