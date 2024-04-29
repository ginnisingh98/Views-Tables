--------------------------------------------------------
--  DDL for Package Body POS_APPR_REJ_SUPP_EVENT_RAISE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_APPR_REJ_SUPP_EVENT_RAISE" AS
 /* $Header: POSSPAREB.pls 120.0.12010000.4 2010/04/20 05:40:50 ntungare noship $ */
    FUNCTION raise_appr_rej_supp_event(p_event_name VARCHAR2,param1 VARCHAR2,
                                       param2 VARCHAR2) RETURN NUMBER IS
        --
        /*       lc_event_key        VARCHAR2(50);
               lc_errcode          VARCHAR2(1) := '0';
               lc_errbuf           VARCHAR2(4000);
               lc_event_name       VARCHAR2(50) := 'xxocs.apps.hr.position.change';
               lc_itemtype         VARCHAR2(30) := 'POSPUBSUPP';
               lp_parameter_list_t wf_parameter_list_t;
        */

        l_itemkey        NUMBER;
        l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
        --l_event_name     VARCHAR2(50) := 'oracle.apps.pos.supplier.approvesupplier';
        l_message        VARCHAR2(50) := NULL;

    BEGIN

        SELECT pos_approv_reject_supp_seq.nextval
        INTO   l_itemkey
        FROM   dual;

        wf_event.addparametertolist(p_name          => 'PARAM1',
                                    p_value         => param1,
                                    p_parameterlist => l_parameter_list);

        wf_event.addparametertolist(p_name          => 'PARAM2',
                                    p_value         => param2,
                                    p_parameterlist => l_parameter_list);


    /*
        wf_event.raise(p_event_name => p_event_name,
                       p_event_key  => l_itemkey);
     */

             wf_event.raise(
                p_event_name     => p_event_name,
                p_event_key      => l_itemkey,
                p_parameters     => l_parameter_list);

        l_parameter_list.DELETE;

        --COMMIT;

        RETURN l_itemkey;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
        WHEN OTHERS THEN
            ROLLBACK;
    END raise_appr_rej_supp_event;
    ------------------------------------
     FUNCTION app_supp_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
        RETURN VARCHAR2 IS

        l_abc VARCHAR2(50) := 'Test';
    BEGIN

        --bu_debug_proc(01, '++ calling the approve_supplier_subscription ++ ');
        --bu_debug_proc(02, 'Event Name' || p_event.geteventname());
        --bu_debug_proc(03, 'Vendor ID' || p_event.GetValueForParameter('PARAM1'));
        --bu_debug_proc(04, 'Party ID' || p_event.GetValueForParameter('PARAM2'));


        RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
            --bu_debug_proc(999, '++ EXCEPTION ++ ' || SQLCODE || SQLERRM);
            RETURN 'FAILURE';
    END app_supp_subscription;
    ----------------------------------------
         FUNCTION app_supp_user_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
        RETURN VARCHAR2 IS

        l_abc VARCHAR2(50) := 'Test';
    BEGIN

       -- bu_debug_proc(05, '++ calling the approve_supplier_user_subscription ++ ');
      --  bu_debug_proc(06, 'Event Name' || p_event.geteventname());
       -- bu_debug_proc(07, 'Person Party ID ' || p_event.GetValueForParameter('PARAM1'));
       -- bu_debug_proc(08, 'User ID' || p_event.GetValueForParameter('PARAM2'));


        RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
          --  bu_debug_proc(999, '++ EXCEPTION ++ ' || SQLCODE || SQLERRM);
            RETURN 'FAILURE';
    END app_supp_user_subscription;
    ----------------------------------------------
         FUNCTION rej_supp_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
        RETURN VARCHAR2 IS

        l_abc VARCHAR2(50) := 'Test';
    BEGIN

       -- bu_debug_proc(09, '++ calling the reject_supplier_subscription ++ ');
       -- bu_debug_proc(10, 'Event Name' || p_event.geteventname());
       -- bu_debug_proc(11, 'Reg. ID' || p_event.GetValueForParameter('PARAM1'));

        RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
           -- bu_debug_proc(999, '++ EXCEPTION ++ ' || SQLCODE || SQLERRM);
            RETURN 'FAILURE';
    END rej_supp_subscription;
    --------------------------------------
FUNCTION rej_supp_user_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
        RETURN VARCHAR2 IS

        l_abc VARCHAR2(50) := 'Test';
    BEGIN

       -- bu_debug_proc(12, '++ calling the reject_supplier_user_subscription ++ ');
       -- bu_debug_proc(13, 'Event Name' || p_event.geteventname());
       -- bu_debug_proc(14, 'Reg. ID' || p_event.GetValueForParameter('PARAM1'));

        RETURN 'SUCCESS';

    EXCEPTION
        WHEN OTHERS THEN
           -- bu_debug_proc(999, '++ EXCEPTION ++ ' || SQLCODE || SQLERRM);
            RETURN 'FAILURE';
    END rej_supp_user_subscription;
END pos_appr_rej_supp_event_raise;

/
