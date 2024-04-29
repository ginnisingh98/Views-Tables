--------------------------------------------------------
--  DDL for Package Body IGI_CC_OPSFI_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CC_OPSFI_INTEGRATION" AS
/* $Header: igiaolab.pls 120.3.12000000.1 2007/07/02 08:27:49 smannava ship $ */

    PROCEDURE Switch_Options IS
    BEGIN
        NULL;
    END Switch_Options;

    FUNCTION Is_CC_On (p_org_id igi_gcc_inst_options_all.org_id%TYPE)
             RETURN BOOLEAN IS

    l_record_count         NUMBER := 0;
    l_sql_stmt             VARCHAR2(2000);

    e_table_does_not_exist EXCEPTION ;
    PRAGMA EXCEPTION_INIT(e_table_does_not_exist, -942);

    BEGIN

        -- Dynamic SQL used because if CC is not installed , the following
        -- table will not exist. Which would mean the package would be
        -- invalid.
        l_sql_stmt := ' SELECT COUNT(*) ' ||
                      ' FROM   igc_cc_routing_ctrls'||
                      ' WHERE NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV(''CLIENT_INFO''),1,1), '' '', NULL, SUBSTRB(USERENV(''CLIENT_INFO''),1,10))),-99)) '||
                      ' = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV(''CLIENT_INFO''),1,1), '' '', NULL,SUBSTRB(USERENV(''CLIENT_INFO''),1,10))),-99)';

/*
        P Org Id not used anymore for performance issues.
        Bug 2376220

        IF p_org_id IS NOT NULL
        THEN
            l_sql_stmt := l_sql_stmt || ' WHERE  org_id = ' ||p_org_id;
        END IF;
*/


        EXECUTE IMMEDIATE l_sql_stmt INTO l_record_count;

        IF l_record_count > 0
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;

    EXCEPTION
    WHEN e_table_does_not_exist
    THEN
        RETURN FALSE;

    WHEN OTHERS
    THEN
        RETURN FALSE;

    END Is_CC_On;

    FUNCTION Is_CBC_On_For_CC_PO RETURN BOOLEAN
    IS
    l_record_count         NUMBER := 0;
    l_sql_stmt             VARCHAR2(2000);

    e_table_does_not_exist EXCEPTION ;
    PRAGMA EXCEPTION_INIT(e_table_does_not_exist, -942);

    BEGIN

        -- Dynamic SQL used because if CC is not installed , the following
        -- table will not exist. Which would mean the package would be
        -- invalid.
        -- Check if CBC is enabled for CC or PO for any SOB.
        l_sql_stmt := ' SELECT COUNT(*) ' ||
                      ' FROM igc_cc_bc_enable ' ||
                      ' WHERE (NVL(cc_bc_enable_flag,''N'') = ''Y''' ||
                      ' OR NVL(cbc_po_enable, ''N'') = ''Y'')';

        EXECUTE IMMEDIATE l_sql_stmt INTO l_record_count;

        IF l_record_count > 0
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;

    EXCEPTION
    WHEN e_table_does_not_exist
    THEN
        RETURN FALSE;

    WHEN OTHERS
    THEN
        RETURN FALSE;

    END Is_CBC_On_For_CC_PO ;

END IGI_CC_OPSFI_INTEGRATION;

/
