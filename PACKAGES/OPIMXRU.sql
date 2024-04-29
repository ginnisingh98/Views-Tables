--------------------------------------------------------
--  DDL for Package OPIMXRU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPIMXRU" AUTHID CURRENT_USER AS
/* $Header: OPIMXRUS.pls 115.1 2002/05/06 22:00:43 ltong noship $ */

PROCEDURE  extract_opi_res_util (p_from_date  DATE ,
				 p_to_date    DATE  );

END opimxru;

 

/
