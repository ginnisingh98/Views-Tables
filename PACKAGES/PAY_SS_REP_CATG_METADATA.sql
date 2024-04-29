--------------------------------------------------------
--  DDL for Package PAY_SS_REP_CATG_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SS_REP_CATG_METADATA" AUTHID CURRENT_USER AS
/* $Header: pyssrcmd.pkh 120.0.12000000.1 2007/07/09 12:27:35 vbattu noship $ */
--
  --------------------------------------------------------------------------------
  -- create_rep_catg_metadata
  --------------------------------------------------------------------------------
  PROCEDURE create_rep_catg_metadata(errbuf  OUT NOCOPY  VARCHAR2
                                    ,retcode OUT NOCOPY  VARCHAR2
                                    ,p_business_group_id NUMBER
                                    ,p_document_type     VARCHAR2 );

END pay_ss_rep_catg_metadata;

 

/
