--------------------------------------------------------
--  DDL for Package IGI_CIS2007_CDROM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_CDROM_PKG" AUTHID CURRENT_USER AS
-- $Header: igipcrus.pls 120.0.12000000.2 2007/07/09 06:25:21 vensubra noship $

  PROCEDURE spawn_loader(p_csv_file_name IN VARCHAR2);
  PROCEDURE match_and_update(p_upl_option IN VARCHAR2);
  PROCEDURE generate_report(p_upl_option IN VARCHAR2);
  PROCEDURE import_cdrom_data_process
  (
    errbuf       OUT NOCOPY VARCHAR2,
    retcode      OUT NOCOPY NUMBER,
    p_upl_option IN VARCHAR2
  );

END igi_cis2007_cdrom_pkg;

 

/
