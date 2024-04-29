--------------------------------------------------------
--  DDL for Package Body ARP_TRX_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_GLOBAL" AS
/* $Header: ARTUGBLB.pls 120.3 2005/11/14 07:03:01 apandit ship $ */

------------------------------------------------------------------------
-- Private types
------------------------------------------------------------------------

--
-- Covers
--
PROCEDURE debug(  line in varchar2 ) is
BEGIN
    arp_util.debug( line );
END;
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
Procedure init is
--
-- Constructor code
--
BEGIN

    --
    -- System info
    --
    BEGIN

        system_info.system_parameters := arp_global.sysparam;
        system_info.chart_of_accounts_id := arp_global.chart_of_accounts_id;
        system_info.period_set_name := arp_global.period_set_name;
        system_info.base_currency := arp_global.functional_currency;
	system_info.base_precision := arp_global.base_precision;
	system_info.base_min_acc_unit := arp_global.base_min_acc_unit;


    EXCEPTION
        WHEN OTHERS THEN
            debug('Error getting system information');
            RAISE;
    END;


    --
    -- Profiles
    --
    BEGIN

        IF( arp_global.program_application_id IS NULL ) THEN
            profile_info.application_id := -1;
        ELSE
            profile_info.application_id := arp_global.program_application_id;
        END IF;

        IF( arp_global.program_id IS NULL ) THEN
            profile_info.conc_program_id := -1;
        ELSE
            profile_info.conc_program_id := arp_global.program_id;
        END IF;

        IF( arp_global.last_update_login IS NULL ) THEN
            profile_info.conc_login_id := -1;
        ELSE
            profile_info.conc_login_id := arp_global.last_update_login;
        END IF;

        IF( arp_global.user_id IS NULL ) THEN
            profile_info.user_id := -1;
        ELSE
            profile_info.user_id := arp_global.user_id;
        END IF;

	profile_info.request_id := arp_global.request_id;

        fnd_profile.get( 'AR_USE_INV_ACCT_FOR_CM_FLAG',
                          profile_info.use_inv_acct_for_cm_flag );

        -- OE/OM change
        -- fnd_profile.get( 'SO_ORGANIZATION_ID',
        --                 profile_info.so_organization_id );

        --Bug 4272915 : apandit
        --removed caching of the profile SO_ORGANIZATION_ID
        --where ever required we will directly get the value
        --by call to oe_profile.value()
        --
        --oe_profile.get( 'SO_ORGANIZATION_ID',
        --                 profile_info.so_organization_id );
        -- Fix 1324548
        --profile_info.so_organization_id := nvl(profile_info.so_organization_id,0);

    EXCEPTION
        WHEN OTHERS THEN
            debug('Error getting profile information');
            RAISE;
    END;

    --
    -- Acct flex info
    --
    BEGIN

        flex_info.delim :=
            arp_flex.expand(arp_flex.gl, 'FIRST', '', '%SEPARATOR%');
        flex_info.number_segments :=
            arp_flex.active_segments(arp_flex.gl);

    EXCEPTION
        WHEN OTHERS THEN
            debug('Error getting acct flex information');
            RAISE;
    END;
end init;

Begin
init;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj



END arp_trx_global;

/
