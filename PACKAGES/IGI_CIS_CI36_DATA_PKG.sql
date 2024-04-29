--------------------------------------------------------
--  DDL for Package IGI_CIS_CI36_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_CI36_DATA_PKG" AUTHID CURRENT_USER as
 /* $Header: igicises.pls 115.6 2003/09/29 06:07:51 sdixit noship $ */

  PROCEDURE  Extract_data ( Errbuf            OUT NOCOPY VARCHAR2,
                            Retcode           OUT NOCOPY NUMBER,
                            x_cis_report       IN VARCHAR2,
                            x_operating_unit  IN VARCHAR2,
			    --x_sob_name         IN VARCHAR2,
                            --x_set_of_books_id  IN NUMBER,
                            x_low_date1        IN VARCHAR2,
                            x_high_date1       IN VARCHAR2,
                            x_vendor_id        IN NUMBER);


  END IGI_CIS_CI36_DATA_PKG;

 

/
