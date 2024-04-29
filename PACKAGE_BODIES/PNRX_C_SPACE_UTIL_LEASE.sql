--------------------------------------------------------
--  DDL for Package Body PNRX_C_SPACE_UTIL_LEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_C_SPACE_UTIL_LEASE" AS
/* $Header: PNRXCLUB.pls 115.2 2002/11/15 20:34:20 stripath ship $ */

PROCEDURE pn_sp_ut_lease(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2,   --lease_number_low
  argument2         IN  VARCHAR2,   --lease_number_high
  argument3         IN  VARCHAR2,   --as_of_date
  argument4         IN  VARCHAR2,
  argument5         IN  VARCHAR2,
  argument6         IN  VARCHAR2,
  argument7         IN  VARCHAR2,
  argument8         IN  VARCHAR2,
  argument9         IN  VARCHAR2,
  argument10        IN  VARCHAR2,
  argument11        IN  VARCHAR2,
  argument12        IN  VARCHAR2,
  argument13        IN  VARCHAR2,
  argument14        IN  VARCHAR2,
  argument15        IN  VARCHAR2,
  argument16        IN  VARCHAR2,
  argument17        IN  VARCHAR2,
  argument18        IN  VARCHAR2,
  argument19        IN  VARCHAR2,
  argument20        IN  VARCHAR2,
  argument21        IN  VARCHAR2,
  argument22        IN  VARCHAR2,
  argument23        IN  VARCHAR2,
  argument24        IN  VARCHAR2,
  argument25        IN  VARCHAR2,
  argument26        IN  VARCHAR2,
  argument27        IN  VARCHAR2,
  argument28        IN  VARCHAR2,
  argument29        IN  VARCHAR2,
  argument30        IN  VARCHAR2,
  argument31        IN  VARCHAR2,
  argument32        IN  VARCHAR2,
  argument33        IN  VARCHAR2,
  argument34        IN  VARCHAR2,
  argument35        IN  VARCHAR2,
  argument36        IN  VARCHAR2,
  argument37        IN  VARCHAR2,
  argument38        IN  VARCHAR2,
  argument39        IN  VARCHAR2,
  argument40        IN  VARCHAR2,
  argument41        IN  VARCHAR2,
  argument42        IN  VARCHAR2,
  argument43        IN  VARCHAR2,
  argument44        IN  VARCHAR2,
  argument45        IN  VARCHAR2,
  argument46        IN  VARCHAR2,
  argument47        IN  VARCHAR2,
  argument48        IN  VARCHAR2,
  argument49        IN  VARCHAR2,
  argument50        IN  VARCHAR2,
  argument51        IN  VARCHAR2,
  argument52        IN  VARCHAR2,
  argument53        IN  VARCHAR2,
  argument54        IN  VARCHAR2,
  argument55        IN  VARCHAR2,
  argument56        IN  VARCHAR2,
  argument57        IN  VARCHAR2,
  argument58        IN  VARCHAR2,
  argument59        IN  VARCHAR2,
  argument60        IN  VARCHAR2,
  argument61        IN  VARCHAR2,
  argument62        IN  VARCHAR2,
  argument63        IN  VARCHAR2,
  argument64        IN  VARCHAR2,
  argument65        IN  VARCHAR2,
  argument66        IN  VARCHAR2,
  argument67        IN  VARCHAR2,
  argument68        IN  VARCHAR2,
  argument69        IN  VARCHAR2,
  argument70        IN  VARCHAR2,
  argument71        IN  VARCHAR2,
  argument72        IN  VARCHAR2,
  argument73        IN  VARCHAR2,
  argument74        IN  VARCHAR2,
  argument75        IN  VARCHAR2,
  argument76        IN  VARCHAR2,
  argument77        IN  VARCHAR2,
  argument78        IN  VARCHAR2,
  argument79        IN  VARCHAR2,
  argument80        IN  VARCHAR2,
  argument81        IN  VARCHAR2,
  argument82        IN  VARCHAR2,
  argument83        IN  VARCHAR2,
  argument84        IN  VARCHAR2,
  argument85        IN  VARCHAR2,
  argument86        IN  VARCHAR2,
  argument87        IN  VARCHAR2,
  argument88        IN  VARCHAR2,
  argument89        IN  VARCHAR2,
  argument90        IN  VARCHAR2,
  argument91        IN  VARCHAR2,
  argument92        IN  VARCHAR2,
  argument93        IN  VARCHAR2,
  argument94        IN  VARCHAR2,
  argument95        IN  VARCHAR2,
  argument96        IN  VARCHAR2,
  argument97        IN  VARCHAR2,
  argument98        IN  VARCHAR2,
  argument99        IN  VARCHAR2,
  argument100       IN  VARCHAR2)
IS
  l_request_id  NUMBER;
  l_user_id     NUMBER;
  BEGIN
    -- Populate mandatory parameters for request_id and user_id
    l_request_id := fnd_global.conc_request_id;
    fnd_profile.get('USER_ID', l_user_id);
    -- Call the inner report passing mandatory parameters (and optional parameters if any)
    pnrx_sp_util_by_lease.pn_space_util_lease(
          lease_number_low =>argument1,
          lease_number_high =>argument2,
          as_of_date=>FND_DATE.CANONICAL_TO_DATE(argument3),
          l_request_id=>to_number(l_request_id),
          l_user_id=>to_number(l_user_id),
          retcode=>retcode,
          errbuf=>errbuf);
    COMMIT;
  END pn_sp_ut_lease;
END pnrx_c_space_util_lease;

/
