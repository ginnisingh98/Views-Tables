--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_EXCEP_INER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_EXCEP_INER_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiaers.pls 120.3.12000000.1 2007/08/01 16:15:20 npandya noship $

  PROCEDURE run_report ( p_book		IN	VARCHAR2
            ,p_period		IN	VARCHAR2
            ,p_request_id		IN	NUMBER
			,p_retcode		OUT NOCOPY NUMBER
			,p_errbuf		OUT NOCOPY VARCHAR2);

  FUNCTION get_flex_segments (p_book IN VARCHAR2 )
  RETURN BOOLEAN;

  FUNCTION get_period_name (p_book		IN	VARCHAR2
                            ,p_period		IN	VARCHAR2)
  RETURN BOOLEAN;

  END IGI_IMP_IAC_EXCEP_INER_PKG;

 

/
