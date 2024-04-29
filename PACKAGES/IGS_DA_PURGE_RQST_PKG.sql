--------------------------------------------------------
--  DDL for Package IGS_DA_PURGE_RQST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_PURGE_RQST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDA11S.pls 115.1 2003/04/22 03:56:36 ddey noship $ */
/**************************************************************************************************************************

   Change History:
   Who         When            What
   DDEY        31-March-2003
   1. Package Created for deleting the request by an Administrator and the Student.
   2. The Job is written to purge the Data, in the base tables based on the parameters passed.
******************************************************************************************************************************/


PROCEDURE delete_row(
                               p_batch_id          IN NUMBER,
                               x_status            OUT NOCOPY VARCHAR2
                     ) ;



PROCEDURE purge_request(
                               ERRBUF    OUT NOCOPY VARCHAR2 ,
                               RETCODE   OUT NOCOPY NUMBER ,
			       p_c_start_date IN VARCHAR2 ,
                               p_c_end_date IN VARCHAR2,
                               p_c_request_number IN NUMBER,
                               p_requestor_id  IN NUMBER,
                               p_responsibility IN VARCHAR2,
                               p_request_status IN VARCHAR2,
                               p_request_type IN VARCHAR2
                          ) ;


END igs_da_purge_rqst_pkg;

 

/
