--------------------------------------------------------
--  DDL for Package Body PNRX_C_RENT_INCREASE_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_C_RENT_INCREASE_DETAIL" AS
/* $Header: PNRXCRDB.pls 120.0 2007/10/03 14:26:03 rthumma noship $ */

PROCEDURE rent_increase_detail(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2               ,   ---lease_number_low
  argument2         IN  VARCHAR2               ,   --lease_number_high
  argument3         IN  VARCHAR2               ,   -- from_Date
  argument4         IN  VARCHAR2               ,   -- to_date
  argument5         IN  VARCHAR2               ,   --
  argument6         IN  VARCHAR2               ,
  argument7         IN  VARCHAR2               ,
  argument8         IN  VARCHAR2               ,
  argument9         IN  VARCHAR2  DEFAULT  NULL,
  argument10        IN  VARCHAR2  DEFAULT  NULL,
  argument11        IN  VARCHAR2  DEFAULT  NULL,
  argument12        IN  VARCHAR2  DEFAULT  NULL,
  argument13        IN  VARCHAR2  DEFAULT  NULL,
  argument14        IN  VARCHAR2  DEFAULT  NULL,
  argument15        IN  VARCHAR2  DEFAULT  NULL,
  argument16        IN  VARCHAR2  DEFAULT  NULL,
  argument17        IN  VARCHAR2  DEFAULT  NULL,
  argument18        IN  VARCHAR2  DEFAULT  NULL,
  argument19        IN  VARCHAR2  DEFAULT  NULL,
  argument20        IN  VARCHAR2  DEFAULT  NULL,
  argument21        IN  VARCHAR2  DEFAULT  NULL,
  argument22        IN  VARCHAR2  DEFAULT  NULL,
  argument23        IN  VARCHAR2  DEFAULT  NULL,
  argument24        IN  VARCHAR2  DEFAULT  NULL,
  argument25        IN  VARCHAR2  DEFAULT  NULL,
  argument26        IN  VARCHAR2  DEFAULT  NULL,
  argument27        IN  VARCHAR2  DEFAULT  NULL,
  argument28        IN  VARCHAR2  DEFAULT  NULL,
  argument29        IN  VARCHAR2  DEFAULT  NULL,
  argument30        IN  VARCHAR2  DEFAULT  NULL,
  argument31        IN  VARCHAR2  DEFAULT  NULL,
  argument32        IN  VARCHAR2  DEFAULT  NULL,
  argument33        IN  VARCHAR2  DEFAULT  NULL,
  argument34        IN  VARCHAR2  DEFAULT  NULL,
  argument35        IN  VARCHAR2  DEFAULT  NULL,
  argument36        IN  VARCHAR2  DEFAULT  NULL,
  argument37        IN  VARCHAR2  DEFAULT  NULL,
  argument38        IN  VARCHAR2  DEFAULT  NULL,
  argument39        IN  VARCHAR2  DEFAULT  NULL,
  argument40        IN  VARCHAR2  DEFAULT  NULL,
  argument41        IN  VARCHAR2  DEFAULT  NULL,
  argument42        IN  VARCHAR2  DEFAULT  NULL,
  argument43        IN  VARCHAR2  DEFAULT  NULL,
  argument44        IN  VARCHAR2  DEFAULT  NULL,
  argument45        IN  VARCHAR2  DEFAULT  NULL,
  argument46        IN  VARCHAR2  DEFAULT  NULL,
  argument47        IN  VARCHAR2  DEFAULT  NULL,
  argument48        IN  VARCHAR2  DEFAULT  NULL,
  argument49        IN  VARCHAR2  DEFAULT  NULL,
  argument50        IN  VARCHAR2  DEFAULT  NULL,
  argument51        IN  VARCHAR2  DEFAULT  NULL,
  argument52        IN  VARCHAR2  DEFAULT  NULL,
  argument53        IN  VARCHAR2  DEFAULT  NULL,
  argument54        IN  VARCHAR2  DEFAULT  NULL,
  argument55        IN  VARCHAR2  DEFAULT  NULL,
  argument56        IN  VARCHAR2  DEFAULT  NULL,
  argument57        IN  VARCHAR2  DEFAULT  NULL,
  argument58        IN  VARCHAR2  DEFAULT  NULL,
  argument59        IN  VARCHAR2  DEFAULT  NULL,
  argument60        IN  VARCHAR2  DEFAULT  NULL,
  argument61        IN  VARCHAR2  DEFAULT  NULL,
  argument62        IN  VARCHAR2  DEFAULT  NULL,
  argument63        IN  VARCHAR2  DEFAULT  NULL,
  argument64        IN  VARCHAR2  DEFAULT  NULL,
  argument65        IN  VARCHAR2  DEFAULT  NULL,
  argument66        IN  VARCHAR2  DEFAULT  NULL,
  argument67        IN  VARCHAR2  DEFAULT  NULL,
  argument68        IN  VARCHAR2  DEFAULT  NULL,
  argument69        IN  VARCHAR2  DEFAULT  NULL,
  argument70        IN  VARCHAR2  DEFAULT  NULL,
  argument71        IN  VARCHAR2  DEFAULT  NULL,
  argument72        IN  VARCHAR2  DEFAULT  NULL,
  argument73        IN  VARCHAR2  DEFAULT  NULL,
  argument74        IN  VARCHAR2  DEFAULT  NULL,
  argument75        IN  VARCHAR2  DEFAULT  NULL,
  argument76        IN  VARCHAR2  DEFAULT  NULL,
  argument77        IN  VARCHAR2  DEFAULT  NULL,
  argument78        IN  VARCHAR2  DEFAULT  NULL,
  argument79        IN  VARCHAR2  DEFAULT  NULL,
  argument80        IN  VARCHAR2  DEFAULT  NULL,
  argument81        IN  VARCHAR2  DEFAULT  NULL,
  argument82        IN  VARCHAR2  DEFAULT  NULL,
  argument83        IN  VARCHAR2  DEFAULT  NULL,
  argument84        IN  VARCHAR2  DEFAULT  NULL,
  argument85        IN  VARCHAR2  DEFAULT  NULL,
  argument86        IN  VARCHAR2  DEFAULT  NULL,
  argument87        IN  VARCHAR2  DEFAULT  NULL,
  argument88        IN  VARCHAR2  DEFAULT  NULL,
  argument89        IN  VARCHAR2  DEFAULT  NULL,
  argument90        IN  VARCHAR2  DEFAULT  NULL,
  argument91        IN  VARCHAR2  DEFAULT  NULL,
  argument92        IN  VARCHAR2  DEFAULT  NULL,
  argument93        IN  VARCHAR2  DEFAULT  NULL,
  argument94        IN  VARCHAR2  DEFAULT  NULL,
  argument95        IN  VARCHAR2  DEFAULT  NULL,
  argument96        IN  VARCHAR2  DEFAULT  NULL,
  argument97        IN  VARCHAR2  DEFAULT  NULL,
  argument98        IN  VARCHAR2  DEFAULT  NULL,
  argument99        IN  VARCHAR2  DEFAULT  NULL,
  argument100       IN  VARCHAR2  DEFAULT  NULL)
