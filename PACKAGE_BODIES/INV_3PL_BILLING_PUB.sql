--------------------------------------------------------
--  DDL for Package Body INV_3PL_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_3PL_BILLING_PUB" AS
/* $Header: INVPBLRB.pls 120.0.12010000.1 2010/01/16 15:09:28 gjyoti noship $ */

    G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_3PL_BILLING_PUB';
    g_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    PROCEDURE debug(p_message  IN  VARCHAR2)
    IS
    BEGIN
        inv_log_util.trace(p_message, G_PKG_NAME , 10 );
    EXCEPTION
        WHEN OTHERS THEN
             NULL;
    END debug;

    FUNCTION set_billing_source_rec
          ( p_billing_source_rec source_rec_type
           ) RETURN BOOLEAN
    IS
          l_return_val BOOLEAN := FALSE;
    BEGIN
        IF g_debug = 1 THEN
            debug('In set_billing_source_rec=> Populate global g_billing_source_rec ');
        END IF;
        g_billing_source_rec := p_billing_source_rec;
        l_return_val := TRUE;
        RETURN l_return_val;
    EXCEPTION
       WHEN OTHERS THEN
            IF g_debug = 1 THEN
                debug('Exception raised => '||SQLERRM);
            END IF;
          RETURN l_return_val;
    END set_billing_source_rec;

END INV_3PL_BILLING_PUB;

/
