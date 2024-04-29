--------------------------------------------------------
--  DDL for Package Body POA_DNB_LTPRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DNB_LTPRT" AS
/* $Header: poaltpb.pls 120.0 2005/06/01 13:49:00 appldev noship $ */


PROCEDURE poa_list_all_tprt(Errbuf  in out NOCOPY Varchar2,
                            Retcode  in out NOCOPY Varchar2)
IS
  CURSOR c_all_tprt IS
     SELECT distinct TPLO_TPartner_Loc_PK TPartner_Loc_PK,
            TPRT_Name Name,
            TPLO_Address_Line1 Address_Line1,
            TPLO_Address_Line2 Address_Line2,
            TPLO_Address_Line3 Address_Line3,
            TPLO_Address_Line4 Address_Line4,
            TPLO_County County,
            TPLO_City City,
            TPLO_State State,
            TPLO_Province Province,
            TPLO_Country Country,
            TPLO_Postal_Code Postal_Code
      FROM EDW_TRD_PARTNER_M
      where ((TPLO_Business_Type = 'VENDOR SITE') and
             (TPLO_Level_Name = 'LOCATION'));

  v_buf    VARCHAR2(240) := NULL;

BEGIN

  errbuf := NULL;
  Retcode := 0;

  POA_LOG.setup('POALTPRT');
  POA_LOG.debug_line('In List All Trading Partners');

  FOR ltprt in c_all_tprt LOOP
    POA_LOG.output_line('"' ||
                        ltprt.TPartner_Loc_PK || '","' ||
                        ltprt.Name || '","' ||
                        ltprt.Address_Line1 || '","' ||
                        ltprt.Address_Line2 || '","' ||
                        ltprt.Address_Line3 || '","' ||
                        ltprt.Address_Line4 || '","' ||
                        ltprt.County || '","' ||
                        ltprt.City || '","' ||
                        NVL(ltprt.State, ltprt.Province) || '","' ||
                        ltprt.Country || '","' ||
                        ltprt.Postal_Code || '"');


  END LOOP;

  POA_LOG.put_line('POALTPRT.out generated');
  POA_LOG.wrapup('SUCCESS');

EXCEPTION WHEN OTHERS THEN
     errbuf := sqlerrm;
     retcode := sqlcode;

     POA_LOG.put_line('Error while listing Trading Partners:');
     POA_LOG.put_line(sqlcode || ': ' || sqlerrm);

     v_buf := retcode || ':' || errbuf;
     ROLLBACK;
     POA_LOG.put_line(v_buf);
     POA_LOG.wrapup('ERROR');

     RETURN;

END poa_list_all_tprt;

END POA_DNB_LTPRT;


/
