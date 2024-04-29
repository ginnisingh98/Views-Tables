--------------------------------------------------------
--  DDL for Package Body PN_RXI_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_RXI_REP" as
  -- $Header: PNRXPRGB.pls 115.3 2002/11/15 20:59:45 stripath ship $

  PROCEDURE purge (
    errbuf                  out NOCOPY             varchar2 ,
    retcode                 out NOCOPY             varchar2   ,
    p_report_name           in              varchar2   ,
    p_date_from             in              varchar2   ,
    p_date_to               in              varchar2  )

  IS

  l_date_from     date;
  l_date_to       date;

  BEGIN

    pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge(+)');

       l_date_from := fnd_date.canonical_to_date(nvl(p_date_from,'0001/01/01 00:00:00'));
       l_date_to := fnd_date.canonical_to_date(nvl(p_date_to,'4712/12/31 00:00:00'));

    IF (p_report_name = 'SPALOC') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_SPACE_ASSIGN_LOC_ITF');

     delete PN_SPACE_ASSIGN_LOC_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_SPACE_ASSIGN_LOC_ITF');

    ELSIF (p_report_name = 'SPALEA') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_SPACE_ASSIGN_LEASE_ITF');

     delete PN_SPACE_ASSIGN_LEASE_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_SPACE_ASSIGN_LEASE_ITF');

    ELSIF (p_report_name = 'SPULOC') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_SPACE_UTIL_LOC_ITF');

     delete PN_SPACE_UTIL_LOC_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_SPACE_UTIL_LOC_ITF');

    ELSIF (p_report_name = 'SPULEA') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_SPACE_UTIL_LEASE_ITF');

     delete PN_SPACE_UTIL_LEASE_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_SPACE_UTIL_LEASE_ITF');

    ELSIF (p_report_name = 'RRLEXP') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_RENT_ROLL_LEASE_EXP_ITF');

     delete PN_RENT_ROLL_LEASE_EXP_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_RENT_ROLL_LEASE_EXP_ITF');

    ELSIF (p_report_name = 'LEAOPT') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_LEASE_OPTIONS_ITF');

     delete PN_LEASE_OPTIONS_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_LEASE_OPTIONS_ITF');

    ELSIF (p_report_name = 'MILEST') THEN

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleting PN_MILESTONES_ITF');

     delete PN_MILESTONES_ITF
     where creation_date between l_date_from and l_date_to;

     pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge - deleted PN_MILESTONES_ITF');

    END IF;
    pnp_debug_pkg.put_log_msg('pnp_rxi_rep.purge(-)');

     exception
     when others then
      retcode:=2;
      errbuf:=substr(SQLERRM,1,235);
      RAISE;
   END purge;

-------------------------------
-- End of Package
-------------------------------
END PN_RXI_REP;

/
