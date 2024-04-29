--------------------------------------------------------
--  DDL for Package Body MSC_VALID_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_VALID_PLAN_PKG" AS
 /* $Header: MSCPVPDB.pls 120.1 2005/07/06 13:27:43 pabram noship $ */

/*----------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE msc_valid_plan (
                            arg_plan_id         IN      NUMBER,
                            arg_exploder        IN      CHAR,
                            arg_snapshot        IN      CHAR,
                            arg_planner         IN      CHAR,
                            arg_crp_planner     IN      CHAR ) IS

--  Constant declarations
    TEST_EXPLODE            CONSTANT NUMBER := 1;
    TEST_MRP_SNAPSHOT       CONSTANT NUMBER := 2;
    TEST_PLANNER            CONSTANT NUMBER := 4;
    TEST_CRP_PLANNER        CONSTANT NUMBER := 16;

    SYS_YES                 CONSTANT NUMBER := 1;
    SYS_NO                  CONSTANT NUMBER := 2;


    var_test_explode        NUMBER;
    var_test_snapshot       NUMBER;
    var_test_planner        NUMBER;
    var_test_crp_planner    NUMBER;

    var_test_level          NUMBER := 0;

    var_plan_rec            msc_plans%ROWTYPE;

    invalid_arg             exception;
    invalid_plan            exception;

BEGIN

    if arg_exploder = 'Y'
    then
        var_test_level := var_test_level + TEST_EXPLODE;
    end if;
    if arg_snapshot = 'Y'
    then
        var_test_level := var_test_level + TEST_MRP_SNAPSHOT;
    end if;
    if arg_planner = 'Y'
    then
        var_test_level := var_test_level + TEST_PLANNER;
    end if;
    if arg_crp_planner = 'Y'
    then
        var_test_level := var_test_level + TEST_CRP_PLANNER;
    end if;


    if var_test_level >= TEST_CRP_PLANNER
    then
        var_test_crp_planner := SYS_YES;
        var_test_level := var_test_level - TEST_CRP_PLANNER;
    else
        var_test_crp_planner := SYS_NO;
    end if;

    if var_test_level >= TEST_PLANNER
    then
        var_test_planner := SYS_YES;
        var_test_level := var_test_level - TEST_PLANNER;
    else
        var_test_planner := SYS_NO;
    end if;

    if var_test_level >= TEST_MRP_SNAPSHOT
    then
        var_test_snapshot := SYS_YES;
        var_test_level := var_test_level - TEST_MRP_SNAPSHOT;
    else
        var_test_snapshot := SYS_NO;
    end if;

    if var_test_level >= TEST_EXPLODE
    then
        var_test_explode := SYS_YES;
        var_test_level := var_test_level - TEST_EXPLODE;
    else
        var_test_explode := SYS_NO;
    end if;

    if var_test_level <> 0
    then
        fnd_message.set_name('MRP', 'GEN-invalid argument');
        fnd_message.set_token('ROUTINE', 'mrp_valid_plan_designator', FALSE);
        fnd_message.set_token('ARGUMENT', 'var_test_level', FALSE);
        fnd_message.set_token('VALUE', to_char(var_test_level), FALSE);
        raise invalid_arg;
    end if;

    SELECT  *
    INTO    var_plan_rec
    FROM    msc_plans
    WHERE   plan_id = arg_plan_id;

/*if var_test_explode = SYS_YES
    then
        if var_plan_rec.explosion_start_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not run');
            fnd_message.set_token('PROCESS', 'E_EXPLODER', TRUE);
            raise invalid_plan;
        elsif var_plan_rec.explosion_completion_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not completed');
            fnd_message.set_token('PROCESS', 'E_EXPLODER', TRUE);
            raise invalid_plan;
        end if;
    end if;
*/
    if var_test_snapshot = SYS_YES
    then
        if var_plan_rec.data_start_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not run');
            fnd_message.set_token('PROCESS', 'E_SNAPSHOT', TRUE);
            raise invalid_plan;
        elsif var_plan_rec.data_completion_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not completed');
            fnd_message.set_token('PROCESS', 'E_SNAPSHOT', TRUE);
            raise invalid_plan;
    /*      elsif var_plan_rec.data_completion_date <
            var_plan_rec.explosion_completion_date
        then
            fnd_message.set_name('MRP', 'GEN-process more recent');
            fnd_message.set_token('PROCESS1', 'E_EXPLODER', TRUE);
            fnd_message.set_token('PROCESS2', 'E_SNAPSHOT', TRUE);
            raise invalid_plan; */
        end if;
    end if;
    if var_test_planner = SYS_YES
    then
        if var_plan_rec.plan_start_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not run');
            fnd_message.set_token('PROCESS', 'E_PLANNER', TRUE);
            raise invalid_plan;
        elsif var_plan_rec.plan_completion_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not completed');
            fnd_message.set_token('PROCESS', 'E_PLANNER', TRUE);
            raise invalid_plan;
        elsif var_plan_rec.plan_completion_date <
            var_plan_rec.data_completion_date
        then
            fnd_message.set_name('MRP', 'GEN-process more recent');
            fnd_message.set_token('PROCESS1', 'E_SNAPSHOT', TRUE);
            fnd_message.set_token('PROCESS2', 'E_PLANNER', TRUE);
            raise invalid_plan;
        end if;
    end if;
/*
    if var_test_crp_planner = SYS_YES
    then
        if var_plan_rec.crp_plan_start_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not run');
            fnd_message.set_token('PROCESS', 'E_CRP_PLANNER', TRUE);
            raise invalid_plan;
        elsif var_plan_rec.crp_plan_completion_date IS NULL
        then
            fnd_message.set_name('MRP', 'PLAN-process not completed');
            fnd_message.set_token('PROCESS', 'E_CRP_PLANNER', TRUE);
            raise invalid_plan;
        elsif var_plan_rec.crp_plan_completion_date <
            var_plan_rec.plan_completion_date
        then
            fnd_message.set_name('MRP', 'GEN-process more recent');
            fnd_message.set_token('PROCESS1', 'E_PLANNER', TRUE);
            fnd_message.set_token('PROCESS2', 'E_CRP_PLANNER', TRUE);
            raise invalid_plan;
        end if;
    end if;
*/
EXCEPTION
    WHEN invalid_arg THEN
        app_exception.raise_exception;
    WHEN invalid_plan THEN
        app_exception.raise_exception;
END msc_valid_plan;
END msc_valid_plan_pkg;

/
