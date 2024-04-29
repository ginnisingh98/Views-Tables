--------------------------------------------------------
--  DDL for Package CCT_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_VALIDATION_PUB" AUTHID CURRENT_USER AS
/*$Header: cctpvals.pls 115.6 2004/04/23 19:12:05 svinamda noship $*/



PROCEDURE VALIDATE_OTM_PARAMS
(
  p_server_group_id IN NUMBER,
  p_server_id IN NUMBER,
  p_env_lang IN VARCHAR2, -- language
  p_param_ids IN IEO_STRING_VARR, -- list of param ids
  p_param_values IN IEO_STRING_VARR, -- list of param values
  x_err_msg_count OUT NOCOPY NUMBER, -- number of error messages
  x_err_msgs OUT NOCOPY IEO_STRING_VARR, -- list of error messages.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_ITS_PARAMS
(
  p_server_group_id IN NUMBER,
  p_server_id IN NUMBER,
  p_env_lang IN VARCHAR2, -- language
  p_param_ids IN IEO_STRING_VARR, -- list of param ids
  p_param_values IN IEO_STRING_VARR, -- list of param values
  x_err_msg_count OUT NOCOPY NUMBER, -- number of error messages
  x_err_msgs OUT NOCOPY IEO_STRING_VARR,  -- list of error messages.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);


PROCEDURE VALIDATE_IQD_PARAMS
(
  p_server_group_id IN NUMBER,
  p_server_id IN NUMBER,
  p_env_lang IN VARCHAR2, -- language
  p_param_ids IN IEO_STRING_VARR, -- list of param ids
  p_param_values IN IEO_STRING_VARR, -- list of param values
  x_err_msg_count OUT NOCOPY NUMBER, -- number of error messages
  x_err_msgs OUT NOCOPY IEO_STRING_VARR,  -- list of error messages.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);


END CCT_VALIDATION_PUB;

 

/
