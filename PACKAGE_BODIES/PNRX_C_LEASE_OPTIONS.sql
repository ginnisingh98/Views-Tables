--------------------------------------------------------
--  DDL for Package Body PNRX_C_LEASE_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_C_LEASE_OPTIONS" AS
/* $Header: PNRXCOLB.pls 115.2 2002/11/15 20:44:45 stripath ship $ */

PROCEDURE pn_c_lease_options(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2,   --lease_number_low
  argument2         IN  VARCHAR2,   --lease_number_high
  argument3         IN  VARCHAR2,   --location_code_low
  argument4         IN  VARCHAR2,   --location_code_high
  argument5         IN  VARCHAR2,   --lease_responsible_user
  argument6         IN  VARCHAR2,   --option_type
  argument7         IN  VARCHAR2,   --exer_window_termination_from
  argument8         IN  VARCHAR2,   --exer_window_termination_to
  argument9         IN  VARCHAR2,   --lease_termination_from
  argument10        IN  VARCHAR2,   --lease_termination_to
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
    pnrx_lease_options.pn_lease_options(
          lease_number_low             =>argument1,
          lease_number_high            =>argument2,
          location_code_low            =>argument3,
          location_code_high           =>argument4,
          lease_responsible_user       =>argument5,
          option_type                  =>argument6,
          exer_window_termination_from =>FND_DATE.CANONICAL_TO_DATE(argument7),
          exer_window_termination_to   =>FND_DATE.CANONICAL_TO_DATE(argument8),
          lease_termination_from       =>FND_DATE.CANONICAL_TO_DATE(argument9),
          lease_termination_to         =>FND_DATE.CANONICAL_TO_DATE(argument10),
          l_request_id                 =>to_number(l_request_id),
          l_user_id                    =>to_number(l_user_id),
          retcode                      =>retcode,
          errbuf                       =>errbuf);
    COMMIT;
  END pn_c_lease_options;
END pnrx_c_lease_options;

/
