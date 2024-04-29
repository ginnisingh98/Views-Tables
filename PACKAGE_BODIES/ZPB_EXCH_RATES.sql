--------------------------------------------------------
--  DDL for Package Body ZPB_EXCH_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_EXCH_RATES" AS
/* $Header: ZPBEXCRT.plb 120.0.12010.2 2005/12/23 06:00:05 appldev noship $ */

PROCEDURE LOAD_RATES (errbuf            OUT NOCOPY VARCHAR2,
                      retcode           OUT NOCOPY VARCHAR2,
                      p_gen_cross_rates IN VARCHAR2,
                      p_data_aw         IN VARCHAR2,
                      p_code_aw         IN VARCHAR2,
                      p_bus_area_id     IN VARCHAR2
                      )
IS
  is_attached   VARCHAR2(1);
BEGIN

  retcode := '0';
  is_attached := 'N';

-- attach the required AW in approp mode
  ZPB_AW.EXECUTE('aw attach ' ||  p_code_aw || ' ro');
  ZPB_AW.EXECUTE('aw attach ' ||  p_data_aw || ' rw');
  is_attached := 'Y';

 -- call the OLAP prog for loading the rates
 ZPB_AW.EXECUTE('call CM.LOADEXRATES(''' || p_gen_cross_rates ||''''||','||''''||p_bus_area_id||''')');

-- dettach the required AW in approp mode
  ZPB_AW.EXECUTE('aw detach ' || p_code_aw );
  ZPB_AW.EXECUTE('aw detach ' || p_data_aw );
  is_attached := 'N';

EXCEPTION
 WHEN OTHERS THEN
   retcode :='2';
   IF (is_attached = 'Y') THEN
     ZPB_AW.EXECUTE('aw detach ' ||  p_code_aw );
     ZPB_AW.EXECUTE('aw detach ' ||  p_data_aw );
   END IF;

   errbuf:= SUBSTR(sqlerrm, 1, 255);
   raise;
END LOAD_RATES;

FUNCTION LOAD_RATES_CP (p_gen_cross_rates IN VARCHAR2,
                        p_bus_area_id     IN VARCHAR2) RETURN NUMBER
IS
  l_id number;
  l_codeAW VARCHAR2(30);
  l_DataAW VARCHAR2(30);
BEGIN
  l_id := fnd_global.user_id;
  l_codeAW := zpb_aw.get_schema||'.'|| zpb_aw.get_code_aw(l_id) ;
  l_dataAW := zpb_aw.get_schema||'.'|| zpb_aw.get_shared_aw;

  -- submit the concurrent request for loading the rates
  l_id := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_LOAD_EXCH_RATES', NULL, NULL, FALSE, p_gen_cross_rates, l_dataAW, l_codeAW, p_bus_area_id   );
  return l_id;

EXCEPTION
  WHEN OTHERS THEN
	NULL;
END LOAD_RATES_CP;

END ZPB_EXCH_RATES ;

/
