--------------------------------------------------------
--  DDL for Package BEN_CWB_INTEGRATOR_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_INTEGRATOR_COPY" AUTHID CURRENT_USER as
/* $Header: bencwbic.pkh 120.0.12010000.2 2009/04/01 12:40:31 sgnanama noship $ */


PROCEDURE copy_integrator( p_group_pl_id     IN NUMBER,
			   p_integrator_code IN VARCHAR2
                        );

END BEN_CWB_INTEGRATOR_COPY;


/
