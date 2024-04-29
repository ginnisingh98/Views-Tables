--------------------------------------------------------
--  DDL for Package IGS_GE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_REPORT" AUTHID CURRENT_USER AS
/* $Header: IGSGE12S.pls 120.1 2005/09/30 04:13:53 appldev ship $ */

-- For Selecting the Report Information from FND_CONCURRENT_REQUESTS.

PROCEDURE GET_INFO(
  p_request_id            IN  NUMBER,
  p_report_id             OUT NOCOPY NUMBER,
  p_report_set            OUT NOCOPY VARCHAR2,
  p_responsibility        OUT NOCOPY VARCHAR2,
  p_application           OUT NOCOPY VARCHAR2,
  p_request_time          OUT NOCOPY DATE,
  p_resub_interval        OUT NOCOPY VARCHAR2,
  p_run_time              OUT NOCOPY DATE,
  p_printer               OUT NOCOPY VARCHAR2,
  p_copies                OUT NOCOPY NUMBER,
  p_save_output           OUT NOCOPY VARCHAR2 )  ;

-- For Validating Address

procedure IGS_PE_VALIDATE_ADDRESS(
  p_city		IN VARCHAR2 ,
  p_state		IN VARCHAR2 ,
  p_province		IN VARCHAR2 ,
  p_county		IN VARCHAR2 ,
  p_country		IN VARCHAR2 ,
  p_postcode		IN VARCHAR2 ,
  p_valid_address	OUT NOCOPY VARCHAR2 ,
  p_error_msg		OUT NOCOPY VARCHAR2 ) ;

END IGS_GE_REPORT;

 

/
