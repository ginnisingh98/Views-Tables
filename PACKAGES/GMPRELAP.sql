--------------------------------------------------------
--  DDL for Package GMPRELAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMPRELAP" AUTHID CURRENT_USER AS
/* $Header: GMPRELAS.pls 120.2.12010000.2 2009/03/30 08:41:42 vpedarla ship $ */

l_profile NUMBER := 0; /* holds value of the GME Profile to use Shop calendar */

  PROCEDURE Implement_Aps_Plng_Sugg(
                                    errbuf             OUT NOCOPY VARCHAR2,
                                    retcode            OUT NOCOPY VARCHAR2,
                                    p_organization_id  IN  NUMBER  ,
                                    p_process_id       IN  NUMBER  ,
                                    p_fitem_no         IN  VARCHAR2,
                                    p_titem_no         IN  VARCHAR2,
                                    p_fdate            IN  VARCHAR2,
                                    p_tdate            IN  VARCHAR2,
                                    p_order_type       IN  NUMBER
                                  ) ;

END GMPRELAP;

/
