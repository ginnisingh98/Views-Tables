--------------------------------------------------------
--  DDL for Package PMI_BUILD_ONHANDSALE_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_BUILD_ONHANDSALE_SUM" AUTHID CURRENT_USER AS
/* $Header: PMIOHDSS.pls 115.22 2002/12/05 17:06:59 skarimis ship $ */
/* Package Valriables to meninmise the passing parameters */
      PV_conv_uom             sy_uoms_mst.um_code%TYPE;
  PROCEDURE BUILD_SUMMARY(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2);
END PMI_BUILD_ONHANDSALE_SUM;

 

/
