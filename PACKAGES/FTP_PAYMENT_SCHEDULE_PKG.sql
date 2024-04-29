--------------------------------------------------------
--  DDL for Package FTP_PAYMENT_SCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_PAYMENT_SCHEDULE_PKG" AUTHID CURRENT_USER AS
/* $Header: ftppayis.pls 120.4 2006/03/06 03:50:20 appldev noship $ */

PROCEDURE TransferData(errbuf   OUT NOCOPY VARCHAR2,
retcode  OUT NOCOPY VARCHAR2,
isTruncate IN  VARCHAR2
);

PROCEDURE DeleteData;

PROCEDURE  Validate_Source_System (
  p_source_system_code     IN  VARCHAR2,
  x_source_system_code     OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2
) ;

PROCEDURE  Validate_Inst_Type_Code(
  p_inst_type_code	   IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2
);

END ftp_payment_schedule_pkg;


 

/
