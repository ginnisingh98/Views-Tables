--------------------------------------------------------
--  DDL for Package EDR_QUERY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_QUERY_UTIL" AUTHID CURRENT_USER as
/*  $Header: EDRGQRYS.pls 120.0.12000000.1 2007/01/18 05:53:54 appldev ship $ */
procedure GET_CLOB (
  pkval in number,
  p_load out NOCOPY VARCHAR2
);

procedure GET_LENGTH (
  pkval in number,
  len out NOCOPY number
);

procedure GET_CLOB (
  pkval in number,
  p_size in number,
  p_offset in number,
  p_load out NOCOPY VARCHAR2
);

procedure ALTER_INDEX (
  p_tag in VARCHAR2,
  p_section in VARCHAR2
);


end EDR_QUERY_UTIL;

 

/
