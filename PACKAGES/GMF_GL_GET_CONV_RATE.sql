--------------------------------------------------------
--  DDL for Package GMF_GL_GET_CONV_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_CONV_RATE" AUTHID CURRENT_USER AS
/* $Header: gmfcnvrs.pls 115.0 99/07/16 04:15:41 porting shi $ */
  FUNCTION get_conv_rate (cur_code VARCHAR2, porg_id NUMBER)
        RETURN NUMBER;
END GMF_GL_GET_CONV_RATE;

 

/
