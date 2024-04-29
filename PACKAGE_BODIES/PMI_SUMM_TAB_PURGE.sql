--------------------------------------------------------
--  DDL for Package Body PMI_SUMM_TAB_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_SUMM_TAB_PURGE" AS
/* $Header: PMISTPUB.pls 115.7 2002/12/05 17:51:10 skarimis noship $ */
  PROCEDURE PURGE_SUMMARY(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2,stable in VARCHAR2) IS
  BEGIN
    IF stable = 'PMI_ONHAND_SALE_SUM' THEN
      DELETE  PMI_ONHAND_SALE_SUM;
      commit;
    ELSIF stable = 'PMI_PROD_SUM' THEN
      DELETE PMI_PROD_SUM;
      commit;
    END IF;
    DELETE PMI_SUMMARY_LOG_TABLE
    WHERE SUMMARY_TABLE = stable;
    commit;
  END;
END PMI_SUMM_TAB_PURGE;

/
