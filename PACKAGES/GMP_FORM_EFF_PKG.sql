--------------------------------------------------------
--  DDL for Package GMP_FORM_EFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_FORM_EFF_PKG" AUTHID CURRENT_USER as
/* $Header: GMPDLEFS.pls 115.0 2002/12/19 15:17:55 sgidugu noship $ */

/* Procedure to Insert insert_gmp_interface  */
PROCEDURE delete_eff_rows( errbuf       out NOCOPY varchar2,
                           retcode      out NOCOPY number,
                           p_validate   IN NUMBER)  ;
PROCEDURE delete_data ( errbuf       OUT NOCOPY VARCHAR2,
                        retcode      OUT NOCOPY NUMBER,
                       p_cur_date  IN DATE ,
                       p_validate  IN NUMBER ,
                       p_dblink    IN VARCHAR2,
                       p_instance_id IN NUMBER );


END gmp_form_eff_pkg ;

 

/
