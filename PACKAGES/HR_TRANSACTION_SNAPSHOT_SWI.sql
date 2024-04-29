--------------------------------------------------------
--  DDL for Package HR_TRANSACTION_SNAPSHOT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TRANSACTION_SNAPSHOT_SWI" AUTHID CURRENT_USER as
/* $Header: hrsnpswi.pkh 120.0 2005/05/31 02:53:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_transaction_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_transaction_snapshot
(
   P_DOCUMENT                IN       CLOB
  ,P_SNAPSHOT_ID             IN OUT   NOCOPY NUMBER
  ,P_OBJECT_VERSION_NUMBER   IN OUT   NOCOPY  NUMBER
  ,P_OBJECT_NAME             IN      VARCHAR2
  ,P_OBJECT_IDENTIFIER       IN      VARCHAR2
  ,P_VALIDATE                IN      NUMBER     default hr_api.g_false_num
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_transaction_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_transaction_snapshot
(
   P_DOCUMENT                IN      CLOB
  ,P_SNAPSHOT_ID             IN      NUMBER
  ,P_OBJECT_VERSION_NUMBER   IN OUT  NOCOPY NUMBER
  ,P_OBJECT_NAME             IN      VARCHAR2
  ,P_OBJECT_IDENTIFIER       IN      VARCHAR2
  ,P_VALIDATE                IN      NUMBER     default hr_api.g_false_num

);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_transaction_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_transaction_snapshot
(
   P_SNAPSHOT_ID              IN    NUMBER
  ,P_OBJECT_VERSION_NUMBER    IN    NUMBER
);
--
end hr_transaction_snapshot_swi;
--

 

/