IS
  l_request_id  NUMBER;
  l_user_id     NUMBER;
  BEGIN
    -- Populate mandatory parameters for request_id and user_id
    l_request_id := Fnd_Global.conc_request_id;
    Fnd_Profile.get('USER_ID', l_user_id);
	 --Fnd_Profile.get('USER_ID', l_user_id);
	  Fnd_File.put_line(Fnd_File.LOG,'arg1:'||argument1);
	  Fnd_File.put_line(Fnd_File.LOG,'arg2:'||argument2);
	  Fnd_File.put_line(Fnd_File.LOG,'arg3:'||argument3);
	  Fnd_File.put_line(Fnd_File.LOG,'arg4:'||argument4);
    -- Call the inner report passing mandatory parameters (and optional parameters if any)
    pnrx_rent_increase_Detail.rent_increase_detail(
        p_lease_number_low     => argument1,
	p_lease_number_high    => argument2,
        p_ri_number_low        => argument3,
	p_ri_number_high       => argument4,
	p_assess_date_from     => fnd_date.canonical_to_date(argument5),
	p_assess_date_to       => fnd_date.canonical_to_date(argument6),
	p_location_id	       => to_number(argument7),
	p_lease_class	       => argument8,
	p_property_id	       => to_number(argument9),
	p_building_id	       => to_number(argument10),
	p_include_draft        => argument11,
	p_rent_type	       => argument12,
        l_request_id           => TO_NUMBER(l_request_id),
        l_user_id              => TO_NUMBER(l_user_id),
        retcode                => retcode,
        errbuf                 => errbuf
                   );
    COMMIT;
  END rent_increase_detail;
END pnrx_c_rent_increase_detail;

/
