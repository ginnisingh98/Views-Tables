--------------------------------------------------------
--  DDL for Package IGR_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_IMP_001" AUTHID CURRENT_USER AS
/* $Header: IGSRT02S.pls 120.0 2005/06/01 22:05:48 appldev noship $ */

  PROCEDURE trn_ss_inq_int_data(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_inquiry_type_id IN NUMBER,
    p_inq_start_date IN VARCHAR2 DEFAULT NULL,
    p_inq_end_date IN    VARCHAR2  DEFAULT NULL
  );
END igr_imp_001;

 

/
