--------------------------------------------------------
--  DDL for Package IEU_UWQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_UTIL" AUTHID CURRENT_USER AS
/* $Header: IEUVUTLS.pls 120.0 2005/06/02 15:55:25 appldev noship $ */

PROCEDURE ADD_DATES
 (l_start_date in DATE,
  l_time_value IN NUMBER,
  l_time_uom IN VARCHAR2,
  l_final_date OUT NOCOPY DATE);

END IEU_UWQ_UTIL;


 

/
