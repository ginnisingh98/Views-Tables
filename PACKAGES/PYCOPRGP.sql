--------------------------------------------------------
--  DDL for Package PYCOPRGP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYCOPRGP" AUTHID CURRENT_USER as
/* $Header: pycoprgp.pkh 115.2 2002/12/09 17:16:26 kkawol noship $ */
--
  Procedure group_submission(errbuf out nocopy varchar2,
                             retcode out nocopy number,
                             proc_group_id in number,
                             argument1 in varchar2,
                             argument2 in varchar2,
                             argument3 in varchar2,
                             argument4 in varchar2,
                             argument5 in varchar2);
end pycoprgp;

 

/
