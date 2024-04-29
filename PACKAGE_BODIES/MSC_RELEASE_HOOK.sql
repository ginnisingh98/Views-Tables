--------------------------------------------------------
--  DDL for Package Body MSC_RELEASE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RELEASE_HOOK" AS -- body
/* $Header: MSCRLHKB.pls 120.2 2007/05/18 15:53:31 vpalla ship $ */
   PROCEDURE EXTEND_RELEASE( ERRBUF                        OUT NOCOPY VARCHAR2
                           , RETCODE                       OUT NOCOPY NUMBER
                           , arg_dblink                    IN      VARCHAR2
                           , arg_plan_id                   IN      NUMBER
                           , arg_log_org_id                IN      NUMBER
                           , arg_org_instance              IN      NUMBER
                           , arg_owning_org_id             IN      NUMBER
                           , arg_owning_instance           IN      NUMBER
                           , arg_compile_desig             IN      VARCHAR2
                           , arg_user_id                   IN      NUMBER
                           , arg_po_group_by               IN      NUMBER
                           , arg_po_batch_number           IN      NUMBER
                           , arg_wip_group_id              IN      NUMBER
                           , arg_loaded_jobs               IN      NUMBER
                           , arg_loaded_lot_jobs           IN      NUMBER
                           , arg_resched_lot_jobs          IN      NUMBER
                           , arg_loaded_reqs               IN      NUMBER
                           , arg_loaded_scheds             IN      NUMBER
                           , arg_resched_jobs              IN      NUMBER
                           , arg_resched_reqs              IN      NUMBER
                           , arg_int_repair_orders         IN      NUMBER
                           , arg_ext_repair_orders         IN      NUMBER
                           , arg_wip_req_id                IN      NUMBER
                           , arg_osfm_req_id               IN      NUMBER
                           , arg_req_load_id               IN      NUMBER
                           , arg_req_resched_id            IN      NUMBER
                           , arg_int_repair_Order_id       IN      NUMBER
                           , arg_ext_repair_Order_id       IN      NUMBER
                           , arg_mode                      IN      VARCHAR2
                           , arg_transaction_id            IN      NUMBER
                           , l_apps_ver                      in VARCHAR2)
  IS
  BEGIN
  null;
  END EXTEND_RELEASE;

END MSC_RELEASE_HOOK;

/
