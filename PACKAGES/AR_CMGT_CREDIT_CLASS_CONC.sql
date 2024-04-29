--------------------------------------------------------
--  DDL for Package AR_CMGT_CREDIT_CLASS_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_CREDIT_CLASS_CONC" AUTHID CURRENT_USER AS
/* $Header: ARCMCLSS.pls 115.1 2002/11/15 02:19:16 anukumar noship $ */

PROCEDURE update_credit_classification(
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_profile_class_id               IN VARCHAR2,
       p_credit_classification          IN VARCHAR2,
       p_update_flag                    IN VARCHAR2
  );


END AR_CMGT_CREDIT_CLASS_CONC;

 

/
